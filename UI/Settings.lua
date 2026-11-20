local _,HP=...
local WHITE="Interface\\Buttons\\WHITE8X8"
local function text(parent,value,size,x,y,width)
    local t=parent:CreateFontString(nil,"OVERLAY");t:SetFont("Fonts\\FRIZQT__.TTF",size or 13);t:SetPoint("TOPLEFT",x,y);t:SetWidth(width or 480);t:SetJustifyH("LEFT");t:SetText(value);t:SetTextColor(1,.83,.30);return t
end
local function rect(parent,x,y,w,h,r,g,b)
    local t=parent:CreateTexture(nil,"BACKGROUND");t:SetTexture(WHITE);t:SetPoint("TOPLEFT",x,y);t:SetSize(w,h);t:SetVertexColor(r,g,b,1);return t
end
local function button(parent,value,x,y,w,fn)
    local b=CreateFrame("Button",nil,parent,"BackdropTemplate");b:SetBackdrop({bgFile=WHITE,edgeFile="Interface\\DialogFrame\\UI-DialogBox-Gold-Border",edgeSize=8,insets={left=3,right=3,top=3,bottom=3}});b:SetBackdropBorderColor(.78,.61,.25,1);b:SetPoint("TOPLEFT",x,y);b:SetSize(w,28)
    b.bg=rect(b,3,-3,w-6,22,.16,.085,.035);b.label=text(b,value,12,10,-7,w-20)
    b:SetScript("OnClick",fn);b:SetScript("OnEnter",function() b.bg:SetVertexColor(.16,.28,.4,1) end);b:SetScript("OnLeave",function() b.bg:SetVertexColor(.16,.085,.035,1) end);return b
end
function HP.CreateSettings()
    local f=HP.frame
    local p=CreateFrame("Frame","DudeWheresMyDingOptions",UIParent,"BackdropTemplate");HP.settings=p
    p:SetSize(820,560);p:SetPoint("CENTER");p:SetFrameStrata("DIALOG");p:SetClampedToScreen(true)
    p:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});p:SetBackdropColor(.10,.10,.10,.99);p:SetBackdropBorderColor(.26,.26,.26,1)
    p:SetMovable(true);p:EnableMouse(true);p:RegisterForDrag("LeftButton");p:SetScript("OnDragStart",p.StartMoving);p:SetScript("OnDragStop",p.StopMovingOrSizing)
    rect(p,0,0,820,83,.12,.075,.045);rect(p,0,-83,205,477,.09,.055,.028)
    -- Close is provided by the titled native-style header.
    p.scroll=CreateFrame("ScrollFrame",nil,p,"UIPanelScrollFrameTemplate");p.scroll:SetPoint("TOPLEFT",220,-96);p.scroll:SetPoint("BOTTOMRIGHT",-29,20)
    p.content=CreateFrame("Frame",nil,p.scroll);p.content:SetSize(550,1000);p.scroll:SetScrollChild(p.content)
    p.controls={};p.labels={};p.pageControls={}
    local function show(page)
        p.page=page;p.scroll:SetVerticalScroll(0)
        if p.guideModeMenu then p.guideModeMenu:Hide() end
        for _,b in ipairs(p.controls) do b:Hide() end;for _,t in ipairs(p.labels) do t:Hide() end
        for _,b in ipairs(p.pageControls) do b:Hide() end
        for _,b in ipairs(type(p.messageEditors)=='table' and p.messageEditors or {}) do b:Hide() end
        local labelIndex,controlIndex=0,0
        local function line(value,size,x,y,width)
            labelIndex=labelIndex+1;local t=p.labels[labelIndex]
            if not t then t=text(p.content,value,size,x,y,width);p.labels[labelIndex]=t end
            t:ClearAllPoints();t:SetPoint("TOPLEFT",x,y);t:SetFont("Fonts\\FRIZQT__.TTF",size);t:SetWidth(width or 480);t:SetHeight(32);t:SetText(value);t:Show();return t
        end
        local function control(value,y,fn,width,x)
            controlIndex=controlIndex+1;local b=p.pageControls[controlIndex]
            if not b then b=button(p.content,value,x or 0,y,width or 510,fn);p.pageControls[controlIndex]=b end
            b:ClearAllPoints();b:SetPoint("TOPLEFT",x or 0,y);b:SetWidth(width or 510);b.label:SetWidth((width or 510)-20);b.label:SetText(value);b:SetScript("OnClick",fn);b:Show();return b
        end
        local function addExisting(b,y) b:ClearAllPoints();b:SetPoint("TOPLEFT",0,y);b:Show() end
        line(({Statistics="Player Statistics",Dungeons="Dungeons & Loot"})[page] or page,20,0,-3)
        if HP.RenderExtraSettingsPage and HP.RenderExtraSettingsPage(p,page,line,control,addExisting) then
        elseif page=="Options" or page=="Navigation" or page=="Map" or page=="Display" then
            line("Changes apply immediately and are saved for this character.",11,0,-35)
            local list=page=="Navigation" and {p.autoWaypoint,f.arrowToggle,f.arrowLock,f.arrowSize,p.resetArrow} or page=="Map" and {p.mapNumbers,f.routeLines,p.animatedTrail,p.minimapTrail,f.pinStyle} or page=="Display" and {p.previewToggle,p.fitStep,p.levelETA,f.transparency,f.tips,p.finished,p.strike,p.guideScale,p.compact,p.itemBar,p.resetItems} or {p.rescanQuests,p.diagnostics,p.markOnClick,p.sound,p.soundChoice,p.classQuests,p.foreverQuests,p.groupQuests,p.raidQuests}
            for i,b in ipairs(list) do addExisting(b,-66-(i-1)*36) end
            p.guideMode.label:SetText("Guide mode: "..(HP.db.guideStyle=="speed" and "Speedrun (experimental)" or "Normal / all zone quests").."  v")
            p.markOnClick.label:SetText("Skull on target-button click: "..(HP.db.markOnClick and "ON" or "OFF"))
            p.partyDone.label:SetText("Party: quest objectives complete: "..(HP.db.announceQuestDone and "ON" or "OFF"))
            p.partyLevel.label:SetText("Party: level and tracked time: "..(HP.db.announceLevelTime and "ON" or "OFF"))
            p.fitStep.label:SetText("Fit entire current step: "..(HP.db.autoFitStep and "ON" or "OFF"))
            p.levelETA.label:SetText("Time to next level: "..(HP.db.showLevelETA and "ON" or "OFF"))
            p.animatedTrail.label:SetText("Animated route trail: "..(HP.db.staticRouteTrail and "OFF" or "ON"))
            p.minimapTrail.label:SetText("Minimap route trail: "..(HP.db.hideMinimapTrail and "OFF" or "ON"))
            p.mapNumbers.label:SetText("World map numbers: "..(HP.db.hideMapNumbers and "OFF" or "ON"))
            p.sound.label:SetText("Visible target sound: "..(HP.db.targetSound and "ON" or "OFF"))
            p.groupQuests.label:SetText("Include group / dungeon quests: "..(HP.db.includeGroupQuests and "ON" or "OFF"))
            p.raidQuests.label:SetText("Include raid quests: "..(HP.db.includeRaidQuests and "ON" or "OFF"))
            p.classQuests.label:SetText("Include class quests: "..(HP.db.includeClassQuests==false and "OFF" or "ON"))
            p.foreverQuests.label:SetText("Include new Forever quests: "..(HP.db.includeForeverQuests==false and "OFF" or "ON"))
            p.finished.label:SetText("Show completed steps: "..(HP.db.showCompleted and "ON" or "OFF"))
            p.content:SetHeight(math.max(450,110+#list*36));HP.UpdateOptionLabels();p.itemBar.label:SetText("Quest-item bar: "..(HP.db.questItemsHidden and "OFF" or "ON"));p.strike.label:SetText("Strike completed text: "..(HP.db.noStrike and "OFF" or "ON"));p.guideScale.label:SetText("Guide size: "..math.floor((HP.db.scale or 1)*100).."%")
        elseif page=="Chapters" then
            line("Horde zone planners · levels 1–60",13,0,-39)
            line("Classic facts; beta changes and route speed need playtesting.",11,0,-67)
            local query=(p.search:GetText() or ""):lower();local y=-105
            for _,id in ipairs(HP.guideOrder) do
                local route=HP.routes[id]
                if query=="" or route.title:lower():find(query,1,true) then
                    local total,class,new,pending=HP.GuideStats(route)
                    control(route.title,y,function() p.detailID=id;show("Guide details") end)
                    line(total.." quests · "..class.." class · "..new.." Forever · "..pending.." awaiting locations",11,0,y-31)
                    y=y-72
                end
            end
            p.content:SetHeight(math.max(450,-y+35))
        elseif page=="Guide details" then
            local route=HP.routes[p.detailID];local total,class,new,pending=HP.GuideStats(route)
            line(route.title,18,0,-48)
            line(route.description or "Quest planning for this zone.",12,0,-86):SetHeight(65)
            line(total.." indexed quests; "..class.." class quests; "..new.." new Forever quests.",12,0,-154)
            line("Race, class, level and prerequisite filters apply automatically.",12,0,-186)
            line("Normal includes all indexed zone quests. Speedrun prioritizes solo quests and short travel; it is not a speed-tested fastest route. Pending Forever quests appear when accepted; missing coordinates use live game waypoints when available.",12,0,-222):SetHeight(90)
            control("Load this zone",-320,function() HP.SelectGuide(p.detailID);p:Hide() end)
            control("Back to all zones",-357,function() show("Chapters") end)
            local y=-410
            for _,step in ipairs(route.steps) do local q=HP.questData[step.questID];if q and HP.Applies(step) then
                line("["..(q.level or "?").."] "..q.name..(q.navigationPending and " · location pending" or ""),12,0,y);y=y-35
            end end
            p.content:SetHeight(math.max(450,-y+40))
        elseif page=="Current" then
            line(HP.route and HP.route.title or "Quest log",16,0,-48)
            local step=HP.route and HP.state and HP.route.steps[HP.state.index]
            line(HP.NavigationInstruction("Guide destination"),14,0,-81);line(HP.NavigationAction(),13,0,-108)
            if step and step.hint and not HP.Done(step) and not HP.db.hideTips then line(step.hint,12,0,-145) end
            control("Resume at next incomplete step",-210,function() HP.Sync();p:Hide() end)
            control("Show my race's guide",-247,function() HP.UseGuide();p:Hide() end)
            control("Use quest-log mode",-284,function() HP.db.mode="quests";HP.demo=false;HP.Refresh();p:Hide() end)
            control("Preview tracker layout",-321,function() HP.demo=true;HP.Refresh();p:Hide() end)
            p.content:SetHeight(450)
        elseif page=="Recent" then
            local y=-50
            for id,state in pairs(HP.db.routes) do local route=HP.routes[id];if route then line(route.title.." - step "..state.index,14,0,y);y=y-36 end end
            p.content:SetHeight(450)
        else
            line("DUDE, WHERE'S MY DING?",23,0,-55);line("Horde leveling, one clear step at a time.",14,0,-90)
            line("What's new in 0.11.1",17,0,-145)
            line("Guidebook: chapter browsing and zone details\nGuide Mode: Normal and experimental Speedrun\nSettings: navigation, map, display and quest filters\nAnnouncements: editable party and raid messages\nCharacter-specific saved settings and history",13,0,-181):SetHeight(155)
            control("Continue my leveling guide",-353,function() HP.UseGuide();p:Hide() end)
            control("Browse guide chapters",-390,function() show("Chapters") end)
            p.content:SetHeight(470)
        end
        if HP.StyleSettingsPage then HP.StyleSettingsPage(p) end
    end
    p.ShowPage=show
    p.navigationButtons={}
    for i,name in ipairs({"Guidebook","Settings"}) do
        local page=({"Home","Navigation"})[i]
        button(p,name,14+(i-1)*112,-46,104,function() show(page) end)
    end
    text(p,"GUIDEBOOK",11,16,-133,180)
    for i,name in ipairs({"Home","Chapters","Guide Mode"}) do p.navigationButtons[name]=button(p,name,12,-151-(i-1)*32,180,function() show(name) end) end
    text(p,"SETTINGS",11,16,-251,180)
    for i,name in ipairs({"Navigation","Map","Display","Options","Announcements"}) do p.navigationButtons[name]=button(p,name,12,-270-(i-1)*32,180,function() show(name) end) end
    p.navigationButtons.Options.label:SetText("Quest & target options")

    p.search=CreateFrame("EditBox",nil,p,"InputBoxTemplate");p.search:SetSize(175,24);p.search:SetPoint("TOPLEFT",17,-102);p.search:SetAutoFocus(false)
    p.search:SetScript("OnEnterPressed",function(self) self:ClearFocus() end)
    p.search:SetScript("OnTextChanged",function(_,userInput) if userInput then show("Chapters") end end);p.search:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    text(p,"Search chapters",9,18,-87,175)
    local function option(value,fn) local b=button(p.content,value,0,0,510,fn);p.controls[#p.controls+1]=b;b:Hide();return b end
    f.transparency=option("Transparency",function() HP.db.transparent=not HP.db.transparent;HP.ApplyTransparency();show(p.page) end)
    f.tips=option("Explanations",function() HP.db.hideTips=not HP.db.hideTips;HP.Refresh();show(p.page) end)
    f.arrowToggle=option("Arrow",function() HP.db.arrowHidden=not HP.db.arrowHidden;HP.Refresh();show(p.page) end)
    f.arrowLock=option("Lock arrow",function() HP.db.arrowLocked=not HP.db.arrowLocked;show(p.page) end)
    f.arrowSize=option("Arrow size",function() local sizes={.8,1,1.25,1.5};local index=2;for i,s in ipairs(sizes) do if s==(HP.db.arrowScale or 1) then index=i end end;HP.db.arrowScale=sizes[index%#sizes+1];HP.ApplyArrowSettings();show(p.page) end)
    p.resetArrow=option("Reset arrow to top center",function() HP.db.arrowPosition=nil;HP.ApplyArrowSettings() end)
    f.routeLines=option("Map route lines",function() HP.db.hideRouteLines=not HP.db.hideRouteLines;HP.UpdateMapPins();show(p.page) end)
    f.pinStyle=option("Map numbers",function() HP.db.pinCircles=not HP.db.pinCircles;HP.UpdateMapPins();show(p.page) end)
    p.strike=option("Strike completed text",function() HP.db.noStrike=not HP.db.noStrike;HP.Refresh();show(p.page) end)
    p.guideScale=option("Guide size",function() local size=(HP.db.scale or 1)+.1;if size>1.51 then size=.8 end;HP.db.scale=size;if HP.Call(InCombatLockdown)==true then HP.pendingGuideScale=true else f:SetScale(size) end;show(p.page) end)
    if UISpecialFrames then table.insert(UISpecialFrames,"DudeWheresMyDingOptions") end
    p.itemBar=option("Quest-item bar",function() HP.db.questItemsHidden=not HP.db.questItemsHidden;HP.UpdateQuestItems();show(p.page) end)
    p.resetItems=option("Reset quest-item bar position",function() HP.db.questItemsPosition=nil;HP.ApplyQuestItemPosition() end)
    p.classQuests=option("Class quests",function() HP.db.includeClassQuests=HP.db.includeClassQuests==false;HP.Sync();show(p.page) end)
    p.foreverQuests=option("Forever quests",function() HP.db.includeForeverQuests=HP.db.includeForeverQuests==false;HP.Sync();show(p.page) end)
    p.finished=option("Completed steps",function() HP.db.showCompleted=not HP.db.showCompleted;HP.Refresh();show(p.page) end)
    p.compact=option("Reset tracker to compact size",function() HP.db.width=350;HP.db.height=250;HP.db.scale=.9;if HP.Call(InCombatLockdown)==true then HP.pendingGuideSize=true;HP.pendingGuideScale=true else f:SetSize(350,250);f:SetScale(.9) end;HP.Refresh();show(p.page) end)
    p.soundChoice=option("Target alert sound: click to switch and preview",function()
        local sounds={8959,SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959,SOUNDKIT and SOUNDKIT.READY_CHECK or 8960};HP.db.targetSoundChoice=(HP.db.targetSoundChoice or 1)%3+1;HP.db.targetSoundID=sounds[HP.db.targetSoundChoice];HP.Call(PlaySound,HP.db.targetSoundID,"Master")
    end)
    p.sound=option("Visible target alerts",function() HP.db.targetSound=not HP.db.targetSound;show(p.page) end)
    p.rescanQuests=option("Rescan current quest log",function() HP.RescanCurrentGuide();show(p.page) end)
    p.diagnostics=option("Show blocked-action and memory diagnostics in chat",function() HP.ShowDiagnostics() end)
    p.guideModeMenu=CreateFrame("Frame",nil,p,"BackdropTemplate");local menu=p.guideModeMenu
    menu:SetSize(510,72);menu:SetFrameStrata("TOOLTIP");menu:SetBackdrop({bgFile=WHITE,edgeFile=WHITE,edgeSize=1});menu:SetBackdropColor(.08,.08,.08,1);menu:SetBackdropBorderColor(.4,.4,.4,1)
    button(menu,"Normal / all indexed zone quests",5,-5,500,function() HP.SetGuideStyle("normal");show(p.page) end)
    button(menu,"Speedrun planner (experimental)",5,-38,500,function() HP.SetGuideStyle("speed");show(p.page) end)
    menu:Hide();p:SetScript("OnHide",function() menu:Hide() end)
    p.guideMode=option("Guide mode",function() if menu:IsShown() then menu:Hide() else menu:ClearAllPoints();menu:SetPoint("TOPLEFT",p.guideMode,"BOTTOMLEFT",0,-2);menu:Show() end end)
    p.groupQuests=option("Include group quests",function() HP.db.includeGroupQuests=not HP.db.includeGroupQuests;HP.resyncGuide=true;HP.UseGuide();show(p.page) end)
    p.raidQuests=option("Include raid quests",function() HP.db.includeRaidQuests=not HP.db.includeRaidQuests;HP.resyncGuide=true;HP.UseGuide();show(p.page) end)
    p.markOnClick=option("Skull on target-button click",function() HP.db.markOnClick=not HP.db.markOnClick;HP.Refresh();show(p.page) end)
    p.partyDone=option("Party quest announcements",function() HP.db.announceQuestDone=not HP.db.announceQuestDone;HP.CheckQuestAnnouncements(true);show(p.page) end)
    p.partyLevel=option("Party level timing",function() HP.db.announceLevelTime=not HP.db.announceLevelTime;show(p.page) end)
    p.fitStep=option("Auto-fit current step",function() HP.db.autoFitStep=not HP.db.autoFitStep;HP.Refresh();show(p.page) end)
    p.levelETA=option("Level ETA",function() HP.db.showLevelETA=not HP.db.showLevelETA;HP.UpdateXPFooter();show(p.page) end)
    p.animatedTrail=option("Animated route trail",function() HP.db.staticRouteTrail=not HP.db.staticRouteTrail;HP.UpdateMapPins();show(p.page) end)
    p.minimapTrail=option("Minimap route trail",function() HP.db.hideMinimapTrail=not HP.db.hideMinimapTrail;HP.UpdateMapPins();show(p.page) end)
    p.mapNumbers=option("Map numbers",function() HP.db.hideMapNumbers=not HP.db.hideMapNumbers;HP.UpdateMapPins();show(p.page) end)
    show("Home");p:Hide()
end
