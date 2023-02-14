local id, e= ...
local addName=HIDE..TEXTURES_SUBHEADER
local Save={
    disabledAlpha= not e.Player.husandro,
}

local function hideTexture(self)
    if self then
        self:SetTexture(0)
        self:SetShown(false)
    end
end
local function setAlpha(self)
    if self and not Save.disabledAlpha then
        self:SetAlpha(0.5)
    end
end

local function set_Alpha_Event(arg1)
    if Save.disabledAlpha then
        return
    end

  if arg1=='Blizzard_ClassTalentUI' and not Save.disabledAlpha then--天赋
        local frame=ClassTalentFrame
        setAlpha(frame.TalentsTab.BottomBar)--下面
        setAlpha(frame.NineSlice.TopLeftCorner)--顶部
        setAlpha(frame.NineSlice.TopEdge)--顶部
        setAlpha(frame.NineSlice.TopRightCorner)--顶部
        setAlpha(ClassTalentFrameBg)--里面
        hideTexture(frame.TalentsTab.BlackBG)
        hooksecurefunc(frame.TalentsTab, 'UpdateSpecBackground', function(self2)--Blizzard_ClassTalentTalentsTab.lua
            if self2.specBackgrounds then
                for _, background in ipairs(self2.specBackgrounds) do
                    hideTexture(background)
                end
            end
        end)

        hideTexture(frame.SpecTab.Background)
        hideTexture(frame.SpecTab.BlackBG)
        hooksecurefunc(frame.SpecTab, 'UpdateSpecContents', function(self2)--Blizzard_ClassTalentSpecTab.lua
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

    elseif arg1=='Blizzard_AchievementUI' then
        hideTexture(AchievementFrameSummary.Background)
        hideTexture(AchievementFrameCategoriesBG)
        hideTexture(AchievementFrameAchievements.Background)

        setAlpha(AchievementFrame.BottomRightCorner)
        setAlpha(AchievementFrame.BottomLeftCorner)
        setAlpha(AchievementFrame.TopLeftCorner)
        setAlpha(AchievementFrame.TopRightCorner)

        setAlpha(AchievementFrame.BottomEdge)
        setAlpha(AchievementFrame.TopEdge)
        setAlpha(AchievementFrame.LeftEdge)
        setAlpha(AchievementFrame.RightEdge)

        setAlpha(AchievementFrame.Header.Right)
        setAlpha(AchievementFrame.Header.Left)

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

    elseif arg1=='Blizzard_Communities' then--公会和社区

    end
end

local function set_UNIT_ENTERED_VEHICLE()--载具
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
end

--######
--初始化
--######
local function Init_HideTexture()
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

    hideTexture(PaladinPowerBarFrameBG)
    hideTexture(PaladinPowerBarFrameBankBG)

    LootFrameBg:SetShown(false)--拾取

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
     end

    --######
    --动作条
    --######
    local KEY_BUTTON_Tab={
        --[[[KEY_BUTTON1]= 'ML',--鼠标左键";
        [KEY_BUTTON3]= 'MR',--鼠标中键";
        [KEY_BUTTON2]= 'MM',--鼠标右键";
        KEY_BUTTON10]= 'M10',--鼠标按键10";
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


local function Init_SetAlpha()
    setAlpha(CharacterFrameBg)
    setAlpha(CharacterFrameInset.Bg)
    setAlpha(CharacterFrame.NineSlice.TopEdge)
    setAlpha(CharacterFrame.NineSlice.TopRightCorner)
    setAlpha(CharacterFrame.NineSlice.TopLeftCorner)
    setAlpha(CharacterFrameInsetRight.Bg)
    setAlpha(CharacterStatsPane.ClassBackground)
    setAlpha(CharacterStatsPane.EnhancementsCategory.Background)
    setAlpha(CharacterStatsPane.AttributesCategory.Background)
    setAlpha(CharacterStatsPane.ItemLevelCategory.Background)

    hideTexture(SpellBookPage1)
    hideTexture(SpellBookPage2)
    SpellBookFrameBg:SetAtlas('auctionhouse-background-sell-right')
    setAlpha(SpellBookFrameBg)
    hideTexture(SpellBookFrameInset.Bg)
    setAlpha(SpellBookFrame.NineSlice.TopLeftCorner)
    setAlpha(SpellBookFrame.NineSlice.TopEdge)
    setAlpha(SpellBookFrame.NineSlice.TopRightCorner)

    setAlpha(WorldMapFrame.BorderFrame.NineSlice.TopLeftCorner)
    setAlpha(WorldMapFrame.BorderFrame.NineSlice.TopEdge)
    setAlpha(WorldMapFrame.BorderFrame.NineSlice.TopRightCorner)
    setAlpha(WorldMapFrameBg)
    setAlpha(QuestMapFrame.Background)
end
--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
panel:RegisterEvent('VEHICLE_PASSENGERS_CHANGED')
panel:RegisterEvent('UPDATE_OVERRIDE_ACTIONBAR')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local check=e.CPanel(e.onlyChinse and '隐藏材质' or addName, not Save.disabled)
            check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
                if Save.disabled then
                    panel.check2.text:SetText('|cff808080'..(e.onlyChinse and '透明度' or CHANGE_OPACITY)..'0.5')
                else
                    panel.check2.text:SetText((e.onlyChinse and '透明度' or CHANGE_OPACITY)..'0.5')
                end
            end)

            panel.check2=CreateFrame("CheckButton", nil, check, "InterfaceOptionsCheckButtonTemplate")
            panel.check2:SetPoint('LEFT', check.text, 'RIGHT')
            panel.check2:SetChecked(not Save.disabledAlpha)
            panel.check2:SetScript('OnMouseDown', function()
                Save.disabledAlpha= not Save.disabledAlpha and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabledAlpha), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
                panel.check2.text:SetText('|cff808080'..(e.onlyChinse and '透明度' or CHANGE_OPACITY)..'0.5')
            else
                Init_HideTexture()
                if not Save.disabledAlpha then
                    Init_SetAlpha()
                end
                panel.check2.text:SetText((e.onlyChinse and '透明度' or CHANGE_OPACITY)..'0.5')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_WeeklyRewards' then--周奖励提示
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

        else
            set_Alpha_Event(arg1)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='UNIT_ENTERED_VEHICLE' or event=='UPDATE_OVERRIDE_ACTIONBAR' then
        set_UNIT_ENTERED_VEHICLE()
    end
end)