local id, e = ...
local addName='Tooltips'
local Save={}

local function setInitItem(self, hide)--创建物品
    if not self.itemText then
        self.itemText=e.Cstr(self, 18)
        self.itemText:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
    end
    if not self.itemText2 then
        self.itemText2=e.Cstr(self, 18)
        self.itemText2:SetPoint('LEFT', self.itemText, 'RIGHT', 5, 0)
    end
    if not self.itemText3 then
        self.itemText3=e.Cstr(self, 18)
        self.itemText3:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
    end
    if not self.backgroundQualityColor then--背景颜色
        self.backgroundQualityColor=self:CreateTexture(nil,'BACKGROUND')
        self.backgroundQualityColor:SetAllPoints(self)
        self.backgroundQualityColor:SetAlpha(0.15)
    end
    if hide then
        self.itemText:SetText('')
        self.itemText2:SetText('')
        self.itemText3:SetText('')
        self.backgroundQualityColor:SetShown(false)
    end
end

local function GetSetsCollectedNum(setID)--套装收集数
    local info=C_TransmogSets.GetSetPrimaryAppearances(setID) or {}
    local numCollected,numAll=0,0
    for _,v in pairs(info) do
        numAll=numAll+1
        if v.collected then
            numCollected=numCollected + 1
        end
    end
    if numAll>0 then
        if numCollected==numAll then
            return '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r'
        elseif numCollected>0 and numCollected~=numAll then
            return '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..COLLECTED..'|r'
        elseif numCollected==0 then
            return  '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r'
        end
    end
end
local function setMount(self, mountID, item)--坐骑    
    local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected=C_MountJournal.GetMountInfoByID(mountID)
    self:AddDoubleLine(MOUNTS..' ID: '..mountID, item and MOUNT..ABILITIES..' ID: '..spellID or ' ')
    if isFactionSpecific then
        self:AddDoubleLine(not faction and ' ' or LFG_LIST_CROSS_FACTION:format(faction==0 and e.Icon.horde2..THE_HORDE or e.Icon.alliance2..THE_ALLIANCE or ''), e.GetShowHide(not shouldHideOnChar) )
    end
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)
    self:AddDoubleLine(MODEL..' ID: '..creatureDisplayInfoID, TUTORIAL_TITLE61_DRUID..': '..(isSelfMount and YES or NO))
    self:AddDoubleLine(source,' ')
    return  isCollected and '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r' or '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r'
end
local function setPet(self, speciesID, item)--宠物
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    self:AddDoubleLine(PET..' ID: '..speciesID, MODEL..' ID: '..creatureDisplayID)

end
local function setItem(self)--物品
    local link=select(2, self:GetItem())
    setInitItem(self)--创建物品
    if not C_Item.IsItemDataCachedByID(link) then C_Item.RequestLoadItemDataByID(link) end
    local _, _, itemQuality, _, _, _, _, _, _, itemTexture, _, _, _, bindType, expacID, setID, isCraftingReagent = GetItemInfo(link)
    local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(link)
    local r, g, b, hex = GetItemQualityColor(itemQuality)
    hex=hex and '|c'..hex or e.Player.col

    self:AddDoubleLine(expacID and _G['EXPANSION_NAME'..expacID], expacID and GAME_VERSION_LABEL..': '..expacID+1)--版本
    self:AddDoubleLine(ITEMS..' ID: '.. itemID , itemTexture and '|T'..itemTexture..':0|t'..itemTexture)--ID, texture
    self:AddDoubleLine((itemType and itemType..' classID'  or 'classID') ..': '..classID, (itemSubType and itemSubType..' subID' or 'subclassID')..': '..subclassID)

    local itemLevel
    if classID==2 or classID==4 then
        itemLevel= GetDetailedItemLevelInfo(link)
        local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]--比较装等
        if slot then
            local slotLink=GetInventoryItemLink('player', slot)
            if slotLink then
                self:AddDoubleLine(_G[itemEquipLoc], TRADESKILL_FILTER_SLOTS..': '..slot)--栏位
                local slotItemLevel= GetDetailedItemLevelInfo(slotLink)
                if slotItemLevel then
                    local num=itemLevel-slotItemLevel
                    if num>0 then
                        itemLevel=itemLevel..e.Icon.up2..'|cnGREEN_FONT_COLOR:+'..num..'|r'
                    elseif num<0 then
                        itemLevel=itemLevel..e.Icon.down2..'|cnRED_FONT_COLOR:'..num..'|r'
                    end
                end
            else
                itemLevel=itemLevel..e.Icon.up2
            end
        end
    end
    self.itemText:SetText(itemLevel and hex..itemLevel..'|r' or '')

    local hasTransmog--幻化
    if classID==2 or classID==4 then
        local sourceID=select(2,C_TransmogCollection.GetItemInfo(link))
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                hasTransmog = sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r' or '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r'
            end
        end
        if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
            hasTransmog=(hasTransmog and hasTransmog..' ' or '')..e.Icon.unlocked
        end
    else
        if setID then--套装
            hasTransmog= GetSetsCollectedNum(setID)
        elseif C_ToyBox.GetToyInfo(itemID) then--玩具
            hasTransmog=PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r' or '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r'
        else
            local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
            local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
            if mountID then
                hasTransmog = setMount(self, mountID, true)--坐骑
            elseif speciesID then
                hasTransmog = setPet(self, speciesID, true)--宠物
            end
        end
    end
    self.itemText2:SetText(hasTransmog and hex..hasTransmog..'|r' or '')

    local bag= GetItemCount(link)--物品数量
    local bank= GetItemCount(link,true) - bag
    self.itemText3:SetText((bag>0 or bank>0) and hex..bank..e.Icon.bank2..' '..bag..e.Icon.bag2..'|r' or '')

    self.backgroundQualityColor:SetColorTexture(r,g,b)
    self.backgroundQualityColor:SetShown(r and g and b)
end

e.tips:SetScript('OnTooltipSetItem', setItem)--物品
ItemRefTooltip:SetScript('OnTooltipSetItem', setItem)--物品
local getPetTypeIcon=function(petType, str)
    local s='BATTLE_PET_DAMAGE_NAME_'
    local ids={[_G[s..1]]=1,[_G[s..10]]=10,[_G[s..2]]=2,[_G[s..3]]=3,[_G[s..4]]=4,[_G[s..5]]=5,[_G[s..6]]=6,[_G[s..7]]=7,[_G[s..8]]=8,[_G[s..9]]=9,}
    if str then
        if id2[str] then
            petType=id2[str]
        else
            for i=1,10 do
                if str:find(_G[s..i]) then
                    petType=i
                    break
                end
            end
        end
    end
    if petType and PET_TYPE_SUFFIX[petType] then
        return 'Interface\\Icons\\Icon_PetFamily_'..PET_TYPE_SUFFIX[petType]
    end    
end;
hooksecurefunc("BattlePetToolTip_Show",function(speciesID, level, breedQuality, maxHealth, power, speed, customName)--BattlePetTooltip.lua FloatingPetBattleTooltip.lua
    if IsShiftKeyDown() then
        if Save.showPetSource then
            Save.showPetSource=nil
        else
            Save.showPetSource=true
        end
    end
    local self=BattlePetTooltip
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(self, ITEM_PET_KNOWN:format(0, limit), 1,0,0)
        end
    end
    BattlePetTooltipTemplate_AddTextLine(self, PET..'ID: '..speciesID..'     '..MODEL..' ID: '..creatureDisplayID..'    |T'..speciesIcon..':0|t'..speciesIcon)
    BattlePetTooltipTemplate_AddTextLine(self, 'NPCID: '..companionID..'    '..	WILD_PETS:gsub(PET,'')..': '..e.GetYesNo(isWild)..'         '..TRADE..': '..e.GetYesNo(isTradeable))
    local tab = C_PetJournal.GetPetAbilityListTable(speciesID)--技能
    table.sort(tab, function(a,b) return a.level< b.level end)
    local abilityIcon=''
    for k, info in pairs(tab) do
        local name, icon, type = C_PetJournal.GetPetAbilityInfo(info.abilityID)
        if abilityIcon~='' then
            abilityIcon=abilityIcon..' '
        end
        abilityIcon=abilityIcon..'|TInterface\\Icons\\Icon_PetFamily_'..PET_TYPE_SUFFIX[type]..':0|t|T'..icon..':0|t'..info.level
    end
    BattlePetTooltipTemplate_AddTextLine(self, abilityIcon)
    if Save.showPetSource then--来源提示
        BattlePetTooltipTemplate_AddTextLine(self, ' ')
        BattlePetTooltipTemplate_AddTextLine(self, tooltipSource)
    else
        BattlePetTooltipTemplate_AddTextLine(self, '                                         Shfit+'..SHOW..SOURCES, 1,0,1)
    end
end)


hooksecurefunc(e.tips, 'SetToyByItemID', function(self)--玩具
    setItem(self)
    self:Show()
end)

e.tips:HookScript("OnHide", function(self)
    setInitItem(self, true)
end);
ItemRefTooltip:HookScript("OnHide", function (self)
    setInitItem(self, true)
end);

hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', function(tooltip, questID, style)--世界任务ID
    e.tips:AddDoubleLine(QUESTS_LABEL..' ID:', questID)
end)



hooksecurefunc('GameTooltip_AddWidgetSet', function(self, widgetSetID, verticalPadding)

    e.tips:AddDoubleLine('widget ID:', widgetSetID)
end)
hooksecurefunc('GameTooltip_AddStatusBar', function(self, min, max, value, text)
    print('GameTooltip_AddStatusBar',self, min, max, value, text)
end)
hooksecurefunc('GameTooltip_AddQuest', function(self, questID)
    print('GameTooltip_AddQuest',self, questID)
end)


--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)