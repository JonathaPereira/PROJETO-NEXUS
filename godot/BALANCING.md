# Onde balancear o NEXUS

Os heróis e os parâmetros globais têm fontes editáveis separadas. O catálogo e as fórmulas usados pelo Godot são gerados dessas fontes. Não é necessário procurar números na interface para mudar o combate.

| Quero mudar | Arquivo editável | Ponto de entrada |
| --- | --- | --- |
| Vida, ataque, defesa e velocidade de um herói | `src/kits.js` | `KITS.<id>.stats`, com `hp`, `attack`, `defense` e `speed` identificados |
| Dano, cura, escudo, efeitos e combos de uma habilidade | `src/kits.js` | `basic`, `skill`, `ultimate` do herói |
| Custo/recarga de uma habilidade específica | `src/kits.js` | Campos opcionais `cost` e `cooldown` na ação |
| Custo/recarga padrão herdados pelo elenco | `src/data.js` | Montagem de `ALL_HEROES`: técnica 30 EN/2 turnos; supremo 80 EN |
| Nome, afinidade, arma, índice de arte e descrição base | `src/data.js` | Entrada do herói em `roster`; `CLASSES` define a ordem do ciclo |
| Crítico, mitigação, duração, energia, debuffs, Fratura | **`src/balance.json`** | Parâmetros globais, detalhados abaixo |
| Uma regra nova ou a sequência da fórmula | `src/engine.js` **e** `godot/scripts/combat.gd` | Motores equivalentes; valide a paridade após editar ambos |
| Gemas, cópias, engastes e bônus da campanha | `godot/scripts/campaign.gd` | `GEMS`, `SLOT_COUNT`, `STARTING_COPIES`, `bonuses()` e `battle()` |
| Minions, chefe e dificuldade das missões | `godot/scripts/campaign.gd` | `register_enemies()` e `MISSIONS[].scale` |
| Entender os testes simulados | `godot/SIMULATIONS.md` | Amostras, filtros, limitações e exportação |

`godot/data/catalog.json` e `godot/data/combat-rules.json` são **cópias geradas**: alterações manuais neles serão substituídas na sincronização. Os 15 heróis ativos vêm de `KITS`; os nove arquivados mantêm seus dados e índices de arte. Não renumere o elenco para remover um personagem da seleção.

## Parâmetros globais: `src/balance.json`

`schemaVersion: 1` descreve o formato; `rulesVersion: "0.5.0"` identifica as regras atuais. A organização nova preserva todos os números, a ordem de resolução e o arredondamento da versão anterior.

Valores `Ratio` são frações da quantidade indicada: `0.25` = 25%. Um `Multiplier` multiplica a quantidade: `0.85` significa receber/produzir 85%, uma redução de 15%. Durações são contadas em turnos/ações pessoais, não em rodadas da equipe.

| Grupo | Campos e valores atuais | Efeito |
| --- | --- | --- |
| `affinity` | `advantageMultiplier: 1.25`, `resistanceMultiplier: 0.85`, `neutralMultiplier: 1` | Vantagem, resistência e neutralidade do ciclo de afinidades |
| `critical` | `chance: 0.1`, `damageMultiplier: 1.4` | 10% de chance; 140% do dano no crítico |
| `damage` | `defenseBaseline: 100`, `defenseWeight: 0.5`, `minimumHit: 1` | Curva de mitigação por defesa e piso do golpe |
| `energy` | `initial: 40`, `maximum: 100`, `basicGain: 24`, `guardGain: 25` | Recursos iniciais, limite e ganhos das ações básicas |
| `shield` | `maxHpRatio: 0.25`, `durationActions: 2` | Teto de escudo por vida máxima e duração; escudos continuam sem acumular |
| `guard` | `shieldMaxHpRatio: 0.06`, `incomingDamageMultiplier: 0.65` | Escudo da defesa e mitigação até o próximo turno |
| `status` | `durationTurns: 2` | Duração padrão de buffs e debuffs aplicados |
| `status` | `burnMaxHpRatio: 0.065`, `bleedMaxHpRatio: 0.065`, `regenMaxHpRatio: 0.04` | Dano de queimadura/sangramento e regeneração no início do turno |
| `status` | `bleedHealingMultiplier: 0.65` | Toda cura recebida com sangramento é reduzida em 35% |
| `status` | `weakenAttackMultiplier: 0.8`, `empowerAttackMultiplier: 1.2`, `exposeDefenseMultiplier: 0.75` | Ataque enfraquecido, ataque fortalecido e defesa exposta |
| `status` | `fortifyIncomingDamageMultiplier: 0.85`, `focusDamageMultiplier: 1.25` | Fortificação e amplificação do próximo golpe pelo Selo |
| `status` | `coverRedirectRatio: 0.25`, `seedHealMaxHpRatio: 0.1` | Parcela interceptada pelo protetor e cura da Semente |
| `status` | `mirrorDamageRatio: 0.2`, `riposteAttackRatio: 0.4` | Reflexão do dano à vida e contra-ataque baseado no ataque |
| `classPassives` | `arcanoDefenseMultiplier: 0.75`, `sombrioDrainRatio: 0.15` | Arcano considera 75% da defesa; Sombrio drena 15% do dano efetivo à vida |
| `fracture` | `startRound: 12`, `initialMaxHpRatio: 0.04`, `perRoundMaxHpRatio: 0.025`, `maxHpRatioCap: 0.85` | Fratura começa com 4% da vida máxima, cresce 2,5 pontos por rodada e limita em 85% |
| `fracture` | `healingReductionPerRound: 0.1` | Cura reduzida em mais 10 pontos percentuais por rodada desde a primeira Fratura |
| `difficulty.enemyStatMultiplier` | `easy: 0.82`, `normal: 1`, `hard: 1.15` | Multiplica vida e ataque da equipe adversária no combate livre |
| `ai` | `healingHealthThreshold: 0.78`, `shieldRefreshMaxHpRatio: 0.14`, `supportEnergyThreshold: 75` | Quando a IA considera cura, reposição de escudo e entrega de energia |

Os limiares de `ai` mudam a política dos bots, não a força de uma habilidade. Isso pode alterar bastante o resultado das simulações. As constantes do gerador aleatório e a ordenação por velocidade permanecem no motor; não são ajustes de balanceamento.

## Exemplo: ajustar um personagem

Em `src/kits.js`, procure `"kira":`. Para reduzir apenas o ataque dela, altere `"attack": 265` para `"attack": 255` dentro de `"stats"`. Os campos `"hp": 1030`, `"defense": 73` e `"speed": 108` permanecem identificados ao lado. Para reduzir somente a técnica, altere o `power` de `Sobrecarga` de `1.65` para `1.55`; atualize também o texto de `165%` para `155%`.

Cada ação é um objeto separado em `basic`, `skill` ou `ultimate`, com campos identificados `name`, `kind`, `power` e `description`. Adicionar `"cost": 35` e `"cooldown": 3` dentro dessa habilidade substitui os padrões somente dela. Outros campos já usados no elenco: `effect`, `extraEffect`, `combo`, `secondary`, `pierce`, `shieldScale`, `executeThreshold` e `executeMultiplier`. Preserve os campos existentes quando adicionar uma substituição.

`speed` define a ordem de iniciativa. `defense` entra na curva de mitigação; não corresponde diretamente a uma porcentagem de redução. Um tanque não intercepta ataques automaticamente por ocupar a frente: Provocação e Cobertura são as regras que alteram os alvos/destinatários do dano.

## Exemplo: ajustar uma fórmula global

Para reduzir o teto das barreiras para 22%, altere **somente** `shield.maxHpRatio` de `0.25` para `0.22` em `src/balance.json`, depois sincronize. Para mudar o crítico para 12%, edite `critical.chance` para `0.12`.

Os motores leem esses mesmos parâmetros. No JavaScript, `RULES` é exportado por `src/engine.js`; no Godot, cada instância expõe `combat.rules`. O alias `combat.SHIELD_CAP` corresponde a `rules.shield.maxHpRatio`.

Descrições de habilidades em `src/kits.js` são editoriais: revise os textos relacionados quando mudar uma duração ou efeito global. A descrição compartilhada da Defesa em `src/data.js` é derivada dos parâmetros automaticamente. Crítico, Fratura, vantagens, estados e limites de escudo do HUD e da ajuda são derivados dos parâmetros por `godot/scripts/rules_text.gd` e `combat_ui.gd`. Um poder escrito no texto não controla a fórmula. A interface deve mostrar o resultado dos recibos do combate, que continuam sendo a fonte do dano efetivamente aplicado.

## Onde fica a fórmula de dano

`act()` no JavaScript e `act()` no Godot seguem a mesma sequência:

```text
ofensiva = ataque × enfraquecimento × fortalecimento × poder
           + escudo convertido × conversão da habilidade
defesaEfetiva = defesa × exposição × passiva arcana
mitigação = damage.defenseBaseline
            / (damage.defenseBaseline + defesaEfetiva × damage.defenseWeight)
golpe = arredondar(ofensiva × mitigação × afinidade × defesa ativa
                   × fortificação × combos × crítico)
```

O golpe é limitado por `minimumHit`. Cobertura divide esse total; perfuração define a parte que atravessa a barreira; o restante consome escudo e depois vida. O dano aplicado à vida é limitado à vida restante. Dreno usa esse dano efetivo à vida, nunca a parcela absorvida pelo escudo. Espelho e Riposta geram reações sem criar uma cadeia infinita de contra-ataques.

Cura é limitada à vida ausente e recebe as reduções de sangramento e Fratura **multiplicadas**. No início do turno, Fratura resolve antes dos danos periódicos e da regeneração. Ao chegar a zero de vida, o personagem não recebe cura e não revive. Não altere a posição dos arredondamentos ao reorganizar a fórmula: isso muda os resultados mesmo mantendo os números.

## Campanha e dados das simulações

Gemas e multiplicadores das missões são aplicados em `campaign.battle()` sobre cópias dos atributos de combate. O elenco base não é alterado. Combate livre, duelo local e laboratório continuam usando os atributos base, sem engastes; as partidas de campanha não entram na tabela de equilíbrio livre.

Três gemas iguais somam os bônus antes de arredondar uma vez: três gemas de ataque dão +12% do ataque base, não três multiplicações sucessivas de 1,04. A vida adicional também aumenta valores baseados em vida máxima, incluindo o teto de escudo; avalie sustentação junto com dano e tempo até a eliminação.

Ao mudar valores de verdade, crie uma nova versão das regras e mantenha os resultados históricos separados. Os identificadores usados nos relatórios estão em `godot/scripts/simulation_log.gd`; o armazenamento dos resumos fica em `godot/scripts/lab.gd`. Não misture partidas antigas e novas sob o mesmo número de versão. Esta reorganização mantém `0.5.0` porque os resultados não mudaram.

## Rotina depois de editar

Na pasta raiz `PROJETO-NEXUS`:

```sh
npm run sync:godot
npm test
npm run test:godot
npm run check
```

A sincronização atualiza o catálogo e copia os parâmetros globais para o Godot. Os testes JavaScript cobrem regras e invariantes; a suíte Godot compara partidas completas, IA, recibos e logs exportados com o motor JavaScript. Asserções que mencionam valores antigos devem ser revisadas junto com uma mudança intencional de regras, preservando a cobertura do comportamento.

Abra o Godot, confirme a habilidade alterada e rode uma nova bateria no laboratório. Compare primeiro o mesmo conjunto de adversários e sementes. Leia N, dano à vida, dano ao escudo, cura, proteção e duração das partidas junto do win rate; uma amostra pequena ou formada só por contrapartidas favoráveis não prova dominância.

O protótipo web importa `src/balance.json` como módulo JSON e precisa ser servido por HTTP com `Content-Type: application/json`; o servidor do projeto já faz isso. `npm run build` inclui o arquivo na versão estática. `npm run build:pages` publica os arquivos do protótipo web e deve ser usado somente quando essa publicação fizer parte da entrega.
