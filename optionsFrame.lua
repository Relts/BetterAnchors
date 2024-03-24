local addonName, addon = ...
local ANCHOR_FRAMES = BetterAnchors.ANCHOR_FRAMES
local SCALE_ADJUSTMENT = addon.SCALE_ADJUSTMENT

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
    { text = "Hide",     func = function() addon:hideGrid() end },
}

local function createOptionsFrame()
    local frame = CreateFrame("Frame", "OptionsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(340, 600)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG") -- Set the frame strata to "HIGH"
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    -- Set the background color of the frame --
    frame:SetBackdropColor(0, 0, 0, 0.8)


    if not BetterAnchorsDB.optionsFrameIsVisible then
        frame:Hide()
    else
        frame:Show()
    end
    return frame
end

local function makeFrameMovable(frame)
    -- Make the frame movable --
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetLeft(), self:GetTop()
        BetterAnchorsDB.optionsFramePosition = { x = x, y = y }
    end)
end

function addon:optionsCloseButton()
    addon:hideAllTextures()
    addon:hideGrid()
    addon:manageOptionsFrame("hide")
    addon:lockAllFrames()
    BetterAnchorsDB.optionsFrameIsVisible = false
end

local function createCloseButton(frame)
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetSize(20, 20)
    closeButton:SetScript("OnClick", function()
        addon:optionsCloseButton()
    end)
end

local function createTitle(frame, titleText)
    -- Create the title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText(titleText)

    -- Create the line below the title
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.5) -- Set the color and alpha of the line
    line:SetHeight(1)

    -- Position the line 10 units below the title and make it the same width as the createLineBreak line
    line:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -title:GetStringHeight() - 20)
    line:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -title:GetStringHeight() - 20)

    local titleHeight = title:GetStringHeight() -- Calculate the height of the title
    return title, titleHeight
end

-- Helper function to create a button
local function createButton(parent, point, text, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(18, 18)
    button:SetPoint(point, parent, point == "RIGHT" and "LEFT" or "RIGHT", point == "RIGHT" and -5 or 5, 0)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

-- Helper function to adjust slider value
local function adjustSliderValue(slider, frameName, adjustment)
    local currentValue = slider:GetValue()
    local newValue = math.floor((currentValue + adjustment) * 10 + 0.5) / 10
    slider:SetValue(newValue)
    if adjustment < 0 then
        addon:decreaseFrameScaleByName(frameName)
    else
        addon:increaseFrameScaleByName(frameName)
    end
end

local function createSlider(option, frameName)
    local slider = CreateFrame("Slider", nil, option, "OptionsSliderTemplate")
    slider:SetSize(90, 20)
    slider:SetPoint("RIGHT", option, "RIGHT", -25, 0)
    slider:SetMinMaxValues(0.1, 2)
    slider:SetValue(BetterAnchorsDB[frameName].Scale or 1)
    slider:SetValueStep(SCALE_ADJUSTMENT)
    slider:SetOrientation("HORIZONTAL")
    slider:SetScript("OnValueChanged", function(self, value, isUserInput)
        if isUserInput then
            -- Round the value to the nearest tenth
            local newValue = addon:round(value, 1)
            addon:setFrameScaleByName(frameName, newValue)
            addon:updateScaleLabel(frameName, newValue)
        end
    end)

    -- Remove the low and high labels
    slider.Low:SetText("")
    slider.High:SetText("")

    -- Create decrease button
    createButton(slider, "RIGHT", "-", function()
        if slider:GetValue() > 0.1 then
            adjustSliderValue(slider, frameName, -SCALE_ADJUSTMENT)
        end
    end)

    -- Create increase button
    createButton(slider, "LEFT", "+", function()
        if slider:GetValue() < 100 then
            adjustSliderValue(slider, frameName, SCALE_ADJUSTMENT)
        end
    end)

    return slider
end

-- The optionName argument is used to specify the name of the option
local function createOption(frame, i, optionName, titleHeight)
    local option = CreateFrame("Frame", nil, frame)
    local frameWidth = frame:GetWidth()
    option:SetSize(frameWidth - 20, 20)
    local verticalOffset = i == 1 and -titleHeight - 30 or
        -titleHeight - 32 -
        30 * (i - 1) -- Adjust vertical offset for the first option
    option:SetPoint("TOP", frame, "TOP", 0, verticalOffset)

    local optionNameText = option:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionNameText:SetPoint("LEFT", option, "LEFT", 5, 0)
    optionNameText:SetText(optionName.name)              -- Assuming optionName is a table with a 'name' field

    local slider = createSlider(option, optionName.name) -- Pass optionName to createSlider

    return slider
end

local function createSliders(frame, titleHeight)
    local lastSlider
    for i, optionName in ipairs(ANCHOR_FRAMES) do
        lastSlider = createOption(frame, i, optionName, titleHeight) -- Pass titleHeight to createOption
    end
    return lastSlider
end

-- ------------- Grid Section ------------ --
local function addGridSection(frame, lastSlider)
    local gridSection = CreateFrame("Frame", nil, frame)
    gridSection:SetSize(280, 200)
    -- Position the gridSection in the center of the frame, but 10 units below the lastSlider
    gridSection:SetPoint("TOP", frame, "TOP", 0, lastSlider:GetBottom() - frame:GetTop() - 15)

    local gridTitle = gridSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    gridTitle:SetPoint("TOP", 0, -12)
    gridTitle:SetText("Grid")
    -- Return the gridSection frame
    return gridSection
end

local function createLineBreak(gridSection)
    -- Create a line above the grid section title
    local line = gridSection:CreateTexture(nil, "BACKGROUND")
    line:SetColorTexture(1, 1, 1, 0.3)                          -- Set the color and alpha of the line
    line:SetHeight(1)                                           -- Set the height of the line
    line:SetPoint("TOPLEFT", gridSection, "TOPLEFT", 5, -30)    -- Position the line
    line:SetPoint("TOPRIGHT", gridSection, "TOPRIGHT", -5, -30) -- Position the line
end

local function createButton(gridSection, buttonData, buttonWidth, buttonHeight, xOffset, yOffset)
    local button = CreateFrame("Button", nil, gridSection, "GameMenuButtonTemplate")
    button:SetSize(buttonWidth, buttonHeight)
    button:SetText(buttonData.text)
    button:SetPoint("TOP", gridSection, "TOP", xOffset, yOffset - 40) -- Increase the offset here

    if buttonData.grid then
        button:SetScript("OnClick", function()
            addon:loadGrid(buttonData.grid)
            addon:print("Button " .. buttonData.text .. " clicked")
        end)
    else
        button:SetScript("OnClick", buttonData.func)
    end

    return button
end

local function createButtons(frame, gridSection)
    local buttonHeight = 25
    local spacing = 5
    local rows = { { 4 }, { 3 }, { 1 }, } -- 4 buttons in the first row, 3 in the second

    gridSection:SetSize(280, (#rows * (buttonHeight + spacing)))

    createLineBreak(gridSection)

    local buttonIndex = 1
    for rowIndex, row in ipairs(rows) do
        local buttonWidth = rowIndex == 1 and 65 or 82

        for i = 1, row[1] do
            local buttonData = buttonData[buttonIndex]
            if buttonData then
                local xOffset = ((i - 1) * (buttonWidth + spacing)) - ((row[1] - 1) * (buttonWidth + spacing) / 2)
                local yOffset = -((rowIndex - 1) * (buttonHeight + spacing))

                createButton(gridSection, buttonData, buttonWidth, buttonHeight, xOffset, yOffset)
                buttonIndex = buttonIndex + 1
            end
        end
    end
end

local function setupFrame()
    local frame = createOptionsFrame()
    makeFrameMovable(frame)

    -- Create the title and get its height
    local title, titleHeight = createTitle(frame, "Scale Frames")

    -- Create the sliders
    local lastSlider = createSliders(frame, titleHeight) -- Pass titleHeight to createSliders

    local gridSection = addGridSection(frame, lastSlider)
    createButtons(frame, gridSection)

    -- Create the close button
    createCloseButton(frame)
end



function addon:manageOptionsFrame(action)
    if not OptionsFrame then
        setupFrame()
    end
    if OptionsFrame then
        if action == "show" then
            OptionsFrame:Show()
            BetterAnchorsDB.optionsFrameIsVisible = true
        elseif action == "hide" then
            OptionsFrame:Hide()
            BetterAnchorsDB.optionsFrameIsVisible = false
        elseif action == "toggle" then
            if OptionsFrame:IsShown() then
                OptionsFrame:Hide()
                BetterAnchorsDB.optionsFrameIsVisible = false
            else
                OptionsFrame:Show()
                BetterAnchorsDB.optionsFrameIsVisible = true
            end
        end
    end
end
