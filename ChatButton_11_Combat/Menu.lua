local e= select(2, ...)
local function Save()
    return WoWTools_CombatMixin.Save
end











local function Init_Menu(self, root)
    local sub, sub2
    local isInCombat= UnitAffectingCombat('player')

    sub=root:CreateCheckbox(e.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO), function()
        return not Save().disabledText
    end, function()
        self:set_Click()
    end)

    sub:CreateCheckbox((e.onlyChinese and '时间类型' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TIME_LABEL:gsub(':',''), TYPE))..' '.. SecondsToTime(35), function()
        return Save().timeTypeText
    end, function()
        Save().timeTypeText= not Save().timeTypeText and true or nil
    end)

    sub2=sub:CreateCheckbox((e.onlyChinese and '战斗时间' or COMBAT)..'|A:communities-icon-chat:0:0|a|cnGREEN_FONT_COLOR:'..Save().SayTime, function()
        return not Save().disabledSayTime
    end, function()
        Save().disabledSayTime= not Save().disabledSayTime and true or false
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '说' or SAY)
    end)

    sub2:CreateButton(e.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWTools_EditText',
        WoWTools_CombatMixin.addName
        ..'|n|n'.. (e.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        ..'|n|n>= 60 '..e.GetEnabeleDisable(true),
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
        name= e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS,
        minValue=60,
        maxValue=600,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddLine(e.onlyChinese and '时间戳' or EVENTTRACE_TIMESTAMP)
        end,
    })
    sub2:CreateSpacer()

    --[[sub2:CreateButton(e.onlyChinese and '设置' or SETTINGS, function()
        StaticPopup_Show('WoWToolsChatButtonCombatSayTime')
        return MenuResponse.Open
    end)]]

    sub:CreateDivider()
    sub:CreateButton(e.onlyChinese and '重置位置' or RESET_POSITION, function()
        Save().textFramePoint=nil
        if WoWTools_CombatMixin.TrackButton then
            WoWTools_CombatMixin.TrackButton:set_Point()
        end
        print(WoWTools_Mixin.addName, WoWTools_CombatMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        return MenuResponse.Open
    end)

    sub2=sub:CreateButton((isInCombat and '|cff9e9e9e' or '')..(e.onlyChinese and '全部清除' or CLEAR_ALL), function()
        if IsControlKeyDown() and not InCombatLockdown() then
            WoWTools_CombatMixin.Save= nil
            WoWTools_Mixin:Reload()
        end
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r+'..e.Icon.left)
        tooltip:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
    end)





--缩放
    root:CreateDivider()
    sub2, sub= WoWTools_MenuMixin:ScaleCheck(self, root, function()
        return Save().inCombatScale
    end, function(value)
        Save().inCombatScale= value
        
            self:set_Sacle_InCombat(true)
            C_Timer.After(3, function()
                self:set_Sacle_InCombat(UnitAffectingCombat('player'))
            end)
        
    end,
    nil,
    function()
        return Save().combatScale
    end, function()
        Save().combatScale= not Save().combatScale and true or nil
        self:set_Sacle_InCombat(UnitAffectingCombat('player'))        
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        self:set_Sacle_InCombat(UnitAffectingCombat('player'))
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    end)

--总游戏时间
    local tab=e.WoWDate[e.Player.guid].Time
    sub=root:CreateCheckbox(e.onlyChinese and '总游戏时间'..((tab and tab.totalTime) and ': '..SecondsToTime(tab.totalTime) or '') or TIME_PLAYED_TOTAL:format((tab and tab.totalTime) and SecondsToTime(tab.totalTime) or ''), function()
        return Save().AllOnlineTime
    end, function ()
        Save().AllOnlineTime = not Save().AllOnlineTime and true or nil
        if Save().AllOnlineTime then
            RequestTimePlayed()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(format(e.onlyChinese and '你在这个等级的游戏时间：%s' or TIME_PLAYED_LEVEL, ''))
    end)

    local timeAll=0
    local numPlayer=0
    for guid, tab2 in pairs(e.WoWDate or {}) do
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
        sub:CreateTitle((e.onlyChinese and '总计：' or FROM_TOTAL).. SecondsToTime(timeAll))

    end
end








function WoWTools_CombatMixin:Init_SetupMenu()
    self.CombatButton:SetupMenu(Init_Menu)
end