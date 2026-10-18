import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdir, mkdtemp, readFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { resolve } from "node:path";
import { HEROES, ARCHIVED_HEROES, CLASS_BY_ID, DEFAULT_TEAMS, GUARD } from "../src/data.js";
import { createBattle, chooseAI, act, currentUnit, preview } from "../src/engine.js";

const root = fileURLToPath(new URL("../", import.meta.url));
assert.deepEqual(JSON.parse(await readFile(resolve(root, "godot/data/catalog.json"), "utf8")), {
  schemaVersion: 1, heroes: HEROES, archivedHeroes: ARCHIVED_HEROES, classes: Object.values(CLASS_BY_ID), defaultTeams: DEFAULT_TEAMS, guard: GUARD,
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
    const prediction = commands.length === 0 ? preview(state, command.actionId, command.targetId) : null;
    const result = act(state, command.actionId, command.targetId);
    commands.push({ ...command, choice, result, prediction });
  }
  assert.equal(state.phase, "finished", name);
  fixtures.push({ name, teams, difficulty, seed, patch, initial, commands, final: state });
}
for (let group = 0; group < 5; group++) {
  const teams = [0,1].map(offset => HEROES.slice(((group+offset)%5)*3, ((group+offset)%5)*3+3).map(h=>h.id));
  for (const [index,difficulty] of ['easy','normal','hard'].entries())
    scenario(`class-${group}-${difficulty}`,teams,difficulty,73+group*139+index*113);
}
scenario('cleanse-and-energy', [['vektor','sylva','saira'],['rhazen','vesper','axion']], 'normal',391, {
 '0-sylva':{hp:500,statuses:['burn','regen','expose','weaken','fortify'].map(type=>({type,turns:2}))},
 '0-vektor':{energy:100}
});
scenario('all-status-combos-and-shields', DEFAULT_TEAMS, 'normal',1972, Object.fromEntries(
 DEFAULT_TEAMS.flatMap((team,side)=>team.map(id=>[`${side}-${id}`,{energy:100,shield:250,statuses:['burn','bleed','expose','seed','focus','empower','fortify','mirror','riposte','emberguard'].map(type=>({type,turns:2}))}]))
));
scenario('cover-guardian', DEFAULT_TEAMS, 'normal',127, {'1-kira':{statuses:[{type:'cover',owner:'1-oren',turns:2}]}});
scenario('fracture-stalemate',DEFAULT_TEAMS,'normal',73,{},true);
const fixturePath = resolve(scratch, "cases.json");
const outputPath = resolve(scratch, "results.json");
await writeFile(fixturePath, JSON.stringify(fixtures));
const env = { ...process.env,
  XDG_DATA_HOME: resolve(scratch, "data"), XDG_CONFIG_HOME: resolve(scratch, "config"),
  XDG_CACHE_HOME: resolve(scratch, "cache"),
};
const executable = process.env.GODOT_EXECUTABLE || "godot";
function run(args, timeout = 120000) {
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
  assert.deepEqual(actual.cases[i].commands, fixture.commands.map(({ choice, result, prediction }) => ({ choice, result, prediction })), `${fixture.name}: AI and action results`);
  assert.deepEqual(actual.cases[i].final, fixture.final, `${fixture.name}: final state`);
}
assert(actual.uiChecks >= 20, "Meaningful native interface coverage");
console.log(log.trim());
console.log(`✓ ${fixtures.length} partidas reproduzidas com resultados idênticos ao JavaScript (${fixtures.reduce((n, f) => n + f.commands.length, 0)} ações).`);
console.log(`✓ ${actual.checks} verificações nativas, incluindo ${actual.uiChecks} de interface: formação, persistência, IA, animação, partida completa e replay.`);
