
local InvPlateTimer



local function Inv_All_Unit()
    local p=C_CVar.GetCVarBool('nameplateShowFriends')
    local all= C_CVar.GetCVarBool('nameplateShowAll')

    if not WoWTools_InviteMixin:Get_Leader() then--取得权限
        print(WoWTools_Mixin.addName, WoWTools_InviteMixin.addName, '|cnRED_FONT_COLOR:', WoWTools_Mixin.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
        return

    elseif UnitAffectingCombat('player') and (not p or not all) then
        print(WoWTools_Mixin.addName, WoWTools_InviteMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '战斗中' or COMBAT))
        return
    end

    do
        if not all then
            C_CVar.SetCVar('nameplateShowAll', '1')
        end
        if not p then
            C_CVar.SetCVar('nameplateShowFriends', '1')
        end
    end

    if InvPlateTimer then
        InvPlateTimer:Cancel()
    end

    InvPlateTimer=C_Timer.NewTimer(0.3, function()
        local n=1
        local co=GetNumGroupMembers()
        local raid=IsInRaid()
        if (not raid and co==5)then
            return

        elseif co==40 then
            return
        else
            --toRaidOrParty(co)--自动, 转团
            local tab= C_NamePlate.GetNamePlates(issecure()) or {}
            do for _, v in pairs(tab) do
                local u = v.namePlateUnitToken or v.UnitFrame and v.UnitFrame.unit
                if u then
                    local name= GetUnitName(u,true)
                    local guid= UnitGUID(u)
                    if name and name~=UNKNOWNOBJECT and guid and not UnitInAnyGroup(u) and not UnitIsAFK(u) and UnitIsConnected(u) and UnitIsPlayer(u) and UnitIsFriend(u, 'player') and not UnitIsUnit('player',u) then
                        if not WoWTools_InviteMixin.InvPlateGuid[guid] then
                            C_PartyInfo.InviteUnit(name)
                            WoWTools_InviteMixin.InvPlateGuid[guid]=name
                            print(WoWTools_Mixin.addName, '|cnGREEN_FONT_COLOR:'..n..'|r)', WoWTools_Mixin.onlyChinese and '邀请' or INVITE ,WoWTools_UnitMixin:GetLink(name, guid))
                            if not raid and n +co>=5  then
                                print(WoWTools_Mixin.addName, WoWTools_InviteMixin.addName, format(PETITION_TITLE, '|cff00ff00'..(WoWTools_Mixin.onlyChinese and '转团' or CONVERT_TO_RAID)..'|r'))
                                break
                            end
                            n=n+1
                        end
                    end
                end
            end end
        end

        if not p and not InCombatLockdown() then
            C_CVar.SetCVar('nameplateShowFriends', '0')
        end
        if n==1 then
            print(WoWTools_Mixin.addName, WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '无' or NONE))
        end
    end)
end



function WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
    Inv_All_Unit()
end


