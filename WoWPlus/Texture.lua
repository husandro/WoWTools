local id, e= ...
local addName=HIDE..TEXTURES_SUBHEADER
local Save={
    --disabledTexture= true,
    disabledAlpha= not e.Player.husandro,
    disabledColor= not e.Player.husandro,
    alpha= 0.5,
}
local panel=CreateFrame("Frame")


local function hideTexture(self)
    if self then
        self:SetTexture(0)
        self:SetShown(false)
    end
end
local function setAlpha(self)
    if self then
        if not Save.disabledAlpha then
            self:SetAlpha(Save.alpha)
        end
        if not Save.disabledColor then
            self:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
        end
    end
end


--###############
--初始化, 隐藏材质
--###############
local function Init_HideTexture()
    if Save.disabledTexture then
        return
    end
    hooksecurefunc('PlayerFrame_UpdateArt', function()--隐藏材质, 载具
        if OverrideActionBarEndCapL then
            hideTexture(OverrideActionBarEndCapL)
            hideTexture(OverrideActionBarEndCapR)
            hideTexture(OverrideActionBarBorder)
            hideTexture(OverrideActionBarBG)
            hideTexture(OverrideActionBarButtonBGMid)
            hideTexture(OverrideActionBarButtonBGR)
            hideTexture(OverrideActionBarButtonBGL)
        end
        if OverrideActionBarMicroBGMid then
            hideTexture(OverrideActionBarMicroBGMid)
            hideTexture(OverrideActionBarMicroBGR)
            hideTexture(OverrideActionBarMicroBGL)
            hideTexture(OverrideActionBarLeaveFrameExitBG)

            hideTexture(OverrideActionBarDivider2)
            hideTexture(OverrideActionBarLeaveFrameDivider3)
        end
        if OverrideActionBarExpBar then
            hideTexture(OverrideActionBarExpBarXpMid)
            hideTexture(OverrideActionBarExpBarXpR)
            hideTexture(OverrideActionBarExpBarXpL)
        end
    end)
    if ExtraActionButton1 then hideTexture(ExtraActionButton1.style) end--额外技能
    if ZoneAbilityFrame then hideTexture(ZoneAbilityFrame.Style) end--区域技能

    if MainMenuBar and MainMenuBar.EndCaps then hideTexture(MainMenuBar.EndCaps.LeftEndCap) end
    if MainMenuBar and MainMenuBar.EndCaps then hideTexture(MainMenuBar.EndCaps.RightEndCap) end

    if PetBattleFrame then--宠物
        hideTexture(PetBattleFrame.TopArtLeft)
        hideTexture(PetBattleFrame.TopArtRight)
        hideTexture(PetBattleFrame.TopVersus)
        PetBattleFrame.TopVersusText:SetText('')
        PetBattleFrame.TopVersusText:SetShown(false)
        hideTexture(PetBattleFrame.WeatherFrame.BackgroundArt)

        hideTexture(PetBattleFrameXPBarLeft)
        hideTexture(PetBattleFrameXPBarRight)
        hideTexture(PetBattleFrameXPBarMiddle)
        if PetBattleFrame.BottomFrame then
            hideTexture(PetBattleFrame.BottomFrame.LeftEndCap)
            hideTexture(PetBattleFrame.BottomFrame.RightEndCap)
            hideTexture(PetBattleFrame.BottomFrame.Background)
            hideTexture(PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2)
            PetBattleFrame.BottomFrame.FlowFrame:SetShown(false)
            PetBattleFrame.BottomFrame.Delimiter:SetShown(false)
        end
    end

    hooksecurefunc('PetBattleFrame_UpdatePassButtonAndTimer', function(self)--Blizzard_PetBattleUI.lua
        hideTexture(self.BottomFrame.TurnTimer.TimerBG)
        --self.BottomFrame.TurnTimer.Bar:SetShown(true);
        hideTexture(self.BottomFrame.TurnTimer.ArtFrame);
        hideTexture(self.BottomFrame.TurnTimer.ArtFrame2);
    end)

    hooksecurefunc(HelpTip,'Show', function(self, parent, info, relativeRegion)--隐藏所有HelpTip HelpTip.lua
        HelpTip:HideAll(parent)
    end)

    C_CVar.SetCVar("showNPETutorials",'0')

    --Blizzard_TutorialPointerFrame.lua 隐藏, 新手教程
    hooksecurefunc(TutorialPointerFrame, 'Show',function(self, content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution)
        if not anchorFrame or not self.DirectionData[direction] then
            return
        end
        local ID=self.NextID
        if ID then
            C_Timer.After(2, function()
                TutorialPointerFrame:Hide(ID-1)
                print(id, addName, '|cffff00ff'..content)
            end)
        end
    end)

    if MainMenuBar and MainMenuBar.BorderArt then--主动作条
        hideTexture(MainMenuBar.BorderArt.TopEdge)
        hideTexture(MainMenuBar.BorderArt.BottomEdge)
        hideTexture(MainMenuBar.BorderArt.LeftEdge)
        hideTexture(MainMenuBar.BorderArt.RightEdge)
        hideTexture(MainMenuBar.BorderArt.TopLeftCorner)
        hideTexture(MainMenuBar.BorderArt.BottomLeftCorner)
        hideTexture(MainMenuBar.BorderArt.TopRightCorner)
        hideTexture(MainMenuBar.BorderArt.BottomRightCorner)
    end
    if MultiBarBottomLeftButton10 then hideTexture(MultiBarBottomLeftButton10.SlotBackground) end

     if CompactRaidFrameManager then--隐藏, 团队, 材质 Blizzard_CompactRaidFrameManager.lua
        hideTexture(CompactRaidFrameManagerBorderTop)
        hideTexture(CompactRaidFrameManagerBorderRight)
        hideTexture(CompactRaidFrameManagerBorderBottom)
        hideTexture(CompactRaidFrameManagerBorderTopRight)
        hideTexture(CompactRaidFrameManagerBorderTopLeft)
        hideTexture(CompactRaidFrameManagerBorderBottomLeft)
        hideTexture(CompactRaidFrameManagerBorderBottomRight)
        hideTexture(CompactRaidFrameManagerDisplayFrameHeaderDelineator)
        hideTexture(CompactRaidFrameManagerDisplayFrameHeaderBackground)
        hideTexture(CompactRaidFrameManagerBg)
        hideTexture(CompactRaidFrameManagerDisplayFrameFilterOptionsFooterDelineator)

        CompactRaidFrameManager.toggleButton:SetNormalAtlas(e.Icon.toRight)--展开, 图标
        CompactRaidFrameManager.toggleButton:SetAlpha(0.3)
        CompactRaidFrameManager.toggleButton:SetHeight(30)
        hooksecurefunc('CompactRaidFrameManager_Collapse', function()
            CompactRaidFrameManager.toggleButton:SetNormalAtlas(e.Icon.toRight)
        end)
        hooksecurefunc('CompactRaidFrameManager_Expand', function()
            CompactRaidFrameManager.toggleButton:SetNormalAtlas(e.Icon.toLeft)
        end)
        if CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdownText then
            CompactRaidFrameManagerDisplayFrameLeaderOptionsCountdownText:SetText('|A:countdown-swords:22:22|a10')
            CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePollText:SetText('|A:groupfinder-icon-role-large-tank:22:22:|a|A:groupfinder-icon-role-large-heal:22:22|a')
            CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheckText:SetText('|A:'..e.Icon.select..':22:22|a')
        end
     end

    --######
    --动作条
    --######
    local KEY_BUTTON_Tab={
        [KEY_BUTTON1]= 'ML',--鼠标左键";
        [KEY_BUTTON3]= 'MR',--鼠标中键";
        [KEY_BUTTON2]= 'MM',--鼠标右键";
        --[[[KEY_BUTTON10]= 'M10',--鼠标按键10";
        [KEY_BUTTON11]= 'M11',--鼠标按键11";
        [KEY_BUTTON12]= 'M12',--鼠标按键12";
        [KEY_BUTTON13]= 'M13',--鼠标按键13";
        [KEY_BUTTON14]= 'M14',--鼠标按键14";
        [KEY_BUTTON15]= 'M15',--鼠标按键15";
        [KEY_BUTTON16]= 'M16',--鼠标按键16";
        [KEY_BUTTON17]= 'M17',--鼠标按键17";
        [KEY_BUTTON18]= 'M18',--鼠标按键18";
        [KEY_BUTTON19]= 'M19',--鼠标按键19";
        [KEY_BUTTON20]= 'M20',--鼠标按键20";
        [KEY_BUTTON21]= 'M21',--鼠标按键21";
        [KEY_BUTTON22]= 'M22',--鼠标按键22";
        [KEY_BUTTON23]= 'M23',--鼠标按键23";
        [KEY_BUTTON24]= 'M24',--鼠标按键24";
        [KEY_BUTTON25]= 'M25',--鼠标按键25";
        [KEY_BUTTON26]= 'M26',--鼠标按键26";
        [KEY_BUTTON27]= 'M27',--鼠标按键27";
        [KEY_BUTTON28]= 'M28',--鼠标按键28";
        [KEY_BUTTON29]= 'M29',--鼠标按键29";
        [KEY_BUTTON30]= 'M30',--鼠标按键30";
        [KEY_BUTTON31]= 'M31',--鼠标按键31";]]
        [KEY_BUTTON4]= 'M4',--鼠标按键4";
        [KEY_BUTTON5]= 'M5',--鼠标按键5";
        [KEY_BUTTON6]= 'M6',--鼠标按键6";
        [KEY_BUTTON7]= 'M7',--鼠标按键7";
        [KEY_BUTTON8]= 'M8',--鼠标按键8";
        [KEY_BUTTON9]= 'M9',--鼠标按键9";
    }
    local function hideButtonText(self)
        if self then
            hideTexture(self.SlotArt)
            hideTexture(self.SlotBackground)--背景，
            hideTexture(self.NormalTexture)--外框，方块
            if self.RightDivider and self.BottomDivider then
                self.RightDivider:SetShown(false)--frame
                self.BottomDivider:SetShown(false)
                hideTexture(self.RightDivider.TopEdge)
                hideTexture(self.RightDivider.BottomEdge)
                hideTexture(self.RightDivider.Center)
            end
            if self.HotKey then--快捷键
                self.HotKey:SetShadowOffset(1, -1)
                local text=self.HotKey:GetText()
                if text and text~='' and text~= RANGE_INDICATOR and #text>4 then
                    for key, mouse in pairs(KEY_BUTTON_Tab) do
                        if text:find(key) then
                            self.HotKey:SetText(text:gsub(key, mouse))
                        end
                    end
                end
            end
            if self.Count then--数量
                self.Count:SetShadowOffset(1, -1)
            end
            if self.Name then--名称
                self.Name:SetShadowOffset(1, -1)
            end
            if self.cooldown then
                --self.cooldown:SetBlingTexture('Interface\\Cooldown\\star4')--闪光
                --self.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge", 1,0,0,1);
                self.cooldown:SetCountdownFont('NumberFontNormal')
            end
        end
    end
    hooksecurefunc('CooldownFrame_Set', function(self, start, duration, enable, forceShowDrawEdge, modRate)
        if enable and enable ~= 0 and start > 0 and duration > 0 then
            self:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
        end
    end)
    C_Timer.After(2, function()
        for i=1, 12 do
            hideButtonText(_G['ActionButton'..i])--主动作条
            hideButtonText(_G['MultiBarBottomLeftButton'..i])--作条2
            hideButtonText(_G['MultiBarBottomRightButton'..i])--作条3
            hideButtonText(_G['MultiBarLeftButton'..i])--作条4
            hideButtonText(_G['MultiBarRightButton'..i])--作条5
            for index=5, 7 do
                hideButtonText(_G['MultiBar'..index..'Button'..i])--作条6, 7, 8
            end
        end
        MainMenuBar.Background:SetShown(false)
    end)
end


local function set_HideTexture_Event(arg1)
    if Save.disabledTexture then
        return
    end
    if arg1=='Blizzard_WeeklyRewards' then--周奖励提示
        if WeeklyRewardExpirationWarningDialog and WeeklyRewardExpirationWarningDialog:IsShown() then
            if WeeklyRewardExpirationWarningDialog.Description then
                print(id, addName, '|cffff00ff'..WeeklyRewardExpirationWarningDialog.Description:GetText())
                WeeklyRewardExpirationWarningDialog:Hide()
            else
                C_Timer.After(5, function()
                    WeeklyRewardExpirationWarningDialog:Hide()
                end)
            end
        end
    end
end











--###########
--初始化, 透明
--###########
local function Init_Set_AlphaAndColor()
    if Save.disabledAlpha and Save.disabledColor then
        return
    end

    --骑士，能量条
    setAlpha(PaladinPowerBarFrameBG)
    setAlpha(PaladinPowerBarFrameBankBG)

    --角色，界面
    setAlpha(CharacterFrameBg)
    hideTexture(CharacterFrameInset.Bg)
    setAlpha(CharacterFrame.NineSlice.TopEdge)
    setAlpha(CharacterFrame.NineSlice.TopRightCorner)
    setAlpha(CharacterFrame.NineSlice.TopLeftCorner)
    hideTexture(CharacterFrameInsetRight.Bg)
    setAlpha(CharacterStatsPane.ClassBackground)
    setAlpha(CharacterStatsPane.EnhancementsCategory.Background)
    setAlpha(CharacterStatsPane.AttributesCategory.Background)
    setAlpha(CharacterStatsPane.ItemLevelCategory.Background)
    hooksecurefunc('PaperDollTitlesPane_UpdateScrollBox', function()--PaperDollFrame.lua
        for _, button in pairs(PaperDollFrame.TitleManagerPane.ScrollBox:GetFrames()) do
            hideTexture(button.BgMiddle)
        end
    end)
    hideTexture(PaperDollFrame.TitleManagerPane.ScrollBar.Backplate)
    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function()--PaperDollFrame.lua
        for _, button in pairs(PaperDollFrame.EquipmentManagerPane.ScrollBox:GetFrames()) do
            hideTexture(button.BgMiddle)
        end
    end)
    hideTexture(PaperDollFrame.EquipmentManagerPane.ScrollBar.Backplate)
    hideTexture(ReputationFrame.ScrollBar.Backplate)
    hideTexture(TokenFrame.ScrollBar.Backplate)

    hideTexture(CharacterModelFrameBackgroundTopLeft)--角色3D背景
    hideTexture(CharacterModelFrameBackgroundTopRight)
    hideTexture(CharacterModelFrameBackgroundBotLeft)
    hideTexture(CharacterModelFrameBackgroundBotRight)
    hideTexture(CharacterModelFrameBackgroundOverlay)

    --法术书
    setAlpha(SpellBookFrame.NineSlice.TopLeftCorner)
    setAlpha(SpellBookFrame.NineSlice.TopEdge)
    setAlpha(SpellBookFrame.NineSlice.TopRightCorner)
    if SpellBookPageText then
        SpellBookPageText:SetTextColor(1, 0.82, 0)
    end

    hideTexture(SpellBookPage1)
    hideTexture(SpellBookPage2)
    setAlpha(SpellBookFrameBg)
    hideTexture(SpellBookFrameInset.Bg)

    for i=1, 12 do
        setAlpha(_G['SpellButton'..i..'Background'])
        local frame= _G['SpellButton'..i]
        if frame then
            hooksecurefunc(frame, 'UpdateButton', function(self)--SpellBookFrame.lua
                self.SpellSubName:SetTextColor(1, 1, 1)
            end)
        end
    end
    --世界地图
    setAlpha(WorldMapFrame.BorderFrame.NineSlice.TopLeftCorner)
    setAlpha(WorldMapFrame.BorderFrame.NineSlice.TopEdge)
    setAlpha(WorldMapFrame.BorderFrame.NineSlice.TopRightCorner)
    setAlpha(WorldMapFrameBg)
    setAlpha(QuestMapFrame.Background)
    WorldMapFrame.NavBar:DisableDrawLayer('BACKGROUND')

    --地下城和团队副本
    setAlpha(PVEFrame.NineSlice.TopLeftCorner)
    setAlpha(PVEFrame.NineSlice.TopEdge)
    setAlpha(PVEFrame.NineSlice.TopRightCorner)
    setAlpha(LFGListFrame.CategorySelection.Inset.CustomBG)
    hideTexture(LFGListFrame.CategorySelection.Inset.Bg)
    setAlpha(LFGListFrame.SearchPanel.SearchBox.Middle)
    setAlpha(LFGListFrame.SearchPanel.SearchBox.Left)
    setAlpha(LFGListFrame.SearchPanel.SearchBox.Right)
    setAlpha(LFGListFrame.SearchPanel.ScrollBar.Backplate)
    setAlpha(LFGListFrame.EntryCreation.Inset.CustomBG)
    setAlpha(LFGListFrame.EntryCreation.Inset.Bg)
    setAlpha(LFGListFrameMiddleMiddle)
    setAlpha(LFGListFrameMiddleLeft)
    setAlpha(LFGListFrameMiddleRight)
    setAlpha(LFGListFrameBottomMiddle)
    setAlpha(LFGListFrameTopMiddle)
    setAlpha(LFGListFrameTopLeft)
    setAlpha(LFGListFrameBottomLeft)
    setAlpha(LFGListFrameTopRight)
    setAlpha(LFGListFrameBottomRight)
    setAlpha(RaidFinderFrameBottomInset.Bg)
    setAlpha(RaidFinderQueueFrameBackground)
    setAlpha(RaidFinderQueueFrameSelectionDropDownMiddle)
    setAlpha(RaidFinderQueueFrameSelectionDropDownLeft)
    setAlpha(RaidFinderQueueFrameSelectionDropDownRight)
    setAlpha(RaidFinderFrameRoleBackground)
    setAlpha(RaidFinderFrameRoleInset.Bg)

    hideTexture(PVEFrameBg)--左边
    hideTexture(PVEFrameBlueBg)
    setAlpha(PVEFrameLeftInset.Bg)

    setAlpha(LFDQueueFrameBackground)
    setAlpha(LFDQueueFrameTypeDropDownMiddle)
    setAlpha(LFDQueueFrameTypeDropDownRight)
    setAlpha(LFDQueueFrameTypeDropDownLeft)

    setAlpha(LFDParentFrameInset.Bg)
    setAlpha(LFDParentFrameRoleBackground)

    setAlpha(ProfessionsFrame.NineSlice.TopLeftCorner)
    setAlpha(ProfessionsFrame.NineSlice.TopEdge)
    setAlpha(ProfessionsFrame.NineSlice.TopRightCorner)
    setAlpha(ProfessionsFrameBg)
    setAlpha(ProfessionsFrame.CraftingPage.SchematicForm.Background)
    setAlpha(ProfessionsFrame.CraftingPage.RankBar.Background)

    setAlpha(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundTop)
    setAlpha(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundMiddle)
    setAlpha(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundBottom)

    hideTexture(ProfessionsFrame.SpecPage.TreeView.Background)
    hideTexture(ProfessionsFrame.SpecPage.DetailedView.Background)
    setAlpha(ProfessionsFrame.SpecPage.DetailedView.Path.DialBG)
    setAlpha(ProfessionsFrame.SpecPage.DetailedView.UnspentPoints.CurrencyBackground)

    setAlpha(GossipFrame.NineSlice.TopEdge)
    setAlpha(GossipFrame.NineSlice.TopLeftCorner)
    setAlpha(GossipFrame.NineSlice.TopRightCorner)
    setAlpha(GossipFrameBg)
    hideTexture(GossipFrameInset.Bg)
    hideTexture(GossipFrame.GreetingPanel.ScrollBar.Backplate)

    if PetStableFrame then--猎人，宠物
        setAlpha(PetStableFrame.NineSlice.TopEdge)
        setAlpha(PetStableFrame.NineSlice.TopLeftCorner)
        setAlpha(PetStableFrame.NineSlice.TopRightCorner)
        hideTexture(PetStableFrameModelBg)
        hideTexture(PetStableFrameInset.Bg)
        setAlpha(PetStableFrameBg)
        hideTexture(PetStableFrameStableBg)
        hideTexture(PetStableActiveBg)
        for i=1, 10 do
            if i<=5 then
                hideTexture(_G['PetStableActivePet'..i..'Background'])
                setAlpha(_G['PetStableActivePet'..i..'Border'])
            end
            setAlpha(_G['PetStableStabledPet'..i..'Background'])
        end
    end

    --商人
    setAlpha(MerchantFrame.NineSlice.TopEdge)
    setAlpha(MerchantFrame.NineSlice.TopLeftCorner)
    setAlpha(MerchantFrame.NineSlice.TopRightCorner)
    setAlpha(MerchantFrameBg)
    hideTexture(MerchantFrameInset.Bg)
    setAlpha(MerchantMoneyInset.Bg)
    hideTexture(MerchantMoneyBgMiddle)
    hideTexture(MerchantMoneyBgLeft)
    hideTexture(MerchantMoneyBgRight)
    for i=1, 12 do
        setAlpha(_G['MerchantItem'..i..'SlotTexture'])
    end
    setAlpha(MerchantFrameLootFilterMiddle)
    setAlpha(MerchantFrameLootFilterLeft)
    setAlpha(MerchantFrameLootFilterRight)

    --银行
    setAlpha(BankFrame.NineSlice.TopEdge)
    setAlpha(BankFrame.NineSlice.TopLeftCorner)
    setAlpha(BankFrame.NineSlice.TopRightCorner)

    hideTexture(BankFrameMoneyFrameInset.Bg)
    setAlpha(BankFrameMoneyFrameBorderMiddle)
    setAlpha(BankFrameMoneyFrameBorderRight)
    setAlpha(BankFrameMoneyFrameBorderLeft)

    BankFrame:DisableDrawLayer('BACKGROUND')
    local texture= BankFrame:CreateTexture(nil,'BORDER',nil, 1)
    texture:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    texture:SetAllPoints(BankFrame)
    setAlpha(texture)
    hideTexture(BankFrameBg)

    hooksecurefunc('BankFrameItemButton_Update',function(button)--银行
        if button.NormalTexture and button.NormalTexture:IsShown() then
            hideTexture(button.NormalTexture)
        end
        if ReagentBankFrame.numColumn and not ReagentBankFrame.hidexBG then
            ReagentBankFrame.hidexBG=true
            for column = 1, 7 do
                hideTexture(ReagentBankFrame["BG"..column])
            end
        end
    end)

    --背包
    setAlpha(ContainerFrameCombinedBags.NineSlice.TopEdge)
    setAlpha(ContainerFrameCombinedBags.NineSlice.TopLeftCorner)
    setAlpha(ContainerFrameCombinedBags.NineSlice.TopRightCorner)
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame and frame.NineSlice then
            setAlpha(frame.NineSlice.TopEdge)
            setAlpha(frame.NineSlice.TopLeftCorner)
            setAlpha(frame.NineSlice.TopRightCorner)
        end
    end

    local function set_BagTexture_Button(button)
        if not button.hasItem then
            hideTexture(button.icon)
            hideTexture(button.ItemSlotBackground)
            button.NormalTexture:SetAlpha(0.1)
        else
            button.NormalTexture:SetAlpha(1)
        end
    end
    local function set_BagTexture(self)
        for i, itemButton in self:EnumerateValidItems() do
            set_BagTexture_Button(itemButton)
        end
    end
    hooksecurefunc('ContainerFrame_GenerateFrame',function (self)--ContainerFrame.lua
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            if not frame.SetBagAlpha then
                set_BagTexture(frame)
                hooksecurefunc(frame, 'UpdateItems', set_BagTexture)
                frame:SetTitle('')--名称
                hooksecurefunc(frame, 'UpdateName', function(self2) self2:SetTitle('') end)
                frame.SetBagAlpha=true
            end
        end
    end)
    hooksecurefunc('PaperDollItemSlotButton_Update', function(frame)--PaperDollFrame.lua
        if frame:GetID()>30 then
            setAlpha(frame:GetNormalTexture())
            setAlpha(frame.icon)
        end
    end)

    --好友列表
    setAlpha(FriendsFrame.NineSlice.TopEdge)
    setAlpha(FriendsFrame.NineSlice.TopLeftCorner)
    setAlpha(FriendsFrame.NineSlice.TopRightCorner)
    setAlpha(FriendsFrameBg)
    hideTexture(FriendsFrameInset.Bg)
    hideTexture(FriendsListFrame.ScrollBar.Backplate)
    hideTexture(IgnoreListFrame.ScrollBar.Backplate)
    if RecruitAFriendFrame and RecruitAFriendFrame.RecruitList then 
        hideTexture(RecruitAFriendFrame.RecruitList.ScrollBar.Backplate)
        setAlpha(RecruitAFriendFrame.RecruitList.ScrollFrameInset.Bg)
    end
    hideTexture(WhoFrameListInset.Bg)
    hideTexture(WhoFrame.ScrollBar.Backplate)
    setAlpha(WhoFrameDropDownMiddle)
    setAlpha(WhoFrameDropDownLeft)
    setAlpha(WhoFrameDropDownRight)
    hideTexture(WhoFrameEditBoxInset.Bg)
    hideTexture(QuickJoinFrame.ScrollBar.Backplate)


    --聊天设置
    setAlpha(ChannelFrame.NineSlice.TopEdge)
    setAlpha(ChannelFrame.NineSlice.TopLeftCorner)
    setAlpha(ChannelFrame.NineSlice.TopRightCorner)
    setAlpha(ChannelFrameBg)
    hideTexture(ChannelFrameInset.Bg)
    hideTexture(ChannelFrame.RightInset.Bg)
    hideTexture(ChannelFrame.LeftInset.Bg)
    hideTexture(ChannelFrame.ChannelRoster.ScrollBar.Backplate)

    --任务
    setAlpha(QuestFrame.NineSlice.TopEdge)
    setAlpha(QuestFrame.NineSlice.TopLeftCorner)
    setAlpha(QuestFrame.NineSlice.TopRightCorner)
    setAlpha(QuestFrameBg)
    hideTexture(QuestFrameInset.Bg)

    --信箱
    setAlpha(MailFrame.NineSlice.TopEdge)
    setAlpha(MailFrame.NineSlice.TopLeftCorner)
    setAlpha(MailFrame.NineSlice.TopRightCorner)
    setAlpha(MailFrameBg)
    hideTexture(InboxFrameBg)
    hideTexture(MailFrameInset.Bg)
    setAlpha(SendStationeryBackgroundLeft)
    setAlpha(SendStationeryBackgroundRight)
    setAlpha(SendMailMoneyBgMiddle)
    setAlpha(SendMailMoneyBgRight)
    setAlpha(SendMailMoneyBgLeft)
    hideTexture(SendMailMoneyInset.Bg)


    --拾取, 历史
    hideTexture(LootHistoryFrameScrollFrame.ScrollBarBackground)
    setAlpha(LootHistoryFrame.NineSlice.Center)

    --频道, 设置
    hideTexture(ChatConfigCategoryFrame.NineSlice.Center)
    hideTexture(ChatConfigBackgroundFrame.NineSlice.Center)
    hideTexture(ChatConfigChatSettingsLeft.NineSlice.Center)

    hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame)--ChatConfigFrame.lua
        if frame.NineSlice then
            hideTexture(frame.NineSlice.TopEdge)
            hideTexture(frame.NineSlice.BottomEdge)
            hideTexture(frame.NineSlice.RightEdge)
            hideTexture(frame.NineSlice.LeftEdge)
            hideTexture(frame.NineSlice.TopLeftCorner)
            hideTexture(frame.NineSlice.TopRightCorner)
            hideTexture(frame.NineSlice.BottomLeftCorner)
            hideTexture(frame.NineSlice.BottomRightCorner)
            hideTexture(frame.NineSlice.Center)
        end
        local checkBoxNameString = frame:GetName().."CheckBox";
        for index, _ in ipairs(frame.checkBoxTable) do
            local checkBox = _G[checkBoxNameString..index];
            if checkBox and checkBox.NineSlice then
                hideTexture(checkBox.NineSlice.TopEdge)
                hideTexture(checkBox.NineSlice.RightEdge)
                hideTexture(checkBox.NineSlice.LeftEdge)
                hideTexture(checkBox.NineSlice.TopRightCorner)
                hideTexture(checkBox.NineSlice.TopLeftCorner)
                hideTexture(checkBox.NineSlice.BottomRightCorner)
                hideTexture(checkBox.NineSlice.BottomLeftCorner)
            end
        end
    end)
    hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)--频道颜色设置 ChatConfigFrame.lua
        if not FCF_GetCurrentChatFrame() then
            return
        end
        local checkBoxNameString = frame:GetName().."CheckBox";
        for index, value in ipairs(frame.checkBoxTable) do
            if value and value.type then
                local r, g, b = GetMessageTypeColor(value.type)
                if r and g and b then
                    if _G[checkBoxNameString..index.."CheckText"] then
                        _G[checkBoxNameString..index.."CheckText"]:SetTextColor(r,g,b)
                    end
                    local checkBox = _G[checkBoxNameString..index]
                    if checkBox and checkBox.NineSlice and checkBox.NineSlice.BottomEdge then
                        checkBox.NineSlice.BottomEdge:SetVertexColor(r,g,b)
                    end
                end
            end
        end
    end)

    --插件，管理
    setAlpha(AddonList.NineSlice.TopEdge)
    setAlpha(AddonList.NineSlice.TopLeftCorner)
    setAlpha(AddonList.NineSlice.TopRightCorner)
    setAlpha(AddonListBg)
    setAlpha(AddonListInset.Bg)
    hideTexture(AddonList.ScrollBar.Backplate)
    setAlpha(AddonCharacterDropDownMiddle)
    setAlpha(AddonCharacterDropDownLeft)
    setAlpha(AddonCharacterDropDownRight)

    --场景 Blizzard_ScenarioObjectiveTracker.lua
    if ObjectiveTrackerBlocksFrame then
        setAlpha(ObjectiveTrackerBlocksFrame.ScenarioHeader.Background)
        setAlpha(ObjectiveTrackerBlocksFrame.AchievementHeader.Background)
        setAlpha(ObjectiveTrackerBlocksFrame.QuestHeader.Background)
        hooksecurefunc('ScenarioStage_UpdateOptionWidgetRegistration', function(stageBlock, widgetSetID)
            setAlpha(stageBlock.NormalBG)
            setAlpha(stageBlock.FinalBG)
        end)
    end

    --小地图
    setAlpha(MinimapCompassTexture)

    --对话框
    if StaticPopup1 then
        if StaticPopup1.Border then
            setAlpha(StaticPopup1.Border.Bg)
        end
    end

    local buttons = {
        CharacterMicroButton,--菜单
        SpellbookMicroButton,
        TalentMicroButton,
        AchievementMicroButton,
        QuestLogMicroButton,
        GuildMicroButton,
        LFDMicroButton,
        EJMicroButton,
        CollectionsMicroButton,
        MainMenuMicroButton,
        HelpMicroButton,
        StoreMicroButton,
        MainMenuBarBackpackButton,--背包
    }
    for _, frame in pairs(buttons) do
        if frame then
            setAlpha(frame:GetNormalTexture())
        end
    end
end

--#########
--事件, 透明
--#########
local function set_Alpha_Event(arg1)
    if Save.disabledAlpha and Save.disabledColor then
        return
    end
    if arg1=='Blizzard_TrainerUI' then--专业训练师
        setAlpha(ClassTrainerFrame.NineSlice.TopEdge)
        setAlpha(ClassTrainerFrame.NineSlice.TopLeftCorner)
        setAlpha(ClassTrainerFrame.NineSlice.TopRightCorner)
        hideTexture(ClassTrainerFrameInset.Bg)
        hideTexture(ClassTrainerFrameBg)

        hideTexture(ClassTrainerFrameBottomInset.Bg)
        setAlpha(ClassTrainerFrameFilterDropDownMiddle)
        setAlpha(ClassTrainerFrameFilterDropDownLeft)
        setAlpha(ClassTrainerFrameFilterDropDownRight)
        hideTexture(ClassTrainerFrame.ScrollBar.Backplate)

    elseif arg1=='Blizzard_TimeManager' then--小时图，时间
        setAlpha(TimeManagerFrame.NineSlice.TopLeftCorner)
        setAlpha(TimeManagerFrame.NineSlice.TopEdge)
        setAlpha(TimeManagerFrame.NineSlice.TopRightCorner)
        setAlpha(TimeManagerFrameBg)
        hideTexture(TimeManagerFrameInset.Bg)
        setAlpha(TimeManagerAlarmMessageEditBox.Middle)
        setAlpha(TimeManagerAlarmMessageEditBox.Left)
        setAlpha(TimeManagerAlarmMessageEditBox.Right)

    elseif arg1=='Blizzard_ClassTalentUI' and not Save.disabledAlpha then--天赋
        setAlpha(ClassTalentFrame.TalentsTab.BottomBar)--下面
        setAlpha(ClassTalentFrame.NineSlice.TopLeftCorner)--顶部
        setAlpha(ClassTalentFrame.NineSlice.TopEdge)--顶部
        setAlpha(ClassTalentFrame.NineSlice.TopRightCorner)--顶部
        setAlpha(ClassTalentFrameBg)--里面
        hideTexture(ClassTalentFrame.TalentsTab.BlackBG)
        hooksecurefunc(ClassTalentFrame.TalentsTab, 'UpdateSpecBackground', function(self2)--Blizzard_ClassTalentTalentsTab.lua
            if self2.specBackgrounds then
                for _, background in ipairs(self2.specBackgrounds) do
                    hideTexture(background)
                end
            end
        end)

        hideTexture(ClassTalentFrame.SpecTab.Background)
        hideTexture(ClassTalentFrame.SpecTab.BlackBG)
        hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecContents', function(self2)--Blizzard_ClassTalentSpecTab.lua
            local numSpecs= self2.numSpecs
            if numSpecs and numSpecs>0 then
                for i = 1, numSpecs do
                    local contentFrame = self2.SpecContentFramePool:Acquire();
                    if contentFrame then
                        hideTexture(contentFrame.HoverBackground)
                    end
                end
            end
        end)

        setAlpha(ClassTalentFrameMiddle)
        setAlpha(ClassTalentFrameLeft)
        setAlpha(ClassTalentFrameRight)
        setAlpha(ClassTalentFrame.TalentsTab.SearchBox.Middle)
        setAlpha(ClassTalentFrame.TalentsTab.SearchBox.Left)
        setAlpha(ClassTalentFrame.TalentsTab.SearchBox.Right)

    elseif arg1=='Blizzard_AchievementUI' then--成就

        setAlpha(AchievementFrame.Header.PointBorder)
        hideTexture(AchievementFrameSummary.Background)
        hideTexture(AchievementFrameCategoriesBG)
        hideTexture(AchievementFrameAchievements.Background)

        hideTexture(AchievementFrameWaterMark)
        hideTexture(AchievementFrameGuildEmblemRight)

        hideTexture(AchievementFrame.BottomRightCorner)
        hideTexture(AchievementFrame.BottomLeftCorner)
        hideTexture(AchievementFrame.TopLeftCorner)
        hideTexture(AchievementFrame.TopRightCorner)

        hideTexture(AchievementFrame.BottomEdge)
        hideTexture(AchievementFrame.TopEdge)
        hideTexture(AchievementFrame.LeftEdge)
        hideTexture(AchievementFrame.RightEdge)
        hideTexture(AchievementFrame.Header.Right)
        hideTexture(AchievementFrame.Header.Left)

        hideTexture(AchievementFrame.SearchBox.Middle)
        hideTexture(AchievementFrame.SearchBox.Left)
        hideTexture(AchievementFrame.SearchBox.Right)

        setAlpha(AchievementFrame.Background)
        setAlpha(AchievementFrameMetalBorderBottomLeft)
        setAlpha(AchievementFrameMetalBorderBottom)
        setAlpha(AchievementFrameMetalBorderBottomRight)
        setAlpha(AchievementFrameMetalBorderRight)
        setAlpha(AchievementFrameMetalBorderLeft)
        setAlpha(AchievementFrameMetalBorderTopLeft)
        setAlpha(AchievementFrameMetalBorderTop)
        setAlpha(AchievementFrameMetalBorderTopRight)

        setAlpha(AchievementFrameWoodBorderBottomLeft)
        setAlpha(AchievementFrameWoodBorderBottomRight)
        setAlpha(AchievementFrameWoodBorderTopLeft)
        setAlpha(AchievementFrameWoodBorderTopRight)

        hideTexture(AchievementFrameSummaryCategoriesStatusBarFillBar)
        for i=1, 10 do
            hideTexture(_G['AchievementFrameCategoriesCategory'..i..'Bar'])
        end
        if AchievementFrameStatsBG then
            AchievementFrameStatsBG:Hide()
        end
        setAlpha(AchievementFrame.Header.LeftDDLInset)
        setAlpha(AchievementFrame.Header.RightDDLInset)
        hooksecurefunc(AchievementTemplateMixin, 'Init', function(self)
            if self.Icon then
                hideTexture(self.Icon.frame)
            end
        end)
        hideTexture(AchievementFrameAchievements.ScrollBar.Backplate)
        hideTexture(AchievementFrameStats.ScrollBar.Backplate)
        hideTexture(AchievementFrameCategories.ScrollBar.Backplate)

    elseif arg1=='Blizzard_Communities' then--公会和社区
        setAlpha(CommunitiesFrame.NineSlice.TopEdge)
        setAlpha(CommunitiesFrame.NineSlice.TopLeftCorner)
        setAlpha(CommunitiesFrame.NineSlice.TopRightCorner)

        setAlpha(CommunitiesFrame.NineSlice.BottomEdge)
        setAlpha(CommunitiesFrame.NineSlice.BottomLeftCorner)
        setAlpha(CommunitiesFrame.NineSlice.BottomRightCorner)

        setAlpha(CommunitiesFrameBg)
        setAlpha(CommunitiesFrame.MemberList.ColumnDisplay.Background)
        setAlpha(CommunitiesFrameCommunitiesList.Bg)
        setAlpha(CommunitiesFrameInset.Bg)
        CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
        CommunitiesFrameGuildDetailsFrameInfo:DisableDrawLayer('BACKGROUND')
        CommunitiesFrameGuildDetailsFrameNews:DisableDrawLayer('BACKGROUND')

        hideTexture(CommunitiesFrameCommunitiesList.ScrollBar.Backplate)
        hideTexture(CommunitiesFrameCommunitiesList.ScrollBar.Background)
        hideTexture(CommunitiesFrame.MemberList.ScrollBar.Backplate)
        hideTexture(CommunitiesFrame.MemberList.ScrollBar.Background)

        setAlpha(CommunitiesFrame.ChatEditBox.Mid)
        setAlpha(CommunitiesFrame.ChatEditBox.Left)
        setAlpha(CommunitiesFrame.ChatEditBox.Right)
        setAlpha(CommunitiesFrameMiddle)

        hideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)

        hooksecurefunc(CommunitiesFrameCommunitiesList,'UpdateCommunitiesList',function(self)
            C_Timer.After(0.3, function()
                for _, button in pairs(CommunitiesFrameCommunitiesList.ScrollBox:GetFrames()) do
                setAlpha(button.Background)
                end
            end)
        end)

        setAlpha(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.Bg)
        hideTexture(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBar.Backplate)
        hideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar.Backplate)
        hideTexture(CommunitiesFrameGuildDetailsFrameNews.ScrollBar.Backplate)
        hideTexture(CommunitiesFrameGuildDetailsFrameNews.ScrollBar.Background)

    elseif arg1=='Blizzard_PVPUI' then--地下城和团队副本, PVP
        hideTexture(HonorFrame.Inset.Bg)
        setAlpha(HonorFrame.BonusFrame.WorldBattlesTexture)
        hideTexture(HonorFrame.ConquestBar.Background)
        setAlpha(ConquestFrame.Inset.Bg)
        setAlpha(ConquestFrame.RatedBGTexture)
        PVPQueueFrame.HonorInset:DisableDrawLayer('BACKGROUND')
        setAlpha(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.Background)
        setAlpha(HonorFrameTypeDropDownMiddle)
        setAlpha(HonorFrameTypeDropDownLeft)
        setAlpha(HonorFrameTypeDropDownRight)
        hideTexture(ConquestFrame.RatedBGTexture)
        --hideTexture(LFGListFrame.SearchPanel.ScrollBar.Backplate)

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        setAlpha(EncounterJournal.NineSlice.TopLeftEdge)
        setAlpha(EncounterJournal.NineSlice.TopEdge)
        setAlpha(EncounterJournal.NineSlice.TopRightEdge)

        hideTexture(EncounterJournalBg)
        hideTexture(EncounterJournalInset.Bg)


        setAlpha(EncounterJournalInstanceSelectBG)
        --setAlpha(EncounterJournalEncounterFrameInfoBG)
        setAlpha(EncounterJournalEncounterFrameInfoModelFrameDungeonBG)
        EncounterJournalNavBar:DisableDrawLayer('BACKGROUND')

        setAlpha(EncounterJournalInstanceSelectTierDropDownMiddle)
        setAlpha(EncounterJournalInstanceSelectTierDropDownLeft)
        setAlpha(EncounterJournalInstanceSelectTierDropDownRight)

        C_Timer.After(0.3, function()
            if EncounterJournalMonthlyActivitiesFrame then
                setAlpha(EncounterJournalMonthlyActivitiesFrame.Bg)
            end
        end)

    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        setAlpha(GuildBankFrame.BlackBG)
        hideTexture(GuildBankFrame.TitleBg)
        hideTexture(GuildBankFrame.RedMarbleBG)
        setAlpha(GuildBankFrame.MoneyFrameBG)

        setAlpha(GuildBankFrame.TabLimitBG)
        setAlpha(GuildBankFrame.TabLimitBGLeft)
        setAlpha(GuildBankFrame.TabLimitBGRight)
        setAlpha(GuildItemSearchBox.Middle)
        setAlpha(GuildItemSearchBox.Left)
        setAlpha(GuildItemSearchBox.Right)
        setAlpha(GuildBankFrame.TabTitleBG)
        setAlpha(GuildBankFrame.TabTitleBGLeft)
        setAlpha(GuildBankFrame.TabTitleBGRight)

        for i=1, 7 do
            local frame= GuildBankFrame['Column'..i]
            if frame then
                hideTexture(frame.Background)
            end
        end

        local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
        local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
        hooksecurefunc(GuildBankFrame,'Update', function(self)--Blizzard_GuildBankUI.lua
            if ( self.mode == "bank" ) then
                local tab = GetCurrentGuildBankTab() or 1
                for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
                    local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
                    if ( index == 0 ) then
                        index = NUM_SLOTS_PER_GUILDBANK_GROUP;
                    end
                    local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
                    local button = self.Columns[column].Buttons[index];
                    if button and button.NormalTexture then
                        local texture= GetGuildBankItemInfo(tab, i)
                        button.NormalTexture:SetAlpha(texture and 1 or 0.1)
                    end
                end
            end
        end)


    elseif arg1=='Blizzard_AuctionHouseUI' then--拍卖行
        setAlpha(AuctionHouseFrame.NineSlice.TopLeftCorner)
        setAlpha(AuctionHouseFrame.NineSlice.TopEdge)
        setAlpha(AuctionHouseFrame.NineSlice.TopRightCorner)
        setAlpha(AuctionHouseFrameBg)
        setAlpha(AuctionHouseFrame.CategoriesList.Background)

        setAlpha(AuctionHouseFrame.SearchBar.SearchBox.Middle)
        setAlpha(AuctionHouseFrame.SearchBar.SearchBox.Left)
        setAlpha(AuctionHouseFrame.SearchBar.SearchBox.Right)
        setAlpha(AuctionHouseFrameMiddleMiddle)
        setAlpha(AuctionHouseFrameMiddleLeft)
        setAlpha(AuctionHouseFrameMiddleRight)
        setAlpha(AuctionHouseFrameBottomMiddle)
        setAlpha(AuctionHouseFrameBottomLeft)
        setAlpha(AuctionHouseFrameBottomRight)

        hideTexture(AuctionHouseFrame.CategoriesList.ScrollBar.Backplate)
        hideTexture(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBar.Backplate)
        setAlpha(AuctionHouseFrameMiddle)
        setAlpha(AuctionHouseFrameLeft)
        setAlpha(AuctionHouseFrameRight)
        hideTexture(AuctionHouseFrame.MoneyFrameInset.Bg)

        setAlpha(AuctionHouseFrame.ItemSellFrame.Background)--出售
        setAlpha(AuctionHouseFrame.ItemSellList.Background)
        hideTexture(AuctionHouseFrame.ItemSellList.ScrollBar.Backplate)

        hideTexture(AuctionHouseFrameAuctionsFrame.SummaryList.ScrollBar.Backplate)
        hideTexture(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBar.Backplate)

        setAlpha(AuctionHouseFrameAuctionsFrame.SummaryList.Background)
        setAlpha(AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background)

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then--专业定制
        setAlpha(ProfessionsCustomerOrdersFrame.NineSlice.TopLeftCorner)
        setAlpha(ProfessionsCustomerOrdersFrame.NineSlice.TopEdge)
        setAlpha(ProfessionsCustomerOrdersFrame.NineSlice.TopRightCorner)
        setAlpha(ProfessionsCustomerOrdersFrameBg)
        setAlpha(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox.Middle)
        setAlpha(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox.Left)
        setAlpha(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox.Right)

        setAlpha(ProfessionsCustomerOrdersFrameMiddleMiddle)
        setAlpha(ProfessionsCustomerOrdersFrameMiddleLeft)
        setAlpha(ProfessionsCustomerOrdersFrameMiddleRight)
        setAlpha(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.Background)

        setAlpha(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground.Background)
        setAlpha(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground.Background)

        hideTexture(ProfessionsCustomerOrdersFrame.MoneyFrameInset.Bg)
        setAlpha(ProfessionsCustomerOrdersFrameLeft)
        setAlpha(ProfessionsCustomerOrdersFrameMiddle)
        setAlpha(ProfessionsCustomerOrdersFrameRight)

    elseif arg1=='Blizzard_BlackMarketUI' then--黑市
        setAlpha(BlackMarketFrameTitleBg)
        setAlpha(BlackMarketFrameBg)
        setAlpha(BlackMarketFrame.LeftBorder)
        setAlpha(BlackMarketFrame.RightBorder)
        setAlpha(BlackMarketFrame.BottomBorder)
        setAlpha(BlackMarketFrame.ScrollBar.Backplate)

    elseif arg1=='Blizzard_Collections' then--收藏
        setAlpha(CollectionsJournal.NineSlice.TopEdge)
        setAlpha(CollectionsJournal.NineSlice.TopLeftCorner)
        setAlpha(CollectionsJournal.NineSlice.TopRightCorner)
        setAlpha(CollectionsJournalBg)

        hideTexture(MountJournal.LeftInset.Bg)
        setAlpha(MountJournal.MountDisplay.YesMountsTex)
        hideTexture(MountJournal.RightInset.Bg)
        setAlpha(MountJournal.BottomLeftInset.Background)
        hideTexture(MountJournal.BottomLeftInset.Bg)

        hideTexture(MountJournal.ScrollBar.Backplate)
        setAlpha(MountJournalSearchBox.Middle)
        setAlpha(MountJournalSearchBox.Right)
        setAlpha(MountJournalSearchBox.Left)

        hideTexture(PetJournalPetCardBG)
        setAlpha(PetJournalPetCardInset.Bg)
        setAlpha(PetJournalRightInset.Bg)
        hideTexture(PetJournalLoadoutPet1BG)
        hideTexture(PetJournalLoadoutPet2BG)
        hideTexture(PetJournalLoadoutPet3BG)
        setAlpha(PetJournalLoadoutBorderSlotHeaderBG)
        hideTexture(PetJournalLeftInset.Bg)

        hideTexture(PetJournal.ScrollBar.Backplate)
        setAlpha(PetJournalSearchBox.Middle)
        setAlpha(PetJournalSearchBox.Right)
        setAlpha(PetJournalSearchBox.Left)
        setAlpha(PetJournal.PetCount.BorderTopMiddle)
        setAlpha(PetJournal.PetCount.Bg)
        setAlpha(PetJournal.PetCount.BorderBottomMiddle)
        setAlpha(PetJournal.PetCount.BorderTopRightMiddle)
        setAlpha(PetJournal.PetCount.BorderTopLeftMiddle)
        setAlpha(PetJournal.PetCount.BorderBottomLeft)
        setAlpha(PetJournal.PetCount.BorderTopLeft)
        setAlpha(PetJournal.PetCount.BorderBottomRight)
        setAlpha(PetJournal.PetCount.BorderTopRight)

        hideTexture(ToyBox.iconsFrame.BackgroundTile)
        hideTexture(ToyBox.iconsFrame.Bg)
        setAlpha(ToyBox.searchBox.Middle)
        setAlpha(ToyBox.searchBox.Right)
        setAlpha(ToyBox.searchBox.Left)
        ToyBox.progressBar:DisableDrawLayer('BACKGROUND')

        hideTexture(HeirloomsJournal.iconsFrame.BackgroundTile)
        hideTexture(HeirloomsJournal.iconsFrame.Bg)
        setAlpha(HeirloomsJournalSearchBox.Middle)
        setAlpha(HeirloomsJournalSearchBox.Right)
        setAlpha(HeirloomsJournalSearchBox.Left)
        setAlpha(HeirloomsJournalClassDropDownMiddle)
        setAlpha(HeirloomsJournalClassDropDownLeft)
        setAlpha(HeirloomsJournalClassDropDownRight)
        setAlpha(HeirloomsJournalMiddleMiddle)
        setAlpha(HeirloomsJournalMiddleLeft)
        setAlpha(HeirloomsJournalMiddleRight)
        setAlpha(HeirloomsJournalBottomMiddle)
        setAlpha(HeirloomsJournalTopMiddle)
        setAlpha(HeirloomsJournalBottomLeft)
        setAlpha(HeirloomsJournalBottomRight)
        setAlpha(HeirloomsJournalTopLeft)
        setAlpha(HeirloomsJournalTopRight)

        hideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.BackgroundTile)
        hideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.Bg)
        hideTexture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)

        hideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BackgroundTile)
        hideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.Bg)
        hideTexture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
        hideTexture(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer.ScrollBar.Backplate)
        hideTexture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineTop)

        setAlpha(WardrobeCollectionFrameSearchBox.Middle)
        setAlpha(WardrobeCollectionFrameSearchBox.Left)
        setAlpha(WardrobeCollectionFrameSearchBox.Right)
        setAlpha(WardrobeCollectionFrameMiddleMiddle)
        setAlpha(WardrobeCollectionFrameTopMiddle)
        setAlpha(WardrobeCollectionFrameBottomMiddle)
        setAlpha(WardrobeCollectionFrameTopMiddle)
        setAlpha(WardrobeCollectionFrameMiddleLeft)
        setAlpha(WardrobeCollectionFrameMiddleRight)
        setAlpha(WardrobeCollectionFrameTopLeft)
        setAlpha(WardrobeCollectionFrameBottomLeft)
        setAlpha(WardrobeCollectionFrameBottomRight)
        setAlpha(WardrobeCollectionFrameTopLeft)
                 --WardrobeCollectionFrameBottomRight

        setAlpha(WardrobeSetsCollectionVariantSetsButtonMiddleMiddle)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonBottomMiddle)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonTopMiddle)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonMiddleLeft)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonMiddleRight)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonTopLeft)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonBottomLeft)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonTopRight)
        setAlpha(WardrobeSetsCollectionVariantSetsButtonBottomRight)
        hideTexture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)
        --[[hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', function(button, displayData)--外观列表
            setAlpha(button.Background)
        end)]]

        --试衣间
        setAlpha(WardrobeFrame.NineSlice.TopLeftCorner)
        setAlpha(WardrobeFrame.NineSlice.TopEdge)
        setAlpha(WardrobeFrame.NineSlice.TopRightCorner)
        hideTexture(WardrobeFrameBg)
        hideTexture(WardrobeTransmogFrame.Inset.Bg)
        setAlpha(WardrobeTransmogFrame.Inset.BG)
        hideTexture(WardrobeCollectionFrame.SetsTransmogFrame.BackgroundTile)
        setAlpha(WardrobeCollectionFrame.SetsTransmogFrame.Bg)
        setAlpha(WardrobeOutfitDropDownMiddle)
        setAlpha(WardrobeOutfitDropDownLeft)
        setAlpha(WardrobeOutfitDropDownRight)
        setAlpha(WardrobeTransmogFrame.MoneyMiddle)
        setAlpha(WardrobeTransmogFrame.MoneyLeft)
        setAlpha(WardrobeTransmogFrame.MoneyRight)
        for v=1,6 do
            for h= 1, 3 do
                local button= WardrobeCollectionFrame.ItemsCollectionFrame['ModelR'..h..'C'..v]
                if button then
                    button:DisableDrawLayer('BACKGROUND')
                end
            end
        end
        for v=1,4 do
            for h= 1, 2 do
                local button= WardrobeCollectionFrame.SetsTransmogFrame['ModelR'..h..'C'..v]
                if button then
                    button:DisableDrawLayer('BACKGROUND')
                end
            end
        end
        WardrobeCollectionFrame.progressBar:DisableDrawLayer('BACKGROUND')
        setAlpha(WardrobeCollectionFrameWeaponDropDownMiddle)
        setAlpha(WardrobeCollectionFrameWeaponDropDownLeft)
        setAlpha(WardrobeCollectionFrameWeaponDropDownRight)


    elseif arg1=='Blizzard_Calendar' then--日历
        setAlpha(CalendarFrameTopMiddleTexture)
        setAlpha(CalendarFrameTopLeftTexture)
        setAlpha(CalendarFrameTopRightTexture)

        setAlpha(CalendarFrameLeftTopTexture)
        setAlpha(CalendarFrameLeftMiddleTexture)
        setAlpha(CalendarFrameLeftBottomTexture)
        setAlpha(CalendarFrameRightTopTexture)
        setAlpha(CalendarFrameRightMiddleTexture)
        setAlpha(CalendarFrameRightBottomTexture)

        setAlpha(CalendarFrameBottomRightTexture)
        setAlpha(CalendarFrameBottomMiddleTexture)
        setAlpha(CalendarFrameBottomLeftTexture)
        for i= 1, 42 do
            local frame= _G['CalendarDayButton'..i]
            if frame then
                frame:DisableDrawLayer('BACKGROUND')
            end
        end

    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        setAlpha(FlightMapFrame.BorderFrame.NineSlice.TopLeftCorner)
        setAlpha(FlightMapFrame.BorderFrame.NineSlice.TopEdge)
        setAlpha(FlightMapFrame.BorderFrame.NineSlice.TopRightCorner)

        hideTexture(FlightMapFrame.ScrollContainer.Child.TiledBackground)
        hideTexture(FlightMapFrameBg)
    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        setAlpha(ItemSocketingFrame.NineSlice.TopLeftCorner)
        setAlpha(ItemSocketingFrame.NineSlice.TopEdge)
        setAlpha(ItemSocketingFrame.NineSlice.TopRightCorner)
        setAlpha(ItemSocketingFrameBg)
        hideTexture(ItemSocketingFrameInset.Bg)
        hideTexture(ItemSocketingFrame['SocketFrame-Right'])
        hideTexture(ItemSocketingFrame['SocketFrame-Left'])
        hideTexture(ItemSocketingFrame['ParchmentFrame-Top'])
        hideTexture(ItemSocketingFrame['ParchmentFrame-Bottom'])
        hideTexture(ItemSocketingFrame['ParchmentFrame-Right'])
        hideTexture(ItemSocketingFrame['ParchmentFrame-Left'])
        setAlpha(ItemSocketingFrame['GoldBorder-Top'])
        setAlpha(ItemSocketingFrame['GoldBorder-Bottom'])
        setAlpha(ItemSocketingFrame['GoldBorder-Right'])
        setAlpha(ItemSocketingFrame['GoldBorder-Left'])
        setAlpha(ItemSocketingFrame['GoldBorder-BottomLeft'])
        setAlpha(ItemSocketingFrame['GoldBorder-TopLeft'])
        setAlpha(ItemSocketingFrame['GoldBorder-BottomRight'])
        setAlpha(ItemSocketingFrame['GoldBorder-TopRight'])
        setAlpha(ItemSocketingScrollFrameMiddle)
        setAlpha(ItemSocketingScrollFrameTop)
        setAlpha(ItemSocketingScrollFrameBottom)

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插件, 界面
        setAlpha(ChallengesFrameInset.Bg)

    elseif arg1=='Blizzard_WeeklyRewards' then--周奖励提示
        setAlpha(WeeklyRewardsFrame.BackgroundTile)
        setAlpha(WeeklyRewardsFrame.HeaderFrame.Middle)
        setAlpha(WeeklyRewardsFrame.HeaderFrame.Left)
        setAlpha(WeeklyRewardsFrame.HeaderFrame.Right)
        setAlpha(WeeklyRewardsFrame.RaidFrame.Background)
        setAlpha(WeeklyRewardsFrame.MythicFrame.Background)
        setAlpha(WeeklyRewardsFrame.PVPFrame.Background)
        hooksecurefunc(WeeklyRewardsFrame,'UpdateSelection', function(self2)
            for _, frame in ipairs(self2.Activities) do
                setAlpha(frame.Background)
            end
        end)

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换        
        setAlpha(ItemInteractionFrame.NineSlice.TopLeftCorner)
        setAlpha(ItemInteractionFrame.NineSlice.TopEdge)
        setAlpha(ItemInteractionFrame.NineSlice.TopRightCorner)
        setAlpha(ItemInteractionFrameBg)
        setAlpha(ItemInteractionFrame.Inset.Bg)
        setAlpha(ItemInteractionFrameMiddle)

        setAlpha(ItemInteractionFrameRight)
        setAlpha(ItemInteractionFrameLeft)

        hideTexture(ItemInteractionFrame.ButtonFrame.BlackBorder)

    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        setAlpha(InspectFrame.NineSlice.TopLeftCorner)
        setAlpha(InspectFrame.NineSlice.TopEdge)
        setAlpha(InspectFrame.NineSlice.TopRightCorner)
        setAlpha(InspectFrameBg)
        hideTexture(InspectFrameInset.Bg)
        hideTexture(InspectPVPFrame.BG)
        hideTexture(InspectGuildFrameBG)

    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面        
        setAlpha(ItemUpgradeFrame.NineSlice.TopLeftCorner)
        setAlpha(ItemUpgradeFrame.NineSlice.TopEdge)
        setAlpha(ItemUpgradeFrame.NineSlice.TopRightCorner)
        setAlpha(ItemUpgradeFrameBg)
        hideTexture(ItemUpgradeFrame.TopBG)
        hideTexture(ItemUpgradeFrame.BottomBG)
        setAlpha(ItemUpgradeFramePlayerCurrenciesBorderMiddle)
        setAlpha(ItemUpgradeFramePlayerCurrenciesBorderLeft)
        setAlpha(ItemUpgradeFramePlayerCurrenciesBorderRight)

        setAlpha(ItemUpgradeFrameMiddle)
        setAlpha(ItemUpgradeFrameRight)
        setAlpha(ItemUpgradeFrameLeft)

    elseif arg1=='Blizzard_MacroUI' then--宏
        setAlpha(MacroFrame.NineSlice.TopLeftCorner)
        setAlpha(MacroFrame.NineSlice.TopEdge)
        setAlpha(MacroFrame.NineSlice.TopRightCorner)
        hideTexture(MacroFrameBg)
        setAlpha(MacroFrameInset.Bg)
        hideTexture(MacroFrame.MacroSelector.ScrollBar.Backplate)
        hideTexture(MacroFrameSelectedMacroBackground)
    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        --[[
        Move(GarrisonShipyardFrame,{})--海军行动
        Move(GarrisonMissionFrame, {})--要塞任务
        
        Move(GarrisonLandingPage, {})--要塞报告
        Move(OrderHallMissionFrame, {})
        ]]
        if GarrisonCapacitiveDisplayFrame then--要塞订单
            setAlpha(GarrisonCapacitiveDisplayFrame.NineSlice.TopLeftCorner)
            setAlpha(GarrisonCapacitiveDisplayFrame.NineSlice.TopEdge)
            setAlpha(GarrisonCapacitiveDisplayFrame.NineSlice.TopRightCorner)
            setAlpha(GarrisonCapacitiveDisplayFrameBg)
            hideTexture(GarrisonCapacitiveDisplayFrame.TopTileStreaks)
            hideTexture(GarrisonCapacitiveDisplayFrameInset.Bg)
        end

    elseif arg1=='Blizzard_GenericTraitUI' then--欲龙术
        setAlpha(GenericTraitFrame.Background)
        setAlpha(GenericTraitFrame.NineSlice.RightEdge)
        setAlpha(GenericTraitFrame.NineSlice.LeftEdge)
        setAlpha(GenericTraitFrame.NineSlice.TopEdge)
        setAlpha(GenericTraitFrame.NineSlice.BottomEdge)
        setAlpha(GenericTraitFrame.NineSlice.TopRightCorner)
        setAlpha(GenericTraitFrame.NineSlice.TopLeftCorner)
        setAlpha(GenericTraitFrame.NineSlice.BottomLeftCorner)
        setAlpha(GenericTraitFrame.NineSlice.BottomRightCorner)

    elseif arg1=='Blizzard_PlayerChoice' then----任务选择
        C_Timer.After(0.3, function()
            if PlayerChoiceFrame.NineSlice then
                hideTexture(PlayerChoiceFrame.NineSlice.TopLeftCorner)
                hideTexture(PlayerChoiceFrame.NineSlice.TopEdge)
                hideTexture(PlayerChoiceFrame.NineSlice.TopRightCorner)
                hideTexture(PlayerChoiceFrame.NineSlice.BottomLeftCorner)
                hideTexture(PlayerChoiceFrame.NineSlice.BottomEdge)
                hideTexture(PlayerChoiceFrame.NineSlice.BottomRightCorner)
                hideTexture(PlayerChoiceFrame.NineSlice.RightEdge)
                hideTexture(PlayerChoiceFrame.NineSlice.LeftEdge)
            end
            if PlayerChoiceFrame.Title then
                setAlpha(PlayerChoiceFrame.Title.Middle)
                setAlpha(PlayerChoiceFrame.Title.Left)
                setAlpha(PlayerChoiceFrame.Title.Right)
            end
            if PlayerChoiceFrame.Background then
                hideTexture(PlayerChoiceFrame.Background.BackgroundTile)
            end
        end)
    end
end


local function set_PopupDialogs()
    local function get_TextToNumber(self)
        local num= self:GetText()
        num= tonumber(num)
        if num and num<1 and num>=0 then
            return num
        end
    end
    StaticPopupDialogs[id..addName..'Aplha']={--修该, 透明度
        text =id..' '..addName..'\n\n'..(e.onlyChinse and '透明度' or CHANGE_OPACITY).. '  |cnGREEN_FONT_COLOR:0 - 0.9|r\n\n|cnRED_FONT_COLOR:'..(e.onlyChinse and '重新加载UI' or RELOADUI),
        whileDead=1,
        hideOnEscape=1,
        exclusive=1,
        hasEditBox=1,
        button1= e.onlyChinse and '修改' or SLASH_CHAT_MODERATE2:gsub('/',''),
        button2= e.onlyChinse and '取消' or CANCEL,
        OnShow = function(self, data)
            self.editBox:SetText(Save.alpha or 0.5)
        end,
        OnAccept = function(self, data)
            local num= get_TextToNumber(self.editBox)
            if num then
                Save.alpha= num
                ReloadUI()
            end
        end,
        EditBoxOnTextChanged=function(self, data)
            local num= get_TextToNumber(self)
            if num then
                print(num)
            end
            self:GetParent().button1:SetEnabled(num and true or false)
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }
    StaticPopup_Show(id..addName..'Aplha')
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            e.Player.useClassColor= not Save.disabledColor--使用职业颜色
            Save.alpha= Save.alpha or 0.5

            --添加控制面板        
            local check=e.CPanel(e.onlyChinse and '隐藏材质' or addName, not Save.disabledTexture)
            check:SetScript('OnMouseDown', function()
                Save.disabledTexture= not Save.disabledTexture and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabledTexture), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            panel.check2=CreateFrame("CheckButton", nil, check, "InterfaceOptionsCheckButtonTemplate")
            panel.check2.text:SetText((e.onlyChinse and '透明度' or CHANGE_OPACITY)..Save.alpha)
            panel.check2:SetPoint('LEFT', check.text, 'RIGHT')
            panel.check2:SetChecked(not Save.disabledAlpha)
            panel.check2:SetScript('OnMouseDown', function()
                Save.disabledAlpha= not Save.disabledAlpha and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabledAlpha), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)


            local button= e.Cbtn(check, true, nil, nil, nil, nil, {20,20})
            button:SetPoint('LEFT', panel.check2.text, 'RIGHT',2,0)
            button:SetNormalAtlas('mechagon-projects')
            button:SetScript('OnClick', set_PopupDialogs)

            panel.check3=CreateFrame("CheckButton", nil, check, "InterfaceOptionsCheckButtonTemplate")
            panel.check3.text:SetText(e.Player.col..(e.onlyChinse and '职业颜色' or COLORS))
            panel.check3:SetPoint('LEFT', button, 'RIGHT')
            panel.check3:SetChecked(not Save.disabledColor)
            panel.check3:SetScript('OnMouseDown', function()
                Save.disabledColor= not Save.disabledColor and true or nil
                e.Player.useClassColor= not Save.disabledColor
                print(id, addName, e.GetEnabeleDisable(not Save.disabledColor), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)
            panel.check3:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.Player.col..(e.onlyChinse and '职业颜色' or CLASS_COLORS))
                e.tips:Show()
            end)
            panel.check3:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabledTexture and Save.disabledAlpha and Save.disabledColor then
                panel:UnregisterAllEvents()
            else
                Init_HideTexture()
                Init_Set_AlphaAndColor()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        else
            set_HideTexture_Event(arg1)
            set_Alpha_Event(arg1)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)