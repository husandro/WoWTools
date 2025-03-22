local id, e = ...

local Save={
    --enabledInRaid=true--在团队中启用会掉帧
}
local addName
local de='>'--分隔符
if e.Player.region==4 or e.Player.region==5 then de='→' end
local UMark={[1]='{rt1}', [2]='{rt2}', [4]='{rt3}', [8]='{rt4}', [16]='{rt5}', [32]='{rt6}', [64]='{rt7}', [128]='{rt8}'}



local eventFrame= CreateFrame("Frame")
eventFrame:SetScript('OnEvent', function()
    local _, eventType, _, sourceGUID, _, _, sourceRaidFlags, destGUID, _, _, destRaidFlags ,spellID, _,_, extraSpellID= CombatLogGetCurrentEventInfo()
    if
        sourceGUID~=e.Player.guid--不是自已
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
end)




local panel= CreateFrame("Frame")
function panel:Set_Event()
    if Save.disabled then
        self:UnregisterEvent('GROUP_ROSTER_UPDATE')
        self:UnregisterEvent('GROUP_LEFT')
    else
        self:RegisterEvent('GROUP_ROSTER_UPDATE')
        self:RegisterEvent('GROUP_LEFT')
    end

    if (not IsInRaid() or Save.enabledInRaid) and not Save.disabled then
        eventFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    else
        eventFrame:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    end
end





panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            Save= WoWToolsSave['Interrupts_Tolen'] or Save

            addName= '|A:nameplates-holypower2-on:0:0|a'..(WoWTools_Mixin.onlyChinese and '断驱散' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INTERRUPTS, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISPELS, ACTION_SPELL_STOLEN)))

            --添加控制面板
            local root= e.AddPanel_Check({
                name= addName,
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled = not Save.disabled and true or nil
                    self:Set_Event()
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            e.AddPanel_Check({
                name= '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '团队' or RAID),
                GetValue= function() return Save.enabledInRaid end,
                SetValue= function()
                    Save.enabledInRaid = not Save.enabledInRaid and true or nil
                    self:Set_Event()
                end,
                tooltip=(WoWTools_Mixin.onlyChinese and '掉帧' or 'Dropped Frames')..'|n|n'..addName,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            }, root)

            if not Save.disabled then
                self:Set_Event()
            end
            self:UnregisterEvent(event)
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        self:Set_Event()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Interrupts_Tolen']=Save
        end
    end
end)

