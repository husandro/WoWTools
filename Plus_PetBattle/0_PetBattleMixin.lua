WoWTools_PetBattleMixin={}






function WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱 SharedPetBattleTemplates.lua
    local strongTexture,weakHintsTexture, stringIndex, weakHintsIndex
    for i=1, C_PetJournal.GetNumPetTypes() do
        local modifier = C_PetBattles.GetAttackModifier(petType, i)
        if modifier then
            if ( modifier > 1 ) then
                strongTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
                stringIndex=i
            elseif ( modifier < 1 ) then
                weakHintsTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
                weakHintsIndex=i
            end
        end
        if strongTexture and weakHintsTexture then
            break
        end
    end
    return strongTexture, weakHintsTexture, stringIndex, weakHintsIndex
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
        if not onlyNum then--返回所有，数据
            local numPets, numOwned = C_PetJournal.GetNumPets()

            if numPets and numOwned and numPets>0 then
                if numPets<numOwned or numPets<3 then
                    AllCollected= WoWTools_Mixin:MK(numOwned, 3)
                else
                    AllCollected= WoWTools_Mixin:MK(numOwned,3)..'/'..WoWTools_Mixin:MK(numPets,3).. (' %i%%'):format(numOwned/numPets*100)
                end
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