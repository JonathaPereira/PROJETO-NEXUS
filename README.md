# NEXUS — Ecos do Crepúsculo

Protótipo jogável de RPG tático original: equipes de três, seis afinidades permanentes, turnos por iniciativa e 24 personagens. A referência é a legibilidade do combate de jogos como Marvel Avengers Alliance; universo, personagens, ilustrações, habilidades e identidade visual são próprios.

## Jogar

### Abrir sem instalar nada

**Pacote pronto:** [NEXUS-v0.1.zip](downloads/NEXUS-v0.1.zip). No GitHub, abra o arquivo ZIP e use **Download raw file** (ícone de download). Extraia o pacote e abra `NEXUS-JOGAR.html` no navegador.

A edição **NEXUS-JOGAR.html** reúne código, imagens, fontes e som em um único arquivo. Baixe o pacote, extraia e abra o HTML no Chrome, Edge ou Firefox. Ele funciona sem servidor e sem internet. A pré-visualização de arquivos do chat pode não executar JavaScript; abra o arquivo baixado no navegador.

Para gerar essa edição a partir do código-fonte:

```bash
npm ci
npm run build:offline
```

O arquivo será criado em `artifacts/NEXUS-JOGAR.html`. A verificação `npm run test:offline` carrega o documento gerado em memória, com rede desativada, e testa ilustrações, fontes, combate, resposta da IA e montagem de equipe. O Chromium desta máquina bloqueia URLs `file:` por política administrativa; o teste não altera essa política. A abertura do arquivo baixado deve ser feita no seu navegador.

### Executar o código-fonte

Requer Node.js 24 ou superior e npm.

```bash
cd /workspace/PROJETO-NEXUS
npm ci
npm run dev
```

O servidor usa a porta **5173**. Abra essa porta na interface do ambiente ou acesse `http://localhost:5173` na sua máquina. Para alterar a porta: `PORT=3000 npm start`. O jogo roda no navegador, sem banco, conta, chave de API ou serviços externos. As dependências npm são usadas somente para testes de navegador.

1. Abra **Personagens** ou **Montar equipe**. Escolha três heróis distintos; a formação rival também pode ser editada.
2. Em **Treino tático**, enfrente a IA. Em **Duelo local**, duas pessoas controlam suas equipes no mesmo dispositivo. Multiplayer pela internet ainda não foi implementado.
3. Clique em **Iniciar combate**. A velocidade determina a ordem de iniciativa da rodada.
4. Escolha uma ação, clique em um alvo válido na arena ou no painel e confirme em **Usar em…**. Ataques atingem rivais; curas e barreiras escolhem aliados.
5. Derrote os três rivais. O resultado mostra rodadas, ações e dano da equipe vencedora e permite jogar novamente ou mudar a formação.

As equipes e preferências ficam salvas neste navegador; uma batalha em andamento não é restaurada ao atualizar. Todos os personagens estão liberados. Obtenção, economia e progressão permanecem em aberto.

## Classes e elenco

**Ígneo → Natural → Técnico → Arcano → Sombrio → Lumi → Ígneo.** Cada classe supera a próxima e causa **25% mais dano**. Atacar a classe que supera a sua causa **15% menos dano**; outras relações são neutras. A classe é fixa.

| Classe  | Identidade                                           | Personagens                 |
| ------- | ---------------------------------------------------- | --------------------------- |
| Ígneo   | Pressão e queimadura                                 | Veyra, Rhazen, Cindra, Torv |
| Natural | Recuperação e resistência                            | Sylva, Oren, Nima, Brin     |
| Técnico | Barreiras e exposição                                | Axion, Kira, Bast, Vektor   |
| Arcano  | Magia; ignora 25% da defesa                          | Astra, Elun, Saira, Ivo     |
| Sombrio | Enfraquecimento; rouba 25% do dano causado como vida | Vesper, Maura, Noct, Riven  |
| Lumi    | Cura e purificação                                   | Auren, Elyra, Solen, Zaya   |

Cada personagem possui ataque básico, técnica, supremo e assinatura visual próprios. Defesa é uma ação comum. Há atacantes, controladores, guardiões e suportes; papel e afinidade são conceitos diferentes.

## Regras do modelo inicial

- **Energia:** começa em 40/100. Ataque básico recupera 24; defesa recupera 25; técnica custa 30 e fica indisponível por dois turnos pessoais; supremo custa 80.
- **Defesa:** barreira de 12% da vida máxima e redução de 35% do dano até o próximo turno. Barreiras absorvem dano antes da vida e acumulam até 60% da vida máxima.
- **Estados:** queimadura tira 6,5% da vida máxima por turno; regeneração cura 7%; exposição reduz defesa em 25%; enfraquecimento reduz ataque em 20%. Duram dois turnos do alvo; aplicações renovam a duração, sem acumular duplicatas. Cura não excede a vida máxima nem ressuscita.
- **Crítico:** chance de 10%, dano multiplicado por 1,4. O motor usa aleatoriedade com semente para permitir simulações reproduzíveis.
- **Fratura do Nexus:** a partir da rodada 12, cada herói sofre dano direto antes de agir. Começa em 4% da vida máxima e sobe 2,5 pontos percentuais por rodada, até 85%. Ignora barreiras e impede impasses de cura/defesa. Cada ocorrência aparece no registro.
- **Dificuldade:** Iniciante usa 82% da vida/ataque da IA; Desafiador usa 115%. Normal e Duelo local usam atributos iguais nos dois lados.

```text
dano = ataque × poder × 100 / (100 + defesa efetiva × 0,5)
       × afinidade × crítico × postura defensiva
```

Enfraquecimento modifica o ataque; exposição e Arcano modificam a defesa efetiva. O dano é arredondado antes da absorção pela barreira. Roubo de vida considera apenas o dano realmente causado à vida.

## Apresentação e controles

Ruínas sob um eclipse, HUD de obsidiana e ouro e ilustrações 2D originais. O protótipo combina deslocamento, antecipação, projéteis, impactos, partículas, números de dano/cura e **24 assinaturas visuais**, uma por personagem. Os supremos têm apresentação ampliada. São coreografias procedurais sobre ilustrações; animação esquelética ou quadros desenhados por golpe podem ser desenvolvidos após validar as mecânicas.

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
```

Os testes do motor cobrem regras, estados, término e simulações que exercitam todos os 24 heróis. Os testes de navegador verificam formações persistentes, filtros, guias, animação, IA, partida local completa, resultado, replay e celular. Capturas ficam em `artifacts/`, ignorada pelo Git.

O teste de navegador inicia e encerra seu servidor na porta 5199. Usa `CHROMIUM_EXECUTABLE_PATH`, `/usr/bin/chromium` quando disponível ou o Chromium do Playwright. Se necessário: `npx playwright install chromium`; para dependências de sistema Linux, `npx playwright install --with-deps chromium`. Para usar um servidor já aberto, defina `NEXUS_TEST_BASE_URL`.

## Recursos

Arena e atlas de personagens foram gerados para este protótipo. Cinzel e Manrope são fontes sob SIL Open Font License, com licenças em `assets/`. Todos os recursos são servidos localmente.
