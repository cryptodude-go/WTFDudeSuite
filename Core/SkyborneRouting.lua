local _,HP=...
-- Availability fields used by the reviewed Skyborne catalogue. Accepted quests
-- and current positive server offers continue to override reference restrictions.
function HP.SkyborneAvailable(q)
 if q.availableStartingWith and not (HP.Active(q.availableStartingWith) or HP.Completed(q.availableStartingWith)) then return false end
 if q.availableUntilCompleted and HP.Completed(q.availableUntilCompleted) then return false end
 if q.disabledByQuest and (HP.Active(q.disabledByQuest) or HP.Completed(q.disabledByQuest)) then return false end
 if q.skyborneAbsentSpell and HP.Call(IsSpellKnown,q.skyborneAbsentSpell)==true then return false end
 if q.skyborneSkill then
  local skills=HP.ProfessionSkills and HP.ProfessionSkills() or {}
  local skill=skills[q.skyborneSkill[1]]
  if not skill or (skill.rank or 0)<q.skyborneSkill[2] then return false end
 end
 return true
end
local score=HP.CandidateScore
function HP.CandidateScore(step)
 local q=HP.questData[step.questID]
 if q and q.skyborneReviewed and not HP.Active(step.questID) and not HP.LiveQuestOffer(step.questID) and not HP.SkyborneAvailable(q) then return end
 return score(step)
end
local location=HP.StepLocation
function HP.StepLocation(step)
 local phase=HP.QuestStepPhase(step);local q=HP.questData[phase.questID]
 if q and q.skyborneReviewed and (phase.action=='accept' or phase.action=='turnin') then
  local observed=HP.db and HP.db.questLocations and HP.db.questLocations[phase.questID]
  local point=observed and observed[phase.action]
  if point then return point end
  point=q[phase.action=='accept' and 'startLocation' or 'finishLocation']
  if point then return point end
 end
 return location(step)
end
-- Recompute this zone's skipped/index state after the catalogue repair, while
-- retaining the character's actual completed-quest history.
if HP.routes.zone_16593 then
 HP.routes.zone_16593.revision=3
 HP.routes.zone_16593.description='Skyborne starter quests with reviewed questgivers, class/faction gates and prerequisite chains. Native quest progress takes priority.'
 HP.routes.zone_16593.source='Skyborne factual pickup and chain review, 2026-10-20'
end
