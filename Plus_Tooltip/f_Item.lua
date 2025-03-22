--设置,物品信息
local e= select(2, ...)











local function Set_Equip(tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, col)
    local textLeft, text2Left
--装等
    itemLevel= itemLink and C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel
    if itemLevel and itemLevel>1 then
--比较装等
        local slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
        if slot then
            local slotTexture= select(2, WoWTools_ItemMixin:GetEquipSlotIcon(slot))
            if slotTexture then
                tooltip.Portrait:SetTexture(slotTexture)
                tooltip.Portrait:SetShown(true)
            end
--栏位
            tooltip:AddDoubleLine(
                (WoWTools_TextMixin:CN(_G[itemEquipLoc]) or '')..' '..(itemEquipLoc or ''),
                ( WoWTools_Mixin.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..slot
            )
            local slotLink=GetInventoryItemLink('player', slot)
            local text
            if slotLink then
                local slotItemLevel= C_Item.GetDetailedItemLevelInfo(slotLink)
                if slotItemLevel then
                    local num=itemLevel-slotItemLevel
                    if num>0 then
                        text=itemLevel..'|A:bags-greenarrow:0:0|a'..'|cnGREEN_FONT_COLOR:+'..num..'|r'
                    elseif num<0 then
                        text=itemLevel..'|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..'|cnRED_FONT_COLOR:'..num..'|r'
                    end
                end
            else
                text=itemLevel..'|A:bags-greenarrow:0:0|a'
            end
            text= col..(text or itemLevel)..'|r'
            textLeft=text
        end
    end

    local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemLink or itemID)--幻化
    local visualID
    if sourceID then
        local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
        if sourceInfo then
            visualID=sourceInfo.visualID
            text2Left=sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        end
    end
    WoWTools_TooltipMixin:Set_Item_Model(tooltip, {itemID=itemID, sourceID=sourceID, appearanceID=appearanceID, visualID=visualID})--设置, 3D模型

    if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
        tooltip.Portrait:SetAtlas('greatVault-lock')
    end

--专精图标
    local specTable = itemLink and C_Item.GetItemSpecInfo(itemLink)
    if specTable and #specTable>0 then
        local player=''
        local other=''
        local otherTab={}

        for _, specID in pairs(specTable) do
            local icon2, _, classFile=select(4, GetSpecializationInfoByID(specID))
            if classFile and icon2 then


                if WoWTools_DataMixin.Player.Class==classFile then
                    player=player..'|T'..icon2..':0|t'

                elseif not otherTab[classFile] then
                    other= other..(WoWTools_UnitMixin:GetClassIcon(nil, classFile, false) or '')
                    --otherTab[classFile]= true
                end
            end
        end
        otherTab=nil

        tooltip:AddDoubleLine(player or ' ', other)
    end
    -- tooltip:Show()

    return textLeft, text2Left
end

















local function Set_keystonee(tooltip)
    local textLeft, text2Left

    for guid, info in pairs(e.WoWDate or {}) do
        if guid and guid~=WoWTools_DataMixin.Player.GUID and info.Keystone.link then
            WoWTools_WeekMixin:KeystoneScorsoColor(info.Keystone.score, false, nil)
            tooltip:AddDoubleLine(
                (info.Keystone.weekNum==0 and '|cff9e9e9e0|r' or info.Keystone.weekNum or '')
                ..(info.Keystone.weekMythicPlus and '|cnGREEN_FONT_COLOR:('..info.Keystone.weekMythicPlus..') ' or '')
                ..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})
                ..WoWTools_WeekMixin:KeystoneScorsoColor(info.Keystone.score, false, nil)..(WoWTools_WeekMixin:KeystoneScorsoColor(info.Keystone.score,true)),
                info.Keystone.link)
        end
    end
    local text=WoWTools_WeekMixin:GetRewardText(1)--得到，周奖励，信息
    --[[
    for _, activities in pairs(C_WeeklyRewards.GetActivities(1) or {}) do--本周完成
        if activities.level and activities.level>=0 and activities.type==1 then--Enum.WeeklyRewardChestThresholdType.MythicPlus 1
            text= (text and text..'/' or '')..activities.level
        end
    end]]

    local score= WoWTools_WeekMixin:KeystoneScorsoColor(C_ChallengeMode.GetOverallDungeonScore(), true)
    if text or score then
        textLeft=(text and '|cnGREEN_FONT_COLOR:'..text..'|r ' or '')..(score or '')
    end

    local info = C_MythicPlus.GetRunHistory(false, true) or {}--本周记录
    local num= 0
    local completedNum=0
    for _, runs  in pairs(info) do
        if runs and runs.level then
            num= num+ 1
            if runs.completed then
                completedNum= completedNum +1
            end
        end
    end
    if num>0 then
        text2Left=num..'|cnGREEN_FONT_COLOR:('..completedNum..')|r'
    end

    return textLeft, text2Left
end



local function Set_Player(tooltip, itemID)
    --local wowNum= 0--WoW 数量    
    local bag= C_Item.GetItemCount(itemID, false, false, false, false)--物品数量
    local bank= C_Item.GetItemCount(itemID, true, false, true, false) --bank
    local net= C_Item.GetItemCount(itemID, false, false, false, true)--战团
    bank= bank- bag
    net= net-bag

    tooltip.textRight:SetText(
        (net==0 and '|cff9e9e9e' or '|cff00ccff')..WoWTools_Mixin:MK(net, 3)..'|r|A:questlog-questtypeicon-account:0:0|a '
        ..(bank==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..WoWTools_Mixin:MK(bank, 3)..'|r|A:Banker:0:0|a '
        ..(bag==0 and '|cff9e9e9e' or '|cffffffff')..WoWTools_Mixin:MK(bag, 3)..'|r|A:bag-main:0:0|a'
    )

end
















local function Set_Item_Num(tooltip, itemID)
    local bagAll,bankAll,numPlayer=0,0,0--帐号数据
    local new={}

    for guid, info in pairs(e.WoWDate or {}) do
        local tab=info.Item[itemID]
        if tab and guid and guid~=WoWTools_DataMixin.Player.GUID then
            if tab.bag>0 or tab.bank>0 then
                table.insert(new, {
                    guid= guid,
                    faction= info.faction,
                    bag= tab.bag,
                    bank= tab.bank,
                    num= tab.bag+tab.bank,
                })
                bagAll=bagAll +tab.bag
                bankAll=bankAll +tab.bank
                numPlayer=numPlayer +1
            end
        end
    end

    if numPlayer>0 then
        tooltip:AddLine(' ')

        table.sort(new, function(n1, n2) return n1.num> n2.num end)

        for index, info in pairs(new) do
            local col= select(5, WoWTools_UnitMixin:Get_Unit_Color(nil, info.guid))

            tooltip:AddDoubleLine(
                WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {faction=info.faction, reName=true, reRealm=true}),

                (info.bank==0 and '|cff9e9e9e' or col)..WoWTools_Mixin:MK(info.bank, 3)..'|r|A:Banker:0:0|a '
                ..(info.bag==0 and '|cff9e9e9e' or col)..WoWTools_Mixin:MK(info.bag, 3)..'|r|A:bag-main:0:0|a'
            )

            if index>4 then
                break
            end
        end

    end

    if numPlayer>1 then
        tooltip:AddDoubleLine(
            numPlayer..WoWTools_DataMixin.Icon.wow2..(WoWTools_Mixin.onlyChinese and '角色' or CHARACTER)..' '..WoWTools_Mixin:MK(bagAll+bankAll, 3),

           WoWTools_Mixin:MK(bankAll,3)..'|A:Banker:0:0|a '
        ..WoWTools_Mixin:MK(bagAll, 3)..'|A:bag-main:0:0|a'
        )
    end
end



















function WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    if not itemLink and not itemID then
        return
    end

    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, classID, subclassID, bindType, expacID, setID =  C_Item.GetItemInfo(itemLink or itemID)
    itemID= itemID or WoWTools_ItemMixin:GetItemID(itemLink)
    if not itemID then
        return
    end

    local r, g, b, col= 1,1,1,WoWTools_DataMixin.Player.col
    if itemQuality then
        r, g, b, col= C_Item.GetItemQualityColor(itemQuality)
        col=col and '|c'..col
    end

    tooltip:AddLine(' ')

    local text2Left, textLeft


--版本数据, 图标，名称，版本
    if expacID or setID then
        tooltip:AddDoubleLine(
            WoWTools_Mixin:GetExpansionText(expacID, nil) or '  ',
            setID and 'setID '..setID
        )
    end

    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID or itemLink)

--itemID,  图标
    tooltip:AddDoubleLine(
        'itemID '..itemID,
        itemTexture and '|T'..itemTexture..':0|t'..itemTexture
    )

--物品，类型
    if classID and subclassID then
        tooltip:AddDoubleLine(
            (WoWTools_TextMixin:CN(itemType) or 'itemType')..' '..classID,
            (WoWTools_TextMixin:CN(itemSubType) or 'itemSubType')..' '..subclassID
        )
    end

    if classID==2 or classID==4 then
        textLeft, text2Left= Set_Equip(tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, col)

    elseif C_ToyBox.GetToyInfo(itemID) then--玩具
        text2Left= PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'

    elseif itemID==122284 then
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            textLeft='|A:token-choice-wow:0:0|a'..C_CurrencyInfo.GetCoinTextureString(price)
        end

    else
        local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if mountID then
            WoWTools_TooltipMixin:Set_Mount(tooltip, mountID, 'item')--坐骑
        elseif speciesID then
            WoWTools_TooltipMixin:Set_Pet(tooltip, speciesID)--宠物
        else
        end
    end

    if itemQuality==0 and(classID==2 or classID==15) then
        local petText= WoWTools_CollectedMixin:GetPet9Item(itemID)--宠物兑换, wow9.0
        if petText then
            tooltip:AddLine(petText)
        end
    end

    local spellName, spellID = C_Item.GetItemSpell(itemID)--物品法术
    if spellName and spellID then
        local spellTexture= C_Spell.GetSpellTexture(spellID)
        tooltip:AddDoubleLine((itemName~=spellName and '|cff71d5ff['..spellName..']|r' or '')..(WoWTools_Mixin.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':0|t'..spellTexture or ' ')
    end


    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        textLeft, text2Left= Set_keystonee(tooltip)
    else
        Set_Item_Num(tooltip, itemID)
    end

    Set_Player(tooltip, itemID)

    --setItemCooldown(tooltip, itemID)--物品冷却

    tooltip.textLeft:SetText(textLeft or '')
    tooltip.text2Left:SetText(text2Left or '')
    

    tooltip.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    tooltip.backgroundColor:SetShown(true)

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='item', id=itemID, name=itemName, col=col, isPetUI=false})--取得网页，数据链接


    --tooltip:Show()
end

