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


local function BuildOptionsForOptionsFrame()
    local anchorFrames = BetterAnchors.anchorFrames
    local lastElement = nil

    local title = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge2")
    title:SetPoint("TOPLEFT", BetterAnchors.optionsFrame, "TOPLEFT", 10, -10)
    title:SetPoint("TOPRIGHT", BetterAnchors.optionsFrame, "TOPRIGHT", -10, -10)
    title:SetText(addonName)

    lastElement = title

    for anchorName, anchorFrame in pairs(anchorFrames) do
        local frame = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
        frame:SetSize(1, 25)
        frame:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
        frame:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)

        frame:EnableMouse(true)

        -- Mouse over frame highlighting
        frame:SetScript("OnEnter", function()
            if anchorFrame then
                anchorFrame:EnableDrawLayer("HIGHLIGHT")
            end
        end)
        frame:SetScript("OnLeave", function()
            if anchorFrame then
                anchorFrame:DisableDrawLayer("HIGHLIGHT")
            end
        end)

        frame.overlay = frame:CreateTexture(nil, "HIGHLIGHT")
        frame.overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
        frame.overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
        frame.overlay:SetAtlas("perks-list-active")
        frame.overlay:SetAlpha(1)

        local frameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frameLabel:SetPoint("LEFT", 5, 0)
        frameLabel:SetJustifyH("LEFT")
        frameLabel:SetJustifyV("CENTER")
        frameLabel:SetText(anchorFrame.frameInfo.label)

        local currentScale = anchorFrame:GetScale()
        currentScale = math.floor(currentScale * 100) / 100
        local slider = CreateFrame("Slider", nil, frame, "MinimalSliderTemplate")
        slider:SetSize(90, 20) -- change the size of the slider
        slider:SetPoint("RIGHT", frame, "RIGHT", 0, 0)
        slider:SetMinMaxValues(0.5, 2)
        slider:SetValueStep(0.01)
        slider:SetObeyStepOnDrag(true)
        slider:SetValue(currentScale)

        slider:SetScript("OnMouseWheel", function(self, delta)
            if not self:IsEnabled() then
                return
            end
            if not IsShiftKeyDown() then
                return
            end
            local step = self:GetValueStep()
            if delta > 0 then
                self:SetValue(self:GetValue() + step)
            else
                self:SetValue(self:GetValue() - step)
            end
        end)

        -- mouse over frame highlighting on slider
        slider:SetScript("OnEnter", function()
            frame:EnableDrawLayer("HIGHLIGHT")
            anchorFrame:EnableDrawLayer("HIGHLIGHT")
        end)
        slider:SetScript("OnLeave", function()
            frame:DisableDrawLayer("HIGHLIGHT")
            anchorFrame:DisableDrawLayer("HIGHLIGHT")
        end)

        slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.valueText:SetPoint("RIGHT", slider, "LEFT", -10, 0)
        slider.valueText:SetJustifyH("RIGHT")
        slider.valueText:SetJustifyV("CENTER")
        slider.valueText:SetText(currentScale)

        slider:SetScript("OnValueChanged", function(self, value)
            anchorFrame:SetAnchorScale(value)
            local roundedValue = math.floor(value * 100) / 100
            self.valueText:SetText(roundedValue)
        end)


        frame.slider = slider

        anchorFrame.optionSliderFrame = frame

        lastElement = frame
    end

    lastElement = BetterAnchors:CreateLineSeparator(lastElement, { left = 0, right = 0, top = -5, bottom = -5 })

    -- Grid Overlay Title
    local gridTitle = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalmed2")
    gridTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 10, -10)
    gridTitle:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", -10, -10)
    gridTitle:SetText("Grid Overlay")

    lastElement = gridTitle

    lastElement = BetterAnchors:CreateMonitorSection("Standard Monitors 16:9", standardButtonData, lastElement)

    lastElement = BetterAnchors:CreateMonitorSection("Ultrawide Monitors 21:9", ultrawideButtonData, lastElement,
        { left = 0, right = 0 })

    lastElement = BetterAnchors:CreateLineSeparator(lastElement, { left = -5, right = 5, top = -10, bottom = -5 })

    local resetButton = CreateFrame("Button", nil, BetterAnchors.optionsFrame, "BigRedThreeSliceButtonTemplate")
    resetButton:SetNormalFontObject("GameFontNormalSmall")
    resetButton:SetText("Reset Positions and Scale")
    resetButton:SetSize(1, 25)
    resetButton:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 5, -5)
    resetButton:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", -5, -5)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("BA_RESET_POSITIONS")
    end)

    lastElement = resetButton
end

local function CreateOptionsFrame()
    local optionsFrame = CreateFrame("Frame", "BetterAnchorsOptionsFrame", UIParent, "BackdropTemplate")
    optionsFrame:SetSize(270, 515)
    optionsFrame:SetPoint("CENTER")
    optionsFrame:SetFrameStrata("DIALOG") -- Set the frame strata to "HIGH"
    optionsFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    local closeButton = CreateFrame("Button", nil, optionsFrame, "UIPanelCloseButton")
    closeButton:SetSize(20, 20)
    closeButton:SetPoint("TOPRIGHT", optionsFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        BetterAnchors:HideOptionsFrame()
        BetterAnchors:HideFrames()
        BetterAnchors:HideGrid()
    end)

    -- Set the background color of the frame --
    optionsFrame:SetBackdropColor(0, 0, 0, 0.8)
    optionsFrame:SetMovable(true)
    optionsFrame:RegisterForDrag("LeftButton")
    optionsFrame:SetScript("OnMouseDown", function(self)
        self:StartMoving()
    end)
    optionsFrame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
        if not BetterAnchorsDB.positions then
            BetterAnchorsDB.positions = {}
        end
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        BetterAnchorsDB.positions.optionsFrame = { point, relativePoint, xOfs, yOfs }
    end)

    return optionsFrame
end

function BetterAnchors:ShowOptionsFrame()
    if not self.optionsFrame then
        self.optionsFrame = CreateOptionsFrame()
        BuildOptionsForOptionsFrame()
        local point, relativePoint, x, y = unpack(BetterAnchorsDB.positions.optionsFrame or { "RIGHT", "RIGHT", -100, 0 })
        self.optionsFrame:SetPoint(point, UIParent, relativePoint, x, y)
    end
    self.optionsFrame:Show()
end

function BetterAnchors:HideOptionsFrame()
    if self.optionsFrame then
        self.optionsFrame:Hide()
    end
end

function BetterAnchors:ToggleOptionsFrame()
    if self.optionsFrame and self.optionsFrame:IsShown() then
        self:HideOptionsFrame()
    else
        self:ShowOptionsFrame()
    end
end

-- TODO: make the frame fit the height of the last element
