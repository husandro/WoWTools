WoWTools_CollectedMixin={}



function WoWTools_CollectedMixin:Mount(mountID, itemID)--坐骑, 收集数量
    if not mountID and itemID then
        mountID= C_MountJournal.GetMountFromItem(itemID)
    end
    if mountID then
        if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
            return '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r', true
        else
            return '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r', false
        end
    end
end

function WoWTools_CollectedMixin:Toy(itemID)--玩具,是否收集
    if C_ToyBox.GetToyInfo(itemID) then
        if PlayerHasToy(itemID) then
            return '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r', true
        else
            return '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r', false
        end
    end
end


function WoWTools_CollectedMixin:Item(itemIDOrLink, sourceID, icon, onlyBool)--物品是否收集 --if itemIDOrLink and IsCosmeticItem(itemIDOrLink) then isCollected= C_TransmogCollection.PlayerHasTransmogByItemInfo(itemIDOrLink)
    sourceID= sourceID or (itemIDOrLink and select(2, C_TransmogCollection.GetItemInfo(itemIDOrLink)))

    local sourceInfo = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)

    local isCollected=nil
    local isSelf

    if sourceInfo then
        isCollected= sourceInfo.isCollected
        isSelf= select(2, C_TransmogCollection.PlayerCanCollectSource(sourceID))

    elseif itemIDOrLink and C_Item.IsCosmeticItem(itemIDOrLink) then
        isCollected= C_TransmogCollection.PlayerHasTransmogByItemInfo(itemIDOrLink)
    end

    if isCollected==nil then
        return
    end

    local text
    if not onlyBool then
        if isCollected==true then
            if icon then
                if isSelf then
                    text='|A:common-icon-checkmark:0:0|a'--绿色√
                else
                    text= '|A:Adventures-Checkmark:0:0|a'--黄色√
                end
            else
                text= '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r'
            end
        else
            if icon then
                if isSelf then
                    text='|T132288:0|t'
                else
                    text= '|A:transmog-icon-hidden:0:0|a'
                end
            else
                text= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
            end
        end
    end
    return text, isCollected, isSelf
end

function WoWTools_CollectedMixin:SetID(setID, isLoot)--套装 , 收集数量, 返回: 图标, 数量, 最大数, 文本
    local numCollected, numAll=0,0
    if setID then
        if isLoot then
            for _, data in pairs(C_LootJournal.GetItemSetItems(setID) or {}) do
                if data.itemID then
                    numAll=numAll+1
                    if C_TransmogCollection.PlayerHasTransmogByItemInfo(data.itemID) then
                        numCollected=numCollected + 1
                    end
                end
            end
        else
            for _, v in pairs(C_TransmogSets.GetSetPrimaryAppearances(setID) or {}) do
                numAll=numAll+1
                if v.collected then
                    numCollected=numCollected + 1
                end
            end
        end
    end

    if numAll==0 then
        return
    elseif numCollected==numAll then
        return '|A:AlliedRace-UnlockingFrame-Checkmark:12:12|a', numCollected, numAll--, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r'
    elseif numCollected==0 then
        return '|cff626262'..numAll-numCollected..'|r ', numCollected, numAll,  '|cff626262'..numCollected..'|r/'..numAll--, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
    else
        return numAll-numCollected, numCollected, numAll, '|cffffffff'..numCollected..'|r/'..numAll--, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
    end
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