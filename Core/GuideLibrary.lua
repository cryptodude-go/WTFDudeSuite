local _,HP=...
local function point(raw)
 local p=raw.go or raw.spots and raw.spots[1] or type(raw.revive)=='table' and raw.revive
 if type(p)=='table' and type(p[1])=='number' and type(p[2])=='number' and type(p[3])=='number' then return {mapID=p[1],x=p[2]/100,y=p[3]/100} end
 if type(raw.talk)=='number' then return HP.LibraryEntityLocation('npc',raw.talk) end
 if type(raw.object)=='number' then return HP.LibraryEntityLocation('object',raw.object) end
end
local function add(route,g,raw,index,action,id,kind)
 local p=point(raw);local s={action=action,questID=id,section=g.title,libraryGuide=g.id,libraryIndex=index,libraryRaw=raw,libraryKind=kind,
 classes=raw.classes,races=raw.races,libraryFaction=raw.faction,hint=raw.note or raw.text,useItemID=raw.useitem or HP.LibraryIds(raw.use)[1]}
 if p then s.mapID=p.mapID;s.x=p.x;s.y=p.y end
 s.librarySequence=#route.steps+1;route.steps[#route.steps+1]=s;return s
end
function HP.CompileLibraryGuide(id)
 local g=HP.guideLibrary[id];if not g then return end
 if g.compiled then return g.compiled end
 local r={id='library:'..id,title=g.title,minLevel=g.minLevel,maxLevel=g.maxLevel,races=g.races,classes=g.classes,revision=1,libraryGuide=id,steps={},source='Ding v1.8.1 / GPL-3.0'}
 for index,raw in ipairs(g.steps) do
  local quests=false
  -- Complete/turn-in before accepting the continuation matches the original combined-step contract.
  for _,entry in ipairs({{'turnin','turnin'},{'accept','accept'},{'complete','objective'}}) do
   for _,qid in ipairs(HP.LibraryIds(raw[entry[1]])) do add(r,g,raw,index,entry[2],qid);quests=true end
  end
  local kind
  for _,key in ipairs({'collect','buy','bank','unbank','equip','abandon','destroy','sethearth','hearth','fly','train','vendor','deathskip','revive','level'}) do if raw[key] then kind=key;break end end
  if not kind and not quests then kind=raw.go and not raw.talk and 'travel' or 'manual' end
  if kind then local s=add(r,g,raw,index,kind=='level' and 'level' or 'library',nil,kind);s.targetLevel=raw.level end
 end
 g.compiled=r;HP.routes[r.id]=r;return r
end
function HP.SelectLibraryGuide(id)
 local g=HP.guideLibrary[id];if not g or not HP.LibraryMatches(g) then return false end
 HP.pendingGuideZone=nil;HP.pendingGuideStyle=nil;HP.pendingGuideBook=nil
 if HP.Call(InCombatLockdown) then HP.pendingLibraryGuide=id;return false end
 HP.pendingLibraryGuide=nil
 HP.db.libraryGuideID=id;HP.db.guideStyle='normal';HP.db.guideBook='leveling';HP.db.mode='guide';HP.db.selectedGuide=nil
 HP.manualWaypoint=nil;HP.normalQuestFocus=nil;HP.review=false;HP.UseGuide();return true
end
function HP.SuggestLibraryGuide()
 local best,score;local level=HP.character and HP.character.level or 1
 for _,id in ipairs(HP.libraryOrder) do local g=HP.guideLibrary[id]
  if g.category=='leveling' and HP.LibraryMatches(g) and level>=g.minLevel and level<=g.maxLevel then
   local value=g.minLevel+(g.races and 1000 or 0)
   if not score or value>score then best,score=g,value end
  end
 end
 return best
end
local route=HP.Route
function HP.Route(race,build)
 local id=HP.db and HP.db.libraryGuideID
 if not id and HP.db and not HP.db.libraryPlannerPreferred and HP.Call(UnitFactionGroup,'player')=='Alliance' then local suggestion=HP.SuggestLibraryGuide();if suggestion then id=suggestion.id;HP.db.libraryGuideID=id end end
 local g=id and HP.guideLibrary[id]
 if g and HP.LibraryMatches(g) then local r=HP.CompileLibraryGuide(id);return r.id,r end
 return route(race,build)
end
local reconcile=HP.ReconcileNormalQuestLog
function HP.ReconcileNormalQuestLog(...)
 if HP.db and HP.db.libraryGuideID and HP.route and HP.route.libraryGuide then return end
 return reconcile(...)
end
local select=HP.SelectGuide
function HP.SelectGuide(...) HP.pendingLibraryGuide=nil;HP.db.libraryGuideID=nil;HP.db.libraryPlannerPreferred=true;return select(...) end
local style=HP.SetGuideStyle
function HP.SetGuideStyle(...) HP.pendingLibraryGuide=nil;HP.db.libraryGuideID=nil;HP.db.libraryPlannerPreferred=true;return style(...) end
local chooseBook=HP.ChooseGuideBook
function HP.ChooseGuideBook(...) HP.pendingLibraryGuide=nil;return chooseBook(...) end
function HP.LibraryCatchup(s)
 if not s.libraryGuide or not s.questID or HP.Active(s.questID) or HP.Completed(s.questID) or HP.LiveQuestOffer and HP.LiveQuestOffer(s.questID) then return end
 local seen={}
 local function missing(id,depth)
  if seen[id] or depth>20 then return end;seen[id]=true
  local q=HP.questData[id];if not q then return end
  local parent
  local function eligible(value)
   local p=HP.questData[value]
   return p and HP.Applies({questID=value,action='quest',classes=p.classes,races=p.races,newForever=p.newForever})
  end
  for _,value in ipairs(q.prerequisiteAll or {}) do if value>0 and not HP.Completed(value) and eligible(value) then parent=value;break end end
  if not parent and #(q.prerequisites or {})>0 then
   local met=false
   for _,value in ipairs(q.prerequisites) do if value>0 and HP.Completed(value) then met=true end end
   if not met then for _,value in ipairs(q.prerequisites) do if value>0 and eligible(value) then parent=parent or value;if HP.Active(value) then parent=value;break end end end end
  end
  if not parent then return end
  if HP.Active(parent) then return parent end
  return missing(parent,depth+1) or parent
 end
 local id=missing(s.questID,1);if not id then return end
 return {questID=id,action=not HP.Active(id) and 'accept' or HP.Done({action='objective',questID=id}) and 'turnin' or 'objective'}
end
local applies=HP.Applies
function HP.Applies(s)
 if not s.libraryGuide then return applies(s) end
 local g=HP.guideLibrary[s.libraryGuide];local raw=s.libraryRaw
 if not HP.LibraryMatches(g) or not HP.LibraryMatches({races=s.races,classes=s.classes,faction=s.libraryFaction}) or not HP.LibraryConditions(raw.when) then return false end
 if (raw.deathskip or raw.revive or raw.destroy or raw.abandon) and HP.db.libraryAdvancedSteps~=true then return false end
 if raw.dungeon and HP.db.includeGroupQuests~=true then return false end
 if raw.elite and HP.db.includeGroupQuests~=true then return false end
 if g.category=='class' and HP.db.includeClassQuests==false then return false end
 if s.questID then
  local q=HP.questData[s.questID]
  if (q and q.newForever or s.questID>=90000) and HP.db.includeForeverQuests==false then return false end
  if q and q.raidQuest and HP.db.includeRaidQuests~=true then return false end
 end
 return true
end
local done=HP.Done
function HP.Done(s)
 if not s.libraryGuide then return done(s) end
 if not HP.Applies(s) then return true end
 local state=HP.db.routes['library:'..s.libraryGuide]
 if state and state.confirmed and state.confirmed[s.librarySequence] then return true end
 local raw=s.libraryRaw
 if s.questID then
  if raw.optional and not HP.Active(s.questID) and not HP.Completed(s.questID) then local q=HP.questData[s.questID];if q and ((HP.character.level or 1)<(q.minLevel or 1) or not HP.PrerequisitesMet(q)) then return true end end
  return done(s)
 end
 if s.libraryKind=='collect' or s.libraryKind=='buy' then
  for _,item in ipairs(HP.LibraryItems(raw[s.libraryKind])) do if HP.ItemCount(item[1])<(item[2] or 1) then return false end end;return true
 elseif s.libraryKind=='level' then
  local level=HP.character and HP.character.level or 1
  return level>(raw.level or 1) or level==(raw.level or 1) and (not raw.xp or (HP.Call(UnitXP,'player') or 0)>=raw.xp)
 elseif s.libraryKind=='travel' then
  local p=point(raw);local dx,dy=p and HP.NavigationVector(p)
  if p then dx,dy=HP.NavigationVector(p) end
  return dx and dx*dx+dy*dy<=(raw.radius or 20)^2 or false
 end
 return false
end
local location=HP.StepLocation
function HP.StepLocation(s)
 if s.libraryGuide and not s.questID then return point(s.libraryRaw) end
 local prerequisite=HP.LibraryCatchup(s);if prerequisite then return location(prerequisite) end
 return location(s)
end
local rows=HP.StepRows
local verbs={sethearth='Set your Hearthstone',hearth='Use your Hearthstone',fly='Take the flight',train='Visit your class trainer',vendor='Visit a vendor',deathskip='Optional death skip',revive='Return to your spirit healer',bank='Deposit the listed items',unbank='Withdraw the listed items',equip='Equip the listed item',abandon='Review the quest to abandon',destroy='Review the item to destroy',manual='Follow the guide instruction',collect='Collect the listed items',buy='Buy the listed items',travel='Go to the next waypoint'}
function HP.StepRows(s,compact)
 if not s.libraryGuide then return rows(s,compact) end
 if s.questID then
  local prerequisite=HP.LibraryCatchup(s)
  local out=rows(prerequisite or s,compact)
  if prerequisite and not compact then out[#out+1]={kind='info',text='Required before '..HP.QuestName(s.questID)..'.'} end
  local q=HP.questData[s.questID]
  if not compact and not HP.Active(s.questID) and q and (q.minLevel or 1)>(HP.character.level or 1) then out[#out+1]={kind='info',text='Requires level '..q.minLevel..'.'} end
  if not compact and s.libraryRaw.floor then out[#out+1]={kind='tip',text='Floor: '..s.libraryRaw.floor,tooltipText='Follow the indicated cave or building floor; the route line does not model vertical passages.'} end
  if not compact and s.hint then out[#out+1]={kind='tip',text='Guide note',tooltipText=s.hint} end
  return out
 end
 local raw=s.libraryRaw;local text=raw.text or verbs[s.libraryKind] or ('Reach level '..tostring(raw.level or '?'))
 if type(raw.sethearth)=='string' then text='Set your Hearthstone in '..raw.sethearth end
 local out={{kind='info',text=text,tooltipText=raw.note or (type(raw.why)=='table' and raw.why.text) or raw.why}}
 if s.libraryKind=='collect' or s.libraryKind=='buy' then for _,item in ipairs(HP.LibraryItems(raw[s.libraryKind])) do
  local data=HP.itemData[item[1]];out[#out+1]={kind='item',text=(data and data.name or ('Item '..item[1]))..' · '..HP.ItemCount(item[1])..'/'..(item[2] or 1),itemID=item[1]}
 end end
 for _,key in ipairs({'bank','unbank','destroy','equip','use','keep','abandon'}) do
  for _,id in ipairs(HP.LibraryIds(raw[key])) do
   local data=HP.itemData[id];local name=key=='abandon' and HP.QuestName(id) or data and data.name or ('Item '..id)
   out[#out+1]={kind='info',text=key..': '..name,tooltipText='Follow this instruction manually; no item or quest is changed automatically.'}
  end
 end
 if raw.object then local object=HP.objectData[raw.object];out[#out+1]={kind='info',text='Interact with '..(object and object.name or 'the indicated object')..'.'} end
 if raw.talk then local npc=HP.npcData[raw.talk];out[#out+1]={kind='talk',text='Talk to '..(npc and npc.name or 'the indicated NPC')..'.',entityKind='npc',entityID=raw.talk,entityName=npc and npc.name} end
 if raw.note then out[#out+1]={kind='tip',text='Guide note',tooltipText=raw.note} end
 if s.libraryKind~='travel' and s.libraryKind~='collect' and s.libraryKind~='buy' and s.libraryKind~='level' then out[#out+1]={kind='info',text='Press Next when finished.'} end
 return out
end
local destination=HP.DestinationName
function HP.DestinationName(s) return destination(HP.LibraryCatchup(s) or s) end
local navigation=HP.NavigationAction
function HP.NavigationAction()
 local s=HP.route and HP.state and HP.route.steps[HP.state.index];local prerequisite=s and HP.LibraryCatchup(s)
 if prerequisite and not HP.manualWaypoint then return (prerequisite.action=='accept' and 'Accept ' or prerequisite.action=='turnin' and 'Turn in ' or 'Complete ')..HP.QuestName(prerequisite.questID) end
 return navigation()
end
local move=HP.Move
function HP.Move(delta)
 local s=HP.route and HP.route.libraryGuide and HP.state and HP.route.steps[HP.state.index]
 if s and not s.questID and delta>0 then
  HP.state.confirmed=HP.state.confirmed or {};HP.state.confirmed[s.librarySequence]=true;HP.state.index=HP.state.index+1;HP.review=false;HP.Refresh();return
 end
 return move(delta)
end
local refresh=HP.Refresh
local advancing=false
function HP.Refresh(...)
 local result=refresh(...)
 if not advancing and HP.db and HP.db.guideBook=='leveling' and HP.db.mode~='quests' and not HP.auxiliaryActive and HP.db.libraryAutoNext~=false and HP.route and HP.route.libraryGuide and HP.state and HP.state.index>#HP.route.steps and not HP.db.paused and not HP.Call(InCombatLockdown) then
  local g=HP.guideLibrary[HP.route.libraryGuide];local nextGuide=g and HP.guideLibrary[g.next]
  if nextGuide and HP.LibraryMatches(nextGuide) then advancing=true;HP.SelectLibraryGuide(nextGuide.id);advancing=false end
 end
 return result
end
local create=HP.CreateUI
function HP.CreateUI()
 create();local events=CreateFrame('Frame');HP.libraryEvents=events;events:RegisterEvent('PLAYER_REGEN_ENABLED')
 events:SetScript('OnEvent',function() if HP.pendingLibraryGuide then local id=HP.pendingLibraryGuide;HP.pendingLibraryGuide=nil;HP.SelectLibraryGuide(id) end end)
end
