local function Save()
    return WoWToolsSave['Plus_SellBuy']
end
























local function Init_UI()

--重新设置，按钮
    WoWTools_DataMixin:Hook('MerchantFrame_UpdateRepairButtons', function()
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

--回购, 物品名称
    MerchantBuyBackItemName:ClearAllPoints()
    MerchantBuyBackItemName:SetPoint('BOTTOMLEFT', MerchantBuyBackItemItemButtonIconTexture, 'TOPLEFT', 0, 5)
    MerchantBuyBackItemName:SetPoint('RIGHT', MerchantFrame)
    MerchantBuyBackItemName:SetHeight(6)

    WoWTools_ColorMixin:Setup(MerchantBuyBackItemItemButtonNormalTexture, {alpha=0.5})

--修理一件物品
    WoWTools_ButtonMixin:AddMask(MerchantRepairItemButton, false)
    WoWTools_ButtonMixin:AddMask(MerchantRepairAllButton, false)

--公会，修理
    WoWTools_ButtonMixin:AddMask(MerchantGuildBankRepairButton, false)

--出售垃圾
    WoWTools_ButtonMixin:AddMask(MerchantSellAllJunkButton, false)

--下一页
    MerchantNextPageButton:ClearAllPoints()
    MerchantNextPageButton:SetPoint('RIGHT', MerchantFrame.FilterDropdown, 'LEFT', 4, 0)
    MerchantNextPageButton:SetFrameStrata('HIGH')
    local label, texture= MerchantNextPageButton:GetRegions()
    if texture and texture:IsObjectType('Texture') then texture:SetTexture(0) end
    if label and label:IsObjectType('FontString') then label:SetText('') end

--上一页
    MerchantPrevPageButton:ClearAllPoints()
    MerchantPrevPageButton:SetPoint('RIGHT', MerchantNextPageButton, 'LEFT',8,0)
    label, texture= MerchantPrevPageButton:GetRegions()
    if texture and texture:IsObjectType('Texture') then texture:SetTexture(0) end
    if label and label:IsObjectType('FontString') then label:SetText('') end

--上页数
    MerchantPageText:ClearAllPoints()
    MerchantPageText:SetPoint('RIGHT', MerchantPrevPageButton, 'LEFT', 0, 0)
    MerchantPageText:SetJustifyH('RIGHT')

--外框
    MerchantFrameBottomLeftBorder:ClearAllPoints()
    MerchantFrameBottomLeftBorder:SetPoint('BOTTOMRIGHT', 0, 26)








   WoWTools_DataMixin:Hook('MerchantFrame_UpdateCurrencies', function()
        MerchantExtraCurrencyInset:SetShown(false)
        MerchantExtraCurrencyBg:SetShown(false)
        MerchantMoneyInset:SetShown(false)
        local btn
        for i=1, MAX_MERCHANT_CURRENCIES do
            btn = _G["MerchantToken"..i]--BackpackTokenTemplate
            if not btn or btn.IconMask then
                break
            end
--添加，遮罩
            WoWTools_ButtonMixin:AddMask(btn, false, btn.Icon)
--大小
            btn.Icon:SetSize(18,18)
--Alpah
            btn:HookScript('OnLeave', function(self)
                self:SetAlpha(1)
            end)
            btn:HookScript('OnEnter', function(self)
                self:SetAlpha(0.3)
            end)
        end
    end)

    if C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(
            WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
            format(WoWTools_DataMixin.onlyChinese and "|cnWARNING_FONT_COLOR:与%s发生冲突！|r" or ALREADY_BOUND, 'Compact Vendor'),
            WoWTools_DataMixin.onlyChinese and '插件' or ADDONS
        )
    end


    Init_UI=function()end
end






















local function Create_Label(btn)

--索引
    btn.IndexLable= WoWTools_LabelMixin:Create(btn, {size=10})
    btn.IndexLable:SetPoint('BOTTOMRIGHT', 2, -2)
    btn.IndexLable:SetAlpha(0.3)

--数量
    btn.buyItemNum=WoWTools_LabelMixin:Create(btn, {size=10})
    btn.buyItemNum:SetPoint('BOTTOMRIGHT', btn.IndexLable, 'TOPRIGHT', 0,3)

--属性
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






--物品，信息 WoWTools_ItemMixin
local function Set_Item_Info()
    local numMerchantNumItems= GetMerchantNumItems()
    local numBuybackItems= GetNumBuybackItems()

    local isMerce= MerchantFrame.selectedTab==1
    local page= isMerce and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    local numItem= isMerce and numMerchantNumItems or numBuybackItems

    local showItemInfo= not Save().notItemInfo--物品信息
    --local notIsUsableAlpha= Save().notIsUsableAlpha or 1--无法使用物品，alpha

    for i=1, page do
        local index = isMerce and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i

        local btn= _G["MerchantItem"..i]

        if not btn then
            break
        end

        local stats, spellID, num, itemID, itemLink, itemName

        if not btn.buyItemNum then
            Create_Label(btn)
        end

        local isValueItem= index<= numItem

        if isValueItem and showItemInfo then
            if isMerce then
                itemID= GetMerchantItemID(index)
                itemLink=  GetMerchantItemLink(index)

            else
                itemID= C_MerchantFrame.GetBuybackItemID(index)
                itemLink= GetBuybackItemLink(index)
            end

--自动购买， 数量
            num=(not Save().notAutoBuy and itemID) and WoWToolsPlayerDate['SellBuyItems'].buy[WoWTools_DataMixin.Player.GUID][itemID]
            num= num and num..'|A:Perks-ShoppingCart:0:0|a' or ''

--包里，银行
            num= num ..(WoWTools_ItemMixin:GetCount(itemID, {notZero=true}) or '')


--物品，属性
            local classID= itemLink and select(6, C_Item.GetItemInfoInstant(itemLink))
            if classID==2 or classID==4 then--装备
                local stat= WoWTools_ItemMixin:GetItemStats(itemLink)--物品，属性，表
                for _, tab in pairs(stat) do
                    stats= stats and stats..' ' or ''
                    stats= (stats and stats..' ' or '')..tab.text
                end
                spellID= itemLink and select(2, C_Item.GetItemSpell(itemLink))
                if spellID then
                    stats= (stats or '').. '|A:soulbinds_tree_conduit_icon_utility:10:10|a'
                end
            end

--怎理，名称
            local itemButton= _G["MerchantItem"..i.."ItemButton"]
            if itemButton and itemButton.name then
                itemName= WoWTools_TextMixin:CN(itemButton.name, {itemID=itemID, isName=true})
                if itemName then
                    itemName= itemName:match('^|c........(.+)|r$') or itemName
    --截取 :(.+)
                    itemName= itemName:match('%：(.+)') or itemName
                    itemName= itemName:match('%:(.+)') or itemName
                    itemName= itemName:match('%- (.+)') or itemName
                end
                if itemName~=itemButton.name then
                    _G["MerchantItem"..i.."Name"]:SetText(itemName)
                end
            end
        end
--索引
        btn.IndexLable:SetText(itemID and index or '')
--数量
        btn.buyItemNum:SetText(num or '')
--属性
        btn.stats:SetText(stats or '')
        btn.stats.spellID= spellID
--提示
        WoWTools_ItemMixin:SetupInfo(
            _G["MerchantItem"..i..'ItemButton'], showItemInfo and {merchant={slot=index, buyBack= not isMerce} or nil}
        )

--无法使用物品，alpha
        --[[local alpha=1
        if isValueItem and isMerce and notIsUsableAlpha<1 then
            local info= C_MerchantFrame.GetItemInfo(i)
            if info and not info.isUsable then
                print(info.name)
                alpha= notIsUsableAlpha
            end
        end
        btn:SetAlpha(alpha)]]
    end

--回购，物品，信息
    if isMerce then
        WoWTools_ItemMixin:SetupInfo(
            MerchantBuyBackItemItemButton,
            {merchant={slot=numBuybackItems, buyBack=true}}
        )
    end



--可卖，物品数量
    MerchantFrameTab1.numLable:SetText(
        (numMerchantNumItems==0 and '|cff626262' or '')
        ..numMerchantNumItems
    )


--回购，数量，提示
    MerchantFrameTab2.numLable:SetText(
        (
        numBuybackItems==0 and '|cff626262'
        or (numBuybackItems==BUYBACK_ITEMS_PER_PAGE and '|cnWARNING_FONT_COLOR:')
        or ''
        )
        ..numBuybackItems
    )
end















--物品信息
local function Init_SetItem_Info()
--物品，数量
    MerchantFrameTab1.numLable= WoWTools_LabelMixin:Create(MerchantFrameTab1)
    MerchantFrameTab1.numLable:SetPoint('TOPRIGHT')


  --回购，数量，提示
    MerchantFrameTab2.numLable= WoWTools_LabelMixin:Create(MerchantFrameTab2)
    MerchantFrameTab2.numLable:SetPoint('TOPRIGHT')


--物品信息
    WoWTools_DataMixin:Hook('MerchantFrame_UpdateMerchantInfo', Set_Item_Info)

    WoWTools_DataMixin:Hook('MerchantFrame_UpdateBuybackInfo', Set_Item_Info)







--购买物品，所需货币数量
    WoWTools_DataMixin:Hook('MerchantFrame_UpdateAltCurrency', function(index, indexOnPage)
        local itemCount = GetMerchantItemCostInfo(index)
        local frameName = "MerchantItem"..indexOnPage.."AltCurrencyFrame"
        local usedCurrencies = 0
        local showItemInfo= not Save().notItemInfo
        if ( itemCount > 0 ) then
            for i=1, MAX_ITEM_COST do
                local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i)
                if itemLink then
                    usedCurrencies = usedCurrencies + 1
                    local btn = _G[frameName.."Item"..usedCurrencies]
                    if btn and btn:IsShown() then
                        local num
                        if showItemInfo then
                            if currencyName then
                                num= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink).quantity
                            else
                                num= C_Item.GetItemCount(itemLink, true, false, true)
                            end
                        end
                        if itemValue and num then
                            if num>=itemValue then
                                num= '|cnGREEN_FONT_COLOR:'..WoWTools_DataMixin:MK(num,0)..'|r'
                            else
                                num= '|cnWARNING_FONT_COLOR:'..WoWTools_DataMixin:MK(num,0)..'|r'
                            end
                        end

if not btn.quantityAll then
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

                        btn.quantityAll.itemValue= itemValue
                        btn.quantityAll:SetText(num or '')
                    end
                end
            end
        end
    end)








    Init_SetItem_Info= function()end
end


























--堆叠,数量,框架 StackSplitFrame.lua
local function Init_StackSplitFrame()
    local rest= CreateFrame('Button', 'WoWToolsStackSplitFrameRestButton', StackSplitFrame, 'WoWToolsButtonTemplate') --WoWTools_ButtonMixin:Cbtn(StackSplitFrame, {size=22})--重置
    rest:SetPoint('TOP')
    rest:SetNormalAtlas('characterundelete-RestoreButton')
    rest:SetScript('OnClick', function(self)
        local f= self:GetParent()
        f.split= f.minSplit
        f.LeftButton:SetEnabled(false)
        f.RightButton:SetEnabled(true)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    rest:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重置' or RESET)
        GameTooltip:Show()
    end)
    rest:SetScript('OnLeave', GameTooltip_Hide)

    local maxButton= CreateFrame('Button', 'WoWToolsStackSplitFrameMaxButton', StackSplitFrame, 'WoWToolsButtonTemplate')--WoWTools_ButtonMixin:Cbtn(StackSplitFrame, {size={40,20}})
    --maxButton:SetSize(40, 20)

    maxButton:SetNormalFontObject('NumberFontNormalYellow')
    maxButton:SetPoint('LEFT', rest, 'RIGHT')
    maxButton:SetScript('OnClick', function(self)
        local f= self:GetParent()
        f.split=f.maxStack
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

   local meta= CreateFrame('Button', 'WoWToolsStackSplitFrameMetaButton', StackSplitFrame, 'WoWToolsButtonTemplate')--WoWTools_ButtonMixin:Cbtn(StackSplitFrame, {size={40,20}})
   meta:SetNormalFontObject('NumberFontNormalYellow')
   meta:SetPoint('RIGHT', rest, 'LEFT')
   meta:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=floor(f.maxStack/2)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    local edit=CreateFrame('EditBox', 'WoWToolsStackSplitFrameEditBox', StackSplitFrame)--输入框
    edit:SetSize(100, 23)
    edit:SetPoint('TOPLEFT', 38, -18)
    edit:SetTextColor(0,1,0)
    edit:SetAutoFocus(false)
    edit:ClearFocus()
    edit:SetFontObject("ChatFontNormal")
    edit:SetMultiLine(false)
    edit:SetNumeric(true)
    --edit:SetScript('OnEditFocusLost', function(self) self:SetText('') end)
    edit:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    edit:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)
    edit:SetScript('OnHide', function(self) self:SetText('') self:ClearFocus() end)
    edit:SetScript('OnTextChanged',function(self, userInput)
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
    StackSplitFrame:HookScript('OnMouseWheel', function(self, d)
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


    WoWTools_DataMixin:Hook(StackSplitFrame, 'OpenStackSplitFrame', function(self)
        _G['WoWToolsStackSplitFrameMaxButton']:SetText(self.maxStack)
        _G['WoWToolsStackSplitFrameMetaButton']:SetText(floor(self.maxStack/2))
    end)

--缩放
    local menu= CreateFrame('DropdownButton', 'WoWToolsStackSplitFrameMenuButton', StackSplitFrame, 'WoWToolsMenuButtonTemplate')
    menu:SetSize(16,16)
    menu:SetNormalAtlas('mechagon-projects')
    menu:SetPoint('TOPLEFT', 5, 0)
    function menu:set_scale()
        self:GetParent():SetScale(Save().StackSplitScale or 1)
    end
    menu:set_scale()
    menu:SetupMenu(function(self, root)
        WoWTools_MenuMixin:Scale(self, root, function()
            return Save().StackSplitScale or 1
        end, function(value)
            Save().StackSplitScale= value
            self:set_scale()
        end)
--打开选项界面
        root:CreateDivider()
        WoWTools_MenuMixin:OpenOptions(root, {
            name=WoWTools_MerchantMixin.addName,
            name2='|A:communities-icon-addgroupplus:0:0|a'..(WoWTools_DataMixin.onlyChinese and '商人 Plus' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MERCHANT, 'Plus'))
        })
    end)

    Init_StackSplitFrame=function()end
end









function WoWTools_MerchantMixin:Plus_ItemInfo()
    if Save().notPlus then
        return
    end
    Init_UI()--移去 UI
    Init_SetItem_Info()--物品，信息
    Init_StackSplitFrame()--堆叠,数量,框架
end
