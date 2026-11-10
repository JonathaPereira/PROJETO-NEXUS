extends RefCounted

const CHAPTER := {
	"id":"nexus", "finalMission":"nexus-heart", "name":"Nexus",
	"eyebrow":"CAPÍTULO VI", "theme":"sanctum", "color":"e5cfff",
	"summary":"Abra um corredor para a cidade descartada e interrompa o mecanismo que mantém uma realidade às custas da outra.",
	"lesson":"Poupe energia e cura para reforços e use a composição do encontro para decidir se defende, escolta ou pressiona.",
}

const ENEMIES := [
	{"id":"minion-chorus","source":"zaya","name":"Coro da cidade vazia","hp":775,"attack":146,"defense":63,"role":"Minion"},
	{"id":"minion-inverter","source":"axion","name":"Inversor de fronteira","hp":865,"attack":157,"defense":90,"role":"Minion"},
	{"id":"minion-remnant","source":"riven","name":"Remanescente do fecho","hp":810,"attack":173,"defense":68,"role":"Minion"},
	{"id":"boss-regulator","source":"kira","name":"Reguladora da saída","hp":1240,"attack":171,"defense":81,"role":"Chefe"},
	{"id":"boss-nexus","source":"astra","name":"Primeira Arquiteta","hp":2050,"attack":207,"defense":109,"role":"Chefe"},
]

const MISSIONS := [
	{
		"id":"nexus-border","seed":1709,"chapter":"nexus","requires":["truths-archive"],
		"name":"26 · O lado que ficou","location":"NEXUS · PORTA DA CIDADE VAZIA",
		"story":"A porta abre sobre a cidade vista nos anéis da árvore. Ela ainda tem gente. Oren estende a mão para o primeiro morador. «A gente pode atravessar nos dois sentidos?» O Inversor ergue sua defesa.",
		"enemies":["minion-inverter","minion-chorus","minion-remnant"],"scale":1.13,"reward":"ember",
		"tip":"O Inversor protege seus aliados e enfraquece quem os atinge diretamente. Abra espaço eliminando o Coro, que cura e acelera o grupo.",
		"ending":"A porta fica aberta tempo suficiente para uma travessia. O protocolo registra o primeiro morador que voltou em vez de marcar a rota como perdida.",
	},
	{
		"id":"nexus-evacuation","seed":1747,"chapter":"nexus","requires":["nexus-border"],
		"name":"27 · A passagem dos nomes","location":"NEXUS · CORREDOR DE EVACUAÇÃO",
		"story":"Saira lê os nomes para que a passagem reconheça cada pessoa. Maura sinaliza o corredor: «A gente segura as duas pontas. Só precisamos terminar a chamada.»",
		"enemies":["minion-remnant","minion-prism","minion-redactor"],"scale":1.04,"reward":"sap",
		"objective":{"type":"survive","rounds":4,"protectAll":true},
		"tip":"Proteja os três leitores até o fim da rodada 4. Purificação ajuda contra as marcas que atravessam barreiras.",
		"ending":"A lista termina com a irmã de Veyra. Ela reconhece a chama das lâminas antes de reconhecer o próprio endereço.",
	},
	{
		"id":"nexus-outlet","seed":1787,"chapter":"nexus","requires":["nexus-evacuation"],
		"name":"28 · A janela de saída","location":"NEXUS · REGISTRO DOS FLUXOS",
		"story":"Cindra calcula o intervalo em que o fecho pode ser desligado. A Reguladora desmonta o painel a cada rodada. «Temos até ela arrancar o último fio.»",
		"enemies":["minion-inverter","boss-regulator","minion-prism"],"scale":1.07,"reward":"pulse",
		"objective":{"type":"target","target":"1-boss-regulator","targetName":"a Reguladora da saída","rounds":7},
		"tip":"A Reguladora perfura escudos. A contagem para com sua queda, mesmo com o Inversor ainda em campo.",
		"ending":"A saída fica aberta por um minuto. A cidade evacuada usa o primeiro meio minuto para trazer seus mapas e o segundo para voltar pelos atrasados.",
	},
	{
		"id":"nexus-carrier","seed":1823,"chapter":"nexus","requires":["nexus-outlet"],
		"name":"29 · Os dois mapas","location":"NEXUS · INTERVALO ENTRE CIDADES",
		"story":"Ivo entrega os dois mapas à retaguarda. «As ruas têm nomes iguais. As pessoas que moram nelas, não.» O portador tem de chegar ao marco sem que uma das versões desapareça.",
		"enemies":["minion-fissure","minion-remnant","minion-notary"],"scale":1.08,"reward":"ember",
		"objective":{"type":"clear","protectSlot":2},
		"field":{"id":"paired-cities","name":"Circuito em pares","basicEnergyGain":5,"skillCostDelta":-3},
		"tip":"O terceiro integrante leva os mapas. Ganho maior de energia e técnica mais barata aumentam o ritmo também do lado rival.",
		"ending":"O primeiro endereço aparece com dois destinos válidos. A ponte aceita o mapa sem tentar corrigir um dos lados.",
	},
	{
		"id":"nexus-seal","seed":1861,"chapter":"nexus","requires":["nexus-carrier"],
		"name":"30 · Os três comandos","location":"NEXUS · MURALHA DE CONTENÇÃO",
		"story":"Bast descobre três comandos de fechamento rodando em série. «Podemos cortar cada um. Se tentarmos os três juntos, a muralha fecha com gente dentro.»",
		"enemies":["minion-inverter","minion-cinder","minion-chorus"],"scale":1.00,"reward":"sap",
		"waves":[{"name":"Primeiro comando","healthScale":0.51,"attackScale":0.85},{"name":"Defesa da muralha","healthScale":0.62,"attackScale":0.92},{"name":"Comando de retorno","healthScale":0.73,"attackScale":1.0}],
		"tip":"São três ondas. No último grupo, o Inversor e o Coro combinam contenção, cura e reposição de energia.",
		"ending":"A muralha para de receber ordens. A luz do outro lado deixa de pulsar junto da contagem de evacuação.",
	},
	{
		"id":"nexus-choice","seed":1901,"chapter":"nexus","requires":["nexus-seal"],
		"name":"31 · Um porto para cada lado","location":"NEXUS · DOCA DOS CONTORNOS",
		"story":"Elyra prepara abrigo para quem decidir esperar. «Uma saída só é uma saída se a gente puder voltar.» A antiga escolta do fecho tenta cortar o último vínculo entre as docas.",
		"enemies":["minion-rootward","minion-redactor","minion-remnant"],"scale":1.15,"reward":"pulse",
		"field":{"id":"split-tide","name":"Maré dividida","basicEnergyGain":-6,"skillCostDelta":-4},
		"tip":"Técnicas ficam mais acessíveis, mas supremos demoram a carregar pelos básicos. Conserve purificação para lidar com as marcas.",
		"ending":"As docas passam a se reconhecer sem cobrar uma cidade em troca da outra. Os moradores escolhem se atravessam agora ou na próxima maré.",
	},
	{
		"id":"nexus-interlock","seed":1933,"chapter":"nexus","requires":["nexus-choice"],
		"name":"32 · O último intertravamento","location":"NEXUS · SALA DOS TRÊS SELOS",
		"story":"A Reguladora ainda pode desligar as portas. Vesper destrava a âncora da sala. «Ela vai perder a autorização quando perder a posição. Mantenham as portas abertas até lá.»",
		"enemies":["minion-redactor","boss-regulator","minion-afterglow"],"scale":1.13,"reward":"ember",
		"objective":{"type":"target","target":"1-boss-regulator","targetName":"a Reguladora da saída","rounds":7},
		"tip":"O Reflexo cura a Reguladora. Fique atento à vida dela depois de cada rodada e combine ataques para encerrar o objetivo de uma vez.",
		"ending":"A autorização de fechamento cai. Resta quem a usou para manter de pé a cidade vazia durante tantos anos.",
	},
	{
		"id":"nexus-heart", "dialogue":[["astra","O fecho responde a dois lados. Se só um deles falar, volta tudo ao princípio."],["saira","Então guardem o outro lado também. É para lá que o caminho precisa voltar."]],"seed":1987,"chapter":"nexus","requires":["nexus-interlock"],
		"name":"33 · O sexto caminho","location":"NEXUS · CORAÇÃO DOS DOIS FARÓIS · CHEFE",
		"story":"A Primeira Arquiteta sustentou a cidade descartada com a energia roubada da outra. «Foi a única saída que encontrei.» Astra aponta os dois mapas sobre a mesa. «Agora temos mais de uma.»",
		"enemies":["boss-nexus","minion-inverter","minion-chorus"],"scale":1.10,"reward":"pulse",
		"field":{"id":"common-light","name":"Luz comum","basicEnergyGain":5,"skillCostDelta":4},
		"bossPhase":{"target":"1-boss-nexus","name":"Portas abertas","healthRatio":0.60,"skillName":"Colapso das margens","skillPower":0.92,"skillPierce":0.35},
		"tip":"Retire a sustentação do Coro. Na segunda fase, 35% do dano de Colapso das Margens atravessa escudos. Defesa reduz o golpe inteiro; combine-a com cura e barreiras para sustentar o trio.",
		"ending":"A Arquiteta desliga a ordem que apagava endereços. As seis ressonâncias passam a sustentar duas cidades em acordo. Zaya recebe sua carta de amanhã e, desta vez, sabe para onde voltar. Fim da campanha.",
	},
]
