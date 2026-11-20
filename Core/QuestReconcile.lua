-- Reconcile positive server quest history without inventing turn-ins or deleting manual marks.
local _,HP=...
local D=HP.Native
local E,C,P,UI,Cfg=D.Engine,D.Compat,D.Panel,D.UI,D.Config
local R={history={},status='Not checked this session.'};HP.QuestReconcile=R
local function enabled()return D.db and D.db.ui.autoCatchUp~=false end
function R:ReadHistory()
 local found={};local count=0
 for id in pairs(self.history)do found[id]=true end
 local ids=HP.Call(C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs)
 self.historyAvailable=type(ids)=='table'
 if self.historyAvailable then
  for _,id in ipairs(ids)do if type(id)=='number' and id>0 then found[id]=true end end
 end
 -- These entries are recorded only on actual QUEST_TURNED_IN events.
 for id,done in pairs(HP.db and HP.db.completed or {})do if done and tonumber(id) then found[tonumber(id)]=true end end
 for id in pairs(found)do count=count+1 end
 self.history=found;self.count=count
 return count
end
local completed=C.IsQuestCompleted
function C.IsQuestCompleted(id)
 if completed(id) then return true end
 -- An active repeatable must still be completed and handed in this time.
 return R.history[id]==true and not C.IsInLog(id)
end
local stepDone=E.IsStepDone
function E:IsStepDone(step,index)
 if stepDone(self,step,index) then return true end
 -- A completed quest's travel coordinate must not keep sending the player back.
 -- Unrelated trainer/hearth/flight/item goals still need their own completion.
 if step.train or step.hearth or step.sethearth or step.fly then return false end
 local any=false
 for _,key in ipairs({'accept','complete','turnin'})do
  for _,id in ipairs(step[key] or {})do any=true;if not self:IsTurnedIn(id)then return false end end
 end
 return any and self:LevelReached(step) and D.Goals:Done(step,index,self.guide) or false
end
function R:ChooseSection()
 local current=E.guide
 if not current or HP.auxiliaryActive then return nil end
 local pack=D:GetGuidePack(current.pack)
 if pack and pack.category and pack.category~='leveling' then return nil end
 local level=tonumber(UnitLevel('player')) or 1
 if level<=(current.maxLevel or 60) and D:GuideMatchesPlayer(current)then return nil end
 local best,score
 for _,g in D:IterateGuides(current.pack)do
  if D:GuideMatchesPlayer(g) and level>=g.minLevel and level<=g.maxLevel then
   local _,left=E:GuideProgress(g)
   if left>0 then
    local active=0
    for _,s in ipairs(g.steps)do
     if D:StepApplies(s) then
      for _,key in ipairs({'accept','complete','turnin'})do
       for _,q in ipairs(s[key] or {})do if C.IsInLog(q) and not E:IsTurnedIn(q)then active=active+1 end end
      end
     end
    end
    local value=active*100+g.minLevel
    if not score or value>score then best,score=g,value end
   end
  end
 end
 return best
end
function R:Adapt()
 if not enabled() or E.hold or HP.auxiliaryActive or HP.db and HP.db.paused then return false end
 local nextGuide=self:ChooseSection()
 if nextGuide then E:Resume(nextGuide.id,true);return true end
 return false
end
function R:Run(silent)
 if not D.db or not D.char or not HP.db then return end
 local count=self:ReadHistory()
 if HP.auxiliaryActive then self.status='Quest history checked; profession/reputation guide kept.';return end
 E.hold=false;E.browseFrom=nil;P.holding=nil
 local switched=self:Adapt()
 if not switched and E.guide then E:Resume(E.guide.id,true)end
 local source=self.historyAvailable and string.format('%d completed quests checked.',count) or 'Available quest flags and recorded turn-ins checked.'
 self.status=string.format('%s Level %d: %s.',source,UnitLevel('player'),E.guide and E.guide.title or 'No compatible section')
 if not silent then D:Print(self.status)end
 E:Refresh()
end
local start=E.Start
function E:Start(...)
 R:ReadHistory();local result=start(self,...)
 if self.guide and not self.startPending then R:Adapt()end
 return result
end
D:On('PLAYER_LEVEL_UP',function()
 if C_Timer and C_Timer.After then C_Timer.After(1,function()R:Adapt()end)end
end)
D:On('QUEST_TURNED_IN',function(_,id)if id then R.history[id]=true end end)
D:On('QUEST_LOG_UPDATE',function()
 if not R.lastLevel or R.lastLevel~=UnitLevel('player')then R.lastLevel=UnitLevel('player');R:Adapt()end
end)
local build=Cfg.TABS[Cfg.TAB.guide or 1].build
Cfg.TABS[Cfg.TAB.guide or 1].build=function(canvas,width)
 local rows=build(canvas,width)
 table.insert(rows,1,UI.CheckRow(canvas,Cfg,{label='Keep the leveling guide near my level',desc='Move beyond outleveled sections. Class, dungeon and skill guides stay selected.',default=true,
 get=enabled,set=function(v)D.db.ui.autoCatchUp=v;if v then R:Run(true)end end},width))
 table.insert(rows,1,UI.ButtonRow(canvas,Cfg,{label='Check completed quests and my level',desc=R.status,button='Check now',run=function()R:Run(false)end},width))
 return rows
end
local command=SlashCmdList.DUDEWHERESMYDING
SlashCmdList.DUDEWHERESMYDING=function(input)
 if (input or ''):lower():match('^%s*resync%s*$')then R:Run(false);return end
 return command(input)
end
