WoWTools_ItemStatsMixin={}

local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"








--local AndStr = COVENANT_RENOWN_TOAST_REWARD_COMBINER:format('(.-)','(.+)')--"%s 和 %s"
function WoWTools_ItemStatsMixin:Gem(frame, itemLink)--显示, 宝石, 属性
    local leftText, bottomLeftText
    if itemLink then
        local dateInfo
        if WoWTools_DataMixin.Is_Timerunning then
            dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=itemLink, index=3})--物品提示，信息
        else
            dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=itemLink, text={'(%+.+)', }})--物品提示，信息
        end
        local text= dateInfo.text['(%+.+)'] or dateInfo.indexText

        if text then
            text= string.lower(text)

            for name, name2 in pairs(WoWTools_DataMixin.StausText) do
                --print(string.lower(name), name2, text:find(string.lower(name)), text)
                if text:find(string.lower(name)) then
                    if not leftText then
                        leftText= '|cffffffff'..name2..'|r'
                    elseif not bottomLeftText then
                        bottomLeftText='|cffffffff'..name2..'|r'
                        --break
                    end
                end
            end
            if text:find(('%+(.+)')) then--+护甲
                leftText= leftText or WoWTools_TextMixin:sub(text:gsub('%+', ''), 1, 3, true)
                --bottomLeftText= bottomLeftText or text:match('(.-%+)')
            end
        end
    end

    if frame then
        if leftText and not frame.leftText then
            frame.leftText= WoWTools_LabelMixin:Create(frame, {size=10})
            frame.leftText:SetPoint('LEFT')
        end
        if frame.leftText then
            frame.leftText:SetText(leftText or '')
        end
        if bottomLeftText and not frame.bottomLeftText then
            frame.bottomLeftText= WoWTools_LabelMixin:Create(frame, {size=10})
            frame.bottomLeftText:SetPoint('BOTTOMLEFT')
        end
        if frame.bottomLeftText then
            frame.bottomLeftText:SetText(bottomLeftText or '')
        end
    end
    return leftText, bottomLeftText
end



















function WoWTools_ItemStatsMixin:GetItem(link)--取得，物品，次属性，表
    if not link then
        return {}
    end
    local num, tab= 0, {}
    local info= C_Item.GetItemStats(link) or {}
    if info['ITEM_MOD_CRIT_RATING_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_CRIT_RATING_SHORT], value=info['ITEM_MOD_CRIT_RATING_SHORT'] or 1, index=1})
        num= num +1
    end
    if info['ITEM_MOD_HASTE_RATING_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_HASTE_RATING_SHORT], value=info['ITEM_MOD_HASTE_RATING_SHORT'] or 1, index=1})
        num= num +1
    end
    if info['ITEM_MOD_MASTERY_RATING_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_MASTERY_RATING_SHORT], value=info['ITEM_MOD_MASTERY_RATING_SHORT'] or 1, index=1})
        num= num +1
    end
    if info['ITEM_MOD_VERSATILITY'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_VERSATILITY], value=info['ITEM_MOD_VERSATILITY'] or 1, index=1})
        num= num +1
    end
    if num<4 and info['ITEM_MOD_CR_AVOIDANCE_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_CR_AVOIDANCE_SHORT], value=info['ITEM_MOD_CR_AVOIDANCE_SHORT'], index=2})
        num= num +1
    end
    if num<4 and info['ITEM_MOD_CR_LIFESTEAL_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_CR_LIFESTEAL_SHORT], value=info['ITEM_MOD_CR_LIFESTEAL_SHORT'] or 1, index=2})
        num= num +1
    end
    if num<4 and info['ITEM_MOD_CR_SPEED_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_CR_SPEED_SHORT], value=info['ITEM_MOD_CR_SPEED_SHORT'] or 1, index=2})
        num= num +1
    end
    --[[if num<4 and info['ITEM_MOD_EXTRA_ARMOR_SHORT'] then
        table.insert(tab, {text=WoWTools_DataMixin.StausText[ITEM_MOD_EXTRA_ARMOR_SHORT], value=info['ITEM_MOD_EXTRA_ARMOR_SHORT'] or 1, index=2})
        num= num +1
    end]]
    table.sort(tab, function(a,b) return a.value>b.value and a.index== b.index end)
    return tab
end










--WoWTools_ItemStatsMixin:SetItem(frame, itemLink, {point=frame.icon, itemID=nil, hideSet=false, hideLevel=false, hideStats=false})--设置，物品，4个次属性，套装，装等，
function WoWTools_ItemStatsMixin:SetItem(frame, link, setting) --设置，物品，次属性，表
    if not frame then
        return
    end
    local setID, itemLevel
    setting= setting or {}

    local hideSet= setting.hideSet
    local point= setting.point or frame
    local hideLevel= setting.hideLevel
    local itemID= setting.itemID
    local hideStats= setting.hideStats

    if link then
        local itemID2, _, _, _, _, classID= C_Item.GetItemInfoInstant(link)
        if classID==2 or classID==4 then
            itemID= itemID or itemID2
        else
            link=nil
        end
    end
    if link then
        if not hideSet then
            setID= select(16 , C_Item.GetItemInfo(link))--套装
            if setID and not frame.itemSet then
                frame.itemSet= frame:CreateTexture()
                frame.itemSet:SetAtlas('UI-HUD-MicroMenu-Highlightalert')--'UI-HUD-MicroMenu-Highlightalert')--services-icon-goldborder
                frame.itemSet:SetAllPoints(point)
                frame.itemSet:SetAlpha(0.7)
            end
        end

        if not hideLevel then--物品, 装等
            if itemID==210333 and frame==CharacterBackSlot then--InspectBackSlot
                local currencies={--https://wago.io/thread_count
                    [2853] = 1, -- "power" aka str/agi/int
                    [2854] = 0.5, -- stamina (1 thread gives 2 of this stat)
                    [2855] = 1, -- crit
                    [2856] = 1, -- haste
                    [2857] = 1, -- leech
                    [2858] = 1, -- mastery
                    [2859] = 1, -- speed
                    [2860] = 1, -- vers
                    -- 2861-2869 are currencies which seem to be modifiers for damage(?) against different creature types (i.e. humanoid, undead, elemental, etc)
                    -- 2870-2876 are currencies which seem to be modifiers for damage (resist?) of the various spell schools (i.e. physical, arcane, fire, etc)
                    [3001] = 1, -- xp gain
                }
                local count = 0
                for currencyID, mult in pairs(currencies) do
                    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
                    if info and info.quantity and info.quantity>0 then
                        count = count + info.quantity*mult
                    end
                end
                if count>0 then
                    itemLevel= WoWTools_Mixin:MK(count, 1)
                end
            else
                --local quality = C_Item.GetItemQualityByID(link)--颜色
                --if quality==7 then
                local dataInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=link, itemID= itemID or C_Item.GetItemInfoInstant(link), text={itemLevelStr}, onlyText=true})--物品提示，信息
                if dataInfo.text[itemLevelStr] then
                    itemLevel= tonumber(dataInfo.text[itemLevelStr])
                end

                itemLevel= itemLevel or C_Item.GetDetailedItemLevelInfo(link)
                if itemLevel and itemLevel>3 then
                    local avgItemLevel= select(2, GetAverageItemLevel())--已装备, 装等
                    if avgItemLevel then
                        local lv = itemLevel- avgItemLevel
                        if lv <= -6  then
                            itemLevel =RED_FONT_COLOR_CODE..itemLevel..'|r'
                        elseif lv>=7 then
                            itemLevel= GREEN_FONT_COLOR_CODE..itemLevel..'|r'
                        else
                            itemLevel='|cffffffff'..itemLevel..'|r'
                        end
                    end
                else
                    itemLevel=nil
                end
            end
            if not frame.itemLevel and itemLevel then
                frame.itemLevel= WoWTools_LabelMixin:Create(frame, {justifyH='CENTER'})
                frame.itemLevel:SetShadowOffset(2,-2)
                frame.itemLevel:SetPoint('CENTER', point)
            end
        end
    end

    if frame.itemSet then frame.itemSet:SetShown(setID) end--套装
    if frame.itemLevel then frame.itemLevel:SetText(itemLevel or '') end--装等

    local tab= not hideStats and self:GetItem(link) or {}--物品，次属性，表
    for index=1 ,4 do
        local text=frame['statText'..index]
        if tab[index] then
            if not text then
                text= WoWTools_LabelMixin:Create(frame, {justifyH= (index==2 or index==4) and 'RIGHT'})
                if index==1 then
                    text:SetPoint('BOTTOMLEFT', point, 'BOTTOMLEFT')
                elseif index==2 then
                    text:SetPoint('BOTTOMRIGHT', point, 'BOTTOMRIGHT', 4,0)
                elseif index==3 then
                    text:SetPoint('TOPLEFT', point, 'TOPLEFT')
                else
                    text:SetPoint('TOPRIGHT', point, 'TOPRIGHT',4,0)
                end
                frame['statText'..index]=text
            end
            text:SetText(tab[index].text)
        elseif text then
            text:SetText('')
        end
    end
end



