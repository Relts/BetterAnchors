local addonName, addon = ...

local framesLocked = false
local framesVisible = true
local framesTextureVisible = true
local framesScale = 1.0

addon.SCALE_ADJUSTMENT = 0.1

BetterAnchorsDB = BetterAnchorsDB or {}
BetterAnchors = BetterAnchors or {}

-- set the default values of the saved variables if they are not set
local function setDefaultValues()
    BetterAnchorsDB = BetterAnchorsDB or {}
    BetterAnchorsDB["positions"] = BetterAnchorsDB["positions"] or {
        ["BA: Tank Icons"] = { "TOP", "TOP", -280, -228.9999847412109 },
        ["BA: Cast Bars"] = { "CENTER", "CENTER", -1, 253 },
        ["BA: Player List"] = { "CENTER", "CENTER", -272, -75 },
        ["BA: Raid Leader List One"] = { "TOPLEFT", "TOPLEFT", 446.9999694824219, -148 },
        ["BA: Icons"] = { "CENTER", "CENTER", -318, 125.9999923706055 },
        ["BA: Co-Tank Icons"] = { "TOP", "TOP", -359, -227 },
        ["BA: Map Frame"] = { "TOP", "TOP", -2, -75 },
        ["BA: Player Circle"] = { "CENTER", "CENTER", 0, -20 },
        ["BA: Private Auras"] = { "CENTER", "CENTER", -253, 55.99999618530273 },
        ["BA: Text Warnings One"] = { "CENTER", "CENTER", -1, 154 },
    }
    BetterAnchorsDB["Scale"] = BetterAnchorsDB["Scale"] or framesScale
    BetterAnchorsDB["framesVisible"] = BetterAnchorsDB["framesVisible"] or framesVisible
    if BetterAnchorsDB["framesTextureVisible"] == nil then
        BetterAnchorsDB["framesTextureVisible"] = framesTextureVisible
    end

    BetterAnchorsDB["framesLocked"] = BetterAnchorsDB["framesLocked"] or framesLocked
    -- Restore the state of framesTextureVisible
    if BetterAnchorsDB.framesTextureVisible ~= nil then
        framesTextureVisible = BetterAnchorsDB.framesTextureVisible
        if framesTextureVisible then
            addon:showAllTextures()
        else
            addon:hideAllTextures()
        end
    end
    BetterAnchorsDB.optionsFramePosition = BetterAnchorsDB.optionsFramePosition or { x = 0, y = 0 }
    if BetterAnchorsDB.optionsFrameIsVisible == nil then
        BetterAnchorsDB.optionsFrameIsVisible = true
    end
    addon:manageOptionsFrame(BetterAnchorsDB.optionsFrameIsVisible)
end

--- List of Frames that get created ---
BetterAnchors.ANCHOR_FRAMES = {
    { name = "BA: Cast Bars",            width = 320, height = 120, scale = 1, moveable = true, },
    { name = "BA: Text Warnings One",    width = 350, height = 50,  scale = 1, moveable = true, },
    { name = "BA: Player Circle",        width = 130, height = 130, scale = 1, moveable = false, },
    { name = "BA: Icons",                width = 200, height = 60,  scale = 1, moveable = true, },
    { name = "BA: Tank Icons",           width = 70,  height = 215, scale = 1, moveable = true, },
    { name = "BA: Co-Tank Icons",        width = 70,  height = 215, scale = 1, moveable = true, },
    { name = "BA: Private Auras",        width = 70,  height = 70,  scale = 1, moveable = true, },
    { name = "BA: Player List",          width = 170, height = 180, scale = 1, moveable = true, },
    { name = "BA: Raid Leader List One", width = 170, height = 450, scale = 1, moveable = true, },
    { name = "BA: Map Frame",            width = 320, height = 180, scale = 1, moveable = true, }
}

local frames = {} -- Store the Frames

function addon:updateScaleLabel(name, overRideScale)
    local frame = frames[name]
    if frame then
        local newScale = overRideScale or BetterAnchorsDB[name].Scale or 1 -- Use 1 as the default scale
        frame.scaleLabel:SetText(string.format("Scale: %.1f", self:round(newScale, 1)))
        -- addon:print("New scale of " .. name .. " is: " .. newScale)
    end
end

local BA_BACKDROP_TEMPLATE = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local function createFrameInnerLine(frame, width, height, point, relativeFrame, relativePoint, offsetX, offsetY)
    local r, g, b = 1, 1, 0 -- Set the color to yellow
    local line = frame:CreateTexture(nil, "OVERLAY")
    line:SetSize(width, height)
    line:SetColorTexture(r, g, b)
    line:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
    return line
end


local function CreateAnchorFrameByName(name, width, height, scale, moveable)
    -- Create a frame
    local frame = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetScale(scale)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    frame:SetFrameStrata("HIGH")

    -- use the backdrop template
    frame:SetBackdrop(BA_BACKDROP_TEMPLATE)

    frame.lockTexture = frame:CreateTexture(nil, "OVERLAY")
    frame.lockTexture:SetAtlas("Garr_LockedBuilding")
    frame.lockTexture:SetSize(20, 20)
    frame.lockTexture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    frame.lockTexture:SetAlpha(0)
    if moveable then
        frame:RegisterForDrag("LeftButton")

        frame:SetScript("OnDragStart", function(self)
            self:StartMoving()
            self:SetUserPlaced(false)
        end)

        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
            BetterAnchorsDB["positions"][name] = { point, relativePoint, xOfs, yOfs }
            frame:SetUserPlaced(false)
        end)
    else
        frame.lockTexture:SetAlpha(1)
    end


    frame.lockFrame = function()
        if not moveable then return end
        frame:SetMovable(false)
        frame:EnableMouse(false)
    end

    frame.unlockFrame = function()
        if not moveable then return end
        frame:SetMovable(true)
        frame:EnableMouse(true)
    end

    -- Add a text label to the frame
    frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
    frame.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, 0)
    frame.label:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 0)
    frame.label:SetText(name)

    -- Add a text label for the scale
    frame.scaleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    BetterAnchorsDB[name] = BetterAnchorsDB[name] or { Scale = 1 }               -- Initialize Scale to 1
    frame.scaleLabel:SetText("Scale: " .. tostring(BetterAnchorsDB[name].Scale)) -- Retrieve the scale from the saved variables
    frame.scaleLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)

    -- Add lines to the frame (First X, then Y)
    frame.topLine = createFrameInnerLine(frame, 1, 12, "TOP", frame, "TOP", 0, 5)
    frame.bottomLine = createFrameInnerLine(frame, 1, 12, "BOTTOM", frame, "BOTTOM", 0, -5)
    frame.leftLine = createFrameInnerLine(frame, 12, 1, "LEFT", frame, "LEFT", -5, 0)
    frame.rightLine = createFrameInnerLine(frame, 12, 1, "RIGHT", frame, "RIGHT", 5, 0)

    frame:Show()
    frames[name] = frame -- Store the frame in the frames tables
end

local function initAnchorFrames()
    for i, frame in ipairs(BetterAnchors.ANCHOR_FRAMES) do
        CreateAnchorFrameByName(frame.name, frame.width, frame.height, BetterAnchorsDB.Scale or frame.scale,
            frame.moveable)
    end
end

--- Login and Logout Events ---
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
    BetterAnchorsDB["framesTextureVisible"] = framesTextureVisible
end

function addon:PLAYER_LOGIN()
    -- Set default values
    setDefaultValues()

    -- Initialize anchor frames
    initAnchorFrames()

    for name, frame in pairs(frames) do
        if BetterAnchorsDB["positions"][name] then
            local point, relativePoint, xOfs, yOfs = unpack(BetterAnchorsDB["positions"][name])
            -- addon:print(name, point, relativePoint, xOfs, yOfs)
            frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
        end

        -- Add the scale restoration code here
        BetterAnchorsDB[name] = BetterAnchorsDB[name] or { Scale = 1 } -- Initialize Scale to 1
        if BetterAnchorsDB[name].Scale then
            frame:SetScale(BetterAnchorsDB[name].Scale)
            addon:updateScaleLabel(name) -- Update the scale label
        end
    end

    -- Restore the state of toggleUnlockAnchorFrames
    if BetterAnchorsDB["framesLocked"] then
        addon:lockAllFrames()
    else
        addon:unlockAllFrames()
    end


    -- Restore the state of togleFrameTexutres
    -- print("framesTextureVisible", BetterAnchorsDB["framesTextureVisible"])
    if BetterAnchorsDB["framesTextureVisible"] then
        addon:showAllTextures()
    else
        addon:hideAllTextures()
    end
end

--- Lock and Unlock Frames ---
function addon:lockAllFrames()
    -- addon:SetOptionFramesLocked(true)
    addon:print("Anchors are now locked")
    for name, frame in pairs(frames) do
        frame:lockFrame()
        framesLocked = true
    end
end

function addon:unlockAllFrames()
    -- addon:SetOptionFramesLocked(false)
    addon:print("Anchors are now unlocked")
    for name, frame in pairs(frames) do
        frame:unlockFrame()
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

--- Texture Show Hide ---
function addon:hideAllTextures()
    for name, frame in pairs(frames) do
        frame:ClearBackdrop()
        frame.label:Hide()
        frame.scaleLabel:Hide()
        frame.lockTexture:Hide()
        frame.topLine:Hide()
        frame.bottomLine:Hide()
        frame.leftLine:Hide()
        frame.rightLine:Hide()
    end
    addon:print("Anchors are now hidden")
    framesTextureVisible = false
end

function addon:showAllTextures()
    for name, frame in pairs(frames) do
        frame:SetBackdrop(BA_BACKDROP_TEMPLATE)
        frame.label:Show()
        frame.scaleLabel:Show()
        frame.lockTexture:Show()
        frame.topLine:Show()
        frame.bottomLine:Show()
        frame.leftLine:Show()
        frame.rightLine:Show()
    end
    addon:print("Anchors are now visible")
    framesTextureVisible = true
end

function addon:toggleTextures()
    local anyTextureVisible = false
    for name, frame in pairs(frames) do
        if frame:GetBackdrop() then
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

--Default Positions --
function addon:resetFramePositions() --FIXME not correctly restoring the default values
    -- Ensure the default values are set
    setDefaultValues()

    for frameName, position in pairs(BetterAnchorsDB["positions"]) do
        local frame = _G[frameName] -- get the frame by its name
        if frame then
            frame:ClearAllPoints()  -- clear all current anchor points
            local point, relativeFrame, relativePoint, offsetX, offsetY = unpack(position)
            if type(relativeFrame) == "string" then
                relativeFrame = frame[relativeFrame]                              -- get the region from the frame
            end
            frame:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY) -- set the frame's position back to its default position
            BetterAnchorsDB["positions"][frameName] =
                position                                                          -- overwrite the position in the SharedVariables
        end
    end
end

---- Chat Commands ---
SLASH_BA1 = "/ba"
SlashCmdList["BA"] = function(msg)
    if msg == "lock" or msg == 'aiaicaptain' then
        addon:lockAllFrames()
    elseif msg == "unlock" then
        addon:unlockAllFrames()
    elseif msg == "show" then
        addon:showAllTextures()
    elseif msg == "hide" then
        addon:hideAllTextures()
    elseif msg == "reset" then
        addon:resetFramePositions()
    else
        addon:toggleTextures()
        addon:manageOptionsFrame("toggle")
        addon:toggleUnlockAnchorFrames()
    end
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



-- TODO change the names of the frames
-- TODO Minimap Icon
-- TODO Minimap Icon Function - show/hide when clicked
-- TODO add option to reset the position of the frames back to default.

-- TODO Version 2 - Grid Snapping
-- TODO clean up the way saved variables are saved.
