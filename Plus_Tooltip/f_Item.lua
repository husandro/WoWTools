--设置,物品信息
--[[
if LOCALE_zhCN then
    function BreakUpLargeNumbers(value)
        return WoWTools_Mixin:MK(value, 3)
    end
end
FIRST_NUMBER = "千";
SECOND_NUMBER = "万";
THIRD_NUMBER = "亿"
]]

local function Set_Value_Text(line)
    local text= line and line:GetText()
    if not text or text=='' then
        return
    end

    local t= text:gsub('%d+', function(v)
        v=tonumber(v)
        if v>=1000 then
            return WoWTools_Mixin:MK(v, 3)
        end
    end)

    t= t:gsub('%d+,%d%d%d', function(v)
        local a,b= v:match('(%d+),(%d%d%d)')
        v= tonumber(a..b)
        return WoWTools_Mixin:MK(v, 3)
    end)

    t= t:gsub('%d+ '..SECOND_NUMBER, function(v)--千
        local a= v:match('(%d+)')
        v= tonumber(a..'000')
        return WoWTools_Mixin:MK(v, 3)
    end)

    t= t:gsub('%d+ '..SECOND_NUMBER, function(v)--万
        local a= v:match('(%d+)')
        v= tonumber(a..'0000')
        return WoWTools_Mixin:MK(v, 3)
    end)

    t= t:gsub('%d+ '..THIRD_NUMBER, function(v)--亿
        local a= v:match('(%d+)')
        v= tonumber(a..'00000000')
        return WoWTools_Mixin:MK(v, 3)
    end)

    if t~=text then
        line:SetText(t)
    end
end

local function Set_Value(tooltip)
    if not WoWTools_DataMixin.onlyChinese then
        return
    end

    local name= tooltip:GetName()
     for i=5, tooltip:NumLines() or 0, 1 do
        Set_Value_Text(_G[name..'TextLeft'..i])
        Set_Value_Text(_G[name..'TextRight'..i])
    end
end








local function Set_Equip(self, tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, col)
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
                (WoWTools_TextMixin:CN(_G[itemEquipLoc]) or '')..' |cffffffff'..(itemEquipLoc or ''),
                ( WoWTools_DataMixin.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' |cffffffff'..slot
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
            text2Left=sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        end
    end
    self:Set_Item_Model(tooltip, {itemID=itemID, sourceID=sourceID, appearanceID=appearanceID, visualID=visualID})--设置, 3D模型

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
                    player=player..'|T'..icon2..':'..self.iconSize..'|t'

                elseif not otherTab[classFile] then
                    other= other..(WoWTools_UnitMixin:GetClassIcon(nil, nil, classFile) or '')
                end
            end
        end
        otherTab=nil

        tooltip:AddDoubleLine(player or ' ', other)
    end

    return textLeft, text2Left
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
            (info.weekNum==0 and '|cff9e9e9e0|r' or info.weekNum or '')
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

                (info.bank==0 and '|cff9e9e9e' or col)..WoWTools_Mixin:MK(info.bank, 3)..'|r|A:Banker:0:0|a '
                ..(info.bag==0 and '|cff9e9e9e' or col)..WoWTools_Mixin:MK(info.bag, 3)..'|r|A:bag-main:0:0|a'
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



















function WoWTools_TooltipMixin:Set_Item(tooltip, itemLink, itemID)
    if not (itemLink or itemID) or WoWTools_FrameMixin:IsLocked(tooltip) then
        return
    end

    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, classID, subclassID, bindType, expacID, setID =  C_Item.GetItemInfo(itemLink or itemID)
    itemID= itemID or WoWTools_ItemMixin:GetItemID(itemLink)

    if not itemID then
        return
    end

    Set_Value(tooltip)

    local r, g, b, col= 1,1,1,WoWTools_DataMixin.Player.col
    if itemQuality then
        r, g, b, col= C_Item.GetItemQualityColor(itemQuality)
        col=col and '|c'..col
    end

    tooltip:AddLine(' ')

    local text2Left, textLeft, textRight, text2Right
    --local isInCombat= UnitAffectingCombat('player')

--版本数据, 图标，名称，版本
    if expacID or setID then
        tooltip:AddDoubleLine(
            WoWTools_Mixin:GetExpansionText(expacID, nil) or '  ',
            setID and 'setID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..setID
        )
    end

    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID or itemLink)

--itemID,  图标
    tooltip:AddDoubleLine(
        itemTexture and '|T'..itemTexture..':'..self.iconSize..'|t|cffffffff'..itemTexture or ' ',

        'itemID|cffffffff'
        ..WoWTools_DataMixin.Icon.icon2
        ..itemID
    )

--物品，类型
    if classID or subclassID then
        tooltip:AddDoubleLine(
            classID and (WoWTools_TextMixin:CN(itemType) or 'itemType')..' |cffffffff'..classID,
            subclassID and (WoWTools_TextMixin:CN(itemSubType) or 'itemSubType')..' |cffffffff'..subclassID
        )
    end

--装备
    if classID==2 or classID==4 then
        textLeft, text2Left= Set_Equip(self, tooltip, itemID, itemLink, itemLevel, itemEquipLoc, bindType, col)

--炉石
    elseif itemID==6948 then
        textLeft= WoWTools_TextMixin:CN(GetBindLocation())

--玩具
    elseif C_ToyBox.GetToyInfo(itemID) then
        text2Left= PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'

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
        local petText= WoWTools_CollectedMixin:GetPet9Item(itemID)--宠物兑换, wow9.0
        if petText then
            tooltip:AddLine(petText)
        end
    end

    local spellName, spellID = C_Item.GetItemSpell(itemID)--物品法术
    if spellName and spellID then
        local spellTexture= C_Spell.GetSpellTexture(spellID)
        tooltip:AddDoubleLine(
            spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':'..self.iconSize..'|t|cffffffff'..spellTexture or ' ',

            (itemName~=spellName and '|cff71d5ff['..WoWTools_TextMixin:CN(spellName, {spellID=spellID, isName=true})..']|r' or '')
            ..(WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)..'|T'..(spellTexture or itemTexture or 0)..':0|t|cffffffff'..spellID
        )
    end


    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        textLeft, text2Left, text2Right= Set_keystonee(tooltip, itemLink)
    else
        Set_Item_Num(tooltip, itemID)
    end


--数量
    tooltip.textRight:SetText(textRight or WoWTools_ItemMixin:GetCount(itemID))
    tooltip.text2Right:SetText(text2Right or '')

    --setItemCooldown(tooltip, itemID)--物品冷却

    tooltip.textLeft:SetText(textLeft or '')
    tooltip.text2Left:SetText(text2Left or '')


    --tooltip.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    tooltip:Set_BG_Color(r,g,b, 0.15)
    --print(r,g,b)
    --tooltip.backgroundColor:SetShown(true)

    self:Set_Web_Link(tooltip, {type='item', id=itemID, name=itemName, col=col, isPetUI=false})--取得网页，数据链接

    WoWTools_Mixin:Call(GameTooltip_CalculatePadding, tooltip)
    --tooltip:Show()
end

