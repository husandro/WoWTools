local id, e = ...
local addName= 	INTERRUPTS..DISPELS..ACTION_SPELL_STOLEN

local Save={}
local panel=CreateFrame("Frame")

local de='->'--分隔符
if e.Player.Lo== "zhCN" or e.Player.Lo == "zhTW" or e.Player.Lo=='koKR' then
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

local function set_COMBAT_LOG_EVENT_UNFILTERED()
    local _, eventType, _, sourceGUID, _, _, sourceRaidFlags, _, _, _, destRaidFlags ,spellID, _,_, extraSpellID= CombatLogGetCurrentEventInfo()
    if (eventType=="SPELL_INTERRUPT" or eventType=="SPELL_DISPEL" or eventType=="SPELL_STOLEN") and sourceGUID==e.Player.guid and spellID and extraSpellID then
        local text=(UMark[sourceRaidFlags] or '')..GetSpellLink(spellID)..de..GetSpellLink(extraSpellID)..(UMark[destRaidFlags] or '')
        e.Chat(text, nil, true)
    end
end


panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                    panel:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                else
                    Save.disabled=true
                    panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
                end
                print(id, addName, e.GetEnabeleDisable(Save.disabled))
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(addName, SAY, nil,nil,nil, 0,1,0)
                e.tips:AddDoubleLine(LFG_LIST_CROSS_FACTION:format(COMBATLOG_FILTER_STRING_ME), LFG_LIST_CROSS_FACTION:format(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS))--仅限我, 仅限队伍
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function()
                e.tips:Hide()
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='COMBAT_LOG_EVENT_UNFILTERED' and IsInGroup() then
        set_COMBAT_LOG_EVENT_UNFILTERED()
    end
end)
