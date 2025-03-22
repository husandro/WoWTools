local e= select(2, ...)
local function Save()
    return WoWTools_CombatMixin.Save
end











local function Init_Menu(self, root)
    local sub, sub2
    local isInCombat= UnitAffectingCombat('player')
--战斗信息

    sub=root:CreateCheckbox(WoWTools_Mixin.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO), function()
        return not Save().disabledText
    end, function()
        self:set_Click()
    end)

    sub:CreateCheckbox((WoWTools_Mixin.onlyChinese and '时间类型' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TIME_LABEL:gsub(HEADER_COLON,''), TYPE))..' '.. SecondsToTime(35), function()
        return Save().timeTypeText
    end, function()
        Save().timeTypeText= not Save().timeTypeText and true or nil
    end)

    sub2=sub:CreateCheckbox((WoWTools_Mixin.onlyChinese and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a|cnGREEN_FONT_COLOR:'..Save().SayTime, function()
        return not Save().disabledSayTime
    end, function()
        Save().disabledSayTime= not Save().disabledSayTime and true or false
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '说' or SAY)
    end)

    sub2:CreateButton(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWTools_EditText',
        WoWTools_CombatMixin.addName
        ..'|n|n'.. (WoWTools_Mixin.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)..' '..(WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        ..'|n|n>= 60 '..WoWTools_TextMixin:GetEnabeleDisable(true),
        nil,
        {
            OnShow=function(s)
                s.editBox:SetNumeric(true)
                s.editBox:SetNumber(Save().SayTime or 120)
            end,
            OnHide=function(s)
                s.editBox:SetNumeric(false)
            end,
            SetValue= function(s)
                local num=s.editBox:GetNumber()
                WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(num), nil, nil)
                Save().SayTime= num
            end,
            EditBoxOnTextChanged=function(s)
                local num= s:GetNumber() or 0
                s:GetParent().button1:SetEnabled(num>=60 and num<2147483647)
            end,
        }
    )
        return MenuResponse.Open
    end)

    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().SayTime
        end, setValue=function(value)
            Save().SayTime= math.floor(value)
            WoWTools_ChatMixin:Chat(WoWTools_TimeMixin:SecondsToClock(Save().SayTime), nil, nil)
        end,
        name= WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS,
        minValue=60,
        maxValue=600,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)
        end,
    })
    sub2:CreateSpacer()

    --[[sub2:CreateButton(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWToolsChatButtonCombatSayTime')
        return MenuResponse.Open
    end)]]

    sub:CreateDivider()
    sub:CreateButton(WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION, function()
        Save().textFramePoint=nil
        if WoWTools_CombatMixin.TrackButton then
            WoWTools_CombatMixin.TrackButton:set_Point()
        end
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_CombatMixin.addName, WoWTools_Mixin.onlyChinese and '重置位置' or RESET_POSITION)
        return MenuResponse.Open
    end)

    sub2=sub:CreateButton((isInCombat and '|cff9e9e9e' or '')..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL), function()
        if IsControlKeyDown() and not InCombatLockdown() then
            WoWTools_CombatMixin.Save= nil
            WoWTools_Mixin:Reload()
        end
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r+'..WoWTools_DataMixin.Icon.left)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)





--缩放
    root:CreateDivider()

    sub= WoWTools_MenuMixin:Scale(self, root, function()
        return Save().inCombatScale or 1
    end, function(value)
        Save().inCombatScale= value

        self:set_Sacle_InCombat(true)
        self:SetButtonState('NORMAL')
        if self:GetScale()==value then
            C_Timer.After(3, function()
                self:set_Sacle_InCombat(UnitAffectingCombat('player'))
            end)
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '战斗中缩放'
                or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, UI_SCALE)
        )
    end)

--总游戏时间
    local tab=WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time
    sub=root:CreateCheckbox(
        tab.totalTime and SecondsToTime(tab.totalTime)
        or (WoWTools_Mixin.onlyChinese and '总游戏时间' or format(TIME_PLAYED_TOTAL, ''):gsub(HEADER_COLON, '')),
    function()
        return Save().AllOnlineTime
    end, function ()
        Save().AllOnlineTime = not Save().AllOnlineTime and true or nil
        if Save().AllOnlineTime then
            RequestTimePlayed()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '总游戏时间' or format(TIME_PLAYED_TOTAL, ''):gsub(HEADER_COLON, ''))
        tooltip:AddLine(format(WoWTools_Mixin.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, ''))
    end)

    local timeAll=0
    local numPlayer=0
    for guid, tab2 in pairs(WoWTools_WoWDate or {}) do
        local time= tab2.Time and tab2.Time.totalTime
        if time and time>0 then
            numPlayer= numPlayer+1
            timeAll= timeAll + time
            sub:CreateButton(WoWTools_UnitMixin:GetPlayerInfo({guid=guid,  reName=true, reRealm=true, factionName=tab.faction})..'|A:socialqueuing-icon-clock:0:0|a  '..SecondsToTime(time), function()
                return MenuResponse.Open
            end)
        end
    end
    WoWTools_MenuMixin:SetGridMode(sub, numPlayer)

    if timeAll>0 then
        sub:CreateDivider()
        sub:CreateTitle((WoWTools_Mixin.onlyChinese and '总计：' or FROM_TOTAL).. SecondsToTime(timeAll))

    end

    root:CreateDivider()
    sub=root:CreateButton(
        '|T'..FRIENDS_TEXTURE_AFK..':0|t'
        ..(UnitIsAFK('player') and '|cff9e9e9e' or '')
        ..(WoWTools_Mixin.onlyChinese and '暂离' or 'AFK'),
    function()
        WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(SLASH_CHAT_AFK1)
    end)
end








function WoWTools_CombatMixin:Init_SetupMenu()
    self.CombatButton:SetupMenu(Init_Menu)
end