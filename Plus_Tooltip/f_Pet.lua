


function WoWTools_TooltipMixin:Set_Pet(tooltip, speciesID)--宠物
    if not speciesID or speciesID< 1 then
        return
    end

    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    local AllCollected, CollectedNum, CollectedText, text2Right, typeTexture
    local size= self.iconSize--20

    if obtainable then--可得到的
        tooltip:AddLine(' ')

        AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)--收集数量

        tooltip:AddDoubleLine('speciesID '..speciesID, speciesIcon and '|T'..speciesIcon..':'..size..'|t'..speciesIcon)
        tooltip:AddDoubleLine(creatureDisplayID and 'displayID '..creatureDisplayID, companionID and 'companionID '..companionID)--ID

--技能图标
        local abilityIconA, abilityIconB = WoWTools_PetBattleMixin:GetAbilityIcon(speciesID, nil, nil, false, size+10)
        if abilityIconA or abilityIconB then
            --tooltip:AddDoubleLine(abilityIconA or ' ', abilityIconB)
            tooltip:AddLine(' ')
            tooltip:AddLine(abilityIconA)
            tooltip:AddLine(abilityIconB)
        end
--该宠物不可交易
        if not isTradeable then
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '该宠物不可交易' or BATTLE_PET_NOT_TRADABLE)

        end
--该生物无法对战。
        if not canBattle then
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '该生物无法对战。' or BATTLE_PET_CANNOT_BATTLE)
        end
    end




    tooltip:AddLine(' ')
--中文， 来源 名称
    local sourceInfo= WoWTools_TextMixin:CN(nil, {speciesID=speciesID}) or {}
    local cnName= WoWTools_TextMixin:CN(nil, {npcID=companionID, isName=true})

    if cnName then
        tooltip:AddLine('|cffffffff'..cnName..'|r')
    end

    if tooltipDescription or sourceInfo[1] then
        tooltip:AddLine(sourceInfo[1] or tooltipDescription, nil,nil,nil, true)--来源
    end
    if tooltipSource or sourceInfo[2] then
        tooltip:AddLine(sourceInfo[2] or tooltipSource,nil,nil,nil, true)--来源
    end


    --local cardModelSceneID, loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(speciesID);

	--loadoutPlate.modelScene:TransitionToModelSceneID(loadoutModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD)
--设置, 3D模型
    WoWTools_TooltipMixin:Set_Item_Model(tooltip, {
       -- modelSceneID= loadoutModelSceneID,
        creatureDisplayID=creatureDisplayID
    })

    if obtainable
        and not UnitAffectingCombat('player')
        and (not tooltip.JournalClick or not tooltip.JournalClick:IsShown())
    then
        if IsAltKeyDown() then--宠物手册，设置名称
            WoWTools_LoadUIMixin:Journal(2, {petSpeciesID=speciesID})
            --PetJournalSearchBox:SetText(speciesName)
        end
        tooltip:AddLine(' ')
        tooltip:AddLine('|A:NPE_Icon:0:0|aAlt |TInterface\\Icons\\PetJournalPortrait:0|t'..(WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH))
    end

    if petType and PET_TYPE_SUFFIX[petType] then
        typeTexture= "Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType]

        local strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        text2Right= '|T'..strongTexture..':'..size..'|t|cnGREEN_FONT_COLOR:<|r|T'..typeTexture..':'..size..':|t|cnRED_FONT_COLOR:>|r|T'..weakHintsTexture..':'..size..'|t'
    end

--图像
    tooltip.Portrait:SetTexture(typeTexture or 0)
    tooltip.Portrait:SetShown(typeTexture)

--收集数量
    tooltip.textLeft:SetText(CollectedNum or '')
    tooltip.text2Left:SetText(CollectedText or '')
    tooltip.textRight:SetText(AllCollected or '')
--强弱
    tooltip.text2Right:SetText(text2Right or '')

    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col= nil, isPetUI=false})--取得网页，数据链接

    WoWTools_PetBattleMixin.Set_TypeButton_Tips(petType)--PetBattle.lua 联动

    GameTooltip_CalculatePadding(tooltip)
end
