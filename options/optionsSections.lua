local addonName, BetterAnchors = ...


function BetterAnchors:CreateLineSeparator(lastElement, padding)
    local lineSeparator = BetterAnchors.optionsFrame:CreateTexture(nil, "OVERLAY")
    lineSeparator:SetColorTexture(1, 1, 1, 0.3) -- Set the color and alpha of the line
    lineSeparator:SetHeight(1)
    lineSeparator:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", padding.left, padding.top)
    lineSeparator:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", padding.right, padding.top)

    return lineSeparator
end

function BetterAnchors:CreateMonitorSection(titleText, buttonData, lastElement, titlePadding)
    local paddingLeft = titlePadding and titlePadding.left or -5
    local paddingRight = titlePadding and titlePadding.right or 5
    local paddingTop = titlePadding and titlePadding.top or -10


    -- Monitor Title
    local monitorTitle = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    monitorTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", paddingLeft, paddingTop)
    monitorTitle:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", paddingRight, paddingTop)
    monitorTitle:SetText(titleText)
    monitorTitle:SetJustifyH("LEFT")

    lastElement = monitorTitle

    -- Create an invisible frame inside the optionsFrame
    local buttonFrame = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
    buttonFrame:SetSize(1, 25)
    buttonFrame:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", 0, -5)
    buttonFrame:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 0, -5)

    local totalWidth = buttonFrame:GetWidth() -- Get the width of the buttonFrame
    local buttonSpacing = 2
    local numButtons = #buttonData
    local buttonWidth = (totalWidth - (buttonSpacing * (numButtons - 1))) /
        numButtons -- Calculate the width of each button based on the buttonFrame width


    local lastButtonPressed = nil

    -- FIXME: button not reseting texture when the user presses the close button when the grid has been loaded.
    for i, data in ipairs(buttonData) do
        local button = CreateFrame("Button", nil, buttonFrame, "BigGoldRedThreeSliceButtonTemplate") -- Create the button inside the buttonFrame
        button:SetNormalFontObject("GameFontNormalSmall")
        button:SetText(data.text)
        button:SetSize(buttonWidth, 25)

        button.SetTextureStyle = function(self, isActive)
            if isActive then
                button.Center:SetAtlas("_128-GoldRedButton-Center")
                button.Left:SetAtlas("_128-GoldRedButton-Left")
                button.Right:SetAtlas("_128-GoldRedButton-Right")
            else
                button.Center:SetAtlas("_128-RedButton-Center")
                button.Left:SetAtlas("128-RedButton-Left")
                button.Right:SetAtlas("128-RedButton-Right")
            end
        end
        button:SetTextureStyle(false)
        button.gridShown = false

        if i == 1 then
            -- Position the first button at the left of the buttonFrame without spacing
            button:SetPoint("TOPLEFT", buttonFrame, "TOPLEFT", 0, 0)
        else
            -- Position subsequent buttons to the right of the last button with spacing
            button:SetPoint("LEFT", lastElement, "RIGHT", buttonSpacing, 0)
        end

        button:SetScript("OnClick", function()
            if data.func then
                data.func()
            else
                -- If another button was pressed before and it's not the current button, reset its state
                if lastButtonPressed and lastButtonPressed ~= button then
                    BetterAnchors:HideGrid(lastButtonPressed.grid)
                    lastButtonPressed.gridShown = false
                    lastButtonPressed:SetTextureStyle(false)
                end

                -- Show or hide the grid based on the button's state
                if button.gridShown then
                    BetterAnchors:HideGrid(data.grid)
                    -- button:SetButtonState("NORMAL", false)
                    button.gridShown = false
                    button:SetTextureStyle(false)
                else
                    BetterAnchors:ShowGrid(data.grid)
                    -- button:SetButtonState("PUSHED", true)
                    button.gridShown = true
                    button:SetTextureStyle(true)
                end

                lastButtonPressed = button
            end
        end)

        lastElement = button
    end

    return buttonFrame
end
