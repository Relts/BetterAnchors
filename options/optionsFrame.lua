local addonName, BetterAnchors = ...


-- create options frame with option elements
-- move frame logic


local function BuildOptionsForOptionsFrame()
    local anchorFrames = BetterAnchors.anchorFrames
    local index = 0
    for anchorName, anchorFrame in pairs(anchorFrames) do
        local frame = CreateFrame("Frame", nil, BetterAnchors.optionsFrame)
        frame:SetSize(1, 30)
        frame:SetPoint("TOPLEFT", BetterAnchors.optionsFrame, "TOPLEFT", 10, (-35 * index) - 10)
        frame:SetPoint("TOPRIGHT", BetterAnchors.optionsFrame, "TOPRIGHT", -10, (-35 * index) - 10)

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
        slider:SetSize(150, 25)
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

        index = index + 1
    end
end



local function CreateOptionsFrame()
    local optionsFrame = CreateFrame("Frame", "BetterAnchorsOptionsFrame", UIParent, "BackdropTemplate")
    optionsFrame:SetSize(320, 600)
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

-- TODO: add grid buttons
-- TODO: add options frame title
-- TODO: add close button to options frame
-- TODO: add reset button to reset all

-- TODO: If we are bored add grid snapping
