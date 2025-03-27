local function Save()
    return WoWToolsSave['Plus_SellBuy']
end









local function Init()
    local selectedTab= MerchantFrame.selectedTab
    local isMerce= selectedTab == 1
    local page= isMerce and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    local numItem= isMerce and GetMerchantNumItems() or GetNumBuybackItems()
    for i=1, page do
        local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
        local btn= _G["MerchantItem"..i]
        local text, spellID, num, itemID, itemLink

        if btn and index<= numItem then
            if isMerce then
                itemID= GetMerchantItemID(index)
                itemLink=  GetMerchantItemLink(index)
            else
                itemID= C_MerchantFrame.GetBuybackItemID(index)
                itemLink= GetBuybackItemLink(index)
            end

            num=(not Save().notAutoBuy and itemID) and Save().buyItems[itemID]--自动购买， 数量
            num= num and num..'|T236994:0|t'
            --包里，银行，总数
            local bag=itemID and C_Item.GetItemCount(itemID, true, false, true)
            if bag and bag>0 then
                num=(num and num..'|n' or '')..bag..'|A:Banker:0:0|a'
            end
            if num and not btn.buyItemNum then
                btn.buyItemNum=WoWTools_LabelMixin:Create(btn)
                btn.buyItemNum:SetPoint('RIGHT')
                btn.buyItemNum:EnableMouse(true)
                btn.buyItemNum:SetScript('OnLeave', GameTooltip_Hide)
                btn.buyItemNum:SetScript('OnEnter', function(self)
                    if not self.itemID then return end
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
					GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_SellBuyMixin.addName)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine('|T236994:0|t'..(WoWTools_Mixin.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), not Save().notAutoBuy and Save().buyItems[self.itemID] or (WoWTools_Mixin.onlyChinese and '无' or NONE))
                    local all= C_Item.GetItemCount(self.itemID, true, false, true)
                    local bag2= C_Item.GetItemCount(self.itemID)
                    GameTooltip:AddDoubleLine('|A:Banker:0:0|a'..(WoWTools_Mixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL), all..'= '.. '|A:bag-main:0:0|a'.. bag2..'+ '..'|A:Banker:0:0|a'..(all-bag))
					GameTooltip:Show()
                end)
            end
            --物品，属性
            local classID= itemLink and select(6, C_Item.GetItemInfoInstant(itemLink))
            if classID==2 or classID==4 then--装备
                local stat= WoWTools_ItemStatsMixin:GetItem(itemLink)--物品，属性，表
                for _, tab in pairs(stat) do
                    text= text and text..' ' or ''
                    text= (text and text..' ' or '')..tab.text
                end
                spellID= itemLink and select(2, C_Item.GetItemSpell(itemLink))
                if spellID then
                    text= (text or '').. '|A:soulbinds_tree_conduit_icon_utility:10:10|a'
                end
                if text and not btn.stats then
                    btn.stats=WoWTools_LabelMixin:Create(btn, {size=10, mouse=true})
                    btn.stats:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT',0,6)
                    btn.stats:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
                    btn.stats:SetScript('OnEnter', function(self)
                        if self.spellID then
                            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                            GameTooltip:ClearLines()
                            GameTooltip:SetSpellByID(self.spellID)
                            GameTooltip:AddLine(' ')
                            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_SellBuyMixin.addName)
                            GameTooltip:Show()
                        end
                        self:SetAlpha(0.5)
                    end)
                end
            end
        end
        if btn then
            if btn.buyItemNum then
                btn.buyItemNum:SetText(num or '')
                btn.buyItemNum.itemID= itemID
            end
            if btn.stats then
                btn.stats:SetText(text or '')
                btn.stats.spellID= spellID
            end
        end
    end
end











--商人Plus. 设置, 提示, 信息
function WoWTools_SellBuyMixin:Set_Merchant_Info()
    if MerchantFrame:IsVisible() and not Save().notPlus then
        Init()
    end
end