# Progressão — equipamentos e próximas etapas

Direção escolhida: **equilibrar campanha e domínio dos heróis com equipamentos e gemas**. O incremento Renascimento entrega as três peças, melhorias, especializações e fragmentos repetíveis descritos a seguir. Fabricação e fusão de gemas também estão implementadas. Nível comum e maestria individual também estão implementados. Variantes de habilidades também estão implementadas para os 24 heróis ativos. Vínculos e técnicas pessoais por pacto também estão implementados.

## Implementado no incremento Renascimento

Em **Coleção → Oficina**, cada herói ativo tem Arma, Proteção e Relíquia, com um engaste correspondente aos três espaços antigos. As peças básicas não alteram atributos. Melhorar preserva a gema; mudar especialização ou trocar peças entre heróis devolve as gemas afetadas. A troca conserva o patamar e não copia o investimento. Prévias incluem vida, ataque, defesa e energia inicial da próxima missão, somando equipamentos e gemas.

| Peça | Padrão: patamares I / II / III | Especialização: patamares I / II / III |
| --- | --- | --- |
| Arma | ATQ +0 / +4% / +8% | Canalizador: ATQ −4%; EN +8 / +12 / +16 |
| Proteção | VIDA +0 / +6% / +12% | Bastião: VIDA −4%; DEF +15% / +30% / +48% |
| Relíquia | EN +0 / +4 / +8 | Âncora vital: EN −4; VIDA +4% / +8% / +12% |

Especializações e patamar II abrem ao concluir `eclipse`; patamar III, ao concluir `tidal-heart`. Melhorias custam **3** e **5 fragmentos**, respectivamente. Especialização e troca entre heróis são gratuitas. Não há compra aleatória ou desgaste de peças. Bônus valem só na campanha; os atributos livres/PvP permanecem normalizados.

Primeiras vitórias concedem **6 fragmentos**, mais **6** em cada final de capítulo. Vitórias antigas recebem esse crédito pela lista histórica de IDs. As nove missões originais somam **72**, exatamente o custo de nove peças no patamar III para um trio. Uma nova vitória em missão concluída concede **2** fragmentos e nenhuma nova gema. O resultado precisa pertencer a uma tentativa real da sessão; reabrir/renderizar a mesma tela não concede outra recompensa. Derrota não consome itens.

O saldo deriva de vitórias e repetições menos os patamares investidos. Save atual no formato **10**, migração 1–9 com cópia exata do original, validação do estoque e recuperação conjunta de peças, gemas e materiais. Edições voltam atrás se salvar falhar; recompensas vitoriosas permanecem pendentes em memória, com aviso e sem duplicar ao atualizar o resultado. [Compatibilidade](CAMPAIGN.md#progresso-e-compatibilidade).

## Continuidade por teclado na Coleção

Melhorar, aplicar especialização, trocar peças e aplicar treinamento atualizam
os valores conservando foco e posição de leitura quando o controle permanece
visível. Ações que ficam indisponíveis devolvem o foco ao seletor da mesma
peça/habilidade; o treinamento conserva a aba escolhida. A troca mantém o
herói destinatário, e selecionar outro herói mantém o foco no novo seletor
ou retrato, sem alterar os trios.

Se salvar falhar, a transação mantém seu rollback e a interface conserva a
prévia solicitada e o botão de tentativa. O erro permanece no rodapé; ao
liberar o caminho, Enter aplica a escolha preservada. A restauração espera
o layout e respeita navegação ou uma escolha de foco mais recente.
A implementação pertence ao Hub; Campaign continua dona de transações,
atributos e saves, sem mudança de regras ou formato. Trinta verificações
dirigidas exercitam Enter real, falha/retry, seleções e navegação rápida.
São fixtures de progresso/maestria, sem aceite humano ou campanha conquistada.

## Um ciclo fácil de entender

**Jogar uma missão → melhorar o trio → escolher uma especialização → enfrentar um novo desafio.**

A campanha deve ensinar as combinações e entregar materiais com destino claro. Equipamentos e gemas devem dar escolhas de montagem. O domínio do herói deve acrescentar maneiras de jogar com seu kit. Nenhum desses caminhos precisa de números infinitos para durar.

| Camada | Como progride | O que entrega |
| --- | --- | --- |
| Campanha | Primeira vitória e objetivos opcionais por missão | Próximos capítulos, diagramas de equipamento, materiais e história |
| Domínio do herói | Experiência compartilhada entre os três participantes e desafios do próprio kit | Marcos de domínio e variantes de habilidade com vantagens e custos |
| Equipamento | Melhorias curtas e limitadas, com materiais visíveis | Ajuste de atributos e identidade do conjunto |
| Gemas | Recompensas escolhidas e fusão de cópias | Direcionamento da montagem, sem substituir a função de classe |

O nível de equipe compartilhado mantém a base dos personagens acompanhando a campanha. A maestria individual cresce com participações vitoriosas e concede os bônus limitados abaixo; variantes táticas usam os mesmos marcos. Assim, trocar de herói não exige reconstruir todos os atributos desde o começo. Suporte e tanque não dependem de dar o último golpe. Derrota não destrói equipamentos, gemas ou experiência já conquistada.

## Equipamentos: começar com três peças

Estão implementadas **Arma, Proteção e Relíquia**, cada uma com um engaste. Isso permite evoluir a interface de três espaços já existente sem multiplicar a quantidade de gemas necessárias por herói.

- **Arma:** contribui com ataque; aparência específica da peça no corpo é futura.
- **Proteção:** contribui com vida e defesa; não torna o personagem imune.
- **Relíquia:** contribui com a preparação do kit, por exemplo energia inicial; efeitos táticos futuros devem ter limites explícitos.

As peças têm três patamares vinculados ao avanço da jornada. Diagramas específicos de capítulos e desafios continuam uma possibilidade futura. O jogador deve saber qual missão entrega o material antes de entrar. Uma troca de equipamento deve devolver sua gema ao inventário automaticamente, sem consumi-la.

A oficina mostra atributos atuais, após melhorar, após especializar e após trocar entre dois heróis. Custos e bloqueios de capítulo aparecem antes de aplicar. Aparência de equipamento no corpo e efeitos táticos novos continuam pendentes.

## Gemas: fabricação e fusão entregues

**Coleção → Engastes e gemas** tem seletor de nível I/II/III, estoque livre/equipado, fabricação, fusão e transferência. Após a primeira vitória, **1 fragmento lapida 3 cópias I do tipo escolhido**. Não há sorteio. Uma fusão gratuita consome **3 livres do mesmo tipo e nível** e produz uma do próximo nível. Nível II abre no fim do capítulo I; III, no fim do II. A confirmação informa as cópias consumidas, o resultado e a irreversibilidade, com Cancelar focado. Cópias equipadas nunca entram na receita; só ficam disponíveis depois de remoção explícita.

| Gema | Nível I | Nível II | Nível III |
| --- | ---: | ---: | ---: |
| Brasa | +4% ATQ | +5% ATQ | +6% ATQ |
| Seiva | +5% VIDA | +6,5% VIDA | +8% VIDA |
| Pulso | +8 EN inicial | +10 EN inicial | +12 EN inicial |

O aumento é limitado. Gemas não alteram recargas/custos e a energia continua limitada pelo combate. Prévias e a próxima batalha usam o mesmo cálculo combinado com equipamentos. Remover, transferir ou trocar peça conserva o nível da gema. O preenchimento por função prefere o maior nível livre do tipo desejado, preservando cópias de outros heróis.

O save 6 registra contagens de fabricação/fusão; o estoque deriva das receitas, cópias iniciais e vitórias. Migra saves 1–5 com cópia exata, incluindo `.v5.bak`. Receitas, peças, gemas e fragmentos são recuperados juntos. Custos/contagens acima do conquistado, donos desconhecidos, patamares bloqueados e versões futuras bloqueiam a gravação; falhas de disco revertem a receita inteira.

A campanha pode terminar com as nove gemas básicas equipadas e todas as peças III, sem fabricar ou repetir missões. Depois, **12 vitórias opcionais** rendem 24 fragmentos: 24 lotes escolhidos produzem nove gemas III, mantendo os nove engastes antigos até cada substituição e conservando suas cópias ao final. É um orçamento de teto opcional, não requisito de campanha nem promessa de duração em minutos. Fabricar antes compete pelos mesmos fragmentos usados nas peças; o custo aparece antes de aplicar.

Parâmetros em `data/gem-forge.json`. Fabricação e fusão adicionais, gemas táticas e raridades continuam fora deste incremento.

O Colapso acrescenta oito primeiras vitórias pelo mesmo recibo do save 8.
Cada uma concede gema e 6 fragmentos, com 6 adicionais no desfecho do capítulo.
As regras de EXP, maestria, fabricação e repetição continuam valendo.

## Nível comum e maestria entregues

**Coleção → Evolução** mostra a experiência da equipe, o próximo marco, a maestria do herói escolhido e os atributos completos da próxima missão. O HUD identifica o nível usado naquela batalha; o resultado informa EXP e pontos por participante. Bônus novos só entram na próxima tentativa, preservando o snapshot do combate encerrado.

| Nível comum | EXP acumulada | VIDA / ATQ / DEF sobre a base |
| --- | ---: | --- |
| 1 | 0 | sem bônus |
| 2 | 100 | +2% / +1% / +1% |
| 3 | 250 | +4% / +2% / +2% |
| 4 | 450 | +6% / +3% / +3% |
| 5 | 700 | +8% / +4% / +4% |
| 6 | 1000 | +10% / +5% / +5% |

Primeiras vitórias concedem 100 EXP comum; novas vitórias em missão concluída, 25. Vitórias antigas contam pelos IDs e repetições já salvos. Todos os heróis recebem o mesmo nível, inclusive ao trocar o trio. O nível para em 6 nesta etapa; EXP excedente não continua aumentando atributos. As nove primeiras vitórias levam ao nível 5, sem repetição obrigatória.

Cada integrante que iniciou uma missão vencida recebe **10 pontos de maestria**, igualmente, sem depender de abates, cura ou sobrevivência individual ao resultado. Trocar o trio salvo antes de receber não transfere crédito. Derrota não concede pontos nem apaga marcos. O mesmo resultado não concede novamente. Maestria I/II/III exige **10/30/60 pontos**, com teto 60.

| Função | Maestria I / II / III |
| --- | --- |
| Dano | ATQ +0,5% / +1% / +1,5% sobre a base |
| Tanque | VIDA +1% / +2% / +3% sobre a base |
| Suporte | EN inicial +1 / +2 / +3 |

Cada marco substitui o anterior. Percentuais somam com nível, peças e gemas antes de arredondar uma vez; energia mantém o teto do combate. O nível e a maestria não afetam o livre/PvP. Parâmetros em `data/progression.json`.

O save 7 migra 1–6, com cópia exata `.v6.bak`, e armazena maestria junto das demais conquistas. A experiência comum deriva do histórico existente. Saves antigos não revelam os trios usados: a migração **não inventa participação individual**. Leitura, recuperação e falhas de gravação seguem os mesmos contratos da campanha. Recompensas não salvas ficam pendentes em memória; a tela avisa e não duplica o recibo. Dados desconhecidos, pontos inválidos ou acima das participações possíveis impedem sobrescrita.

## Habilidades treináveis entregues

Em **Coleção → Evolução**, as abas Técnica, Supremo e Ataque mostram desbloqueio, contrapartida e prévia completa antes de aplicar. Cada um dos 24 heróis ativos tem três alternativas, com seleção independente por ação. Trocar ou voltar à versão original é gratuito fora do combate.

| Marco | Variante | Benefício | Contrapartida |
| --- | --- | --- | --- |
| I · Técnica | Ímpeto | fator principal ×1,15 | custo +10 EN |
| II · Supremo | Economia | custo −10 EN | fator principal ×0,90 |
| III · Ataque | Ritmo | recupera +4 EN no básico (28) | fator principal ×0,90 |

O fator principal pode ser dano, cura ou escudo. Nas técnicas sem fator principal que transferem energia, Ímpeto/Economia ajustam a quantidade transferida, arredondando uma vez. Efeitos, alvos, combos, durações, recargas e efeitos secundários restantes conservam a identidade do kit. As descrições e os cartões de combate mostram os valores efetivos. Coleção mostra a prévia base; campos específicos da missão ajustam energia ao preparar o combate (Corrente do éter: básico +4 EN e técnica +5 EN de custo para ambos os lados). Não há novas funções ou purificações implícitas.

A batalha captura a seleção ao iniciar; alterar a preparação depois não muda o combate em andamento. Livre/PvP usam as habilidades originais. O automático da campanha considera custo e energia real do básico. Parâmetros em `data/ability-training.json`.

Introduzido no save **8**, `abilityChoices` migra 1–7 e preserva uma cópia exata `.v7.bak`. Heróis, ações, variantes ou marcos incompatíveis impedem sobrescrita. Falha de gravação desfaz a seleção. A suíte executa as 72 formas alternativas, comparando recibos com a prévia pública, além de testar interface, snapshots, bloqueios, migração e recuperação. As técnicas pessoais adquiridas pelas jornadas ampliam essas opções no formato 10, como descrito a seguir.

## Vínculos e pactos

Cada vitória de campanha credita uma vez os três pares do trio que iniciou a
batalha. Após três vitórias compartilhadas, cada parceiro vinculado no trio
concede **+2 EN inicial**, até +4 por herói. **Coleção → Evolução** mostra os
parceiros e as vitórias compartilhadas. O save 9 valida os pares e o limite de
participação. A migração de 1–8 preserva o arquivo original e começa sem
vínculos presumidos.

As 24 jornadas pessoais ficam em **Coleção → História** após o prólogo. O
protagonista participa com dois parceiros livres. A primeira vitória firma
um pacto que dá um bônus pequeno por função na campanha. O pacto deriva da
vitória da jornada, sem estoque ou contador separado. Os 24 heróis continuam
disponíveis em Livre e PvP com seus kits base.


## Técnicas pessoais adquiridas

Concluir uma jornada libera uma técnica alternativa do protagonista em
**Coleção → Evolução → Técnica → Pacto pessoal**. A seleção é gratuita e
opcional, inclusive sem maestria. Pode voltar à original ou a Ímpeto antes de
preparar outra missão. O combate em andamento conserva sua escolha inicial.

São 24 técnicas com contrapartidas próprias: Veyra troca dano por barreira
pessoal; Cindra troca proteção por purificação e energia; Kira troca potência
por perfuração maior de escudo; Solen troca área por um golpe concentrado.
A prévia mostra o efeito e o custo; campos da missão ajustam o custo final.
As receitas editáveis ficam em `data/pact-abilities.json`.

O save **10** guarda `"pact"` na escolha da técnica e valida a jornada
concluída. Migra 1–9 com cópia exata do original, inclusive `.v9.bak`.
Não concede jornadas ou técnicas automaticamente. Falha de gravação desfaz
a seleção e preserva o arquivo anterior. Os 109 checks específicos incluem
as 24 execuções com prévia, snapshots, migração e o menu real. A inspeção Web
usa um perfil descartável com jornadas concluídas; não representa aceite
humano ou conclusão manual das jornadas.

## Conquistas locais

**Extras → Conquistas locais** mostra oito marcos com requisito, contagem e
estado: primeira missão principal; as 48 principais; nível 6 da equipe;
primeiro pacto; as 24 jornadas; primeiro vínculo maduro; um herói em maestria
III; e os três desafios especiais. Os cartões distinguem progresso de
conquista concluída por texto, além da cor.

As conquistas são calculadas pelos fatos já validados do save 10. Consultar a
tela não grava dados, concede moedas, muda trios ou presume participação.
Saves antigos reconhecem suas missões registradas; vínculos e maestria
continuam dependendo dos registros próprios. Não há serviço externo ou novo
contador para manter sincronizado. As 15 verificações específicas incluem
perfil inicial, catálogo parcial sem metas zero conquistadas, primeira missão salva, reabertura, preservação byte a byte,
progresso antigo e os oito marcos em um perfil completo de teste.

## Campanha e objetivos opcionais

A vitória comum libera a próxima missão. Objetivos opcionais podem premiar composição e domínio: usar uma sinergia entre classes, proteger um aliado ou vencer sem sofrer baixas. Acesso ao próximo capítulo não deve exigir perfeição nesses objetivos.

Capítulos podem conceder um equipamento definido, um marco de domínio e materiais suficientes para experimentar uma melhoria. Uma única moeda comum de fabricação é um começo mais claro que várias moedas concorrentes.

## PvP futuro

Minha recomendação é usar **níveis e atributos normalizados no modo competitivo**, preservando composição, escolhas de habilidade e tipos de gema. A campanha entrega crescimento e conquistas; uma pessoa recém-chegada ainda consegue disputar uma partida justa. O duelo local atual continua usando os atributos base, sem gemas.

Essa política precisa ser escolhida antes de precificar melhorias. Uma progressão longa de atributos e um PvP competitivo dependente desses mesmos atributos criariam uma vantagem de tempo difícil de corrigir depois.

## Ordem sugerida de implementação

1. **Entregue:** equipamentos de três peças, especializações, fragmentos e migração dos três engastes atuais.
2. **Entregue:** fabricação escolhida, fusão até III, prévias e proteção das cópias equipadas.
3. **Entregue para os 24 ativos:** nível comum, experiência, maestria e três alternativas de habilidade por herói. Uma técnica pessoal por herói é adquirida pela jornada; vínculos e escolha opcional já são jogáveis.
4. **Entregues:** seis capítulos, 48 missões principais, três secundárias, três desafios e 24 jornadas. O balanceamento amplo, a validação humana e o audiovisual final continuam pendentes.

Para ampliar essas regras, conferir o tempo para completar um trio, a viabilidade de trocar de personagem, a quantidade de itens livres, a duração dos combates e a diferença entre uma equipe inicial e uma evoluída. O jogador deve conseguir experimentar um novo herói sem recomeçar todo o investimento.
