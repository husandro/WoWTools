local id, e = ...
local addName
local Save={
        autoSet=true,
        tank= 2,
        tank2= 6,
        healer= 1,

        countdown=7,
        groupReadyTips=true,
        tipsTextSacle=1,

        markersScale=1,
        markersFrame= e.Player.husandro,
        FrameStrata='MEDIUM',
        pingTime= e.Player.husandro,--显示ping冷却时间
        autoReady=0,
      }

local MarkerButton
local SetTankHealerFrame--设置队伍标记
local ReadyTipsButton--队员,就绪,提示信息
local MakerFrame--设置标记, 框架


local Color={
    [1]={r=1, g=1, b=0, col='|cffffff00'},--星星, 黄色
    [2]={r=1, g=0.45, b=0.04, col='|cffff7f3f'},--圆形, 橙色
    [3]={r=1, g=0, b=1, col='|cffa335ee'},--菱形, 紫色
    [4]={r=0, g=1, b=0, col='|cff1eff00'},--三角, 绿色
    [5]={r=0.6, g=0.6, b=0.6, col='|cffffffff'},--月亮, 白色
    [6]={r=0.1, g=0.2, b=1, col='|cff0070dd'},--方块, 蓝色
    [7]={r=1, g=0, b=0, col='|cffff2020'},--十字, 红色
    [8]={r=1, g=1, b=1, col='|cffffffff'},--骷髅,白色
}
--[[

WORLD_MARKER = "世界标记%d";
WORLD_MARKER1 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t |cff0070dd 蓝色|r世界标记"
WORLD_MARKER2 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t |cff1eff00 绿色|r世界标记";
WORLD_MARKER3 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t |cffa335ee 紫色|r世界标记";
WORLD_MARKER4 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t |cffff2020 红色|r世界标记";
WORLD_MARKER5 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t |cffffff00 黄色|r世界标记";
WORLD_MARKER6 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t |cffff7f3f 橙色|r世界标记";
WORLD_MARKER7 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t |cffaaaadd 银色|r世界标记";
WORLD_MARKER8 = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t |cffffffff 白色|r世界标记";
]]

local function get_RaidTargetTexture(index, unit)--取得图片
    if unit then
        index= GetRaidTargetIndex(unit)
    end
    if not index or index<1 or index>NUM_WORLD_RAID_MARKERS then
        return ''
    else
        return '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t'
    end
end

local function Is_Leader()--队长， 或助理
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player')
end

local function in_Raid_Leader()--是不有权限
    local raid =IsInRaid()
    return (raid and Is_Leader()) or not raid
end


local function set_Taget(unit, index)--设置,目标,标记
    if CanBeRaidTarget(unit) and GetRaidTargetIndex(unit)~=index then
        SetRaidTarget(unit, index)
    end
end









--队伍标记工具, 选项，菜单
local function Init_MarkerTools_Menu(root)
--战斗中
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    --[[root:CreateCheckbox('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '图标方向' or  HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION), function()
        return Save.H
    end, function()
        Save.H = not Save.H and true or nil
        if MakerFrame then
            MakerFrame:set_button_point()
        end
    end)]]

    --位于上方
    WoWTools_MenuMixin:ToTop(root, {
        name=nil,
        GetValue=function()
            return Save.H
        end,
        SetValue=function()
            Save.H = not Save.H and true or nil
            if MakerFrame then
                MakerFrame:set_button_point()
            end
        end,
        tooltip=false,
    })


--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
        if MakerFrame then
            return MakerFrame:GetFrameStrata()==data
        else
            return Save.FrameStrata== data
        end
    end, function(data)
        Save.FrameStrata= data
        if MakerFrame then
            MakerFrame:set_frame_strata()
            print(e.addName, addName, MakerFrame:GetFrameStrata())
        end
    end)
    


    WoWTools_MenuMixin:Scale(root, function()
        return Save.markersScale
    end, function(value)
        Save.markersScale= value
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_scale()
        end
    end)

    --[[root:CreateDivider()
    local col= not Save.markersFramePoint and '|cff9e9e9e'
        and (MakerFrame and not MakerFrame:CanChangeAttribute() and '|cnGREEN_FONT_COLOR:')
        or ''
    root:CreateButton(col..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        if MakerFrame and MakerFrame:CanChangeAttribute() then
            MakerFrame:ClearAllPoints()
            Save.markersFramePoint=nil
            MakerFrame:Init_Set_Frame()--位置
            print(e.addName,addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)]]

    --重置位置
    root:CreateDivider()
    WoWTools_MenuMixin:RestPoint(root, Save.markersFramePoint and MakerFrame and MakerFrame:CanChangeAttribute(), function()
        Save.markersFramePoint=nil
        if MakerFrame and MakerFrame:CanChangeAttribute() then
            MakerFrame:ClearAllPoints()
            MakerFrame:Init_Set_Frame()
        end
        print(e.addName,addName, e.onlyChinese and '重置位置' or RESET_POSITION)
    end)
end
















--###########
--设置队伍标记
--###########
local function Init_set_Tank_Healer()
    SetTankHealerFrame=CreateFrame("Frame", nil, MarkerButton)

    SetTankHealerFrame:SetPoint('BOTTOMLEFT',4, 4)
    SetTankHealerFrame:SetSize(12,12)
    SetTankHealerFrame:SetFrameLevel(MarkerButton:GetFrameLevel()+1)

    SetTankHealerFrame.autoSetTexture= SetTankHealerFrame:CreateTexture()
    SetTankHealerFrame.autoSetTexture:SetAtlas('mechagon-projects')
    SetTankHealerFrame.autoSetTexture:SetAllPoints(SetTankHealerFrame)


    function SetTankHealerFrame:check_Enable(set)
        return (Save.autoSet or set) and in_Raid_Leader() and IsInGroup() and not WoWTools_MapMixin:IsInPvPArea()
    end

    function SetTankHealerFrame:set_TankHealer(set)--设置队伍标记
        if not self:check_Enable(set) then
            return
        end
        local tank, healer
        if IsInRaid() then
            local tab={}--设置团队标记
            for index=1, MAX_RAID_MEMBERS do-- GetNumGroupMembers
                --local online, _, role, _, combatRole = select(8, GetRaidRosterInfo(index))
                local name, _, _, _, _, _, _, online, _, role, _, combatRole= GetRaidRosterInfo(index)
                local unit= 'raid'..index
                if (role=='TANK' or combatRole=='TANK') and online then
                    table.insert(tab, {
                        unit=unit,
                        hp=UnitHealthMax(unit)
                    })
                elseif name then
                    local raidIndex= GetRaidTargetIndex(unit)
                    if raidIndex and raidIndex>0 and raidIndex<=8 then
                        set_Taget(unit, 0)
                    end
                end
            end
            table.sort(tab, function(a,b) return a.hp>b.hp end)
            if tab[1] then
                set_Taget(tab[1].unit, Save.tank)--设置,目标,标记
                tank=true
            end
            if tab[2] then
                set_Taget(tab[2].unit, Save.tank2)--设置,目标,标记
                tank=true
            end

        else--设置队伍标记
            for index=1, MAX_PARTY_MEMBERS+1 do
                local unit= index <= MAX_PARTY_MEMBERS and 'party'..index or 'player'
                if UnitExists(unit) and UnitIsConnected(unit) then
                    local role=  UnitGroupRolesAssigned(unit)
                    if role=='TANK' then
                        if not tank then
                            set_Taget(unit, Save.tank)--设置,目标,标记
                            tank=true
                        end
                    elseif role=='HEALER' then
                        if not healer then
                            set_Taget(unit, Save.healer)--设置,目标,标记
                            healer=true
                        end
                    else
                        local raidIndex= GetRaidTargetIndex(unit)
                        if raidIndex and raidIndex>0 and raidIndex<=8 then
                            set_Taget(unit, 0)
                        end
                    end
                end
            end
        end
        return tank or healer
    end



    function SetTankHealerFrame:set_Event()--设置，事件
        if self:check_Enable() then
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_LEFT')
            self:RegisterEvent('GROUP_JOINED')

        else
            self:UnregisterEvent('GROUP_ROSTER_UPDATE')
            self:UnregisterEvent('GROUP_LEFT')
            self:UnregisterEvent('GROUP_JOINED')
        end
    end

    function SetTankHealerFrame:set_Enabel_Event()
        if Save.autoSet then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:set_Event()
        else
            self:UnregisterAllEvents()
        end
        self:SetShown(Save.autoSet and true or false)
    end

    SetTankHealerFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()
        else
            self:set_TankHealer()--设置队伍标记
        end
    end)

    SetTankHealerFrame:set_Enabel_Event()

    function SetTankHealerFrame:on_click()
        if SetTankHealerFrame:set_TankHealer(true) then--设置队伍标记
            print(e.addName, addName, e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '坦克' or TANK, e.onlyChinese and '治疗' or HEALER)
        else
            print(e.addName, addName, e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '坦克' or TANK, e.onlyChinese and '治疗' or HEALER, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
        end
    end
end










--################
--队员,就绪,提示信息
--################
local function Init_Ready_Tips_Button()
    if not Save.groupReadyTips then
        if ReadyTipsButton then
            ReadyTipsButton:set_Event()
            ReadyTipsButton:set_Shown()
        end
        return
    elseif ReadyTipsButton then
        ReadyTipsButton:set_Event()
        ReadyTipsButton:set_Shown()
        return
    end

    ReadyTipsButton= WoWTools_ButtonMixin:Cbtn(nil, {size={22,22}, atlas=e.Icon.select})
    ReadyTipsButton.text=WoWTools_LabelMixin:CreateLabel(ReadyTipsButton)
    ReadyTipsButton.text:SetPoint('BOTTOMLEFT', ReadyTipsButton, 'TOPLEFT')

    ReadyTipsButton:RegisterForDrag("RightButton")--移动
    ReadyTipsButton:SetMovable(true)
    ReadyTipsButton:SetClampedToScreen(true)
    ReadyTipsButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    ReadyTipsButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.groupReadyTipsPoint={self:GetPoint(1)}
        Save.groupReadyTipsPoint[2]=nil
    end)

    ReadyTipsButton:SetScript("OnMouseUp", ResetCursor)--还原光标

    function ReadyTipsButton:set_Scale()
        self.text:SetScale(Save.tipsTextSacle or 1)
    end
    function ReadyTipsButton:set_Point()--设置位置
        if Save.groupReadyTipsPoint then
            self:SetPoint(Save.groupReadyTipsPoint[1], UIParent, Save.groupReadyTipsPoint[3], Save.groupReadyTipsPoint[4], Save.groupReadyTipsPoint[5])
        else
            self:SetPoint('BOTTOMLEFT', MarkerButton, 'TOPLEFT', 0, 20)
        end
    end

    function ReadyTipsButton:set_Shown()--显示/隐藏
        local text= self.text:GetText()
        local show= Save.groupReadyTips and (text and text~='')
        if not show and self.HideTemr then
            self:Cancel()
        end
        self:SetShown(show)
    end
    function ReadyTipsButton:set_Hide()--隐藏
        self.text:SetText("")
        self:set_Shown()
    end

    function ReadyTipsButton:set_Event()--设置，信息
        if Save.groupReadyTips then
            self:RegisterEvent('READY_CHECK_CONFIRM')
            self:RegisterEvent('CHAT_MSG_SYSTEM')
            self:RegisterEvent('READY_CHECK')
        else
           self:UnregisterAllEvents()
        end
    end

    function ReadyTipsButton:get_ReadyCheck_Status(unit, index, uiMapID)--取得，就绪信息
        local stat= GetReadyCheckStatus(unit)
        if stat=='ready' then
            return
        end
        local mapText, mapID WoWTools_MapMixin:GetUnit(unit)--单位, 地图名称
        return (
                    stat== 'waiting' and '|A:QuestTurnin:0:0|a'
                    or (stat== 'notready' and '|A:common-icon-redx:0:0|a')
                    or stat
                    or ''
                )
                ..(index<10 and ' ' or '')..index..')'--编号号
                ..(WoWTools_UnitMixin:GetOnlineInfo(unit) or '')
                ..WoWTools_UnitMixin:GetPlayerInfo(unit, UnitGUID(unit), nil, {reName=true, reRealm=true})
                ..(UnitHasLFGRandomCooldown(unit) and '|cnRED_FONT_COLOR:<'..(e.onlyChinese and '逃亡者' or DESERTER)..'>|r' or '')
                ..(uiMapID~=mapID and mapText or '')--地图名称
                ..' '
    end

    function ReadyTipsButton:get_ReadyCheck_Text()--取得，队伍，所有，就绪信息
        local text
        local isInRaid=IsInRaid()
        local unit=isInRaid and 'raid' or 'party'
        local num= GetNumGroupMembers()
        local uiMapID= C_Map.GetBestMapForUnit('player')
        if isInRaid then
            for index= 1, num do
                local text2= self:get_ReadyCheck_Status(unit..index, index, uiMapID)
                if text2 then
                    text= (text and text..'|n' or '')..text2
                end
            end
        else
            for index= 1, num-1 do
                local text2= self:get_ReadyCheck_Status(unit..index, index, uiMapID)
                if text2 then
                    text= (text and text..'|n' or '')..text2
                end
            end
            local text2= self:get_ReadyCheck_Status('player', num, uiMapID)
            if text2 then
                text= (text and text..'|n' or '')..text2
            end
        end
        return text
    end

    ReadyTipsButton:SetScript('OnEvent', function(self, event, arg1, arg2)
        if event=='CHAT_MSG_SYSTEM' then
            if arg1== READY_CHECK_ALL_READY then--所有人都已准备就绪
                self:set_Hide()
            end
            return
        end

        local text= self:get_ReadyCheck_Text()
        self.text:SetText(text or '')
        self:set_Shown()

        if event=='READY_CHECK' and text then
            e.Ccool(ReadyTipsButton,nil, arg2 or 35, nil, true)
            self.HideTimer=C_Timer.NewTimer(arg2 or 35, function()
                self:set_Hide()
            end)
        end
    end)

    ReadyTipsButton:SetScript('OnDoubleClick', ReadyTipsButton.set_Hide)--隐藏

    ReadyTipsButton:SetScript('OnMouseWheel', function(self, delta)--缩放
        Save.tipsTextSacle= WoWTools_FrameMixin:ScaleFrame(self, delta, Save.tipsTextSacle)--设置Frame缩放
    end)


    function ReadyTipsButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(addName, e.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '隐藏' or HIDE, (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE,'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.tipsTextSacle or 1), 'Alt+'..e.Icon.mid)
        e.tips:Show()
    end
    ReadyTipsButton:SetScript('OnLeave', function()
        e.tips:Hide()
        MarkerButton:SetButtonState('NORMAL')
        MarkerButton:state_leave(true)
    end)
    ReadyTipsButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        MarkerButton:state_enter(nil, true)
    end)

    ReadyTipsButton:SetScript('OnHide', function(self)
        e.Ccool(self, nil, 0)
    end)

    ReadyTipsButton:set_Point()
    ReadyTipsButton:set_Scale()
    ReadyTipsButton:set_Event()
    ReadyTipsButton:set_Shown()


    hooksecurefunc('ShowReadyCheck', function(initiator)--ReadyCheckListenerFrame
        if not initiator then
            return
        end
        local _, difficultyID
        difficultyID = select(3, GetInstanceInfo())
        if ( not difficultyID or difficultyID == 0 ) then
            if UnitInRaid("player") then-- not in an instance, go by current difficulty setting
                difficultyID = GetRaidDifficultyID()
            else
                difficultyID = GetDungeonDifficultyID()
            end
        end
        local difficultyName, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(difficultyID)
        local name= WoWTools_UnitMixin:GetPlayerInfo(nil, nil, initiator, {reName=true})
        name= name~='' and name or initiator
        if ( toggleDifficultyID and toggleDifficultyID > 0 ) then
            -- the current difficulty might change while inside an instance so show the difficulty on the ready check
            difficultyName=  WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID) or difficultyName
            ReadyCheckFrameText:SetFormattedText(
                (e.onlyChinese and "%s正在进行就位确认。\n团队副本难度: |cnGREEN_FONT_COLOR:" or READY_CHECK_MESSAGE..'|n'..RAID_DIFFICULTY..': ')
                ..difficultyName..'|r', name)
        else
            ReadyCheckFrameText:SetFormattedText(e.onlyChinese and '%s正在进行就位确认。' or READY_CHECK_MESSAGE, name)
        end
    end)
end


















































--#############
--设置标记, 框架
--#############
local function Init_Markers_Frame()--设置标记, 框架
    if not Save.markersFrame then
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
        Save.markersFramePoint={frame:GetPoint(1)}
        Save.markersFramePoint[2]=nil
    end)
    function btn:set_Alpha(enter)
        self:SetAlpha(enter and 1 or 0.1)
    end
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif not IsModifierKeyDown() and d=='RightButton' then
            MenuUtil.CreateContextMenu(self, function(_, root)
                Init_MarkerTools_Menu(root)--队伍标记工具, 选项，菜单    
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
        if self:CanChangeAttribute() then
            self:GetParent():SetScale(Save.markersScale or 1)--缩放
        end
    end
    btn:set_scale()

    function btn:set_tooltip()
        self:GetParent():set_Tooltips_Point()
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, e.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '缩放' or  UI_SCALE), '|cnGREEN_FONT_COLOR:'..(Save.markersScale or 1)..'|r Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU, e.Icon.right)
        e.tips:Show()
    end
    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:set_Alpha()
        MarkerButton:state_leave(true)
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_Alpha(true)
        MarkerButton:state_enter(nil, true)
    end)
    btn:SetScript('OnMouseWheel', function(self, delta)--缩放
        Save.markersScale= WoWTools_FrameMixin:ScaleFrame(self, delta, Save.markersScale)
    end)












    --Ping System Blizzard_PingUI.lua
    MakerFrame.ping= CreateFrame('Frame', nil, MakerFrame)
    table.insert(MakerFrame.Buttons, MakerFrame.ping)
    MakerFrame.ping:SetSize(size, size)
    function MakerFrame.ping:set_point()
        if Save.H then
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
                if Save.H then
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
        if Save.H then
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
                C_PartyInfo.DoCountdown(Save.countdown or 7)
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
                    self2.editBox:SetNumber(Save.countdown or 7)
                end,
                OnHide=EditBox_ClearFocus,
                OnAccept = function(self2)
                    local num= self2.editBox:GetNumber()
                    Save.countdown=num
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
        e.tips:AddLine(e.Icon.left..(e.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' '..(Save.countdown or 7))
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
        if Save.H then
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
        if Save.H then
            self:SetPoint('RIGHT', MakerFrame, 'LEFT')
        else
            self:SetPoint('TOP', MakerFrame, 'BOTTOM')
        end
    end
    MakerFrame.target:set_point()

    function MakerFrame.target:set_Clear_Unit(unit, index)
        local t= UnitExists(unit) and GetRaidTargetIndex(unit)
        if t and t>0 and (index==t or not index) then
            set_Taget(unit, 0)--设置,目标,标记
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
                if Save.H then
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
                    SetTankHealerFrame:on_click()
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
                e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save.tank))
                if not IsInRaid() then
                    e.tips:AddLine(e.Icon.HEALER..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save.healer))
                else
                    e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save.tank2))
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
                    set_Taget('target', self.index)--设置,目标, 标记
                elseif d=='RightButton' then
                    set_Taget('player', self.index)--设置,目标, 标记
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
        if Save.H then
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
                if Save.H then
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
            self:SetFrameStrata(Save.FrameStrata)
        end
    end
    MakerFrame:set_frame_strata()

    MakerFrame:SetMovable(true)--移动
    MakerFrame:SetClampedToScreen(true)
    MakerFrame:SetSize(size,size)--大小


    function MakerFrame:Init_Set_Frame()--位置
        if Save.markersFramePoint then
            self:SetPoint(Save.markersFramePoint[1], UIParent, Save.markersFramePoint[3], Save.markersFramePoint[4], Save.markersFramePoint[5])
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
        local isLeader= Is_Leader()
        local isRaid= (raid and isLeader) or not raid
        local isInGroup= IsInGroup()

        local enabled= not WoWTools_MapMixin:IsInPvPArea()
                    and Save.markersFrame
                    --and not InCinematic()
                    --and not IsInCinematicScene()
                    --and not MovieFrame:IsShown()

        local ping= C_CVar.GetCVarBool("enablePings") and Save.markersFrame
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
        if Save.markersFrame then
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






































--#####
--主菜单
--#####
local function Init_Menu(_, root)
    local sub, tre, tab

    sub=root:CreateCheckbox(
        (Save.tank==0 and Save.healer==0 and '|cff9e9e9e' or '')
        ..'|A:mechagon-projects:0:0|a'
        ..((e.onlyChinese and '自动标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, EVENTTRACE_MARKER))
        ..e.Icon.TANK..e.Icon.HEALER
    ), function ()
        return Save.autoSet
    end, function ()
        Save.autoSet= not Save.autoSet and true or nil
        SetTankHealerFrame:set_Enabel_Event()
        if Save.autoSet then
            SetTankHealerFrame:set_TankHealer(true)--设置队伍标记
        end
    end)
    sub:SetGridMode(MenuConstants.VerticalGridDirection, 3)

    tab={
        {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK), type='tank'},
        {text= e.Icon.HEALER..(e.onlyChinese and '治疗' or HEALER), type='healer', tip=e.onlyChinese and '仅限小队' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GROUP)},
        {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK)..'2', type='tank2', tip=e.onlyChinese and '仅限团队' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RAID)},
    }
    for _, info in pairs(tab) do
        tre=sub:CreateButton(info.text, function()
            Save.tank= 2
            Save.tank2= 6
            Save.healer= 1
        end)
        tre:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '重置' or RESET)
        end)
        sub:CreateDivider()

        for i=1, NUM_RAID_ICONS do
            tre=sub:CreateCheckbox(Color[i].col..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..i..':0|t'..e.cn(_G['RAID_TARGET_'..i]), function(data)
                return Save[data.type]==data.index
            end, function(data)
                if Save.tank==data.index or Save.healer==data.index or Save.tank2==data.index then
                    return
                end
                Save[data.type]=data.index
                MarkerButton:set_Texture()--图标

            end, {index=i, type=info.type, tip=info.tip})
            tre:SetTooltip(function(tooltip, data)
                tooltip:AddLine(data.data.tip)
            end)
        end
    end


    root:CreateDivider()

    sub=root:CreateCheckbox(
        (WoWTools_MapMixin:IsInPvPArea() or (MakerFrame and not MakerFrame:CanChangeAttribute()) and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET)
    ), function()
        return MakerFrame and MakerFrame:IsShown()
    end, function()
        Save.markersFrame= not Save.markersFrame and true or nil
        Init_Markers_Frame()--设置标记, 框架
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '世界标记' or SLASH_WORLD_MARKER3:gsub('/',''))
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '需求：队伍和权限' or (NEED..": "..format(COVENANT_RENOWN_TOAST_REWARD_COMBINER, HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, CALENDAR_INVITELIST_SETMODERATOR)))
        if MakerFrame and not MakerFrame:CanChangeAttribute() then
            GameTooltip_AddErrorLine(tooltip, e.onlyChinese and "当前禁用操作" or (REFORGE_CURRENT..': '..DISABLE))
        end
    end)
    Init_MarkerTools_Menu(sub)--队伍标记工具, 选项，菜单


    sub=root:CreateCheckbox(e.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)), function()
        return Save.groupReadyTips
    end, function()
        Save.groupReadyTips= not Save.groupReadyTips and true or nil
        Init_Ready_Tips_Button()--注册事件, 就绪,队员提示信息
        if Save.groupReadyTips then--测试
            ReadyTipsButton.text:SetText('Test')
            ReadyTipsButton:set_Shown()
        end
    end)
    sub:CreateButton(
        (ReadyTipsButton and ReadyTipsButton:IsShown() and '' or '|cff9e9e9e')
        ..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
    ), function()
        if ReadyTipsButton then
            ReadyTipsButton:set_Hide()
        end
    end)
    sub:CreateButton((Save.groupReadyTipsPoint and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save.groupReadyTipsPoint=nil
        if ReadyTipsButton then
            ReadyTipsButton:ClearAllPoints()
            ReadyTipsButton:set_Point()--位置
            print(e.addName, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)

    tab={
        [1]= format('|cff00ff00%s|r|A:common-icon-checkmark:0:0|a', e.onlyChinese and '就绪' or READY),
        [2]= format('|cffff0000%s|r|A:auctionhouse-ui-filter-redx:0:0|a', e.onlyChinese and '未就绪' or NOT_READY_FEMALE),
        [0]= e.onlyChinese and '无' or NONE
    }

    root:CreateDivider()
    for value, text in pairs(tab) do
        sub=root:CreateCheckbox(text, function(data)
                return (data==0 and (Save.autoReady==0 or not Save.autoReady))
                        or Save.autoReady==data
            end, function(data)
                Save.autoReady=data
                MarkerButton.ReadyTextrueTips:settings()--自动就绪, 主图标, 提示
            end, value)
        sub:SetTooltip(function(tooltip, data)
            if data.data==1 or data.data==2 then
                tooltip:AddLine(e.onlyChinese and '自动' or SELF_CAST_AUTO)
            end
        end)
    end

end












































--####
--初始
--####
local function Init()

    --自动就绪, 主图标, 提示
    MarkerButton.ReadyTextrueTips=MarkerButton:CreateTexture(nil,'OVERLAY')
    MarkerButton.ReadyTextrueTips:SetPoint('TOP')
    local size=MarkerButton:GetWidth()/2
    MarkerButton.ReadyTextrueTips:SetSize(size, size)
    function MarkerButton.ReadyTextrueTips:settings()
        if not Save.autoReady or Save.autoReady==0 then
            MarkerButton.ReadyTextrueTips:SetTexture(0)
        else
            MarkerButton.ReadyTextrueTips:SetAtlas(Save.autoReady==1 and e.Icon.select or 'auctionhouse-ui-filter-redx')
        end
    end
    MarkerButton.ReadyTextrueTips:settings()


    Init_Markers_Frame()--设置标记, 框架
    Init_set_Tank_Healer()--设置队伍标记

    function MarkerButton:set_Texture()--图标
        self.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save.tank)
    end
    MarkerButton:set_Texture()--图标

    function MarkerButton:set_Desaturated_Textrue()--主图标,是否有权限
        local raid= IsInRaid()
        local enabled= not WoWTools_MapMixin:IsInPvPArea()
                and (
                        (raid and Is_Leader())
                    or (GetNumGroupMembers()>1 and not raid)
                )
        self.texture:SetDesaturated(not enabled)
    end

    MarkerButton:set_Desaturated_Textrue()--主图标,是否有权限

    MarkerButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    MarkerButton:RegisterEvent('GROUP_ROSTER_UPDATE')
    MarkerButton:RegisterEvent('GROUP_LEFT')
    MarkerButton:RegisterEvent('GROUP_JOINED')
    MarkerButton:SetScript("OnEvent", MarkerButton.set_Desaturated_Textrue)



    Init_Ready_Tips_Button()--注册事件, 就绪,队员提示信息

    MarkerButton:SetScript("OnClick", function(self, d)
        if d=='LeftButton' then
            SetTankHealerFrame:on_click()
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            e.tips:Hide()
        end
    end)

    function MarkerButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(addName, (e.onlyChinese and '标记' or EVENTTRACE_MARKER), e.Icon.left)
        e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save.tank))
        if not IsInRaid() then
            e.tips:AddLine(e.Icon.HEALER..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save.healer))
        else
            e.tips:AddLine(e.Icon.TANK..format('|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t', Save.tank2))
        end
        e.tips:Show()
    end



    MarkerButton:SetScript('OnLeave', function(self)
        if self.groupReadyTips then
            self.groupReadyTips:SetButtonState('NORMAL')
        end
        e.tips:Hide()
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(false)
        end
        self:state_leave()
    end)
    MarkerButton:SetScript('OnEnter', function(self)
        if self.groupReadyTips and self.groupReadyTips:IsShown() then
            self.groupReadyTips:SetButtonState('PUSHED')
        end
        self:set_tooltip()
        self:state_enter(Init_Menu)
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_Alpha(true)
        end
    end)








    local readyFrame=ReadyCheckListenerFrame--自动就绪事件, 提示
    if readyFrame then
        readyFrame:SetScript('OnHide',function ()
            if MarkerButton.autoReadyTime then
                MarkerButton.autoReadyTime:Cancel()
            end
        end)
        readyFrame:SetScript('OnShow',function(self)
            if Save.autoReady and not self.autoReadyText then
                self.autoReadyText=WoWTools_LabelMixin:CreateLabel(self)
                self.autoReadyText:SetPoint('BOTTOM', self, 'TOP')
            end
            if self.autoReadyText then
                local text=''
                if Save.autoReady==1 then
                    text=id..' '..addName
                    ..'|n|cnGREEN_FONT_COLOR:'
                    .. (e.onlyChinese and '自动就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, READY))
                    ..format('|A:%s:0:0|a', e.Icon.select)
                elseif Save.autoReady==2 then
                    text=id..' '..addName..'|n|cnRED_FONT_COLOR:'
                    ..(e.onlyChinese and '自动未就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, NOT_READY_FEMALE))
                    ..'|r'..format('|A:%s:0:0|a', e.Icon.disabled)
                end
               self.autoReadyText:SetText(text)
            end
        end)
    end


end
















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['ChatButton_Markers'] or Save
            addName= '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:0|t|cffffff00'..(e.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET)..'|r'
            MarkerButton= WoWTools_ChatButtonMixin:CreateButton('Markers', addName)

            if MarkerButton then
                Init()

                self:RegisterEvent('READY_CHECK')
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Markers']=Save
        end

    elseif event=='READY_CHECK' then--自动就绪事件
        e.PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        if Save.autoReady or Save.autoReady==0 then
            if arg1 and arg1~=UnitName('player') then
                if self.autoReadyTime then self.autoReadyTime:Cancel() end
                self.autoReadyTime= C_Timer.NewTimer(3, function()
                    if ReadyCheckFrame and ReadyCheckFrame:IsShown() then
                        ConfirmReadyCheck(Save.autoReady==1 and 1 or nil)
                    end
                end)
                e.Ccool(ReadyCheckListenerFrame, nil, 3, nil, true)--冷却条
            end
        else
            e.Ccool(ReadyCheckListenerFrame, nil, arg2 or 35, nil, true, true)--冷却条
        end
    end
end)


--Blizzard_CompactRaidFrameManager.lua