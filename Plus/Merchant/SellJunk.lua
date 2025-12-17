local function Save()
    return WoWToolsSave['Plus_SellBuy']
end











--自动出售
local function Init()
    local AutoSellJunkCheck=CreateFrame('CheckButton', 'WoWTools_AutoSellJunkCheck', MerchantSellAllJunkButton, "InterfaceOptionsCheckButtonTemplate")
    AutoSellJunkCheck:SetSize(18,18)
    AutoSellJunkCheck:SetPoint('BOTTOMLEFT', MerchantSellAllJunkButton, -4,-5)

    function AutoSellJunkCheck:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_MerchantMixin.addName)
        --GameTooltip:AddLine('|A:Cursor_lootall_128:0:0|a'..(WoWTools_DataMixin.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus')
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '自动出售垃圾' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SELL_ALL_JUNK_ITEMS_EXCLUDE_HEADER), WoWTools_TextMixin:GetEnabeleDisable(not Save().notSellJunk))
        if not Save().notSellJunk then
            GameTooltip:AddLine(format(
                WoWTools_DataMixin.onlyChinese and '品质：%s' or PROFESSIONS_CRAFTING_QUALITY,
                WoWTools_ItemMixin.QualityText[0]
            ))
        end
        GameTooltip:Show()
    end
    function AutoSellJunkCheck:settings()
        self:SetChecked(not Save().notSellJunk)
        self:set_sell_junk()--出售物品
    end
    AutoSellJunkCheck:SetScript('OnClick', function(self)
        Save().notSellJunk= not Save().notSellJunk and true or nil
        self:settings()
        self:set_tooltip()
    end)
    AutoSellJunkCheck:SetScript('OnLeave', GameTooltip_Hide)--self:SetAlpha(0.3)
    AutoSellJunkCheck:SetScript('OnEnter', AutoSellJunkCheck.set_tooltip)


    function AutoSellJunkCheck:set_sell_junk()--出售物品
        if IsModifierKeyDown()
            or not C_MerchantFrame.IsSellAllJunkEnabled()
            or InCombatLockdown()
            or MerchantFrame.selectedTab~=1
        then
            return
        end

        local Sell, notSellCustom= WoWToolsPlayerDate['SellBuyItems'].sell, Save().notSellCustom
        local num, gruop, preceTotale= 0, 0, 0

        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
                local info = C_Container.GetContainerItemInfo(bag,slot)

                if IsModifierKeyDown()
                    or InCombatLockdown()
                    or MerchantFrame.selectedTab~=1
                then
                    print(
                        WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_DataMixin.onlyChinese and '中断' or INTERRUPT
                    )
                    return

                elseif info
                    and info.hyperlink
                    and info.itemID
                    and info.quality
                    and (info.quality<Enum.ItemQuality.Legendary or Sell[info.itemID] and not notSellCustom)
                then
                    local checkText= WoWTools_MerchantMixin:CheckSellItem(info.itemID, info.hyperlink, info.quality, info.isBound)--检察 ,boss掉落, 指定 或 出售灰色,宠物
                    if not info.isLocked and checkText then

                        do
                            C_Container.UseContainerItem(bag, slot)--买出
                        end

                        local prece =0
                        if not info.hasNoValue then--卖出钱
                            prece = (select(11, C_Item.GetItemInfo(info.hyperlink)) or 0) * (info.stackCount or 1)--价格
                            preceTotale = preceTotale + prece
                        end
                        gruop= gruop+ 1
                        num= num+ (info.stackCount or 1)--数量

                        print(
                            '|cnWARNING_FONT_COLOR:'..gruop..')|r',
                            checkText or '',
                            info.hyperlink,
                            C_CurrencyInfo.GetCoinTextureString(prece)
                        )

                        if gruop>= 11 then
                            break
                        end
                    end
                    if gruop>= 11 then
                        break
                    end
                end
            end
        end

        if num > 0 then
            print(
                WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,

                (WoWTools_DataMixin.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)
                ..' |cnGREEN_FONT_COLOR:'..gruop..'|r'
                ..(WoWTools_DataMixin.onlyChinese and '组' or AUCTION_PRICE_PER_STACK),

                '|cnGREEN_FONT_COLOR:'..num..'|r'..(WoWTools_DataMixin.onlyChinese and '件' or AUCTION_HOUSE_QUANTITY_LABEL),
                C_CurrencyInfo.GetCoinTextureString(preceTotale)
            )
        end
    end



    AutoSellJunkCheck:RegisterEvent('MERCHANT_SHOW')
    AutoSellJunkCheck:SetScript('OnEvent', function(self)
        self:set_sell_junk()
    end)

    AutoSellJunkCheck:SetChecked(not Save().notSellJunk)

--提示，垃圾，数量
    MerchantSellAllJunkButton:HookScript('OnEnter', function()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '垃圾' or BAG_FILTER_JUNK , '|cnGREEN_FONT_COLOR:'..(C_MerchantFrame.GetNumJunkItems() or 0))
        GameTooltip:Show()
    end)
    MerchantSellAllJunkButton.Text= WoWTools_LabelMixin:Create(MerchantSellAllJunkButton, {justifyH='RIGHT'})
    MerchantSellAllJunkButton.Text:SetPoint('BOTTOM',MerchantSellAllJunkButton, 'TOP', 0, -6)
    WoWTools_DataMixin:Hook('MerchantFrame_Update', function()
        if not MerchantSellAllJunkButton:IsVisible() then
            return
        end
        local num= C_MerchantFrame.GetNumJunkItems() or 0
        MerchantSellAllJunkButton.Text:SetText((num==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:')..num)
    end)
end














local Frame= CreateFrame('Frame')
Frame:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
Frame:SetScript("OnEvent", function(_, event, _, itemID, itemLink, _, playerName)--encounterID, itemID, itemLink, quantity, playerName, classFileName
    if event=='ENCOUNTER_LOOT_RECEIVED' then--买出BOOS装备
        if IsInInstance() and  (playerName and playerName:find(UnitName('player')) or not IsInGroup()) then
            local _, _, itemQuality, itemLevel, _, _, _, _, itemEquipLoc, _, _, classID, subclassID, bindType, expansionID = C_Item.GetItemInfo(itemLink)
            itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel

            local avgItemLevel= GetAverageItemLevel() or 30
            local other= classID==15 and subclassID==0

            if itemEquipLoc--绑定
                and itemQuality and itemQuality<=4--最高史诗
                and (classID==2 or classID==3 or classID==4 or other)--2武器 3宝石 4盔甲
                and bindType == Enum.ItemBind.OnAcquire--1     LE_ITEM_BIND_ON_ACQUIRE    拾取绑定
                and (
                        (itemLevel and itemLevel>1 and avgItemLevel-itemLevel>=30)
                        or (WoWTools_DataMixin.Player.isMaxLevel and expansionID and expansionID<WoWTools_DataMixin.ExpansionLevel)--旧版本
                    )
                and not WoWToolsPlayerDate['SellBuyItems'].noSell[itemID]
            then

                if other then
                    local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=itemLink, red=true, onlyRed=true})--物品提示，信息
                    if not dateInfo.red then
                        return
                    end
                end

                Save().bossItems[itemID]= itemLevel

                if not Save().notSellBoss then
                    print(
                        WoWTools_MerchantMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_DataMixin.onlyChinese and '添加出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, AUCTION_HOUSE_SELL_TAB),
                        itemLink or itemID
                    )
                end

            end
        end
    end
end)













--自动出售
function WoWTools_MerchantMixin:Init_Auto_Sell_Junk()
    Init()
end