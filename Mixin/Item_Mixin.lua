--[[
GetTooltip
GetLink
GetColor return color.r, color.g, color.b, color.hex, color
GetName(itemID)--取得物品，名称
]]


local e= select(2, ...)


WoWTools_ItemMixin={}

function WoWTools_ItemMixin:GetTooltip(tab)
    local tooltipData

    local bag= tab.bag--bag, slot
    local guidBank= tab.guidBank--tab, slot
    local merchant= tab.merchant--slot
    local inventory= tab.inventory
    local hyperLink= tab.hyperLink
    local itemKey= tab.itemKey

    local itemID= tab.itemID
    local quality= tab.quality

    local index= tab.index--取得，指定行，内容 leftText

    local text= tab.text--{内容1, 内容2}，取得指定内容，行
    local onlyText= tab.onlyText--仅查指定内容

    local wow= tab.wow--是否战网绑定,还回 atlas
    local onlyWoW= tab.onlyWoW--仅查战网绑定

    local red= tab.red--是否有红色字体，一般指 不可用
    local onlyRed= tab.onlyRed--仅查红色

    if bag then
        if bag.bag and bag.slot then
            tooltipData= C_TooltipInfo.GetBagItem(bag.bag, bag.slot)
        end

    elseif guidBank then-- guidBank then
        if guidBank.tab and guidBank.slot then
            tooltipData= C_TooltipInfo.GetGuildBankItem(guidBank.tab, guidBank.slot)
        end

    elseif merchant then
        if merchant.slot then
            if merchant.buyBack then
                tooltipData= C_TooltipInfo.GetBuybackItem(merchant.slot)
            else
                tooltipData= C_TooltipInfo.GetMerchantItem(merchant.slot)--slot
            end
        end

    elseif inventory then
        tooltipData= C_TooltipInfo.GetInventoryItem('player', inventory)

    elseif hyperLink then
        tooltipData=  C_TooltipInfo.GetHyperlink(hyperLink)
    elseif itemID then
        if C_Heirloom.IsItemHeirloom(itemID) then
            tooltipData= C_TooltipInfo.GetHeirloomByItemID(itemID)
        else
            tooltipData= C_TooltipInfo.GetItemByID(itemID, quality)
        end
    elseif itemKey then
        tooltipData= C_TooltipInfo.GetItemKey(itemKey.itemID, itemKey.itemLevel, itemKey.itemSuffix, itemKey.requiredLevel)
    end
    local data={
        red=false,
        wow=false,
        text={},
        indexText=nil,
    }
    if not tooltipData or not tooltipData.lines then
        return data

    elseif index then
        if tooltipData.lines[index] then
            data.indexText= tooltipData.lines[index].leftText
        end
        return data
    end

    local numText= text and #text or 0
    local findText= numText>0 or wow
    local numFind=0
    for _, line in ipairs(tooltipData.lines) do--是否 TooltipUtil.SurfaceArgs(line)
        if red and not data.red then
            local leftHex=line.leftColor and line.leftColor:GenerateHexColor()
            local rightHex=line.rightColor and line.rightColor:GenerateHexColor()
            if leftHex == 'ffff2020' or leftHex=='fefe1f1f' then-- or hex=='fefe7f3f' then
                data.red= line.leftText
            elseif rightHex== 'ffff2020' or rightHex=='fefe1f1f' then
                data.red= line.rightText
            end
            if onlyRed and data.red then
                break
            end
        end
        if line.leftText and findText then
            if text then
                for _, t in pairs(text) do
                    if t and (line.leftText:find(t) or line.leftText==t) then
                        data.text[t]= line.leftText:match(t) or line.leftText
                        numFind= numFind +1
                        if onlyText and numFind==numText then
                            break
                        end
                    end
                end
            end
            if wow and not data.wow then
                if line.leftText==ITEM_ACCOUNTBOUND--战团绑定
                    or line.leftText==ITEM_BNETACCOUNTBOUND
                    or line.leftText==ITEM_BIND_TO_BNETACCOUNT
                    or line.leftText==ITEM_BIND_TO_ACCOUNT
                    or line.leftText==ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP--装备前战团绑定
                    or line.leftText==ITEM_ACCOUNTBOUND_UNTIL_EQUIP--装备前战团绑定
                then
                    data.wow='|A:questlog-questtypeicon-account:0:0:a'
                    if onlyWoW then
                        break
                    end
                end
            end
        end
    end
    return data
end





--GetButtonOverlayQualityColor
function WoWTools_ItemMixin:GetColor(itemID, quality)
    quality= quality or (itemID and C_Item.GetItemQualityByID(itemID))
    local color= ITEM_QUALITY_COLORS[quality] or ITEM_QUALITY_COLORS[Enum.ItemQuality.Common]
    return color.r, color.g, color.b, color.hex, color, quality
end




--ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()
function WoWTools_ItemMixin:GetLink(itemID)
    local link
    if itemID then
        link= select(2, C_Item.GetItemInfo(itemID))
        if not link then
            e.LoadData({id=itemID, type='item'})
            local name= e.cn(nil, {itemID=itemID, isName=true})
            link= '|Hitem:'..itemID..'::::::::::::::::::|h['..(name or itemID)..']|h'
            if not name then
                local hex= select(4, self:GetColor(itemID, nil))
                if hex then
                    link= hex..link..'|r'
                end
            end
        end
    end
    return link
end









function WoWTools_ItemMixin:GetName(itemID)--取得物品，名称
    if not itemID then
        return
    end

    local col, name, desc, cool
    e.LoadData({id=itemID, type='item'})

    if C_ToyBox.GetToyInfo(itemID) then
        if not PlayerHasToy(itemID) then
            col='|cnRED_FONT_COLOR:'
            desc= '|A:Islands-QuestBangDisable:0:0|a'..(e.onlyChinese and '未收集' or NOT_COLLECTED)
        else
            cool= e.GetSpellItemCooldown(nil, itemID)
        end
    else
        local num= C_Item.GetItemCount(itemID, true, false, true, true) or 0
        if num==0 then
            col='|cff9e9e9e'
        else
            cool= e.GetSpellItemCooldown(nil, itemID)
        end
        desc= ' x'..num..' '
    end
    name= e.cn(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID '..itemID)
    if name then
        name= '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'..(name:match('|c........(.+)|r') or name)
    end


    if desc and col then
        desc= col..desc..'|r'
    end

    return name..(desc or '')..(cool or ''), col
end







--[[
	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemIDOrLink) then
		button.IconOverlay:SetAtlas("AzeriteIconFrame");

	elseif C_Item.IsCorruptedItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("Nzoth-inventory-icon");

	elseif C_Item.IsCosmeticItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("CosmeticIconFrame");

	elseif C_Soulbinds.IsItemConduitByItemInfo(itemIDOrLink) then
		button.IconOverlay:SetAtlas("ConduitIconFrame");

		if button.IconOverlay2 then
			button.IconOverlay2:SetAtlas("ConduitIconFrame-Corners");
			button.IconOverlay2:Show();
		end
	elseif C_Item.IsCurioItem(itemIDOrLink) then
		button.IconOverlay:SetAtlas("delves-curios-icon-border");
]]