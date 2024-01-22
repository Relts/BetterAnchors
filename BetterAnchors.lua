local addonName, addon = ...

local ANCHOR_FRAMES = {
    { name = "Cast Bars",            width = 300, height = 350 },
    { name = "Text Warnings One",    width = 320, height = 40 },
    { name = "Text Warnings Two",    width = 320, height = 40 },
    { name = "Player Circle",        width = 170, height = 170 },
    { name = "Icons",                width = 180, height = 60 },
    { name = "Tank Icons",           width = 60,  height = 200 },
    { name = "Co-Tank Icons",        width = 60,  height = 200 },
    { name = "Private Auras",        width = 70,  height = 70 },
    { name = "Player List",          width = 150, height = 180 },
    { name = "Raid Leader List One", width = 150, height = 300 },
    { name = "Raid Leader List Two", width = 150, height = 300 },
}

local frames = {} -- Store the Frames

local function CreateAnchorFrameByName(name, width, height)
    -- Create a frame
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    -- Add a text label to the frame
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetAllPoints()
    label:SetText(name)
    -- frame:Show()
    frame:Hide()
    frames[name] = frame -- Store the frame in the frames table
end

----- List of Anchor Frames ----
local function initAnchorFrames()
    for i, frame in ipairs(ANCHOR_FRAMES) do
        CreateAnchorFrameByName(frame.name, frame.width, frame.height)
    end
end

initAnchorFrames()



function addon:toggleFrames()
    for name, frame in pairs(frames) do
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end

---- Toggle Commmand ------
SLASH_TOGGLEFRAMES1 = "/betteranchors"
SlashCmdList["TOGGLEFRAMES"] = function(msg)
    addon:toggleFrames()
end

-- TODO Another Function that adds the frame to the edit mode
-- TODO Another function that handles addon settings frame
-- TODO register events player_login or player_entering_world
-- TODO add scale to the frames