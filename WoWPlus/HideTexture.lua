local id, e= ...
local addName=HIDE..TEXTURES_SUBHEADER
local Save={}

local function hideTexture(self)
    if self then
        self:SetTexture(0)
        self:SetShown(false)
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
local function Init()
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

--[[
    hooksecurefunc(BaseActionButtonMixin,'UpdateButtonArt', function(self, hideDivider)--ActionButton.lua
        if (not self or not self.SlotArt or not self.SlotBackground) then
            return;
        end

        hideTexture(self.SlotArt)
        hideTexture(self.SlotBackground)
        if self.RightDivider and self.BottomDivider then
           -- print(self.RightDivider:IsShown(), self:GetName())
            self.RightDivider:SetShown(false)
            self.BottomDivider:SetShown(false) 
        end
    end)
]]
    for i=1, 12 do
        local self= _G['ActionButton'..i]
        if self and self.SlotArt and self.SlotBackground then
            hideTexture(self.SlotArt)
            hideTexture(self.SlotBackground)
            if self.RightDivider and self.BottomDivider then
                --self.RightDivider:SetShown(false)--frame
                --self.BottomDivider:SetShown(false)

                hideTexture(self.RightDivider.TopEdge)
                hideTexture(self.RightDivider.BottomEdge)
                hideTexture(self.RightDivider.Center)
                --hideTexture(self.Border)

            end
        end
    end

    MainMenuBar.Background:SetShown(false)
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
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '隐藏材质' or addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='UNIT_ENTERED_VEHICLE' or event=='UPDATE_OVERRIDE_ACTIONBAR' then
        set_UNIT_ENTERED_VEHICLE()

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
    end
end)