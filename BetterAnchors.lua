local addonName, addon = ...
local framesLocked = true
local framesVisible = true
local framesScale = 1.0
local SCALE_ADJUSTMENT = 0.1

BetterAnchorsDB = BetterAnchorsDB or {}
BetterAnchors = BetterAnchors or {}

-- set the default values of the saved variables if they are not set
local function setDefaultValues()
    BetterAnchorsDB = BetterAnchorsDB or {}
    if BetterAnchorsDB["positions"] == nil then
        BetterAnchorsDB["positions"] = BetterAnchorsDB["positions"] or { "CENTER", "CENTER", 0, 0 }
    end
    if BetterAnchorsDB["Scale"] == nil then
        BetterAnchorsDB["Scale"] = BetterAnchorsDB["Scale"] or framesScale
    end
    if BetterAnchorsDB["framesVisible"] == nil then
        BetterAnchorsDB["framesVisible"] = framesVisible
    end
    if BetterAnchorsDB["framesLocked"] == nil then
        BetterAnchorsDB["framesLocked"] = framesLocked
    end
end

--- List of Frames that get created ---
BetterAnchors.ANCHOR_FRAMES = {
    { name = "Cast Bars",            width = 300, height = 350, scale = 1, },
    { name = "Text Warnings One",    width = 320, height = 40,  scale = 1, },
    { name = "Text Warnings Two",    width = 320, height = 40,  scale = 1, },
    { name = "Player Circle",        width = 170, height = 170, scale = 1, },
    { name = "Icons",                width = 180, height = 60,  scale = 1, },
    { name = "Tank Icons",           width = 60,  height = 200, scale = 1, },
    { name = "Co-Tank Icons",        width = 60,  height = 200, scale = 1, },
    { name = "Private Auras",        width = 70,  height = 70,  scale = 1, },
    { name = "Player List",          width = 150, height = 180, scale = 1, },
    { name = "Raid Leader List One", width = 150, height = 300, scale = 1, },
    { name = "Raid Leader List Two", width = 150, height = 300, scale = 1, }
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

    -- Seperate the frame from the backgroundTexture

    frame:SetBackdropColor(0, 0, 0, 0.5)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        BetterAnchorsDB["positions"][name] = tostring({ point, relativePoint, xOfs, yOfs })
        -- call function here to store the position in the saved variables
    end)

    -- Add a text label to the frame
    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    label:SetAllPoints()
    label:SetText(name)
    frame:Show()
    frames[name] = frame -- Store the frame in the frames table
end
----- List of Anchor Frames ----
local function initAnchorFrames()
    for i, frame in ipairs(BetterAnchors.ANCHOR_FRAMES) do
        CreateAnchorFrameByName(frame.name, frame.width, frame.height, BetterAnchorsDB.Scale or frame.scale)
    end
end

-- fall back function that saves the positions
-- Save the current position of each frame when the player logs out
function addon:PLAYER_LOGOUT()
    for name, frame in pairs(frames) do
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        BetterAnchorsDB["positions"][name] = { point, relativePoint, xOfs, yOfs }
        BetterAnchorsDB[name] = BetterAnchorsDB[name] or {}
        BetterAnchorsDB[name].Scale = frame:GetScale()
    end
    -- save the state of toggleUnlockAnchorFrames
    BetterAnchorsDB["framesLocked"] = framesLocked
    BetterAnchorsDB["framesVisible"] = framesVisible
end

-- Restore the position of each frame when the player logs in
function addon:PLAYER_LOGIN()
    setDefaultValues()
    initAnchorFrames()
    for name, frame in pairs(frames) do
        addon:print("Restoring position of " .. name)
        if BetterAnchorsDB["positions"][name] then
            local point, relativePoint, xOfs, yOfs = unpack(BetterAnchorsDB["positions"][name])
            addon:print(name, point, relativePoint, xOfs, yOfs)
            frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        end
        -- Add the scale restoration code here
        if BetterAnchorsDB[name] and BetterAnchorsDB[name].Scale then
            frame:SetScale(BetterAnchorsDB[name].Scale)
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
    addon:print("Locking Frames")
    for name, frame in pairs(frames) do
        frame:SetMovable(false)
        frame:EnableMouse(false)
        framesLocked = true
    end
end

function addon:unlockAllFrames()
    addon:SetOptionFramesLocked(false)
    addon:print("Unlocking Frames")
    for name, frame in pairs(frames) do
        frame:SetMovable(true)
        frame:EnableMouse(true)
        framesLocked = false
    end
end

function addon:toggleUnlockAnchorFrames()
    if framesLocked then
        addon:unlockAllFrames()
    else
        addon:lockAllFrames()
    end
end

function addon:hideAllFrames()
    addon:SetOptionFramesVisible(false)
    for name, frame in pairs(frames) do
        frame:Hide()
        framesVisible = false
    end
    addon:print("Anchors are now hidden")
end

function addon:showAllFrames()
    addon:SetOptionFramesVisible(true)
    for name, frame in pairs(frames) do
        frame:Show()
        framesVisible = true
    end
    addon:print("Anchors are now visible")
end

function addon:toggleFrames()
    for name, frame in pairs(frames) do
        if frame:IsShown() then
            addon:hideAllFrames()
        else
            addon:showAllFrames()
        end
    end
end

-- Scale Frames by name
function addon:increaseFrameScaleByName(name)
    local frame = frames[name]
    if frame then
        local currentScale = frame:GetScale()
        local newScale = currentScale + SCALE_ADJUSTMENT
        frame:SetScale(newScale)
        BetterAnchorsDB[name] = BetterAnchorsDB[name] or {}
        BetterAnchorsDB[name].Scale = newScale
    else
        print("Frame with name " .. name .. " not found.")
    end
end

function addon:decreaseFrameScaleByName(name)
    local frame = frames[name]
    if frame then
        local currentScale = frame:GetScale()
        local newScale = currentScale - SCALE_ADJUSTMENT
        frame:SetScale(newScale)
        BetterAnchorsDB[name] = BetterAnchorsDB[name] or {}
        BetterAnchorsDB[name].Scale = newScale
    else
        print("Frame with name " .. name .. " not found.")
    end
end

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
    elseif msg == "unlock" then
        addon:unlockAllFrames()
    elseif msg == "config" then
        InterfaceOptionsFrame_OpenToCategory("BetterAnchors")
        InterfaceOptionsFrame_OpenToCategory("BetterAnchors")
        addon:print("Opening BetterAnchors Config")
    else
        addon:toggleFrames()
        addon:showOptionsFrame()
    end
end

-- REVIEW add a scale command
SLASH_BAS1 = "/bas"
SlashCmdList["BAS"] = function(msg)
    if msg == "up" then
        addon:setFrameScale(framesScale + 0.1)
        addon:print("Frames are now scaled up")
    elseif msg == "down" then
        addon:setFrameScale(framesScale - 0.1)
        addon:print("Frames are now scaled down")
    else
        addon:print("Invalid command")
    end
end

-- VDT Debug Table
function addon:debugTable(t)
    if not C_AddOns.IsAddOnLoaded("ViragDevTool") then
        print("ViragDevTool is not loaded")
        return
    end
    ViragDevTool:AddData(t)
end

local addonEventFrame = CreateFrame("Frame")

addonEventFrame:SetScript("OnEvent", function(self, event, ...)
    addon:debugTable(addon)
    if addon[event] then
        addon[event](addon, ...)
    end
end)

-- Print Function
function addon:print(...)
    local message = "|cff00ff00BetterAnchors:|r " .. table.concat({ ... }, " ")
    DEFAULT_CHAT_FRAME:AddMessage(message, 1, 1, 1) -- Display in white
end

-- login and reload events.
-- First Time login event, creates the databse
local function eventHandler(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "BetterAnchors" then
        if BetterAnchorsDB == nil then
            setDefaultValues()
        end
        -- Run the PLAYER_LOGIN code here, after the saved variables have been initialized
        addon:PLAYER_LOGIN()
    end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", eventHandler)
f:RegisterEvent("ADDON_LOADED")

addonEventFrame:RegisterEvent("PLAYER_LOGOUT")


-- TODO make the frames transparent when you close /ba
-- TODO add a scale slider to all the frames
-- TODO create a default postion for the frames
-- TODO create object pool for the frames
-- TODO create garbage collection
-- TODO lock the player circle frame and add a lock icon
-- TODO message that your version of BA is out of date and should update asap
-- TODO add in a new frame called Raid Map, this is for things like neltharion etc
