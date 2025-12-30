local function Save()
    return WoWToolsSave['ChatButton_Markers'] or {}
end

--local MakerFrame
local Name='WoWToolsMakerFrame'

local Buttons={}--_G[Name..Button[1]]
local PingButtons={}
local TargetButtons={}
local MarkerButtons={}

--SecureTemplates.lua

















--设置标记, 框架
local function Init()--设置标记, 框架
    if not Save().markersFrame then
        return
    end

    local MakerFrame= CreateFrame('Frame', 'WoWToolsChatButtonMarkersFrame', UIParent)

    local size= 23

    --移动按钮
    local btn= WoWTools_ButtonMixin:Cbtn(MakerFrame, {name= 'WoWTools_MarkerFrame_Move_Button', size=size, texture='Interface\\Cursor\\UI-Cursor-Move'})
    btn:SetAllPoints(MakerFrame)
    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self:GetParent()) then
            self:GetParent():StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function(frame)
        local self= frame:GetParent()
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().markersFramePoint={self:GetPoint(1)}
            Save().markersFramePoint[2]=nil
        end
    end)
    function btn:set_Alpha(enter)
        self:SetAlpha(enter and 1 or 0.1)
    end
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(self:GetParent()) then
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
        GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, EVENTTRACE_MARKER)))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end
    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_Alpha()
        WoWTools_ChatMixin:GetButtonForName('Markers'):SetButtonState('NORMAL')
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_Alpha(true)
        WoWTools_ChatMixin:GetButtonForName('Markers'):SetButtonState('PUSHED')
    end)












    --Ping System Blizzard_PingUI.lua
    MakerFrame.ping= CreateFrame('Frame', Name..'PingFrame', MakerFrame)
    table.insert(Buttons, 'PingFrame')

    MakerFrame.ping:SetSize(size, size)
    function MakerFrame.ping:set_point()
        if Save().H then
            self:SetPoint("BOTTOM", MakerFrame, 'TOP')
        else
            self:SetPoint('RIGHT', MakerFrame, 'LEFT')
        end
    end
    MakerFrame.ping:set_point()

    MakerFrame.ping.tab={--Enum.PingSubjectType.Warning
        [8]={name=WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO, atlas='Ping_Marker_Icon_NonThreat', action='TOGGLEPINGLISTENER'},
        [7]={name=WoWTools_DataMixin.onlyChinese and '信号' or PING, atlas='Cursor_OpenHand_128', action='TOGGLEPINGLISTENER'},
        [0]={name=WoWTools_DataMixin.onlyChinese and '攻击' or PING_TYPE_ATTACK, atlas='Ping_Marker_Icon_Attack', action='PINGATTACK', text=BINDING_NAME_PINGATTACK},--text='attack'},
        [1]={name=WoWTools_DataMixin.onlyChinese and '警告' or PING_TYPE_WARNING, atlas='Ping_Marker_Icon_Warning', action= 'PINGWARNING', text=BINDING_NAME_PINGWARNING},--text='warning'},

        [3]={name=WoWTools_DataMixin.onlyChinese and '正在赶来' or PING_TYPE_ON_MY_WAY, atlas='Ping_Marker_Icon_OnMyWay', action='PINGONMYWAY', text=BINDING_NAME_PINGONMYWAY},--text='onmyway'},
        [2]={name=WoWTools_DataMixin.onlyChinese and '协助' or PING_TYPE_ASSIST, atlas='Ping_Marker_Icon_Assist', action='PINGASSIST', text=BINDING_NAME_PINGASSIST},-- text='assist'},
        [4]={name=WoWTools_DataMixin.onlyChinese and '威胁' or REPORT_THREAT , atlas='Ping_Marker_Icon_threat'},
        [5]={name=WoWTools_DataMixin.onlyChinese and '看这里' or format(PING_SUBJECT_TYPE_ALERT_NOT_THREAT_POINT,'','',''), atlas='Ping_Marker_Icon_nonthreat'},
    }


    for setIndex, index in pairs({8, 0, 1, 3, 2}) do
        btn= WoWTools_ButtonMixin:Cbtn(MakerFrame.ping, {
            name=Name..'PingButton'..index,
            size=size,
            atlas= MakerFrame.ping.tab[index].atlas,
            isSecure=true,
            setID=setIndex,
        })
        table.insert(PingButtons, 'PingButton'..index)

        if setIndex==1 then
            btn:SetAllPoints(MakerFrame.ping)

        else
            table.insert(Buttons, 'PingButton'..index)

            function btn:set_point()
                local b= _G[Name..PingButtons[self:GetID()-1]]
                if Save().H then
                    self:SetPoint('BOTTOMRIGHT', b, 'TOPRIGHT')
                else
                    self:SetPoint('BOTTOMRIGHT', b, 'BOTTOMLEFT')
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
                local exists= WoWTools_UnitMixin:UnitExists('target')
                if not self.action then
                    local atlas
                    local guid= exists and UnitGUID('target') or WoWTools_DataMixin.Player.GUID
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
            GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            if self.action then
                GameTooltip:AddLine(MicroButtonTooltipText(self.name, self.action), 1,1,1)
                GameTooltip:AddLine(WoWTools_DataMixin.Icon.left..(not UnitExists('target') and '|cff626262' or '')..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS), 1,1,1)
                GameTooltip:AddLine(
                    WoWTools_DataMixin.Icon.right
                    ..WoWTools_DataMixin.Icon.Player
                    ..WoWTools_ColorMixin:SetStringColor(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
                    1,1,1
                )
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
                GameTooltip:AddLine(WoWTools_DataMixin.Icon.left..(not UnitExists('target') and '|cff626262' or '')..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
                            ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or '')
                )

                type= C_Ping.GetContextualPingTypeForUnit(WoWTools_DataMixin.Player.GUID)
                GameTooltip:AddLine(
                    WoWTools_DataMixin.Icon.right
                    ..WoWTools_DataMixin.Icon.Player
                    ..WoWTools_ColorMixin:SetStringColor(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                    ..(
                        (type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or ''
                    )
                )

            end
            GameTooltip:Show()
        end)

--快捷键
        btn.HotKey= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
        btn.HotKey:SetPoint('TOPRIGHT', 1, 2)
        function btn:set_hotkey()
            if self.action then
                self.HotKey:SetText(Save().showMakerFrameHotKey and WoWTools_KeyMixin:GetHotKeyText(nil, self.action) or '')
            end
        end

        btn:set_Event()
    end



--这个是被保护
    hooksecurefunc(PingListenerFrame, 'SetupCooldownTimer', function(self)--冷却，时间
        if MakerFrame.ping:IsShown() then
            local cooldownDuration = (self.cooldownInfo.endTimeMs / 1000) - GetTime()
            for _, name in pairs(PingButtons) do
                WoWTools_CooldownMixin:Setup(_G[Name..name], nil, cooldownDuration, nil, true)
            end
        end
    end)











--倒计时
    MakerFrame.countdown= WoWTools_ButtonMixin:Cbtn(MakerFrame, {
        name=Name..'CountdownButton',
        size=size,
        atlas='countdown-swords'
    })
    table.insert(Buttons, 'CountdownButton')

    function MakerFrame.countdown:set_point()
        local b= _G[Name..PingButtons[#PingButtons]]
        if Save().H then
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
        GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' '..(Save().countdown or 7))
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.Player.IsCN and '取消 取消 取消' or 'STOP STOP STOP'))
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '备注：不要太快了' or (LABEL_NOTE..': '..ERR_GENERIC_THROTTLE), 1,0,0)
        GameTooltip:AddLine(WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS))
        GameTooltip:Show()
    end)
    MakerFrame.countdown:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    function MakerFrame.countdown:set_Event()
        if self:IsShown() then
            self:RegisterEvent('START_TIMER')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.countdown:SetScript('OnShow', function(self)
        self:set_Event()
    end)
    MakerFrame.countdown:SetScript('OnHide', function(self)
        self:set_Event()
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

    MakerFrame.countdown.HotKey= WoWTools_LabelMixin:Create(MakerFrame.countdown, {color={r=1,g=1,b=1}})
    MakerFrame.countdown.HotKey:SetPoint('TOPRIGHT', 1, 2)
    function MakerFrame.countdown:set_hotkey()
        local value
        if Save().showMakerFrameHotKey then
            value= Save().countdown or 7
        end
        self.HotKey:SetText(value or '')
    end
    MakerFrame.countdown:set_hotkey()














--就绪
    MakerFrame.check=WoWTools_ButtonMixin:Cbtn(MakerFrame, {
        name=Name..'CheckButton',
        size=size,
        atlas='common-icon-checkmark'
    })
    table.insert(Buttons, 'CheckButton')

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
        GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(EMOTE127_CMD3)
        GameTooltip:Show()
    end)
    MakerFrame.check:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    function MakerFrame.check:set_Event()
        if self:IsShown() then
            self:RegisterEvent('READY_CHECK')
            self:RegisterEvent('READY_CHECK_FINISHED')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.check:SetScript('OnShow', function(self)
        self:set_Event()
    end)
    MakerFrame.check:SetScript('OnHide', function(self)
        self:set_Event()
    end)
    MakerFrame.check:SetScript('OnEvent', function(self, event, _, arg2)
        WoWTools_CooldownMixin:Setup(self, nil, event=='READY_CHECK_FINISHED' and 0 or arg2 or 0, nil, true, true)--冷却条
    end)
    MakerFrame.check:set_Event()




    MakerFrame.RolePoll=WoWTools_ButtonMixin:Cbtn(MakerFrame, {
        name=Name..'RolePollButton',
        size=size,
        atlas='GM-icon-roles'
    })
    table.insert(Buttons, 'RolePollButton')

    function MakerFrame.RolePoll:set_point()
        if Save().H then
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
        GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '职责选定' or CRF_ROLE_POLL)
        GameTooltip:Show()
    end)
    MakerFrame.RolePoll:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)--RolePollPopup











--队伍标记
    MakerFrame.target= CreateFrame("Frame", Name..'TargetFrame', MakerFrame)
    MakerFrame.target:SetSize(size, size)
    table.insert(Buttons, 'TargetFrame')

    function MakerFrame.target:set_point()
        if Save().H then
            self:SetPoint('RIGHT', MakerFrame, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame, 'BOTTOM')
        end
    end
    MakerFrame.target:set_point()

    function MakerFrame.target:set_Clear_Unit(unit, index)
        local t= GetRaidTargetIndex(unit)
        if canaccessvalue(t) then
            if t and t>0 and (index==t or not index) then
                WoWTools_MarkerMixin:Set_Taget(unit, 0)--设置,目标,标记
            end
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
    for index = 0, NUM_RAID_ICONS do
        btn= CreateFrame('Button', Name..'TargetButton'..index, MakerFrame.target, "SecureActionButtonTemplate WoWToolsButtonTemplate", index)

        table.insert(TargetButtons, 'TargetButton'..index)

        if index==0 then
            btn:SetAllPoints(MakerFrame.target)
            btn:SetNormalAtlas('jailerstower-animapowerlist-powerborder-purple')
            btn:SetAttribute('type', 'raidtarget')
            btn:SetAttribute("action", "clear-all")
            btn.tooltip='|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除全部' or CLEAR_ALL)..WoWTools_DataMixin.Icon.left

        else
            table.insert(Buttons, 'TargetButton'..index)

            function btn:set_point()
                local b= _G[Name..TargetButtons[self:GetID()]]
                if Save().H then
                    self:SetPoint('BOTTOM', b, 'TOP')
                else
                    self:SetPoint('RIGHT', b, 'LEFT')
                end
            end
            btn:set_point()
            btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)

            btn.texture= btn:CreateTexture(nil, 'BACKGROUND')
            btn.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            btn.texture:SetSize(size/2.5, size/2.5)
            btn.texture:SetPoint('CENTER')

            btn:SetAttribute('type1', 'raidtarget')
            btn:SetAttribute('marker1', index)
            btn:SetAttribute("action1", "set")
            btn:SetAttribute("unit1", 'target')

            btn:SetAttribute("type2", "raidtarget")
            btn:SetAttribute("marker2", index)
            btn:SetAttribute("action2", "clear")

            btn:SetAttribute('alt-type1', 'raidtarget')
            btn:SetAttribute('alt-marker1', index)
            btn:SetAttribute("alt-action1", "set")
            btn:SetAttribute("alt-unit1", 'player')

            btn:SetAttribute("alt-type2", "raidtarget")
            btn:SetAttribute("alt-marker2", index)
            btn:SetAttribute("alt-action2", "clear")
            btn:SetAttribute("alt-unit2", 'player')

            btn:SetScript('OnLeave', function(self)
                GameTooltip:Hide()
                self:set_Active()
            end)
            btn:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
                local col= WoWTools_MarkerMixin:GetColor(self:GetID()).col
                GameTooltip:SetText(
                    col
                   ..WoWTools_DataMixin.Icon.left
                   ..(WoWTools_DataMixin.onlyChinese and '目标' or TARGET)
                   ..'|A:bags-button-autosort-up:0:0|a'
                   ..WoWTools_DataMixin.Icon.right
                )
                GameTooltip:AddLine(
                    col
                    ..WoWTools_DataMixin.Icon.left
                    ..'Alt+'
                    ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                    ..'|A:bags-button-autosort-up:0:0|a'
                   ..WoWTools_DataMixin.Icon.right
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
            function btn:set_Events()
                self:UnregisterAllEvents()
                if self:IsShown() then
                    --if CombatLogGetCurrentEventInfo then--12.0出问题
                        self:RegisterEvent('PLAYER_TARGET_CHANGED')
                        self:RegisterEvent('RAID_TARGET_UPDATE')
                        self:set_Active()
                    --end
                    if Save().showMakerFrameHotKey then
                        self:RegisterEvent('UPDATE_BINDINGS')
                    end
                    self:set_hotkey()
                end
            end

--快捷键
            btn.HotKey= WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
            btn.HotKey:SetPoint('TOPRIGHT', 1, 2)
            function btn:set_hotkey()
                self.HotKey:SetText(
                    Save().showMakerFrameHotKey and
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
                self:set_Events()
            end)
            btn:SetScript('OnHide', function(self)
                self:set_Events()
            end)

            btn:set_Events()
        end
   end















    --世界标记
    MakerFrame.marker= CreateFrame("Frame", Name..'MarkerFrame', MakerFrame)
    MakerFrame.marker:SetSize(size, size)
    table.insert(Buttons, 'MarkerFrame')

    function MakerFrame.marker:set_point()
        if Save().H then
            self:SetPoint('RIGHT', MakerFrame.target, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame.target, 'BOTTOM')
        end
    end
    MakerFrame.marker:set_point()

    local markerTab={5,6,3,2,7,1,4,8}
    for index=0, NUM_WORLD_RAID_MARKERS do
        btn= WoWTools_ButtonMixin:Cbtn(MakerFrame.marker, {
            name=Name..'MakerButton'..index,
            isSecure=true,
            size=size,
            atlas= index==0 and 'jailerstower-animapowerlist-powerborder-blue',--'auctionhouse-itemicon-border-orange',
            texture= index~=0 and 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index,
            setID= index
        })

        table.insert(MarkerButtons, 'MakerButton'..index)
        if index==0 then
            btn:SetAllPoints(MakerFrame.marker)
        else
            table.insert(Buttons, 'MakerButton'..index)
            function btn:set_point()
                local b= _G[Name..MarkerButtons[self:GetID()]]
                if Save().H then
                    self:SetPoint('BOTTOM', b, 'TOP')
                else
                    self:SetPoint('RIGHT', b, 'LEFT')
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
        btn:SetScript('OnLeave', function(self)
            GameTooltip:Hide()
            if self.index==0 then
                self:SetAlpha(0.5)
            end
        end)
        btn:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(MakerFrame, "ANCHOR_RIGHT")
            if self.index==0 then
                GameTooltip:SetText('|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除全部' or CLEAR_ALL)..WoWTools_DataMixin.Icon.left)
            else
                local color= WoWTools_MarkerMixin:GetColor(self.index2)
                GameTooltip:SetText(
                    color.col
                    ..WoWTools_DataMixin.Icon.left
                    ..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)
                    ..WoWTools_MarkerMixin:GetIcon(self.index2)
                )

                GameTooltip:AddLine(WoWTools_DataMixin.Icon.right..color.col
                    ..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
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

            local col= WoWTools_MarkerMixin:GetColor(index)
            btn.texture:SetColorTexture(col.r, col.g, col.b)
            btn.texture:SetAlpha(0.3)

            btn:SetScript('OnHide', function(self)
                self.elapsed= nil
            end)

            btn:SetScript('OnUpdate', function(self, elapsed)
                self.elapsed= (self.elapsed or 2) +elapsed
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

    WoWTools_DataMixin:Hook('MovieFrame_PlayMovie', function()
        MakerFrame:set_Shown()
    end)

    WoWTools_DataMixin:Hook('MovieFrame_OnMovieFinished', function()
        MakerFrame:set_Shown()
    end)

    MakerFrame:set_Event()
    MakerFrame:set_Shown()









--背景
    WoWTools_TextureMixin:CreateBG(MakerFrame.ping, {isColor=true})
    MakerFrame.ping.Background:SetPoint('BOTTOMRIGHT', _G[Name..PingButtons[1]])
    MakerFrame.ping.Background:SetPoint('TOPLEFT', _G[Name..PingButtons[#PingButtons]])

    WoWTools_TextureMixin:CreateBG(MakerFrame.target, {isColor=true})
    MakerFrame.target.Background:SetPoint('BOTTOMRIGHT', _G[Name..TargetButtons[2]])
    MakerFrame.target.Background:SetPoint('TOPLEFT', _G[Name..TargetButtons[#TargetButtons]])

    WoWTools_TextureMixin:CreateBG(MakerFrame.marker, {isColor=true})
    MakerFrame.marker.Background:SetPoint('BOTTOMRIGHT', _G[Name..MarkerButtons[2]])
    MakerFrame.marker.Background:SetPoint('TOPLEFT', _G[Name..MarkerButtons[#MarkerButtons]])

    WoWTools_TextureMixin:CreateBG(MakerFrame.countdown, {isAllPoint=true, isColor=true})
    WoWTools_TextureMixin:CreateBG(MakerFrame.check, {isAllPoint=true, isColor=true})
    WoWTools_TextureMixin:CreateBG(MakerFrame.RolePoll, {isAllPoint=true, isColor=true})

    function MakerFrame:set_background()
        local alpha= Save().MakerFrameBgAlpha or 0.5
        for _, name in pairs(Buttons) do
            if _G[Name..name].Background then
                _G[Name..name].Background:SetColorTexture(0, 0, 0, alpha)
            end
        end
    end
    MakerFrame:set_background()






--菜单用

--设置全部，快捷键
    function MakerFrame:set_all_hotkey()
        for _, name in pairs(PingButtons) do
            if _G[Name..name].set_hotkey then
                _G[Name..name]:set_hotkey()
            end
        end
--倒计时
        MakerFrame.countdown:set_hotkey()
--队伍标记
        for _, name in pairs(TargetButtons) do
            if _G[Name..name].set_hotkey then
                _G[Name..name]:set_hotkey()
            end
        end
    end

--位于上方
    function MakerFrame:set_button_point()
        if not self:CanChangeAttribute() then
            return
        end
        for _, name in pairs(Buttons) do
            _G[Name..name]:ClearAllPoints()
            _G[Name..name]:set_point()
        end
    end

    Init=function()
        _G['WoWToolsChatButtonMarkersFrame']:set_Shown()
        _G['WoWToolsChatButtonMarkersFrame']:set_Event()
    end
end

























function WoWTools_MarkerMixin:Init_Markers_Frame()--设置标记, 框架
    Init()
end



--[[
 WoWTools_DataMixin:Hook( PingManager, 'OnPingPinFrameAdded', function(self3, frame, uiTextureKit)
    local ping= self3.activePinFrames[frame]
    if not ping.valueFrame then
        ping.valueFrame=CreateFrame("Frame",nil, ping)
        ping.valueFrame.value=5
        ping.valueFrame.elapsed=1
        ping.valueFrame:SetSize(1,1)
        ping.valueFrame:SetPoint('CENTER')
        ping.valueFrame.text= e.Cstr(ping.valueFrame)
        ping.valueFrame.text:SetPoint('CENTER')
        ping.valueFrame:SetScript('OnUpdate', function(self2, elapsed)
            self2.elapsed = self2.elapsed + elapsed
            self2.value= self2.value - elapsed
            if self2.elapsed>=1 then
                self2.text:SetFormattedText("%i", self2.value)
                self2.elapsed=0
            end
        end)
    else
        ping.valueFrame.value=5
        ping.valueFrame.elapsed=1
    end

    local color= PingColor[uiTextureKit]
    if color then
        ping.valueFrame.text:SetTextColor(color.r, color.g, color.b)
    end
    ping.valueFrame:SetShown(true)
end)
]]