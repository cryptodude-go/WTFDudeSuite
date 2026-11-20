local _,HP=...
-- Independent implementation. Scope follows the active guide; no reward choice is automated.
function HP.GuideWantsQuest(id,phase)
 if not HP.route or not HP.state or HP.db.guideBook~='leveling' or HP.db.mode=='quests' then return false end
 local finish=HP.route.catalog and #HP.route.steps or math.min(#HP.route.steps,HP.state.index+7)
 local start=HP.route.catalog and 1 or HP.state.index
 for i=start,finish do local s=HP.route.steps[i]
  if s.libraryRaw then for _,blocked in ipairs(HP.LibraryIds(s.libraryRaw.noauto)) do if blocked==id then return false end end end
  local catchup=HP.LibraryCatchup(s);if catchup and catchup.questID==id and catchup.action==phase then return true end
  if s.questID==id and HP.Applies(s) and (s.action=='quest' or s.action==phase or phase=='accept' and s.action=='objective') then return true end
 end
 return false
end
function HP.HandleQuestAssistance(event)
 if not HP.db or HP.db.hidden or HP.db.paused or HP.Call(InCombatLockdown) or HP.Call(IsShiftKeyDown) then return end
 local id=HP.Call(GetQuestID);if type(id)~='number' or id<=0 then return end
 if event=='QUEST_DETAIL' and HP.db.autoAcceptQuests and HP.GuideWantsQuest(id,'accept') then HP.Call(AcceptQuest)
 elseif HP.db.autoTurnInQuests and HP.GuideWantsQuest(id,'turnin') then
  if event=='QUEST_PROGRESS' and HP.Call(IsQuestCompletable)==true then HP.Call(CompleteQuest)
  elseif event=='QUEST_COMPLETE' and HP.Call(GetNumQuestChoices)==0 then HP.Call(GetQuestReward,1) end
 end
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local f=CreateFrame('Frame');HP.questAssistanceEvents=f
 for _,event in ipairs({'QUEST_DETAIL','QUEST_PROGRESS','QUEST_COMPLETE'}) do f:RegisterEvent(event) end
 f:SetScript('OnEvent',function(_,event) HP.HandleQuestAssistance(event) end)
end
