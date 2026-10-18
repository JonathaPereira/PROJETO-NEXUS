# O Farol Partido — capítulo I

Primeira campanha jogável da Alpha 0.7. Três batalhas independentes, com introdução e desfecho em texto. Não é uma campanha longa nem inclui treinamento de habilidades nesta etapa.

## Como jogar

1. No menu, abra **História** e use **Escolher trio**. O primeiro integrante fica na frente, com as mesmas regras de alvo livre do combate normal.
2. Abra **Engastes**, escolha o herói e clique em **Engastar**. O painel mostra os atributos resultantes e quem está usando cada cópia.
3. Volte às missões, escolha uma disponível e clique em **Iniciar missão** no campo de batalha.
4. Ao vencer, leia o desfecho e a recompensa. **Voltar às missões** abre o próximo confronto.
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
| Brasa lapidada | +4% ataque | 1 |
| Seiva cristalizada | +5% vida máxima e inicial | 1 |
| Pulso de éter | +8 energia inicial: começa com 48 | 1 |

Um espaço por herói, uma cópia por engaste. Uma gema não pode estar simultaneamente em dois heróis; cópias adicionais permitem isso. O estoque total é o inicial mais as primeiras vitórias. O herói pode estar fora do trio e continuar com a cópia equipada: o painel identifica seus donos. Remover ou trocar devolve a cópia gratuitamente. Não há venda, custo, raridade, aumento de nível nem obtenção aleatória nesta versão.

Os bônus são calculados uma vez ao criar cada missão, com arredondamento do motor. A Seiva também altera valores proporcionais à vida máxima, mantendo o limite normal de escudo em 25%. Nenhuma gema aumenta diretamente cura, duração de escudo ou energia por ação. Equipe e engastes só podem ser ajustados entre missões. Cada nova tentativa restaura todos os integrantes.

As composições seguem livres: tanque, suporte e dano não são obrigatórios. Frente e retaguarda são posições visuais; Provocação continua sendo a mecânica que restringe golpes individuais. As regras de sangramento, Fratura, escudo único e redução progressiva de cura permanecem.

## Progresso e compatibilidade

`user://campaign-0.7.json` armazena versão do formato, número de etapas concluídas, trio e engastes. O estoque é derivado das vitórias, evitando duplicação ao reabrir resultados ou repetir missões. A gravação usa arquivo temporário e substituição após escrita; falhas aparecem na interface. Um arquivo ilegível é preservado até uma nova gravação explícita por equipe, engaste ou vitória. Batalhas em andamento não são retomadas.

Os dados são locais. Reabrir este mesmo projeto preserva o progresso no diretório de usuário do Godot. Para localizar os arquivos no Windows, use **Executar → `%APPDATA%\Godot\app_userdata\NEXUS — Ecos do Crepúsculo`**. Não há sincronização com GitHub ou outro computador.

Combate livre, duelo local, treinos e laboratório usam atributos base e não recebem bônus das gemas. Campanha não registra partidas na tabela de balanço. O catálogo compartilhado com JavaScript não contém esses inimigos: são registrados somente na camada nativa de campanha, fora da lista de heróis. O protótipo web continua inalterado.

## Próximas decisões

Medir dificuldade, variedade de estratégias e impacto dos três bônus antes de expandir o sistema. Treinamento de skills, gemas com efeitos especiais, novos capítulos e integração com A Lei do Trono continuam para as próximas etapas.
