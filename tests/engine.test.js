import {test} from 'node:test';
import assert from 'node:assert/strict';
import {HEROES,ARCHIVED_HEROES,CLASSES,CLASS_BY_ID,HERO_BY_ID,DEFAULT_TEAMS} from '../src/data.js';
import {createBattle,currentUnit,advantage,canUse,legalTargets,getAction,act,chooseAI,validateTeam,preview} from '../src/engine.js';
function scene(id='veyra') {
 const rest=HEROES.map(h=>h.id).filter(h=>h!==id);
 const s=createBattle([id,...rest.slice(0,2)],rest.slice(2,5));
 const a=s.units[0];s.order=[a.id,...s.units.slice(1).map(u=>u.id)];s.cursor=0;a.energy=100;
 return {s,a,t:s.units[3]};
}
const damage=r=>r.events.find(e=>e.type==='damage'&&!e.reaction&&!e.intercepted);
test('five affinities each have a distinct tank, support and damage kit; nine archived heroes retain art indices',()=>{
 assert.equal(HEROES.length,15);assert.equal(ARCHIVED_HEROES.length,9);assert.equal(CLASSES.length,5);
 assert.equal(new Set([...HEROES,...ARCHIVED_HEROES].map(h=>h.index)).size,24);
 for(const c of CLASSES) assert.deepEqual(HEROES.filter(h=>h.classId===c.id).map(h=>h.role).sort(),['Dano','Suporte','Tanque']);
 for(const h of HEROES) {assert(h.identity&&h.synergy);for(const k of ['basic','skill','ultimate'])assert(h[k].description&&h[k].name);}
 assert(!HERO_BY_ID.auren);
});
test('five-class cycle closes with Sombrio over Ígneo and reversed resistance',()=>{
 for(const c of CLASSES){assert.equal(advantage(c.id,CLASS_BY_ID[c.id].strongAgainst),1.25);assert.equal(advantage(CLASS_BY_ID[c.id].strongAgainst,c.id),.85);}
 assert.equal(advantage('sombrio','igneo'),1.25);assert.equal(advantage('arcano','igneo'),1);
});
test('invalid or archived teams, illegal targets and unavailable actions do not mutate a battle',()=>{
 assert(!validateTeam(['auren','veyra','astra']));assert(!validateTeam(['veyra','veyra','astra']));
 const s=createBattle(...DEFAULT_TEAMS),before=structuredClone(s);
 assert.throws(()=>act(s,'ultimate',s.units[3].id));assert.throws(()=>act(s,'basic',currentUnit(s).id));assert.deepEqual(s,before);
});
test('preview gives exact normal and critical shield/HP endpoints without changing RNG or live state',()=>{
 const {s,a,t}=scene();t.shield=200;const before=structuredClone(s),p=preview(s,'skill',t.id);
 assert.deepEqual(s,before);assert.deepEqual(p.normal,act(structuredClone(s),'skill',t.id,false));assert.deepEqual(p.critical,act(structuredClone(s),'skill',t.id,true));
 assert(damage(p.critical).total>damage(p.normal).total);assert.equal(a.energy,100);
});
test('Veyra consumes a burn for a 40% technique combo, while Riven keeps bleeding on his technique',()=>{
 for(const id of ['veyra','riven']){
  const {s,t}=scene(id),type=id==='veyra'?'burn':'bleed';t.statuses=[{type,turns:2}];
  const baseline=scene(id);const low=damage(act(baseline.s,'skill',baseline.t.id,false)).total;
  const r=act(s,'skill',t.id,false),d=damage(r);assert(d.total>low);assert.equal(d.combo,type);
  assert.equal(r.impactUnits.find(u=>u.id===t.id).statuses.some(st=>st.type===type),id==='riven');
 }
});
test('basic attacks apply their own marks and grant 24 energy; cooldown lasts two personal turns',()=>{
 const {s,a,t}=scene('riven');a.energy=40;const r=act(s,'basic',t.id,false);assert.equal(a.energy,64);assert.equal(damage(r).effect,'bleed');
 const q=scene();q.a.energy=100;act(q.s,'skill',q.t.id);assert.equal(q.a.cooldowns.skill,3);
 let visits=0;while(visits<3){const u=currentUnit(q.s);if(u===q.a){visits++;assert.equal(canUse(u,'skill'),visits===3);if(visits===3)break;}act(q.s,'guard',u.id);}
});
test('taunt constrains single-target damage but area attacks still reach all enemies',()=>{
 const {s,a,t}=scene();t.statuses=[{type:'taunt',turns:2}];
 assert.deepEqual(legalTargets(s,a,getAction(a,'basic')).map(u=>u.id),[t.id]);
 assert.equal(legalTargets(s,a,getAction(a,'ultimate')).length,3);
 const q=scene('rhazen');assert.deepEqual(legalTargets(q.s,q.a,getAction(q.a,'skill')).map(u=>u.id),[q.a.id]);
});
test('a live cover guardian receives 35% of a single hit; a dead guardian cannot protect',()=>{
 const {s,t}=scene();const g=s.units[4];t.statuses=[{type:'cover',turns:2,owner:g.id}];
 const r=act(s,'basic',t.id,false);const intercept=r.events.find(e=>e.intercepted);assert(intercept.amount>0);assert.equal(g.stats.protected,intercept.amount);
 assert.equal(intercept.total+damage(r).total,damage(act(scene().s,'basic',scene().t.id,false)).total);
 const q=scene();q.s.units[4].hp=0;q.t.statuses=[{type:'cover',turns:2,owner:q.s.units[4].id}];assert(!act(q.s,'basic',q.t.id).events.some(e=>e.intercepted));
});
test('Sylva seed heals the next attacker, is consumed, and cannot revive',()=>{
 const {s,a,t}=scene();a.hp-=300;t.statuses=[{type:'seed',turns:2}];
 const r=act(s,'basic',t.id,false),h=r.events.find(e=>e.source==='seed');assert.equal(h.amount,Math.round(a.maxHp*.1));assert(!r.impactUnits.find(u=>u.id===t.id).statuses.some(st=>st.type==='seed'));
});
test('fortification reduces incoming damage and inspiration increases attack',()=>{
 const base=scene();const normal=damage(act(base.s,'basic',base.t.id,false)).total;
 const fort=scene();fort.t.statuses=[{type:'fortify',turns:2}];assert(damage(act(fort.s,'basic',fort.t.id,false)).total<normal);
 const buff=scene();buff.a.statuses=[{type:'empower',turns:2}];assert(damage(act(buff.s,'basic',buff.t.id,false)).total>normal);
});
test('mirror and riposte react once, and do not trigger infinite counter chains',()=>{
 const {s,a,t}=scene();a.statuses=[{type:'riposte',turns:2}];t.statuses=[{type:'mirror',turns:2},{type:'riposte',turns:2}];
 const r=act(s,'basic',t.id,false);assert.equal(r.events.filter(e=>e.reaction).length,1);assert(a.hp<a.maxHp);
});
test('Kira pierces shield while Elun spends his stored shield once for an area supreme',()=>{
 const q=scene('kira');q.t.shield=500;const d=damage(act(q.s,'skill',q.t.id,false));assert(d.amount>0&&d.absorbed>0);
 const {s,a,t}=scene('elun');a.shield=400;const r=act(s,'ultimate',t.id,false);assert.equal(r.impactUnits[0].shield,0);assert.equal(r.events.filter(e=>e.type==='converted').length,1);assert.equal(r.events.filter(e=>e.type==='damage').length,3);
});
test('Vektor restores only available energy and purification preserves positive statuses',()=>{
 const {s,a}=scene('vektor');const ally=s.units[1];ally.energy=90;ally.statuses=['burn','bleed','expose','regen','fortify','empower'].map(type=>({type,turns:2}));
 const r=act(s,'skill',ally.id);assert.equal(ally.energy,100);assert.equal(r.events.find(e=>e.type==='energy').amount,10);assert.deepEqual(ally.statuses.map(x=>x.type),['regen','fortify','empower']);assert.equal(a.stats.energyGiven,10);
});
test('Maura benefits from allied bleeding to heal the most wounded ally',()=>{
 const {s,a,t}=scene('maura');a.hp=100;t.statuses=[{type:'bleed',turns:2}];
 const r=act(s,'skill',t.id,false);assert.equal(r.events.find(e=>e.source==='secondary').amount,Math.round(a.maxHp*.18*1.5));
});
test('critical against shield reports exact remaining barrier and useful protection',()=>{
 const {s,t}=scene();t.shield=600;const d=damage(act(s,'basic',t.id,true));assert(d.critical);assert.equal(d.amount,0);assert.equal(t.shield,600-d.absorbed);assert.equal(t.stats.shieldAbsorbed,d.absorbed);
});
test('damage is capped at remaining HP and shield; attacks cannot revive defeated targets',()=>{
 const {s,t}=scene();t.hp=10;t.shield=40;const d=damage(act(s,'skill',t.id,true));assert.equal(d.amount,10);assert.equal(d.absorbed,40);assert.equal(d.hpAfter,0);
});
test('burn and bleeding tick separately after impact and bypass shields; regeneration never revives',()=>{
 const {s,a,t}=scene();s.order=[a.id,t.id,...s.units.filter(u=>![a,t].includes(u)).map(u=>u.id)];t.shield=600;t.statuses=['burn','bleed'].map(type=>({type,turns:2}));
 const r=act(s,'basic',t.id,false);assert.deepEqual(r.turnEvents.map(e=>e.type),['burn','bleed']);assert.equal(r.turnEvents[0].remaining,1);assert.equal(t.hp,t.maxHp-2*Math.round(t.maxHp*.065));
 const q=scene();q.s.order=[q.a.id,q.t.id];q.t.hp=1;q.t.statuses=[{type:'burn',turns:2},{type:'regen',turns:2}];act(q.s,'guard',q.a.id);assert.equal(q.t.hp,0);
});
test('Fracture starts at round 12 with 4% max HP, bypasses barriers and ends defensive loops',()=>{
 const {s,a}=scene();s.round=11;s.order=[a.id];a.speed=999;const hp=a.hp;act(s,'guard',a.id);assert.equal(s.round,12);assert.equal(a.hp,hp-Math.ceil(a.maxHp*.04));assert(a.shield>0);
 const q=createBattle(...DEFAULT_TEAMS);while(q.phase==='playing'&&q.turns<400)act(q,'guard',currentUnit(q).id);assert.equal(q.phase,'finished');
});
test('deterministic AI exercises all fifteen kits and keeps resources bounded through complete matches',()=>{
 for(let i=0;i<15;i++){
 const teams=[0,5].map(offset=>[0,1,2].map(j=>HEROES[(i+offset+j)%15].id));const s=createBattle(...teams,{seed:i+1});
 while(s.phase==='playing'&&s.turns<400){const m=chooseAI(s);assert(m);assert(canUse(currentUnit(s),m.actionId));act(s,m.actionId,m.targetId);for(const u of s.units){assert(u.hp>=0&&u.hp<=u.maxHp);assert(u.shield>=0&&u.shield<=Math.round(u.maxHp*.6));assert(u.energy>=0&&u.energy<=100);}}
 assert.equal(s.phase,'finished',`match ${i}`);
 }
});
test('difficulty scales enemy HP and attack, while roles and speeds are persistent',()=>{
 const easy=createBattle(...DEFAULT_TEAMS,{difficulty:'easy'}),hard=createBattle(...DEFAULT_TEAMS,{difficulty:'hard'});
 assert(easy.units[3].maxHp<hard.units[3].maxHp);assert.equal(easy.units[3].speed,hard.units[3].speed);assert.equal(easy.units[0].maxHp,hard.units[0].maxHp);
});

test('periodic burn, bleeding and regeneration activate exactly twice per target',()=>{
 const s=createBattle(...DEFAULT_TEAMS),a=currentUnit(s);a.hp-=400;
 a.statuses=['burn','bleed','regen'].map(type=>({type,turns:2}));
 const initial=a.hp,delta=2*Math.round(a.maxHp*.065)-Math.round(a.maxHp*.07);
 act(s,'guard',a.id);let visits=0;
 while(visits<3){const u=currentUnit(s);if(u.id===a.id){visits++;assert.equal(a.hp,initial-delta*Math.min(2,visits));if(visits===3)break;}act(s,'guard',u.id);}
 assert.equal(a.statuses.length,0);
});
