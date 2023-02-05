local id, e= ...

if e.Player.level~=MAX_PLAYER_LEVEL then
    return
end

local addName= MOUNT_JOURNAL_FILTER_DRAGONRIDING..SPEED
local Save= {}
local panel= CreateFrame("Frame")

local lastX, lastY, lastT = 0, 0, 0
local function get_Speed()
    local time = GetTime()
    local dt = time - lastT
    local uiMapID = C_Map.GetBestMapForUnit('player')
    if uiMapID then
        local position = C_Map.GetPlayerMapPosition(uiMapID, "player")
        if position then
            local x, y = position.x, position.y
            local w, h = C_Map.GetMapWorldSize(uiMapID)
            x = x * w
            y = y * h
            local dx = x - lastX
            local dy = y - lastY

            local groundSpeed = math.sqrt(dx * dx + dy * dy) / dt
            if groundSpeed > 0 then
                local cosTheta = math.cos(math.abs(0))
                if cosTheta > 0 then
                    lastX = x
                    lastY = y
                    lastT = time
                    return groundSpeed / cosTheta
                end
            end
        end
    end
    lastX, lastY, lastT = 0, 0, 0
end

local timeElapsed = 0
local speedTextFactor = 100 / BASE_MOVEMENT_SPEED
panel:SetScript('OnUpdate', function(self, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 0.3 then
        timeElapsed = 0
        local speed= get_Speed()
        if speed and speed>1 then
            panel.text:SetFormattedText('%i%%', speed * speedTextFactor)
        else
            panel.text:SetText('')
        end
    end
end)

local function set_Shown()
    local find= false
    if IsMounted() then
        for _, mountID in ipairs(C_MountJournal.GetCollectedDragonridingMounts()) do
            if select(4, C_MountJournal.GetMountInfoByID(mountID)) then
                find= true
            end
        end
    end
    panel:SetShown(find)
    if not find then
        lastX, lastY, lastT = 0, 0, 0
    end
end

local function set_Events()
    if not IsInInstance() then
        panel:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
        panel:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')
        panel:RegisterEvent('LEARNED_SPELL_IN_TAB')
        panel:RegisterUnitEvent('UNIT_SPELLCAST_SUCCEEDED','player')
        panel:RegisterEvent('VEHICLE_ANGLE_UPDATE')
        panel:RegisterEvent('UPDATE_UI_WIDGET')
        set_Shown()
    else
        panel:UnregisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
        panel:UnregisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')
        panel:UnregisterEvent('LEARNED_SPELL_IN_TAB')
        panel:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED')
        panel:UnregisterEvent('VEHICLE_ANGLE_UPDATE')
        panel:UnregisterEvent('UPDATE_UI_WIDGET')
        lastX, lastY, lastT = 0, 0, 0
        panel.text:SetText('')
        panel:SetShown(false)
    end
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

--####
--初始
--####
local function Init()
    panel.text= e.Cstr(UIWidgetPowerBarContainerFrame, 24)
    panel.text:SetPoint('BOTTOM', UIWidgetPowerBarContainerFrame, 'TOP')
end

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        --添加控制面板        
        local sel=e.CPanel(e.onlyChinse and '驭龙术速度' or addName, not Save.disabled, true)
        sel:SetScript('OnMouseDown', function()
            Save.disabled = not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '重新加载UI' or RELOADUI)
        end)

        if Save.disabled then
            panel:UnregisterAllEvents()
        else
            Init()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")
        panel:UnregisterEvent('ADDON_LOADED')

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        set_Events()

    else
        set_Shown()
    end
end)

--[[
---- Parameters ----
--UIWidgetPowerBarContainerFrame:SetScale(0.5)

local mountEvents = {
    ["PLAYER_MOUNT_DISPLAY_CHANGED"] = true,
    ["MOUNT_JOURNAL_USABILITY_CHANGED"] = true,
    ["LEARNED_SPELL_IN_TAB"] = true,
}

local ascentSpell = 372610
local thrillBuff = 377234
local thrillSpeed = 60
local maxSamples = 5
local ascentDuration = 3.5
local ascentBoostMax = 35
local pollRate = 1 / 10
local updatePeriod = 1 / 10
local showSpeed = aura_env.config.speedshow
local speedTextFormat, speedTextFactor = "%.0f%%", 100 / 7

---- Variables ----

local active = false
local updateHandle = nil
local ascentStart = 0
local lastX, lastY, lastT = 0, 0, 0
local samples = 0
local skipped = false
local smoothSpeed, smoothGSpeed, lastSpeed = 0, 0, 0


local ScanEvents = WeakAuras.ScanEvents
local GetTime = GetTime
local After = C_Timer.After
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local GetMapWorldSize = C_Map.GetMapWorldSize

---- Trigger 1 ----

-- Events:
--   PLAYER_MOUNT_DISPLAY_CHANGED
--   MOUNT_JOURNAL_USABILITY_CHANGED
--   LEARNED_SPELL_IN_TAB
--   UNIT_SPELLCAST_SUCCEEDED:player
--   DMUI_DRAGONRIDING_UPDATE

local function setActive(allstates, state)
    active = state
    After(0, function()
            ScanEvents("DMUI_DRAGONRIDING_SHOW", state)
    end)

    if active then

        if not updateHandle then
            updateHandle = C_Timer.NewTicker(pollRate, function()
                    if active then
                        ScanEvents("DMUI_DRAGONRIDING_UPDATE", true)
                    end
            end)
        end

        if not allstates[""] then
            allstates[""] = {
                show = true,
                changed = true,
                progressType = "static",
                value = 0,
                accel = 0,
                total = 100,
                thrill = false,
                speedtext = "",
            }
            return true
        end
    else
        if updateHandle then
            updateHandle:Cancel()
            updateHandle = nil
        end

        if allstates[""] then
            allstates[""].show = false
            allstates[""].changed = true
            return true
        end
    end
end

aura_env.trigger1 = function(allstates, event, _, _, spellId)

    if event ~= "DMUI_DRAGONRIDING_UDPATE" then

        -- Ensure ticker is stopped on opening WA options
        if event == "OPTIONS" then
            return setActive(allstates, false)
        end

        -- Detect dragonriding start/end
        if mountEvents[event] then
            if IsMounted() then
                for _, mountId in ipairs(C_MountJournal.GetCollectedDragonridingMounts()) do
                    if select(4, C_MountJournal.GetMountInfoByID(mountId)) then
                        return setActive(allstates, true)
                    end
                end
            end
            return setActive(allstates, false)
        end

        -- Detect ascent boost
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            if spellId == ascentSpell then
                ascentStart = GetTime()
            end
            return false
        end
    end

    local time = GetTime()

    -- Delta time
    local dt = time - lastT
    if dt < updatePeriod then
        -- Rate limit speed updates!
        return false
    end
    lastT = time

    if not allstates or not allstates[""] then return false end

    -- Compute accurate speed if possible
    local instanced = true
    local speed, groundSpeed = 0, 0
    local map = GetBestMapForUnit("player")
    if map then
        local position = GetPlayerMapPosition(map, "player")
        if position then
            instanced = false

            -- Delta position
            local x, y = position.x, position.y
            local w, h = GetMapWorldSize(map)
            x = x * w
            y = y * h
            local dx = x - lastX
            local dy = y - lastY
            lastX = x
            lastY = y

            -- Compute horizontal speed and adjust for pitch
            groundSpeed = math.sqrt(dx * dx + dy * dy) / dt
            if groundSpeed > 0 then
                local cosTheta = math.cos(math.abs(0))
                if cosTheta > 0 then
                    speed = groundSpeed / cosTheta
                end
            end
        end
    end

    -- Ignore obviously invalid speeds that occur when jumping zones
    if speed > 150 then
        return false
    end

    -- If speed can't be detected, reduce exp-avg window size
    if speed == 0 then
        samples = math.min(1, samples)
    end

    local thrill = C_UnitAuras.GetPlayerAuraBySpellID(thrillBuff)

    -- Override with ascent boost
    if thrill and time < ascentStart + ascentDuration then
        local progress = (time - ascentStart) / ascentDuration
        local boost = thrillSpeed + (1 - progress) * ascentBoostMax
        if speed < boost then
            speed = boost
            samples = 0
            skipped = true
        end
    end

    -- Override speed based on Thrill buff
    if speed < thrillSpeed and thrill then
        speed = thrillSpeed
    end

    if speed > thrillSpeed and not thrill then
        speed = thrillSpeed
        samples = 0
        skipped = true
    end

    -- Skip sampling on large apparent speed changes
    if math.abs(speed - smoothSpeed) > 100 then
        if skipped then
            samples = 0
        else
            skipped = true
            return false
        end
    end
    skipped = false

    -- Compute smooth speed
    samples = math.min(maxSamples, samples + 1)
    local lastWeight = (samples - 1) / samples
    local newWeight = 1 / samples
    smoothSpeed = smoothSpeed * lastWeight + speed * newWeight
    smoothGSpeed = smoothGSpeed * lastWeight + groundSpeed * newWeight
    lastSpeed = smoothSpeed

    -- Update display variables
    local s = allstates[""]
    s.changed = true
    s.value = smoothSpeed
    s.thrill = not not thrill
    if showSpeed then
        local speed = (true or instanced) and smoothSpeed or smoothGSpeed
        s.speedtext = speed < 1 and "" or string.format(speedTextFormat, speed * speedTextFactor)
    end

    return true
end
]]
