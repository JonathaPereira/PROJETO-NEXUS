extends RefCounted

const CHAPTER := {
	"id":"truths", "finalMission":"truths-archive", "name":"As Seis Verdades",
	"eyebrow":"CAPÍTULO V", "theme":"tides", "color":"bce9b1",
	"summary":"As gravações da dobra contam histórias incompatíveis. Reúna as seis testemunhas e descubra quem tinha acesso à ordem de contenção.",
	"lesson":"Procure a abertura de cada formação e proteja as testemunhas enquanto os registros são transmitidos.",
}

const ENEMIES := [
	{"id":"minion-redactor","source":"noct","name":"Rasurador do Véu","hp":780,"attack":170,"defense":68,"role":"Minion"},
	{"id":"minion-notary","source":"vektor","name":"Notário do protocolo","hp":810,"attack":144,"defense":76,"role":"Minion"},
	{"id":"minion-rootward","source":"brin","name":"Vigia de enxertia","hp":740,"attack":142,"defense":64,"role":"Minion"},
	{"id":"minion-furnace","source":"torv","name":"Fiscal térmico","hp":845,"attack":176,"defense":72,"role":"Minion"},
	{"id":"boss-archivist","source":"elun","name":"Arquivista do silêncio","hp":1780,"attack":205,"defense":104,"role":"Chefe"},
]

const MISSIONS := [
	{
		"id":"truths-courier","seed":1423,"chapter":"truths","requires":["collapse-anchor"],
		"name":"18 · A mensageira sem data","location":"POENTE · ESTAÇÃO DOS ESTAFETAS",
		"story":"A primeira testemunha é uma estafeta que Zaya ainda não conheceu. «Levei o aviso ontem. Seu selo já estava lá quando cheguei.» O Rasurador tenta arrancar a carta de suas mãos.",
		"enemies":["minion-redactor","minion-notary","minion-prism"],"scale":1.09,"reward":"pulse",
		"objective":{"type":"clear","protectSlot":1},
		"tip":"O segundo integrante leva o depoimento. Limpe a Marca obscura para reduzir a pressão do Rasurador sobre ele.",
		"ending":"A estafeta lê a carta em voz alta. A ordem para selar o Farol chegou antes do alarme, com autorização de uma sessão que ainda não havia ocorrido.",
	},
	{
		"id":"truths-roots","seed":1451,"chapter":"truths","requires":["truths-courier"],
		"name":"19 · O anel da árvore","location":"BOSQUES DE VIDRO · VIVEIRO DE REGISTROS",
		"story":"Sylva toca um tronco ferido. A testemunha guardou a data da enxertia nos anéis da árvore. «A seiva só começou a guardar nomes depois que abriram o desvio.»",
		"enemies":["minion-rootward","minion-root","minion-fissure"],"scale":1.09,"reward":"sap",
		"objective":{"type":"survive","rounds":4,"protectAll":true},
		"tip":"Os três precisam sustentar a leitura. Remova Sangramento antes que a cura se torne insuficiente.",
		"ending":"Os anéis marcam duas primaveras sobrepostas. A ordem de contenção ligou o Farol a uma cidade onde o inverno nunca terminou.",
	},
	{
		"id":"truths-heat","seed":1493,"chapter":"truths","requires":["truths-roots"],
		"name":"20 · A válvula testemunha","location":"FORNALHAS DE BAIXO · LINHA DE EMERGÊNCIA",
		"story":"Rhazen encontra a operária que abriu as saídas durante o acidente. «Sua válvula funcionou. O protocolo mandou fechar a porta que você tinha acabado de abrir.» O Fiscal já apaga o livro de turnos.",
		"enemies":["minion-furnace","minion-cinder","minion-sentinel"],"scale":1.10,"reward":"ember",
		"objective":{"type":"target","target":"1-minion-furnace","targetName":"o Fiscal térmico","rounds":5},
		"field":{"id":"hot-circuit","name":"Circuito aquecido","basicEnergyGain":6,"skillCostDelta":3},
		"tip":"Concentre ataques no Fiscal. O ganho dos básicos ajuda a antecipar supremos para ambos os lados.",
		"ending":"O livro registra uma sexta saída de emergência que nunca constou na planta. A operária ouviu alguém agradecer do outro lado.",
	},
	{
		"id":"truths-matter","seed":1523,"chapter":"truths","requires":["truths-heat"],
		"name":"21 · O peso da assinatura","location":"TRONO · CÂMARA DOS CONTRAPESOS",
		"story":"Bast reconhece o torque das engrenagens. Vektor confronta a testemunha técnica: «É a sua assinatura.» Ela destrava o contrapeso. «Reconstruída a partir de um turno em que eu nem estava acordada.»",
		"enemies":["minion-notary","minion-sentinel","minion-prism"],"scale":1.14,"reward":"ember",
		"waves":[{"name":"Controle de acesso","healthScale":0.58,"attackScale":0.91},{"name":"Certificação","healthScale":0.78,"attackScale":1.0}],
		"tip":"O Notário devolve energia aos guardas. Impeça a primeira defesa de virar um cerco e conserve um supremo para a certificação.",
		"ending":"A prova é uma peça de ferro, pesada demais para ter sido movida pelo assinante. A máquina validou a existência da assinatura e ignorou de quem era a mão.",
	},
	{
		"id":"truths-memory","seed":1567,"chapter":"truths","requires":["truths-matter"],
		"name":"22 · Uma lembrança emprestada","location":"OBSERVATÓRIO · SALA DAS JANELAS DUPLAS",
		"story":"Saira escuta duas infâncias na mesma voz. «Eu me lembro da sua cidade. Também lembro de vê-la sumir», diz a testemunha. Os ecos querem empurrar a lembrança de volta para o canal.",
		"enemies":["minion-afterglow","minion-siren","minion-tide"],"scale":1.02,"reward":"sap",
		"field":{"id":"soft-memory","name":"Maré suspensa","basicEnergyGain":-4,"skillCostDelta":-8},
		"tip":"Duas curas rivais mantêm o Vigia de pé. A técnica mais barata ajuda a forçar uma abertura antes que o escudo volte.",
		"ending":"A testemunha escolhe qual lembrança gravar com seu nome e entrega a outra à pessoa que a viveu. Saira preserva a distinção no registro.",
	},
	{
		"id":"truths-shadow","seed":1597,"chapter":"truths","requires":["truths-memory"],
		"name":"23 · O testemunho da sombra","location":"VIGÍLIA · SALA DO JURAMENTO",
		"story":"Vesper ouve um relato que começa com a própria voz. «A ordem era manter a passagem aberta», corrige a testemunha. A vigília recebeu a cópia invertida e puniu seu guardião.",
		"enemies":["minion-redactor","minion-acolyte","minion-fissure"],"scale":1.13,"reward":"pulse",
		"objective":{"type":"target","target":"1-minion-redactor","targetName":"o Rasurador do Véu","rounds":6},
		"tip":"O Rasurador se sustenta com dano e marca. Ataques de área atingem os acompanhantes, mas a contagem só para quando ele cai.",
		"ending":"Vesper retira sua assinatura da ordem de fechamento. A sombra termina o relato com a última frase omitida: o sexto povo manteve a passagem para receber os evacuados.",
	},
	{
		"id":"truths-hearing","seed":1627,"chapter":"truths","requires":["truths-shadow","beacon-returns-proof","tides-returns-proof","forge-returns-proof"],
		"name":"24 · A ata aberta","location":"TRONO · PÁTIO DA AUDIÊNCIA",
		"story":"Astra põe os seis depoimentos e os três anexos na mesma mesa. «Se alguém assinar sozinho, tudo se repete.» Cindra abre três canais de cópia e os defende enquanto a audiência escuta.",
		"enemies":["minion-notary","minion-prism","minion-redactor"],"scale":1.10,"reward":"sap",
		"objective":{"type":"survive","rounds":4,"protectAll":true},
		"field":{"id":"open-record","name":"Ata em transmissão","basicEnergyGain":3,"skillCostDelta":7},
		"tip":"Todos os integrantes sustentam os canais. Básicos recuperam mais energia, mas o custo maior da técnica pode atrasar uma cura.",
		"ending":"O conselho aceita a ata. O protocolo tenta arquivar a cidade inteira como testemunho e convoca o último guardião dos registros.",
	},
	{
		"id":"truths-archive", "dialogue":[["elyra","As seis vozes estão na ata. O arquivo não precisa escolher qual delas fica."],["veyra","Desta vez a ata sai daqui em mãos abertas."]],"seed":1669,"chapter":"truths","requires":["truths-hearing"],
		"name":"25 · O arquivo que não fecha","location":"TRONO · COFRE DE ASSINATURAS · CHEFE",
		"story":"O Arquivista procura uma versão única do desastre. Elun encontra a ordem de fechamento em seus escudos: «Ele está protegendo o registro que mandaram queimar.» A equipe precisa manter abertas todas as versões.",
		"enemies":["boss-archivist","minion-notary","minion-afterglow"],"scale":1.06,"reward":"pulse",
		"bossPhase":{"target":"1-boss-archivist","name":"Registro aberto","healthRatio":0.55,"skillName":"Rebote da ata","skillPower":0.82,"skillEffect":"expose"},
		"tip":"Rebote da Ata reduz a defesa de todo o trio por dois turnos. Purifique os aliados expostos antes dos ataques seguintes. O Notário dá energia ao Arquivista; retirar seu apoio abre espaço para recuperar o grupo.",
		"ending":"O cofre devolve as assinaturas e a ordem original. Fim do capítulo V. A ordem veio do Nexus, onde a versão descartada da cidade tenta sobreviver fechando todas as outras.",
	},
]
