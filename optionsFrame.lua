local addonName, addon = ...

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
    frame:SetSize(300, 600)
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

---- Create the Title ----
local function createTitle(frame)
    -- Add the 'Change Frame Scale' title --
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2")
    title:SetPoint("TOP", frame, "TOP", 0, -10)
    title:SetText("Change Frame Scale")
end

local function createSliders(frame)
    -- Create Sliders ---
    local options = {}
    local lastSlider

    for i = 1, 10 do
        local option = CreateFrame("Frame", nil, frame)
        option:SetSize(280, 20) -- Increase the size of the option frame
        option:SetPoint("TOPLEFT", 10, -35 * i)

        local optionName = option:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        optionName:SetPoint("LEFT", option, "LEFT", 5, 0)
        optionName:SetText("Option " .. i)

        local slider = CreateFrame("Slider", nil, option, "OptionsSliderTemplate")
        slider:SetSize(150, 20)
        slider:SetPoint("RIGHT", option, "RIGHT", -5, 0)
        slider:SetMinMaxValues(0, 100)
        slider:SetValue(50)
        slider:SetValueStep(1)
        slider:SetOrientation("HORIZONTAL")

        lastSlider = slider -- Keep track of the last slider
    end

    return lastSlider -- Return the last slider
end

-- ------------- Grid Section ------------ --
local function addGridSection(frame, lastSlider)
    local gridSection = CreateFrame("Frame", nil, frame)
    gridSection:SetSize(280, 200)
    -- Position the gridSection in the center of the frame, but 10 units below the lastSlider
    gridSection:SetPoint("TOP", frame, "TOP", 0, lastSlider:GetBottom() - frame:GetTop() - 15)

    local gridTitle = gridSection:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    gridTitle:SetPoint("TOP", 0, -10)
    gridTitle:SetText("Grid")
    -- Return the gridSection frame
    return gridSection
end

local function createButton(gridSection, buttonData, buttonWidth, buttonHeight, xOffset, yOffset)
    local button = CreateFrame("Button", nil, gridSection, "GameMenuButtonTemplate")
    button:SetSize(buttonWidth, buttonHeight)
    button:SetText(buttonData.text)
    button:SetPoint("TOP", gridSection, "TOP", xOffset, yOffset - 30)

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

-------- Function Calls --------
local frame = createFrame()
makeFrameMovable(frame)
createTitle(frame)
createSliders(frame)

local lastSlider = createSliders(frame)
local gridSection = addGridSection(frame, lastSlider) -- Assign the return value of addGridSection to gridSection
createButtons(frame, gridSection)


-- TODO make buttons work on a increment of 10 as a slider instead of different buttons.
-- REVIEW script on value change for the slider OnValueChanged
