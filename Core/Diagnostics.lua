local addonName,HP=...
function HP.ShowDiagnostics()
    if UpdateAddOnMemoryUsage then HP.Call(UpdateAddOnMemoryUsage) end
    local memory=HP.Call(GetAddOnMemoryUsage,addonName) or HP.Call(C_AddOns and C_AddOns.GetAddOnMemoryUsage,addonName)
    print('|cffffa640Dude diagnostic:|r '..tostring(HP.character.version)..' / '..tostring(HP.character.build)..'; click marking '..(HP.db.markOnClick and 'ON' or 'OFF')..'; memory '..(type(memory)=='number' and string.format('%.2f MB',memory/1024) or 'unavailable'))
    for _,entry in ipairs(HP.db.blockedActions or {}) do print(entry.time..' '..entry.event..': '..entry.addon..' → '..entry.action) end
    if #(HP.db.blockedActions or {})==0 then print('No blocked-action event recorded yet. Reproduce the warning, then /dudeding debug again.') end
    print('Detailed trace: /console taintLog 2 then /reload. Reproduce once, inspect Logs/taint.log, then /console taintLog 0.')
end
local create=HP.CreateUI
function HP.CreateUI()
    create();local events=CreateFrame('Frame',nil,UIParent);HP.diagnosticEvents=events
    for _,event in ipairs({'ADDON_ACTION_BLOCKED','ADDON_ACTION_FORBIDDEN'}) do pcall(events.RegisterEvent,events,event) end
    events:SetScript('OnEvent',function(_,event,addon,action)
        if not HP.Public(addon) or not HP.Public(action) then return end
        HP.db.blockedActions=HP.db.blockedActions or {};local entries=HP.db.blockedActions
        entries[#entries+1]={event=event,addon=tostring(addon or 'unknown'),action=tostring(action or 'unknown'),time=tostring(HP.Call(date,'%H:%M:%S') or HP.Call(GetTime) or '')}
        if #entries>20 then table.remove(entries,1) end
        if addon==addonName then print('|cffffa640Dude:|r blocked '..tostring(action)..'. /dudeding debug shows the recorded action.') end
    end)
end
