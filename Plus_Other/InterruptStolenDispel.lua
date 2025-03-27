
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

local P_Save={
    --enabledInRaid=true--在团队中启用会掉帧
}

local function Save()
    return WoWToolsSave['Interrupts_Tolen']
end

local addName
local de='>'--分隔符
local UMark

local function COMBAT_LOG_EVENT_UNFILTERED()
    local _, eventType, _, sourceGUID, _, _, sourceRaidFlags, destGUID, _, _, destRaidFlags ,spellID, _,_, extraSpellID= CombatLogGetCurrentEventInfo()
    if
        sourceGUID~=WoWTools_DataMixin.Player.GUID--不是自已
        or not C_PlayerInfo.GUIDIsPlayer(sourceGUID)--PET
        or not destGUID--目标
        or not spellID
        or not extraSpellID
        or not (eventType=="SPELL_INTERRUPT" or eventType=="SPELL_DISPEL" or eventType=="SPELL_STOLEN")--事件
    then
        return
    end

    local text=(UMark[sourceRaidFlags] or '')..WoWTools_SpellMixin:GetLink(spellID)..de..WoWTools_SpellMixin:GetLink(extraSpellID)..(UMark[destRaidFlags] or '')
    if destGUID==WoWTools_DataMixin.Player.GUID then
        print('|A:nameplates-holypower2-on:0:0|a', WoWTools_DataMixin.Icon.Player..WoWTools_DataMixin.Player.col, text)
    else
        WoWTools_ChatMixin:Chat(text, nil, nil)
    end
end







local function Set_Event(self)
    self:UnregisterAllEvents()

    if not Save().disabled then
        self:RegisterEvent('GROUP_ROSTER_UPDATE')
        self:RegisterEvent('GROUP_LEFT')

        if not IsInRaid() or Save().enabledInRaid then
            self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
        end
    end
end









local function Init_Panel()

    WoWToolsSave['Interrupts_Tolen']= WoWToolsSave['Interrupts_Tolen'] or P_Save

    addName= '|A:nameplates-holypower2-on:0:0|a'..(WoWTools_Mixin.onlyChinese and '断驱散' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INTERRUPTS, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISPELS, ACTION_SPELL_STOLEN)))

    --添加控制面板
    local root= WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled = not Save().disabled and true or nil
            Set_Event(panel)
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '团队' or RAID),
        GetValue= function() return Save().enabledInRaid end,
        SetValue= function()
            Save().enabledInRaid = not Save().enabledInRaid and true or nil
            Set_Event(panel)
        end,
        tooltip=(WoWTools_Mixin.onlyChinese and '掉帧' or 'Dropped Frames')..'|n|n'..addName,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    }, root)

    if WoWTools_DataMixin.Player.Region==4 or WoWTools_DataMixin.Player.Region==5 then de='→' end

    UMark={[1]='{rt1}', [2]='{rt2}', [4]='{rt3}', [8]='{rt4}', [16]='{rt5}', [32]='{rt6}', [64]='{rt7}', [128]='{rt8}'}

    if not Save().disabled then
        Set_Event(panel)
    end

    panel:UnregisterEvent('ADDON_LOADED')

    Init_Panel=function()end
end











panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            Init_Panel()
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        Set_Event(self)

    elseif event=='COMBAT_LOG_EVENT_UNFILTERED' then
        COMBAT_LOG_EVENT_UNFILTERED()
    end
end)

