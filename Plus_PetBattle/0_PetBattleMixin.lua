WoWTools_PetBattleMixin={}






function WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱 SharedPetBattleTemplates.lua
    if not petType then
        return
    end

    local strongTexture,weakHintsTexture, strongType, weakHintsType
    for i=1, C_PetJournal.GetNumPetTypes() do
        local modifier = C_PetBattles.GetAttackModifier(petType, i)
        if modifier then
            if ( modifier > 1 ) then
                strongTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
                strongType=i
            elseif ( modifier < 1 ) then
                weakHintsTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
                weakHintsType=i
            end
        end
        if strongTexture and weakHintsTexture then
            break
        end
    end
    return strongTexture, weakHintsTexture, strongType, weakHintsType
end







function WoWTools_PetBattleMixin:Collected(speciesID, itemID, onlyNum, petOwner, petIndex)--总收集数量， 25 25 25， 3/3
    if petOwner and petIndex then
        speciesID= C_PetBattles.GetPetSpeciesID(petOwner, petIndex)
    elseif (not speciesID or speciesID==0) and itemID then--宠物物品
        speciesID= select(13, C_PetJournal.GetPetInfoByItemID(itemID))
    end

    if not speciesID or speciesID==0 then
        return
    end

    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    if numCollected and limit then
        local AllCollected, CollectedNum, CollectedText

--返回所有，数据
        if not onlyNum then
            local numPets = C_PetJournal.GetNumPets()
            local ownedPetIDs = C_PetJournal.GetOwnedPetIDs()
            local numOwned= #ownedPetIDs
            if numPets and numPets>0 then
                if numPets<numOwned or numPets<3 then
                    AllCollected= WoWTools_DataMixin:MK(numOwned, 3)
                else
                    AllCollected= WoWTools_DataMixin:MK(numOwned,3)..'/'..WoWTools_DataMixin:MK(numPets,3).. (' %i%%'):format(numOwned/numPets*100)
                end
            else

                AllCollected= WoWTools_DataMixin:MK(numOwned, 3)
            end
            if numCollected and numCollected>0 and limit and limit>0 then
                local text2
                for index= 1 ,numOwned do
                    local petID, speciesID2, _, _, level = C_PetJournal.GetPetInfoByIndex(index)
                    if speciesID2==speciesID and petID and level then
                        local rarity = select(5, C_PetJournal.GetPetStats(petID))
                        local col= rarity and select(4, C_Item.GetItemQualityColor(rarity-1))
                        if col then
                            text2= text2 and text2..' ' or ''
                            text2= text2..'|c'..col..level..'|r'
                        end
                    end
                end
                CollectedNum= text2

            end
        end
        local isCollectedAll--是否已全部收集
        if numCollected==0 then
            CollectedText='|cnRED_FONT_COLOR:'..numCollected..'|r/'..limit
        elseif limit and numCollected==limit and limit>0 then
            CollectedText= '|cnGREEN_FONT_COLOR:'..numCollected..'/'..limit..'|r'
            isCollectedAll= true
        else
            CollectedText= numCollected..'/'..limit
        end
        return AllCollected, CollectedNum, CollectedText, isCollectedAll
    end
end


--技能列表图标
function WoWTools_PetBattleMixin:GetAbilityIcon(speciesID, petIndex, petID, onlyIcon, size)
    if not speciesID then
        if petIndex then
            speciesID= select(2, C_PetJournal.GetPetInfoByIndex(petIndex))
        elseif petID then
            speciesID= C_PetJournal.GetPetInfoByPetID(petID)
        end
    end

    local tab = speciesID
        and select(8, C_PetJournal.GetPetInfoBySpeciesID(speciesID))--canBattle
        and C_PetJournal.GetPetAbilityListTable(speciesID)

    if not tab then
        return
    end

    size= size or 0

    table.sort(tab, function(a,b) return a.level> b.level end)

    local abilityIconA, abilityIconB, icon, typePet, text
    for index, info in pairs(tab) do
        icon, typePet = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))

        text= '|T'..(icon or 0)..':'..size..'|t'
        if onlyIcon then
            abilityIconA= (abilityIconA or '')..text
        else
            text='|TInterface\\TargetingFrame\\PetBadge-'..(PET_TYPE_SUFFIX[typePet] or '')..':'..size..'|t'
                ..text
                ..(info.level or '')
                .. ((index~=3 or index~=6) and (index>3 and '   ' or ' ') or '')
            if index>3 then
                abilityIconA= text..(abilityIconA or '')
            else
                abilityIconB= text..(abilityIconB or '')
            end
        end
    end
    return abilityIconA, abilityIconB
end