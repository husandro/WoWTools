


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

if C_Item.IsDecorItem(itemLink or itemID) then
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink or itemID, true)
    if entryInfo then
        textLeft, portrait= self:Set_HouseItem(tooltip, entryInfo)
        if entryInfo.quality then
            r, g, b, col= WoWTools_ItemMixin:GetColor(entryInfo.quality)
        end
    end
end
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
            '|T'..entryInfo.iconTexture..':'..size..':'..size..'|t'
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
    for _, name in pairs(entryInfo.dataTagsByID or {}) do
        tag= (tag and tag..NORMAL_FONT_COLOR:WrapTextInColorCode(PLAYER_LIST_DELIMITER) or '')
            ..WoWTools_TextMixin:CN(name)
    end
    if tag then
        tooltip:AddLine(' ')
        tooltip:AddLine(tag, 1,1,1, true)
    end
--来源
    if entryInfo.sourceText and entryInfo.sourceText~='' then
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_TextMixin:CN(entryInfo.sourceText), 1,1,1)
    end

    if entryInfo.canCustomize then
        portrait='housing-dyable-palette-icon'
    end
    if entryInfo.showQuantity then--entryInfo.showQuantity and 
        local numPlaced= entryInfo.numPlaced or 0
        local quantity= (entryInfo.quantity or 0)+ (entryInfo.remainingRedeemable or 0)
        numPlaced= numPlaced==0 and '|cff6262620|r' or numPlaced
        quantity= quantity==0 and '|cff6262620|r' or quantity
        textLeft=numPlaced..'/'..quantity..'|A:house-chest-icon:0:0|a'
    end

    return textLeft, portrait
end



