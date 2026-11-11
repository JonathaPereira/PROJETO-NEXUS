extends RefCounted
## Local milestones derive from validated campaign facts; browsing never writes progress.
static func _entry(id: String,title: String,hint: String,current: int,goal: int) -> Dictionary:
 return {"id":id,"title":title,"hint":hint,"current":mini(current,goal),"goal":goal,"unlocked":goal>0 and current>=goal}

static func entries(story) -> Array:
 var main: Array=story.main_missions()
 var won: int=main.filter(story.is_complete).size()
 var journeys: Array=range(story.missions.size()).filter(func(index):return story.missions[index].get("kind")=="journey")
 var pacts: int=journeys.filter(story.is_complete).size()
 var challenges: Array=range(story.missions.size()).filter(func(index):return story.missions[index].get("kind")=="challenge")
 var cleared_challenges: int=challenges.filter(story.is_complete).size()
 var bonds: int=story.bonds.values().filter(func(value):return int(value)>=story.Bonds.REQUIRED_VICTORIES).size()
 var masters:=0
 for hero in story.catalog.heroes:
  if story.mastery_rank(hero.id)>=3:masters+=1
 return [
  _entry("first-light","A primeira chama","Conclua uma missão principal.",won,1),
  _entry("six-paths","Os seis caminhos","Conclua todas as missões principais dos seis capítulos.",won,main.size()),
  _entry("beacon-awake","Farol desperto","Alcance o nível 6 da equipe.",story.team_level(),6),
  _entry("first-pact","Um pacto","Conclua uma jornada pessoal.",pacts,1),
  _entry("full-chorus","Coro completo","Conclua as jornadas dos 24 heróis.",pacts,journeys.size()),
  _entry("side-by-side","Lado a lado","Firme um vínculo com três vitórias compartilhadas.",bonds,1),
  _entry("own-mastery","Domínio próprio","Alcance maestria III com um herói.",masters,1),
  _entry("against-odds","Contra o impossível","Conclua os três desafios especiais.",cleared_challenges,challenges.size()),
 ]
