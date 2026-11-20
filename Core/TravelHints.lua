local _,HP=...
HP.itemData[6948]=HP.itemData[6948] or {name='Hearthstone',mobs={},vendors={}}
local function playerLocation()
    local map=HP.Call(C_Map and C_Map.GetBestMapForUnit,'player')
    local position=map and HP.Call(C_Map and C_Map.GetPlayerMapPosition,map,'player')
    local x,y;if position then x,y=HP.Call(position.GetXY,position) end
    if type(map)=='number' and type(x)=='number' and type(y)=='number' then return {mapID=map,x=x,y=y} end
end
function HP.RecordHearthstoneBind()
    local location=playerLocation();local name=HP.Call(GetBindLocation)
    if location and type(name)=='string' and name~='' then HP.db.hearthBind={name=name,location=location} end
end
local function distance(a,b)
    local n,w,i=HP.WorldPoint(a);local bn,bw,bi=HP.WorldPoint(b)
    if n and bn and i==bi then return math.sqrt((n-bn)^2+(w-bw)^2) end
    if a and b and a.mapID==b.mapID then
        local width,height=HP.Call(C_Map and C_Map.GetMapWorldSize,a.mapID)
        if type(width)=='number' and type(height)=='number' then return math.sqrt(((a.x-b.x)*width)^2+((a.y-b.y)*height)^2) end
    end
end
function HP.HearthstoneAdvice(step)
    if not step or not step.questID or HP.abandonQuest or HP.review or HP.demo or HP.db.mode=='quests' or HP.Done(step) or HP.ItemCount(6948)<1 then return end
    local bind=HP.db.hearthBind;local name=HP.Call(GetBindLocation)
    if not bind or type(name)~='string' or name~=bind.name then return end
    local start,duration,enabled=HP.Call(C_Container and C_Container.GetItemCooldown or C_Item and C_Item.GetItemCooldown or GetItemCooldown,6948)
    if type(start)~='number' or type(duration)~='number' or enabled==0 or start+duration>(HP.Call(GetTime) or 0) then return end
    local target=HP.StepLocation(step);local player=playerLocation()
    if not target or not player or not bind.location or bind.location.mapID~=target.mapID then return end
    local after=distance(bind.location,target);local before=distance(player,target)
    if after and ((before and before>after+600) or (not before and player.mapID~=target.mapID and after<300)) then
        return 'Use Hearthstone to return to '..bind.name..', then follow the waypoint.'
    end
end
local rows=HP.StepRows
function HP.StepRows(step,compact)
    local result=rows(step,compact);local advice=not compact and HP.HearthstoneAdvice(step)
    if advice then table.insert(result,1,{kind='use',text=advice,questID=step.questID,itemID=6948,icon=HP.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon,6948)}) end
    return result
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local events=CreateFrame('Frame',nil,UIParent);HP.travelHintEvents=events
    for _,event in ipairs({'HEARTHSTONE_BOUND','UNIT_SPELLCAST_SUCCEEDED','PLAYER_ENTERING_WORLD','ZONE_CHANGED_NEW_AREA','SPELL_UPDATE_COOLDOWN'}) do pcall(events.RegisterEvent,events,event) end
    events:SetScript('OnEvent',function(_,event,unit,castGUID,spellID)
        if event=='HEARTHSTONE_BOUND' then HP.RecordHearthstoneBind();HP.Refresh()
        elseif event=='UNIT_SPELLCAST_SUCCEEDED' and unit=='player' and spellID==8690 then HP.hearthOrigin=playerLocation()
        elseif event=='SPELL_UPDATE_COOLDOWN' and HP.db.hearthBind then
            local start,duration=HP.Call(C_Container and C_Container.GetItemCooldown or C_Item and C_Item.GetItemCooldown or GetItemCooldown,6948)
            local expiry=type(start)=='number' and type(duration)=='number' and start+duration
            if expiry and expiry~=HP.hearthCooldownExpiry then HP.hearthCooldownExpiry=expiry;HP.Refresh() end
        elseif HP.hearthOrigin then
            local current=playerLocation();local origin=HP.hearthOrigin
            if current and (current.mapID~=origin.mapID or math.abs(current.x-origin.x)+math.abs(current.y-origin.y)>.01) then HP.RecordHearthstoneBind();HP.hearthOrigin=nil;HP.Refresh() end
        end
    end)
end
