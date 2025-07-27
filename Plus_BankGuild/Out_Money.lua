local function Save()
    return WoWToolsSave['Plus_GuildBank']
end

local function Init()
    local check= WoWTools_ButtonMixin:Cbtn(GuildBankFrame.WithdrawButton,{
        name= 'WoWToolsGuildBankFrameAutoOutMoneyCheck',
        isCheck=true,
    })
    check:SetPoint('RIGHT', GuildBankFrame.WithdrawButton, 'LEFT')
    
    check:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:settings()
    end)


    function check:settings()
        
    end
    
    GuildBankFrame:HookScript('OnShow', function()
        check:settings()
    end)

    Init=function()end
end


--autoOutMoney
function WoWTools_GuildBankMixin:Init_Out_Money()
    Init()
end

