local addonName, BetterAnchors = ...

function BetterAnchors:CreateMonitorSection(titleText, buttonData, lastElement)
    -- Monitor Title
    local monitorTitle = BetterAnchors.optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    monitorTitle:SetPoint("TOPLEFT", lastElement, "BOTTOMLEFT", -5, -10)
    monitorTitle:SetPoint("TOPRIGHT", lastElement, "BOTTOMRIGHT", 5, -10)
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
    local buttonWidth = (totalWidth - (buttonSpacing * (#buttonData - 1))) /
        #
        buttonData -- Calculate the width of each button based on the buttonFrame width

    for i, data in ipairs(buttonData) do
        local button = CreateFrame("Button", nil, buttonFrame, "BigGoldRedThreeSliceButtonTemplate") -- Create the button inside the buttonFrame
        button:SetNormalFontObject("GameFontNormalSmall")
        button:SetText(data.text)
        button:SetSize(buttonWidth, 25) -- Set the width of the button

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
                BetterAnchors:ShowGrid(data.grid)
            end
        end)

        lastElement = button
    end

    return buttonFrame
end
