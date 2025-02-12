local addonName, BetterAnchors = ...

local ANCHOR_FRAMES = {
    { name = "BACastBars",          label = "Cast Bars",     width = 320, height = 120, scale = 1, moveable = true,  defaultPosition = { "TOP", 0, -247 }, },
    { name = "BATextWarningsOne",   label = "Text Warnings", width = 350, height = 50,  scale = 1, moveable = true,  defaultPosition = { "CENTER", 0, 188 }, },
    { name = "BAIcons",             label = "Icons",         width = 200, height = 60,  scale = 1, moveable = true,  defaultPosition = { "CENTER", -251, 83 }, },
    { name = "BATankIcons",         label = "Tank Icons",    width = 70,  height = 215, scale = 1, moveable = true,  defaultPosition = { "TOP", -273, -193 }, },
    { name = "BACoTankIcons",       label = "Co-Tank Icons", width = 70,  height = 215, scale = 1, moveable = true,  defaultPosition = { "TOP", -359, -193 }, },
    { name = "BAPrivateAuras",      label = "Private Auras", width = 70,  height = 70,  scale = 1, moveable = true,  defaultPosition = { "CENTER", 114, 40 }, },
    { name = "BAPlayerList",        label = "Player List",   width = 170, height = 180, scale = 1, moveable = true,  defaultPosition = { "CENTER", -263, -84 }, },
    { name = "BARaidLeaderListOne", label = "Large List",    width = 170, height = 450, scale = 1, moveable = true,  defaultPosition = { "LEFT", 440, 52 }, },
    { name = "BAMapFrame",          label = "Map Frame",     width = 320, height = 180, scale = 1, moveable = true,  defaultPosition = { "TOP", 1, -62 }, },
    { name = "BAPlayerCircle",      label = "Player Circle", width = 130, height = 130, scale = 1, moveable = false, defaultPosition = { "CENTER", 0, -20 }, },
}
-- NEWFEATURE: Add Anchor frames for ERT and Kick Weakaura

function BetterAnchors:ShowFrames()
    if not self.anchorFrames then
        self:CreateAllAnchorFrames()
    end
    -- show the textures and unlock the frames
    for _, anchorFrame in pairs(self.anchorFrames) do
        anchorFrame:UnlockFrame()
        anchorFrame:ShowTextures()
    end
    self.anchorsVisible = true
end

function BetterAnchors:HideFrames()
    if not self.anchorFrames then
        self:CreateAllAnchorFrames()
    end
    -- hide the textures and lock the frames
    for _, anchorFrame in pairs(self.anchorFrames) do
        anchorFrame:LockFrame()
        anchorFrame:HideTextures()
    end
    self.anchorsVisible = false
end

function BetterAnchors:ToggleFrames()
    if self.anchorsVisible then
        self:HideFrames()
    else
        self:ShowFrames()
    end
end

function BetterAnchors:ResetPositions()
    for _, frame in pairs(self.anchorFrames) do
        frame:ResetPosition()
    end
end

function BetterAnchors:ResetScales()
    for _, frame in pairs(self.anchorFrames) do
        frame:SetAnchorScale(1)
        if frame.optionSliderFrame then
            frame.optionSliderFrame.slider:SetValue(1)
            frame.optionSliderFrame.slider.valueText:SetText(1)
        end
    end
end

local function GetPositionForAnchorName(name)
    if not BetterAnchorsDB or not BetterAnchorsDB.positions then
        return
    end
    if BetterAnchorsDB.positions then
        return BetterAnchorsDB.positions[name]
    end
end


local function GetScaleForAnchorName(name)
    if not BetterAnchorsDB or not BetterAnchorsDB.positions then
        return
    end
    if BetterAnchorsDB.scales then
        return BetterAnchorsDB.scales[name]
    end
end

function BetterAnchors:CreateAllAnchorFrames()
    if self.framesCreated then
        return
    end
    for _, frameInfo in ipairs(ANCHOR_FRAMES) do
        frameInfo.position = GetPositionForAnchorName(frameInfo.name) or frameInfo.defaultPosition
        frameInfo.scale = GetScaleForAnchorName(frameInfo.name) or 1
        self:CreateAnchorFrame(frameInfo)
    end
    self.framesCreated = true
end
