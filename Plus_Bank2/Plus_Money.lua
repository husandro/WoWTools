
if BankFrameTab2 then
    return
end

local function Save()
    return WoWToolsSave['Plus_Bank2']
end













local function Auto_Save_Money()
    local autoSaveMoney= Save().autoSaveMoney

    if not autoSaveMoney
        or not C_Bank.CanDepositMoney(Enum.BankType.Account)
        or Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID]
    then
        return
    end

    local saveMoney= GetMoney()- autoSaveMoney*10000
    if saveMoney<=0 then
        return
    end

    C_Bank.DepositMoney(Enum.BankType.Account, saveMoney)
end





local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub
    if not C_Bank.CanDepositMoney(Enum.BankType.Account) then
        sub=root:CreateTitle(WoWTools_DataMixin.onlyChinese and '锁定' or LOCKED)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_TextMixin:CN(C_Bank.FetchBankLockedReason(Enum.BankType.Account)))
        end)
        return
    end

    root:CreateButton(
        ((Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] or not Save().autoSaveMoney) and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '存放' or BANK_DEPOSIT_MONEY_BUTTON_LABEL),
    function()
        Auto_Save_Money()
        return MenuResponse.Open
    end)


    local autoSaveMoney= Save().autoSaveMoney
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动存钱' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, BANK_DEPOSIT_MONEY_BUTTON_LABEL),
    function()
        return Save().autoSaveMoney
    end, function()
        Save().autoSaveMoney= not Save().autoSaveMoney and (autoSaveMoney or 500) or nil
        self:settings()
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().autoSaveMoney or 500
        end, setValue=function(value)
            Save().autoSaveMoney=value
            self:settings()
        end,
        name=
            (WoWTools_DataMixin.onlyChinese and '存钱' or BANK_DEPOSIT_MONEY_BUTTON_LABEL)
            ..'|A:Coin-Gold:0:0|a |cnGREEN_FONT_COLOR:>',
        minValue=50,
        maxValue=10000,
        step=50,
        bit=nil,
    })

--过滤器
    local num=0
    for _ in pairs(Save().filterSaveMoney) do
        num= num+1
    end
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '过滤器' or FILTER)..' |cnGREEN_FONT_COLOR:#'..num,
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

    WoWTools_MenuMixin:SetScrollMode(sub)

    sub:CreateDivider()
    root:CreateCheckbox(
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
    end)

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
    function()
        for _ in pairs(Save().filterSaveMoney) do
            return false
        end
        return true
    end, function()
        Save().filterSaveMoney={}
    end)

EVENTTRACE_BUTTON_DISABLE_FILTERS = "撤选所有";
EVENTTRACE_BUTTON_DISCARD_FILTER = "丢弃所有";
EVENTTRACE_BUTTON_ENABLE_FILTERS = "勾选所有";
end
--[[
EVENTTRACE_BUTTON_DISABLE_FILTERS = "撤选所有";
EVENTTRACE_BUTTON_DISCARD_FILTER = "丢弃所有";
EVENTTRACE_BUTTON_ENABLE_FILTERS = "勾选所有";
]]






local function Init()
    local btn= WoWTools_ButtonMixin:Menu(BankPanel.MoneyFrame, {
        size=23,
        --icon='hide',
        --addTexture=true,
        atlas='BonusLoot-Chest',
    })

    btn:SetPoint('RIGHT', BankPanel.MoneyFrame.MoneyDisplay, 'LEFT', -8, 0)
    
    btn.Text= WoWTools_LabelMixin:Create(btn, {color={r=0,g=0.8,b=1}})
    btn.Text:SetPoint('RIGHT', btn, 'LEFT')

    function btn:settings()
        local autoSaveMoney= not Save().filterSaveMoney[WoWTools_DataMixin.Player.GUID] and Save().autoSaveMoney
        local icon= self:GetNormalTexture()
        icon:SetAlpha(autoSaveMoney and 1 or 0.5)
        icon:SetDesaturated(not autoSaveMoney and true or false)
        self.Text:SetText(autoSaveMoney and WoWTools_Mixin:MK(autoSaveMoney, 3) or '')
    end

    btn:SetupMenu(Init_Menu)
    btn:settings()

    BankFrame:HookScript('OnShow', function()
        Auto_Save_Money()
    end)

    Init=function()end
end

function WoWTools_BankMixin:Init_Money_Plus()
    Init()
end