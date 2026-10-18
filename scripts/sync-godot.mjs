import { mkdir, copyFile, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { HEROES, CLASS_BY_ID, DEFAULT_TEAMS, GUARD } from "../src/data.js";

const destination = new URL("../godot/", import.meta.url);
await mkdir(new URL("data/", destination), { recursive: true });
await mkdir(new URL("assets/", destination), { recursive: true });
await writeFile(new URL("data/catalog.json", destination), JSON.stringify({
  schemaVersion: 1, heroes: HEROES, classes: Object.values(CLASS_BY_ID),
  defaultTeams: DEFAULT_TEAMS, guard: GUARD,
}, null, 2) + "\n");
for (const file of ["heroes.png", "arena.png", "cinzel.ttf", "manrope.ttf", "favicon.svg", "Cinzel-LICENSE.txt", "Manrope-LICENSE.txt"])
  await copyFile(new URL(`../assets/${file}`, import.meta.url), new URL(`assets/${file}`, destination));
console.log(`Catálogo e recursos sincronizados: ${fileURLToPath(destination)}`);
