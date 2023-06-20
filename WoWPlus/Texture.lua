local id, e= ...
local addName= TEXTURES_SUBHEADER
local Save={
    --disabledTexture= true,
    disabledAlpha= not e.Player.husandro,
    alpha= 0.5,
    chatBubbleAlpha= 0.5,--聊天泡泡
    chatBubbleSacal= 0.85,
    classPowerNum= e.Player.husandro,--职业，显示数字
}
local panel=CreateFrame("Frame")


local function hide_Texture(self, notClear)
    if self then
        if self:GetObjectType()=='Texture' then
            if not notClear then
                self:SetTexture(0)
            end
        end
        self:SetShown(false)
    end
end

local function set_Alpha(self, notAlpha, notColor, value)
    if self then
        if not (Save.disabledAlpha or notAlpha)  then
            self:SetAlpha(value or Save.alpha)
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
                    hide_Texture(icon)
                    break
                end
            elseif icon:GetObjectType()=="Texture" then
                icon:SetTexture(0)
                icon:SetShown(false)
            end
        end
    end
end

--透明度, 颜色, frame, 子材质 set_Alpha_Frame_Texture(frame, {index=nil, notAlpha=nil, notColor=nil})
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
                if not Save.disabledAlpha and not tab.notAlpha  then
                    icon:SetAlpha(Save.alpha)
                end
                if e.Player.useColor and not tab.notColor then
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
            hide_Texture(OverrideActionBarEndCapL)
            hide_Texture(OverrideActionBarEndCapR)
            hide_Texture(OverrideActionBarBorder)
            hide_Texture(OverrideActionBarBG)
            hide_Texture(OverrideActionBarButtonBGMid)
            hide_Texture(OverrideActionBarButtonBGR)
            hide_Texture(OverrideActionBarButtonBGL)
        end
        if OverrideActionBarMicroBGMid then
            hide_Texture(OverrideActionBarMicroBGMid)
            hide_Texture(OverrideActionBarMicroBGR)
            hide_Texture(OverrideActionBarMicroBGL)
            hide_Texture(OverrideActionBarLeaveFrameExitBG)

            hide_Texture(OverrideActionBarDivider2)
            hide_Texture(OverrideActionBarLeaveFrameDivider3)
        end
        if OverrideActionBarExpBar then
            hide_Texture(OverrideActionBarExpBarXpMid)
            hide_Texture(OverrideActionBarExpBarXpR)
            hide_Texture(OverrideActionBarExpBarXpL)
        end
    end)
    if ExtraActionButton1 then hide_Texture(ExtraActionButton1.style) end--额外技能
    if ZoneAbilityFrame then hide_Texture(ZoneAbilityFrame.Style) end--区域技能

    if MainMenuBar and MainMenuBar.EndCaps then hide_Texture(MainMenuBar.EndCaps.LeftEndCap) end
    if MainMenuBar and MainMenuBar.EndCaps then hide_Texture(MainMenuBar.EndCaps.RightEndCap) end

    if PetBattleFrame then--宠物
        hide_Texture(PetBattleFrame.TopArtLeft)
        hide_Texture(PetBattleFrame.TopArtRight)
        hide_Texture(PetBattleFrame.TopVersus)
        PetBattleFrame.TopVersusText:SetText('')
        PetBattleFrame.TopVersusText:SetShown(false)
        hide_Texture(PetBattleFrame.WeatherFrame.BackgroundArt)

        hide_Texture(PetBattleFrameXPBarLeft)
        hide_Texture(PetBattleFrameXPBarRight)
        hide_Texture(PetBattleFrameXPBarMiddle)

        if PetBattleFrame.BottomFrame then
            hide_Texture(PetBattleFrame.BottomFrame.LeftEndCap)
            hide_Texture(PetBattleFrame.BottomFrame.RightEndCap)
            hide_Texture(PetBattleFrame.BottomFrame.Background)
            hide_Texture(PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2)
            PetBattleFrame.BottomFrame.FlowFrame:SetShown(false)
            PetBattleFrame.BottomFrame.Delimiter:SetShown(false)
        end
    end

    hide_Frame_Texture(PetBattleFrame.BottomFrame.MicroButtonFrame)

    hooksecurefunc('PetBattleFrame_UpdatePassButtonAndTimer', function(self)--Blizzard_PetBattleUI.lua
        hide_Texture(self.BottomFrame.TurnTimer.TimerBG)
        --self.BottomFrame.TurnTimer.Bar:SetShown(true);
        hide_Texture(self.BottomFrame.TurnTimer.ArtFrame);
        hide_Texture(self.BottomFrame.TurnTimer.ArtFrame2);
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
        hide_Texture(MainMenuBar.BorderArt.TopEdge)
        hide_Texture(MainMenuBar.BorderArt.BottomEdge)
        hide_Texture(MainMenuBar.BorderArt.LeftEdge)
        hide_Texture(MainMenuBar.BorderArt.RightEdge)
        hide_Texture(MainMenuBar.BorderArt.TopLeftCorner)
        hide_Texture(MainMenuBar.BorderArt.BottomLeftCorner)
        hide_Texture(MainMenuBar.BorderArt.TopRightCorner)
        hide_Texture(MainMenuBar.BorderArt.BottomRightCorner)
    end
    if MultiBarBottomLeftButton10 then hide_Texture(MultiBarBottomLeftButton10.SlotBackground) end

     if CompactRaidFrameManager then--隐藏, 团队, 材质 Blizzard_CompactRaidFrameManager.lua
        hide_Texture(CompactRaidFrameManagerBorderTop)
        hide_Texture(CompactRaidFrameManagerBorderRight)
        hide_Texture(CompactRaidFrameManagerBorderBottom)
        hide_Texture(CompactRaidFrameManagerBorderTopRight)
        hide_Texture(CompactRaidFrameManagerBorderTopLeft)
        hide_Texture(CompactRaidFrameManagerBorderBottomLeft)
        hide_Texture(CompactRaidFrameManagerBorderBottomRight)
        hide_Texture(CompactRaidFrameManagerDisplayFrameHeaderDelineator)
        hide_Texture(CompactRaidFrameManagerDisplayFrameHeaderBackground)
        hide_Texture(CompactRaidFrameManagerBg)
        hide_Texture(CompactRaidFrameManagerDisplayFrameFilterOptionsFooterDelineator)

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
            hide_Texture(self.SlotArt)
            hide_Texture(self.SlotBackground)--背景，
            hide_Texture(self.NormalTexture)--外框，方块
            if self.RightDivider and self.BottomDivider then
                self.RightDivider:SetShown(false)--frame
                self.BottomDivider:SetShown(false)
                hide_Texture(self.RightDivider.TopEdge)
                hide_Texture(self.RightDivider.BottomEdge)
                hide_Texture(self.RightDivider.Center)
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

    --####
    --职业
    --####
    local function set_Num_Texture(self, num, color)
        if not self.numTexture and (self.layoutIndex or num) and Save.classPowerNum then
            self.numTexture= self:CreateTexture(nil, 'OVERLAY')
            self.numTexture:SetSize(12,12)
            self.numTexture:SetPoint('CENTER', self, 'CENTER')
            self.numTexture:SetAtlas(e.Icon.number..(num or self.layoutIndex))
            if color~=false then
                if not color then
                    set_Alpha(self.numTexture, true)
                else
                    self.numTexture:SetVertexColor(color.r, color.g, color.b)
                end
            end
        end
    end
    if e.Player.class=='PALADIN' then--QS PaladinPowerBarFrame
        if PaladinPowerBarFrame and PaladinPowerBarFrame.Background and PaladinPowerBarFrame.ActiveTexture then
            hide_Texture(PaladinPowerBarFrame.Background, true)
            hide_Texture(PaladinPowerBarFrame.ActiveTexture, true)
            PaladinPowerBarFrame:HookScript('OnEnter', function(self2)
                self2.Background:SetShown(true)
                self2.ActiveTexture:SetShown(true)
            end)
            PaladinPowerBarFrame:HookScript('OnLeave', function(self2)
                hide_Texture(self2.Background, true)
                hide_Texture(self2.ActiveTexture, true)
            end)
            if ClassNameplateBarPaladinFrame then
                hide_Texture(ClassNameplateBarPaladinFrame.Background)
                hide_Texture(ClassNameplateBarPaladinFrame.ActiveTexture)
            end
            local maxHolyPower = UnitPowerMax('player', Enum.PowerType.HolyPower)--UpdatePower
            for i=1,maxHolyPower do
                local holyRune = PaladinPowerBarFrame["rune"..i]
                set_Num_Texture(holyRune, i, false)
            end
        end

    elseif e.Player.class=='MAGE' then--法师
        if MageArcaneChargesFrame and MageArcaneChargesFrame.classResourceButtonTable then
            for _, mage in pairs(MageArcaneChargesFrame.classResourceButtonTable) do
                hide_Texture(mage.ArcaneBG)
            end
            if ClassNameplateBarMageFrame and ClassNameplateBarMageFrame.classResourceButtonTable then
                for _, mage in pairs(ClassNameplateBarMageFrame.classResourceButtonTable) do
                    hide_Texture(mage.ArcaneBG)
                end
            end
        end

    elseif e.Player.class=='DRUID' then--DruidComboPointBarFrame
        local function set_DruidComboPointBarFrame(self)
            if self then
                for btn, _ in pairs(self) do
                    hide_Texture(btn.BG_Active)
                    hide_Texture(btn.BG_Inactive)
                    set_Num_Texture(btn)
                end
            end
        end
        set_DruidComboPointBarFrame(DruidComboPointBarFrame and DruidComboPointBarFrame.classResourceButtonPool and DruidComboPointBarFrame.classResourceButtonPool.activeObjects)
        if DruidComboPointBarFrame then
            DruidComboPointBarFrame:HookScript('OnEvent', function(self)
                set_DruidComboPointBarFrame(self.classResourceButtonPool.activeObjects)
            end)
        end
        if ClassNameplateBarFeralDruidFrame and ClassNameplateBarFeralDruidFrame.classResourceButtonTable then
            for _, btn in pairs(ClassNameplateBarFeralDruidFrame.classResourceButtonTable) do
                hide_Texture(btn.BG_Active)
                hide_Texture(btn.BG_Inactive)
                set_Num_Texture(btn)
            end
        end

    elseif e.Player.class=='ROGUE' then--DZ RogueComboPointBarFrame
        if RogueComboPointBarFrame and RogueComboPointBarFrame.UpdateMaxPower then
            hooksecurefunc(RogueComboPointBarFrame, 'UpdateMaxPower',function(self)
                C_Timer.After(0.5, function()
                    for _, btn in pairs(self.classResourceButtonTable or {}) do
                        hide_Texture(btn.BGActive)
                        hide_Texture(btn.BGInactive)
                        set_Alpha(btn.BGShadow, nil, nil, 0.3)
                        set_Num_Texture(btn)
                    end
                    if ClassNameplateBarRogueFrame and ClassNameplateBarRogueFrame.classResourceButtonTable then
                        for _, btn in pairs(ClassNameplateBarRogueFrame.classResourceButtonTable) do
                            hide_Texture(btn.BGActive)
                            hide_Texture(btn.BGInactive)
                            set_Alpha(btn.BGShadow, nil, nil, 0.3)
                            set_Num_Texture(btn)
                        end
                    end
                end)
            end)
        end

    elseif e.Player.class=='MONK' then--MonkHarmonyBarFrame
        local function set_MonkHarmonyBarFrame(btn)
            if btn then
                hide_Texture(btn.Chi_BG_Active)
                hide_Texture(btn.BGInactive)
                set_Alpha(btn.Chi_BG, nil, nil, 0.2)
                set_Num_Texture(btn)
            end
        end
        hooksecurefunc(MonkHarmonyBarFrame, 'UpdateMaxPower', function(self)
            C_Timer.After(0.5, function()
                for i = 1, #self.classResourceButtonTable do
                    set_MonkHarmonyBarFrame(self.classResourceButtonTable[i])
                end
                local tab= ClassNameplateBarWindwalkerMonkFrame and ClassNameplateBarWindwalkerMonkFrame.classResourceButtonTable or {}
                for i = 1, #tab do
                    set_MonkHarmonyBarFrame(tab[i])
                end
            end)
        end)
        hooksecurefunc(MonkHarmonyBarFrame, 'UpdatePower', function(self)
            for _, btn in pairs(self.classResourceButtonTable or {}) do
                if btn.Chi_BG then
                    btn.Chi_BG:SetAlpha(0.2)
                end
            end
            if ClassNameplateBarWindwalkerMonkFrame then
                for _, btn in pairs(ClassNameplateBarWindwalkerMonkFrame.classResourceButtonTable or {}) do
                    if btn.Chi_BG then
                        btn.Chi_BG:SetAlpha(0.2)
                    end
                end
            end
        end)
    elseif e.Player.class=='DEATHKNIGHT' then
        if RuneFrame.Runes then
            for _, btn in pairs(RuneFrame.Runes) do
                hide_Texture(btn.BG_Active)
                hide_Texture(btn.BG_Inactive)
            end
        end
        if DeathKnightResourceOverlayFrame.Runes then
            for _, btn in pairs(DeathKnightResourceOverlayFrame.Runes) do
                hide_Texture(btn.BG_Active)
                hide_Texture(btn.BG_Inactive)
            end
        end
    end


    --角色，界面
    set_Alpha(CharacterFrameBg)
    hide_Texture(CharacterFrameInset.Bg)
    set_Alpha(CharacterFrame.NineSlice.TopEdge)
    set_Alpha(CharacterFrame.NineSlice.BottomEdge)
    set_Alpha(CharacterFrame.NineSlice.LeftEdge)
    set_Alpha(CharacterFrame.NineSlice.RightEdge)

    set_Alpha(CharacterFrame.NineSlice.TopRightCorner)
    set_Alpha(CharacterFrame.NineSlice.TopLeftCorner)
    set_Alpha(CharacterFrame.NineSlice.BottomRightCorner)
    set_Alpha(CharacterFrame.NineSlice.BottomLeftCorner)

    hide_Texture(CharacterFrameInsetRight.Bg)
    set_Alpha(CharacterStatsPane.ClassBackground)
    set_Alpha(CharacterStatsPane.EnhancementsCategory.Background)
    set_Alpha(CharacterStatsPane.AttributesCategory.Background)
    set_Alpha(CharacterStatsPane.ItemLevelCategory.Background)
    hooksecurefunc('PaperDollTitlesPane_UpdateScrollBox', function()--PaperDollFrame.lua
        for _, button in pairs(PaperDollFrame.TitleManagerPane.ScrollBox:GetFrames()) do
            hide_Texture(button.BgMiddle)
        end
    end)
    hide_Texture(PaperDollFrame.TitleManagerPane.ScrollBar.Backplate)
    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function()--PaperDollFrame.lua
        for _, button in pairs(PaperDollFrame.EquipmentManagerPane.ScrollBox:GetFrames()) do
            hide_Texture(button.BgMiddle)
        end
    end)
    hide_Texture(PaperDollFrame.EquipmentManagerPane.ScrollBar.Backplate)
    hide_Texture(ReputationFrame.ScrollBar.Backplate)
    hide_Texture(TokenFrame.ScrollBar.Backplate)

    hide_Texture(CharacterModelFrameBackgroundTopLeft)--角色3D背景
    hide_Texture(CharacterModelFrameBackgroundTopRight)
    hide_Texture(CharacterModelFrameBackgroundBotLeft)
    hide_Texture(CharacterModelFrameBackgroundBotRight)
    hide_Texture(CharacterModelFrameBackgroundOverlay)

    --法术书
    set_Alpha(SpellBookFrame.NineSlice.TopLeftCorner)
    set_Alpha(SpellBookFrame.NineSlice.TopEdge)
    set_Alpha(SpellBookFrame.NineSlice.TopRightCorner)
    if SpellBookPageText then
        SpellBookPageText:SetTextColor(1, 0.82, 0)
    end

    hide_Texture(SpellBookPage1)
    hide_Texture(SpellBookPage2)
    set_Alpha(SpellBookFrameBg)
    hide_Texture(SpellBookFrameInset.Bg)

    for i=1, 12 do
        set_Alpha(_G['SpellButton'..i..'Background'])
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


    --世界地图
    set_Alpha(WorldMapFrame.BorderFrame.NineSlice.TopLeftCorner)
    set_Alpha(WorldMapFrame.BorderFrame.NineSlice.TopEdge)
    set_Alpha(WorldMapFrame.BorderFrame.NineSlice.TopRightCorner)
    set_Alpha(WorldMapFrameBg)
    set_Alpha(QuestMapFrame.Background)
    WorldMapFrame.NavBar:DisableDrawLayer('BACKGROUND')

    --地下城和团队副本
    set_Alpha(PVEFrame.NineSlice.TopLeftCorner)
    set_Alpha(PVEFrame.NineSlice.TopEdge)
    set_Alpha(PVEFrame.NineSlice.TopRightCorner)
    set_Alpha(LFGListFrame.CategorySelection.Inset.CustomBG)
    hide_Texture(LFGListFrame.CategorySelection.Inset.Bg)
    set_Alpha(LFGListFrame.SearchPanel.SearchBox.Middle)
    set_Alpha(LFGListFrame.SearchPanel.SearchBox.Left)
    set_Alpha(LFGListFrame.SearchPanel.SearchBox.Right)
    set_Alpha(LFGListFrame.SearchPanel.ScrollBar.Backplate)
    set_Alpha(LFGListFrame.EntryCreation.Inset.CustomBG)
    set_Alpha(LFGListFrame.EntryCreation.Inset.Bg)
    set_Alpha(LFGListFrameMiddleMiddle)
    set_Alpha(LFGListFrameMiddleLeft)
    set_Alpha(LFGListFrameMiddleRight)
    set_Alpha(LFGListFrameBottomMiddle)
    set_Alpha(LFGListFrameTopMiddle)
    set_Alpha(LFGListFrameTopLeft)
    set_Alpha(LFGListFrameBottomLeft)
    set_Alpha(LFGListFrameTopRight)
    set_Alpha(LFGListFrameBottomRight)
    set_Alpha(RaidFinderFrameBottomInset.Bg)
    set_Alpha(RaidFinderQueueFrameBackground)
    set_Alpha(RaidFinderQueueFrameSelectionDropDownMiddle)
    set_Alpha(RaidFinderQueueFrameSelectionDropDownLeft)
    set_Alpha(RaidFinderQueueFrameSelectionDropDownRight)
    set_Alpha(RaidFinderFrameRoleBackground, nil, true)
    set_Alpha(RaidFinderFrameRoleInset.Bg)

    hide_Texture(PVEFrameBg)--左边
    hide_Texture(PVEFrameBlueBg)
    set_Alpha(PVEFrameLeftInset.Bg)

    set_Alpha(LFDQueueFrameBackground)
    set_Alpha(LFDQueueFrameTypeDropDownMiddle)
    set_Alpha(LFDQueueFrameTypeDropDownRight)
    set_Alpha(LFDQueueFrameTypeDropDownLeft)

    set_Alpha(LFDParentFrameInset.Bg)
    set_Alpha(LFDParentFrameRoleBackground)

    --专业
    set_Alpha(ProfessionsFrame.NineSlice.TopLeftCorner)
    set_Alpha(ProfessionsFrame.NineSlice.TopEdge)
    set_Alpha(ProfessionsFrame.NineSlice.TopRightCorner)
    set_Alpha(ProfessionsFrameBg)
    set_Alpha(ProfessionsFrame.CraftingPage.SchematicForm.Background)
    set_Alpha(ProfessionsFrame.CraftingPage.RankBar.Background)

    set_Alpha(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundTop)
    set_Alpha(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundMiddle)
    set_Alpha(ProfessionsFrame.CraftingPage.SchematicForm.Details.BackgroundBottom)

    hide_Texture(ProfessionsFrame.SpecPage.TreeView.Background)
    hide_Texture(ProfessionsFrame.SpecPage.DetailedView.Background)
    set_Alpha(ProfessionsFrame.SpecPage.DetailedView.Path.DialBG)
    set_Alpha(ProfessionsFrame.SpecPage.DetailedView.UnspentPoints.CurrencyBackground)

    set_Alpha(InspectRecipeFrameBg)
    set_Alpha(InspectRecipeFrame.SchematicForm.MinimalBackground)


    set_Alpha(GossipFrame.NineSlice.TopEdge)
    set_Alpha(GossipFrame.NineSlice.TopLeftCorner)
    set_Alpha(GossipFrame.NineSlice.TopRightCorner)
    set_Alpha(GossipFrameBg)
    hide_Texture(GossipFrameInset.Bg)
    hide_Texture(GossipFrame.GreetingPanel.ScrollBar.Backplate)

    set_Alpha_Frame_Texture(PVEFrameTab1)
    set_Alpha_Frame_Texture(PVEFrameTab2)
    set_Alpha_Frame_Texture(PVEFrameTab3)

    if PetStableFrame then--猎人，宠物
        set_Alpha(PetStableFrame.NineSlice.TopEdge)
        set_Alpha(PetStableFrame.NineSlice.TopLeftCorner)
        set_Alpha(PetStableFrame.NineSlice.TopRightCorner)
        hide_Texture(PetStableFrameModelBg)
        hide_Texture(PetStableFrameInset.Bg)
        set_Alpha(PetStableFrameBg)
        hide_Texture(PetStableFrameStableBg)
        hide_Texture(PetStableActiveBg)
        for i=1, 10 do
            if i<=5 then
                hide_Texture(_G['PetStableActivePet'..i..'Background'])
                set_Alpha(_G['PetStableActivePet'..i..'Border'])
            end
            set_Alpha(_G['PetStableStabledPet'..i..'Background'])
        end
    end

    --商人
    set_Alpha(MerchantFrame.NineSlice.TopEdge)
    set_Alpha(MerchantFrame.NineSlice.TopLeftCorner)
    set_Alpha(MerchantFrame.NineSlice.TopRightCorner)
    set_Alpha(MerchantFrameBg)
    hide_Texture(MerchantFrameInset.Bg)
    set_Alpha(MerchantMoneyInset.Bg)
    hide_Texture(MerchantMoneyBgMiddle)
    hide_Texture(MerchantMoneyBgLeft)
    hide_Texture(MerchantMoneyBgRight)
    for i=1, 12 do
        set_Alpha(_G['MerchantItem'..i..'SlotTexture'])
    end
    set_Alpha(MerchantFrameLootFilterMiddle)
    set_Alpha(MerchantFrameLootFilterLeft)
    set_Alpha(MerchantFrameLootFilterRight)

    --银行
    set_Alpha(BankFrame.NineSlice.TopEdge)
    set_Alpha(BankFrame.NineSlice.TopLeftCorner)
    set_Alpha(BankFrame.NineSlice.TopRightCorner)

    hide_Texture(BankFrameMoneyFrameInset.Bg)
    set_Alpha(BankFrameMoneyFrameBorderMiddle)
    set_Alpha(BankFrameMoneyFrameBorderRight)
    set_Alpha(BankFrameMoneyFrameBorderLeft)

    BankFrame:DisableDrawLayer('BACKGROUND')
    local texture= BankFrame:CreateTexture(nil,'BORDER',nil, 1)
    texture:SetAtlas('auctionhouse-background-buy-noncommodities-market')
    texture:SetAllPoints(BankFrame)
    set_Alpha(texture)
    hide_Texture(BankFrameBg)

    hooksecurefunc('BankFrameItemButton_Update',function(button)--银行
        if button.NormalTexture and button.NormalTexture:IsShown() then
            hide_Texture(button.NormalTexture)
        end
        if ReagentBankFrame.numColumn and not ReagentBankFrame.hidexBG then
            ReagentBankFrame.hidexBG=true
            for column = 1, 7 do
                hide_Texture(ReagentBankFrame["BG"..column])
            end
        end
    end)

    --背包
    if ContainerFrameCombinedBags and ContainerFrameCombinedBags.NineSlice then
        set_Alpha(ContainerFrameCombinedBags.NineSlice.TopEdge)
        set_Alpha(ContainerFrameCombinedBags.NineSlice.LeftEdge)
        set_Alpha(ContainerFrameCombinedBags.NineSlice.RightEdge)

        set_Alpha(ContainerFrameCombinedBags.NineSlice.BottomEdge)

        set_Alpha(ContainerFrameCombinedBags.NineSlice.TopLeftCorner)
        set_Alpha(ContainerFrameCombinedBags.NineSlice.TopRightCorner)
        set_Alpha(ContainerFrameCombinedBags.NineSlice.BottomRightCorner)
        set_Alpha(ContainerFrameCombinedBags.NineSlice.BottomLeftCorner)
        set_Alpha(ContainerFrameCombinedBags.MoneyFrame.Border.Middle)
        set_Alpha(ContainerFrameCombinedBags.MoneyFrame.Border.Right)
        set_Alpha(ContainerFrameCombinedBags.MoneyFrame.Border.Left)

        set_Alpha(ContainerFrameCombinedBags.Bg.TopSection, true)
        --set_Alpha(ContainerFrameCombinedBags.Bg.BottomEdge)
        --set_Alpha(ContainerFrameCombinedBags.Bg.BottomRight)
        --set_Alpha(ContainerFrameCombinedBags.Bg.BottomLeft)
        set_Alpha(BagItemSearchBox.Middle)
        set_Alpha(BagItemSearchBox.Left)
        set_Alpha(BagItemSearchBox.Right)
    end
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame and frame.NineSlice then
            set_Alpha(frame.Bg.TopSection, true)
            set_Alpha(frame.NineSlice.TopEdge)
            set_Alpha(frame.NineSlice.TopLeftCorner)
            set_Alpha(frame.NineSlice.TopRightCorner)
        end
    end

    local function set_BagTexture_Button(button)
        if not button.hasItem then
            hide_Texture(button.icon)
            hide_Texture(button.ItemSlotBackground)
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
            set_Alpha(frame:GetNormalTexture())
            set_Alpha(frame.icon)
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
    set_Alpha(FriendsFrame.NineSlice.TopEdge)
    set_Alpha(FriendsFrame.NineSlice.TopLeftCorner)
    set_Alpha(FriendsFrame.NineSlice.TopRightCorner)
    set_Alpha(FriendsFrameBg)
    hide_Texture(FriendsFrameInset.Bg)
    hide_Texture(FriendsListFrame.ScrollBar.Backplate)
    hide_Texture(IgnoreListFrame.ScrollBar.Backplate)
    if RecruitAFriendFrame and RecruitAFriendFrame.RecruitList then
        hide_Texture(RecruitAFriendFrame.RecruitList.ScrollBar.Backplate)
        set_Alpha(RecruitAFriendFrame.RecruitList.ScrollFrameInset.Bg)
    end
    hide_Texture(WhoFrameListInset.Bg)
    hide_Texture(WhoFrame.ScrollBar.Backplate)
    set_Alpha(WhoFrameDropDownMiddle)
    set_Alpha(WhoFrameDropDownLeft)
    set_Alpha(WhoFrameDropDownRight)
    hide_Texture(WhoFrameEditBoxInset.Bg)
    hide_Texture(QuickJoinFrame.ScrollBar.Backplate)

    set_Alpha_Frame_Texture(FriendsFrameTab1)
    set_Alpha_Frame_Texture(FriendsFrameTab2)
    set_Alpha_Frame_Texture(FriendsFrameTab3)
    set_Alpha_Frame_Texture(FriendsFrameTab4)

    --聊天设置
    set_Alpha(ChannelFrame.NineSlice.TopEdge)
    set_Alpha(ChannelFrame.NineSlice.TopLeftCorner)
    set_Alpha(ChannelFrame.NineSlice.TopRightCorner)
    set_Alpha(ChannelFrameBg)
    hide_Texture(ChannelFrameInset.Bg)
    hide_Texture(ChannelFrame.RightInset.Bg)
    hide_Texture(ChannelFrame.LeftInset.Bg)
    hide_Texture(ChannelFrame.ChannelRoster.ScrollBar.Backplate)

    --任务
    set_Alpha(QuestFrame.NineSlice.TopEdge)
    set_Alpha(QuestFrame.NineSlice.TopLeftCorner)
    set_Alpha(QuestFrame.NineSlice.TopRightCorner)
    set_Alpha(QuestFrameBg)
    hide_Texture(QuestFrameInset.Bg)

    --信箱
    set_Alpha(MailFrame.NineSlice.TopEdge)
    set_Alpha(MailFrame.NineSlice.TopLeftCorner)
    set_Alpha(MailFrame.NineSlice.TopRightCorner)
    set_Alpha(MailFrameBg)
    hide_Texture(InboxFrameBg)
    hide_Texture(MailFrameInset.Bg)
    set_Alpha(OpenMailFrame.NineSlice)
    set_Alpha(OpenMailFrameBg)
    set_Alpha(OpenMailFrameInset.Bg)

    SendMailBodyEditBox:HookScript('OnEditFocusLost', function()
        set_Alpha(SendStationeryBackgroundLeft)
        set_Alpha(SendStationeryBackgroundRight)
    end)
    SendMailBodyEditBox:HookScript('OnEditFocusGained', function()
        if SendStationeryBackgroundLeft then
            SendStationeryBackgroundLeft:SetAlpha(1)
            SendStationeryBackgroundLeft:SetVertexColor(1,1,1)
            SendStationeryBackgroundRight:SetAlpha(1)
            SendStationeryBackgroundRight:SetVertexColor(1,1,1)
        end
    end)
    set_Alpha(SendStationeryBackgroundLeft)
    set_Alpha(SendStationeryBackgroundRight)

    set_Alpha(SendMailMoneyBgMiddle)
    set_Alpha(SendMailMoneyBgRight)
    set_Alpha(SendMailMoneyBgLeft)
    hide_Texture(SendMailMoneyInset.Bg)
    set_Alpha(MailFrame.NineSlice.LeftEdge)
    set_Alpha(MailFrame.NineSlice.RightEdge)
    set_Alpha(MailFrame.NineSlice.BottomRightCorner)
    set_Alpha(MailFrame.NineSlice.BottomLeftCorner)
    set_Alpha(MailFrame.NineSlice.BottomEdge)
    set_Alpha(MailFrameInset.NineSlice.LeftEdge)


    --拾取, 历史
    set_Alpha(GroupLootHistoryFrame.NineSlice.TopRightCorner)
    set_Alpha(GroupLootHistoryFrame.NineSlice.TopEdge)
    set_Alpha(GroupLootHistoryFrame.NineSlice.TopLeftCorner)
    set_Alpha(GroupLootHistoryFrame.NineSlice.RightEdge)
    set_Alpha(GroupLootHistoryFrame.NineSlice.LeftEdge)
    set_Alpha(GroupLootHistoryFrame.NineSlice.BottomLeftCorner)
    set_Alpha(GroupLootHistoryFrame.NineSlice.BottomRightCorner)
    set_Alpha(GroupLootHistoryFrame.NineSlice.BottomEdge)
    set_Alpha(GroupLootHistoryFrameBg)
    set_Alpha(GroupLootHistoryFrame.ScrollBar.Track.Middle)
    set_Alpha(GroupLootHistoryFrame.ScrollBar.Track.Begin)
    set_Alpha(GroupLootHistoryFrame.ScrollBar.Track.End)

    set_Alpha(GroupLootHistoryFrameMiddle)
    set_Alpha(GroupLootHistoryFrameLeft)
    set_Alpha(GroupLootHistoryFrameRight)
    set_Alpha()




    --频道, 设置
    hide_Texture(ChatConfigCategoryFrame.NineSlice.Center)
    hide_Texture(ChatConfigBackgroundFrame.NineSlice.Center)
    hide_Texture(ChatConfigChatSettingsLeft.NineSlice.Center)

    hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame)--ChatConfigFrame.lua
        if frame.NineSlice then
            hide_Texture(frame.NineSlice.TopEdge)
            hide_Texture(frame.NineSlice.BottomEdge)
            hide_Texture(frame.NineSlice.RightEdge)
            hide_Texture(frame.NineSlice.LeftEdge)
            hide_Texture(frame.NineSlice.TopLeftCorner)
            hide_Texture(frame.NineSlice.TopRightCorner)
            hide_Texture(frame.NineSlice.BottomLeftCorner)
            hide_Texture(frame.NineSlice.BottomRightCorner)
            hide_Texture(frame.NineSlice.Center)
        end
        local checkBoxNameString = frame:GetName().."CheckBox";
        for index, _ in ipairs(frame.checkBoxTable) do
            local checkBox = _G[checkBoxNameString..index];
            if checkBox and checkBox.NineSlice then
                hide_Texture(checkBox.NineSlice.TopEdge)
                hide_Texture(checkBox.NineSlice.RightEdge)
                hide_Texture(checkBox.NineSlice.LeftEdge)
                hide_Texture(checkBox.NineSlice.TopRightCorner)
                hide_Texture(checkBox.NineSlice.TopLeftCorner)
                hide_Texture(checkBox.NineSlice.BottomRightCorner)
                hide_Texture(checkBox.NineSlice.BottomLeftCorner)
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
    set_Alpha(AddonList.NineSlice.TopEdge)
    set_Alpha(AddonList.NineSlice.TopLeftCorner)
    set_Alpha(AddonList.NineSlice.TopRightCorner)
    set_Alpha(AddonListBg)
    set_Alpha(AddonListInset.Bg)
    hide_Texture(AddonList.ScrollBar.Backplate)
    set_Alpha(AddonCharacterDropDownMiddle)
    set_Alpha(AddonCharacterDropDownLeft)
    set_Alpha(AddonCharacterDropDownRight)

    --场景 Blizzard_ScenarioObjectiveTracker.lua
    --[[if ObjectiveTrackerBlocksFrame then
        set_Alpha(ObjectiveTrackerBlocksFrame.ScenarioHeader.Background)
        set_Alpha(ObjectiveTrackerBlocksFrame.AchievementHeader.Background)
        set_Alpha(ObjectiveTrackerBlocksFrame.QuestHeader.Background)
        hooksecurefunc('ScenarioStage_UpdateOptionWidgetRegistration', function(stageBlock, widgetSetID)
            set_Alpha(stageBlock.NormalBG, nil, true)
            set_Alpha(stageBlock.FinalBG)
        end)
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
            set_Alpha(frame:GetNormalTexture(), true)
        end
    end
    buttons=nil

    if MainStatusTrackingBarContainer then--货币，XP，追踪，最下面BAR
        hide_Texture(MainStatusTrackingBarContainer.BarFrameTexture)
    end

    hide_Frame_Texture(AddonCompartmentFrame)
    if e.Player.useColor then
        AddonCompartmentFrame.Text:SetTextColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
    end

    hide_Texture(PlayerFrameAlternateManaBarBorder)
    hide_Texture(PlayerFrameAlternateManaBarLeftBorder)
    hide_Texture(PlayerFrameAlternateManaBarRightBorder)

    --小地图
    set_Alpha(MinimapCompassTexture)
    set_Alpha_Frame_Texture(MinimapCluster.BorderTop)
    set_Alpha_Frame_Texture(MinimapCluster.Tracking.Button)
    set_Alpha_Frame_Texture(GameTimeFrame)

    C_Timer.After(2, function()
        if SpellFlyout and SpellFlyout.Background then--Spell Flyout
            hide_Texture(SpellFlyout.Background.HorizontalMiddle)
            hide_Texture(SpellFlyout.Background.End)
            hide_Texture(SpellFlyout.Background.VerticalMiddle)
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
        set_Alpha(ClassTrainerFrame.NineSlice.TopEdge)
        set_Alpha(ClassTrainerFrame.NineSlice.TopLeftCorner)
        set_Alpha(ClassTrainerFrame.NineSlice.TopRightCorner)
        hide_Texture(ClassTrainerFrameInset.Bg)
        hide_Texture(ClassTrainerFrameBg)

        hide_Texture(ClassTrainerFrameBottomInset.Bg)
        set_Alpha(ClassTrainerFrameFilterDropDownMiddle)
        set_Alpha(ClassTrainerFrameFilterDropDownLeft)
        set_Alpha(ClassTrainerFrameFilterDropDownRight)
        hide_Texture(ClassTrainerFrame.ScrollBar.Backplate)

    elseif arg1=='Blizzard_TimeManager' then--小时图，时间
        set_Alpha(TimeManagerFrame.NineSlice.TopLeftCorner)
        set_Alpha(TimeManagerFrame.NineSlice.TopEdge)
        set_Alpha(TimeManagerFrame.NineSlice.TopRightCorner)
        set_Alpha(TimeManagerFrameBg)
        hide_Texture(TimeManagerFrameInset.Bg)
        set_Alpha(TimeManagerAlarmMessageEditBox.Middle)
        set_Alpha(TimeManagerAlarmMessageEditBox.Left)
        set_Alpha(TimeManagerAlarmMessageEditBox.Right)
        if e.Player.useColor then
            TimeManagerClockTicker:SetTextColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)
        end


    elseif arg1=='Blizzard_ClassTalentUI' and not Save.disabledAlpha then--天赋
        set_Alpha(ClassTalentFrame.TalentsTab.BottomBar)--下面
        set_Alpha(ClassTalentFrame.NineSlice.TopLeftCorner)--顶部
        set_Alpha(ClassTalentFrame.NineSlice.TopEdge)--顶部
        set_Alpha(ClassTalentFrame.NineSlice.TopRightCorner)--顶部
        set_Alpha(ClassTalentFrameBg)--里面
        hide_Texture(ClassTalentFrame.TalentsTab.BlackBG)
        hooksecurefunc(ClassTalentFrame.TalentsTab, 'UpdateSpecBackground', function(self2)--Blizzard_ClassTalentTalentsTab.lua
            if self2.specBackgrounds then
                for _, background in ipairs(self2.specBackgrounds) do
                    hide_Texture(background)
                end
            end
        end)

        hide_Texture(ClassTalentFrame.SpecTab.Background)
        hide_Texture(ClassTalentFrame.SpecTab.BlackBG)
        hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecContents', function(self2)--Blizzard_ClassTalentSpecTab.lua
            local numSpecs= self2.numSpecs
            if numSpecs and numSpecs>0 then
                for i = 1, numSpecs do
                    local contentFrame = self2.SpecContentFramePool:Acquire();
                    if contentFrame then
                        hide_Texture(contentFrame.HoverBackground)
                    end
                end
            end
        end)

        set_Alpha(ClassTalentFrameMiddle)
        set_Alpha(ClassTalentFrameLeft)
        set_Alpha(ClassTalentFrameRight)
        set_Alpha(ClassTalentFrame.TalentsTab.SearchBox.Middle)
        set_Alpha(ClassTalentFrame.TalentsTab.SearchBox.Left)
        set_Alpha(ClassTalentFrame.TalentsTab.SearchBox.Right)

    elseif arg1=='Blizzard_AchievementUI' then--成就
        set_Alpha(AchievementFrame.Header.PointBorder)
        hide_Texture(AchievementFrameSummary.Background)
        hide_Texture(AchievementFrameCategoriesBG)
        hide_Texture(AchievementFrameAchievements.Background)

        hide_Texture(AchievementFrameWaterMark)
        hide_Texture(AchievementFrameGuildEmblemRight)

        hide_Texture(AchievementFrame.BottomRightCorner)
        hide_Texture(AchievementFrame.BottomLeftCorner)
        hide_Texture(AchievementFrame.TopLeftCorner)
        hide_Texture(AchievementFrame.TopRightCorner)

        hide_Texture(AchievementFrame.BottomEdge)
        hide_Texture(AchievementFrame.TopEdge)
        hide_Texture(AchievementFrame.LeftEdge)
        hide_Texture(AchievementFrame.RightEdge)
        hide_Texture(AchievementFrame.Header.Right)
        hide_Texture(AchievementFrame.Header.Left)

        hide_Texture(AchievementFrame.SearchBox.Middle)
        hide_Texture(AchievementFrame.SearchBox.Left)
        hide_Texture(AchievementFrame.SearchBox.Right)

        set_Alpha(AchievementFrame.Background)
        set_Alpha(AchievementFrameMetalBorderBottomLeft)
        set_Alpha(AchievementFrameMetalBorderBottom)
        set_Alpha(AchievementFrameMetalBorderBottomRight)
        set_Alpha(AchievementFrameMetalBorderRight)
        set_Alpha(AchievementFrameMetalBorderLeft)
        set_Alpha(AchievementFrameMetalBorderTopLeft)
        set_Alpha(AchievementFrameMetalBorderTop)
        set_Alpha(AchievementFrameMetalBorderTopRight)

        set_Alpha(AchievementFrameWoodBorderBottomLeft)
        set_Alpha(AchievementFrameWoodBorderBottomRight)
        set_Alpha(AchievementFrameWoodBorderTopLeft)
        set_Alpha(AchievementFrameWoodBorderTopRight)

        hide_Texture(AchievementFrameSummaryCategoriesStatusBarFillBar)
        for i=1, 10 do
            hide_Texture(_G['AchievementFrameCategoriesCategory'..i..'Bar'])
        end
        if AchievementFrameStatsBG then
            AchievementFrameStatsBG:Hide()
        end
        set_Alpha(AchievementFrame.Header.LeftDDLInset)
        set_Alpha(AchievementFrame.Header.RightDDLInset)
        hooksecurefunc(AchievementTemplateMixin, 'Init', function(self)
            if self.Icon then
                hide_Texture(self.Icon.frame)
            end
        end)
        hide_Texture(AchievementFrameAchievements.ScrollBar.Backplate)
        hide_Texture(AchievementFrameStats.ScrollBar.Backplate)
        hide_Texture(AchievementFrameCategories.ScrollBar.Backplate)
        set_Alpha_Frame_Texture(AchievementFrameTab1)
        set_Alpha_Frame_Texture(AchievementFrameTab2)
        set_Alpha_Frame_Texture(AchievementFrameTab3)

    elseif arg1=='Blizzard_Communities' then--公会和社区
        set_Alpha(CommunitiesFrame.NineSlice.TopEdge)
        set_Alpha(CommunitiesFrame.NineSlice.TopLeftCorner)
        set_Alpha(CommunitiesFrame.NineSlice.TopRightCorner)

        set_Alpha(CommunitiesFrame.NineSlice.BottomEdge)
        set_Alpha(CommunitiesFrame.NineSlice.BottomLeftCorner)
        set_Alpha(CommunitiesFrame.NineSlice.BottomRightCorner)

        set_Alpha(CommunitiesFrameBg)
        set_Alpha(CommunitiesFrame.MemberList.ColumnDisplay.Background)
        set_Alpha(CommunitiesFrameCommunitiesList.Bg)
        set_Alpha(CommunitiesFrameInset.Bg)
        CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
        CommunitiesFrameGuildDetailsFrameInfo:DisableDrawLayer('BACKGROUND')
        CommunitiesFrameGuildDetailsFrameNews:DisableDrawLayer('BACKGROUND')

        hide_Texture(CommunitiesFrameCommunitiesList.ScrollBar.Backplate)
        hide_Texture(CommunitiesFrameCommunitiesList.ScrollBar.Background)
        hide_Texture(CommunitiesFrame.MemberList.ScrollBar.Backplate)
        hide_Texture(CommunitiesFrame.MemberList.ScrollBar.Background)

        set_Alpha(CommunitiesFrame.ChatEditBox.Mid)
        set_Alpha(CommunitiesFrame.ChatEditBox.Left)
        set_Alpha(CommunitiesFrame.ChatEditBox.Right)
        set_Alpha(CommunitiesFrameMiddle)

        hide_Texture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)

        hooksecurefunc(CommunitiesFrameCommunitiesList,'UpdateCommunitiesList',function(self)
            C_Timer.After(0.3, function()
                for _, button in pairs(CommunitiesFrameCommunitiesList.ScrollBox:GetFrames()) do
                set_Alpha(button.Background)
                end
            end)
        end)

        set_Alpha(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.Bg)
        hide_Texture(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBar.Backplate)
        hide_Texture(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar.Backplate)
        hide_Texture(CommunitiesFrameGuildDetailsFrameNews.ScrollBar.Backplate)
        hide_Texture(CommunitiesFrameGuildDetailsFrameNews.ScrollBar.Background)

        hide_Frame_Texture(CommunitiesFrame.ChatTab, {index=1})
        hide_Frame_Texture(CommunitiesFrame.RosterTab, {index=1})
        hide_Frame_Texture(CommunitiesFrame.GuildBenefitsTab, {index=1})
        hide_Frame_Texture(CommunitiesFrame.GuildInfoTab, {index=1})
        hide_Frame_Texture(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, {index=1})
        hide_Frame_Texture(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, {index=1})

        set_Alpha(ClubFinderGuildFinderFrame.InsetFrame.Bg)


    elseif arg1=='Blizzard_PVPUI' then--地下城和团队副本, PVP
        hide_Texture(HonorFrame.Inset.Bg)
        set_Alpha(HonorFrame.BonusFrame.WorldBattlesTexture)
        hide_Texture(HonorFrame.ConquestBar.Background)
        set_Alpha(ConquestFrame.Inset.Bg)
        set_Alpha(ConquestFrame.RatedBGTexture)
        PVPQueueFrame.HonorInset:DisableDrawLayer('BACKGROUND')
        set_Alpha(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.Background)
        set_Alpha(HonorFrameTypeDropDownMiddle)
        set_Alpha(HonorFrameTypeDropDownLeft)
        set_Alpha(HonorFrameTypeDropDownRight)
        hide_Texture(ConquestFrame.RatedBGTexture)
        hide_Texture(LFDQueueFrameSpecific.ScrollBar.Backplate)

    elseif arg1=='Blizzard_EncounterJournal' then--冒险指南
        set_Alpha(EncounterJournal.NineSlice.TopLeftEdge)
        set_Alpha(EncounterJournal.NineSlice.TopEdge)
        set_Alpha(EncounterJournal.NineSlice.TopRightEdge)
        set_Alpha(EncounterJournal.NineSlice.TopRightCorner)
        set_Alpha(EncounterJournal.NineSlice.TopLeftCorner)

        hide_Texture(EncounterJournalBg)
        hide_Texture(EncounterJournalInset.Bg)


        set_Alpha(EncounterJournalInstanceSelectBG)
        --set_Alpha(EncounterJournalEncounterFrameInfoBG)
        set_Alpha(EncounterJournalEncounterFrameInfoModelFrameDungeonBG)
        EncounterJournalNavBar:DisableDrawLayer('BACKGROUND')

        set_Alpha(EncounterJournalInstanceSelectTierDropDownMiddle)
        set_Alpha(EncounterJournalInstanceSelectTierDropDownLeft)
        set_Alpha(EncounterJournalInstanceSelectTierDropDownRight)

        C_Timer.After(0.3, function()
            if EncounterJournalMonthlyActivitiesFrame then
                set_Alpha(EncounterJournalMonthlyActivitiesFrame.Bg)
            end
        end)

        set_Alpha_Frame_Texture(EncounterJournalSuggestTab)
        set_Alpha_Frame_Texture(EncounterJournalMonthlyActivitiesTab)
        set_Alpha_Frame_Texture(EncounterJournalDungeonTab)
        set_Alpha_Frame_Texture(EncounterJournalRaidTab)

    elseif arg1=="Blizzard_GuildBankUI" then--公会银行
        set_Alpha(GuildBankFrame.BlackBG)
        hide_Texture(GuildBankFrame.TitleBg)
        hide_Texture(GuildBankFrame.RedMarbleBG)
        set_Alpha(GuildBankFrame.MoneyFrameBG)

        set_Alpha(GuildBankFrame.TabLimitBG)
        set_Alpha(GuildBankFrame.TabLimitBGLeft)
        set_Alpha(GuildBankFrame.TabLimitBGRight)
        set_Alpha(GuildItemSearchBox.Middle)
        set_Alpha(GuildItemSearchBox.Left)
        set_Alpha(GuildItemSearchBox.Right)
        set_Alpha(GuildBankFrame.TabTitleBG)
        set_Alpha(GuildBankFrame.TabTitleBGLeft)
        set_Alpha(GuildBankFrame.TabTitleBGRight)

        for i=1, 7 do
            local frame= GuildBankFrame['Column'..i]
            if frame then
                hide_Texture(frame.Background)
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
        set_Alpha(AuctionHouseFrame.NineSlice.TopLeftCorner)
        set_Alpha(AuctionHouseFrame.NineSlice.TopEdge)
        set_Alpha(AuctionHouseFrame.NineSlice.TopRightCorner)
        set_Alpha(AuctionHouseFrameBg)
        set_Alpha(AuctionHouseFrame.CategoriesList.Background)

        set_Alpha(AuctionHouseFrame.SearchBar.SearchBox.Middle)
        set_Alpha(AuctionHouseFrame.SearchBar.SearchBox.Left)
        set_Alpha(AuctionHouseFrame.SearchBar.SearchBox.Right)
        set_Alpha(AuctionHouseFrameMiddleMiddle)
        set_Alpha(AuctionHouseFrameMiddleLeft)
        set_Alpha(AuctionHouseFrameMiddleRight)
        set_Alpha(AuctionHouseFrameBottomMiddle)
        set_Alpha(AuctionHouseFrameBottomLeft)
        set_Alpha(AuctionHouseFrameBottomRight)

        hide_Texture(AuctionHouseFrame.CategoriesList.ScrollBar.Backplate)
        hide_Texture(AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBar.Backplate)
        set_Alpha(AuctionHouseFrameMiddle)
        set_Alpha(AuctionHouseFrameLeft)
        set_Alpha(AuctionHouseFrameRight)
        hide_Texture(AuctionHouseFrame.MoneyFrameInset.Bg)

        set_Alpha(AuctionHouseFrame.ItemSellFrame.Background)--出售
        set_Alpha(AuctionHouseFrame.ItemSellList.Background)
        hide_Texture(AuctionHouseFrame.ItemSellList.ScrollBar.Backplate)

        hide_Texture(AuctionHouseFrameAuctionsFrame.SummaryList.ScrollBar.Backplate)
        hide_Texture(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBar.Backplate)

        set_Alpha(AuctionHouseFrameAuctionsFrame.SummaryList.Background)
        set_Alpha(AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background)

    elseif arg1=='Blizzard_ProfessionsCustomerOrders' then--专业定制
        set_Alpha(ProfessionsCustomerOrdersFrame.NineSlice.TopLeftCorner)
        set_Alpha(ProfessionsCustomerOrdersFrame.NineSlice.TopEdge)
        set_Alpha(ProfessionsCustomerOrdersFrame.NineSlice.TopRightCorner)
        set_Alpha(ProfessionsCustomerOrdersFrameBg)
        set_Alpha(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox.Middle)
        set_Alpha(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox.Left)
        set_Alpha(ProfessionsCustomerOrdersFrame.BrowseOrders.SearchBar.SearchBox.Right)

        set_Alpha(ProfessionsCustomerOrdersFrameMiddleMiddle)
        set_Alpha(ProfessionsCustomerOrdersFrameMiddleLeft)
        set_Alpha(ProfessionsCustomerOrdersFrameMiddleRight)
        set_Alpha(ProfessionsCustomerOrdersFrame.BrowseOrders.CategoryList.Background)

        set_Alpha(ProfessionsCustomerOrdersFrame.Form.LeftPanelBackground.Background)
        set_Alpha(ProfessionsCustomerOrdersFrame.Form.RightPanelBackground.Background)

        hide_Texture(ProfessionsCustomerOrdersFrame.MoneyFrameInset.Bg)
        set_Alpha(ProfessionsCustomerOrdersFrameLeft)
        set_Alpha(ProfessionsCustomerOrdersFrameMiddle)
        set_Alpha(ProfessionsCustomerOrdersFrameRight)

    elseif arg1=='Blizzard_BlackMarketUI' then--黑市
        set_Alpha(BlackMarketFrameTitleBg)
        set_Alpha(BlackMarketFrameBg)
        set_Alpha(BlackMarketFrame.LeftBorder)
        set_Alpha(BlackMarketFrame.RightBorder)
        set_Alpha(BlackMarketFrame.BottomBorder)
        set_Alpha(BlackMarketFrame.ScrollBar.Backplate)

    elseif arg1=='Blizzard_Collections' then--收藏
        set_Alpha(CollectionsJournal.NineSlice.TopEdge)
        set_Alpha(CollectionsJournal.NineSlice.TopLeftCorner)
        set_Alpha(CollectionsJournal.NineSlice.TopRightCorner)
        set_Alpha(CollectionsJournalBg)

        hide_Texture(MountJournal.LeftInset.Bg)
        set_Alpha(MountJournal.MountDisplay.YesMountsTex)
        hide_Texture(MountJournal.RightInset.Bg)
        set_Alpha(MountJournal.BottomLeftInset.Background)
        hide_Texture(MountJournal.BottomLeftInset.Bg)

        hide_Texture(MountJournal.ScrollBar.Backplate)
        set_Alpha(MountJournalSearchBox.Middle)
        set_Alpha(MountJournalSearchBox.Right)
        set_Alpha(MountJournalSearchBox.Left)

        hide_Texture(PetJournalPetCardBG)
        set_Alpha(PetJournalPetCardInset.Bg)
        set_Alpha(PetJournalRightInset.Bg)
        hide_Texture(PetJournalLoadoutPet1BG)
        hide_Texture(PetJournalLoadoutPet2BG)
        hide_Texture(PetJournalLoadoutPet3BG)
        set_Alpha(PetJournalLoadoutBorderSlotHeaderBG)
        hide_Texture(PetJournalLeftInset.Bg)

        hide_Texture(PetJournal.ScrollBar.Backplate)
        set_Alpha(PetJournalSearchBox.Middle)
        set_Alpha(PetJournalSearchBox.Right)
        set_Alpha(PetJournalSearchBox.Left)
        set_Alpha(PetJournal.PetCount.BorderTopMiddle)
        set_Alpha(PetJournal.PetCount.Bg)
        set_Alpha(PetJournal.PetCount.BorderBottomMiddle)
        set_Alpha(PetJournal.PetCount.BorderTopRightMiddle)
        set_Alpha(PetJournal.PetCount.BorderTopLeftMiddle)
        set_Alpha(PetJournal.PetCount.BorderBottomLeft)
        set_Alpha(PetJournal.PetCount.BorderTopLeft)
        set_Alpha(PetJournal.PetCount.BorderBottomRight)
        set_Alpha(PetJournal.PetCount.BorderTopRight)

        hide_Texture(ToyBox.iconsFrame.BackgroundTile)
        hide_Texture(ToyBox.iconsFrame.Bg)
        set_Alpha(ToyBox.searchBox.Middle)
        set_Alpha(ToyBox.searchBox.Right)
        set_Alpha(ToyBox.searchBox.Left)
        ToyBox.progressBar:DisableDrawLayer('BACKGROUND')

        hide_Texture(HeirloomsJournal.iconsFrame.BackgroundTile)
        hide_Texture(HeirloomsJournal.iconsFrame.Bg)
        set_Alpha(HeirloomsJournalSearchBox.Middle)
        set_Alpha(HeirloomsJournalSearchBox.Right)
        set_Alpha(HeirloomsJournalSearchBox.Left)
        set_Alpha(HeirloomsJournalClassDropDownMiddle)
        set_Alpha(HeirloomsJournalClassDropDownLeft)
        set_Alpha(HeirloomsJournalClassDropDownRight)
        set_Alpha(HeirloomsJournalMiddleMiddle)
        set_Alpha(HeirloomsJournalMiddleLeft)
        set_Alpha(HeirloomsJournalMiddleRight)
        set_Alpha(HeirloomsJournalBottomMiddle)
        set_Alpha(HeirloomsJournalTopMiddle)
        set_Alpha(HeirloomsJournalBottomLeft)
        set_Alpha(HeirloomsJournalBottomRight)
        set_Alpha(HeirloomsJournalTopLeft)
        set_Alpha(HeirloomsJournalTopRight)

        hide_Texture(WardrobeCollectionFrame.ItemsCollectionFrame.BackgroundTile)
        hide_Texture(WardrobeCollectionFrame.ItemsCollectionFrame.Bg)
        hide_Texture(WardrobeCollectionFrame.ItemsCollectionFrame.ShadowLineTop)

        hide_Texture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.BackgroundTile)
        hide_Texture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.Bg)
        hide_Texture(WardrobeCollectionFrame.SetsCollectionFrame.LeftInset.Bg)
        hide_Texture(WardrobeCollectionFrame.SetsCollectionFrame.ListContainer.ScrollBar.Backplate)
        hide_Texture(WardrobeCollectionFrame.SetsCollectionFrame.RightInset.ShadowLineTop)

        set_Alpha(WardrobeCollectionFrameSearchBox.Middle)
        set_Alpha(WardrobeCollectionFrameSearchBox.Left)
        set_Alpha(WardrobeCollectionFrameSearchBox.Right)
        set_Alpha(WardrobeCollectionFrameMiddleMiddle)
        set_Alpha(WardrobeCollectionFrameTopMiddle)
        set_Alpha(WardrobeCollectionFrameBottomMiddle)
        set_Alpha(WardrobeCollectionFrameTopMiddle)
        set_Alpha(WardrobeCollectionFrameMiddleLeft)
        set_Alpha(WardrobeCollectionFrameMiddleRight)
        set_Alpha(WardrobeCollectionFrameTopLeft)
        set_Alpha(WardrobeCollectionFrameBottomLeft)
        set_Alpha(WardrobeCollectionFrameBottomRight)
        set_Alpha(WardrobeCollectionFrameTopLeft)
                 --WardrobeCollectionFrameBottomRight

        set_Alpha(WardrobeSetsCollectionVariantSetsButtonMiddleMiddle)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonBottomMiddle)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonTopMiddle)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonMiddleLeft)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonMiddleRight)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonTopLeft)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonBottomLeft)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonTopRight)
        set_Alpha(WardrobeSetsCollectionVariantSetsButtonBottomRight)
        hide_Texture(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.ModelFadeTexture)
        --[[hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', function(button, displayData)--外观列表
            set_Alpha(button.Background)
        end)]]

        --试衣间
        set_Alpha(WardrobeFrame.NineSlice.TopLeftCorner)
        set_Alpha(WardrobeFrame.NineSlice.TopEdge)
        set_Alpha(WardrobeFrame.NineSlice.TopRightCorner)
        hide_Texture(WardrobeFrameBg)
        hide_Texture(WardrobeTransmogFrame.Inset.Bg)
        set_Alpha(WardrobeTransmogFrame.Inset.BG)
        hide_Texture(WardrobeCollectionFrame.SetsTransmogFrame.BackgroundTile)
        set_Alpha(WardrobeCollectionFrame.SetsTransmogFrame.Bg)
        set_Alpha(WardrobeOutfitDropDownMiddle)
        set_Alpha(WardrobeOutfitDropDownLeft)
        set_Alpha(WardrobeOutfitDropDownRight)
        set_Alpha(WardrobeTransmogFrame.MoneyMiddle)
        set_Alpha(WardrobeTransmogFrame.MoneyLeft)
        set_Alpha(WardrobeTransmogFrame.MoneyRight)
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
        set_Alpha(WardrobeCollectionFrameWeaponDropDownMiddle)
        set_Alpha(WardrobeCollectionFrameWeaponDropDownLeft)
        set_Alpha(WardrobeCollectionFrameWeaponDropDownRight)

        set_Alpha_Frame_Texture(CollectionsJournalTab1)
        set_Alpha_Frame_Texture(CollectionsJournalTab2)
        set_Alpha_Frame_Texture(CollectionsJournalTab3)
        set_Alpha_Frame_Texture(CollectionsJournalTab4)
        set_Alpha_Frame_Texture(CollectionsJournalTab5)

        if RematchJournal then
            set_Alpha(RematchJournal.NineSlice.TopEdge)
            set_Alpha(RematchJournal.NineSlice.TopRightCorner)
            set_Alpha(RematchJournal.NineSlice.TopLeftCorner)
            set_Alpha(RematchJournalBg)
            set_Alpha(RematchLoadoutPanel.Target.InsetBack)
            hide_Texture(RematchPetPanel.Top.InsetBack)
            set_Alpha(RematchQueuePanel.List.Background.InsetBack)
            set_Alpha(RematchQueuePanel.Top.InsetBack)
            hide_Texture(RematchPetPanel.Top.TypeBar.NineSlice)
            set_Alpha(RematchTeamPanel.List.Background.InsetBack)
            set_Alpha(RematchOptionPanel.List.Background.InsetBack)
            set_Alpha(RematchLoadoutPanel.TopLoadout.InsetBack)
        end
    elseif arg1=='Blizzard_Calendar' then--日历
        set_Alpha(CalendarFrameTopMiddleTexture)
        set_Alpha(CalendarFrameTopLeftTexture)
        set_Alpha(CalendarFrameTopRightTexture)

        set_Alpha(CalendarFrameLeftTopTexture)
        set_Alpha(CalendarFrameLeftMiddleTexture)
        set_Alpha(CalendarFrameLeftBottomTexture)
        set_Alpha(CalendarFrameRightTopTexture)
        set_Alpha(CalendarFrameRightMiddleTexture)
        set_Alpha(CalendarFrameRightBottomTexture)

        set_Alpha(CalendarFrameBottomRightTexture)
        set_Alpha(CalendarFrameBottomMiddleTexture)
        set_Alpha(CalendarFrameBottomLeftTexture)
        for i= 1, 42 do
            local frame= _G['CalendarDayButton'..i]
            if frame then
                frame:DisableDrawLayer('BACKGROUND')
            end
        end
        set_Alpha(CalendarCreateEventFrame.Border.Bg)


    elseif arg1=='Blizzard_FlightMap' then--飞行地图
        set_Alpha(FlightMapFrame.BorderFrame.NineSlice.TopLeftCorner)
        set_Alpha(FlightMapFrame.BorderFrame.NineSlice.TopEdge)
        set_Alpha(FlightMapFrame.BorderFrame.NineSlice.TopRightCorner)

        hide_Texture(FlightMapFrame.ScrollContainer.Child.TiledBackground)
        hide_Texture(FlightMapFrameBg)
    elseif arg1=='Blizzard_ItemSocketingUI' then--镶嵌宝石，界面
        set_Alpha(ItemSocketingFrame.NineSlice.TopLeftCorner)
        set_Alpha(ItemSocketingFrame.NineSlice.TopEdge)
        set_Alpha(ItemSocketingFrame.NineSlice.TopRightCorner)
        set_Alpha(ItemSocketingFrameBg)
        hide_Texture(ItemSocketingFrameInset.Bg)
        hide_Texture(ItemSocketingFrame['SocketFrame-Right'])
        hide_Texture(ItemSocketingFrame['SocketFrame-Left'])
        hide_Texture(ItemSocketingFrame['ParchmentFrame-Top'])
        hide_Texture(ItemSocketingFrame['ParchmentFrame-Bottom'])
        hide_Texture(ItemSocketingFrame['ParchmentFrame-Right'])
        hide_Texture(ItemSocketingFrame['ParchmentFrame-Left'])
        set_Alpha(ItemSocketingFrame['GoldBorder-Top'])
        set_Alpha(ItemSocketingFrame['GoldBorder-Bottom'])
        set_Alpha(ItemSocketingFrame['GoldBorder-Right'])
        set_Alpha(ItemSocketingFrame['GoldBorder-Left'])
        set_Alpha(ItemSocketingFrame['GoldBorder-BottomLeft'])
        set_Alpha(ItemSocketingFrame['GoldBorder-TopLeft'])
        set_Alpha(ItemSocketingFrame['GoldBorder-BottomRight'])
        set_Alpha(ItemSocketingFrame['GoldBorder-TopRight'])
        set_Alpha(ItemSocketingScrollFrameMiddle)
        set_Alpha(ItemSocketingScrollFrameTop)
        set_Alpha(ItemSocketingScrollFrameBottom)

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, 钥匙插入， 界面
        set_Alpha(ChallengesFrameInset.Bg)

        hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(self2)--钥匙插入， 界面
            set_Alpha_Frame_Texture(self2, {index=1})
            hide_Texture(self2.InstructionBackground)
        end)

    elseif arg1=='Blizzard_WeeklyRewards' then--周奖励提示
        set_Alpha(WeeklyRewardsFrame.BackgroundTile)
        set_Alpha(WeeklyRewardsFrame.HeaderFrame.Middle)
        set_Alpha(WeeklyRewardsFrame.HeaderFrame.Left)
        set_Alpha(WeeklyRewardsFrame.HeaderFrame.Right)
        set_Alpha(WeeklyRewardsFrame.RaidFrame.Background)
        set_Alpha(WeeklyRewardsFrame.MythicFrame.Background)
        set_Alpha(WeeklyRewardsFrame.PVPFrame.Background)
        hooksecurefunc(WeeklyRewardsFrame,'UpdateSelection', function(self2)
            for _, frame in ipairs(self2.Activities) do
                set_Alpha(frame.Background)
            end
        end)

    elseif arg1=='Blizzard_ItemInteractionUI' then--套装, 转换        
        set_Alpha(ItemInteractionFrame.NineSlice.TopLeftCorner)
        set_Alpha(ItemInteractionFrame.NineSlice.TopEdge)
        set_Alpha(ItemInteractionFrame.NineSlice.TopRightCorner)
        set_Alpha(ItemInteractionFrameBg)
        set_Alpha(ItemInteractionFrame.Inset.Bg)
        set_Alpha(ItemInteractionFrameMiddle)

        set_Alpha(ItemInteractionFrameRight)
        set_Alpha(ItemInteractionFrameLeft)

        hide_Texture(ItemInteractionFrame.ButtonFrame.BlackBorder)

    elseif arg1=='Blizzard_InspectUI' then--玩家, 观察角色, 界面
        set_Alpha(InspectFrame.NineSlice.TopLeftCorner)
        set_Alpha(InspectFrame.NineSlice.TopEdge)
        set_Alpha(InspectFrame.NineSlice.TopRightCorner)
        set_Alpha(InspectFrameBg)
        hide_Texture(InspectFrameInset.Bg)
        hide_Texture(InspectPVPFrame.BG)
        hide_Texture(InspectGuildFrameBG)

    elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级,界面        
        set_Alpha(ItemUpgradeFrame.NineSlice.TopLeftCorner)
        set_Alpha(ItemUpgradeFrame.NineSlice.TopEdge)
        set_Alpha(ItemUpgradeFrame.NineSlice.TopRightCorner)
        set_Alpha(ItemUpgradeFrameBg)
        hide_Texture(ItemUpgradeFrame.TopBG)
        hide_Texture(ItemUpgradeFrame.BottomBG)
        set_Alpha(ItemUpgradeFramePlayerCurrenciesBorderMiddle)
        set_Alpha(ItemUpgradeFramePlayerCurrenciesBorderLeft)
        set_Alpha(ItemUpgradeFramePlayerCurrenciesBorderRight)

        set_Alpha(ItemUpgradeFrameMiddle)
        set_Alpha(ItemUpgradeFrameRight)
        set_Alpha(ItemUpgradeFrameLeft)

    elseif arg1=='Blizzard_MacroUI' then--宏
        set_Alpha(MacroFrame.NineSlice.TopLeftCorner)
        set_Alpha(MacroFrame.NineSlice.TopEdge)
        set_Alpha(MacroFrame.NineSlice.TopRightCorner)
        hide_Texture(MacroFrameBg)
        set_Alpha(MacroFrameInset.Bg)
        hide_Texture(MacroFrame.MacroSelector.ScrollBar.Backplate)
        hide_Texture(MacroFrameSelectedMacroBackground)
    elseif arg1=='Blizzard_GarrisonUI' then--要塞
        --[[
        Move(GarrisonShipyardFrame,{})--海军行动
        Move(GarrisonMissionFrame, {})--要塞任务
        
        Move(GarrisonLandingPage, {})--要塞报告
        Move(OrderHallMissionFrame, {})
        ]]
        if GarrisonCapacitiveDisplayFrame then--要塞订单
            set_Alpha(GarrisonCapacitiveDisplayFrame.NineSlice.TopLeftCorner)
            set_Alpha(GarrisonCapacitiveDisplayFrame.NineSlice.TopEdge)
            set_Alpha(GarrisonCapacitiveDisplayFrame.NineSlice.TopRightCorner)
            set_Alpha(GarrisonCapacitiveDisplayFrameBg)
            hide_Texture(GarrisonCapacitiveDisplayFrame.TopTileStreaks)
            hide_Texture(GarrisonCapacitiveDisplayFrameInset.Bg)
        end

    elseif arg1=='Blizzard_GenericTraitUI' then--欲龙术
        set_Alpha(GenericTraitFrame.Background)
        set_Alpha(GenericTraitFrame.NineSlice.RightEdge)
        set_Alpha(GenericTraitFrame.NineSlice.LeftEdge)
        set_Alpha(GenericTraitFrame.NineSlice.TopEdge)
        set_Alpha(GenericTraitFrame.NineSlice.BottomEdge)
        set_Alpha(GenericTraitFrame.NineSlice.TopRightCorner)
        set_Alpha(GenericTraitFrame.NineSlice.TopLeftCorner)
        set_Alpha(GenericTraitFrame.NineSlice.BottomLeftCorner)
        set_Alpha(GenericTraitFrame.NineSlice.BottomRightCorner)

    elseif arg1=='Blizzard_PlayerChoice' then----任务选择
        C_Timer.After(0.3, function()
            if PlayerChoiceFrame.NineSlice then
                hide_Texture(PlayerChoiceFrame.NineSlice.TopLeftCorner)
                hide_Texture(PlayerChoiceFrame.NineSlice.TopEdge)
                hide_Texture(PlayerChoiceFrame.NineSlice.TopRightCorner)
                hide_Texture(PlayerChoiceFrame.NineSlice.BottomLeftCorner)
                hide_Texture(PlayerChoiceFrame.NineSlice.BottomEdge)
                hide_Texture(PlayerChoiceFrame.NineSlice.BottomRightCorner)
                hide_Texture(PlayerChoiceFrame.NineSlice.RightEdge)
                hide_Texture(PlayerChoiceFrame.NineSlice.LeftEdge)
            end
            if PlayerChoiceFrame.Title then
                set_Alpha(PlayerChoiceFrame.Title.Middle)
                set_Alpha(PlayerChoiceFrame.Title.Left)
                set_Alpha(PlayerChoiceFrame.Title.Right)
            end
            if PlayerChoiceFrame.Background then
                hide_Texture(PlayerChoiceFrame.Background.BackgroundTile)
            end
        end)
    elseif arg1=='Blizzard_MajorFactions' then--派系声望
        set_Alpha(MajorFactionRenownFrame.Background)

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

--###########
--添加控制面板
--###########
local function options_Init()--初始，选项
    panel.check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.check.text:SetText('1)'..(e.onlyChinese and '隐藏材质' or HIDE..addName))
    panel.check:SetChecked(not Save.disabledTexture)
    panel.check:SetPoint('TOPLEFT', 0, -48)
    panel.check:SetScript('OnMouseDown', function()
        Save.disabledTexture= not Save.disabledTexture and true or nil
    end)

    local alphaCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    alphaCheck.text:SetText('2)'..(e.onlyChinese and '透明度' or CHANGE_OPACITY))
    alphaCheck:SetPoint('TOPLEFT', panel.check, 'BOTTOMLEFT', 0, -16)
    alphaCheck:SetChecked(not Save.disabledAlpha)
    alphaCheck:SetScript('OnMouseDown', function()
        Save.disabledAlpha= not Save.disabledAlpha and true or false
    end)

    local alphaValue= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    alphaValue:SetPoint("LEFT", alphaCheck.text, 'RIGHT', 6,0)
    alphaValue:SetSize(120,20)
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

    --职业，显示数字
    local classNumCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    classNumCheck.text:SetText((e.onlyChinese and '职业能量数字' or (CLASS..'('..AUCTION_HOUSE_QUANTITY_LABEL..')'..ENERGY))..format(e.Icon.number2,1)..format(e.Icon.number2,2)..format(e.Icon.number2,3))
    classNumCheck:SetPoint('LEFT', alphaValue, 'RIGHT', 6, 0)
    classNumCheck:SetChecked(Save.classPowerNum)
    classNumCheck:SetScript('OnMouseDown', function()
        Save.classPowerNum= not Save.classPowerNum and true or nil
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
    chatBubbleAlpha:SetPoint('TOPLEFT', chatBubbleCheck, 'BOTTOMRIGHT',0,-10)
    chatBubbleAlpha:SetChecked(not Save.disabledChatBubbleAlpha)
    chatBubbleAlpha:SetScript('OnMouseDown', function()
        Save.disabledChatBubbleAlpha= not Save.disabledChatBubbleAlpha and true or false
    end)

    local chaAlphaValue= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    chaAlphaValue:SetPoint("LEFT", chatBubbleAlpha.text, 'RIGHT', 6,0)
    chaAlphaValue:SetSize(120,20)
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
    chaScaleValue:SetSize(120,20)
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

            panel.name = '|A:AnimCreate_Icon_Texture:0:0|a'..(e.onlyChinese and '材质' or addName)
            panel.parent =id
            InterfaceOptions_AddCategory(panel)

            e.ReloadPanel({panel=panel, addName= addName, restTips=true, checked= not Save.disabled, clearTips=nil,--重新加载UI, 重置, 按钮
                disabledfunc= function()
                                Save.disabled= not Save.disabled and true or nil
                                if not Save.disabled and not panel.check then
                                    options_Init()--初始，选项
                                end
                                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                            end,
                clearfunc= function() Save=nil e.Reload() end}
            )

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init_HideTexture()
                Init_Set_AlphaAndColor()
                if not Save.disabledChatBubble then
                    Init_chatBubbles()
                end
                options_Init()--初始，选项
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
                if not buble.set_Alpha then
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
                        buble.set_Alpha= true
                    end
                end
            end
        end)
    end
end)