local addonName, addon = ...
local EME = LibStub("EditModeExpanded-1.0")


--- List of Frames that get created ---
local ANCHOR_FRAMES = {
    { name = "Cast Bars",            width = 300, height = 350, defaultX = 0, defaultY = 110 },
    { name = "Text Warnings One",    width = 320, height = 40,  defaultX = 0, defaultY = 120 },
    { name = "Text Warnings Two",    width = 320, height = 40,  defaultX = 0, defaultY = 130 },
    { name = "Player Circle",        width = 170, height = 170, defaultX = 0, defaultY = 140 },
    { name = "Icons",                width = 180, height = 60,  defaultX = 0, defaultY = 150 },
    { name = "Tank Icons",           width = 60,  height = 200, defaultX = 0, defaultY = 160 },
    { name = "Co-Tank Icons",        width = 60,  height = 200, defaultX = 0, defaultY = 170 },
    { name = "Private Auras",        width = 70,  height = 70,  defaultX = 0, defaultY = 180 },
    { name = "Player List",          width = 150, height = 180, defaultX = 0, defaultY = 190 },
    { name = "Raid Leader List One", width = 150, height = 300, defaultX = 0, defaultY = 200 },
    { name = "Raid Leader List Two", width = 150, height = 300, defaultX = 0, defaultY = 210 },
}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")


local frames = {} -- Store the Frames
local function CreateAnchorFrame(frameInfo)
    -- Create a frame
    local frame = CreateFrame("Frame", frameInfo.name, UIParent)
    frame:SetSize(frameInfo.width, frameInfo.height)
    frame:SetPoint("CENTER", frameInfo.defaultX, frameInfo.defaultY)
    frame.scale = 1

    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    backdrop:SetBackdropColor(0, 0, 0, 0.5)
    backdrop:SetAllPoints()
    backdrop:Hide()
    frame.backdrop = backdrop

    -- Add a text label to the frame
    local label = backdrop:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetAllPoints()
    label:SetText(frameInfo.name)
    frame:Show()

    table.insert(frames, frame)

    if not BetterAnchorsDB then
        BetterAnchorsDB = {}
    end
    EME:RegisterFrame(frame, frameInfo.name, BetterAnchorsDB[frameInfo.name])
    EME:RegisterHideable(frame)
    EME:UpdateFrameResize(frame)

    EME:RegisterCustomButton(frame, "Increase Scale", function()
        frame.scale = frame.scale + 0.1
        frame:SetScale(frame.scale)
    end)

    EME:RegisterCustomButton(frame, "Decrease Scale", function()
        frame.scale = frame.scale - 0.1
        frame:SetScale(frame.scale)
    end)
end

----- List of Anchor Frames ----
local function initAnchorFrames()
    for i, frameInfo in ipairs(ANCHOR_FRAMES) do
        CreateAnchorFrame(frameInfo)
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        initAnchorFrames()
    end
end)


local function onEnterEditMode()
    for i, frame in ipairs(frames) do
        frame.backdrop:Show()
    end
end

local function onLeaveEditMode()
    for i, frame in ipairs(frames) do
        frame.backdrop:Hide()
    end
end

EventRegistry:RegisterCallback("EditMode.Enter", onEnterEditMode)
EventRegistry:RegisterCallback("EditMode.Exit", onLeaveEditMode)


local framesInteractable
local function toggleAllFramesInteractable()
    framesInteractable = not framesInteractable
    for _, frame in ipairs(frames) do
        frame:EnableMouse(framesInteractable)
        if framesInteractable then
            frame.backdrop:Show()
        else
            frame.backdrop:Hide()
        end
    end
end


local function SlashCmdHandler()
    toggleAllFramesInteractable()
end

SlashCmdList["BETTERANCHORS"] = SlashCmdHandler
SLASH_BETTERANCHORS1 = "/betteranchors"
SLASH_BETTERANCHORS2 = "/ba"
