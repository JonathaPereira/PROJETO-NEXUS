## Checkpoint para continuidade em outro chat

Checkout de continuidade: `codex/renascimento-save-recovery`. Estado atual:
24 heróis/seis afinidades, seis capítulos/48 missões principais, três
secundárias, três desafios, 24 jornadas/pactos e save 10. Progressão,
equipamento/gemas, vínculos, objetivos/ondas/campos/fases e 24 perfis corporais
estão implementados nas fatias documentadas; os supremos de Rhazen/Cindra
acrescentam 16 desenhos aos 192 anteriores. Corte local de fontes 80 e
documentação/evidências 81 no ZIP de 10/11/2026. Os pacotes iniciais com nove
missões/save 8 são históricos e permanecem preservados. Sem homologação 1.0.

Prompt, diretriz original e checklist completa ficam no repositório `A-LEI-DO-TRONO-SERVER`, em `docs/RENASCIMENTO_CHECKPOINT.md`, também incluído no pacote de transferência. A autorização atual exige confirmação explícita para commit e push; a continuidade conserva fontes locais e pacotes sem executar essas ações. Branches e revisões estão registradas no manifesto do ZIP consolidado. Não depende de logs locais ou do histórico do chat. Pacotes são reconstruíveis; não houve deploy ou homologação 1.0.

## Renascimento — fundações em desenvolvimento

Incremento 80: oito desenhos exclusivos de Constelação ardente
de Cindra. Achado de revisão sobre escala da emissão reproduzido nos dois
lados e corrigido no Fighter, preservando a escala padrão. Nove casos de
transição/geometria e 62 de comportamento, 55 JS/check, nativo quatro casos
e export 113,4 MiB passaram; Chrome em duas resoluções inspecionado, inclusive repouso/controles após queimadura do
supremo e básico posterior. Standards/Spec sem achados restantes após correção do P2. Demais 23 perfis/quadros
básicos/tempos/kits/saves intactos; sem aceite humano. Integrada ampla do 78
é histórica, não uma nova execução 80.

Ensaio 79 isolou a seleção Web incorreta do roteiro78: lista aberta por mouse
começava sem item focado; Home não mudou esse estado e uma seta focou Veyra.
Duas setas/Enter selecionaram Rhazen; abertura por teclado conservou foco e
exigiu uma seta/Enter. Reprodução mínima e galeria em duas resoluções
conferidas, sem alterar produto/motor. Não conclui acessibilidade ampla.

Incremento 78: supremo corporal de Rhazen com oito desenhos
exclusivos, preservando básico/defesa/derrota/repouso e resolução do combate.
26 dirigidos e cinco transições passaram; nativo observou oito quadros em
duas resoluções/ambos os lados, estado único igual ao motor. 55 JS/check e integrada passaram: 286 coreografias,
1.301 nativos/1.272 UI, paridade/replays. Web local 112,6 MiB, Chrome em duas
resoluções conferido após repetir seleção inválida de personagem. Standards/
Spec sem achados; sem homologação dos supremos de todo o elenco.

Ensaio 77, sem mudança de produto: 25 campanhas compararam foco no relé.
Kira/Bast/Vektor e Ivo/Vesper/Maura chegaram a 48/48 ao priorizar a curadora
nas duas primeiras rodadas; recursos conquistados/RNG normal, sem grind.
A política atual continua perdendo com esses trios, e três outras composições
não passaram com as táticas experimentadas. Seis composições têm percurso
completo comprovado por políticas distintas; equilíbrio amplo e humano abertos.

Refluxo das marés (76) acrescenta Enfraquecimento purificável à segunda fase
do Executor, conservando limiar, potência, custo/recarga, trios, progressão e
kits livres. Passaram 38 padrões, 55 JS, integrada 1.301/1.272 UI, paridade
e replays; quatro trios completaram 48/48 com recursos conquistados. Export
Web local de 111,9 MiB e inspeção nativa em duas resoluções concluídos;
Chrome confirmou fase 2 e vitória em duas resoluções: 17 rodadas/76 ações,
com automático normal e perfil desbloqueado de fixture. Standards/Spec sem
achados; reexecução independente dos 38 padrões passou. Perfil desbloqueado e atores/
limiar/100 EN nativos são fixtures; sem homologação humana ou publicação.

Ensaio nativo 73, sem mudar fontes Nexus: 1.316 ciclos mistos/1.802,790 s
em Wayland/llvmpipe, 439 cancelamentos, 877 conclusões (438 puladas) e 54
reaberturas isoladas. Saída 0 sem erros/avisos de recursos, retorno das ações
conferido antes de liberar Main. Trinta amostras: 617–640 nós, 3.718–3.830
objetos e memória estática 70,0303–71,0801 MiB (primeira/última 70,0303/70,8857).
Ator/100 EN, áudio Dummy desativado e verificações concorrentes são fixture;
categorias de cancelamento/pulo permanecem associadas aos heróis como no 71.
Não mede cada herói em cada categoria, RSS/memória do driver/GPU ou 60 FPS
no hardware físico; sem aceite humano. Não comparar valores absolutos com
headless como redução total de RAM. A meta ampla de desempenho segue aberta.

Ensaio 71: 1.325 ciclos mistos em 1.801,028 s, com quatro ações/24 heróis,
442 cancelamentos, 883 conclusões (441 puladas) e 55 reaberturas isoladas.
Ator/100 EN são fixture; cancelamento não confirma turno e conclusão/pulo
confirma uma vez. Retornos aguardados antes de liberar Main, saída 0 sem
avisos de recursos. A primeira execução liberava o dono cedo e permanece
preservada com seu aviso; a correção foi no roteiro, sem mudar o jogo.
Memória headless 343,9530→373,5109 MiB: uma reprodução sem carregar o jogo
corresponde ao [defeito Godot #124439](https://github.com/godotengine/godot/issues/124439).
Nodes/Node2D, Controls fora da árvore/reutilizados e o controle nativo por
software ficaram estáveis. Motor 4.6.3 mantido; não comprova memória/FPS do
jogo nativo ou hardware físico. Homologação permanece aberta.

Coleção preserva foco/rolagem após melhorias, especializações, troca de peças
e treinamento. Ações que ficam indisponíveis devolvem foco ao seletor habilitado; troca
mantém destinatário e treinamento conserva a aba. Falha de save conserva
prévia/retry com rollback existente. Selecionar herói nas quatro telas não
altera trios nem perde o foco; navegação posterior não sofre restauração
atrasada. Passaram 30 casos dirigidos, 55 JS, checagens e export local de
111,9 MiB. Inspeções nativa/Chrome em duas resoluções verificaram melhorias sucessivas,
especialização e treinamento por teclado, com progresso/maestria de fixture.
A primeira tentativa Web de treinamento não aplicou a variante; foi preservada
e repetida com Tab/Enter, confirmando Ritmo. A integrada passou com 284 de
coreografia, 110 de derrota, 33 de lições, campanha 48/48, 1.301 nativos/1.272
UI, paridade de 36 partidas/2.018 ações e 282 logs/17.730 ações reproduzidas.
Revisões de código sem achados; precisão documental do fallback corrigida.
Áudio Dummy/mutado e renderização por software, sem aceite humano.

Aprender oferece cinco batalhas guiadas: as três anteriores e purificação/
Égide, transmissão de aflições/interceptação. Os recibos reais marcam objetivos;
proteção sem remoção ou ataque sem aflição não simulam progresso. Lista rolável,
foco acompanhado e estados textuais Pendente/Feito atendem as resoluções
1280×720/1600×900. Opções ficam indisponíveis no PvP com explicação; ao sair,
trios, modo e dificuldade livres voltam, sem gravar campanha ou registros.
Passaram 33 casos dirigidos e seis simulações legais de objetivos (três sementes
por lição, seis ações cada), integrada 1.301/1.272 UI e paridade/replays. Export
local de 111,9 MiB e inspeções nativa/Web concluídos, com a quinta lição em 2/2
por teclado/ordem natural e movimento reduzido escolhido na interface. Revisões
Standards/Spec sem achados. A integrada rodou 27 dirigidos; os 33 finais incluem
seis casos legais acrescentados depois. Sem aceite humano ou mudança de kits/saves.

Validação do elenco: passaram 284 casos de coreografia, 110 de derrota,
55 testes JS e PvP nativo local com 305 verificações/69 ações, além de dois
clientes Chrome locais. Ensaio de 240 cancelamentos/retornos alternando os
24 concluiu em 155,19 s: 617 nós/3.690 objetos constantes, 334,64–336,29 MiB.
É uma fixture limitada, sem prova de GPU física/sessões por horas. Revisões
Standards/Spec de 55/56/58/59/60/61 concluídas sem achados; sem aceite humano.
A integrada passou com 1.301 verificações nativas/1.272 de interface, 36
partidas em paridade (2.018 ações), 282 logs (17.730 ações) e campanha
contínua 48/48. Isso não substitui as matrizes amplas ou o aceite humano.

Elyra, Solen e Zaya completam os 24 perfis corporais de oito desenhos
(192 desenhos), referenciados em `lumi-three.png`. Cajado/palma/arco têm
fases próprias; curas, barreiras e energia conservam suporte. A seleção
corrige fundos/auras e margens; prompts integrais e as três correções de
Elyra constam no manifesto, com hashes e aceite humano falso. Repousos e
kits preservados. Passaram 55 testes JS e export local de 111,9 MiB;
inspeções nativa/Chrome concluídas, suíte completa/ensaio em fechamento.
Revisões Standards/Spec de 60/61 e documentos concluídas sem achados. Os supremos finais e aceite humano continuam.

Noct, Maura e Riven ampliam a 21 os perfis de oito desenhos. Garras, adagas
e magia têm fases próprias; Pacto continua ataque com cura secundária e
Réquiem permanece suporte. As fontes selecionadas corrigem halos, preservando
as candidatas e repousos. Prompts/correções/hashes ficam no manifesto.
Passaram 60 casos dirigidos, 110 de derrota, JS e build Web de 109,5 MiB.
Inspeções nativas e Chrome em duas resoluções concluídas pelo agente;
revisões Standards/Spec de 60/61 concluídas sem achados.
Sem aceite humano ou conclusão dos supremos finais.

Torv, Brin, Bast e Ivo levam a 18 os perfis corporais de oito desenhos,
referenciados em `returned-five.png`. Punhos/cortes têm fases próprias;
curas de Brin e escudos de Bast conservam suporte. As folhas selecionadas
corrigem margens e transparência. Prompts, correções, hashes e bytes estão
em `animation-art.json`; repousos e kits preservados. Passaram 72 verificações
dirigidas e 110 de derrota, checagens JS e export Web de 107,3 MiB. Inspeção
nativa Godot/llvmpipe e galerias Chrome em duas resoluções concluídas pelo
agente. Revisões Standards/Spec de 55/56/58/59 concluídas sem achados no 59,
encerrando as pendências anteriores. Aceite humano permanece pendente.

Veyra, Sylva, Vesper e Auren ampliam para 14 os perfis corporais de oito
desenhos, usando as artes originais individuais. Lâminas, cajado, foice e lança
mantêm identidades; curas/proteções seguem seus kits. As folhas selecionadas
corrigem margem da foice e transparência de Sylva (versão 2), preservando a
candidata rejeitada nas evidências. Repousos e motor permanecem.
Passaram 164 casos de coreografia; após a correção de Sylva, 36 selecionados
com base Rhazen/Cindra e 110 de derrota. Build final de 104,4 MiB, inspeções
Godot/llvmpipe e galerias Chrome em 1600×900/1280×720 concluídos pelo agente.
Manifesto contém prompts, correções e hashes. Revisão independente pendente
por limite de uso; sem aceite humano ou conclusão das animações dos 24.

Ensaio limitado de reinício/cancelamento: 100 batalhas alternando os dez
perfis novos, com retorno ao menu durante a preparação. Após aquecimento,
617 nós e 3.475 objetos nas dez amostras; memória estática 229,11–229,94 MiB
em 64,71 s. Fixture headless com ator forçado, sem prova de FPS/GPU ou sessão
prolongada. Os logs/limites acompanham o checkpoint de fontes.

Elun e Saira levam a dez os perfis corporais. Passaram 116 verificações de
coreografia, 110 de derrota, export de 99,9 MiB e inspeções Godot/Chrome.
As folhas foram selecionadas na primeira geração. Conferência local realizada;
revisões independentes das duas últimas duplas aguardam disponibilidade da
ferramenta. Arte final e homologação humana continuam abertas.

Axion e Astra ampliam para oito os perfis corporais. Passaram 92 verificações
de coreografia, 110 de derrota, export Web local de 97,8 MiB e inspeções
Godot/Chrome em duas resoluções. A conferência local foi realizada; as duas
revisões independentes retornaram limite de uso e permanecem pendentes nesta
fatia. Arte e homologação humana continuam abertas.

Arquivista e Primeira Arquiteta têm pressões diferentes na segunda fase:
Exposição purificável e dano com 35% de passagem por escudos. Preparação,
HUD e Registro explicam as respostas. Passaram 25 verificações específicas,
457 regressões pertinentes e quatro campanhas contínuas 48/48 com progresso
adquirido. Export Web e inspeção nativa são desenvolvimento; não homologação.

Kira e Vektor levam a seis os perfis corporais expandidos. As novas folhas
conservam rifle/drones e habilidades de suporte, com pontos próprios de emissão.
Passaram 68 verificações de coreografia, três de transições, quatro de
enquadramento e 110 de derrota, além da regressão integrada. Galeria e
opacidade dos derrotados receberam correções verificadas. Export Web local
de 95,7 MiB e inspeção do agente são desenvolvimento, sem aceite humano.

O piloto corporal agora inclui Oren e Nima, além de Rhazen e Cindra. As
quatro folhas usam fases/tempos próprios e o mesmo controlador. As 44
verificações de coreografia, 110 de derrota, export e inspeções nativas/Web
passaram. Os kits e repousos foram preservados. Isso não encerra o programa
de animações completas do elenco ou o aceite artístico humano.

Cindra ampliou o piloto com uma segunda folha de oito desenhos, fases de
arco, postura protetora de Sinal Escarlate e derrota ajoelhada. São 24
verificações de coreografia para os dois heróis, mais a regressão de derrota
do elenco. A mudança reutiliza o controlador sem alterar motor ou saves.
O programa de animações completas e o aceite humano continuam abertos.

Piloto de coreografia corporal entregue em Rhazen: folha adicional de oito
quadros, fases e tempos por ação, defesa própria e derrota ajoelhada. Há
14 verificações dirigidas e inspeção renderizada; a integração usa os Tweens
do diretor existente. Originais e fallback do elenco permanecem. O trabalho
de animações completas dos 24 e o aceite humano continuam pendentes.

Corrigida a pose de derrota que podia se reerguer ao cancelar a apresentação
anterior. O mesmo estado final atende movimento reduzido, pulo e snapshots;
Fighter mantém a pose, usando o Tween controlado pelo diretor na animação.
Há 110 verificações direcionadas, incluindo os 24 heróis nos dois lados,
dano periódico e reflexão fatal. Animações finais completas continuam abertas.

Os nove comandos do combate têm remapeamento em Teclado, com conflitos por
troca, restauração, dicas coerentes e persistência nas preferências. O mesmo
mapa atende captura e despacho. Automático e pulo permanecem locais; janelas
abertas bloqueiam atalhos de batalha. Inspeção e evidências ficam na checklist
Renascimento principal; isso não encerra a acessibilidade ou a homologação.

Incremento tático: objetivos de ritual com prazo, defesa do trio,
comandante, portador escolhido, ondas e campo em seis encontros existentes, com preparação/HUD/resultado e IA de
campanha orientada ao objetivo. [Regras e controles](CAMPAIGN.md#objetivos-táticos--incremento-renascimento).
Na fundação, esse incremento manteve nove missões; a revisão Lumi ampliou o elenco para 24 ativos. O incremento de equipamentos iniciou no save 5; fabricação/fusão usam o save 6. Não altera o combate livre
ou o protocolo PvP. A continuidade descrita abaixo acrescenta expansão, vínculos e técnicas pessoais. Audiovisual final e homologação continuam pendentes.

Novo incremento: **Coleção → Oficina** com três peças, patamares I–III, três especializações alternativas, fragmentos de primeira vitória/repetição, prévias e troca gratuita entre heróis. Migração dos formatos 1–4 para 5, conservação de gemas e investimento, recuperação conjunta e rollback de edições em falhas de disco. [Regras entregues e próximas etapas](PROGRESSION.md). As alternativas de maestria chegaram no save 8; vínculos chegaram no 9 e técnicas pessoais no 10.

Incremento seguinte: **fabricação escolhida e fusão de gemas até III**, estoque por nível, confirmação e proteção das cópias equipadas. Save 6 migra 1–5 com backup exato e recupera receitas/peças/gemas/fragmentos juntos. Economia validada em campanha e teto opcional do trio; equilíbrio amplo ainda pendente.

Incremento de evolução: **nível comum 1–6 e maestria I–III por participação**, bônus limitados por função, tela Evolução, HUD e recibos reais. Save 7 migra 1–6; histórico concede nível comum e não inventa trios antigos. [Regras e curvas](PROGRESSION.md#nível-comum-e-maestria-entregues).

Incremento de habilidades: **Ímpeto, Economia e Ritmo** para técnica, supremo e básico dos 24 heróis, desbloqueados por maestria. Prévia, escolha gratuita e cartões com custos reais; save 8 migra 1–7. [Regras e limites](PROGRESSION.md#habilidades-treináveis-entregues).

Primeiro incremento: backup rotativo e recuperação de saves de campanha
ilegíveis/ausentes, com aviso e preservação do arquivo danificado. Manual em
[CAMPAIGN.md](CAMPAIGN.md); testes em `tests/save_recovery.gd`, incluídos em
`npm run test:godot`. O incremento seguinte migra formatos 1/2/3 para o formato 4,
com IDs e recompensas históricas por missão, pré-requisitos/agrupamento explícitos,
proteção contra dados desconhecidos e UI que conserva a identidade ao reordenar.
Regressões de migração e da interface real em `tests/mission_progress.gd`.
As nove missões originais permanecem disponíveis; a revisão Lumi disponibiliza os 24 heróis originais.
O escopo completo está em [DESIGN.md](../docs/DESIGN.md). A campanha chegou a
seis capítulos, 48 missões principais e três secundárias. A preparação dedicada
mostra condições, recompensa e falas nos encontros culminantes.

Ondas entregues na escadaria das marés: dois grupos, conservação do trio e recompensa apenas após o último; estado e saves preservados. Campo de energia entregue na guardiã da memória. O Arconte e o Custódio já têm duas fases com troca de técnica. O Colapso levou a campanha a 17 missões. As Seis Verdades, Nexus e os três arcos de contraprovas completam a rota atual, com os mesmos IDs históricos. [Manual da campanha](CAMPAIGN.md).

A campanha registra vínculos desde o save 9 e oferece 24 jornadas de pacto,
três secundárias e três desafios. O save 10 acrescenta uma técnica pessoal por
herói, adquirida pela jornada e escolhida gratuitamente em Coleção → Evolução.
As jornadas preservam a seleção livre e os kits base do Livre/PvP.
[Progressão e limites](PROGRESSION.md#vínculos-e-pactos).

Em Extras, oito conquistas locais mostram condições e progresso derivados
do save: campanha, jornadas, nível, vínculos, maestria e desafios. Abrir a
tela conserva o arquivo e as recompensas. [Regras](PROGRESSION.md#conquistas-locais).

Créditos e avisos completos de fontes, motor e síntese estão em **Extras →
Ver créditos**, incluídos no export e com retorno sem alterar o progresso.

O combate livre e a campanha agora oferecem **Pular animação** durante uma
ação. O resultado já calculado, efeitos periódicos e recompensa são aplicados
uma vez; reinício/saída invalidam a apresentação anterior. PvP conserva seu
fluxo autoritativo. A suíte específica é `tests/animation_skip.gd`.

## Revisão Lumi — regras 0.16.0

Auren (tanque purificador), Elyra (cura com barreiras), Solen (dano que consome enfraquecimento) e Zaya (cura/energia de equipe) completam os 24 ativos/seis afinidades. Ciclo Sombrio → Lumi → Ígneo; os vinte kits anteriores permanecem. Fichas, 16 falas sintéticas adicionais, arte isolada e assinaturas de efeitos integradas; 72 alternativas de treino. Arte/animação/voz final e aceite humano continuam pendentes. Laboratório com 282 partidas e arquivos 0.16 próprios, preservando os registros 0.15. Servidor PvP publicado precisa acompanhar o catálogo antes de aceitar o pacote novo; validação local usa cliente e servidor da mesma versão. Nenhuma publicação realizada.

## Alpha 0.13 · PvP experimental

Salas online por convite, preparação com gemas livres e três engastes por herói, servidor autoritativo, registros próprios, painel administrativo e exportação Web. [Publicação e integração](PVP.md). Ranking, contas e login do A Lei do Trono continuam como próximos passos.

# Estado atual — Alpha 0.12

Menu inicial com jornada e trio, estados com ícones próprios e inspeção acessível, impactos pintados e áudio em camadas. [O que mudou](POLISH-0.12.md). A progressão segue [o estado entregue e as propostas](PROGRESSION.md), equilibrando campanha/domínio e equipamentos/gemas. As regras de combate continuam em 0.11.0.

# Estado atual — Alpha 0.11

A direção principal é **2D**, com nove missões, automático, vinte heróis, identidades de classe e oficina de engastes. [Implementação e capturas](CLASSES.md). PvP online e evolução futura para 3D continuam no roteiro.

O registro abaixo descreve as etapas anteriores; números e regras atuais estão em [KITS.md](KITS.md) e [SIMULATIONS-0.11.md](SIMULATIONS-0.11.md).

# Progressão e próximas etapas

**Etapa 3D (Alpha 0.9):** a batalha principal usa arena, iluminação e personagens volumétricos com articulações procedurais, ataques com contato sincronizado e janelas de resultado detalhadas. Esta é a base jogável para evoluir o conceito visual; modelos e animações de arte final, novos capítulos e PvP online continuam sendo entregas futuras. [Escopo e validação](GRAPHICS-3D.md).

Pedidos do jogador em 18 e 19/10/2026, com a primeira etapa na Alpha 0.7 e os refinamentos da **Alpha 0.8**.

Implementado:

- Menu com Sanctum hi-tech, painéis modernos, fontes Space Grotesk/Manrope e acesso à história, heróis, engastes, combate livre, treinos, galeria e laboratório.
- **Heróis:** os 15 personagens têm fichas com atributos, três habilidades ilustradas, descrições, custos, sinergias, origem, motivação e história própria.
- **O Farol Partido:** três missões, três tipos de minions, Vesper como chefe, introduções, dicas e desfechos em texto, desbloqueio e progresso local. A Alpha 0.8 amplia o contexto da queda do Farol e a relação do elenco com a âncora do eclipse.
- **Engastes:** três espaços por personagem, com gemas repetidas; três cópias iniciais de cada tipo e recompensa única por missão; bônus aditivos só na história; troca e remoção gratuitas. Migração do progresso anterior com backup. [Regras completas](CAMPAIGN.md).
- **Combate:** cards de habilidades mais legíveis; recibos por alvo distinguem vida, escudo, valor restante, crítico e estados; coreografias com rastros, antecipação e pausas no impacto em Full HD. São ilustrações 2D: cinco heróis têm quatro poses desenhadas, e os demais usam movimento procedural.
- **Balanceamento:** atributos dos heróis com campos nomeados, parâmetros globais em `src/balance.json` e sincronização para Godot. [Guia das fórmulas](BALANCING.md) e [interpretação das simulações](SIMULATIONS.md).

Próximas etapas:

- **Treinamento de habilidades:** desenvolver skills ao longo do jogo. Custos, limites e tipos de evolução ainda serão definidos.
- Expandir história, objetivos e inimigos depois dos testes deste capítulo.
- Refinar obtenção e efeitos de gemas, antes de adicionar raridades ou melhorias acumulativas.
- Ampliar poses desenhadas e variedade de animações após validar a leitura dos ataques e o ritmo desta apresentação.
- Investigar os extremos das simulações com substituições controladas de heróis, diferentes adversários e partidas jogadas. A amostra atual não comprova equilíbrio competitivo.
- Definir obtenção dos heróis, multiplayer e a relação de progressão com futuros confrontos entre jogadores. O combate livre atual usa atributos normalizados.

O jogador gostou do TTK atual. Preservar esse ritmo em rodadas como referência: sem sustentação infinita e com oportunidade de resposta. A Alpha 0.8 mantém as regras de referência **0.5.0** no combate livre e nas 156 simulações; a reorganização das fórmulas não muda seus valores. Animações mais detalhadas alteram a duração visual, enquanto campanha e gemas não contaminam os dados de balanço.

A montagem de equipes segue livre. A integração futura com **A Lei do Trono** permanece planejada, sem mudanças naquele repositório nesta etapa.
