--SetTexture
function WoWTools_TextureMixin.Frames:BankFrame()
    self:SetUIButton(BankPanel.AutoDepositFrame.DepositButton)
    self:SetUIButton(BankPanel.MoneyFrame.WithdrawButton)
    self:SetUIButton(BankPanel.MoneyFrame.DepositButton)
    self:SetUIButton(BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton)
    self:SetButton(BankFrameCloseButton)

--下面Tab
    self:SetTabButton(BankFrame)

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
    WoWTools_DataMixin:Hook(BankPanelTabMixin, 'OnLoad', function(btn)
        self:HideTexture(btn.Border)
        WoWTools_ButtonMixin:AddMask(btn, true, btn.Icon)
    end)

--TabSettingsMenu
    self:SetIconSelectFrame(BankPanel.TabSettingsMenu)
    self:SetUIButton(BankPanel.TabSettingsMenu.BorderBox.OkayButton)
    self:SetUIButton(BankPanel.TabSettingsMenu.BorderBox.CancelButton)

--button
    WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'OnLoad', function(btn)
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