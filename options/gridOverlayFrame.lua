local addonName, BetterAnchors = ...

local standardButtonData = {
    -- Standard Monitors 16:9
    { text = "32",  grid = '32' },
    { text = "64",  grid = '64' },
    { text = "96",  grid = '96' },
    { text = "128", grid = '128' },
}

local ultrawideButtonData = {
    -- Ultrawide Monitors 21:9
    { text = "128 x 54", grid = 'uw' },
    { text = "86 x 36",  grid = 'uw2' },
}

---1 equals 16:9, over 1 is ultrawide (like 21:9)
---@return integer
local function GetMonitorAspectRatio()
    local width, height = GetPhysicalScreenSize()
    return math.floor(width / height)
end

local function BuildOptionsForGridOverlayFrame()
    local lastElement = nil

    local gridTitle = BetterAnchors.gridOptionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalmed2")
    gridTitle:SetPoint("TOPLEFT", BetterAnchors.gridOptionsFrame, "TOPLEFT", 10, -10)
    gridTitle:SetPoint("TOPRIGHT", BetterAnchors.gridOptionsFrame, "TOPRIGHT", -10, -10)
    gridTitle:SetText("Grid Overlay")
    -- gridTitle:SetHeight(30)

    lastElement = gridTitle

    local gridFrameHeight = gridTitle:GetHeight()

    lastElement = BetterAnchors:CreateLineSeparatorGridFrame(lastElement, { left = 5, right = -5, top = -5 })

    gridFrameHeight = gridFrameHeight + lastElement:GetHeight() + 5

    if GetMonitorAspectRatio() == 1 then
        lastElement = BetterAnchors:CreateMonitorSection("Standard Monitors 16:9", standardButtonData, lastElement)
    else
        lastElement = BetterAnchors:CreateMonitorSection("Ultrawide Monitors 21:9", ultrawideButtonData, lastElement,
            { left = 0, right = 0 })
    end

    gridFrameHeight = gridFrameHeight + lastElement:GetHeight() + 50

    -- Set the height after all elements are added
    BetterAnchors.gridOptionsFrame:SetHeight(gridFrameHeight)
end


local function CreateGridOverlayFrame()
    local gridOptionsFrame = CreateFrame("Frame", "BetterAnchorsGridOptionsFrame", UIParent, "BackdropTemplate")
    gridOptionsFrame:SetSize(270, 1)
    gridOptionsFrame:SetFrameStrata("DIALOG")
    gridOptionsFrame:SetPoint("TOP", BetterAnchors.optionsFrame, "BOTTOM", 0, -1)
    gridOptionsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    gridOptionsFrame:SetBackdropColor(0, 0, 0, 0.8)

    return gridOptionsFrame
end

function BetterAnchors:ShowGridOptionsFrame()
    if not self.gridOptionsFrame then
        self.gridOptionsFrame = CreateGridOverlayFrame()
        BuildOptionsForGridOverlayFrame()
        self:ShowGridOptionsFrame()
    end
    self.gridOptionsFrame:Show()
end

function BetterAnchors:HideGridOptionsFrame()
    if self.gridOptionsFrame then
        self.gridOptionsFrame:Hide()
        BetterAnchors:HideGrid()
    end
end

function BetterAnchors:ToggleGridOptionsFrame()
    if self.gridOptionsFrame and self.gridOptionsFrame:IsShown() then
        self:HideGridOptionsFrame()
    else
        self:ShowGridOptionsFrame()
    end
end
