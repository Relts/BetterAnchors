local addonName, BetterAnchors = ...


-- TODO: minimap icon
-- TODO: ldb brocker

local function OnLoad()
    -- called when all files and the saved variables of this addon are loaded
    if not BetterAnchorsDB then
        BetterAnchorsDB = {}
        BetterAnchors:ShowFrames()
        BetterAnchors:ShowOptionsFrame()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        BetterAnchors:CreateAllAnchorFrames()
    elseif event == "ADDON_LOADED" then
        local addon = ...
        if addon == addonName then
            OnLoad()
        end
    end
end)

BetterAnchors.eventFrame = eventFrame



StaticPopupDialogs["BA_RESET_POSITIONS"] = {
    text = "Are you sure you want to reset all anchor positions and scales?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterAnchors:ResetPositions()
        BetterAnchors:ResetScales()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

---- Chat Commands ---
SLASH_BA1 = "/ba"
SlashCmdList["BA"] = function(msg)
    if msg == "lock" or msg == "aiaicaptain" or msg == "show" then
        BetterAnchors:ShowOptionsFrame()
        BetterAnchors:ShowFrames()
    elseif msg == "unlock" or msg == "hide" then
        BetterAnchors:HideOptionsFrame()
        BetterAnchors:HideFrames()
    elseif msg == "reset" then
        StaticPopup_Show("BA_RESET_POSITIONS")
    else
        BetterAnchors:ToggleOptionsFrame()
        BetterAnchors:ToggleFrames()
    end
end
