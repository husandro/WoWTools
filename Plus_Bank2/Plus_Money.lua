
if BankFrameTab2 then
    return
end

local function Save()
    return WoWToolsSave['Plus_Bank2']
end


--C_Bank.CanWithdrawMoney(Enum.BankType.Account)
local function Can_DepositMoney()
    return C_Bank.DoesBankTypeSupportMoneyTransfer(Enum.BankType.Account)
        and C_Bank.CanDepositMoney(Enum.BankType.Account)
end









local function Auto_Save_Money()
    local autoSaveMoney= Save().autoSaveMoney

    if not autoSaveMoney
        or not Can_DepositMoney()
        or Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]
    then
        return
    end

    local saveMoney= GetMoney()- autoSaveMoney*10000
    if saveMoney<=0 then
        return
    end

    C_Bank.DepositMoney(Enum.BankType.Account, saveMoney)

    print(WoWTools_BankMixin.addName..WoWTools_DataMixin.Icon.icon2,
        '|cff00ccff'
        ..(WoWTools_DataMixin.onlyChinese and '自动存钱' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, BANK_DEPOSIT_MONEY_BUTTON_LABEL))
        ..'|r',
        C_CurrencyInfo.GetCoinTextureString(saveMoney)
    )
end














local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

    self:set_tooltip()

    local sub, sub2

    if not Can_DepositMoney() then
        sub=root:CreateTitle(WoWTools_DataMixin.onlyChinese and '锁定' or LOCKED)
        sub:SetTooltip(function(tooltip)
            GameTooltip_AddErrorLine(tooltip,
                WoWTools_TextMixin:CN(BankPanelLockPromptMixin:GetBankLockedMessage()),
                true
            )
        end)
        return
    end




--存放
    --local autoSaveMoney= not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] and Save().autoSaveMoney
    local function Get_Save_Text()
        local saveMoney
        local autoSaveMoney= Save().autoSaveMoney
        if autoSaveMoney then
            saveMoney= math.modf(GetMoney()/10000- autoSaveMoney)
            saveMoney= math.max(saveMoney, 0)
        end
        return '|cff00ccff'
        ..(WoWTools_DataMixin.onlyChinese and '存放' or BANK_DEPOSIT_MONEY_BUTTON_LABEL)
        ..(saveMoney and ' '..WoWTools_Mixin:MK(saveMoney, 3)..'|A:Coin-Gold:0:0|a' or '')
    end
    local autoSub=root:CreateButton(
        Get_Save_Text(),
    function()
        Auto_Save_Money()
        return MenuResponse.Open
    end)
    autoSub:AddInitializer(function(btn)
        btn:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame.fontString:SetText(Get_Save_Text())
            end
        end)
        btn:SetScript('OnHide', function(frame)
            frame:SetScript('OnUpdate', nil)
            frame.elapsed=nil
        end)
    end)

--自动存钱
    sub=autoSub:CreateCheckbox(
        '|cff00ccff'
        ..(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO),
    function()
        return Save().autoSaveMoney
    end, function()
        Save().autoSaveMoney= not Save().autoSaveMoney and 500 or nil
        self:settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '打开银行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OPENING, BANK))
    end)

--自定义数量
    --autoSub:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(autoSub, {
        getValue=function()
            return Save().autoSaveMoney or 500
        end, setValue=function(value)
            if Save().autoSaveMoney then
                Save().autoSaveMoney=value
            end
            self:settings()
        end,
        name='',
        tooltip='|cff00ccff'
            ..(WoWTools_DataMixin.onlyChinese and '存钱' or BANK_DEPOSIT_MONEY_BUTTON_LABEL)
            ..'|cnGREEN_FONT_COLOR:> |A:Coin-Gold:0:0|a',
        minValue=0,
        maxValue=10000,
        step=100,
    })
    sub:AddInitializer(function(btn)
        btn:SetScript('OnUpdate', function(frame, elapsed)
            frame.elapsed= (frame.elapsed or 0.3) +elapsed
            if frame.elapsed>0.3 then
                frame.elapsed=0
                frame:SetEnabled(Save().autoSaveMoney and true or false)
            end
        end)
    end)
    autoSub:CreateSpacer()

    --全部存放
    sub=root:CreateButton(
        '|cff00ccff'
        ..(WoWTools_DataMixin.onlyChinese and '全部存放' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, BANK_DEPOSIT_MONEY_BUTTON_LABEL)),
    function()
        C_Bank.DepositMoney(Enum.BankType.Account, GetMoney())
        return MenuResponse.Open
    end)

--存放 100, 500, 1000, 5000, 10000
    local function Get_SaveMoney_Value(num)
        local money= GetMoney()-num*10000
        if money>0 then
            return money
        end
    end
    --[[local function Get_SaveMoney_Text(num)
        local money= Get_SaveMoney_Value(num)
        if money then
            --money= C_CurrencyInfo.GetCoinTextureString(money)..' |cff606060'..WoWTools_Mixin:MK(num,0)
            return (money and '|cff606060' or '').. 
        else
            money= '|cff606060'..num..'|A:Coin-Gold:0:0|a'
        end
        return money
    end]]

    for _, num in pairs({100000,50000, 10000,5000, 1000, 500, 100}) do
        sub2= sub:CreateButton(
            WoWTools_Mixin:MK(num, 0)..'|A:Coin-Gold:0:0|a',
        function(data)
            local money= Get_SaveMoney_Value(data)
            if money then
                C_Bank.DepositMoney(Enum.BankType.Account, money)
            end
            return MenuResponse.Open
        end, num)
        sub2:SetTooltip(function(tooltip, desc)
            local money= Get_SaveMoney_Value(desc.data)
            tooltip:AddDoubleLine(
                '|cff00ccff'..(WoWTools_DataMixin.onlyChinese and '存放' or DEPOSIT),
                money and C_CurrencyInfo.GetCoinTextureString(money)
            )
            tooltip:AddDoubleLine(
                WoWTools_DataMixin.Player.col
                ..format(WoWTools_DataMixin.onlyChinese and '剩余%s' or GARRISON_MISSION_TIMELEFT, ''),
                WoWTools_DataMixin.Player.col..WoWTools_DataMixin.Player.col..WoWTools_Mixin:MK(desc.data, 0)..'|A:Coin-Gold:0:0|a'
            )
        end)
        sub2:AddInitializer(function(btn, desc)
            btn:SetScript("OnUpdate", function(frame, elapsed)
                frame.elapsed= (frame.elapsed or 0.3) +elapsed
                if frame.elapsed>0.3 then
                    frame.elapsed=0
                    if Get_SaveMoney_Value(desc.data) then
                        frame.fontString:SetTextColor(1,1,1)
                    else
                        frame.fontString:SetTextColor(0.5, 0.5, 0.5)
                    end
                end
            end)
            btn:SetScript('OnHide', function(frame)
                frame:SetScript('OnUpdate', nil)
                frame.elapsed=nil
                frame.fontString:SetTextColor(1,1,1)
            end)

            
        end)
    end





    

--过滤器
    root:CreateDivider()
    local num=0
    for _ in pairs(Save().filterSaveMoney) do
        num= num+1
    end
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '过滤' or CALENDAR_FILTERS)
        ..'|r |cnGREEN_FONT_COLOR:#'..num,
    function()
        return MenuResponse.Open
    end)
--我
    sub:CreateCheckbox(
        WoWTools_UnitMixin:GetPlayerInfo(nil, WoWTools_DataMixin.Player.GUID, nil, {faction=WoWTools_DataMixin.Player.Faction, reName=true,reRealm=true, level=WoWTools_DataMixin.Player.Level}),
    function()
        return Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]
    end, function()
        Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]= not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] and true or nil
        self:settings()
    end)
--战团
    for guid, wow in pairs(WoWTools_WoWDate) do
        if guid~=WoWTools_DataMixin.Player.GUID
            and wow.region== WoWTools_DataMixin.Player.Region
            and wow.battleTag== WoWTools_DataMixin.Player.BattleTag
        then
            sub:CreateCheckbox(
                WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil, {faction=wow.faction, reName=true,reRealm=true, level=wow.level}),
            function(data)
                return Save().filterSaveMoney[data.guid]
            end, function(data)
                Save().filterSaveMoney[data.guid]= not Save().filterSaveMoney[data.guid] and true or nil
            end, {guid=guid})
        end
    end
    sub:CreateDivider()
--勾选所有
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS,
    function()
        for guid in pairs(WoWTools_WoWDate) do
            if not Save().filterSaveMoney[guid] then
                return false
            end
        end
        return true
    end, function()
        Save().filterSaveMoney={}
        for guid, wow in pairs(WoWTools_WoWDate) do
            if wow.region== WoWTools_DataMixin.Player.Region and wow.battleTag== WoWTools_DataMixin.Player.BattleTag then
                Save().filterSaveMoney[guid]= true
            end
        end
        self:settings()
    end)
--撤选所有
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
    function()
        for _ in pairs(Save().filterSaveMoney) do
            return false
        end
        return true
    end, function()
        Save().filterSaveMoney={}
        self:settings()
    end)
    WoWTools_MenuMixin:SetScrollMode(sub)



--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName})
end
--[[
EVENTTRACE_BUTTON_DISABLE_FILTERS = "撤选所有";
EVENTTRACE_BUTTON_DISCARD_FILTER = "丢弃所有";
EVENTTRACE_BUTTON_ENABLE_FILTERS = "勾选所有";
]]














local function Init()
    local btn= WoWTools_ButtonMixin:Menu(BankPanel.MoneyFrame, {size=24,icon='hide', name='WoWToolsPlusBankMoneyButton'})
    btn.texture= btn:CreateTexture(nil, 'BORDER')
    btn.texture:SetPoint('CENTER')
    btn.texture:SetSize(24,24)
    btn.texture:SetAtlas('greatVault-whole-normal')

    btn:SetPoint('RIGHT', BankPanel.MoneyFrame.MoneyDisplay, 'LEFT', -8, 0)

    btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=0, g=0.8, b=1}})
    btn.Text:SetPoint('TOPRIGHT', btn, 'TOPLEFT')
    btn.Text2= WoWTools_LabelMixin:Create(btn, {color={r=0.62, g=0.62, b=0.62}})
    btn.Text2:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT')
    --btn.Text2:SetText('aaaaaaa')

    --btn.Text:SetPoint('RIGHT', btn.texture, 'LEFT')


    function btn:set_tooltip()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '自动存钱' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, BANK_DEPOSIT_MONEY_BUTTON_LABEL))
            ..': |cnGREEN_FONT_COLOR:>|r '
            ..(Save().autoSaveMoney
                and WoWTools_Mixin:MK(Save().autoSaveMoney, 3)..'|A:Coin-Gold:0:0|a'
                or WoWTools_TextMixin:GetEnabeleDisable(false)
            )
        )

        GameTooltip:AddLine(
            WoWTools_DataMixin.Icon.Player
            ..(WoWTools_DataMixin.onlyChinese and '过滤' or CALENDAR_FILTERS)
            ..': '..WoWTools_TextMixin:GetYesNo(Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID])
        )
        if not Can_DepositMoney() then
            GameTooltip_AddErrorLine(GameTooltip,
                WoWTools_TextMixin:CN(BankPanelLockPromptMixin:GetBankLockedMessage()),
                true
            )
        end
        GameTooltip:Show()
    end
    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)

    btn:SetupMenu(Init_Menu)

    function btn:settings()
        local autoSaveMoney
        if Can_DepositMoney() and not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] then
            autoSaveMoney= Save().autoSaveMoney
        end
        --local icon= self:GetNormalTexture()
        self.texture:SetAlpha(autoSaveMoney and 1 or 0.5)
        self.texture:SetDesaturated(not autoSaveMoney and true or false)
        self.Text:SetText(autoSaveMoney and '|cff00ccff'..WoWTools_Mixin:MK(autoSaveMoney, 3) or '')
    end

    hooksecurefunc(BankPanel.MoneyFrame.DepositButton, 'Refresh', function()
        btn:settings()
    end)
    BankFrame:HookScript('OnShow', function()
        Auto_Save_Money()
    end)

    Init=function()end
end

function WoWTools_BankMixin:Init_Money_Plus()
    Init()
end