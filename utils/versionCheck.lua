local addonName, BetterAnchors = ...

-- Get version from TOC file metadata using the correct API
local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "0.0.0"
local versionManager = {}
BetterAnchors.versionManager = versionManager

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
    local v1_major, v1_minor, v1_patch = string.match(v1, "(%d+)%.(%d+)%.(%d+)")
    local v2_major, v2_minor, v2_patch = string.match(v2, "(%d+)%.(%d+)%.(%d+)")

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

    -- Print version on load
    BetterAnchors:addonPrint(string.format("Version %s loaded", self.CURRENT_VERSION))
end

function versionManager:BroadcastVersion()
    if IsInGroup() or IsInRaid() then
        local message = self.CURRENT_VERSION
        C_ChatInfo.SendAddonMessage(addonName, message, IsInRaid() and "RAID" or "PARTY")
    end
end

function versionManager:OnVersionReceived(prefix, message, channel, sender)
    if prefix ~= addonName or sender == UnitName("player") then return end

    local theirVersion = message

    -- Check if their version is compatible
    if not self.COMPATIBLE_VERSIONS[theirVersion] then
        -- Version mismatch detected
        if CompareVersions(theirVersion, self.CURRENT_VERSION) then
            -- Their version is older
            BetterAnchors:addonPrint(string.format(
                "|cffff0000Warning:|r %s is using an older version (%s). Please ask them to update.",
                sender, theirVersion
            ))
        else
            -- Their version is newer
            BetterAnchors:addonPrint(string.format(
                "|cffff0000Warning:|r %s is using a newer version (%s). Please update your addon.",
                sender, theirVersion
            ))
        end
    end
end

function versionManager:HandleVersionCommand()
    BetterAnchors:addonPrint(string.format("Current version: %s", self.CURRENT_VERSION))
    self:BroadcastVersion()
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

    BetterAnchors:addonPrint("=== Starting Version Check Test ===")
    BetterAnchors:addonPrint(string.format("Your version: %s", self.CURRENT_VERSION))

    for _, test in ipairs(testCases) do
        -- Simulate receiving version from other player
        self:OnVersionReceived(
            addonName,
            test.version,
            "WHISPER",
            test.name
        )
    end

    BetterAnchors:addonPrint("=== Version Check Test Complete ===")
end

----- TESTING FUNCTION END -----
