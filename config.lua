print("-----------config.lua has been loaded -------")

local addonName, addon = ...

-- Create a panel for the Interface Options
local function createOptionsPanel()
    local panel = CreateFrame("Frame", "BetterAnchorsOptionsPanel", UIParent)
    panel.name = addonName              -- see panel fields
    InterfaceOptions_AddCategory(panel) -- see InterfaceOptions API
    -- add widgets to the panel as desired
    local title = panel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
    title:SetPoint("TOP")
    title:SetText(addonName)
    -- Add a line below the title
    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetTexture("Interface\\COMMON\\UI-TooltipDivider-Transparent")
    line:SetSize(500, 2)
    line:SetPoint("TOP", title, "BOTTOM", 0, -10)
    -- Add checkbox to show/hide anchors
    local checkbox = CreateFrame("CheckButton", "BetterAnchorsShowHideCheckbox", panel,
        "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -20)
    checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            addon:toggleFrames()
            print("Anchors are now visible")
        else
            addon:toggleFrames()
            print("Anchors are now hidden")
        end
    end)
    checkbox:SetChecked(true)
    checkbox.text:SetText("Show/Hide Anchors")
    return panel
end

createOptionsPanel()

--TODO add a checkbox to show/hide anchors
--TODO add a checkbox to lock/unlock anchors
--TODO add a checkbox to reset anchors to default positions