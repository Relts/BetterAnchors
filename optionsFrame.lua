local addonName, addon = ...
local ANCHOR_FRAMES = BetterAnchors.ANCHOR_FRAMES

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
    { text = "Hide",     func = function() addon:hideGrid() end }
}

local function createFrame()
    local frame = CreateFrame("Frame", "ScaleFrame", UIParent, "BackdropTemplate")
    frame:SetSize(320, 600)
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

    return frame
end

local function makeFrameMovable(frame)
    -- Make the frame movable --
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
end

local function createCloseButton(frame)
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetSize(20, 20)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
        addon:hideAllFrames()
    end)
end


---- Create the Title ----
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

local function createSlider(option)
    local slider = CreateFrame("Slider", nil, option, "OptionsSliderTemplate")
    slider:SetSize(140, 20)
    slider:SetPoint("RIGHT", option, "RIGHT", -5, 0)
    slider:SetMinMaxValues(0, 100)
    slider:SetValue(50)
    slider:SetValueStep(1)
    slider:SetOrientation("HORIZONTAL")
    return slider
end

local function createOption(frame, i, optionName, titleHeight)
    local option = CreateFrame("Frame", nil, frame)
    local frameWidth = frame:GetWidth()
    option:SetSize(frameWidth - 20, 20)
    local verticalOffset = i == 1 and -titleHeight - 30 or
        -titleHeight - 30 -
        35 * (i - 1) -- Adjust vertical offset for the first option
    option:SetPoint("TOP", frame, "TOP", 0, verticalOffset)

    local optionNameText = option:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    optionNameText:SetPoint("LEFT", option, "LEFT", 5, 0)
    optionNameText:SetText(optionName.name) -- Assuming optionName is a table with a 'name' field

    local slider = createSlider(option)
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
    local frame = createFrame()
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

setupFrame()

function addon:showOptionsFrame()
    ScaleFrame:Show()
end

-- TODO make buttons work on a increment of 10 as a slider instead of different buttons.
-- REVIEW script on value change for the slider OnValueChanged
