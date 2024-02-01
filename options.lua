print "--- Options Loaded ---"


BetterAnchors_CHECK_BOX_OPTIONS = { -- Check Box Table
    {                               -- Show Anchors Check Box
        name = "ShowHideAnchors",
        text = "Show/Hide Anchors",
        point = "TOPLEFT",
        relativeTo = "line",
        relativePoint = "BOTTOMLEFT",
        xOffset = 0,
        yOffset = -20,
        onClick = function(self)
            if self:GetChecked() then
                addon:showAllFrames()
                print("Anchors are now visible")
            else
                addon:hideAllFrames()
                print("Anchors are now hidden")
            end
        end,
        setOption = function(self, checked)
            checkboxShowHide:SetChecked(checked)
        end
    },


    { -- Lock Anchors Check Box
        name = "LockUnlockAnchors",
        text = "Lock/Unlock Anchors",
        point = "TOPLEFT",
        relativeTo = "line",
        relativePoint = "BOTTOMLEFT",
        xOffset = 0,
        yOffset = -60,
        onClick = function(self)
            if self:GetChecked() then
                addon:lockAllFrames()
                print("Anchors are now locked")
            else
                addon:unlockAllFrames()
                print("Anchors are now unlocked")
            end
        end,
        setOption = function(self, checked)
            checkboxLockUnlock:SetChecked(checked)
        end
    },
}

return CHECK_BOX_OPTIONS
