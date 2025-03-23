--邀请, 对话框
local function Save()
    return WoWToolsSave['ChatButton_Invite']
end


local function isInLFG()--是否有FB, 排除中
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then
            return true
        end
    end
end

local notInviterGUID--邀请,对话框, guid












local function Settings(_, name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
     local StaticPopupFrame= WoWTools_Mixin:StaticPopup_FindVisible('PARTY_INVITE')
     local info = StaticPopupDialogs['PARTY_INVITE']
     print(info and info.tiemout)
print(StaticPopupFrame.timeout)
    if not inviterGUID or not name or not StaticPopupFrame then
        return
    end


    local text
    local sec

    local function setPrint()
        WoWTools_Mixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音

        print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName)
        print(
            '|cnGREEN_FONT_COLOR:'..(sec or ''), (WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)..'|r',

            text,

            (isTank and WoWTools_DataMixin.Icon.TANK or '')
            ..(isHealer and WoWTools_DataMixin.Icon.HEALER or '')
            ..(isDamage and WoWTools_DataMixin.Icon.DAMAGER or '')
            ..(allowMultipleRoles and '|cffff8200'..(WoWTools_DataMixin.onlyChinese and '多个职责' or CLUB_FINDER_MULTIPLE_ROLES)..'|r' or ''),

            (questSessionActive and '|cff00ffff'..(WoWTools_Mixin.onlyChinese and '场景战役' or SCENARIOS) or '')--场景战役
        )
        if isNativeRealm then
             print(
                '|cffff00ff'
                ..format(
                    WoWTools_Mixin.onlyChinese
                    and '%s邀请你加入队伍。接受邀请可能会将你传送到另外一个服务器区域。'
                    or INVITATION_XREALM:gsub('\n\n', ''),
                    WoWTools_UnitMixin:GetLink(nil, inviterGUID)
                )
            )--转服务器
        end
        WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, sec, nil, true, true, nil)--冷却条    
    end


    local friend=WoWTools_UnitMixin:GetIsFriendIcon(nil, inviterGUID, nil)
    if friend then--好友
        if not Save().FriendAceInvite then
            WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条  
            return
        end

        sec=isInLFG() and 10 or 3--是否有FB, 排除中
        text= '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '接受' or ACCEPT)..'|r'..(WoWTools_Mixin.onlyChinese and '好友' or FRIENDS)
        setPrint()

        if StaticPopupFrame.InvTimer then StaticPopupFrame.InvTimer:Cancel() end

        StaticPopupFrame.InvTimer = C_Timer.NewTimer(sec, function()
            AcceptGroup()
            StaticPopup_Hide("PARTY_INVITE")
        end)

    elseif Save().InvNoFriend[inviterGUID] then--拒绝
        sec= 3
        text= '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r '..Save().InvNoFriend[inviterGUID]..'/'..Save().InvNoFriendNum
        setPrint()

        StaticPopupFrame.button3:SetText('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|r'..(WoWTools_Mixin.onlyChinese and '接受' or ACCEPT))
        notInviterGUID=inviterGUID

        if StaticPopupFrame.InvTimer then StaticPopupFrame.InvTimer:Cancel() end

        StaticPopupFrame.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save().InvNoFriendNum=Save().InvNoFriendNum+1

            Save().InvNoFriend[inviterGUID]= (Save().InvNoFriend[inviterGUID] or 0) + 1
        end)

    elseif IsResting() and Save().NoInvInResting and not questSessionActive then--休息区不组队
        sec= 3
        text= '|cnRED_FONT_COLOR:'
            ..(WoWTools_Mixin.onlyChinese and '休息区拒绝' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DECLINE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_STATUS_OUT, ZONE)))
            ..'|r'
        setPrint()

        StaticPopupFrame.button3:SetText(
            '|cnGREEN_FONT_COLOR:'
            ..WoWTools_Mixin.onlyChinese and '添加拒绝' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, DECLINE)
        )
        notInviterGUID=inviterGUID

        if StaticPopupFrame.InvTimer then StaticPopupFrame.InvTimer:Cancel() end
        StaticPopupFrame.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save().InvNoFriendNum=Save().InvNoFriendNum+1
        end)

    else--添加 拒绝 陌生人
        StaticPopupFrame.button3:SetText(
            '|cnGREEN_FONT_COLOR:'
            ..WoWTools_Mixin.onlyChinese and '添加拒绝' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, DECLINE)
        )
        notInviterGUID=inviterGUID

        WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
    end
end





local function Init()


    EventRegistry:RegisterFrameEventAndCallback("PARTY_INVITE_REQUEST", Settings)


    StaticPopupDialogs["PARTY_INVITE"].button3= '|cff00ff00'..(WoWTools_Mixin.onlyChinese and '总是' or ALWAYS)..'|r'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'--添加总是拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if notInviterGUID then
            if Save().InvNoFriend[notInviterGUID] then
                Save().InvNoFriend[notInviterGUID] =nil
                print(WoWTools_Mixin.addName, 'ChatButton', WoWTools_InviteMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|r', WoWTools_UnitMixin:GetLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'..(WoWTools_Mixin.onlyChinese and '邀请' or INVITE))
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
            else


                Save().InvNoFriend[notInviterGUID] = (Save().InvNoFriend[notInviterGUID] or 0)+ 1
                Save().InvNoFriendNum=Save().InvNoFriendNum+1
                DeclineGroup()
                StaticPopup_Hide("PARTY_INVITE")
                print(WoWTools_Mixin.addName, 'ChatButton', WoWTools_InviteMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..'|r', WoWTools_UnitMixin:GetLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'..(WoWTools_Mixin.onlyChinese and '邀请' or INVITE))
            end
        end
        notInviterGUID=nil
    end

    return true
end











function WoWTools_InviteMixin:Init_StaticPopup()
    if Save().FriendAceInvite and Init() then
        Init=function()end
        return true
    end
end