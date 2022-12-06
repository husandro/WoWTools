local id, e= ...
local addName=HIDE..TEXTURES_SUBHEADER
local Save={}


--######
--初始化
--######
local function Init()
    ExtraActionButton1.style:SetShown(false)--额外技能
    ZoneAbilityFrame.Style:SetShown(false)--区域技能

  
    MainMenuBar.EndCaps.LeftEndCap:SetShown(false)
    MainMenuBar.EndCaps.RightEndCap:SetShown(false)

    PetBattleFrame.TopArtLeft:SetShown(false)
    PetBattleFrame.TopArtRight:SetShown(false)
    PetBattleFrame.TopVersus:SetShown(false)
    PetBattleFrame.TopVersusText:SetShown(false)
    PetBattleFrame.WeatherFrame.BackgroundArt:SetShown(false)
    PetBattleFrame.BottomFrame.LeftEndCap:SetShown(false)
    PetBattleFrame.BottomFrame.RightEndCap:SetShown(false)
    PetBattleFrame.BottomFrame.Background:SetShown(false)
    PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2:SetShown(false)
    PetBattleFrame.BottomFrame.FlowFrame:SetShown(false)
    PetBattleFrame.BottomFrame.Delimiter:SetShown(false)
    --PetBattleFrame.BottomFrame.TurnTimer.ArtFrame2:SetShown(false)
    PetBattleFrameXPBarLeft:SetShown(false)
    PetBattleFrameXPBarRight:SetShown(false)
    PetBattleFrameXPBarMiddle:SetShown(false)



    --PetBattleFrame.BottomFrame.MicroButtonFrame.RightEndCap:SetShown(false)
    --PetBattleFrame.BottomFrame.MicroButtonFrame.LeftEndCap:SetShown(false)
    hooksecurefunc('PetBattleFrame_UpdatePassButtonAndTimer', function(self)--Blizzard_PetBattleUI.lua
        self.BottomFrame.TurnTimer.TimerBG:SetShown(false);
        --self.BottomFrame.TurnTimer.Bar:SetShown(true);
        self.BottomFrame.TurnTimer.ArtFrame:SetShown(false);
        self.BottomFrame.TurnTimer.ArtFrame2:SetShown(false);
    end)

    local frame =PaladinPowerBarFrameBG if frame then frame:SetShown(false) end
    frame=PaladinPowerBarFrameBankBG if frame then frame:SetShown(false) end
    
    LootFrameBg:SetShown(false)--拾取

    hooksecurefunc(HelpTip,'Show', function(self, parent, info, relativeRegion)--隐藏所有HelpTip HelpTip.lua
        --e.Ccool(parent,nil, 2, nil, nil, true, nil, true)
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
end

local function set_UNIT_ENTERED_VEHICLE()--载具
    if OverrideActionBarEndCapL then
        OverrideActionBarEndCapL:SetShown(false)
        OverrideActionBarEndCapR:SetShown(false)
        OverrideActionBarBorder:SetShown(false)
        OverrideActionBarBG:SetShown(false)
        OverrideActionBarButtonBGMid:SetShown(false)     
        OverrideActionBarButtonBGR:SetShown(false)
        OverrideActionBarButtonBGL:SetShown(false)
    end
    if OverrideActionBarMicroBGMid then
        OverrideActionBarMicroBGMid:SetShown(false)
        OverrideActionBarMicroBGR:SetShown(false)
        OverrideActionBarMicroBGL:SetShown(false)
        OverrideActionBarLeaveFrameExitBG:SetShown(false)

        OverrideActionBarDivider2:SetShown(false)
        OverrideActionBarLeaveFrameDivider3:SetShown(false)
    end
    if OverrideActionBarExpBar then
        OverrideActionBarExpBarXpMid:SetShown(false)
        OverrideActionBarExpBarXpR:SetShown(false)
        OverrideActionBarExpBarXpL:SetShown(false)
    end
end
--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
panel:RegisterEvent('VEHICLE_PASSENGERS_CHANGED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), REQUIRES_RELOAD)
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
    elseif event=='UNIT_ENTERED_VEHICLE' then
        set_UNIT_ENTERED_VEHICLE()
    end
end)