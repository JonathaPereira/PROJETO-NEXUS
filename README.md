# Nexus — versão Web 0.15

[Baixar nexus-web-0.15.zip](https://github.com/JonathaPereira/PROJETO-NEXUS/raw/refs/heads/downloads/nexus-web-0.15.zip) · aproximadamente 87,2 MiB

Pacote HTML5 exportado do Godot 4.6.3, com `index.html` na raiz. Código-fonte: [codex/nexus-015](https://github.com/JonathaPereira/PROJETO-NEXUS/tree/codex/nexus-015), revisão `e517fc814541c7c6f1b428e87e1019e0dfbd7a9b`.

- Escudos acumulam em camadas independentes de duas rodadas globais, limitadas a 25% da vida.
- Vesper provoca e contra-ataca por dois turnos pessoais, perdendo 25% da própria defesa enquanto provoca. A penalidade aparece em vermelho e termina junto com a postura.
- Tanques: aproximadamente +8% de ataque e cobertura inicial dos aliados pelo primeiro tanque da formação. Heróis de dano: aproximadamente −6% de vida, preservando ataque e poderes. Suportes preservados.
- IA avalia finalizações, suporte inimigo, combos, cura efetiva e proteção.
- Vozes e efeitos corrigidos no Web e testados com PCM real, diretamente e em iframe. Há testes de voz e golpe nas configurações.
- Campanha, gemas, animações e estudo 3D preservados. O servidor PvP já vem configurado como `wss://nexus-pvp.onrender.com/pvp`.

[Guia completo de atualização](https://github.com/JonathaPereira/PROJETO-NEXUS/blob/codex/nexus-015/godot/BALANCE-0.15.md) · [Relatório de 36.108 combates](https://github.com/JonathaPereira/PROJETO-NEXUS/blob/codex/nexus-015/docs/balance-015/README.md)

## Ativar a versão nova

**Atualize o servidor junto com o jogo.** A versão 0.15 usa regras e fingerprint novos.

1. Render → serviço nexus-pvp → Settings → Branch: **codex/nexus-015**. Root Directory vazio; Build `npm ci --omit=dev`; Start `npm run pvp:server`. Salve e faça Manual Deploy → Deploy latest commit. Preserve as variáveis existentes.
2. Espere Live e confira [health](https://nexus-pvp.onrender.com/health): `ok: true`, build `24bfd1a18f421ac1558263a19f326a8b818748bb6d0c959afe6027f0f1024866`.
3. itch.io → Dashboard → Nexus → Edit game → Uploads: envie o ZIP inteiro, sem extrair. Marque **This file will be played in the browser**, mantenha **Public** e salve.
4. Ambos os jogadores recarregam o jogo. Criem/entrem na mesma sala e confirmem as equipes. Reiniciar o servidor encerra salas em memória.
5. Se o itch.io gerar outro código `embed-upload`, atualize o Embed game no Trono. O ZIP fica no itch.io; não precisa ser colocado no Surge.

SHA-256: `2d83c0b0c3b537d3bbd2ecafa2a140711ace7cd79aa9b3a3fd3e11da023fa98f`

[Tamanho, revisão e fingerprint em JSON](release-0.15.json) · [Checksums](SHA256SUMS.txt)

## Arquivos anteriores e capa

As versões 0.13 e 0.14 permanecem arquivadas para preservar os links anteriores; seus clientes não são compatíveis com o servidor atualizado para 0.15.

[Capa PNG — 630 × 500](https://github.com/JonathaPereira/PROJETO-NEXUS/raw/refs/heads/downloads/nexus-capa-630x500.png)
