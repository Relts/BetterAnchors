local addonName, addon = ...
local ANCHOR_FRAMES = BetterAnchors.ANCHOR_FRAMES
local SCALE_ADJUSTMENT = 0.1

-- Frame Scale Adjustment

-- Increase Frame Scale By Name
function addon:increaseFrameScaleByName(name)
    local frame = _G[name]
    if frame then
        local currentScale = frame:GetScale()
        local newScale = currentScale + SCALE_ADJUSTMENT
        if newScale <= 2 then
            frame:SetScale(newScale)
            BetterAnchorsDB[name] = BetterAnchorsDB[name] or {}
            BetterAnchorsDB[name].Scale = newScale
        else
            addon:errorPrint("Cannot increase scale: new scale value would be greater than 2")
        end
    else
        addon:errorPrint("Frame with name " .. name .. " not found.")
    end
end

-- Decrease Frame Scale By Name
function addon:decreaseFrameScaleByName(frameName)
    local frame = _G[frameName]
    if frame then
        local currentScale = frame:GetScale()
        local newScale = currentScale - SCALE_ADJUSTMENT -- adjust this value as needed
        if newScale >= 0.1 then
            frame:SetScale(newScale)
        else
            addon:errorPrint("Cannot decrease scale: new scale value would be less than 0.1")
        end
    end
end

-- NOTE this function needs fixing to work with the slider
function addon:setFrameScaleByName(frameName, scale)
    local frame = _G[frameName]
    if frame then
        if scale > 0 then
            frame:SetScale(scale)
        else
            addon:errorPrint("Cannot set scale to 0 for " .. frameName)
        end
    else
        addon:errorPrint("Frame " .. frameName .. " not found")
    end
end
