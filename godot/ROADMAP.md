# Progressão e próximas etapas

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
