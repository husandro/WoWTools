
local function Save()
    return WoWToolsSave['Plus_Bank']
end





local function Init()

    WoWTools_MoveMixin:Setup(BankFrame, {
        --needSize=true, needMove=true,
        setSize=true, minW=80, minH=140,
    sizeUpdateFunc= function()
        local h= math.ceil((BankFrame:GetHeight()-108)/(Save().line+37))
        Save().num= h
    end, sizeRestFunc= function()
        Save().num=15
        WoWTools_BankMixin:Init_Plus()
    end, sizeStopFunc= function()
        WoWTools_BankMixin:Init_Plus()
    end})

    WoWTools_MoveMixin:Setup(AccountBankPanel, {frame=BankFrame})

    if not BankFrame.ResizeButton then
        return
    end

    hooksecurefunc('BankFrame_ShowPanel', function()
        local index= BankFrame.activeTabIndex
        local enable= index==1
                    or (index==3 and Save().allAccountBag)

        BankFrame.ResizeButton.setSize= enable or false
    end)
end







function WoWTools_BankMixin:Init_MoveFrame()
    Init()
end