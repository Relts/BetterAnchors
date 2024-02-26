local addonName, addon = ...

-- Slah Command for activation - Usage : /soe <value>
SLASH_BAGRID1 = "/bagrid"

-- local variables for frame and line points
local frame
local w
local h

-- Map for grid sizes
local gridSizes = {
    ['128'] = { w = 128, h = 72 },
    ['96'] = { w = 96, h = 54 },
    ['64'] = { w = 64, h = 36 },
    ['32'] = { w = 32, h = 18 },
    ['uw'] = { w = 128, h = 54 },
    ['uw2'] = { w = 86, h = 36 },
    ['4k'] = { w = 128, h = 72 }
}


local function BuildHorizontalLines(lines_w, lines_h)
    for i = -w / 2, w / 2 do
        local line_texture = frame:CreateTexture(nil, 'BACKGROUND')
        local isCenterLine = i == 0
        local isBlueLine = i % 8 == 0
        line_texture:SetColorTexture(isCenterLine and 1 or isBlueLine and 0 or 0.7,
            isCenterLine and 0 or isBlueLine and 0.5 or 0.7,
            isCenterLine and 1 or isBlueLine and 1 or 0.7,
            isCenterLine and 0.5 or isBlueLine and 0.5 or 0.1) -- Changed alpha value for blue lines to 0.5
        line_texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', (i + w / 2) * lines_w - 1, 0)
        line_texture:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', (i + w / 2) * lines_w + 1, 0)
    end
end

local function BuildVerticalLines(lines_w, lines_h)
    for i = -h / 2, h / 2 do
        local line_texture = frame:CreateTexture(nil, 'BACKGROUND')
        local isCenterLine = i == 0
        local isBlueLine = i % 8 == 0
        line_texture:SetColorTexture(isCenterLine and 1 or isBlueLine and 0 or 0.7,
            isCenterLine and 0 or isBlueLine and 0.5 or 0.7,
            isCenterLine and 1 or isBlueLine and 1 or 0.7,
            isCenterLine and 0.5 or isBlueLine and 0.5 or 0.1) -- Changed alpha value for blue lines to 0.5
        line_texture:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -(i + h / 2) * lines_h + 1)
        line_texture:SetPoint('BOTTOMRIGHT', frame, 'TOPRIGHT', 0, -(i + h / 2) * lines_h - 1)
    end
end

local function buildLines(lines_w, lines_h)
    BuildHorizontalLines(lines_w, lines_h)
    BuildVerticalLines(lines_w, lines_h)
end


-- Command function for "SOEREA"
SlashCmdList["BAGRID"] = function(msg, editbox)
    -- If frame exists, hide it and clear the reference
    if frame then
        frame:Hide()
        frame = nil
        return
    end

    -- Get grid size from the map using the input message
    local gridSize = gridSizes[msg]
    if gridSize then
        w = gridSize.w
        h = gridSize.h
    end

    -- If width is not set, print usage message and return
    if not w then
        print(
            "Usage: '/bagrid <value>' Value options are '32'/'64'/'96'/'128' or 'uw'/'uw2'/'4k' for Ultrawide Monitors")
        return
    end

    -- Calculate the number of lines in width and height
    local lines_w = GetScreenWidth() / w
    local lines_h = GetScreenHeight() / h

    -- Create a new frame and set it to cover the entire parent
    frame = CreateFrame('Frame', nil, UIParent)
    frame:SetAllPoints(UIParent)

    buildLines(lines_w, lines_h)
end


--TODO add left and right margin lines that the user can define
