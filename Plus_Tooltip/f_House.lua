function WoWTools_TooltipMixin:Set_HouseItem(tooltip, entryInfo)
    if not entryInfo then
        return
    end

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
--无法被摧毁
    if C_HousingCatalog.CanDestroyEntry(entryInfo.entryID)==false then
        tooltip:AddLine(
            '|cnGREEN_FONT_COLOR:|A:Objective-Fail:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '此装饰无法被摧毁，也不会计入住宅收纳箱的容量限制' or HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY),
            nil, nil, nil, true
        )
    end



--来源
    local sourceText
    if entryInfo.sourceText and entryInfo.sourceText~='' then
        sourceText=  WoWTools_TextMixin:CN(entryInfo.sourceText)
    else
        sourceText= WoWTools_HouseMixin:GetObjectiveText(entryInfo)
    end
    if sourceText then
        tooltip:AddLine(' ')
        tooltip:AddLine(sourceText, 1, 0.82, 0, true)
    end

--关键词
    local tag= WoWTools_HouseMixin:GetTagsText(entryInfo)
    if tag then
        tooltip:AddLine(' ')
        tooltip:AddLine(tag, 1, 0.82, 0, true)
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



