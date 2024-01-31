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
    checkboxShowHide:SetChecked(addon.framesVisible) -- Set the checked state based on the framesVisible variable
    checkboxShowHide.text:SetText("Show/Hide Anchors")
    checkboxShowHide.text:SetPoint("left", checkboxShowHide, "right", 10, 0)

    -- Add checkbox to lock/unlock anchors
    local checkboxLockUnlock = CreateFrame("CheckButton", "BetterAnchorsLockUnlockCheckbox", panel,
        "InterfaceOptionsCheckButtonTemplate")
    checkboxLockUnlock:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -60)
    checkboxLockUnlock:SetScript("OnClick", function(self)
        if self:GetChecked() then
            addon:lockAllFrames()
            print("Anchors are now locked")
        else
            addon:unlockAllFrames()
            print("Anchors are now unlocked")
        end
    end)
    checkboxLockUnlock:SetChecked(addon.framesLocked) -- Set the checked state based on the framesLocked variable
    checkboxLockUnlock.text:SetText("Lock/Unlock Anchors")
    checkboxLockUnlock.text:SetPoint("left", checkboxLockUnlock, "right", 10, 0)
    return panel
end

createOptionsPanel()

-- REVIEW ask nerc about why the check boxes dont remember the state they should be in
--TODO add a checkbox to reset anchors to default positions
