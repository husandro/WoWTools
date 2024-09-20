local e= select(2, ...)
local function Save()
    return WoWTools_MarkersMixin.Save
end






--队员,就绪,提示信息
local ReadyTipsButton

local function Init()
    if not Save().groupReadyTips then
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
    WoWTools_MarkersMixin.ReadyTipsButton= ReadyTipsButton

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
        Save().groupReadyTipsPoint={self:GetPoint(1)}
        Save().groupReadyTipsPoint[2]=nil
    end)

    ReadyTipsButton:SetScript("OnMouseUp", ResetCursor)--还原光标

    function ReadyTipsButton:set_Scale()
        self.text:SetScale(Save().tipsTextSacle or 1)
    end
    function ReadyTipsButton:set_Point()--设置位置
        if Save().groupReadyTipsPoint then
            self:SetPoint(Save().groupReadyTipsPoint[1], UIParent, Save().groupReadyTipsPoint[3], Save().groupReadyTipsPoint[4], Save().groupReadyTipsPoint[5])
        else
            self:SetPoint('BOTTOMLEFT', WoWTools_MarkersMixin.MarkerButton, 'TOPLEFT', 0, 20)
        end
    end

    function ReadyTipsButton:set_Shown()--显示/隐藏
        local text= self.text:GetText()
        local show= Save().groupReadyTips and (text and text~='')
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
        if Save().groupReadyTips then
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
        Save().tipsTextSacle= WoWTools_FrameMixin:ScaleFrame(self, delta, Save().tipsTextSacle)--设置Frame缩放
    end)


    function ReadyTipsButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_MarkersMixin.addName, e.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '隐藏' or HIDE, (e.onlyChinese and '双击' or BUFFER_DOUBLE)..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE,'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().tipsTextSacle or 1), 'Alt+'..e.Icon.mid)
        e.tips:Show()
    end
    ReadyTipsButton:SetScript('OnLeave', function()
        e.tips:Hide()
        WoWTools_MarkersMixin.MarkerButton:SetButtonState('NORMAL')
        WoWTools_MarkersMixin.MarkerButton:state_leave(true)
    end)
    ReadyTipsButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        WoWTools_MarkersMixin.MarkerButton:state_enter(nil, true)
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










function WoWTools_MarkersMixin:Init_Ready_Tips_Button()--队员,就绪,提示信息
    Init()
end