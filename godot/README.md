# NEXUS em Godot

Primeira base jogável em **Godot 4.6 / GDScript**, validada com Godot 4.6.3 Standard em Linux. Sem addons, bibliotecas pagas, C#, chaves de API ou dependências de produção do npm. O motor é gratuito e tem licença MIT; desenvolvimento local não exige hospedagem.

## Abrir e jogar

1. Instale o [Godot Standard](https://godotengine.org/download/) 4.6 ou posterior; a edição .NET não é necessária.
2. Obtenha o código da branch `codex/nexus-jogavel`. Com Git:

   ```bash
   git clone --branch codex/nexus-jogavel --single-branch https://github.com/JonathaPereira/PROJETO-NEXUS.git
   ```

3. No gerenciador de projetos do Godot, escolha **Importar** e selecione `PROJETO-NEXUS/godot/project.godot`.
4. Abra o projeto, aguarde a importação das imagens e fontes e pressione **F5**.
5. Clique em **Montar equipes**, escolha três heróis por lado e confirme. Escolha treino contra IA ou duelo no mesmo computador e use **Iniciar combate**.
6. Selecione ataque, técnica, supremo ou defesa. Clique no personagem ou no botão do alvo e confirme em **Usar em…**. As ações de cura e proteção escolhem aliados.

O editor também executa o jogo pela linha de comando, a partir da raiz do repositório:

```bash
godot --path godot
```

Atalhos: **1–4** selecionam a ação; **Enter** confirma quando o foco não está em outro botão. Há guia de afinidades, instruções, opção de reduzir animações e som sintetizado ativado por botão. A formação e as preferências são salvas em `user://preferences.cfg`; uma batalha em andamento não é restaurada. Para trocar equipes durante uma partida, use **Reiniciar**.

## Escopo desta etapa

- 24 heróis, quatro por afinidade, com as habilidades e os atributos do protótipo web.
- Ciclo Ígneo → Natural → Técnico → Arcano → Sombrio → Lumi → Ígneo; vantagem +25%, desvantagem −15%.
- Combate determinístico: iniciativa, energia, recarga, barreiras, defesa, queimadura, regeneração, exposição, enfraquecimento, purificação, crítico e roubo de vida.
- IA, três dificuldades de treino, duelo local com atributos iguais, resultado e replay. A Fratura a partir da rodada 12 encerra impasses defensivos.
- Arena e ilustrações existentes, deslocamento e impactos procedurais básicos com variações por personagem, números de dano/cura e sinais sonoros próprios.

A direção visual é provisória. O rework de gráficos, animações e clareza das regras será feito depois de validar esta base. As animações atuais usam ilustrações, não esqueletos ou quadros completos por golpe. O layout nativo foi conferido em computador; celulares e outras plataformas exigem validação específica.

Campanha, missões, aquisição, economia, multiplayer online, painel de balanceamento e ligação com A Lei do Trono são etapas futuras. O Godot não substitui o site existente automaticamente: **o GitHub Pages continua executando a versão JavaScript**. Nenhum executável ou pacote de download foi gerado nesta etapa.

## Estrutura e dados

| Arquivo | Função |
| --- | --- |
| `scenes/main.tscn` | Cena inicial |
| `scripts/main.gd` | Interface, formação, fluxo dos turnos e preferências |
| `scripts/combat.gd` | Regras e IA, independentes das cenas e do áudio |
| `scripts/catalog.gd` | Carregamento do elenco e validação de equipes |
| `scripts/fighter.gd` | Ilustração, barras e seleção de personagens |
| `scripts/impact.gd` | Efeitos procedurais temporários |
| `scripts/sound.gd` | Geração dos sinais sonoros |
| `data/catalog.json` | Catálogo compartilhado, versão de esquema 1 |

Enquanto as duas versões coexistem, `src/data.js` na raiz é a fonte dos atributos e habilidades. Para atualizar o catálogo e copiar os recursos para o Godot:

```bash
npm run sync:godot
```

O script usa apenas o Node. Os arquivos gerados já estão versionados, portanto **não é necessário instalar Node para abrir ou jogar no Godot**. A pasta `.godot/` é um cache local e fica fora do Git. Preserve os arquivos `.uid` e os metadados `.import` versionados.

O motor de combate não depende dos desenhos nem dos controles. Isso permite refazer a apresentação depois, preservando as regras; mudanças de balanceamento serão deliberadas e poderão ser comparadas em simulações. A tabela de regras detalhada permanece no [README principal](../README.md).

## Verificação

Na raiz, com Node 24+ e o Godot disponível no PATH:

```bash
npm test
npm run test:godot
```

Para outro nome/caminho do binário, use a variável `GODOT_EXECUTABLE`. O teste importa o projeto, compara partidas completas com o motor JavaScript e executa verificações nativas da interface. Cobre os 24 heróis, dificuldades, ações inválidas sem alteração do estado, estados, desempates da IA, Fratura, formação, persistência, resposta da IA, prevenção de ação duplicada, cancelamento da IA ao reiniciar, animação, partida local completa e replay. Os dados de teste e as preferências ficam isolados em `artifacts/`, fora do Git.

Uma conferência gráfica opcional requer um display ativo:

```bash
godot --path godot --script res://tests/capture.gd -- /caminho/absoluto/para/capturas
```

Os testes não instalam plugins nem baixam recursos. A exportação web ainda precisa de templates oficiais, configuração de exportação com inclusão de `data/*.json`, teste de áudio, fontes e desempenho nos navegadores, e validação da hospedagem. Não há preset de exportação declarado como pronto.

## Integração futura com A Lei do Trono

Esta etapa mantém o NEXUS independente e não altera o outro repositório. Os identificadores estáveis do catálogo, como `veyra` e `igneo`, serão referências de conteúdo; identificadores de unidades como `0-veyra` valem somente dentro de uma batalha.

A integração futura deverá passar por uma API compartilhada para identidade e pelo servidor para progresso, inventário e recompensas. O domínio do NEXUS terá nomes próprios para evitar conflitos com os itens e personagens de A Lei do Trono. O cliente Godot enviará intenções de ação; partidas competitivas e recompensas deverão ser validadas pelo servidor. O salvamento local deste protótipo não representa posse de personagens ou saldo de uma conta online.

Compartilhar conta não obriga compartilhar economia. Quais conquistas, personagens e recompensas transitam entre os jogos será uma decisão de produto posterior.

## Recursos e licenças

Arena e atlas foram gerados para o protótipo existente. As fontes Cinzel e Manrope acompanham suas licenças SIL em `assets/`. Os sons são sintetizados pelo código do jogo. A [licença MIT do Godot](https://godotengine.org/license/) não impõe royalties do motor; uma futura distribuição deverá incluir os avisos exigidos pelo motor e pelos recursos utilizados. Hospedagem e lojas podem ter custos próprios.
