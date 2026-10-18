import { HERO_BY_ID, CLASS_BY_ID, GUARD } from "./data.js";
export function advantage(from, to) {
  const c = CLASS_BY_ID[from];
  if (!c || !CLASS_BY_ID[to]) throw Error("Afinidade desconhecida.");
  return c.strongAgainst === to ? 1.25 : c.weakAgainst === to ? 0.85 : 1;
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
          side === 1 ? { easy: 0.82, normal: 1, hard: 1.15 }[difficulty] : 1;
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
        energy: 40,
        shield: 0,
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
function heal(target, amount) {
  const n = Math.min(target.maxHp - target.hp, Math.round(amount));
  target.hp += n;
  return n;
}
function addStatus(target, type, owner = null) {
  if (type === "cleanse") {
    target.statuses = target.statuses.filter((s) => POSITIVE.includes(s.type));
    return;
  }
  const s = target.statuses.find((s) => s.type === type);
  if (s) { s.turns = 2; if (type === "cover") s.owner = owner; }
  else target.statuses.push(type === "cover" ? { type, turns: 2, owner } : { type, turns: 2 });
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
    const report = (event) => {
      const detail = { ...event, hpAfter: actor.hp, shieldAfter: actor.shield };
      log(state, detail);
      turnEvents.push(detail);
    };
    for (const id of Object.keys(actor.cooldowns))
      actor.cooldowns[id] = Math.max(0, actor.cooldowns[id] - 1);
    // A public, increasing hazard prevents permanent healing/barrier stalemates.
    // It bypasses barriers and is resolved before regeneration, never reviving a casualty.
    if (state.round >= 12) {
      const amount = Math.min(
        actor.hp,
        Math.ceil(
          actor.maxHp * Math.min(0.85, 0.04 + (state.round - 12) * 0.025),
        ),
      );
      actor.hp -= amount;
      report({
        type: "fracture",
        actor: actor.id,
        target: actor.id,
        amount,
      });
      if (actor.hp <= 0)
        report({ type: "defeated", actor: actor.id, target: actor.id });
    }
    for (const s of actor.statuses) {
      if (actor.hp <= 0) break;
      if (s.turns <= 0) continue;
      if (s.type === "burn" || s.type === "bleed") {
        const n = Math.min(actor.hp, Math.round(actor.maxHp * 0.065));
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
        const n = heal(actor, actor.maxHp * 0.07);
        report({
          type: "heal",
          actor: actor.id,
          target: actor.id,
          amount: n,
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
function shield(unit, power) {
  const before = unit.shield;
  unit.shield = Math.min(Math.round(unit.maxHp * .6), before + Math.round(unit.maxHp * power));
  return {type:'shield',target:unit.id,amount:unit.shield-before,shieldBefore:before,shieldAfter:unit.shield};
}
function hit(target, total, pierce = 0, metadata = {}) {
  const before = target.shield;
  const absorbed = Math.min(before, total - Math.round(total * pierce));
  target.shield -= absorbed;
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
  if (storedShield) { actor.shield = 0; emit({type:'converted',target:actor.id,shieldSpent:storedShield}); }
  if (action.kind === 'guard') {
    actor.guarding = true;
    const e = shield(actor,.12); e.type = 'guard'; emit(e);
    actor.stats.shieldGranted += e.amount;
    actor.energy = Math.min(100,actor.energy+25);
  } else {
    for (const target of recipients) {
      let event;
      if (action.kind.startsWith('heal')) {
        const amount = heal(target,target.maxHp*action.power);
        actor.stats.healing += amount;
        event = {type:'heal',target:target.id,amount};
      } else if (action.kind.startsWith('shield')) {
        event = shield(target,action.power); actor.stats.shieldGranted += event.amount;
      } else if (action.kind.startsWith('support')) {
        event = {type:'support',target:target.id,amount:0};
      } else {
        const weak = has(actor,'weaken') ? .8 : 1, empowered = has(actor,'empower') ? 1.2 : 1;
        const defense = target.defense * (has(target,'expose') ? .75 : 1) * (hero.classId === 'arcano' ? .75 : 1);
        const multiplier = advantage(hero.classId,HERO_BY_ID[target.heroId].classId);
        let critical = random(state) < .1;
        if (criticalOverride !== null) critical = criticalOverride;
        let bonus = 1, combo = '';
        if (action.combo && has(target,action.combo.status)) {
          bonus *= action.combo.multiplier; combo = action.combo.status; actor.stats.combos++;
          if (action.combo.consume) remove(target,action.combo.status);
        }
        if (has(target,'focus')) { bonus *= 1.25; remove(target,'focus'); combo = combo || 'focus'; actor.stats.combos++; }
        if (action.executeThreshold && target.hp / target.maxHp < action.executeThreshold) { bonus *= action.executeMultiplier; combo = combo || 'execute'; actor.stats.combos++; }
        let total = Math.max(1,Math.round((actor.attack*weak*empowered*action.power+storedShield*(action.shieldScale||0)) * 100/(100+defense*.5) * multiplier * (target.guarding ? .65 : 1) * (has(target,'fortify')?.8:1) * bonus * (critical?1.4:1)));
        const protection = action.kind === 'damage' && target.statuses.find(s => s.type === 'cover');
        const guardian = protection && state.units.find(u => u.id === protection.owner && u.hp > 0 && u.side === target.side && u.id !== target.id);
        if (guardian) {
          const share = Math.round(total*.35); total -= share;
          const e = hit(guardian,share,action.pierce||0,{intercepted:true}); emit(e);
          guardian.stats.protected += e.amount; actor.stats.damage += e.amount; actor.stats.shieldDamage += e.absorbed;
          if (!guardian.hp) emit({type:'defeated',target:guardian.id});
        }
        event = hit(target,total,action.pierce||0,{advantage:multiplier,critical});
        if (combo) event.combo = combo;
        actor.stats.damage += event.amount; actor.stats.shieldDamage += event.absorbed;
        if (has(target,'seed') && actor.hp > 0) {
          remove(target,'seed'); const amount = heal(actor,actor.maxHp*.1);
          emit({type:'heal',target:actor.id,amount,passive:true,source:'seed'}); actor.stats.healing += amount;
        }
        if (hero.classId === 'sombrio' && event.amount > 0 && actor.hp > 0) {
          const amount = heal(actor,event.amount*.25);
          if (amount) { emit({type:'heal',target:actor.id,amount,passive:true,source:'drain'}); actor.stats.healing += amount; }
        }
        if (target.hp > 0 && actor.hp > 0) {
          const retaliation = (has(target,'mirror') ? Math.round(event.amount*.2) : 0) + (has(target,'riposte') ? Math.round(target.attack*.4) : 0);
          if (retaliation > 0) {
            const e = hit(actor,retaliation,0,{reaction:true}); emit(e);
            target.stats.damage += e.amount; target.stats.shieldDamage += e.absorbed;
            if (!actor.hp) emit({type:'defeated',target:actor.id});
          }
          if (has(target,'emberguard') && actor.hp > 0) { addStatus(actor,'burn'); emit({type:'status',target:actor.id,effect:'burn',effectTurns:2,source:'emberguard'}); }
        }
      }
      if (target.hp > 0) {
        for (const effect of [action.effect,action.extraEffect].filter(Boolean)) {
          if (!event.effect) { event.effect = effect; event.effectTurns = effect === 'cleanse' ? 0 : 2; }
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
        if (extra.kind === 'heal') { const amount = heal(target,target.maxHp*power); actor.stats.healing += amount; emit({type:'heal',target:target.id,amount,source:'secondary'}); }
        if (extra.kind === 'shield') { const e = shield(target,power); actor.stats.shieldGranted += e.amount; emit(e); }
        if (extra.kind === 'energy') { const amount = Math.min(100-target.energy,extra.amount); target.energy += amount; actor.stats.energyGiven += amount; emit({type:'energy',target:target.id,amount,energyAfter:target.energy}); }
      }
    }
    if (actionId === 'basic') actor.energy = Math.min(100,actor.energy+24);
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
        if (target.hp/target.maxHp >= .78 && !(action.effect === 'cleanse' && targets.some(t=>t.statuses.some(s=>!POSITIVE.includes(s.type))))) continue;
      } else if (action.kind.startsWith('shield')) {
        target = targets.find(t=>t.shield<t.maxHp*.14 || (action.effect && !has(t,action.effect)));
        if (!target) continue;
      } else {
        target = [...targets].sort((a,b)=>a.energy-b.energy)[0];
        if (target.energy > 75 && !targets.some(t=>t.statuses.some(s=>!POSITIVE.includes(s.type)))) continue;
      }
      return {actionId,targetId:target.id};
    }
    const score = t => (t.hp+t.shield) / (advantage(hero.classId,HERO_BY_ID[t.heroId].classId) * (action.combo && has(t,action.combo.status) ? action.combo.multiplier : 1));
    const target = [...targets].sort((a,b)=>score(a)-score(b))[0];
    return {actionId,targetId:target.id};
  }
  return {actionId:'guard',targetId:actor.id};
}
