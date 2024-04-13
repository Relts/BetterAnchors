local addonName, BetterAnchors = ...

local buttonData = {
    -- Standard Monitors 16:9
    { text = "32",       grid = '32' },
    { text = "64",       grid = '64' },
    { text = "96",       grid = '96' },
    { text = "128",      grid = '128' },
    -- Ultrawide Monitors 21:9
    { text = "128 x 54", grid = 'uw' },
    { text = "86 x 36",  grid = 'uw2' },
    -- 4k Monitors 16:9
    { text = "128 x 72", grid = '4k' },
    { text = "Hide",     func = function() BetterAnchors:HideGrid() end },
}

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
        slider:SetSize(100, 20) -- change the size of the slider
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

        slider:SetScript("OnEnter", function()
            frame:EnableDrawLayer("HIGHLIGHT")
        end)
        slider:SetScript("OnLeave", function()
            frame:DisableDrawLayer("HIGHLIGHT")
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

    -- Line Seperator
    local optionsLineOne = BetterAnchors.optionsFrame:CreateTexture(nil, "BACKGROUND")
    optionsLineOne:SetColorTexture(1, 1, 1, 0.3) -- Set the color and alpha of the line
    optionsLineOne:SetHeight(2)
    optionsLineOne:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
    optionsLineOne:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)

    lastElement = optionsLineOne

    -- Grid Overlay Title
    local gridTitle = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalmed2")
    gridTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 10, -10)
    gridTitle:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", -10, -10)
    gridTitle:SetText("Grid Overlay")

    lastElement = gridTitle

    -- Standard Monitor Title
    local standardMonitorTitle = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    standardMonitorTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", -5, -10)
    standardMonitorTitle:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 5, -10)
    standardMonitorTitle:SetText("Standard Monitors 16:9")
    standardMonitorTitle:SetJustifyH("LEFT")

    lastElement = standardMonitorTitle

    -- Create an invisible frame inside the optionsFrame
    local standardButtonFrame = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
    standardButtonFrame:SetSize(1, 25)
    standardButtonFrame:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
    standardButtonFrame:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)

    -- local bg = standardButtonFrame:CreateTexture(nil, "BACKGROUND")
    -- bg:SetColorTexture(1, 1, 1, 0.3)
    -- bg:SetAllPoints(standardButtonFrame)

    local totalWidth = standardButtonFrame:GetWidth() -- Get the width of the buttonFrame
    local buttonSpacing = 2
    local buttonWidth = (totalWidth - (buttonSpacing * (#standardButtonData - 1))) /
        #
        standardButtonData -- Calculate the width of each button based on the buttonFrame width

    for i, data in ipairs(standardButtonData) do
        local button = CreateFrame("Button", nil, standardButtonFrame, "BigGoldRedThreeSliceButtonTemplate") -- Create the button inside the buttonFrame
        button:SetNormalFontObject("GameFontNormalSmall")
        button:SetText(data.text)
        button:SetSize(buttonWidth, 25) -- Set the width of the button

        if i == 1 then
            -- Position the first button at the left of the buttonFrame without spacing
            button:SetPoint("TOPLEFT", standardButtonFrame, "TOPLEFT", 0, 0)
        else
            -- Position subsequent buttons to the right of the last button with spacing
            button:SetPoint("LEFT", lastElement, "RIGHT", buttonSpacing, 0)
        end

        button:SetScript("OnClick", function()
            if data.func then
                data.func()
            else
                BetterAnchors:ShowGrid(data.grid)
            end
        end)

        lastElement = button
    end

    lastElement = standardButtonFrame

    -- Ultrawide Monitor Title
    local ultrawideMonitorTitle = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ultrawideMonitorTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -10)
    ultrawideMonitorTitle:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -10)
    ultrawideMonitorTitle:SetText("Ultrawide Monitors 21:9")
    ultrawideMonitorTitle:SetJustifyH("LEFT")

    lastElement = ultrawideMonitorTitle

    -- Create an invisible frame inside the optionsFrame
    local ultrawideButtonFrame = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
    ultrawideButtonFrame:SetSize(1, 25)
    ultrawideButtonFrame:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
    ultrawideButtonFrame:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)

    totalWidth = ultrawideButtonFrame:GetWidth() -- Get the width of the buttonFrame
    buttonSpacing = 2
    buttonWidth = (totalWidth - (buttonSpacing * (#ultrawideButtonData - 1))) /
        #
        ultrawideButtonData -- Calculate the width of each button based on the buttonFrame width

    for i, data in ipairs(ultrawideButtonData) do
        local button = CreateFrame("Button", nil, ultrawideButtonFrame, "BigGoldRedThreeSliceButtonTemplate") -- Create the button inside the buttonFrame
        button:SetNormalFontObject("GameFontNormalSmall")
        button:SetText(data.text)
        button:SetSize(buttonWidth, 25) -- Set the width of the button

        if i == 1 then
            -- Position the first button at the left of the buttonFrame without spacing
            button:SetPoint("TOPLEFT", ultrawideButtonFrame, "TOPLEFT", 0, 0)
        else
            -- Position subsequent buttons to the right of the last button with spacing
            button:SetPoint("LEFT", lastElement, "RIGHT", buttonSpacing, 0)
        end

        button:SetScript("OnClick", function()
            if data.func then
                data.func()
            else
                BetterAnchors:ShowGrid(data.grid)
            end
        end)

        lastElement = button
    end

    lastElement = ultrawideButtonFrame

    -- Line Seperator
    local optionsLineTwo = BetterAnchors.optionsFrame:CreateTexture(nil, "BACKGROUND")
    optionsLineTwo:SetColorTexture(1, 1, 1, 0.3) -- Set the color and alpha of the line
    optionsLineTwo:SetHeight(2)
    optionsLineTwo:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", -5, -5)
    optionsLineTwo:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 5, -5)

    lastElement = optionsLineTwo

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
    optionsFrame:SetSize(280, 600)
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

-- TODO: add grid buttons and keep pressed state for showing and hiding.
-- TODO: If we are bored add grid snapping
-- TODO: make the frame fit the height of the last element
