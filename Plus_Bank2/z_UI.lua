
if BankFrameTab2 then
    return
end




--SetTexture
function WoWTools_TextureMixin.Frames:BankFrame()
--下面Tab
    self:SetTabButton(BankFrame)
    self:SetButton(BankFrameCloseButton)

--搜索框
    self:SetEditBox(BankItemSearchBox)
    self:HideTexture(BankFrame.TopTileStreaks)
--背景
    self:HideFrame(BankFrame, {show={[BankFrame.Background]=true}})
    BankFrame.Background:ClearAllPoints()
    BankFrame.Background:SetAllPoints()


--BankPanel
    self:HideFrame(BankPanel)
    self:SetNineSlice(BankPanel, 0)
    self:HideFrame(BankPanel.EdgeShadows)

--钱
    self:HideFrame(BankPanel.MoneyFrame.Border)


--右边Tab
    self:HideTexture(BankPanel.PurchaseTab.Border)
    WoWTools_ButtonMixin:AddMask(BankPanel.PurchaseTab, true, BankPanel.PurchaseTab.Border.Icon)
    hooksecurefunc(BankPanelTabMixin, 'OnLoad', function(btn)
        self:HideTexture(btn.Border)
        WoWTools_ButtonMixin:AddMask(btn, true, btn.Icon)
    end)

--TabSettingsMenu
    self:SetFrame(BankPanel.TabSettingsMenu.BorderBox)
    self:SetFrame(BankPanel.TabSettingsMenu.DepositSettingsMenu)
    self:SetScrollBar(BankPanel.TabSettingsMenu.IconSelector)
    self:SetMenu(BankPanel.TabSettingsMenu.BorderBox.IconTypeDropdown)
    self:SetMenu(BankPanel.TabSettingsMenu.DepositSettingsMenu.ExpansionFilterDropdown)
    self:SetEditBox(BankPanel.TabSettingsMenu.BorderBox.IconSelectorEditBox)
    self:HideFrame(BankPanel.TabSettingsMenu.BorderBox.SelectedIconArea.SelectedIconButton)

--button
    hooksecurefunc(BankPanelItemButtonMixin, 'OnLoad', function(btn)
        self:SetAlphaColor(btn.Background, nil, nil, 0.2)
        self:HideTexture(btn.NormalTexture)
    end)

    self:SetFrame(BankCleanUpConfirmationPopup.Border, {notAlpha=true})

    self:Init_BGMenu_Frame(BankFrame, {
        enabled=true,
        alpha=1,
        settings=function(_, texture, alpha)
            alpha= texture and 0 or alpha or 1
            BankFrame.Background:SetAlpha(alpha)
        end
    })
end