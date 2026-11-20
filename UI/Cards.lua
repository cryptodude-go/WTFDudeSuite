local _,HP=...
local WHITE='Interface\\Buttons\\WHITE8X8'
local function text(parent,size)
    local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Fonts\\FRIZQT__.TTF',size);t:SetTextColor(1,.83,.3);return t
end
function HP.StepEntity(step)
    if not step then return end
    step=HP.QuestStepPhase(step);local q=HP.questData[step.questID]
    if step.action=='buy' then local npc=HP.Vendor(step);return 'npc',step.vendorID,npc and npc.name end
    if not q then return end
    if step.action=='accept' or step.action=='turnin' then
        local id=step.action=='accept' and q.start or q.finish;local npc=HP.npcData[id]
        if npc then return 'npc',id,npc.name end
        local object=step.action=='accept' and q.startObject or q.finishObject
        if object and HP.objectData[object] then return 'object',object,HP.objectData[object].name end
    end
    for i,goal in ipairs(q.goals or {}) do
        local o=HP.Objectives(step.questID)[i]
        if not o or not o.finished then
            local kind=goal.kind=='kill' and 'npc' or goal.kind=='item' and 'item' or 'object'
            local entity=HP.Entity(goal.kind,goal.id);return kind,goal.id,entity and entity.name
        end
    end
    return 'quest',step.questID,q.name
end
local build=HP.BuildGuideRows
function HP.BuildGuideRows()
    local source=build();local rows={};local previous
    for _,row in ipairs(source) do
        if row.kind~='section' and (HP.db.showCompleted or (HP.review and row.stepIndex==HP.state.index) or not row.done or (row.kind=='objective' and row.stepIndex==HP.state.index and HP.Active(row.questID))) then
            local index=row.stepIndex
            if index and index~=previous then
                local visible=HP.VisibleProgress(HP.route,{index=index,skipped=HP.state.skipped})
                rows[#rows+1]={kind='section',text=HP.ModernCardTitle and HP.ModernCardTitle(HP.route.steps[index]) or string.format('STEP %02d%s',visible,index==HP.state.index and ' · CURRENT' or ' · NEXT'),stepIndex=index,cardHeader=true}
                previous=index
            end
            rows[#rows+1]=row
        end
    end
    return rows
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local f=HP.frame
    -- Migrate the previous standard size once; keep deliberate custom dimensions.
    if not HP.db.cardLayout then
        if not HP.db.width or HP.db.width==350 then HP.db.width=380 end
        if not HP.db.height or HP.db.height==250 then HP.db.height=280 end
        HP.db.cardLayout=true;f:SetSize(HP.db.width,HP.db.height)
    end
    f.header:SetFont('Fonts\\FRIZQT__.TTF',16);f.header:ClearAllPoints();f.header:SetPoint('TOP',10,-10)
    f.tab:SetFont('Fonts\\FRIZQT__.TTF',17);f.tab:SetTextColor(1,.83,.28)
    f.step:ClearAllPoints();f.step:SetPoint('TOP',f,'TOP',0,-29);f.step:SetTextColor(1,.83,.28)
    if f.xp then f.xp:Hide() end
    f.character:Hide();f.tabBackground:SetVertexColor(.09,.08,.06,.9);f.toolbarBackground:SetVertexColor(.08,.08,.08,.8)
    f:SetBackdropBorderColor(.55,.47,.27,.95)
    f.portrait=f:CreateTexture(nil,'ARTWORK');f.portrait:SetSize(38,38);f.portrait:SetPoint('TOPLEFT',10,-37)
    if SetPortraitTexture then HP.Call(SetPortraitTexture,f.portrait,'player') else f.portrait:SetTexture('Interface\\FriendsFrame\\PlusManz-Horde') end
    f.tab:ClearAllPoints();f.tab:SetPoint('TOPLEFT',f,'TOPLEFT',57,-46);f.tab:SetPoint('TOPRIGHT',f,'TOPRIGHT',-47,-46)
    f.model=CreateFrame('PlayerModel',nil,UIParent);f.model:SetSize(170,190);f.model:SetFrameStrata('TOOLTIP');f.model:Hide()
    f.targetButtons={};f.cards={}
    local wheel=HP.Call(f.scroll.GetScript,f.scroll,"OnMouseWheel")
    if wheel then f.scroll:SetScript("OnMouseWheel",function(self,delta) if HP.Call(InCombatLockdown)==true then return end;wheel(self,delta);HP.Refresh() end) end
    for i=1,8 do
        local b=CreateFrame('Button','DudeDingTarget'..i,UIParent,'SecureActionButtonTemplate');f.targetButtons[i]=b
        b:SetSize(26,26);b:SetFrameStrata('LOW');b:SetFrameLevel(50);b:RegisterForClicks('AnyUp','AnyDown');b:SetAttribute('type','macro');b:SetAttribute('useOnKeyDown',true)
        b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetAllPoints();b.icon:SetTexture('Interface\\Icons\\Ability_Hunter_SniperShot')
        b:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
        b:SetScript('OnEnter',function(self) if GameTooltip and self.npcName then GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText('Target '..self.npcName);GameTooltip:AddLine('Click to target by exact name and mark a living enemy with Skull. Green means a matching NPC is visible.',1,.85,.4,true);GameTooltip:Show() end end)
        b:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end);b:Hide()
    end
    local elapsed,gps=0,0
    f.targetTicker=CreateFrame('Frame',nil,f);f.targetTicker:SetScript('OnUpdate',function(_,dt) elapsed=elapsed+dt;gps=gps+dt;if gps>2 then gps=0;HP.UpdateDynamicDestination() end;if elapsed>.5 then elapsed=0;HP.UpdateTargetPresence() end end)
end
function HP.ShowRowTooltip(row)
    if not GameTooltip then return end
    local kind,id,name=row.entityKind,row.entityID,row.entityName
    GameTooltip:SetOwner(row,'ANCHOR_RIGHT');GameTooltip:SetText(name or (row.questID and HP.QuestName(row.questID)) or 'Guide step')
    if kind=='item' and id and GameTooltip.SetItemByID then HP.Call(GameTooltip.SetItemByID,GameTooltip,id) end
    if row.location then GameTooltip:AddLine(string.format('Coordinates: %.1f, %.1f',row.location.x*100,row.location.y*100),1,.85,.35) end
    if row.questID then local q=HP.questData[row.questID];if q then GameTooltip:AddLine('Quest: '..q.name,.7,.85,1,true);GameTooltip:AddLine('Required level: '..(q.minLevel or 1),.8,.8,.8);if q.groupRecommended then GameTooltip:AddLine('Elite objective: a group may be needed.',1,.4,.3,true) end end end
    GameTooltip:AddLine('Click coordinates to set the waypoint.',.7,.7,.7,true);GameTooltip:Show()
end
local render=HP.RenderRows
function HP.RenderRows(tab,rows,note,current,total,progress)
    if HP.Call(InCombatLockdown)==true then HP.refreshPending=true;return end
    render(tab,rows,note,current,total,progress)
    local f=HP.frame;f.step:SetText(string.format('Step: %02d / %d',current or 1,total or 1))
    local top=0;local targetIndex=0;local cardIndex=0;local currentCard
    for _,card in ipairs(f.cards or {}) do card:Hide() end
    local safe=HP.Call(InCombatLockdown)~=true
    if safe then for _,b in ipairs(f.targetButtons or {}) do b:Hide() end end
    for i,data in ipairs(rows) do
        local row=f.rows[i];local step=data.stepIndex and HP.route and HP.route.steps[data.stepIndex]
        local kind,id,name=HP.StepEntity(step)
        if data.itemID then kind,id,name='item',data.itemID,HP.itemData[data.itemID] and HP.itemData[data.itemID].name end
        if data.kind=='accept' or data.kind=='turnin' then kind,id,name='quest',data.questID,HP.QuestName(data.questID) end
        if data.entityKind then kind,id,name=data.entityKind,data.entityID,data.entityName end
        row.objectiveRow=data.kind=='objective';row.objectiveDone=data.done==true;row.cardHeader=data.cardHeader==true;row.questID=data.questID or (step and step.questID);row.entityKind=kind;row.entityID=id;row.entityName=name
        row:SetScript('OnEnter',HP.ShowRowTooltip);row:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end;if f.model then f.model:Hide() end end)
        row:RegisterForClicks('LeftButtonUp','RightButtonUp')
        row:SetScript('OnClick',function(self,click) if self.location then HP.manualWaypoint=self.location;HP.manualWaypointQuestID=self.questID;HP.waypoint=self.location;HP.UpdateArrow();HP.UpdateMapPins() elseif self.questID and HP.Active(self.questID) then HP.Call(QuestMapFrame_OpenToQuestDetails,self.questID) end end)
        row.bg:SetVertexColor(data.cardHeader and .16 or .055,data.cardHeader and .14 or .055,data.cardHeader and .10 or .055,HP.db.transparent and .45 or .97)
        if data.cardHeader then
            if currentCard then top=top+6;currentCard:SetHeight(top-currentCard.start) end
            top=top+2;cardIndex=cardIndex+1;local card=f.cards[cardIndex]
            if not card then card=CreateFrame('Frame',nil,f.content,'BackdropTemplate');f.cards[cardIndex]=card;card:SetBackdrop({edgeFile=WHITE,edgeSize=1});card:SetBackdropBorderColor(.48,.44,.33,.85);card:SetFrameLevel(math.max(0,row:GetFrameLevel()-1)) end
            card:ClearAllPoints();card:SetPoint('TOPLEFT',5,-top);card:SetWidth(f:GetWidth()-10);card.start=top;card:Show();currentCard=card
            row.text:SetTextColor(1,.83,.3);row.text:SetFont('Fonts\\FRIZQT__.TTF',HP.cardTitleFontSize or 11) end
        row.text:SetWidth(f:GetWidth()-116-(data.indent or 0))
        if data.cardHeader and HP.CardHeaderWidth then row.text:SetWidth(HP.CardHeaderWidth(step)) end
        local minimum=data.cardHeader and (HP.cardHeaderHeight or 22) or data.kind=='tip' and 20 or (kind=='npc' or kind=='item') and 30 or 23
        row:SetHeight(math.max(minimum,row.text:GetStringHeight()+8))
        row.offset=top;row:ClearAllPoints();row:SetPoint('TOPLEFT',7,-top);row:SetWidth(f:GetWidth()-40);top=top+row:GetHeight();if currentCard then currentCard:SetHeight(top-currentCard.start+2) end
        local targetID,targetName=id,name
        if kind=='item' then local item=HP.itemData[id];targetID=item and item.mobs and item.mobs[1];targetName=targetID and HP.npcData[targetID] and HP.npcData[targetID].name end
        if (kind=='npc' or kind=='item') and targetID and targetName and data.kind~='section' and data.kind~='tip' and data.current and safe and not HP.db.hidden and not HP.db.paused and not HP.demo and row.offset-(f.scroll:GetVerticalScroll() or 0)>=0 and row.offset-(f.scroll:GetVerticalScroll() or 0)<f.scroll:GetHeight()-26 and targetIndex<8 then
            targetIndex=targetIndex+1;local b=f.targetButtons[targetIndex]
            if b then b:SetScale((HP.Call(f.GetEffectiveScale,f) or 1)/(HP.Call(UIParent.GetEffectiveScale,UIParent) or 1));b.npcID=targetID;b.npcName=targetName;b:SetAttribute('macrotext','/targetexact '..targetName:gsub('[\r\n]','')..(HP.db.markOnClick and '\n/tm [@target,harm,nodead] 8' or ''));b:ClearAllPoints();b:SetPoint('TOPRIGHT',row,'TOPRIGHT',-3,-2);b:Show();row.text:SetWidth(f:GetWidth()-116-(data.indent or 0)) end
        end
    end
    if currentCard then top=top+6;currentCard:SetHeight(top-currentCard.start) end
    f.currentBottom=0
    for i,data in ipairs(rows) do if HP.state and data.stepIndex==HP.state.index then local row=f.rows[i];f.currentBottom=math.max(f.currentBottom,(row.offset or 0)+row:GetHeight()+6) end end
    f.content:SetHeight(math.max(1,top))
    HP.AttachQuestItems()
end
function HP.AttachQuestItems()
    if HP.Call(InCombatLockdown)==true then return end
    local bar=HP.questItemBar;if not bar then return end
    if not bar:IsShown() then for _,b in ipairs(bar.inlineButtons) do b:Hide() end;return end
    bar:SetBackdropColor(.025,.025,.025,.94);bar:SetBackdropBorderColor(.2,.2,.2,.9);bar.close:Show()
    for i,b in ipairs(bar.inlineButtons) do
        local source=bar.buttons[i];local match
        if type(source.itemID)=="number" and not HP.db.hidden and not HP.db.paused and not HP.demo then
            for _,row in ipairs(HP.frame.rows) do
                local offset=(row.offset or 0)-(HP.frame.scroll:GetVerticalScroll() or 0)
                if row:IsShown() and row.questID==source.questID and row.entityKind=='item' and row.entityID==source.itemID and offset>=0 and offset<HP.frame.scroll:GetHeight()-26 then match=row;break end
            end
        end
        b.itemID=match and source.itemID or nil;b.questID=match and source.questID or nil;b.logIndex=match and source.logIndex or nil
        b:SetAttribute('item',match and 'item:'..source.itemID or nil)
        if match then
            b:SetScale((HP.Call(HP.frame.GetEffectiveScale,HP.frame) or 1)/(HP.Call(UIParent.GetEffectiveScale,UIParent) or 1))
            b.icon:SetTexture(HP.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon,b.itemID) or 'Interface\\Icons\\INV_Misc_QuestionMark')
            b:ClearAllPoints();b:SetPoint('TOPRIGHT',match,'TOPRIGHT',-35,-2);b:Show()
            match.text:SetWidth(HP.frame:GetWidth()-110-(rawget(match,"indent") or 0))
        else b:Hide() end
    end
    HP.UpdateQuestItemCooldowns()
end
function HP.UpdateTargetPresence()
    local f=HP.frame;if not f then return end
    for _,b in ipairs(f.targetButtons or {}) do
        if b:IsShown() and b.npcID then
            local present=false
            local units={target=true,mouseover=true};for unit in pairs(HP.plates or {}) do units[unit]=true end
            for unit in pairs(units) do local guid=HP.Call(UnitGUID,unit);local id=type(guid)=='string' and tonumber(guid:match('^[^-]+%-[^-]+%-[^-]+%-[^-]+%-[^-]+%-(%d+)'))
                if id==b.npcID then present=true;break end
            end
            b.icon:SetVertexColor(present and .3 or 1,1,present and .3 or 1)
            if present and not b.present and HP.db.targetSound then HP.Call(PlaySound,HP.db.targetSoundID or 8959,'Master') end
            b.present=present
        end
    end
end
local items=HP.UpdateQuestItems
function HP.UpdateQuestItems() items();HP.AttachQuestItems() end

function HP.UpdateDynamicDestination()
    if HP.db.hidden or HP.db.paused or HP.db.autoWaypoint==false or HP.manualWaypoint or not HP.route or not HP.state then return end
    local step=HP.route.steps[HP.state.index]
    if not step or step.action~="quest" then return end
    local next=HP.StepLocation(step);local old=HP.waypoint
    if next and (not old or next.mapID~=old.mapID or math.abs(next.x-old.x)+math.abs(next.y-old.y)>.003) then HP.Refresh() end
end

local goal=HP.GoalRow
function HP.GoalRow(questID,objective,o)
    local row=goal(questID,objective,o)
    if objective then row.entityKind=objective.kind=="kill" and "npc" or objective.kind=="item" and "item" or "object";row.entityID=objective.id;local entity=HP.Entity(objective.kind,objective.id);row.entityName=entity and entity.name end
    return row
end

local stepRows=HP.StepRows
function HP.StepRows(step,compact)
    local rows=stepRows(step,compact)
    if not compact and HP.Active(step.questID) and HP.QuestStepPhase(step).action=="objective" then
        for _,item in ipairs(HP.QuestUseItems()) do
            if item.questID==step.questID then
                local exists=false;for _,row in ipairs(rows) do if row.itemID==item.itemID and row.kind=="use" then exists=true end end
                if not exists then local info=HP.itemData[item.itemID];table.insert(rows,1,{kind="use",text="Use "..(info and info.name or "the quest item").." on the quest target",itemID=item.itemID,questID=step.questID,icon=HP.Call(C_Item and C_Item.GetItemIconByID,item.itemID)}) end
            end
        end
    end
    return rows
end




