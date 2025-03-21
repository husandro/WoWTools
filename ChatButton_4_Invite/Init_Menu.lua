local e= select(2, ...)
local function Save()
    return WoWTools_InviteMixin.Save
end





local function InvPlateGuidFunc()--从已邀请过列表里, 再次邀请 
    if not WoWTools_InviteMixin:Get_Leader() then--取得权限
        print(e.Icon.icon2..WoWTools_InviteMixin.addName, e.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
        return
    end
    local n=0
    local co=GetNumGroupMembers()
    for guid, name in pairs(WoWTools_InviteMixin.InvPlateGuid) do
        local num=n+co
        if num==40 then
            return
        elseif not IsInRaid() and num==5 and not Save().PartyToRaid then
            print(e.Icon.icon2..WoWTools_InviteMixin.addName, e.onlyChinese and '请求：转化为团队' or  PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
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
        e.Icon.left
        ..(WoWTools_InviteMixin:Get_Leader() and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7),
    function()
        WoWTools_InviteMixin:Inv_All_Unit()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '周围玩家' or 'Players around')
    end)

    sub:CreateButton(e.onlyChinese and '再次邀请' or INVITE, InvPlateGuidFunc)
    sub:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
        WoWTools_InviteMixin.InvPlateGuid={}
    end)
    sub:CreateDivider()

    num=0
    for guid, name in pairs(WoWTools_InviteMixin.InvPlateGuid) do
        if not e.GroupGuid[guid] then
            sub2= sub:CreateButton(WoWTools_UnitMixin:GetPlayerInfo(nil, guid, name, {reName=true, reRealm=true}), function(data)
                C_PartyInfo.InviteUnit(name)
            end, name)
            sub2:SetTooltip(function(tooltip)
                tooltip:AddLine(e.onlyChinese and '再次邀请' or INVITE)
            end)
            num= num+1
        end
    end
    WoWTools_MenuMixin:SetGridMode(sub, num)


    sub=root:CreateCheckbox((IsInInstance() and '|cff9e9e9e' or '')..(e.onlyChinese and '邀请目标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, TARGET))..'|A:poi-traveldirections-arrow2:0:0|a', function()
        return Save().InvTar
    end, function()
        Save().InvTar= not Save().InvTar and true or nil
        self:settings()
        WoWTools_InviteMixin:Inv_Target_Settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '仅限队长' or format(LFG_LIST_CROSS_FACTION, LEADER))
        tooltip:AddLine(e.onlyChinese and '不在副本中' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NO, INSTANCE))
    end)

    sub=root:CreateCheckbox((e.onlyChinese and '频道' or CHANNEL)..'|A:poi-traveldirections-arrow2:0:0|a'..('|cnGREEN_FONT_COLOR: '..Save().ChannelText..'|r'), function()
        return Save().Channel
    end, function()
        Save().Channel = not Save().Channel and true or nil
        WoWTools_InviteMixin.InvChanellFrame:set_event()
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(Save().ChannelText)
        tooltip:AddLine(e.onlyChinese and '说, 喊, 密语' or (SAY..', '..YELL..', '..WHISPER))
    end)

    sub:CreateButton(e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT, function()
        StaticPopup_Show('WoWTools_EditText',
        (e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT),
        nil, {
            text=Save().ChannelText,
            SetValue= function(s)
                Save().ChannelText = string.upper(s.editBox:GetText())
                print(e.Icon.icon2..WoWTools_InviteMixin.addName, e.onlyChinese and '频道' or CHANNEL,'|cnGREEN_FONT_COLOR:'..Save().ChannelText..'|r')
            end,
        })
    end)














--接受邀请
    root:CreateDivider()
    sub=root:CreateCheckbox((e.onlyChinese and '接受邀请' or CALENDAR_ACCEPT_INVITATION)..format('|A:%s:0:0|a', e.Icon.select), function()
        return Save().FriendAceInvite
    end, function()
        Save().FriendAceInvite= not Save().FriendAceInvite and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '战网, 好友, 公会' or (COMMUNITY_COMMAND_BATTLENET..', '..FRIENDS..', '..GUILD))
    end)







--召唤
    sub=root:CreateCheckbox((e.onlyChinese and '召唤' or SUMMON)..'|A:Raid-Icon-SummonPending:0:0|a', function()
        return Save().Summon
    end, function()
        Save().Summon= not Save().Summon and true or nil
        self:settings()--召唤，提示
    end)
    sub:SetTooltip(function(tooltip)
        if e.onlyChinese then
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
    sub:CreateButton(e.onlyChinese and '修改' or SLASH_CHAT_MODERATE2:gsub('/', ''), function()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '召唤' or SUMMON),
            nil,
            {
                text= Save().SummonThxText or WoWTools_InviteMixin.SummonThxText,
                SetValue= function(s)
                    Save().SummonThxText=s.editBox:GetText()
                    print(e.Icon.icon2..WoWTools_InviteMixin.addName, Save().SummonThxText)
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
        e.onlyChinese and '团队' or RAID,
    function()
        return Save().SummonThxInRaid
    end, function()
        Save().SummonThxInRaid= not Save().SummonThxInRaid and true or nil
    end)







    sub=root:CreateCheckbox(e.onlyChinese and '休息区信息' or
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
        if not e.onlyChinese then
            tooltip:AddLine(' ')
            tooltip:AddLine(SPELL_FAILED_CUSTOM_ERROR_464)
        end
    end)









--焦点
    sub=root:CreateCheckbox((e.onlyChinese and '焦点' or HUD_EDIT_MODE_FOCUS_FRAME_LABEL)..(Save().setFucus and ' |cnGREEN_FONT_COLOR:'..Save().focusKey..'|r + '..e.Icon.left or ''), function()
        return Save().setFucus
    end, function()
        Save().setFucus= not Save().setFucus and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    for _, key in pairs({'Shift', 'Ctrl', 'Alt'}) do
        col= (Save().focusKey== key or not self:CanChangeAttribute()) and '|cff9e9e9e' or ''
        sub2=sub:CreateCheckbox(format('%s%s + %s', col, key, e.Icon.left), function(data)
            return Save().focusKey== data
        end, function(data)
            Save().focusKey= data
        end, key)
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end)
    end

    sub:CreateTitle(
        format('    %s+%s%s=%s|r',
                Save().focusKey or '',
                e.Icon.right,
                e.onlyChinese and '空' or EMPTY,
                e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
            )
    )

    sub:CreateDivider()
    sub2=sub:CreateCheckbox(e.onlyChinese and '密语/跟随' or (SLASH_TEXTTOSPEECH_WHISPER..'/'..FOLLOW),function()
        return Save().setFrameFun
    end, function()
        Save().setFrameFun= not Save().setFrameFun and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    sub:CreateTitle(format('   |A:bags-greenarrow:0:0|a%s', e.onlyChinese and '鼠标滚轮向上滚动: 密语' or (KEY_MOUSEWHEELUP..": "..SLASH_TEXTTOSPEECH_WHISPER)))
    sub:CreateTitle(format('   |A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a%s', e.onlyChinese and'鼠标滚轮向下滚动: 跟随' or (KEY_MOUSEWHEELDOWN..': '..FOLLOW)))
    sub:CreateDivider()
    sub:CreateTitle(e.onlyChinese and'友情提示: 可能会出现错误' or 'Note: Errors may occur')

--reload
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub)









    root:CreateDivider()
    sub=root:CreateButton(format('|A:%s:0:0|a%s %d %s', e.Icon.disabled, e.onlyChinese and '拒绝' or DECLINE,  Save().InvNoFriendNum or 0, e.onlyChinese and '邀请' or INVITE))

    sub2=sub:CreateCheckbox(e.onlyChinese and '休息区' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_STATUS_OUT, ZONE), function()
        return Save().NoInvInResting
    end, function()
        Save().NoInvInResting= not Save().NoInvInResting and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '拒绝' or DECLINE)
        tooltip:AddLine(e.onlyChinese and '好友除外' or 'Except friends')
    end)
    sub:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
        Save().InvNoFriend={}
    end)
    sub:CreateDivider()

    num=0
    for guid, nu in pairs(Save().InvNoFriend) do
        sub2=sub:CreateButton(nu..' '..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {reName=true, reRealm=true}),
        function(data)
            Save().InvNoFriend[data]=nil
            print(e.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_UnitMixin:GetPlayerInfo(nil, data, nil,{reLink=true}))
        end, guid)
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
        end)
    end
    WoWTools_MenuMixin:SetGridMode(sub2, num)
end





function WoWTools_InviteMixin:Init_Menu(...)
    Init_Menu(...)
end
