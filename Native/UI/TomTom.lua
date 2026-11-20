-- Optional bridge to TomTom: when it is installed and the setting allows it, Ding hands
-- its target to TomTom and the player follows TomTom's arrow. Only TomTom's public API
-- is called (AddWaypoint / RemoveWaypoint); nothing of TomTom is copied into Ding.
local _, HP = ...
local Ding = HP.Native

local B = {}
Ding.TomTom = B

local function api()
    local tt = _G.TomTom
    if type(tt) == "table" and type(tt.AddWaypoint) == "function" then return tt end
end

-- TomTom is loaded and has not failed this session.
function B:Available()
    return api() ~= nil and not self.failed
end

-- Ding's own arrow steps aside only while TomTom really shows the target.
function B:Active()
    return Ding.db.arrow.tomtom and self:Available()
end

local function keyOf(point)
    return ("%s:%.2f:%.2f:%s"):format(tostring(point.map), point.x, point.y, tostring(point.label))
end

-- Points TomTom at `point` ({ map = uiMapID, x, y = 0-100, label }). Same point as last
-- time: nothing to do, so a waypoint the player cleared in TomTom stays cleared.
-- Returns false when TomTom refused it: the caller falls back to Ding's arrow.
function B:Show(point)
    local tt = api()
    if not tt or not point or not point.map then return false end
    local key = keyOf(point)
    if key == self.key and not self.clearPending then return true end
    if self:Clear() == false then return false end
    local ok, uid = pcall(tt.AddWaypoint, tt, point.map, point.x / 100, point.y / 100, {
        title = Ding.TITLE .. " : " .. (point.label or ""),
        from = Ding.TITLE,
        persistent = false, minimap = true, world = true, crazy = true, silent = true,
        cleardistance = 0,   -- Ding decides when the step is done
    })
    if not ok or uid == nil then
        self.failed = true
        Ding:Debug("TomTom:AddWaypoint failed: " .. tostring(uid))
        return false
    end
    self.uid, self.key = uid, key
    return true
end

-- Only a pin on TomTom's world map and minimap for `point` (no arrow of TomTom's): the world
-- map mark of a client without map waypoints. True if set.
function B:MarkWorld(point)
    local tt = api()
    if not tt or self.failed or not point or not point.map then return false end
    if self:ClearWorld() == false then return false end
    local ok, uid = pcall(tt.AddWaypoint, tt, point.map, point.x / 100, point.y / 100, {
        title = Ding.TITLE .. " : " .. (point.label or ""),
        from = Ding.TITLE,
        persistent = false, minimap = false, world = true, crazy = false, silent = true,
        cleardistance = 0,
    })
    if not ok or uid == nil then return false end
    self.worldUid = uid
    return true
end

function B:ClearWorld()
    local tt, uid = api(), self.worldUid
    if not uid then return true end
    if not tt or type(tt.RemoveWaypoint) ~= "function" then return false end
    local ok, result = pcall(tt.RemoveWaypoint, tt, uid)
    if not ok or result == false then return false end
    self.worldUid = nil
    return true
end

function B:Clear()
    local tt, uid = api(), self.uid
    if not uid then self.key, self.clearPending, self.clearRetryAt = nil, nil, nil; return true end
    if self.clearRetryAt and GetTime() < self.clearRetryAt then return false end
    if not tt or type(tt.RemoveWaypoint) ~= "function" then self.clearPending = true; self.clearRetryAt = GetTime() + 0.5; return false end
    local ok, result = pcall(tt.RemoveWaypoint, tt, uid)
    if not ok or result == false then self.clearPending = true; self.clearRetryAt = GetTime() + 0.5; return false end
    self.uid, self.key, self.clearPending, self.clearRetryAt = nil, nil, nil, nil
    return true
end
