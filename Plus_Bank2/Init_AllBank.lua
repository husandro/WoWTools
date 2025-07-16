
if BankFrameTab2 then
    return
end
local function Save()
    return WoWToolsSave['Plus_Bank2']
end
--[[
self:GetActiveBankType() == Enum.BankType.Account

BankPanel.selectedTabID
    bankType
    purchasedBankTabData

BankPanel.itemButtonPool
    bankTabPool


BankPanel:GetActiveBankType()
    IsBankTypeLocked()
    RefreshBankPanel()
    GenerateItemSlotsForSelectedTab()

BankFrame:GetActiveBankType()
}
]]
local PURCHASE_TAB_ID= -1

local function GenerateItemSlotsForSelectedTab(self)
    if not self.selectedTabID or self.selectedTabID == PURCHASE_TAB_ID or not Save().allBank then
        return
    end
end




local function Init()
    if not Save().allBank then
        return
    end

--存放各种材料
    BankPanel.AutoDepositFrame.DepositButton:ClearAllPoints()
    BankPanel.AutoDepositFrame.DepositButton:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6,0)
    BankPanel.AutoDepositFrame.DepositButton:SetSize(23, 23)
    BankPanel.AutoDepositFrame.DepositButton.Left:SetAlpha(0)
    BankPanel.AutoDepositFrame.DepositButton.Right:SetAlpha(0)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseUp', function(self)
        self:SetAlpha(1)
    end)
    BankPanel.AutoDepositFrame.DepositButton:HookScript('OnMouseDown', function(self)
        self:SetAlpha(0.5)
    end)
    hooksecurefunc(BankPanel.AutoDepositFrame.DepositButton, 'UpdateTextForBankType', function(self)
        self:SetText('')
    end)

    BankPanel.AutoDepositFrame.DepositButton:SetNormalAtlas('Professions_Tracking_Fish')
    BankPanel.AutoDepositFrame.DepositButton:SetScript('OnLeave', GameTooltip_Hide)
    BankPanel.AutoDepositFrame.DepositButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TextMixin:CN(self:GetBestTextForBankType()))
        GameTooltip:Show()
    end)

--Check 包括可交易的材料
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:ClearAllPoints()
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetPoint('RIGHT', BankPanel.AutoDepositFrame.DepositButton, 'LEFT')
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetScript('OnLeave', GameTooltip_Hide)
    BankPanel.AutoDepositFrame.IncludeReagentsCheckbox:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TextMixin:CN(self.text))
        GameTooltip:Show()
    end)
    hooksecurefunc(BankPanel.AutoDepositFrame.IncludeReagentsCheckbox, 'Init', function(self)
        self.Text:SetText('')
    end)

--钱
    WoWTools_TextureMixin:CreateBG(BankPanel.MoneyFrame, {point=function(icon)
        icon:SetPoint('TOPLEFT', BankPanelGoldButtonText, -2, 2)
        icon:SetPoint('BOTTOMRIGHT', BankPanelCopperButtonText, 2, -2)
    end})
    BankPanel.MoneyFrame:ClearAllPoints()
    BankPanel.MoneyFrame:SetPoint('TOPRIGHT', BankPanel, 'BOTTOMRIGHT')

--整全一起
    hooksecurefunc(BankPanel, 'GenerateItemSlotsForSelectedTab', GenerateItemSlotsForSelectedTab)

    --BankFrame:UpdateWidthForSelectedTab()




    Init=function()
        --WoWTools_Mixin:Call(BankFrame, 'UpdateWidthForSelectedTab', BankFrame)
        BankPanel:GenerateItemSlotsForSelectedTab()
    end
end






local function Init_Move()
    BankPanel:SetPoint('TOPRIGHT')
    BankPanel:SetPoint('BOTTOMRIGHT')

    WoWTools_MoveMixin:Setup(BankFrame, {
        setSize=true, minW=80, minH=140,
    sizeUpdateFunc= function()
        local h= math.ceil((BankFrame:GetHeight()-108)/(Save().line+37))
        Save().num= h
        --Init()
    end, sizeRestFunc= function()
        Save().num=15
        Init()
        --BankFrame:SetSize(738, 460)
    end, sizeStopFunc= function()
        Init()
    end})
    WoWTools_MoveMixin:Setup(BankPanel.TabSettingsMenu, {frame=BankFrame})
    WoWTools_MoveMixin:Setup(BankCleanUpConfirmationPopup)
    
    BankFrame.ResizeButton.setSize= Save().allBank
    Init_Move=function()
        BankFrame.ResizeButton.setSize= Save().allBank
    end
end




--移动，银行
function WoWTools_MoveMixin.Frames:BankFrame()
    Init_Move()
end

function WoWTools_BankMixin:Init_AllBank()
    Init()
    Init_Move()
end
