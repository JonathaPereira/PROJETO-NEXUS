import { test } from "node:test";
import assert from "node:assert/strict";
import {
  HEROES,
  HERO_BY_ID,
  CLASSES,
  CLASS_BY_ID,
  DEFAULT_TEAMS,
} from "../src/data.js";
import {
  createBattle,
  currentUnit,
  advantage,
  canUse,
  legalTargets,
  getAction,
  act,
  chooseAI,
  validateTeam,
} from "../src/engine.js";

test("24 original starters form six fixed classes with four complete kits each", () => {
  assert.equal(HEROES.length, 24);
  assert.equal(new Set(HEROES.map((h) => h.id)).size, 24);
  assert.equal(new Set(HEROES.map((h) => h.animation)).size, 24);
  for (const c of CLASSES)
    assert.equal(HEROES.filter((h) => h.classId === c.id).length, 4);
  for (const h of HEROES) {
    for (const action of ["basic", "skill", "ultimate"])
      assert(h[action].name && h[action].description);
    assert(h.hp > 0 && h.attack > 0 && h.defense > 0 && h.speed > 0);
    if (h.skill.kind.startsWith("heal") || h.skill.kind.startsWith("shield"))
      assert(
        ["regen", "cleanse"].includes(h.skill.effect),
        `${h.id} must not debuff allies`,
      );
  }
});
test("regeneration heals on exactly two personal turns and purification removes only negative effects", () => {
  const state = createBattle(...DEFAULT_TEAMS),
    first = currentUnit(state);
  first.hp -= 400;
  first.statuses = [{ type: "regen", turns: 2 }];
  const before = first.hp;
  act(state, "guard", first.id);
  let visits = 0;
  while (visits < 3) {
    const actor = currentUnit(state);
    if (actor.id === first.id) {
      visits++;
      assert.equal(
        first.hp,
        before + Math.round(first.maxHp * 0.07) * Math.min(visits, 2),
      );
      if (visits === 3) break;
    }
    act(state, "guard", actor.id);
  }
  const cleansing = createBattle(
    ["elyra", "bast", "oren"],
    ["rhazen", "noct", "axion"],
  );
  const healer = currentUnit(cleansing),
    target = cleansing.units[1];
  target.hp = 500;
  target.statuses = ["burn", "regen", "expose", "weaken"].map((type) => ({
    type,
    turns: 2,
  }));
  act(cleansing, "skill", target.id);
  assert.equal(
    target.hp,
    Math.min(target.maxHp, 500 + Math.round(target.maxHp * 0.36)),
  );
  assert.deepEqual(
    target.statuses.map((s) => s.type),
    ["regen"],
  );
  assert.equal(healer.heroId, "elyra");
});
test("Nexus fracture starts on round twelve, bypasses barriers and stops defensive stalemates", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    actor = currentUnit(s);
  s.round = 11;
  s.order = [actor.id];
  s.cursor = 0;
  const hp = actor.hp;
  act(s, "guard", actor.id);
  assert.equal(s.round, 12);
  assert.equal(actor.hp, hp - Math.ceil(actor.maxHp * 0.04));
  assert(actor.shield > 0);
  assert(s.log.some((e) => e.type === "fracture" && e.target === actor.id));
  const defensive = createBattle(
    ["sylva", "elyra", "brin"],
    ["saira", "zaya", "oren"],
  );
  while (defensive.phase === "playing" && defensive.turns < 400)
    act(defensive, "guard", currentUnit(defensive).id);
  assert.equal(defensive.phase, "finished");
});
test("all six edges have +25% offense and the reverse has −15%, with neutral unrelated classes", () => {
  for (const c of CLASSES) {
    assert.equal(advantage(c.id, CLASS_BY_ID[c.id].strongAgainst), 1.25);
    assert.equal(advantage(CLASS_BY_ID[c.id].strongAgainst, c.id), 0.85);
    assert.equal(advantage(c.id, c.id), 1);
  }
  assert.equal(advantage("igneo", "arcano"), 1);
  assert.throws(() => advantage("unknown", "lumi"));
});
test("a team has exactly three known, distinct characters; mirrors across teams remain legal", () => {
  assert(validateTeam(DEFAULT_TEAMS[0]));
  assert(!validateTeam(["veyra", "veyra", "astra"]));
  assert(!validateTeam(["veyra", "astra"]));
  assert(!validateTeam(["veyra", "astra", "invalid"]));
  assert.throws(() => createBattle(["veyra"], DEFAULT_TEAMS[1]));
  assert.doesNotThrow(() => createBattle(DEFAULT_TEAMS[0], DEFAULT_TEAMS[0]));
});
test("initiative is ordered by speed; an action advances to the next living hero", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    first = currentUnit(s);
  assert.equal(first.heroId, "veyra");
  const t = legalTargets(s, first, getAction(first, "basic"))[0];
  act(s, "basic", t.id);
  assert.equal(currentUnit(s).heroId, "vesper");
  assert.equal(s.turns, 1);
  assert.equal(first.energy, 64);
});
test("invalid targets and unavailable actions leave resources, HP and turn untouched", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    actor = currentUnit(s),
    before = structuredClone(s);
  assert.throws(() => act(s, "ultimate", s.units[3].id), /indisponível/);
  assert.deepEqual(s, before);
  assert.throws(() => act(s, "basic", actor.id), /alvo válido/);
  assert.deepEqual(s, before);
});
test("technique spends energy and remains unavailable for two personal turns", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    first = currentUnit(s);
  first.energy = 100;
  act(s, "skill", s.units[3].id);
  assert.equal(first.energy, 70);
  assert.equal(first.cooldowns.skill, 3);
  let turns = 0;
  while (turns < 3 && s.phase === "playing") {
    const actor = currentUnit(s);
    if (actor.id === first.id) {
      turns++;
      assert.equal(canUse(first, "skill"), turns >= 3);
      if (turns === 3) break;
    }
    act(s, "guard", actor.id);
  }
  assert.equal(turns, 3);
});
test("guard gains a capped barrier, restores energy and reduces incoming damage", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    actor = currentUnit(s);
  actor.shield = actor.maxHp * 0.59;
  actor.energy = 90;
  act(s, "guard", actor.id);
  assert(actor.guarding);
  assert(actor.shield <= actor.maxHp * 0.6);
  assert.equal(actor.energy, 100);
  const rival = currentUnit(s),
    before = actor.hp;
  const result = act(s, "basic", actor.id);
  assert.equal(actor.hp, before);
  assert(result.events.find((e) => e.type === "damage").absorbed > 0);
  assert(rival.energy <= 100);
});
test("targeted healing cannot revive defeated heroes or select enemies", () => {
  const s = createBattle(
    ["elyra", "oren", "bast"],
    ["rhazen", "noct", "axion"],
  );
  const actor = currentUnit(s);
  assert.equal(actor.heroId, "elyra");
  s.units[1].hp -= 600;
  s.units[2].hp = 0;
  const legal = legalTargets(s, actor, getAction(actor, "skill"));
  assert(!legal.includes(s.units[2]));
  assert(!legal.some((u) => u.side === 1));
  const before = s.units[1].hp;
  act(s, "skill", s.units[1].id);
  assert(s.units[1].hp > before);
  assert(s.units[1].hp <= s.units[1].maxHp);
  assert.equal(s.units[2].hp, 0);
});
test("a damaging supreme hits every living rival and consumes exactly 80 energy", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    actor = currentUnit(s);
  actor.energy = 100;
  const before = s.units.filter((u) => u.side === 1).map((u) => u.hp);
  const result = act(s, "ultimate", s.units[3].id);
  assert.equal(actor.energy, 20);
  assert.equal(result.events.filter((e) => e.type === "damage").length, 3);
  s.units
    .filter((u) => u.side === 1)
    .forEach((u, i) => assert(u.hp < before[i]));
});
test("Sombrio lifesteal restores real health without exceeding maximum", () => {
  const s = createBattle(
      ["vesper", "noct", "rhazen"],
      ["elyra", "oren", "bast"],
    ),
    actor = currentUnit(s);
  actor.hp -= 400;
  const before = actor.hp;
  const result = act(s, "basic", s.units[3].id);
  const dmg = result.events.find((e) => e.type === "damage");
  assert.equal(actor.hp - before, Math.round(dmg.amount * 0.25));
});
test("burn and regeneration tick for exactly two turns; burn death never resurrects", () => {
  const s = createBattle(...DEFAULT_TEAMS),
    first = currentUnit(s);
  first.statuses = [{ type: "burn", turns: 2 }];
  const before = first.hp;
  act(s, "guard", first.id);
  let visits = 0;
  while (visits < 3) {
    const actor = currentUnit(s);
    if (actor.id === first.id) {
      visits++;
      assert.equal(
        first.hp,
        before - Math.round(first.maxHp * 0.065) * Math.min(visits, 2),
      );
      if (visits === 3) break;
    }
    act(s, "guard", actor.id);
  }
  const death = createBattle(...DEFAULT_TEAMS),
    victim = death.units.find((u) => u.heroId === "vesper");
  victim.hp = 1;
  victim.statuses = [
    { type: "burn", turns: 2 },
    { type: "regen", turns: 2 },
  ];
  act(
    death,
    "basic",
    death.units.find((u) => u.side === 1 && u.id !== victim.id).id,
  );
  assert.equal(victim.hp, 0);
  assert.notEqual(currentUnit(death).id, victim.id);
});
test("deterministic seeded AI matches exercise every character and maintain combat invariants", () => {
  let completed = 0;
  for (let offset = 0; offset < 24; offset++) {
    const team = Array.from(
        { length: 3 },
        (_, i) => HEROES[(offset + i) % 24].id,
      ),
      enemy = Array.from(
        { length: 3 },
        (_, i) => HEROES[(offset + 8 + i) % 24].id,
      ),
      s = createBattle(team, enemy, { seed: offset + 1 });
    while (s.phase === "playing" && s.turns < 900) {
      const move = chooseAI(s);
      assert(move);
      const actor = currentUnit(s);
      assert(canUse(actor, move.actionId));
      act(s, move.actionId, move.targetId);
      for (const u of s.units) {
        assert(u.hp >= 0 && u.hp <= u.maxHp);
        assert(u.energy >= 0 && u.energy <= 100);
        assert(u.shield >= 0 && u.shield <= Math.ceil(u.maxHp * 0.6));
      }
    }
    assert.equal(
      s.phase,
      "finished",
      `Match ${offset} did not terminate in 900 actions`,
    );
    assert(s.units.filter((u) => u.side === s.winner).some((u) => u.hp > 0));
    assert(s.units.filter((u) => u.side !== s.winner).every((u) => u.hp === 0));
    assert.equal(chooseAI(s), null);
    completed++;
  }
  assert.equal(completed, 24);
});
test("difficulty only scales AI HP/attack and leaves persistent class/initiative unchanged", () => {
  const easy = createBattle(...DEFAULT_TEAMS, { difficulty: "easy" }),
    normal = createBattle(...DEFAULT_TEAMS),
    hard = createBattle(...DEFAULT_TEAMS, { difficulty: "hard" });
  for (let i = 0; i < 3; i++) {
    assert.equal(easy.units[i].hp, normal.units[i].hp);
    assert.equal(hard.units[i].hp, normal.units[i].hp);
  }
  for (let i = 3; i < 6; i++) {
    assert(easy.units[i].maxHp < normal.units[i].maxHp);
    assert(hard.units[i].attack > normal.units[i].attack);
    assert.equal(easy.units[i].speed, hard.units[i].speed);
  }
  assert.throws(() =>
    createBattle(...DEFAULT_TEAMS, { difficulty: "invalid" }),
  );
});
