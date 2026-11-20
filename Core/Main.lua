local addonName, HP = ...
local function say(value) print("|cffffa640WTF! DUDE SUITE:|r "..value) end
local function label(parent,size,color)
    local value=parent:CreateFontString(nil,"OVERLAY")
    value:SetFont("Fonts\\FRIZQT__.TTF",size)
    value:SetTextColor(unpack(color or {.9,.9,.9})); value:SetJustifyH("LEFT")
    return value
end
function HP.UpdateArrow()
    local w=HP.waypoint
    if not w or HP.demo or HP.db.hidden or HP.db.paused or HP.db.arrowHidden then HP.arrow:Hide(); return end
    HP.arrow:Show()
    local destination=HP.manualWaypoint and string.format("Waypoint %.1f, %.1f",w.x*100,w.y*100) or "Guide destination"
    for _,marker in ipairs(HP.markers or {}) do
        local loc=marker.location
        if loc.mapID==w.mapID and loc.x==w.x and loc.y==w.y then destination=marker.number..". "..(marker.name or marker.titles[1] or destination); break end
    end
    destination=HP.NavigationInstruction(destination)
    HP.arrow.target:SetText(destination)
    HP.arrow.action:SetText(HP.NavigationAction())
    HP.arrow.coords:SetText(HP.CoordinateText(w))
    -- Stack actual wrapped text heights with the same two-pixel gap.
    for _,field in ipairs({HP.arrow.target,HP.arrow.action,HP.arrow.coords}) do
        field:SetHeight(math.max(14,HP.Call(field.GetStringHeight,field) or 14))
    end
    HP.arrow:SetHeight(64+HP.arrow.target:GetHeight()+HP.arrow.action:GetHeight()+14+HP.arrow.coords:GetHeight()+6+4)
    HP.CheckArrival()
    local dx,dy=HP.NavigationVector(w)
    local facing=HP.Call(GetPlayerFacing)
    if not dx or type(facing)~="number" then
        HP.arrow.texture:Hide(); HP.arrow.label:SetText("Position unavailable"); return
    end
    local distance=math.sqrt(dx*dx+dy*dy)
    HP.arrow.texture:SetVertexColor(distance<15 and .55 or 1,1,distance<15 and .55 or 1,1)
    HP.SetArrowHeading(math.atan2(-dx,dy)-facing,distance); HP.arrow.texture:Show()
    HP.arrow.label:SetText(distance<15 and "Arrived" or string.format("%d yd",math.floor(distance+.5)).."  "..HP.ArrivalEstimate(w,distance))
end
HP.plates={}
function HP.RefreshPlate(unit)
    local plate=HP.Call(C_NamePlate and C_NamePlate.GetNamePlateForUnit,unit)
    if not plate then return end
    local box=plate.DudeWheresMyDingBox
    if not box then
        box=CreateFrame("Frame",nil,plate); box:SetSize(220,40); box:SetPoint("BOTTOM",plate,"TOP",0,4)
        box.label=label(box,11,{1,.8,.3}); box.label:SetWidth(220); box.label:SetPoint("CENTER"); box.label:SetJustifyH("CENTER")
        plate.DudeWheresMyDingBox=box
    end
    HP.plates[unit]=box
    box:Hide()
    if HP.db.paused or HP.db.hidden then return end
    local lines=HP.PlateLines(unit)
    if #lines>0 then
        box.label:SetText(table.concat(lines,"\n")); box:SetHeight(math.max(24,box.label:GetStringHeight()+4)); box:Show()
    end
end

function HP.UseGuide()
    HP.db.mode="guide"; HP.demo=false; HP.review=false
    HP.DetectCharacter()
    HP.routeID,HP.route=HP.Route(HP.character.race,HP.character.build)
    if HP.route then
        local state=HP.db.routes[HP.routeID]
        if not state or state.revision~=HP.route.revision then
            state={index=1,skipped={},revision=HP.route.revision}; HP.db.routes[HP.routeID]=state
        end
        if HP.resyncGuide then state.index=1;state.skipped={};HP.resyncGuide=nil end
        HP.state=state
    end
    HP.Refresh()
end
function HP.Sync()
    HP.normalQuestFocus=nil;HP.review=false
    if HP.route and HP.state then HP.state.index=1 end
    HP.Refresh()
end
function HP.Refresh()
    if HP.frame and HP.Call(InCombatLockdown)==true then
        HP.refreshPending=true;HP.HideDetachedControls();HP.UpdateArrow();HP.UpdateMapPins();return
    end
    HP.refreshPending=false
    if not HP.frame then return end
    if HP.pendingGuideScale then HP.frame:SetScale(HP.db.scale or .9);HP.pendingGuideScale=nil end
    if HP.pendingGuideSize then HP.frame:SetSize(HP.db.width or 350,HP.db.height or 250);HP.pendingGuideSize=nil end
    HP.DetectCharacter()
    if HP.ReconcileNormalQuestLog then HP.ReconcileNormalQuestLog() end
    if HP.db.hidden then HP.frame:Hide(); HP.frame.menu:Hide() else HP.frame:Show() end
    HP.waypoint=nil; HP.markers={}; HP.areas={}
    HP.abandonQuest=HP.GetAbandonQuest and HP.GetAbandonQuest()
    if HP.abandonQuest then
        local q=HP.abandonQuest;local index=HP.state.index;local current,total,progress=HP.VisibleProgress(HP.route,HP.state)
        HP.RenderRows(HP.route.title,{{kind="section",text="SPEEDRUN · QUEST LOG CLEANUP",cardHeader=true,stepIndex=index},{kind="info",text="Abandon '"..q.title.."'",questID=q.questID,stepIndex=index,current=true},{kind="tip",text="Outside this speedrun route. Abandon manually in the quest log, or press Next to keep it.",stepIndex=index}},"",current,total,progress)
    elseif HP.demo then
        HP.RenderRows("Durotar (1-10)",{
            {kind="talk",text="Talk to |cffa2e985Kaltunk|r"},
            {kind="accept",text="Accept '|cffffd68aYour Place in the World|r'"},
        },"Layout preview - use /dudeding guide to start",1,1,.03)
    elseif HP.route and HP.db.mode~="quests" then
        local state=HP.state
        if not HP.db.paused and not HP.review then state.index=HP.NextStep(HP.route,state.index,state.skipped) end
        local step=HP.route.steps[state.index]
        local current,total,progress=HP.VisibleProgress(HP.route,state)
        if step then
            local rows=HP.BuildGuideRows()
            local location=HP.StepLocation(step)
            -- If a quest was abandoned, point back to the giver rather than to mobs.
            if step.action=="objective" and not HP.Active(step.questID) then
                local q=HP.questData[step.questID]; local npc=q and HP.npcData[q.start]
                if npc then location=npc.location end
            end
            HP.waypoint=location
            local note=step.section or ""
            HP.RenderRows(HP.route.title,rows,note,current,total,progress)
        else
            local blocked=HP.route.catalog and HP.route.blocked
            HP.RenderRows(HP.route.title,{{kind="info",text=blocked and "No available quests at your current level." or "Chapter completed!"}},
                "Open = for the next zone. Level, prerequisites and quest settings affect available steps.",current,total,progress)
        end
    else
        HP.quests=HP.Quests(); HP.questIndex=1
        for i,q in ipairs(HP.quests) do if q.questID==HP.db.questID then HP.questIndex=i; break end end
        local q=HP.quests[HP.questIndex]; HP.db.questID=q and q.questID or nil
        if q then
            HP.Render(q.title,HP.Objectives(q.questID),"Quest log mode - /dudeding guide selects your starting chapter")
            local map,x,y=HP.Call(C_QuestLog and C_QuestLog.GetNextWaypoint,q.questID)
            if type(map)=="number" and type(x)=="number" and type(y)=="number" then HP.waypoint={mapID=map,x=x,y=y}
            elseif HP.questData[q.questID] then
                local finished=HP.Call(C_QuestLog and C_QuestLog.ReadyForTurnIn,q.questID)
                HP.waypoint=HP.StepLocation({questID=q.questID,action=finished and "turnin" or "objective"})
            end
            if HP.waypoint then HP.markers={{number=1,location=HP.waypoint,titles={q.title},name=q.title}} end
        else HP.Render("No active quests",{},"/dudeding guide selects your race's leveling chapter") end
    end
    local currentStep=HP.route and HP.state and HP.route.steps[HP.state.index]
    if HP.manualWaypointQuestID and (not currentStep or currentStep.questID~=HP.manualWaypointQuestID) then HP.manualWaypoint=nil;HP.manualWaypointQuestID=nil end
    if HP.db.autoWaypoint==false and not HP.manualWaypoint then HP.waypoint=nil;HP.markers={};HP.areas={} end
    if HP.manualWaypoint then HP.waypoint=HP.manualWaypoint end
    HP.UpdateArrow(); HP.UpdateMapPins(); HP.UpdateQuestItems(); HP.HideDetachedControls()
    for unit in pairs(HP.plates) do HP.RefreshPlate(unit) end
end
function HP.Move(delta)
    if HP.demo then return end
    if delta>0 and HP.CycleNormalQuest and HP.CycleNormalQuest(delta) then return end
    HP.manualWaypoint=nil
    if HP.abandonQuest then
        if delta>0 then HP.abandonDismissed=HP.abandonDismissed or {};HP.abandonDismissed[HP.abandonQuest.questID]=true;HP.Refresh();return end
        HP.review=true;HP.abandonQuest=nil
    end
    if HP.route and HP.db.mode~="quests" then
        local state=HP.state
        if delta>0 then
            if state.index<=#HP.route.steps then state.skipped[state.index]=true end
            state.index=math.min(#HP.route.steps+1,state.index+1)
            HP.review=false
        else
            local index=math.max(1,state.index-1)
            while index>1 and not HP.Applies(HP.route.steps[index]) do index=index-1 end
            state.index=index; HP.review=true
        end
    elseif HP.quests and #HP.quests>0 then
        local index=math.max(1,math.min(#HP.quests,HP.questIndex+delta)); HP.db.questID=HP.quests[index].questID
    end
    HP.Refresh()
end
local events=CreateFrame("Frame");HP.mainEvents=events
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent",function(_,event,arg)
    if event=="PLAYER_LOGIN" and HP.InitializeModules then HP.InitializeModules() end
    if event=="ADDON_LOADED" then
        if arg==addonName then
            if HP.ImportStandaloneProgress then HP.ImportStandaloneProgress() end
            DudeWheresMyDingDB=DudeWheresMyDingDB or {}
            HP.db=DudeWheresMyDingDB; HP.db.routes=HP.db.routes or {}; HP.db.completed=HP.db.completed or {}
        end
        return
    end
    if event=="QUEST_TURNED_IN" and HP.db and type(arg)=="number" and HP.Public(arg) then HP.db.completed[arg]=true end
    if event=="PLAYER_LEVEL_UP" and type(arg)=="number" and HP.Public(arg) then HP.levelFromEvent=arg end
    if event=="PLAYER_LOGIN" then
        if UnitFactionGroup("player")~="Horde" then say("Horde characters only."); return end
        HP.DetectCharacter()
        HP.CreateUI(); HP.CreateMinimapButton()
        if HP.db.guideStyle=="normal" then HP.resyncGuide=true;HP.normalDeferred={};HP.normalQuestFocus=nil end
        HP.UseGuide()
        if HP.route then say("Selected "..HP.route.title.." for your "..(HP.character.raceName or HP.character.race).." "..(HP.character.className or HP.character.class)..".")
        else say("No starting chapter for this race yet. Using quest-log mode.") end
        return
    end
    if not HP.frame then return end
    if event=="PLAYER_REGEN_ENABLED" and HP.rescanPending then HP.RescanCurrentGuide();return end
    if event=="QUEST_DETAIL" or event=="QUEST_PROGRESS" or event=="QUEST_COMPLETE" then HP.RecordQuestLocation(event); return end
    if event=="SPELL_UPDATE_COOLDOWN" then HP.UpdateQuestItemCooldowns(); return end
    if event=="NAME_PLATE_UNIT_ADDED" then HP.RefreshPlate(arg)
    elseif event=="NAME_PLATE_UNIT_REMOVED" then
        if HP.plates[arg] then HP.plates[arg]:Hide(); HP.plates[arg]=nil end
    else HP.Refresh() end
end)
for _,event in ipairs({"UPDATE_FACTION","QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE","BAG_UPDATE_DELAYED","SPELL_UPDATE_COOLDOWN","MERCHANT_CLOSED","PLAYER_LOGIN","PLAYER_LEVEL_UP","PLAYER_XP_UPDATE","QUEST_LOG_UPDATE","QUEST_ACCEPTED","QUEST_TURNED_IN","QUEST_REMOVED","PLAYER_ENTERING_WORLD","ZONE_CHANGED_NEW_AREA","NAME_PLATE_UNIT_ADDED","NAME_PLATE_UNIT_REMOVED","PLAYER_REGEN_DISABLED","PLAYER_REGEN_ENABLED"}) do
    pcall(events.RegisterEvent,events,event)
end
SLASH_DUDEWHERESMYDING1="/dudeding"
SlashCmdList.DUDEWHERESMYDING=function(input)
    if not HP.frame then say("Log in on a Horde character first."); return end
    if input=="debug" or input=="diagnostics" then HP.ShowDiagnostics();return end
    if input=="marks" then HP.db.markOnClick=not HP.db.markOnClick;HP.Refresh();say("Click marking: "..(HP.db.markOnClick and "ON" or "OFF"));return end
    local command=input:match("^(%S+)") or "show"
    if command=="preview" then HP.demo=true; HP.db.hidden=false
    elseif command=="options" or command=="settings" then HP.settings.ShowPage("Options"); HP.settings:Show(); return
    elseif command=="guide" then HP.db.hidden=false;HP.ChooseGuideBook("leveling");if HP.Call(InCombatLockdown)~=true then HP.UseGuide() end;return
    elseif command=="live" or command=="quests" then HP.demo=false;HP.db.mode="quests";HP.db.hidden=false;HP.ChooseGuideBook("leveling")
    elseif command=="sync" then HP.Sync(); return
    elseif command=="reset" then if HP.auxiliaryActive then HP.RescanCurrentGuide();return end;if HP.state then HP.state.index=1; HP.state.skipped={}; HP.db.arrivals={} end; HP.Sync(); return
    elseif command=="show" then HP.db.hidden=false
    elseif command=="hide" then HP.db.hidden=true
    elseif command=="pause" then HP.db.paused=not HP.db.paused
    elseif command=="next" then HP.Move(1); return
    elseif command=="back" then HP.Move(-1); return
    elseif command=="minimap" then
        if HP.minimapButton then
            HP.db.minimapHidden=not HP.db.minimapHidden
            if HP.db.minimapHidden then HP.minimapButton:Hide() else HP.minimapButton:Show() end
        end
    elseif command=="arrow" then HP.db.arrowHidden=not HP.db.arrowHidden; HP.UpdateOptionLabels()
    elseif command=="resetarrow" then HP.db.arrowPosition=nil; HP.ApplyArrowSettings()
    elseif command=="transparent" then HP.db.transparent=not HP.db.transparent; HP.ApplyTransparency()
    elseif command=="clearway" then HP.manualWaypoint=nil
    elseif command=="scale" then
        local scale=tonumber(input:match("^scale%s+([%d.]+)%s*$"))
        if not scale or scale<.7 or scale>1.6 then say("Use /dudeding scale 0.7-1.6"); return end
        HP.db.scale=scale;if HP.Call(InCombatLockdown)==true then HP.pendingGuideScale=true else HP.frame:SetScale(scale) end
    elseif command=="way" then
        local map,x,y=input:match("^way%s+(%d+)%s+([%d.]+)%s+([%d.]+)%s*$")
        map,x,y=tonumber(map),tonumber(x),tonumber(y)
        if not map or not x or not y or x<0 or x>100 or y<0 or y>100 then say("Use /dudeding way MAP_ID X Y (0-100)."); return end
        HP.manualWaypoint={mapID=map,x=x/100,y=y/100}
    elseif command=="build" or command=="debug" then
        local version,build,_,interface=GetBuildInfo()
        say(string.format("Version %s; build %s; interface %s",version,build,interface))
        local p=HP.DetectCharacter()
        say((p.race or "?").." / "..(p.class or "?").." / level "..p.level)
        if HP.route then say(HP.route.title.."; step "..HP.state.index.."; "..HP.route.source) end
        return
    else
        say("/dudeding guide | quests | sync | reset | preview | show | hide | pause")
        say("/dudeding next | back | minimap | scale NUMBER | debug")
        say("/dudeding way MAP_ID X Y | clearway"); return
    end
    HP.Refresh()
end

