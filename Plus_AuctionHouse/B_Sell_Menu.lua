
if GameLimitedMode_IsActive() or PlayerGetTimerunningSeasonID() then
    return
end
--拍卖行
local e= select(2, ...)

local function Save()
    return WoWTools_AuctionHouseMixin.Save
end






local function Init_Menu(self, root)
    local sub, sub2
    root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '显示' or SHOW,
    function()
        return not Save().hideSellItemList
    end, function()
        Save().hideSellItemList= not Save().hideSellItemList and true or nil
        self:Settings()
        self:Init_Sell_Item_Button()
    end)

    root:CreateDivider()

    sub=root:CreateButton(
        WoWTools_Mixin.onlyChinese and '隐藏物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, ITEMS),
    function()
        return MenuResponse.Open
    end)

--隐藏物品列表，隐藏按钮
    sub:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '隐藏' or HIDE,
    function()
        return Save().hideSellItemListButton
    end, function()
        Save().hideSellItemListButton= not Save().hideSellItemListButton and true or nil
        self:Init_Sell_Item_Button()
    end)

--全部清除
    sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        Save().hideSellItem={}
        Save().hideSellPet={}
        self:Init_Sell_Item_Button()
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_AuctionHouseMixin.addName, WoWTools_Mixin.onlyChinese and '清除隐藏物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, ITEMS)))
        return MenuResponse.Refresh
    end)

    sub:CreateDivider()
    local find=false
--隐藏，物品，列表
    for itemID in pairs(Save().hideSellItem) do
        sub2= sub:CreateCheckbox(
            WoWTools_ItemMixin:GetName(itemID, nil),
        function(data)
            return Save().hideSellItem[data.itemID]
        end, function(data)
            Save().hideSellItem[data.itemID]= not Save().hideSellItem[data.itemID] and true or nil
            self:Init_Sell_Item_Button()
        end, {itemID= itemID})
        WoWTools_SetTooltipMixin:Set_Menu(sub2)
        find=true
    end


--隐藏，宠物，列表
    if find then
        sub:CreateDivider()
    end
    for speciesID, itemLink in pairs(Save().hideSellPet) do--speciesID是字符
        local speciesName, speciesIcon, _, companionID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        if speciesName then
            sub2= sub:CreateCheckbox(
                '|T'..(speciesIcon or 0)..':0|t'
                ..WoWTools_TextMixin:CN(speciesName, {npcID=companionID, isName=true}),
            function(data)
                return Save().hideSellPet[data.speciesID]
            end, function(data)
                Save().hideSellPet[data.speciesID]= not Save().hideSellPet[data.speciesID] and data.itemLink or nil
                self:Init_Sell_Item_Button()
            end, {speciesID= speciesID, itemLink= itemLink})

            WoWTools_SetTooltipMixin:Set_Menu(sub2)
            find=true
        end
    end


    if not find then
       sub:CreateTitle(WoWTools_Mixin.onlyChinese and '无' or NONE)
    end
    WoWTools_MenuMixin:SetScrollMode(sub)

--物品品质
    sub= root:CreateButton(
        select(4, WoWTools_ItemMixin:GetColor(Save().sellItemQualiy))
        ..format(
            CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,
            WoWTools_Mixin.onlyChinese and '品质' or PROFESSIONS_COLUMN_HEADER_QUALITY,
            (WoWTools_TextMixin:CN(_G['ITEM_QUALITY'..Save().sellItemQualiy..'_DESC']) or Save().sellItemQualiy)
        ),
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '最小' or MINIMUM)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '物品品质' or COLORBLIND_ITEM_QUALITY)
    end)
--物品品质 0, 8
    for quality= Enum.ItemQuality.Poor ,  Enum.ItemQuality.WoWToken do
        sub2=sub:CreateCheckbox(
            select(4, WoWTools_ItemMixin:GetColor(quality))
            ..(WoWTools_TextMixin:CN(_G['ITEM_QUALITY'..quality..'_DESC']) or quality),
        function(data)
            return Save().sellItemQualiy== data.quality
        end, function(data)
            Save().sellItemQualiy= data.quality
            self:Init_Sell_Item_Button()
        end, {quality=quality})
        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.quality)
        end)
    end

--转到出售
    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '转到出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NPE_TURN, AUCTION_HOUSE_SELL_TAB),
    function()
        return Save().intShowSellItem
    end, function()
        Save().intShowSellItem= not Save().intShowSellItem and true or nil
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '显示拍卖行时' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, BUTTON_LAG_AUCTIONHOUSE))
    end)

--打开，选项
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_AuctionHouseMixin.addName})

--行数
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().numButton
        end, setValue=function(value)
            Save().numButton=value
            self:Init_Sell_Item_Button()
        end,
        name=WoWTools_Mixin.onlyChinese and '行数' or HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
        minValue=1,
        maxValue=40,
        step=1,
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scaleSellButton or 1
    end, function(value)
        Save().scaleSellButton= value
        self:Settings()
    end)

end





function WoWTools_AuctionHouseMixin:Sell_Setup_Menu(button)
    button:SetupMenu(Init_Menu)
end