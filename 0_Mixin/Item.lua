--[[
GetTooltip
GetLink
GetColor return color.r, color.g, color.b, color.hex, color
GetName(itemID)--取得物品，名称
GetSlotIcon
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





--GetButtonOverlayQualityColor {itemID, itemLocation}
function WoWTools_ItemMixin:GetColor(quality, tab)
    tab= tab or {}

    quality= quality
        or (tab.itemID and C_Item.GetItemQualityByID(tab.itemID))
        or (tab.itemLocation and C_Item.GetItemQuality(tab.itemLocation))

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



function WoWTools_ItemMixin:GetItemID(itemLink)
    local itemID
    if itemLink then
        itemID= C_Item.GetItemInfoInstant(itemLink)
        if not itemID then
            itemID = itemLink and itemLink:match("|H.-:(%d+).-|h")
            if itemID then
                itemID= tonumber(itemID)
            end
        end
    end
    return itemID
end





function WoWTools_ItemMixin:GetName(itemID, itemLink)--取得物品，名称
    itemID= itemID or self:GetItemID(itemLink)
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
        if not name:find('|c') then
            local col2= select(4, self:GetColor(itemID))
            if col2 then
                name= col2..name..'|r'
            end
        end
        name= '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'..name--(name:match('|c........(.+)|r') or name)
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














local itemSlotName={--InventorySlotId
    [1]= 'HEADSLOT',
    [2]= 'NECKSLOT',
    [3]= 'SHOULDERSLOT',
    [4]= 'SHIRTSLOT',
    [5]= 'CHESTSLOT',
    [6]= 'WAISTSLOT',
    [7]= 'LEGSSLOT',
    [8]= 'FEETSLOT',
    [9]= 'WRISTSLOT',
    [10]= 'HANDSSLOT',
    [11]= 'FINGER0SLOT',
    [12]= 'FINGER1SLOT',
    [13]= 'TRINKET0SLOT',
    [14]= 'TRINKET1SLOT',
    [15]= 'BACKSLOT',
    [16]= 'MAINHANDSLOT',
    [17]= 'SECONDARYHANDSLOT',
    [19]= 'TABARDSLOT',
}
local itemSlotTable={
    ['INVTYPE_HEAD']=1,
    ['INVTYPE_NECK']=2,
    ['INVTYPE_SHOULDER']=3,
    ['INVTYPE_BODY']=4,
    ['INVTYPE_ROBE']=5,
    ['INVTYPE_CHEST']=5,
    ['INVTYPE_WAIST']=6,
    ['INVTYPE_LEGS']=7,
    ['INVTYPE_FEET']=8,
    ['INVTYPE_WRIST']=9,
    ['INVTYPE_HAND']=10,
    ['INVTYPE_FINGER']={11,12},
    ['INVTYPE_TRINKET']={13,14},
    ['INVTYPE_CLOAK']=15,
    ['INVTYPE_SHIELD']=17,
    ['INVTYPE_RANGED']=16,
    ['INVTYPE_2HWEAPON']=16,
    ['INVTYPE_RANGEDRIGHT']=16,
    ['INVTYPE_WEAPON']={16,17},
    ['INVTYPE_WEAPONMAINHAND']=16,
    ['INVTYPE_WEAPONOFFHAND']=16,
    ['INVTYPE_THROWN']=16,
    ['INVTYPE_HOLDABLE']=17,
    ['INVTYPE_TABARD']=19,
    ['INVTYPE_PROFESSION_TOOL']={20,23},
    ['INVTYPE_PROFESSION_GEAR']={21, 22, 24, 25},
}

function WoWTools_ItemMixin:GetEquipSlotIcon(slotID)
    local invSlotName= itemSlotName[slotID]
    local texture= invSlotName and select(2, GetInventorySlotInfo(invSlotName))
    if texture then
        return format('|T%s:0:0|t', texture), texture
    end
end

--local invTypeNum = C_Item.GetItemInventoryTypeByID(itemID)
--local invType = C_Item.GetItemInventorySlotKey(invTypeNum)
function WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
    local slot= itemSlotTable[itemEquipLoc]
    if slot then
        if type(slot)=='table' then
            return slot[1], slot[2], slot[3], slot[4]
        else
            return slot
        end
    end
end











--装备管理，能否装备
--EquipmentManager.lua
function WoWTools_ItemMixin:IsCan_EquipmentSet(setID)--装备管理，能否装备
	if not setID or C_EquipmentSet.EquipmentSetContainsLockedItems(setID) or UnitCastingInfo("player") then
		return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '你还不能那样做。' or ERR_CLIENT_LOCKED_OUT)..'|r'
	end
end
