if not BankFrameTab2 then
    return
end

local function Save()
    return WoWToolsSave['Plus_Bank'] or {}
end


--银行
function WoWTools_MoveMixin.Frames:BankFrame()
    if Save().disabled then
        self:Setup(BankFrame)
        self:Setup(AccountBankPanel, {frame=BankFrame})
    end
end



local function Init()
    WoWTools_MoveMixin:Setup(BankFrame, {
        setSize=true, minW=80, minH=140,
    sizeUpdateFunc= function()
        local h= math.ceil((BankFrame:GetHeight()-108)/(Save().line+37))
        Save().num= h
        --WoWTools_BankMixin:Init_Plus()
    end, sizeRestFunc= function()
        Save().num=15
        WoWTools_BankMixin:Init_Plus()
    end, sizeStopFunc= function()
        WoWTools_BankMixin:Init_Plus()
    end})

    WoWTools_MoveMixin:Setup(AccountBankPanel, {frame=BankFrame})
    WoWTools_MoveMixin:Setup(BankCleanUpConfirmationPopup)

    hooksecurefunc('BankFrame_ShowPanel', function()
        local index= BankFrame.activeTabIndex
        local enable= index==1
                    or (index==3 and Save().allAccountBag)

        BankFrame.ResizeButton.setSize= enable or false
    end)

    Init=function() end
end







function WoWTools_BankMixin:Init_MoveFrame()
    Init()
end