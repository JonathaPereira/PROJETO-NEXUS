import { HERO_BY_ID, CLASS_BY_ID, GUARD } from "./data.js";
// Shared formula parameters; hero-specific stats/powers live in kits.js.
// Godot reads a generated copy. See godot/BALANCING.md before changing rules.
import RULES from "./balance.json" with { type: "json" };
export { RULES };
const FRACTURE_HEALING_PERCENT = RULES.fracture.healingReductionPerRound * 100;
export function advantage(from, to) {
  const c = CLASS_BY_ID[from];
  if (!c || !CLASS_BY_ID[to]) throw Error("Afinidade desconhecida.");
  return c.strongAgainst === to ? RULES.affinity.advantageMultiplier : c.weakAgainst === to ? RULES.affinity.resistanceMultiplier : RULES.affinity.neutralMultiplier;
}
export function validateTeam(ids) {
  return (
    Array.isArray(ids) &&
    ids.length === 3 &&
    new Set(ids).size === 3 &&
    ids.every((id) => Object.hasOwn(HERO_BY_ID, id))
  );
}
export function createBattle(
  team1,
  team2,
  { difficulty = "normal", seed = 73 } = {},
) {
  if (!validateTeam(team1) || !validateTeam(team2))
    throw Error("Cada equipe precisa de três personagens diferentes.");
  if (!["normal", "easy", "hard"].includes(difficulty))
    throw Error("Dificuldade inválida.");
  const units = [team1, team2].flatMap((ids, side) =>
    ids.map((heroId, slot) => {
      const hero = HERO_BY_ID[heroId],
        scale =
          side === 1 ? RULES.difficulty.enemyStatMultiplier[difficulty] : 1;
      return {
        id: `${side}-${heroId}`,
        heroId,
        side,
        slot,
        hp: Math.round(hero.hp * scale),
        maxHp: Math.round(hero.hp * scale),
        attack: Math.round(hero.attack * scale),
        defense: hero.defense,
        speed: hero.speed,
        energy: RULES.energy.initial,
        shield: 0,
        shieldTurns: 0,
        guarding: false,
        statuses: [],
        cooldowns: {},
        stats: { damage: 0, healing: 0, actions: 0, shieldDamage: 0, shieldGranted: 0, protected: 0, energyGiven: 0, combos: 0, shieldAbsorbed: 0 },
      };
    }),
  );
  const state = {
    units,
    order: [],
    cursor: 0,
    round: 1,
    phase: "playing",
    winner: null,
    log: [],
    random: seed >>> 0,
    turns: 0,
  };
  state.order = turnOrder(state);
  beginTurn(state);
  return state;
}
function turnOrder(state) {
  return state.units
    .filter((u) => u.hp > 0)
    .sort((a, b) => b.speed - a.speed || a.side - b.side || a.slot - b.slot)
    .map((u) => u.id);
}
export function currentUnit(state) {
  return state.units.find((u) => u.id === state.order[state.cursor]);
}
export function getAction(unit, id) {
  const hero = HERO_BY_ID[unit.heroId];
  return id === "guard" ? GUARD : hero[id];
}
export function canUse(unit, id) {
  const a = getAction(unit, id);
  return (
    !!a && unit.hp > 0 && unit.energy >= a.cost && !(unit.cooldowns[id] > 0)
  );
}
export const POSITIVE = ['regen','empower','fortify','cover','mirror','riposte','taunt','emberguard'];
export function friendly(action) { return /^(heal|shield|support)/.test(action.kind); }
export function legalTargets(state, actor, action) {
  if (action.kind === 'guard' || action.self) return [actor];
  let targets = state.units.filter(u => u.hp > 0 && u.side === (friendly(action) ? actor.side : 1 - actor.side));
  if (action.kind === 'damage') {
    const taunting = targets.filter(u => u.statuses.some(s => s.type === 'taunt'));
    if (taunting.length) targets = taunting;
  }
  return targets;
}
function random(state) {
  state.random = (Math.imul(state.random, 1664525) + 1013904223) >>> 0;
  return state.random / 4294967296;
}
function log(state, event) {
  state.log.push({ round: state.round, ...event });
  if (state.log.length > 100) state.log.shift();
}
function checkVictory(state) {
  for (const side of [0, 1])
    if (!state.units.some((u) => u.side === side && u.hp > 0)) {
      state.phase = "finished";
      state.winner = 1 - side;
      return true;
    }
  return false;
}
export function healingMultiplier(state, target) {
  const fracture = Math.max(0, 1 - Math.max(0, state.round - (RULES.fracture.startRound - 1)) * RULES.fracture.healingReductionPerRound);
  return fracture * (has(target, 'bleed') ? RULES.status.bleedHealingMultiplier : 1);
}
function heal(state, target, amount, metadata = {}) {
  const multiplier = healingMultiplier(state, target);
  const n = target.hp > 0 ? Math.min(target.maxHp - target.hp, Math.round(amount * multiplier)) : 0;
  target.hp += n;
  return {type:'heal',target:target.id,amount:n,healingPenalty:Math.round((1-multiplier)*100),...metadata};
}
function addStatus(target, type, owner = null) {
  if (type === "cleanse") {
    target.statuses = target.statuses.filter((s) => POSITIVE.includes(s.type));
    return;
  }
  const s = target.statuses.find((s) => s.type === type);
  if (s) { s.turns = RULES.status.durationTurns; if (type === "cover") s.owner = owner; }
  else target.statuses.push(type === "cover" ? { type, turns: RULES.status.durationTurns, owner } : { type, turns: RULES.status.durationTurns });
}
function beginTurn(state, turnEvents = []) {
  // At most six dead units can be encountered; rounds are rebuilt from survivors.
  while (state.phase === "playing") {
    if (state.cursor >= state.order.length) {
      state.round++;
      state.cursor = 0;
      state.order = turnOrder(state);
    }
    const actor = currentUnit(state);
    if (!actor || actor.hp <= 0) {
      state.cursor++;
      continue;
    }
    actor.guarding = false;
    if (actor.shield > 0 && actor.shieldTurns > 0) actor.shieldTurns--;
    const report = (event) => {
      const detail = { ...event, hpAfter: actor.hp, shieldAfter: actor.shield };
      log(state, detail);
      turnEvents.push(detail);
    };
    for (const id of Object.keys(actor.cooldowns))
      actor.cooldowns[id] = Math.max(0, actor.cooldowns[id] - 1);
    // A public, increasing hazard prevents permanent healing/barrier stalemates.
    // It bypasses barriers and is resolved before regeneration, never reviving a casualty.
    if (state.round >= RULES.fracture.startRound) {
      const amount = Math.min(
        actor.hp,
        Math.ceil(
          actor.maxHp * Math.min(RULES.fracture.maxHpRatioCap, RULES.fracture.initialMaxHpRatio + (state.round - RULES.fracture.startRound) * RULES.fracture.perRoundMaxHpRatio),
        ),
      );
      actor.hp -= amount;
      report({
        type: "fracture",
        actor: actor.id,
        target: actor.id,
        amount,
        healingPenalty: Math.min(100, (state.round - (RULES.fracture.startRound - 1)) * FRACTURE_HEALING_PERCENT),
      });
      if (actor.hp <= 0)
        report({ type: "defeated", actor: actor.id, target: actor.id });
    }
    for (const s of actor.statuses) {
      if (actor.hp <= 0) break;
      if (s.turns <= 0) continue;
      if (s.type === "burn" || s.type === "bleed") {
        const n = Math.min(actor.hp, Math.round(actor.maxHp * (s.type === 'burn' ? RULES.status.burnMaxHpRatio : RULES.status.bleedMaxHpRatio)));
        actor.hp -= n;
        report({
          type: s.type,
          actor: actor.id,
          target: actor.id,
          amount: n,
          remaining: s.turns - 1,
        });
        if (actor.hp <= 0) {
          report({ type: "defeated", actor: actor.id, target: actor.id });
          break;
        }
      }
      if (s.type === "regen") {
        report({
          ...heal(state, actor, actor.maxHp * RULES.status.regenMaxHpRatio),
          actor: actor.id,
          passive: true,
          remaining: s.turns - 1,
        });
      }
      s.turns--;
    }
    // Stat effects last through the affected actor's action, including their last turn.
    actor.statuses = actor.statuses.filter((s) => s.turns > 0 ||
      (s.turns === 0 && !["burn", "bleed", "regen"].includes(s.type)));
    if (checkVictory(state)) return;
    if (actor.hp <= 0) {
      state.cursor++;
      continue;
    }
    return;
  }
}
function has(unit, type) { return unit.statuses.some(s => s.type === type); }
function remove(unit, type) { unit.statuses = unit.statuses.filter(s => s.type !== type); }
// One finite shield per unit: stronger value wins; weaker applications do not extend it.
export const SHIELD_CAP = RULES.shield.maxHpRatio;
function shield(unit, power) {
  const before = unit.shield;
  const grant = Math.min(Math.round(unit.maxHp * SHIELD_CAP), Math.round(unit.maxHp * power));
  const remaining = unit.shieldTurns === 0 ? 0 : before;
  if (grant >= remaining) unit.shieldTurns = RULES.shield.durationActions;
  unit.shield = Math.max(remaining, grant);
  return {type:'shield',target:unit.id,amount:unit.shield-remaining,shieldBefore:before,shieldAfter:unit.shield,shieldTurns:unit.shieldTurns};
}
function hit(target, total, pierce = 0, metadata = {}) {
  const before = target.shield;
  const absorbed = Math.min(before, total - Math.round(total * pierce));
  target.shield -= absorbed;
  if (target.shield === 0) target.shieldTurns = 0;
  target.stats.shieldAbsorbed += absorbed;
  const amount = Math.min(target.hp, total - absorbed);
  target.hp -= amount;
  return {type:'damage',target:target.id,amount,absorbed,advantage:1,critical:false,total,shieldBefore:before,shieldAfter:target.shield,hpAfter:target.hp,...metadata};
}
export function act(state, actionId, targetId, criticalOverride = null) {
  if (state.phase !== 'playing') throw Error('A batalha terminou.');
  const actor = currentUnit(state);
  if (!canUse(actor, actionId)) throw Error('Ação indisponível: energia ou recarga.');
  const action = getAction(actor, actionId), targets = legalTargets(state, actor, action);
  const selected = targets.find(t => t.id === targetId);
  if (!selected) throw Error('Escolha um alvo válido.');
  const hero = HERO_BY_ID[actor.heroId], events = [];
  const emit = event => { events.push(event); log(state,{...event,actor:actor.id}); };
  actor.energy -= action.cost;
  actor.stats.actions++; state.turns++;
  if (action.cooldown) actor.cooldowns[actionId] = action.cooldown + 1;
  log(state,{type:'action',actor:actor.id,name:action.name,actionId});
  const recipients = ['aoe','healAll','shieldAll','supportAll'].includes(action.kind) ? targets : [selected];
  const boostedSecondary = action.secondary?.whenStatus && recipients.some(t => has(t,action.secondary.whenStatus));
  const storedShield = action.shieldScale ? actor.shield : 0;
  if (storedShield) { actor.shield = 0; actor.shieldTurns = 0; emit({type:'converted',target:actor.id,shieldSpent:storedShield}); }
  if (action.kind === 'guard') {
    actor.guarding = true;
    const e = shield(actor,RULES.guard.shieldMaxHpRatio); e.type = 'guard'; emit(e);
    actor.stats.shieldGranted += e.amount;
    actor.energy = Math.min(RULES.energy.maximum,actor.energy+RULES.energy.guardGain);
  } else {
    for (const target of recipients) {
      let event;
      if (action.kind.startsWith('heal')) {
        event = heal(state,target,target.maxHp*action.power);
        actor.stats.healing += event.amount;
      } else if (action.kind.startsWith('shield')) {
        event = shield(target,action.power); actor.stats.shieldGranted += event.amount;
      } else if (action.kind.startsWith('support')) {
        event = {type:'support',target:target.id,amount:0};
      } else {
        const weak = has(actor,'weaken') ? RULES.status.weakenAttackMultiplier : 1, empowered = has(actor,'empower') ? RULES.status.empowerAttackMultiplier : 1;
        const defense = target.defense * (has(target,'expose') ? RULES.status.exposeDefenseMultiplier : 1) * (hero.classId === 'arcano' ? RULES.classPassives.arcanoDefenseMultiplier : 1);
        const multiplier = advantage(hero.classId,HERO_BY_ID[target.heroId].classId);
        let critical = random(state) < RULES.critical.chance;
        if (criticalOverride !== null) critical = criticalOverride;
        let bonus = 1, combo = '';
        if (action.combo && has(target,action.combo.status)) {
          bonus *= action.combo.multiplier; combo = action.combo.status; actor.stats.combos++;
          if (action.combo.consume) remove(target,action.combo.status);
        }
        if (has(target,'focus')) { bonus *= RULES.status.focusDamageMultiplier; remove(target,'focus'); combo = combo || 'focus'; actor.stats.combos++; }
        if (action.executeThreshold && target.hp / target.maxHp < action.executeThreshold) { bonus *= action.executeMultiplier; combo = combo || 'execute'; actor.stats.combos++; }
        // Order matters: one rounding after offense, defense, affinity and bonuses.
        let total = Math.max(RULES.damage.minimumHit, Math.round(
          (actor.attack * weak * empowered * action.power + storedShield * (action.shieldScale || 0))
          * RULES.damage.defenseBaseline / (RULES.damage.defenseBaseline + defense * RULES.damage.defenseWeight)
          * multiplier
          * (target.guarding ? RULES.guard.incomingDamageMultiplier : 1)
          * (has(target, 'fortify') ? RULES.status.fortifyIncomingDamageMultiplier : 1)
          * bonus * (critical ? RULES.critical.damageMultiplier : 1)
        ));
        const protection = action.kind === 'damage' && target.statuses.find(s => s.type === 'cover');
        const guardian = protection && state.units.find(u => u.id === protection.owner && u.hp > 0 && u.side === target.side && u.id !== target.id);
        if (guardian) {
          const share = Math.round(total*RULES.status.coverRedirectRatio); total -= share;
          const e = hit(guardian,share,action.pierce||0,{intercepted:true}); emit(e);
          guardian.stats.protected += e.amount; actor.stats.damage += e.amount; actor.stats.shieldDamage += e.absorbed;
          if (!guardian.hp) emit({type:'defeated',target:guardian.id});
        }
        event = hit(target,total,action.pierce||0,{advantage:multiplier,critical});
        if (combo) event.combo = combo;
        actor.stats.damage += event.amount; actor.stats.shieldDamage += event.absorbed;
        if (has(target,'seed') && actor.hp > 0) {
          remove(target,'seed'); const receipt = heal(state,actor,actor.maxHp*RULES.status.seedHealMaxHpRatio,{passive:true,source:'seed'});
          emit(receipt); actor.stats.healing += receipt.amount;
        }
        if (hero.classId === 'sombrio' && event.amount > 0 && actor.hp > 0) {
          const receipt = heal(state,actor,event.amount*RULES.classPassives.sombrioDrainRatio,{passive:true,source:'drain'});
          if (receipt.amount) { emit(receipt); actor.stats.healing += receipt.amount; }
        }
        if (target.hp > 0 && actor.hp > 0) {
          const retaliation = (has(target,'mirror') ? Math.round(event.amount*RULES.status.mirrorDamageRatio) : 0) + (has(target,'riposte') ? Math.round(target.attack*RULES.status.riposteAttackRatio) : 0);
          if (retaliation > 0) {
            const e = hit(actor,retaliation,0,{reaction:true}); emit(e);
            target.stats.damage += e.amount; target.stats.shieldDamage += e.absorbed;
            if (!actor.hp) emit({type:'defeated',target:actor.id});
          }
          if (has(target,'emberguard') && actor.hp > 0) { addStatus(actor,'burn'); emit({type:'status',target:actor.id,effect:'burn',effectTurns:RULES.status.durationTurns,source:'emberguard'}); }
        }
      }
      if (target.hp > 0) {
        for (const effect of [action.effect,action.extraEffect].filter(Boolean)) {
          if (!event.effect) { event.effect = effect; event.effectTurns = effect === 'cleanse' ? 0 : RULES.status.durationTurns; }
          else event.extraEffect = effect;
          if (effect === 'cleanse') event.cleansed = target.statuses.filter(s => !POSITIVE.includes(s.type)).map(s => s.type);
          addStatus(target,effect,actor.id);
        }
      }
      emit(event);
      if (!target.hp) emit({type:'defeated',target:target.id});
    }
    const extra = action.secondary;
    if (extra && actor.hp > 0) {
      const allies = state.units.filter(u => u.side === actor.side && u.hp > 0);
      const destinations = extra.target === 'allies' ? allies : extra.target === 'actor' ? [actor] : extra.target === 'lowestAlly' ? [[...allies].sort((a,b)=>a.hp/a.maxHp-b.hp/b.maxHp)[0]] : [selected];
      for (const target of destinations) {
        if (target.hp <= 0) continue;
        const power = (extra.power||0) * (boostedSecondary ? extra.multiplier : 1);
        if (extra.kind === 'heal') { const receipt = heal(state,target,target.maxHp*power,{source:'secondary'}); actor.stats.healing += receipt.amount; emit(receipt); }
        if (extra.kind === 'shield') { const e = shield(target,power); actor.stats.shieldGranted += e.amount; emit(e); }
        if (extra.kind === 'energy') { const amount = Math.min(RULES.energy.maximum-target.energy,extra.amount); target.energy += amount; actor.stats.energyGiven += amount; emit({type:'energy',target:target.id,amount,energyAfter:target.energy}); }
      }
    }
    if (actionId === 'basic') actor.energy = Math.min(RULES.energy.maximum,actor.energy+RULES.energy.basicGain);
  }
  if (actor.shield > 0 && actor.shieldTurns === 0) {
    const amount = actor.shield; actor.shield = 0;
    emit({type:'shieldExpired',target:actor.id,amount,shieldAfter:0});
  }
  actor.statuses = actor.statuses.filter(s => s.turns > 0);
  const impactUnits = structuredClone(state.units), turnEvents = [];
  if (!checkVictory(state)) { state.cursor++; beginTurn(state,turnEvents); }
  return {actor:actor.id,heroId:actor.heroId,actionId,animation:hero.animation,events,impactUnits,turnEvents};
}
export function preview(state, actionId, targetId) {
  return {normal:act(structuredClone(state),actionId,targetId,false),critical:act(structuredClone(state),actionId,targetId,true)};
}
export function chooseAI(state) {
  const actor = currentUnit(state);
  if (!actor || state.phase !== 'playing') return null;
  const hero = HERO_BY_ID[actor.heroId];
  for (const actionId of ['ultimate','skill','basic']) {
    if (!canUse(actor,actionId)) continue;
    const action = getAction(actor,actionId), targets = legalTargets(state,actor,action);
    if (friendly(action)) {
      let target;
      if (action.kind.startsWith('heal')) {
        target = [...targets].sort((a,b)=>a.hp/a.maxHp-b.hp/b.maxHp)[0];
        const cleansing = action.effect === 'cleanse' && targets.some(t=>t.statuses.some(s=>!POSITIVE.includes(s.type)));
        if ((target.hp/target.maxHp >= RULES.ai.healingHealthThreshold || healingMultiplier(state,target) === 0) && !cleansing) continue;
      } else if (action.kind.startsWith('shield')) {
        target = targets.find(t=>t.shield<t.maxHp*RULES.ai.shieldRefreshMaxHpRatio || (action.effect && !has(t,action.effect)));
        if (!target) continue;
      } else {
        target = [...targets].sort((a,b)=>a.energy-b.energy)[0];
        if (target.energy > RULES.ai.supportEnergyThreshold && !targets.some(t=>t.statuses.some(s=>!POSITIVE.includes(s.type)))) continue;
      }
      return {actionId,targetId:target.id};
    }
    const score = t => (t.hp+t.shield) / (advantage(hero.classId,HERO_BY_ID[t.heroId].classId) * (action.combo && has(t,action.combo.status) ? action.combo.multiplier : 1));
    const target = [...targets].sort((a,b)=>score(a)-score(b))[0];
    return {actionId,targetId:target.id};
  }
  return {actionId:'guard',targetId:actor.id};
}
