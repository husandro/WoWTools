local id, e = ...
local addName= BINDING_HEADER_RAID_TARGET
local Save={ autoSet=true, tank=2, tank2=6, healer=1, countdown=7, groupReadyTips=true, markersScale=0.85, markersFrame= e.Player.husandro}

local button
local panel= CreateFrame("Frame")

local color={
    [1]={r=1, g=1, b=0},--星星, 黄色
    [2]={r=1, g=0.45, b=0.04},--圆形, 金色
    [3]={r=1, g=0, b=1},--菱形,紫色
    [4]={r=0, g=1, b=0},--三角,绿色

    [5]={r=0.6, g=0.6, b=0.6},--月亮,灰色
    [6]={r=0.1, g=0.2, b=1},--方块, 蓝色
    [7]={r=1, g=0, b=0},--十字, 红色
    [8]={r=1, g=1, b=1},--骷髅,白色
}
local function getTexture(index)--取得图片
    if not index or index<1 or index>NUM_WORLD_RAID_MARKERS then
        return ''
    else
        return '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t'
    end
end

local function getIsLeader()--队长， 或助理
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player')
end

local function setTaget(unit, index)--设置,目标,标记
    if CanBeRaidTarget(unit) and GetRaidTargetIndex(unit)~=index then
        SetRaidTarget(unit, index)
    end
end

local function getAllSet()--是不有权限
    local raid =IsInRaid()
    return (raid and getIsLeader()) or not raid
end

local function setRaidTarget()--设置团队标记
    local tab={}
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
        setTaget(tab[1].unit, Save.tank)--设置,目标,标记
        if num>=2 and Save.tank2~=0 then
            setTaget(tab[2].unit, Save.tank)--设置,目标,标记
        end
    end
end

local function setPartyTarget()--设置队伍标记
    local tank, healer
    local num=GetNumGroupMembers()--MAX_PARTY_MEMBERS + 1
    for index=1, num do
        local unit = index==num and 'player' or 'party'..index
        local role = UnitGroupRolesAssigned(unit)
        if role=='TANK' then
            if not tank then
                setTaget(unit, Save.tank)--设置,目标,标记
                tank=true
            end
        elseif role=='HEALER' then
            if not healer then
                setTaget(unit, Save.healer)--设置,目标,标记
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
            print(id, addName, SETTINGS, TANK..getTexture(Save.tank), HEALER..getTexture(Save.healer), '|cnRED_FONT_COLOR:'..SPELL_TARGET_TYPE4_DESC..'<2|r')
        end
        return
    end
    if IsInRaid() then
        if not getIsLeader() and not autoSet then--没有权限
            print(id, addName, SETTINGS, TANK..getTexture(Save.tank), HEALER..getTexture(Save.healer), '|cnRED_FONT_COLOR:'..ERR_ARENA_TEAM_PERMISSIONS..'|r')
        else
            setRaidTarget()--设置团队标记
        end
    else
        setPartyTarget()--设置队伍标记
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
local function setGroupReadyTipsEvent()--注册事件, 就绪,队员提示信息
    if Save.groupReadyTips then
        panel:RegisterEvent('READY_CHECK_CONFIRM')
        panel:RegisterEvent('CHAT_MSG_SYSTEM')
    else
        panel:UnregisterEvent('READY_CHECK_CONFIRM')
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    end
end
local function getReadyCheckStatus(unit, index)
    local stat=GetReadyCheckStatus(unit)
    local text= e.GetPlayerInfo({unit=unit, guid=UnitGUID(unit), name=nil,  reName=true, reRealm=true, reLink=false})
    local hasCoolText= UnitHasLFGRandomCooldown(unit) and '|T236347:0|t|cnRED_FONT_COLOR:'..(e.onlyChinese and '逃亡者' or DESERTER)..'|r' or ''
    if stat=='ready' then
        return '|cnGREEN_FONT_COLOR:'..index..")|r"..e.Icon.select2..text..hasCoolText
    elseif stat=='waiting' then
        return index..")   "..text..hasCoolText
    elseif stat=='notready' then
        return '|cnRED_FONT_COLOR:'..index..")|r"..e.Icon.O2..text..(UnitIsAFK(unit) and '|cff606060<'..AFK..'>|r' or not UnitIsConnected(unit) and 	'|cff606060<'..(e.onlyChinese and '离线' or PLAYER_OFFLINE)..'>|r' or '')..hasCoolText
    end
end
local function setGroupReadyTips(event, arg1, arg2)
    local text=''
    if event=='READY_CHECK' or event=='READY_CHECK_CONFIRM'  then
        local isInRaid=IsInRaid()
        local unit=isInRaid and 'raid' or 'party'
        local num=GetNumGroupMembers()
        if isInRaid then
            for index= 1, num do
                local text2=getReadyCheckStatus(unit..index, index)
                if text2 then
                    text= (text~='' and text..'\n' or text)..text2
                end
            end
        else
            for index= 1, num-1 do
                local text2=getReadyCheckStatus(unit..index, index)
                if text2 then
                    text= (text~='' and text..'\n' or text)..text2
                end
            end
            local text2=getReadyCheckStatus('player', num)
            if text2 then
                text= (text~='' and text..'\n' or text)..text2
            end
        end
        if text~='' and not button.groupReadyTips then
            button.groupReadyTips=e.Cbtn(nil, {icon='hide', size={20,20}})
            if Save.groupReadyTipsPoint then
                button.groupReadyTips:SetPoint(Save.groupReadyTipsPoint[1], UIParent, Save.groupReadyTipsPoint[3], Save.groupReadyTipsPoint[4], Save.groupReadyTipsPoint[5])
            else
                button.groupReadyTips:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', 0, 20)
            end
            button.groupReadyTips:SetScript('OnMouseDown', function(self,d)
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
            end)
            button.groupReadyTips:SetScript('OnLeave', function()
                ResetCursor()
                e.tips:Hide()
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
            button.groupReadyTips.timer=C_Timer.NewTimer(arg2 or 35, function()
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
    if Save.autoSet then
        button.border:SetAtlas('bag-border')
    else
        button.border:SetAtlas('bag-reagent-border')
    end
end
local function setAllTextrue()--主图标,是否有权限
    button.texture:SetDesaturated(GetNumGroupMembers() <2  or not getAllSet())
end


--#############
--设置标记, 框架
--#############
local function C(unit, index)
    local t=GetRaidTargetIndex(unit)
    if t and t>0 and (index==t or not index) then
        setTaget(unit, 0)--设置,目标,标记
    end
end
local function Clear(index)--取消标记标    
    local u;--取消怪物标记
    local tab= C_NamePlate.GetNamePlates() or {}
    for _, v in pairs(tab) do
        u = v.namePlateUnitToken or v.UnitFrame and v.UnitFrame.unit
        C(u, index);
    end
    if IsInGroup() then
        u=  IsInRaid() and 'raid' or 'party'--取消队友标记
        for i=1, GetNumGroupMembers() do
            C(u..i, index)
            C(u..i..'target', index)
            C(u..'pet'..i, index)
        end
    end
    u={
        'player', 'target','pet','focus',
        'boss1', 'boss2', 'boss3', 'boss4', 'boss5'
    }
    for _, v in pairs(u) do
        C(v, index)
    end
end

local frame, frame2
local function setMarkersFrame_Postion()--设置标记框架, 位置
    if frame then
        if Save.markersFramePoint then
            frame:SetPoint(Save.markersFramePoint[1], UIParent, Save.markersFramePoint[3], Save.markersFramePoint[4], Save.markersFramePoint[5])
        --elseif MultiBarBottomLeftButton12 and MultiBarBottomLeftButton12:IsShown() then
        --    frame:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton12, 'TOPRIGHT')
        else
            frame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 330, 175)
        end
    end
end
local function setMarkersFrame()--设置标记, 框架
    local combat=UnitAffectingCombat('player')

    if not Save.markersFrame or not getAllSet() or combat then
        if combat then
            panel:RegisterEvent('PLAYER_REGEN_ENABLED')
            button.combat=true
        else
            if frame then
                frame:SetShown(false)
            end
        end
        return
    end

    if not frame then
        local last
        frame=CreateFrame("Frame",nil, UIParent)
        frame:SetFrameStrata('HIGH')
        setMarkersFrame_Postion()--设置标记框架, 位置
        frame:SetSize(1, 25)
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        if Save.markersScale and Save.markersScale~=1 then--缩放
            frame:SetScale(Save.markersScale)
        end

        for index = 0, NUM_RAID_ICONS do
            local btn=e.Cbtn(frame, {icon='hide', size={25,25}})
            if Save.H then
                btn:SetPoint('BOTTOMLEFT', last or frame, 'TOPLEFT')
            else
                btn:SetPoint('BOTTOMRIGHT', last or frame, 'BOTTOMLEFT')
            end
            if index==0 then
                btn:SetNormalTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-mark.tga')
                btn:RegisterForDrag("RightButton")
                btn:SetScript("OnDragStart", function(self,d )
                    if d=='RightButton' and not IsModifierKeyDown() then
                        frame:StartMoving()
                    end
                end)
                btn:SetScript("OnDragStop", function(self)
                    ResetCursor()
                    frame:StopMovingOrSizing()
                    Save.markersFramePoint={frame:GetPoint(1)}
                    Save.markersFramePoint[2]=nil
                end)
                btn:SetScript('OnMouseDown', function(self, d)
                    local key=IsModifierKeyDown()
                    if d=='LeftButton' and not key then
                        Clear()--取消标记标
                    elseif d=='RightButton' and not key then
                        SetCursor('UI_MOVE_CURSOR')
                    elseif d=='RightButton' and IsControlKeyDown() then
                        Save.H = not Save.H and true or nil
                        print(id,addName,HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION..(Save.H and e.Icon.up2 or e.Icon.toLeft2), REQUIRES_RELOAD)
                    end
                end)
                btn:SetScript('OnMouseUp', function()
                    ResetCursor()
                end)
                btn:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:AddDoubleLine(e.Icon.O2..(e.onlyChinese and '清除全部' or CLEAR_ALL), e.Icon.left)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE,e.Icon.right)
                    e.tips:AddDoubleLine(e.onlyChinese and '缩放' or  UI_SCALE, (Save.markersScale or 1)..' Alt+'..e.Icon.mid)
                    e.tips:AddDoubleLine((e.onlyChinese and '图标方向' or  HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION)..(Save.H and e.Icon.toLeft2 or e.Icon.up2), 'Ctrl+'..e.Icon.right)
                    e.tips:Show()
                end)
                btn:EnableMouseWheel(true)
                btn:SetScript('OnMouseWheel', function(self, d)--缩放
                    if IsAltKeyDown() then
                        local sacle=Save.markersScale or 1
                        if d==1 then
                            sacle=sacle+0.1
                        elseif d==-1 then
                            sacle=sacle-0.1
                        end
                        if sacle>3 then
                            sacle=3
                        elseif sacle<0.6 then
                            sacle=0.6
                        end
                        print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, sacle)
                        frame:SetScale(sacle)
                        Save.markersScale=sacle
                    end
                end)
                button.markersFrame=btn--给 SetButtonState('PUSHED') 用
            else
                btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                btn:SetScript('OnMouseDown', function(self, d)
                    if d=='LeftButton' then
                        setTaget('target', index)--设置,目标, 标记
                    elseif d=='RightButton' then
                        Clear(index)--取消标记标    
                    end
                end)
                btn:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddLine(getTexture(index)..(e.onlyChinese and '设置' or SETTINGS)..e.Icon.left, color[index].r, color[index].g, color[index].b)
                    e.tips:AddLine(getTexture(index)..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..e.Icon.right, color[index].r, color[index].g, color[index].b)
                    e.tips:Show()
                end)
            end
            btn:SetScript('OnLeave', function()
                e.tips:Hide()
            end)
            last=btn
        end
    end
    frame:SetShown(true)

    if not frame.check then--就绪
        frame.check=e.Cbtn(frame, {icon='hide', size={25,25}})
        frame.check:SetNormalAtlas(e.Icon.select)
        if Save.H then
            frame.check:SetPoint('TOPLEFT')
        else
            frame.check:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT')
        end
        frame.check:SetScript('OnMouseDown', function()
            DoReadyCheck()
        end)
        frame.check:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddLine(EMOTE127_CMD3)
            e.tips:Show()
        end)
        frame.check:SetScript('OnLeave', function() e.tips:Hide() end)

        frame.countdown=e.Cbtn(frame.check, {icon='hide', size={25,25}})--倒计时10秒
        frame.countdown:SetNormalAtlas('countdown-swords')
        if Save.H then
            frame.countdown:SetPoint('TOPRIGHT',frame.check, 'TOPLEFT')
        else
            frame.countdown:SetPoint('BOTTOMLEFT', frame.check, 'TOPLEFT')
        end
        frame.countdown:SetScript('OnMouseDown', function(self, d)
            local key=IsModifierKeyDown()
            if d=='LeftButton' and not key then
                if not self.star then
                    C_PartyInfo.DoCountdown(Save.countdown or 7)
                end
            elseif d=='RightButton' and not key then
                if self.star then
                    C_PartyInfo.DoCountdown(0)
                end
                e.Chat(BINDING_NAME_STOPATTACK)

            elseif d=='RightButton' and IsControlKeyDown() then--设置时间
                StaticPopupDialogs[id..addName..'COUNTDOWN']={--区域,设置对话框
                    text=id..' '..addName..'\n'..(e.onlyChinese and '就绪' or READY)..'\n\n1 - 3600',
                    whileDead=1,
                    hideOnEscape=1,
                    exclusive=1,
                    timeout = 60,
                    hasEditBox=1,
                    button1= e.onlyChinese and '设置' or SETTINGS,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnShow = function(self2, data)
                        self2.editBox:SetNumeric(true)
                        self2.editBox:SetNumber(Save.countdown or 7)
                    end,
                    OnAccept = function(self2, data)
                        local num= self2.editBox:GetNumber()
                        Save.countdown=num
                    end,
                    EditBoxOnTextChanged=function(self2, data)
                        local num= self2:GetNumber()
                        self2:GetParent().button1:SetEnabled(num>0 and num<=3600)
                        self2:GetParent().button1:SetText(SecondsToClock(num))
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'COUNTDOWN')
            end
        end)
        frame.countdown:SetScript('OnEvent', function(self, event, timerType, timeRemaining, totalTime)
            if timerType==3 and event=='START_TIMER' then
                if totalTime==0 then
                   self.star=nil
                   if self.timer then self.timer:Cancel() end
                elseif totalTime>0 then
                    if self.timer then self.timer:Cancel() end
                    self.timer=C_Timer.NewTimer(totalTime, function() self.star=nil end)
                    self.star=true
                end
            end
        end)
        frame.countdown:RegisterEvent('START_TIMER')
        frame.countdown:SetScript('OnShow', function(self)
            self:RegisterEvent('START_TIMER')
        end)
        frame.countdown:SetScript('OnHide', function(self)
            self:UnregisterEvent('START_TIMER')
        end)
        frame.countdown:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:AddLine(e.Icon.left..(e.onlyChinese and '/倒计时' or SLASH_COUNTDOWN2)..' '..(Save.countdown or 7))
            e.tips:AddLine(e.Icon.right..BINDING_NAME_STOPATTACK)
            e.tips:AddLine(' ')
            e.tips:AddLine(e.onlyChinese and '你太快了' or ERR_GENERIC_THROTTLE, 1,0,0)
            e.tips:AddLine('Ctrl+'..e.Icon.right..(e.onlyChinese and '设置' or SETTINGS))
            e.tips:Show()
        end)
        frame.countdown:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    frame.check:SetShown(GetNumGroupMembers()>1 and (IsInRaid() and getIsLeader()) or UnitIsGroupLeader('player'))


    local isInGroup=IsInGroup()--世界标记
    if combat then
       if not isInGroup or not frame2 or not frame2:IsShown() then
            panel:RegisterEvent('PLAYER_REGEN_ENABLED')
            button.combat=true
            return
       end
    elseif not isInGroup then
        if frame2 then
            frame2:SetShown(false)
        end
        return
    end
    if not frame2 then
        frame2=CreateFrame("Frame", nil, frame)
        if Save.H then
            frame2:SetPoint('TOPRIGHT', frame, 'TOPLEFT')
        else
            frame2:SetPoint('TOPLEFT', frame, 'TOPRIGHT',-1,0)
        end
        frame2:SetSize(1, 1)
        local last
        local tab={5,6,3,2,7,1,4,8}
        for index=0,  NUM_WORLD_RAID_MARKERS do
            local btn=e.Cbtn(frame2, {type=true, icon='hide', size={25,25}})
            if Save.H then
                btn:SetPoint('BOTTOMRIGHT', last or frame2, 'TOPRIGHT')
            else
                btn:SetPoint('BOTTOMRIGHT', last or frame2, 'BOTTOMLEFT')
            end
            --btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)

            btn:SetAttribute('type1', 'worldmarker')
            btn:SetAttribute('marker1', index==0 and 0 or tab[index])
            btn:SetAttribute("action1", index==0 and 'clear' or "set")

            btn:SetAttribute("type2", "worldmarker")
            btn:SetAttribute("marker2", index==0 and 0 or tab[index])
            btn:SetAttribute("action2", "clear")
            if index==0 then
                btn:SetNormalTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-mark.tga')
            else
                btn:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            end
            btn:SetScript('OnLeave', function()
                e.tips:Hide()
            end)
            btn:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                if index==0 then
                    e.tips:AddLine(e.Icon.O2..(e.onlyChinese and '清除全部' or CLEAR_ALL)..e.Icon.left)
                else
                    e.tips:AddLine(getTexture(index)..(e.onlyChinese and '设置' or SETTINGS)..e.Icon.left, color[index].r, color[index].g, color[index].b)
                    e.tips:AddLine(getTexture(index)..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..e.Icon.right, color[index].r, color[index].g, color[index].b)
                end
                e.tips:Show()
            end)
            last=btn
            if index~=0 then--背景
                btn.texture=btn:CreateTexture(nil,'BACKGROUND')
                btn.texture:SetAllPoints(btn)
                btn.texture:SetColorTexture(color[index].r, color[index].g, color[index].b)
                btn.texture:SetAlpha(0.3)
            end
        end
    end
    frame2:SetShown(true)
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local colorCode={
        [1]='|cffffff00',
        [2]='|cffE29114',
        [3]='|cffff00ff',
        [4]='|cff00ff00',
        [6]='|cff03BBFA',
        [7]='|cffff0000',
    }
    local info
    if type then
        if type=='ready' then
            info={
                text=e.Icon.select2..(e.onlyChinese and '就绪' or READY),--就绪
                colorCode='|cff00ff00',
                checked=Save.autoReady==1,
                func=function()
                    Save.autoReady=1
                    setReadyTexureTips()--自动就绪, 主图标, 提示
                    e.LibDD:CloseDropDownMenus();
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            info={
                text=e.Icon.O2..(e.onlyChinese and '未就绪' or NOT_READY_FEMALE),--未就绪
                colorCode='|cffff0000',
                checked=Save.autoReady==2,
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
                func=function()
                    Save.groupReadyTips= not Save.groupReadyTips and true or false
                    setGroupReadyTipsEvent()--注册事件, 就绪,队员提示信息
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

        elseif type=='MakerFrameResetPost' then--重置位置， 队伍标记工具
            info={
                text= e.onlyChinese and '重置位置' or RESET_POSITION,
                notCheckable=true,
                colorCode= not Save.markersFramePoint and '|cff606060',
                func= function()
                    frame:ClearAllPoints()
                    Save.markersFramePoint=nil
                    setMarkersFrame_Postion()--设置标记框架, 位置
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
                    colorCode=colorCode[index],
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
            text= e.onlyChinese and '自动标记' or (AUTO_JOIN:gsub(JOIN,'')..EVENTTRACE_MARKER)..e.Icon.TANK..e.Icon.HEALER,
            checked= Save.autoSet,
            disabled= Save.tank==0 and Save.healer==0,
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
                menuList=tab2.type,
                hasArrow=true,
            }
            if Save[tab2.type]~=0 then
                info.text=info.text..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save[tab2.type]..':0|t'
            end
            info.colorCode=colorCode[Save[tab2.type]]
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
            text=e.onlyChinese and '队伍标记工具' or format(BINDING_HEADER_RAID_TARGET, PROFESSION_TOOL_TOOLTIP_LINE),
            checked=Save.markersFrame,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '世界标记' or SLASH_WORLD_MARKER3:gsub('/',''),
            tooltipText= e.onlyChinese and '需求：队伍和权限' or NEED..": "..COVENANT_RENOWN_TOAST_REWARD_COMBINER:format(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS,CALENDAR_INVITELIST_SETMODERATOR),
            menuList= 'MakerFrameResetPost',
            hasArrow=true,
            func=function()
                if UnitAffectingCombat('player') then
                    print(id, addName, '|cnRED_FONT_COLOR:'..COMBAT..'|r')
                    return
                end
                Save.markersFrame= not Save.markersFrame and true or nil
                setMarkersFrame()--设置标记, 框架
            end,
            disabled=not getAllSet(),--是不有权限
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text=(Save.autoReady==1 and e.Icon.select2 or Save.autoReady==2 and e.Icon.O2 or (e.onlyChinese and '无' or NONE)).. (e.onlyChinese and '自动' or AUTO_JOIN:gsub(JOIN,''))..((not Save.autoReady or Save.autoReady==1) and (e.onlyChinese and '就绪' or READY) or Save.autoReady==2 and (e.onlyChinese and '未就绪' or NOT_READY_FEMALE) or ''),
            checked= Save.autoReady==1 or Save.autoReady==2,
            colorCode= Save.autoReady==1 and '|cff00ff00' or Save.autoReady==2 and '|cffff0000',
            menuList='ready',
            hasArrow=true,
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
    setMarkersFrame()--设置标记, 框架
    setReadyTexureTips()--自动就绪, 主图标, 提示
    setGroupReadyTipsEvent()--注册事件, 就绪,队员提示信息

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
        if self.markersFrame and self.markersFrame:IsShown() then
            self.markersFrame:SetButtonState('PUSHED')
        end
    end)
    button:SetScript('OnLeave', function(self)
        if self.groupReadyTips then
            self.groupReadyTips:SetButtonState('NORMAL')
        end
        if self.markersFrame then
            self.markersFrame:SetButtonState('NORMAL')
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
                    text=id..' '..addName..'\n|cnGREEN_FONT_COLOR:'..AUTO_JOIN:gsub(JOIN, '')..READY..'|r'..e.Icon.select2
                elseif Save.autoReady==2 then
                    text=id..' '..addName..'\n|cnRED_FONT_COLOR:'..AUTO_JOIN:gsub(JOIN, '')..NOT_READY_FEMALE..'|r'..e.Icon.O2
                end
               self.autoReadyText:SetText(text)
            end
        end)
    end
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
                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

                Init()

                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent('GROUP_ROSTER_UPDATE')
                panel:RegisterEvent('GROUP_LEFT')
                panel:RegisterEvent('READY_CHECK')
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        setTankHealer(true)--设置队伍标记
        setAllTextrue()--主图标,是否有权限
        setMarkersFrame()--设置标记, 框架

    elseif event=='PLAYER_REGEN_ENABLED' then
        if self.combat then
            setMarkersFrame()--设置标记, 框架
            self.combat=nil
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
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