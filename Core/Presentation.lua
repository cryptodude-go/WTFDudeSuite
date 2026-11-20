-- Player-facing title, portrait/level badge and announcement controls.
local _,HP=...
local D=HP.Native
local P,C,UI=D.Panel,D.Config,D.UI
local function updatePortrait()
 local f=P.frame;if not f or not HP.db then return end
 local a=f.racePortrait
 if not a then
  a=CreateFrame('Frame',nil,f);f.racePortrait=a
  a:SetSize(56,56);a:SetPoint('TOPRIGHT',f,'TOPLEFT',-5,4)
  a:EnableMouse(true);a:RegisterForDrag('LeftButton')
  a:SetScript('OnDragStart',function()f.dudePortraitDragging=true;local fn=f:GetScript('OnDragStart');if fn then fn(f)end end)
  a:SetScript('OnDragStop',function()f.dudePortraitDragging=nil;local fn=f:GetScript('OnDragStop');if fn then fn(f)end end)
  a.image=a:CreateTexture(nil,'ARTWORK');a.image:SetSize(46,46);a.image:SetPoint('CENTER')
  if a.CreateMaskTexture and a.image.AddMaskTexture then
   local mask=HP.Call(a.CreateMaskTexture,a);if mask then mask:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\PortraitMask');mask:SetAllPoints(a.image);a.image:AddMaskTexture(mask)end
  end
  local ring=a:CreateTexture(nil,'OVERLAY');ring:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\PortraitRing');ring:SetAllPoints()
  local badge=CreateFrame('Frame',nil,a);a.badge=badge;badge:SetSize(25,25);badge:SetPoint('BOTTOMRIGHT',3,-3)
  local bg=badge:CreateTexture(nil,'BACKGROUND');bg:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\StepOrb');bg:SetAllPoints()
  local br=badge:CreateTexture(nil,'ARTWORK');br:SetTexture('Interface\\AddOns\\WTFDudeSuite\\Media\\PortraitRing');br:SetAllPoints()
  a.levelText=UI.Text(badge,'semibold',13,{1,.84,.24,1});a.levelText:SetPoint('CENTER');a.levelText:SetJustifyH('CENTER')
 end
 -- Coordinates are converted to physical pixels before choosing the free side.
 local center=tonumber((HP.Call(f.GetCenter,f)))
 local screen=tonumber((HP.Call(UIParent.GetWidth,UIParent)))
 if center and screen and screen>0 then
  local scale=tonumber((HP.Call(f.GetEffectiveScale,f))) or 1
  local parentScale=tonumber((HP.Call(UIParent.GetEffectiveScale,UIParent))) or 1
  local side=center*scale<screen*parentScale*.5 and 'RIGHT' or 'LEFT'
  if a.dockSide~=side then
   a:ClearAllPoints();a.badge:ClearAllPoints()
   if side=='RIGHT' then a:SetPoint('TOPLEFT',f,'TOPRIGHT',5,4);a.badge:SetPoint('BOTTOMLEFT',-3,-3)
   else a:SetPoint('TOPRIGHT',f,'TOPLEFT',-5,4);a.badge:SetPoint('BOTTOMRIGHT',3,-3)end
   a.dockSide=side
  end
 end
 local _,race=HP.Call(UnitRace,'player');local female=HP.Call(UnitSex,'player')==3
 local atlas='raceicon128-'..(race=='Scourge' and 'undead' or tostring(race):lower())..'-'..(female and 'female' or 'male')
 if a.raceKey~=atlas then
  if HP.Call(C_Texture and C_Texture.GetAtlasInfo,atlas) and a.image.SetAtlas then a.image:SetAtlas(atlas)
  elseif SetPortraitTexture then HP.Call(SetPortraitTexture,a.image,'player')
  else a.image:SetTexture('Interface\\CharacterFrame\\TemporaryPortrait')end
  a.raceKey=atlas
 end
 local level=math.max(tonumber((HP.Call(UnitLevel,'player'))) or 1,HP.xpState and HP.xpState.level or 1)
 a.levelText:SetText(tostring(level));a:SetShown(D.db.panel.portrait~=false)
end
local update=P.Update
function P:Update(...)local result=update(self,...);updatePortrait();
 local f=self.frame;if f and not f.dudePortraitDragHook then
  f.dudePortraitDragHook=true
  f:HookScript('OnDragStart',function()f.dudePortraitDragging=true end)
  f:HookScript('OnDragStop',function()f.dudePortraitDragging=nil;updatePortrait()end)
  f:HookScript('OnHide',function()f.dudePortraitDragging=nil end)
 end
 return result end
HP.UpdateNativePortrait=updatePortrait
D:On('PLAYER_LEVEL_UP',function()updatePortrait()end)
D:On('UNIT_PORTRAIT_UPDATE',function(_,unit)if unit=='player' then if P.frame and P.frame.racePortrait then P.frame.racePortrait.raceKey=nil end;updatePortrait()end end)
local appearance=C.TABS[C.TAB.appearance or 6].build
C.TABS[C.TAB.appearance or 6].build=function(canvas,width)
 local rows=appearance(canvas,width)
 table.insert(rows,1,UI.CheckRow(canvas,C,{label='Show race portrait and level badge',default=true,
 get=function()return D.db.panel.portrait~=false end,set=function(v)D.db.panel.portrait=v;updatePortrait()end},width))
 return rows
end
-- Put announcements directly beside the automation controls; no hidden legacy panel.
local automate=C.TABS[C.TAB.automation or 3].build
C.TABS[C.TAB.automation or 3].build=function(canvas,width)
 local rows=automate(canvas,width)
 if HP.Suite then return rows end
 local extra=HP.nativeCommunityPage.build(canvas,width)
 for i=#extra,1,-1 do table.insert(rows,1,extra[i])end
 return rows
end

-- The portrait follows the window while it is dragged, rather than waiting for a quest event.
local portraitTicker=CreateFrame('Frame');local portraitElapsed=0
portraitTicker:SetScript('OnUpdate',function(_,elapsed)
 portraitElapsed=portraitElapsed+elapsed
 if portraitElapsed>=.15 then portraitElapsed=0;if P.frame and P.frame:IsShown() and P.frame.dudePortraitDragging then updatePortrait()end end
end)
