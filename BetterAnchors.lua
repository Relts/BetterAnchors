local addonName, BetterAnchors = ...

local LibStub = _G.LibStub
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")


local function OnLoad()
    -- called when all files and the saved variables of this addon are loaded
    if not BetterAnchorsDB then
        BetterAnchorsDB = {}
        BetterAnchors:ShowFrames()
        BetterAnchors:ShowOptionsFrame()
    end
end

-- mini map icon stuff
local betterAnchorsDataBroker = LDB:NewDataObject(addonName, {
    type = "data source",
    text = addonName,
    icon = "Interface\\Addons\\BetterAnchors\\assets\\onsIcon",
    OnClick = function(clickedFrame, button)
        if button == "LeftButton" then
            BetterAnchors:ToggleOptionsFrame()
            BetterAnchors:ToggleFrames()
        elseif button == "RightButton" then
            -- Handle right click
        end
    end,
    OnTooltipShow = function(tooltip)
        -- Add lines to the tooltip
        tooltip:AddLine(addonName)
        tooltip:AddLine("Left click to toggle frames")
    end,
})

-- Register the data broker with LibDBIcon
icon:Register(addonName, betterAnchorsDataBroker, BetterAnchorsDB)


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

function BetterAnchors:ToggleMinimapIcon()
    if BetterAnchorsDB.hide then
        icon:Show(addonName)
        BetterAnchorsDB.hide = false
        print("Minimap icon shown")
    else
        icon:Hide(addonName)
        BetterAnchorsDB.hide = true
        print("Minimap icon hidden")
    end
end

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
    elseif msg == "minimap" then
        BetterAnchors:ToggleMinimapIcon()
    else
        BetterAnchors:ToggleOptionsFrame()
        BetterAnchors:ToggleFrames()
    end
end


-- Dev Mode
-- C_Timer.After(5, function()
--     BetterAnchors:ToggleOptionsFrame()
--     BetterAnchors:ToggleFrames()
--     print("Dev Mode")
-- end)
