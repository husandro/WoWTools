--设置,物品信息
--[[
if LOCALE_zhCN then
    function BreakUpLargeNumbers(value)
        return WoWTools_DataMixin:MK(value, 3)
    end
end
FIRST_NUMBER = "千";
SECOND_NUMBER = "万";
THIRD_NUMBER = "亿"

--TooltipComparisonManager:SetItemTooltip(

]]

local function Set_Value_Text(line)
    local text= line and line:GetText()
    if not text or text=='' or text==' ' then
        return
    end

    local t= text:gsub('%d+', function(v)
        v=tonumber(v)
        if v>=1000 then
            return WoWTools_DataMixin:MK(v, 3)
        end
    end)

    t= t:gsub('%d+,%d%d%d', function(v)
        local a,b= v:match('(%d+),(%d%d%d)')
        v= tonumber(a..b)
        return WoWTools_DataMixin:MK(v, 3)
    end)

    t= t:gsub('%d+ '..SECOND_NUMBER, function(v)--千
        local a= v:match('(%d+)')
        v= tonumber(a..'000')
        return WoWTools_DataMixin:MK(v, 3)
    end)

    t= t:gsub('%d+ '..SECOND_NUMBER, function(v)--万
        local a= v:match('(%d+)')
        v= tonumber(a..'0000')
        return WoWTools_DataMixin:MK(v, 3)
    end)

    t= t:gsub('%d+ '..THIRD_NUMBER, function(v)--亿
        local a= v:match('(%d+)')
        v= tonumber(a..'00000000')
        return WoWTools_DataMixin:MK(v, 3)
    end)

    if t~=text then
        line:SetText(t)
    end
end

local function Set_Value(tooltip)
    local name= tooltip:GetName() or 'GameTooltip'
    for i=5, tooltip:NumLines() or 0, 1 do
        Set_Value_Text(_G[name..'TextLeft'..i])
        Set_Value_Text(_G[name..'TextRight'..i])
    end
end





local function Get_SlotLevel(slot)
    local level
    for _, slotID in ipairs(slot) do
        local itemLink= GetInventoryItemLink('player', slotID)
        if itemLink then
            local itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or 0
            if itemLevel>1 then
                level= (not level or itemLevel<level) and itemLevel or level
            end
        end
    end
    return level or 0
end


local function Set_Equip(self, tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, col)
    local textLeft, text2Left
--装等
    itemLevel= itemLink and C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel
    local portrait
    if itemLevel and itemLevel>1 then
--比较装等
        local slot= {WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)}
        if slot[1] then
            local slotTexture= select(2, WoWTools_ItemMixin:GetEquipSlotIcon(slot[1]))
            if slotTexture then
                portrait=slotTexture
            end
--栏位
            tooltip:AddDoubleLine(
                (WoWTools_TextMixin:CN(_G[itemEquipLoc]) or '')..' |cffffffff'..(itemEquipLoc or ''),
                ( WoWTools_DataMixin.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' |cffffffff'..slot[1]
            )

            local slotItemLevel= Get_SlotLevel(slot)

            local text
            if slotItemLevel>0 then
                local num=itemLevel-slotItemLevel
                if num>0 then
                    text=itemLevel..'|A:bags-greenarrow:0:0|a'..'|cnGREEN_FONT_COLOR:+'..num..'|r'
                elseif num<0 then
                    text=itemLevel..'|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..'|cnWARNING_FONT_COLOR:'..num..'|r'
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
            text2Left=sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        end
    end
    self:Set_Item_Model(tooltip, {itemID=itemID, sourceID=sourceID, appearanceID=appearanceID, visualID=visualID})--设置, 3D模型

    if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
        portrait:SetAtlas('Professions_Specialization_Lock_Glow')
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
                    player=player..'|T'..icon2..':'..self.iconSize..'|t'

                elseif not otherTab[classFile] then
                    other= other..(WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile) or '')
                end
            end
        end
        otherTab=nil

        tooltip:AddDoubleLine(player or ' ', other)
    end

    return textLeft, text2Left, portrait
end












local StatsValue={
    ['ITEM_MOD_VERSATILITY']= CR_VERSATILITY_DAMAGE_DONE,--全能 29

    ['ITEM_MOD_HASTE_RATING_SHORT']= CR_HASTE_MELEE,--急速 18
    ['ITEM_MOD_MASTERY_RATING_SHORT']= CR_MASTERY,--精通 26
    ['ITEM_MOD_CRIT_RATING_SHORT']= CR_CRIT_MELEE,--爆击 9

    ['ITEM_MOD_CR_AVOIDANCE_SHORT']= CR_AVOIDANCE,--闪避 21
    ['ITEM_MOD_CR_LIFESTEAL_SHORT']= CR_LIFESTEAL,--吸血 17
    ['ITEM_MOD_CR_SPEED_SHORT']= CR_SPEED,--加速 14
    ['ITEM_MOD_BLOCK_RATING_SHORT']= CR_BLOCK,--格挡 5
    ['ITEM_MOD_PARRY_RATING_SHORT'] = CR_PARRY,--招架 4
}
--次属性 %值
local function Set_ItemStatus(tooltip, itemLink)
    local stats= C_Item.GetItemStats(itemLink)

    local find
    for stat, va in pairs(stats) do
        local value= nil
        if StatsValue[stat] then
            value= GetCombatRatingBonusForCombatRatingValue(StatsValue[stat], va)
            if value then
                value= format('%.2f%%', value)
            end
        end
        stats[stat]= value
        find= find or value
    end
    if not find then
        return
    end

    local name= tooltip:GetName() or 'GameTooltip'

    for i=5, tooltip:NumLines() or 0, 1 do
        local line= _G[name..'TextLeft'..i]
        local text= line:GetText()

        for stat, value in pairs(stats) do
            if text:find('%+.+ '.._G[stat]) then
                line:SetText(text.. ' '..value)
                stats[stat]= nil
                break
            end
        end
    end
end













--[[
score= score,
all= all,
weekNum= weekNum,
weekLevel= weekLevel,
]]

local function Set_keystonee(tooltip, itemLink)
    local textLeft, text2Left, text2Right

    local new={}

    for guid, info in pairs(WoWTools_WoWDate or {}) do
        if info.Keystone.link then
            if guid==WoWTools_DataMixin.Player.GUID then
                text2Right= WoWTools_TextMixin:CN(info.Keystone.link, {itemLink=info.Keystone.link, isName=true})
            else
                table.insert(new, {
                    guid=guid,
                    faction=info.faction,

                    score= info.Keystone.score or 0,
                    weekNum= info.Keystone.weekNum or 0,
                    weekLevel= info.Keystone.weekLevel or 0,

                    weekMythicPlus= info.Keystone.weekMythicPlus,
                    link= info.Keystone.link
                })
            end
        end
    end

    local num= #new
    table.sort(new, function(a, b)
        if a.score==b.score then
            if b.weekNum==a.weekNum then
                return b.weekLevel>a.weekLevel
            else
                return b.weekNum>a.weekNum
            end
        else
            return b.score>a.score
        end
    end)

    for index, info in pairs(new) do
        tooltip:AddDoubleLine(
            (info.weekNum==0 and '|cff6262620|r' or info.weekNum or '')
            ..(info.weekMythicPlus and '|cnGREEN_FONT_COLOR:('..info.weekMythicPlus..') ' or '')
            ..WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {faction=info.faction, reName=true, reRealm=true})
            ..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.score, false, nil)..(WoWTools_ChallengeMixin:KeystoneScorsoColor(info.score,true)),

            WoWTools_HyperLink:CN_Link(info.link, {isName=true})
        )
        if index>2 and not IsShiftKeyDown() then
            if num>index then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:<|A:NPE_Icon:0:0|aShift+ '..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)..' '..num..'>')
            end
            break
        end
    end


    local text=WoWTools_ChallengeMixin:GetRewardText(Enum.WeeklyRewardChestThresholdType.Activities)--得到，周奖励，信息


    local score= WoWTools_ChallengeMixin:KeystoneScorsoColor(C_ChallengeMode.GetOverallDungeonScore(), true)
    if text or score then
        textLeft=(text and '|cnGREEN_FONT_COLOR:'..text..'|r ' or '')..(score or '')
    end

    local info = C_MythicPlus.GetRunHistory(false, true) or {}--本周记录

    num= 0
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

--Affix
    local affix= WoWTools_HyperLink:GetKeyAffix(itemLink)
    if affix then
        tooltip:AddLine(affix)
    end
    return textLeft, text2Left, text2Right
end
















local function Set_Item_Num(tooltip, itemID)
    local bagAll,bankAll,numPlayer=0,0,0--帐号数据
    local new={}
    local tab
    for guid, info in pairs(WoWTools_WoWDate or {}) do
        tab=info.Item[itemID]
        if tab and guid~=WoWTools_DataMixin.Player.GUID and (tab.bag>0 or tab.bank>0)  then
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

    if numPlayer>0 then
        tooltip:AddLine(' ')

        table.sort(new, function(n1, n2) return n1.num> n2.num end)

        for index, info in pairs(new) do
            local col= select(5, WoWTools_UnitMixin:GetColor(nil, info.guid))

            tooltip:AddDoubleLine(
                WoWTools_UnitMixin:GetPlayerInfo(nil, info.guid, nil, {faction=info.faction, reName=true, reRealm=true}),

                (info.bank==0 and '|cff626262' or col)..WoWTools_DataMixin:MK(info.bank, 3)..'|r|A:Banker:0:0|a '
                ..(info.bag==0 and '|cff626262' or col)..WoWTools_DataMixin:MK(info.bag, 3)..'|r|A:bag-main:0:0|a'
            )

            if index>2 and not IsShiftKeyDown() then
                if numPlayer>index then
                    tooltip:AddLine('|cnGREEN_FONT_COLOR:<|A:NPE_Icon:0:0|aShift+ '..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)..' '..numPlayer..'>')
                end
                break
            end
        end

    end

end




--[[
Name = "HousingCatalogEntryInfo",
Type = "Structure",
Fields =
{
    { Name = "entryID", Type = "HousingCatalogEntryID", Nilable = false },
    { Name = "name", Type = "cstring", Nilable = false },
    { Name = "asset", Type = "ModelAsset", Nilable = true },
    { Name = "iconTexture", Type = "FileAsset", Nilable = true },
    { Name = "iconAtlas", Type = "textureAtlas", Nilable = true },
    { Name = "uiModelSceneID", Type = "number", Nilable = true },
    { Name = "quantity", Type = "number", Nilable = false },
    { Name = "showQuantity", Type = "bool", Nilable = false },
    { Name = "categoryIDs", Type = "table", InnerType = "number", Nilable = false },
    { Name = "subcategoryIDs", Type = "table", InnerType = "number", Nilable = false },
    { Name = "dataTagsByID", Type = "LuaValueVariant", Nilable = false },
    { Name = "size", Type = "HousingCatalogEntrySize", Nilable = false },
    { Name = "placementCost", Type = "number", Nilable = false },
    { Name = "numPlaced", Type = "number", Nilable = false },
    { Name = "numStored", Type = "number", Nilable = false },
    { Name = "isAllowedOutdoors", Type = "bool", Nilable = false },
    { Name = "isAllowedIndoors", Type = "bool", Nilable = false },
    { Name = "canCustomize", Type = "bool", Nilable = false },
    { Name = "isPrefab", Type = "bool", Nilable = false },
    { Name = "quality", Type = "ItemQuality", Nilable = true },
    { Name = "customizations", Type = "table", InnerType = "cstring", Nilable = false },
    { Name = "marketInfo", Type = "HousingMarketInfo", Nilable = true },
    { Name = "remainingRedeemable", Type = "number", Nilable = false },
    { Name = "firstAcquisitionBonus", Type = "number", Nilable = false },
    { Name = "sourceText", Type = "cstring", Nilable = false },
},
},

local ValueTypePortraits = {
	[Enum.HouseLevelRewardValueType.InteriorDecor] = "house-decor-budget-icon",
	[Enum.HouseLevelRewardValueType.ExteriorDecor] = "house-outdoor-budget-icon",
	[Enum.HouseLevelRewardValueType.Rooms] =         "house-room-limit-icon",
	[Enum.HouseLevelRewardValueType.Fixtures] =      "house-fixture-budget-icon",
}

entryInfo.isPrefab 匠心房间
]]


function WoWTools_TooltipMixin:Set_HouseItem(tooltip, entryInfo)
    local textLeft, portrait
    if entryInfo.entryID then
        tooltip:AddLine(
            'recordID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..entryInfo.entryID.recordID
        )
    end
    if entryInfo.asset then
        tooltip:AddDoubleLine(
            entryInfo.asset and 'asset'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..entryInfo.asset,
            entryInfo.uiModelSceneID and 'sceneID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..entryInfo.uiModelSceneID
        )
    end

    if entryInfo.iconTexture then
        local size= math.min(entryInfo.size, 90)*5
        tooltip:AddDoubleLine(nil,
            '|T'..entryInfo.iconTexture..':'..size..':'..size..'|t'--':-'..entryInfo.size..'|t'
        )
    end


    tooltip:AddDoubleLine(
        format(
            NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '品质：%s' or PROFESSIONS_CRAFTING_QUALITY),
            '|cffffffff'..WoWTools_ItemMixin.QualityText[entryInfo.quality or 1]..'|r'
        ),
        '|T'..entryInfo.iconTexture..':23|t|cffffffff'..entryInfo.iconTexture
    )

--室内, 室外
    if entryInfo.isAllowedIndoors or entryInfo.isAllowedOutdoors then
        tooltip:AddDoubleLine(
            entryInfo.isAllowedIndoors and  '|A:house-room-limit-icon:0:0|a'..NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '室内' or HOUSING_CATALOG_FILTERS_INDOORS) or ' ',
            entryInfo.isAllowedOutdoors and  NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '室外' or HOUSING_CATALOG_FILTERS_OUTDOORS)..'|A:house-outdoor-budget-icon:0:0|a'
        )
    end

    if C_HousingCatalog.CanDestroyEntry(entryInfo.entryID)==false then
        tooltip:AddLine(
            '|cnGREEN_FONT_COLOR:|A:Objective-Fail:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '此装饰无法被摧毁，也不会计入住宅收纳箱的容量限制' or HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY),
            nil, nil, nil, true
        )
    end

--关键词
    local tag
    for _, name in pairs(entryInfo.dataTagsByID) do
        tag= (tag and tag.. NORMAL_FONT_COLOR:WrapTextInColorCode(PLAYER_LIST_DELIMITER) or '')..WoWTools_TextMixin:CN(name)
    end
    if tag then
        tooltip:AddLine(tag, 1,1,1, true)
    end
--来源
    if entryInfo.sourceText and entryInfo.sourceText~='' then
        tooltip:AddLine(entryInfo.sourceText, 1,1,1)
    end

    if entryInfo.canCustomize then
        portrait='housing-dyable-palette-icon'
    end
    if entryInfo.showQuantity then
        textLeft=entryInfo.numPlaced..'/'..entryInfo.numStored..'|A:house-chest-icon:0:0|a'
    end

    return textLeft, portrait
end










function WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    if not (itemLink or itemID) or self:IsInCombatDisabled(tooltip) then
        return
    end

    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, classID, subclassID, bindType, expacID, setID =  C_Item.GetItemInfo(itemLink or itemID)
    itemID= itemID or WoWTools_ItemMixin:GetItemID(itemLink)

    if not itemID then
        return
    end

    if WoWTools_DataMixin.onlyChinese then
        Set_Value(tooltip)
    end

    local r, g, b, col= WoWTools_ItemMixin:GetColor(itemQuality)

    tooltip:AddLine(' ')

    local text2Left, textLeft, textRight, text2Right

--版本数据, 图标，名称，版本
    if expacID or setID then
        tooltip:AddDoubleLine(
            WoWTools_DataMixin:GetExpansionText(expacID, nil) or '  ',
            setID and 'setID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..setID
        )
    end

--物品法术
    local spellName, spellID = C_Item.GetItemSpell(itemID)
    if spellName and spellID then
        local spellTexture= C_Spell.GetSpellTexture(spellID)
        tooltip:AddDoubleLine(
            spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':'..self.iconSize..'|t|cffffffff'..spellTexture or ' ',

            (itemName~=spellName and '|cff71d5ff['..WoWTools_TextMixin:CN(spellName, {spellID=spellID, isName=true})..']|r' or '')
            ..NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..'|T'..(spellTexture or itemTexture or 0)..':0|t|cffffffff'..spellID
        )
    end

    itemTexture= itemTexture or select(5, C_Item.GetItemInfoInstant(itemID or itemLink))

--itemID,  图标
    tooltip:AddDoubleLine(
        itemTexture and '|T'..itemTexture..':'..self.iconSize..'|t|cffffffff'..itemTexture or ' ',

        NORMAL_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '物品' or PROFESSIONS_COLUMN_HEADER_ITEM)..'|cffffffff'
        ..WoWTools_DataMixin.Icon.icon2
        ..itemID
    )

--物品，类型
    if classID or subclassID then
        tooltip:AddDoubleLine(
            classID and NORMAL_FONT_COLOR:WrapTextInColorCode((WoWTools_TextMixin:CN(itemType) or 'itemType'))..' |cffffffff'..classID or ' ',
            subclassID and NORMAL_FONT_COLOR:WrapTextInColorCode((WoWTools_TextMixin:CN(itemSubType) or 'itemSubType'))..' |cffffffff'..subclassID
        )
    end

--套装：炎阳珠衣装
    local transmogSetID= C_Item.GetItemLearnTransmogSet(itemID)

    local portrait
--住宅装饰
    if C_Item.IsDecorItem(itemLink or itemID) then
        local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink or itemID, true)
        if entryInfo then
            textLeft, portrait= self:Set_HouseItem(tooltip, entryInfo)
            if entryInfo.quality then
                r, g, b, col= WoWTools_ItemMixin:GetColor(entryInfo.quality)
            end
        end

--套装：炎阳珠衣装
    elseif transmogSetID then
        local collect, numAll = select(2, WoWTools_CollectionMixin:SetID(transmogSetID))
        if numAll then
            if collect==numAll then
                textLeft= format('|cnGREEN_FONT_COLOR:%s|r',  WoWTools_DataMixin.onlyChinese and '已收集' or WoWTools_TextMixin)
            elseif collect>0 then
                textLeft= '|cnWARNING_FONT_COLOR:'..collect..'/'..numAll
            else
                textLeft= format('|cnWARNING_FONT_COLOR:%s|r',  WoWTools_DataMixin.onlyChinese and '未收集' or WoWTools_TextMixin)
            end
        end
        tooltip:AddLine('transmogSetID|cffffffff'..WoWTools_DataMixin.Icon.icon2..transmogSetID)
--装备
    elseif classID==2 or classID==4 then
        textLeft, text2Left, portrait= Set_Equip(self, tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, col)
--次属性 %值
        if not PlayerIsTimerunning() then
            Set_ItemStatus(tooltip, itemLink)
        end
--炉石
    elseif itemID==6948 then
        textLeft= WoWTools_TextMixin:CN(GetBindLocation())

--玩具
    elseif C_ToyBox.GetToyInfo(itemID) then
        text2Left= PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'

    elseif itemID==122284 then
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            textLeft='|A:token-choice-wow:0:0|a|cffffffff'..C_CurrencyInfo.GetCoinTextureString(price)
        end


    else
        local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if mountID then
            self:Set_Mount(tooltip, mountID, 'item')--坐骑
        elseif speciesID then
            self:Set_Pet(tooltip, speciesID)--宠物
        end
    end

    if itemQuality==0 and(classID==2 or classID==15) then
        local petText= WoWTools_CollectionMixin:GetPet9Item(itemID)--宠物兑换, wow9.0
        if petText then
            tooltip:AddLine(petText)
        end
    end


    tooltip.Portrait:settings(portrait or itemTexture)

    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        textLeft, text2Left, text2Right= Set_keystonee(tooltip, itemLink)
    else
        Set_Item_Num(tooltip, itemID)
    end

    textRight= textRight or WoWTools_ItemMixin:GetCount(itemID)

--嵌入式
    tooltip:Set_TopLabel(textLeft, text2Left, textRight, text2Right)

    tooltip:Set_BG_Color(r, g, b, 0.15)
    --setItemCooldown(tooltip, itemID)--物品冷却
    self:Set_Web_Link(tooltip, {type='item', id=itemID, name=itemName, col=col, isPetUI=false})--取得网页，数据链接

    WoWTools_DataMixin:Call('GameTooltip_CalculatePadding', tooltip)
    --tooltip:Show()
end