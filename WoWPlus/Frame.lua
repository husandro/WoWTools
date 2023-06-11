local id, e = ...
local Save={
        --disabledMove=true,--禁用移动
        point={},--移动
        SavePoint= e.Player.husandro,--保存窗口,位置
        moveToScreenFuori=e.Player.husandro,--可以移到屏幕外

        --disabledZoom=true,--禁用缩放
        scale={--缩放
            ['UIWidgetPowerBarContainerFrame']= 0.85,
        },
}
local addName= 'Frame'
local panel= CreateFrame("Frame")


--###############
--设置, 移动, 位置
--###############
local function set_Frame_Point(self, name)--设置, 移动, 位置
    if not Save.disabledMove and self then
        name= name or self.FrameName or self:GetName()
        if name and name~='SettingsPanel' then
            local p= Save.point[name]
            if p and p[1] and p[3] and p[4] and p[5] then
                local frame= self.MoveFrame or self
                frame:ClearAllPoints()
                frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            end
        end
    end
end


--####
--缩放
--####
local function set_Zoom_Frame(frame, tab)--notZoom, zeroAlpha, name)--放大
    local self= tab.frame or frame
    if not tab.name then
        tab.name= self and self:GetName()
    end

    if not self or self.ZoomInOutFrame or tab.notZoom or Save.disabledZoom or not tab.name or _G['MoveZoomInButtonPer'..tab.name] then
        return
    end

    self.ZoomInOutFrame= e.Cbtn(self.Header
                        or self.TitleContainer
                        or self.SpellButtonContainer
                        or self.BorderFrame and self.BorderFrame.TitleContainer
                        or self
        , {atlas='UI-HUD-Minimap-Zoom-In', size={18,18}, name='MoveZoomInButtonPer'..tab.name})

    self.ZoomInOutFrame.ScaleName= tab.name
    self.ZoomInOutFrame.ZoomFrame= self
    self.ZoomInOutFrame.alpha= tab.zeroAlpha and 0 or 0.2
    self.ZoomInOutFrame:SetFrameLevel(self.ZoomInOutFrame:GetFrameLevel() +5)

    if self.moveButton then
        self.ZoomInOutFrame:SetPoint('RIGHT', self.moveButton, 'LEFT')

    elseif self.Header then
        self.ZoomInOutFrame:SetPoint('LEFT')

    elseif self.TitleContainer then
        self.ZoomInOutFrame:SetPoint('LEFT', 35,-2)

    elseif self.SpellButtonContainer then
        self.ZoomInOutFrame:SetPoint('BOTTOM', self.SpellButtonContainer, 'TOP', -20,0)

    elseif self.BorderFrame and self.BorderFrame.TitleContainer then
        self.ZoomInOutFrame:SetPoint('LEFT', 35,-2)

    else
        self.ZoomInOutFrame:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
    end

    self.ZoomInOutFrame:SetScript('OnClick', function(self2, d)
        local n= Save.scale[self2.ScaleName] or 1
        if d=='LeftButton' then
            n= n+ 0.05
        elseif d=='RightButton' then
            n= n- 0.05
        end
        n= n>3 and 3 or n
        n= n< 0.5 and 0.5 or n
        Save.scale[self2.ScaleName]= n
        self2.ZoomFrame:SetScale(n)
    end)

    self.ZoomInOutFrame:SetScript('OnMouseWheel', function(self2,d)
        local n= Save.scale[self2.ScaleName] or 1
        if d==-1 then
            n= n+ 0.05
        elseif d==1 then
            n= n- 0.05
        end
        n= n>3 and 3 or n
        n= n< 0.5 and 0.5 or n
        Save.scale[self2.ScaleName]= n
        self2.ZoomFrame:SetScale(n)
    end)

    self.ZoomInOutFrame:SetAlpha(self.ZoomInOutFrame.alpha)
    self.ZoomInOutFrame:SetScript("OnLeave", function(self2)
        e.tips:Hide()
        self2:SetAlpha(self2.alpha)
    end)
    self.ZoomInOutFrame:SetScript("OnEnter",function(self2)
        self2:SetAlpha(1)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine('|cff00ff00'..(Save.scale[self2.ScaleName] or 1))
        e.tips:AddDoubleLine(e.onlyChinese and '放大' or ZOOM_IN, '3'..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '缩小' or ZOOM_OUT, '0.5'..e.Icon.right)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)

    if Save.scale[tab.name] and Save.scale[tab.name]~=1 then
        self:SetScale(Save.scale[tab.name])
    end
    if tab.zeroAlpha then
        self:HookScript('OnEnter', function(self2)
            self2.ZoomInOutFrame:SetAlpha(1)
            if self2.moveButton then
                self2.moveButton:SetAlpha(1)
            end
        end)
        self:HookScript('OnLeave', function(self2)
            self2.ZoomInOutFrame:SetAlpha(0)
            if self2.moveButton then
                self2.moveButton:SetAlpha(0)
            end
        end)
    end
end

--############
--设置Frame属性
--############
local function stop_Drag(self)--停止移动
    if self.MoveFrame and self.MoveFrame:IsMovable() then
        self.MoveFrame:StopMovingOrSizing()
    end
    if self and self:IsMovable() then
        self:StopMovingOrSizing()
    end
    ResetCursor()--还原，光标
end
local function set_SetClampedToScreen(self)
    if self then
        if Save.moveToScreenFuori then
            self:SetClampedToScreen(false)
        else
            self:SetClampedToScreen(self.SavePoint and true or false)
        end
        self:SetMovable(true)
    end--self:EnableMouse(true)
end
local function set_Frame_Drag(self)
    set_SetClampedToScreen(self)
    set_SetClampedToScreen(self.MoveFrame)
    if self.ClickTypeMove=='R' then
        self:RegisterForDrag("RightButton")
    elseif self.ClickTypeMove=='L' then
        self:RegisterForDrag("LeftButton")
    else
        self:RegisterForDrag("LeftButton", "RightButton")
    end
    self:SetScript("OnDragStart", function(self2)--开始移动
        local moveFrame= self2.MoveFrame or self2
        moveFrame:StartMoving()
    end)
    self:SetScript("OnDragStop", function(self2)
        stop_Drag(self)--停止移动
        local moveFrame= self2.MoveFrame or self2
        local frameName= self2.FrameName or moveFrame:GetName()
        if frameName and frameName~='SettingsPanel' then
            if self2.SavePoint then--保存点
                Save.point[frameName]= {moveFrame:GetPoint(1)}
                Save.point[frameName][2]= nil
            else
                Save.point[frameName]= nil
            end
        end
    end)
    self:HookScript("OnMouseUp", stop_Drag)--停止移动
    self:HookScript('OnHide', stop_Drag)--停止移动
    self:HookScript("OnMouseDown", function(self2, d)--设置, 光标
        if not self2.ClickTypeMove or (self2.ClickTypeMove=='R' and d=='RightButton') or (self2.ClickTypeMove=='L' and d=='LeftButton') then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
end

--####
--移动
--####
local set_Move_Frame=function(self, tab)--set_Move_Frame(frame, {frame=nil, click=nil, save=nil, show=nil, zeroAlpha=nil, notZoom=true})    
    if not self then
        return
    end
    tab= tab or {}
    if not Save.disabledMove then
        local name= tab.frame and tab.frame:GetName() or self and self:GetName()
        tab.name= name
        if name and not self.FrameName then
            self.SavePoint= ((tab.save and name) or Save.SavePoint) and true or false--是否保存
            self.ClickTypeMove= tab.click--点击,或右击
            self.MoveFrame= tab.frame--要移动的Frame
            self.FrameName= name

            set_Frame_Drag(self)--设置Frame,移动属性

            local header= self.Header or self.HeaderFrame or self.TitleContainer or self.TitleButton
            if header then
                header.SavePoint= self.SavePoint
                header.ClickTypeMove= self.ClickTypeMove
                header.MoveFrame= self
                header.FrameName=name
                set_Frame_Drag(header)--设置Frame,移动属性
            end

            --[[if tab.show or Save.SavePoint then
                self:HookScript("OnShow", set_Frame_Point)--设置, 移动, 位置
            end]]

            self:HookScript("OnLeave", ResetCursor)
        end
        set_Frame_Point(self, name)--设置, 移动, 位置
    end
    set_Zoom_Frame(self, tab)
end


--#################
--创建, 一个移动按钮
--#################
local function created_Move_Button(self, tab)--created_Move_Button(self, {frame=nil, save=true, zeroAlpha=nil, notZoom=nil})
    if not self or Save.disabledMove then
        return
    end
    if not self.moveButton then
        self.moveButton= e.Cbtn(self, {texture='Interface\\Cursor\\UI-Cursor-Move', size={16,16}})
        self.moveButton:SetPoint('BOTTOM', self, 'TOP')
        self.moveButton:SetFrameLevel(self:GetFrameLevel()+5)
        self.moveButton.alpha= tab.zeroAlpha and 0 or 0.2
        self.moveButton:SetAlpha(self.moveButton.alpha)
        self.moveButton:SetScript("OnEnter",function(self2)
            self2:SetAlpha(1)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, tab.click=='R' and e.Icon.right or e.Icon.left)
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)

        tab.frame=self
        set_Move_Frame(self.moveButton, tab)

        self.moveButton:SetScript("OnLeave", function(self2)
            ResetCursor()
            e.tips:Hide()
            self2:SetAlpha(self2.alpha)
        end)
    else
        set_Frame_Point(self)--设置, 移动, 位置)
    end
end


local combatCollectionsJournal--藏品
local function set_Move_CollectionJournal()--藏品
    set_Move_Frame(CollectionsJournal)--藏品
    --set_Move_Frame(RematchJournal, {frame=CollectionsJournal})--藏品
    set_Move_Frame(WardrobeFrame)--幻化
end

local function setAddLoad(arg1)
    if arg1=='Blizzard_TimeManager' then--小时图，时间
        set_Move_Frame(TimeManagerFrame, {save=true})
        set_Move_Frame(TimeManagerClockButton, {save=true, click="R", notZoom=true})
        hooksecurefunc('TimeManagerClockButton_UpdateTooltip', function()
            e.tips:AddLine(' ')
            e.tips:AddLine(e.Icon.right..(e.onlyChinese and '移动' or NPE_MOVE))
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        TimeManagerClockButton:HookScript('OnLeave', TimeManagerClockButton_OnLeave)

    elseif arg1=='Blizzard_AchievementUI' then--成就
        --set_Move_Frame(AchievementFrame.Header, {frame=AchievementFrame})
        set_Move_Frame(AchievementFrame)
        set_Move_Frame(AchievementFrameComparisonHeader, {frame=AchievementFrame})

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        set_Move_Frame(EncounterJournal)

    elseif arg1=='Blizzard_ClassTalentUI' then--天赋
        local frame=ClassTalentFrame
        if frame then
            set_Move_Frame(frame, {save=true})
            if frame.TalentsTab and frame.TalentsTab.ButtonsParent then
                set_Move_Frame(frame.TalentsTab.ButtonsParent, {save=true, frame=frame})--里面, 背景
            end
            if frame.ZoomInOutFrame then
                --设置,大小
                --Blizzard_SharedTalentFrame.lua
                hooksecurefunc(TalentFrameBaseMixin, 'OnShow', function (self)
                    local name= ClassTalentFrame:GetName()
                    if name then
                        if Save.scale[name] and Save.scale[name]~= ClassTalentFrame:GetScale() then
                            ClassTalentFrame:SetScale(Save.scale[name])
                        end
                    end
                end)
            end

            --####################
            --专精 UpdateSpecFrame
            --Blizzard_ClassTalentSpecTab.lua
            if frame.SpecTab and frame.SpecTab.SpecContentFramePool then
                for specContentFrame in frame.SpecTab.SpecContentFramePool:EnumerateActive() do
                    set_Move_Frame(specContentFrame, {frame= frame, save=true})
                end
            end
            hooksecurefunc(frame.SpecTab, 'UpdateSpecContents', function()--Blizzard_ClassTalentSpecTab.lua
                local name= ClassTalentFrame:GetName()
                if name then
                    if Save.scale[name] and Save.scale[name]~= ClassTalentFrame:GetScale() then
                        ClassTalentFrame:SetScale(Save.scale[name])
                    end
                end
            end)
        end

    elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
        set_Move_Frame(AuctionHouseFrame)

    elseif arg1=='Blizzard_BlackMarketUI' then--黑市
        set_Move_Frame(BlackMarketFrame)

    elseif arg1=='Blizzard_Communities' then--公会和社区
        set_Move_Frame(CommunitiesFrame)

    elseif arg1=='Blizzard_Collections' then--收藏
        local checkbox = WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox
        checkbox.Label:ClearAllPoints()
        checkbox.Label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1)
        checkbox.Label:SetPoint("RIGHT", checkbox, "RIGHT", 160, 1)
        if not UnitAffectingCombat('player') then
            set_Move_CollectionJournal()--藏品
        else
            combatCollectionsJournal=true
            panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        end

    elseif arg1=='Blizzard_Calendar' then--日历
        set_Move_Frame(CalendarFrame)
        set_Move_Frame(CalendarEventPickerFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarTexturePickerFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarMassInviteFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarCreateEventFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarViewEventFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarViewHolidayFrame, {frame=CalendarFrame})
        set_Move_Frame(CalendarViewRaidFrame, {frame=CalendarFrame})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        set_Move_Frame(GarrisonShipyardFrame)--海军行动
        set_Move_Frame(GarrisonMissionFrame)--要塞任务
        set_Move_Frame(GarrisonCapacitiveDisplayFrame)--要塞订单
        set_Move_Frame(GarrisonLandingPage)--要塞报告
        set_Move_Frame(OrderHallMissionFrame)

    elseif arg1=='Blizzard_PlayerChoice' then
        set_Move_Frame(PlayerChoiceFrame)--任务选择

    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        set_Move_Frame(GuildBankFrame)

    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        set_Move_Frame(FlightMapFrame)

    elseif arg1=='Blizzard_OrderHallUI' then
        set_Move_Frame(OrderHallTalentFrame)

    elseif arg1=='Blizzard_GenericTraitUI' then--欲龙术
        set_Move_Frame(GenericTraitFrame)
        set_Move_Frame(GenericTraitFrame.ButtonsParent, {frame=GenericTraitFrame})

    elseif arg1=='Blizzard_WeeklyRewards' then--'Blizzard_EventTrace' then--周奖励面板
        set_Move_Frame(WeeklyRewardsFrame)
        set_Move_Frame(WeeklyRewardsFrame.Blackout, {frame=WeeklyRewardsFrame})

    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        set_Move_Frame(ItemSocketingFrame)
    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面
        set_Move_Frame(ItemUpgradeFrame)

    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        if InspectFrame then
            set_Move_Frame(InspectFrame)
        end

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插件, 界面
        set_Move_Frame(ChallengesKeystoneFrame, {save=true})

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换
        set_Move_Frame(ItemInteractionFrame)

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then--专业定制
        set_Move_Frame(ProfessionsCustomerOrdersFrame)

    elseif arg1=='Blizzard_VoidStorageUI' then--虚空，仓库
         set_Move_Frame(VoidStorageFrame)

    elseif arg1=='Blizzard_ChromieTimeUI' then--时光漫游
        set_Move_Frame(ChromieTimeFrame)

    elseif arg1=='Blizzard_TrainerUI' then--专业训练师
        set_Move_Frame(ClassTrainerFrame)

    elseif arg1=='Blizzard_BFAMissionUI' then--侦查地图
        set_Move_Frame(BFAMissionFrame)

    elseif arg1=='Blizzard_MacroUI' then--宏
        set_Move_Frame(MacroFrame)

    elseif arg1=='Blizzard_MajorFactions' then--派系声望
        set_Move_Frame(MajorFactionRenownFrame)

    elseif arg1=='Blizzard_DebugTools' then--FSTACK
        set_Move_Frame(TableAttributeDisplay)

    elseif arg1=='Blizzard_EventTrace' then--ETRACE
        set_Move_Frame(EventTrace, {notZoom=true, save=true})
    end
end

--###########
--职业，能量条
--###########
local function set_classPowerBar()
    local tab={
        PlayerFrame.classPowerBar,
        RuneFrame,
        MonkStaggerBar,
        PlayerFrameAlternateManaBar,
        --MageArcaneChargesFrame,
        --TotemFrame,
    }

    for _, self in pairs(tab) do
        if self and self:IsShown() then
            if self.FrameName then
                set_Frame_Point(self)
            else
                set_Move_Frame(self, {save=true, zeroAlpha=true})
            end
        end
    end

    if TotemFrame and TotemFrame:IsShown() and TotemFrame.totemPool and TotemFrame.totemPool.activeObjects then
        for btn, _ in pairs(TotemFrame.totemPool.activeObjects) do
            if btn:IsShown() then
                if btn.FrameName then
                    set_Frame_Point(btn)
                else
                    set_Move_Frame(btn, {frame=TotemFrame, save=true, zeroAlpha=true})
                end
            end
        end
    end
end



--########
--初始,移动
--########
local function Init_Move()
    local FrameTab={
        AddonList={},--插件
        GameMenuFrame={save=true,},--菜单
        ProfessionsFrame={},--专业
        InspectRecipeFrame={},

        CharacterFrame={},--角色
        ReputationDetailFrame={save=true},--声望描述q
        TokenFramePopup={save=true},--货币设置
        SpellBookFrame={},--法术书
        PVEFrame={},--地下城和团队副本
        HelpFrame={},--客服支持
        MacroFrame={},--宏
        ExtraActionButton1={click='R',  },--额外技能
        ChatConfigFrame={save=true},--聊天设置
        SettingsPanel={},--选项

        FriendsFrame={},--好友列表
        RaidInfoFrame={frame=FriendsFrame},

        GossipFrame={},
        QuestFrame={},
        PetStableFrame={},--猎人，宠物
        BankFrame={save=true},--银行
        MerchantFrame={},--货物

        WorldMapFrame={},--世界地图
        MapQuestInfoRewardsFrame={frame= WorldMapFrame},

        ContainerFrameCombinedBags={save=true},--{notZoom=true},--包
        VehicleSeatIndicator={},--车辆，指示
        ExpansionLandingPage={},--要塞

        PlayerPowerBarAlt={},--UnitPowerBarAlt.lua
        MailFrame={},
        SendMailFrame={frame= MailFrame},
        OpenMailFrame={},
        MirrorTimer1={save=true},

        GroupLootHistoryFrame={},

        ChannelFrame={},--聊天设置

        ColorPickerFrame={save=true, click='R'},--颜色选择器
    }

    for k, v in pairs(FrameTab) do
        if v then
            local f= _G[k]
            if f then
                set_Move_Frame(f, v)
            end
        end
    end
    for text, _ in pairs(UIPanelWindows) do
       local frame=_G[text]
       if frame and not FrameTab[frame] then
            set_Move_Frame(_G[text])
       end
    end
    FrameTab=nil

    created_Move_Button(ZoneAbilityFrame, {frame=ZoneAbilityFrame.SpellButtonContainer, save=true})

    --专业
    InspectRecipeFrame:HookScript('OnShow', function(self)
        local name= self:GetName()
        if name and Save.scale[name] then
            self:SetScale(Save.scale[name])
        end
    end)

    --########
    --小，背包
    --########
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if i==1 then
                set_Move_Frame(frame, {save=true})
            else
                set_Move_Frame(frame)
            end
        end
    end

    hooksecurefunc('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            local name= frame and frame:GetName()
            if name then
                if frame.ZoomInOutFrame and Save.scale[name] and Save.scale[name]~=1 then--缩放
                    frame:SetScale(Save.scale[name])
                end
                if (frame==ContainerFrameCombinedBags or frame==ContainerFrame1) then--位置
                    set_Frame_Point(frame, name)--设置, 移动, 位置
                elseif frame==ContainerFrame1 then
                    set_Frame_Point(frame, name)--设置, 移动, 位置
                end
            end
        end
    end)


    if UIWidgetPowerBarContainerFrame then--移动, 能量条
        created_Move_Button(UIWidgetPowerBarContainerFrame, {})

       local tab= UIWidgetPowerBarContainerFrame.widgetFrames or {}
        local find=false
        for widgetID,_ in pairs(tab) do
            if widgetID then
                find=true
                break
            end
        end
        if UIWidgetPowerBarContainerFrame.ZoomInOutFrame or UIWidgetPowerBarContainerFrame.moveButton then--and frame.ZoomOut then
            if UIWidgetPowerBarContainerFrame.moveButton then
                UIWidgetPowerBarContainerFrame.moveButton:SetShown(find)
            end
            if UIWidgetPowerBarContainerFrame.ZoomInOutFrame then
                UIWidgetPowerBarContainerFrame.ZoomInOutFrame:SetShown(find)
            end
            hooksecurefunc(UIWidgetPowerBarContainerFrame, 'RemoveWidget', function(self, widgetID)--Blizzard_UIWidgetManager.lua frame.ZoomOut:SetShown(find)
                if self.ZoomInOutFrame then
                    self.ZoomInOutFrame:SetShown(false)
                end
                if self.moveButton then
                    self.moveButton:SetShown(false)
                end
            end)
            hooksecurefunc(UIWidgetPowerBarContainerFrame, 'CreateWidget', function(self)
                if self.ZoomInOutFrame then--and self.ZoomOut then
                    self.ZoomInOutFrame:SetShown(true)
                end
                if self.moveButton then
                    self.moveButton:SetShown(true)
                end
            end)
        end
    end


    hooksecurefunc('PlayerFrame_ToPlayerArt', function()
        C_Timer.After(0.5, set_classPowerBar)
    end)

    set_Move_Frame(LootFrame, {save=false})--物品拾取

    --################################
    --场景 self==ObjectiveTrackerFrame
    --Blizzard_ObjectiveTracker.lua ObjectiveTracker_GetVisibleHeaders()
    hooksecurefunc('ObjectiveTracker_Initialize', function(self)
        for _, module in ipairs(self.MODULES) do
            set_Move_Frame(module.Header, {frame=self, notZoom=true})
        end
        self:SetClampedToScreen(false)
    end)

    --if Save.SavePoint then--在指定位置,显示
    hooksecurefunc('UpdateUIPanelPositions',function(currentFrame)
        if not UnitAffectingCombat('player') then
            set_Frame_Point(currentFrame)
        end
    end)
    --end

    --职业，能量条
    if TotemFrame then
        TotemFrame:HookScript('OnEvent', function()
            set_classPowerBar()
        end)
    end
    panel:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
    panel:RegisterEvent('PLAYER_TALENT_UPDATE')

    C_Timer.After(2, function()
        created_Move_Button(QueueStatusButton, {save=true, notZoom=true, show=true})--小眼睛, 

        --编辑模式
        hooksecurefunc(EditModeManagerFrame, 'ExitEditMode', function()
            set_classPowerBar()--职业，能量条
            created_Move_Button(QueueStatusButton, {save=true, notZoom=true, show=true})--小眼睛, 
       end)
    end)
end

local function Init_Options()
    panel.check= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.check.Text:SetText('|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(e.onlyChinese and '移动' or NPE_MOVE))
    panel.check:SetPoint('TOPLEFT', 0, -48)
    panel.check:SetChecked(not Save.disabledMove)
    panel.check:SetScript('OnMouseDown', function()
        Save.disabledMove= not Save.disabledMove and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local checkPoint=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkPoint.Text:SetText(e.onlyChinese and '位置' or CHOOSE_LOCATION:gsub(CHOOSE , ''))
    checkPoint:SetPoint('LEFT', panel.check.Text, 'RIGHT',4,0)
    checkPoint:SetChecked(not Save.disabledZoom)
    checkPoint:SetScript('OnMouseDown', function()
        Save.SavePoint= not Save.SavePoint and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.disabledZoom), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local checkMoveToScreenFuori=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkMoveToScreenFuori.Text:SetText(e.onlyChinese and '可以移到屏幕外' or 'Can be moved off screen')
    checkMoveToScreenFuori:SetPoint('LEFT', checkPoint.Text, 'RIGHT',4,0)
    checkMoveToScreenFuori:SetChecked(Save.moveToScreenFuori)
    checkMoveToScreenFuori:SetScript('OnMouseDown', function()
        Save.moveToScreenFuori= not Save.moveToScreenFuori and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.disabledZoom), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local check2=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check2.Text:SetText('|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(e.onlyChinese and '缩放' or UI_SCALE))
    check2:SetPoint('TOPLEFT', panel.check, 'BOTTOMLEFT',0,-16)
    check2:SetChecked(not Save.disabledZoom)
    check2:SetScript('OnMouseDown', function()
        Save.disabledZoom= not Save.disabledZoom and true or nil
        print(id, addName, e.GetEnabeleDisable(not Save.disabledZoom), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local btn= e.Cbtn(panel, {atlas='bags-button-autosort-up', size={24,24}})
    btn:SetPoint('TOPLEFT', check2, 'BOTTOMLEFT',0,-16)
    btn:SetScript('OnClick', function()
        StaticPopupDialogs[id..addName..'MoveZoom']={
            text =id..' '..addName..'|n|n'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 )..' ('..(e.onlyChinese and '保存' or SAVE)..')',
            button1 = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移动' or NPE_MOVE),
            button2 = e.onlyChinese and '取消' or CANCEL,
            button3 = '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '缩放' or UI_SCALE),
            whileDead=true,
            timeout=60,
            hideOnEscape = true,
            OnAccept=function()
                Save.point={}
                print(id, addName, e.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
            end,
            OnAlt= function()
                Save.scale={}
                print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
            end,
        }
        StaticPopup_Show(id..addName..'MoveZoom')
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.scale= Save.scale or {}

            --添加控制面板CollectionsJournal
            panel.name= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..('框架' or addName)
            panel.parent= id
            InterfaceOptions_AddCategory(panel)

            e.ReloadPanel({panel=panel, addName= addName, restTips=true, checked= not Save.disabled, clearTips=nil,--重新加载UI, 重置, 按钮
                            disabledfunc=function()
                                            Save.disabled= not Save.disabled and true or nil
                                            if not Save.disabled and not panel.check then
                                                Init_Options()--初始, 选项
                                            end
                                            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                                        end,
                            clearfunc= function() Save=nil e.Reload() end}
                        )

            if not Save.disabled then
                Init_Options()--初始, 选项
                Init_Move()--初始, 移动
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        else
            setAddLoad(arg1)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[NPE_MOVE..'Frame']=nil--清除上版本内容
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if combatCollectionsJournal then
            set_Move_CollectionJournal()--藏品
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')

    elseif event=='UNIT_DISPLAYPOWER' or event=='PLAYER_TALENT_UPDATE' then
        C_Timer.After(0.5, set_classPowerBar)
    end
end)
--[[--缩放
    br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
]]