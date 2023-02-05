local id, e = ...
local Save={point={},}
local addName= NPE_MOVE..'Frame'
local panel= CreateFrame("Frame")

local Point=function(frame, name2)
    local p=Save.point
    p=p[name2]
    if p and p[1] and p[3] and p[4] and p[5] then
        frame:ClearAllPoints()
        frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    end
end

local Move=function(F, tab)
    tab=tab or {}
    local F2, click, save, enter, show,  re =tab.frame, tab.click, tab.save, tab.enter, tab.show, tab.re;--, tab.hook;    
    if not F2 and not F then
        return
    end
    local name;
    if F2 then
        name=F2:GetName();
        if not name and save then
            return true
        end
        if save then
            F2:SetClampedToScreen(true);
        end
        F2:SetMovable(true);
    else
        F2=F;
        name= F:GetName();
        if not name and save then
            return
        end
    end
    F:SetClampedToScreen(save and true or false);
    F:SetMovable(true);

    if click=='R' then
        F:RegisterForDrag("RightButton");
    elseif click=='L' then
        F:RegisterForDrag("LeftButton");
    else
        F:RegisterForDrag("LeftButton", "RightButton");
    end
    F:EnableMouse(true);
    F:SetScript("OnDragStart", function() F2:StartMoving() end);
    F:SetScript("OnDragStop", function()
            ResetCursor();
            F2:StopMovingOrSizing();
            if save then
                Save.point[name]={F2:GetPoint(1)}
                Save.point[name][2]=nil
            end;
    end);

    if save then
        Point(F2,name);
        local Re={}
        local n=F2:GetNumPoints()
        for i=1,n do
            table.insert(Re, {F2:GetPoint(i)})
        end
        F:SetScript("OnMouseUp", function(self,D)--还原 Alt+右击
                if D=='RightButton' and IsAltKeyDown() then
                    Save.point[name]=nil
                    F2:ClearAllPoints();
                    local point=Re[1]
                    if point then
                        F2:SetPoint(point[1], point[2], point[3], point[4], point[5]);
                    end
                end
                ResetCursor();
        end);
        if enter then
            F:SetScript("OnEnter", function() Point(F2,name) end);
        end
        if show  then
            F:SetScript("OnShow", function() Point(F2,name) end);
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
            SetCursor('UI_MOVE_CURSOR');
    end);
    F:SetScript("OnLeave", function() ResetCursor() end);
end

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
    ExtraActionButton1={click='R' },--额外技能
    ChatConfigFrame={save=true},--聊天设置
    SettingsPanel={},--选项
    UIWidgetPowerBarContainerFrame={},
    FriendsFrame={},--好友列表
    GossipFrame={},
    QuestFrame={},
    BlackMarketFrame={},--黑市
    BankFrame={save=true},--银行
    MerchantFrame={},--货物
    ClassTrainerFrame={},--专业训练师
    ColorPickerFrame={save=true},--颜色选择器
    BFAMissionFrame={},--侦查地图    
    WorldMapFrame={},--世界地图
    ContainerFrameCombinedBags={},--包
    VehicleSeatIndicator={},--车辆，指示
    ExpansionLandingPage={},--要塞
    --MainMenuBarBackpackButton={save=true, click='R', frame=MicroButtonAndBagsBar},--主菜单
    PlayerPowerBarAlt={},--UnitPowerBarAlt.lua
    MailFrame={},
    SendMailFrame={frame= MailFrame},
    MirrorTimer1={save=true},
    LootHistoryFrame= {},--拾取框
    --StoreFrame={},--商店
};
--UIWidgetBelowMinimapContainerFrame={save=true,click='RightButton'},

--#################
--禁用, 窗口,重置位置
--#################



local function setTabInit()
    for k, v in pairs(FrameTab) do
        if v then
            local f= _G[k];
            if f then
                Move(f, v);
                FrameTab[k]=nil
            end
        end
    end
end

local function setClass()--职业,能量条
    if e.Player.class== 'PALADIN' then
        local frame = PaladinPowerBarFrame;--圣骑士能量条, 
        if frame then
            Move(frame, {save=true})
            frame =PaladinPowerBarFrameBG if frame then frame:Hide() end
            frame=PaladinPowerBarFrameBankBG if frame then frame:Hide() end
        end

    elseif e.Player.class=='DEATHKNIGHT' then--DK符文
        Move(RuneFrame, {save=true})

    elseif e.Player.class=='MONK' then--WS
        local frame= MonkHarmonyBarFrame;--DPS
        if frame then
            if not frame.moveFrame then
                frame.moveFrame=CreateFrame('Frame', nil, frame);
                frame.moveFrame:SetSize(21, 21);
                frame.moveFrame:SetPoint('RIGHT', frame, 'LEFT');
                frame.moveFrame.textrue=frame.moveFrame:CreateTexture()
                frame.moveFrame.textrue:SetAllPoints(frame.moveFrame)
                frame.moveFrame.textrue:SetAtlas(e.Icon.icon)
                frame.moveFrame.textrue:SetShown(false)
                frame.moveFrame:SetScript('OnEnter', function(self2)
                    if not UnitAffectingCombat('player') then
                        self2.textrue:SetShown(true)
                        e.tips:ClearLines()
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine(NPE_MOVE, e.Icon.left)
                        e.tips:Show()
                    end
                end)
                Move(frame.moveFrame, {save=true, frame=frame})
                frame.moveFrame:SetScript('OnLeave', function(self2)
                    ResetCursor()
                    e.tips:Hide()
                    self2.textrue:SetShown(false)
                end)
            end
        end
        frame=MonkStaggerBar--T
        if frame then
            Move(frame, {save=true})
        end

    elseif e.Player.class=='WARLOCK' then--SS
        Move(WarlockPowerFrame, {save=true})

    elseif e.Player.class=='MAGE' then--Fs
        local frame=MageArcaneChargesFrame
        if frame then
            Move(frame, {save=true})
            if frame.Background then frame.Background:Hide() end
            frame:SetScale(0.7);--缩放
        end
    elseif e.Player.class=='ROGUE' or e.Player.class=='DRUID' then --DZ , XD        
        local frame=ComboPointPlayerFrame
        if frame then
            Move(frame, {save=true})
            UIParent.unit='player';
            if frame.Background then frame.Background:Hide() end

            if frame.ComboPoints then
                for i = 1, #frame.ComboPoints do
                    local self=frame.ComboPoints[i]
                    if self then
                        if self.PointOff then  self.PointOff:Hide() end--:SetAlpha(0) end
                        if self.CircleBurst then self.CircleBurst:Hide() end
                        if not self.tex then
                            self.tex=self:CreateTexture(nil, 'BACKGROUND');
                            local setFrame=self.Point or self
                            self.tex:SetPoint('BOTTOM', setFrame, 'BOTTOM',0,0);
                            self.tex:SetSize(12, 12);
                            self.tex:SetAtlas(e.Icon.number:format(i));
                        end
                    end
                end
            end
        end
    end
end

local combatCollectionsJournal--藏品
local function setAddLoad(arg1)
    if arg1=='Blizzard_AchievementUI' then--成就
        Move(AchievementFrame.Header,{frame=AchievementFrame})

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        Move(EncounterJournal, {})

    elseif arg1=='Blizzard_ClassTalentUI' then--天赋
        Move(ClassTalentFrame, {save=true})

    elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
        Move(AuctionHouseFrame, {})

    elseif arg1=='Blizzard_Communities' then--公会和社区
        local dialog = CommunitiesFrame.NotificationSettingsDialog or nil;
        if dialog then
            dialog:ClearAllPoints();
            dialog:SetAllPoints();
        end
        Move(CommunitiesFrame, {})

    elseif arg1=='Blizzard_Collections' then
        local checkbox = WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox;
        checkbox.Label:ClearAllPoints();
        checkbox.Label:SetPoint("LEFT", checkbox, "RIGHT", 2, 1);
        checkbox.Label:SetPoint("RIGHT", checkbox, "RIGHT", 160, 1);
        if not UnitAffectingCombat('player') then
            Move(CollectionsJournal, {})--藏品
            Move(WardrobeFrame, {})--幻化
        else
            combatCollectionsJournal=true
            panel:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    elseif arg1=='Blizzard_Calendar' then--日历
        Move(CalendarFrame, {})

    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        Move(GarrisonShipyardFrame,{})--海军行动
        Move(GarrisonMissionFrame, {})--要塞任务
        Move(GarrisonCapacitiveDisplayFrame, {})--要塞订单
        Move(GarrisonLandingPage, {})--要塞报告
        Move(OrderHallMissionFrame, {})
    elseif arg1=='Blizzard_PlayerChoice' then
        Move(PlayerChoiceFrame, {})--任务选择
    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        Move(GuildBankFrame.Emblem, {frame=GuildBankFrame})

    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        Move(FlightMapFrame, {})

    elseif arg1=='Blizzard_OrderHallUI' then
        Move(OrderHallTalentFrame,{})

    elseif arg1=='Blizzard_GenericTraitUI' then--欲龙术
        Move(GenericTraitFrame,{})
        Move(GenericTraitFrame.ButtonsParent,{frame=GenericTraitFrame})

    elseif arg1=='Blizzard_WeeklyRewards' then--'Blizzard_EventTrace' then--周奖励面板
        Move(WeeklyRewardsFrame, {})

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

    end
end


local function Init()
    if ZoneAbilityFrame and ZoneAbilityFrame.SpellButtonContainer then--区域，技能
        ZoneAbilityFrame.moveFrame=CreateFrame('Frame')
        ZoneAbilityFrame.moveFrame:SetPoint('CENTER', ZoneAbilityFrame.SpellButtonContainer, 'CENTER')
        ZoneAbilityFrame.moveFrame:SetSize(62, 62)--0, 52
        Move(ZoneAbilityFrame.moveFrame, {frame= ZoneAbilityFrame})
    end
--[[local tex= ZoneAbilityFrame.moveFrame:CreateTexture()
tex:SetAllPoints(ZoneAbilityFrame.moveFrame)
tex:SetAtlas('!perks-list-side-vertical')
-- Move(ZoneAbilityFrame.SpellButtonContainer, {click='R'})
]]

    setTabInit()

    --[[hooksecurefunc(LootFrame,'Open', function(self2)--物品拾取LootFrame.lua
        if not GetCVarBool("autoLootDefault") and not GetCVarBool("lootUnderMouse") then
            local p=Save.point.LootFrame and Save.point.LootFrame[1]
            if p and p[1] and p[3] and p[4] and p[5] then
                self2:ClearAllPoints();
                self2:SetPoint(p[1], nil, p[3], p[4], p[5]);
            end
        end
    end)
    Move(LootFrame.TitleContainer, {frame=LootFrame, save=true})--物品拾取
    ]]

    Move(DressUpFrame.TitleContainer, {frame = DressUpFrame})--试衣间    

    if QueueStatusButton then--小眼睛, 信息, 设置菜单,移动
        hooksecurefunc('QueueStatusDropDown_Show', function()
            UIDropDownMenu_AddSeparator()
            local info={
                text=NPE_MOVE..e.Icon.left,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=REQUIRES_RELOAD,
                tooltipText=id..'\n'..addName,
                func= function()
                    Move(QueueStatusButton, {save=true})
                    print(id, addName, '|cnGREEN_FONT_COLOR:'..REQUIRES_RELOAD..'|r', 'Alt+'..e.Icon.right..RESET_POSITION )
                end
            }
            UIDropDownMenu_AddButton(info)
        end)
        local p=Save.point['QueueStatusButton']
        if p and p[1] and p[3] and p[4] and p[5] then
            QueueStatusButton:ClearAllPoints()
            QueueStatusButton:SetPoint(p[1],UIParent, p[3], p[4], p[5])
        end
    end



    --########
    --小，背包
    --########
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if frame.TitleContainer then
                Move(frame.TitleContainer, {frame=frame})
            end
        end
    end
    --[[
    --移动，主菜单，背包提示
    hooksecurefunc(MainMenuBarBackpackButton, 'OnEnterInternal', function ()
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinse and '重置位置' or RESET_POSITION, 'alt+'..e.Icon.right)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)

    --###############################
    --修正，在战斗中，打开收藏界面，错误
    --###############################
    if not CollectionsJournal then
        ToggleCollectionsJournal(1)
        HideUIPanel(CollectionsJournal)
    end]]

    Move(MailFrame.TitleContainer,{frame=MailFrame})
end

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '框架移动' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if not Save.disabled then
                Init()
                setTabInit()
                setClass()--职业,能量条

            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif event=='ADDON_LOADED' then
                setAddLoad(arg1)
                setTabInit()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if combatCollectionsJournal then
            Move(CollectionsJournal, {})--藏品
            Move(WardrobeFrame, {})--幻化
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)
--[[
if UIPanelWindows[name] then
UIPanelWindows[name]=nil
end
]]