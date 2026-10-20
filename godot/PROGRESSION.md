# Proposta de progressão — para a próxima etapa

Direção escolhida: **equilibrar campanha e domínio dos heróis com equipamentos e gemas**. Este documento é uma proposta de regras; a Alpha 0.12 mantém o progresso e os três engastes existentes. Níveis, equipamentos e fusão descritos abaixo ainda não estão implementados.

## Um ciclo fácil de entender

**Jogar uma missão → melhorar o trio → escolher uma especialização → enfrentar um novo desafio.**

A campanha deve ensinar as combinações e entregar materiais com destino claro. Equipamentos e gemas devem dar escolhas de montagem. O domínio do herói deve acrescentar maneiras de jogar com seu kit. Nenhum desses caminhos precisa de números infinitos para durar.

| Camada | Como progride | O que entrega |
| --- | --- | --- |
| Campanha | Primeira vitória e objetivos opcionais por missão | Próximos capítulos, diagramas de equipamento, materiais e história |
| Domínio do herói | Experiência compartilhada entre os três participantes e desafios do próprio kit | Marcos de domínio e variantes de habilidade com vantagens e custos |
| Equipamento | Melhorias curtas e limitadas, com materiais visíveis | Ajuste de atributos e identidade do conjunto |
| Gemas | Recompensas escolhidas e fusão de cópias | Direcionamento da montagem, sem substituir a função de classe |

Eu começaria com um nível de equipe compartilhado, que mantém a base dos personagens acompanhando a campanha. O domínio individual cresce com a participação e abre variantes táticas. Assim, trocar de herói não exige reconstruir todos os atributos desde o começo. Suporte e tanque não dependem de dar o último golpe. Derrota não destrói equipamentos, gemas ou experiência já conquistada.

## Equipamentos: começar com três peças

Proponho **Arma, Proteção e Relíquia**, cada uma com um engaste. Isso permite evoluir a interface de três espaços já existente sem multiplicar a quantidade de gemas necessárias por herói.

- **Arma:** contribui com ataque e aparência do estilo de combate.
- **Proteção:** contribui com vida e defesa; não torna o personagem imune.
- **Relíquia:** contribui com a preparação do kit, por exemplo energia inicial; efeitos táticos futuros devem ter limites explícitos.

As peças teriam três patamares, vinculados ao avanço da jornada. Diagramas viriam de capítulos e desafios conhecidos. O jogador deve saber qual missão entrega o material antes de entrar. Uma troca de equipamento deve devolver sua gema ao inventário automaticamente, sem consumi-la.

Antes de adicionar atributos novos, precisamos mostrar a comparação **atual → após equipar**, o custo e o ganho de cada melhoria. O painel da oficina já oferece essa leitura para gemas.

## Gemas: conservar o investimento e limitar a escalada

Na primeira etapa, manteria Brasa, Seiva e Pulso. Depois, acrescentaria gemas táticas em pequenos grupos, avaliando crítico e resistência a crítico antes de abrir evasão, precisão e penetração simultaneamente. Muitos atributos ocultos tornam difícil entender por que um ataque falhou.

A referência de **três gemas iguais virarem uma do próximo nível** pode funcionar com um teto inicial de **três níveis**. Uma gema de nível 3 exigiria nove cópias de nível 1; o jogo precisa conceder essas cópias num ritmo compatível com os nove espaços do trio, sem obrigar o jogador a desmontar a equipe para sentir progresso.

Proposta de parâmetros para simular, antes de aprovar:

| Gema | Nível 1, atual | Nível 2, proposto | Nível 3, proposto |
| --- | ---: | ---: | ---: |
| Brasa | +4% ATQ | +5% ATQ | +6% ATQ |
| Seiva | +5% VIDA | +6,5% VIDA | +8% VIDA |
| Pulso | +8 energia inicial | +10 energia inicial | +12 energia inicial |

O ganho entre níveis é moderado: os tipos, a distribuição e as sinergias continuam importantes. A fusão deve usar somente cópias livres e informar exatamente quais serão consumidas. Cópias equipadas só entram depois de o jogador as remover explicitamente. Remover e transferir continuam gratuitos.

Além das primeiras vitórias, missões repetidas precisariam conceder um recurso fixo de fabricação, com possibilidade de escolher a gema. O sistema atual não dá recompensas repetidas; essa fonte deve entrar junto da fusão, evitando um estoque sem caminho de renovação. Não proponho energia de entrada, perda de item na derrota ou espera obrigatória para avançar.

## Domínio: melhorar a decisão, não todos os números ao mesmo tempo

Começaria com três marcos de domínio por herói. Cada marco abre uma escolha de variante; apenas uma variante de cada habilidade fica ativa. Alterar a montagem fora de batalha deve ser gratuito.

Exemplos para discutir e simular:

| Herói | Variante possível | Custo ou contrapartida |
| --- | --- | --- |
| Vesper | Riposta mais forte durante a Provocação | Menor escudo na mesma técnica; a janela continua curta |
| Brin | Purificação que deixa uma cura posterior | Menor cura imediata |
| Bast | Maior parcela interceptada | Maior risco para o próprio Bast e sem ampliar a duração |
| Ivo | Escolher a aflição que será transmitida | Mantém apenas um destino e não renova a duração |
| Noct | Consumir a marca para antecipar sua drenagem | Perde as ativações futuras da marca |

As identidades das cinco classes permanecem. Domínio não deve fazer um dano ocupar simultaneamente os papéis de curador e tanque. As variantes precisam preservar oportunidades de resposta e ser legíveis no recibo do ataque.

## Campanha e objetivos opcionais

A vitória comum libera a próxima missão. Objetivos opcionais podem premiar composição e domínio: usar uma sinergia entre classes, proteger um aliado ou vencer sem sofrer baixas. Acesso ao próximo capítulo não deve exigir perfeição nesses objetivos.

Capítulos podem conceder um equipamento definido, um marco de domínio e materiais suficientes para experimentar uma melhoria. Uma única moeda comum de fabricação é um começo mais claro que várias moedas concorrentes.

## PvP futuro

Minha recomendação é usar **níveis e atributos normalizados no modo competitivo**, preservando composição, escolhas de habilidade e tipos de gema. A campanha entrega crescimento e conquistas; uma pessoa recém-chegada ainda consegue disputar uma partida justa. O duelo local atual continua usando os atributos base, sem gemas.

Essa política precisa ser escolhida antes de precificar melhorias. Uma progressão longa de atributos e um PvP competitivo dependente desses mesmos atributos criariam uma vantagem de tempo difícil de corrigir depois.

## Ordem sugerida de implementação

1. Equipamentos de três peças, inventário compartilhado e migração segura dos três engastes atuais.
2. Recompensas repetíveis previsíveis e fusão de gemas até o nível 3, com comparação de atributos e proteção de cópias equipadas.
3. Domínio com experiência de equipe e primeira variante testada em poucos heróis.
4. Novos capítulos e desafios para validar o ritmo; só então ampliar os atributos de gemas e preparar PvP online.

Antes de implantar, vamos conferir o tempo para completar um trio, a viabilidade de trocar de personagem, a quantidade de itens livres, a duração dos combates e a diferença entre uma equipe inicial e uma evoluída. O jogador deve conseguir experimentar um novo herói sem recomeçar todo o investimento.
