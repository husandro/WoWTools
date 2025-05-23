local ItemButtons={
        [1]	 = "CharacterHeadSlot",
        [2]	 = "CharacterNeckSlot",
        [3]	 = "CharacterShoulderSlot",
        [4]	 = "CharacterShirtSlot",
        [5]	 = "CharacterChestSlot",
        [6]	 = "CharacterWaistSlot",
        [7]	 = "CharacterLegsSlot",
        [8]	 = "CharacterFeetSlot",
        [9]	 = "CharacterWristSlot",
        [10] = "CharacterHandsSlot",
        [11] = "CharacterFinger0Slot",
        [12] = "CharacterFinger1Slot",
        [13] = "CharacterTrinket0Slot",
        [14] = "CharacterTrinket1Slot",
        [15] = "CharacterBackSlot",
        [16] = "CharacterMainHandSlot",
        [17] = "CharacterSecondaryHandSlot",
        [19] = "CharacterTabardSlot",
}

--角色，界面
function WoWTools_TextureMixin.Frames:PaperDollFrame()

    self:SetButton(CharacterFrameCloseButton, {all=true})
    self:SetNineSlice(CharacterFrameInset, true)
    self:SetNineSlice(CharacterFrame, true)
    self:SetNineSlice(CharacterFrameInsetRight, true)

    self:HideTexture(CharacterFrameBg)
    self:HideTexture(CharacterFrameInset.Bg)

    --self:SetAlphaColor(CharacterFrame.Background)

    self:HideTexture(PaperDollInnerBorderBottom)
    self:HideTexture(PaperDollInnerBorderRight)
    self:HideTexture(PaperDollInnerBorderLeft)
    self:HideTexture(PaperDollInnerBorderTop)

    self:HideTexture(PaperDollInnerBorderTopLeft)
    self:HideTexture(PaperDollInnerBorderTopRight)
    self:HideTexture(PaperDollInnerBorderBottomLeft)
    self:HideTexture(PaperDollInnerBorderBottomRight)

    self:HideTexture(PaperDollInnerBorderBottom2)
    self:HideTexture(CharacterFrameInsetRight.Bg)

    self:SetAlphaColor(PaperDollSidebarTabs.DecorRight, nil, nil, 0.3)
    self:SetAlphaColor(PaperDollSidebarTabs.DecorLeft, nil, nil, 0.3)

    self:SetNineSlice(CharacterFrameInsetRight, nil, true)

--角色，物品栏
    for _, name in pairs(ItemButtons) do
        self:
        (_G[name])
    end

    self:SetTabButton(CharacterFrameTab1)
    self:SetTabButton(CharacterFrameTab2)
    self:SetTabButton(CharacterFrameTab3)

--属性
    self:SetAlphaColor(CharacterStatsPane.ClassBackground)
    self:SetAlphaColor(CharacterStatsPane.EnhancementsCategory.Background)
    self:SetAlphaColor(CharacterStatsPane.AttributesCategory.Background)
    self:SetAlphaColor(CharacterStatsPane.ItemLevelCategory.Background)

--头衔
    hooksecurefunc('PaperDollTitlesPane_UpdateScrollBox', function()--PaperDollFrame.lua
        local frame= PaperDollFrame.TitleManagerPane.ScrollBox
        if not frame or not frame:GetView() then
            return
        end
        for _, button in pairs(frame:GetFrames() or {}) do
            self:SetAlphaColor(button.BgMiddle, nil, nil, true)
        end
    end)
    self:SetScrollBar(PaperDollFrame.TitleManagerPane)

--装备方案
    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function()
        for _, button in pairs(PaperDollFrame.EquipmentManagerPane.ScrollBox:GetFrames() or {}) do
            self:SetAlphaColor(button.BgMiddle, nil, nil, true)
        end
    end)
    self:SetScrollBar(PaperDollFrame.EquipmentManagerPane)



    self:SetAlphaColor(CharacterModelFrameBackgroundTopLeft, nil, nil, 0)--角色3D背景
    self:SetAlphaColor(CharacterModelFrameBackgroundTopRight, nil, nil, 0)
    self:SetAlphaColor(CharacterModelFrameBackgroundBotLeft, nil, nil, 0)
    self:SetAlphaColor(CharacterModelFrameBackgroundBotRight, nil, nil, 0)
    self:SetAlphaColor(CharacterModelFrameBackgroundOverlay, nil, nil, 0)
    CharacterModelFrameBackgroundOverlay:Hide()

--图标，选取
    self:HideFrame(GearManagerPopupFrame.BorderBox)
    self:SetAlphaColor(GearManagerPopupFrame.BG, nil, nil, 0.3)
    self:SetScrollBar(GearManagerPopupFrame.IconSelector)
    self:SetEditBox(GearManagerPopupFrame.BorderBox.IconSelectorEditBox)
    self:SetMenu(GearManagerPopupFrame.BorderBox.IconTypeDropdown)

--声望
    self:SetScrollBar(ReputationFrame)
    self:SetMenu(ReputationFrame.filterDropdown)
    self:SetFrame(ReputationFrame.ReputationDetailFrame.Border, {isMinAlpha=true})
    hooksecurefunc(ReputationFrame.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, frame in pairs(f:GetFrames() or {}) do
            if frame.Middle then
                self:SetAlphaColor(frame.Middle, nil, nil, true)
                self:SetAlphaColor(frame.Right, nil, nil, true)
                self:SetAlphaColor(frame.Left, nil, nil, true)
            end
        end
    end)
--添加Bg
    self:CreateBackground(ReputationFrame.ScrollBox, {
        atlas= "UI-Character-Info-"..WoWTools_DataMixin.Player.Class.."-BG",
        alpha=0.3,
        isAllPoint=true,
    })



--BG, 菜单
    CharacterFrame.PortraitContainer:SetPoint('TOPLEFT', -3, 3)
    CharacterFrame.Background:SetPoint('TOPLEFT',0, -2)
    CharacterFrame.Background:SetPoint('BOTTOMRIGHT',-6, 2)
    WoWTools_TextureMixin:Init_BGMenu_Frame(CharacterFrame, nil, CharacterFrame.Background, nil)
end



--货币
function WoWTools_TextureMixin.Events:Blizzard_TokenUI()
    self:SetScrollBar(TokenFrame)
    self:SetFrame(TokenFramePopup.Border, {alpha=0.3})
    self:SetMenu(TokenFrame.filterDropdown)


    hooksecurefunc(TokenFrame.ScrollBox, 'Update', function(f)
        if not f:GetView() then
            return
        end
        for _, frame in pairs(f:GetFrames() or {}) do
            if frame.Middle then
                self:SetAlphaColor(frame.Middle, nil, nil, true)
                self:SetAlphaColor(frame.Right, nil, nil, true)
                self:SetAlphaColor(frame.Left, nil, nil, true)
            end
        end
    end)

--添加Bg
    self:CreateBackground(TokenFrame.ScrollBox, {
        atlas= "UI-Character-Info-"..WoWTools_DataMixin.Player.Class.."-BG",
        alpha=0.3,
        isAllPoint=true,
    })


    --货币转移
    self:SetNineSlice(CurrencyTransferLog, true)
    self:SetAlphaColor(CurrencyTransferLogBg, nil, nil, 0.3)
    self:SetNineSlice(CurrencyTransferLogInset, true)
    self:SetScrollBar(CurrencyTransferLog)
    self:SetNineSlice(CurrencyTransferMenu, true)
    self:SetAlphaColor(CurrencyTransferMenuBg, nil, nil, 0.3)
    self:SetNineSlice(CurrencyTransferMenuInset)
    self:SetEditBox(CurrencyTransferMenu.AmountSelector.InputBox)
    self:SetMenu(CurrencyTransferMenu.SourceSelector.Dropdown)
end




--玩家, 观察角色, 界面
function WoWTools_TextureMixin.Events:Blizzard_InspectUI()
    self:SetNineSlice(InspectFrame, true)
    --self:SetAlphaColor(InspectFrameBg)
    self:HideTexture(InspectFrameInset.Bg)
    self:HideTexture(InspectPVPFrame.BG)
    
    self:HideTexture(InspectGuildFrameBG)
    self:SetTabButton(InspectFrameTab1)
    self:SetTabButton(InspectFrameTab2)
    self:SetTabButton(InspectFrameTab3)
    self:SetNineSlice(InspectFrame, true)
    self:SetNineSlice(InspectFrameInset, nil, true)

    self:SetAlphaColor(InspectModelFrameBackgroundOverlay, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundBotLeft, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundBotRight, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundTopLeft, nil, nil, 0)
    self:SetAlphaColor(InspectModelFrameBackgroundTopRight, nil, nil, 0)

    
end





