# Nexus: Ecos do Crepúsculo — proposta de jogo

## Universo

O Nexus mantém seis forças em equilíbrio. Depois da Fratura, cidades inteiras ficaram suspensas entre diferentes momentos da história. Asterion é uma delas: o eclipse nunca termina, suas torres guardam máquinas esquecidas e suas florestas crescem através dos palácios.

O jogador é um **Vinculador**, capaz de reunir três ecos de pessoas que atravessaram a Fratura. Eles mantêm desejos, identidades e afinidades; não são versões do mesmo personagem com elementos intercambiáveis.

## Pilares

1. **Uma decisão legível por turno.** Iniciativa, energia, recarga, estados e vantagem ficam visíveis. Não há velocidade de clique ou tempo limite neste modelo.
2. **Identidade antes de quantidade.** 24 heróis, quatro por classe, com kits e assinaturas reconhecíveis. Obtenção não limita os experimentos do protótipo.
3. **Composição importa.** Dano em área pressiona grupos; dano concentrado elimina antes do próximo turno; guardiões absorvem pressão; suportes prolongam a presença da equipe. A afinidade favorece uma resposta sem determinar automaticamente o resultado.
4. **Batalhas com desfecho.** A Fratura do Nexus impede que combinações de cura e barreiras sustentem um impasse permanente.

## Elenco inicial

| Herói  | Classe  | Técnica              | Supremo                | Assinatura de animação           |
| ------ | ------- | -------------------- | ---------------------- | -------------------------------- |
| Veyra  | Ígneo   | Dança das brasas     | Sol partido            | Arcos de lâminas incandescentes  |
| Rhazen | Ígneo   | Coração de ferro     | Queda da fornalha      | Cratera e fragmentos de fornalha |
| Cindra | Ígneo   | Chuva escarlate      | Constelação ardente    | Rajada de flechas de brasa       |
| Torv   | Ígneo   | Fissura tectônica    | Erupção primordial     | Pilares de magma                 |
| Sylva  | Natural | Jardim suspenso      | Primavera eterna       | Pétalas em florescimento         |
| Oren   | Natural | Casca ancestral      | Despertar da floresta  | Anéis de raízes                  |
| Nima   | Natural | Laço das raízes      | Mil espinhos           | Agulhas triangulares             |
| Brin   | Natural | Sopro verdejante     | Canção do mundo        | Espiral de seiva                 |
| Axion  | Técnico | Campo de contenção   | Protocolo zero         | Contenção hexagonal              |
| Kira   | Técnico | Sobrecarga           | Órbita de aço          | Feixe vetorial                   |
| Bast   | Técnico | Placa reativa        | Bastião magnético      | Placas geométricas               |
| Vektor | Técnico | Enxame de cobalto    | Singularidade mecânica | Drones orbitais                  |
| Astra  | Arcano  | Órbita fragmentada   | Colapso celeste        | Elipses e estrelas               |
| Elun   | Arcano  | Trama impossível     | Paradoxo               | Prismas diagonais                |
| Saira  | Arcano  | Maré de éter         | Coro das constelações  | Runas circulares                 |
| Ivo    | Arcano  | Passo entre mundos   | Horizonte quebrado     | Fenda dimensional                |
| Vesper | Sombrio | Passo da penumbra    | Eclipse absoluto       | Foice crescente                  |
| Maura  | Sombrio | Pacto silencioso     | Réquiem das sombras    | Fios espectrais                  |
| Noct   | Sombrio | Armadura do vazio    | Noite sem fim          | Garras oblíquas                  |
| Riven  | Sombrio | Dívida de sangue     | Última lembrança       | Adagas em rotação                |
| Auren  | Lumi    | Aurora protetora     | Julgamento da aurora   | Lança de luz                     |
| Elyra  | Lumi    | Luz que acolhe       | Segundo amanhecer      | Halo de renovação                |
| Solen  | Lumi    | Selo do horizonte    | Mil sóis               | Raios radiais                    |
| Zaya   | Lumi    | Bênção do crepúsculo | Asas da eternidade     | Leque de penas                   |

Os atributos e descrições executados pelo jogo estão em `src/data.js`. Os nomes são narrativos; tipo e descrição deixam explícito se a habilidade causa dano, cura ou protege.

## Hipóteses para balancear

- Medir duração, taxa de vitória por composição, primeiro supremo, dano absorvido e recuperação. Não existe telemetria de usuários nesta versão; a evidência atual vem de testes locais.
- Começar com atributos iguais e três heróis distintos por equipe. Uma formação pode espelhar escolhas do rival.
- Observar suportes múltiplos, barreiras com regeneração e a vulnerabilidade durante a recarga.
- Confirmar se +25%/−15% oferece vantagem relevante sem anular os papéis da equipe.
- Ajustar a Fratura após medir partidas: deve encerrar impasses sem dominar um combate normal.
- Antes de ranking, medir o impacto de críticos e da iniciativa. Sementes reproduzíveis permitem repetir simulações com as mesmas decisões.

## Decisões ainda em aberto

**Obtenção:** sem decisão sobre campanha, desbloqueio, moeda ou outro sistema. Todos os iniciais permanecem disponíveis.

**Progressão:** não definir raridade, equipamentos ou crescimento de atributos antes de validar o combate em condições iguais.

**Multiplayer pela internet:** exigirá servidor autoritativo, validação, sessões e reconexão. O duelo implementado é local, no mesmo dispositivo.

**Animação final:** a versão atual valida enquadramento, ritmo e identidade usando ilustrações, transformações e partículas. Uma etapa posterior pode incluir rig ou frames de ataque/reação e som individual, preservando a separação entre regras e apresentação.

**Conteúdo:** campanha e arenas adicionais podem explorar as seis forças. A interface atual apresenta somente os modos implementados.
