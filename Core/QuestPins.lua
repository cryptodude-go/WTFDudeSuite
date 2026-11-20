-- Quest/objective pin lifecycle. Leave player waypoints and gathering detours alone.
local _,HP=...
local D=HP.Native
local E,A,P,C=D.Engine,D.Arrow,D.Panel,D.Compat
local X={};HP.QuestPins=X
function X:AllObjectivesDone(q)
 if not C.IsInLog(q)then return false end
 local list=C.GetObjectives(q)
 if #list==0 then return false end
 for _,obj in ipairs(list)do if not C.ObjectiveComplete(obj)then return false end end
 return true
end
function X:RowDone(row,wasInLog)
 if not row or not row.quest then return false end
 local q=row.quest
 if E:IsTurnedIn(q)then return true end
 if wasInLog and not C.IsInLog(q)then return true end
 if row.action=='accept'then return C.IsInLog(q)end
 if row.action=='turnin'then return false end
 if row.action=='objective'then
  local obj=row.index and C.GetObjectives(q)[row.index]
  if obj and C.ObjectiveComplete(obj)then return true end
 end
 if row.action=='objective'or row.action=='complete'or row.action=='header'then
  return C.IsQuestReady(q)or self:AllObjectivesDone(q)
 end
 return false
end
function X:DropFocus()
 local f=A.forced
 if f and self:RowDone(f.row,f.wasInLog)then
  A.forced,A.point,A.shownPoint,A.farm,A.follow=nil,nil,nil,nil,nil
  A.targetsFor,A.stepTargets=nil,nil
  return true
 end
 return false
end
local points=P.PointsOf
function P:PointsOf(row)
 if X:RowDone(row)then return {}end
 return points(self,row)
end
local candidates=E.StepCandidates
function E:StepCandidates(step,index)
 -- Coordinates attached to completed quest actions are not an independent
 -- reason to keep the completed objective's pin on screen.
 if step and not(step.train or step.fly or step.hearth or step.sethearth or step.vendor or step.repair)then
  local any,done=false,true
  for _,key in ipairs({'accept','complete','turnin'})do
   for _,q in ipairs(step[key]or{})do
    any=true
    local actionDone=self:IsTurnedIn(q)or(key=='accept'and C.IsInLog(q))
     or(key=='complete'and(C.IsQuestReady(q)or X:AllObjectivesDone(q)))
    if not actionDone then done=false end
   end
  end
  if any and done and self:LevelReached(step)and D.Goals:Done(step,index or self.index,self.guide)then return {}end
 end
 return candidates(self,step,index)
end
function X:HidePins()
 if D.MinimapPins then
  local pins=D.MinimapPins
  if pins.target then pins.target:Hide();pins.edge:Hide()end
  for _,dot in ipairs(pins.dots or{})do dot:Hide();dot.point=nil end
 end
end
function X:Signature()
 local ids,seen={},{}
 local function add(q)if type(q)=='number'and not seen[q]then seen[q]=true;ids[#ids+1]=q end end
 local step=E:CurrentStep()
 for _,key in ipairs({'accept','complete','turnin'})do for _,q in ipairs(step and step[key]or{})do add(q)end end
 for _,q in ipairs(E:LogQuests())do add(q)end
 local f=A.forced;if f and f.row then add(f.row.quest)end
 for _,entry in ipairs(D.Along and D.Along.shown or{})do add(entry.quest)end
 table.sort(ids)
 local parts={tostring(E.guide),tostring(E.index),tostring(E.finished)}
 for _,q in ipairs(ids)do
  parts[#parts+1]=q..':'..tostring(E:IsTurnedIn(q))..':'..tostring(C.IsInLog(q))..':'..tostring(C.IsQuestReady(q))
  for _,obj in ipairs(C.GetObjectives(q))do
   parts[#parts+1]=tostring(C.ObjectiveComplete(obj))..':'..(obj.text or ''):gsub('%d+%s*/%s*%d+','')
  end
 end
 return table.concat(parts,'|')
end
function X:Reconcile(force)
 if self.busy or not D.db or not D.char or not HP.nativeStarted or HP.auxiliaryActive then return end
 local signature=self:Signature()
 if not force and signature==self.signature then return end
 self.busy=true
 local ok,err=pcall(function()
  self:DropFocus()
  -- Reset only when quest availability/objective completion changes, not on
  -- duplicate events or every kill counter. Farming loops remain stable.
  A.point,A.shownPoint,A.farm,A.follow=nil,nil,nil,nil
  E:Update()
  if D.MinimapPins then D.MinimapPins:Update()end
  if HP.UpdateMapPins then HP.UpdateMapPins()elseif HP.UpdateRouteLines then HP.UpdateRouteLines()end
  self.signature=self:Signature()
 end)
 self.busy=false
 if not ok then error(err)end
end

local update=A.Update
function A:Update()
 X:DropFocus()
 if HP.db and HP.db.paused and not self.manualPoint then
  self.point,self.shownPoint,self.farm=nil,nil,nil
  self:MarkWorld(nil);X:HidePins()
 end
 return update(self)
end
local tick=A.Tick
function A:Tick()
 if not D.db then return end
 if HP.db and HP.db.paused and not self.manualPoint then self:MarkWorld(nil);X:HidePins();return end
 if not X.busy and X:DropFocus()then
  X:Reconcile()
  return
 end
 return tick(self)
end
local mini=D.MinimapPins.Update
function D.MinimapPins:Update()
 if HP.db and HP.db.paused and not A.manualPoint then X:HidePins();return end
 return mini(self)
end
for _,event in ipairs({'QUEST_LOG_UPDATE','QUEST_ACCEPTED','QUEST_TURNED_IN','QUEST_REMOVED','QUEST_WATCH_UPDATE'})do
 D:On(event,function()D:Safe(X.Reconcile,X)end)
end
