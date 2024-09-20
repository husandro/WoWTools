local e= select(2, ...)
local function Save()
    return WoWTools_MarkersMixin.Save
end













local MakerFrame
--设置标记, 框架
--#############
local function Init()--设置标记, 框架
    if not Save().markersFrame then
        if MakerFrame then
            MakerFrame:set_Shown()
            MakerFrame:set_Event()
        end
        return
    else
        if MakerFrame then
            MakerFrame:set_Shown()
            MakerFrame:set_Event()
            return
        end

    end

    local size, btn= 22, nil

    MakerFrame=CreateFrame('Frame', 'WoWTools_ChatButton_MarkersFrame', UIParent)
    WoWTools_MarkersMixin= MakerFrame
    MakerFrame.Buttons={}










    --移动按钮
    btn= WoWTools_ButtonMixin:Cbtn(MakerFrame, {name= 'WoWTools_MarkerFrame_Move_Button', size={size,size}, texture='Interface\\Cursor\\UI-Cursor-Move'})
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
        elseif not IsModifierKeyDown() and d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(_, root)
                WoWTools_MarkersMixin:Init_MarkerTools_Menu(root)--队伍标记工具, 选项，菜单    
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
        if UnitAffectingCombat('player') then
            self:GetParent():SetScale(Save().markersScale or 1)--缩放
        end
    end
    btn:set_scale()

    function btn:set_tooltip()
        self:GetParent():set_Tooltips_Point()
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, e.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '缩放' or  UI_SCALE), '|cnGREEN_FONT_COLOR:'..(Save().markersScale or 1)..'|r Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU, e.Icon.right)
        e.tips:Show()
    end
    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:set_Alpha()
        WoWTools_MarkersMixin.MarkerButton:state_leave(true)
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_Alpha(true)
        WoWTools_MarkersMixin.MarkerButton:state_enter(nil, true)
    end)
    btn:SetScript('OnMouseWheel', function(self, delta)--缩放
        Save().markersScale= WoWTools_FrameMixin:ScaleFrame(self, delta, Save().markersScale)
    end)












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
        [8]={name= e.onlyChinese and '自动' or SELF_CAST_AUTO, atlas='Ping_Marker_Icon_NonThreat'},
        [7]={name=e.onlyChinese and '信号' or PING, atlas='Cursor_OpenHand_128', action='TOGGLEPINGLISTENER'},
        [0]={name=e.onlyChinese and '攻击' or PING_TYPE_ATTACK, atlas='Ping_Marker_Icon_Attack', action='PINGATTACK', text=BINDING_NAME_PINGATTACK},--text='attack'},
        [1]={name=e.onlyChinese and '警告' or PING_TYPE_WARNING, atlas='Ping_Marker_Icon_Warning', action= 'PINGWARNING', text=BINDING_NAME_PINGWARNING},--text='warning'},

        [3]={name=e.onlyChinese and '正在赶来' or PING_TYPE_ON_MY_WAY, atlas='Ping_Marker_Icon_OnMyWay', action='PINGONMYWAY', text=BINDING_NAME_PINGONMYWAY},--text='onmyway'},
        [2]={name=e.onlyChinese and '协助' or PING_TYPE_ASSIST, atlas='Ping_Marker_Icon_Assist', action='PINGASSIST', text=BINDING_NAME_PINGASSIST},-- text='assist'},
        [4]={name=e.onlyChinese and '威胁' or REPORT_THREAT , atlas='Ping_Marker_Icon_threat'},
        [5]={name=e.onlyChinese and '看这里' or format(PING_SUBJECT_TYPE_ALERT_NOT_THREAT_POINT,'','',''), atlas='Ping_Marker_Icon_nonthreat'},
    }

    MakerFrame.ping.Button={}

    for setIndex, index in pairs({8, 0, 1, 3, 2}) do
        btn= WoWTools_ButtonMixin:Cbtn(MakerFrame.ping, {
            size={size,size},
            atlas= MakerFrame.ping.tab[index].atlas,
            type=true,
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
            if self:IsVisible() then
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
            else
                self:UnregisterEvent('PLAYER_TARGET_CHANGED')
            end
        end

        btn:SetScript('OnShow', btn.set_Event)
        btn:SetScript('OnHide', btn.set_Event)
        btn:set_Event()

        btn:SetScript('OnEvent', function(self)
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
        end)
        btn:SetAlpha(0.5)

        btn:SetScript('OnLeave', function() e.tips:Hide() ResetCursor() end)
        btn:SetScript('OnEnter', function(self)
            self:GetParent():GetParent():set_Tooltips_Point()
            e.tips:ClearLines()
            if self.action then
                e.tips:AddLine(MicroButtonTooltipText(self.name, self.action), 1,1,1)
                e.tips:AddLine(e.Icon.left..(not UnitExists('target') and '|cff9e9e9e' or '')..(e.onlyChinese and '设置' or SETTINGS), 1,1,1)
                e.tips:AddLine(e.Icon.right..e.Icon.player..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME), 1,1,1)
            else
                local find
                local pingTab= self:GetParent().tab
                for _, pingIndex in pairs({7, 0, 1, 3, 2}) do
                    local name= pingTab[pingIndex].name
                    local text= MicroButtonTooltipText(name, pingTab[pingIndex].action)
                    if text and text~=name then
                        e.tips:AddLine('|A:'..pingTab[pingIndex].atlas..':0:0|a'..text, 1,1,1)
                        find=true
                    end
                end
                if find then
                    e.tips:AddLine(' ')
                end
                local guid= UnitExists('target') and UnitGUID('target')
                local type=guid and C_Ping.GetContextualPingTypeForUnit(guid)
                e.tips:AddLine(e.Icon.left..(not UnitExists('target') and '|cff9e9e9e' or '')..(e.onlyChinese and '设置' or SETTINGS)
                            ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or '')
                )

                type= C_Ping.GetContextualPingTypeForUnit(e.Player.guid)
                e.tips:AddLine(e.Icon.right..e.Icon.player..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                            ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or '')
                )

            end
            e.tips:Show()
        end)
    end
    hooksecurefunc(PingListenerFrame, 'SetupCooldownTimer', function(self)--冷却，时间
        if MakerFrame.ping:IsShown() then
            local cooldownDuration = (self.cooldownInfo.endTimeMs / 1000) - GetTime()
            for _, btn2 in pairs(MakerFrame.ping.Button) do
                e.Ccool(btn2, nil, cooldownDuration, nil, true)
            end
        end
    end)
















--倒计时10秒
    MakerFrame.countdown= WoWTools_ButtonMixin:Cbtn(MakerFrame, {size={size,size}, atlas='countdown-swords'})

    table.insert(MakerFrame.Buttons, MakerFrame.countdown)
    function MakerFrame.countdown:set_point()
        local frame= MakerFrame.ping.Button[#MakerFrame.ping.Button]
        if Save().H then
            self:SetPoint('BOTTOM',frame, 'TOP', 0, size)
        else
            self:SetPoint('RIGHT', frame, 'LEFT', -size, 0)
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

        elseif d=='RightButton' and IsControlKeyDown() then--设置时间
            StaticPopupDialogs[id..'ChatButton_Maker_COUNTDOWN']={--区域,设置对话框
                text=id..' '..addName..'|n'..(e.onlyChinese and '就绪' or READY)..'|n|n1 - 3600',
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=true,
                button1= e.onlyChinese and '设置' or SETTINGS,
                button2= e.onlyChinese and '取消' or CANCEL,
                OnShow = function(self2)
                    self2.editBox:SetNumeric(true)
                    self2.editBox:SetNumber(Save().countdown or 7)
                end,
                OnHide=EditBox_ClearFocus,
                OnAccept = function(self2)
                    local num= self2.editBox:GetNumber()
                    Save().countdown=num
                end,
                EditBoxOnTextChanged=function(self2)
                    local num= self2:GetNumber()
                    local parent= self2:GetParent()
                    parent.button1:SetEnabled(num>0 and num<=3600)
                    parent.button1:SetText(WoWTools_TimeMixin:SecondsToClock(num))
                end,
                EditBoxOnEscapePressed = function(self2)
                    self2:GetParent():Hide()
                end,
            }
            StaticPopup_Show(id..'ChatButton_Maker_COUNTDOWN')
        end
    end)
    MakerFrame.countdown:SetScript('OnEnter', function(self)
        self:GetParent():set_Tooltips_Point()
        e.tips:ClearLines()
        e.tips:AddLine(e.Icon.left..(e.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' '..(Save().countdown or 7))
        e.tips:AddLine(e.Icon.right..(e.Player.cn and '取消 取消 取消' or 'STOP STOP STOP'))
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '备注：不要太快了' or (LABEL_NOTE..': '..ERR_GENERIC_THROTTLE), 1,0,0)
        e.tips:AddLine('Ctrl+'..e.Icon.right..(e.onlyChinese and '设置' or SETTINGS))
        e.tips:Show()
    end)
    MakerFrame.countdown:SetScript('OnLeave', GameTooltip_Hide)
    function MakerFrame.countdown:set_Event()
        if self:IsVisible() then
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
            e.Ccool(self, nil, timeRemaining or totalTime, nil, true)--冷却条
        end
    end)
    MakerFrame.countdown:set_Event()

















--检查，按钮
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
        e.tips:ClearLines()
        e.tips:AddLine(EMOTE127_CMD3)
        e.tips:Show()
    end)
    MakerFrame.check:SetScript('OnLeave', GameTooltip_Hide)
    function MakerFrame.check:set_Event()
        if self:IsVisible() then
            self:RegisterEvent('READY_CHECK')
            self:RegisterEvent('READY_CHECK_FINISHED')
        else
            self:UnregisterAllEvents()
        end
    end
    MakerFrame.check:SetScript('OnShow', MakerFrame.check.set_Event)
    MakerFrame.check:SetScript('OnHide', MakerFrame.check.set_Event)
    MakerFrame.check:SetScript('OnEvent', function(self, event, _, arg2)
        e.Ccool(self, nil, event=='READY_CHECK_FINISHED' and 0 or arg2 or 0, nil, true, true)--冷却条
    end)
    MakerFrame.check:set_Event()















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
            WoWTools_MarkersMixin:Set_Taget(unit, 0)--设置,目标,标记
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
                    WoWTools_MarkersMixin.TankHealerFrame:on_click()
                end
            end)
            btn:SetScript('OnLeave', function(self)
                self:SetAlpha(0.5)
                e.tips:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                MakerFrame:set_Tooltips_Point()
                e.tips:ClearLines()
                e.tips:AddLine('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine((e.onlyChinese and '标记' or EVENTTRACE_MARKER), e.Icon.right)
                e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().tank))
                if not IsInRaid() then
                    e.tips:AddLine(e.Icon.HEALER..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().healer))
                else
                    e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save().tank2))
                end
                e.tips:Show()
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
                    WoWTools_MarkersMixin:Set_Taget('target', self.index)--设置,目标, 标记
                elseif d=='RightButton' then
                    WoWTools_MarkersMixin:Set_Taget('player', self.index)--设置,目标, 标记
                end
            end)
            btn:SetScript('OnLeave', function(self)
                e.tips:Hide()
                self:set_Active()
            end)
            btn:SetScript('OnEnter', function(self)
                self:GetParent():GetParent():set_Tooltips_Point()
                e.tips:ClearLines()
                local can= CanBeRaidTarget('target')
                e.tips:AddLine(MicroButtonTooltipText(get_RaidTargetTexture(self.index), 'RAIDTARGET'..self.index))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(
                    e.Icon.left..(e.onlyChinese and '目标' or TARGET),
                    not can and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)
                )
                e.tips:AddLine(e.Icon.right..e.Icon.player..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME))
                e.tips:AddLine(' ')
                e.tips:AddLine(MicroButtonTooltipText('Alt+'..e.Icon.left..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2), 'RAIDTARGETNONE'))

                e.tips:Show()
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
                if self:IsVisible() then
                    self:RegisterEvent('PLAYER_TARGET_CHANGED')
                    self:RegisterEvent('RAID_TARGET_UPDATE')
                    self:set_Active()
                else
                    self:UnregisterAllEvents()
                end
            end

            btn:SetScript('OnEvent', btn.set_Active)
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
            type=true,
            size={size,size},
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
        btn:SetScript('OnLeave', function(self) e.tips:Hide() if self.index==0 then self:SetAlpha(0.5) end  end)
        btn:SetScript('OnEnter', function(self)
            self:GetParent():GetParent():set_Tooltips_Point()
            e.tips:ClearLines()
            if self.index==0 then
                e.tips:AddLine('|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
            else
                e.tips:AddLine(
                    Color[self.index2].col
                    ..e.Icon.left
                    ..(e.onlyChinese and '设置' or SETTINGS)
                    ..get_RaidTargetTexture(self.index2))

                    e.tips:AddLine(e.Icon.right..Color[self.index2].col
                    ..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..'|A:bags-button-autosort-up:0:0|a'
                )
            end
            e.tips:Show()
            self:SetAlpha(1)
        end)
        btn.index= index==0 and 0 or markerTab[index]
        btn.index2= index

        if index~=0 then--背景
            btn:SetPushedAtlas('Forge-ColorSwatchHighlight')
            btn.texture=btn:CreateTexture(nil,'BACKGROUND')
            btn.texture:SetAllPoints(btn)
            btn.texture:SetColorTexture(Color[index].r, Color[index].g, Color[index].b)
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
            self:SetFrameStrata(Save().FrameStrata)
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
        end

        local raid= IsInRaid()
        local isLeader= WoWTools_GroupMixin:isLeader()--队长(团长)或助理
        local isRaid= (raid and isLeader) or not raid
        local isInGroup= IsInGroup()

        local enabled= not WoWTools_MapMixin:IsInPvPArea()
                    and Save().markersFrame
                    --and not InCinematic()
                    --and not IsInCinematicScene()
                    --and not MovieFrame:IsShown()

        local ping= C_CVar.GetCVarBool("enablePings") and Save().markersFrame
        self.ping:SetShown(ping )

        local target= isRaid and enabled
        self.target:SetShown(target)

        local marker= isInGroup and isRaid and enabled
        self.marker:SetShown(marker)

        local check= isLeader and isInGroup and enabled
        self.countdown:SetShown(check)
        self.check:SetShown(check)

        self:SetShown((ping or target or marker or check) and not C_PetBattles.IsInBattle())
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
        else
            self:UnregisterAllEvents()
        end
    end

    function MakerFrame:set_Tooltips_Point()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
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

    function MakerFrame:set_button_point()
        if UnitAffectingCombat('player') then
            return
        end
        for _, frame in pairs(self.Buttons) do
            frame:ClearAllPoints()
            frame:set_point()
        end
    end
end









function WoWTools_MarkersMixin:Init_Markers_Frame()--设置标记, 框架
    Init()
end