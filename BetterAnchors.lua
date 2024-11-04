local addonName, BetterAnchors = ...

local LibStub = _G.LibStub
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")



-- mini map icon stuff
local betterAnchorsDataBroker = LDB:NewDataObject(addonName, {
    type = "data source",
    text = addonName,
    icon = "Interface\\Addons\\BetterAnchors\\assets\\baIcon",
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


local function OnLoad()
    -- called when all files and the saved variables of this addon are loaded
    if not BetterAnchorsDB then
        BetterAnchorsDB = {}
        BetterAnchors:ShowFrames()
        BetterAnchors:ShowOptionsFrame()
    end
    -- Register the data broker with LibDBIcon
    LDBIcon:Register(addonName, betterAnchorsDataBroker, BetterAnchorsDB)
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

function BetterAnchors:ToggleMinimapIcon()
    if BetterAnchorsDB.hide then
        LDBIcon:Show(addonName)
        BetterAnchorsDB.hide = false
        BetterAnchors:addonPrint("Minimap icon shown")
    else
        LDBIcon:Hide(addonName)
        BetterAnchorsDB.hide = true
        BetterAnchors:addonPrint("Minimap icon hidden")
    end
end

function BetterAnchors:addonPrint(msg)
    print("|cff00FF00" .. addonName .. ":|r " .. msg)
end

StaticPopupDialogs["BA_RESET_POSITIONS"] = {
    text = "Are you sure you want to reset all anchor positions and scales?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        BetterAnchors:ResetPositions()
        BetterAnchors:ResetScales()
        BetterAnchors:addonPrint("All anchor positions and scales have been reset")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
-- This function is called when the Game Menu is shown
local function handleGameMenuShow(self)
    BetterAnchors:HideFrames()
    BetterAnchors:HideOptionsFrame()
    BetterAnchors:HideGrid()
end

-- Register the OnShow event for the Game Menu Frame
GameMenuFrame:HookScript("OnShow", handleGameMenuShow)

---- Chat Commands ---
SLASH_BA1 = "/ba"
SlashCmdList["BA"] = function(msg)
    if msg == "not lock" or msg == "aiaicaptain" or msg == "show" then
        BetterAnchors:ShowOptionsFrame()
        BetterAnchors:ShowFrames()
    elseif msg == "not unlock" or msg == "hide" then
        BetterAnchors:HideGrid()
        BetterAnchors:HideOptionsFrame()
        BetterAnchors:HideFrames()
    elseif msg == "reset" then
        StaticPopup_Show("BA_RESET_POSITIONS")
    elseif msg == "minimap" then
        BetterAnchors:ToggleMinimapIcon()
    elseif msg == "help" then
        BetterAnchors:addonPrint("Type /ba to toggle the options frame")
        BetterAnchors:addonPrint("Type /ba reset to reset all anchor positions and scales")
        BetterAnchors:addonPrint("Type /ba minimap to toggle the minimap icon")
    elseif msg == "version" then
        local version = C_AddOns.GetAddOnMetadata("BetterAnchors", "Version")
        BetterAnchors:addonPrint("Version: " .. version)
    elseif msg == "ver" then
        local version = C_AddOns.GetAddOnMetadata("BetterAnchors", "Version")
        BetterAnchors:addonPrint("Version: " .. version)
    else
        BetterAnchors:ToggleOptionsFrame()
        BetterAnchors:ToggleFrames()
    end
end


-- Welcome Message

local function printWelcomeMessage()
    local version = C_AddOns.GetAddOnMetadata("BetterAnchors", "Version")
    BetterAnchors:addonPrint("Type /ba to toggle the options or /ba help for more commands | Version: " .. version)
end


-- local function printWelcomeMessage()
--     local version = C_AddOns.GetAddOnMetadata("BetterAnchors", "Version")
--     BetterAnchors:addonPrint("Welcome to Better Anchors! Version: " .. version)
--     BetterAnchors:addonPrint("Type /ba to toggle the options frame")
--     BetterAnchors:addonPrint("Type /ba help for more commands")
-- end

C_Timer.After(3, printWelcomeMessage)

-- Dev Mode
-- C_Timer.After(5, function()
--     BetterAnchors:ToggleOptionsFrame()
--     BetterAnchors:ToggleFrames()
--     print("Dev Mode")
-- end)

-- function BetterAnchors:OpacityTest()


-- end
