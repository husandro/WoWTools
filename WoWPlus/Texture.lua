local id, e= ...
local addName= TEXTURES_SUBHEADER
local Save={
    --disabledTexture= true,
    disabledAlpha= not e.Player.husandro,
    alpha= 0.5,
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,
}
local panel=CreateFrame("Frame")


local function hideTexture(self)
    if self then
        if self:GetObjectType()=='Texture' then
            self:SetTexture(0)
        end
        self:SetShown(false)
    end
end

local function setAlpha(self, notAlpha, notColor)
    if self then
        if not (Save.disabledAlpha or notAlpha)  then
            self:SetAlpha(Save.alpha)
        end
        if e.Player.useColor and self:GetObjectType()=='Texture' and not notColor then
            self:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
        end
    end
end

--隐藏, frame, 子材质
local function hide_Frame_Texture(frame, tab)
    if frame then
        tab= tab or {}
        local frames= {frame:GetRegions()}
        for index, icon in pairs(frames) do
            if tab.index then
                if tab.index==index then
                    hideTexture(icon)
                    break
                end
            elseif icon:GetObjectType()=="Texture" then
                icon:SetTexture(0)
                icon:SetShown(false)
            end
        end
    end
end

--透明度, 颜色, frame, 子材质
local function set_Alpha_Frame_Texture(frame, tab)
    if frame then
        tab=tab or {}
        local tabs= {frame:GetRegions()}
        for index, icon in pairs(tabs) do
            if tab.index== index then
                if not Save.disabledAlpha  then
                    icon:SetAlpha(Save.alpha)
                end
                if e.Player.useColor then
                    icon:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
                end
                return
            elseif icon:GetObjectType()=="Texture" then
                if not Save.disabledAlpha  then
                    icon:SetAlpha(Save.alpha)
                end
                if e.Player.useColor then
                    icon:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
                end
            end
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

    hide_Frame_Texture(PetBattleFrame.BottomFrame.MicroButtonFrame)

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

        CompactRaidFrameManager.toggleButton:SetNormalAtlas(e.Icon.toRight,true)--展开, 图标
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
        hooksecurefunc(WeeklyRewardsFrame,'UpdateOverlay', function(self)--Blizzard_WeeklyRewards.lua
            if self.Overlay and self.Overlay:IsShown() then--未提取,提示
                self.Overlay:SetScale(0.4)
                self.Overlay:ClearAllPoints()
                self.Overlay:SetPoint('TOPLEFT', 80,-60)
            end
        end)
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
    if Save.disabledAlpha then
        return
    end

    --骑士，能量条
    setAlpha(PaladinPowerBarFrameBG)
    setAlpha(PaladinPowerBarFrameBankBG)

    --角色，界面
    setAlpha(CharacterFrameBg)
    hideTexture(CharacterFrameInset.Bg)
    setAlpha(CharacterFrame.NineSlice.TopEdge)
    setAlpha(CharacterFrame.NineSlice.BottomEdge)
    setAlpha(CharacterFrame.NineSlice.LeftEdge)
    setAlpha(CharacterFrame.NineSlice.RightEdge)

    setAlpha(CharacterFrame.NineSlice.TopRightCorner)
    setAlpha(CharacterFrame.NineSlice.TopLeftCorner)
    setAlpha(CharacterFrame.NineSlice.BottomRightCorner)
    setAlpha(CharacterFrame.NineSlice.BottomLeftCorner)

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

    set_Alpha_Frame_Texture(SpellBookFrameTabButton1)
    set_Alpha_Frame_Texture(SpellBookFrameTabButton2)
    set_Alpha_Frame_Texture(SpellBookFrameTabButton3)

    --[[set_Alpha_Frame_Texture(SpellBookSkillLineTab1)
    set_Alpha_Frame_Texture(SpellBookSkillLineTab2)
    set_Alpha_Frame_Texture(SpellBookSkillLineTab3)
    set_Alpha_Frame_Texture(SpellBookSkillLineTab4)
    set_Alpha_Frame_Texture(SpellBookSkillLineTab5)
    set_Alpha_Frame_Texture(SpellBookSkillLineTab6)]]
    --hide_Frame_Texture(SpellBookSkillLineTab1, {index=3})
    --hide_Frame_Texture(SpellBookSkillLineTab1, {index=2})
    --hide_Frame_Texture(SpellBookSkillLineTab1, {index=1})


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
    setAlpha(RaidFinderFrameRoleBackground, nil, true)
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

    set_Alpha_Frame_Texture(PVEFrameTab1)
    set_Alpha_Frame_Texture(PVEFrameTab2)
    set_Alpha_Frame_Texture(PVEFrameTab3)

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
    if ContainerFrameCombinedBags and ContainerFrameCombinedBags.NineSlice then
        setAlpha(ContainerFrameCombinedBags.NineSlice.TopEdge)
        setAlpha(ContainerFrameCombinedBags.NineSlice.LeftEdge)
        setAlpha(ContainerFrameCombinedBags.NineSlice.RightEdge)

        setAlpha(ContainerFrameCombinedBags.NineSlice.BottomEdge)

        setAlpha(ContainerFrameCombinedBags.NineSlice.TopLeftCorner)
        setAlpha(ContainerFrameCombinedBags.NineSlice.TopRightCorner)
        setAlpha(ContainerFrameCombinedBags.NineSlice.BottomRightCorner)
        setAlpha(ContainerFrameCombinedBags.NineSlice.BottomLeftCorner)
        setAlpha(ContainerFrameCombinedBags.MoneyFrame.Border.Middle)
        setAlpha(ContainerFrameCombinedBags.MoneyFrame.Border.Right)
        setAlpha(ContainerFrameCombinedBags.MoneyFrame.Border.Left)

        setAlpha(ContainerFrameCombinedBags.Bg.TopSection, true)
        --setAlpha(ContainerFrameCombinedBags.Bg.BottomEdge)
        --setAlpha(ContainerFrameCombinedBags.Bg.BottomRight)
        --setAlpha(ContainerFrameCombinedBags.Bg.BottomLeft)
        setAlpha(BagItemSearchBox.Middle)
        setAlpha(BagItemSearchBox.Left)
        setAlpha(BagItemSearchBox.Right)
    end
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame and frame.NineSlice then
            setAlpha(frame.Bg.TopSection, true)
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
            if e.Player.useColor then
                button.NormalTexture:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
            end
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
    hide_Frame_Texture(CharacterHeadSlot)--1
    hide_Frame_Texture(CharacterNeckSlot)--2
    hide_Frame_Texture(CharacterShoulderSlot)--3
    hide_Frame_Texture(CharacterShirtSlot)--4
    hide_Frame_Texture(CharacterChestSlot)--5
    hide_Frame_Texture(CharacterWaistSlot)--6
    hide_Frame_Texture(CharacterLegsSlot)--7
    hide_Frame_Texture(CharacterFeetSlot)--8
    hide_Frame_Texture(CharacterWristSlot)--9
    hide_Frame_Texture(CharacterHandsSlot)--10
    hide_Frame_Texture(CharacterBackSlot)--15
    hide_Frame_Texture(CharacterTabardSlot)--19
    hide_Frame_Texture(CharacterFinger0Slot)--11
    hide_Frame_Texture(CharacterFinger1Slot)--12
    hide_Frame_Texture(CharacterTrinket0Slot)--13
    hide_Frame_Texture(CharacterTrinket1Slot)--14
    hide_Frame_Texture(CharacterMainHandSlot)--16
    hide_Frame_Texture(CharacterSecondaryHandSlot)--17

    set_Alpha_Frame_Texture(CharacterFrameTab1)
    set_Alpha_Frame_Texture(CharacterFrameTab2)
    set_Alpha_Frame_Texture(CharacterFrameTab3)

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

    set_Alpha_Frame_Texture(FriendsFrameTab1)
    set_Alpha_Frame_Texture(FriendsFrameTab2)
    set_Alpha_Frame_Texture(FriendsFrameTab3)
    set_Alpha_Frame_Texture(FriendsFrameTab4)

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
    setAlpha(GroupLootHistoryFrame.NineSlice.TopRightCorner)
    setAlpha(GroupLootHistoryFrame.NineSlice.TopEdge)
    setAlpha(GroupLootHistoryFrame.NineSlice.TopLeftCorner)
    setAlpha(GroupLootHistoryFrame.NineSlice.RightEdge)
    setAlpha(GroupLootHistoryFrame.NineSlice.LeftEdge)
    setAlpha(GroupLootHistoryFrame.NineSlice.BottomLeftCorner)
    setAlpha(GroupLootHistoryFrame.NineSlice.BottomRightCorner)
    setAlpha(GroupLootHistoryFrame.NineSlice.BottomEdge)
    setAlpha(GroupLootHistoryFrameBg)
    setAlpha(GroupLootHistoryFrame.ScrollBar.Track.Middle)
    setAlpha(GroupLootHistoryFrame.ScrollBar.Track.Begin)
    setAlpha(GroupLootHistoryFrame.ScrollBar.Track.End)

    setAlpha(GroupLootHistoryFrameMiddle)
    setAlpha(GroupLootHistoryFrameLeft)
    setAlpha(GroupLootHistoryFrameRight)
    setAlpha()

    
    

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
    --[[if ObjectiveTrackerBlocksFrame then
        setAlpha(ObjectiveTrackerBlocksFrame.ScenarioHeader.Background)
        setAlpha(ObjectiveTrackerBlocksFrame.AchievementHeader.Background)
        setAlpha(ObjectiveTrackerBlocksFrame.QuestHeader.Background)
        hooksecurefunc('ScenarioStage_UpdateOptionWidgetRegistration', function(stageBlock, widgetSetID)
            setAlpha(stageBlock.NormalBG, nil, true)
            setAlpha(stageBlock.FinalBG)
        end)
    end]]

    --小地图
    setAlpha(MinimapCompassTexture)

    --[[对话框
    if StaticPopup1 then
        if StaticPopup1.Border then
            setAlpha(StaticPopup1.Border.Bg)
        end
    end]]

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
            setAlpha(frame:GetNormalTexture(), true)
        end
    end

    if MainStatusTrackingBarContainer then--货币，XP，追踪，最下面BAR
        hideTexture(MainStatusTrackingBarContainer.BarFrameTexture)
    end
    

    C_Timer.After(3, function()
        if SpellFlyout and SpellFlyout.Background then--Spell Flyout
            hideTexture(SpellFlyout.Background.HorizontalMiddle)
            hideTexture(SpellFlyout.Background.End)
            hideTexture(SpellFlyout.Background.VerticalMiddle)
        end

        for i=1, GetNumAddOns() do
            local t= GetAddOnEnableState(nil,i);
            if t==2 then
                local name=GetAddOnInfo(i)
                name= name:match('(.-)%-') or name
                if name then
                    set_Alpha_Frame_Texture(_G['LibDBIcon10_'..name], {index=2})
                end
            end
        end
    end)
end

--#########
--事件, 透明
--#########
local function set_Alpha_Event(arg1)
    if Save.disabledAlpha then
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
        set_Alpha_Frame_Texture(AchievementFrameTab1)
        set_Alpha_Frame_Texture(AchievementFrameTab2)
        set_Alpha_Frame_Texture(AchievementFrameTab3)

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

        hide_Frame_Texture(CommunitiesFrame.ChatTab, {index=1})
        hide_Frame_Texture(CommunitiesFrame.RosterTab, {index=1})
        hide_Frame_Texture(CommunitiesFrame.GuildBenefitsTab, {index=1})
        hide_Frame_Texture(CommunitiesFrame.GuildInfoTab, {index=1})
        hide_Frame_Texture(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, {index=1})
        hide_Frame_Texture(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, {index=1})

        setAlpha(ClubFinderGuildFinderFrame.InsetFrame.Bg)


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
        hideTexture(LFDQueueFrameSpecific.ScrollBar.Backplate)

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        setAlpha(EncounterJournal.NineSlice.TopLeftEdge)
        setAlpha(EncounterJournal.NineSlice.TopEdge)
        setAlpha(EncounterJournal.NineSlice.TopRightEdge)
        setAlpha(EncounterJournal.NineSlice.TopRightCorner)
        setAlpha(EncounterJournal.NineSlice.TopLeftCorner)

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

        set_Alpha_Frame_Texture(EncounterJournalSuggestTab)
        set_Alpha_Frame_Texture(EncounterJournalMonthlyActivitiesTab)
        set_Alpha_Frame_Texture(EncounterJournalDungeonTab)
        set_Alpha_Frame_Texture(EncounterJournalRaidTab)

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
        --[[for v=1,6 do--物品,幻化, 背景
            for h= 1, 3 do
                local button= WardrobeCollectionFrame.ItemsCollectionFrame['ModelR'..h..'C'..v]
                if button then
                    button:DisableDrawLayer('BACKGROUND')
                end
            end
        end]]
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

        set_Alpha_Frame_Texture(CollectionsJournalTab1)
        set_Alpha_Frame_Texture(CollectionsJournalTab2)
        set_Alpha_Frame_Texture(CollectionsJournalTab3)
        set_Alpha_Frame_Texture(CollectionsJournalTab4)
        set_Alpha_Frame_Texture(CollectionsJournalTab5)

        if RematchJournal then
            setAlpha(RematchJournal.NineSlice.TopEdge)
            setAlpha(RematchJournal.NineSlice.TopRightCorner)
            setAlpha(RematchJournal.NineSlice.TopLeftCorner)
            setAlpha(RematchJournalBg)
            setAlpha(RematchLoadoutPanel.Target.InsetBack)
            hideTexture(RematchPetPanel.Top.InsetBack)
            setAlpha(RematchQueuePanel.List.Background.InsetBack)
            setAlpha(RematchQueuePanel.Top.InsetBack)
            hideTexture(RematchPetPanel.Top.TypeBar.NineSlice)
            setAlpha(RematchTeamPanel.List.Background.InsetBack)
            setAlpha(RematchOptionPanel.List.Background.InsetBack)
            setAlpha(RematchLoadoutPanel.TopLoadout.InsetBack)
        end
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
        setAlpha(CalendarCreateEventFrame.Border.Bg)


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
    elseif arg1=='Blizzard_MajorFactions' then--派系声望
        setAlpha(MajorFactionRenownFrame.Background)
    end
end

local function Init_chatBubbles()--聊天泡泡
    local chatBubblesEvents={
        'CHAT_MSG_SAY',
        'CHAT_MSG_YELL',
        'CHAT_MSG_PARTY',
        'CHAT_MSG_PARTY_LEADER',
        'CHAT_MSG_RAID',
        'CHAT_MSG_RAID_LEADER',
        'CHAT_MSG_MONSTER_PARTY',
        'CHAT_MSG_MONSTER_SAY',
        'CHAT_MSG_MONSTER_YELL',
    }
    if not Save.disabledChatBubble then
        FrameUtil.RegisterFrameForEvents(panel, chatBubblesEvents)
    else
        FrameUtil.UnregisterFrameForEvents(panel, chatBubblesEvents);
    end
end


local function options_Init()--添加控制面板
    panel.name = '|A:AnimCreate_Icon_Texture:0:0|a'..(e.onlyChinese and '材质' or addName)
    panel.parent =id
    InterfaceOptions_AddCategory(panel)

    e.ReloadPanel({panel=panel, addName= addName, restTips=true, checked=nil,--重新加载UI, 重置, 按钮
        disabledfunc=nil,
        clearfunc= function() Save=nil e.Reload() end}
    )

    local textureCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    textureCheck.text:SetText('1)'..(e.onlyChinese and '隐藏材质' or HIDE..addName))
    textureCheck:SetChecked(not Save.disabledTexture)
    textureCheck:SetPoint('TOPLEFT', 0, -48)
    textureCheck:SetScript('OnMouseDown', function()
        Save.disabledTexture= not Save.disabledTexture and true or nil
    end)

    local alphaCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    alphaCheck.text:SetText('2)'..(e.onlyChinese and '透明度' or CHANGE_OPACITY))
    alphaCheck:SetPoint('TOPLEFT', textureCheck, 'BOTTOMLEFT', 0, -16)
    alphaCheck:SetChecked(not Save.disabledAlpha)
    alphaCheck:SetScript('OnMouseDown', function()
        Save.disabledAlpha= not Save.disabledAlpha and true or false
    end)

    local alphaValue= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    alphaValue:SetPoint("LEFT", alphaCheck.text, 'RIGHT', 6,0)
    alphaValue:SetSize(200,20)
    alphaValue:SetMinMaxValues(0, 0.9)
    alphaValue:SetValue(Save.alpha)
    alphaValue.Low:SetText('0')
    alphaValue.High:SetText('0.9')
    alphaValue.Text:SetText(Save.alpha)
    alphaValue:SetValueStep(0.1)
    alphaValue:SetScript('OnValueChanged', function(self, value, userInput)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.alpha= value==0 and 0 or value
    end)


    --聊天泡泡 ChatBubble
    local chatBubbleCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    chatBubbleCheck.text:SetText('3)'..(e.onlyChinese and '聊天泡泡: 副本无效' or (CHAT_BUBBLES_TEXT..': '..INSTANCE..' ('..NO..')')))
    chatBubbleCheck:SetPoint('TOPLEFT', alphaCheck, 'BOTTOMLEFT', 0, -16)
    chatBubbleCheck:SetChecked(not Save.disabledChatBubble)
    chatBubbleCheck:SetScript('OnMouseDown', function()
        Save.disabledChatBubble= not Save.disabledChatBubble and true or false
    end)
    chatBubbleCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.onlyChinese and '说' or SAY, 'CVar: chatBubbles '.. e.GetShowHide(C_CVar.GetCVarBool("chatBubbles")))
        e.tips:AddDoubleLine(e.onlyChinese and '小队' or CHAT_MSG_PARTY, 'CVar: chatBubblesParty '.. e.GetShowHide(C_CVar.GetCVarBool("chatBubblesParty")))
        e.tips:Show()
    end)
    chatBubbleCheck:SetScript('OnLeave', function() e.tips:Hide() end)

    local chatBubbleAlpha=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    chatBubbleAlpha.text:SetText(e.onlyChinese and '透明度' or CHANGE_OPACITY)
    chatBubbleAlpha:SetPoint('TOPLEFT', chatBubbleCheck, 'BOTTOMRIGHT')
    chatBubbleAlpha:SetChecked(not Save.disabledChatBubbleAlpha)
    chatBubbleAlpha:SetScript('OnMouseDown', function()
        Save.disabledChatBubbleAlpha= not Save.disabledChatBubbleAlpha and true or false
    end)

    local chaAlphaValue= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    chaAlphaValue:SetPoint("LEFT", chatBubbleAlpha.text, 'RIGHT', 6,0)
    chaAlphaValue:SetSize(200,20)
    chaAlphaValue:SetMinMaxValues(0, 0.9)
    chaAlphaValue:SetValue(Save.chatBubbleAlpha)
    chaAlphaValue.Low:SetText('0')
    chaAlphaValue.High:SetText('0.9')
    chaAlphaValue.Text:SetText(Save.chatBubbleAlpha)
    chaAlphaValue:SetValueStep(0.1)
    chaAlphaValue:SetScript('OnValueChanged', function(self, value, userInput)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.chatBubbleAlpha= value==0 and 0 or value
    end)

    local chatBubbleSacale=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    chatBubbleSacale.text:SetText(e.onlyChinese and '缩放' or UI_SCALE)
    chatBubbleSacale:SetPoint('TOPLEFT', chatBubbleAlpha, 'BottomLEFT', 0, -12)
    chatBubbleSacale:SetChecked(not Save.disabledChatBubbleSacal)
    chatBubbleSacale:SetScript('OnMouseDown', function()
        Save.disabledChatBubbleSacal= not Save.disabledChatBubbleSacal and true or false
    end)

    local chaScaleValue= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    chaScaleValue:SetPoint("LEFT", chatBubbleSacale.text, 'RIGHT', 6,0)
    chaScaleValue:SetSize(200,20)
    chaScaleValue:SetMinMaxValues(0.3, 2)
    chaScaleValue:SetValue(Save.chatBubbleSacal)
    chaScaleValue.Low:SetText('0.3')
    chaScaleValue.High:SetText('2')
    chaScaleValue.Text:SetText(Save.chatBubbleSacal)
    chaScaleValue:SetValueStep(0.01)
    chaScaleValue:SetScript('OnValueChanged', function(self, value, userInput)
        value= tonumber(format('%.2f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.chatBubbleSacal=value
    end)
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName] or Save

            options_Init()

            if Save.disabledTexture and Save.disabledAlpha and Save.disabledChatBubble then
                panel:UnregisterAllEvents()
            else
                Init_HideTexture()
                Init_Set_AlphaAndColor()
                if not Save.disabledChatBubble then
                    Init_chatBubbles()
                end
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        else
            set_HideTexture_Event(arg1)
            set_Alpha_Event(arg1)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then

            WoWToolsSave[addName]=Save
        end

    else--ChatBubbles https://wago.io/yyX84OlOD
        C_Timer.After(0, function()
            for _, buble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
                if not buble.setAlpha then
                    local frame= buble:GetChildren()
                    if frame then
                        if not Save.disabledChatBubbleSacal and Save.chatBubbleSacal~=1 then
                            local fontString = frame.String
                            local point, relativeTo, relativePoint, ofsx, ofsy = fontString:GetPoint(1)
                            local currentScale= buble:GetScale()
                            frame:SetScale(Save.chatBubbleSacal)
                            if point then
                                local scaleRatio = Save.chatBubbleSacal / currentScale
                                fontString:SetPoint(point, relativeTo, relativePoint, ofsx / scaleRatio, ofsy / scaleRatio)
                            end
                        end
                        if not Save.disabledChatBubbleAlpha then
                            local tab={frame:GetRegions()}
                            for _, frame2 in pairs(tab) do
                                if frame2:GetObjectType()=='Texture' then-- .String
                                    frame2:SetAlpha(Save.chatBubbleAlpha)
                                    if not Save.disabledColor then
                                        frame2:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
                                    end
                                end
                            end
                        end
                        buble.setAlpha= true
                    end
                end
            end
        end)
    end
end)