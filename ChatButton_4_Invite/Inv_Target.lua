local e= select(2, ...)
local function Save()
    return WoWTools_InviteMixin.Save
end















local function Init()
    local frame= CreateFrame('Frame')
    WoWTools_InviteMixin.InvTargetFrame= frame

    function frame:set_event()--设置, 邀请目标事件
        self:UnregisterAllEvents()
        if Save().InvTar and not IsInInstance() then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
        end
    end

    function frame:InviteTarget()
        if not Save().InvTar
        --or WoWTools_InviteMixin.InvPlateGuid[guid]--已邀请
        or not UnitExists('target')
        or not WoWTools_InviteMixin:Get_Leader()--取得权限
        or UnitInAnyGroup('target')
        or UnitIsAFK('target')
        or not UnitIsConnected('target')
        or not UnitIsPlayer('target')
        or not UnitIsFriend('target', 'player')
        or UnitIsUnit('player','target')
        then
            return
        end

        local raid=IsInRaid()
        local co=GetNumGroupMembers()
        if (raid and co==40) or (not raid and co==5 and not Save().PartyToRaid) then
            return
        end

        local name=GetUnitName('target', true)
        if not name then
            return
        end

        --toRaidOrParty(co)--自动, 转团

        C_PartyInfo.InviteUnit(name)

        local guid=UnitGUID('target')
        if guid then
            WoWTools_InviteMixin.InvPlateGuid[guid]=name--保存到已邀请列表
        end
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '目标' or TARGET, WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reLink=true}))
    end

    frame:SetScript('OnEvent', frame.InviteTarget)

    frame:set_event()
end



















function WoWTools_InviteMixin:Init_Target()
    Init()
end

function WoWTools_InviteMixin:Inv_Target_Settings()
    self.InvTargetFrame:set_event()
    self.InvTargetFrame:InviteTarget()
end