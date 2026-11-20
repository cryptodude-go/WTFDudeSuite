local _WTF=assert(_G.WTFDudeSuiteRuntime)
_WTF.Defer(30,'automation',function(...)
-- Class-aware weighted gear comparisons for Forever. Scores are estimates, not simulated DPS.
local _,HP=...
local D=HP.Native;local R,C,UI,Cfg=D.Rewards,D.Compat,D.UI,D.Config
local G={overlays={},revision=0};HP.GearScore=G
local EXTRA={AP={'ITEM_MOD_ATTACK_POWER_SHORT'},RAP={'ITEM_MOD_RANGED_ATTACK_POWER_SHORT'},SP={'ITEM_MOD_SPELL_POWER_SHORT','ITEM_MOD_SPELL_DAMAGE_DONE_SHORT'},HEAL={'ITEM_MOD_SPELL_HEALING_DONE_SHORT'},CRIT={'ITEM_MOD_CRIT_RATING_SHORT'},HIT={'ITEM_MOD_HIT_RATING_SHORT'},MP5={'ITEM_MOD_MANA_REGENERATION_SHORT'},DEF={'ITEM_MOD_DEFENSE_SKILL_RATING_SHORT'},DODGE={'ITEM_MOD_DODGE_RATING_SHORT'}}
local ROLES={
 melee={STR=1.5,AGI=2,STA=1,INT=0,SPI=.1,ARMOR=.01,DPS=3,RANGED=0,AP=.5,CRIT=1.5,HIT=2},
 ranged={STR=0,AGI=2,STA=1,INT=.5,SPI=.1,ARMOR=.01,DPS=.2,RANGED=3,RAP=.5,CRIT=1.5,HIT=2},
 caster={STR=0,AGI=0,STA=1,INT=2,SPI=.7,ARMOR=.005,DPS=0,RANGED=.5,SP=1,CRIT=1,HIT=2},
 healer={STR=0,AGI=0,STA=1,INT=1.7,SPI=2,ARMOR=.005,DPS=0,RANGED=0,HEAL=1,SP=.6,MP5=2},
 tank={STR=1,AGI=1,STA=2.5,INT=0,SPI=0,ARMOR=.05,DPS=1,RANGED=0,DEF=2,DODGE=1.5},
}
local LABELS={STR='Strength',AGI='Agility',STA='Stamina',INT='Intellect',SPI='Spirit',ARMOR='Armor',DPS='Melee weapon DPS',RANGED='Ranged weapon DPS',AP='Attack power',RAP='Ranged attack power',SP='Spell power',HEAL='Healing power',CRIT='Critical rating',HIT='Hit rating',MP5='Mana per 5 sec',DEF='Defense rating',DODGE='Dodge rating'}
local ORDER={'STR','AGI','STA','INT','SPI','ARMOR','DPS','RANGED','AP','RAP','SP','HEAL','CRIT','HIT','MP5','DEF','DODGE'}
local DB_DEFAULTS={enabled=true,tooltips=true,bags=true,loot=true,rewards=true,profile='class',threshold=1}
function G:DB()
 if not D.db then return end
 D.db.ui.gearScore=D.db.ui.gearScore or {}
 local db=D.db.ui.gearScore
 for key,v in pairs(DB_DEFAULTS)do if db[key]==nil then db[key]=v end end
 db.weights=db.weights or {};return db
end
function G:Enabled()local db=self:DB();return db and db.enabled and (not HP.Suite or HP.Suite:On('gear'))end
function G:ProfileKey()return (C.PlayerClass()or 'WARRIOR')..':'..self:DB().profile end
function G:Base()
 local db=self:DB();local base=ROLES[db.profile]or R.CLASS_WEIGHTS[C.PlayerClass()]or R.CLASS_WEIGHTS.WARRIOR
 if C.PlayerClass()=='DRUID' and (db.profile=='melee' or db.profile=='tank')then
  local adjusted={};for k,v in pairs(base)do adjusted[k]=v end;base=adjusted;base.DPS=0;base.AP=1
 end
 local weights={};for _,k in ipairs(ORDER)do weights[k]=base[k]or 0 end
 if db.profile=='class' then
  local cls=C.PlayerClass();local magic=cls=='MAGE'or cls=='WARLOCK'or cls=='PRIEST'
  weights.AP=magic and 0 or .4;weights.RAP=cls=='HUNTER'and .5 or 0
  weights.SP=magic and 1 or (cls=='DRUID'or cls=='SHAMAN'or cls=='PALADIN')and .4 or 0
  weights.HEAL=cls=='PRIEST'and .6 or 0
 end
 return weights
end
function G:Weights()
 local weights=self:Base();local custom=self:DB().weights[self:ProfileKey()]or {}
 for k,v in pairs(custom)do if type(v)=='number'and v==v and v>=0 and v<=10 then weights[k]=v end end
 return weights
end
local score=R.Score
function R:Score(link,slot)
 local value=score(self,link,slot)
 if not G:Enabled()or not link then return value end
 local stats=C.ItemStats(link);local weights=G:Weights()
 for k,keys in pairs(EXTRA)do
  local amount=0;for _,stat in ipairs(keys)do amount=math.max(amount,stats[stat]or 0)end
  value=value+amount*(weights[k]or 0)
 end
 return value
end
local function id(link)return type(link)=='string'and tonumber(link:match('item:(%d+)'))end
function G:Evaluate(link)
 if not self:Enabled()or type(link)~='string'then return end
 local info=C.ItemInfo(link)
 if not info or not R.SLOTS[info.equipLoc] or not D.Gear:CanWear(link,info)then return end
 local stats=C.ItemStats(link);if not next(stats)then return end -- no loaded/scorable stats: never guess
 if info.equipLoc=='INVTYPE_WEAPONOFFHAND' or info.equipLoc=='INVTYPE_SHIELD' or info.equipLoc=='INVTYPE_HOLDABLE' then
  local main=C.EquippedLink(16);local mainInfo=main and C.ItemInfo(main)
  if mainInfo and mainInfo.equipLoc=='INVTYPE_2HWEAPON' then return end
 end
 if info.equipLoc=='INVTYPE_2HWEAPON' then
  for _,slot in ipairs({16,17})do local worn=C.EquippedLink(slot);if worn and not next(C.ItemStats(worn))then return end end
 end
 local comparison=R:Compare(link,info.equipLoc);if not comparison then return end
 for _,slot in ipairs(R.SLOTS[info.equipLoc])do
  local worn=C.EquippedLink(slot)
  if worn and id(worn)and id(worn)==id(link)then
   comparison.before=R:Score(worn,slot);comparison.after=R:Score(link,slot)
   comparison.gain=comparison.after-comparison.before;comparison.slot=slot;comparison.replaced=worn;break
  end
 end
 if comparison.replaced and not next(C.ItemStats(comparison.replaced))then return end
 comparison.percent=comparison.before>0 and comparison.gain/comparison.before*100 or nil
 comparison.upgrade=comparison.gain>=D.Gear.MIN_GAIN and (not comparison.percent or comparison.percent>=self:DB().threshold)
 comparison.link=link;comparison.profile=self:DB().profile
 return comparison
end
function G:Summary(cmp)
 if not cmp then return ''end
 local change=cmp.percent and string.format('%+.1f%%',cmp.percent)or (not cmp.replaced and 'empty slot' or string.format('%+.1f points',cmp.gain))
 return string.format('Score %.1f → %.1f%s',cmp.before,cmp.after,change~=''and (' · '..change)or '')
end
function G:Tooltip(tooltip,link)
 if not self:Enabled()or not self:DB().tooltips or self.busy then return end
 self.busy=true
 local ok,err=pcall(function()
  if not link and type(tooltip.GetItem)=='function'then local _,found=tooltip:GetItem();link=found end
  local cmp=self:Evaluate(link);if not cmp then return end
  local signature=link..':'..self.revision..':'..self:ProfileKey()
  if tooltip.dudeSuiteScore==signature then return end
  tooltip.dudeSuiteScore=signature
  tooltip:AddLine('WTF! DUDE SUITE · '..self:DB().profile..' score',1,.82,.2)
  tooltip:AddLine(self:Summary(cmp),cmp.upgrade and .25 or .78,cmp.upgrade and 1 or .78,.45,true)
  tooltip:AddLine(cmp.upgrade and 'Upgrade for the selected profile' or 'No clear upgrade for the selected profile',.75,.75,.7,true)
  tooltip:Show()
 end)
 self.busy=false;if not ok then self.lastError=tostring(err)end
end
function G:Paint(button,link,enabled)
 if not button then return end
 local overlay=self.overlays[button]
 if not enabled or not self:Enabled()or not button:IsShown()then if overlay then overlay:Hide()end;return end
 local cmp=self:Evaluate(link)
 if not cmp or not cmp.upgrade then if overlay then overlay:Hide()end;return end
 if not overlay then
  overlay=CreateFrame('Frame',nil,button);self.overlays[button]=overlay;overlay:SetAllPoints(button);overlay:EnableMouse(false)
  overlay:SetFrameLevel(button:GetFrameLevel()+5)
  overlay.arrow=overlay:CreateTexture(nil,'ARTWORK');overlay.arrow:SetTexture('Interface\\Buttons\\Arrow-Up-Up');overlay.arrow:SetSize(12,12);overlay.arrow:SetPoint('BOTTOMLEFT',0,1);overlay.arrow:SetVertexColor(.25,1,.3)
  overlay.text=UI.Text(overlay,'semibold',10,{.25,1,.3,1});overlay.text:SetPoint('BOTTOMLEFT',11,2)
  overlay.text:SetShadowOffset(1,-1)
 end
 overlay.text:SetText(string.format('%.0f',cmp.after));overlay:Show()
end
function G:OverlaySignature()
 local parts={tostring(self:Enabled()),tostring(self.revision)}
 for _,name in ipairs({'LootFrame','QuestFrame','ContainerFrameCombinedBags'})do local f=_G[name];parts[#parts+1]=f and f:IsShown()and name or ''end
 for i=1,13 do local f=_G['ContainerFrame'..i];parts[#parts+1]=f and f:IsShown()and tostring(HP.Call(f.GetID,f)or i)or ''end
 for i=1,16 do local f=_G['GroupLootFrame'..i];parts[#parts+1]=f and f:IsShown()and tostring(f.rollID or i)or ''end
 return table.concat(parts,':')
end
function G:RefreshOverlays()
 self.overlaySignature=self:OverlaySignature();self.dirty=false
 for _,overlay in pairs(self.overlays)do overlay:Hide()end
 if not self:Enabled()then return end
 local db=self:DB()
 if db.bags then
  for frameID=1,13 do
   local frame=_G['ContainerFrame'..frameID]
   if frame and frame:IsShown()then
    local bag=HP.Call(frame.GetID,frame)
    for buttonID=1,40 do
     local b=_G['ContainerFrame'..frameID..'Item'..buttonID]
     local slot=b and HP.Call(b.GetID,b)
     local item=type(bag)=='number'and type(slot)=='number'and C.BagItem(bag,slot)
     if b then self:Paint(b,item and item.link,true)end
    end
   end
  end
  local combined=ContainerFrameCombinedBags and ContainerFrameCombinedBags.Container
  if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() and combined and type(combined.EnumerateActive)=='function'then pcall(function()
   local count=0;for b in combined:EnumerateActive()do
    local bag=b.bagID or HP.Call(b.GetBagID,b);local slot=HP.Call(b.GetID,b)
    local item=type(bag)=='number'and type(slot)=='number'and C.BagItem(bag,slot)
    self:Paint(b,item and item.link,true);count=count+1;if count>300 then break end
   end
  end)end
 end
 if db.loot then
  for i=1,16 do
   local lootOpen=LootFrame and LootFrame:IsShown()
   if lootOpen then self:Paint(_G['LootButton'..i],HP.Call(GetLootSlotLink,i),true)end
   local roll=_G['GroupLootFrame'..i];local link=roll and roll:IsShown()and roll.rollID and HP.Call(GetLootRollItemLink,roll.rollID)
   self:Paint(roll and (roll.IconFrame or roll),link,true)
  end
 end
 if db.rewards and QuestFrame and QuestFrame:IsShown() then
  local count=HP.Call(GetNumQuestChoices)or 6
  for i=1,math.min(count,6)do
   local link=HP.Call(GetQuestItemLink,'choice',i)
   for _,prefix in ipairs({'QuestInfoRewardsFrameQuestInfoItem','QuestInfoItem','QuestRewardItem'})do self:Paint(_G[prefix..i],link,true)end
  end
 end
end
function G:Changed()
 self.revision=self.revision+1
 for _,tooltip in ipairs({GameTooltip,ItemRefTooltip})do if tooltip then tooltip.dudeSuiteScore=nil end end
 self:RefreshOverlays();D.Gear:Update();D.Panel:Update()
end
-- Reuse the existing actionable upgrade hint, adding score without changing equip behavior.
local show=D.GearHint.Show
function D.GearHint:Show(upgrade,seconds)
 show(self,upgrade,seconds)
 local cmp=G:Evaluate(upgrade.link)
 if cmp and self.banner then self.banner.text:SetText(D.L.GEAR_UPGRADE:format(upgrade.link)..'\n'..G:Summary(cmp));self.banner:SetHeight(math.max(44,self.banner.text:GetStringHeight()+16))end
end
local page={key='suite-gear-score',title='Gear upgrades & score'};HP.nativeGearScorePage=page
page.build=function(canvas,width)
 local db=G:DB();local rows={UI.CheckRow(canvas,Cfg,{label='Enable gear score',default=true,get=function()return db.enabled end,set=function(v)db.enabled=v;G:Changed()end},width),
 UI.InfoRow(canvas,'Class-safe weighted comparison against your equipped item. Choose a role for your build. These are leveling estimates; procs, set bonuses and special effects are not simulated.',width),
 UI.SelectorRow(canvas,Cfg,{label='Scoring profile',default='class',values={{'class','Class leveling'},{'melee','Melee DPS'},{'ranged','Ranged DPS'},{'caster','Caster DPS'},{'healer','Healer'},{'tank','Tank'}},get=function()return db.profile end,set=function(v)db.profile=v;G:Changed();Cfg:OpenPage(page)end},width)}
 for _,entry in ipairs({{'tooltips','Show score and upgrade % in tooltips'},{'bags','Upgrade score on bag items'},{'loot','Upgrade score on loot and rolls'},{'rewards','Upgrade score on quest rewards'}})do
  local k,label=entry[1],entry[2]
  rows[#rows+1]=UI.CheckRow(canvas,Cfg,{label=label,default=true,get=function()return db[k]end,set=function(v)db[k]=v;G:Changed()end},width)
 end
 rows[#rows+1]=UI.SliderRow(canvas,Cfg,{label='Minimum upgrade',min=0,max=10,step=.5,default=1,format=function(v)return v..' %'end,get=function()return db.threshold end,set=function(v)db.threshold=v;G:Changed()end},width)
 rows[#rows+1]=UI.HeaderRow(canvas,'Stat weights · '..C.PlayerClass()..' / '..db.profile,width)
 for _,key in ipairs(ORDER)do
  local k=key
  rows[#rows+1]=UI.SliderRow(canvas,Cfg,{label=LABELS[k],min=0,max=5,step=k=='ARMOR'and .005 or .1,default=function()return G:Base()[k]end,
  format=function(v)return string.format('%.3g',v)end,get=function()return G:Weights()[k]or 0 end,set=function(v)
   local profile=G:ProfileKey();db.weights[profile]=db.weights[profile]or {};db.weights[profile][k]=v;G:Changed()
  end},width)
 end
 rows[#rows+1]=UI.ButtonRow(canvas,Cfg,{label='Reset current profile weights',button='Reset',run=function()db.weights[G:ProfileKey()]=nil;G:Changed();Cfg:RefreshRows()end},width)
 return rows
end
local build=Cfg.TABS[Cfg.TAB.automation].build
Cfg.TABS[Cfg.TAB.automation].build=function(canvas,width)
 local rows=build(canvas,width)
 table.insert(rows,2,UI.PageRow(canvas,Cfg,{label='Gear upgrades & score',desc='Profiles, stat weights, tooltip scores and upgrade indicators.',open=function()Cfg:OpenPage(page)end},width))
 return rows
end
D:On('PLAYER_LOGIN',function()
 G:DB()
 local function cleared(t)t.dudeSuiteScore=nil end
 local modern=TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item
 if modern then
  local ok=pcall(TooltipDataProcessor.AddTooltipPostCall,Enum.TooltipDataType.Item,function(t,data)if t==GameTooltip or t==ItemRefTooltip then G:Tooltip(t,data and data.hyperlink)end end)
  if not ok then modern=nil end
 end
 for _,t in ipairs({GameTooltip,ItemRefTooltip})do if t and t.HookScript then
  pcall(t.HookScript,t,'OnTooltipCleared',cleared)
  if not modern then pcall(t.HookScript,t,'OnTooltipSetItem',function(tooltip)G:Tooltip(tooltip)end)end
 end end
end)
for _,event in ipairs({'PLAYER_EQUIPMENT_CHANGED','BAG_UPDATE_DELAYED','GET_ITEM_INFO_RECEIVED','QUEST_COMPLETE','LOOT_OPENED','LOOT_CLOSED','START_LOOT_ROLL','LOOT_SLOT_CLEARED','CANCEL_LOOT_ROLL','QUEST_ITEM_UPDATE'})do D:On(event,function()G.revision=G.revision+1;G.dirty=true end)end
local driver=CreateFrame('Frame');G.driver=driver;local elapsed=0
 driver:SetScript('OnUpdate',function(_,dt)
 elapsed=elapsed+dt;if elapsed<.75 then return end;elapsed=0
 if D.db and (G.dirty or G.overlaySignature~=G:OverlaySignature())then D:Safe(G.RefreshOverlays,G)end
end)

local gain=R.Gain
function R:Gain(link,equipLoc)
 if not G:Enabled()then return gain(self,link,equipLoc)end
 local cmp=G:Evaluate(link)
 if cmp then return cmp.upgrade and cmp.gain or 0,cmp.slot end
end
local refreshSuite=HP.Suite.Refresh
function HP.Suite:Refresh(...)
 local result=refreshSuite(self,...);G:RefreshOverlays();return result
end
local command=SlashCmdList.WTFDUDESUITE
SlashCmdList.WTFDUDESUITE=function(input)
 if (input or ''):lower():match('^%s*gear%s*$')then Cfg:Open('automation');if Cfg.frame and Cfg.frame:IsShown()then Cfg:OpenPage(page)end;return end
 return command(input)
end

end)
