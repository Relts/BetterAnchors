local addonName, BetterAnchors = ...




local function BuildOptionsForOptionsFrame()
    local anchorFrames = BetterAnchors.anchorFrames
    local lastElement = nil
    --  Title Image Container
    local titleContainer = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
    titleContainer:SetPoint("TOPLEFT", BetterAnchors.optionsFrame, "TOPLEFT", 10, -5)
    titleContainer:SetPoint("TOPRIGHT", BetterAnchors.optionsFrame, "TOPRIGHT", -10, -5)
    titleContainer:SetHeight(60)

    local titleTexture = titleContainer:CreateTexture(nil, "OVERLAY")
    titleTexture:SetTexture("Interface\\AddOns\\BetterAnchors\\assets\\baLogo.blp")
    titleTexture:SetPoint("CENTER", titleContainer, "CENTER")
    titleTexture:SetWidth(titleContainer:GetWidth() - 25)
    titleTexture:SetHeight(titleContainer:GetHeight() - 10)
    lastElement = titleContainer

    local optionsFrameHeight = titleContainer:GetHeight()
    -- Line Separator
    lastElement = BetterAnchors:CreateLineSeparator(lastElement, { left = 0, right = 0, top = 0 })
    optionsFrameHeight = optionsFrameHeight + lastElement:GetHeight() + 5

    -- Anchor Frame Scale Selection
    --NEWFEATURE: add in slider to adjust the opacity.
    --NEWFEATURE: Add in frame to switch views between scale and opacity



    -- Anchor Frame Scale Selection
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
        frameLabel:SetJustifyV("MIDDLE")
        frameLabel:SetText(anchorFrame.frameInfo.label)

        local currentScale = anchorFrame:GetScale()
        currentScale = Round(currentScale * 100) / 100
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
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            GameTooltip:SetText("Hold shift and mouse wheel to scroll", nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        slider:SetScript("OnLeave", function()
            frame:DisableDrawLayer("HIGHLIGHT")
            anchorFrame:DisableDrawLayer("HIGHLIGHT")
            GameTooltip:Hide()
        end)

        slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        slider.valueText:SetPoint("RIGHT", slider, "LEFT", -10, 0)
        slider.valueText:SetJustifyH("RIGHT")
        slider.valueText:SetJustifyV("MIDDLE")
        slider.valueText:SetText(currentScale)

        slider:SetScript("OnValueChanged", function(self, value)
            anchorFrame:SetAnchorScale(value)
            local roundedValue = Round(value * 100) / 100
            self.valueText:SetText(roundedValue)
        end)


        frame.slider = slider

        anchorFrame.optionSliderFrame = frame

        optionsFrameHeight = optionsFrameHeight + frame:GetHeight() + 5
        lastElement = frame
    end




    -- Line Separator
    lastElement = BetterAnchors:CreateLineSeparator(lastElement, { left = 0, right = 0, top = -5 })
    optionsFrameHeight = optionsFrameHeight + lastElement:GetHeight() + (5 * 2)

    -- Option Select buttons container
    local buttonWidth = (BetterAnchors.optionsFrame:GetWidth() - 30) / 2 -- Adjust the width to fit both buttons

    -- Option Select buttons container
    local optionSelectButtonContainer = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
    optionSelectButtonContainer:SetSize(BetterAnchors.optionsFrame:GetWidth(), 30)
    optionSelectButtonContainer:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
    optionSelectButtonContainer:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)

    local scaleViewButton = CreateFrame("Button", nil, optionSelectButtonContainer, "BigRedThreeSliceButtonTemplate")
    scaleViewButton:SetNormalFontObject("GameFontNormalSmall")
    scaleViewButton:SetText("Change Scale")
    scaleViewButton:SetSize(buttonWidth, 30)
    scaleViewButton:SetPoint("LEFT", optionSelectButtonContainer, "LEFT", 0, 0)
    scaleViewButton:SetScript("OnClick", function()
        -- BetterAnchors:ToggleGridOptionsFrame()
        BetterAnchors:addonPrint("Scale View Button Clicked")
    end)

    local opacityViewButton = CreateFrame("Button", nil, optionSelectButtonContainer, "BigRedThreeSliceButtonTemplate")
    opacityViewButton:SetNormalFontObject("GameFontNormalSmall")
    opacityViewButton:SetText("Change Opacity")
    opacityViewButton:SetSize(buttonWidth, 30)
    opacityViewButton:SetPoint("RIGHT", optionSelectButtonContainer, "RIGHT", 0, 0)
    opacityViewButton:SetScript("OnClick", function()
        -- StaticPopup_Show("BA_RESET_POSITIONS")
        BetterAnchors:addonPrint("Opacity View Button Clicked")
    end)

    lastElement = optionSelectButtonContainer
    optionsFrameHeight = optionsFrameHeight + scaleViewButton:GetHeight() + 5

    -- Line Separator
    lastElement = BetterAnchors:CreateLineSeparator(lastElement, { left = 0, right = 0, top = -5 })
    optionsFrameHeight = optionsFrameHeight + lastElement:GetHeight() + (5 * 2)

    -- Grid Toggle and Reset Button Container
    local gridToggleResetButtonContainer = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
    gridToggleResetButtonContainer:SetSize(BetterAnchors.optionsFrame:GetWidth(), 30)
    gridToggleResetButtonContainer:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
    gridToggleResetButtonContainer:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)


    local gridToggleButton = CreateFrame("Button", nil, gridToggleResetButtonContainer, "BigRedThreeSliceButtonTemplate")
    gridToggleButton:SetNormalFontObject("GameFontNormalSmall")
    gridToggleButton:SetText("Toggle Grid")
    gridToggleButton:SetSize(buttonWidth, 30)
    gridToggleButton:SetPoint("LEFT", gridToggleResetButtonContainer, "LEFT", 0, 0)
    gridToggleButton:SetScript("OnClick", function()
        BetterAnchors:ToggleGridOptionsFrame()
    end)

    local resetButton = CreateFrame("Button", nil, gridToggleResetButtonContainer, "BigRedThreeSliceButtonTemplate")
    resetButton:SetNormalFontObject("GameFontNormalSmall")
    resetButton:SetText("Reset Anchors")
    resetButton:SetSize(buttonWidth, 30)
    resetButton:SetPoint("RIGHT", gridToggleResetButtonContainer, "RIGHT", 0, 0)
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("BA_RESET_POSITIONS")
    end)

    lastElement = gridToggleResetButtonContainer


    optionsFrameHeight = optionsFrameHeight + gridToggleButton:GetHeight() + 5 -- Adjusted to add height only once
    lastElement =
        gridToggleResetButtonContainer                                         -- Adjusted to set lastElement to gridToggleButton

    -- padding at the bottom
    optionsFrameHeight = optionsFrameHeight + 0
    BetterAnchors.optionsFrame:SetHeight(optionsFrameHeight)
end

local function CreateOptionsFrame()
    local optionsFrame = CreateFrame("Frame", "BetterAnchorsOptionsFrame", UIParent, "BackdropTemplate")
    optionsFrame:SetSize(270, 1)
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
    -- FIXME: change getaddonmetadata to C_addon.getmetadata
    local versionTitle = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalGraySmall")
    versionTitle:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 10, -10)
    versionTitle:SetText(GetAddOnMetadata(addonName, "Version"))

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
        local optionPosition
        if BetterAnchorsDB.positions and BetterAnchorsDB.positions.optionsFrame then
            optionPosition = BetterAnchorsDB.positions.optionsFrame
        else
            optionPosition = { "RIGHT", "RIGHT", -100, 0 }
        end
        local point, relativePoint, x, y = unpack(optionPosition)
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
        self:HideGrid()
        self:HideOptionsFrame()
    else
        self:ShowOptionsFrame()
    end
end
