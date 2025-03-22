local e= select(2, ...)
local MakerFrame
local function Save()
    return WoWTools_MarkerMixin.Save
end














--设置标记, 框架
local function Init()--设置标记, 框架
    MakerFrame=CreateFrame('Frame', 'WoWTools_ChatButton_MarkersFrame', UIParent)
    WoWTools_MarkerMixin.MakerFrame= MakerFrame
    MakerFrame.Buttons={}

    local size= 23

    --移动按钮
    local btn= WoWTools_ButtonMixin:Cbtn(MakerFrame, {name= 'WoWTools_MarkerFrame_Move_Button', size={size,size}, texture='Interface\\Cursor\\UI-Cursor-Move'})
    btn:SetAllPoints(MakerFrame)
    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:GetParent():StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        local frame= self:GetParent()
        frame:StopMovingOrSizing()
        Save().markersFramePoint={frame:GetPoint(1)}
        Save().markersFramePoint[2]=nil
    end)
    function btn:set_Alpha(enter)
        self:SetAlpha(enter and 1 or 0.1)
    end
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, function(frame, root)
                WoWTools_MarkerMixin:Init_MarkerTools_Menu(frame, root)--队伍标记工具, 选项，菜单    
            end)
        end
        self:SetAlpha(0.3)
    end)
    btn:set_Alpha()
    btn:SetScript('OnMouseUp', function(self)
        ResetCursor()
        self:set_Alpha(true)
    end)

    function btn:set_scale()
        local frame= self:GetParent()
        if frame:CanChangeAttribute() then
            frame:SetScale(Save().markersScale or 1)--缩放
        end
    end
    btn:set_scale()

    function btn:set_tooltip()
        self:GetParent():set_Tooltips_Point()
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_Mixin.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, EVENTTRACE_MARKER))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        GameTooltip:Show()
    end
    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_Alpha()
        WoWTools_MarkerMixin.MarkerButton:SetButtonState('NORMAL')
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_Alpha(true)
        WoWTools_MarkerMixin.MarkerButton:SetButtonState('PUSHED')
    end)
    --[[btn:SetScript('OnMouseWheel', function(self, delta)--缩放
        Save().markersScale= WoWTools_FrameMixin:ScaleFrame(self, delta, Save().markersScale)
    end)]]












    --Ping System Blizzard_PingUI.lua
    MakerFrame.ping= CreateFrame('Frame', nil, MakerFrame)
    table.insert(MakerFrame.Buttons, MakerFrame.ping)
    MakerFrame.ping:SetSize(size, size)

    function MakerFrame.ping:set_point()
        if Save().H then
            MakerFrame.ping:SetPoint("BOTTOM", MakerFrame, 'TOP')
        else
            MakerFrame.ping:SetPoint('RIGHT', MakerFrame, 'LEFT')
        end
    end
    MakerFrame.ping:set_point()

    MakerFrame.ping.tab={--Enum.PingSubjectType.Warning
        [8]={name= WoWTools_Mixin.onlyChinese and '自动' or SELF_CAST_AUTO, atlas='Ping_Marker_Icon_NonThreat', action='TOGGLEPINGLISTENER'},
        [7]={name=WoWTools_Mixin.onlyChinese and '信号' or PING, atlas='Cursor_OpenHand_128', action='TOGGLEPINGLISTENER'},
        [0]={name=WoWTools_Mixin.onlyChinese and '攻击' or PING_TYPE_ATTACK, atlas='Ping_Marker_Icon_Attack', action='PINGATTACK', text=BINDING_NAME_PINGATTACK},--text='attack'},
        [1]={name=WoWTools_Mixin.onlyChinese and '警告' or PING_TYPE_WARNING, atlas='Ping_Marker_Icon_Warning', action= 'PINGWARNING', text=BINDING_NAME_PINGWARNING},--text='warning'},

        [3]={name=WoWTools_Mixin.onlyChinese and '正在赶来' or PING_TYPE_ON_MY_WAY, atlas='Ping_Marker_Icon_OnMyWay', action='PINGONMYWAY', text=BINDING_NAME_PINGONMYWAY},--text='onmyway'},
        [2]={name=WoWTools_Mixin.onlyChinese and '协助' or PING_TYPE_ASSIST, atlas='Ping_Marker_Icon_Assist', action='PINGASSIST', text=BINDING_NAME_PINGASSIST},-- text='assist'},
        [4]={name=WoWTools_Mixin.onlyChinese and '威胁' or REPORT_THREAT , atlas='Ping_Marker_Icon_threat'},
        [5]={name=WoWTools_Mixin.onlyChinese and '看这里' or format(PING_SUBJECT_TYPE_ALERT_NOT_THREAT_POINT,'','',''), atlas='Ping_Marker_Icon_nonthreat'},
    }

    MakerFrame.ping.Button={}

    for setIndex, index in pairs({8, 0, 1, 3, 2}) do
        btn= WoWTools_ButtonMixin:Cbtn(MakerFrame.ping, {
            size=size,
            atlas= MakerFrame.ping.tab[index].atlas,
            isSecure=true,
            setID=setIndex,
        })

        table.insert(MakerFrame.ping.Button, btn)
        if setIndex==1 then
            btn:SetAllPoints(MakerFrame.ping)
        else
            table.insert(MakerFrame.Buttons, btn)
            function btn:set_point()
                local parent= self:GetParent().Button[self:GetID()-1]
                if Save().H then
                    self:SetPoint('BOTTOMRIGHT', parent, 'TOPRIGHT')
                else
                    self:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMLEFT')
                end
            end
            btn:set_point()
        end

        btn.name= '|A:'..MakerFrame.ping.tab[index].atlas..':0:0|a'..MakerFrame.ping.tab[index].name
        btn.action= MakerFrame.ping.tab[index].action

        btn:SetAttribute('type1', 'macro')
        btn:SetAttribute('type2', 'macro')
        btn:SetAttribute("macrotext1", SLASH_PING1..' [@target]'..(MakerFrame.ping.tab[index].text or ''))
        btn:SetAttribute("macrotext2", SLASH_PING1..' [@player]'..(MakerFrame.ping.tab[index].text or ''))

        function btn:set_Event()
            self:UnregisterAllEvents()
            if self:IsShown() then
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
                if Save().showMakerFrameHotKey then
                    self:RegisterEvent('UPDATE_BINDINGS')
                end
            end
            self:set_hotkey()
        end

        btn:SetScript('OnShow', btn.set_Event)
        btn:SetScript('OnHide', btn.set_Event)

        btn:SetScript('OnEvent', function(self, event)
            if event=='UPDATE_BINDINGS' then
                self:set_hotkey()
            else
                local exists= UnitExists('target')
                if not self.action then
                    local atlas
                    local guid= exists and UnitGUID('target') or e.Player.guid
                    local type=guid and C_Ping.GetContextualPingTypeForUnit(guid)
                    if type then
                        local pingTab=self:GetParent().tab
                        if pingTab[type] then
                            atlas= pingTab[type].atlas
                        end
                    end
                    self:SetNormalTexture(atlas or self.atlas)
                end
                self:SetAlpha(exists and 1 or 0.5)
            end
        end)
        btn:SetAlpha(0.5)

        btn:SetScript('OnLeave', function() GameTooltip:Hide() ResetCursor() end)
        btn:SetScript('OnEnter', function(self)
            self:GetParent():GetParent():set_Tooltips_Point()
            GameTooltip:ClearLines()
            if self.action then
                GameTooltip:AddLine(MicroButtonTooltipText(self.name, self.action), 1,1,1)
                GameTooltip:AddLine(e.Icon.left..(not UnitExists('target') and '|cff9e9e9e' or '')..(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS), 1,1,1)
                GameTooltip:AddLine(e.Icon.right..e.Icon.player..e.Player.col..(WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME), 1,1,1)
            else
                local find
                local pingTab= self:GetParent().tab
                for _, pingIndex in pairs({7, 0, 1, 3, 2}) do
                    local name= pingTab[pingIndex].name
                    local text= MicroButtonTooltipText(name, pingTab[pingIndex].action)
                    if text and text~=name then
                        GameTooltip:AddLine('|A:'..pingTab[pingIndex].atlas..':0:0|a'..text, 1,1,1)
                        find=true
                    end
                end
                if find then
                    GameTooltip:AddLine(' ')
                end
                local guid= UnitExists('target') and UnitGUID('target')
                local type=guid and C_Ping.GetContextualPingTypeForUnit(guid)
                GameTooltip:AddLine(e.Icon.left..(not UnitExists('target') and '|cff9e9e9e' or '')..(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS)
                            ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or '')
                )

                type= C_Ping.GetContextualPingTypeForUnit(e.Player.guid)
                GameTooltip:AddLine(e.Icon.right..e.Icon.player..e.Player.col..(WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                            ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or '')
                )

            end
            GameTooltip:Show()
        end)

--快捷键
        btn.HotKey= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
        btn.HotKey:SetPoint('TOPRIGHT', 1, 2)
        function btn:set_hotkey()
            if self.action then
                self.HotKey:SetText(Save().showMakerFrameHotKey and e.GetHotKeyText(nil, self.action) or '')
            end
        end

        btn:set_Event()
    end

    hooksecurefunc(PingListenerFrame, 'SetupCooldownTimer', function(self)--冷却，时间
        if MakerFrame.ping:IsShown() then
            local cooldownDuration = (self.cooldownInfo.endTimeMs / 1000) - GetTime()
            for _, btn2 in pairs(MakerFrame.ping.Button) do
                WoWTools_CooldownMixin:Setup(btn2, nil, cooldownDuration, nil, true)
            end
        end
    end)
















--倒计时
    MakerFrame.countdown= WoWTools_ButtonMixin:Cbtn(MakerFrame, {size={size,size}, atlas='countdown-swords'})

    table.insert(MakerFrame.Buttons, MakerFrame.countdown)
    function MakerFrame.countdown:set_point()
        local frame= MakerFrame.ping.Button[#MakerFrame.ping.Button]
        if Save().H then
            self:SetPoint('BOTTOM',frame, 'TOP')
        else
            self:SetPoint('RIGHT', frame, 'LEFT')
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
            WoWTools_ChatMixin:Chat(e.Player.cn and '{rt7}取消 取消 取消{rt7}' or '{rt7}STOP STOP STOP{rt7}', nil, nil)
        end
    end)
    MakerFrame.countdown:SetScript('OnEnter', function(self)
        self:GetParent():set_Tooltips_Point()
        GameTooltip:ClearLines()
        GameTooltip:AddLine(e.Icon.left..(WoWTools_Mixin.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' '..(Save().countdown or 7))
        GameTooltip:AddLine(e.Icon.right..(e.Player.cn and '取消 取消 取消' or 'STOP STOP STOP'))
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '备注：不要太快了' or (LABEL_NOTE..': '..ERR_GENERIC_THROTTLE), 1,0,0)
        GameTooltip:AddLine(e.Icon.mid..(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS))
        GameTooltip:Show()
    end)
    MakerFrame.countdown:SetScript('OnLeave', GameTooltip_Hide)
    function MakerFrame.countdown:set_Event()
        if self:IsShown() then
            self:RegisterEvent('START_TIMER')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.countdown:SetScript('OnShow', MakerFrame.countdown.set_Event)
    MakerFrame.countdown:SetScript('OnHide', MakerFrame.countdown.set_Event)
    MakerFrame.countdown:SetScript('OnEvent', function(self, event, timerType, timeRemaining, totalTime)
        if timerType==3 and event=='START_TIMER' then
            if totalTime==0 then
               self.star=nil
               if self.timer then self.timer:Cancel() end
            elseif totalTime>0 then
                if self.timer then self.timer:Cancel() end
                self.timer=C_Timer.NewTimer(timeRemaining or totalTime, function() self.star=nil end)
                self.star=true
            end
            WoWTools_CooldownMixin:Setup(self, nil, timeRemaining or totalTime, nil, true)--冷却条
        end
    end)
    MakerFrame.countdown:set_Event()


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
                name=WoWTools_Mixin.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2,
                minValue=1,
                maxValue=3600,
                step=1,
                tooltip=function(tooltip)
                    tooltip:AddLine(WoWTools_Mixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
                end
            })
            root:CreateSpacer()
        end)
    end)

    MakerFrame.countdown.HotKey= WoWTools_LabelMixin:Create(MakerFrame.countdown, {color={r=1,g=1,b=1}})
    MakerFrame.countdown.HotKey:SetPoint('TOPRIGHT', 1, 2)
    function MakerFrame.countdown:set_hotkey()
        local value= Save().showMakerFrameHotKey and Save().countdown
        self.HotKey:SetText(value and value~=7 and WoWTools_Mixin:MK(value, 0) or '')
    end
    MakerFrame.countdown:set_hotkey()














--就绪
    MakerFrame.check=WoWTools_ButtonMixin:Cbtn(MakerFrame, {size={size,size}, atlas=e.Icon.select})

    table.insert(MakerFrame.Buttons, MakerFrame.check)
    --MakerFrame.check:SetNormalAtlas(e.Icon.select)
    function MakerFrame.check:set_point()
        if Save().H then
            self:SetPoint('BOTTOM', MakerFrame.countdown, 'TOP')
        else
            self:SetPoint('RIGHT', MakerFrame.countdown, 'LEFT')
        end
    end
    MakerFrame.check:set_point()

    MakerFrame.check:SetScript('OnClick', function()
        DoReadyCheck()
    end)
    MakerFrame.check:SetScript('OnEnter', function(self)
        self:GetParent():set_Tooltips_Point()
        GameTooltip:ClearLines()
        GameTooltip:AddLine(EMOTE127_CMD3, WoWTools_Mixin.onlyChinese and '就绪' or READY)
        GameTooltip:Show()
    end)
    MakerFrame.check:SetScript('OnLeave', GameTooltip_Hide)
    function MakerFrame.check:set_Event()
        if self:IsShown() then
            self:RegisterEvent('READY_CHECK')
            self:RegisterEvent('READY_CHECK_FINISHED')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.check:SetScript('OnShow', MakerFrame.check.set_Event)
    MakerFrame.check:SetScript('OnHide', MakerFrame.check.set_Event)
    MakerFrame.check:SetScript('OnEvent', function(self, event, _, arg2)
        WoWTools_CooldownMixin:Setup(self, nil, event=='READY_CHECK_FINISHED' and 0 or arg2 or 0, nil, true, true)--冷却条
    end)
    MakerFrame.check:set_Event()




    MakerFrame.RolePoll=WoWTools_ButtonMixin:Cbtn(MakerFrame, {size={size,size}, atlas='GM-icon-roles'})

    table.insert(MakerFrame.Buttons, MakerFrame.RolePoll)
    function MakerFrame.RolePoll:set_point()
        if Save().H then
            self:SetPoint('BOTTOM', MakerFrame.check, 'TOP')
        else
            self:SetPoint('RIGHT', MakerFrame.check, 'LEFT')
        end
    end
    MakerFrame.RolePoll:set_point()

    MakerFrame.RolePoll:SetScript('OnClick', function()
        InitiateRolePoll();
    end)
    MakerFrame.RolePoll:SetScript('OnEnter', function(self)
        self:GetParent():set_Tooltips_Point()
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '职责选定' or CRF_ROLE_POLL)
        GameTooltip:Show()
    end)
    MakerFrame.RolePoll:SetScript('OnLeave', GameTooltip_Hide)--RolePollPopup











--队伍标记
    MakerFrame.target= CreateFrame("Frame", nil, MakerFrame)
    MakerFrame.target:SetSize(size, size)


    table.insert(MakerFrame.Buttons, MakerFrame.target)
    function MakerFrame.target:set_point()
        if Save().H then
            self:SetPoint('RIGHT', MakerFrame, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame, 'BOTTOM')
        end
    end
    MakerFrame.target:set_point()

    function MakerFrame.target:set_Clear_Unit(unit, index)
        local t= UnitExists(unit) and GetRaidTargetIndex(unit)
        if t and t>0 and (index==t or not index) then
            WoWTools_MarkerMixin:Set_Taget(unit, 0)--设置,目标,标记
        end
    end
    function MakerFrame.target:set_Clear(index)--取消标记标    
        local u--取消怪物标记
        local tab= C_NamePlate.GetNamePlates(issecure()) or {}
        for _, v in pairs(tab) do
            u = v.namePlateUnitToken or v.UnitFrame and v.UnitFrame.unit
            self:set_Clear_Unit(u, index)
        end
        if IsInGroup() then
            u=  IsInRaid() and 'raid' or 'party'--取消队友标记
            for i=1, GetNumGroupMembers() do
                self:set_Clear_Unit(u..i, index)
                self:set_Clear_Unit(u..i..'target', index)
                self:set_Clear_Unit(u..'pet'..i, index)
            end
        end
        u={
            'player', 'target','pet','focus',
            'boss1', 'boss2', 'boss3', 'boss4', 'boss5'
        }
        for _, v in pairs(u) do
            self:set_Clear_Unit(v, index)
        end
    end











--目标，标记
    MakerFrame.target.Button={}
    for index = 0, NUM_RAID_ICONS do
        btn= WoWTools_ButtonMixin:Cbtn(MakerFrame.target, {
            size={size,size},
            atlas= index==0 and 'auctionhouse-itemicon-border-orange' or nil,
            texture= index>0 and 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index or nil,
            setID=index,
        })

        table.insert(MakerFrame.target.Button, btn)
        if index==0 then
            btn:SetAllPoints(MakerFrame.target)
        else
            table.insert(MakerFrame.Buttons, btn)
            function btn:set_point()
                local frame= self:GetParent().Button[self:GetID()]
                if Save().H then
                    self:SetPoint('BOTTOM', frame, 'TOP')
                else
                    self:SetPoint('RIGHT', frame, 'LEFT')
                end
            end
            btn:set_point()
        end

        if index==0 then
            btn:SetScript('OnClick', function(self, d)
                if d=='LeftButton' then
                    self:GetParent():set_Clear()--取消标记标    
                elseif d=='RightButton' then
                    WoWTools_MarkerMixin:Set_TankHealer(true)
                end
            end)
            btn:SetScript('OnLeave', function(self)
                self:SetAlpha(0.5)
                GameTooltip:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                MakerFrame:set_Tooltips_Point()
                GameTooltip:ClearLines()
                GameTooltip:AddLine('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
                GameTooltip:AddDoubleLine((WoWTools_Mixin.onlyChinese and '标记' or EVENTTRACE_MARKER), e.Icon.right)
                GameTooltip:Show()
                self:SetAlpha(1)
            end)
            btn:SetAlpha(0.5)
        else
            btn.index= index
            btn.texture= btn:CreateTexture(nil, 'BACKGROUND')
            btn.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            btn.texture:SetSize(size/2.5, size/2.5)
            btn.texture:SetPoint('CENTER')
            btn:SetScript('OnClick', function(self, d)
                if IsAltKeyDown() then
                    self:GetParent():set_Clear(self.index)--取消标记标    
                elseif d=='LeftButton' then
                    WoWTools_MarkerMixin:Set_Taget('target', self.index)--设置,目标, 标记
                elseif d=='RightButton' then
                    WoWTools_MarkerMixin:Set_Taget('player', self.index)--设置,目标, 标记
                end
            end)
            btn:SetScript('OnLeave', function(self)
                GameTooltip:Hide()
                self:set_Active()
            end)
            btn:SetScript('OnEnter', function(self)
                self:GetParent():GetParent():set_Tooltips_Point()
                GameTooltip:ClearLines()
                local can= CanBeRaidTarget('target')
                GameTooltip:AddLine(MicroButtonTooltipText(WoWTools_MarkerMixin:GetIcon(self.index), 'RAIDTARGET'..self.index))
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(
                    e.Icon.left..(WoWTools_Mixin.onlyChinese and '目标' or TARGET),
                    not can and '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '禁用' or DISABLE)
                )
                GameTooltip:AddLine(e.Icon.right..e.Icon.player..e.Player.col..(WoWTools_Mixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME))
                GameTooltip:AddLine(' ')
                GameTooltip:AddLine(MicroButtonTooltipText('Alt+'..e.Icon.left..(WoWTools_Mixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), 'RAIDTARGETNONE'))

                GameTooltip:Show()
                self:SetButtonState('NORMAL')
                self:SetAlpha(1)
            end)
            function btn:set_Active()
                local check=GetRaidTargetIndex('target')== self.index
                self:SetButtonState(check and 'PUSHED' or 'NORMAL')
                self.texture:SetShown(check)
                self:SetAlpha((not UnitExists('target') or not CanBeRaidTarget('target')) and 0.5 or 1)
            end
            function btn:set_Events()
                self:UnregisterAllEvents()
                if self:IsShown() then
                    self:RegisterEvent('PLAYER_TARGET_CHANGED')
                    self:RegisterEvent('RAID_TARGET_UPDATE')
                    if Save().showMakerFrameHotKey then
                        self:RegisterEvent('UPDATE_BINDINGS')
                    end
                    self:set_Active()
                end
                self:set_hotkey()
            end

--快捷键
            btn.HotKey= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
            btn.HotKey:SetPoint('TOPRIGHT', 1, 2)
            function btn:set_hotkey()
                self.HotKey:SetText(
                    Save().showMakerFrameHotKey and
                    e.GetHotKeyText(nil, 'RAIDTARGET'..self.index)
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
            btn:SetScript('OnShow', btn.set_Events)
            btn:SetScript('OnHide', btn.set_Events)
            btn:set_Events()
        end
    end














    --世界标记
    MakerFrame.marker= CreateFrame("Frame", nil, MakerFrame)
    MakerFrame.marker:SetSize(size, size)



    table.insert(MakerFrame.Buttons, MakerFrame.marker)
    function MakerFrame.marker:set_point()
        if Save().H then
            self:SetPoint('RIGHT', MakerFrame.target, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame.target, 'BOTTOM')
        end
    end
    MakerFrame.marker:set_point()

    MakerFrame.marker.Button={}
    local markerTab={5,6,3,2,7,1,4,8}
    for index=0,  NUM_WORLD_RAID_MARKERS do
        btn= WoWTools_ButtonMixin:Cbtn(MakerFrame.marker, {
            isSecure=true,
            size=size,
            atlas= index==0 and 'auctionhouse-itemicon-border-orange',
            texture= index~=0 and 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index,
            setID= index
        })

        table.insert(MakerFrame.marker.Button, btn)
        if index==0 then

            btn:SetAllPoints(MakerFrame.marker)
        else
            table.insert(MakerFrame.Buttons, btn)
            function btn:set_point()
                local frame= self:GetParent().Button[self:GetID()]
                if Save().H then
                    self:SetPoint('BOTTOM', frame, 'TOP')
                else
                    self:SetPoint('RIGHT', frame, 'LEFT')
                end
                btn:Show()
            end
            btn:set_point()
        end

        btn:SetAttribute('type1', 'worldmarker')
        btn:SetAttribute('marker1', index==0 and 0 or markerTab[index])
        btn:SetAttribute("action1", index==0 and 'clear' or "set")

        btn:SetAttribute("type2", "worldmarker")
        btn:SetAttribute("marker2", index==0 and 0 or markerTab[index])
        btn:SetAttribute("action2", "clear")
        btn:SetScript('OnLeave', function(self) GameTooltip:Hide() if self.index==0 then self:SetAlpha(0.5) end  end)
        btn:SetScript('OnEnter', function(self)
            self:GetParent():GetParent():set_Tooltips_Point()
            GameTooltip:ClearLines()
            if self.index==0 then
                GameTooltip:AddLine('|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
            else
                local color= WoWTools_MarkerMixin:SetColor(self.index2)
                GameTooltip:AddLine(
                    color.col
                    ..e.Icon.left
                    ..(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS)
                    ..WoWTools_MarkerMixin:GetIcon(self.index2))

                    GameTooltip:AddLine(e.Icon.right..color.col
                    ..(WoWTools_Mixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..'|A:bags-button-autosort-up:0:0|a'
                )
            end
            GameTooltip:Show()
            self:SetAlpha(1)
        end)
        btn.index= index==0 and 0 or markerTab[index]
        btn.index2= index

        if index~=0 then--背景
            btn:SetPushedAtlas('Forge-ColorSwatchHighlight')
            btn.texture=btn:CreateTexture(nil,'BACKGROUND')
            btn.texture:SetAllPoints()

            local col= WoWTools_MarkerMixin:SetColor(index)
            btn.texture:SetColorTexture(col.r, col.g, col.b)
            btn.texture:SetAlpha(0.3)

            btn.elapsed=2
            btn:SetScript('OnUpdate', function(self, elapsed)
                self.elapsed= self.elapsed +elapsed
                if self.elapsed>2 then
                    self.elapsed=0
                    self:SetButtonState(IsRaidMarkerActive(self.index) and 'PUSHED' or 'NORMAL')
                end
            end)
        else
            btn:SetAlpha(0.5)
        end
    end














    function MakerFrame:set_frame_strata()
        if self:CanChangeAttribute() then
            self:SetFrameStrata(Save().FrameStrata or 'MEDIUM')
        end
    end
    MakerFrame:set_frame_strata()

    MakerFrame:SetMovable(true)--移动
    MakerFrame:SetClampedToScreen(true)
    MakerFrame:SetSize(size,size)--大小


    function MakerFrame:Init_Set_Frame()--位置
        if Save().markersFramePoint then
            self:SetPoint(Save().markersFramePoint[1], UIParent, Save().markersFramePoint[3], Save().markersFramePoint[4], Save().markersFramePoint[5])
        elseif e.Player.husandro then
            self:SetPoint('BOTTOMRIGHT', _G['MultiBarBottomLeftButton11'], 'TOPRIGHT', 0, 60)
        else
            self:SetPoint('CENTER', -150, 50)
        end
    end
    MakerFrame:Init_Set_Frame()

    function MakerFrame:set_Shown()
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        elseif C_PetBattles.IsInBattle() or not Save().markersFrame then
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

    function MakerFrame:set_Event()
        if Save().markersFrame then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')--显示/隐藏
            self:RegisterEvent('CVAR_UPDATE')
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_LEFT')
            self:RegisterEvent('GROUP_JOINED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterEvent('PARTY_LEADER_CHANGED')
        else
            self:UnregisterAllEvents()
        end
    end

    function MakerFrame:set_Tooltips_Point()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    end

    MakerFrame:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_REGEN_ENABLED' then
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            self:set_Shown()

        elseif event=='PLAYER_ENTERING_WORLD' then
            self:set_Shown()

        elseif event=='CVAR_UPDATE' then
            if arg1=='enablePings' then
                self:set_Shown()
            end
        else
            self:set_Shown()
        end
    end)
    hooksecurefunc('MovieFrame_PlayMovie', function() MakerFrame:set_Shown() end)
    hooksecurefunc('MovieFrame_OnMovieFinished', function() MakerFrame:set_Shown() end)
    MakerFrame:set_Event()
    MakerFrame:set_Shown()









--背景
    WoWTools_TextureMixin:CreateBackground(MakerFrame.ping, {alpha=0.5})
    MakerFrame.ping.Background:SetPoint('BOTTOMRIGHT', MakerFrame.ping.Button[1])
    MakerFrame.ping.Background:SetPoint('TOPLEFT', MakerFrame.ping.Button[#MakerFrame.ping.Button])

    WoWTools_TextureMixin:CreateBackground(MakerFrame.target, {alpha=0.5})
    MakerFrame.target.Background:SetPoint('BOTTOMRIGHT', MakerFrame.target.Button[2])
    MakerFrame.target.Background:SetPoint('TOPLEFT', MakerFrame.target.Button[#MakerFrame.target.Button])

    WoWTools_TextureMixin:CreateBackground(MakerFrame.marker, {alpha=0.5})
    MakerFrame.marker.Background:SetPoint('BOTTOMRIGHT', MakerFrame.marker.Button[2])
    MakerFrame.marker.Background:SetPoint('TOPLEFT', MakerFrame.marker.Button[#MakerFrame.marker.Button])

    WoWTools_TextureMixin:CreateBackground(MakerFrame.countdown, {alpha=0.5, isAllPoint=true})
    WoWTools_TextureMixin:CreateBackground(MakerFrame.check, {alpha=0.5, isAllPoint=true})
    WoWTools_TextureMixin:CreateBackground(MakerFrame.RolePoll, {alpha=0.5, isAllPoint=true})

    function MakerFrame:set_background()
        local show= Save().showMakerFrameBackground
        for _, frame in pairs(self.Buttons) do
            if frame.Background then
                frame.Background:SetShown(show)
            end
        end
    end
    MakerFrame:set_background()






--菜单用

--设置全部，快捷键
    function MakerFrame:set_all_hotkey()
        for _, frame in pairs(self.ping.Button) do
            if frame.set_hotkey then
                frame:set_hotkey()
            end
        end
--倒计时
        MakerFrame.countdown:set_hotkey()
--队伍标记
        for _, frame in pairs(self.target.Button) do
            if frame.set_hotkey then
                frame:set_hotkey()
            end
        end
    end

--位于上方
    function MakerFrame:set_button_point()
        if not self:CanChangeAttribute() then
            return
        end
        for _, frame in pairs(self.Buttons) do
            frame:ClearAllPoints()
            frame:set_point()
        end
    end
end

























function WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    if MakerFrame then
        MakerFrame:set_Shown()
        MakerFrame:set_Event()

    elseif Save().markersFrame then
        do
            Init()
        end
        Init=function()end
    end
end