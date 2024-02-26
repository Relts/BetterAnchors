local addonName, addon = ...
addon:print("----------- config.lua has been loaded -------")
-- options.lua

local initOptions = false

local function createCheckBoxes(parent, relativeTo)
    addon.checkBoxes = {}
    for i, option in ipairs(addon.CHECK_BOX_OPTIONS) do
        local checkBox = CreateFrame("CheckButton", "BetterAnchorsCheckBox" .. i, parent,
            "InterfaceOptionsCheckButtonTemplate")
        checkBox:SetPoint(option.point, relativeTo, option.relativePoint, option.xOffset, option.yOffset)
        checkBox:SetScript("OnClick", option.onClick)
        checkBox.text:SetText(option.text)
        checkBox.text:SetPoint("LEFT", checkBox, "RIGHT", 10, 0)
        checkBox.name = option.name
        table.insert(addon.checkBoxes, checkBox)
    end
end

local function getCheckBoxByName(name)
    for _, checkbox in ipairs(addon.checkBoxes) do
        if checkbox.name == name then
            return checkbox
        end
    end
end


function addon:SetOptionFramesVisible(checked)
    if not initOptions then
        addon:createOptionsPanel()
    end
    local checkbox = getCheckBoxByName("ShowHideAnchors")
    assert(checkbox, "Checkbox ShowHideAnchors not found")
    checkbox:SetChecked(checked)
end

function addon:SetOptionFramesLocked(checked)
    if not initOptions then
        addon:createOptionsPanel()
    end
    local checkbox = getCheckBoxByName("LockUnlockAnchors")
    assert(checkbox, "Checkbox LockUnlockAnchors not found")
    checkbox:SetChecked(checked)
end

-- Create a panel for the Interface Options
function addon:createOptionsPanel()
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
    --- Adlined a line below the title ---
    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\COMMON\\UI-TooltipDivider-Transparent")
    line:SetSize(500, 2)
    line:SetPoint("TOP", title, "BOTTOM", 0, -10)

    -- -- Assuming createCheckBoxes function is defined and CHECK_BOX_OPTIONS is populated
    createCheckBoxes(panel, line)

    initOptions = true
end

addon:createOptionsPanel()

--TODO add a checkbox to reset anchors to default positions
-- SLIDERS have a "OnValueChanged" script
-- slider:SetScript("OnValueChanged", function(self, value)
--    print("Slider value changed to: " .. value)
-- end)
