local function Save()
    return WoWToolsSave['Plus_GuildBank']
end





local function Get_Money()
    local money= Save().autoOutMoney
    if not money then
        return
    end
    money= money*10000

    
    local withdrawLimit = GetGuildBankWithdrawMoney() or 0

    if withdrawLimit <= 0 then
        return
    end

    local amount;
    if (not CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) or (CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) then
        return
    else
        amount = GetGuildBankMoney() or 0
    end

    amount = min(withdrawLimit, amount)
    if money>0 then--等于0时，提取最大值
        amount = min(amount, money)
    end

    if amount>0 then
        return amount
    end
end









local function Init()
    local btn= WoWTools_ButtonMixin:Menu(GuildBankFrame.WithdrawButton,{
        name= 'WoWToolsGuildBankFrameAutoOutMoneyCheck',
        atlas= 'Cursor_OpenHandGlow_32',
    })
    btn:SetPoint('RIGHT', GuildBankFrame.WithdrawButton, 'LEFT')

    btn:SetScript('OnLeave', function()
        GameTooltip_Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:tooltip()
    end)

   function btn:tooltip()
        GameTooltip:SetOwner(btn, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '打开公会银行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OPENING, GUILD_BANK))

        local r
        local num= Save().autoOutMoney
        if num==0 then
            r=WoWTools_DataMixin.onlyChinese and '最大' or MAXIMUM            
        elseif num then
            local money= Get_Money()
            if money then
                r= '|cnGREEN_FONT_COLOR:'..C_CurrencyInfo.GetCoinTextureString(money)
            else
                r= '|cff606060'..WoWTools_Mixin:MK(num, 3)
            end
        else
            r= WoWTools_TextMixin:GetEnabeleDisable(false)
        end

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW)),

            r..'|A:Coin-Gold:0:0|a'
        )

        GameTooltip:Show()
    end



    function btn:settings()
        self:SetNormalAtlas(Get_Money() and 'Cursor_OpenHandGlow_32' or 'Cursor_unableOpenHandGlow_32')
        self:GetNormalTexture():SetAlpha(Save().autoOutMoney and 1 or 0.5)
    end


--菜单
    btn:SetupMenu(function(self, root)
--自动提取
        local num= Save().autoOutMoney or 0
        root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW),
        function()
            return Save().autoOutMoney
        end, function()
            Save().autoOutMoney= not Save().autoOutMoney and num or nil
            self:settings()
        end)


--自定义数量
        root:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(root, {
            getValue=function()
                return Save().autoOutMoney or num
            end, setValue=function(value)
                if Save().autoOutMoney then
                    Save().autoOutMoney=value
                end
            end,
            name='',
            tooltip=self.tooltip,
            minValue=0,
            maxValue=100000,
            step=100,
        })
        root:CreateSpacer()
    end)







    GuildBankFrame:HookScript('OnShow', function()
        local money= Get_Money()
        if money then

            WithdrawGuildBankMoney(money)

            print(
                WoWTools_GuildBankMixin.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW),
                '|cnGREEN_FONT_COLOR:'..C_CurrencyInfo.GetCoinTextureString(money)
            )
        end
        btn:settings()
    end)

    Init=function()end
end


--autoOutMoney3



function WoWTools_GuildBankMixin:Init_Out_Money()


    Init()
end

