local addonName, addon = ...

local framesLocked = false
local framesVisible = true
local framesTextureVisible = true
local framesScale = 1.0
local SCALE_ADJUSTMENT = 0.1
local MOVE_FRAME_VALUE = 0.1

-- local MOVE_FRAME_UP = 0.01
-- local MOVE_FRAME_DOWN = -0.01

BetterAnchorsDB = BetterAnchorsDB or {}
BetterAnchors = BetterAnchors or {}

-- set the default values of the saved variables if they are not set
local function setDefaultValues()
    BetterAnchorsDB = BetterAnchorsDB or {}
    BetterAnchorsDB["positions"] = BetterAnchorsDB["positions"] or {
        ["Tank Icons"] = { "TOP", "TOP", -280, -228.9999847412109 },
        ["Cast Bars"] = { "CENTER", "CENTER", -1, 253 },
        ["Player List"] = { "CENTER", "CENTER", -272, -75 },
        ["Raid Leader List One"] = { "TOPLEFT", "TOPLEFT", 446.9999694824219, -148 },
        ["Icons"] = { "CENTER", "CENTER", -318, 125.9999923706055 },
        ["Co-Tank Icons"] = { "TOP", "TOP", -359, -227 },
        ["Map Frame"] = { "TOP", "TOP", -2, -75 },
        ["Player Circle"] = { "CENTER", "CENTER", -1, 1 },
        ["Raid Leader List Two"] = { "LEFT", "LEFT", 447.9999694824219, -17 },
        ["Text Warnings Two"] = { "CENTER", "CENTER", -0.1790575981140137, 108.3590393066406 },
        ["Private Auras"] = { "CENTER", "CENTER", -253, 55.99999618530273 },
        ["Text Warnings One"] = { "CENTER", "CENTER", -1, 154 },
    }
    BetterAnchorsDB["Scale"] = BetterAnchorsDB["Scale"] or framesScale
    BetterAnchorsDB["framesVisible"] = BetterAnchorsDB["framesVisible"] or framesVisible
    BetterAnchorsDB["framesTextureVisible"] = BetterAnchorsDB["framesTextureVisible"] or framesTextureVisible
    BetterAnchorsDB["framesLocked"] = BetterAnchorsDB["framesLocked"] or framesLocked
end

--- List of Frames that get created ---
BetterAnchors.ANCHOR_FRAMES = {
    { name = "Cast Bars",            width = 300, height = 150, scale = 1, },
    { name = "Text Warnings One",    width = 320, height = 40,  scale = 1, },
    { name = "Text Warnings Two",    width = 320, height = 40,  scale = 1, },
    { name = "Player Circle",        width = 170, height = 170, scale = 1, },
    { name = "Icons",                width = 180, height = 60,  scale = 1, },
    { name = "Tank Icons",           width = 60,  height = 200, scale = 1, },
    { name = "Co-Tank Icons",        width = 60,  height = 200, scale = 1, },
    { name = "Private Auras",        width = 70,  height = 70,  scale = 1, },
    { name = "Player List",          width = 150, height = 180, scale = 1, },
    { name = "Raid Leader List One", width = 150, height = 300, scale = 1, },
    { name = "Raid Leader List Two", width = 150, height = 300, scale = 1, },
    { name = "Map Frame",            width = 300, height = 180, scale = 1 }
}

local frames = {} -- Store the Frames

local function CreateAnchorFrameByName(name, width, height, scale)
    -- Create a frame
    local frame = CreateFrame("Frame", name, UIParent)
    frame:SetSize(width, height)
    frame:SetScale(scale)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    frame:SetFrameStrata("HIGH")

    -- Separate the frame from the backgroundTexture
    frame.backgroundTexture = frame:CreateTexture(nil, "BACKGROUND")
    frame.backgroundTexture:SetAllPoints(frame)
    frame.backgroundTexture:SetColorTexture(0, 0, 0, 0.5)

    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        BetterAnchorsDB["positions"][name] = { point, relativePoint, xOfs, yOfs }
    end)

    -- Add a text label to the frame
    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.label:SetAllPoints()
    frame.label:SetText(name)

    -- Create the up button
    local upButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    upButton:SetSize(25, 25)                                         -- Set the size of the button
    upButton:SetText("^")                                            -- Set the text of the button to an up arrow
    upButton:SetPoint("RIGHT", frame, "RIGHT", 0, 0)                 -- Position the button to the right of the frame
    upButton:SetScript("OnClick", function() moveFrameUp(frame) end) -- Add the moveFrameUp function to the button

    -- Create the down button
    local downButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    downButton:SetSize(25, 25)                                           -- Set the size of the button
    downButton:SetText("v")                                              -- Set the text of the button to a down arrow
    downButton:SetPoint("TOP", upButton, "BOTTOM", 0, 0)                 -- Position the button below the up button
    downButton:SetScript("OnClick", function() moveFrameDown(frame) end) -- Add the moveFrameDown function to the button -- Position the button below the up button

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

    -- Restore the state of togleFrameTexutres
    if BetterAnchorsDB["framesTextureVisible"] then
        addon:showAllTextures()
    else
        addon:hideAllTextures()
    end
end

function addon:lockAllFrames()
    -- addon:SetOptionFramesLocked(true)
    addon:print("Locking Frames")
    for name, frame in pairs(frames) do
        frame:SetMovable(false)
        frame:EnableMouse(false)
        framesLocked = true
    end
end

function addon:unlockAllFrames()
    -- addon:SetOptionFramesLocked(false)
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

--------------------------------_
----- Hide Show Frames ---------
--------------------------------


-- function addon:hideAllFrames()
--     addon:SetOptionFramesVisible(false)
--     for name, frame in pairs(frames) do
--         -- frame:Hide()
--         frame.backgroundTexture:Hide()
--         framesVisible = false
--     end
--     addon:print("Anchors are now hidden")
-- end

-- function addon:showAllFrames()
--     addon:SetOptionFramesVisible(true)
--     for name, frame in pairs(frames) do
--         -- frame:Show()
--         frame.backgroundTexture:Show()
--         framesVisible = true
--     end
--     addon:print("Anchors are now visible")
-- end


--------------------------------
----- Texture show hide --------
--------------------------------
function addon:hideAllTextures()
    for name, frame in pairs(frames) do
        frame.backgroundTexture:Hide()
        frame.label:Hide()
    end
    addon:print("Anchors are now hidden")
end

function addon:showAllTextures()
    for name, frame in pairs(frames) do
        frame.backgroundTexture:Show()
        frame.label:Show()
    end
    addon:print("Anchors are now visible")
end

function addon:toggleTextures()
    local anyTextureVisible = false
    for name, frame in pairs(frames) do
        if frame.backgroundTexture:IsShown() then
            anyTextureVisible = true
            break
        end
    end

    if anyTextureVisible then
        addon:hideAllTextures()
    else
        addon:showAllTextures()
    end
end

-- function addon:toggleFrames()
--     local anyFrameVisible = false
--     for name, frame in pairs(frames) do
--         if frame.backgroundTexture:IsShown() then
--             anyFrameVisible = true
--             break
--         end
--     end

--     if anyFrameVisible then
--         addon:hideAllFrames()
--     else
--         addon:showAllFrames()
--     end
-- end



function addon:moveFrameUp(frameName)
    local frame = _G[frameName]
    if frame then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + MOVE_FRAME_VALUE)
    end
end

function addon:moveFrameDown(frameName)
    local frame = _G[frameName]
    if frame then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        frame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs - MOVE_FRAME_VALUE)
    end
end

function addon:moveFrameLeft(frameName)
    local frame = _G[frameName]
    if frame then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        frame:SetPoint(point, relativeTo, relativePoint, xOfs - MOVE_FRAME_VALUE, yOfs)
    end
end

function addon:moveFrameRight(frameName)
    local frame = _G[frameName]
    if frame then
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        frame:SetPoint(point, relativeTo, relativePoint, xOfs + MOVE_FRAME_VALUE, yOfs)
    end
end

------!SECTION Slash Commands !------
---- Toggle Commmand ------

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
    elseif msg == "show" then -- Change Alpha of the Frames
        addon:showAllTextures()
        -- frame:SetAlpha(1)
    elseif msg == "hide" then -- Change Alpha of the Frames
        addon:hideAllTextures()
        -- frame:SetAlpha(0)
    else
        addon:toggleTextures()
        addon:toggleOptionsFrame()
        addon:toggleUnlockAnchorFrames()
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

function addon:errorPrint(...)
    local message = "|cffff0000ERROR:|r |cff00ff00BetterAnchors:|r " .. table.concat({ ... }, " ")
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



-- TODO lock the player circle frame and add a lock icon
-- TODO message that your version of BA is out of date and should update asap
