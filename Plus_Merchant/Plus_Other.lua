local function Save()
    return WoWToolsSave['Plus_SellBuy']
end
















local function Init_UI()
--重新设置，按钮
    hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
        MerchantRepairItemButton:ClearAllPoints()--单个，修理
        MerchantRepairItemButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -289, 33)
        MerchantRepairAllButton:ClearAllPoints()--全部，修理
        MerchantRepairAllButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -241, 33)
        MerchantGuildBankRepairButton:ClearAllPoints()--公会，修理
        MerchantGuildBankRepairButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -193, 33)
        MerchantSellAllJunkButton:ClearAllPoints()--出售垃圾，修理
        MerchantSellAllJunkButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -145, 33)--36
    end)
--回购
    MerchantBuyBackItem:ClearAllPoints()
    MerchantBuyBackItem:SetPoint('BOTTOMRIGHT', MerchantFrame, -16, 33)--115

--下一页
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint('RIGHT', MerchantFrame.FilterDropdown, 'LEFT', 4, 0)
    MerchantNextPageButton:SetFrameStrata('HIGH')
    local label, texture= MerchantNextPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

--上一页
    MerchantPrevPageButton:ClearAllPoints()
    MerchantPrevPageButton:SetPoint('RIGHT', MerchantNextPageButton, 'LEFT',8,0)
    label, texture= MerchantPrevPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end

--上页数
    MerchantPageText:ClearAllPoints()
    MerchantPageText:SetPoint('RIGHT', MerchantPrevPageButton, 'LEFT', 0, 0)
    MerchantPageText:SetJustifyH('RIGHT')

--外框
    MerchantFrameBottomLeftBorder:ClearAllPoints()
    MerchantFrameBottomLeftBorder:SetPoint('BOTTOMRIGHT', 0, 26)



    --物品数量
    MerchantFrameTab1.numLable= WoWTools_LabelMixin:Create(MerchantFrameTab1)
    MerchantFrameTab1.numLable:SetPoint('TOPRIGHT')
    MerchantFrame:HookScript('OnShow', function()
        local num= GetMerchantNumItems()
        MerchantFrameTab1.numLable:SetText(num and num>0 and num or '')
    end)

    --回购，数量，提示
    MerchantFrameTab2.numLable= WoWTools_LabelMixin:Create(MerchantFrameTab2)
    MerchantFrameTab2.numLable:SetPoint('TOPRIGHT')
    function MerchantFrameTab2:set_buyback_num()
        local num
        num= GetNumBuybackItems() or 0
        if num>0 then
            num= num==BUYBACK_ITEMS_PER_PAGE and '|cnRED_FONT_COLOR:'..num or num
        else
            num= ''
        end
        self.numLable:SetText(num)
    end


   hooksecurefunc('MerchantFrame_UpdateCurrencies', function()
        MerchantExtraCurrencyInset:SetShown(false)
        MerchantExtraCurrencyBg:SetShown(false)
        MerchantMoneyInset:SetShown(false)
    end)


    if C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_MerchantMixin.addName,
            format(WoWTools_DataMixin.onlyChinese and "|cffff0000与%s发生冲突！|r" or ALREADY_BOUND, 'Compact Vendor'),
            WoWTools_DataMixin.onlyChinese and '插件' or ADDONS
        )
    end

    Init_UI=function()end
end





























--物品，信息 WoWTools_ItemMixin
local function setMerchantInfo()

    local isBuy= MerchantFrame.selectedTab==1
    local page= isBuy and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE

    for i=1, page do
        local slot = isBuy and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
        local itemButton= _G["MerchantItem"..i..'ItemButton']
        if itemButton then
            WoWTools_ItemMixin:Setup(itemButton, {
                merchant={slot=slot, buyBack= not isBuy}
            })
        end
    end

    WoWTools_ItemMixin:Setup(
        MerchantBuyBackItemItemButton,
        {merchant={slot=GetNumBuybackItems(), buyBack=true}}
    )
end


--货币，拥有，数量
local function Create_Quantity_Label(btn)
    if btn.quantityAll then
        return
    end

    btn.quantityAll= WoWTools_LabelMixin:Create(btn, {size=10})
    btn.quantityAll:SetPoint('TOPLEFT', btn.Text, 'BOTTOMRIGHT', 0, 2)
    btn.quantityAll:SetAlpha(0.7)

    btn:EnableMouse(true)
    btn:HookScript('OnMouseDown', function(self)
        if self.itemLink then
            local link= self.itemLink..(
                self.quantityAll.itemValue and ' x'..self.quantityAll.itemValue or ''
            )
            WoWTools_ChatMixin:Chat(link, nil, true)
        end
        self:SetAlpha(0.3)
    end)
    btn:HookScript('OnEnter', function(self)
        self:SetAlpha(0.5)
    end)
    btn:HookScript('OnMouseUp', function(self)
        self:SetAlpha(0.5)
    end)
    btn:HookScript('OnLeave', function(self) self:SetAlpha(1) end)
    btn:HookScript('OnEnter', function(self)
        if self.itemLink and GameTooltip:IsShown() then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, WoWTools_DataMixin.Icon.left)
            GameTooltip:Show()
        end
    end)
end







--物品信息
local function Init_SetItem_Info()
--物品信息
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', setMerchantInfo)--MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)

--购买物品，所需货币数量
    hooksecurefunc('MerchantFrame_UpdateAltCurrency', function(index, indexOnPage)
        local itemCount = GetMerchantItemCostInfo(index)
        local frameName = "MerchantItem"..indexOnPage.."AltCurrencyFrame"
        local usedCurrencies = 0
        if ( itemCount > 0 ) then
            for i=1, MAX_ITEM_COST do
                local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i)
                if itemLink then
                    usedCurrencies = usedCurrencies + 1
                    local btn = _G[frameName.."Item"..usedCurrencies]
                    if btn and btn:IsShown() then
                        local num
                        if currencyName then
                            num= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink).quantity
                        else
                            num= C_Item.GetItemCount(itemLink, true, false, true)
                        end
                        if itemValue and num then
                            if num>=itemValue then
                                num= '|cnGREEN_FONT_COLOR:'..WoWTools_Mixin:MK(num,0)..'|r'
                            else
                                num= '|cnRED_FONT_COLOR:'..WoWTools_Mixin:MK(num,0)..'|r'
                            end
                        end

                        Create_Quantity_Label(btn)

                        btn.quantityAll.itemValue= itemValue
                        btn.quantityAll:SetText(num or '')
                    end
                end
            end
        end
    end)






--物品，属性，急 爆 全
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
                    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MerchantMixin.addName)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine('|T236994:0|t'..(WoWTools_DataMixin.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), not Save().notAutoBuy and Save().buyItems[self.itemID] or (WoWTools_DataMixin.onlyChinese and '无' or NONE))
                    local all= C_Item.GetItemCount(self.itemID, true, false, true)
                    local bag2= C_Item.GetItemCount(self.itemID)
                    GameTooltip:AddDoubleLine('|A:Banker:0:0|a'..(WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL), all..'= '.. '|A:bag-main:0:0|a'.. bag2..'+ '..'|A:Banker:0:0|a'..(all-bag))
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
                            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MerchantMixin.addName)
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



    Init_SetItem_Info= function()end
end


























--堆叠,数量,框架 StackSplitFrame.lua
local function Init_StackSplitFrame()
    local frame= StackSplitFrame
    frame.restButton=WoWTools_ButtonMixin:Cbtn(frame, {size=22})--重置
    frame.restButton:SetPoint('TOP')
    frame.restButton:SetNormalAtlas('characterundelete-RestoreButton')
    frame.restButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split= f.minSplit
        f.LeftButton:SetEnabled(false)
        f.RightButton:SetEnabled(true)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    frame.restButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MerchantMixin.addName)
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重置' or RESET)
        GameTooltip:Show()
    end)
    frame.restButton:SetScript('OnLeave', GameTooltip_Hide)

    frame.MaxButton=WoWTools_ButtonMixin:Cbtn(frame, {size={40,20}})
    frame.MaxButton:SetNormalFontObject('NumberFontNormalYellow')
    frame.MaxButton:SetPoint('LEFT', frame.restButton, 'RIGHT')
    frame.MaxButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=f.maxStack
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    frame.MetaButton=WoWTools_ButtonMixin:Cbtn(frame, {size={40,20}})
    frame.MetaButton:SetNormalFontObject('NumberFontNormalYellow')
    frame.MetaButton:SetPoint('RIGHT', frame.restButton, 'LEFT')
    frame.MetaButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=floor(f.maxStack/2)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    frame.editBox=CreateFrame('EditBox', nil, frame)--输入框
    frame.editBox:SetSize(100, 23)
    frame.editBox:SetPoint('TOPLEFT', 38, -18)
    frame.editBox:SetTextColor(0,1,0)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:ClearFocus()
    frame.editBox:SetFontObject("ChatFontNormal")
    frame.editBox:SetMultiLine(false)
    frame.editBox:SetNumeric(true)
    --frame.editBox:SetScript('OnEditFocusLost', function(self) self:SetText('') end)
    frame.editBox:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    frame.editBox:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)
    frame.editBox:SetScript('OnHide', function(self) self:SetText('') self:ClearFocus() end)
    frame.editBox:SetScript('OnTextChanged',function(self, userInput)
        if not userInput then
            return
        end
        local f= self:GetParent()
        local num=self:GetNumber()
        if f.isMultiStack then
            num= floor(num/f.minSplit) * f.minSplit
        end
        num= num<f.minSplit and f.minSplit or num
        num= num>f.maxStack and f.maxStack or num
        f.RightButton:SetEnabled(num<f.maxStack)
        f.LeftButton:SetEnabled(num==f.minSplit)
        f.split=num
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    frame:HookScript('OnMouseWheel', function(self, d)
        local minSplit= self.minSplit or 1
        local maxStack= self.maxStack or 1
        local num= self.split or 1
        num= d==1 and num+ minSplit or num
        num= d==-1 and num- minSplit or num
        num= num< minSplit and minSplit or num
        num= num> maxStack and maxStack or num
        self.split= num
        self:UpdateStackText()
        self:UpdateStackSplitFrame(self.maxStack)
    end)

    hooksecurefunc(StackSplitFrame, 'OpenStackSplitFrame', function(self)
        self.MaxButton:SetText(self.maxStack)
        self.MetaButton:SetText(floor(self.maxStack/2))
    end)
end









function WoWTools_MerchantMixin:Init_Plus_Other()
    if Save().plus then
        Init_UI()--移去 UI
        Init_SetItem_Info()--物品，信息
        Init_StackSplitFrame()--堆叠,数量,框架
    end
end
