local _,HP=...
local function label(parent,size)
    local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',size);t:SetTextColor(.94,.9,.8);t:SetJustifyH('LEFT');return t
end
local function skin(frame,compact)
    frame:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',edgeFile='Interface\\DialogFrame\\UI-DialogBox-Gold-Border',tile=true,tileSize=32,edgeSize=compact and 8 or 16,insets={left=5,right=5,top=5,bottom=5}})
    frame:SetBackdropColor(.04,.07,.09,.94);frame:SetBackdropBorderColor(.78,.61,.25,1)
end
local function action(parent,name,caption,secure)
    local b=CreateFrame('Button',name,secure and UIParent or parent,secure and 'SecureActionButtonTemplate,BackdropTemplate' or 'BackdropTemplate')
    skin(b,true);b.fill=b:CreateTexture(nil,'BACKGROUND');b.fill:SetPoint('TOPLEFT',5,-5);b.fill:SetPoint('BOTTOMRIGHT',-5,5);b.fill:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight2');b.fill:SetVertexColor(.08,.22,.32,.8);b:SetFrameStrata('LOW');b:SetFrameLevel(parent:GetFrameLevel()+4);b:SetSize(82,27)
    b.label=label(b,10);b.label:SetAllPoints();b.label:SetJustifyH('CENTER');b.label:SetText(caption)
    b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
    if secure then b:RegisterForClicks('AnyUp','AnyDown');b:SetAttribute('useOnKeyDown',true) end
    b:SetScript('OnEnter',function(self) if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(self.tooltip or caption);GameTooltip:Show() end end)
    b:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end);return b
end
function HP.RewardSummary(id)
    local q=HP.questData[id] or {};local xp,money=q.xp,q.money;local live=false
    if id and HP.Call(C_QuestLog and C_QuestLog.GetSelectedQuest)==id then
        local x=HP.Call(GetQuestLogRewardXP,id);local m=HP.Call(GetQuestLogRewardMoney,id)
        if HP.Public(x) and type(x)=='number' then xp=x;live=true end;if HP.Public(m) and type(m)=='number' then money=m end
    end
    local prefix=live and '' or '~ '
    local x=type(xp)=='number' and prefix..xp..' XP' or 'XP: unknown'
    local cash='Gold: unknown'
    if type(money)=='number' then local n=math.abs(money);cash=(money<0 and 'Cost ' or prefix)..math.floor(n/10000)..'g '..math.floor(n%10000/100)..'s '..math.floor(n%100)..'c' end
    return x..'   |   '..cash
end
local function npcForStep(step)
    local kind,id,name=HP.StepEntity(step)
    if kind=='item' then local item=HP.itemData[id];id=item and item.mobs and item.mobs[1];kind=id and 'npc';name=id and HP.npcData[id] and HP.npcData[id].name end
    if kind=='npc' then return id,name end
end
function HP.UpdateModernPanel()
    local f=HP.frame;if not f or not f.rewards then return end
    local step=HP.route and HP.state and HP.route.steps[HP.state.index];local id=step and step.questID or HP.db.questID
    local xpValue=HP.Call(UnitXP,'player');local xpCap=HP.Call(UnitXPMax,'player');if not HP.auxiliaryActive and f.xpPercent and HP.Public(xpValue) and HP.Public(xpCap) and type(xpValue)=='number' and type(xpCap)=='number' and xpCap>0 then f.xpPercent:SetText(string.format('%.0f%%',math.max(0,math.min(100,xpValue/xpCap*100)))) end
    f.levelBadge:SetText(tostring(HP.character.level or 1));f.rewards:SetText(HP.RewardSummary(id))
    local xp,money=HP.RewardSummary(id):match('^(.-)%s+|%s+(.*)$')
    if f.rewardXP then f.rewardXP.label:SetText(xp or 'XP: unknown');f.rewardMoney.label:SetText(money or 'Gold: unknown') end
    local loc=step and HP.StepLocation(step);local auto=HP.db.autoWaypoint~=false
    local assigned=auto and loc~=nil
    f.setWaypoint.label:SetTextColor(assigned and .3 or .8,assigned and 1 or .8,.35);f.setWaypoint:SetBackdropBorderColor(assigned and .25 or .78,assigned and .85 or .61,assigned and .35 or .25,1)
    f.setWaypoint.tooltip=auto and (loc and 'Auto waypoint is enabled: current quest destination is set automatically.' or 'Auto waypoint is enabled; coordinates are not available for this step.') or 'Set the current quest waypoint manually.'
    local npcID,name=npcForStep(step);local npc=npcID and HP.npcData[npcID]
    local panel=f.npcPanel;if HP.Call(InCombatLockdown)~=true then panel:SetHeight(math.max(240,math.min(340,f:GetHeight()))) end
    if HP.db.hidden or HP.db.paused or HP.demo or HP.db.hideNPCPanel or not HP.previewHovered or not npcID then panel:Hide() else
        local npcID=HP.previewNPCID or npcID;local name=HP.previewNPCName or name;local npc=HP.npcData[npcID]
        panel:Show();panel.title:SetText(name or 'NPC '..npcID);panel.detail:SetText((npc and (npc.rank==1 or npc.rank==3) and 'Elite · ' or '')..'NPC '..npcID)
        if panel.npcID~=npcID then panel.npcID=npcID;panel.model:ClearModel();HP.Call(panel.model.SetCreature,panel.model,npcID) end
        local loot={};local seen={};local q=id and HP.questData[id]
        for _,goal in ipairs(q and q.goals or {}) do if goal.kind=='item' then
            local item=HP.itemData[goal.id];for _,source in ipairs(item and item.mobs or {}) do if source==npcID and not seen[goal.id] then loot[#loot+1]=(item.name or 'Item '..goal.id)..' (quest)';seen[goal.id]=true end end
        end end
        for _,itemID in ipairs(HP.db.observedLoot and HP.db.observedLoot[npcID] or {}) do if not seen[itemID] then loot[#loot+1]=(HP.Call(C_Item and C_Item.GetItemNameByID or GetItemInfo,itemID) or 'Item '..itemID)..' (observed)';seen[itemID]=true end;if #loot>=4 then break end end
        panel.loot:SetText(#loot>0 and 'Quest items / observed drops\n'..table.concat(loot,'\n',1,math.min(4,#loot)) or 'No indexed drops for this NPC.\nLoot details appear after observed drops.')
        local lootHeight=math.max(70,math.min(120,HP.Call(panel.loot.GetStringHeight,panel.loot) or 70));panel.loot:SetHeight(lootHeight);panel.model:SetPoint('BOTTOMRIGHT',-7,lootHeight+14)
    end
    if HP.Call(InCombatLockdown)==true then return end
    local w=(f:GetWidth()-42)/4;local scale=(HP.Call(f.GetEffectiveScale,f) or 1)/(HP.Call(UIParent.GetEffectiveScale,UIParent) or 1)
    for i,b in ipairs({f.setWaypoint,f.actionTarget,f.actionUse,f.skipStep}) do
        if b==f.actionTarget or b==f.actionUse then b:SetScale(scale) else b:SetScale(1) end
        b:ClearAllPoints();b:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',12+(i-1)*(w+6),18);b:SetSize(w,28)
        b.label:SetText((w<80 and ({'Waypoint','Target','Use','Skip'}) or ({'Set Waypoint','Target','Use Item','Skip Step'}))[i])
    end
    local navWidth=(f:GetWidth()-30)/2
    for i,b in ipairs({f.rewardXP,f.rewardMoney}) do b:SetWidth(navWidth);b:ClearAllPoints();b:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',12+(i-1)*(navWidth+6),86);b.label:SetWidth(navWidth-32) end
    for i,b in ipairs({f.previousStep,f.nextStep}) do b:ClearAllPoints();b:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',12+(i-1)*(navWidth+6),51);b:SetSize(navWidth,28) end
    local visible=not HP.db.hidden and not HP.db.paused and not HP.demo
    f.actionTarget:SetAttribute('type','macro');f.actionTarget:SetAttribute('macrotext',name and '/targetexact '..name:gsub('[\r\n]','')..(HP.db.markOnClick and '\n/tm [@target,harm,nodead] 8' or '') or nil)
    f.actionTarget.npcID=npcID;f.actionTarget.npcName=name
    f.actionTarget.tooltip=name and 'Target '..name or 'No NPC target for this step.';f.actionTarget.label:SetTextColor(name and 1 or .4,name and .85 or .4,.35)
    local useID=step and step.useItemID
    if not useID then for _,item in ipairs(HP.QuestUseItems()) do if item.questID==id then useID=item.itemID;break end end end
    f.actionUse:SetAttribute('type','item');f.actionUse:SetAttribute('item',useID and 'item:'..useID or nil)
    f.actionUse.tooltip=useID and 'Use '..(HP.itemData[useID] and HP.itemData[useID].name or 'quest item') or 'No quest-use item for this step.'
    f.actionUse.label:SetTextColor(useID and 1 or .4,useID and .85 or .4,.35)
    if visible then f.actionTarget:Show();f.actionUse:Show() else f.actionTarget:Hide();f.actionUse:Hide() end
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local f=HP.frame;HP.guideFooterHeight=134;HP.guideHeaderHeight=88;HP.bodyFontSize=11;HP.tipFontSize=10;skin(f);f.originalClose:Hide();f.closeNative=CreateFrame('Button',nil,f,'UIPanelCloseButton');f.closeNative:SetSize(22,22);f.closeNative:SetPoint('TOPRIGHT',-4,-4);f.closeNative:SetScript('OnClick',function() HP.db.hidden=true;HP.Refresh() end);f.progress:SetStatusBarColor(.08,.63,.94)
    if not HP.db.modernUI0100 then HP.db.hideMinimapNumbers=true;HP.db.modernUI0100=true end
    if HP.db.autoWaypoint==nil then HP.db.autoWaypoint=true end
    f.portrait=f:CreateTexture(nil,'ARTWORK');f.portrait:SetSize(48,48);f.portrait:SetPoint('TOPLEFT',12,-10)
    if SetPortraitTexture then SetPortraitTexture(f.portrait,'player') else f.portrait:SetTexture('Interface\\CharacterFrame\\TemporaryPortrait') end
    f.levelBadge=label(f,13);f.levelBadge:SetPoint('TOPLEFT',48,-46);f.levelBadge:SetTextColor(1,.84,.25)
    f.header:ClearAllPoints();f.header:SetPoint('TOPLEFT',70,-11);f.header:SetFont('Fonts\\FRIZQT__.TTF',10);f.horde:Hide()
    f.tab:ClearAllPoints();f.previous:ClearAllPoints();f.previous:SetPoint('TOPLEFT',57,-29);f.tab:SetPoint('TOPLEFT',91,-35);f.tab:SetFont('Fonts\\FRIZQT__.TTF',14);f.tab:SetTextColor(1,.83,.2);f.tab:SetPoint('TOPRIGHT',-102,-34)
    f.note:Hide();f.scroll:SetPoint('TOPLEFT',f,'TOPLEFT',5,-88);f.scroll:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-5,134)
    f.progress:ClearAllPoints();f.progress:SetPoint('TOPLEFT',f,'TOPLEFT',70,-76);f.progress:SetPoint('TOPRIGHT',f,'TOPRIGHT',-50,-76);f.progress:SetHeight(4)
    f.xpPercent=label(f,10);f.xpPercent:SetPoint('TOPRIGHT',-14,-71)
    f.rewards=label(f,10);f.rewards:SetPoint('BOTTOMLEFT',18,86);f.rewards:SetPoint('BOTTOMRIGHT',-18,86);f.rewards:SetHeight(22)
    f.rewards:Hide()
    for i,field in ipairs({'rewardXP','rewardMoney'}) do
        local box=CreateFrame('Frame',nil,f,'BackdropTemplate');f[field]=box;skin(box,true);box:SetHeight(24)
        box.icon=box:CreateTexture(nil,'ARTWORK');box.icon:SetSize(14,14);box.icon:SetPoint('LEFT',7,0);box.icon:SetTexture(i==1 and 'Interface\\Icons\\XP_Icon' or 'Interface\\MoneyFrame\\UI-GoldIcon')
        box.label=label(box,10);box.label:SetPoint('LEFT',26,0)
    end
    f.rewardHeading=label(f,10);f.rewardHeading:SetPoint('BOTTOMLEFT',16,111);f.rewardHeading:SetText('REWARDS')
    f.previousStep=action(f,nil,'<  Previous');f.previousStep:SetScript('OnClick',function() HP.Move(-1) end)
    f.nextStep=action(f,nil,'Next Step  >');f.nextStep:SetScript('OnClick',function() HP.Move(1) end)
    f.setWaypoint=action(f,nil,'Set Waypoint');f.setWaypoint:SetScript('OnClick',function()
        if HP.db.autoWaypoint~=false then HP.manualWaypoint=nil;HP.manualWaypointQuestID=nil;HP.Refresh();return end
        local step=HP.route and HP.state and HP.route.steps[HP.state.index];local loc=step and HP.StepLocation(step)
        if loc then HP.manualWaypoint=loc;HP.manualWaypointQuestID=step.questID;HP.waypoint=loc;HP.UpdateArrow();HP.UpdateMapPins() end
    end)
    f.actionTarget=action(f,'DudeDingActionTarget','Target',true);f.actionUse=action(f,'DudeDingActionUse','Use Item',true)
    f.skipStep=action(f,nil,'Skip Step');f.skipStep:SetScript('OnClick',function()
        if HP.abandonQuest then HP.Move(1);return end
        if HP.state then HP.state.skipped[HP.state.index]=true;local step=HP.route.steps[HP.state.index];if HP.db.guideStyle=='normal' and step.questID then HP.normalDeferred=HP.normalDeferred or {};HP.normalDeferred[step.questID]=true end;HP.normalQuestFocus=nil;HP.review=false;HP.state.index=HP.NextStep(HP.route,HP.state.index+1,HP.state.skipped);HP.Refresh() end
    end)
    for i,b in ipairs({f.setWaypoint,f.actionTarget,f.actionUse,f.skipStep}) do
        b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(13,13);b.icon:SetPoint('LEFT',7,0)
        b.icon:SetTexture(({'Interface\\Icons\\INV_Misc_Map_01','Interface\\Icons\\Ability_Hunter_SniperShot','Interface\\Icons\\INV_Misc_Bag_10','Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up'})[i])
        b.label:ClearAllPoints();b.label:SetPoint('LEFT',23,0);b.label:SetPoint('RIGHT',-4,0);b.label:SetFont('Fonts\\FRIZQT__.TTF',9);b.label:SetWordWrap(false)
    end
    f.actionTarget:SetScript('OnEnter',function(self) HP.ShowNPCPreview(self.npcID,self.npcName) end)
    f.actionTarget:SetScript('OnLeave',function() HP.HideNPCPreview();if GameTooltip then GameTooltip:Hide() end end)
    for _,b in ipairs(f.targetButtons) do b:SetScript('OnEnter',function(self) HP.ShowNPCPreview(self.npcID,self.npcName) end);b:SetScript('OnLeave',function() HP.HideNPCPreview() end) end
    local panel=CreateFrame('Frame','DudeDingNPCPanel',f,'BackdropTemplate');f.npcPanel=panel;skin(panel);panel:SetWidth(172);panel:SetPoint('TOPLEFT',f,'TOPRIGHT',7,0)
    panel.title=label(panel,13);panel.title:SetPoint('TOPLEFT',11,-12);panel.title:SetWidth(150);panel.title:SetHeight(30)
    panel.detail=label(panel,10);panel.detail:SetPoint('TOPLEFT',11,-42)
    panel.model=CreateFrame('PlayerModel',nil,panel);panel.model:SetPoint('TOPLEFT',7,-62);panel.model:SetPoint('BOTTOMRIGHT',-7,84);panel.model:EnableMouse(false)
    panel.loot=label(panel,10);panel.loot:SetPoint('BOTTOMLEFT',10,10);panel.loot:SetWidth(152);panel.loot:SetHeight(70)
    local options=HP.settings;skin(options)
    options.autoWaypoint=action(options.content,nil,'Automatic waypoint: ON');options.autoWaypoint:SetWidth(510);table.insert(options.controls,options.autoWaypoint)
    options.autoWaypoint:SetScript('OnClick',function() HP.db.autoWaypoint=HP.db.autoWaypoint==false;HP.manualWaypoint=nil;HP.manualWaypointQuestID=nil;options.autoWaypoint.label:SetText('Automatic waypoint: '..(HP.db.autoWaypoint and 'ON' or 'OFF'));HP.Refresh() end)
    options.previewToggle=action(options.content,nil,'Target-hover preview: ON');options.previewToggle:SetWidth(510);table.insert(options.controls,options.previewToggle)
    options.previewToggle:SetScript('OnClick',function() HP.db.hideNPCPanel=not HP.db.hideNPCPanel;options.previewToggle.label:SetText('Target-hover preview: '..(HP.db.hideNPCPanel and 'OFF' or 'ON'));HP.Refresh() end)
    options.autoWaypoint.label:SetText('Automatic waypoint: '..(HP.db.autoWaypoint and 'ON' or 'OFF'));options.previewToggle.label:SetText('Target-hover preview: '..(HP.db.hideNPCPanel and 'OFF' or 'ON'));options.autoWaypoint:Hide();options.previewToggle:Hide()
    local events=CreateFrame('Frame',nil,f);HP.lootEvents=events;pcall(events.RegisterEvent,events,'LOOT_OPENED')
    events:SetScript('OnEvent',function()
        HP.db.observedLoot=HP.db.observedLoot or {};local total=0;for _ in pairs(HP.db.observedLoot) do total=total+1 end
        for slot=1,(HP.Call(GetNumLootItems) or 0) do
            local guid=HP.Call(GetLootSourceInfo,slot);local npcID=type(guid)=='string' and tonumber(guid:match('^[^-]+%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)'))
            local link=HP.Call(GetLootSlotLink,slot);local itemID=type(link)=='string' and tonumber(link:match('item:(%d+)'))
            if npcID and itemID and (HP.db.observedLoot[npcID] or total<100) then
                if not HP.db.observedLoot[npcID] then HP.db.observedLoot[npcID]={};total=total+1 end
                local list=HP.db.observedLoot[npcID];local found=false;for _,id in ipairs(list) do if id==itemID then found=true end end
                if not found and #list<20 then list[#list+1]=itemID end
            end
        end
        HP.UpdateModernPanel()
    end)
end
local render=HP.RenderRows
function HP.RenderRows(...)
    render(...);if not HP.frame.rewards then return end
    HP.UpdateModernPanel()
end
local hide=HP.HideDetachedControls
function HP.HideDetachedControls()
    hide();local f=HP.frame;if not f.actionTarget then return end
    for _,b in ipairs({f.actionTarget,f.actionUse}) do
        if HP.db.hidden or HP.db.paused or HP.demo then if HP.Call(InCombatLockdown)~=true then b:Hide() end;b.label:Hide() else b.label:Show() end
    end
end

local tooltip=HP.ShowRowTooltip
function HP.ShowRowTooltip(row)
    tooltip(row);HP.frame.model:Hide()
end

function HP.ShowNPCPreview(id,name)
    if not id or HP.db.hideNPCPanel then return end
    HP.previewHovered=true;HP.previewNPCID=id;HP.previewNPCName=name;HP.UpdateModernPanel()
end
function HP.HideNPCPreview()
    HP.previewHovered=nil;HP.previewNPCID=nil;HP.previewNPCName=nil
    if HP.frame and HP.frame.npcPanel then HP.frame.npcPanel:Hide() end
end

function HP.ModernCardTitle(step)
    if not step then return 'Current step' end
    local phase=HP.QuestStepPhase(step);local name=step.questID and HP.QuestName(step.questID)
    if phase.action=='level' then return 'Reach level '..(phase.targetLevel or '') end
    if phase.action=='buy' then local item=HP.itemData[phase.itemID];return 'Buy '..(item and item.name or 'supplies') end
    if phase.action=='accept' then return 'Accept · '..name end
    if phase.action=='turnin' then return 'Turn in · '..name end
    if step.questID==5441 then return 'Wake Lazy Peons' end
    local kind,id,entity=HP.StepEntity(step)
    if kind=='npc' then return 'Kill '..(entity or 'quest target') end
    if kind=='item' then return 'Collect '..(entity or 'quest items') end
    return name or 'Current step'
end
