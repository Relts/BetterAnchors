local addonName, addon = ...

SLASH_BAGRID1 = "/bagrid"

local frame

-- Found data for table at: https://www.curseforge.com/wow/addons/screengrid

local GRID_SIZES = {
    -- Standard Monitors 16:9
    ['128'] = { w = 128, h = 72 },
    ['96'] = { w = 96, h = 54 },
    ['64'] = { w = 64, h = 36 },
    ['32'] = { w = 32, h = 18 },
    -- UltraWide Monitors 21:9
    ['uw'] = { w = 128, h = 54 },
    ['uw2'] = { w = 86, h = 36 },
    -- 4k Monitors 16:9
    ['4k'] = { w = 128, h = 72 }
}

function addon:getLineColor(index)
    if index == 0 then
        -- Pink color for index 0
        return { 1, 0, 1, 0.5 }
    elseif index % 8 == 0 then
        -- Light blue color for multiples of 8
        return { 0, 0.5, 1, 0.5 }
    else
        -- Light gray color for other indices
        return { 0.7, 0.7, 0.7, 0.1 }
    end
end

function addon:setLines(w, h)
    if not self.frame then
        -- Initialize frame here or handle the error
        addon:print("Error: frame is not initialized")
        return
    end

    local lines_w = GetScreenWidth() / w
    local lines_h = GetScreenHeight() / h
    self.frame.texturePool:ReleaseAll()
    -- Rest of the function
    for i = -w / 2, w / 2 do
        local line = self.frame.texturePool:Acquire()
        line:SetColorTexture(unpack(self:getLineColor(i)))
        line:ClearAllPoints()
        line:SetPoint('TOPLEFT', self.frame, 'TOPLEFT', (i + w / 2) * lines_w - 1, 0)
        line:SetPoint('BOTTOMRIGHT', self.frame, 'BOTTOMLEFT', (i + w / 2) * lines_w + 1, 0)
        line:Show()
    end

    for i = -h / 2, h / 2 do
        local line = self.frame.texturePool:Acquire()
        line:SetColorTexture(unpack(self:getLineColor(i)))
        line:ClearAllPoints()
        line:SetPoint('TOPLEFT', self.frame, 'TOPLEFT', 0, -(i + h / 2) * lines_h + 1)
        line:SetPoint('BOTTOMRIGHT', self.frame, 'TOPRIGHT', 0, -(i + h / 2) * lines_h - 1)
        line:Show()
    end
    self.frame:Show()
end

function addon:createLineParentFrame()
    if self.frame then return end
    self.frame = CreateFrame('Frame', nil, UIParent)
    self.frame:SetAllPoints(UIParent)
    self.frame.texturePool = CreateTexturePool(self.frame, "BACKGROUND");
    self.frame:Hide()
end

SlashCmdList["BAGRID"] = function(msg, editbox)
    addon:createLineParentFrame()
    local gridInfo = GRID_SIZES[msg]
    if not gridInfo then
        if addon.frame:IsShown() then
            addon.frame:Hide()
        else
            -- if no proper grid size is found and the frame is not available then show the usage
            print(
                "Usage: '/bagrid <value>' Value options are '32'/'64'/'96'/'128' or 'uw'/'uw2'/'4k' for Ultrawide Monitors")
        end
        return
    end
    addon:setLines(gridInfo.w, gridInfo.h)
end

----- Functions for other addons to use ----

function addon:loadGrid(gridSize)
    self:createLineParentFrame()
    local size = GRID_SIZES[gridSize]
    if size then
        self:setLines(size.w, size.h)
    end
end

function addon:hideGrid()
    if addon.frame and addon.frame:IsShown() then
        addon.frame:Hide()
    end
end

-- TODO create option size for the grid in a frame
