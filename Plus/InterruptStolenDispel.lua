local id, e = ...
local addName= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INTERRUPTS, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISPELS, ACTION_SPELL_STOLEN))

local Save={}
local panel=CreateFrame("Frame")

local de=' > '--分隔符
--if e.Player.Lo== "zhCN" or e.Player.Lo == "zhTW" or e.Player.Lo=='koKR' then
if e.Player.region==4 or e.Player.region==5 then
    de='→'
end

local UMark={--'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..t..':0|t'
    [1]='{rt1}',
    [2]='{rt2}',
    [4]='{rt3}',
    [8]='{rt4}',
    [16]='{rt5}',
    [32]='{rt6}',
    [64]='{rt7}',
    [128]='{rt8}',
}



local function set_COMBAT_LOG_EVENT_UNFILTERED()--https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT
    --timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, [spellID, spellName, spellSchool], casterGUID, casterName, casterFlags, casterRaidFlags, absorbSpellId, absorbSpellName, absorbSpellSchool, amount, critical
    local _, eventType, _, sourceGUID, _, _, sourceRaidFlags, destGUID, _, _, destRaidFlags ,spellID, _,_, extraSpellID= CombatLogGetCurrentEventInfo()
    local target = destGUID and UnitTokenFromGUID(destGUID)
    if not target
        or not spellID
        or not extraSpellID
        or sourceGUID~=e.Player.guid
        or not (eventType=="SPELL_INTERRUPT" or eventType=="SPELL_DISPEL" or eventType=="SPELL_STOLEN")
        or UnitIsUnit(target, 'pet')
    then
        return
    end
    local text=(UMark[sourceRaidFlags] or '')..C_Spell.GetSpellLink(spellID)..de..C_Spell.GetSpellLink(extraSpellID)..(UMark[destRaidFlags] or '')
    if UnitIsUnit(target, 'player') then
        print('|A:nameplates-holypower2-on:0:0|a', e.Icon.player, text)
    else
        e.Chat(text, nil, nil)
    end
    
end

local function set_Events()--注册，事件
    if IsInGroup() and not IsInRaid() then
        panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    else
        panel:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    end
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('GROUP_ROSTER_UPDATE')
panel:RegisterEvent('GROUP_LEFT')

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save


            --添加控制面板
            local initializer= e.AddPanel_Check({
                name= '|A:nameplates-holypower2-on:0:0|a'..(e.onlyChinese and '断驱散' or addName),
                tooltip= e.onlyChinese and '说|n仅限：我, 小队'
                    or (SAY..'|n'..format(LFG_LIST_CROSS_FACTION, COMBATLOG_FILTER_STRING_ME)..'|n'..format(LFG_LIST_CROSS_FACTION, SLASH_TEXTTOSPEECH_PARTY)),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    if Save.disabled then
                        Save.disabled=nil
                        panel:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                    else
                        Save.disabled=true
                        panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                    end
                    print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.disabled))
                end
            })

            e.AddPanel_Check({
                name= '|A:nameplates-holypower2-on:0:0|a'..(e.onlyChinese and '断驱散' or addName),
                tooltip= e.onlyChinese and '说|n仅限：我, 小队'
                    or (SAY..'|n'..format(LFG_LIST_CROSS_FACTION, COMBATLOG_FILTER_STRING_ME)..'|n'..format(LFG_LIST_CROSS_FACTION, SLASH_TEXTTOSPEECH_PARTY)),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    if Save.disabled then
                        Save.disabled=nil
                        panel:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                    else
                        Save.disabled=true
                        panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                    end
                    print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.disabled))
                end
            }, initializer)
          

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                set_Events()--注册，事件
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='COMBAT_LOG_EVENT_UNFILTERED' then-- and IsInGroup() then
        set_COMBAT_LOG_EVENT_UNFILTERED()

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        set_Events()--注册，事件
    end
end)
