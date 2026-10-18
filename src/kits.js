// Explicit role kits. Affinity and combat role are independent axes.
const action = (name, kind, power, description, extra = {}) => ({ name, kind, power, description, ...extra });
const basic = (power, effect, description) => action('', 'damage', power, description + ' Recupera 24 de energia.', effect ? { effect } : {});
export const KITS = {
  veyra: { role:'Dano', identity:'Duelista que detona brasas', synergy:'Cindra ou Rhazen preparam queimadura; Veyra a consome para antecipar dano.', stats:[1080,251,78,112],
    basic:basic(1,null,'Golpe direto de 100% do ataque.'),
    skill:action('Dança das brasas','damage',1.55,'155% do ataque. Contra queimadura: +40% de dano e consome a queimadura.',{combo:{status:'burn',multiplier:1.4,consume:true}}),
    ultimate:action('Sol partido','aoe',1.75,'175% do ataque a todos. Contra queimadura: +30% e consome o efeito.',{combo:{status:'burn',multiplier:1.3,consume:true}}) },
  rhazen: { role:'Tanque', identity:'Fornalha que atrai e pune ataques', synergy:'Provoca para proteger a equipe e devolve queimadura, preparando detonadores.', stats:[1390,180,116,69],
    basic:action('Martelo da fornalha','damage',.8,'80% do ataque e ganha escudo de 2% da própria vida máxima. Recupera 24 de energia.',{secondary:{kind:'shield',target:'actor',power:.02}}),
    skill:action('Coração de ferro','shield',.16,'Escudo de 16% em si. Provoca ataques individuais e queima quem o atingir por 2 turnos.',{self:true,effect:'taunt',extraEffect:'emberguard'}),
    ultimate:action('Queda da fornalha','aoe',1.1,'110% do ataque em área, queimadura por 2 turnos e escudo próprio de 8%.',{effect:'burn',secondary:{kind:'shield',target:'actor',power:.08}}) },
  cindra: { role:'Suporte', identity:'Artilheira que abastece o trio', synergy:'Prepara queimadura para Veyra e fortalece atacantes de qualquer afinidade.', stats:[1100,189,86,102],
    basic:basic(.7,'burn','70% do ataque e queimadura por 2 turnos.'),
    skill:action('Sinal escarlate','shieldAll',.08,'Escudo de 8% da vida máxima e ataque +20% para a equipe por 2 turnos.',{effect:'empower'}),
    ultimate:action('Constelação ardente','aoe',.95,'95% do ataque em área, queimadura por 2 turnos e +20 de energia para cada aliado.',{effect:'burn',secondary:{kind:'energy',target:'allies',amount:20}}) },
  oren: { role:'Tanque', identity:'Colosso que divide o peso do golpe', synergy:'Cobre um aliado frágil; escudo e regeneração sustentam essa proteção.', stats:[1380,179,118,66],
    basic:basic(.8,'weaken','80% do ataque e ataque inimigo −20% por 2 turnos.'),
    skill:action('Raízes entrelaçadas','shield',.14,'Escudo de 14% em um aliado. Oren recebe 25% dos golpes individuais desse aliado por 2 turnos.',{effect:'cover'}),
    ultimate:action('Despertar da floresta','shieldAll',.1,'Escudo de 10% e regeneração para todos os aliados por 2 turnos.',{effect:'regen'}) },
  sylva: { role:'Suporte', identity:'Semeadora de cura por agressão', synergy:'Sua Semente cura o próximo aliado que atingir o alvo; combina com tanques e finalizadores.', stats:[1180,188,103,94],
    basic:basic(.7,'seed','70% do ataque e Semente por 2 turnos. O próximo aliado a atingir o alvo se cura em 10% da própria vida máxima e consome a Semente.'),
    skill:action('Jardim suspenso','heal',.2,'Cura 20% da vida máxima de um aliado e concede regeneração por 2 turnos.',{effect:'regen'}),
    ultimate:action('Primavera eterna','healAll',.22,'Cura 22% da vida máxima da equipe; depois remove todos os efeitos negativos.',{effect:'cleanse'}) },
  nima: { role:'Dano', identity:'Caçadora que abre feridas e armaduras', synergy:'Sangramento de Nima ou Riven prepara o disparo que expõe a defesa para outros atacantes.', stats:[1050,252,75,114],
    basic:basic(.8,'bleed','80% do ataque e sangramento por 2 turnos.'),
    skill:action('Espinho perfurante','damage',1.5,'150% do ataque; contra sangramento: +35% e consome o efeito. Reduz defesa em 25% por 2 turnos.',{effect:'expose',combo:{status:'bleed',multiplier:1.35,consume:true}}),
    ultimate:action('Mil espinhos','aoe',1.65,'165% do ataque em área e sangramento por 2 turnos.',{effect:'bleed'}) },
  axion: { role:'Tanque', identity:'Sentinela que fortifica a equipe', synergy:'Barreiras e redução de dano protegem suportes; seus golpes expõem alvos para Kira e Astra.', stats:[1340,186,114,80],
    basic:basic(.8,'expose','80% do ataque e defesa inimiga −25% por 2 turnos.'),
    skill:action('Campo de contenção','shieldAll',.08,'Escudo de 8% para a equipe e Fortificação: recebe 15% menos dano por 2 turnos.',{effect:'fortify'}),
    ultimate:action('Protocolo zero','shieldAll',.16,'Escudo de 16%, Fortificação por 2 turnos e +10 de energia para cada aliado.',{effect:'fortify',secondary:{kind:'energy',target:'allies',amount:10}}) },
  vektor: { role:'Suporte', identity:'Engenheiro que acelera os aliados', synergy:'Entrega energia a um aliado para antecipar técnicas e supremos; remove debuffs sem precisar curar.', stats:[1120,188,96,98],
    basic:basic(.75,'expose','75% do ataque e defesa inimiga −25% por 2 turnos.'),
    skill:action('Drone de manutenção','support',0,'Remove efeitos negativos de um aliado e entrega até 30 de energia.',{effect:'cleanse',secondary:{kind:'energy',target:'target',amount:30}}),
    ultimate:action('Rede de cobalto','supportAll',0,'Regeneração por 2 turnos e até +20 de energia para toda a equipe.',{effect:'regen',secondary:{kind:'energy',target:'allies',amount:20}}) },
  kira: { role:'Dano', identity:'Atiradora que atravessa barreiras', synergy:'Axion, Vektor ou Nima expõem o alvo. Kira concentra dano e penetra escudos.', stats:[1030,265,73,108],
    basic:basic(1,null,'Disparo direto de 100% do ataque.'),
    skill:action('Sobrecarga','damage',1.65,'165% do ataque; contra defesa exposta: +35%. 30% do dano atravessa o escudo.',{pierce:.3,combo:{status:'expose',multiplier:1.35,consume:false}}),
    ultimate:action('Disparo orbital','damage',2.8,'280% do ataque em um alvo; metade do dano atravessa escudos.',{pierce:.5}) },
  elun: { role:'Tanque', identity:'Espelho que transforma defesa em ataque', synergy:'Recebe escudos da equipe para fortalecer o supremo; o Espelho pune dano à vida.', stats:[1340,183,110,78],
    basic:basic(.8,'expose','80% do ataque e defesa inimiga −25% por 2 turnos.'),
    skill:action('Trama impossível','shield',.18,'Escudo próprio de 18% e Espelho por 2 turnos: devolve 20% do dano sofrido à vida.',{self:true,effect:'mirror'}),
    ultimate:action('Paradoxo','aoe',1,'100% do ataque em área, mais 45% do escudo armazenado. Consome o escudo e expõe a defesa por 2 turnos.',{shieldScale:.45,effect:'expose'}) },
  saira: { role:'Suporte', identity:'Voz que purifica e prepara ofensivas', synergy:'Remove queimadura, sangramento e marcas. Seu supremo fortalece aliados já preparados para atacar.', stats:[1140,181,100,101],
    basic:basic(.7,'weaken','70% do ataque e ataque inimigo −20% por 2 turnos.'),
    skill:action('Maré de éter','healAll',.12,'Cura 12% da vida máxima de toda a equipe; depois remove efeitos negativos.',{effect:'cleanse'}),
    ultimate:action('Coro das constelações','healAll',.22,'Cura 22% da vida máxima e concede ataque +20% por 2 turnos para a equipe.',{effect:'empower'}) },
  astra: { role:'Dano', identity:'Cartógrafa que abre uma janela de explosão', synergy:'Seu Selo aumenta o próximo golpe de qualquer aliado. Defesa exposta fortalece seu supremo.', stats:[1040,276,70,104],
    basic:basic(1,null,'Estilhaço direto de 100% do ataque.'),
    skill:action('Selo da órbita','damage',1.25,'125% do ataque e Selo astral por 2 turnos. O próximo golpe aliado causa +25% de dano e consome o Selo.',{effect:'focus'}),
    ultimate:action('Colapso celeste','aoe',1.85,'185% do ataque em área; contra defesa exposta: +30% de dano.',{combo:{status:'expose',multiplier:1.3,consume:false}}) },
  vesper: { role:'Tanque', identity:'Duelista que protege por contra-ataques', synergy:'Atrai golpes individuais, enfraquece rivais e responde com uma riposta enquanto mantém escudo.', stats:[1320,195,108,76],
    basic:basic(.8,'weaken','80% do ataque e ataque inimigo −20% por 2 turnos.'),
    skill:action('Guarda do eclipse','shield',.14,'Escudo próprio de 14%, Provocação e Riposta por 2 turnos. Ao ser atingido, contra-ataca com 40% do ataque.',{self:true,effect:'taunt',extraEffect:'riposte'}),
    ultimate:action('Eclipse absoluto','aoe',1.1,'110% do ataque em área, ataque inimigo −20% por 2 turnos e cura própria de 8%.',{effect:'weaken',secondary:{kind:'heal',target:'actor',power:.08}}) },
  maura: { role:'Suporte', identity:'Tecelã que transforma feridas em sustento', synergy:'Riven ou Nima aplicam sangramento; Maura aproveita a ferida para curar mais o aliado mais ferido.', stats:[1190,188,101,93],
    basic:basic(.7,'weaken','70% do ataque e ataque inimigo −20% por 2 turnos.'),
    skill:action('Pacto silencioso','damage',.9,'90% do ataque e enfraquecimento por 2 turnos. Cura o aliado mais ferido em 14%; contra sangramento, cura 21%.',{effect:'weaken',secondary:{kind:'heal',target:'lowestAlly',power:.14,whenStatus:'bleed',multiplier:1.5}}),
    ultimate:action('Réquiem das sombras','supportAll',0,'Purifica a equipe e entrega até +20 de energia a cada aliado.',{effect:'cleanse',secondary:{kind:'energy',target:'allies',amount:20}}) },
  riven: { role:'Dano', identity:'Executor que prepara a própria oportunidade', synergy:'Sangramento aliado habilita seu combo. Alvos abaixo de 35% da vida ficam mais expostos à finalização.', stats:[1060,263,76,107],
    basic:basic(.8,'bleed','80% do ataque e sangramento por 2 turnos.'),
    skill:action('Dívida de sangue','damage',1.6,'160% do ataque; contra sangramento: +35%. Contra alvos abaixo de 35% da vida: mais +30%.',{combo:{status:'bleed',multiplier:1.35,consume:false},executeThreshold:.35,executeMultiplier:1.3}),
    ultimate:action('Última lembrança','damage',2.65,'265% do ataque em um alvo. Contra sangramento: +25%, consumindo a ferida.',{combo:{status:'bleed',multiplier:1.25,consume:true}}) },
};
export function applyKit(hero) {
  const kit = KITS[hero.id];
  const [hp,attack,defense,speed] = kit.stats;
  const result = { ...hero, role:kit.role, identity:kit.identity, synergy:kit.synergy, hp,attack,defense,speed };
  for (const id of ['basic','skill','ultimate']) result[id] = {...hero[id], effect:undefined, ...kit[id], name:kit[id].name || hero[id].name};
  for (const id of ['basic','skill','ultimate']) {
    const a = result[id];
    if (a.kind.startsWith('shield') || a.secondary?.kind === 'shield') a.description += ' Escudo dura 2 ações do protegido; não soma com outro escudo.';
    if (a.effect === 'bleed') a.description += ' Sangramento reduz toda cura recebida em 35% enquanto durar.';
  }
  // JSON and runtime must expose the same keys.
  return JSON.parse(JSON.stringify(result));
}
