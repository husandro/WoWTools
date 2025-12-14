local function Save()
    return WoWToolsSave['Plus_GuildBank']
end




local function Get_CanOut_Money()
    local withdrawLimit = GetGuildBankWithdrawMoney() or 0
    if withdrawLimit <= 0 then
        return
    elseif (not CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) or (CanGuildBankRepair() and not CanWithdrawGuildBankMoney()) then
        return
    else
        local out=GetGuildBankMoney() or 0
        out= math.min(out, withdrawLimit)

        if out>0 then
            return out
        end
    end
end

local function Out_Value(num)
    local money= num or Save().autoOutMoney
    if not money then
        return
    end

    money= money*10000

    local amount = Get_CanOut_Money()--可提取数量
    if not amount then
        return
    end

    if money>0 then--等于0时，提取最大值
        amount = min(amount, money)
    end

    if amount>0 then
        return amount
    end
end

--自动填充
local function Out_Money(num)
    local money= Out_Value(num)
    if money then

        WithdrawGuildBankMoney(money)

        print(
            WoWTools_GuildBankMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW),
            '|cnGREEN_FONT_COLOR:'..C_CurrencyInfo.GetCoinTextureString(money)
        )
    end
end






local function Out_Text(num)
    local money= Out_Value(num)
    local text=''
    if money then
       text= ' '..WoWTools_DataMixin:MK(math.modf(money/10000), 3)..'|A:Coin-Gold:0:0|a'
    end
    return WoWTools_DataMixin.Player.col
            ..(WoWTools_DataMixin.onlyChinese and '提取' or WITHDRAW)
            ..text
end

local function Out_Tooltip(tooltip, num)
    local money= Out_Value(num) or 0
    local guild= GetGuildBankMoney() or 0
    local out= GetGuildBankWithdrawMoney() or 0
    out= math.min(guild, out)

    tooltip:AddDoubleLine(
        (WoWTools_DataMixin.onlyChinese and '公会银行' or GUILD_BANK)
        ..' '
        ..C_CurrencyInfo.GetCoinTextureString(GetGuildBankMoney() or 0)
    )
    tooltip:AddLine(' ')
    tooltip:AddLine(
        (money>0 and '|cnGREEN_FONT_COLOR:' or '|cff606060')
        ..(WoWTools_DataMixin.onlyChinese and '可用数量' or GUILDBANK_AVAILABLE_MONEY)
        ..' '
        ..(C_CurrencyInfo.GetCoinTextureString(out))
    )
end








local function Save_Value(num)
    local bag= GetMoney() or 0
    local money= num*10000
    if bag>= money then
        return money
    end
end


local function Save_Tooltip(tooltip, num)
    local bag= GetMoney() or 0
    local money= num*10000
    tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '放入' or DEPOSIT)

    if bag>=money then
        tooltip:AddLine(
            WoWTools_DataMixin.Player.col
            ..WoWTools_DataMixin.Icon.Player
            ..C_CurrencyInfo.GetCoinTextureString(bag-money)
        )
    else
        tooltip:AddLine(
            '|cff606060'
            ..WoWTools_DataMixin.Icon.Player
            ..C_CurrencyInfo.GetCoinTextureString(bag)
        )
    end
end


local SaveMoney=0
local function Save_Money(num)
    local money= Save_Value(num)
    if money then
        DepositGuildBankMoney(money)
        SaveMoney= SaveMoney + money

        print(
            WoWTools_DataMixin.Icon.wow2
            ..(WoWTools_DataMixin.onlyChinese and '放入' or DEPOSIT),
            C_CurrencyInfo.GetCoinTextureString(money),

            SaveMoney~=money and '|cnGREEN_FONT_COLOR:'..WoWTools_DataMixin:MK(SaveMoney/10000, 3) or ''
        )
    end
end















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2



--提取
    local autoSub=root:CreateButton(
        Out_Text(),
    function()
        Out_Money()
        return MenuResponse.Open
    end)
    autoSub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame.fontString:SetText(Out_Text())
            end
        end)
        btn:SetScript('OnHide', function(frame)
            frame:SetScript('OnUpdate', nil)
            frame.elapsed=nil
        end)
    end)
    autoSub:SetTooltip(function(tooltip)
        Out_Tooltip(tooltip)
    end)

--自动提取
    local out= Save().autoOutMoney or 0
    autoSub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW),
    function()
        return Save().autoOutMoney
    end, function()
        Save().autoOutMoney= not Save().autoOutMoney and out or nil
        self:settings()
    end)


--自定义数量
    autoSub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(autoSub, {
        getValue=function()
            return Save().autoOutMoney or out
        end, setValue=function(value)
            if Save().autoOutMoney then
                Save().autoOutMoney=value
                self:settings()
            end
            out= value
        end,
        name='',
        tooltip=self.tooltip,
        minValue=0,
        maxValue=100000,
        step=100,
    })
    autoSub:CreateSpacer()

    sub=autoSub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '仅限成员' or  format(LFG_LIST_CROSS_FACTION, COMMUNITY_MEMBER_ROLE_NAME_MEMBER),
    function()
        return Save().onlyMemberOutMoney
    end, function()
        Save().onlyMemberOutMoney= not Save().onlyMemberOutMoney and true or false
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            (WoWTools_DataMixin.onlyChinese and '管理员' or COMMUNITY_MEMBER_ROLE_NAME_LEADER)
            ..': '
            ..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
        )
    end)




--全部提取
    sub=root:CreateButton(
        WoWTools_DataMixin.Player.col
        ..(WoWTools_DataMixin.onlyChinese and '全部提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, DEPOSIT)),
    function()
        Out_Money(0)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        Out_Tooltip(tooltip, 0)
    end)

--填充 100, 500, 1000, 5000, 10000
    for _, num in pairs({100000, 50000, 10000,5000, 1000, 500, 100}) do
        sub2= sub:CreateButton(
            WoWTools_DataMixin:MK(num, 0)
            ..'|A:Coin-Gold:0:0|a',
        function(data)
            Out_Money(data)
            return MenuResponse.Refresh
        end, num)
        sub2:SetTooltip(function(tooltip, desc)
            Out_Tooltip(tooltip, desc.data)
        end)
        sub2:AddInitializer(function(btn, desc)
            btn:SetScript("OnUpdate", function(frame, elapsed)
                frame.elapsed= (frame.elapsed or 0.3) +elapsed
                if frame.elapsed>0.3 then
                    frame.elapsed=0
                    local value= (Get_CanOut_Money() or 0)/10000
                    if value>desc.data then
                        frame.fontString:SetTextColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
                    else
                        frame.fontString:SetTextColor(0.62, 0.62, 0.62)
                    end
                end
            end)
            btn:SetScript('OnHide', function(frame)
                frame:SetScript('OnUpdate', nil)
                frame.elapsed=nil
            end)
        end)
    end








    local isLeader= WoWTools_GuildMixin:IsLeaderOrOfficer()

    root:CreateDivider()
    sub= root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '放入' or DEPOSIT,
    function()
        return  MenuResponse.Open
    end)



    for _, num in pairs({100000, 50000, 10000, 5000, 1000, 500, 100}) do
        if num<5000 or isLeader then
            if num==1000 and isLeader then
                sub:CreateDivider()
            end

            sub2= sub:CreateButton(
                WoWTools_DataMixin:MK(num, 0)
                ..'|A:Coin-Gold:0:0|a',
            function(data)
                Save_Money(data)
                return MenuResponse.Open
            end, num)
            sub2:SetTooltip(function(tooltip, desc)
                Save_Tooltip(tooltip, desc.data)
            end)
            sub2:AddInitializer(function(btn, desc)
                btn:SetScript("OnUpdate", function(frame, elapsed)
                    frame.elapsed= (frame.elapsed or 0.3) +elapsed
                    if frame.elapsed>0.3 then
                        frame.elapsed=0
                        if Save_Value(desc.data) then
                            frame.fontString:SetTextColor(1,1,1)
                        else
                            frame.fontString:SetTextColor(0.62, 0.62, 0.62)
                        end
                    end
                end)
                btn:SetScript('OnHide', function(frame)
                    frame:SetScript('OnUpdate', nil)
                    frame.elapsed=nil
                end)
            end)
        end
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
        GameTooltip:AddLine(' ')

        local r
        local num= Save().autoOutMoney
        if num==0 then
            r= (WoWTools_DataMixin.onlyChinese and '最大' or MAXIMUM)..'|A:Coin-Gold:0:0|a'
        elseif num then
            local money= Out_Value()
            if money then
                r= '|cnGREEN_FONT_COLOR:'..C_CurrencyInfo.GetCoinTextureString(money)
            else
                r= '|cff606060'..WoWTools_DataMixin:MK(num, 3)..'|A:Coin-Gold:0:0|a'
            end
        else
            r= WoWTools_TextMixin:GetEnabeleDisable(false)..'|A:Coin-Gold:0:0|a'
        end

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '自动提取' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, WITHDRAW)),

            r
        )

        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '仅限成员' or  format(LFG_LIST_CROSS_FACTION, COMMUNITY_MEMBER_ROLE_NAME_MEMBER),
            WoWTools_TextMixin:GetEnabeleDisable(Save().onlyMemberOutMoney)
        )


        GameTooltip:Show()
    end



    function btn:settings()
        local out= Save().autoOutMoney
        if out==0 then
            self:SetNormalAtlas('Cursor_OpenHandGlow_32')
        elseif out then
            self:SetNormalAtlas('Cursor_OpenHand_32')
        else
            self:SetNormalAtlas('Cursor_unableOpenHandGlow_32')
        end
    end


--菜单
    btn:SetupMenu(Init_Menu)







    GuildBankFrame:HookScript('OnShow', function()
        if not IsModifierKeyDown()
            and (
                    Save().onlyMemberOutMoney
                    and (not WoWTools_GuildMixin:IsLeaderOrOfficer())
                    or not Save().onlyMemberOutMoney
            )
        then
            Out_Money()
        end
        btn:settings()
    end)

    Init=function()end
end






function WoWTools_GuildBankMixin:Init_Out_Money()
    Init()
end

