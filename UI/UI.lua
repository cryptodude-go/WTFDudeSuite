local _, HP = ...
local WHITE="Interface\\Buttons\\WHITE8X8"
local function label(parent,size,color,font)
    local t=parent:CreateFontString(nil,"OVERLAY")
    t:SetFont(font or "Fonts\\FRIZQT__.TTF",size)
    t:SetTextColor(unpack(color or {.95,.95,.95}))
    t:SetJustifyH("LEFT")
    return t
end
local function fill(parent,color)
    local t=parent:CreateTexture(nil,"BACKGROUND")
    t:SetTexture(WHITE); t:SetAllPoints(); t:SetVertexColor(unpack(color))
    return t
end
local function button(parent,caption,x,y,w,fn)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate")
    b:SetSize(w or 26,26); b:SetPoint("TOPLEFT",x,y)
    b.label=label(b,#caption>8 and 11 or 15,{.8,.8,.8}); b.label:SetAllPoints(); b.label:SetJustifyH("CENTER"); b.label:SetText(caption)
    b:SetScript("OnClick",fn)
    b:SetScript("OnEnter",function() b.label:SetTextColor(1,.75,.3) end)
    b:SetScript("OnLeave",function() b.label:SetTextColor(.8,.8,.8) end)
    return b
end
function HP.CreateUI()
    local f=CreateFrame("Frame","DudeWheresMyDingGuide",UIParent,"BackdropTemplate")
    f:SetFrameStrata("LOW")
    HP.frame=f; f:SetSize(HP.db.width or 350,HP.db.height or 250); f:SetPoint("CENTER",UIParent,"CENTER",300,80)
    f:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1})
    f:SetBackdropColor(.025,.025,.025,HP.db.transparent and .40 or .96); f:SetBackdropBorderColor(.17,.17,.17,.9)
    f:SetMovable(true); f:SetClampedToScreen(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart",function(self) if HP.Call(InCombatLockdown)~=true then self:StartMoving() end end)
    f:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing()
        if HP.AnchorGuideTop then HP.AnchorGuideTop() end
        local p,_,r,x,y=self:GetPoint(); HP.db.position={p,r,x,y}
    end)
    if HP.db.position then local p=HP.db.position; f:ClearAllPoints(); f:SetPoint(p[1],UIParent,p[2],p[3],p[4]) end
    if HP.db.scale then f:SetScale(HP.db.scale) end
    f.header=label(f,16,{1,1,1},"Fonts\\FRIZQT__.TTF")
    f.header:SetPoint("TOP",10,-13); f.header:SetText("DUDE, WHERE'S MY DING?")
    f.horde=f:CreateTexture(nil,"ARTWORK");f.horde:SetTexture("Interface\\FriendsFrame\\PlusManz-Horde");f.horde:SetSize(18,18);f.horde:SetPoint("RIGHT",f.header,"LEFT",-5,0)
    f.menuToggle=button(f,"=",5,-7,26,function() HP.ToggleMenu() end)
    local close=button(f,"x",338,-7,26,function() HP.db.hidden=true; HP.Refresh() end)
    f.originalClose=close
    close:ClearAllPoints(); close:SetPoint("TOPRIGHT",-6,-7)
    local tab=CreateFrame("Frame",nil,f); tab:SetPoint("TOPLEFT",9,-43); tab:SetSize(275,27); tab:SetPoint("TOPRIGHT",f,"TOPRIGHT",-50,-43)
    f.zoneHeader=tab; f.tabBackground=fill(tab,{.22,.22,.22,1})
    local xp=label(tab,11,{1,.8,.25}); xp:SetPoint("LEFT",10,0); xp:SetText("XP"); f.xp=xp
    f.tab=label(tab,13); f.tab:SetPoint("LEFT",33,0); f.tab:SetPoint("RIGHT",tab,"RIGHT",-8,0); f.tab:SetWordWrap(false)
    local plus=button(f,"+",286,-43,26,function() HP.ToggleMenu() end); plus:ClearAllPoints(); plus:SetPoint("TOPRIGHT",-15,-43); f.plus=plus
    local bar=CreateFrame("Frame",nil,f); bar:SetPoint("TOPLEFT",0,-70); bar:SetSize(370,26); bar:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,-70)
    f.toolbar=bar; f.toolbarBackground=fill(bar,{.22,.22,.22,1})
    f.previous=button(f,"<",6,-70,24,function() HP.Move(-1) end)
    f.step=label(bar,13); f.step:SetPoint("LEFT",40,0)
    f.next=button(f,">",65,-70,24,function() HP.Move(1) end)
    f.character=label(bar,10,{.78,.78,.78}); f.character:SetPoint("RIGHT",-73,0)
    f.pause=button(f,"Pause",307,-70,57,function() HP.db.paused=not HP.db.paused; HP.Refresh() end)
    f.pause:ClearAllPoints(); f.pause:SetPoint("TOPRIGHT",-6,-70)
    f.pause.label:SetFont("Fonts\\FRIZQT__.TTF",10)
    f.rows={}
    f.scroll=CreateFrame("ScrollFrame",nil,f)
    f.scroll:SetPoint("TOPLEFT",1,-96); f.scroll:SetPoint("BOTTOMRIGHT",-1,54)
    f.content=CreateFrame("Frame",nil,f.scroll); f.content:SetSize(f:GetWidth()-2,1); f.scroll:SetScrollChild(f.content)
    f.scroll:SetClipsChildren(true); f.scroll:EnableMouseWheel(true)
    f.scroll:SetScript("OnMouseWheel",function(self,delta)
        local max=math.max(0,f.content:GetHeight()-self:GetHeight())
        self:SetVerticalScroll(math.max(0,math.min(max,(self:GetVerticalScroll() or 0)-delta*32)))
    end)
    f:SetResizable(true)
    if f.SetResizeBounds then f:SetResizeBounds(330,230,850,950) else f:SetMinResize(330,230); f:SetMaxResize(850,950) end
    f.resize=CreateFrame("Button",nil,f); f.resize:SetSize(22,22); f.resize:SetPoint("BOTTOMRIGHT")
    local grip=label(f.resize,19,{.8,.65,.3}); grip:SetAllPoints(); grip:SetText("//")
    f.resize:SetScript("OnMouseDown",function(_,b) if b=="LeftButton" and HP.Call(InCombatLockdown)~=true then f:StartSizing("BOTTOMRIGHT") end end)
    f.resize:SetScript("OnMouseUp",function() f:StopMovingOrSizing(); HP.db.width=f:GetWidth(); HP.db.height=f:GetHeight(); HP.Refresh() end)
    f:SetScript("OnSizeChanged",function()
        f.content:SetWidth(f:GetWidth()-2)
        if f.cached then HP.RenderRows(unpack(f.cached)) end
    end)
    f.note=label(f,10,{.67,.67,.67}); f.note:SetPoint("BOTTOMLEFT",11,18); f.note:SetPoint("BOTTOMRIGHT",-25,18); f.note:SetHeight(32); f.note:SetWordWrap(true)
    f.progress=CreateFrame("StatusBar",nil,f)
    f.progress:SetPoint("BOTTOMLEFT",9,7); f.progress:SetSize(352,5)
    f.progress:SetStatusBarTexture(WHITE); f.progress:SetStatusBarColor(.24,.8,.09,1)
    f.progress:SetPoint("BOTTOMRIGHT",-26,7)
    f.progress:SetMinMaxValues(0,1); fill(f.progress,{.25,.25,.25,1})
    local a=CreateFrame("Frame","DudeWheresMyDingArrow",UIParent); a:SetFrameStrata("LOW"); HP.arrow=a
    a:SetSize(310,142); a:SetPoint("TOP",UIParent,"TOP",0,-110)
    a:SetMovable(true); a:SetClampedToScreen(true); a:EnableMouse(true); a:RegisterForDrag("LeftButton")
    a:SetScript("OnDragStart",function(self) if not HP.db.arrowLocked then self:StartMoving() end end)
    a:SetScript("OnDragStop",function(self)
        self:StopMovingOrSizing(); local p,_,r,x,y=self:GetPoint(); HP.db.arrowPosition={p,r,x,y}
    end)
    a.texture=a:CreateTexture(nil,"ARTWORK"); a.texture:SetSize(64,64); a.texture:SetPoint("TOP")
    a.texture:SetTexture("Interface\\AddOns\\WTFDudeSuite\\Media\\WaypointArrow")
    a.label=label(a,12); a.label:SetWidth(300); a.label:SetHeight(14); a.label:SetJustifyH("CENTER")
    a.label:SetShadowColor(0,0,0,1); a.label:SetShadowOffset(1,-1)
    a.target=label(a,12,{.9,.9,.85}); a.target:SetPoint("TOP",0,-64); a.target:SetWidth(300); a.target:SetHeight(14); a.target:SetJustifyH("CENTER")
    a.target:SetShadowColor(0,0,0,1); a.target:SetShadowOffset(1,-1)
    a.action=label(a,12,{1,.83,.43}); a.action:SetPoint("TOP",a.target,"BOTTOM",0,-2); a.action:SetWidth(300); a.action:SetHeight(14); a.action:SetJustifyH("CENTER")
    a.label:SetPoint("TOP",a.action,"BOTTOM",0,-2)
    a.action:SetShadowColor(0,0,0,1); a.action:SetShadowOffset(1,-1)
    a.coords=label(a,12,{.7,.8,.8});a.coords:SetPoint("TOP",a.label,"BOTTOM",0,-2);a.coords:SetWidth(310);a.coords:SetHeight(14);a.coords:SetJustifyH("CENTER")
    a.coords:SetShadowColor(0,0,0,1);a.coords:SetShadowOffset(1,-1)
    a:SetScript("OnMouseUp",function(_,b) if b=="RightButton" then HP.manualWaypoint=nil; HP.Refresh() end end)
    a:SetScript("OnEnter",function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,"ANCHOR_BOTTOM"); GameTooltip:SetText("Navigation")
        GameTooltip:AddLine(HP.db.arrowLocked and "Arrow locked. Unlock in Guide Options." or "Drag to move the arrow.",1,1,1)
        GameTooltip:AddLine("Right-click to resume the guide destination.",1,1,1); GameTooltip:Show()
    end)
    a:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    a:Hide()
    HP.ApplyArrowSettings()
    local elapsed=0
    f:SetScript("OnUpdate",function(_,dt) elapsed=elapsed+dt; if elapsed>=.1 then elapsed=0; HP.UpdateArrow(); HP.UpdateQuestItemCooldowns(); if HP.UpdateMapPins then HP.UpdateMapPins() end end end)
    HP.CreateQuestItemBar()
    HP.CreateSettings()
    f.menu=HP.settings
    HP.ApplyTransparency(); HP.UpdateOptionLabels()
    f.menu:Hide()
end
function HP.ApplyArrowSettings()
    local a=HP.arrow; if not a then return end
    a:ClearAllPoints()
    local p=HP.db.arrowPosition
    if p then a:SetPoint(p[1],UIParent,p[2],p[3],p[4]) else a:SetPoint("TOP",UIParent,"TOP",0,-110) end
    a:SetScale(HP.db.arrowScale or 1)
end
function HP.UpdateOptionLabels()
    local f=HP.frame
    f.routeLines.label:SetText("Map route lines: "..(HP.db.hideRouteLines and "OFF" or "ON"))
    f.arrowToggle.label:SetText("Navigation arrow: "..(HP.db.arrowHidden and "OFF" or "ON"))
    f.arrowLock.label:SetText("Lock arrow: "..(HP.db.arrowLocked and "ON" or "OFF"))
    f.arrowSize.label:SetText("Arrow size: "..math.floor((HP.db.arrowScale or 1)*100).."%")
    f.pinStyle.label:SetText("Map numbers: "..(HP.db.pinCircles and "faint circles" or "numbers only"))
    f.tips.label:SetText("Explanations: "..(HP.db.hideTips and "OFF" or "ON"))
end
function HP.ApplyTransparency()
    local f=HP.frame; if not f then return end
    f:SetBackdropColor(.025,.025,.025,HP.db.transparent and .40 or .96)
    if f.tabBackground then f.tabBackground:SetVertexColor(.22,.22,.22,HP.db.transparent and .35 or 1) end
    if f.toolbarBackground then f.toolbarBackground:SetVertexColor(.22,.22,.22,HP.db.transparent and .35 or 1) end
    if f.transparency then f.transparency.label:SetText("Transparency: "..(HP.db.transparent and "ON" or "OFF")) end
end
function HP.ToggleMenu()
    if HP.frame.menu:IsShown() then HP.frame.menu:Hide() else HP.frame.menu:Show() end
end
local icons={
    talk="Interface\\GossipFrame\\GossipGossipIcon",
    objective="Interface\\Icons\\Ability_Warrior_SavageBlow",
    level="Interface\\Icons\\Achievement_Level_10",
    travel="Interface\\Icons\\INV_Misc_Map_01",
    use="Interface\\Icons\\INV_Misc_QuestionMark",
    info="Interface\\Icons\\INV_Misc_Map_01",
}
function HP.RenderRows(tab,rows,note,current,total,progress)
    local f=HP.frame
    f.cached={tab,rows,note or "",current or 1,total or 1,progress or 0}
    f.tab:SetText(tab)
    f.step:SetText(tostring(current or 1))
    local p=HP.character or {}
    f.character:SetText((p.raceName or p.race or "").." "..(p.className or p.class or "").."  Lv."..(p.level or 1))
    f.pause.label:SetText(HP.db.paused and "Resume" or "Pause")
    for _,row in ipairs(f.rows) do row:Hide() end
    local top=0
    for index,data in ipairs(rows) do
        local row=f.rows[index]
        if not row then
            row=CreateFrame("Button",nil,f.content); row:SetWidth(f:GetWidth()-2)
            row.bg=fill(row,{.1,.1,.1,.94})
            row.symbol=label(row,17); row.symbol:SetPoint("TOPLEFT",9,-5); row.symbol:SetWidth(20); row.symbol:SetJustifyH("CENTER")
            row.icon=row:CreateTexture(nil,"ARTWORK"); row.icon:SetSize(16,16); row.icon:SetPoint("TOPLEFT",11,-7)
            row.text=label(row,13); row.text:SetPoint("TOPLEFT",34,-6); row.text:SetWidth(325); row.text:SetWordWrap(true)
            row:SetScript("OnClick",function(self)
                if self.location then HP.manualWaypoint=self.location; HP.waypoint=self.location; HP.UpdateArrow(); return end
                if self.questID and HP.Active(self.questID) and QuestMapFrame_OpenToQuestDetails then
                    HP.Call(QuestMapFrame_OpenToQuestDetails,self.questID)
                end
            end)
            row:SetScript("OnEnter",function(self)
                if self.itemID and GameTooltip then GameTooltip:SetOwner(self,"ANCHOR_RIGHT"); HP.Call(GameTooltip.SetItemByID,GameTooltip,self.itemID); GameTooltip:Show() end
            end)
            row:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
            f.rows[index]=row
        end
        row.questID=data.questID; row.location=data.location; row.itemID=data.itemID
        row:SetWidth(f:GetWidth()-2)
        local indent=data.indent or 0
        row.icon:ClearAllPoints(); row.icon:SetPoint("TOPLEFT",11+indent,-7)
        row.symbol:ClearAllPoints(); row.symbol:SetPoint("TOPLEFT",9+indent,-5)
        row.text:ClearAllPoints(); row.text:SetPoint("TOPLEFT",34+indent,-6); row.text:SetWidth(f:GetWidth()-45-indent)
        row.text:SetFont("Fonts\\FRIZQT__.TTF",(data.kind=="tip" or data.kind=="section") and (HP.tipFontSize or 11) or (HP.bodyFontSize or 13))
        row.bg:SetVertexColor(.10,.10,.10,HP.db.transparent and .20 or .95)
        if data.kind=="objective" and data.current and not data.done then row.bg:SetVertexColor(.30,.055,.07,HP.db.transparent and .35 or .95) end
        row.symbol:Hide(); row.icon:Hide()
        if data.done then
            row.icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready"); row.icon:Show()
        elseif data.kind=="accept" or data.kind=="turnin" then
            row.symbol:SetText(data.kind=="accept" and "!" or "?")
            row.symbol:SetTextColor(1,.9,.25); row.symbol:Show()
            if data.kind=="accept" and not data.done then row.bg:SetVertexColor(.42,.06,.075,HP.db.transparent and .35 or .98) end
        elseif data.kind=="tip" or data.kind=="section" then
            -- Explanatory text is deliberately quieter, without another icon.
        else row.icon:SetTexture(data.icon or icons[data.kind] or icons.info); row.icon:Show() end
        row.text:SetText(data.done and data.text:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") or data.text)
        row.text:SetTextColor(data.done and .55 or data.kind=="tip" and .76 or .95,data.done and .65 or data.kind=="tip" and .76 or .95,data.done and .55 or data.kind=="tip" and .68 or .95)
        local height=math.max(data.kind=="tip" and 20 or 28,row.text:GetStringHeight()+(data.kind=="tip" and 9 or 12))
        HP.StrikeRow(row,data.done,height,(data.kind=="tip" or data.kind=="section") and (HP.tipFontSize or 11) or (HP.bodyFontSize or 13))
        row:SetHeight(height); row:ClearAllPoints(); row:SetPoint("TOPLEFT",1,-top); row:Show()
        top=top+height
    end
    f.note:SetText(note or "")
    f.content:SetHeight(math.max(1,top))
    f.scroll:SetVerticalScroll(math.min(f.scroll:GetVerticalScroll() or 0,math.max(0,top-f.scroll:GetHeight())))
    f.progress:SetValue(math.max(0,math.min(1,progress or 0)))
end
-- Kept as a small adapter for quest-log mode.
function HP.Render(title,objectives,note)
    local rows={}
    for _,o in ipairs(objectives) do rows[#rows+1]={kind="objective",text=HP.Progress(o),done=HP.Public(o.finished) and o.finished} end
    if #rows==0 then rows[1]={kind="info",text=title} end
    HP.RenderRows(title,rows,note,1,1,0)
end
function HP.GoalRow(questID,goal,o)
    local entity=goal and HP.Entity(goal.kind,goal.id)
    local override=questID==5441 and "Wake sleeping peons"
    local text=override or entity and ((goal.kind=="kill" and "Kill " or "Collect ")..entity.name) or nil
    local itemID=goal and goal.kind=="item" and goal.id
    return {kind="objective",text=o and HP.Progress(o,text) or (text or "Follow the quest instructions"),
        done=o and HP.Public(o.finished) and o.finished==true,questID=questID,indent=24,
        icon=itemID and HP.Call(C_Item and C_Item.GetItemIconByID,itemID),itemID=itemID}
end
function HP.StepRows(step,compact)
    local rows={}
    if step.action=="level" then
        rows[1]={kind="level",text="Reach |cffa2e985level "..step.targetLevel.."|r",done=HP.Done(step)}
        if not compact then rows[2]={kind="tip",text="Current level: "..(HP.character.level or 1),indent=24} end
        return rows
    end
    if step.action=="buy" then
        local item=HP.itemData[step.itemID]; local vendor=HP.Vendor(step)
        if not compact then rows[#rows+1]={kind="talk",text="Talk to |cffa2e985"..(vendor and vendor.name or "a vendor").."|r"} end
        rows[#rows+1]={kind="buy",text="Buy "..(item and item.name or ("Item "..step.itemID)).." ("..HP.ItemCount(step.itemID).."/"..(step.count or 1)..")",done=HP.Done(step),indent=24,
            icon=HP.Call(C_Item and C_Item.GetItemIconByID,step.itemID),itemID=step.itemID}
        return rows
    end
    local q=HP.questData[step.questID]
    local npc=q and HP.npcData[step.action=="accept" and q.start or q.finish]
    local name=HP.QuestName(step.questID)
    if step.action=="accept" or step.action=="turnin" then
        if npc and not compact then rows[#rows+1]={kind="talk",text="Talk to |cffa2e985"..npc.name.."|r"} end
        local verb=step.action=="accept" and "Accept" or "Turn in"
        rows[#rows+1]={kind=step.action,text=verb.." '|cffffd68a"..name.."|r'",questID=step.questID,done=HP.Done(step)}
        if not compact and step.action=="accept" and q and HP.character.level<q.minLevel then
            rows[#rows+1]={kind="tip",text="Requires level "..q.minLevel.."; finish nearby objectives first.",indent=24}
        end
    else
        if not HP.Active(step.questID) and not compact then
            rows[#rows+1]={kind="accept",text="Pick up '|cffffd68a"..name.."|r' first; use Back or Sync.",questID=step.questID}
        end
        if step.useItemID and not compact then
            local item=HP.itemData[step.useItemID]
            rows[#rows+1]={kind="use",text="Use |cff7ad7ea"..(item and item.name or ("Item "..step.useItemID)).."|r",icon=HP.Call(C_Item and C_Item.GetItemIconByID,step.useItemID),itemID=step.useItemID,indent=24}
        end
        local objectives=HP.Active(step.questID) and HP.Objectives(step.questID) or {}
        if #objectives>0 then
            for i,o in ipairs(objectives) do rows[#rows+1]=HP.GoalRow(step.questID,q and q.goals[i],o) end
        else
            for _,goal in ipairs(q and q.goals or {}) do rows[#rows+1]=HP.GoalRow(step.questID,goal) end
            if #rows==0 then rows[1]={kind="objective",text="Follow the quest instructions; awaiting objective data.",indent=24} end
        end
    end
    return rows
end
function HP.VisibleProgress(route,state)
    local current,total,done=0,0,0
    for i,step in ipairs(route.steps) do
        if HP.Applies(step) then
            total=total+1
            if i<=state.index then current=total end
            if HP.Done(step) or state.skipped[i] then done=done+1 end
        end
    end
    return math.max(1,current),math.max(1,total),total>0 and done/total or 0
end

