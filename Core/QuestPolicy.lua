-- Quest eligibility shared by the engine, catch-up, previews, automation and navigation.
local _, HP = ...
local D=HP.Native
local E,C,Data=D.Engine,D.Compat,D.Data
local Q={};HP.QuestPolicy=Q
function Q:Leveling(guide)
 if not guide or HP.auxiliaryActive then return false end
 local pack=D:GetGuidePack(guide.pack)
 return not pack or not pack.category or pack.category=='leveling'
end
function Q:Maps(guide)
 if HP.auxiliaryActive then return nil end
 if guide and guide.pack=='ding-zones' and D.db and D.db.ui.zoneFocus~=false then return guide.zoneMaps end
end
function Q:PointAllowed(point,guide)
 local maps=self:Maps(guide or E.guide)
 if not maps then return true end
 for _,map in ipairs(maps)do if point.map==map then return true end end
 return false
end
local places={}
function Q:Places(q)
 if places[q]then return places[q]end
 local groups={Data:StartPoints(q),Data:EndPoints(q)}
 for _,target in ipairs(Data:ObjectiveTargets(q))do groups[#groups+1]=target.points end
 places[q]=groups
 return groups
end
function Q:BaseReject(q,guide)
 if not self:Leveling(guide) or E:IsTurnedIn(q)then return nil end
 local gap=tonumber(D.db and D.db.ui.questLevelGap) or 5
 local level=Data:QuestLevel(q)
 -- Already finished quests may still be handed in locally; never abandon anything.
 if gap>0 and level>0 and UnitLevel('player')-level>gap
  and not (C.IsInLog(q) and C.IsQuestReady(q))then return 'level' end
 if self:Maps(guide)then
  -- Every known action must be possible inside the selected zone. A delivery or
  -- prerequisite outside it cannot secretly drag the route into another zone.
  for _,points in ipairs(self:Places(q))do
   if #points>0 then
    local here=false
    for _,point in ipairs(points)do if self:PointAllowed(point,guide)then here=true;break end end
    if not here then return 'zone' end
   end
  end
 end
end
function Q:Reject(q,guide,seen,depth)
 guide=guide or E.guide
 if not self:Leveling(guide) or E:IsTurnedIn(q)then return nil end
 local reason=self:BaseReject(q,guide)
 if reason then return reason end
 if C.IsInLog(q)then return nil end
 -- Do not replace a skipped old quest with its inaccessible follow-up. Single
 -- prerequisites are alternatives; group prerequisites must all be completed.
 seen=seen or {};depth=depth or 0
 if seen[q] or depth>=15 then return nil end
 seen[q]=true
 local single,group=Data:QuestPrereqs(q)
 for _,p in ipairs(group or {})do
  if not E:IsTurnedIn(p) and Data:QuestOpenToPlayer(p) and self:Reject(p,guide,seen,depth+1)then seen[q]=nil;return 'chain' end
 end
 local available,blocked,done=false,false,false
 for _,p in ipairs(single or {})do
  if E:IsTurnedIn(p)then done=true;break end
  if Data:QuestOpenToPlayer(p)then
   available=true
   if not self:Reject(p,guide,seen,depth+1)then blocked=false;available=false;break end
   blocked=true
  end
 end
 seen[q]=nil
 if not done and available and blocked then return 'chain' end
end
function Q:OnlyExcluded(step,guide)
 local any,rejected=false,false
 for _,key in ipairs({'accept','complete','turnin'})do
  for _,q in ipairs(step[key]or {})do
   any=true
   local reason=self:Reject(q,guide)
   rejected=rejected or reason~=nil
   if not E:IsTurnedIn(q) and not reason then return false end
  end
 end
 return any and rejected
end
local done=E.IsStepDone
function E:IsStepDone(step,index)
 if Q:Leveling(self.guide)then
  if Q:OnlyExcluded(step,self.guide) and not (step.train or step.vendor or step.repair)then return true end
  if step.go and Q:Maps(self.guide) and not Q:PointAllowed({map=step.go[1]},self.guide)then return true end
  -- A hearth/travel/service reminder with no eligible work left in this section
  -- is not a reason to revisit its old hub.
  if not(step.accept or step.complete or step.turnin) and not step.level then
   local remaining=false
   for i=(index or self.index)+1,#self.guide.steps do
    local s=self.guide.steps[i]
    if D:StepApplies(s)then
     for _,key in ipairs({'accept','complete','turnin'})do for _,q in ipairs(s[key]or {})do
      if not self:IsTurnedIn(q) and not Q:Reject(q,self.guide)then remaining=true;break end
     end end
    end
    if remaining then break end
   end
   if not remaining and (step.go or step.hearth or step.sethearth or step.fly)then return true end
  end
 end
 return done(self,step,index)
end
local catch=E.CatchUp
function E:CatchUp(q,step)
 if Q:Reject(q,self.guide)then return nil end
 local p=catch(self,q,step)
 return p and not Q:Reject(p,self.guide) and p or nil
end
local nextGuide=E.NextGuide
function E:NextGuide(guide)
 local next=nextGuide(self,guide)
 local maps=Q:Maps(guide)
 if maps and next then
  if not next.zoneMaps then return nil end
  for _,map in ipairs(next.zoneMaps)do
   local same=false;for _,current in ipairs(maps)do if current==map then same=true end end
   if not same then return nil end
  end
 end
 return next
end
local candidates=E.StepCandidates
function E:StepCandidates(step,index)
 if step and Q:OnlyExcluded(step,self.guide)then return {}end
 local points=candidates(self,step,index)
 local out={};for _,p in ipairs(points)do if Q:PointAllowed(p,self.guide)then out[#out+1]=p end end
 return out
end
local describe=E.Describe
function E:Describe(step,preview)
 if not step or not Q:Leveling(self.guide)then return describe(self,step,preview)end
 local filtered={};for k,v in pairs(step)do filtered[k]=v end
 for _,key in ipairs({'accept','complete','turnin'})do
  if step[key]then filtered[key]={};for _,q in ipairs(step[key])do
   if not Q:Reject(q,self.guide)then filtered[key][#filtered[key]+1]=q end
  end end
 end
 return describe(self,filtered,preview)
end
local find=E.FindQuest
function E:FindQuest(q)
 if Q:Reject(q,self.guide)then return nil end
 local result=find(self,q)
 if result and Q:Maps(self.guide) and result.guide~=self.guide.id then return nil end
 return result
end
local choose=HP.QuestReconcile.ChooseSection
function HP.QuestReconcile:ChooseSection()
 if Q:Maps(E.guide)then return nil end
 return choose(self)
end
local content=D.Panel.Content
function D.Panel:Content()
 if E.finished and Q:Maps(E.guide)then
  return {{action='info',text='No eligible quests left in this zone.'},
   {indent=true,kind='hint',text='Choose another zone or switch to the leveling route in Settings.'}}
 end
 return content(self)
end
local build=D.Config.TABS[D.Config.TAB.guide or 1].build
D.Config.TABS[D.Config.TAB.guide or 1].build=function(canvas,width)
 local rows=build(canvas,width)
 table.insert(rows,3,D.UI.SelectorRow(canvas,D.Config,{
  label='Maximum quest levels below me',default=5,
  values={{3,'3'},{5,'5 (recommended)'},{6,'6'},{8,'8'},{0,'No limit'}},
  get=function()return tonumber(D.db.ui.questLevelGap)or 5 end,
  set=function(v)D.db.ui.questLevelGap=v;HP.QuestReconcile:Run(true)end},width))
 table.insert(rows,4,D.UI.CheckRow(canvas,D.Config,{
  label='Stay in the selected zone',desc='Zone guides keep their own quests and stop before another zone. Applies to the Zones book.',default=true,
  get=function()return D.db.ui.zoneFocus~=false end,
  set=function(v)D.db.ui.zoneFocus=v;HP.QuestReconcile:Run(true)end},width))
 return rows
end
-- Filter the shared candidate list as well as individual steps (sticky objectives).
local allCandidates=E.Candidates
function E:Candidates(step,index)
 local out={}
 for _,p in ipairs(allCandidates(self,step,index))do if Q:PointAllowed(p,self.guide)then out[#out+1]=p end end
 return out
end
local rebuild=D.Along.Rebuild
function D.Along:Rebuild()
 rebuild(self)
 for _,entry in ipairs(self.entries or {})do
  local points={};for _,p in ipairs(entry.points or {})do if Q:PointAllowed(p,E.guide)then points[#points+1]=p end end
  entry.points=points
 end
end
local fallback=HP.NativeFallbackPoints
function HP.NativeFallbackPoints()
 if E.finished and not HP.auxiliaryActive then return {}end
 local out={}
 for _,p in ipairs(fallback())do if Q:PointAllowed(p,E.guide)then out[#out+1]=p end end
 return out
end
local wanted=D.AutoQuest.Wanted
function D.AutoQuest:Wanted()
 local accept,turnin,ahead=wanted(self)
 for q in pairs(accept)do if Q:Reject(q,E.guide)then accept[q],ahead[q]=nil,nil end end
 for q in pairs(turnin)do if Q:Reject(q,E.guide)then turnin[q]=nil end end
 return accept,turnin,ahead
end
