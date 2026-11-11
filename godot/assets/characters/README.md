# Personagens 2D

`returned-five.png` é uma folha RGBA criada para esta revisão com geração de imagem, usando o atlas original do projeto como referência de identidade para Torv, Brin, Bast, Ivo e Noct. Não é captura de gameplay. As regiões de corpo e retrato ficam em `godot/data/art-regions.json`, mantendo os índices 3, 7, 10, 15 e 18.

As imagens em `docs/classes-preview/` são capturas reais do Godot, produzidas por `godot/tests/capture_classes.gd`. As artes e poses anteriores permanecem no projeto.

`lumi-three.png` isola Elyra, Solen e Zaya em RGBA, criado com geração de imagem a partir do atlas original para preservar seus trajes, armas e paleta. Os índices 21–23 e as artes antigas permanecem; Auren continua usando sua arte e poses anteriores (índice 20). A integração foi inspecionada no jogo; aceite artístico humano continua pendente.

## Coreografia de Rhazen — Renascimento

`../poses/rhazen-renascimento-v1.png` acrescenta oito desenhos corporais RGBA
do Guardião da Fornalha, gerados com a ferramenta nativa image_gen usando
Rhazen em `cutouts-a.png` como referência. A primeira versão cortava a arma
no limite de um quadro; a edição selecionada preserva as oito poses completas.
Prompts integrais, referência, dimensões e SHA-256 ficam em
`godot/data/animation-art.json`. A imagem final tem 1774×887 pixels e 1.280.833
bytes. Nada substitui o repouso original ou os seis atlas anteriores.

As regiões/âncoras e sequências em `pose-regions.json` conectam preparação,
golpe descendente, contato e recuperação; o quadro defensivo atende Coração
de Ferro/Defesa, e o último quadro mostra derrota ajoelhada. O diretor usa
seus próprios Tweens para animar os quadros, sincronizados ao único impacto.
Tempos de Rhazen estão no mesmo metadado, separados das regras de combate.

Inspeção de alfa/margens e capturas do Godot/Wayland com Mesa/llvmpipe foram
realizadas pelo agente. Não constituem aceite artístico humano nem animações
completas dos outros 23 personagens. As capturas temporárias são fixtures de
apresentação, sem progressão/recompensas de campanha.

## Coreografia de Cindra — Renascimento

`../poses/cindra-renascimento-v1.png` acrescenta oito poses da Artilheira de
Cinzas, com `cutouts-a.png` como referência. A edição selecionada corrige
margens do arco e dos pés. A folha RGBA tem 1774×887 pixels e 1.401.341 bytes;
prompts completos e SHA-256 estão em `godot/data/animation-art.json`.

Preparação, tensionamento, disparo, acompanhamento e recuperação atendem
Agulhas de Brasa e Constelação Ardente. Sinal Escarlate conserva sua função
de suporte e usa a postura protetora, assim como Defesa. A derrota tem pose
ajoelhada. A integração acrescenta só arte/metadados ao controlador existente,
com tempos próprios e âncoras, preservando a ilustração de repouso e o kit.

As 24 verificações de coreografia cobrem Rhazen e Cindra, incluindo resultados
do motor, espelhamento, morte real, pulo e movimento reduzido. Inspeção nativa
Godot/llvmpipe foi realizada pelo agente; aceite artístico humano permanece
pendente. Isso não declara as animações completas de todo o elenco.

## Coreografias de Oren e Nima — Renascimento

`../poses/oren-renascimento-v1.png` e `../poses/nima-renascimento-v1.png`
acrescentam oito desenhos para cada personagem, referenciados nos dois
quadrantes inferiores de `cutouts-a.png`. Oren conserva corpo de pedra,
raízes e punhos; Nima conserva cabelo, capa de folhas, arco e aljava. Houve
edição de margens e transparência antes da seleção das folhas. Ambas são
RGBA de 1774×887; prompts completos, bytes e hashes estão no manifesto
`godot/data/animation-art.json`.

Oren usa preparação e golpe pesado em Âncora de Carvalho, mantendo a postura
protetora para Raízes Entrelaçadas e Despertar da Floresta. Nima usa erguer,
tensionar, soltar e recuperar o arco nos três ataques. Defesa e derrota
ajoelhada têm desenhos próprios. São novos dados no controlador existente,
sem alterações de atributos, habilidades ou regras.

As 44 verificações de coreografia cobrem os quatro perfis, e 110 verificações
de derrota cobrem o elenco. O agente inspecionou quadros nativos Godot/
llvmpipe e as galerias Web em 1600×900 e 1280×720. O alfa foi avaliado também
no renderizador existente; o halo do PNG bruto de Nima não aparece como
matte externo no cenário. Inspeções são fixtures, sem aceite humano ou
conclusão das animações completas dos 24 personagens.

## Coreografias de Kira e Vektor — Renascimento

`../poses/kira-renascimento-v1.png` e `../poses/vektor-renascimento-v1.png`
acrescentam oito desenhos por personagem, referenciados em `cutouts-b.png`.
São as primeiras folhas selecionadas, sem edição corretiva. Kira conserva
cabelo curto prateado e rifle ciano; Vektor conserva máscara, casaco e três
drones. Ambas são RGBA 1774×887. Prompts integrais, bytes e SHA-256 estão em
`godot/data/animation-art.json`, com aceite humano marcado como falso.

Kira percorre preparação, disparo e recuperação em seus três ataques.
Vektor dispara no básico; Drone de Manutenção e Rede de Cobalto usam suporte.
Ambos têm guarda e derrota ajoelhada, mantendo os repousos originais.
Âncoras opcionais de emissão alinham projéteis ao desenho, inclusive espelhado.
Uma versão por comando impede que o Tween de uma fase anterior substitua a
pose atual. O diretor continua dono dos Tweens e da resolução de impacto.

Passaram 68 verificações de coreografia, 110 de derrota, três de transição
e quatro de enquadramento. A galeria ajusta a profundidade à altura disponível;
a derrota evita dupla redução de alfa. Build Web local de 95,7 MiB e inspeções
Godot/llvmpipe e Chrome em 1600×900/1280×720 foram realizados pelo agente.
São fixtures de apresentação, sem aceite artístico humano ou conclusão das
animações completas dos 24. O resíduo de alfa baixo das folhas brutas foi
verificado também no shader existente, sem alterar o shader ou as artes originais.

## Coreografias de Axion e Astra — Renascimento

`../poses/axion-renascimento-v1.png` e `../poses/astra-renascimento-v1.png`
acrescentam oito desenhos por personagem, referenciados nas ilustrações
individuais originais. As edições selecionadas corrigem margens de espada,
capa e esferas. Ambas são RGBA 1774×887. Prompts, correções, bytes e SHA-256
estão no manifesto `godot/data/animation-art.json`, com aceite humano falso.

Axion conserva elmo fechado, armadura/capa e espada ciana: Lâmina de Pulso
usa preparação/corte/recuperação; as duas habilidades de proteção mantêm a
postura defensiva. Astra conserva cabelo prateado, traje e três esferas;
seus três ataques percorrem a sequência astral. Guarda e derrota ajoelhada
são próprias. Âncoras de emissão reutilizam o controlador existente.

Passaram 92 verificações de coreografia e 110 de derrota. O agente inspecionou
as fases no Godot/llvmpipe e as galerias Chrome em 1600×900/1280×720; export
Web de 97,8 MiB. A conferência local incluiu o diff, manifesto e margens de
alfa. As revisões independentes não puderam concluir por limite de uso da
ferramenta. São fixtures, sem aceite artístico humano ou conclusão dos 24.

## Coreografias de Elun e Saira — Renascimento

`../poses/elun-renascimento-v1.png` e `../poses/saira-renascimento-v1.png`
acrescentam oito desenhos por personagem, referenciados nos quadrantes
inferiores de `cutouts-b.png`. Foram selecionadas as primeiras folhas, sem
edição corretiva. Ambas são RGBA 1774×887, com arma/corpo inteiros nos quadros.
Prompts, bytes e SHA-256 constam em `godot/data/animation-art.json`; aceite
humano é falso. Repousos originais e kits permanecem nos donos existentes.

Elun conserva cabelo azul, traje e espada violeta. Corte Prismático/Paradoxo
percorrem preparação, corte e recuperação; Trama Impossível mantém proteção.
Saira conserva cabelo violeta, vestido e cajado dourado: Runa Cintilante usa
lançamento, e as duas habilidades de cura usam a postura de suporte. Ambos
têm guarda e derrota ajoelhada. Âncoras de emissão usam a interface existente.

Passaram 116 verificações de coreografia e 110 de derrota, com export Web de
99,9 MiB. O agente conferiu fases/derrota no Godot/llvmpipe e as galerias Chrome
em 1600×900/1280×720. Conferência local de dados, hashes e margens realizada;
revisão independente pendente pela indisponibilidade informada no incremento
anterior. Sem aceite humano ou conclusão das animações de todo o elenco.

## Coreografias de Veyra, Sylva, Vesper e Auren — Renascimento

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

As fontes selecionadas são `../poses/veyra-renascimento-v1.png`,
`../poses/sylva-renascimento-v2.png`, `../poses/vesper-renascimento-v1.png`
e `../poses/auren-renascimento-v1.png`. Todas RGBA 1774×887, em grade 4×2.

## Coreografias de Torv, Brin, Bast e Ivo — Renascimento

Torv, Brin, Bast e Ivo levam a 18 os perfis corporais de oito desenhos,
referenciados em `returned-five.png`. Punhos/cortes têm fases próprias;
curas de Brin e escudos de Bast conservam suporte. As folhas selecionadas
corrigem margens e transparência. Prompts, correções, hashes e bytes estão
em `animation-art.json`; repousos e kits preservados. Passaram 72 verificações
dirigidas e 110 de derrota, checagens JS e export Web de 107,3 MiB. Inspeção
nativa Godot/llvmpipe e galerias Chrome em duas resoluções concluídas pelo
agente. Revisões Standards/Spec de 55/56/58/59 concluídas sem achados no 59,
encerrando as pendências anteriores. Aceite humano permanece pendente.

Fontes: `../poses/torv-renascimento-v1.png`, `../poses/brin-renascimento-v1.png`,
`../poses/bast-renascimento-v1.png`, `../poses/ivo-renascimento-v1.png`. Todas
RGBA 1774×887 em grade 4×2. As candidatas iniciais permanecem no diretório
de geração; nenhuma arte original foi removida.

## Coreografias de Noct, Maura e Riven — Renascimento

Noct, Maura e Riven ampliam a 21 os perfis de oito desenhos. Garras, adagas
e magia têm fases próprias; Pacto continua ataque com cura secundária e
Réquiem permanece suporte. As fontes selecionadas corrigem halos, preservando
as candidatas e repousos. Prompts/correções/hashes ficam no manifesto.
Passaram 60 casos dirigidos, 110 de derrota, JS e build Web de 109,5 MiB.
Inspeções nativas e Chrome em duas resoluções concluídas pelo agente;
revisões Standards/Spec de 60/61 concluídas sem achados.
Sem aceite humano ou conclusão dos supremos finais.

Fontes `../poses/noct-renascimento-v1.png`, `../poses/maura-renascimento-v1.png`
e `../poses/riven-renascimento-v1.png`: RGBA 1774×887 em grade 4×2.

## Coreografias de Elyra, Solen e Zaya — Renascimento

Elyra, Solen e Zaya completam os 24 perfis corporais de oito desenhos
(192 desenhos), referenciados em `lumi-three.png`. Cajado/palma/arco têm
fases próprias; curas, barreiras e energia conservam suporte. A seleção
corrige fundos/auras e margens; prompts integrais e as três correções de
Elyra constam no manifesto, com hashes e aceite humano falso. Repousos e
kits preservados. Passaram 55 testes JS e export local de 111,9 MiB;
inspeções nativa/Chrome concluídas, suíte completa/ensaio em fechamento.
Revisões Standards/Spec de 60/61 e documentos concluídas sem achados. Os supremos finais e aceite humano continuam.

Fontes `../poses/elyra-renascimento-v1.png`, `../poses/solen-renascimento-v1.png`
e `../poses/zaya-renascimento-v1.png`: RGBA 1774×887, grade 4×2.

## Supremo de Rhazen — Renascimento 78

`../poses/rhazen-supreme-renascimento-v1.png` acrescenta oito desenhos próprios
para Queda da fornalha; não substitui a folha básica nem o repouso. Referência:
`../poses/rhazen-renascimento-v1.png`. A primeira candidata tinha margens
estreitas; a correção selecionada conserva ao menos 40 px em cada célula
com alfa acima de 30/255. Há alfa residual baixo fora da silhueta; o shader
existente elimina alfa ≤0,08. A inspeção nativa não mostrou halo externo.
Ambas permanecem nas evidências. RGBA 1774×887,
1.006.280 bytes; geração nativa image_gen, prompts integrais, correção e
SHA-256 em `animation-art.json`, com `humanAcceptance: false`.

Fases próprias por habilidade e seleção de arquivo/escala por quadro ficam
em `pose-regions.json` e Fighter. Básico/defesa/derrota, demais heróis e
combate conservados. Integração acrescenta oito desenhos aos 192 anteriores;
não conclui supremos finais ou animações completas dos 24.

## Supremo de Cindra — Renascimento 80

`../poses/cindra-supreme-renascimento-v1.png` acrescenta oito desenhos
exclusivos de Constelação ardente, com mira elevada e recuperação própria.
A referência é a folha básica de Cindra, que permanece intacta. RGBA
1774×887/1.239.834 bytes; geração nativa image_gen, prompt/correção/SHA-256
em `animation-art.json`, sem aceite humano. A candidata e a edição
selecionada ficam nas evidências; margens de pelo menos 45 px são medidas
com alfa acima de 30/255. Há alfa residual baixo; o shader existente filtra
valores ≤0,08. A inspeção nativa não mostrou halo externo visível.

Arquivo/escala por quadro e sequência do supremo usam o Fighter existente.
O ponto de emissão do quadro 11 acompanha a escala efetiva, inclusive
espelhado: a revisão reproduziu e corrigiu o uso indevido da escala básica.
O básico não ganhou nova âncora; conserva sua apresentação. 62 casos de
comportamento e nove de transição/geometria passaram. Soma 208 desenhos
corporais nas 26 folhas; não conclui animações ou supremos de todo o elenco.
