local addonName, addon = ...

SLASH_BAGRID1 = "/bagrid"

local frame
local w
local h

local gridSizes = {
    ['128'] = { w = 128, h = 72 },
    ['96'] = { w = 96, h = 54 },
    ['64'] = { w = 64, h = 36 },
    ['32'] = { w = 32, h = 18 },
    ['uw'] = { w = 128, h = 54 },
    ['uw2'] = { w = 86, h = 36 },
    ['4k'] = { w = 128, h = 72 }
}

local function createLine(isCenterLine, isBlueLine)
    local line_texture = frame:CreateTexture(nil, 'BACKGROUND')
    line_texture:SetColorTexture(isCenterLine and 1 or isBlueLine and 0 or 0.7,
        isCenterLine and 0 or isBlueLine and 0.5 or 0.7,
        isCenterLine and 1 or isBlueLine and 1 or 0.7,
        isCenterLine and 0.5 or isBlueLine and 0.5 or 0.1)
    return line_texture
end

local function BuildHorizontalLines(lines_w, lines_h)
    for i = -w / 2, w / 2 do
        local isCenterLine = i == 0
        local isBlueLine = i % 8 == 0
        local line_texture = createLine(isCenterLine, isBlueLine)
        line_texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', (i + w / 2) * lines_w - 1, 0)
        line_texture:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', (i + w / 2) * lines_w + 1, 0)
    end
end

local function BuildVerticalLines(lines_w, lines_h)
    for i = -h / 2, h / 2 do
        local isCenterLine = i == 0
        local isBlueLine = i % 8 == 0
        local line_texture = createLine(isCenterLine, isBlueLine)
        line_texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -(i + h / 2) * lines_h + 1)
        line_texture:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, -(i + h / 2) * lines_h - 1)
    end
end

local function buildLines(lines_w, lines_h)
    BuildHorizontalLines(lines_w, lines_h)
    BuildVerticalLines(lines_w, lines_h)
end

SlashCmdList["BAGRID"] = function(msg, editbox)
    if frame then
        frame:Hide()
        frame = nil
        return
    end

    local gridSize = gridSizes[msg]
    if gridSize then
        w = gridSize.w
        h = gridSize.h
    end

    if not w then
        print(
            "Usage: '/bagrid <value>' Value options are '32'/'64'/'96'/'128' or 'uw'/'uw2'/'4k' for Ultrawide Monitors")
        return
    end

    local lines_w = GetScreenWidth() / w
    local lines_h = GetScreenHeight() / h

    frame = CreateFrame('Frame', nil, UIParent)
    frame:SetAllPoints(UIParent)

    buildLines(lines_w, lines_h)
end

--TODO add left and right margin lines that the user can define