local addonName, HP = ...
HP.icon = "Interface\\AddOns\\" .. addonName .. "\\Media\\Icon"
function HP.MinimapPosition(angle)
    local radians = math.rad(angle)
    local x, y = math.cos(radians), math.sin(radians)
    local rx, ry = Minimap:GetWidth()/2 + 8, Minimap:GetHeight()/2 + 8
    -- Match square minimaps when another addon supplies the standard shape API.
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then
        local maximum = math.max(math.abs(x), math.abs(y))
        x, y = x/maximum, y/maximum
    end
    return x*rx, y*ry
end
function HP.UpdateMinimapPosition()
    if HP.Call(InCombatLockdown)==true then return end
    local x, y = HP.MinimapPosition(HP.db.minimapAngle)
    HP.minimapButton:ClearAllPoints()
    HP.minimapButton:SetPoint("CENTER",Minimap,"CENTER",x,y)
end
function HP.MinimapTooltip()
    if not GameTooltip then return end
    GameTooltip:SetOwner(HP.minimapButton,"ANCHOR_LEFT")
    GameTooltip:SetText("WTF! DUDE SUITE",1,.7,.25)
    GameTooltip:AddLine("Left-click: show or hide guide",1,1,1)
    GameTooltip:AddLine("Right-click: pause or resume",1,1,1)
    GameTooltip:AddLine("Drag: move around the minimap",.75,.75,.75)
    GameTooltip:AddLine("/dudeding help",.75,.75,.75)
    GameTooltip:Show()
end
function HP.CreateMinimapButton()
    if not Minimap then return end
    if type(HP.db.minimapAngle) ~= "number" then HP.db.minimapAngle = 225 end
    local b = CreateFrame("Button","DudeWheresMyDingMinimapButton",Minimap,"SecureHandlerClickTemplate")
    HP.minimapButton = b
    if b.SetFrameRef then
        for i,item in ipairs(HP.questItemBar.inlineButtons or {}) do b:SetFrameRef("inlineItem"..i,item) end
        if HP.frame.actionTarget then b:SetFrameRef("actionTarget",HP.frame.actionTarget);b:SetFrameRef("actionUse",HP.frame.actionUse) end
        b:SetFrameRef("guide",HP.frame);b:SetFrameRef("items",HP.questItemBar)
        for i,target in ipairs(HP.frame.targetButtons or {}) do b:SetFrameRef("target"..i,target) end
        b:SetAttribute("_onclick",[[
            if button=="LeftButton" then
                local guide=self:GetFrameRef("guide")
                if guide and guide:IsShown() then
                    guide:Hide()
                    local actionTarget=self:GetFrameRef("actionTarget");if actionTarget then actionTarget:Hide() end
                    local actionUse=self:GetFrameRef("actionUse");if actionUse then actionUse:Hide() end
                    local items=self:GetFrameRef("items");if items then items:Hide() end
                    for i=1,8 do local item=self:GetFrameRef("inlineItem"..i);if item then item:Hide() end end
                    for i=1,8 do local target=self:GetFrameRef("target"..i);if target then target:Hide() end end
                end
            end
        ]])
    end
    b:SetSize(32,32)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel()+5)
    b:SetClampedToScreen(true)
    b:RegisterForClicks("LeftButtonUp","RightButtonUp")
    b:RegisterForDrag("LeftButton")
    local bg = b:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    b.icon = b:CreateTexture(nil,"ARTWORK")
    b.icon:SetSize(22,22)
    b.icon:SetPoint("CENTER")
    b.icon:SetTexture(HP.icon)
    local border = b:CreateTexture(nil,"OVERLAY")
    border:SetSize(54,54)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    b:SetScript("OnEnter",HP.MinimapTooltip)
    b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    b:SetScript("OnClick",function(_,mouseButton)
        if HP.suppressClickUntil and GetTime() < HP.suppressClickUntil then return end
        if mouseButton == "RightButton" then
            HP.db.paused = not HP.db.paused
        else
            HP.db.hidden = not HP.db.hidden
        end
        HP.Refresh()
    end)
    b:SetScript("OnDragStart",function(self)
        if HP.Call(InCombatLockdown)==true then return end
        if GameTooltip then GameTooltip:Hide() end
        self:SetScript("OnUpdate",function()
            local mx,my = Minimap:GetCenter()
            if not mx or not my then return end
            local cx,cy = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            HP.db.minimapAngle = math.deg(math.atan2(cy/scale-my,cx/scale-mx)) % 360
            HP.UpdateMinimapPosition()
        end)
    end)
    b:SetScript("OnDragStop",function(self)
        self:SetScript("OnUpdate",nil)
        HP.suppressClickUntil = GetTime()+.2
    end)
    HP.UpdateMinimapPosition()
    if HP.db.minimapHidden then b:Hide() else b:Show() end
end

