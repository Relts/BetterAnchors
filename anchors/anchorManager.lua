local addonName, BetterAnchors = ...


local ANCHOR_FRAMES = {
    { name = "BACastBars",          label = "Cast Bars",           width = 320, height = 120, scale = 1, moveable = true,  defaultPosition = { "CENTER", -1, 253 }, },
    { name = "BATextWarningsOne",   label = "Text Warnings One",   width = 350, height = 50,  scale = 1, moveable = true,  defaultPosition = { "CENTER", -1, 154 }, },
    { name = "BAIcons",             label = "Icons",               width = 200, height = 60,  scale = 1, moveable = true,  defaultPosition = { "CENTER", -318, 126 }, },
    { name = "BATankIcons",         label = "Tank Icons",          width = 70,  height = 215, scale = 1, moveable = true,  defaultPosition = { "TOP", -280, -229 }, },
    { name = "BACoTankIcons",       label = "Co-Tank Icons",       width = 70,  height = 215, scale = 1, moveable = true,  defaultPosition = { "TOP", -359, -227 }, },
    { name = "BAPrivateAuras",      label = "Private Auras",       width = 70,  height = 70,  scale = 1, moveable = true,  defaultPosition = { "CENTER", -253, 56 }, },
    { name = "BAPlayerList",        label = "Player List",         width = 170, height = 180, scale = 1, moveable = true,  defaultPosition = { "CENTER", -272, -75 }, },
    { name = "BARaidLeaderListOne", label = "Raid Leader List On", width = 170, height = 450, scale = 1, moveable = true,  defaultPosition = { "TOPLEFT", 447, -148 }, },
    { name = "BAMapFrame",          label = "Map Frame",           width = 320, height = 180, scale = 1, moveable = true,  defaultPosition = { "TOP", -2, -75 }, },
    { name = "BAPlayerCircle",      label = "Player Circle",       width = 130, height = 130, scale = 1, moveable = false, defaultPosition = { "CENTER", 0, -20 }, },
}


function BetterAnchors:ShowFrames()
    -- show the textures and unlock the frames
    for _, anchorFrame in pairs(self.anchorFrames) do
        anchorFrame:UnlockFrame()
        anchorFrame:ShowTextures()
    end
    self.anchorsVisible = true
end

function BetterAnchors:HideFrames()
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
    if BetterAnchorsDB.positions then
        return BetterAnchorsDB.positions[name]
    end
end


local function GetScaleForAnchorName(name)
    if BetterAnchorsDB.scales then
        return BetterAnchorsDB.scales[name]
    end
end

function BetterAnchors:CreateAllAnchorFrames()
    for _, frameInfo in ipairs(ANCHOR_FRAMES) do
        frameInfo.position = GetPositionForAnchorName(frameInfo.name) or frameInfo.defaultPosition
        frameInfo.scale = GetScaleForAnchorName(frameInfo.name) or 1
        self:CreateAnchorFrame(frameInfo)
    end
end
