local function Save()
    return WoWToolsSave['Plus_GuildBank']
end

local function Init()
    local btn= WoWTools_ButtonMixin:Menu(GuildBankFrame.WithdrawButton,{
        name= 'WoWToolsGuildBankFrameAutoOutMoneyCheck',
        atlas= 'Cursor_OpenHandGlow_32',
    })
    btn:SetPoint('RIGHT', GuildBankFrame.WithdrawButton, 'LEFT')
    
    --[[btn:SetScript('OnLeave', function()
        GameTooltip_Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)]]

   function btn:tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '打开公会银行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OPENING, GUILD_BANK))

        local r
        local num= Save().autoOutMone
        if num==0 then
            r=WoWTools_DataMixin.onlyChinese and '最大' or MAXIMUM
        elseif num then
            r= WoWTools_Mixin:MK(num, 3)
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

    btn:SetupMenu(function(self, root)
        local num= Save().autoOutMoney or 0
        root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW),
        function()
            return Save().autoOutMoney
        end, function()
            Save().autoOutMoney= not Save().autoOutMoney and num or nil
        end)

        --自定义数量
        root:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(root, {
            getValue=function()
                return Save().autoOutMoney or 500
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
    
    function btn:settings()
        
    end
    


    GuildBankFrame:HookScript('OnShow', function()
        btn:settings()
    end)

    Init=function()end
end


--autoOutMoney3



function WoWTools_GuildBankMixin:Init_Out_Money()
    Init()
end

