local id, e = ...
local addName= BINDING_HEADER_RAID_TARGET
local Save={
        autoSet=true,
        tank=2,
        tank2=6,
        healer=1,
        countdown=7,
        groupReadyTips=true,

        markersScale=0.85,
        markersFrame= e.Player.husandro,
        pingTime= e.Player.husandro,--显示ping冷却时间
    }

local button
local panel= CreateFrame("Frame")

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
local PingColor={
    ["Assist"] = {r=0.09, g=0.78, b=0.39, col='|cff17c864'},--协助
    ["Attack"] = {r=1.00, g=0.50, b=0.00, col='|cffff8000' },--攻击
    ["OnMyWay"] = {r=0.16, g=0.64, b=1.00, col='|cff2aa2ff'},--正在赶来
    ["Warning"] = {r=1.00, g=0.13, b=0.08, col='|c3fff2114'},--警告
    ["NonThreat"] = {r=0.16, g=0.64, b=1.00, col='|cff2aa2ff'},--看这里
    ["Threat"] = {r=0.8, g=0, b=0, col='|cffcc0000'},--威胁提示
}

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

local function is_Leader()--队长， 或助理
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player')
end

local function get_All_Set()--是不有权限
    local raid =IsInRaid()
    return (raid and is_Leader()) or not raid
end

local function is_In_PvP_Area()
    return C_PvP.IsArena() or C_PvP.IsBattleground()
end

local function set_Taget(unit, index)--设置,目标,标记
    if CanBeRaidTarget(unit) and GetRaidTargetIndex(unit)~=index then
        SetRaidTarget(unit, index)
    end
end

local function set_Raid_Target()--设置团队标记
    local tab={}--设置团队标记
    for index=1,GetNumGroupMembers() do-- MAX_RAID_MEMBERS do
        local online, _, role, _, combatRole = select(8, GetRaidRosterInfo(index))
        if (role=='TANK' or  combatRole=='TANK') and online then
            table.insert(tab, {
                unit='raid'..index,
                hp=UnitHealthMax('raid'..index)
            })
        end
    end
    local num= #tab
    if num> 0 then
        table.sort(tab, function(a,b) return a.hp<b.hp end)
        set_Taget(tab[1].unit, Save.tank)--设置,目标,标记

        if num>=2 and Save.tank2~=0 then
            set_Taget(tab[2].unit, Save.tank2)--设置,目标,标记
        end
    end
end

local function set_Party_Target()--设置队伍标记
    local tank, healer
    local num=GetNumGroupMembers()--MAX_PARTY_MEMBERS + 1
    for index=1, num do
        local unit = index==num and 'player' or 'party'..index
        local role = UnitGroupRolesAssigned(unit)
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
        end
    end
end

local function setTankHealer(autoSet)--设置队伍标记
    if autoSet and not Save.autoSet then
        return
    end
    local num=GetNumGroupMembers()
    if Save.tank==0 or num<2 then
        if num<2 and not autoSet then
            print(id, addName,e.onlyChinese and '设置' or SETTINGS,
            INLINE_TANK_ICON..(e.onlyChinese and '坦克' or TANK)..get_RaidTargetTexture(Save.tank),
            INLINE_HEALER_ICON..(e.onlyChinese and '治疗' or HEALER)..get_RaidTargetTexture(Save.healer),
                '|cnRED_FONT_COLOR:'..(e.onlyChinese and '队员' or SPELL_TARGET_TYPE4_DESC)..'<2|r')
        end
        return
    end
    if IsInRaid() then
        if not is_Leader() and not autoSet then--没有权限
            print(id, addName,e.onlyChinese and '设置' or SETTINGS,
            INLINE_TANK_ICON..(e.onlyChinese and '坦克' or TANK)..get_RaidTargetTexture(Save.tank),
            INLINE_HEALER_ICON..(e.onlyChinese and '治疗' or HEALER)..get_RaidTargetTexture(Save.healer),
            '|cnRED_FONT_COLOR:'..(e.onlyChinese and '没有权限' or ERR_ARENA_TEAM_PERMISSIONS)..'|r')
        else
            set_Raid_Target()--设置团队标记
        end
    else
        set_Party_Target()--设置队伍标记
    end
end

local function setReadyTexureTips()--自动就绪, 主图标, 提示
    if Save.autoReady and not button.ReadyTextrueTips then
        button.ReadyTextrueTips=button:CreateTexture(nil,'OVERLAY')
        button.ReadyTextrueTips:SetPoint('TOP')
        local size=button:GetWidth()/2
        button.ReadyTextrueTips:SetSize(size, size)
    end
    if button.ReadyTextrueTips then
        if Save.autoReady then
            button.ReadyTextrueTips:SetAtlas(Save.autoReady==1 and e.Icon.select or 'auctionhouse-ui-filter-redx')
        end
        button.ReadyTextrueTips:SetShown(Save.autoReady and true or false)
    end
end



















--################
--队员,就绪,提示信息
--################
local function set_GroupReady_Tips_Event()--注册事件, 就绪,队员提示信息
    if Save.groupReadyTips then
        panel:RegisterEvent('READY_CHECK_CONFIRM')
        panel:RegisterEvent('CHAT_MSG_SYSTEM')
    else
        panel:UnregisterEvent('READY_CHECK_CONFIRM')
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    end
end
local function get_ReadyCheck_Status(unit, index, uiMapID)
    local stat= GetReadyCheckStatus(unit)
    if stat=='ready' then
        return
    end
    local mapText, mapID e.GetUnitMapName(unit)--单位, 地图名称
    return (
                stat== 'waiting' and '|A:QuestTurnin:0:0|a'
                or stat== 'notready' and e.Icon.X2
                or stat
                or ''
            )
            ..(index<10 and ' ' or '')..index..')'--编号号
            ..(e.PlayerOnlineInfo(unit) or '')
            ..e.GetPlayerInfo({guid=UnitGUID(unit), unit=unit, reName=true, reRealm=true})
            ..(UnitHasLFGRandomCooldown(unit) and '|cnRED_FONT_COLOR:<'..(e.onlyChinese and '逃亡者' or DESERTER)..'>|r' or '')
            ..(uiMapID~=mapID and mapText or '')--地图名称
            ..' '
end
local function setGroupReadyTips(event, _, arg2)
    local text=''
    if event=='READY_CHECK' or event=='READY_CHECK_CONFIRM'  then
        local isInRaid=IsInRaid()
        local unit=isInRaid and 'raid' or 'party'
        local num=GetNumGroupMembers()
        local uiMapID= C_Map.GetBestMapForUnit('player')
        if isInRaid then
            for index= 1, num do
                local text2=get_ReadyCheck_Status(unit..index, index, uiMapID)
                if text2 then
                    text= (text~='' and text..'|n' or text)..text2
                end
            end
        else
            for index= 1, num-1 do
                local text2=get_ReadyCheck_Status(unit..index, index, uiMapID)
                if text2 then
                    text= (text~='' and text..'|n' or text)..text2
                end
            end
            local text2=get_ReadyCheck_Status('player', num, uiMapID)
            if text2 then
                text= (text~='' and text..'|n' or text)..text2
            end
        end
        if text~='' and not button.groupReadyTips then
            button.groupReadyTips= e.Cbtn(nil, {icon='hide', size={20,20}})
            if Save.groupReadyTipsPoint then
                button.groupReadyTips:SetPoint(Save.groupReadyTipsPoint[1], UIParent, Save.groupReadyTipsPoint[3], Save.groupReadyTipsPoint[4], Save.groupReadyTipsPoint[5])
            else
                button.groupReadyTips:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', 0, 20)
            end
            button.groupReadyTips:SetScript('OnClick', function(self, d)
                local key=IsModifierKeyDown()
                if d=='LeftButton' and not key then
                    self.text:SetText('')
                    self:SetShown(false)
                elseif d=='RightButton' and not key then

                elseif d=='RightButton' and IsAltKeyDown() then
                    Save.groupReadyTipsPoint=nil
                    self:ClearAllPoints()
                    self:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', 0, 20)
                end
            end)
            button.groupReadyTips:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(addName, e.onlyChinese and '队员就绪信息' or PLAYERS_IN_GROUP..READY..INFO)
                e.tips:AddDoubleLine(e.onlyChinese and '清除全部' or  CLEAR_ALL, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
                e.tips:Show()
                button:SetButtonState('PUSHED')
            end)
            button.groupReadyTips:SetScript('OnLeave', function()
                ResetCursor()
                e.tips:Hide()
                button:SetButtonState('NORMAL')
            end)
            button.groupReadyTips:SetScript("OnMouseUp", function(self, d)
                ResetCursor()
            end)

            button.groupReadyTips:RegisterForDrag("RightButton")
            button.groupReadyTips:SetMovable(true)
            button.groupReadyTips:SetClampedToScreen(true)

            button.groupReadyTips:SetScript("OnDragStart", function(self,d )
                if not IsModifierKeyDown() and d=='RightButton' then
                    self:StartMoving()
                end
            end)
            button.groupReadyTips:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.groupReadyTipsPoint={self:GetPoint(1)}
                Save.groupReadyTipsPoint[2]=nil
                print(id, addName, RESET_POSITION, 'Alt+'..e.Icon.right)
                self:Raise()
            end)
            button.groupReadyTips:SetScript('OnHide', function(self)
                if self.timer then
                    self.timer:Cancel()
                end
            end)
            button.groupReadyTips.text=e.Cstr(button.groupReadyTips)
            button.groupReadyTips.text:SetPoint('BOTTOMLEFT', button.groupReadyTips, 'BOTTOMRIGHT')
        end
        if event=='READY_CHECK' and text~='' then
            if button.groupReadyTips.timer then button.groupReadyTips.timer:Cancel() end
            button.groupReadyTips.timer= C_Timer.NewTimer(arg2 or 35, function()
                button.groupReadyTips.text:SetText('')
                button.groupReadyTips:SetShown(false)
            end)
            e.Ccool(button.groupReadyTips,nil, arg2 or 35, nil,nil,true )
        end
    end
    if button.groupReadyTips then
        button.groupReadyTips:SetShown(text~='')
        button.groupReadyTips.text:SetText(text)
    end
end












--#############
--设置,按钮,图片
--#############
local function setTexture()--图标, 自动标记
    if Save.tank==0 then
        button.texture:SetTexture(0)
    else
        button.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save.tank)
    end
    if Save.autoSet and not button.autoSetTips then
        button.autoSetTips= button:CreateTexture(nil,'OVERLAY')
        button.autoSetTips:SetPoint('BOTTOMLEFT',4, 4)
        button.autoSetTips:SetSize(12,12)
        button.autoSetTips:SetAtlas('Warfronts-BaseMapIcons-Alliance-Workshop-Minimap')
        --button.autoSetTips:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
    end
    if button.autoSetTips then
        button.autoSetTips:SetShown(Save.autoSet)
    end
end
local function setAllTextrue()--主图标,是否有权限
    button.texture:SetDesaturated(GetNumGroupMembers() <2  or not get_All_Set())
end

















--#############
--设置标记, 框架
--#############
local Frame
local function Init_Markers_Frame()--设置标记, 框架
    if not Save.markersFrame then
        if Frame then
            Frame:set_Shown()
            Frame:set_Event()
        end
        return
    else
        if Frame then
            Frame:set_Shown()
            Frame:set_Event()
            return
        end

    end

    local size, last, btn= 16, nil, nil

    Frame=CreateFrame('Frame')
    Frame:Raise()
    Frame:SetMovable(true)--移动
    Frame:SetClampedToScreen(true)

    Frame:SetSize(size,size)--大小
    Frame:SetScale(Save.markersScale or 1)--缩放

    function Frame:Init_Set_Frame()--位置
        if Save.markersFramePoint then
            Frame:SetPoint(Save.markersFramePoint[1], UIParent, Save.markersFramePoint[3], Save.markersFramePoint[4], Save.markersFramePoint[5])
        elseif e.Player.husandro then
            Frame:SetPoint('BOTTOMRIGHT', _G['MultiBarBottomLeftButton11'], 'TOPRIGHT', 0, 40)
        else
            Frame:SetPoint('CENTER', -150, 50)
        end
    end
    Frame:Init_Set_Frame()

    function Frame:set_Shown()
        if UnitAffectingCombat('player') then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else

            local ping= C_CVar.GetCVarBool("enablePings") and true or false
            self.ping:SetShown(ping)

            local target= get_All_Set()--是不有权限
            self.target:SetShown(target)

            local marker= IsInGroup() and is_Leader()
            self.marker:SetShown(marker)

            self:SetShown(Save.markersFrame
                        and not is_In_PvP_Area()
                        and (ping or target or marker)
                    )

            local isLeader=GetNumGroupMembers()>1 and (IsInRaid() and is_Leader()) or UnitIsGroupLeader('player')
            self.countdown:SetShown(isLeader)
            self.check:SetShown(isLeader)
        end
    end
    function Frame:set_Event()
        if Save.markersFrame then
            Frame:RegisterEvent('PLAYER_ENTERING_WORLD')--显示/隐藏
            Frame:RegisterEvent('CVAR_UPDATE')
            Frame:RegisterEvent('GROUP_ROSTER_UPDATE')
            Frame:RegisterEvent('GROUP_LEFT')
            Frame:RegisterEvent('GROUP_JOINED')
        else
            Frame:UnregisterAllEvents()
        end
    end
    Frame:SetScript('OnEvent', function(self, event, arg1)
        if event=='PLAYER_REGEN_ENABLED' then
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
            self:set_Shown()

        elseif event=='PLAYER_ENTERING_WORLD' then
            self:set_Shown()

        elseif event=='CVAR_UPDATE' then
            if arg1=='enablePings' then
                self:set_Shown()
            end
        elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' or event=='GROUP_JOINED' then
            self:set_Shown()
        end
    end)
    Frame:set_Event()



    btn= e.Cbtn(Frame, {size={size,size}, texture='Interface\\Cursor\\UI-Cursor-Move'})--移动按钮
    btn:SetAllPoints(Frame)
    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
    btn:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            Frame:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function()
        ResetCursor()
        Frame:StopMovingOrSizing()
        Save.markersFramePoint={Frame:GetPoint(1)}
        Save.markersFramePoint[2]=nil
    end)
    function btn:set_Alpha(enter)
        self:SetAlpha(enter and 1 or 0.1)
    end
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and IsControlKeyDown() then
            Save.H = not Save.H and true or nil
            print(id,addName,
                e.onlyChinese and '图标方向' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION..(Save.H and e.Icon.up2 or e.Icon.toLeft2),
                e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
        end
        self:SetAlpha(0.3)
    end)
    btn:set_Alpha()
    btn:SetScript('OnMouseUp', function(self) ResetCursor() self:set_Alpha(true) end)
    btn:SetScript('OnLeave', function(self) e.tips:Hide() self:set_Alpha() end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'alt+'..e.Icon.right)
        e.tips:AddDoubleLine((UnitAffectingCombat('player') and '|cff606060' or '')..(e.onlyChinese and '缩放' or  UI_SCALE), (Save.markersScale or 1)..' Alt+'..e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '图标方向' or  HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION)..(Save.H and e.Icon.toLeft2 or e.Icon.up2), 'Ctrl+'..e.Icon.right)
        e.tips:Show()
        self:set_Alpha(true)
    end)
    btn:SetScript('OnMouseWheel', function(_, d)--缩放
        if UnitAffectingCombat('player') then
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            return
        end
        if IsAltKeyDown() then
            local sacle= Save.markersScale or 1
            if d==1 then
                sacle=sacle+0.05
            elseif d==-1 then
                sacle=sacle-0.05
            end
            if sacle>3 then
                sacle=3
            elseif sacle<0.6 then
                sacle=0.6
            end
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..sacle)
            Frame:SetScale(sacle)
            Save.markersScale=sacle
        end
    end)


    


    --Ping System Blizzard_PingUI.lua
    Frame.ping= CreateFrame('Frame', nil, Frame)
    Frame.ping:SetSize(size, size)
    if Save.H then
        Frame.ping:SetPoint("BOTTOM", Frame, 'TOP')
    else
        Frame.ping:SetPoint('RIGHT', Frame, 'LEFT')
    end

    Frame.ping.tab={--Enum.PingSubjectType.Warning
        [8]={name= e.onlyChinese and '自动' or SELF_CAST_AUTO, atlas='Ping_Marker_Icon_NonThreat'},

        [7]={name=e.onlyChinese and '信号' or PING, atlas='Cursor_OpenHand_128', action='TOGGLEPINGLISTENER'},
        [0]={name=e.onlyChinese and '攻击' or PING_TYPE_ATTACK, atlas='Ping_Marker_Icon_Attack', action='PINGATTACK', text=BINDING_NAME_PINGATTACK},--text='attack'},
        [1]={name=e.onlyChinese and '警告' or PING_TYPE_WARNING, atlas='Ping_Marker_Icon_Warning', action= 'PINGWARNING', text=BINDING_NAME_PINGWARNING},--text='warning'},
        [3]={name=e.onlyChinese and '正在赶来' or PING_TYPE_ON_MY_WAY, atlas='Ping_Marker_Icon_OnMyWay', action='PINGONMYWAY', text=BINDING_NAME_PINGONMYWAY},--text='onmyway'},
        [2]={name=e.onlyChinese and '协助' or PING_TYPE_ASSIST, atlas='Ping_Marker_Icon_Assist', action='PINGASSIST', text=BINDING_NAME_PINGASSIST},-- text='assist'},

        [4]={name=e.onlyChinese and '威胁' or REPORT_THREAT , atlas='Ping_Marker_Icon_threat'},
        [5]={name=e.onlyChinese and '看这里' or format(PING_SUBJECT_TYPE_ALERT_NOT_THREAT_POINT,'','',''), atlas='Ping_Marker_Icon_nonthreat'},
    }

    Frame.ping.Button={}
    
    for _, index in pairs({8, 0, 1, 3, 2}) do
        btn= e.Cbtn(Frame.ping, {
            size={size,size},
            atlas= Frame.ping.tab[index].atlas,
            type=true,
        })
        if not last then
            btn:SetPoint('CENTER')
        else
            if Save.H then
                btn:SetPoint('BOTTOMRIGHT', last or Frame.ping, 'TOPRIGHT')
            else
                btn:SetPoint('BOTTOMRIGHT', last or Frame.ping, 'BOTTOMLEFT')
            end
        end

        btn.name= '|A:'..Frame.ping.tab[index].atlas..':0:0|a'..Frame.ping.tab[index].name
        btn.action= Frame.ping.tab[index].action

        btn:SetAttribute('type1', 'macro')
        btn:SetAttribute('type2', 'macro')
        btn:SetAttribute("macrotext1", SLASH_PING1..' [@target]'..(Frame.ping.tab[index].text or ''))
        btn:SetAttribute("macrotext2", SLASH_PING1..' [@player]'..(Frame.ping.tab[index].text or ''))

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
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            if self.action then
                local key1= GetBindingKey(self.action)
                e.tips:AddDoubleLine(self.name, (key1 and key1~='') and '|cnGREEN_FONT_COLOR:'..key1..'|r' or nil)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine((not UnitExists('target') and '|cff606060' or '')..(e.onlyChinese and '目标' or TARGET), e.Icon.left)
                e.tips:AddDoubleLine(e.Icon.player..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME), e.Icon.right)
            else
                local find
                local pingTab= self:GetParent().tab
                for _, pingIndex in pairs({7, 0, 1, 3, 2}) do
                    local key1= GetBindingKey(pingTab[pingIndex].action)
                    if key1 and key1~='' then
                        e.tips:AddDoubleLine('|A:'..pingTab[pingIndex].atlas..':0:0|a'..pingTab[pingIndex].name, '|cnGREEN_FONT_COLOR:'..key1..'|r')
                        find=true
                    end
                end
                if find then
                    e.tips:AddLine(' ')
                end
                local guid= UnitExists('target') and UnitGUID('target')
                local type=guid and C_Ping.GetContextualPingTypeForUnit(guid)
                e.tips:AddDoubleLine((not UnitExists('target') and '|cff606060' or '')..(e.onlyChinese and '目标' or TARGET)
                                    ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or ''),
                                    e.Icon.left)

                                    type= C_Ping.GetContextualPingTypeForUnit(e.Player.guid)
                e.tips:AddDoubleLine(e.Icon.player..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                                    ..((type and pingTab[type]) and '|A:'..pingTab[type].atlas..':0:0|a'..pingTab[type].name or ''),
                                        e.Icon.right)

            end
            e.tips:Show()
        end)
        table.insert(Frame.ping.Button, btn)
        last=btn
    end
    hooksecurefunc(PingListenerFrame, 'SetupCooldownTimer', function(self)--冷却，时间
        if Frame.ping:IsShown() then
            local cooldownDuration = (self.cooldownInfo.endTimeMs / 1000) - GetTime()
            for _, btn2 in pairs(Frame.ping.Button) do
                e.Ccool(btn2, nil, cooldownDuration, nil, true)
            end
        end
    end)



    Frame.check=e.Cbtn(Frame, {size={size,size}, atlas=e.Icon.select})
    Frame.check:SetNormalAtlas(e.Icon.select)
    if Save.H then
        Frame.check:SetPoint('BOTTOM', last, 'TOP', 0, size)
    else
        Frame.check:SetPoint('RIGHT', last, 'LEFT', -size, 0)
    end
    Frame.check:SetScript('OnMouseDown', function()
        DoReadyCheck()
    end)
    Frame.check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(EMOTE127_CMD3)
        e.tips:Show()
    end)
    Frame.check:SetScript('OnLeave', function() e.tips:Hide() end)
    function Frame.check:set_Event()
        if self:IsVisible() then
            self:RegisterEvent('READY_CHECK')
            self:RegisterEvent('READY_CHECK_FINISHED')
        else
            self:UnregisterAllEvents()
        end
    end
    Frame.check:SetScript('OnShow', Frame.check.set_Event)
    Frame.check:SetScript('OnHide', Frame.check.set_Event)
    Frame.check:SetScript('OnEvent', function(self, event, _, arg2)
        e.Ccool(self, nil, event=='READY_CHECK_FINISHED' and 0 or arg2 or 0, nil, true, true)--冷却条
    end)
    Frame.check:set_Event()


    Frame.countdown= e.Cbtn(Frame, {size={size,size}, atlas='countdown-swords'})--倒计时10秒
    if Save.H then
        Frame.countdown:SetPoint('BOTTOM', Frame.check, 'TOP')
    else
        Frame.countdown:SetPoint('RIGHT', Frame.check, 'LEFT')
    end
    Frame.countdown:SetScript('OnClick', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            if not self.star then
                C_PartyInfo.DoCountdown(Save.countdown or 7)
            end
        elseif d=='RightButton' and not key then
            if self.star then
                C_PartyInfo.DoCountdown(0)
            end
            e.Chat(e.Player.cn and '{rt7}取消 取消 取消{rt7}' or '{rt7}STOP STOP STOP{rt7}')

        elseif d=='RightButton' and IsControlKeyDown() then--设置时间
            StaticPopupDialogs[id..addName..'COUNTDOWN']={--区域,设置对话框
                text=id..' '..addName..'|n'..(e.onlyChinese and '就绪' or READY)..'|n|n1 - 3600',
                whileDead=true, hideOnEscape=true, exclusive=true,
                hasEditBox=true,
                button1= e.onlyChinese and '设置' or SETTINGS,
                button2= e.onlyChinese and '取消' or CANCEL,
                OnShow = function(self2)
                    self2.editBox:SetNumeric(true)
                    self2.editBox:SetNumber(Save.countdown or 7)
                end,
                OnAccept = function(self2)
                    local num= self2.editBox:GetNumber()
                    Save.countdown=num
                end,
                EditBoxOnTextChanged=function(self2)
                    local num= self2:GetNumber()
                    local parent= self2:GetParent()
                    parent.button1:SetEnabled(num>0 and num<=3600)
                    parent.button1:SetText(e.SecondsToClock(num))
                end,
                EditBoxOnEscapePressed = function(self2)
                    self2:GetParent():Hide()
                end,
            }
            StaticPopup_Show(id..addName..'COUNTDOWN')
        end
    end)
    Frame.countdown:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.Icon.left..(e.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' '..(Save.countdown or 7))
        e.tips:AddLine(e.Icon.right..(e.Player.cn and '取消 取消 取消' or 'STOP STOP STOP'))
        e.tips:AddLine(' ')
        e.tips:AddLine(e.onlyChinese and '备注：不要太快了' or ('note:' ..ERR_GENERIC_THROTTLE), 1,0,0)
        e.tips:AddLine('Ctrl+'..e.Icon.right..(e.onlyChinese and '设置' or SETTINGS))
        e.tips:Show()
    end)
    Frame.countdown:SetScript('OnLeave', function() e.tips:Hide() end)
    function Frame.countdown:set_Event()
        if self:IsVisible() then
            self:RegisterEvent('START_TIMER')
        else
            self:UnregisterAllEvents()
        end
    end
    Frame.countdown:SetScript('OnShow', Frame.countdown.set_Event)
    Frame.countdown:SetScript('OnHide', Frame.countdown.set_Event)
    Frame.countdown:SetScript('OnEvent', function(self, event, timerType, timeRemaining, totalTime)
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
    Frame.countdown:set_Event()




    --队伍标记
    Frame.target= CreateFrame("Frame", nil, Frame)
    Frame.target:SetSize(size, size)
    if Save.H then
        Frame.target:SetPoint('RIGHT', Frame, 'LEFT')
    else
        Frame.target:SetPoint('TOP', Frame, 'BOTTOM')
    end

    function Frame.target:set_Clear_Unit(unit, index)
        local t= UnitExists(unit) and GetRaidTargetIndex(unit)
        if t and t>0 and (index==t or not index) then
            set_Taget(unit, 0)--设置,目标,标记
        end
    end
    function Frame.target:set_Clear(index)--取消标记标    
        local u--取消怪物标记
        local tab= C_NamePlate.GetNamePlates() or {}
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

    last=nil
    for index = 0, NUM_RAID_ICONS do
        btn= e.Cbtn(Frame.target, {
            size={size,size},
            atlas= index==0 and 'auctionhouse-itemicon-border-orange' or nil,
            texture= index>0 and 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index or nil,
        })
        if not last then
            btn:SetPoint('CENTER')
        else
            if Save.H then
                btn:SetPoint('BOTTOM', last, 'TOP')
            else
                btn:SetPoint('RIGHT', last, 'LEFT')
            end
        end
        if index==0 then
            btn:SetScript('OnClick', function()
                Frame.target:set_Clear()--取消标记标
            end)
            btn:SetScript('OnLeave', function(self)
                self:SetAlpha(0.5)
                e.tips:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.Icon.O2..(e.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
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
                if d=='LeftButton' and IsAltKeyDown() then
                    Frame.target:set_Clear(self.index)--取消标记标    
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
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                local key1= GetBindingKey('RAIDTARGET'..self.index)
                local key2= GetBindingKey('RAIDTARGETNONE')
                local can= CanBeRaidTarget('target')
                e.tips:AddDoubleLine(get_RaidTargetTexture(self.index)..(can and Color[self.index].col or '|cff606060')
                                    ..(e.onlyChinese and '目标' or TARGET)..e.Icon.left
                                    ..(not can and ' '..(e.onlyChinese and '禁用' or DISABLE) or ''),
                                    key1 or nil)
                e.tips:AddLine(e.Icon.player..e.Player.col..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)..e.Icon.right)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine('|A:bags-button-autosort-up:0:0|a'..Color[self.index].col..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..' Alt+'..e.Icon.right, key2 or nil)
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

        last=btn
    end


    --世界标记
    Frame.marker= CreateFrame("Frame", nil, Frame)
    Frame.marker:SetSize(size, size)
    if Save.H then
        Frame.marker:SetPoint('RIGHT', Frame.target, 'LEFT')
    else
        Frame.marker:SetPoint('TOP', Frame.target, 'BOTTOM')
    end

    last=nil
    local markerTab={5,6,3,2,7,1,4,8}
    for index=0,  NUM_WORLD_RAID_MARKERS do
        btn= e.Cbtn(Frame.marker, {
            type=true,
            size={size,size},
            atlas= index==0 and 'auctionhouse-itemicon-border-orange',
            texture= index~=0 and 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index,
        })
        if not last then
            btn:SetPoint('CENTER')
        else
            if Save.H then
                btn:SetPoint('BOTTOMRIGHT', last or Frame.marker, 'TOPRIGHT')
            else
                btn:SetPoint('BOTTOMRIGHT', last or Frame.marker, 'BOTTOMLEFT')
            end
        end

        btn:SetAttribute('type1', 'worldmarker')
        btn:SetAttribute('marker1', index==0 and 0 or markerTab[index])
        btn:SetAttribute("action1", index==0 and 'clear' or "set")

        btn:SetAttribute("type2", "worldmarker")
        btn:SetAttribute("marker2", index==0 and 0 or markerTab[index])
        btn:SetAttribute("action2", "clear")
        btn:SetScript('OnLeave', function(self) e.tips:Hide() if self.index==0 then self:SetAlpha(0.5) end  end)
        btn:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            if self.index==0 then
                e.tips:AddLine(e.Icon.O2..(e.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
            else
                e.tips:AddDoubleLine(
                    Color[self.index2].col
                    ..e.Icon.left
                    ..(e.onlyChinese and '设置' or SETTINGS)
                    ..get_RaidTargetTexture(self.index2),

                    Color[self.index2].col
                    ..'|A:bags-button-autosort-up:0:0|a'
                    ..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..e.Icon.right
                )
            end
            e.tips:Show()
            self:SetAlpha(1)
        end)
        btn.index= index==0 and 0 or markerTab[index]
        btn.index2= index
        last=btn

        if index~=0 then--背景
            btn:SetPushedAtlas('Forge-ColorSwatchHighlight')
            btn.texture=btn:CreateTexture(nil,'BACKGROUND')
            btn.texture:SetAllPoints(btn)
            btn.texture:SetColorTexture(Color[index].r, Color[index].g, Color[index].b)
            btn.texture:SetAlpha(0.3)
            btn.setActive= function(self)
                self:SetButtonState(IsRaidMarkerActive(self.index) and 'PUSHED' or 'NORMAL')
            end
            btn.elapsed= 0
            btn:SetScript('OnUpdate', function(self, elapsed)
                self.elapsed= self.elapsed +elapsed
                if self.elapsed>2 then
                    self.setActive(self)
                    self.elapsed=0
                end
            end)
            btn.setActive(btn)
        else
            btn:SetAlpha(0.5)
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

        btn:SetScript('OnShow', btn.set_Events)
        btn:SetScript('OnHide', btn.set_Events)
    end

    Frame:set_Shown()
end










--#####
--主菜单
--#####
local function InitMenu(_, level, type)--主菜单
    local info
    if type then
        if type=='ready' then
            info={
                text=e.Icon.select2..(e.onlyChinese and '就绪' or READY),--就绪
                colorCode='|cff00ff00',
                checked= Save.autoReady==1,
                keepShownOnClick=true,
                func=function()
                    Save.autoReady=1
                    setReadyTexureTips()--自动就绪, 主图标, 提示
                    e.LibDD:CloseDropDownMenus();
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            info={
                text=e.Icon.X2..(e.onlyChinese and '未就绪' or NOT_READY_FEMALE),--未就绪
                colorCode='|cffff0000',
                checked= Save.autoReady==2,
                keepShownOnClick= true,
                func=function()
                    Save.autoReady=2
                    setReadyTexureTips()--自动就绪, 主图标, 提示
                    e.LibDD:CloseDropDownMenus();
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            info={--无
                text= e.onlyChinese and '无' or NONE,
                checked=not Save.autoReady,
                keepShownOnClick= true,
                func=function()
                    Save.autoReady=nil
                    setReadyTexureTips()--自动就绪, 主图标, 提示
                    e.LibDD:CloseDropDownMenus();
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            e.LibDD:UIDropDownMenu_AddSeparator(level)--队员提示信息
            info={
                text= e.onlyChinese and '队员就绪信息' or (PLAYERS_IN_GROUP..READY..INFO),
                checked=Save.groupReadyTips,
                keepShownOnClick= true,
                func=function()
                    Save.groupReadyTips= not Save.groupReadyTips and true or false
                    set_GroupReady_Tips_Event()--注册事件, 就绪,队员提示信息
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

        elseif type=='MakerFrameResetPost' then--重置位置， 队伍标记工具
            --[[info={
                text= e.onlyChinese and '冷却时间：信号' or format(CAPACITANCE_SHIPMENT_COOLDOWN, PING),
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this',
                colorCode= not C_CVar.GetCVarBool("enablePings") and '|cff606060' or nil,
                checked= Save.pingTime,
                keepShownOnClick=true,
                func= function()
                    Save.pingTime= not Save.pingTime and true or nil
                    print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            e.LibDD:UIDropDownMenu_AddSeparator(level)]]

            info={
                text= e.onlyChinese and '重置位置' or RESET_POSITION,
                notCheckable=true,
                colorCode= not Save.markersFramePoint and '|cff606060',
                keepShownOnClick=true,
                disabled= not Frame,
                func= function()
                    Frame:ClearAllPoints()
                    Save.markersFramePoint=nil
                    Frame:Init_Set_Frame()--位置
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

        else
            local num= NUM_RAID_ICONS+1
            for index=1, num do
                if index==num then
                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                end
                info={
                    text= index==num and (e.onlyChinese and '无' or NONE) or _G['RAID_TARGET_'..index],
                    icon= index==num and nil or 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index,
                    checked= Save[type]==index,
                    colorCode=Color[index] and Color[index].col,
                    keepShownOnClick= true,
                    func=function()
                        Save[type]=index
                        e.LibDD:CloseDropDownMenus()
                        if type=='tank' then
                            setTexture()--图标, 自动标记
                        end
                    end
                }
                if index~=0 then
                    if type=='tank' then
                        info.disabled= Save.healer==index or Save.tank2==index
                    elseif type=='tank2' then
                        info.disabled= Save.tank==index or Save.tank==0
                    elseif type=='healer' then
                        info.disabled= Save.tank==index
                    end
                end
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
            info={
                text=format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, type=='tank2' and (e.onlyChinese and '团队' or RAID) or type=='healer' and (e.onlyChinese and '小队' or GROUP) or (e.onlyChinese and '队伍' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)),
                notCheckable=true,
                isTitle=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    else
        info={
            text= (e.onlyChinese and '自动标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, EVENTTRACE_MARKER))..e.Icon.TANK..e.Icon.HEALER,
            icon= 'Warfronts-BaseMapIcons-Alliance-Workshop-Minimap',
            checked= Save.autoSet,
            disabled= Save.tank==0 and Save.healer==0,
            keepShownOnClick= true,
            func=function()
                if Save.autoSet then
                    Save.autoSet=nil
                else
                    Save.autoSet=true
                    setTankHealer(true)
                end
                setTexture()--设置,按钮图片
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator()

        local tab={
                {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK), type='tank'},
                {text= e.Icon.HEALER..(e.onlyChinese and '治疗' or HEALER), type='healer'},
                {text= e.Icon.TANK..(e.onlyChinese and '坦克' or TANK)..'2', type='tank2'},
            }
        for _, tab2 in pairs(tab) do
            info={
                text=tab2.text,
                checked=Save[tab2.type]~=0,
                keepShownOnClick= true,
                menuList=tab2.type,
                hasArrow=true,
            }
            if Save[tab2.type]~=0 then
                info.text=info.text..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save[tab2.type]..':0|t'
            end
            info.colorCode=Color[Save[tab2.type]] and Color[Save[tab2.type]].col
            if tab2.type2 and Save.tank==0 then
                info.disabled=true
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            if tab2.type=='healer' then
                e.LibDD:UIDropDownMenu_AddSeparator()
            end
        end

        e.LibDD:UIDropDownMenu_AddSeparator()
        info={
            text=e.onlyChinese and '队伍标记工具' or format(PROFESSION_TOOL_TOOLTIP_LINE, BINDING_HEADER_RAID_TARGET),
            checked=Save.markersFrame,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '世界标记' or SLASH_WORLD_MARKER3:gsub('/',''),
            tooltipText= (e.onlyChinese and '需求：队伍和权限' or (NEED..": "..format(COVENANT_RENOWN_TOAST_REWARD_COMBINER, HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS, CALENDAR_INVITELIST_SETMODERATOR))),
            menuList= 'MakerFrameResetPost',
            hasArrow=true,
            keepShownOnClick= true,
            disabled=not get_All_Set() or C_PvP.IsArena() or C_PvP.IsBattleground() or UnitAffectingCombat('player'),--是不有权限
            func=function()
                Save.markersFrame= not Save.markersFrame and true or nil
                Init_Markers_Frame()--设置标记, 框架
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text=(
                    Save.autoReady==1 and e.Icon.select2
                    or Save.autoReady==2 and e.Icon.O2
                    or (e.onlyChinese and '无' or NONE)
                )
                ..format(e.onlyChinese and '%s%s' or CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '自动' or SELF_CAST_AUTO, (
                    (not Save.autoReady or Save.autoReady==1) and (e.onlyChinese and '就绪' or READY)
                    or Save.autoReady==2 and (e.onlyChinese and '未就绪'
                    or NOT_READY_FEMALE)
                    or ''
                )),
            --checked= Save.autoReady==1 or Save.autoReady==2,
            notCheckable=true,
            colorCode= Save.autoReady==1 and '|cff00ff00' or Save.autoReady==2 and '|cffff0000',
            menuList='ready',
            hasArrow=true,
            keepShownOnClick= true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end
end














--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    setTexture()--设置,按钮图片
    setAllTextrue()--主图标,是否有权限

    Init_Markers_Frame()--设置标记, 框架
    setReadyTexureTips()--自动就绪, 主图标, 提示
    set_GroupReady_Tips_Event()--注册事件, 就绪,队员提示信息

    button:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then
            setTankHealer()--设置队伍标记
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
    end)

    button:SetScript('OnEnter', function(self)
        if self.groupReadyTips and self.groupReadyTips:IsShown() then
            self.groupReadyTips:SetButtonState('PUSHED')
        end
    end)
    button:SetScript('OnLeave', function(self)
        if self.groupReadyTips then
            self.groupReadyTips:SetButtonState('NORMAL')
        end
    end)

    local readyFrame=ReadyCheckListenerFrame--自动就绪事件, 提示
    if readyFrame then
        readyFrame:SetScript('OnHide',function ()
            if button.autoReadyTime then
                button.autoReadyTime:Cancel()
            end
        end)
        readyFrame:SetScript('OnShow',function(self)
            if Save.autoReady  and not self.autoReadyText then
                self.autoReadyText=e.Cstr(self)
                self.autoReadyText:SetPoint('BOTTOM', self, 'TOP')
            end
            if self.autoReadyText then
                local text=''
                if Save.autoReady==1 then
                    text=id..' '..addName..'|n|cnGREEN_FONT_COLOR:'..AUTO_JOIN:gsub(JOIN, '')..READY..'|r'..e.Icon.select2
                elseif Save.autoReady==2 then
                    text=id..' '..addName..'|n|cnRED_FONT_COLOR:'..AUTO_JOIN:gsub(JOIN, '')..NOT_READY_FEMALE..'|r'..e.Icon.O2
                end
               self.autoReadyText:SetText(text)
            end
        end)
    end


    --if Save.pingTime then
        --[[hooksecurefunc( PingManager, 'OnPingPinFrameAdded', function(self3, frame, uiTextureKit)
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
        end)]]
    --end
end
















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save

                button= e.Cbtn2({
                    name=nil,
                    parent=WoWToolsChatButtonFrame,
                    click=true,-- right left
                    notSecureActionButton=true,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })

                Init()

                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent('READY_CHECK')

            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='READY_CHECK' then--自动就绪事件
        e.PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        if Save.autoReady then
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
            e.Ccool(ReadyCheckListenerFrame, nil, arg2 or 35, nil, true,true)--冷却条
        end
        if Save.groupReadyTips then
            setGroupReadyTips(event, arg1, arg2)--队员,就绪,提示信息
        end
    elseif event=='READY_CHECK_CONFIRM' then
            setGroupReadyTips(event, arg1, arg2)--队员,就绪,提示信息

    elseif event=='CHAT_MSG_SYSTEM' then
        if arg1==READY_CHECK_ALL_READY then
            setGroupReadyTips(event, arg1, arg2)--队员,就绪,提示信息
        end
    end
end)


--Blizzard_CompactRaidFrameManager.lua