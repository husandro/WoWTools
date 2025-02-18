
local function Save()
    return WoWTools_BankMixin.Save
end





local function Init()

    WoWTools_MoveMixin:Setup(BankFrame, {setSize=true, needSize=true, needMove=true, minW=329, minH=402,
    sizeUpdateFunc= function()
        local h= math.ceil((BankFrame:GetHeight()-108)/(Save().line+37))
        Save().num= h
        print(h)
    end, sizeRestFunc= function()
        Save().num=15
        WoWTools_BankMixin:Init_Plus()
    end, sizeStopFunc= function()
        WoWTools_BankMixin:Init_Plus()
    end
})

    WoWTools_MoveMixin:Setup(AccountBankPanel, {frame=BankFrame})

    if not BankFrame.ResizeButton then
        return
    end

    hooksecurefunc('BankFrame_ShowPanel', function()
        BankFrame.ResizeButton.setSize= BankFrame.activeTabIndex==1 and true or false
    end)
end







function WoWTools_BankMixin:Init_MoveFrame()
    Init()
end