local _,HP=...
local INF=math.huge
local function enabled(route)
 return HP.db and (HP.db.guideStyle=='normal' or HP.db.guideStyle=='speed') and HP.db.mode~='quests' and not HP.auxiliaryActive and route and route.catalog
end
local function playerLocation()
 local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
 local pos=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,'player')
 local x,y;if pos then x,y=HP.Call(pos.GetXY,pos) end
 if type(x)=='number' and type(y)=='number' then return {mapID=map,x=x,y=y} end
end
local function projected(loc)
 if not loc then return end
 local n,w,instance=HP.WorldPoint(loc)
 return {loc=loc,n=n,w=w,instance=instance}
end
local function distance(a,b)
 if not a or not b then return INF end
 if a.n and a.w and b.n and b.w and a.instance~=nil and a.instance==b.instance then return math.sqrt((a.n-b.n)^2+(a.w-b.w)^2) end
 if a.loc.mapID==b.loc.mapID then
  local w,h=HP.Call(C_Map and C_Map.GetMapWorldSize,a.loc.mapID)
  if type(w)=='number' and w>0 and type(h)=='number' and h>0 then return math.sqrt(((a.loc.x-b.loc.x)*w)^2+((a.loc.y-b.loc.y)*h)^2) end
 end
 return INF
end
local function nearest(pool,origin,kind)
 local best,dist
 for _,node in ipairs(pool) do if not node.used and node.kind==kind then
  local d=distance(origin,node.point)
  if not best or d<dist or d==dist and node.index<best.index then best,dist=node,d end
 end end
 return best,dist or INF
end
local function append(points,loc)
 if not loc then return end
 local prev=points[#points]
 if not prev or prev.mapID~=loc.mapID or math.abs(prev.x-loc.x)+math.abs(prev.y-loc.y)>.0001 then points[#points+1]=loc end
end
local plan=HP.PlanCandidates
function HP.PlanCandidates(route,skipped)
 local result=plan(route,skipped)
 if not enabled(route) then return result end
 local origin=projected(playerLocation())
 if not origin then HP.smartPlan=nil;return result end
 local pool,byIndex={},{}
 for _,candidate in ipairs(result) do
  local step=route.steps[candidate.index];local phase=HP.QuestStepPhase(step).action
  local kind=HP.Active(step.questID) and (phase=='turnin' and 'turnin' or phase=='objective' and 'objective') or phase=='accept' and 'accept'
  local loc=kind and HP.StepLocation(step)
  if loc then
   local node={candidate=candidate,index=candidate.index,questID=step.questID,kind=kind,point=projected(loc)}
   pool[#pool+1]=node;byIndex[node.index]=node
  end
 end
 local focus
 if HP.normalQuestFocus then
  for _,node in ipairs(pool) do if node.questID==HP.normalQuestFocus then focus=node;break end end
  if not focus or focus.kind~=(HP.normalQuestFocusPhase or 'objective') then HP.normalQuestFocus=nil;HP.normalQuestFocusPhase=nil;focus=nil end
 end
 local ordered,used,points={}, {}, {}
 local cursor=origin;local count=0;local reason
 while count<8 do
  local objective,od=nearest(pool,cursor,'objective')
  local turn,td=nearest(pool,cursor,'turnin')
  local virtual,vd=nearest(pool,cursor,'return')
  if vd<td then turn,td=virtual,vd end
  local pickup,pd=nearest(pool,cursor,'accept')
  local chosen
  if focus and count==0 then chosen=focus;reason='manual selection'
  elseif turn and td<=65 then chosen=turn;reason=reason or 'nearby quest hub'
  elseif pickup and pd<=60 then chosen=pickup;reason=reason or 'nearby pickup'
  elseif objective and od<INF and (not turn or od<=math.max(450,td*1.15)) then
   chosen=objective;reason=reason or 'nearby objectives'
   -- Small movements inside overlapping spawn areas should not flip the target.
   if count==0 and HP.route==route and HP.state then local current=byIndex[HP.state.index]
    if current and current.kind=='objective' and distance(cursor,current.point)<=od+80 then chosen=current end
   end
  elseif turn and td<INF then chosen=turn;reason=reason or 'return before distant objectives'
  elseif objective and od<INF then chosen=objective
  elseif pickup and pd<INF then chosen=pickup end
  if not chosen then break end
  chosen.used=true;append(points,chosen.point.loc);cursor=chosen.point
  if chosen.kind=='return' then break end
  count=count+1;ordered[#ordered+1]=chosen.candidate;used[chosen.index]=true
  if chosen.kind=='objective' then
   local finish=HP.StepLocation({action='turnin',questID=chosen.questID})
   if finish then pool[#pool+1]={kind='return',index=chosen.index,point=projected(finish)} end
  elseif chosen.kind=='turnin' then
   -- Preview the remaining ready turn-ins in this hub, then let the refreshed
   -- quest log account for follow-ups before planning another field trip.
   for _=1,6 do local hub,d=nearest(pool,cursor,'turnin');if not hub or d>100 then break end
    hub.used=true;ordered[#ordered+1]=hub.candidate;used[hub.index]=true;append(points,hub.point.loc);cursor=hub.point
   end
   break
  elseif chosen.kind=='accept' then break end
 end
 for _,candidate in ipairs(result) do if not used[candidate.index] then ordered[#ordered+1]=candidate end end
 -- Preserve unknown/unprojectable live objectives in the list, without letting
 -- a fabricated distance block a known ready turn-in.
 for i,candidate in ipairs(ordered) do candidate.score=i end
 HP.smartPlan={route=route,firstIndex=ordered[1] and ordered[1].index,points=points,reason=reason}
 return ordered
end
local trail=HP.TrailPoints
function HP.TrailPoints()
 local p=HP.smartPlan
 if not enabled(HP.route) or HP.manualWaypoint or HP.review or not p or p.route~=HP.route or not HP.state or p.firstIndex~=HP.state.index or #p.points==0 then return trail() end
 local points={};append(points,playerLocation())
 local step=HP.route.steps[HP.state.index]
 for _,point in ipairs(step and step.path or {}) do append(points,point) end
 append(points,HP.waypoint)
 for i=HP.waypoint and 2 or 1,#p.points do append(points,p.points[i]) end
 return points
end
-- Clip every queued segment to the minimap circle. Offscreen objective-to-hub
-- segments must not draw across the UI or connect unrelated coordinate frames.
local function clip(x1,y1,x2,y2,r)
 local dx,dy=x2-x1,y2-y1;local a=dx*dx+dy*dy;if a<.001 then return end
 local b=2*(x1*dx+y1*dy);local c=x1*x1+y1*y1-r*r;local disc=b*b-4*a*c;if disc<0 then return end
 local lo=math.max(0,(-b-math.sqrt(disc))/(2*a));local hi=math.min(1,(-b+math.sqrt(disc))/(2*a))
 if lo>hi then return end;return x1+dx*lo,y1+dy*lo,x1+dx*hi,y1+dy*hi
end
HP.ClipSmartRoute=clip
local update=HP.UpdateRouteLines
function HP.UpdateRouteLines()
 update()
 local f=HP.smartTrailMini
 if f then for _,dot in ipairs(f.dots) do dot:Hide() end;f:Hide() end
 if not enabled(HP.route) or HP.manualWaypoint or HP.review or not HP.smartPlan or not HP.state or HP.smartPlan.firstIndex~=HP.state.index or #HP.smartPlan.points==0 or HP.db.hidden or HP.db.paused or HP.db.hideRouteLines or HP.db.hideMinimapTrail or HP.demo or not Minimap or not Minimap:IsShown() or not HP.waypoint then return end
 if HP.trailMini then HP.trailMini:Hide() end
 if not f then f=CreateFrame('Frame',nil,Minimap);HP.smartTrailMini=f;f:SetAllPoints(Minimap);f:SetFrameLevel(Minimap:GetFrameLevel()+20);f:EnableMouse(false);f.dots={} end
 local radius=HP.Call(C_Minimap and C_Minimap.GetViewRadius)
 if type(radius)~='number' or radius<=0 then
  local z=HP.Call(Minimap.GetZoom,Minimap) or 0
  local outdoor={233.333,200,166.667,133.333,100,66.667};local indoor={150,120,90,60,40,25}
  radius=((tonumber(HP.Call(GetCVar,'minimapZoom'))==z and outdoor or indoor)[z+1] or 233.333)
 end
 local w,h=Minimap:GetWidth(),Minimap:GetHeight();local angle=HP.Call(GetCVar,'rotateMinimap')=='1' and (HP.Call(GetPlayerFacing) or 0) or 0
 local offset=HP.db.staticRouteTrail and 0 or ((HP.Call(GetTime) or 0)*24)%16
 local previous,count=nil,0
 for _,point in ipairs(HP.TrailPoints()) do
  local dx,dy=HP.NavigationVector(point)
  if dx and dy then
   local x=(dx*math.cos(angle)+dy*math.sin(angle))/radius*w/2
   local y=(dy*math.cos(angle)-dx*math.sin(angle))/radius*h/2
   if previous then local ax,ay,bx,by=clip(previous[1],previous[2],x,y,math.min(w,h)*.47)
    if ax then local length=math.sqrt((bx-ax)^2+(by-ay)^2)
     for d=offset,length,16 do if count>=160 then break end;count=count+1
      local dot=f.dots[count];if not dot then dot=f:CreateTexture(nil,'OVERLAY');dot:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\Circle');f.dots[count]=dot end
      local t=length>0 and d/length or 0;dot:ClearAllPoints();dot:SetPoint('CENTER',f,'TOPLEFT',w/2+ax+(bx-ax)*t,-h/2+ay+(by-ay)*t);dot:SetSize(4,4);dot:SetVertexColor(1,.94,.30,1);dot:Show()
     end
    end
   end
   previous={x,y}
  else previous=nil end
 end
 f:Show()
end
