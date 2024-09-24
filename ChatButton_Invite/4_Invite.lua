local id, e = ...


WoWTools_InviteMixin={
Save={
    InvNoFriend={},
    --LFGListAceInvite=true,--接受,LFD, 邀请
    FriendAceInvite=true,--接受, 好友, 邀请
    InvNoFriendNum=0,--拒绝, 次数
    restingTips=true,--休息区提示
    ChannelText=e.Player.cn and '1' or 'inv',--频道, 邀请, 事件,内容
    Summon= true,--接受, 召唤

    setFrameFun= e.Player.husandro,--跟随，密语

    setFucus= e.Player.husandro,--焦点
    overSetFocus= e.Player.husandro,--移过是，
    focusKey= 'Shift',
},
InviteButton=nil,
RestingFrame=nil,
InvTargetFrame=nil,
InvChanellFrame=nil
}


local function Save()
    return WoWTools_InviteMixin.Save
end


local InvPlateGuid={}

function WoWTools_InviteMixin:Get_InvPlateGuid()
    return InvPlateGuid
end

local InviteButton












function WoWTools_InviteMixin:Get_Leader()--取得权限
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end








local InvPlateTimer
function WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
    local p=C_CVar.GetCVarBool('nameplateShowFriends')
    local all= C_CVar.GetCVarBool('nameplateShowAll')

    if not WoWTools_InviteMixin:Get_Leader() then--取得权限
        print(e.addName, WoWTools_InviteMixin.addName, '|cnRED_FONT_COLOR:', e.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
        return

    elseif UnitAffectingCombat('player') and (not p or not all) then
        print(e.addName, WoWTools_InviteMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT))
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
                        if not WoWTools_InviteMixin:Get_InvPlateGuid()[guid] then
                            C_PartyInfo.InviteUnit(name)
                            WoWTools_InviteMixin:Get_InvPlateGuid()[guid]=name
                            print(e.addName, '|cnGREEN_FONT_COLOR:'..n..'|r)', e.onlyChinese and '邀请' or INVITE ,WoWTools_UnitMixin:GetLink(name, guid))
                            if not raid and n +co>=5  then
                                print(e.addName, WoWTools_InviteMixin.addName, format(PETITION_TITLE, '|cff00ff00'..(e.onlyChinese and '转团' or CONVERT_TO_RAID)..'|r'))
                                break
                            end
                            n=n+1
                        end
                    end
                end
            end end
        end

        if not p and not UnitAffectingCombat('player') then
            C_CVar.SetCVar('nameplateShowFriends', '0')
        end
        if n==1 then
            print(e.addName, WoWTools_InviteMixin.addName, e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
        end
    end)
end











































--####
--初始
--####
local function Init()
    WoWTools_InviteMixin.InviteButton= InviteButton

    InviteButton.texture:SetAtlas('communities-icon-addgroupplus')

    InviteButton.summonTips= InviteButton:CreateTexture(nil,'OVERLAY')--召唤，提示
    InviteButton.summonTips:SetPoint('BOTTOMLEFT', 0, 3)
    InviteButton.summonTips:SetSize(16,16)
    InviteButton.summonTips:SetAtlas('Raid-Icon-SummonPending')

    InviteButton.invTips= InviteButton:CreateTexture(nil,'OVERLAY')--召唤，提示
    InviteButton.invTips:SetPoint('BOTTOMRIGHT', -2, 0)
    InviteButton.invTips:SetSize(16,16)
    InviteButton.invTips:SetAtlas('poi-traveldirections-arrow2')

    function InviteButton:settings()
        self.summonTips:SetShown(Save().Summon)--召唤，提示
        self.invTips:SetShown(Save().Channel and Save().ChannelText or Save().InvTar)
    end

    InviteButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
        else
            WoWTools_InviteMixin:Init_Menu(self)
        end
    end)

    InviteButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:state_leave()
    end)
    InviteButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_InviteMixin.addName, e.Icon.left)
        if Save().InvTar then
            e.tips:AddLine(e.onlyChinese and '邀请目标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, TARGET))
        end
        if Save().Channel and Save().ChannelText then
            e.tips:AddLine((e.onlyChinese and '频道' or CHANNEL)..'|cnGREEN_FONT_COLOR: '..Save().ChannelText)
        end
        e.tips:Show()
        self:state_enter()
    end)

    InviteButton:settings()



    WoWTools_InviteMixin:Init_Chanell()--设置,内容,频道, 邀请,事件
    WoWTools_InviteMixin:Init_Target()--设置, 邀请目标
    WoWTools_InviteMixin:Init_Focus()--Shift+点击设置焦点
    WoWTools_InviteMixin:Init_Summon()
    WoWTools_InviteMixin:Init_Resting()--设置, 休息区提示事件

    --hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate", Init_CONFIRM_SUMMON)


end






















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_InviteMixin.Save= WoWToolsSave['ChatButton_Invite'] or WoWTools_InviteMixin.Save

            WoWTools_InviteMixin.addName= '|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '邀请' or INVITE)

            InviteButton= WoWTools_ChatButtonMixin:CreateButton('Invite', WoWTools_InviteMixin.addName)

            if InviteButton then
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Invite']= WoWTools_InviteMixin.Save
        end
    end
end)