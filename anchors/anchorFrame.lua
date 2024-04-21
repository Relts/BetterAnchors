local addonName, BetterAnchors = ...

--- List of Frames that get created ---
local BA_BACKDROP_TEMPLATE = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local FRAME_DEFAULT_ALIGN_HELPERS = {
    top = {
        width = 2,
        height = 12,
        x = 0,
        y = 5
    },
    bottom = {
        width = 2,
        height = 12,
        x = 0,
        y = -5
    },
    left = {
        width = 12,
        height = 2,
        x = -5,
        y = 0
    },
    right = {
        width = 12,
        height = 2,
        x = 5,
        y = 0
    },
}

local function CreateAnchorFrame(frameInfo)
    local frame = CreateFrame("Frame", frameInfo.name, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(100, 100)

    local point, relativePoint, x, y
    if frameInfo.position then
        point, relativePoint, x, y = unpack(frameInfo.position)
    else
        point, x, y = unpack(frameInfo.defaultPosition)
        relativePoint = point
    end
    frame:SetPoint(point, UIParent, relativePoint, x, y)
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop(BA_BACKDROP_TEMPLATE)

    if not frameInfo.moveable then
        local lockTexture = frame:CreateTexture(nil, "OVERLAY")
        lockTexture:SetAtlas("Garr_LockedBuilding")
        lockTexture:SetSize(20, 20)
        lockTexture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
        frame.lockTexture = lockTexture
    end


    local nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, 0)
    nameLabel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 0)
    nameLabel:SetText(frameInfo.label)
    frame.nameLabel = nameLabel

    local scaleLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    scaleLabel:SetText("Scale: " .. 1)
    scaleLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
    frame.scaleLabel = scaleLabel

    for alignPosition, alignInfo in pairs(FRAME_DEFAULT_ALIGN_HELPERS) do
        local line = frame:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(1, 1, 0)
        line:SetSize(alignInfo.width, alignInfo.height)
        line:SetPoint(alignPosition, frame, alignPosition, alignInfo.x, alignInfo.y)
        frame[alignPosition .. "Line"] = line
    end

    frame:SetScript("OnMouseDown", function(self)
        self:StartMoving()
    end)


    frame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
        if not BetterAnchorsDB.positions then
            BetterAnchorsDB.positions = {}
        end
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        BetterAnchorsDB.positions[frameInfo.name] = { point, relativePoint, xOfs, yOfs }
    end)


    frame.LockFrame = function()
        if not frame.moveable then return end
        frame:SetMovable(false)
        frame:EnableMouse(false)
    end

    frame.UnlockFrame = function()
        if not frame.moveable then return end
        frame:SetMovable(true)
        frame:EnableMouse(true)
    end

    frame.SetAnchorScale = function(self, scale)
        local roundedValue = math.floor(scale * 100) / 100
        if not BetterAnchorsDB.scales then
            BetterAnchorsDB.scales = {}
        end
        BetterAnchorsDB.scales[frameInfo.name] = roundedValue
        self:SetScale(roundedValue)
        self.scaleLabel:SetText("Scale: " .. roundedValue)
    end

    frame.HideTextures = function()
        frame:ClearBackdrop()
        frame.nameLabel:Hide()
        frame.scaleLabel:Hide()
        frame.topLine:Hide()
        frame.bottomLine:Hide()
        frame.leftLine:Hide()
        frame.rightLine:Hide()
        if frame.lockTexture then
            frame.lockTexture:Hide()
        end
    end

    frame.ShowTextures = function()
        frame:SetBackdrop(BA_BACKDROP_TEMPLATE)
        frame.nameLabel:Show()
        frame.scaleLabel:Show()
        frame.topLine:Show()
        frame.bottomLine:Show()
        frame.leftLine:Show()
        frame.rightLine:Show()
        if frame.lockTexture then
            frame.lockTexture:Show()
        end
    end

    frame.ResetPosition = function()
        frame:ClearAllPoints()
        local point, x, y = unpack(frameInfo.defaultPosition)
        frame:SetPoint(point, x, y)
        BetterAnchorsDB.positions[frameInfo.name] = { point, point, x, y }
    end
    -- mouseover frame highlighting
    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(true)
    highlight:SetColorTexture(1, 1, 0, 0.2)
    highlight:SetBlendMode("ADD")
    frame.highlight = highlight

    return frame
end



function BetterAnchors:CreateAnchorFrame(frameInfo)
    local frame = CreateAnchorFrame(frameInfo)
    frame.moveable = frameInfo.moveable
    frame:SetSize(frameInfo.width, frameInfo.height)
    frame:SetAnchorScale(frameInfo.scale)

    -- mouse over frame highlighting
    frame:SetScript("OnEnter", function(self)
        self:EnableDrawLayer("HIGHLIGHT")
    end)
    frame:SetScript("OnLeave", function(self)
        if not self:IsMouseOver() then
            self:DisableDrawLayer("HIGHLIGHT")
        end
    end)


    if not frameInfo.moveable then
        frame:SetScript("OnMouseDown", nil)
        frame:SetScript("OnMouseUp", nil)
        frame:SetMovable(false)
        frame:EnableMouse(false)
    else
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
    end
    frame:HideTextures()
    frame:LockFrame()
    frame:Show()
    frame.frameInfo = frameInfo
    if not self.anchorFrames then
        self.anchorFrames = {}
    end
    self.anchorFrames[frameInfo.name] = frame
end

-- TODO: XY cords to better algin the frames.
-- TODO: Grid Snapping
-- NEWFEATURE
