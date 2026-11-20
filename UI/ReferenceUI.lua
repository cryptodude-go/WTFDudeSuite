local _,HP=...
local MEDIA='Interface\\AddOns\\WTFDudeSuite\\Media\\'
local function text(parent,size,color)
    local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',size);t:SetTextColor(unpack(color or {.92,.92,.85}));return t
end
local function dark(frame)
    frame:SetBackdrop({bgFile='Interface\\DialogFrame\\UI-DialogBox-Background',tile=true,tileSize=32});frame:SetBackdropColor(.035,.075,.10,.97)
end
local function ornament(frame,size)
    frame.referenceOutline={}
    local function piece(coords,a,ax,ay,b,bx,by,width,height)
        local t=frame:CreateTexture(nil,'OVERLAY');t:SetTexture(MEDIA..'ReferenceBorder');t:SetTexCoord(unpack(coords));t:SetPoint(a,frame,a,ax,ay)
        if b then t:SetPoint(b,frame,b,bx,by) end
        if width then t:SetWidth(width) end;if height then t:SetHeight(height) end
        frame.referenceOutline[#frame.referenceOutline+1]=t
    end
    piece({0,.25,0,.25},'TOPLEFT',0,0,nil,nil,nil,size,size)
    piece({.75,1,0,.25},'TOPRIGHT',0,0,nil,nil,nil,size,size)
    piece({0,.25,.75,1},'BOTTOMLEFT',0,0,nil,nil,nil,size,size)
    piece({.75,1,.75,1},'BOTTOMRIGHT',0,0,nil,nil,nil,size,size)
    piece({.25,.75,0,.25},'TOPLEFT',size,0,'TOPRIGHT',-size,0,nil,size)
    piece({.25,.75,.75,1},'BOTTOMLEFT',size,0,'BOTTOMRIGHT',-size,0,nil,size)
    piece({0,.25,.25,.75},'TOPLEFT',0,-size,'BOTTOMLEFT',0,size,size,nil)
    piece({.75,1,.25,.75},'TOPRIGHT',0,-size,'BOTTOMRIGHT',0,size,size,nil)
end
local function round(frame,size)
    local ring=frame:CreateTexture(nil,'OVERLAY');ring:SetTexture(MEDIA..'PortraitRing');ring:SetAllPoints();frame.ring=ring
    local bg=frame:CreateTexture(nil,'BACKGROUND');bg:SetTexture(MEDIA..'StepOrb');bg:SetAllPoints()
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local f=HP.frame
    HP.guideHeaderHeight=104;HP.guideFooterHeight=134;HP.cardHeaderHeight=31;HP.cardTitleFontSize=14
    if not HP.db.referenceLayout0102 then HP.db.width=math.max(430,HP.db.width or 430);HP.db.referenceLayout0102=true end
    f:SetWidth(math.max(430,HP.db.width or 430));if f.SetResizeBounds then f:SetResizeBounds(430,240,850,950) end
    f:SetBackdrop(nil);f.zoneHeader:Hide();f.toolbar:Hide();f.header:Hide();f.portrait:Hide();f.levelBadge:Hide();f.tab:Hide();f.step:Hide();f.progress:Hide();f.xpPercent:Hide();f.menuToggle:Hide()
    local body=CreateFrame('Frame',nil,f,'BackdropTemplate');f.referenceBody=body;body:SetPoint('TOPLEFT',f,'TOPLEFT',5,-94);body:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-5,3);dark(body);ornament(body,15)
    f.scroll:SetParent(body);f.scroll:SetFrameLevel(body:GetFrameLevel()+2);f.content:SetFrameLevel(f.scroll:GetFrameLevel()+1)
    f.scroll:ClearAllPoints();f.scroll:SetPoint('TOPLEFT',body,'TOPLEFT',8,-10);f.scroll:SetPoint('BOTTOMRIGHT',body,'BOTTOMRIGHT',-8,131)
    local header=CreateFrame('Frame',nil,f,'BackdropTemplate');f.referenceHeaderFrame=header;header:SetPoint('TOPLEFT',f,'TOPLEFT',72,-22);header:SetPoint('TOPRIGHT',f,'TOPRIGHT',-5,-22);header:SetHeight(65);dark(header);ornament(header,14)
    f.levelRange=text(header,20,{1,.81,.23});f.levelRange:SetPoint('TOPLEFT',14,-14);f.levelRange:SetWidth(75);f.levelRange:SetJustifyH('LEFT')
    f.tab=text(header,15);f.tab:SetPoint('TOPLEFT',92,-17);f.tab:SetPoint('TOPRIGHT',-73,-17);f.tab:SetHeight(20);f.tab:SetWordWrap(false);f.tab:SetJustifyH('LEFT')
    local badge=CreateFrame('Frame',nil,f,'BackdropTemplate');f.referenceStepTab=badge;badge:SetSize(126,22);badge:SetPoint('TOPLEFT',f,'TOPLEFT',91,-2);dark(badge);ornament(badge,8)
    f.step=text(badge,11);f.step:SetPoint('CENTER',badge,'CENTER',0,0);f.step:SetWidth(118);f.step:SetJustifyH('CENTER')
    local avatar=CreateFrame('Frame',nil,f);f.referenceAvatar=avatar;avatar:SetSize(80,80);avatar:SetPoint('TOPLEFT',f,'TOPLEFT',4,-1);avatar:SetFrameLevel(header:GetFrameLevel()+4);round(avatar,80)
    f.portrait=avatar:CreateTexture(nil,'ARTWORK');f.portrait:SetSize(66,66);f.portrait:SetPoint('CENTER')
    local race=HP.character.race;local female=HP.Call(UnitSex,'player')==3;local column=({Tauren=0,Scourge=1,Troll=2,Orc=3})[race]
    local atlas='raceicon128-'..(race=='Scourge' and 'undead' or tostring(race):lower())..'-'..(female and 'female' or 'male')
    local atlasInfo=HP.Call(C_Texture and C_Texture.GetAtlasInfo,atlas)
    if type(atlasInfo)=='table' and type(f.portrait.SetAtlas)=='function' then f.portrait:SetAtlas(atlas)
    elseif column then
        f.portrait:SetTexture('Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races');local row=female and .75 or .25;f.portrait:SetTexCoord(column*.25,(column+1)*.25,row,row+.25)
    elseif SetPortraitTexture then SetPortraitTexture(f.portrait,'player') else
        local model=CreateFrame('PlayerModel',nil,avatar);model:SetPoint('TOPLEFT',7,-7);model:SetPoint('BOTTOMRIGHT',-7,7);HP.Call(model.SetUnit,model,'player');HP.Call(model.SetPortraitZoom,model,1);f.portraitModel=model
    end
    if type(avatar.CreateMaskTexture)=='function' and type(f.portrait.AddMaskTexture)=='function' then
        local mask=HP.Call(avatar.CreateMaskTexture,avatar);if mask then mask:SetTexture(MEDIA..'PortraitMask');mask:SetAllPoints(f.portrait);f.portrait:AddMaskTexture(mask) end
    end
    local level=CreateFrame('Frame',nil,avatar);f.referenceLevelMedallion=level;level:SetSize(31,31);level:SetPoint('BOTTOMRIGHT',3,-3);round(level,31)
    f.levelBadge=text(level,15,{1,.84,.24});f.levelBadge:SetPoint('CENTER');f.levelBadge:SetJustifyH('CENTER')
    f.progress=CreateFrame('StatusBar',nil,header);f.progress:SetPoint('BOTTOMLEFT',12,12);f.progress:SetPoint('BOTTOMRIGHT',-43,12);f.progress:SetHeight(6);f.progress:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar');f.progress:SetStatusBarColor(.08,.7,1)
    local track=f.progress:CreateTexture(nil,'BACKGROUND');track:SetAllPoints();track:SetTexture('Interface\\Buttons\\WHITE8X8');track:SetVertexColor(.08,.11,.14,1)
    f.xpPercent=text(header,9);f.xpPercent:SetPoint('BOTTOMRIGHT',-8,8)
    for i,b in ipairs({f.previous,f.next}) do
        b:SetParent(header);b:SetFrameLevel(header:GetFrameLevel()+2);b:ClearAllPoints();b:SetPoint('TOPRIGHT',header,'TOPRIGHT',i==1 and -39 or -8,-11);b:SetSize(27,27);b.label:Hide()
        b.arrow=b:CreateTexture(nil,'ARTWORK');b.arrow:SetAllPoints();b.arrow:SetTexture(i==1 and 'Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up' or 'Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up');ornament(b,8)
    end
    f.pause:ClearAllPoints();f.pause:SetPoint('TOPRIGHT',-27,-4);f.pause:SetSize(38,18);f.pause.label:SetFont('Fonts\\FRIZQT__.TTF',9)
    f.rescan:ClearAllPoints();f.rescan:SetPoint('TOPRIGHT',f,'TOPRIGHT',-69,-5);f.rescan:SetSize(14,14)
    f.closeNative:SetFrameLevel(header:GetFrameLevel()+5)
    local gear=CreateFrame('Button',nil,avatar);f.settingsGear=gear;gear:SetSize(18,18);gear:SetPoint('BOTTOMLEFT',1,-1);gear.icon=gear:CreateTexture(nil,'ARTWORK');gear.icon:SetAllPoints();gear.icon:SetTexture('Interface\\Icons\\Trade_Engineering');gear:SetScript('OnClick',HP.ToggleMenu)
    avatar:EnableMouse(true);avatar:RegisterForDrag('LeftButton');avatar:SetScript('OnDragStart',function() if HP.Call(InCombatLockdown)~=true then f:StartMoving() end end);avatar:SetScript('OnDragStop',function() f:StopMovingOrSizing();HP.AnchorGuideTop() end)
    avatar:SetScript('OnEnter',function(self) if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_LEFT');GameTooltip:SetText((HP.character.raceName or HP.character.race or '')..' '..(HP.character.className or HP.character.class or ''));GameTooltip:AddLine('Level '..(HP.character.level or 1));GameTooltip:Show() end end);avatar:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    for _,b in ipairs({f.rewardXP,f.rewardMoney,f.previousStep,f.nextStep,f.setWaypoint,f.skipStep}) do b:SetParent(body);dark(b);ornament(b,10) end
    for _,b in ipairs({f.actionTarget,f.actionUse}) do dark(b);ornament(b,10) end
    f.groupIcon=f.content:CreateTexture(nil,'ARTWORK');f.groupIcon:SetSize(21,21);f.groupIcon:SetPoint('TOPRIGHT',-137,-4);f.groupIcon:SetTexture('Interface\\Icons\\INV_Sword_04');f.groupIcon:Hide()
    f.groupNote=text(f.content,9,{.65,.73,.81});f.groupNote:SetPoint('TOPRIGHT',-12,-5);f.groupNote:SetWidth(116);f.groupNote:SetHeight(26);f.groupNote:SetJustifyH('LEFT');f.groupNote:Hide()
    f.rewardHeading:Hide();f.rewardHeading=text(body,10,{.60,.68,.76});f.rewardHeading:SetPoint('BOTTOMLEFT',13,108);f.rewardHeading:SetText('REWARDS / NEXT')
    f.previousStep.label:SetFont('Fonts\\FRIZQT__.TTF',12);f.nextStep.label:SetFont('Fonts\\FRIZQT__.TTF',12);f.nextStep.fill:SetVertexColor(.05,.50,.85,1)
    f.npcPanel:ClearAllPoints();f.npcPanel:SetPoint('TOPLEFT',f,'TOPRIGHT',6,-94);dark(f.npcPanel);ornament(f.npcPanel,15);f.npcPanel.title:SetFont('Fonts\\FRIZQT__.TTF',15);f.npcPanel.title:SetTextColor(1,.34,.24);f.npcPanel.detail:SetTextColor(1,.85,.2)
    f.setWaypoint.icon:SetTexture(MEDIA..'ActionPin');f.actionTarget.icon:SetTexture(MEDIA..'ActionTarget');f.skipStep.icon:SetTexture(MEDIA..'ActionSkip')
end
local update=HP.UpdateModernPanel
function HP.UpdateModernPanel()
    update();local f=HP.frame;if type(f.referenceHeaderFrame)~='table' and type(f.referenceHeaderFrame)~='userdata' then return end
    local route=HP.route;local current=f.cached and f.cached[4] or 1;local total=f.cached and f.cached[5] or 1
    f.step:SetText('Step '..current..' of '..total)
    f.levelRange:SetText(route and tostring(route.minLevel or 1)..' - '..tostring(route.maxLevel or 60) or '')
    f.tab:SetText(route and (route.zone or route.title:gsub('%s*%b()','')) or 'Quest log')
    f.levelBadge:SetText(tostring(HP.character.level or 1))
    local step=route and HP.state and route.steps[HP.state.index];local difficulty=step and HP.QuestDifficulty(step.questID)
    if difficulty=='group' or difficulty=='raid' then f.groupNote:SetText(difficulty=='raid' and 'Raid objective\nBring your raid group.' or 'Elite / group objective\nConsider bringing allies.');f.groupNote:Show();f.groupIcon:Show() else f.groupNote:Hide();f.groupIcon:Hide() end
    local panel=f.npcPanel;local npc=HP.npcData[panel.npcID]
    if npc then
        local unitLevel;local guid=HP.Call(UnitGUID,'target');local targetID=type(guid)=='string' and tonumber(guid:match('^[^-]+%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)'))
        if targetID==panel.npcID then unitLevel=HP.Call(UnitLevel,'target') end
        local level=type(unitLevel)=='number' and unitLevel>0 and tostring(unitLevel) or npc.minLevel and ('~ '..npc.minLevel..(npc.maxLevel~=npc.minLevel and ' - '..npc.maxLevel or ''))
        if level then panel.detail:SetText('Level '..level..(npc.rank==1 and ' · Elite' or ' · NPC')) end
    end
    if HP.Call(InCombatLockdown)~=true then
        local usable=f:GetWidth()-42;local weights={.32,.19,.27,.22};local x=12
        for i,b in ipairs({f.setWaypoint,f.actionTarget,f.actionUse,f.skipStep}) do
            b:ClearAllPoints();b:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',x,18);b:SetSize(usable*weights[i],29);x=x+usable*weights[i]+6
            b.label:SetText(({HP.db.autoWaypoint~=false and 'Auto Waypoint' or 'Set Waypoint','Target','Use Item','Skip Step'})[i]);b.label:SetFont('Fonts\\FRIZQT__.TTF',10)
        end
    end
    if HP.Call(InCombatLockdown)==true then return end
    for _,card in ipairs(f.cards or {}) do card:SetBackdrop(nil) end
    for _,row in ipairs(f.rows) do if row:IsShown() then
        row.bg:SetVertexColor(.02,.06,.08,0)
        if row.cardHeader then
            row.icon:SetTexture(MEDIA..'StepOrb');row.icon:ClearAllPoints();row.icon:SetPoint('TOPLEFT',9,-2);row.icon:SetSize(27,27);row.icon:Show()
            row.symbol:SetText('1');row.symbol:SetFont('Fonts\\FRIZQT__.TTF',11);row.symbol:SetTextColor(.9,.96,1);row.symbol:ClearAllPoints();row.symbol:SetPoint('TOPLEFT',13,-8);row.symbol:SetWidth(19);row.symbol:Show()
            row.text:ClearAllPoints();row.text:SetPoint('TOPLEFT',44,-6);row.text:SetWidth(f:GetWidth()-(difficulty and 220 or 90))
        else row.icon:SetSize(16,16) end
    end end
end

local transparency=HP.ApplyTransparency
function HP.ApplyTransparency()
    transparency();local f=HP.frame
    if f and (type(f.referenceBody)=='table' or type(f.referenceBody)=='userdata') then f.referenceBody:SetBackdropColor(.035,.075,.1,HP.db.transparent and .91 or .99);f.referenceHeaderFrame:SetBackdropColor(.035,.075,.1,HP.db.transparent and .94 or .99) end
end



function HP.CardHeaderWidth(step)
    return HP.frame:GetWidth()-(step and HP.QuestDifficulty(step.questID) and 220 or 90)
end

HP.ReferenceOrnament=ornament
HP.ReferenceDark=dark
