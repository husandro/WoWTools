
local function Save()
    return WoWToolsSave['ChatButton_Markers'] or {}
end

--队员,就绪,提示信息
local ReadyTipsButton










local function Init()
    ReadyTipsButton= WoWTools_ButtonMixin:Cbtn(nil, {
        size=22,
        atlas='common-icon-checkmark',
        name='WoWToolsChatMarkersReadyInfoButton',
    })

    ReadyTipsButton.text=WoWTools_LabelMixin:Create(ReadyTipsButton)
    ReadyTipsButton.text:SetPoint('BOTTOMLEFT', ReadyTipsButton, 'TOPLEFT')

    ReadyTipsButton:RegisterForDrag("RightButton")--移动
    ReadyTipsButton:SetMovable(true)
    ReadyTipsButton:SetClampedToScreen(true)
    ReadyTipsButton:SetScript("OnDragStart", function(self, d)
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    ReadyTipsButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().groupReadyTipsPoint={self:GetPoint(1)}
            Save().groupReadyTipsPoint[2]=nil
        else
            print(
                WoWTools_DataMixin.addName,
                '|cnRED_FONT_COLOR:',
                WoWTools_DataMixin.onlyChinese and '保存失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, FAILED)
            )
        end
    end)

    ReadyTipsButton:SetScript("OnMouseUp", function()--还原光标
        ResetCursor()
    end)

    function ReadyTipsButton:set_Scale()
        self.text:SetScale(Save().tipsTextSacle or 1)
    end
    function ReadyTipsButton:set_Point()--设置位置
        if Save().groupReadyTipsPoint then
            self:SetPoint(Save().groupReadyTipsPoint[1], UIParent, Save().groupReadyTipsPoint[3], Save().groupReadyTipsPoint[4], Save().groupReadyTipsPoint[5])
        else
            self:SetPoint('BOTTOMLEFT', WoWTools_MarkerMixin.MarkerButton, 'TOPLEFT', 0, 20)
        end
    end

    function ReadyTipsButton:set_Shown()--显示/隐藏
        local text= self.text:GetText()
        local show= Save().groupReadyTips and (text and text~='')
        if not show and self.HideTemr then
            self.HideTemr:Cancel()
            self.HideTemr= nil
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
                ..(UnitHasLFGRandomCooldown(unit) and '|cnRED_FONT_COLOR:<'..(WoWTools_DataMixin.onlyChinese and '逃亡者' or DESERTER)..'>|r' or '')
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
            WoWTools_CooldownMixin:Setup(ReadyTipsButton,nil, arg2 or 35, nil, true)
            self.HideTimer=C_Timer.NewTimer(arg2 or 35, function()
                self:set_Hide()
            end)
        end
    end)

    ReadyTipsButton:SetScript('OnClick', function(self, d)--隐藏
        if d=='LeftButton' and not IsModifierKeyDown() then
            self:set_Hide()
        end
    end)

    ReadyTipsButton:SetScript('OnMouseWheel', function(self, delta)--缩放
        Save().tipsTextSacle= WoWTools_FrameMixin:ScaleFrame(self, delta, Save().tipsTextSacle)--设置Frame缩放
    end)


    function ReadyTipsButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_MarkerMixin.addName, WoWTools_DataMixin.onlyChinese and '队员就绪信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, READY, INFO)))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE,'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().tipsTextSacle or 1), 'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
    end
    ReadyTipsButton:SetScript('OnLeave', function()
        GameTooltip:Hide()
        WoWTools_MarkerMixin.MarkerButton:SetButtonState('NORMAL')
        WoWTools_MarkerMixin.MarkerButton:state_leave(true)
    end)
    ReadyTipsButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        WoWTools_MarkerMixin.MarkerButton:state_enter(nil, true)
    end)

    ReadyTipsButton:SetScript('OnHide', function(self)
        WoWTools_CooldownMixin:Setup(self, nil, 0)
    end)

    ReadyTipsButton:set_Point()
    ReadyTipsButton:set_Scale()
    ReadyTipsButton:set_Event()
    ReadyTipsButton:set_Shown()

    return true
end










function WoWTools_MarkerMixin:Init_Ready_Tips_Button()--队员,就绪,提示信息
    if Save().groupReadyTips and Init() then
        Init=function()
            ReadyTipsButton:set_Event()
            ReadyTipsButton:set_Shown()
        end
    end
end