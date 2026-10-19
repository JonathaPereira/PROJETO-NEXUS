// BALANCEAMENTO DOS 15 HERÓIS — edite os objetos abaixo.
// stats: hp = vida, attack = ataque, defense = defesa, speed = iniciativa.
// basic / skill / ultimate: nome, tipo, poder, descrição e efeitos de cada golpe.
// power em dano: 1.55 = 155% do ataque; em cura/escudo: 0.20 = 20% da vida.
// cost e cooldown podem ser adicionados à habilidade para substituir os padrões.
// Atualize a description quando mudar seu poder ou efeito.
// Afinidades/arte: data.js. Fórmulas globais: balance.json.
// Guia completo: godot/BALANCING.md. Depois de editar: npm run sync:godot.

export const KITS = {
  "veyra": {
    "role": "Dano",
    "identity": "Duelista que detona brasas",
    "synergy": "Cindra ou Rhazen preparam queimadura; Veyra a consome para antecipar dano.",
    "stats": {
      "hp": 1080,
      "attack": 251,
      "defense": 78,
      "speed": 112
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 1,
      "description": "Golpe direto de 100% do ataque. Recupera 24 de energia."
    },
    "skill": {
      "name": "Dança das brasas",
      "kind": "damage",
      "power": 1.55,
      "description": "155% do ataque. Contra queimadura: +40% de dano e consome a queimadura.",
      "combo": {
        "status": "burn",
        "multiplier": 1.4,
        "consume": true
      }
    },
    "ultimate": {
      "name": "Sol partido",
      "kind": "aoe",
      "power": 1.75,
      "description": "175% do ataque a todos. Contra queimadura: +30% e consome o efeito.",
      "combo": {
        "status": "burn",
        "multiplier": 1.3,
        "consume": true
      }
    }
  },
  "rhazen": {
    "role": "Tanque",
    "identity": "Fornalha que atrai e pune ataques",
    "synergy": "Provoca para proteger a equipe e devolve queimadura, preparando detonadores.",
    "stats": {
      "hp": 1390,
      "attack": 180,
      "defense": 116,
      "speed": 69
    },
    "basic": {
      "name": "Martelo da fornalha",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e ganha escudo de 2% da própria vida máxima. Recupera 24 de energia.",
      "secondary": {
        "kind": "shield",
        "target": "actor",
        "power": 0.02
      }
    },
    "skill": {
      "name": "Coração de ferro",
      "kind": "shield",
      "power": 0.16,
      "description": "Escudo de 16% em si. Provoca ataques individuais e queima quem o atingir por 2 turnos.",
      "self": true,
      "effect": "taunt",
      "extraEffect": "emberguard"
    },
    "ultimate": {
      "name": "Queda da fornalha",
      "kind": "aoe",
      "power": 1.1,
      "description": "110% do ataque em área, queimadura por 2 turnos e escudo próprio de 8%.",
      "effect": "burn",
      "secondary": {
        "kind": "shield",
        "target": "actor",
        "power": 0.08
      }
    }
  },
  "cindra": {
    "role": "Suporte",
    "identity": "Artilheira que abastece o trio",
    "synergy": "Prepara queimadura para Veyra e fortalece atacantes de qualquer afinidade.",
    "stats": {
      "hp": 1100,
      "attack": 189,
      "defense": 86,
      "speed": 102
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.7,
      "description": "70% do ataque e queimadura por 2 turnos. Recupera 24 de energia.",
      "effect": "burn"
    },
    "skill": {
      "name": "Sinal escarlate",
      "kind": "shieldAll",
      "power": 0.08,
      "description": "Escudo de 8% da vida máxima e ataque +20% para a equipe por 2 turnos.",
      "effect": "empower"
    },
    "ultimate": {
      "name": "Constelação ardente",
      "kind": "aoe",
      "power": 0.95,
      "description": "95% do ataque em área, queimadura por 2 turnos e +20 de energia para cada aliado.",
      "effect": "burn",
      "secondary": {
        "kind": "energy",
        "target": "allies",
        "amount": 20
      }
    }
  },
  "oren": {
    "role": "Tanque",
    "identity": "Colosso que divide o peso do golpe",
    "synergy": "Cobre um aliado frágil; escudo e regeneração sustentam essa proteção.",
    "stats": {
      "hp": 1380,
      "attack": 179,
      "defense": 118,
      "speed": 66
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e ataque inimigo −20% por 2 turnos. Recupera 24 de energia.",
      "effect": "weaken"
    },
    "skill": {
      "name": "Raízes entrelaçadas",
      "kind": "shield",
      "power": 0.14,
      "description": "Escudo de 14% em um aliado. Oren recebe 25% dos golpes individuais desse aliado por 2 turnos.",
      "effect": "cover"
    },
    "ultimate": {
      "name": "Despertar da floresta",
      "kind": "shieldAll",
      "power": 0.1,
      "description": "Escudo de 10% e regeneração para todos os aliados por 2 turnos.",
      "effect": "regen"
    }
  },
  "sylva": {
    "role": "Suporte",
    "identity": "Semeadora de cura por agressão",
    "synergy": "Sua Semente cura o próximo aliado que atingir o alvo; combina com tanques e finalizadores.",
    "stats": {
      "hp": 1180,
      "attack": 188,
      "defense": 103,
      "speed": 94
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.7,
      "description": "70% do ataque e Semente por 2 turnos. O próximo aliado a atingir o alvo se cura em 10% da própria vida máxima e consome a Semente. Recupera 24 de energia.",
      "effect": "seed"
    },
    "skill": {
      "name": "Jardim suspenso",
      "kind": "heal",
      "power": 0.2,
      "description": "Cura 20% da vida máxima de um aliado e concede regeneração por 2 turnos.",
      "effect": "regen"
    },
    "ultimate": {
      "name": "Primavera eterna",
      "kind": "healAll",
      "power": 0.22,
      "description": "Cura 22% da vida máxima da equipe; depois remove todos os efeitos negativos.",
      "effect": "cleanse"
    }
  },
  "nima": {
    "role": "Dano",
    "identity": "Caçadora que abre feridas e armaduras",
    "synergy": "Sangramento de Nima ou Riven prepara o disparo que expõe a defesa para outros atacantes.",
    "stats": {
      "hp": 1050,
      "attack": 252,
      "defense": 75,
      "speed": 114
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e sangramento por 2 turnos. Recupera 24 de energia.",
      "effect": "bleed"
    },
    "skill": {
      "name": "Espinho perfurante",
      "kind": "damage",
      "power": 1.5,
      "description": "150% do ataque; contra sangramento: +35% e consome o efeito. Reduz defesa em 25% por 2 turnos.",
      "effect": "expose",
      "combo": {
        "status": "bleed",
        "multiplier": 1.35,
        "consume": true
      }
    },
    "ultimate": {
      "name": "Mil espinhos",
      "kind": "aoe",
      "power": 1.65,
      "description": "165% do ataque em área e sangramento por 2 turnos.",
      "effect": "bleed"
    }
  },
  "axion": {
    "role": "Tanque",
    "identity": "Sentinela que fortifica a equipe",
    "synergy": "Barreiras e redução de dano protegem suportes; seus golpes expõem alvos para Kira e Astra.",
    "stats": {
      "hp": 1340,
      "attack": 186,
      "defense": 114,
      "speed": 80
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e defesa inimiga −25% por 2 turnos. Recupera 24 de energia.",
      "effect": "expose"
    },
    "skill": {
      "name": "Campo de contenção",
      "kind": "shieldAll",
      "power": 0.08,
      "description": "Escudo de 8% para a equipe e Fortificação: recebe 15% menos dano por 2 turnos.",
      "effect": "fortify"
    },
    "ultimate": {
      "name": "Protocolo zero",
      "kind": "shieldAll",
      "power": 0.16,
      "description": "Escudo de 16%, Fortificação por 2 turnos e +10 de energia para cada aliado.",
      "effect": "fortify",
      "secondary": {
        "kind": "energy",
        "target": "allies",
        "amount": 10
      }
    }
  },
  "vektor": {
    "role": "Suporte",
    "identity": "Engenheiro que acelera os aliados",
    "synergy": "Entrega energia a um aliado para antecipar técnicas e supremos; remove debuffs sem precisar curar.",
    "stats": {
      "hp": 1120,
      "attack": 188,
      "defense": 96,
      "speed": 98
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.75,
      "description": "75% do ataque e defesa inimiga −25% por 2 turnos. Recupera 24 de energia.",
      "effect": "expose"
    },
    "skill": {
      "name": "Drone de manutenção",
      "kind": "support",
      "power": 0,
      "description": "Remove efeitos negativos de um aliado e entrega até 30 de energia.",
      "effect": "cleanse",
      "secondary": {
        "kind": "energy",
        "target": "target",
        "amount": 30
      }
    },
    "ultimate": {
      "name": "Rede de cobalto",
      "kind": "supportAll",
      "power": 0,
      "description": "Regeneração por 2 turnos e até +20 de energia para toda a equipe.",
      "effect": "regen",
      "secondary": {
        "kind": "energy",
        "target": "allies",
        "amount": 20
      }
    }
  },
  "kira": {
    "role": "Dano",
    "identity": "Atiradora que atravessa barreiras",
    "synergy": "Axion, Vektor ou Nima expõem o alvo. Kira concentra dano e penetra escudos.",
    "stats": {
      "hp": 1030,
      "attack": 265,
      "defense": 73,
      "speed": 108
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 1,
      "description": "Disparo direto de 100% do ataque. Recupera 24 de energia."
    },
    "skill": {
      "name": "Sobrecarga",
      "kind": "damage",
      "power": 1.65,
      "description": "165% do ataque; contra defesa exposta: +35%. 30% do dano atravessa o escudo.",
      "pierce": 0.3,
      "combo": {
        "status": "expose",
        "multiplier": 1.35,
        "consume": false
      }
    },
    "ultimate": {
      "name": "Disparo orbital",
      "kind": "damage",
      "power": 2.8,
      "description": "280% do ataque em um alvo; metade do dano atravessa escudos.",
      "pierce": 0.5
    }
  },
  "elun": {
    "role": "Tanque",
    "identity": "Espelho que transforma defesa em ataque",
    "synergy": "Recebe escudos da equipe para fortalecer o supremo; o Espelho pune dano à vida.",
    "stats": {
      "hp": 1340,
      "attack": 183,
      "defense": 110,
      "speed": 78
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e defesa inimiga −25% por 2 turnos. Recupera 24 de energia.",
      "effect": "expose"
    },
    "skill": {
      "name": "Trama impossível",
      "kind": "shield",
      "power": 0.18,
      "description": "Escudo próprio de 18% e Espelho por 2 turnos: devolve 20% do dano sofrido à vida.",
      "self": true,
      "effect": "mirror"
    },
    "ultimate": {
      "name": "Paradoxo",
      "kind": "aoe",
      "power": 1,
      "description": "100% do ataque em área, mais 45% do escudo armazenado. Consome o escudo e expõe a defesa por 2 turnos.",
      "shieldScale": 0.45,
      "effect": "expose"
    }
  },
  "saira": {
    "role": "Suporte",
    "identity": "Voz que purifica e prepara ofensivas",
    "synergy": "Remove queimadura, sangramento e marcas. Seu supremo fortalece aliados já preparados para atacar.",
    "stats": {
      "hp": 1140,
      "attack": 181,
      "defense": 100,
      "speed": 101
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.7,
      "description": "70% do ataque e ataque inimigo −20% por 2 turnos. Recupera 24 de energia.",
      "effect": "weaken"
    },
    "skill": {
      "name": "Maré de éter",
      "kind": "healAll",
      "power": 0.12,
      "description": "Cura 12% da vida máxima de toda a equipe; depois remove efeitos negativos.",
      "effect": "cleanse"
    },
    "ultimate": {
      "name": "Coro das constelações",
      "kind": "healAll",
      "power": 0.22,
      "description": "Cura 22% da vida máxima e concede ataque +20% por 2 turnos para a equipe.",
      "effect": "empower"
    }
  },
  "astra": {
    "role": "Dano",
    "identity": "Cartógrafa que abre uma janela de explosão",
    "synergy": "Seu Selo aumenta o próximo golpe de qualquer aliado. Defesa exposta fortalece seu supremo.",
    "stats": {
      "hp": 1040,
      "attack": 276,
      "defense": 70,
      "speed": 104
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 1,
      "description": "Estilhaço direto de 100% do ataque. Recupera 24 de energia."
    },
    "skill": {
      "name": "Selo da órbita",
      "kind": "damage",
      "power": 1.25,
      "description": "125% do ataque e Selo astral por 2 turnos. O próximo golpe aliado causa +25% de dano e consome o Selo.",
      "effect": "focus"
    },
    "ultimate": {
      "name": "Colapso celeste",
      "kind": "aoe",
      "power": 1.85,
      "description": "185% do ataque em área; contra defesa exposta: +30% de dano.",
      "combo": {
        "status": "expose",
        "multiplier": 1.3,
        "consume": false
      }
    }
  },
  "vesper": {
    "role": "Tanque",
    "identity": "Duelista que protege por contra-ataques",
    "synergy": "Atrai golpes individuais, enfraquece rivais e responde com uma riposta enquanto mantém escudo.",
    "stats": {
      "hp": 1320,
      "attack": 195,
      "defense": 108,
      "speed": 76
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e ataque inimigo −20% por 2 turnos. Recupera 24 de energia.",
      "effect": "weaken"
    },
    "skill": {
      "name": "Guarda do eclipse",
      "kind": "shield",
      "power": 0.14,
      "description": "Escudo próprio de 14%, Provocação e Riposta por 2 turnos. Ao ser atingido, contra-ataca com 40% do ataque.",
      "self": true,
      "effect": "taunt",
      "extraEffect": "riposte"
    },
    "ultimate": {
      "name": "Eclipse absoluto",
      "kind": "aoe",
      "power": 1.1,
      "description": "110% do ataque em área, ataque inimigo −20% por 2 turnos e cura própria de 8%.",
      "effect": "weaken",
      "secondary": {
        "kind": "heal",
        "target": "actor",
        "power": 0.08
      }
    }
  },
  "maura": {
    "role": "Suporte",
    "identity": "Tecelã que transforma feridas em sustento",
    "synergy": "Riven ou Nima aplicam sangramento; Maura aproveita a ferida para curar mais o aliado mais ferido.",
    "stats": {
      "hp": 1190,
      "attack": 188,
      "defense": 101,
      "speed": 93
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.7,
      "description": "70% do ataque e ataque inimigo −20% por 2 turnos. Recupera 24 de energia.",
      "effect": "weaken"
    },
    "skill": {
      "name": "Pacto silencioso",
      "kind": "damage",
      "power": 0.9,
      "description": "90% do ataque e enfraquecimento por 2 turnos. Cura o aliado mais ferido em 14%; contra sangramento, cura 21%.",
      "effect": "weaken",
      "secondary": {
        "kind": "heal",
        "target": "lowestAlly",
        "power": 0.14,
        "whenStatus": "bleed",
        "multiplier": 1.5
      }
    },
    "ultimate": {
      "name": "Réquiem das sombras",
      "kind": "supportAll",
      "power": 0,
      "description": "Purifica a equipe e entrega até +20 de energia a cada aliado.",
      "effect": "cleanse",
      "secondary": {
        "kind": "energy",
        "target": "allies",
        "amount": 20
      }
    }
  },
  "riven": {
    "role": "Dano",
    "identity": "Executor que prepara a própria oportunidade",
    "synergy": "Sangramento aliado habilita seu combo. Alvos abaixo de 35% da vida ficam mais expostos à finalização.",
    "stats": {
      "hp": 1060,
      "attack": 263,
      "defense": 76,
      "speed": 107
    },
    "basic": {
      "name": "",
      "kind": "damage",
      "power": 0.8,
      "description": "80% do ataque e sangramento por 2 turnos. Recupera 24 de energia.",
      "effect": "bleed"
    },
    "skill": {
      "name": "Dívida de sangue",
      "kind": "damage",
      "power": 1.6,
      "description": "160% do ataque; contra sangramento: +35%. Contra alvos abaixo de 35% da vida: mais +30%.",
      "combo": {
        "status": "bleed",
        "multiplier": 1.35,
        "consume": false
      },
      "executeThreshold": 0.35,
      "executeMultiplier": 1.3
    },
    "ultimate": {
      "name": "Última lembrança",
      "kind": "damage",
      "power": 2.65,
      "description": "265% do ataque em um alvo. Contra sangramento: +25%, consumindo a ferida.",
      "combo": {
        "status": "bleed",
        "multiplier": 1.25,
        "consume": true
      }
    }
  }
};

export function applyKit(hero) {
  const kit = KITS[hero.id];
  const {hp,attack,defense,speed} = kit.stats;
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
