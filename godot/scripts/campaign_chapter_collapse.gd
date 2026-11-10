extends RefCounted
## O Colapso. The old finale opens a new route without changing historical rewards.

const CHAPTER := {
	"id":"collapse", "finalMission":"collapse-anchor", "name":"O Colapso",
	"eyebrow":"CAPÍTULO IV", "theme":"sanctum", "color":"d5b4ff",
	"summary":"O Farol voltou a funcionar, mas uma passagem esquecida responde ao seu pulso. Siga os avisos de Zaya até a dobra onde o sinal ganha força.",
	"lesson":"Alterne pressão sobre o alvo, defesa do trio e controle de energia. O supremo guardado para a próxima onda pode decidir o confronto.",
}

const ENEMIES := [
	{"id":"minion-prism","source":"solen","name":"Batedor prismático","hp":810,"attack":175,"defense":62,"role":"Minion"},
	{"id":"minion-fissure","source":"ivo","name":"Cartógrafo da fenda","hp":800,"attack":162,"defense":58,"role":"Minion"},
	{"id":"minion-afterglow","source":"elyra","name":"Reflexo da aurora","hp":740,"attack":138,"defense":61,"role":"Minion"},
	{"id":"boss-lens","source":"zaya","name":"Operadora da lente","hp":1120,"attack":159,"defense":75,"role":"Chefe"},
	{"id":"boss-collapse","source":"auren","name":"Custódio da dobra","hp":1850,"attack":216,"defense":112,"role":"Chefe"},
]

const MISSIONS := [
	{
		"id":"collapse-warning", "seed":1091, "chapter":"collapse", "requires":["forge-heart"],
		"name":"10 · A carta de amanhã", "location":"POENTE · POSTO DE SINAIS",
		"story":"Zaya traz uma carta com o selo do posto recém-reaberto. «Foi escrita amanhã», diz ela. Antes que Vektor alcance o transmissor, reflexos armados começam a atacar seus próprios remetentes.",
		"enemies":["minion-prism","minion-fissure","minion-afterglow"], "scale":1.04, "reward":"ember",
		"tip":"O Reflexo protege aliados feridos. Pressione a cura primeiro ou use ataques em área para quebrar várias barreiras.",
		"ending":"A carta traz o horário em que a passagem vai fechar. Zaya reconhece a própria letra, mas escolhe mudar o destino da mensagem.",
	},
	{
		"id":"collapse-lens", "seed":1129, "chapter":"collapse", "requires":["collapse-warning"],
		"name":"11 · A lente invertida", "location":"POENTE · TORRE DE ESPELHOS",
		"story":"Cindra ouve duas transmissões saírem da mesma lente. «Uma pede evacuação. A outra chama reforços.» Corte a segunda enquanto a rota de saída ainda está livre.",
		"enemies":["minion-sentinel","boss-lens","minion-prism"], "scale":1.03, "reward":"sap",
		"objective":{"type":"target","target":"1-boss-lens","targetName":"a Operadora da lente","rounds":6},
		"tip":"A Operadora acelera os outros rivais. Derrote-a até a rodada 6; as sentinelas não precisam cair.",
		"ending":"Sem o sinal duplicado, os moradores seguem a rota de Cindra. Pelo vidro, a equipe vê o bairro inteiro repetir o mesmo minuto.",
	},
	{
		"id":"collapse-shelter", "seed":1163, "chapter":"collapse", "requires":["collapse-lens"],
		"name":"12 · Até o último abrigo", "location":"POENTE · GALERIA DE EVACUAÇÃO",
		"story":"Elyra mantém três arcos de luz abertos para os moradores atravessarem. «Segurem seus postos até eu contar o último grupo.» Nenhum arco pode apagar durante a passagem.",
		"enemies":["minion-fissure","minion-prism","minion-cinder"], "scale":0.99, "reward":"pulse",
		"objective":{"type":"survive","rounds":4,"protectAll":true},
		"tip":"Mantenha os três de pé por quatro rodadas. Purificar aflições impede que o Cartógrafo as espalhe pelo trio.",
		"ending":"O último grupo atravessa. Uma menina leva duas versões da mesma chave. Elyra deixa as duas com ela: o abrigo existe em ambos os lados.",
	},
	{
		"id":"collapse-crossing", "seed":1201, "chapter":"collapse", "requires":["collapse-shelter"],
		"name":"13 · A ponte que se dobra", "location":"FRONTEIRA · PASSAGEM DE IVO",
		"story":"Ivo finca a bússola no parapeito. «A ponte volta para o ponto de partida sempre que o chão vibra.» Mantenha a bússola com o portador para fixar um destino.",
		"enemies":["minion-fissure","minion-root","minion-acolyte"], "scale":1.04, "reward":"ember",
		"objective":{"type":"clear","protectSlot":0},
		"field":{"id":"energy-ebb","name":"Vazante prismática","basicEnergyGain":-4,"skillCostDelta":-5},
		"tip":"Escolha quem leva a bússola no primeiro espaço. A técnica mais barata pode salvar o portador sem esperar um supremo.",
		"ending":"A ponte se fixa do outro lado. Ivo deixa uma marca em cada extremidade. Pela primeira vez, as duas aparecem no mesmo mapa.",
	},
	{
		"id":"collapse-echoes", "seed":1237, "chapter":"collapse", "requires":["collapse-crossing"],
		"name":"14 · Ecos do outro lado", "location":"FRONTEIRA · ARCO DE RETORNO",
		"story":"Solen estende a mão para o arco e vê sua sombra continuar andando. «Eles repetem a travessia. Precisamos segurar a passagem até o eco perder força.»",
		"enemies":["minion-prism","minion-tide","minion-fissure"], "scale":1.06, "reward":"sap",
		"waves":[{"name":"Exploradores da dobra","healthScale":0.65,"attackScale":0.9},{"name":"Ecos da travessia","healthScale":0.80,"attackScale":1.0}],
		"tip":"Poupe cura e energia na primeira onda. Na segunda, o Vigia pode proteger um rival antes que você o finalize.",
		"ending":"As sombras finalmente acompanham quem as projeta. No chão fica um sulco de seis marcas; cinco delas coincidem com as do Farol.",
	},
	{
		"id":"collapse-chamber", "seed":1279, "chapter":"collapse", "requires":["collapse-echoes"],
		"name":"15 · A câmara sem ruído", "location":"DOBRA · CÂMARA DE AMORTECIMENTO",
		"story":"Astra tenta reproduzir o padrão gravado no chão. O vazio entre as marcas engole parte do pulso. «A sexta não está faltando. Alguém desligou sua resposta.»",
		"enemies":["minion-fissure","minion-afterglow","minion-sentinel"], "scale":1.12, "reward":"pulse",
		"field":{"id":"silent-band","name":"Faixa muda","basicEnergyGain":-6,"skillCostDelta":4},
		"tip":"Técnicas custam mais e básicos geram menos energia para ambos os lados. Elimine a sustentação rival antes que as barreiras se acumulem.",
		"ending":"Astra isola a frequência apagada. Do outro lado da câmara, alguém responde com a ordem que manteve Vesper preso à âncora.",
	},
	{
		"id":"collapse-counterseal", "seed":1319, "chapter":"collapse", "requires":["collapse-chamber"],
		"name":"16 · Antes que o selo feche", "location":"DOBRA · PÁTIO DO CONTRASSELO",
		"story":"Noct identifica a marca da antiga prisão na lente de reserva. «O Custódio está fechando o poente por dentro.» Interrompa a Operadora antes de a lente gravar a ordem.",
		"enemies":["minion-fissure","boss-lens","minion-afterglow"], "scale":1.09, "reward":"ember",
		"objective":{"type":"target","target":"1-boss-lens","targetName":"a Operadora da lente","rounds":5},
		"tip":"A cura do Reflexo pode custar uma rodada. Combine dano concentrado e golpes em área para abrir espaço antes do prazo.",
		"ending":"Noct corta a marca da lente. O selo abre uma passagem curta até o Custódio, mas a última ordem já alcançou o núcleo.",
	},
	{
		"id":"collapse-anchor", "dialogue":[["ivo","A dobra tem dois apoios. O Custódio ainda está segurando o que resta."],["elyra","Deixe um sinal para quem vem atrás. Quando o apoio cair, seguimos juntos."]], "seed":1361, "chapter":"collapse", "requires":["collapse-counterseal"],
		"name":"17 · A dobradiça do horizonte", "location":"DOBRA · NÚCLEO PRISMÁTICO · CHEFE",
		"story":"O Custódio guardou a dobra desde o primeiro silêncio. «Se a abrir, seis testemunhas vão contestar a história do Farol.» Auren pede que ele deixe essas vozes falar. O Custódio ergue a última barreira.",
		"enemies":["boss-collapse","minion-prism","minion-fissure"], "scale":1.07, "reward":"pulse",
		"bossPhase":{"target":"1-boss-collapse","name":"Refração aberta","healthRatio":0.6,"skillName":"Estilhaço prismático","skillPower":0.83},
		"tip":"Quando o Custódio trocar a técnica, antecipe cura ou proteção coletiva. A pressão de área começa assim que ele puder agir e pagar o custo.",
		"ending":"A dobra deixa de copiar a cidade. Do outro lado chegam seis gravações que discordam sobre a queda do Farol. Fim do capítulo IV. Zaya separa a primeira carta: a testemunha está esperando nas Rotas do Poente.",
	},
]
