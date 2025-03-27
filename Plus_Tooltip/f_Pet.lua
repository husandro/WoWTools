


function WoWTools_TooltipMixin:Set_Pet(tooltip, speciesID)--宠物
    if not speciesID or speciesID< 1 then
        return
    end
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)

    if obtainable then--可得到的
        tooltip:AddLine(' ')

        local AllCollected, CollectedNum, CollectedText= WoWTools_PetBattleMixin:Collected(speciesID)--收集数量
        tooltip.textLeft:SetText(CollectedNum or '')
        tooltip.text2Left:SetText(CollectedText or '')
        tooltip.textRight:SetText(AllCollected or '')

        tooltip:AddDoubleLine('speciesID'..speciesID..(speciesIcon and '  |T'..speciesIcon..':0|t'..speciesIcon or ''), (creatureDisplayID and 'displayID'..creatureDisplayID..' ' or '')..(companionID and 'companionID'..companionID or ''))--ID

        local tab = C_PetJournal.GetPetAbilityListTable(speciesID) or {}--技能图标
        table.sort(tab, function(a,b) return a.level< b.level end)
        local abilityIconA, abilityIconB = '', ''
        for k, info in pairs(tab) do
            local icon, type = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))
            icon='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[type]..':0|t|T'..(icon or 0)..':0|t'..info.level.. ((k~=3 or k~=6) and '  ' or '')
            if k>3 then
                abilityIconA=abilityIconA..icon
            else
                abilityIconB=abilityIconB..icon
            end
        end
        tooltip:AddDoubleLine(abilityIconA, abilityIconB)
        if not isTradeable then
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '该宠物不可交易' or BATTLE_PET_NOT_TRADABLE, 1,0,0)
        end
        if not canBattle then
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '该生物无法对战。' or BATTLE_PET_CANNOT_BATTLE, 1,0,0)
        end
    end

    tooltip:AddLine(' ')
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

    if petType then
        tooltip.Portrait:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType])
        tooltip.Portrait:SetShown(true)
    end
    WoWTools_TooltipMixin:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayID})--设置, 3D模型

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


    WoWTools_TooltipMixin:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col= nil, isPetUI=false})--取得网页，数据链接

    WoWTools_PetBattleMixin.Set_TypeButton_Tips(petType)--PetBattle.lua 联动
end
