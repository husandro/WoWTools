local e= select(2, ...)
WoWTools_CollectedMixin={}



function WoWTools_CollectedMixin:Mount(mountID, itemID)--坐骑, 收集数量
    if not mountID and itemID then
        mountID= C_MountJournal.GetMountFromItem(itemID)
    end
    if mountID then
        if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
            return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r', true
        else
            return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r', false
        end
    end
end

function WoWTools_CollectedMixin:Toy(itemID)--玩具,是否收集
    if C_ToyBox.GetToyInfo(itemID) then
        if PlayerHasToy(itemID) then
            return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r', true
        else
            return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r', false
        end
    end
end


function WoWTools_CollectedMixin:Item(itemIDOrLink, sourceID, icon, onlyBool)--物品是否收集 --if itemIDOrLink and IsCosmeticItem(itemIDOrLink) then isCollected= C_TransmogCollection.PlayerHasTransmogByItemInfo(itemIDOrLink)
    sourceID= sourceID or itemIDOrLink and select(2, C_TransmogCollection.GetItemInfo(itemIDOrLink))
    local sourceInfo = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)
    if sourceInfo then
        local isCollected= sourceInfo.isCollected
        local isSelf= select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))
        local text
        if not onlyBool then
            if isCollected==true then
                if icon then
                    if isSelf then
                        text= format('|A:%s:0:0|a', e.Icon.select)
                    else
                        text= '|A:Adventures-Checkmark:0:0|a'--黄色√
                    end
                else
                    text= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r'
                end
            elseif isCollected==false then
                if icon then
                    if isSelf then
                        text='|T132288:0|t'
                    else
                        text= '|A:transmog-icon-hidden:0:0|a'
                    end
                else
                    text= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
                end
            end
        end
        return text, sourceInfo.isCollected, isSelf
    end
end

function WoWTools_CollectedMixin:Pet(speciesID, itemID, onlyNum)--总收集数量， 25 25 25， 3/3
    if (not speciesID or speciesID==0) and itemID then--宠物物品
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
            if numCollected and limit and limit>0 then
                if numCollected>0 then
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


--[[function e.GetSetsCollectedNum(setID)--套装 , 收集数量, 返回: 图标, 数量, 最大数, 文本
    local info= setID and C_TransmogSets.GetSetPrimaryAppearances(setID)
    local numCollected, numAll=0,0
    for _,v in pairs(info or {}) do
        numAll=numAll+1
        if v.collected then
            numCollected=numCollected + 1
        end
    end
    if numAll>0 then
        if numCollected==numAll then
            return '|A:transmog-icon-checkmark:0:0|a', numCollected, numAll, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r'
        elseif numCollected==0 then
            return '|cnRED_FONT_COLOR:'..numAll-numCollected..'|r ', numCollected, numAll, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        else
            return ' |cnYELLOW_FONT_COLOR:'..numAll-numCollected..'|r ', numCollected, numAll, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        end
    end
end]]













function WoWTools_CollectedMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱 SharedPetBattleTemplates.lua
    local strongTexture,weakHintsTexture, stringIndex, weakHintsIndex
    for i=1, C_PetJournal.GetNumPetTypes() do
        local modifier = C_PetBattles.GetAttackModifier(petType, i)
        if ( modifier > 1 ) then
            strongTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]--"Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[i]
            weakHintsIndex=i
        elseif ( modifier < 1 ) then
            weakHintsTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[i]
            weakHintsIndex=i
        end
    end
    return strongTexture,weakHintsTexture, stringIndex, weakHintsIndex ----_G["BATTLE_PET_NAME_"..petType]
end






function WoWTools_CollectedMixin:GetPet9Item(itemID, find)--宠物兑换, wow9.0
    if itemID==11406 or itemID==11944 or itemID==25402 then--[黄晶珠蜒]
        if find then
            return true
        else
            return '|T3856129:0|t'..(C_PetJournal.GetNumCollectedInfo(3106) or 0)
                ..' = '
                ..'|T134357:0|t'..C_Item.GetItemCount(11406, true)
                ..'|T132540:0|t'..C_Item.GetItemCount(11944, true)
                ..'|T133053:0|t'..C_Item.GetItemCount(25402, true)
        end

    elseif itemID==3300 or itemID==3670 or itemID==6150 then--[绿松石珠蜒]
        if find then
            return true
        else
            return '|T3856129:0|t'..(C_PetJournal.GetNumCollectedInfo(3105) or 0)
                    ..' = '
                    ..'|T132936:0|t'..C_Item.GetItemCount(3300, true)
                    ..'|T133718:0|t'..C_Item.GetItemCount(3670, true)
                    ..'|T133676:0|t'..C_Item.GetItemCount(6150, true)
        end

    elseif itemID==36812 or itemID==62072 or itemID==67410 then--[红宝石珠蜒]
        if find then
            return true
        else
            return '|T3856131:0|t'..(C_PetJournal.GetNumCollectedInfo(3104) or 0)
                    ..' = '
                    ..'|T134063:0|t'..C_Item.GetItemCount(36812, true)
                    ..'|T135148:0|t'..C_Item.GetItemCount(62072, true)
                    ..'|T135239:0|t'..C_Item.GetItemCount(67410, true)
        end
    end
end