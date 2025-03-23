
local function Save()
    return WoWToolsSave['ChatButton_Invite']
end





local function InvPlateGuidFunc()--从已邀请过列表里, 再次邀请 
    if not WoWTools_InviteMixin:Get_Leader() then--取得权限
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
        return
    end
    local n=0
    local co=GetNumGroupMembers()
    for guid, name in pairs(WoWTools_InviteMixin.InvPlateGuid) do
        local num=n+co
        if num==40 then
            return
        elseif not IsInRaid() and num==5 and not Save().PartyToRaid then
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '请求：转化为团队' or  PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
            return
        end

        --toRaidOrParty(num)--自动, 转团,转小队
        if name then
            C_PartyInfo.InviteUnit(name)
            n=n+1

            print(n..')'..WoWTools_UnitMixin:GetLink(name, guid))
        end
    end
end















local function Init_Menu(self, root)
    local sub, sub2, col, num

    sub=root:CreateButton(
        WoWTools_DataMixin.Icon.left
        ..(WoWTools_InviteMixin:Get_Leader() and '' or '|cff9e9e9e')
        ..(WoWTools_Mixin.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7),
    function()
        WoWTools_InviteMixin:Inv_All_Unit()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '周围玩家' or 'Players around')
    end)

    sub:CreateButton(WoWTools_Mixin.onlyChinese and '再次邀请' or INVITE, InvPlateGuidFunc)
    sub:CreateButton(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL, function()
        WoWTools_InviteMixin.InvPlateGuid={}
    end)
    sub:CreateDivider()

    num=0
    for guid, name in pairs(WoWTools_InviteMixin.InvPlateGuid) do
        if not WoWTools_DataMixin.GroupGuid[guid] then
            sub2= sub:CreateButton(WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reName=true, reRealm=true}), function(data)
                C_PartyInfo.InviteUnit(name)
            end, name)
            sub2:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_Mixin.onlyChinese and '再次邀请' or INVITE)
            end)
            num= num+1
        end
    end
    WoWTools_MenuMixin:SetGridMode(sub, num)


    sub=root:CreateCheckbox((IsInInstance() and '|cff9e9e9e' or '')..(WoWTools_Mixin.onlyChinese and '邀请目标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, TARGET))..'|A:poi-traveldirections-arrow2:0:0|a', function()
        return Save().InvTar
    end, function()
        Save().InvTar= not Save().InvTar and true or nil
        self:settings()
        WoWTools_InviteMixin:Inv_Target_Settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '仅限队长' or format(LFG_LIST_CROSS_FACTION, LEADER))
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '不在副本中' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NO, INSTANCE))
    end)

    sub=root:CreateCheckbox((WoWTools_Mixin.onlyChinese and '频道' or CHANNEL)..'|A:poi-traveldirections-arrow2:0:0|a'..('|cnGREEN_FONT_COLOR: '..Save().ChannelText..'|r'), function()
        return Save().Channel
    end, function()
        Save().Channel = not Save().Channel and true or nil
        if _G['WoWToolsChatInviteChanellFrame'] then
            _G['WoWToolsChatInviteChanellFrame']:set_event()
        end
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(Save().ChannelText)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '说, 喊, 密语' or (SAY..', '..YELL..', '..WHISPER))
    end)

    sub:CreateButton(WoWTools_Mixin.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT, function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_Mixin.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT),
        nil, {
            text=Save().ChannelText,
            SetValue= function(s)
                Save().ChannelText = string.upper(s.editBox:GetText())
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '频道' or CHANNEL,'|cnGREEN_FONT_COLOR:'..Save().ChannelText..'|r')
            end,
        })
    end)














--接受邀请
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|A:common-icon-checkmark:0:0|a'..(WoWTools_Mixin.onlyChinese and '邀请' or INVITE),
    function()
        return not Save().notInvitePlus
    end, function()
        Save().notInvitePlus= not Save().notInvitePlus and true or nil
        if not WoWTools_InviteMixin:Init_StaticPopup() then
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    end)

    sub:CreateTitle(WoWTools_Mixin.onlyChinese and '接受' or ACCEPT)
    sub2=sub:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '好友' or FRIENDS,
    function()
        return Save().FriendAceInvite
    end, function()
        Save().FriendAceInvite= not Save().FriendAceInvite and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '战网, 好友, 公会' or (COMMUNITY_COMMAND_BATTLENET..', '..FRIENDS..', '..GUILD))
    end)


    sub:CreateTitle(WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE)
    sub2=sub:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '休息区' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_STATUS_OUT, ZONE),
    function()
        return Save().NoInvInResting
    end, function()
        Save().NoInvInResting= not Save().NoInvInResting and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '必须处于休息区域。' or SPELL_FAILED_CUSTOM_ERROR_464)
    end)


    sub:CreateDivider()
    sub:CreateButton(
        WoWTools_Mixin.onlyChinese and '测试' or 'Test',
    function()
        local name= UnitName('player')
        StaticPopup_Show("PARTY_INVITE", '|n'..format(WoWTools_Mixin.onlyChinese and '"%s邀请你加入队伍"' or INVITATION, name)..'|n|n')
        EventRegistry:TriggerEvent('PARTY_INVITE_REQUEST', UnitName('player'), true, true, true, false, true, WoWTools_DataMixin.Player.GUID, false)
        return MenuResponse.Open
    end)






--召唤
    sub=root:CreateCheckbox(
        '|A:Raid-Icon-SummonPending:0:0|a'..(WoWTools_Mixin.onlyChinese and '召唤' or SUMMON),
    function()
        return Save().Summon
    end, function()
        Save().Summon= not Save().Summon and true or nil
        self:settings()--召唤，提示
    end)
    sub:SetTooltip(function(tooltip)
        if WoWTools_Mixin.onlyChinese then
            tooltip:AddLine('取消: 战斗中, 离开, Alt键')
        else
            tooltip:AddLine(format('%s: %s, %s, %s', CANCEL, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, AFK, ALT_KEY))
        end
    end)

    sub:CreateCheckbox(
        Save().SummonThxText or WoWTools_InviteMixin.SummonThxText,
    function()
        return not Save().notSummonChat
    end, function()
        Save().notSummonChat= not Save().notSummonChat and true or nil
    end)

--修改    
    sub:CreateButton(WoWTools_Mixin.onlyChinese and '修改' or SLASH_CHAT_MODERATE2:gsub('/', ''), function()
        StaticPopup_Show('WoWTools_EditText',
            (WoWTools_Mixin.onlyChinese and '召唤' or SUMMON),
            nil,
            {
                text= Save().SummonThxText or WoWTools_InviteMixin.SummonThxText,
                SetValue= function(s)
                    Save().SummonThxText=s.editBox:GetText()
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, Save().SummonThxText)
                end,
                OnAlt=function()
                    Save().SummonThxText=nil
                end,
            }
        )
        return MenuResponse.Open
    end)

    sub:CreateDivider()
    sub:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '团队' or RAID,
    function()
        return Save().SummonThxInRaid
    end, function()
        Save().SummonThxInRaid= not Save().SummonThxInRaid and true or nil
    end)







    sub=root:CreateCheckbox(WoWTools_Mixin.onlyChinese and '休息区信息' or
        format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, '|cnGREEN_FONT_COLOR:Rest|r', ZONE), INFO), function()
        return Save().restingTips
    end, function()
        Save().restingTips= not Save().restingTips and true or nil
        WoWTools_InviteMixin:Resting_Settings()--设置, 休息区提示
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('|A:communities-icon-chat:0:0|a')
        tooltip:AddLine(WoWTools_InviteMixin.RestingFrame.enterText)
        tooltip:AddLine(WoWTools_InviteMixin.RestingFrame.leaveText)
        if not WoWTools_Mixin.onlyChinese then
            tooltip:AddLine(' ')
            tooltip:AddLine(SPELL_FAILED_CUSTOM_ERROR_464)
        end
    end)








--焦点
    sub=root:CreateCheckbox((WoWTools_Mixin.onlyChinese and '焦点' or HUD_EDIT_MODE_FOCUS_FRAME_LABEL)..(Save().setFucus and ' |cnGREEN_FONT_COLOR:'..Save().focusKey..'|r + '..WoWTools_DataMixin.Icon.left or ''), function()
        return Save().setFucus
    end, function()
        Save().setFucus= not Save().setFucus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    for _, key in pairs({'Shift', 'Ctrl', 'Alt'}) do
        col= (Save().focusKey== key or not self:CanChangeAttribute()) and '|cff9e9e9e' or ''
        sub2=sub:CreateCheckbox(format('%s%s + %s', col, key, WoWTools_DataMixin.Icon.left), function(data)
            return Save().focusKey== data
        end, function(data)
            Save().focusKey= data
        end, key)
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end)
    end

    sub:CreateTitle(
        format('    %s+%s%s=%s|r',
                Save().focusKey or '',
                WoWTools_DataMixin.Icon.right,
                WoWTools_Mixin.onlyChinese and '空' or EMPTY,
                WoWTools_Mixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
            )
    )

    sub:CreateDivider()
    sub2=sub:CreateCheckbox(WoWTools_Mixin.onlyChinese and '密语/跟随' or (SLASH_TEXTTOSPEECH_WHISPER..'/'..FOLLOW),function()
        return Save().setFrameFun
    end, function()
        Save().setFrameFun= not Save().setFrameFun and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    sub:CreateTitle(format('   |A:bags-greenarrow:0:0|a%s', WoWTools_Mixin.onlyChinese and '鼠标滚轮向上滚动: 密语' or (KEY_MOUSEWHEELUP..": "..SLASH_TEXTTOSPEECH_WHISPER)))
    sub:CreateTitle(format('   |A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a%s', WoWTools_Mixin.onlyChinese and'鼠标滚轮向下滚动: 跟随' or (KEY_MOUSEWHEELDOWN..': '..FOLLOW)))
    sub:CreateDivider()
    sub:CreateTitle(WoWTools_Mixin.onlyChinese and'友情提示: 可能会出现错误' or 'Note: Errors may occur')

--reload
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub)









    root:CreateDivider()
    sub=root:CreateButton(format('|A:talents-button-reset:0:0|a%s %d %s', 'talents-button-reset', WoWTools_Mixin.onlyChinese and '拒绝' or DECLINE,  Save().InvNoFriendNum or 0, WoWTools_Mixin.onlyChinese and '邀请' or INVITE))
 
    sub:CreateButton(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL, function()
        Save().InvNoFriend={}
    end)
    sub:CreateDivider()

    num=0
    for guid, nu in pairs(Save().InvNoFriend) do
        sub2=sub:CreateButton(nu..' '..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}),
        function(data)
            Save().InvNoFriend[data]=nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_UnitMixin:GetPlayerInfo(nil, data, nil,{reLink=true}))
        end, guid)
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '移除' or REMOVE)
        end)
    end
    WoWTools_MenuMixin:SetGridMode(sub2, num)
end





function WoWTools_InviteMixin:Init_Menu(...)
    Init_Menu(...)
end
