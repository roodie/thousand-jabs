local TJ = LibStub('AceAddon-3.0'):GetAddon('ThousandJabs')
local Core = TJ:GetModule('Core')
local Config = TJ:GetModule('Config')
local Profiling = TJ:GetModule('Profiling')
local TableCache = TJ:GetModule('TableCache')
local UnitCache = TJ:GetModule('UnitCache')
local UI = TJ:GetModule('UI')

local LSD = LibStub('LibSerpentDump')

local co_create = coroutine.create
local co_resume = coroutine.resume
local co_status = coroutine.status
local GetAddOnInfo = GetAddOnInfo
local GetNumAddOns = GetNumAddOns
local GetSpecialization = GetSpecialization
local GetSpellBaseCooldown = GetSpellBaseCooldown
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime
local LoadAddOn = LoadAddOn
local mmax = math.max
local NewTicker = C_Timer.NewTicker
local pairs = pairs
local select = select
local tconcat = table.concat
local UnitChannelInfo = UnitChannelInfo
local UnitClass = UnitClass
local UnitSpellHaste = UnitSpellHaste

Core:Safety()

------------------------------------------------------------------------------------------------------------------------
-- Locals
------------------------------------------------------------------------------------------------------------------------

-- Timer update
local screenUpdateTimer = nil
local queuedScreenUpdateTime = Core.devMode and 0.05 or 0.2  -- seconds (high-speed in dev mode, hopefully trigger issues)
local watchdogScreenUpdateTime = 0.75 -- seconds
local nextScreenUpdateExpiry = GetTime()
local watchdogScreenUpdateExpiry = GetTime()

-- Profile reload frequency
local lastProfileReload = 0
local profileReloadThrottle = 2 -- Seconds

------------------------------------------------------------------------------------------------------------------------
-- Shared private variables
------------------------------------------------------------------------------------------------------------------------

-- The active profile
TJ.currentProfile = nil

-- Time combat was last entered
TJ.combatStart = 0

-- Cast tracking
TJ.abilitiesUsed = {}
TJ.lastCastTimes = {}
TJ.castsOffGCD = {}
TJ.lastMainhandAttack = 0
TJ.lastOffhandAttack = 0

-- Incoming damage tracking
TJ.lastIncomingDamage = 0
TJ.damageTable = {}

-- Target tracking
TJ.seenTargets = {}

------------------------------------------------------------------------------------------------------------------------
-- Addon initialisation
------------------------------------------------------------------------------------------------------------------------
function TJ:OnInitialize()
    -- Upgrade any config entries that need to be updated
    Config:Upgrade()
end

------------------------------------------------------------------------------------------------------------------------
-- Command queue
------------------------------------------------------------------------------------------------------------------------

local commandQueue = {}

function TJ:ExecuteFuncAsCoroutine(funcToExec)
    local th = co_create(funcToExec)
    commandQueue[th] = true
    TJ:QueueUpdate()
end

function TJ:RunFuncCoroutines()
    for th in pairs(commandQueue) do
        if co_status(th) == "dead" then
            commandQueue[th] = nil
        else
            co_resume(th)
        end
        TJ:QueueUpdate()
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Screen update
------------------------------------------------------------------------------------------------------------------------

function TJ:QueueUpdate()
    local now = GetTime()

    if not screenUpdateTimer then
        watchdogScreenUpdateExpiry = now + watchdogScreenUpdateTime
        screenUpdateTimer = NewTicker(Core.devMode and 0.01 or 0.1, function() TJ:PerformUpdate() end)
    end

    nextScreenUpdateExpiry = nextScreenUpdateExpiry or now + queuedScreenUpdateTime
end

function TJ:QueueProfileReload()
    TJ.needsProfileReload = true
    TJ:QueueUpdate()
end

function TJ:PerformUpdate()
    -- Drop out early if we're not needed yet
    local now = GetTime()
    if watchdogScreenUpdateExpiry > now then
        if not nextScreenUpdateExpiry or nextScreenUpdateExpiry > now then
            return
        end
    end

    -- Reset the expiry times
    nextScreenUpdateExpiry = nil
    watchdogScreenUpdateExpiry = now + watchdogScreenUpdateTime

    -- Clear out any errors for the last screen update
    Core:DebugReset()

    -- Update stats
    Core:UpdateUsageStatistics()

    -- Purge any old cast times
    local expiryTime = 10 * (TJ.currentGCD or 1)
    for k,v in pairs(TJ.abilitiesUsed) do
        if k + expiryTime < now then
            TJ.abilitiesUsed[k] = nil
        end
    end
    for k,v in pairs(TJ.lastCastTimes) do
        if v + expiryTime < now then
            TJ.lastCastTimes[k] = nil
        end
    end
    for k,v in pairs(TJ.seenTargets) do
        if v + expiryTime < now then
            TJ.seenTargets[k] = nil
        end
    end

    if TJ.needsProfileReload and lastProfileReload + profileReloadThrottle < now then
        TJ.needsProfileReload = nil
        lastProfileReload = now

        -- Deactivate the current profile
        TJ:DeactivateProfile()
        -- Activate the new profile if present
        TJ:ActivateProfile()
    end

    if TJ.currentProfile then
        -- Set up frame fading
        UI:UpdateAlpha()

        -- Cache current player/target information if requested
        UnitCache:UpdateUnitCache('player')
        UnitCache:UpdateUnitCache('target')

        -- Perform the prediction...
        self:ExecuteAllActionProfiles()

        -- Attempt to work out the cooldown frame, based off the GCD
        local start, duration = GetSpellCooldown(61304)

        -- ....unless we're currently channeling something (i.e. fists of fury), in which case use the rest of its channel time
        local channelName, _, _, _, channelStart, channelEnd = UnitChannelInfo('player')
        if channelName then
            start = (channelStart * 0.001)
            duration = (channelEnd - channelStart) * 0.001
        end
        -- set the cooldown
        if start and duration then
            UI:SetCooldown(start, duration)
        end
    end

    -- Perform a debugging screen update as well
    Core:UpdateLog()

    -- Run any commands in the queue
    self:RunFuncCoroutines()
end

Profiling:ProfileFunction(TJ, 'PerformUpdate')

------------------------------------------------------------------------------------------------------------------------
-- Profile activation/deactivation
------------------------------------------------------------------------------------------------------------------------

function TJ:GetActiveProfile()
    local classID, specID = select(3, UnitClass('player')), GetSpecialization()
    local isDisabled = Config:Get("class", classID, "spec", specID, "disabled") and true or false
    local profile = self.profiles and self.profiles[classID] and self.profiles[classID][specID] or nil
    local betaAllowed = Config:Get("allowBetaProfiles")
    local isBetaProfile = profile and profile.betaProfile and true or false
    if (isBetaProfile and betaAllowed) then
        return profile
    elseif (not isBetaProfile) then
        return profile
    end
end

function TJ:ActivateProfile()
    -- Set up a base GCD, this will change during combat
    self.currentGCD = 1

    -- Find a profile based on current class/spec
    TJ.currentProfile = self:GetActiveProfile()

    -- If we actually have a profile to show, activate it
    if TJ.currentProfile then
        -- Activate the profile
        TJ.currentProfile:Activate()

        -- Create new state
        self.state = self:CreateNewState()

        -- Show the frame
        UI:Show()
        UI:EnableMouse(self.movable)
        UI:UpdateAlpha()

        -- Register event listeners
        TJ:RegisterEvent('PLAYER_LEVEL_UP', 'GENERIC_RELOAD_PROFILE_HANDLER')
        TJ:RegisterEvent('PLAYER_REGEN_ENABLED')
        TJ:RegisterEvent('PLAYER_REGEN_DISABLED')
        TJ:RegisterEvent('PLAYER_TARGET_CHANGED', 'GENERIC_EVENT_UPDATE_HANDLER')
        TJ:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        TJ:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
        TJ:RegisterEvent('PLAYER_TALENT_UPDATE', 'GENERIC_RELOAD_PROFILE_HANDLER')
        TJ:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN', 'GENERIC_EVENT_UPDATE_HANDLER')
        TJ:RegisterEvent('PET_BAR_UPDATE', 'GENERIC_EVENT_UPDATE_HANDLER')
        TJ:RegisterEvent('PET_BAR_UPDATE_COOLDOWN', 'GENERIC_EVENT_UPDATE_HANDLER')
        TJ:RegisterEvent('UNIT_POWER')
        TJ:RegisterEvent('UNIT_POWER_FREQUENT', 'UNIT_POWER')
        TJ:RegisterEvent('UNIT_PET')
        TJ:RegisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW', 'GENERIC_EVENT_UPDATE_HANDLER')
    else
        UI:Hide()
        UI:EnableMouse(false)
    end

    self:QueueUpdate()
end

Profiling:ProfileFunction(TJ, 'ActivateProfile')

function TJ:DeactivateProfile()
    -- Clear the update timer
    if screenUpdateTimer then screenUpdateTimer:Cancel() end
    screenUpdateTimer = nil

    -- Hide the frame
    UI:Hide()

    -- Destroy states
    if self.state then self.state = nil end

    -- Remove event listeners
    TJ:UnregisterEvent('SPELL_ACTIVATION_OVERLAY_GLOW_SHOW')
    TJ:UnregisterEvent('UNIT_PET')
    TJ:UnregisterEvent('UNIT_POWER_FREQUENT')
    TJ:UnregisterEvent('UNIT_POWER')
    TJ:UnregisterEvent('PET_BAR_UPDATE_COOLDOWN')
    TJ:UnregisterEvent('PET_BAR_UPDATE')
    TJ:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
    TJ:UnregisterEvent('PLAYER_TALENT_UPDATE')
    TJ:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    TJ:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    TJ:UnregisterEvent('PLAYER_TARGET_CHANGED')
    TJ:UnregisterEvent('PLAYER_REGEN_DISABLED')
    TJ:UnregisterEvent('PLAYER_REGEN_ENABLED')
    TJ:UnregisterEvent('PLAYER_LEVEL_UP')

    -- Deactivate the current profile
    if TJ.currentProfile then
        TJ.currentProfile:Deactivate()
        TJ.currentProfile = nil
    end

    self:QueueUpdate()
end

Profiling:ProfileFunction(TJ, 'DeactivateProfile')

------------------------------------------------------------------------------------------------------------------------
-- Queued profile actions
------------------------------------------------------------------------------------------------------------------------

function TJ:ExportCurrentProfile()
    if TJ.currentProfile and self.state then
        local actionsTable = self.state:ExportActionsTable()
        local dbg = Core:GenerateDebuggingInformation()
        Core:OpenDebugWindow('ThousandJabs Current profile', 'zzzz='..LSD({
            ['!dbg'] = dbg,
            ['actions'] = actionsTable,
            ['parsed'] = self.state:ExportParsedTable(),
        }):gsub('|', '||'))
    end
end

------------------------------------------------------------------------------------------------------------------------
-- APL Execution
------------------------------------------------------------------------------------------------------------------------

function TJ:ExecuteAllActionProfiles()
    -- Work out how many targets we're dealing with
    local targetCount = 0
    if Config:Get('displayMode') == 'automatic' then
        for k,v in Core:OrderedPairs(self.seenTargets) do
            targetCount = targetCount + 1
        end
    else
        targetCount = 1
    end
    targetCount = mmax(1, targetCount)

    -- Reset the single-target state
    Core:Debug("")
    Core:Debug(Config:Get('displayMode') ~= 'automatic' and "|cFFFFFFFFSingle Target|r" or "|cFFFFFFFFAutomatic Target Counting|r" )
    self.state:Reset(targetCount)

    -- Export the current profile state just after reset, if requested
    if TJ.needExportCurrentProfile then
        TJ.needExportCurrentProfile = nil
        Core:DevPrint("Exporting current profile...")
        self:ExportCurrentProfile()
    end

    -- Calculate the single-target profiles
    local action = self.state:PredictNextAction() or "wait"
    UI:SetAction(UI.SINGLE_TARGET, 1, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
    action = self.state:PredictActionFollowing(action) or "wait"
    UI:SetAction(UI.SINGLE_TARGET, 2, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
    action = self.state:PredictActionFollowing(action) or "wait"
    UI:SetAction(UI.SINGLE_TARGET, 3, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
    action = self.state:PredictActionFollowing(action) or "wait"
    UI:SetAction(UI.SINGLE_TARGET, 4, self.state.env[action].Icon, self.state.env[action].OverlayTitle)

    if Config:Get('displayMode') ~= 'automatic' then
        if Config:Get('showCleave') then
            Core:Debug("")
            Core:Debug("|cFFFFFFFFCleave|r")
            self.state:Reset(2)
            action = self.state:PredictNextAction() or "wait"
            UI:SetAction(UI.CLEAVE, 1, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
            action = self.state:PredictActionFollowing(action) or "wait"
            UI:SetAction(UI.CLEAVE, 2, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
        end

        if Config:Get('showAoE') then
            Core:Debug("")
            Core:Debug("|cFFFFFFFFAoE|r")
            self.state:Reset(3)
            action = self.state:PredictNextAction() or "wait"
            UI:SetAction(UI.AOE, 1, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
            action = self.state:PredictActionFollowing(action) or "wait"
            UI:SetAction(UI.AOE, 2, self.state.env[action].Icon, self.state.env[action].OverlayTitle)
        end
    end
end

Profiling:ProfileFunction(TJ, 'ExecuteAllActionProfiles')

------------------------------------------------------------------------------------------------------------------------
-- Addon enable/disable handlers
------------------------------------------------------------------------------------------------------------------------

function TJ:OnEnable()
    -- Add event listeners
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'GENERIC_RELOAD_PROFILE_HANDLER')
    self:RegisterEvent('PLAYER_ALIVE', 'GENERIC_RELOAD_PROFILE_HANDLER')
    self:RegisterEvent('PLAYER_DEAD', 'GENERIC_RELOAD_PROFILE_HANDLER')
    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'GENERIC_RELOAD_PROFILE_HANDLER')
    self:RegisterEvent('SPELLS_CHANGED', 'GENERIC_RELOAD_PROFILE_HANDLER')

    -- Create the UI
    UI:CreateFrames()
    UI:EnableMouse(self.movable)
    UI:UpdateAlpha()

    -- Handle movement if enabled
    UI:SetScript("OnMouseDown", function(self, button)
        if UI.movable and button == "LeftButton" and not self.isMoving then
            self:StartMoving()
            self.isMoving = true
        end
    end)
    UI:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false
            local _, _, tgtPoint, offsetX, offsetY = self:GetPoint()
            Config:Set(tgtPoint, "position", "tgtPoint")
            Config:Set(offsetX, "position", "offsetX")
            Config:Set(offsetY, "position", "offsetY")
        end
    end)
    UI:SetScript("OnHide", function(self)
        if self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false
            local _, _, tgtPoint, offsetX, offsetY = self:GetPoint()
            Config:Set(tgtPoint, "position", "tgtPoint")
            Config:Set(offsetX, "position", "offsetX")
            Config:Set(offsetY, "position", "offsetY")
        end
    end)

    -- Show the debug log if we've enabled debugging
    if Config:Get("do_debug") then
        Core:ShowLoggingFrame()
    end
end

function TJ:OnDisable()
    -- Disable the debug log
    Core:HideLoggingFrame()

    -- Deactivate the profile
    self:DeactivateProfile()

    -- Remove event listeners
    self:UnregisterEvent('SPELLS_CHANGED')
    self:UnregisterEvent('PLAYER_ENTERING_WORLD')
    self:UnregisterEvent('ZONE_CHANGED_NEW_AREA')
    self:UnregisterEvent('ZONE_CHANGED_INDOORS')
    self:UnregisterEvent('ZONE_CHANGED')
    self:UnregisterEvent('PLAYER_SPECIALIZATION_CHANGED')
end

------------------------------------------------------------------------------------------------------------------------
-- GCD detection, incoming damage tracking
------------------------------------------------------------------------------------------------------------------------

function TJ:TryDetectUpdateGlobalCooldown(lastCastSpellID)
    -- Work out the current GCD
    local spellCD = GetSpellBaseCooldown(lastCastSpellID or 0)
    if spellCD and spellCD == 0 then
        local _, duration = GetSpellCooldown(61304)
        if duration and duration > 0 then
            local playerHasteMultiplier = ( 100 / ( 100 + UnitSpellHaste('player') ) )
            local gcd = duration / playerHasteMultiplier
            self.currentGCD = (gcd > 1) and gcd or 1
        end
    end
end

function TJ:GetIncomingDamage(timestamp, secs)
    local toDelete = TableCache:Acquire()
    local now = GetTime()
    local value = 0
    for entrytime, damage in pairs(self.damageTable) do
        -- Delete entries more than 1 min old
        if entrytime < now-60 then toDelete[1+#toDelete] = entrytime end

        -- If this entry fulfils the time criteria, then add it
        if entrytime > timestamp-secs then
            value = value + damage
        end
    end

    -- Perform deletes
    for i=1, #toDelete do self.damageTable[toDelete[i]] = nil end
    TableCache:Release(toDelete)
    return value
end

------------------------------------------------------------------------------------------------------------------------
-- Console command
------------------------------------------------------------------------------------------------------------------------

local function splitargv(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = ("([^%s]+)"):format(sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function TJ:ConsoleCommand(args)
    local argv = splitargv(args, '%s+')
    if argv[1] == "cfg" then
        Config:OpenDialog()
    elseif argv[1] == "move" then
        UI:ToggleMovement()
    elseif argv[1] == "resetpos" then
        UI:ResetPosition()
    elseif argv[1] == 'ticket' then
        Core:ExportDebuggingInformation()
    elseif argv[1] == 'blacklist' then
        local action = rawget(TJ.currentProfile.actions, argv[2])
        if not action then
            Core:Print('Error, action "|cFFFF6600%s|r" not found.', argv[2])
        else
            local classID, specID = select(3, UnitClass('player')), GetSpecialization()
            local current = Config:Get("class", classID, "spec", specID, "blacklist", argv[2]) and true or false
            local newvalue = not current
            Config:Set(newvalue and true or false, "class", classID, "spec", specID, "blacklist", argv[2])
            Core:Print('Blacklist |cFFFF6600%s|r=|cFFFFCC00%s|r', argv[2], tostring(newvalue))
            self:QueueUpdate()
        end
    elseif argv[1] == '_rp' then
        self:QueueProfileReload()
    elseif argv[1] == "_dbg" then
        if Config:Get("do_debug") then
            Config:Set(false, "do_debug")
            Core:HideLoggingFrame()
            Core:Print('Debugging info disabled. Enable with "|cFFFF6600/tj _dbg|r".')
        else
            Config:Set(true, "do_debug")
            Core:ShowLoggingFrame()
            Core:Print('Debugging info enabled. Disable with "|cFFFF6600/tj _dbg|r".')
        end
    elseif argv[1] == '_dtc' then
        Core:Print('Dumping table cache metrics:')
        Core:Print(' - Total allocated: %d, total acquired: %d, total released: %d, total in-use: %d',
            TableCache.TableCache.TotalAllocated, TableCache.TableCache.TotalAcquired, TableCache.TableCache.TotalReleased, TableCache.TableCache.TotalAcquired - TableCache.TableCache.TotalReleased)
    elseif argv[1] == '_dbe' then
        Core:OpenDebugWindow('Thousand Jabs SavedVariables Export', LSD(ThousandJabsDB))
    elseif argv[1] == '_prof' then
        Core:Print(Profiling:GetProfilingString())
    elseif argv[1] == '_duc' then
        Core:Print('Dumping unit cache table:')
        if not IsAddOnLoaded('Blizzard_DebugTools') then LoadAddOn('Blizzard_DebugTools') end
        DevTools_Dump{unitCache=UnitCache.unitCache}
    elseif argv[1] == '_mem' then
        UpdateAddOnMemoryUsage()
        Core:Print('Memory usage: %d kB', GetAddOnMemoryUsage('ThousandJabs'))
    elseif argv[1] == '_esd' then
        self:ExportAbilitiesFromSpellBook()
    elseif argv[1] == '_dcp' then
        if TJ.currentProfile then
            TJ.needExportCurrentProfile = true
        end
    else
        Core:Print('Thousand Jabs chat commands:')
        Core:Print("     |cFFFF6600/tj cfg|r - Opens the configuration dialog.")
        Core:Print("     |cFFFF6600/tj move|r - Toggles frame moving.")
        Core:Print("     |cFFFF6600/tj resetpos|r - Resets frame positioning to default.")
        Core:Print("     |cFFFF6600/tj ticket|r - Shows a window that can be used to copy/paste debugging information for raising tickets.")
        Core:Print("     |cFFFF6600/tj blacklist <action>|r - Enables blacklisting of actions using slash commands / macros.")
        Core:Print('Thousand Jabs debugging:')
        Core:Print('     |cFFFF6600/tj _dbg|r - Toggles debug information visibility.')
    end
end

TJ:RegisterChatCommand('tj', 'ConsoleCommand')
