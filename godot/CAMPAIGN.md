# A jornada do Farol — três capítulos

A Alpha 0.11 mantém **nove batalhas em três capítulos**, com introdução, tática, desfecho e recompensa por primeira vitória. O Farol perdeu suas cinco ressonâncias; o trio precisa libertar o guardião, recuperar as memórias levadas pela maré e interromper a extração da Última Fornalha.

## Como jogar

1. Abra **Modo História**. As três abas permitem consultar os capítulos; o botão **Continuar** aponta para a próxima missão disponível.
2. Use **Escolher trio** para montar a equipe. Em **Coleção → Engastes e gemas**, distribua suas cópias entre os heróis.
3. Escolha uma missão disponível e confirme **Iniciar missão**. O automático é opcional: ative **Automático · A** para delegar alvos e habilidades.
4. A vitória salva o avanço, concede a primeira recompensa e libera a próxima etapa. A derrota permite tentar novamente e preserva seus itens e progresso.

| Capítulo | Missões | Chefe |
| --- | --- | --- |
| I — O Farol Partido | Os portões quebrados; Ecos no pátio; O guardião do eclipse | Vesper preso à âncora |
| II — Marés da Memória | A escadaria das marés; O arquivo submerso; A guardiã da memória | Guardiã das marés |
| III — A Última Fornalha | A estrada das cinzas; O coração das máquinas; O último juramento | Arconte da fornalha |

Cada capítulo concede uma Brasa, uma Seiva e um Pulso. Repetir uma missão não duplica recompensas. Os inimigos de história ficam fora do elenco selecionável. As novas variantes aproveitam ilustrações de heróis existentes, com identidade e atributos isolados na campanha; os kits dos heróis selecionáveis permanecem iguais.

O trio padrão completou as nove missões com o motor real em testes, sem gemas obrigatórias. Isso demonstra um caminho acessível, não equilíbrio final para todas as composições. Não há custo de entrada nem consumo de energia fora do combate. Cada tentativa restaura os integrantes.

## Engastes

| Gema | Bônus na história | Estoque inicial |
| --- | --- | --- |
| Brasa lapidada | +4% ataque por cópia | 3 |
| Seiva cristalizada | +5% vida máxima e inicial por cópia | 3 |
| Pulso de éter | +8 energia inicial por cópia | 3 |

São **três espaços por herói**, com **gemas repetidas permitidas**. Cada espaço ocupado usa uma cópia do estoque compartilhado. Uma mesma cópia não pode ocupar dois espaços; para repetir uma gema no herói ou distribuí-la entre heróis, use cópias diferentes. Há nove cópias iniciais ao todo e mais três de cada tipo ao concluir as nove missões pela primeira vez. O herói pode estar fora do trio e continuar com as cópias equipadas: o painel identifica seus donos. Remover ou trocar devolve a cópia gratuitamente. Não há venda, custo, raridade, aumento de nível nem obtenção aleatória nesta versão.

| Três gemas iguais em um herói | Resultado |
| --- | --- |
| 3 Brasas | +12% do ataque base |
| 3 Seivas | +15% da vida base |
| 3 Pulsos | +24 energia inicial: começa com 64 em vez de 40 |

Você também pode misturar os três tipos. Percentuais do mesmo atributo são **somados sobre o valor base antes de arredondar uma vez**, ao criar a missão. Três Brasas não multiplicam o ataque por 1,04 três vezes. A Seiva também altera valores proporcionais à vida máxima, mantendo o limite normal de escudo em 25%. Nenhuma gema aumenta diretamente cura, duração de escudo ou energia por ação. Equipe e engastes só podem ser ajustados entre missões. Cada nova tentativa restaura todos os integrantes.

As composições seguem livres: tanque, suporte e dano não são obrigatórios. Frente e retaguarda são posições visuais; Provocação continua sendo a mecânica que restringe golpes individuais. As regras de sangramento, Fratura, escudo único e redução progressiva de cura permanecem.

## Progresso e compatibilidade

O caminho continua **`user://campaign-0.7.json`**, agora com **`schemaVersion: 3`**. Ele armazena etapas concluídas, trio e os três engastes de cada herói. O estoque é derivado das vitórias, evitando duplicação ao reabrir resultados ou repetir missões.

Os formatos 1 e 2 são reconhecidos automaticamente. O engaste único do formato 1 ocupa o primeiro espaço; os três espaços do formato 2 são mantidos. Trio e as três missões antigas concluídas são preservados. Quem terminou o primeiro capítulo já pode iniciar a missão 4.

**Antes da próxima gravação**, o arquivo original é copiado para `campaign-0.7.json.v1.bak` ou `.v2.bak`, conforme o formato. O progresso passa a usar o formato 3. Se já existir um backup diferente, um sufixo numérico preserva ambos. Dados de formatos anteriores são limitados às três missões que existiam, evitando transformar um valor inválido em vitórias nos novos capítulos.

A gravação usa arquivo temporário e substituição após escrita; falhas aparecem na interface. Um arquivo ilegível é preservado e recebe cópia `.invalid.bak` antes de uma nova gravação explícita por equipe, engaste ou vitória. Se não for possível preservar o original, ele não é substituído. Batalhas em andamento não são retomadas.

Os dados são locais. Reabrir este mesmo projeto preserva o progresso no diretório de usuário do Godot. Para localizar os arquivos no Windows, use **Executar → `%APPDATA%\Godot\app_userdata\NEXUS — Ecos do Crepúsculo`**. Não há sincronização com GitHub ou outro computador.

Combate livre, duelo local, treinos e laboratório usam atributos base e não recebem bônus das gemas. Campanha não registra partidas na tabela de balanço. O catálogo compartilhado com JavaScript não contém esses inimigos: são registrados somente na camada nativa de campanha, fora da lista de heróis. O protótipo web continua inalterado.

## Próximas decisões

Medir dificuldade, variedade de estratégias e impacto dos três engastes antes de expandir o sistema. Os parâmetros ficam em `scripts/campaign.gd`; o [guia de balanceamento](BALANCING.md) explica a separação entre progressão e combate base. O [relatório de simulações](SIMULATIONS.md) usa heróis sem gemas, não mede a dificuldade da campanha. Treinamento de skills, gemas com efeitos especiais, expansões futuras e integração com A Lei do Trono continuam para as próximas etapas.

## Oficina da Alpha 0.11

O painel de **Coleção → Engastes e gemas** mostra personagem, atributos e inventário lado a lado. Escolha um espaço, equipe uma cópia livre, remova por **×**, use **Desengastar tudo** ou transfira uma cópia do dono escolhido com **Trazer**. **Preencher vazios por função** prioriza ataque para dano, vida para tanques e energia para suportes, preservando cópias equipadas e usando alternativas livres quando necessário. As edições são gratuitas e atômicas, com restauração do inventário caso o salvamento falhe. [Guia visual](CLASSES.md).
