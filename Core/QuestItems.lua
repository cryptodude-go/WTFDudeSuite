local addonName,HP=...
local function combat() return HP.Call(InCombatLockdown)==true end
local function font(parent,size)
    local t=parent:CreateFontString(nil,"OVERLAY");t:SetFont("Fonts\\FRIZQT__.TTF",size,"OUTLINE");t:SetTextColor(1,1,1);return t
end
function HP.QuestUseItems()
    local items,seen={},{}
    local function add(id,questID,index)
        if type(id)~="number" or seen[id] or HP.Completed(questID) or HP.Done({action="objective",questID=questID}) then return end
        seen[id]=true;items[#items+1]={itemID=id,questID=questID,logIndex=index}
    end
    local current=HP.route and HP.state and HP.route.steps[HP.state.index]
    if current and HP.HearthstoneAdvice and HP.HearthstoneAdvice(current) then add(6948,current.questID) end
    if current and current.useItemID and HP.Active(current.questID) and not HP.Done(current) then add(current.useItemID,current.questID) end
    if not HP.questUseIndex then
        HP.questUseIndex={};local indexed={}
        for _,route in pairs(HP.routes) do for _,step in ipairs(route.steps) do if step.useItemID then
            local key=tostring(step.questID)..":"..step.useItemID..":"..table.concat(step.classes or {},",")..":"..table.concat(step.races or {},",")
            if not indexed[key] then indexed[key]=true;HP.questUseIndex[#HP.questUseIndex+1]=step end
        end end end
    end
    for _,step in ipairs(HP.questUseIndex) do if HP.Applies(step) and HP.Active(step.questID) and not HP.Done(step) then add(step.useItemID,step.questID) end end
    for _,quest in ipairs(HP.Quests()) do
        local index=HP.Call(C_QuestLog and C_QuestLog.GetLogIndexForQuestID,quest.questID)
        local link=HP.Call(GetQuestLogSpecialItemInfo or C_QuestLog and C_QuestLog.GetQuestLogSpecialItemInfo,index)
        local id=type(link)=="string" and tonumber(link:match("item:(%d+)"))
        if id then add(id,quest.questID,index) end
    end
    return items
end
function HP.ApplyQuestItemPosition()
    if combat() then HP.itemPositionPending=true;return end
    local bar=HP.questItemBar;if not bar then return end
    bar:ClearAllPoints()
    local p=HP.db.questItemsPosition
    if p then bar:SetPoint(p[1],UIParent,p[2],p[3],p[4]) else bar:SetPoint("BOTTOMLEFT",HP.frame,"TOPLEFT",0,8) end
    HP.itemPositionPending=false
end
function HP.CreateQuestItemBar()
    local bar=CreateFrame("Frame","DudeWheresMyDingQuestItems",UIParent,"BackdropTemplate");HP.questItemBar=bar
    bar:SetSize(78,44);bar:SetFrameStrata("LOW");bar:SetFrameLevel(50);bar:SetMovable(true);bar:SetClampedToScreen(true);bar:EnableMouse(true);bar:RegisterForDrag("LeftButton")
    bar:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1});bar:SetBackdropColor(.025,.025,.025,.94);bar:SetBackdropBorderColor(.2,.2,.2,.9)
    local function start() if not combat() then bar:StartMoving() end end
    local function stop()
        if combat() then return end
        bar:StopMovingOrSizing();local p,_,r,x,y=bar:GetPoint();HP.db.questItemsPosition={p,r,x,y}
    end
    bar:SetScript("OnDragStart",start);bar:SetScript("OnDragStop",stop)
    bar.buttons={};bar.inlineButtons={}
    for slot=1,16 do
        local inline=slot>8;local i=inline and slot-8 or slot
        local b=CreateFrame("Button","DudeWheresMyDingQuestItem"..slot,inline and UIParent or bar,"SecureActionButtonTemplate")
        if inline then bar.inlineButtons[i]=b else bar.buttons[i]=b end
        b:SetFrameStrata("LOW");b:SetFrameLevel(50);b:SetSize(inline and 24 or 34,inline and 24 or 34);b:SetPoint("LEFT",bar,"LEFT",5+(i-1)*40,0);b:RegisterForClicks("AnyUp","AnyDown")
        b:SetAttribute("type","item");b:SetAttribute("useOnKeyDown",true)
        b.icon=b:CreateTexture(nil,"ARTWORK");b.icon:SetAllPoints();b.icon:SetTexCoord(.07,.93,.07,.93)
        b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square","ADD")
        b.cooldown=CreateFrame("Cooldown",nil,b,"CooldownFrameTemplate");b.cooldown:SetAllPoints()
        b.count=font(b,11);b.count:SetPoint("BOTTOMRIGHT",-1,1)
        if not inline then b:RegisterForDrag("LeftButton");b:SetScript("OnDragStart",start);b:SetScript("OnDragStop",stop) end
        b:SetScript("OnEnter",function(self)
            if not GameTooltip or not self.itemID then return end
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            if GameTooltip.SetItemByID then GameTooltip:SetItemByID(self.itemID) else GameTooltip:SetHyperlink("item:"..self.itemID) end
            GameTooltip:AddLine(inline and "Click to use on your target." or "Click to use on your target. Drag to move this bar.",1,.8,.4,true);GameTooltip:Show()
        end)
        b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end);b:Hide()
    end
    bar.close=CreateFrame("Button",nil,bar);bar.close:SetSize(24,24);bar.close:SetPoint("TOPRIGHT",-1,-1)
    bar.close.label=font(bar.close,16);bar.close.label:SetAllPoints();bar.close.label:SetText("x")
    bar.close:SetScript("OnClick",function() HP.db.questItemsHidden=true;HP.UpdateQuestItems() end)
    HP.ApplyQuestItemPosition();bar:Hide()
end
function HP.UpdateQuestItems()
    local bar=HP.questItemBar;if not bar then return end
    -- Secure item assignments, visibility, parenting and placement cannot change in combat.
    if combat() then HP.itemBarPending=true;return end
    HP.itemBarPending=false
    if HP.itemPositionPending then HP.ApplyQuestItemPosition() end
    local items=HP.QuestUseItems()
    local visible=not HP.demo and not HP.db.hidden and not HP.db.paused and not HP.db.questItemsHidden
    for i,b in ipairs(bar.buttons) do
        local item=visible and items[i] or nil
        b.questID=item and item.questID or nil;b.itemID=item and item.itemID or nil;b.logIndex=item and item.logIndex or nil
        b:SetAttribute("item",item and "item:"..item.itemID or nil)
        if item then
            b.icon:SetTexture(HP.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon,item.itemID) or "Interface\\Icons\\INV_Misc_QuestionMark");b:Show()
        else b:Hide() end
    end
    if visible and #items>0 then bar:SetWidth(math.min(#items,8)*40+32);bar:Show() else bar:Hide() end
    HP.UpdateQuestItemCooldowns()
end
function HP.UpdateQuestItemCooldowns()
    local bar=HP.questItemBar;if not bar or not bar:IsShown() then return end
    for slot=1,16 do
        local b=slot<=8 and bar.buttons[slot] or bar.inlineButtons[slot-8]
        if type(b.itemID)=="number" then
            local count=HP.ItemCount(b.itemID);b.count:SetText(count~=1 and tostring(count) or "")
            b.icon:SetDesaturated(count==0)
            local start,duration,enabled
            if b.logIndex then start,duration,enabled=HP.Call(GetQuestLogSpecialItemCooldown,b.logIndex) end
            if not start then start,duration,enabled=HP.Call(C_Container and C_Container.GetItemCooldown or C_Item and C_Item.GetItemCooldown or GetItemCooldown,b.itemID) end
            if type(start)=="number" and type(duration)=="number" and duration>0 and enabled~=0 then b.cooldown:SetCooldown(start,duration);b.cooldown:Show() else b.cooldown:Hide() end
        end
    end
end

