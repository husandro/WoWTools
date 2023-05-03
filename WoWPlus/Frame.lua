local id, e = ...
local Save={
        point={},--移动
        scale={UIWidgetPowerBarContainerFrame=0.85},--缩放
}
local addName= NPE_MOVE..'Frame'
local panel= CreateFrame("Frame")
local size= 16--放大， 缩小，移动，按钮大小
local classPowerFrame--职业，能量条

--####
--移动
--####
local Point=function(frame, name2)
    local p=Save.point
    p=p[name2]
    if p and p[1] and p[3] and p[4] and p[5] then
        frame:ClearAllPoints()
        frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    end
end

--####
--缩放
--####
local function show_Tips(frame, name, zeroAlpha)
    frame.name= name
    frame.alpha= zeroAlpha and 0 or 0.1
    frame:SetAlpha(frame.alpha)
    frame:SetScript("OnLeave", function(self) e.tips:Hide() self:SetAlpha(self.alpha) end)
    frame:SetScript("OnEnter",function(self)
        if UnitAffectingCombat('player') then
            return
        end
        self:SetAlpha(1)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        --e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE), Save.scale[self.name] or 1)
        e.tips:AddDoubleLine(e.onlyChinese and '放大' or ZOOM_IN, '|cff00ff00'..(Save.scale[self.name] or 1)..'|r '..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '缩小' or ZOOM_OUT, e.Icon.right)
        --e.tips:AddDoubleLine('Frame', self.name)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
end
local function ZoomFrame(self, notZoom, zeroAlpha)
    local name= (self and not notZoom and not Save.disabledZoom) and self:GetName()
    if not name then
        return
    end
    local frame= nil
    if self.moveButton then
        frame= self
        self.ZoomIn= e.Cbtn(frame, {icon='hide', size={size,size}})
        self.ZoomIn:SetPoint('RIGHT', self.moveButton, 'LEFT')

    elseif self.BorderFrame and self.BorderFrame.TitleContainer then
        frame= self.BorderFrame.TitleContainer
        self.ZoomIn= e.Cbtn(frame, {icon='hide', size={size,size}})--放大
        self.ZoomIn:SetPoint('LEFT',35,-2)

    elseif self.SpellButtonContainer then
        frame=self.SpellButtonContainer
        self.ZoomIn= e.Cbtn(frame, {icon='hide', size={size,size}})
        self.ZoomIn:SetPoint('BOTTOM', frame, 'TOP', -20,0)
        self.ZoomIn:SetFrameLevel(frame:GetFrameLevel()+7)

    elseif self.TitleContainer then
        frame= self.TitleContainer
        self.ZoomIn= e.Cbtn(frame, {icon='hide', size={size,size}})
        self.ZoomIn:SetPoint('LEFT',35,-2)

    elseif self.Header then
        frame= self.Header
        self.ZoomIn= e.Cbtn(frame, {icon='hide', size={size,size}})
        self.ZoomIn:SetPoint('LEFT')
    else
        frame= self
        self.ZoomIn= e.Cbtn(frame, {icon='hide', size={size,size}})
        self.ZoomIn:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT')
        self.ZoomIn:SetFrameLevel(frame:GetFrameLevel()+7)
    end

    self.ZoomIn:SetNormalAtlas('UI-HUD-Minimap-Zoom-In')
    self.ZoomIn:SetScript('OnClick', function(self2,d)
        local n= Save.scale[self2.name] or self:GetScale() or 1
        if d=='LeftButton' then
            n= n+ 0.05
        elseif d=='RightButton' then
            n= n- 0.05
        end
        n= n>2 and 2 or n
        n= n< 0.5 and 0.5 or n
        Save.scale[self2.name]= n
        self:SetScale(n)
    end)

    --[[self.ZoomOut= e.Cbtn(frame, {icon='hide', size={size,size}})--缩小
    self.ZoomOut:SetFrameLevel(self.ZoomIn:GetFrameLevel())
    if self.moveButton then
        self.ZoomOut:SetPoint('LEFT',self.moveButton, 'RIGHT')
    else
        self.ZoomOut:SetPoint('LEFT',self.ZoomIn, 'RIGHT')
    end
    self.ZoomOut:SetNormalAtlas('UI-HUD-Minimap-Zoom-Out')
    self.ZoomOut:SetScript('OnMouseDown', function(self2)
        local n= Save.scale[self2.name] or self:GetScale() or 1
        n= n- 0.05
        n= n< 0.5 and 0.5 or n
        Save.scale[self2.name]= n
        self:SetScale(n)
    end)]]

    show_Tips(self.ZoomIn, name, zeroAlpha)
    --show_Tips(self.ZoomOut, name, zeroAlpha)

    if Save.scale[name] and Save.scale[name]~=1 then
        self:SetScale(Save.scale[name])
    end
end

--[[####################
--大小， 加个，三角图标
--###################
local function set_Size(self, tab)
    if tab.size  and self then
        self.Sizing= e.Cbtn(self, {size={15,15}})
        self.Sizing:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        self.Sizing:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        self.Sizing:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        self.Sizing:SetPoint('TOP', self, 'BOTTOM')
        
        self.Sizing:SetScript("OnDragStart", function(self2)
            self2:GetParent():StartSizing() --'bottomleft'
        end)
        self.Sizing:SetScript("OnDragStop", function(self2)
            local frame=self2:GetParent()
            ResetCursor()
            frame:StopMovingOrSizing()
        end)
        self.Sizing:RegisterForDrag("LeftButton", 'RightButton')
        self:SetMovable(true)
        self.Sizing:SetMovable(true)
    end
end
set_Size(WorldMapFrame, {size=true})]]
--####
--移动
--####
local Move=function(F, tab)
    tab=tab or {}
    local F2, click, save, enter, show,  re =tab.frame, tab.click, tab.save, tab.enter, tab.show, tab.re --, tab.hook 
    if not F then
        return
    end
    local name
    if F2 then
        name=F2:GetName()
        if not name and save then
            return true
        end
        if save then
            F2:SetClampedToScreen(true)
        end
        F2:SetMovable(true)
    else
        F2=F
        name= F:GetName()
        if not name and save then
            return
        end
    end
    F:SetClampedToScreen(save and true or false)
    F:SetMovable(true)

    if click=='R' then
        F:RegisterForDrag("RightButton")
    elseif click=='L' then
        F:RegisterForDrag("LeftButton")
    else
        F:RegisterForDrag("LeftButton", "RightButton")
    end
    F:EnableMouse(true)
    F:SetScript("OnDragStart", function() F2:StartMoving() end)
    F:SetScript("OnDragStop", function(self2)
            ResetCursor()
            F2:StopMovingOrSizing()
            if save then
                Save.point[name]={F2:GetPoint(1)}
                Save.point[name][2]=nil
            end
    end)

    if save then
        Point(F2,name)
        local Re={}
        local n=F2:GetNumPoints()
        for i=1,n do
            table.insert(Re, {F2:GetPoint(i)})
        end
        F:SetScript("OnMouseUp", function(self,D)--还原 Alt+右击
                if D=='RightButton' and IsAltKeyDown() then
                    Save.point[name]=nil
                    F2:ClearAllPoints()
                    local point=Re[1]
                    if point then
                        F2:SetPoint(point[1], point[2], point[3], point[4], point[5])
                    end
                end
                ResetCursor()
        end)
        if enter then
            F:SetScript("OnEnter", function() Point(F2,name) end)
        end
        if show  then
            F:SetScript("OnShow", function() Point(F2,name) end)
        end

    end
    if re then
        F2:SetResizable(true)
    end
    F:SetScript("OnMouseDown", function(self,d)
            if IsModifierKeyDown()
            or (click=='R' and d~='RightButton')
            or (click=='L' and d~='LeftButton')
            then return end
            SetCursor('UI_MOVE_CURSOR')
    end)
    F:SetScript("OnLeave", function() ResetCursor() end)

    ZoomFrame(F2, tab.notZoom, tab.zeroAlpha)


end

local function set_Move_Button(frame, tab)
    tab= tab or {}
    local pointFrame, save, zeroAlpha, notZoom= tab.frame, tab.save, tab.zeroAlpha, tab.notZoom
    if frame then
        if not frame.moveButton then
            frame.moveButton= e.Cbtn(frame, {icon='hide', size={size,size}})
            frame.moveButton:SetPoint('BOTTOM', pointFrame or frame, 'TOP')--,0,-13)
            frame.moveButton:SetFrameLevel(frame:GetFrameLevel()+5)
            frame.moveButton:SetNormalTexture('Interface\\Cursor\\UI-Cursor-Move')
            frame.moveButton.alpha= zeroAlpha and 0 or 0.1
            frame.moveButton:SetAlpha(frame.moveButton.alpha)
            frame.moveButton:SetScript("OnEnter",function(self)
                if UnitAffectingCombat('player') then
                    return
                end
                self:SetAlpha(1)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, tab.click=='R' and e.Icon.right or e.Icon.left)
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            Move(frame.moveButton, {frame= frame, save=save, zeroAlpha= zeroAlpha, notZoom= notZoom})
            frame.moveButton:SetScript("OnLeave", function(self) ResetCursor() e.tips:Hide() self:SetAlpha(self.alpha) end)
        else
            local name= frame:GetName()
            if name then
                Point(frame, name)
            end
        end
    end
end



local combatCollectionsJournal--藏品
local function set_Move_CollectionJournal()--藏品
    Move(CollectionsJournal, {})--藏品
    Move(RematchJournal, {frame=CollectionsJournal})--藏品
    Move(WardrobeFrame, {})--幻化
end

local function setAddLoad(arg1)
    if arg1=='Blizzard_TimeManager' then--小时图，时间
        Move(TimeManagerFrame,{})

    elseif arg1=='Blizzard_AchievementUI' then--成就
        Move(AchievementFrame.Header,{frame=AchievementFrame})
        Move(AchievementFrame,{})

        Move(AchievementFrameComparisonHeader, {frame=AchievementFrame})

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        Move(EncounterJournal, {})

    elseif arg1=='Blizzard_ClassTalentUI' then--天赋
        local frame=ClassTalentFrame
        if frame then
            Move(frame, {save=true})
            if frame.TalentsTab and frame.TalentsTab.ButtonsParent then
                Move(frame.TalentsTab.ButtonsParent,{save=true, frame=frame})--里面, 背景
            end
            if frame.ZoomIn then
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
            --专精 UpdateSpecFrame
            --Blizzard_ClassTalentSpecTab.lua
            if frame.SpecTab and frame.SpecTab.SpecContentFramePool then
                for specContentFrame in frame.SpecTab.SpecContentFramePool:EnumerateActive() do
                    Move(specContentFrame, {frame= frame, save=true})
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
        Move(AuctionHouseFrame, {})

    elseif arg1=='Blizzard_BlackMarketUI' then--黑市
        Move(BlackMarketFrame, {})

    elseif arg1=='Blizzard_Communities' then--公会和社区
        --[[local dialog = CommunitiesFrame.NotificationSettingsDialog or nil
        if dialog then
            dialog:ClearAllPoints()
            dialog:SetAllPoints()
        end--]]
        Move(CommunitiesFrame, {})

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
        Move(CalendarFrame, {})
        Move(CalendarEventPickerFrame, {frame=CalendarFrame})
        Move(CalendarTexturePickerFrame, {frame=CalendarFrame})
        Move(CalendarMassInviteFrame, {frame=CalendarFrame})
        Move(CalendarCreateEventFrame, {frame=CalendarFrame})
        Move(CalendarViewEventFrame, {frame=CalendarFrame})
        Move(CalendarViewHolidayFrame, {frame=CalendarFrame})
        Move(CalendarViewRaidFrame, {frame=CalendarFrame})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        Move(GarrisonShipyardFrame,{})--海军行动
        Move(GarrisonMissionFrame, {})--要塞任务
        Move(GarrisonCapacitiveDisplayFrame, {})--要塞订单
        Move(GarrisonLandingPage, {})--要塞报告
        Move(OrderHallMissionFrame, {})

    elseif arg1=='Blizzard_PlayerChoice' then
        Move(PlayerChoiceFrame, {})--任务选择

    elseif arg1=="Blizzard_GuildBankUI" then--公会银行--Move(GuildBankFrame.Emblem, {frame=GuildBankFrame})
        Move(GuildBankFrame, {})

    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        Move(FlightMapFrame, {})

    elseif arg1=='Blizzard_OrderHallUI' then
        Move(OrderHallTalentFrame,{})

    elseif arg1=='Blizzard_GenericTraitUI' then--欲龙术
        Move(GenericTraitFrame,{})
        Move(GenericTraitFrame.ButtonsParent,{frame=GenericTraitFrame})

    elseif arg1=='Blizzard_WeeklyRewards' then--'Blizzard_EventTrace' then--周奖励面板
        Move(WeeklyRewardsFrame, {})
        Move(WeeklyRewardsFrame.Blackout, {frame=WeeklyRewardsFrame})

    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        Move(ItemSocketingFrame,{})
        if ItemSocketingFrame.TitleContainer then
            Move(ItemSocketingFrame.TitleContainer, {frame=ItemSocketingFrame})
        end

    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面
        if ItemUpgradeFrame then
            if ItemUpgradeFrame.TitleContainer then
                Move(ItemUpgradeFrame.TitleContainer,{frame=ItemUpgradeFrame})
            end
            Move(ItemUpgradeFrame,{})
        end

    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        if InspectFrame then
            if InspectFrame.TitleContainer then
                Move(InspectFrame.TitleContainer,{frame=InspectFrame})
            end
            Move(InspectFrame,{})
        end

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插件, 界面
        Move(ChallengesKeystoneFrame, {save=true})

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换
        Move(ItemInteractionFrame, {})

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then--专业定制
        Move(ProfessionsCustomerOrdersFrame, {})

    elseif arg1=='Blizzard_VoidStorageUI' then--虚空，仓库
         Move(VoidStorageFrame, {})

    elseif arg1=='Blizzard_ChromieTimeUI' then--时光漫游
        Move(ChromieTimeFrame, {})

    elseif arg1=='Blizzard_TrainerUI' then--专业训练师
        Move(ClassTrainerFrame, {})

    elseif arg1=='Blizzard_BFAMissionUI' then--侦查地图
        Move(BFAMissionFrame, {})

    elseif arg1=='Blizzard_MacroUI' then--宏
        Move(MacroFrame, {})

    elseif arg1=='Blizzard_MajorFactions' then--派系声望
        Move(MajorFactionRenownFrame, {})
        Move(MajorFactionRenownFrame.HeaderFrame, {frame=MajorFactionRenownFrame})

    elseif arg1=='Blizzard_DebugTools' then--FSTACK
        Move(TableAttributeDisplay.TitleButton, {frame= TableAttributeDisplay})
        Move(TableAttributeDisplay,{})

    elseif arg1=='Blizzard_EventTrace' then--ETRACE
        Move(EventTrace.TitleContainer, {frame=EventTrace, notZoom=true})
        Move(EventTrace, {notZoom=true, save=true})
    end
end


local function Init_Move()
    local FrameTab={
        AddonList={},--插件
        GameMenuFrame={save=true,},--菜单
        ProfessionsFrame={},--专业
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
        --UIWidgetPowerBarContainerFrame={},

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
        --MainMenuBarBackpackButton={save=true, click='R', frame=MicroButtonAndBagsBar},--主菜单
        PlayerPowerBarAlt={},--UnitPowerBarAlt.lua
        MailFrame={},
        SendMailFrame={frame= MailFrame},
        MirrorTimer1={save=true},
        --LootHistoryFrame= {},--拾取框
        GroupLootHistoryFrame={},
        --EncounterBar={},
        --[StoreFrame.TitleContainer]={frame=StoreFrame},--商店
        ChannelFrame={},--聊天设置
        --StaticPopup1={},
        [DressUpFrame.TitleContainer]= {frame = DressUpFrame},--试衣间 
        [MailFrame.TitleContainer]= {frame=MailFrame},
        ColorPickerFrame={save=true, click='R'},--颜色选择器
    }

    for k, v in pairs(FrameTab) do
        if v then
            local f= _G[k]
            if f then
                Move(f, v)
                FrameTab[k]=nil
            end
        end
    end

    set_Move_Button(ZoneAbilityFrame, {frame=ZoneAbilityFrame.SpellButtonContainer, save=true, zeroAlpha=nil, notZoom=nil})
    set_Move_Button(QueueStatusButton, {frame=nil, save=false, zeroAlpha=true, notZoom=true})--小眼睛, 


    --########
    --小，背包
    --########
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if frame.TitleContainer then
                if i==1 then
                    Move(frame.TitleContainer, {frame=frame, save=true})
                    Move(frame, {save=true})
                else
                    Move(frame.TitleContainer, {frame=frame})
                    Move(frame, {})
                end
            end
        end
    end
    hooksecurefunc('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            local name= frame and frame:GetName()
            if name then
                if frame.ZoomIn and Save.scale[name] and Save.scale[name]~=1 then--缩放
                    frame:SetScale(Save.scale[name])
                end
                if (frame==ContainerFrameCombinedBags or frame==ContainerFrame1) then--位置
                    Point(frame, name)
                elseif frame==ContainerFrame1 then
                    Point(frame, name)
                end
            end
        end
    end)


    if UIWidgetPowerBarContainerFrame then--移动, 能量条
        local frame=UIWidgetPowerBarContainerFrame
        set_Move_Button(frame, {frame=nil, save=nil, zeroAlpha=nil, notZoom=nil})

        local tab= frame.widgetFrames or {}
        local find
        for widgetID,_ in pairs(tab) do
            if widgetID then
                find=true
                break
            end
        end
        frame.moveButton:SetShown(find)

        if frame.ZoomIn then--and frame.ZoomOut then
            frame.ZoomIn:SetShown(find)
            --frame.ZoomOut:SetShown(find)
            --显示, 隐藏, 缩放
            --Blizzard_UIWidgetManager.lua
            hooksecurefunc(frame, 'RemoveWidget', function(self, widgetID)
                if self.ZoomIn then--and self.ZoomOut then
                    self.ZoomIn:SetShown(false)
                    --self.ZoomOut:SetShown(false)
                end
                if self.moveButton then
                    self.moveButton:SetShown(false)
                end
            end)
            hooksecurefunc(frame, 'CreateWidget', function(self)
                if self.ZoomIn then--and self.ZoomOut then
                    self.ZoomIn:SetShown(true)
                    --self.ZoomOut:SetShown(true)
                end
                if self.moveButton then
                    self.moveButton:SetShown(true)
                end
            end)
        end
    end

    --职业,能量条
    if PlayerFrame.classPowerBar then--PlayerFrame.lua
        classPowerFrame= PlayerFrame.classPowerBar
    elseif (e.Player.class == "SHAMAN") then
        classPowerFrame= TotemFrame
    elseif (e.Player.class == "DEATHKNIGHT") then
        classPowerFrame= RuneFrame
    elseif (e.Player.class == "PRIEST") then
        classPowerFrame= PriestBarFrame
    end
    if classPowerFrame then
        panel:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
        C_Timer.After(2, function()
            set_Move_Button(classPowerFrame, {frame=nil, save=true, zeroAlpha=true, notZoom=nil})
        end)
        hooksecurefunc('PlayerFrame_ToPlayerArt', function()
            C_Timer.After(0.5, function()
                set_Move_Button(classPowerFrame, {frame=nil, save=true, zeroAlpha=true, notZoom=nil})
            end)
        end)
    end

    --[[hooksecurefunc(LootFrame,'Open', function(self2)--物品拾取LootFrame.lua
        if not GetCVarBool("autoLootDefault") and not GetCVarBool("lootUnderMouse") then
            local p=Save.point.LootFrame and Save.point.LootFrame[1]
            if p and p[1] and p[3] and p[4] and p[5] then
                self2:ClearAllPoints()
                self2:SetPoint(p[1], nil, p[3], p[4], p[5])
            end
        end
    end)]]
    Move(LootFrame.TitleContainer, {frame=LootFrame, save=false})--物品拾取
    Move(LootFrame, {save=false})--物品拾取

    --场景 
    C_Timer.After(2, function()
        if ObjectiveTrackerFrame and ObjectiveTrackerFrame.MODULES then--Blizzard_ObjectiveTracker.lua ObjectiveTracker_GetVisibleHeaders()
            for _, module in ipairs(ObjectiveTrackerFrame.MODULES) do
                local header = module.Header;
                Move(header, {frame=ObjectiveTrackerFrame, notZoom=true})
            end
        end
        ObjectiveTrackerFrame:SetClampedToScreen(false)
    end)
    --[[Move(ObjectiveTrackerBlocksFrame.ScenarioHeader, {frame=ObjectiveTrackerFrame, notZoom=true})
    Move(ObjectiveTrackerBlocksFrame.AchievementHeader, {frame=ObjectiveTrackerFrame, notZoom=true})
    Move(ObjectiveTrackerBlocksFrame.QuestHeader, {frame=ObjectiveTrackerFrame, zeroAlpha=true, notZoom=true})
    Move(ObjectiveTrackerBlocksFrame.CampaignQuestHeader, {frame=ObjectiveTrackerFrame, notZoom=true})
    Move(ObjectiveTrackerBlocksFrame.ProfessionHeader, {frame=ObjectiveTrackerFrame, notZoom=true})
    Move(ObjectiveTrackerBlocksFrame.MonthlyActivitiesHeader, {frame=ObjectiveTrackerFrame, notZoom=true})]]
    
end

local function set_PopupDialogs()
    StaticPopupDialogs[id..addName..'MoveZoom']={
        text =id..' '..addName..'\n\n'..(e.onlyChinese and '清除全部' or REMOVE_WORLD_MARKERS)..' ('..(e.onlyChinese and '保存' or SAVE)..')'..'\n\n|cnRED_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI),
        button1 = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移动' or NPE_MOVE),
        button2 = e.onlyChinese and '取消' or CANCEL,
        button3 = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '缩放' or UI_SCALE),
        whileDead=true,
        timeout=60,
        hideOnEscape = true,
        OnAccept=function(self,data)
            Save.point={}
            e.Reload()
        end,
        OnAlt= function()
            Save.scale={}
            e.Reload()
        end,
    }
    StaticPopup_Show(id..addName..'MoveZoom')
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

            --添加控制面板        
            local check=e.CPanel('|A:communities-chat-icon-plus:0:0|a'..(e.onlyChinese and '框架移动' or addName), not Save.disabled)
            check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                if Save.disabled then
                    panel.check2.text:SetText('|cff808080'..(e.onlyChinese and '缩放' or UI_SCALE))
                else
                    panel.check2.text:SetText(e.onlyChinese and '缩放' or UI_SCALE)
                end
            end)

            panel.check2=CreateFrame("CheckButton", nil, check, "InterfaceOptionsCheckButtonTemplate")
            panel.check2.text:SetText(e.onlyChinese and '缩放' or UI_SCALE)
            panel.check2:SetPoint('LEFT', check.text, 'RIGHT')
            panel.check2:SetChecked(not Save.disabledZoom)
            panel.check2:SetScript('OnMouseDown', function()
                Save.disabledZoom= not Save.disabledZoom and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabledZoom), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            local button= e.Cbtn(check, {icon='hide', size={20,20}})
            button:SetPoint('LEFT', panel.check2.text, 'RIGHT',2,0)
            button:SetNormalAtlas('bags-button-autosort-up')
            button:SetScript('OnClick', set_PopupDialogs)

            if not Save.disabled then
                Init_Move()--移动
            else
                panel.check2.text:SetText('|cff808080'..(e.onlyChinese and '缩放' or UI_SCALE))
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        else
            setAddLoad(arg1)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if combatCollectionsJournal then
            set_Move_CollectionJournal()--藏品
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')

    elseif event=='UNIT_DISPLAYPOWER' then
        set_Move_Button(classPowerFrame, {frame=nil, save=true, zeroAlpha=true, notZoom=nil})
    end
end)
--[[--缩放
    br:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    br:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    br:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
]]