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

    -- Add a text label to the frame
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetAllPoints()
    label:SetText(name)
    frame:Show()
end

----- List of Anchor Frames ----
local function initAnchorFrames()
    for i, frame in ipairs(ANCHOR_FRAMES) do
        CreateAnchorFrameByName(frame.name, frame.width, frame.height, framesScale)
    end
end


-- Restore the position of each frame when the player logs in
function addon:PLAYER_LOGIN()
    initAnchorFrames()
end
