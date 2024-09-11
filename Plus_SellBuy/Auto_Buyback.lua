--回购物品
local e= select(2, ...)

local function Save()
    return WoWTools_SellBuyMixin.Save
end






local function Init()
    local BuybackButton= WoWTools_ButtonMixin:Cbtn(MerchantBuyBackItem, {name='WoWTools_BuybackButton', size={22,22}, icon='hide'})--nil, false)--购回
    
    function BuybackButton:set_texture()
        self:SetNormalAtlas('common-icon-undo')
    end
    BuybackButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,18)

    function BuybackButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_SellBuyMixin.addName)
        local num= self:set_text()
        e.tips:AddDoubleLine('|cffff00ff'..(e.onlyChinese and '回购' or BUYBACK), '|cnGREEN_FONT_COLOR: #'..num)
        e.tips:AddLine(' ')
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='merchant' and itemID then
            itemLink= GetMerchantItemLink(itemID)
            itemID= GetMerchantItemID(itemID)
        end
        if (infoType=='item' or infoType=='merchant') and itemID and itemLink then
            local icon= '|T'..(C_Item.GetItemIconByID(itemLink) or 0)..':0|t'..itemLink
            if Save().noSell[itemID] then
                e.tips:AddDoubleLine(icon, '|A:bags-button-autosort-up:0:0|a|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.left)
                self:SetNormalAtlas('bags-button-autosort-up')
            else
                e.tips:AddDoubleLine(icon, '|A:common-icon-undo:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.left)
                local icon= C_Item.GetItemIconByID(itemLink)
                if icon then
                    self:SetNormalTexture(icon)
                end
            end
        else
            num= GetNumBuybackItems()
	        local buybackName, buybackTexture= GetBuybackItemInfo(num)
            if buybackName then
                itemID = C_MerchantFrame.GetBuybackItemID(num)
                if itemID then
                    e.tips:AddDoubleLine(
                        '|T'..(buybackTexture or 0)..':0|t'..(GetMerchantItemLink(num) or buybackName),
                        '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.left
                    )
                    e.tips:AddLine(' ')
                    if buybackTexture then
                        self:SetNormalTexture(buybackTexture)
                    end
                end
            end
            e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '回购' or BUYBACK)
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        end
        e.tips:Show()
    end
    BuybackButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='merchant' and itemID then--购买物品
            itemLink= GetMerchantItemLink(itemID)
            itemID= GetMerchantItemID(itemID)
        end
        if (infoType=='item' or infoType=='merchant') and itemID then
            if Save().noSell[itemID] then
                Save().noSell[itemID]=nil
                print(e.addName, WoWTools_SellBuyMixin.addName,'|cnRED_FONT_COLOR:', e.onlyChinese and '移除' or REMOVE, e.onlyChinese and '回购' or BUYBACK, itemLink)
            else
                Save().noSell[itemID]=true
                Save().Sell[itemID]=nil
                print(e.addName,WoWTools_SellBuyMixin.addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '添加' or ADD, e.onlyChinese and '回购' or BUYBACK, itemLink )
                self:set_buyback_item()--购回物品
            end
            ClearCursor()
            self:set_tooltip()

        elseif d=='RightButton' then
            --WoWTools_SellBuyMixin:Init_Menu(self)

        elseif d=='LeftButton' then
            local num= GetNumBuybackItems()
	        local buybackName= GetBuybackItemInfo(num)
            if buybackName then
                local itemID2 = C_MerchantFrame.GetBuybackItemID(num)
                if itemID2 then
                    Save().noSell[itemID2]= true
                    Save().Sell[itemID2]= nil
                    print(e.addName, WoWTools_SellBuyMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.onlyChinese and '回购' or BUYBACK, GetMerchantItemLink(num) or buybackName)
                    self:set_buyback_item()--购回物品
                end
            end
            self:set_tooltip()
        end

    end)
    BuybackButton:SetScript('OnMouseUp', function(self) self:set_texture() self:set_tooltip() end)
    BuybackButton:SetScript('OnLeave', function(self) self:set_texture() GameTooltip_Hide() end)
    BuybackButton:SetScript('OnEnter', BuybackButton.set_tooltip)

    BuybackButton.Text= e.Cstr(BuybackButton, {justifyH='CENTER'})
    BuybackButton.Text:SetPoint('CENTER', 2, 0)
    function BuybackButton:set_text()--回购，数量，提示
        local num= 0
        for _ in pairs(Save().noSell) do
            num= num +1
        end
        self.Text:SetText(num>0 and num or '')
        return num
    end


    function BuybackButton:set_buyback_item()--购回物品
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
                print(e.addName, WoWTools_SellBuyMixin.addName, index..')|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '购回' or BUYBACK), itemLink)
            end
            for index, info in pairs(no) do
                print(e.addName, WoWTools_SellBuyMixin.addName, index..')|cnRED_FONT_COLOR:'..(e.onlyChinese and '购回失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BUYBACK, INCOMPLETE)), info[1], C_CurrencyInfo.GetCoinTextureString(info[2]))
            end
        end)
    end
    BuybackButton:RegisterEvent('MERCHANT_UPDATE')
    BuybackButton:RegisterEvent('MERCHANT_SHOW')
    BuybackButton:SetScript('OnEvent', BuybackButton.set_buyback_item)

    BuybackButton:set_texture()
    BuybackButton:set_text()--回购，数量，提示


    --清除，回购买，图标
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:ClearAllPoints()
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:SetTexture(0)
end











function WoWTools_SellBuyMixin:Init_Buyback_Button()--回购物品
    Init()
end