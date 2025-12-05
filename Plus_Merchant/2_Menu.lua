local function Save()
    return WoWToolsSave['Plus_SellBuy']
end
local function RepairSave()
    return WoWToolsPlayerDate['RepairMoney']
end








--显示背景
--[[local function Set_ShowBackground()
    local alpha= Save().bgAlpha or 0.5
    WoWTools_ColorMixin:Setup(MerchantFrameBg, {type='Texture', alpha=alpha})
    MerchantFrameBg:SetAlpha(alpha)
    WoWTools_ColorMixin:Setup(MerchantFrameInset.Bg, {type='Texture', alpha=alpha})
end]]









--出售自定义
local function Player_Sell_Menu(_, root)
    local num, sub, sub2
    num=0
    for _ in pairs(WoWToolsPlayerDate['SellBuyItems'].sell) do
        num=num+1
    end
    sub=root:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '出售自定义' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, CUSTOM))
        ..(num==0 and '|cff626262' or '')
        ..' #'..num,
    function()
        return not Save().notSellCustom
    end, function()
        Save().notSellCustom= not Save().notSellCustom and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '备注：在战斗中无法出售物品' or (NOTE_COLON..': '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)))
    end)

    --列表, 出售自定义
    num=0
    for itemID in pairs(WoWToolsPlayerDate['SellBuyItems'].sell) do
        num=num+1
        sub2=sub:CreateCheckbox(
            num..') '..WoWTools_ItemMixin:GetName(itemID),
        function(data)
            return WoWToolsPlayerDate['SellBuyItems'].sell[data.itemID]
        end, function(data)
            WoWToolsPlayerDate['SellBuyItems'].sell[data.itemID]= not WoWToolsPlayerDate['SellBuyItems'].sell[data.itemID] and true or nil
        end, {itemID=itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
            nil,
            {SetValue=function()
                WoWToolsPlayerDate['SellBuyItems'].sell={}
            end})
            return MenuResponse.Open
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end
end













--回购
local function Buyback_Menu(_, root)
    local num, sub, sub2
    num=''
    if _G['WoWTools_BuybackButton'] then
        num= _G['WoWTools_BuybackButton']:set_text()--回购，数量，提示
    end
    sub=root:CreateButton(
        '    |A:common-icon-undo:0:0|a'..(WoWTools_DataMixin.onlyChinese and '回购' or BUYBACK)..'|cnGREEN_FONT_COLOR: #'..(num or '')..'|r',
    function()
       return MenuResponse.Open
    end)

--列表，回购
    num=0
    for itemID in pairs(WoWToolsPlayerDate['SellBuyItems'].noSell) do
        num= num+1
       WoWTools_DataMixin:Load(itemID, 'item')
        local itemName= WoWTools_ItemMixin:GetName(itemID)
        sub2= sub:CreateCheckbox(
            itemName,
        function(data)
            return WoWToolsPlayerDate['SellBuyItems'].noSell[data.itemID]
        end, function(data)
            WoWToolsPlayerDate['SellBuyItems'].noSell[data.itemID]=not WoWToolsPlayerDate['SellBuyItems'].noSell[data.itemID] and true or nil
            local btn= _G['WoWTools_BuybackButton']
            if btn then
                btn:set_text()--回购，数量，提示
            end
        end, {itemID=itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
            nil,
            {SetValue=function()
               WoWToolsPlayerDate['SellBuyItems'].noSell={}
            end})
            return MenuResponse.Open
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end
end




















--购买物品
local function BuyItem_Menu(_, root)
    local num, sub, sub2
    num=''
    if _G['WoWTools_BuyItemButton'] then
        num= _G['WoWTools_BuyItemButton']:set_text()--回购，数量，提示
    end
    sub=root:CreateCheckbox(
        '|A:Perks-ShoppingCart:0:0|a'..(WoWTools_DataMixin.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..'|cnGREEN_FONT_COLOR: #'..(num or '')..'|r',
    function()
        return not Save().notAutoBuy
    end, function()
        Save().notAutoBuy= not Save().notAutoBuy and true or nil
        WoWTools_MerchantMixin:Update_MerchantFrame()
        if _G['WoWTools_BuyItemButton'] then
            _G['WoWTools_BuyItemButton']:set_text()--回购，数量，提示
        end
    end)


    --列表，购买
    local guid= WoWTools_DataMixin.Player.GUID
    num=0
    for itemID, numItem in pairs(WoWToolsPlayerDate['SellBuyItems'].buy[guid]) do
        num=num+1
        local itemName= WoWTools_ItemMixin:GetName(itemID)
        sub2=sub:CreateCheckbox(
            '|cnGREEN_FONT_COLOR:'..numItem..'|r '..itemName,
        function(data)
            return WoWToolsPlayerDate['SellBuyItems'].buy[guid][data.itemID]
        end, function(data)
            WoWToolsPlayerDate['SellBuyItems'].buy[guid][data.itemID]=not WoWToolsPlayerDate['SellBuyItems'].buy[guid][data.itemID] and data.num or nil
           WoWTools_MerchantMixin:Update_MerchantFrame()
            local btn= _G['WoWTools_BuybackButton']
            if btn then
                btn:set_text()--回购，数量，提示
            end
        end, {itemID=itemID, num= WoWToolsPlayerDate['SellBuyItems'].buy[guid][itemID] or 1})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end

    if num>1 then
        sub:CreateDivider()
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
            nil,
            {SetValue=function()
                WoWToolsPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID]={}
                WoWTools_MerchantMixin:Update_MerchantFrame()
                local btn= _G['WoWTools_BuybackButton']
                if btn then
                    btn:set_text()--回购，数量，提示
                end
            end})
            return MenuResponse.Open
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end
end






















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    
    local sub, sub2, num

--自动出售垃圾
    sub=root:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '自动出售垃圾' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SELL_ALL_JUNK_ITEMS_EXCLUDE_HEADER)),
    function()
        return not Save().notSellJunk
    end, function()
        Save().notSellJunk= not Save().notSellJunk and true or nil
        if _G['WoWTools_AutoSellJunkCheck'] then
            _G['WoWTools_AutoSellJunkCheck']:settings()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '品质：|cff626262粗糙' or format(PROFESSIONS_CRAFTING_QUALITY, '|cff626262'..ITEM_QUALITY0_DESC))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '备注：在战斗中无法出售物品' or (NOTE_COLON..': '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)))
    end)








--出售自定义
    Player_Sell_Menu(self, root)





--出售BOSS掉落
    num=0
    for _ in pairs(Save().bossItems) do
        num=num+1
    end

    sub=root:CreateCheckbox(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '出售首领掉落' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB,TRANSMOG_SOURCE_1))
        ..(num==0 and '|cff626262' or '')
        ..' #'..num,
    function()
        return not Save().notSellBoss
    end, function()
        Save().notSellBoss= not Save().notSellBoss and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        local avgItemLevel= (GetAverageItemLevel() or 60)- 30
        tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)..' < ' ..math.ceil(avgItemLevel))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '备注：在战斗中无法出售物品' or (NOTE_COLON..': '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)))
    end)

    num=0
    for itemLink, itemLevel in pairs(Save().bossItems) do
        num=num+1
        local itemID= WoWTools_ItemMixin:GetItemID(itemLink)
       WoWTools_DataMixin:Load(itemLink or itemID, 'item')
        sub2=sub:CreateCheckbox(
            num..') '
            ..'|T'..(select(5, C_Item.GetItemInfoInstant(itemLink)) or 0)..':0|t'
            ..itemLink
            ..('['..itemLevel..']'),
        function(data)
            return Save().bossItems[data.itemLink]
        end, function(data)
            Save().bossItems[data.itemLink]= not Save().bossItems[data.itemLink] and true or nil
        end, {itemID=itemID, itemLink=itemLink})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
    end
    sub:CreateDivider()
    if num>1 then
        sub:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
            nil,
            {SetValue=function()
                Save().bossItems={}
            end})
            return MenuResponse.Open
        end)
        WoWTools_MenuMixin:SetScrollMode(sub)
    end

--保存 BOSS列表    
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '保存' or SAVE,
    function()
        return Save().saveBossLootList
    end, function()
        Save().saveBossLootList = not Save().saveBossLootList and true or nil
    end)

--[[添加 按钮菜单
    sub2= sub:CreateCheckbox(
        '|A:Perks-ShoppingCart:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '按钮菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, HUD_EDIT_MODE_MICRO_MENU_LABEL),
    function()
        return Save().addButtonMenu
    end, function()
        Save().addButtonMenu= not Save().addButtonMenu and true or nil
    end)]]
    


--回购
    root:CreateDivider()
    Buyback_Menu(self, root)

--购买物品
    BuyItem_Menu(self, root)








--自动修理
    root:CreateDivider()
    sub=root:CreateCheckbox(
        '|A:SpellIcon-256x256-RepairAll:0:0|a'..(WoWTools_DataMixin.onlyChinese and '自动修理所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REPAIR_ALL_ITEMS)),
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

    local repDate= RepairSave().date
    local repNum= RepairSave().num or 0
    local repGuild= RepairSave().guild or 0
    local repPlayer= RepairSave().player or 0


    sub:CreateTitle(repDate)
    sub:CreateSpacer()

    sub:CreateTitle((WoWTools_DataMixin.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR)..': '..repNum..' '..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
    sub:CreateTitle((WoWTools_DataMixin.onlyChinese and '公会' or GUILD)..': '..C_CurrencyInfo.GetCoinTextureString(repGuild))
    sub:CreateTitle((WoWTools_DataMixin.onlyChinese and '玩家' or PLAYER)..': '..C_CurrencyInfo.GetCoinTextureString(repPlayer))

    sub:CreateSpacer()
    sub:CreateTitle((WoWTools_DataMixin.onlyChinese and '合计' or TOTAL)..': '..C_CurrencyInfo.GetCoinTextureString(repGuild+repPlayer))

    sub:CreateDivider()
    sub:CreateTitle((WoWTools_DataMixin.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP)..': '..C_CurrencyInfo.GetCoinTextureString(CanGuildBankRepair() and GetGuildBankMoney() or 0))







--商人 Plus
    sub=root:CreateCheckbox(
        '|A:communities-icon-addgroupplus:0:0|a'..(WoWTools_DataMixin.onlyChinese and '商人 Plus' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MERCHANT, 'Plus')),
    function()
        return not Save().notPlus
    end, function()
        Save().notPlus = not Save().notPlus and true or nil
        print(
            WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnWARNING_FONT_COLOR:',
            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
        )
        --商人 Plus
        WoWTools_MerchantMixin:Init_WidthX2()
        WoWTools_MerchantMixin:Plus_ItemInfo()
    end)

--增加，按钮宽度，按钮，菜单
    WoWTools_MerchantMixin:ResizeButton2_Menu(self, sub)






--删除字符
    sub=root:CreateCheckbox(
        '|A:common-icon-redx:0:0|a'..(WoWTools_DataMixin.onlyChinese and 'DELETE' or DELETE_ITEM_CONFIRM_STRING),
    function()
        return not Save().notDELETE
    end, function()
        Save().notDELETE= not Save().notDELETE and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(format(
            WoWTools_DataMixin.onlyChinese and '你真的要摧毁%s吗？|n|n请在输入框中输入 DELETE 以确认。' or DELETE_GOOD_ITEM,
            WoWTools_DataMixin.onlyChinese and '物品' or AUCTION_HOUSE_HEADER_ITEM,
            DELETE_ITEM_CONFIRM_STRING
        ))
        tooltip:AddDoubleLine('-', '-', 0,1,0, 0,1,0)
        tooltip:AddLine(format(
            WoWTools_DataMixin.onlyChinese and '确定要摧毁%s吗？\n|cffff2020摧毁该物品也将同时放弃相关任务。|r\n\n请在输入框中输入\"DELETE\"以确认。' or DELETE_GOOD_QUEST_ITEM,
            WoWTools_DataMixin.onlyChinese and '任务物品' or ITEM_BIND_QUEST,
            DELETE_ITEM_CONFIRM_STRING
        ))
    end)






--自动拾取 plus
    sub=root:CreateCheckbox(
        '|A:Cursor_lootall_128:0:0|a'..(WoWTools_DataMixin.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus',
    function()
        return not Save().notAutoLootPlus
    end, function()
        Save().notAutoLootPlus= not Save().notAutoLootPlus and true or nil
        print(
            WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnWARNING_FONT_COLOR:',
            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
        )
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '自动拾取' or AUTO_LOOT_DEFAULT_TEXT, WoWTools_TextMixin:GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
        tooltip:AddLine(' ')
        tooltip:AddLine(
            WoWTools_DataMixin.onlyChinese and '拾取窗口 Shift: 禁用'
            or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_LOOT_FRAME_LABEL, 'Shift: ')..DISABLE)
        )
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '不在战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT)
    end)



--[[显示背景
    WoWTools_MenuMixin:BgAplha(root,
    function()
        return Save().bgAlpha or 0.5
    end, function(value)
        Save().bgAlpha= value
        Set_ShowBackground()
    end)]]

--打开选项界面
    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_MerchantMixin.addName})

--重置数据
    WoWTools_MenuMixin:RestData(sub, WoWTools_MerchantMixin.addName, function()
        WoWToolsPlayerDate['Plus_SellBuy']=nil
        WoWTools_DataMixin:Reload()
    end)

    sub:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end
















local function Init()
    local btn= WoWTools_ButtonMixin:Menu(MerchantFrameCloseButton, {name='WoWTools_SellBuyMenuButton'})
    btn:SetPoint('RIGHT', MerchantFrameCloseButton, 'LEFT', -2, 0)
    btn:SetupMenu(Init_Menu)

--显示背景
    --Set_ShowBackground()

    Init=function()end
end











function WoWTools_MerchantMixin:Init_Menu()
    Init()
end

--购买物品
function WoWTools_MerchantMixin:BuyItem_Menu(frame, root)
    BuyItem_Menu(frame, root)
end

--回购
function WoWTools_MerchantMixin:Buyback_Menu(frame, root)
    Buyback_Menu(frame, root)
end

--出售自定义
function WoWTools_MerchantMixin:Player_Sell_Menu(frame, root)
    Player_Sell_Menu(frame, root)
end
