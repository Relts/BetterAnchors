local addonName, BetterAnchors = ...

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

function BetterAnchors:GetLineColor(index)
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

function BetterAnchors:SetLines(w, h)
    if not self.gridFrame then
        -- Initialize frame here or handle the error
        return
    end

    local lines_w = GetScreenWidth() / w
    local lines_h = GetScreenHeight() / h
    self.gridFrame.texturePool:ReleaseAll()

    for i = -w / 2, w / 2 do
        local line = self.gridFrame.texturePool:Acquire()
        line:SetColorTexture(unpack(self:GetLineColor(i)))
        line:ClearAllPoints()
        line:SetPoint('TOPLEFT', self.gridFrame, 'TOPLEFT', (i + w / 2) * lines_w - 1, 0)
        line:SetPoint('BOTTOMRIGHT', self.gridFrame, 'BOTTOMLEFT', (i + w / 2) * lines_w + 1, 0)
        line:Show()
    end

    for i = -h / 2, h / 2 do
        local line = self.gridFrame.texturePool:Acquire()
        line:SetColorTexture(unpack(self:GetLineColor(i)))
        line:ClearAllPoints()
        line:SetPoint('TOPLEFT', self.gridFrame, 'TOPLEFT', 0, -(i + h / 2) * lines_h + 1)
        line:SetPoint('BOTTOMRIGHT', self.gridFrame, 'TOPRIGHT', 0, -(i + h / 2) * lines_h - 1)
        line:Show()
    end
    self.gridFrame:Show()
end

function BetterAnchors:CreateLineParentFrame()
    if self.gridFrame then return end
    local gridFrame = CreateFrame('Frame', nil, UIParent)
    gridFrame:SetAllPoints(UIParent)
    gridFrame.texturePool = CreateTexturePool(gridFrame, "BACKGROUND");
    gridFrame:Hide()
    self.gridFrame = gridFrame
end

function BetterAnchors:ShowGrid(gridSize)
    self:CreateLineParentFrame()
    local size = GRID_SIZES[gridSize]
    if size then
        self:SetLines(size.w, size.h)
    end
end

function BetterAnchors:HideGrid()
    if BetterAnchors.gridFrame and BetterAnchors.gridFrame:IsShown() then
        BetterAnchors.gridFrame:Hide()
    end
end
