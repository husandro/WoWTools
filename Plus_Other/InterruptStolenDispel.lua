local id, e = ...

local Save={
    --enabledInRaid=true--在团队中启用会掉帧
}


local de='>'--分隔符
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




local EventFrame=CreateFrame('Frame')
EventFrame:SetScript("OnEvent", function(self, event)
    if event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        self:set_event()

    elseif event=='COMBAT_LOG_EVENT_UNFILTERED' then
        self:settings()
    end
end)



--[[
timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, [spellID, spellName, spellSchool], casterGUID, casterName, casterFlags, casterRaidFlags, absorbSpellId, absorbSpellName, absorbSpellSchool, amount, critical
local target = destGUID and UnitTokenFromGUID(destGUID)
https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT
]]
function EventFrame:settings()
    local _, eventType, _, sourceGUID, _, _, sourceRaidFlags, destGUID, _, _, destRaidFlags ,spellID, _,_, extraSpellID= CombatLogGetCurrentEventInfo()
    if sourceGUID~=e.Player.guid--不是自已
    or not C_PlayerInfo.GUIDIsPlayer(sourceGUID)--PET
        or not destGUID--目标
        or not spellID
        or not extraSpellID
        or not (eventType=="SPELL_INTERRUPT" or eventType=="SPELL_DISPEL" or eventType=="SPELL_STOLEN")--事件
    then
        return
    end

    local text=(UMark[sourceRaidFlags] or '')..WoWTools_SpellMixin:GetLink(spellID)..de..WoWTools_SpellMixin:GetLink(extraSpellID)..(UMark[destRaidFlags] or '')
    if destGUID==e.Player.guid then
        print('|A:nameplates-holypower2-on:0:0|a', e.Icon.player..e.Player.col, text)
    else
        WoWTools_ChatMixin:Chat(text, nil, nil)
    end
end



function EventFrame:set_event()
    if Save.disabled then
--禁用
        self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        self:UnregisterEvent('GROUP_ROSTER_UPDATE')
        self:UnregisterEvent('GROUP_LEFT')
    else
--团，队，个人，启用
        if Save.enabledInRaid then
            self:UnregisterEvent('GROUP_ROSTER_UPDATE')
            self:UnregisterEvent('GROUP_LEFT')
            self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        else
--设置，事件
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_LEFT')
--禁用，团
            if IsInRaid() and not Save.enabledInRaid then
                self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
            else
--启用
                self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
            end
        end
    end
end
























EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~=id then
        return
    end
    Save= WoWToolsSave['Interrupts_Tolen'] or Save

    --添加控制面板 format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INTERRUPTS, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISPELS, ACTION_SPELL_STOLEN))
    local root= e.AddPanel_Check({
        name= '|A:nameplates-holypower2-on:0:0|a'..(e.onlyChinese and '断驱散' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INTERRUPTS, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISPELS, ACTION_SPELL_STOLEN))),
        GetValue= function() return not Save.disabled end,
        SetValue= function()
            Save.disabled = not Save.disabled and true or nil
            EventFrame:set_event()
        end
    })

    e.AddPanel_Check({
        name= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '团队' or RAID),
        GetValue= function() return Save.enabledInRaid end,
        SetValue= function()
            Save.enabledInRaid = not Save.enabledInRaid and true or nil
            EventFrame:set_event()
        end,
        tooltip=e.onlyChinese and '掉帧' or 'Dropped Frames'
    }, root)

    if not Save.disabled then
        EventFrame:set_event()
    end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['Interrupts_Tolen']=Save
    end
end)