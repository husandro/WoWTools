--回购物品

local function Save()
    return WoWToolsSave['Plus_SellBuy']
end










--购回物品, itemID, itemLink
local function Get_Buyback_ItemID()
    local num= GetNumBuybackItems()
    if num and num>0 then
        return C_MerchantFrame.GetBuybackItemID(num), GetMerchantItemLink(num)
    end
end











--购回物品
local function set_buyback_item()
    local num= GetNumBuybackItems() or 0
    if IsModifierKeyDown() or num==0 then
        return
    end

    local tab={}
    local no={}
    for index=1, num do
        local itemID = C_MerchantFrame.GetBuybackItemID(index)
        if itemID and Save().noSell[itemID] then
            local itemLink= GetBuybackItemLink(index) or itemID
            local co= select(3, GetBuybackItemInfo(index)) or 0
            if co<=GetMoney() then
                table.insert(tab, itemLink)
                BuybackItem(index)
            else
                table.insert(no, {itemLink, co or 0})
            end
        end
    end

    C_Timer.After(0.3, function()
        for index, itemLink in pairs(tab) do
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName, index..')|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '购回' or BUYBACK), itemLink)
        end
        for index, info in pairs(no) do
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName, index..')|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '购回失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BUYBACK, INCOMPLETE)), info[1], C_CurrencyInfo.GetCoinTextureString(info[2]))
        end
    end)
end












--添加，移除，到Save
local function Add_Remove_ToSave(itemID)
    local text
    if Save().noSell[itemID] then
        Save().noSell[itemID]=nil
        text= '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)
    else
        Save().noSell[itemID]=true
        Save().Sell[itemID]=nil
        text='|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
        set_buyback_item()
    end
    print(
        WoWTools_DataMixin.addName,
        WoWTools_MerchantMixin.addName,
        WoWTools_DataMixin.onlyChinese and '回购' or BUYBACK,
        text
    )
end












local function Init_Menu(self, root)
    local name, sub
    local itemID= Get_Buyback_ItemID()
    if itemID then
        name= WoWTools_ItemMixin:GetName(itemID)--取得物品，名称
    end

    if name then
        sub=root:CreateCheckbox(name, function(data)
            return Save().noSell[data.itemID]
        end, function(data)
            Add_Remove_ToSave(data.itemID)
        end, {itemID=itemID})
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '添加回购' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, BUYBACK))
        end)
    else
        root:CreateTitle(WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))

    end

    root:CreateDivider()
    WoWTools_MerchantMixin:Buyback_Menu(self, root)
end













--购回
local function Init()

    local BuybackButton= WoWTools_ButtonMixin:Cbtn(MerchantBuyBackItem, {
        name='WoWTools_BuybackButton',
        size=35
    })

    if Save().notPlus then
        BuybackButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,18)
        BuybackButton:SetSize(22, 22)
    else
        BuybackButton:SetPoint('LEFT', MerchantBuyBackItemItemButtonIconTexture, 'RIGHT', 10, 0)
    end

    BuybackButton.texture= BuybackButton:CreateTexture(nil, 'BORDER')
    BuybackButton.texture:SetAllPoints()
    function BuybackButton:set_texture()
        self.texture:SetAtlas('common-icon-undo')
    end

    function BuybackButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()

        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '回购' or BUYBACK, '|cnGREEN_FONT_COLOR: #'..(self:set_text() or ''))
        GameTooltip:AddLine(' ')

        local infoType, itemID= GetCursorInfo()
        if infoType=='merchant' and itemID then
            itemID= GetMerchantItemID(itemID)
        end

        if (infoType=='item' or infoType=='merchant') and itemID then
            local name= WoWTools_ItemMixin:GetName(itemID)
            if Save().noSell[itemID] then
                GameTooltip:AddDoubleLine(name, (WoWTools_DataMixin.onlyChinese and '移除' or REMOVE)..WoWTools_DataMixin.Icon.left)
                self.texture:SetAtlas('bags-button-autosort-up')
            else
                GameTooltip:AddDoubleLine(name, (WoWTools_DataMixin.onlyChinese and '添加' or ADD)..WoWTools_DataMixin.Icon.left)
                local icon= C_Item.GetItemIconByID(itemID)
                if icon then
                    self.texture:SetTexture(icon)
                end
            end

        else
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, WoWTools_DataMixin.Icon.right)
        end
        GameTooltip:Show()
    end






    BuybackButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID = GetCursorInfo()
        if infoType=='merchant' and itemID then--购买物品
            itemID= GetMerchantItemID(itemID)
        end

        if (infoType=='item' or infoType=='merchant') and itemID then
            Add_Remove_ToSave(itemID)
            ClearCursor()
        else
            MenuUtil.CreateContextMenu(self, function(...)
            Init_Menu(...)
        end)
        end
        self:set_tooltip()
    end)






    BuybackButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:set_texture()
    end)
    BuybackButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)
    BuybackButton:SetScript('OnMouseUp', function(self)
        self:set_texture()
    end)


    BuybackButton.Text= WoWTools_LabelMixin:Create(BuybackButton, {justifyH='RIGHT', color={r=1,g=1,b=1}})
    BuybackButton.Text:SetPoint('BOTTOMRIGHT')

    function BuybackButton:set_text()--回购，数量，提示
        local num= 0
        for _ in pairs(Save().noSell) do
            num= num +1
        end
        self.Text:SetText(num>0 and num or '')
        self.texture:SetDesaturated(num==0)
        return num
    end



    BuybackButton:RegisterEvent('MERCHANT_UPDATE')
    BuybackButton:RegisterEvent('MERCHANT_SHOW')
    BuybackButton:SetScript('OnEvent', set_buyback_item)

    BuybackButton:set_text()--回购，数量，提示
    BuybackButton:set_texture()

--清除，回购买，图标
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:ClearAllPoints()
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:SetTexture(0)
end











function WoWTools_MerchantMixin:Init_Buyback_Button()--回购物品
    Init()
end