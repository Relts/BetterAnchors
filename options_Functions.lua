local addonName, addon = ...
local ANCHOR_FRAMES = BetterAnchors.ANCHOR_FRAMES
local SCALE_ADJUSTMENT = 0.1

-- Get Frame By Name
local function getFrameByName(name)
    local frame = _G[name]
    if not frame then
        addon:errorPrint("Frame with name " .. name .. " not found.")
    end
    return frame
end

-- Increase Frame Scale By Name
function addon:increaseFrameScaleByName(name)
    local frame = getFrameByName(name)
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
    end
end

-- Decrease Frame Scale By Name
function addon:decreaseFrameScaleByName(name)
    local frame = getFrameByName(name)
    if frame then
        local currentScale = frame:GetScale()
        local newScale = currentScale - SCALE_ADJUSTMENT
        if newScale >= 0.1 then
            frame:SetScale(newScale)
        else
            addon:errorPrint("Cannot decrease scale: new scale value would be less than 0.1")
        end
    end
end

-- Set Frame Scale By Name
function addon:setFrameScaleByName(name, scale)
    local frame = getFrameByName(name)
    if frame then
        if scale > 0 then
            frame:SetScale(scale)
        else
            addon:errorPrint("Cannot set scale to 0 for " .. name)
        end
    end
end
