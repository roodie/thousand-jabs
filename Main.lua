local addonName, internal = ...;
local TJ = internal.TJ
local Debug = internal.Debug
local fmt = internal.fmt
local Config = TJ:GetModule('Config')
local Profiling = TJ:GetModule('Profiling')
local TableCache = TJ:GetModule('TableCache')
local UnitCache = TJ:GetModule('UnitCache')
local UI = TJ:GetModule('UI')

local LSD = LibStub('LibSerpentDump')

local co_create = coroutine.create
local co_status = coroutine.status
local co_resume = coroutine.resume
local pairs = pairs
local pcall = pcall
local select = select
local tostring = tostring
local NewTicker = C_Timer.NewTicker
local GetSpecialization = GetSpecialization
local GetSpellBaseCooldown = GetSpellBaseCooldown
local GetSpellCooldown = GetSpellCooldown
local GetTime = GetTime
local UnitChannelInfo = UnitChannelInfo
local UnitClass = UnitClass
local UnitSpellHaste = UnitSpellHaste

internal.Safety()

------------------------------------------------------------------------------------------------------------------------
-- Locals
------------------------------------------------------------------------------------------------------------------------

-- Timer update
local screenUpdateTimer = nil
local queuedScreenUpdateTime = internal.devMode and 0.05 or 0.2  -- seconds (high-speed in dev mode, hopefully trigger issues)
local watchdogScreenUpdateTime = 0.75 -- seconds
local nextScreenUpdateExpiry = GetTime()
local watchdogScreenUpdateExpiry = GetTime()

------------------------------------------------------------------------------------------------------------------------
-- Shared private variables
------------------------------------------------------------------------------------------------------------------------

-- The active profile
TJ.currentProfile = nil

-- Time combat was last entered
TJ.combatStart = 0

-- Cast tracking
TJ.abilitiesUsed = {}
TJ.lastCastTime = {}
TJ.lastMainhandAttack = 0
TJ.lastOffhandAttack = 0

-- Incoming damage tracking
TJ.lastIncomingDamage = 0
TJ.damageTable = {}

------------------------------------------------------------------------------------------------------------------------
-- Addon initialisation
------------------------------------------------------------------------------------------------------------------------
function TJ:OnInitialize()
    Config:Upgrade()
end

------------------------------------------------------------------------------------------------------------------------
-- Statistics
------------------------------------------------------------------------------------------------------------------------

local function TimedUpdateUsageStats()
    local start = debugprofilestop()
    UpdateAddOnMemoryUsage()
    UpdateAddOnCPUUsage()
    local finish = debugprofilestop()
    return finish - start
end

local function UpdateUsageStatistics()
    if not internal.updateBrokerText then return end
    if not internal.statUpdateTime then
        if not InCombatLockdown() then
            internal.statUpdateTime = TimedUpdateUsageStats()
        end
    else
        internal.lastStatCheck = internal.lastStatCheck or 0
        local statUpdateSpeed = 5 -- in seconds
        if (InCombatLockdown() and internal.statUpdateTime < 30) or (internal.statUpdateTime < 100) then -- calc in-combat if <30ms, or out-of-combat if <100ms
            local now = GetTime()
            if internal.lastStatCheck + statUpdateSpeed < now then
                internal.statUpdateTime = TimedUpdateUsageStats()
                internal.lastStatCheckDelta = now - internal.lastStatCheck
                internal.lastMemAmount = internal.currMemAmount
                internal.currMemAmount = GetAddOnMemoryUsage(addonName)
                internal.lastCpuAmount = internal.currCpuAmount
                internal.currCpuAmount = GetAddOnCPUUsage(addonName)
                internal.lastStatCheck = now
            end
            Debug("Usage stats update time: %12.3f ms", internal.statUpdateTime)
            if internal.lastStatCheckDelta then
                local dt = internal.lastStatCheckDelta
                if internal.lastMemAmount and internal.lastMemAmount > 0 then
                    local curr = internal.currMemAmount
                    local prev = internal.lastMemAmount
                    local delta = curr - prev
                    Debug("           Memory usage: %12.3f kB", curr)
                    Debug("           Memory delta: %12.3f kB", delta)
                    Debug("           Memory delta: %12.3f kB/sec (over last %d secs)", delta/dt, statUpdateSpeed)
                    internal.dataobj.text = internal.fmt("Thousand Jabs: Memory: %dkB/sec", delta/dt)
                end
                if internal.lastCpuAmount and internal.lastCpuAmount > 0 then
                    local curr = internal.currCpuAmount
                    local prev = internal.lastCpuAmount
                    local delta = curr - prev
                    Debug("              CPU usage: %12.3f ms", curr)
                    Debug("              CPU delta: %12.3f ms", delta)
                    Debug("              CPU delta: %12.3f ms/sec (over last %d secs)", delta/dt, statUpdateSpeed)
                    Debug("              CPU usage: %10.1f%%", 100*(delta/dt)/1000.0)
                    internal.dataobj.text = internal.dataobj.text .. internal.fmt(", CPU: %.1f%% (%.3fms)", 100*(delta/dt)/1000.0, delta/dt)
                end
            end
        else
            internal.dataobj.text = internal.fmt("Thousand Jabs: Statistics disabled, too much time used (%d ms)", internal.statUpdateTime)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Command queue
------------------------------------------------------------------------------------------------------------------------

local commandQueue = {}
function TJ:ExecuteFuncAsCoroutine(funcToExec)
    local th = co_create(funcToExec)
    commandQueue[th] = true
    self:QueueUpdate()
end
function TJ:RunFuncCoroutines()
    for th in pairs(commandQueue) do
        if co_status(th) == "dead" then
            commandQueue[th] = nil
        else
            co_resume(th)
        end
        self:QueueUpdate()
    end
end

------------------------------------------------------------------------------------------------------------------------
-- Screen update
------------------------------------------------------------------------------------------------------------------------

function TJ:QueueUpdate()
    local now = GetTime()

    if not screenUpdateTimer then
        watchdogScreenUpdateExpiry = now + watchdogScreenUpdateTime
        screenUpdateTimer = NewTicker(0.01, function() TJ:PerformUpdate() end)
    end

    nextScreenUpdateExpiry = nextScreenUpdateExpiry or now + queuedScreenUpdateTime
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

    -- Purge any old cast times
    local expiryTime = 10 * (self.currentGCD or 1)
    for k,v in pairs(self.abilitiesUsed) do
        if k + expiryTime < now then
            self.abilitiesUsed[k] = nil
        end
    end
    for k,v in pairs(self.lastCastTime) do
        if v + expiryTime < now then
            self.lastCastTime[k] = nil
        end
    end

    -- Clear out any errors for the last screen update
    internal.DebugReset()

    -- Update stats
    UpdateUsageStatistics()

    if self.currentProfile then
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
    self:UpdateLog()

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
    local isBetaProfile = profile.betaProfile and true or false
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
    self.currentProfile = self:GetActiveProfile()

    -- If we actually have a profile to show, activate it
    if self.currentProfile then
        -- Activate the profile
        self.currentProfile:Activate()

        -- Create new state objects
        self.st_state = self:CreateNewState(1)
        self.cleave_state = self:CreateNewState(2)
        self.aoe_state = self:CreateNewState(3)

        -- Show the frame
        UI:Show()
        UI:EnableMouse(self.movable)
        UI:UpdateAlpha()

        -- Register event listeners
        TJ:RegisterEvent('PLAYER_LEVEL_UP')
        TJ:RegisterEvent('PLAYER_REGEN_ENABLED')
        TJ:RegisterEvent('PLAYER_REGEN_DISABLED')
        TJ:RegisterEvent('PLAYER_TARGET_CHANGED')
        TJ:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        TJ:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
        TJ:RegisterEvent('PLAYER_TALENT_UPDATE')
        TJ:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN', 'GENERIC_EVENT_UPDATE_HANDLER')
        TJ:RegisterEvent('UNIT_POWER')
        TJ:RegisterEvent('UNIT_POWER_FREQUENT', 'UNIT_POWER')
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
    if self.st_state then self.st_state = nil end
    if self.cleave_state then self.cleave_state = nil end
    if self.aoe_state then self.aoe_state = nil end

    -- Remove event listeners
    TJ:UnregisterEvent('UNIT_POWER_FREQUENT')
    TJ:UnregisterEvent('UNIT_POWER')
    TJ:UnregisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
    TJ:UnregisterEvent('PLAYER_TALENT_UPDATE')
    TJ:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    TJ:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    TJ:UnregisterEvent('PLAYER_TARGET_CHANGED')
    TJ:UnregisterEvent('PLAYER_REGEN_DISABLED')
    TJ:UnregisterEvent('PLAYER_REGEN_ENABLED')
    TJ:UnregisterEvent('PLAYER_LEVEL_UP')

    -- Deactivate the current profile
    if self.currentProfile then
        self.currentProfile:Deactivate()
        self.currentProfile = nil
    end

    self:QueueUpdate()
end

Profiling:ProfileFunction(TJ, 'DeactivateProfile')

------------------------------------------------------------------------------------------------------------------------
-- APL Execution
------------------------------------------------------------------------------------------------------------------------

function TJ:ExecuteAllActionProfiles()
    local ok, err = pcall(function()
        -- Reset the single-target state
        Debug("")
        Debug("|cFFFFFFFFSingle Target|r")
        self.st_state:Reset()

        -- Export the current profile state just after reset, if requested
        if self.needExportCurrentProfile then
            self.needExportCurrentProfile = nil
            local dbg = self:GenerateDebuggingInformation()
            local actionsTable = self.st_state:ExportActionsTable()
            self:OpenDebugWindow(addonName..' Current profile', LSD({dbg=dbg, actions=actionsTable}))
        end

        -- Calculate the single-target profiles
        local action = self.st_state:PredictNextAction() or "wait"
        UI:SetActionTexture(UI.SINGLE_TARGET, 1, self.st_state.env[action].Icon)
        action = self.st_state:PredictActionFollowing(action) or "wait"
        UI:SetActionTexture(UI.SINGLE_TARGET, 2, self.st_state.env[action].Icon)
        action = self.st_state:PredictActionFollowing(action) or "wait"
        UI:SetActionTexture(UI.SINGLE_TARGET, 3, self.st_state.env[action].Icon)
        action = self.st_state:PredictActionFollowing(action) or "wait"
        UI:SetActionTexture(UI.SINGLE_TARGET, 4, self.st_state.env[action].Icon)

        if Config:Get('showCleave') then
            Debug("")
            Debug("|cFFFFFFFFCleave|r")
            self.cleave_state:Reset()
            action = self.cleave_state:PredictNextAction() or "wait"
            UI:SetActionTexture(UI.CLEAVE, 1, self.cleave_state.env[action].Icon)
            action = self.cleave_state:PredictActionFollowing(action) or "wait"
            UI:SetActionTexture(UI.CLEAVE, 2, self.cleave_state.env[action].Icon)
        end

        if Config:Get('showAoE') then
            Debug("")
            Debug("|cFFFFFFFFAoE|r")
            self.aoe_state:Reset()
            action = self.aoe_state:PredictNextAction() or "wait"
            UI:SetActionTexture(UI.AOE, 1, self.aoe_state.env[action].Icon)
            action = self.aoe_state:PredictActionFollowing(action) or "wait"
            UI:SetActionTexture(UI.AOE, 2, self.aoe_state.env[action].Icon)
        end
    end)

    if not ok then
        internal.error(fmt("Error executing action profiles:\n%s", tostring(err)))
    end
end

Profiling:ProfileFunction(TJ, 'ExecuteAllActionProfiles')

------------------------------------------------------------------------------------------------------------------------
-- Addon enable/disable handlers
------------------------------------------------------------------------------------------------------------------------

function TJ:OnEnable()
    -- Add event listeners
    self:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
    self:RegisterEvent('ZONE_CHANGED')
    self:RegisterEvent('ZONE_CHANGED_INDOORS', 'ZONE_CHANGED')
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', 'ZONE_CHANGED')
    self:RegisterEvent('PLAYER_ENTERING_WORLD', 'ZONE_CHANGED')
    self:RegisterEvent('SPELLS_CHANGED')

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
        self:ShowLoggingFrame()
    end
end

function TJ:OnDisable()
    -- Disable the debug log
    self:HideLoggingFrame()

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
