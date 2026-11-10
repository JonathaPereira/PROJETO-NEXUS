extends RefCounted
## Personal accounts take place in the existing world and use the campaign ledger.
const PACTS = {
	"Dano":{"attack":0.01,"description":"+1% ATQ base na campanha"},
	"Tanque":{"health":0.015,"description":"+1,5% VIDA base na campanha"},
	"Suporte":{"energy":2,"description":"+2 EN inicial na campanha"},
}

const RECORDS := {
	"veyra":{"name":"A janela da irmã","chapter":"forge","location":"FORNALHAS DE BAIXO","enemies":["minion-cinder","minion-redactor","minion-notary"],
		"story":"Veyra encontra uma janela que ainda guarda a primeira manhã sem sua irmã. Um Rasurador busca apagar a chama usada como sinal.",
		"ending":"Ela deixa a chama acesa para quem reconhecer o caminho de volta.","target":"o Rasurador do Véu","targetSlot":1},
	"rhazen":{"name":"A porta de emergência","chapter":"forge","location":"OFICINA SUBTERRÂNEA","enemies":["minion-sentinel","minion-furnace","minion-cinder"],
		"story":"A antiga porta da oficina abre só enquanto Rhazen alimenta suas dobradiças. Os três precisam sustentar o corredor.",
		"ending":"Ele instala um mecanismo que permite abrir por dentro, mesmo sem um coração de fornalha.","survive":3},
	"cindra":{"name":"Um sinal verdadeiro","chapter":"forge","location":"TORRE DO HORIZONTE","enemies":["minion-prism","minion-notary","minion-fissure"],
		"story":"Cindra volta à torre acusada de mentir. Ela carrega o transmissor que vai devolver à cidade o aviso interrompido.",
		"ending":"O aviso chega com seu nome e a hora correta. O bairro responde com as luzes de suas janelas.","escort":true},
	"torv":{"name":"Onde a rocha respira","chapter":"forge","location":"ESCARPAS DA FORNALHA","enemies":["minion-furnace","minion-root","minion-cinder"],
		"story":"Torv escuta a montanha sob as máquinas. Primeiro precisa silenciar os coletores. Depois poderá ouvir de onde vem a próxima fissura.",
		"ending":"O sopro que atravessa a rocha volta a aquecer as casas da encosta.","waves":["Coletores das escarpas","Guarda da perfuração"]},
	"sylva":{"name":"A semente que escuta","chapter":"beacon","location":"BOSQUES DE VIDRO","enemies":["minion-root","minion-acolyte","minion-rootward"],
		"story":"Sylva planta uma semente nos jardins que passaram a crescer contra a luz. O trio sustenta o solo até que as raízes aprendam um novo caminho.",
		"ending":"O broto não guarda nomes roubados. Guarda a voz de quem decidiu ficar no jardim.","survive":4},
	"oren":{"name":"Quem ficou na margem","chapter":"tides","location":"ANEL DAS RAÍZES","enemies":["minion-tide","minion-siren","minion-root"],
		"story":"Oren volta pelo túnel que fechou durante a evacuação. Ele leva a corda que ainda está amarrada do lado de lá.",
		"ending":"A corda recebe novos nós, um para cada sobrevivente que voltou a atravessar.","escort":true},
	"nima":{"name":"A pegada que faltava","chapter":"beacon","location":"MARGENS DO ANEL","enemies":["minion-fissure","minion-root","minion-redactor"],
		"story":"Nima identifica uma trilha deixada por uma máquina que caminhava para trás. O Cartógrafo tenta trocar sua origem por outra.",
		"ending":"A trilha termina onde o primeiro fragmento foi retirado, junto a uma rota que os vigias ainda desconhecem.","target":"o Cartógrafo da fenda","targetSlot":0},
	"brin":{"name":"A memória que criou raízes","chapter":"beacon","location":"SANTUÁRIO DA SEIVA","enemies":["minion-rootward","minion-root","minion-afterglow"],
		"story":"Brin precisa separar da árvore a lembrança que ela tomou por doença. A seiva recupera energia cedo, mas dificulta o controle de seu fluxo.",
		"ending":"A lembrança volta ao dono. Brin deixa a árvore lembrar apenas do que ela mesma viu.","field":[4,5,"Seiva inquieta"]},
	"axion":{"name":"A margem do protocolo","chapter":"beacon","location":"DISTRITO TÉCNICO","enemies":["minion-inverter","minion-sentinel","minion-prism"],
		"story":"Axion encontra um registro que classificava moradores sem marca como obstáculos. Ele apaga a ordem diante dos guardas que a executavam.",
		"ending":"O novo protocolo pede primeiro um nome. Uma criança testa a entrada dizendo o próprio em voz alta."},
	"kira":{"name":"O alvo que não consta","chapter":"forge","location":"PASSARELA DOS VIGIAS","enemies":["minion-sentinel","boss-regulator","minion-furnace"],
		"story":"Kira segue uma ordem de captura assinada com o nome de alguém que nunca existiu. A Reguladora tenta abrir uma segunda ordem.",
		"ending":"A ordem falsa cai. Kira risca seu número de identificação, mas conserva o nome que escolheu.","target":"a Reguladora da saída","targetSlot":1},
	"bast":{"name":"A sentinela e a escolha","chapter":"forge","location":"ANEL DE CONTENÇÃO","enemies":["minion-inverter","minion-furnace","minion-cinder"],
		"story":"Bast volta à plataforma onde ficou imóvel. Ele decide defender a passagem sem esperar que a Fornalha autorize.",
		"ending":"Os trabalhadores atravessam. Bast usa a antiga placa de comando para marcar o ponto de encontro.","survive":3},
	"vektor":{"name":"Onze segundos inteiros","chapter":"beacon","location":"POSTO DE GRAVAÇÃO","enemies":["minion-notary","minion-fissure","minion-prism"],
		"story":"Vektor volta à transmissão truncada. Os vigias disparam novas cópias enquanto ele tenta reconstruir cada segundo na ordem certa.",
		"ending":"A gravação recuperada termina com o silêncio real, sem uma ordem adicionada por cima.","waves":["Cópia automática","Última transmissão"]},
	"astra":{"name":"A estrela fora do mapa","chapter":"tides","location":"CÂMARA DAS EFEMÉRIDES","enemies":["minion-fissure","minion-redactor","minion-afterglow"],
		"story":"Astra mede uma estrela que só aparece no mapa da outra cidade. A faixa fria consome parte da energia dos básicos.",
		"ending":"Ela desenha as duas posições no mesmo mapa e deixa espaço para uma terceira observação.","field":[-5,-4,"Faixa das efemérides"]},
	"elun":{"name":"A ata que ainda escuta","chapter":"tides","location":"ARQUIVO SUBMERSO","enemies":["minion-siren","minion-acolyte","minion-notary"],
		"story":"Elun volta à ata incompleta. Ele precisa levar a placa ao leitor enquanto os ecos tentam devolver o texto à versão antiga.",
		"ending":"A ata aceita uma correção sem apagar o primeiro registro.","escort":true},
	"saira":{"name":"A voz que veio de volta","chapter":"tides","location":"CANAL DOS NOMES","enemies":["minion-afterglow","minion-redactor","minion-siren"],
		"story":"Saira ouve sua própria voz chamando alguém que não conhece. O trio sustenta o canal até que a pessoa consiga responder.",
		"ending":"O nome é registrado com a voz de quem o escolheu, em vez do eco que o imitava.","survive":3},
	"ivo":{"name":"A porta sem destino","chapter":"beacon","location":"PASSAGENS DIMENSIONAIS","enemies":["minion-fissure","minion-prism","minion-inverter"],
		"story":"Ivo volta ao corredor onde todas as portas desembocavam. O Cartógrafo redesenha o mesmo atalho cada vez que alguém atravessa.",
		"ending":"A primeira porta volta a abrir do outro lado do corredor. Ivo deixa a segunda para quem precisar voltar.","target":"o Cartógrafo da fenda","targetSlot":0},
	"vesper":{"name":"A vigília sem ordem","chapter":"beacon","location":"NÚCLEO DO FAROL","enemies":["minion-redactor","minion-sentinel","minion-acolyte"],
		"story":"Vesper retorna sozinho ao posto de onde saiu preso. Seu trio chega para ajudá-lo a abrir a guarda aos moradores que ainda esperam.",
		"ending":"Ele conserva a espada, mas deixa o antigo juramento no posto vazio."},
	"maura":{"name":"O espelho das feridas","chapter":"beacon","location":"PÁTIO DAS RAÍZES","enemies":["minion-redactor","minion-rootward","minion-root"],
		"story":"Maura identifica uma marca que reage à dor de outra pessoa. A ferida não pode ser deixada com a criatura que a espalha.",
		"ending":"Ela devolve cada marca à lembrança certa. As pessoas voltam a reconhecer o que sentiram.","field":[3,6,"Marca devolvida"]},
	"noct":{"name":"O rastro da primeira marca","chapter":"beacon","location":"VIGÍLIA DO VÉU","enemies":["minion-redactor","minion-acolyte","minion-fissure"],
		"story":"Noct segue a marca no peito até seu primeiro portador. A passagem se fecha se o Rasurador alcançar a próxima assinatura.",
		"ending":"A marca perde seu autor antigo. Noct decide quanto dela ainda quer carregar.","target":"o Rasurador do Véu","targetSlot":0},
	"riven":{"name":"A rota dos atrasados","chapter":"tides","location":"GALERIA DE TRÂNSITO","enemies":["minion-remnant","minion-siren","minion-inverter"],
		"story":"Riven volta pelo beco que a evacuação não cobriu. A última ronda inimiga se divide para fechar as duas saídas.",
		"ending":"Riven deixa as marcas da nova rota na altura dos olhos de quem não consegue correr.","waves":["Vigias do beco","Ronda da saída"]},
	"auren":{"name":"A luz que faz sombra","chapter":"tides","location":"MURALHA DO POENTE","enemies":["minion-prism","minion-fissure","minion-inverter"],
		"story":"Auren carrega uma lanterna que ilumina o caminho sem revelar quem se esconde. Os vigias querem obrigá-lo a apontá-la para o abrigo.",
		"ending":"A lanterna passa a apontar para o chão. O abrigo conserva seu caminho e seu segredo.","escort":true},
	"elyra":{"name":"A última cama do abrigo","chapter":"tides","location":"ABRIGO DA AURORA","enemies":["minion-afterglow","minion-root","minion-cinder"],
		"story":"Elyra mantém o abrigo aberto para mais uma pessoa. O trio precisa sustentar o perímetro até que a porta possa fechar.",
		"ending":"A cama vazia finalmente recebe um nome. Elyra põe outra no corredor para o próximo viajante.","survive":4},
	"solen":{"name":"O brilho depois do golpe","chapter":"forge","location":"ANEL DA ÚLTIMA LUZ","enemies":["minion-prism","minion-cinder","minion-furnace"],
		"story":"Solen volta ao ponto onde perdeu o controle da própria luz. A energia volta depressa, mas a técnica precisa de mais fôlego.",
		"ending":"Ele apaga a última chama sem ferir quem observa. A luz volta a caber na mão.","field":[6,7,"Clarão residual"]},
	"zaya":{"name":"A carta em mãos certas","chapter":"tides","location":"ROTAS DO POENTE","enemies":["minion-prism","minion-notary","minion-afterglow"],
		"story":"Zaya encontra enfim a destinatária de uma carta que descreve o caminho antes de ele existir. Ela leva a mensagem consigo.",
		"ending":"A destinatária lê a carta e escreve uma resposta com a data de hoje.","escort":true},
}

static func missions() -> Array:
	var result: Array = []
	for hero in RECORDS:
		var record: Dictionary = RECORDS[hero]
		var mission := {
			"id":"journey-"+hero,"chapter":record.chapter,"kind":"journey","requiredHero":hero,
			"requires":["eclipse"],"seed":2671+result.size()*31,"name":record.name,"location":record.location,
			"story":record.story,"ending":record.ending,"enemies":record.enemies,"scale":0.94,
			"reward":{"beacon":"ember","tides":"sap","forge":"pulse"}[record.chapter],
			"tip":"Escolha os outros dois integrantes do trio de acordo com os rivais. A vitória firma o pacto pessoal.",
		}
		if record.has("target"):
			mission.objective={"type":"target","target":"1-"+record.enemies[record.targetSlot],"targetName":record.target,"rounds":6}
		if record.has("survive"):
			mission.objective={"type":"survive","rounds":record.survive,"protectAll":true}
		if record.get("escort",false): mission.protectProtagonist=true
		if record.has("waves"):
			mission.waves=[{"name":record.waves[0],"healthScale":0.58,"attackScale":0.88},{"name":record.waves[1],"healthScale":0.73,"attackScale":0.98}]
		if record.has("field"):
			mission.field={"id":mission.id,"name":record.field[2],"basicEnergyGain":record.field[0],"skillCostDelta":record.field[1]}
		result.append(mission)
	return result
