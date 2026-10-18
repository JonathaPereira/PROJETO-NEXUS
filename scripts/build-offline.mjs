import { build } from "esbuild";
import { readFile, writeFile, mkdir } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { resolve } from "node:path";

const root = fileURLToPath(new URL("../", import.meta.url));
const output = resolve(root, "artifacts", "NEXUS-JOGAR.html");
const dataUrl = async (file, type) =>
  `data:${type};base64,${(await readFile(resolve(root, file))).toString("base64")}`;
const assets = [
  ["/assets/cinzel.ttf", "font/ttf"],
  ["/assets/manrope.ttf", "font/ttf"],
  ["/assets/arena.png", "image/png"],
];
let css = await readFile(resolve(root, "styles.css"), "utf8");
for (const [path, type] of assets)
  css = css.replaceAll(path, await dataUrl(path.slice(1), type));
if (/\/assets\//.test(css))
  throw Error("An external CSS asset was left in the offline edition.");

const bundled = await build({
  absWorkingDir: root,
  entryPoints: ["src/app.js"],
  bundle: true,
  format: "iife",
  target: "es2022",
  minify: true,
  write: false,
  legalComments: "inline",
});
// Keep the atlas data only once. Repeating its data URI in every fighter/portrait
// would duplicate megabytes on every UI update; all instances share this blob.
const atlas = (await readFile(resolve(root, "assets/heroes.png"))).toString(
  "base64",
);
const bootstrap = `const atlasBytes=Uint8Array.from(atob(${JSON.stringify(atlas)}),c=>c.charCodeAt(0));globalThis.NEXUS_ASSETS={heroes:URL.createObjectURL(new Blob([atlasBytes],{type:"image/png"}))};`;
const code =
  bootstrap + bundled.outputFiles[0].text.replaceAll('href="/"', 'href="#"');
let html = await readFile(resolve(root, "index.html"), "utf8");
if (!html.includes('<link rel="stylesheet" href="/styles.css" />'))
  throw Error("Stylesheet entry not found.");
if (!html.includes('<script type="module" src="/src/app.js"></script>'))
  throw Error("JavaScript entry not found.");
html = html
  .replace(
    '<link rel="stylesheet" href="/styles.css" />',
    () => `<style>${css}</style>`,
  )
  .replace('<script type="module" src="/src/app.js"></script>', "")
  .replace(
    "/assets/favicon.svg",
    await dataUrl("assets/favicon.svg", "image/svg+xml"),
  )
  .replace(
    "</body>",
    () =>
      `<noscript>Ative o JavaScript e abra este arquivo no navegador para jogar Nexus.</noscript><script>${code.replace(/<\/script/gi, "<\\/script")}</script></body>`,
  );
await mkdir(resolve(root, "artifacts"), { recursive: true });
await writeFile(output, html);
await writeFile(
  resolve(root, "artifacts", "COMO-JOGAR.txt"),
  `NEXUS — ECOS DO CREPÚSCULO\n\n1. Extraia o arquivo ZIP.\n2. Abra NEXUS-JOGAR.html no Chrome, Edge ou Firefox.\n3. Clique em Iniciar combate.\n\nNão é necessário instalar Node.js, iniciar servidor ou conectar à internet.\nA visualização de arquivos do chat pode não executar jogos; abra o arquivo baixado no navegador.\n\nPersonagens: escolha 3 dos 24 heróis.\nTreino tático: enfrente a IA.\nDuelo local: duas pessoas jogam no mesmo dispositivo.\nEscolha a ação, selecione o alvo e confirme em Usar em.\nAs equipes e preferências são locais ao navegador; o combate em andamento não é salvo.\n\nAs fontes Cinzel e Manrope usam SIL Open Font License; consulte os arquivos de licença incluídos no pacote.\n`,
);
console.log(
  `Edição offline criada: ${output} (${(Buffer.byteLength(html) / 1024 / 1024).toFixed(1)} MiB)`,
);
