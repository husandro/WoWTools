






local function Init()
    WoWTools_MoveMixin:Setup(BankFrame)
    WoWTools_MoveMixin:Setup(AccountBankPanel, {frame=BankFrame})
end







function WoWTools_BankMixin:Init_MoveFrame()
    Init()
end