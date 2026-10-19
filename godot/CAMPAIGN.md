# O Farol Partido — capítulo I

Primeira campanha jogável, introduzida na Alpha 0.7 e ampliada na **Alpha 0.8** com relatos do Farol e fichas dos heróis. São três batalhas independentes, com introdução e desfecho em texto. Treinamento de habilidades continua para uma etapa futura.

O Farol mantinha em equilíbrio cinco ressonâncias — calor, vida, matéria, memória e sombra. Quando seu núcleo se partiu, as defesas começaram a reconhecer seus guardiões como invasores. Uma transmissão pede que o trio quebre a âncora sem destruir o guardião. As missões revelam pistas da sabotagem e da ligação de Vesper com o núcleo; a aba **Heróis → História** mostra por que cada personagem respondeu ao chamado.

## Como jogar

1. No menu, abra **História** e use **Escolher trio**. O primeiro integrante fica na frente, com as mesmas regras de alvo livre do combate normal.
2. Abra **Heróis → Engastes** ou **Gemas**, escolha o herói, selecione um dos três espaços e clique em **Engastar** na gema desejada. O painel mostra os atributos resultantes e quem está usando cada cópia.
3. Volte às missões e use **Jogar próxima missão**, ou escolha uma etapa disponível. No campo de batalha, clique em **Iniciar missão**.
4. Ao vencer, leia o desfecho e a recompensa. **Voltar às missões** retorna à seleção, com a próxima etapa desbloqueada. Use **Jogar próxima missão** para entrar nela; após concluir o capítulo, o botão oferece **Revisitar missão final**.
5. Se perder, tente novamente ou feche o resultado e abra **Menu** para trocar trio ou gemas. A derrota não remove itens nem progresso.

| Missão | Adversários | Primeira vitória |
| --- | --- | --- |
| Os portões quebrados | Sentinela, Rastejante e Acólito | +1 Brasa; abre a missão 2 |
| Ecos no pátio | Minions reforçados | +1 Seiva; abre a missão 3 |
| O guardião do eclipse | Vesper chefe, Sentinela e Acólito | +1 Pulso; final do capítulo |

O Sentinela cria uma barreira própria; o Rastejante aplica sangramento; o Acólito expõe defesas. Vesper mantém sua identidade de provocação e riposta, com mais vida e ataque somente nesse confronto. O kit e os atributos do herói Vesper não mudam. Os inimigos de história não entram nos 15 heróis selecionáveis.

A missão 1 usa os atributos básicos dos minions; a 2 multiplica vida/ataque por 1,24; a final usa 1,05 e um Vesper chefe com 1.800 PV, 205 ATQ, 108 DEF e 78 VEL antes desse multiplicador. O chefe começa com 64 de energia. Estes são parâmetros iniciais para teste, sem promessa de equilíbrio final entre todas as composições.

## Engastes

| Gema | Bônus na história | Estoque inicial |
| --- | --- | --- |
| Brasa lapidada | +4% ataque por cópia | 3 |
| Seiva cristalizada | +5% vida máxima e inicial por cópia | 3 |
| Pulso de éter | +8 energia inicial por cópia | 3 |

São **três espaços por herói**, com **gemas repetidas permitidas**. Cada espaço ocupado usa uma cópia do estoque compartilhado. Uma mesma cópia não pode ocupar dois espaços; para repetir uma gema no herói ou distribuí-la entre heróis, use cópias diferentes. Há nove cópias iniciais ao todo e mais uma de cada tipo ao concluir as três missões pela primeira vez. O herói pode estar fora do trio e continuar com as cópias equipadas: o painel identifica seus donos. Remover ou trocar devolve a cópia gratuitamente. Não há venda, custo, raridade, aumento de nível nem obtenção aleatória nesta versão.

| Três gemas iguais em um herói | Resultado |
| --- | --- |
| 3 Brasas | +12% do ataque base |
| 3 Seivas | +15% da vida base |
| 3 Pulsos | +24 energia inicial: começa com 64 em vez de 40 |

Você também pode misturar os três tipos. Percentuais do mesmo atributo são **somados sobre o valor base antes de arredondar uma vez**, ao criar a missão. Três Brasas não multiplicam o ataque por 1,04 três vezes. A Seiva também altera valores proporcionais à vida máxima, mantendo o limite normal de escudo em 25%. Nenhuma gema aumenta diretamente cura, duração de escudo ou energia por ação. Equipe e engastes só podem ser ajustados entre missões. Cada nova tentativa restaura todos os integrantes.

As composições seguem livres: tanque, suporte e dano não são obrigatórios. Frente e retaguarda são posições visuais; Provocação continua sendo a mecânica que restringe golpes individuais. As regras de sangramento, Fratura, escudo único e redução progressiva de cura permanecem.

## Progresso e compatibilidade

O caminho continua **`user://campaign-0.7.json`**, agora com **`schemaVersion: 2`**. Ele armazena etapas concluídas, trio e os três engastes de cada herói. O estoque é derivado das vitórias, evitando duplicação ao reabrir resultados ou repetir missões.

O formato anterior é reconhecido automaticamente: seu engaste único ocupa o primeiro espaço e os outros dois começam vazios; trio e avanço são mantidos. O estoque passa a partir das três cópias de cada tipo desta versão. **Antes da próxima gravação**, o arquivo original é copiado para `campaign-0.7.json.v1.bak`, e o progresso passa a ser gravado no formato 2. Se já existir um backup diferente, é usado um sufixo numérico para preservá-lo.

A gravação usa arquivo temporário e substituição após escrita; falhas aparecem na interface. Um arquivo ilegível é preservado e recebe cópia `.invalid.bak` antes de uma nova gravação explícita por equipe, engaste ou vitória. Se não for possível preservar o original, ele não é substituído. Batalhas em andamento não são retomadas.

Os dados são locais. Reabrir este mesmo projeto preserva o progresso no diretório de usuário do Godot. Para localizar os arquivos no Windows, use **Executar → `%APPDATA%\Godot\app_userdata\NEXUS — Ecos do Crepúsculo`**. Não há sincronização com GitHub ou outro computador.

Combate livre, duelo local, treinos e laboratório usam atributos base e não recebem bônus das gemas. Campanha não registra partidas na tabela de balanço. O catálogo compartilhado com JavaScript não contém esses inimigos: são registrados somente na camada nativa de campanha, fora da lista de heróis. O protótipo web continua inalterado.

## Próximas decisões

Medir dificuldade, variedade de estratégias e impacto dos três engastes antes de expandir o sistema. Os parâmetros ficam em `scripts/campaign.gd`; o [guia de balanceamento](BALANCING.md) explica a separação entre progressão e combate base. O [relatório de simulações](SIMULATIONS.md) usa heróis sem gemas, não mede a dificuldade deste capítulo. Treinamento de skills, gemas com efeitos especiais, novos capítulos e integração com A Lei do Trono continuam para as próximas etapas.
