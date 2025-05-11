---@diagnostic disable: undefined-global

local addonName, BetterAnchors = ...

-- Get version from TOC file metadata using the correct API
local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "0.0.0"
local versionManager = {}
BetterAnchors.versionManager = versionManager

-- Spam prevention: track last warning time and version
versionManager.lastWarningTime = 0
versionManager.lastWarnedVersion = nil
versionManager.WARNING_COOLDOWN = 600 -- 10 minutes in seconds

-- Version tracking
versionManager.CURRENT_VERSION = version
versionManager.MIN_SUPPORTED_VERSION = "1.0.0"
versionManager.COMPATIBLE_VERSIONS = {
    [version] = true, -- Current version is always compatible
    ["1.0.10"] = true,
    ["1.0.9"] = true,
    -- Add other compatible versions
}

-- Version comparison function
local function CompareVersions(v1, v2)
    local v1_major, v1_minor, v1_patch = v1:match("(%d+)%.(%d+)%.(%d+)")
    local v2_major, v2_minor, v2_patch = v2:match("(%d+)%.(%d+)%.(%d+)")

    v1_major, v1_minor, v1_patch = tonumber(v1_major), tonumber(v1_minor), tonumber(v1_patch)
    v2_major, v2_minor, v2_patch = tonumber(v2_major), tonumber(v2_minor), tonumber(v2_patch)

    if v1_major ~= v2_major then return v1_major < v2_major end
    if v1_minor ~= v2_minor then return v1_minor < v2_minor end
    return v1_patch < v2_patch
end

function versionManager:Initialize()
    -- Register addon message prefix
    C_ChatInfo.RegisterAddonMessagePrefix(addonName)

    -- Create frame for communication events
    local versionFrame = CreateFrame("Frame")
    versionFrame:RegisterEvent("CHAT_MSG_ADDON")
    versionFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    versionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    versionFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_ADDON" then
            self:OnVersionReceived(...)
        elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
            self:BroadcastVersion()
        end
    end)

    --REMOVE: Print version on load not used
    -- BetterAnchors:addonPrint(string.format("Version %s loaded", self.CURRENT_VERSION))
end

function versionManager:BroadcastVersion()
    if IsInGroup() or IsInRaid() then
        local message = self.CURRENT_VERSION
        C_ChatInfo.SendAddonMessage(addonName, message, IsInRaid() and "RAID" or "PARTY")
        self.versionBroadcasted = true
        C_Timer.After(10, function()
            self.versionBroadcasted = false
        end) -- Reset flag after 10 seconds to resolve the players phasing in to the zone and triggering the status update event.
    end
end

function versionManager:OnVersionReceived(prefix, message, channel, sender)
    if prefix ~= addonName or sender == UnitName("player") then return end

    if message == "REQ_VERSION" then
        -- Reply with our version
        C_ChatInfo.SendAddonMessage(addonName, self.CURRENT_VERSION, "WHISPER", sender)
        return
    end

    -- Otherwise, treat as version reply
    local theirVersion = message
    self.receivedVersions = self.receivedVersions or {}
    self.receivedVersions[sender] = theirVersion

    -- Check if their version is newer
    if CompareVersions(self.CURRENT_VERSION, theirVersion) then
        -- Only warn if not already warned for this version recently
        local now = time()
        if self.lastWarnedVersion ~= theirVersion or (now - (self.lastWarningTime or 0)) > self.WARNING_COOLDOWN then
            BetterAnchors:addonPrint(string.format(
                "|cffff0000Warning:|r Addon is out of date. Please update to the latest version (%s -> %s).",
                self.CURRENT_VERSION, theirVersion
            ))
            self.lastWarningTime = now
            self.lastWarnedVersion = theirVersion
        end
    end
end

function versionManager:HandleVersionCommand()
    BetterAnchors:addonPrint(string.format("Current version: %s", self.CURRENT_VERSION))
    self:BroadcastVersion()
end

--- Version Chat Print List Red means out of date green means in date.
---

function versionManager:PrintAllUserVersionsInChat()
    local output = {
        "=== Starting Version Check ===",
        string.format("Your version: %s", self.CURRENT_VERSION)
    }

    local numMembers = GetNumGroupMembers()
    self.receivedVersions = {} -- Reset before requesting

    -- Send version request to all group members
    for i = 1, numMembers do
        local name = GetRaidRosterInfo(i)
        if name and name ~= UnitName("player") then
            C_ChatInfo.SendAddonMessage(addonName, "REQ_VERSION", "WHISPER", name)
        end
    end

    -- Wait 2 seconds for responses, then print
    C_Timer.After(2, function()
        local highestVersion = self.CURRENT_VERSION
        -- First pass: Determine the highest version
        for i = 1, numMembers do
            local name = GetRaidRosterInfo(i)
            if name then
                local theirVersion = self.receivedVersions[name] or self.CURRENT_VERSION
                if CompareVersions(highestVersion, theirVersion) then
                    highestVersion = theirVersion
                end
            end
        end
        -- Second pass: Print versions with color coding
        for i = 1, numMembers do
            local name, _, _, _, _, class = GetRaidRosterInfo(i)
            if name then
                local theirVersion = self.receivedVersions[name] or "Unknown"
                local versionColor = "|cffff0000"
                if theirVersion == highestVersion then
                    versionColor = "|cff00ff00"
                end
                local classColor = RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr or "ffffffff"
                table.insert(output,
                    string.format("|c%s%s|r: %sVersion %s|r", classColor, name, versionColor, theirVersion))
            end
        end
        table.insert(output, "=== Version Check Complete ===")
        BetterAnchors:addonPrint(table.concat(output, "\n"))
    end)
end

----- TESTING FUNCTION START -----
function versionManager:TestVersionCheck()
    -- Simulate different version scenarios
    local testCases = {
        { name = "OlderPlayer",   version = "1.0.8" },
        { name = "NewerPlayer",   version = "1.1.1" },
        { name = "SamePlayer",    version = self.CURRENT_VERSION },
        { name = "InvalidPlayer", version = "2.0.0" }
    }

    local output = {
        "=== Starting Version Check Test ===",
        string.format("Your version: %s", self.CURRENT_VERSION)
    }

    for _, test in ipairs(testCases) do
        -- Simulate receiving version from other player
        self:OnVersionReceived(
            addonName,
            test.version,
            "WHISPER",
            test.name
        )
    end

    table.insert(output, "=== Version Check Test Complete ===")
    BetterAnchors:addonPrint(table.concat(output, "\n"))
end

----- TESTING FUNCTION END -----
