-- Respect conditional availability on imported facts without guessing server unlocks.
local _,HP=...
local D=HP.Native;local Data,C=D.Data,D.Compat
local open=Data.QuestOpenToPlayer
function Data:QuestOpenToPlayer(id)
 local q=HP.questData[id]
 if not(q and q.questie150)then return open(self,id)end
 if C.IsInLog(id)then return true end
 if q.questieAvailabilityPending then return false end
 if q.raceMask and q.raceMask>0 then
  local _,race,raceID=HP.Call(UnitRace,'player');local bit=HP.RaceQuestBit and HP.RaceQuestBit(raceID,race)
  if not bit or math.floor(q.raceMask/bit)%2==0 then return false end
 end
 if q.classes then local allowed=false;for _,class in ipairs(q.classes)do if class==C.PlayerClass()then allowed=true;break end end;if not allowed then return false end end
 for _,other in ipairs(q.exclusive or {})do if C.IsQuestCompleted(other)or C.IsInLog(other)then return false end end
 local skill=q.requiredSkill
 if skill and skill[1]and skill[1]>0 then local learned=HP.ProfessionSkills()[skill[1]];if not learned or learned.rank<(skill[2]or 1)then return false end end
 for _,rule in ipairs({{q.requiredMinRep,true},{q.requiredMaxRep,false}})do
  local gate=rule[1]
  if gate and gate[1]and gate[1]>0 then local value=HP.ReputationValue(gate[1]);if not value or(rule[2]and value<(gate[2]or 0))or(not rule[2]and value>=(gate[2]or 0))then return false end end
 end
 return true
end
