import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdir, mkdtemp, readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { resolve } from "node:path";
import { HEROES, CLASS_BY_ID, DEFAULT_TEAMS, GUARD } from "../src/data.js";
import { createBattle, chooseAI, act, currentUnit } from "../src/engine.js";

const root = fileURLToPath(new URL("../", import.meta.url));
assert.deepEqual(JSON.parse(await readFile(resolve(root, "godot/data/catalog.json"), "utf8")), {
  schemaVersion: 1, heroes: HEROES, classes: Object.values(CLASS_BY_ID), defaultTeams: DEFAULT_TEAMS, guard: GUARD,
}, "Shared catalog is current; run npm run sync:godot after editing src/data.js");
await mkdir(resolve(root, "artifacts"), { recursive: true });
const scratch = await mkdtemp(resolve(root, "artifacts/godot-test-"));
const fixtures = [];
function scenario(name, teams, difficulty, seed, patch = {}, defensive = false) {
  const state = createBattle(...teams, { difficulty, seed });
  const initial = structuredClone(state);
  for (const unit of state.units) Object.assign(unit, structuredClone(patch[unit.id] || {}));
  const commands = [];
  while (state.phase === "playing" && state.turns < 400) {
    const choice = chooseAI(state);
    const command = defensive ? { actionId: "guard", targetId: currentUnit(state).id } : choice;
    const result = act(state, command.actionId, command.targetId);
    commands.push({ ...command, choice, result });
  }
  assert.equal(state.phase, "finished", name);
  fixtures.push({ name, teams, difficulty, seed, patch, initial, commands, final: state });
}
for (let group = 0; group < 4; group++) {
  const ids = HEROES.slice(group * 6, group * 6 + 6).map(h => h.id);
  for (const [index, difficulty] of ["easy", "normal", "hard"].entries())
    scenario(`roster-${group}-${difficulty}`, [ids.slice(0, 3), ids.slice(3)], difficulty, 73 + group * 139 + index * 113);
}
scenario("purification-and-status-refresh", [["elyra", "bast", "oren"], ["rhazen", "noct", "axion"]], "normal", 391, {
  "0-bast": { hp: 500, statuses: ["burn", "regen", "expose", "weaken"].map(type => ({ type, turns: 2 })) },
  "0-elyra": { energy: 100 },
});
scenario("burn-cannot-revive", DEFAULT_TEAMS, "normal", 73, {
  "1-vesper": { hp: 1, statuses: [{ type: "burn", turns: 2 }, { type: "regen", turns: 2 }] },
});
scenario("healing-ties-preserve-team-order", [["elyra", "sylva", "saira"], ["rhazen", "noct", "axion"]], "normal", 211,
  Object.fromEntries(["elyra", "sylva", "saira"].map(id => [`0-${id}`, { hp: HEROES.find(h => h.id === id).hp / 2 }])));
scenario("ultimates-and-shield-absorption", DEFAULT_TEAMS, "normal", 127, Object.fromEntries(
  DEFAULT_TEAMS.flatMap((team, side) => team.map(id => [`${side}-${id}`, { energy: 100, shield: 250 }]))
));
scenario("shielded-critical-and-both-dots", DEFAULT_TEAMS, "normal", 1972, {
  "1-vesper": { shield: 600, statuses: ["burn", "bleed"].map(type => ({type, turns: 2})) },
});
scenario("fracture-ends-defensive-stalemate", [["sylva", "elyra", "brin"], ["saira", "zaya", "oren"]], "normal", 73, {}, true);
const fixturePath = resolve(scratch, "cases.json");
const outputPath = resolve(scratch, "results.json");
await writeFile(fixturePath, JSON.stringify(fixtures));
const env = { ...process.env,
  XDG_DATA_HOME: resolve(scratch, "data"), XDG_CONFIG_HOME: resolve(scratch, "config"),
  XDG_CACHE_HOME: resolve(scratch, "cache"),
};
const executable = process.env.GODOT_EXECUTABLE || "godot";
function run(args, timeout = 75000) {
  const result = spawnSync(executable, args, { cwd: root, env, encoding: "utf8", timeout, maxBuffer: 4 * 1024 * 1024 });
  const log = (result.stdout || "") + (result.stderr || "");
  if (result.error || result.status !== 0 || /SCRIPT ERROR|Parse Error|ERROR:/i.test(log))
    throw Error(`Godot validation failed: ${result.error?.message || result.status}\n${log}`);
  return log;
}
console.log("Importando o projeto com Godot…");
run(["--headless", "--path", "godot", "--editor", "--import", "--quit"]);
console.log("Executando paridade do motor e teste de interface…");
const log = run(["--headless", "--audio-driver", "Dummy", "--path", "godot", "--script", "res://tests/run.gd", "--", fixturePath, outputPath]);
const actual = JSON.parse(await readFile(outputPath, "utf8"));
assert.equal(actual.cases.length, fixtures.length);
for (const [i, fixture] of fixtures.entries()) {
  assert.deepEqual(actual.cases[i].initial, fixture.initial, `${fixture.name}: initial state`);
  assert.deepEqual(actual.cases[i].commands, fixture.commands.map(({ choice, result }) => ({ choice, result })), `${fixture.name}: AI and action results`);
  assert.deepEqual(actual.cases[i].final, fixture.final, `${fixture.name}: final state`);
}
assert(actual.uiChecks >= 20, "Meaningful native interface coverage");
console.log(log.trim());
console.log(`✓ ${fixtures.length} partidas reproduzidas com resultados idênticos ao JavaScript (${fixtures.reduce((n, f) => n + f.commands.length, 0)} ações).`);
console.log(`✓ ${actual.checks} verificações nativas, incluindo ${actual.uiChecks} de interface: formação, persistência, IA, animação, partida completa e replay.`);
