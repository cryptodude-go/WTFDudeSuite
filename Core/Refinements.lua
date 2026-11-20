local _,HP=...
local build=HP.BuildGuideRows
function HP.BuildGuideRows()
    local rows={}
    for _,row in ipairs(build()) do if not row.stepIndex or row.stepIndex==HP.state.index then rows[#rows+1]=row end end
    return rows
end
function HP.HideDetachedControls()
    local hidden=HP.db.hidden or HP.db.paused or HP.demo
    for _,b in ipairs(HP.questItemBar.inlineButtons or {}) do
        if hidden then if HP.Call(InCombatLockdown)~=true then b:Hide() end;b.icon:Hide();b.count:Hide();b.cooldown:Hide() else b.icon:Show();b.count:Show() end
    end
    if hidden then
        for _,b in ipairs(HP.frame.targetButtons or {}) do
            if HP.Call(InCombatLockdown)~=true then b:Hide() end
            b.icon:Hide()
        end
    else
        for _,b in ipairs(HP.frame.targetButtons or {}) do b.icon:Show() end
    end
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local f=HP.frame
    f.plus:Hide();f.toolbarBackground:Hide()
    f.zoneHeader:ClearAllPoints();f.zoneHeader:SetPoint('TOPLEFT',f,'TOPLEFT',5,-28);f.zoneHeader:SetPoint('TOPRIGHT',f,'TOPRIGHT',-5,-28);f.zoneHeader:SetHeight(29)
    f.xp:Hide()
    f.previous:ClearAllPoints();f.previous:SetPoint('TOPLEFT',7,-29)
    f.next:ClearAllPoints();f.next:SetPoint('TOPRIGHT',-70,-29)
    f.pause:ClearAllPoints();f.pause:SetPoint('TOPRIGHT',-5,-29);f.pause:SetSize(55,26)
    f.tab:ClearAllPoints();f.tab:SetPoint('TOPLEFT',f,'TOPLEFT',35,-34);f.tab:SetPoint('TOPRIGHT',f,'TOPRIGHT',-102,-34)
    f.rescan=CreateFrame('Button','DudeDingRescan',f,'BackdropTemplate');f.rescan:SetSize(18,18);f.rescan:SetPoint('TOPRIGHT',f,'TOPRIGHT',-18,-56)
    f.rescan.icon=f.rescan:CreateTexture(nil,'ARTWORK');f.rescan.icon:SetAllPoints();f.rescan.icon:SetTexture('Interface\\Buttons\\UI-RotationRight-Button-Up')
    f.rescan:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
    f.rescan:SetScript('OnClick',function() HP.RescanCurrentGuide() end)
    f.rescan:SetScript('OnEnter',function(self) if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText('Rescan quest log');GameTooltip:AddLine('Refresh completed quests, active objectives and the next guide step.',1,1,1,true);GameTooltip:Show() end end)
    f.rescan:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    f.step:ClearAllPoints();f.step:SetPoint('TOP',f,'TOP',0,-59)
    f.scroll:ClearAllPoints();f.scroll:SetPoint('TOPLEFT',f,'TOPLEFT',1,-78);f.scroll:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-1,34)
    if f.SetResizeBounds then f:SetResizeBounds(330,155,850,950) end
    if not HP.db.safety095 then HP.db.markOnClick=false;HP.db.autoFitStep=true;HP.db.safety095=true
        for id,state in pairs(HP.db.routes or {}) do if id:find('^zone_') or id:find('^chapter_') then state.skipped={} end end
    end
    HP.db.flightTimes=nil;HP.db.transportSchedules=nil;HP.db.selectedTransport=nil;HP.db.travelPosition=nil;HP.db.hideFlightTimer=nil;HP.db.hideBoatTimers=nil
end
