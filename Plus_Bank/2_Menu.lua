local e= select(2, ...)
local function Save()
    return WoWTools_BankMixin.Save
end














--#######
--设置菜单
--#######
local function Init_Menu(self, root)
    local sub, sub2
    local isBank, _, isAccount= WoWTools_BankMixin:GetActive()

--自动打开背包栏位
    sub=root:CreateCheckbox(
        e.onlyChinese and '自动打开背包栏位' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, UNWRAP, BAGSLOTTEXT)),
    function()
        return Save().openBagInBank
    end, function()
        Save().openBagInBank= not Save().openBagInBank and true or nil
        self:set_event()
    end)
    if _G['NDui_BackpackBank'] then
        sub:SetTooltip(function(tooltip)
            GameTooltip_AddErrorLine(tooltip, 'Bub: NDui')
        end)
        sub:SetEnabled(false)
    else
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '跟背包插件冲突' or format(ALREADY_BOUND, 'Backpack Addon'))
        end)
    end

--索引
    root:CreateCheckbox(e.onlyChinese and '索引' or 'Index', function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or nil--显示，索引
        WoWTools_BagMixin:CloseBag(nil, true)
        WoWTools_BankMixin:Init_Plus()
    end)

--显示背景
    root:CreateCheckbox(
        e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND,
    function()
        return Save().showBackground
    end, function()
        Save().showBackground= not Save().showBackground and true or nil
        WoWTools_BankMixin:Set_Background_Texture(BankFrame.Background)
        WoWTools_BankMixin:Set_Background_Texture(AccountBankPanel.Background)
        WoWTools_BankMixin:Init_Left_List()
    end)

--左边列表
    sub=root:CreateCheckbox(e.onlyChinese and '物品列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, TYPE), function()
        return Save().left_List
    end, function()
        Save().left_List= not Save().left_List and true or nil
        WoWTools_BankMixin:Init_Left_List()--分类，存取,
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine('ItemClassID List')
    end)

--CVar
    sub=root:CreateButton('CVar', function() return MenuResponse.Open end)

    for _, info in pairs({
        {name='bankConfirmTabCleanUp',
        text=e.onlyChinese and '清理战团银行' or BAG_CLEANUP_ACCOUNT_BANK,
        tooltip=function(tooltip, desc)
            tooltip:AddLine(desc.data.name)
            tooltip:AddLine(' ')
            tooltip:AddLine(e.onlyChinese and '确认清理战团银行' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, RPE_CONFIRM, BAG_CLEANUP_ACCOUNT_BANK))
            tooltip:AddLine(e.onlyChinese and "你确定要自动整理你的物品吗？|n该操作会影响所有的战团标签。" or ACCOUNT_BANK_CONFIRM_CLEANUP_PROMPT)
        end,
        func=nil},
        {name='bankAutoDepositReagents',
        text=e.onlyChinese and '包括可交易的材料' or BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL,
        tooltip=function(tooltip, desc)
            tooltip:AddLine(desc.data.name)
            tooltip:AddLine(' ')
            tooltip:AddLine(e.onlyChinese and '战团银行' or ACCOUNT_BANK_PANEL_TITLE)
            tooltip:AddLine(e.onlyChinese and '存放: 包括可交易的材料' or (BANK_DEPOSIT_MONEY_BUTTON_LABEL..': '..BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL))
        end,
        func=function()
            local check= AccountBankPanel.ItemDepositFrame.IncludeReagentsCheckbox
            if check:IsShown() then
                check:Hide()
                check:Show()
                if AccountBankPanel.ItemDepositFrame.DepositButton.set_text then
                    AccountBankPanel.ItemDepositFrame.DepositButton:set_text()
                end
            end
        end},
    }) do

        sub2=sub:CreateCheckbox(
            (InCombatLockdown() and '|cff828282' or '')
            ..(info.text or info.name),
        function(data)
            return C_CVar.GetCVarBool(data.name)
        end, function(data)
            if InCombatLockdown() then
                print(WoWTools_Mixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            else
                C_CVar.SetCVar(data.name, C_CVar.GetCVarBool(data.name) and '0' or '1')
                if data.func then
                    data.func()
                end
            end
        end, {name=info.name, func=info.func})
        sub2:SetTooltip(info.tooltip)
    end


    local function settings(desc, type)
        desc:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED)
        end)
        desc:SetEnabled(type)
    end
    
--银行
    root:CreateTitle(e.onlyChinese and '银行' or BANK)
    --sub= root:CreateButton(e.onlyChinese and '银行' or BANK, function() return MenuResponse.Open end)

--银行背包
    sub=root:CreateCheckbox(
        '1 '..(e.onlyChinese and '银行背包' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BANK, BAGSLOT)),
    function()
        return not Save().disabledBankBag
    end, function()
        Save().disabledBankBag= not Save().disabledBankBag and true or nil
        WoWTools_BagMixin:CloseBag(nil, true)
        if not Save().disabledBankBag then
            WoWTools_BagMixin:OpenBag(nil, true)
        end
        WoWTools_BankMixin:Init_Plus()
        WoWTools_BankMixin:Set_PortraitButton()
    end)
    settings(sub, isBank)

--材料银行
    sub=root:CreateCheckbox(
        '2 '..(e.onlyChinese and '材料银行' or REAGENT_BANK),
    function()
        return not Save().disabledReagentFrame
    end, function()
        Save().disabledReagentFrame= not Save().disabledReagentFrame and true or nil
        ReagentBankFrame:SetShown(false)
        WoWTools_BankMixin:Init_Plus()
    end)
    settings(sub, isBank)



--战团银行
    sub=root:CreateCheckbox(
        '3 '..(e.onlyChinese and '战团银行' or ACCOUNT_BANK_PANEL_TITLE),
    function()
        return not Save().disabledAccountBag
    end, function()
        Save().disabledAccountBag= not Save().disabledAccountBag and true or nil
        AccountBankPanel:SetShown(false)
        WoWTools_BankMixin:Init_Plus()
    end)
    settings(sub, isBank)


--战团银行,整合
    root:CreateTitle(e.onlyChinese and '战团银行' or ACCOUNT_BANK_PANEL_TITLE)
    sub= root:CreateCheckbox(
        e.onlyChinese and '战团银行' or ACCOUNT_BANK_PANEL_TITLE,
    function()
        return Save().allAccountBag
    end, function()
        Save().allAccountBag= not Save().allAccountBag and true or nil
        
        e.call(BankFrame_ShowPanel, AccountBankPanel, (BANK_PANELS[3].name))--缩放按钮， 需要
        AccountBankPanel:GenerateItemSlotsForSelectedTab()
        WoWTools_BankMixin:Init_Plus()
    end)
    settings(sub, isAccount)

--行数

root:CreateDivider()
    root:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().num
        end, setValue=function(value)
            Save().num=value
            WoWTools_BankMixin:Init_Plus()
        end,
        name=e.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=4,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub:SetEnabled(isBank or isAccount)

--间隔
    root:CreateSpacer()
    sub=WoWTools_MenuMixin:CreateSlider(root, {
        getValue=function()
            return Save().line
        end, setValue=function(value)
            Save().line=value
            WoWTools_BankMixin:Init_Plus()
        end,
        name=e.onlyChinese and '间隔' or 'Interval',
        minValue=0,
        maxValue=32,
        step=1,
        bit=nil,
    })
    sub:SetEnabled(isBank or isAccount)
    root:CreateSpacer()

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName})
    WoWTools_MenuMixin:Reload(sub, false)
end














local function Init()
    local OptionButton= WoWTools_ButtonMixin:Menu(BankFrameCloseButton, {name='WoWTools_BankFrameMenuButton'})
    OptionButton:SetPoint('RIGHT', BankFrameCloseButton, 'LEFT', -2,0)

    function OptionButton:Open_Bag()
        do
            WoWTools_BagMixin:OpenBag(nil, true)
        end
        BankFrame:Raise()
    end
    OptionButton:SetupMenu(Init_Menu)


    OptionButton:SetScript('OnLeave', GameTooltip_Hide)
    OptionButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        e.tips:Show()
    end)

    function OptionButton:set_event()
        if Save().openBagInBank then
            self:RegisterEvent('BANKFRAME_OPENED')
        else
            self:UnregisterEvent('BANKFRAME_OPENED')
        end
    end
    OptionButton:SetScript('OnEvent', OptionButton.Open_Bag)
    OptionButton:set_event()

   if Save().openBagInBank then
        OptionButton:Open_Bag()
   end




--钱    
    BankFrameMoneyFrameBorder:Hide()
    BankFrameMoneyFrame:ClearAllPoints()
    if IsReagentBankUnlocked() then
        BankFrameMoneyFrame:SetPoint('RIGHT', OptionButton, 'LEFT')
    else
        BankFrameMoneyFrame:SetPoint('BOTTOM', BankFrame, 'TOP')
        WoWTools_TextureMixin:CreateBackground(BankFrameMoneyFrame, {isAllPoint=true})
    end
    BankFrameMoneyFrame:SetFrameStrata(OptionButton:GetFrameStrata())
    BankFrameMoneyFrame:SetFrameLevel(OptionButton:GetFrameLevel()+1)

    BankFrameMoneyFrameGoldButton:HookScript("OnLeave", ResetCursor)
    BankFrameMoneyFrameGoldButton:HookScript('OnEnter', function()
        SetCursor('Interface\\Cursor\\Cast.blp')--Redlist.xml
    end)

    BankFrameMoneyFrameSilverButton:HookScript("OnLeave", ResetCursor)
    BankFrameMoneyFrameSilverButton:HookScript('OnEnter', function()
        SetCursor('Interface\\Cursor\\Cast.blp')--Redlist.xml
    end)

    BankFrameMoneyFrameCopperButton:HookScript("OnLeave", ResetCursor)
    BankFrameMoneyFrameCopperButton:HookScript('OnEnter', function()
        SetCursor('Interface\\Cursor\\Cast.blp')--Redlist.xml
    end)
end


function WoWTools_BankMixin:Init_Menu()
    Init()
end
