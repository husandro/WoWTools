local addName
local function Save()
    return WoWToolsSave['Other_MarkerFrame'] or {}
end

local TargetColor={
    [1]= YELLOW_FONT_COLOR,-- {r=1, g=1, b=0, col='|cffffff00'},--星星, 黄色
    [2]= ORANGE_FONT_COLOR,-- {r=1, g=0.45, b=0.04, col='|cffff7f3f'},--圆形, 橙色
    [3]= EPIC_PURPLE_COLOR,--{r=1, g=0, b=1, col='|cffa335ee'},--菱形, 紫色
    [4]= GREEN_FONT_COLOR, --CreateColor(0, 1, 0),--{r=0, g=1, b=0, col='|cff1eff00'},--三角, 绿色
    [5]= HIGHLIGHT_FONT_COLOR,-- CreateColor(1, 1, 1),--{r=0.6, g=0.6, b=0.6, col='|cffffffff'},--月亮, 白色
    [6]= BLUE_FONT_COLOR,-- CreateColor(),--{r=0.1, g=0.2, b=1, col='|cff0070dd'},--方块, 蓝色
    [7]= RED_FONT_COLOR,-- CreateColor(),--{r=1, g=0, b=0, col='|cffff2020'},--十字, 红色
    [8]= DISABLED_FONT_COLOR,--CreateColor(),--{r=1, g=1, b=1, col='|cffffffff'},--骷髅,白色
}




local MakerFrame


local Buttons={}--_G[Name..Button[1]]
local PingButtons={}
local TargetButtons={}
local MarkerButtons={}

--SecureTemplates.lua








local function Init_Menu(self, root)

    local sub,sub2

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,
    function()
        return Save().isShowHotKey
    end, function()
        Save().isShowHotKey= not Save().isShowHotKey and true or nil
        self:set_all_hotkey()--设置全部，快捷键
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '提示' or CHARACTER_CUSTOMIZATION_TUTORIAL_TITLE)
    end)

--打开选项，信号系统
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '信号系统' or PING_SYSTEM_LABEL,
    function()
        if not InCombatLockdown() then
            Settings.OpenToCategory(Settings.PINGSYSTEM_CATEGORY_ID)--Blizzard_SettingsDefinitions_Frame/PingSystem.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or SETTINGS_TITLE)
    end)

--打开选项，队伍标记
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET,
    function()
        if not InCombatLockdown() then
            Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, BINDING_HEADER_RAID_TARGET)--Blizzard_SettingsDefinitions_Frame/PingSystem.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or SETTINGS_TITLE)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
    end)





--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
            return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:set_strata()
    end)

    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:set_scale()
    end)

--显示背景 
    WoWTools_MenuMixin:BgAplha(root, function()
        return Save().bgAlpha or 0.5
    end, function(value)
        Save().bgAlpha=value
        self:set_bg()
    end)


--位于上方
    WoWTools_MenuMixin:ToTop(self, root, {
        name=nil,
        GetValue=function()
            return Save().isToUp
        end,
        SetValue=function()
            Save().isToUp = not Save().isToUp and true or nil
            self:set_all_point()
        end,
        tooltip=false,
    })

--HUD提示信息
   sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and 'HUD提示信息' or HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
    function()
        return not Save().hideTooltip
    end, function()
        Save().hideTooltip= not Save().hideTooltip and true or nil
    end)

    sub:CreateCheckbox(
        'ANCHOR_LEFT',
    function()
        return Save().isTooltipLeft
    end, function()
        Save().isTooltipLeft= not Save().isTooltipLeft and true or nil
    end)

--选项
    root:CreateDivider()
    sub = WoWTools_OtherMixin:OpenOption(root, 'MarkerFrame', addName)

--倒计时
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().countdown or 7
        end, setValue=function(value)
            Save().countdown=value
            self.countdown:set_hotkey()
        end,
        name=WoWTools_DataMixin.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2,
        minValue=1,
        maxValue=3600,
        step=1,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        end
    })
    sub:CreateSpacer()

--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().point, function()
        Save().point=nil
        self:set_point()
        print(
            WoWTools_DataMixin.Icon.icon2..addName,
            WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
        )
    end)
end
















--是否显示，HUD提示信息
local function Tooltip_SetOwner()
    if not Save().hideTooltip then
        if Save().isTooltipLeft then
            GameTooltip:SetOwner(MakerFrame.RolePoll, 'ANCHOR_LEFT')
        else
            GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
        end
        return true
    end
end















--设置标记, 框架
local function Init()--设置标记, 框架
    MakerFrame= CreateFrame('Button', 'WoWToolsMarkerFrame', UIParent, 'WoWToolsButtonTemplate')
    MakerFrame:SetClampedToScreen(true)
    MakerFrame:SetSize(23,23)--大小



    MakerFrame.texture= MakerFrame:CreateTexture()
    MakerFrame.texture:SetPoint('CENTER')
    MakerFrame.texture:SetTexture('Interface\\Cursor\\UI-Cursor-Move')
    MakerFrame.texture:SetSize(16, 16)













    --Ping System Blizzard_PingUI.lua
    MakerFrame.ping= CreateFrame('Frame', 'WoWToolsMarkersPingFrame', MakerFrame)
    table.insert(Buttons, 'WoWToolsMarkersPingFrame')

    MakerFrame.ping:SetSize(23, 23)
    function MakerFrame.ping:set_point()
        self:ClearAllPoints()
        if Save().isToUp then
            self:SetPoint("BOTTOM", MakerFrame, 'TOP')
        else
            self:SetPoint('RIGHT', MakerFrame, 'LEFT')
        end
    end
    MakerFrame.ping:set_point()

    MakerFrame.ping.tab={--Enum.PingSubjectType.Warning
        [8]={name=WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO, atlas='Ping_Marker_Icon_NonThreat', action='TOGGLEPINGLISTENER'},
        [0]={name=WoWTools_DataMixin.onlyChinese and '攻击' or PING_TYPE_ATTACK, atlas='Ping_Marker_Icon_Attack', action='PINGATTACK', text=BINDING_NAME_PINGATTACK},--text='attack'},
        [1]={name=WoWTools_DataMixin.onlyChinese and '警告' or PING_TYPE_WARNING, atlas='Ping_Marker_Icon_Warning', action= 'PINGWARNING', text=BINDING_NAME_PINGWARNING},--text='warning'},
        [3]={name=WoWTools_DataMixin.onlyChinese and '正在赶来' or PING_TYPE_ON_MY_WAY, atlas='Ping_Marker_Icon_OnMyWay', action='PINGONMYWAY', text=BINDING_NAME_PINGONMYWAY},--text='onmyway'},
        [2]={name=WoWTools_DataMixin.onlyChinese and '协助' or PING_TYPE_ASSIST, atlas='Ping_Marker_Icon_Assist', action='PINGASSIST', text=BINDING_NAME_PINGASSIST},-- text='assist'},

        --[7]={name=WoWTools_DataMixin.onlyChinese and '信号' or PING, atlas='Cursor_OpenHand_128', action='TOGGLEPINGLISTENER'},
        --[4]={name=WoWTools_DataMixin.onlyChinese and '威胁' or REPORT_THREAT , atlas='Ping_Marker_Icon_threat'},
        --[5]={name=WoWTools_DataMixin.onlyChinese and '看这里' or format(PING_SUBJECT_TYPE_ALERT_NOT_THREAT_POINT,'','',''), atlas='Ping_Marker_Icon_nonthreat'},
    }


    for setIndex, index in pairs({8, 0, 1, 3, 2}) do
        local btn= CreateFrame('Button', 'WoWToolsMakersPingButton'..index, MakerFrame.ping, 'WoWToolsButtonTemplate SecureActionButtonTemplate', setIndex)

        table.insert(PingButtons, 'WoWToolsMakersPingButton'..index)

        btn:SetNormalAtlas(MakerFrame.ping.tab[index].atlas)

        if setIndex==1 then
            btn:SetAllPoints(MakerFrame.ping)

        else
            table.insert(Buttons, 'WoWToolsMakersPingButton'..index)

            function btn:set_point()
                local b= _G[PingButtons[self:GetID()-1]]
                self:ClearAllPoints()
                if Save().isToUp then
                    self:SetPoint('BOTTOMRIGHT', b, 'TOPRIGHT')
                else
                    self:SetPoint('BOTTOMRIGHT', b, 'BOTTOMLEFT')
                end
            end
            btn:set_point()
        end

        btn.name= MakerFrame.ping.tab[index].name..'|A:'..MakerFrame.ping.tab[index].atlas..':26:26|a'
        btn.action= MakerFrame.ping.tab[index].action

        btn:SetAttribute('type1', 'macro')
        btn:SetAttribute('type2', 'macro')
        btn:SetAttribute("macrotext1", SLASH_PING1..' [@target]'..(MakerFrame.ping.tab[index].text or ''))
        btn:SetAttribute("macrotext2", SLASH_PING1..' [@player]'..(MakerFrame.ping.tab[index].text or ''))

        function btn:set_event()
            self:UnregisterAllEvents()
            if self:IsVisible() then
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
                if Save().isShowHotKey then
                    self:RegisterEvent('UPDATE_BINDINGS')
                end
            end
            self:set_hotkey()
            WoWTools_CooldownMixin:Setup(self)
        end

        btn:SetScript('OnShow', btn.set_event)
        btn:SetScript('OnHide', btn.set_event)

        btn:SetScript('OnEvent', function(self, event)
            if event=='UPDATE_BINDINGS' then
                self:set_hotkey()
            else
                self:SetAlpha(UnitExists('target') and 1 or 0.5)
            end
        end)
        btn:SetAlpha(0.5)

        btn:SetScript('OnLeave', function() GameTooltip:Hide() ResetCursor() end)
        btn:SetScript('OnEnter', function(self)
            if not Tooltip_SetOwner() then
                return
            end
            GameTooltip:SetText(
                WoWTools_DataMixin.Icon.left
                ..MicroButtonTooltipText(self.name, self.action)
                ..WoWTools_ColorMixin:SetStringColor(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                ..WoWTools_DataMixin.Icon.right
            )
            GameTooltip:Show()
        end)

--快捷键
        btn.HotKey= btn:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
        btn.HotKey:SetPoint('TOPRIGHT', 1, 2)
        function btn:set_hotkey()
            if self.action then
                self.HotKey:SetText(Save().isShowHotKey and WoWTools_KeyMixin:GetHotKeyText(nil, self.action) or '')
            end
        end

        btn:set_event()
    end



--这个是被保护
    hooksecurefunc(PingListenerFrame, 'SetupCooldownTimer', function(self)--冷却，时间
        if MakerFrame.ping:IsVisible() and canaccessvalue(self.cooldownInfo.endTimeMs) then
            local cooldownDuration = (self.cooldownInfo.endTimeMs / 1000) - GetTime()
            for _, name in pairs(PingButtons) do
                WoWTools_CooldownMixin:Setup(_G[name], nil, cooldownDuration, nil, true)
            end
        end
    end)











--倒计时
    MakerFrame.countdown= CreateFrame('Button', 'WoWToolsMarkersCountdownButton', MakerFrame, 'WoWToolsButtonTemplate')

    table.insert(Buttons, 'WoWToolsMarkersCountdownButton')

    MakerFrame.countdown:SetNormalAtlas('countdown-swords')

    function MakerFrame.countdown:set_point()
        local b= _G[PingButtons[#PingButtons]]
        self:ClearAllPoints()
        if Save().isToUp then
            self:SetPoint('BOTTOM', b, 'TOP')
        else
            self:SetPoint('RIGHT', b, 'LEFT')
        end
    end
    MakerFrame.countdown:set_point()

    MakerFrame.countdown:SetScript('OnClick', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            if not self.star then
                C_PartyInfo.DoCountdown(Save().countdown or 7)
            end
        elseif d=='RightButton' and not key then
            if self.star then
                C_PartyInfo.DoCountdown(0)
            end
            WoWTools_ChatMixin:Chat(WoWTools_DataMixin.Player.IsCN and '{rt7}取消 取消 取消{rt7}' or '{rt7}STOP STOP STOP{rt7}', nil, nil)
        end
    end)
    MakerFrame.countdown:SetScript('OnEnter', function()
        if not Tooltip_SetOwner() then
            return
        end
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' |cffffffFF'..(Save().countdown or 7))
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.Player.IsCN and '取消 取消 取消' or 'STOP STOP STOP')..'|A:transmog-icon-chat:0:0|a', HIGHLIGHT_FONT_COLOR:GetRGB())
        GameTooltip:AddLine(' ')
        GameTooltip_AddInstructionLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '备注：不要太快了' or format('%s: %s', LABEL_NOTE, ERR_GENERIC_THROTTLE), true)
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS))
        GameTooltip:Show()
    end)
    MakerFrame.countdown:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    function MakerFrame.countdown:set_event()
        if self:IsShown() then
            self:RegisterEvent('START_TIMER')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.countdown:SetScript('OnShow', function(self)
        self:set_event()
    end)
    MakerFrame.countdown:SetScript('OnHide', function(self)
        self:set_event()
    end)
    MakerFrame.countdown:SetScript('OnEvent', function(self, event, timerType, timeRemaining, totalTime)
        if timerType==3 and event=='START_TIMER' then
            if totalTime==0 then
               self.star=nil
               if self.timer then self.timer:Cancel() self.timer=nil end
            elseif totalTime>0 then
                if self.timer then self.timer:Cancel() self.timer=nil end
                self.timer=C_Timer.NewTimer(timeRemaining or totalTime, function() self.star=nil end)
                self.star=true
            end
            WoWTools_CooldownMixin:Setup(self, nil, timeRemaining or totalTime, nil, true)--冷却条
        end
    end)
    MakerFrame.countdown:set_event()


    MakerFrame.countdown:SetScript('OnMouseWheel', function(self)
        MenuUtil.CreateContextMenu(self, function(frame, root)
            root:CreateSpacer()
            WoWTools_MenuMixin:CreateSlider(root, {
                getValue=function()
                    return Save().countdown or 7
                end, setValue=function(value)
                    Save().countdown=value
                    frame:set_hotkey()
                end,
                name=WoWTools_DataMixin.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2,
                minValue=1,
                maxValue=3600,
                step=1,
                tooltip=function(tooltip)
                    tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
                end
            })
            root:CreateSpacer()
        end)
    end)

    MakerFrame.countdown.HotKey= MakerFrame.countdown:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    MakerFrame.countdown.HotKey:SetPoint('TOPRIGHT', 1, 2)
    function MakerFrame.countdown:set_hotkey()
        local value
        if Save().isShowHotKey then
            value= Save().countdown or 7
        end
        self.HotKey:SetText(value or '')
    end
    MakerFrame.countdown:set_hotkey()














--就绪
    MakerFrame.check= CreateFrame('Button', 'WoWToolsMarkesCheckButton', MakerFrame, 'WoWToolsButtonTemplate')

    table.insert(Buttons, 'WoWToolsMarkesCheckButton')

    MakerFrame.check:SetNormalAtlas('common-icon-checkmark-yellow')

    function MakerFrame.check:set_point()
        self:ClearAllPoints()
        if Save().isToUp then
            self:SetPoint('BOTTOM', MakerFrame.countdown, 'TOP')
        else
            self:SetPoint('RIGHT', MakerFrame.countdown, 'LEFT')
        end
    end
    MakerFrame.check:set_point()

    MakerFrame.check:SetScript('OnClick', function()
        DoReadyCheck()
    end)
    MakerFrame.check:SetScript('OnEnter', function()
        if not Tooltip_SetOwner() then
            return
        end
        GameTooltip:SetText(EMOTE127_CMD3)
        GameTooltip:Show()
    end)
    MakerFrame.check:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    function MakerFrame.check:set_event()
        if self:IsShown() then
            self:RegisterEvent('READY_CHECK')
            self:RegisterEvent('READY_CHECK_FINISHED')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.check:SetScript('OnShow', function(self)
        self:set_event()
    end)
    MakerFrame.check:SetScript('OnHide', function(self)
        self:set_event()
    end)
    MakerFrame.check:SetScript('OnEvent', function(self, event, _, arg2)
        WoWTools_CooldownMixin:Setup(self, nil, event=='READY_CHECK_FINISHED' and 0 or arg2 or 0, nil, true, true)--冷却条
    end)
    MakerFrame.check:set_event()




    MakerFrame.RolePoll= CreateFrame('Button', 'WoWToolsMarkersRolePollButton', MakerFrame, 'WoWToolsButtonTemplate')

    table.insert(Buttons, 'WoWToolsMarkersRolePollButton')

    MakerFrame.RolePoll:SetNormalAtlas('GM-icon-roles')

    WoWTools_TextureMixin:SetButton(MakerFrame.RolePoll, {alpha=1})

    function MakerFrame.RolePoll:set_point()
        self:ClearAllPoints()
        if Save().isToUp then
            self:SetPoint('BOTTOM', MakerFrame.check, 'TOP')
        else
            self:SetPoint('RIGHT', MakerFrame.check, 'LEFT')
        end
    end
    MakerFrame.RolePoll:set_point()

    MakerFrame.RolePoll:SetScript('OnClick', function()
        InitiateRolePoll()
    end)
    MakerFrame.RolePoll:SetScript('OnEnter', function()
        if not Tooltip_SetOwner() then
            return
        end
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '职责选定' or CRF_ROLE_POLL)
        GameTooltip:Show()
    end)
    MakerFrame.RolePoll:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)--RolePollPopup











--队伍标记
    MakerFrame.target= CreateFrame("Frame", 'WoWToolsMakersTargetFrame', MakerFrame)
    MakerFrame.target:SetSize(23, 23)
    table.insert(Buttons, 'WoWToolsMakersTargetFrame')

    function MakerFrame.target:set_point()
        self:ClearAllPoints()
        if Save().isToUp then
            self:SetPoint('RIGHT', MakerFrame, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame, 'BOTTOM')
        end
    end
    MakerFrame.target:set_point()











--目标，标记
    for index = 0, NUM_RAID_ICONS do
        local btn= CreateFrame('Button', 'WoWToolsMakersTargetButton'..index, MakerFrame.target, "SecureActionButtonTemplate WoWToolsButtonTemplate", index)

        table.insert(TargetButtons, 'WoWToolsMakersTargetButton'..index)

        if index==0 then
            btn:SetAllPoints(MakerFrame.target)
            
            btn:SetAttribute('type', 'raidtarget')
            btn:SetAttribute("action", "clear-all")
            btn.texture= btn:CreateTexture()
            btn.texture:SetAtlas('jailerstower-animapowerlist-powerborder-purple')
            btn.texture:SetPoint('CENTER')
            btn.texture:SetSize(16,16)
            function btn:set_alpha()
                self.texture:SetAlpha(self:IsMouseOver() and 1 or 0.5)
            end
            btn:SetScript('OnLeave', function(self)
                self:set_alpha()
                GameTooltip:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                self:set_alpha()
                if not Tooltip_SetOwner() then
                    return
                end
                GameTooltip:SetText(
                    '|A:bags-button-autosort-up:0:0|a'
                    ..(WoWTools_DataMixin.onlyChinese and '单位' or GROUPMANAGER_UNIT_MARKER),
                    EPIC_PURPLE_COLOR:GetRGB()
                )
                GameTooltip:Show()
            end)
            btn:set_alpha()
        else
            table.insert(Buttons, 'WoWToolsMakersTargetButton'..index)

            function btn:set_point()
                local b= _G[TargetButtons[self:GetID()]]
                self:ClearAllPoints()
                if Save().isToUp then
                    self:SetPoint('BOTTOM', b, 'TOP')
                else
                    self:SetPoint('RIGHT', b, 'LEFT')
                end
            end
            btn:set_point()
            btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)

            btn.texture= btn:CreateTexture(nil, 'BACKGROUND')
            btn.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            btn.texture:SetSize(23/2.5, 23/2.5)
            btn.texture:SetPoint('CENTER')

            if CombatLogGetCurrentEventInfo then--12.0没有了
                btn.index=index
                btn:SetScript('OnClick', function(self, d)
                    local u= d=='LeftButton' and 'target' or 'player'
                    if CanBeRaidTarget(u) then
                        if not IsAltKeyDown() then
                            SetRaidTarget(u, self.index)
                        else
                            SetRaidTarget(u, 0)
                        end
                    else
                    end
                end)
            else
                btn:SetAttribute('type', 'raidtarget')
                btn:SetAttribute("marker", index)

                btn:SetAttribute("action1", "set")
                btn:SetAttribute("unit1", 'target')

                btn:SetAttribute("action2", "set")
                btn:SetAttribute("unit2", 'player')

                btn:SetAttribute("alt-action1", "clear")
                btn:SetAttribute("alt-unit1", 'target')

                btn:SetAttribute("alt-action2", "clear")
                btn:SetAttribute("alt-unit2", 'player')
            end


            btn:SetScript('OnLeave', function(self)
                GameTooltip:Hide()
                self:set_Active()
            end)
            btn:SetScript('OnEnter', function(self)
                if not Tooltip_SetOwner() then
                    return
                end

                GameTooltip:SetText(
                    WoWTools_DataMixin.Icon.left
                   ..(WoWTools_DataMixin.onlyChinese and '单位' or GROUPMANAGER_UNIT_MARKER)
                   ..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..self:GetID()..':26|t'
                   ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                   ..WoWTools_DataMixin.Icon.right,
                   TargetColor[self:GetID()]:GetRGB()
                )
                GameTooltip:AddLine(
                    '|A:bags-button-autosort-up:0:0|a'
                    ..'Alt+',
                   TargetColor[self:GetID()]:GetRGB()
                )

                GameTooltip:Show()
                self:SetButtonState('NORMAL')
                self:SetAlpha(1)
            end)
            function btn:set_Active()
                local t= GetRaidTargetIndex('target')
                local check= canaccessvalue(t) and t== self:GetID()
                self:SetButtonState(check and 'PUSHED' or 'NORMAL')
                self.texture:SetShown(check)
                self:SetAlpha(CanBeRaidTarget('target') and 1 or 0.5)
            end
            function btn:set_event()
                self:UnregisterAllEvents()
                if self:IsVisible() then
                    self:RegisterEvent('PLAYER_TARGET_CHANGED')
                    self:set_Active()
                    if Save().isShowHotKey then
                        self:RegisterEvent('UPDATE_BINDINGS')
                    end
                    self:set_hotkey()
                end
            end

--快捷键
            btn.HotKey= btn:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
            btn.HotKey:SetPoint('TOPRIGHT', 1, 2)
            function btn:set_hotkey()
                self.HotKey:SetText(
                    Save().isShowHotKey and
                    WoWTools_KeyMixin:GetHotKeyText(nil, 'RAIDTARGET'..self:GetID())
                    or ''
                )
            end

            btn:SetScript('OnEvent', function(self, event)
                if event=='UPDATE_BINDINGS' then
                    self:set_hotkey()
                else
                    self:set_Active()
                end
            end)
            btn:SetScript('OnShow', function(self)
                self:set_event()
            end)
            btn:SetScript('OnHide', function(self)
                self:set_event()
            end)

            btn:set_event()
        end
   end

















--世界标记
    MakerFrame.marker= CreateFrame("Frame", 'WoWToolsMarkersWorldFrame', MakerFrame)
    MakerFrame.marker:SetSize(23, 23)
    table.insert(Buttons, 'WoWToolsMarkersWorldFrame')

    function MakerFrame.marker:set_point()
        self:ClearAllPoints()
        if Save().isToUp then
            self:SetPoint('RIGHT', MakerFrame.target, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame.target, 'BOTTOM')
        end
    end
    MakerFrame.marker:set_point()

    local markerTab={5,6,3,2,7,1,4,8}
    for index=0, NUM_WORLD_RAID_MARKERS do
        local btn= CreateFrame('Button', 'WoWToolsMakersWorldButton'..index, MakerFrame.marker, "WoWToolsButtonTemplate SecureActionButtonTemplate", index)
        table.insert(MarkerButtons, 'WoWToolsMakersWorldButton'..index)

        if index==0 then--ClearRaidMarker()
            if CombatLogGetCurrentEventInfo then--12.0没有了
                    btn:SetAttribute('type', 'worldmarker')
                    btn:SetAttribute("action", 'clear')
                    btn:SetAttribute('marker', 0)
            else
                local text
                for i=1, NUM_RAID_ICONS do
                    text= (text and text..'\n' or '').. '/cwm '..i
                end
                btn:SetAttribute('type', 'macro')
                btn:SetAttribute('macrotext', text)
            end

            btn:SetAllPoints(MakerFrame.marker)
            btn.texture= btn:CreateTexture()
            btn.texture:SetAtlas('jailerstower-animapowerlist-powerborder-blue')
            btn.texture:SetPoint('CENTER')
            btn.texture:SetSize(16,16)
            function btn:set_alpha()
                self.texture:SetAlpha(self:IsMouseOver() and 1 or 0.5)
            end
            btn:SetScript('OnLeave', function(self)
                self:set_alpha()
                GameTooltip:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                self:set_alpha()
                if not Tooltip_SetOwner() then
                    return
                end
                GameTooltip:SetText(
                    '|A:bags-button-autosort-up:0:0|a'
                    ..(WoWTools_DataMixin.onlyChinese and '地面' or GROUPMANAGER_GROUND_MARKER),
                    ACCOUNT_WIDE_FONT_COLOR:GetRGB()
                )
                GameTooltip:Show()
            end)
            btn:set_alpha()
        else

            function btn:set_point()
                local b= _G[MarkerButtons[self:GetID()]]
                self:ClearAllPoints()
                if Save().isToUp then
                    self:SetPoint('BOTTOM', b, 'TOP')
                else
                    self:SetPoint('RIGHT', b, 'LEFT')
                end
                btn:Show()
            end
            btn:set_point()

            btn.marker= markerTab[index]
            btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)

            btn:SetAttribute('type1', 'worldmarker')
            btn:SetAttribute("action1", "set")

            btn:SetAttribute("type2", "worldmarker")
            btn:SetAttribute("action2", "clear")

            btn:SetAttribute('marker', btn.marker)

            btn:SetScript('OnLeave', function(self)
                self.elapsed=1
                GameTooltip:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                self.elapsed=1
                if not Tooltip_SetOwner() then
                    return
                end
                GameTooltip:SetText(
                    WoWTools_DataMixin.Icon.left
                    ..(WoWTools_DataMixin.onlyChinese and '地面' or GROUPMANAGER_GROUND_MARKER)
                    ..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..self:GetID()..':26|t'
                    ..'|A:bags-button-autosort-up:0:0|a'
                    ..WoWTools_DataMixin.Icon.right,
                    TargetColor[self:GetID()]:GetRGB()
                )
                GameTooltip:Show()
                self:SetAlpha(1)
            end)

            btn.texture=btn:CreateTexture(nil, 'BACKGROUND')
            btn.texture:SetAllPoints()
            btn.texture:SetColorTexture(TargetColor[index]:GetRGB())
            btn.texture:SetAlpha(0.4)

            btn.elapsed= 1.3
            btn:SetScript('OnUpdate', function(self, elapsed)
                self.elapsed= self.elapsed +elapsed
                if self.elapsed>2 then
                    self.elapsed=0
                    self:SetButtonState(IsRaidMarkerActive(self.marker) and 'PUSHED' or 'NORMAL')
                end
            end)
            btn:SetScript('OnMouseUp', function(self)
                self:RegisterEvent('GLOBAL_MOUSE_DOWN')
                self.elapsed=1.3
            end)
            btn:SetScript('OnEvent', function(self, event)
                self:UnregisterEvent(event)
                self.elapsed=1.3
            end)
        end

    end
























--FrameStrata
    function MakerFrame:set_strata()
        if self:CanChangeAttribute() then
            self:SetFrameStrata(Save().strata or 'MEDIUM')
        end
    end
--位置
    function MakerFrame:set_point()
        if self:CanChangeAttribute() then
            self:ClearAllPoints()
            if Save().point then
                self:SetPoint(Save().point[1], UIParent, Save().point[3], Save().point[4], Save().point[5])
            else
                self:SetPoint('CENTER', -150, 50)
            end
        end
    end
--缩放
    function MakerFrame:set_scale()
        if self:CanChangeAttribute() then
            self:SetScale(Save().scale or 1)
        end
    end

    function MakerFrame:set_shown()
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        elseif C_PetBattles.IsInBattle() then
            self:SetShown(false)
            return
        end

        local isAssistant= UnitIsGroupAssistant('player')
        local isLeader= UnitIsGroupLeader('player')
        local isLeaderORAssistant= isAssistant or isLeader--队长(团长)或助理

        local isGroup= IsInGroup()
        local isParty= isGroup and not IsInRaid()
        local isNotPvP= not WoWTools_MapMixin:IsInPvPArea()--and not InCinematic() and not IsInCinematicScene() and not MovieFrame:IsShown()

        local roleValue= C_PartyInfo.GetRestrictPings() or 0
        local ping= C_CVar.GetCVarBool("enablePings")
        if ping and isGroup and roleValue> Enum.RestrictPingsTo.None and not isLeader then
            if roleValue== Enum.RestrictPingsTo.Lead then
                ping= isLeader
            elseif roleValue== Enum.RestrictPingsTo.Assist then
                ping= isLeaderORAssistant
            elseif roleValue== Enum.RestrictPingsTo.TankHealer and not isAssistant then
                local role = UnitGroupRolesAssignedEnum('player')
                ping= role== Enum.LFGRole.Tank or role== Enum.LFGRole.Healer
            end
        end
        self.ping:SetShown(ping)

        local target= (not isGroup or isLeaderORAssistant or isParty) and isNotPvP
        self.target:SetShown(target)--目标标记

        local marker= (isGroup and isNotPvP) and (isParty or isLeaderORAssistant)
        self.marker:SetShown(marker)--世界标记

        local check= isGroup and isLeader
        self.check:SetShown(check)--就绪

        local countdown= isParty or (isGroup and isLeaderORAssistant)
        self.countdown:SetShown(countdown)--倒计时

        local rolepoll= isGroup and isLeaderORAssistant
        self.RolePoll:SetShown(rolepoll)

        self:SetShown(ping or target or marker or check or countdown or rolepoll)
    end

    function MakerFrame:set_event()
        self:UnregisterAllEvents()

        if self:IsShown() then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')--显示/隐藏
            self:RegisterEvent('CVAR_UPDATE')
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_LEFT')
            self:RegisterEvent('GROUP_JOINED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterEvent('PARTY_LEADER_CHANGED')
        end
    end

    MakerFrame:RegisterForDrag("RightButton")
    MakerFrame:SetMovable(true)
    MakerFrame:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then
            self:StartMoving()
            if not self.movingOwnerID then
                self.movingOwnerID= EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", function(owner)
                    self:StopMovingOrSizing()
                    self.movingOwnerID= nil
                    EventRegistry:UnregisterCallback('PLAYER_REGEN_DISABLED', owner)
                end)
            end

        end
    end)
    MakerFrame:SetScript("OnDragStop", function(self)
        ResetCursor()
        if WoWTools_FrameMixin:IsLocked(self) then
            return
        end
        if self.movingOwnerID then
            EventRegistry:UnregisterCallback('PLAYER_REGEN_DISABLED', self.movingOwnerID)
            self.movingOwnerID= nil
        end
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
        end
    end)
    function MakerFrame:set_alpha()
        self.texture:SetAlpha(self:IsMouseOver() and 1 or 0.3)
    end
    MakerFrame:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self) then
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
        self.texture:SetAlpha(0.1)
    end)

    MakerFrame:SetScript('OnMouseUp', function(self)
        ResetCursor()
        self:set_alpha()
    end)
    MakerFrame:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_alpha()
    end)
    MakerFrame:SetScript('OnEnter', function(self)
        self:set_alpha()
        if not Tooltip_SetOwner() then
            return
        end
        GameTooltip:SetText(addName)
        GameTooltip:AddLine(' ')
        local r,g,b
        if InCombatLockdown() then
            r,g,b= DISABLED_FONT_COLOR:GetRGB()
        else
             r,g,b= HIGHLIGHT_FONT_COLOR:GetRGB()
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right, r,g,b, r,g,b)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left, HIGHLIGHT_FONT_COLOR:GetRGB())
        GameTooltip:Show()
    end)

    MakerFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_REGEN_ENABLED' then
            self:UnregisterEvent(event)
            self:set_shown()

        elseif event=='PLAYER_ENTERING_WORLD' then
            self:set_shown()

        elseif event=='CVAR_UPDATE' then
            if arg1=='enablePings' then
                self:set_shown()
            end
        else
            self:set_shown()
        end
    end)

    WoWTools_DataMixin:Hook('MovieFrame_PlayMovie', function()
        MakerFrame:set_shown()
    end)

    WoWTools_DataMixin:Hook('MovieFrame_OnMovieFinished', function()
        MakerFrame:set_shown()
    end)











--背景
    WoWTools_TextureMixin:CreateBG(MakerFrame.ping, {isColor=true})
    MakerFrame.ping.Background:SetPoint('BOTTOMRIGHT', _G[PingButtons[1]])
    MakerFrame.ping.Background:SetPoint('TOPLEFT', _G[PingButtons[#PingButtons]])

    WoWTools_TextureMixin:CreateBG(MakerFrame.target, {isColor=true})
    MakerFrame.target.Background:SetPoint('BOTTOMRIGHT', _G[TargetButtons[2]])
    MakerFrame.target.Background:SetPoint('TOPLEFT', _G[TargetButtons[#TargetButtons]])

    WoWTools_TextureMixin:CreateBG(MakerFrame.marker, {isColor=true})
    MakerFrame.marker.Background:SetPoint('BOTTOMRIGHT', _G[MarkerButtons[2]])
    MakerFrame.marker.Background:SetPoint('TOPLEFT', _G[MarkerButtons[#MarkerButtons]])

    WoWTools_TextureMixin:CreateBG(MakerFrame.countdown, {isAllPoint=true, isColor=true})
    WoWTools_TextureMixin:CreateBG(MakerFrame.check, {isAllPoint=true, isColor=true})
    WoWTools_TextureMixin:CreateBG(MakerFrame.RolePoll, {isAllPoint=true, isColor=true})

    function MakerFrame:set_bg()
        local alpha= Save().bgAlpha or 0.5
        for _, name in pairs(Buttons) do
            if _G[name].Background then
                _G[name].Background:SetColorTexture(0, 0, 0, alpha)
            end
        end
    end


--设置全部，快捷键
    function MakerFrame:set_all_hotkey()
        for _, name in pairs(PingButtons) do
            if _G[name].set_hotkey then
                _G[name]:set_hotkey()
            end
        end
--倒计时
        MakerFrame.countdown:set_hotkey()
--队伍标记
        for _, name in pairs(TargetButtons) do
            if _G[name].set_hotkey then
                _G[name]:set_hotkey()
            end
        end
    end

--位于上方
    function MakerFrame:set_all_point()
        if not self:CanChangeAttribute() then
            return
        end
        for _, name in pairs(Buttons) do
            _G[name]:set_point()
        end
    end



    MakerFrame:set_alpha()
    MakerFrame:set_scale()
    MakerFrame:set_point()
    MakerFrame:set_strata()
    MakerFrame:set_event()
    MakerFrame:set_shown()
    MakerFrame:set_bg()

    Init=function()end
end








local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then
        WoWToolsSave['Other_MarkerFrame']= WoWToolsSave['Other_MarkerFrame'] or {}

        addName= '|A:GM-raidMarker7:0:0|a'..(WoWTools_DataMixin.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET))
        local isEnabled, sub= WoWTools_OtherMixin:AddOption('MarkerFrame', addName)

        WoWTools_PanelMixin:OnlyButton({
        buttonText=WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        SetValue=function()
            StaticPopup_Show('WoWTools_RestData',
                addName,
                nil,
            function()
                WoWToolsSave['Other_MarkerFrame']= nil
            end)
        end,
        tooltip= (WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)
            ..'|n|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI),
        }, sub)

        if isEnabled then
            Init()
        end
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
    end
end)