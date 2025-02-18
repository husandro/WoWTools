local e= select(2, ...)
local function Save()
    return WoWTools_BankMixin.Save
end














--#######
--设置菜单
--#######
local function Init_Menu(self, root)
    local sub


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


--整合

--索引

    root:CreateCheckbox(e.onlyChinese and '索引' or 'Index', function()
        return Save().showIndex
    end, function()
        Save().showIndex= not Save().showIndex and true or nil--显示，索引
        WoWTools_BankMixin:CloseBag()
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
    end)


    local isEnabled= BankFrame.activeTabIndex==1


    root:CreateTitle(e.onlyChinese and '银行' or BANK)

--材料银行
    sub=root:CreateCheckbox(
        e.onlyChinese and '材料银行' or REAGENT_BANK,
    function()
        return not Save().disabledReagentFrame
    end, function()
        Save().disabledReagentFrame= not Save().disabledReagentFrame and true or nil
        WoWTools_BankMixin:Init_Plus()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '转化为联合的大包' or BAG_COMMAND_CONVERT_TO_COMBINED)
    end)
    sub:SetEnabled(isEnabled)

--行数
    sub=root:CreateCheckbox(e.onlyChinese and '左边列表' or 'Left List', function()
        return Save().left_List
    end, function()
        Save().left_List= not Save().left_List and true or nil
        WoWTools_BankMixin:Init_Left_List()--分类，存取,
    end)
    sub:SetEnabled(isEnabled)

--行数
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
    sub:SetEnabled(isEnabled)

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
    sub:SetEnabled(isEnabled)
    root:CreateSpacer()

    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_BankMixin.addName})
    WoWTools_MenuMixin:Reload(sub, false)
end




local function Init()
    OptionButton= WoWTools_ButtonMixin:CreateMenu(BankFrameCloseButton, {name='WoWTools_BankFrameMenuButton'})
    OptionButton:SetPoint('RIGHT', BankFrameCloseButton, 'LEFT', -2,0)

    function OptionButton:Open_Bag()
        do
            WoWTools_BankMixin:OpenBag()
        end
        WoWTools_BankMixin:Init_Plus()
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








end


function WoWTools_BankMixin:Init_Menu()
    Init()
end
