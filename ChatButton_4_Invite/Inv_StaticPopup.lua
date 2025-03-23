
local function Save()
    return WoWTools_InviteMixin.Save
end

















local function isInLFG()--是否有FB, 排除中
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then
            return true
        end
    end
end
















--###########
--邀请, 对话框
--###########
local notInviterGUID--邀请,对话框, guid
local function PARTY_INVITE_REQUEST(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    if not inviterGUID or not name then
        return
    end
    if not StaticPopup1 or not StaticPopup1:IsShown() then
        return
    end

    local function setPrint(sec, text)
        WoWTools_Mixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        print(WoWTools_Mixin.addName, 'ChatButton', WoWTools_InviteMixin.addName, text,
            '|cnGREEN_FONT_COLOR:'..sec.. ' |r'..(WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS),
            (isTank and WoWTools_DataMixin.Icon.TANK or '')..(isHealer and WoWTools_DataMixin.Icon.TANK or '')..(isDamage and WoWTools_DataMixin.Icon.DAMAGER or ''),
            questSessionActive and (WoWTools_Mixin.onlyChinese and '场景战役' or SCENARIOS) or '',--场景战役
            isNativeRealm and '|cnGREEN_FONT_COLOR:'..format(WoWTools_Mixin.onlyChinese and '%s其它服务器' or INVITATION_XREALM,
            WoWTools_UnitMixin:GetLink(nil, inviterGUID))--转服务器
        )
        WoWTools_CooldownMixin:Setup(StaticPopup1, nil, sec, nil, true, true, nil)--冷却条    
    end

    local friend=WoWTools_UnitMixin:GetIsFriendIcon(nil, inviterGUID, nil)
    if friend then--好友
        if not Save().FriendAceInvite then
            WoWTools_CooldownMixin:Setup(StaticPopup1, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条  
            return
        end
        local sec=isInLFG() and 10 or 3--是否有FB, 排除中
        setPrint(sec, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '接受' or ACCEPT)..'|r'..(WoWTools_Mixin.onlyChinese and '好友' or FRIENDS))
        if StaticPopup1.InvTimer then StaticPopup1.InvTimer:Cancel() end
        StaticPopup1.InvTimer = C_Timer.NewTimer(sec, function()
            AcceptGroup()
            StaticPopup_Hide("PARTY_INVITE")
        end)

    elseif Save().InvNoFriend[inviterGUID] then--拒绝
        setPrint(3, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'..Save().InvNoFriend[inviterGUID]..'/'..Save().InvNoFriendNum)
        StaticPopup1.button3:SetText('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|r'..(WoWTools_Mixin.onlyChinese and '接受' or ACCEPT))
        notInviterGUID=inviterGUID
        if StaticPopup1.InvTimer then StaticPopup1.InvTimer:Cancel() end
        StaticPopup1.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save().InvNoFriendNum=Save().InvNoFriendNum+1
            Save().InvNoFriend[inviterGUID]=Save().InvNoFriend[inviterGUID]+1
        end)

    elseif IsResting() and Save().NoInvInResting and not questSessionActive then--休息区不组队
        setPrint(3, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '' or DECLINE)..'|r'..(WoWTools_Mixin.onlyChinese and '休息区' or (CALENDAR_STATUS_OUT..ZONE)))

        StaticPopup1.button3:SetText('|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..'|r'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE))
        notInviterGUID=inviterGUID
        if StaticPopup1.InvTimer then StaticPopup1.InvTimer:Cancel() end
        StaticPopup1.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save().InvNoFriendNum=Save().InvNoFriendNum+1
        end)

    else--添加 拒绝 陌生人
        StaticPopup1.button3:SetText('|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..'|r'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE))
        notInviterGUID=inviterGUID

        WoWTools_CooldownMixin:Setup(StaticPopup1, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
    end
end





local function Init()
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('PARTY_INVITE_REQUEST')
    frame:SetScript('OnEvent', PARTY_INVITE_REQUEST)



    StaticPopupDialogs["PARTY_INVITE"].button3= '|cff00ff00'..(WoWTools_Mixin.onlyChinese and '总是' or ALWAYS)..'|r'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'--添加总是拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if notInviterGUID then
            if Save().InvNoFriend[notInviterGUID] then
                Save().InvNoFriend[notInviterGUID] =nil
                print(WoWTools_Mixin.addName, 'ChatButton', WoWTools_InviteMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)..'|r', WoWTools_UnitMixin:GetLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'..(WoWTools_Mixin.onlyChinese and '邀请' or INVITE))
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
            else
                Save().InvNoFriend[notInviterGUID] =Save().InvNoFriend[notInviterGUID] and Save().InvNoFriend[notInviterGUID]+1 or 1
                Save().InvNoFriendNum=Save().InvNoFriendNum+1
                DeclineGroup()
                StaticPopup_Hide("PARTY_INVITE")
                print(WoWTools_Mixin.addName, 'ChatButton', WoWTools_InviteMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '添加' or ADD)..'|r', WoWTools_UnitMixin:GetLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)..'|r'..(WoWTools_Mixin.onlyChinese and '邀请' or INVITE))
            end
        end
        notInviterGUID=nil
    end
end











function WoWTools_InviteMixin:Init_StaticPopup()
    Init()
end