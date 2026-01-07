
--角色，界面
function WoWTools_TextureMixin.Frames:CharacterFrame()

    self:SetButton(CharacterFrameCloseButton)
    self:HideTexture(CharacterFrameBg)
    self:HideTexture(CharacterFrame.TopTileStreaks)

    self:HideFrame(CharacterModelScene)
    --[[self:HideTexture(PaperDollInnerBorderBottom)
    self:HideTexture(PaperDollInnerBorderRight)
    self:HideTexture(PaperDollInnerBorderLeft)
    self:HideTexture(PaperDollInnerBorderTop)
    self:HideTexture(PaperDollInnerBorderTopLeft)
    self:HideTexture(PaperDollInnerBorderTopRight)
    self:HideTexture(PaperDollInnerBorderBottomLeft)
    self:HideTexture(PaperDollInnerBorderBottomRight)
    self:HideTexture(PaperDollInnerBorderBottom2)]]

    self:HideTexture(PaperDollSidebarTabs.DecorRight)
    self:HideTexture(PaperDollSidebarTabs.DecorLeft)

    self:SetNineSlice(CharacterFrameInset)
    self:HideTexture(CharacterFrameInset.Bg)

    self:SetNineSlice(CharacterFrameInsetRight)
    self:HideTexture(CharacterFrameInsetRight.Bg)

    self:SetModelZoom(CharacterModelScene.ControlFrame)
    PaperDollFrame:HookScript('OnShow', function()
        CharacterModelScene.ControlFrame:SetShown(false)
    end)

--角色，物品栏 CharacterTrinket0SlotFrame
    for _, name in pairs(WoWTools_PaperDollMixin.ItemButtons) do
        self:HideTexture(_G[name..'Frame'])
        self:HideTexture(_G[name..'NormalTexture'])
    end
    CharacterMainHandSlot:DisableDrawLayer('BACKGROUND')
    CharacterSecondaryHandSlot:DisableDrawLayer('BACKGROUND')

--Tab
    self:SetTabButton(CharacterFrameTab1)
    self:SetTabButton(CharacterFrameTab2)
    self:SetTabButton(CharacterFrameTab3)

--属性
    self:SetAlphaColor(CharacterStatsPane.ClassBackground, nil, nil, true)
    self:SetAlphaColor(CharacterStatsPane.EnhancementsCategory.Background, nil, nil, true)
    self:SetAlphaColor(CharacterStatsPane.AttributesCategory.Background, nil, nil, true)
    self:SetAlphaColor(CharacterStatsPane.ItemLevelCategory.Background, nil, nil, true)

--头衔
    WoWTools_DataMixin:Hook('PaperDollTitlesPane_InitButton', function(btn, data)
        self:SetAlphaColor(btn.BgMiddle, nil, nil, true)
        btn.BgMiddle:SetPoint('RIGHT', 4, 0)
        if data.index == 1 then
            btn.BgTop:SetShown(false)
        elseif data.index==#PaperDollFrame.TitleManagerPane.titles then
            btn.BgBottom:SetShown(false)
        end
    end)
    self:SetScrollBar(PaperDollFrame.TitleManagerPane)

--装备方案
    WoWTools_DataMixin:Hook('PaperDollEquipmentManagerPane_InitButton', function(btn, data)
        self:SetAlphaColor(btn.BgMiddle, nil, nil, true)
        btn.BgMiddle:SetPoint('RIGHT', 4, 0)
        if data.addSetButton then
            btn.BgTop:SetShown(false)
            btn.BgBottom:SetShown(false)
        elseif data.index==1 then
            btn.BgTop:SetShown(false)
        end
    end)
    self:SetScrollBar(PaperDollFrame.EquipmentManagerPane)
    self:SetUIButton(PaperDollFrameEquipSet)
    self:SetUIButton(PaperDollFrameSaveSet)



    self:SetAlphaColor(CharacterModelFrameBackgroundTopLeft, nil, nil, 0)--角色3D背景
    self:SetAlphaColor(CharacterModelFrameBackgroundTopRight, nil, nil, 0)
    self:SetAlphaColor(CharacterModelFrameBackgroundBotLeft, nil, nil, 0)
    self:SetAlphaColor(CharacterModelFrameBackgroundBotRight, nil, nil, 0)
    self:SetAlphaColor(CharacterModelFrameBackgroundOverlay, nil, nil, 0)
    CharacterModelFrameBackgroundOverlay:Hide()--:SetAlpha(0)---Hide()

--图标，选取
    self:SetIconSelectFrame(GearManagerPopupFrame)
    self:SetUIButton(GearManagerPopupFrame.BorderBox.OkayButton)
    self:SetUIButton(GearManagerPopupFrame.BorderBox.CancelButton)
    --[[self:HideFrame(GearManagerPopupFrame.BorderBox)
    self:SetAlphaColor(GearManagerPopupFrame.BG, nil, nil, 0.3)
    self:SetScrollBar(GearManagerPopupFrame.IconSelector)
    self:SetEditBox(GearManagerPopupFrame.BorderBox.IconSelectorEditBox)
    self:SetMenu(GearManagerPopupFrame.BorderBox.IconTypeDropdown)]]

--声望
    self:SetScrollBar(ReputationFrame)
    self:SetMenu(ReputationFrame.filterDropdown)
    self:SetFrame(ReputationFrame.ReputationDetailFrame.Border)
    self:SetButton(ReputationFrame.ReputationDetailFrame.CloseButton)
    self:SetAlphaColor(ReputationFrame.ReputationDetailFrame.Divider)
    self:SetScrollBar(ReputationFrame.ReputationDetailFrame.ScrollingDescriptionScrollBar)
    self:SetUIButton(ReputationFrame.ReputationDetailFrame.ViewRenownButton)
    self:SetCheckBox(ReputationFrame.ReputationDetailFrame.AtWarCheckbox)
    self:SetCheckBox(ReputationFrame.ReputationDetailFrame.MakeInactiveCheckbox)
    self:SetCheckBox(ReputationFrame.ReputationDetailFrame.WatchFactionCheckbox)
    WoWTools_DataMixin:Hook(ReputationBarMixin, 'UpdateBarProgressText', function(f)
        if not f.isSetTuexrue then
            self:SetStatusBar(f)
            self:SetAlphaColor(f.LeftTexture, nil, nil, 0.5)
            self:SetAlphaColor(f.RightTexture, nil, nil, 0.5)
            f.isSetTuexrue=true
        end
    end)

    WoWTools_DataMixin:Hook(ReputationFrame.ScrollBox, 'Update', function(f)
        if not f:HasView() then
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
    self:CreateBG(ReputationFrame.ScrollBox, {
        atlas= "UI-Character-Info-"..WoWTools_DataMixin.Player.Class.."-BG",
        alpha=0.3,
        isAllPoint=true,
    })



--BG, 菜单
    --CharacterFrame.PortraitContainer:SetPoint('TOPLEFT', -3, 3)

    self:Init_BGMenu_Frame(CharacterFrame)
end
















--货币
function WoWTools_TextureMixin.Events:Blizzard_TokenUI()
    self:SetButton(TokenFrame.CurrencyTransferLogToggleButton, 1)

    self:SetFrame(TokenFramePopup.Border, {alpha=1})
    self:SetUIButton(TokenFramePopup.CurrencyTransferToggleButton)
    self:SetCheckBox(TokenFramePopup.InactiveCheckbox)
    self:SetCheckBox(TokenFramePopup.BackpackCheckbox)
--货币转移, 记录
    self:SetButton(CurrencyTransferLogCloseButton)
    self:SetNineSlice(CurrencyTransferLog)
    self:SetAlphaColor(CurrencyTransferLogBg, nil, nil, 0.3)
    self:SetNineSlice(CurrencyTransferLogInset, nil, true)
    self:SetScrollBar(CurrencyTransferLog)
--货币转移
    self:SetButton(CurrencyTransferMenuCloseButton)
    self:SetUIButton(CurrencyTransferMenu.Content.ConfirmButton)
    self:SetUIButton(CurrencyTransferMenu.Content.CancelButton)
    self:SetUIButton(CurrencyTransferMenu.Content.AmountSelector.MaxQuantityButton)
    self:SetAlphaColor(CurrencyTransferMenu.Content.TransactionDivider)
        self:SetNineSlice(CurrencyTransferMenu)
    self:SetAlphaColor(CurrencyTransferMenu.TransactionDivider)
    self:HideTexture(CurrencyTransferMenuBg)
    self:SetNineSlice(CurrencyTransferMenuInset)
    if CurrencyTransferMenu.AmountSelector then--11.2 没有了
        self:SetEditBox(CurrencyTransferMenu.AmountSelector.InputBox)
        self:SetMenu(CurrencyTransferMenu.SourceSelector.Dropdown)
    else
        self:SetEditBox(CurrencyTransferMenu.Content.AmountSelector.InputBox)
        self:SetMenu(CurrencyTransferMenu.Content.SourceSelector.Dropdown)
    end

    self:SetFrame(TokenFrame)
    self:SetMenu(TokenFrame.filterDropdown)
    self:SetScrollBar(TokenFrame)--bug，货币转移，出错
    self:SetButton(TokenFramePopup['$parent.CloseButton'] or TokenFramePopup.CloseButton)

    WoWTools_DataMixin:Hook(TokenHeaderMixin, 'OnLoad_TokenHeaderTemplate', function(frame)
        self:SetAlphaColor(frame.Middle, nil, nil, 0.5)
        self:SetAlphaColor(frame.Right, nil, nil, 0.5)
        self:SetAlphaColor(frame.Left, nil, nil, 0.5)
    end)

    self:CreateBG(TokenFrame.ScrollBox, {--添加Bg
        atlas= "UI-Character-Info-"..WoWTools_DataMixin.Player.Class.."-BG",
        alpha=0.3,
        isAllPoint=true,
    })
end