-- The quest reward window with several choices: a banner names the best one (Core/Rewards.lua)
-- and a ring marks its button. Ding's own frames on UIParent (UI.Banner, UI.Ring): the game's
-- quest window is only read (where the reward button stands), never anchored to or changed.
local _, HP = ...
local Ding = HP.Native
local L = Ding.L
local UI = Ding.UI

local RH = {}
Ding.RewardHint = RH

-- Names of the reward buttons across the clients' quest windows (choices come first).
local BUTTONS = { "QuestInfoRewardsFrameQuestInfoItem", "QuestInfoItem", "QuestRewardItem" }

function RH:Create()
    if self.banner then return end
    self.banner = UI.Banner("DudeDingRewardBanner", 340)
    self.marker = UI.Ring("DudeDingRewardMarker", 44)
end

-- best: { index, link, reason } from Rewards:Best.
function RH:Show(best)
    self:Create()
    self.banner.text:SetText(Ding.Rewards:Description(best))
    self.banner:SetHeight(math.max(32, self.banner.text:GetStringHeight() + 18))
    self.banner:Show()
    self.marker:Hide()
    for _, name in ipairs(BUTTONS) do
        local x, y = UI.ScreenCenter(_G[name .. best.index])
        if x then
            self.marker:ShowAt(x, y)
            break
        end
    end
end

function RH:Hide()
    if self.banner then self.banner:Hide() end
    if self.marker then self.marker:Hide() end
end

---------------------------------------------------------------------------
-- Gear upgrade in the bags (Core/Gear.lua): a banner for a few seconds.
---------------------------------------------------------------------------
local GH = {}
Ding.GearHint = GH

function GH:Show(upgrade, seconds)
    if not self.banner then self.banner = UI.Banner("DudeDingGearBanner", 340) end
    self.banner.text:SetText(L.GEAR_UPGRADE:format(upgrade.link or "?"))
    self.banner:Show()
    local token = {}
    self.token = token
    C_Timer.After(seconds or 6, function()
        if GH.token == token then GH:Hide() end
    end)
end

function GH:Hide()
    self.token = nil
    if self.banner then self.banner:Hide() end
end
