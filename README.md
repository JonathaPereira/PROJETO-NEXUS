# NEXUS — Ecos do Crepúsculo

Protótipo jogável de RPG tático original: equipes de três, cinco afinidades permanentes, turnos por iniciativa e 15 personagens ativos. A referência é a legibilidade do combate de jogos como Marvel Avengers Alliance; universo, personagens, ilustrações, habilidades e identidade visual são próprios.

## Jogar

### Nova base em Godot

O projeto Godot está em **[godot/](godot/README.md)**. Use **Godot 4.6 Standard**, gratuito, sem a edição .NET. Importe [godot/project.godot](godot/project.godot), aguarde a importação dos recursos e pressione **F5**.

A **Alpha 0.4** traz **15 kits distintos: tanque, suporte e dano em cada uma das cinco classes**. Lumi e nove personagens ficam arquivados com seus recursos preservados. Há combos entre aliados, provocação, proteção, penetração de escudos, prévias de ações, três batalhas guiadas e um laboratório com dados locais e simulações de IA separados. A formação triangular, artes de habilidades, poses e HUD da versão anterior foram preservados. Campanha e integração com A Lei do Trono continuam para etapas futuras.

O endereço atual do GitHub Pages continua executando o protótipo JavaScript. A versão Godot é aberta pelo editor nesta etapa; sua exportação para navegador será uma entrega separada. Veja [godot/README.md](godot/README.md) para instruções, estrutura e testes.

### Protótipo web existente

O download anterior foi retirado após o relato **“Vírus detectado”**. A causa permanece inconclusiva. Não execute o pacote antigo nem desative a proteção. O [registro do alerta](docs/ALERTA-DO-DOWNLOAD.md) documenta o arquivo e as medidas tomadas.

### Versão web

O jogo usa HTML, CSS, módulos JavaScript, imagens e fontes separados. A pasta `docs/` contém a versão preparada para GitHub Pages, sem ZIP ou HTML com código e imagens empacotados. **Preparar os arquivos não ativa a hospedagem.**

Para o proprietário ativar o site pelo GitHub:

1. Abra **Settings → Pages** neste repositório.
2. Em **Build and deployment**, escolha **Deploy from a branch**.
3. Selecione a branch **codex/nexus-jogavel** e a pasta **/docs**, depois **Save**.
4. Aguarde a publicação e abra o endereço mostrado pelo próprio GitHub.

Isso publica um site acessível pela internet, conforme a visibilidade e o plano do repositório. O GitHub pode exigir tornar o repositório público ou um plano compatível; avalie essa escolha nas configurações. A ativação não foi feita por este ambiente: o acesso à API do GitHub está bloqueado pelo proxy de rede.

Para preparar os arquivos a partir do código-fonte:

```bash
npm run build         # arquivos em dist/ para hospedagem estática
npm run build:pages   # atualiza a cópia em docs/ para GitHub Pages
```

O gerador usa apenas bibliotecas do Node e copia uma lista explícita de arquivos públicos. Após mudar o código ou os recursos, execute `npm run build:pages` e envie também as alterações de `docs/`.

### Executar o código-fonte

Requer Node.js 24 ou superior e npm.

```bash
cd PROJETO-NEXUS
npm ci
npm run dev
```

O servidor usa a porta **5173**. Quando executado na sua própria máquina, abra `http://localhost:5173`. Esta interface de configuração na nuvem não oferece uma prévia pública dessa porta; para jogar sem instalação, use a hospedagem web após sua ativação. Para alterar a porta: `PORT=3000 npm start`. O jogo roda no navegador, sem banco, conta, chave de API ou serviços externos. As dependências npm são usadas somente para testes de navegador.

1. Abra **Personagens** ou **Montar equipe**. Escolha três heróis distintos; a formação rival também pode ser editada.
2. Em **Treino tático**, enfrente a IA. Em **Duelo local**, duas pessoas controlam suas equipes no mesmo dispositivo. Multiplayer pela internet ainda não foi implementado.
3. Clique em **Iniciar combate**. A velocidade determina a ordem de iniciativa da rodada.
4. Escolha uma ação, clique em um alvo válido na arena ou no painel e confirme em **Usar em…**. Ataques atingem rivais; curas e barreiras escolhem aliados.
5. Derrote os três rivais. O resultado mostra rodadas, ações e dano da equipe vencedora e permite jogar novamente ou mudar a formação.

As equipes e preferências ficam salvas neste navegador; uma batalha em andamento não é restaurada ao atualizar. Todos os personagens estão liberados. Obtenção, economia e progressão permanecem em aberto.

## Classes e elenco

**Ígneo → Natural → Técnico → Arcano → Sombrio → Ígneo.** Cada classe supera a próxima (+25% de dano); a relação inversa recebe resistência (−15%). Outras relações são neutras. A afinidade é fixa; a função depende do kit. Não é obrigatório escolher um personagem de cada função.

| Classe | Tanque | Suporte | Dano |
| --- | --- | --- | --- |
| Ígneo | Rhazen | Cindra | Veyra |
| Natural | Oren | Sylva | Nima |
| Técnico | Axion | Vektor | Kira |
| Arcano | Elun | Saira | Astra |
| Sombrio | Vesper | Maura | Riven |

Os nove restantes estão em `ARCHIVED_HEROES`, sem entrar na seleção ou nas simulações atuais. Kits e exemplos de sinergia: [godot/KITS.md](godot/KITS.md).

## Regras do modelo inicial

- **Energia:** começa em 40/100. Ataque básico recupera 24; defesa recupera 25; técnica custa 30 e fica indisponível por dois turnos pessoais; supremo custa 80.
- **Defesa:** barreira de 12% da vida máxima e redução de 35% do dano até o próximo turno. Barreiras absorvem dano antes da vida e acumulam até 60% da vida máxima.
- **Estados:** queimadura e sangramento tiram 6,5% da vida máxima por turno e atravessam escudos; regeneração cura 7%; exposição reduz defesa em 25%; enfraquecimento reduz ataque em 20%. Duram dois turnos do alvo; aplicações renovam a duração, sem acumular duplicatas. Cura não excede a vida máxima nem ressuscita.
- **Crítico:** chance de 10%, dano multiplicado por 1,4. O motor usa aleatoriedade com semente para permitir simulações reproduzíveis.
- **Fratura do Nexus:** a partir da rodada 12, cada herói sofre dano direto antes de agir. Começa em 4% da vida máxima e sobe 2,5 pontos percentuais por rodada, até 85%. Ignora barreiras e impede impasses de cura/defesa. Cada ocorrência aparece no registro.
- **Dificuldade:** Iniciante usa 82% da vida/ataque da IA; Desafiador usa 115%. Normal e Duelo local usam atributos iguais nos dois lados.

```text
dano = ataque × poder × 100 / (100 + defesa efetiva × 0,5)
       × afinidade × crítico × postura defensiva
```

Enfraquecimento modifica o ataque; exposição e Arcano modificam a defesa efetiva. O dano é arredondado antes da absorção pela barreira. Roubo de vida considera apenas o dano realmente causado à vida.

## Apresentação e controles

Ruínas sob um eclipse, HUD de obsidiana e ouro e ilustrações 2D originais. O protótipo combina deslocamento, antecipação, projéteis, impactos, partículas, números de dano/cura e **15 assinaturas visuais ativas**, uma por personagem. Os supremos têm apresentação ampliada. São coreografias procedurais sobre ilustrações; animação esquelética ou quadros desenhados por golpe podem ser desenvolvidos após validar as mecânicas.

O som é sintetizado localmente e ativado no topo. O guia oferece **Reduzir animações** e respeita inicialmente a preferência do sistema. No celular, **Ver ficha** abre atributos, história e habilidades.

| Tecla | Ação                                                 |
| ----- | ---------------------------------------------------- |
| 1–4   | Selecionar ataque, técnica, supremo ou defesa        |
| ← / → | Alternar alvo válido                                 |
| Enter | Confirmar ação quando o foco não está em outro botão |
| Esc   | Fechar painel                                        |

## Desenvolvimento e balanceamento

| Arquivo                        | Responsabilidade                                        |
| ------------------------------ | ------------------------------------------------------- |
| [src/data.js](src/data.js)     | Elenco, atributos, habilidades e ciclo de classes       |
| [src/engine.js](src/engine.js) | Motor de combate independente da interface e IA         |
| [src/app.js](src/app.js)       | Formação, HUD, diálogos, som e coreografias             |
| [src/art.js](src/art.js)       | Ícones e recortes do atlas de personagens               |
| [styles.css](styles.css)       | Identidade visual, responsividade e efeitos individuais |
| [server.mjs](server.mjs)       | Servidor estático sem dependências de produção          |

Os números são uma **base inicial para balancear**, não uma alegação de equilíbrio competitivo. A IA respeita os mesmos custos, alvos e recargas. Veja [docs/DESIGN.md](docs/DESIGN.md) para o conceito, elenco e decisões em aberto.

## Verificar

```bash
npm run check
npm test
npm run test:browser
npm run test:site
```

Os testes do motor cobrem regras, estados, término e simulações que exercitam todos os 15 heróis ativos. Os testes de navegador verificam formações persistentes, filtros, guias, animação, IA, partida local completa, resultado, replay e celular. `test:site` verifica a versão construída em uma subpasta de URL, incluindo fontes, imagens, combate e celular. São testes funcionais, não uma análise antivírus. Capturas ficam em `artifacts/`, ignorada pelo Git.

O teste de navegador inicia e encerra seu servidor na porta 5199. Usa `CHROMIUM_EXECUTABLE_PATH`, `/usr/bin/chromium` quando disponível ou o Chromium do Playwright. Se necessário: `npx playwright install chromium`; para dependências de sistema Linux, `npx playwright install --with-deps chromium`. Para usar um servidor já aberto, defina `NEXUS_TEST_BASE_URL`.

## Recursos

Arena e atlas de personagens foram gerados para este protótipo. Cinzel e Manrope são fontes sob SIL Open Font License, com licenças em `assets/`. Todos os recursos são servidos localmente.
