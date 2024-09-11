
local e= select(2, ...)

local function Save()
    return WoWTools_SellBuyMixin.Save
end


local function Init_Menu(self, root)
    local sub, sub2, num

--自动出售垃圾
    sub=root:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '自动出售垃圾' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SELL_ALL_JUNK_ITEMS_EXCLUDE_HEADER)),
    function()
        return not Save().notSellJunk
    end, function()
        Save().notSellJunk= not Save().notSellJunk and true or nil
        if _G['WoWTools_AutoSellJunkCheck'] then
            _G['WoWTools_AutoSellJunkCheck']:settings()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '品质：|cff9e9e9e粗糙' or format(PROFESSIONS_CRAFTING_QUALITY, '|cff9e9e9e'..ITEM_QUALITY0_DESC))
        tooltip:AddLine(e.onlyChinese and '备注：在战斗中无法出售物品' or (NOTE_COLON..': '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)))
    end)







--出售自定义
    num=0
    for _ in pairs(Save().Sell) do
        num=num+1
    end
    sub=root:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'
        ..(e.onlyChinese and '出售自定义' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, CUSTOM))
        ..(num==0 and '|cff9e9e9e' or '')
        ..' #'..num,
    function()
        return not Save().notSellCustom
    end, function()
        Save().notSellCustom= not Save().notSellCustom and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '备注：在战斗中无法出售物品' or (NOTE_COLON..': '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)))
    end)

--列表
    num=0
    for itemID in pairs(Save().Sell) do
        num=num+1
        sub2=sub:CreateCheckbox(
            num..') '..WoWTools_ItemMixin:GetName(itemID),
        function(data)
            return Save().Sell[data.itemID]
        end, function(data)
            Save().Sell[data.itemID]= not Save().Sell[data.itemID] and true or nil
        end, {itemID=itemID})
        WoWTools_TooltipMixin:SetTooltip(nil, nil, sub2, nil)
    end
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            Save().Sell={}
        end)
    end
    WoWTools_MenuMixin:SetNumButton(sub, num)









--出售BOSS掉落
    num=0
    for _ in pairs(Save().bossItems) do
        num=num+1
    end

    sub=root:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'
        ..(e.onlyChinese and '出售首领掉落' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB,TRANSMOG_SOURCE_1))
        ..(num==0 and '|cff9e9e9e' or '')
        ..' #'..num,
    function()
        return not Save().notSellBoss
    end, function()
        Save().notSellBoss= not Save().notSellBoss and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        local avgItemLevel= (GetAverageItemLevel() or 60)- 30
        tooltip:AddLine((e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)..' < ' ..math.ceil(avgItemLevel))
        tooltip:AddLine(e.onlyChinese and '备注：在战斗中无法出售物品' or (NOTE_COLON..': '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)))
    end)
    sub:SetEnabled(not e.Is_Timerunning)

    num=0
    for itemLink, itemLevel in pairs(Save().bossItems) do
        num=num+1
        local itemID= WoWTools_ItemMixin:GetItemID(itemLink)
        e.LoadData({id=itemID, type='item', itemLink=itemLink})
        sub2=sub:CreateCheckbox(
            num..') '
            ..'|T'..(C_Item.GetItemIconByID(itemLink) or 0)..':0|t'
            ..itemLink
            ..('['..itemLevel..']'),
        function(data)
            return Save().bossItems[data.itemLink]
        end, function(data)
            Save().bossItems[data.itemLink]= not Save().bossItems[data.itemLink] and true or nil
        end, {itemID=itemID, itemLink=itemLink})
        WoWTools_TooltipMixin:SetTooltip(nil, nil, sub2, nil)
    end
    sub:CreateDivider()
    if num>1 then
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            Save().bossItems={}
        end)
    end
    WoWTools_MenuMixin:SetNumButton(sub, num)

--保存 BOSS列表    
    sub:CreateCheckbox(
        e.onlyChinese and '保存' or SAVE,
    function()
        return Save().saveBossLootList
    end, function()
        Save().saveBossLootList = not Save().saveBossLootList and true or nil
    end)
    

    num=''
    if _G['WoWTools_BuybackButton'] then
        num= _G['WoWTools_BuybackButton']:set_text()--回购，数量，提示
    end
--回购
    sub=root:CreateButton(
        '    |A:common-icon-undo:0:0|a'..(e.onlyChinese and '回购' or BUYBACK)..'|cnGREEN_FONT_COLOR: #'..(num or '')..'|r',
    function()
       return MenuResponse.Open 
    end)

--列表，回购
    num=0
    for itemID in pairs(Save().noSell) do
        num= num+1
        e.LoadData({id=itemID, type='item'})
        local bag=C_Item.GetItemCount(itemID)
        local bank=C_Item.GetItemCount(itemID, true, false, true, true)-bag
        local itemName= WoWTools_ItemMixin:GetName(itemID)
        sub2= sub:CreateCheckbox(
            itemName..' '..'|cnYELLOW_FONT_COLOR:'..bag..'|A:bag-main:0:0|a'..bank..'|A:Banker:0:0|a'..'|r',
        function(data)
            return Save().noSell[data.itemID]
        end, function(data)
            Save().noSell[data.itemID]=not Save().noSell[data.itemID] and true or nil
            local btn= _G['WoWTools_BuybackButton']
            if btn then
                btn:set_text()--回购，数量，提示
            end
        end, {itemID=itemID})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)           
        end)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            Save().noSell={}
        end)
    end
    WoWTools_MenuMixin:SetNumButton(sub, num)
    

--购买物品
    num=''
    if _G['WoWTools_BuyItemButton'] then
        num= _G['WoWTools_BuyItemButton']:set_text()--回购，数量，提示
    end
    sub=root:CreateCheckbox(
        '|T236994:0|t'..(e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..'|cnGREEN_FONT_COLOR: #'..(num or '')..'|r',
    function()
        return not Save().notAutoBuy
    end, function()
        Save().notAutoBuy= not Save().notAutoBuy and true or nil
        WoWTools_SellBuyMixin:Set_Merchant_Info()--设置, 提示, 信息
        if _G['WoWTools_BuyItemButton'] then
            _G['WoWTools_BuyItemButton']:set_text()--回购，数量，提示
        end
    end)


--列表，购买
    num=0
    for itemID, numItem in pairs(Save().buyItems[e.Player.guid] or {}) do
        num=num+1
        local bag=C_Item.GetItemCount(itemID)
        local bank=C_Item.GetItemCount(itemID, true, false, true, true)-bag
        local itemName= WoWTools_ItemMixin:GetName(itemID)
        sub2=sub:CreateCheckbox(
            '|cnGREEN_FONT_COLOR:'..numItem..'|r '..itemName..' '..'|cnYELLOW_FONT_COLOR:'..bag..'|A:bag-main:0:0|a'..bank..'|A:Banker:0:0|a'..'|r',
        function(data)
            return Save().buyItems[e.Player.guid][data.itemID]
        end, function(data)
            Save().buyItems[e.Player.guid][data.itemID]=not Save().buyItems[e.Player.guid][data.itemID] and true or nil
            WoWTools_SellBuyMixin:Set_Merchant_Info()--设置, 提示, 信息
            local btn= _G['WoWTools_BuybackButton']
            if btn then
                btn:set_text()--回购，数量，提示
            end
        end, {itemID=itemID})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '移除' or REMOVE)
        end)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            Save().buyItems[e.Player.guid]={}
            WoWTools_SellBuyMixin:Set_Merchant_Info()--设置, 提示, 信息
            local btn= _G['WoWTools_BuybackButton']
            if btn then
                btn:set_text()--回购，数量，提示
            end
        end)
    end
    WoWTools_MenuMixin:SetNumButton(sub, num)


--自动修理
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|A:SpellIcon-256x256-RepairAll:0:0|a'..(e.onlyChinese and '自动修理所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REPAIR_ALL_ITEMS)),
    function()
        return not Save().notAutoRepairAll
    end, function()
        Save().notAutoRepairAll= not Save().notAutoRepairAll and true or nil
        local chek= _G['WoWTools_AutoRepairCheck']
        if chek then
            chek:set_repair_all()
            chek:SetChecked(not Save().notAutoRepairAll)
        end
    end)
    sub:CreateTitle((e.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR)..': '..Save().repairItems.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
    sub:CreateTitle((e.onlyChinese and '公会' or GUILD)..': '..C_CurrencyInfo.GetCoinTextureString(Save().repairItems.guild))
    sub:CreateTitle((e.onlyChinese and '玩家' or PLAYER)..': '..C_CurrencyInfo.GetCoinTextureString(Save().repairItems.player))    
    if Save().repairItems.guild>0 and Save().repairItems.player>0 then
        sub:CreateDivider()
        sub:CreateTitle((e.onlyChinese and '合计' or TOTAL)..': '..C_CurrencyInfo.GetCoinTextureString(Save().repairItems.guild+Save().repairItems.player))
    end
    sub:CreateDivider()
    sub:CreateTitle((e.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP)..': '..C_CurrencyInfo.GetCoinTextureString(CanGuildBankRepair() and GetGuildBankMoney() or 0))


--商人 Plus
    root:CreateDivider()
    root:CreateCheckbox(
        '|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '商人 Plus' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MERCHANT, 'Plus')),
    function()
        return not Save().notPlus
    end, function()
        Save().notPlus = not Save().notPlus and true or nil
        print(e.addName, WoWTools_SellBuyMixin.addName, '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)


--删除字符
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '自动输入DELETE' or (RUNECARVER_SCRAPPING_CONFIRMATION_TEXT..': '..DELETE_ITEM_CONFIRM_STRING)),
    function()
        return not Save().notDELETE
    end, function()
        Save().notDELETE= not Save().notDELETE and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(
            e.onlyChinese and '你真的要摧毁%s吗？|n|n请在输入框中输入 DELETE 以确认。'
            or DELETE_GOOD_ITEM
        )
    end)


--自动拾取 plus
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus',
    function()
        return not Save().notAutoLootPlus
    end, function()
        Save().notAutoLootPlus= not Save().notAutoLootPlus and true or nil
        print(e.addName, WoWTools_SellBuyMixin.addName, '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '自动拾取' or AUTO_LOOT_DEFAULT_TEXT, e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
        tooltip:AddLine(' ')
        tooltip:AddLine(
            e.onlyChinese and '拾取窗口 Shift: 禁用'
            or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_LOOT_FRAME_LABEL, 'Shift: ')..DISABLE)
        )
        tooltip:AddLine(e.onlyChinese and '不在战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT)
    end)

    
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_SellBuyMixin.addName})
end



--[[

local function Ini(_, level, type)



 

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    local text=	(e.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR)..': '..Save().repairItems.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
                ..'|n'..(e.onlyChinese and '公会' or GUILD)..': '..C_CurrencyInfo.GetCoinTextureString(Save().repairItems.guild)
                ..'|n'..(e.onlyChinese and '玩家' or PLAYER)..': '..C_CurrencyInfo.GetCoinTextureString(Save().repairItems.player)
    if Save().repairItems.guild>0 and Save().repairItems.player>0 then
        text=text..'|n|n'..(e.onlyChinese and '合计' or TOTAL)..': '..C_CurrencyInfo.GetCoinTextureString(Save().repairItems.guild+Save().repairItems.player)
    end
    text=text..'|n|n'..(e.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP)..'|n'..C_CurrencyInfo.GetCoinTextureString(CanGuildBankRepair() and GetGuildBankMoney() or 0)

    info={--自动修理
        text= '|A:SpellIcon-256x256-RepairAll:0:0|a'..(e.onlyChinese and '自动修理所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REPAIR_ALL_ITEMS)),
        checked=not Save().notAutoRepairAll,
        keepShownOnClick=true,
        func=function()
            Save().notAutoRepairAll= not Save().notAutoRepairAll and true or nil
            local chek= _G['WoWTools_AutoRepairCheck']
            if chek then
                chek:set_repair_all()
                chek:SetChecked(not Save().notAutoRepairAll)
            end
        end,
        tooltipOnButton=true,
        tooltipTitle= '|cffff00ff'..(e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER).. '|r '..Save().repairItems.date,
        tooltipText=text,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    info= {--商人 Plus
        text= '|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '商人 Plus' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MERCHANT, 'Plus')),
        checked= not Save().notPlus,
        keepShownOnClick=true,
        func=function ()
            Save().notPlus = not Save().notPlus and true or nil
            print(e.addName, WoWTools_SellBuyMixin.addName, '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--删除字符
        text= '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '自动输入DELETE' or (RUNECARVER_SCRAPPING_CONFIRMATION_TEXT..': '..DELETE_ITEM_CONFIRM_STRING)),
        checked= not Save().notDELETE,
        keepShownOnClick=true,
        func=function ()
            Save().notDELETE= not Save().notDELETE and true or nil
        end,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '你真的要摧毁%s吗？|n|n请在输入框中输入 DELETE 以确认。' or DELETE_GOOD_ITEM,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    info={
        text= '|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus',
        checked= not Save().notAutoLootPlus,
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle=(not e.onlyChinese and AUTO_LOOT_DEFAULT_TEXT..', '..REFORGE_CURRENT or '自动拾取, 当前: ')..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")),
        tooltipText= (not e.onlyChinese and HUD_EDIT_MODE_LOOT_FRAME_LABEL..'Shift: '..DISABLE or '拾取窗口 Shift: 禁用')..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '不在战斗中' or 'not in combat'),
        func= function()
            Save().notAutoLootPlus= not Save().notAutoLootPlus and true or nil
            print(e.addName, WoWTools_SellBuyMixin.addName, '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end

    }
    e.LibDD:UIDropDownMenu_AddButton(info)
    info={
        text= '    |A:SpellIcon-256x256-SellJunk:0:0|a'..(e.onlyChinese and '选项' or OPTIONS),
        notCheckable=true,
        func= function()
            e.OpenPanelOpting(nil, WoWTools_SellBuyMixin.addName)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info)
end


]]




function WoWTools_SellBuyMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end