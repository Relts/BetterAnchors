local addonName, addon = ...
local framesLocked = true
local framesVisible = true
local framesScale = 1.0

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

BetterAnchorsDB = BetterAnchorsDB or {}
--- List of Frames that get created ---
local ANCHOR_FRAMES = {
    { name = "Cast Bars",            width = 300, height = 350 },
    { name = "Text Warnings One",    width = 320, height = 40, },
    { name = "Text Warnings Two",    width = 320, height = 40, },
    { name = "Player Circle",        width = 170, height = 170 },
    { name = "Icons",                width = 180, height = 60, },
    { name = "Tank Icons",           width = 60,  height = 200 },
    { name = "Co-Tank Icons",        width = 60,  height = 200 },
    { name = "Private Auras",        width = 70,  height = 70, },
    { name = "Player List",          width = 150, height = 180 },
    { name = "Raid Leader List One", width = 150, height = 300 },
    { name = "Raid Leader List Two", width = 150, height = 300 },
}

local frames = {} -- Store the Frames

local function CreateAnchorFrameByName(name, width, height, scale)
    -- Create a frame
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetScale(scale)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        BetterAnchorsDB["positions"][name] = { point, relativePoint, xOfs, yOfs }
        -- call function here to store the position in the saved variables
    end)
    -- Add a text label to the frame
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetAllPoints()
    label:SetText(name)
    frame:Show()
    --frame:Hide()
    frames[name] = frame -- Store the frame in the frames table
end
----- List of Anchor Frames ----
local function initAnchorFrames()
    for i, frame in ipairs(ANCHOR_FRAMES) do
        CreateAnchorFrameByName(frame.name, frame.width, frame.height, framesScale)
    end
end
-- fall back function that saves the positions
-- Save the current position of each frame when the player logs out
function addon:PLAYER_LOGOUT()
    for name, frame in pairs(frames) do
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()

        BetterAnchorsDB["positions"][name] = { point, relativePoint, xOfs, yOfs }
    end
    -- save the state of toggleUnlockAnchorFrames
    BetterAnchorsDB["framesLocked"] = framesLocked
    BetterAnchorsDB["framesVisible"] = framesVisible
end

local function setDefaultValues()
    if BetterAnchorsDB["framesVisible"] == nil then
        BetterAnchorsDB["framesVisible"] = framesVisible
    end
    if BetterAnchorsDB["framesLocked"] == nil then
        BetterAnchorsDB["framesLocked"] = framesLocked
    end
end
-- Restore the position of each frame when the player logs in
function addon:PLAYER_LOGIN()
    initAnchorFrames()
    setDefaultValues()
    for name, frame in pairs(frames) do
        print("Restoring position of " .. name)
        if BetterAnchorsDB["positions"][name] then
            local point, relativePoint, xOfs, yOfs = unpack(BetterAnchorsDB["positions"][name])
            print(name, point, relativePoint, xOfs, yOfs)
            frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        end
    end
    -- Restore the state of toggleUnlockAnchorFrames
    if BetterAnchorsDB["framesLocked"] then
        addon:lockAllFrames()
    else
        addon:unlockAllFrames()
    end

    -- Restore the state of toggleFrames
    if BetterAnchorsDB["framesVisible"] then
        addon:showAllFrames()
    else
        addon:hideAllFrames()
    end
end

function addon:lockAllFrames()
    addon:SetOptionFramesLocked(true)
    print("Locking Frames")
    for name, frame in pairs(frames) do
        frame:SetMovable(false)
        frame:EnableMouse(false)
        framesLocked = true
    end
end

function addon:unlockAllFrames()
    addon:SetOptionFramesLocked(false)
    print("Unlocking Frames")
    for name, frame in pairs(frames) do
        frame:SetMovable(true)
        frame:EnableMouse(true)
        framesLocked = false
    end
end

function addon:toggleUnlockAnchorFrames()
    if framesLocked then
        addon:unlockAllFrames()
        print("Frames are now unlocked")
    else
        addon:lockAllFrames()
        print("Frames are now locked")
    end
end

function addon:hideAllFrames()
    addon:SetOptionFramesVisible(false)
    for name, frame in pairs(frames) do
        frame:Hide()
        framesVisible = false
    end
end

function addon:showAllFrames()
    addon:SetOptionFramesVisible(true)
    for name, frame in pairs(frames) do
        frame:Show()
        framesVisible = true
    end
end

function addon:toggleFrames()
    for name, frame in pairs(frames) do
        if frame:IsShown() then
            addon:hideAllFrames()
            print("Anchors are now hidden")
        else
            addon:showAllFrames()
            print("Anchors are now visible")
        end
    end
end

-- REVIEW add a scale function to the frames
function addon:setFrameScale(scale)
    for name, frame in pairs(frames) do
        frame:SetScale(scale)
    end
end

-- add scale sub table to the saved variables
-- index by names
-- set the scale of each fram
-- scale changed event
-- lines 44 check for how its done
-- 92 - 96 check how this was done.

------!SECTION Slash Commands !------
---- Toggle Commmand ------
SLASH_TOGGLEFRAMES1 = "/betteranchors"
SlashCmdList["TOGGLEFRAMES"] = function(msg)
    addon:toggleFrames()
end

SLASH_BA1 = "/ba"
SlashCmdList["BA"] = function(msg)
    if msg == "lock" or msg == 'aiaicaptain' then
        addon:lockAllFrames()
        print("Frames are now locked")
    elseif msg == "unlock" then
        addon:unlockAllFrames()
        print("Frames are now unlocked")
    elseif msg == "config" then
        InterfaceOptionsFrame_OpenToCategory("BetterAnchors")
        InterfaceOptionsFrame_OpenToCategory("BetterAnchors")
        print("Opening BetterAnchors Config")
    else
        addon:toggleFrames()
    end
end

---- Lock Command ------
SLASH_LOCKFRAMES1 = "/lockanchors"
SlashCmdList["LOCKFRAMES"] = function(msg)
    addon:toggleLockFrames()
end

-- VDT Debug Table
local function debugTable(t)
    if not C_AddOns.IsAddOnLoaded("ViragDevTool") then
        print("ViragDevTool is not loaded")
        return
    end
    ViragDevTool:AddData(t)
end

local addonEventFrame = CreateFrame("Frame")
addonEventFrame:SetScript("OnEvent", function(self, event, ...)
    debugTable(addon)
    if addon[event] then
        addon[event](addon, ...)
    end
end)

-- login and reload events.
addonEventFrame:RegisterEvent("PLAYER_LOGIN")
addonEventFrame:RegisterEvent("PLAYER_LOGOUT")


-- Print Function
local originalPrint = print
print = function(...)
    local message = "|cff00ff00BetterAnchors:|r " .. table.concat({ ... }, " ")
    DEFAULT_CHAT_FRAME:AddMessage(message, 1, 1, 1) -- Display in white
end

-- TODO Another Function that adds the frame to the edit mode
-- TODO add scale to the frames
