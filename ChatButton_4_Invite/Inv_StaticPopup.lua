--邀请, 对话框
local function Save()
    return WoWToolsSave['ChatButton_Invite'] or {}
end


local function isInLFG()--是否有FB, 排除中
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then
            return true
        end
    end
end

local InviterPlayerGUID--邀请,对话框, guid
local InvTimer




local function Decline()
    Save().InvNoFriendNum=Save().InvNoFriendNum+1
    if InviterPlayerGUID then
        Save().InvNoFriend[InviterPlayerGUID]= (Save().InvNoFriend[InviterPlayerGUID] or 0) + 1
    end
    DeclineGroup()
    StaticPopup_Hide("PARTY_INVITE")
end

local function Accept()
    AcceptGroup()
    StaticPopup_Hide("PARTY_INVITE")
end











local function Settings(_, name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)

    InviterPlayerGUID= inviterGUID

    local StaticPopupFrame, TimeLeft= WoWTools_DataMixin:StaticPopup_FindVisible('PARTY_INVITE')
    if not inviterGUID or not name or not StaticPopupFrame then
        return

    end

    local text
    local sec

    local function setPrint()
        WoWTools_DataMixin:PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音

        print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName)
        print(
            '|cnGREEN_FONT_COLOR:'..(sec or ''), (WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)..'|r',

            text,

            (isTank and WoWTools_DataMixin.Icon.TANK or '')
            ..(isHealer and WoWTools_DataMixin.Icon.HEALER or '')
            ..(isDamage and WoWTools_DataMixin.Icon.DAMAGER or '')
            ..(allowMultipleRoles and '|cffff8200'..(WoWTools_DataMixin.onlyChinese and '多个职责' or CLUB_FINDER_MULTIPLE_ROLES)..'|r' or ''),

            (questSessionActive and '|cff00ffff'..(WoWTools_DataMixin.onlyChinese and '场景战役' or SCENARIOS) or '')--场景战役
        )
        if isNativeRealm then--转服务器
             print(
                '|cffff00ff'
                ..format(
                    WoWTools_DataMixin.onlyChinese
                    and '%s邀请你加入队伍。接受邀请可能会将你传送到另外一个服务器区域。'
                    or INVITATION_XREALM:gsub('\n\n', ''),
                    WoWTools_UnitMixin:GetLink(nil, inviterGUID, name, false)
                )
            )
        end
        if sec then
            print('|cnGREEN_FONT_COLOR:Alt',WoWTools_DataMixin.onlyChinese and '取消' or CANCEL )
        end
        WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, sec or TimeLeft, nil, true, true, nil)--冷却条    
    end


--拒绝
    if Save().InvNoFriend[inviterGUID] then
        sec= 3
        text= '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '拒绝' or DECLINE)..' '..Save().InvNoFriend[inviterGUID]..'/'..Save().InvNoFriendNum..'|r'
        setPrint()

        StaticPopupFrame.button3:SetText(WoWTools_DataMixin.onlyChinese and '移除拒绝' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, DECLINE))

        if InvTimer then InvTimer:Cancel() InvTimer=nil end

        InvTimer = C_Timer.NewTimer(3, Decline)

--好友
    elseif WoWTools_UnitMixin:GetIsFriendIcon(nil, inviterGUID, nil) then
        if not Save().FriendAceInvite then
            WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, TimeLeft or STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条  
            return
        end

        sec=isInLFG() and 10 or 3--是否有FB, 排除中

        text= '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '接受好友' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCEPT, FRIENDS))
            ..'|r'
        setPrint()

        if InvTimer then InvTimer:Cancel() InvTimer=nil end
        InvTimer = C_Timer.NewTimer(sec, Accept)

--休息区不组队
    elseif IsResting() and Save().NoInvInResting and not questSessionActive then
        sec= 3
        text= '|cnRED_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '休息区拒绝' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DECLINE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_STATUS_OUT, ZONE)))
            ..'|r'
        setPrint()

        if InvTimer then InvTimer:Cancel() InvTimer=nil end
        InvTimer = C_Timer.NewTimer(3, Decline)

    else

--添加 拒绝 陌生人
        WoWTools_CooldownMixin:Setup(StaticPopupFrame, nil, TimeLeft or STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
    end
end





local function Init()
    if Save().notInvitePlus then
        return
    end


    EventRegistry:RegisterFrameEventAndCallback("PARTY_INVITE_REQUEST", function(...)
        Settings(...)
    end)


    StaticPopupDialogs["PARTY_INVITE"].button3= WoWTools_DataMixin.onlyChinese and '添加拒绝' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, DECLINE)--添加拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if not InviterPlayerGUID then
            return
        end

        if Save().InvNoFriend[InviterPlayerGUID] then
            Save().InvNoFriend[InviterPlayerGUID] =nil

            print(WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
                WoWTools_UnitMixin:GetLink(nil, InviterPlayerGUID, nil, false)
            )
            Accept()


        else

            Save().InvNoFriend[InviterPlayerGUID] = (Save().InvNoFriend[InviterPlayerGUID] or 0)+ 1
            Save().InvNoFriendNum=Save().InvNoFriendNum+1

            print(WoWTools_InviteMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '添加' or ADD,
                WoWTools_UnitMixin:GetLink(nil, InviterPlayerGUID, nil, false)
            )
            Decline()
        end
    end

    StaticPopupDialogs["PARTY_INVITE"].OnUpdate=function(self)
        if InvTimer and IsModifierKeyDown() then
            InvTimer:Cancel()
            InvTimer=nil
            WoWTools_CooldownMixin:Setup(self, nil, select(2, WoWTools_DataMixin:StaticPopup_FindVisible('PARTY_INVITE')), nil, true, true, nil)--冷却条  
        end
    end

    WoWTools_DataMixin:Hook(StaticPopupDialogs["PARTY_INVITE"], 'OnHide', function(self)
        if InvTimer then InvTimer:Cancel() InvTimer=nil end
        InviterPlayerGUID=nil
        WoWTools_CooldownMixin:Setup(self)--冷却条  
    end)

    Init=function()end
end











function WoWTools_InviteMixin:Init_StaticPopup()
    Init()
end