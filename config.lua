print("----------- config.lua has been loaded -------")
-- options.lua
local CHECK_BOX_OPTIONS = BetterAnchors_CHECK_BOX_OPTIONS

local addonName, addon = ...

local initOptions = false

local function createCheckBoxes(name, text, point, relativeTo, relativePoint, xOffset, yOffset, onClick)
    local checkBoxes = {}
    for i, option in ipairs(CHECK_BOX_OPTIONS) do
        local checkBox = CreateFrame("CheckButton", "BetterAnchorsCheckBox" .. i, UIParent,
            "ChatConfigCheckButtonTemplate")
        checkBox:SetPoint(option.point, option.relativeTo, option.relativePoint, option.xOffset, option.yOffset)
        checkBox:SetScript("OnClick", option.onClick)
        checkBox.text:SetText(option.text)
        checkBox.text:SetPoint("left", checkBox, "right", 10, 0)
        table.insert(checkBoxes, checkBox)
    end
    return checkBoxes
end


-- Create a panel for the Interface Options
local function createOptionsPanel()
    if initOptions then
        return
    end
    ---- Create The Panel ----
    local panel = CreateFrame("Frame", "BetterAnchorsOptionsPanel", UIParent)
    panel.name = addonName              -- see panel fields
    InterfaceOptions_AddCategory(panel) -- see InterfaceOptions API
    -- add widgets to the panel as desired
    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP")
    title:SetText(addonName)
    --- Add a line below the title ---
    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\COMMON\\UI-TooltipDivider-Transparent")
    line:SetSize(500, 2)
    line:SetPoint("TOP", title, "BOTTOM", 0, -10)

    -- -- Assuming createCheckBoxes function is defined and CHECK_BOX_OPTIONS is populated
    -- local checkBoxes = createCheckBoxes()

    -- -- Set the checked state based on the framesVisible and framesLocked variables
    -- addon.SetOptionFramesVisible = function(self, checked)
    --     for _, checkbox in ipairs(checkBoxes) do
    --         if checkbox.name == "ShowHideAnchors" then
    --             checkbox:setOption(checked)
    --         end
    --     end
    -- end

    -- addon.SetOptionFramesLocked = function(self, checked)
    --     for _, checkbox in ipairs(checkBoxes) do
    --         if checkbox.name == "LockUnlockAnchors" then
    --             checkbox:setOption(checked)
    --         end
    --     end
    -- end

    -- initOptions = true
    -- return panel

    -- -----------------------------------------------------
    -- -- Add checkbox to show/hide anchors
    local checkboxShowHide = CreateFrame("CheckButton", "BetterAnchorsShowHideCheckbox", panel,
        "InterfaceOptionsCheckButtonTemplate")
    checkboxShowHide:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -20)
    checkboxShowHide:SetScript("OnClick", function(self)
        if self:GetChecked() then
            addon:showAllFrames()
            print("Anchors are now visible")
        else
            addon:hideAllFrames()
            print("Anchors are now hidden")
        end
    end)

    -- Set the checked state based on the framesVisible variable
    addon.SetOptionFramesVisible = function(self, checked)
        checkboxShowHide:SetChecked(checked)
    end
    checkboxShowHide.text:SetText("Show/Hide Anchors")
    checkboxShowHide.text:SetPoint("left", checkboxShowHide, "right", 10, 0)

    -- Add checkbox to lock/unlock anchors
    local checkboxLockUnlock = CreateFrame("CheckButton", "BetterAnchorsLockUnlockCheckbox", panel,
        "InterfaceOptionsCheckButtonTemplate")
    checkboxLockUnlock:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -60)
    checkboxLockUnlock:SetScript("OnClick", function(self)
        -- self is the checkbox frame
        if self:GetChecked() then
            addon:lockAllFrames()
            print("Anchors are now locked")
        else
            addon:unlockAllFrames()
            print("Anchors are now unlocked")
        end
    end)


    -- Set the checked state based on the framesLocked variable
    addon.SetOptionFramesLocked = function(self, checked)
        checkboxLockUnlock:SetChecked(checked)
    end
    checkboxLockUnlock.text:SetText("Lock/Unlock Anchors")
    checkboxLockUnlock.text:SetPoint("left", checkboxLockUnlock, "right", 10, 0)
    initOptions = true
    return panel
end

createOptionsPanel()

--TODO add a checkbox to reset anchors to default positions
-- SLIDERS have a "OnValueChanged" script
-- slider:SetScript("OnValueChanged", function(self, value)
--    print("Slider value changed to: " .. value)
-- end)
