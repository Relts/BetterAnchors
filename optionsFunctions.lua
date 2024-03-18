local addonName, addon = ...
local ANCHOR_FRAMES = BetterAnchors.ANCHOR_FRAMES
local SCALE_ADJUSTMENT = addon.SCALE_ADJUSTMENT


----------------------------------------------------------
-- Scale Functions
----------------------------------------------------------

-- Custom round function
function addon:round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

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
        local newScale = addon:round((currentScale + SCALE_ADJUSTMENT), 2)
        if newScale <= 2 then
            frame:SetScale(newScale)
            BetterAnchorsDB[name] = BetterAnchorsDB[name] or {}
            BetterAnchorsDB[name].Scale = newScale
            addon:updateScaleLabel(name)
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
        local newScale = addon:round((currentScale - SCALE_ADJUSTMENT), 2)
        if newScale >= 0.1 then
            frame:SetScale(newScale)
            BetterAnchorsDB[name] = BetterAnchorsDB[name] or {}
            BetterAnchorsDB[name].Scale = newScale
            addon:updateScaleLabel(name)
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
            -- Round the scale to the nearest hundredth
            local newScale = addon:round(scale, 2)
            frame:SetScale(newScale)
        else
            addon:errorPrint("Cannot set scale to 0 for " .. name)
        end
    end
end
