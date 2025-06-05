--[[
GetTooltip
GetLink
GetColor return color.r, color.g, color.b, color.hex, color
GetName(itemID)--取得物品，名称
GetSlotIcon
]]
WoWTools_ItemMixin={}










local ColorRed={
    ['ffff2020']=1,
    ['fefe1f1f']=1,
}


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
            --print(leftHex, '|c'..leftHex..line.leftText)
            if ColorRed[leftHex] then-- or hex=='fefe7f3f' then
                data.red= line.leftText
            elseif ColorRed[rightHex] then--== 'ffff2020' or rightHex=='fefe1f1f' then
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
        or ((tab.itemID or tab.itemLink)
            and C_Item.GetItemQualityByID(tab.itemLink or tab.itemID)
        )
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
            WoWTools_Mixin:Load({id=itemID, type='item'})
            local name= WoWTools_TextMixin:CN(nil, {itemID=itemID, isName=true})
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





function WoWTools_ItemMixin:GetName(itemID, itemLink, itemLocation, tab)--取得物品，名称 itemLocation,ItemButton
    tab= tab or {}

    local disableCount= tab.notCount

    itemID= itemID or self:GetItemID(itemLink)
    if itemLocation then
        itemID= itemID or itemLocation:GetItemID()
        itemLink= itemLink or itemLocation:GetItemLink()
    end
    if not itemID then
        return itemID or itemLink or itemLocation
    end

    local col, name, desc, cool
    WoWTools_Mixin:Load({id=itemID, type='item'})

    if C_ToyBox.GetToyInfo(itemID) then
        if not PlayerHasToy(itemID) then
            col='|cnRED_FONT_COLOR:'
            desc= '|A:Islands-QuestBangDisable:0:0|a'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)
        else
            cool= WoWTools_CooldownMixin:GetText(nil, itemID)
        end
    else
        if not disableCount then
            local num= C_Item.GetItemCount(itemID, true, false, true, true) or 0
            if num==0 then
                col='|cff9e9e9e'
            else
                cool= WoWTools_CooldownMixin:GetText(nil, itemID)
            end

            desc= ' x'..num..' '
        end
    end

    name= WoWTools_TextMixin:CN(C_Item.GetItemNameByID(itemID), {itemID=itemID,itemLink=itemLink, isName=true}) or ('itemID '..itemID)

    if name then
        if not name:find('|c') then
            local col2= select(4, self:GetColor(nil, {itemID=itemID, itemLink=itemLink}))
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
		return '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '你还不能那样做。' or ERR_CLIENT_LOCKED_OUT)..'|r'
	end
end



function WoWTools_ItemMixin:GetCount(itemID, tab)
    tab= tab or {}
    itemID= itemID
        or (tab.itemKey and tab.itemKey.itemID)
    --local isWoW= tab.isWoW

    if not itemID then
        return nil, 0, 0, 0, 0, 0
    end

    local zoro= not tab.notZero

    local wow= self:GetWoWCount(itemID)

    local bag= C_Item.GetItemCount(itemID, false, false, false, false) or 0--物品数量
    local bank= C_Item.GetItemCount(itemID, true, false, true, false) or 0--bank
    local net= C_Item.GetItemCount(itemID, false, false, false, true) or 0--战团
    bank= bank- bag
    net= net-bag

    local text
    if zoro or wow>0 then
        text= (wow==0 and '|cff9e9e9e' or '|cff00ccff')..WoWTools_Mixin:MK(wow, 3)..'|r'..WoWTools_DataMixin.Icon.wow2
    end
    if zoro or net>0 then
        text= (text and text..' ' or '')
            ..(net==0 and '|cff9e9e9e' or '|cff00ccff')..WoWTools_Mixin:MK(net, 3)..'|r|A:questlog-questtypeicon-account:0:0|a'
    end
    if zoro or bank>0 then
        text= (text and text..' ' or '')
            ..(bank==0 and '|cff9e9e9e' or '|cffffffff')..WoWTools_Mixin:MK(bank, 3)..'|r|A:Banker:0:0|a'
    end
    if zoro or bag>0 then
        text= (text and text..' ' or '')
            ..(bag==0 and '|cff9e9e9e' or '|cffffffff')..WoWTools_Mixin:MK(bag, 3)..'|r|A:bag-main:0:0|a'
    end

    return
        text,--1
        bag,--2
        bank,--3
        net,--4
        wow--5
end





function WoWTools_ItemMixin:GetWoWCount(itemID)--WoWTools_BagMixin:GetItem_WoW_Num()--取得WOW物品数量
    local all,numPlayer=0,0
    for guid, info in pairs(WoWTools_WoWDate) do
        if info.region==WoWTools_DataMixin.Player.Region and guid~=WoWTools_DataMixin.Player.GUID then
            if C_Item.IsItemKeystoneByID(itemID) and info.Keystone.link then--Keystone
                all=all +1
                numPlayer=numPlayer +1
            else
                local tab=info.Item[itemID]
                if tab and tab.bag and tab.bank then
                    all=all + tab.bag+ tab.bank
                    numPlayer=numPlayer +1
                end
            end
        end
    end
    return all, numPlayer
end
