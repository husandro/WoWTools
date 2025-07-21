if BankFrameTab2 then
    return
end

--[[
BankPanelSystemMixin:IsActiveBankTypeLocked()
BankPanelSystemMixin:GetActiveBankType()
BankPanel:GetActiveBankType() == Enum.BankType.Account

BankPanel.selectedTabID
BankPanel.bankType
BankPanel.purchasedBankTabData
BankPanel.itemButtonPool
BankPanel.bankTabPool
BankPanel:GetActiveBankType()
BankPanel:IsBankTypeLocked()
BankPanel:RefreshBankPanel()
BankPanel:GenerateItemSlotsForSelectedTab()
BankFrame:GetActiveBankType()

C_Bank.FetchBankLockedReason(Enum.BankType.Account) : reason
C_Bank.FetchDepositedMoney(Enum.BankType.Account) : amount
C_Bank.FetchNextPurchasableBankTabData(Enum.BankType.Account) : nextPurchasableTabData
C_Bank.FetchNumPurchasedBankTabs(Enum.BankType.Account) : numPurchasedBankTabs
C_Bank.FetchPurchasedBankTabData(Enum.BankType.Account) : purchasedBankTabData
C_Bank.FetchPurchasedBankTabIDs(Enum.BankType.Account) : purchasedBankTabIDs
C_Bank.FetchViewableBankTypes() :


]]

