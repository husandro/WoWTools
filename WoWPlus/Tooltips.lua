local id, e = ...
local addName='Tooltips'
local Save={setDefaultAnchor=true, setUnit=true}
local wowItemsSave={}
local wowCurrencySave={}
local panel=CreateFrame("Frame")

local function setInitItem(self, hide)--创建物品
    if not self.textLeft then--左上角字符
        self.textLeft=e.Cstr(self, 18)
        self.textLeft:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
        --self.textLeft:SetPoint('TOPLEFT', self, 'BOTTOMLEFT')下
    end
    if not self.text2Left then--左上角字符2
        self.text2Left=e.Cstr(self, 18)
        self.text2Left:SetPoint('LEFT', self.textLeft, 'RIGHT', 5, 0)
    end
    if not self.textRight then--右上角字符
        self.textRight=e.Cstr(self, 18)
        self.textRight:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
        --self.textRight:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')--下
    end
    if not self.backgroundColor then--背景颜色
        self.backgroundColor=self:CreateTexture(nil,'BACKGROUND')
        self.backgroundColor:SetAllPoints(self)
    end
    if not self.itemModel then--3D模型
        self.itemModel=CreateFrame("PlayerModel", nil, self)
        self.itemModel:SetFacing(0.35)
        self.itemModel:SetPoint("TOPRIGHT", self, 'TOPLEFT')
        self.itemModel:SetSize(250, 250)
    end
    
    if not self.Portrait then--右上角图标
        self.Portrait=self:CreateTexture(nil, 'BORDER')
        self.Portrait:SetPoint('TOPRIGHT',-2, -3)
        self.Portrait:SetSize(40,40)
        --self.Portrait:SetMask(e.Icon.mask)
    end

    if hide then
        self.textLeft:SetText('')
        self.text2Left:SetText('')
        self.textRight:SetText('')
        self.itemModel:ClearModel()
        self.itemModel:SetShown(false)
        self.Portrait:SetShown(false)
        self.backgroundColor:SetShown(false)
        self.creatureDisplayID=nil--物品
        if self.playerModel then
            self.playerModel:ClearModel()
            self.playerModel:SetShown(false)
            self.playerModel.guid=nil
        end
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
local function setMount(self, mountID)--坐骑    
    local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected=C_MountJournal.GetMountInfoByID(mountID)
    
    self:AddDoubleLine(MOUNTS..'ID: '..mountID, SUMMON..ABILITIES..'ID: '..spellID)
    if isFactionSpecific then
        self:AddDoubleLine(not faction and ' ' or LFG_LIST_CROSS_FACTION:format(faction==0 and e.Icon.horde2..THE_HORDE or e.Icon.alliance2..THE_ALLIANCE or ''), ' ')
    end
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)
    self:AddDoubleLine(MODEL..'ID: '..creatureDisplayInfoID, TUTORIAL_TITLE61_DRUID..': '..(isSelfMount and YES or NO))
    self:AddDoubleLine(source,' ')

    if creatureDisplayInfoID and self.creatureDisplayID~=creatureDisplayInfoID then--3D模型
        self.itemModel:SetShown(true)
        self.itemModel:SetDisplayInfo(creatureDisplayInfoID)
        self.itemModel:SetAnimation(animID)
        self.creatureDisplayID=creatureDisplayInfoID
    end

    self.text2Left:SetText(isCollected and '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r' or '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r')
end

local function setPet(self, speciesID)--宠物
    if not speciesID or speciesID <= 0 then
        return
    end
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    self:AddLine(' ')

    if obtainable then--收集数量
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        self:AddDoubleLine(numCollected==0 and '|cnRED_FONT_COLOR:'..ITEM_PET_KNOWN:format(0, limit)..'|r' or ' ', 'NPCID: '..companionID)
    end
    self:AddDoubleLine(PET..'ID: '..speciesID, MODEL..'ID: '..creatureDisplayID)--ID

    local tab = C_PetJournal.GetPetAbilityListTable(speciesID)--技能图标
    table.sort(tab, function(a,b) return a.level< b.level end)
    local abilityIconA, abilityIconB = '', ''
    for k, info in pairs(tab) do
        local icon, type = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))
        icon='|TInterface\\Icons\\Icon_PetFamily_'..PET_TYPE_SUFFIX[type]..':0|t|T'..icon..':0|t'..info.level.. ((k~=3 or k~=6) and '  ' or '')
        if k>3 then
            abilityIconA=abilityIconA..icon
        else
            abilityIconB=abilityIconB..icon
        end
    end
    self:AddDoubleLine(abilityIconA, abilityIconB)

    if Save.showSource then--来源提示
        self:AddLine(' ')
        self:AddDoubleLine(tooltipSource,' ')
    else
        self:AddDoubleLine(' ', '|cffff00ffShfit+'..SHOW..SOURCES..'|r')
    end

    self.Portrait:SetTexture('Interface\\Icons\\Icon_PetFamily_'..PET_TYPE_SUFFIX[petType])--宠物类型图标
    self.Portrait:SetShown(true)

    if creatureDisplayID and self.creatureDisplayID~=creatureDisplayID then--3D模型
        self.itemModel:SetDisplayInfo(creatureDisplayID)
        self.itemModel:SetShown(true)
        self.creatureDisplayID=creatureDisplayID
    end
end

local function setItem(self)--物品
    if IsShiftKeyDown() then
        if Save.showSource then
            Save.showSource=nil
        else
            Save.showSource=true
        end
    elseif IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
    local link=select(2, self:GetItem())
    setInitItem(self)--创建物品
    if not C_Item.IsItemDataCachedByID(link) then C_Item.RequestLoadItemDataByID(link) end
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(link)
    local itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subclassID = GetItemInfoInstant(link)
    local r, g, b, hex = GetItemQualityColor(itemQuality)
    hex=hex and '|c'..hex or e.Player.col

    self:AddDoubleLine(expacID and _G['EXPANSION_NAME'..expacID], expacID and GAME_VERSION_LABEL..': '..expacID+1)--版本
    self:AddDoubleLine(ITEMS..'ID: '.. itemID , itemTexture and EMBLEM_SYMBOL..'ID: '..itemTexture)--ID, texture
    self:AddDoubleLine((itemType and itemType..' classID'  or 'classID') ..': '..classID, (itemSubType and itemSubType..' subID' or 'subclassID')..': '..subclassID)

    self.Portrait:SetTexture(itemTexture)
    self.Portrait:SetShown(true)

    local specTable = GetItemSpecInfo(link) or {}--专精图标
    local specTableNum=#specTable
    if specTableNum>0 then
        local num=math.modf(specTableNum/2)
        local specA=''
        local class
        table.sort(specTable, function (a2, b2) return a2<b2 end)
        for k,  specID in pairs(specTable) do
            local icon2, _, classFile=select(4, GetSpecializationInfoByID(specID))
            icon2='|T'..icon2..':0|t'
            specA = specA..((k>1 and class~=classFile) and '  ' or '')..icon2
            class=classFile
        end
        self:AddDoubleLine(specA, ' ')
    end

    local spellName, spellID = GetItemSpell(link)--物品法术
    if spellName and spellID then
        local spellTexture=GetSpellTexture(spellID)
        self:AddDoubleLine((itemName~=spellName and spellName..'('..SPELLS..')' or SPELLS)..'ID: '..spellID, spellTexture~=itemTexture and '|T'..spellTexture..':0|t'..spellTexture or ' ')
    end

    if classID==2 or classID==4 then
        itemLevel= GetDetailedItemLevelInfo(link) or itemLevel--装等
        if itemLevel and itemLevel>1 then
            local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]--比较装等
            if slot then
                self:AddDoubleLine(_G[itemEquipLoc], TRADESKILL_FILTER_SLOTS..': '..slot)--栏位
                local slotLink=GetInventoryItemLink('player', slot)
                if slotLink then
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
            self.textLeft:SetText(itemLevel and hex..itemLevel..'|r' or '')
        end

        local appearanceID, sourceID =C_TransmogCollection.GetItemInfo(link)--幻化
        local visualID
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                visualID=sourceInfo.visualID
                self.text2Left:SetText(sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r' or '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r')
            end
        end
        if appearanceID and self.creatureDisplayID~=appearanceID then
            self.itemModel:SetItemAppearance(appearanceID, visualID)
            self.itemModel:SetShown(true)
            self.creatureDisplayID=appearanceID
        end
        if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
            self.Portrait:SetAtlas(e.Icon.unlocked)
        end
    else
        if setID then--套装
            local collectedNum= GetSetsCollectedNum(setID)
            if collectedNum then
                self.text2Left:SetText(collectedNum)
            end
        elseif C_ToyBox.GetToyInfo(itemID) then--玩具
            self.text2Left:SetText(PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r' or '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r')
        else
            local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
            local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
            if mountID then
                setMount(self, mountID)--坐骑
            elseif speciesID then
                setPet(self, speciesID)--宠物
            end
        end
    end

    local bag= GetItemCount(link)--物品数量
    local bank= GetItemCount(link,true) - bag
    self.textRight:SetText((bag>0 or bank>0) and hex..bank..e.Icon.bank2..' '..bag..e.Icon.bag2..'|r' or '')

    self.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    self.backgroundColor:SetShown(true)
end

local function setSpell(self)--法术
    if IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
    local spellID = select(2, self:GetSpell())
    local spellTexture=spellID and  GetSpellTexture(spellID)
    if not spellTexture then
        return
    end
    self:AddDoubleLine(SPELLS..'ID: '..spellID, EMBLEM_SYMBOL..'ID: '..spellTexture)
    setInitItem(self)--创建物品
    self.Portrait:SetTexture(spellTexture)
    self.Portrait:SetShown(true)

    local mountID = C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        setMount(self, mountID)
    end
end

local function setCurrency(self, currencyID)--货币
    if IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if info then
        self:AddDoubleLine(TOKENS..'ID: '..currencyID, EMBLEM_SYMBOL..'ID: '..info.iconFileID)
        setInitItem(self)--创建物品
        self.Portrait:SetTexture(info.iconFileID)
        self.Portrait:SetShown(true)
    end
    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= GetFactionInfoByID(factionID)
        if name then
            self.AddDoubleLine(REPUTATION, name)
        end
    end
end

local function setAchievement(self, achievementID)--成就
    local _, _, points, completed, _, _, _, _, flags, icon = GetAchievementInfo(achievementID)
    self.textLeft:SetText(points..RESAMPLE_QUALITY_POINT)--点数
    self.text2Left:SetText(completed and '|cnGREEN_FONT_COLOR:'..	CRITERIA_COMPLETED..'|r' or '|cnRED_FONT_COLOR:'..	ACHIEVEMENTFRAME_FILTER_INCOMPLETE..'|r')--否是完成
    if flags== 0x20000 then
        self.textRight:SetText(e.Icon.wow2)
    end
    local str= flags== 0x4000 and GUILD or flags==0x20000 and e.Icon.wow2..'WoW'..SHARE_QUEST_ABBREV
    if str then
        self:AddDoubleLine(ACHIEVEMENTS..'ID: '..achievementID..(icon and ' '..EMBLEM_SYMBOL..'ID: '..icon or ''), str, nil,nil,nil, 1,0,1)
    else
        self:AddDoubleLine(ACHIEVEMENTS..'ID: '..achievementID, icon and EMBLEM_SYMBOL..'ID: '..icon)
    end
    if icon then
        setInitItem(self)--创建物品
        self.Portrait:SetTexture(icon)
        self.Portrait:SetShown(true)
    end
end

local function setQuest(self, questID)
    self:AddDoubleLine(QUESTS_LABEL..'ID:', questID)
end


--####################
--物品, 法术, 货币, 成就
--####################

hooksecurefunc(e.tips, "SetCurrencyToken", function(self, index)--角色货币栏
    local currencyLink = C_CurrencyInfo.GetCurrencyListLink(index)
    local currencyID = currencyLink and C_CurrencyInfo.GetCurrencyIDFromLink(currencyLink)
    if currencyID then
        setCurrency(self, currencyID)
    end
end)
hooksecurefunc(e.tips, 'SetBackpackToken', function(self, index)--包里货币
    local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
    if info and info.currencyTypesID then
        setCurrency(self, info.currencyTypesID)
        self:Show()
    end
end)

e.tips:SetScript('OnTooltipSetItem', setItem)--物品

hooksecurefunc(e.tips, 'SetToyByItemID', function(self)--玩具
    setItem(self)
    self:Show()
end)

e.tips:HookScript('OnTooltipSetSpell', setSpell)--法术
hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', setQuest)--世界任务ID GameTooltip_AddQuest

hooksecurefunc(ItemRefTooltip, 'SetHyperlink', function(self, link)--ItemRef.lua ItemRefTooltipMixin:ItemRefSetHyperlink(link)
    setInitItem(self, true)
    local linkName, linkID = link:match('(.-):(%d+):')
    linkID = (linkName and linkID) and tonumber(linkID)
    if not linkID then
        return
    end
    if linkName=='item' then--物品OnTooltipSetItem
        setItem(self)
        self:Show()
    elseif linkName=='spell' then--法术OnTooltipSetSpell
        setSpell(self)
    elseif linkName=='currency' then--货币
        setCurrency(self, linkID)
        self:Show()
    elseif linkName=='achievement' then--成就
        setAchievement(self, linkID)
        self:Show()
    elseif linkName=='quest'then
        setQuest(self, linkID)
        self:Show()
    end
    --print(linkName, linkID)
end)


--####
--widgetSet
--####

hooksecurefunc('GameTooltip_AddWidgetSet', function(self, widgetSetID, verticalPadding)--没测试
    e.tips:AddDoubleLine('widgetID:', widgetSetID)
end)


--###########
--宠物面板提示
--###########
local function setBattlePet(self, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID <= 0 then
        return
    end
    if IsShiftKeyDown() then
        if Save.showSource then
            Save.showSource=nil
        else
            Save.showSource=true
        end
    elseif IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            BattlePetTooltipTemplate_AddTextLine(self, id..': Ctrl+'..SHOW, 1,0,1)
        end
        return
    end
    local speciesName, speciesIcon, _, companionID, tooltipSource, _, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if not self.model then--3D模型
        self.model=CreateFrame("PlayerModel", nil, self)
        self.model:SetFacing(0.35)
        self.model:SetPoint("TOPRIGHT", self, 'TOPLEFT')
        self.model:SetSize(260, 260)
    end
    self.model:SetDisplayInfo(creatureDisplayID)
    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(self, ITEM_PET_KNOWN:format(0, limit), 1,0,0)
        end
    end
    BattlePetTooltipTemplate_AddTextLine(self, PET..'ID: '..speciesID..'                  |T'..speciesIcon..':0|t'..speciesIcon)
    BattlePetTooltipTemplate_AddTextLine(self, 'NPCID: '..companionID..'                  '..MODEL..'ID: '..creatureDisplayID)--..'    '..	WILD_PETS:gsub(PET,'')..': '..e.GetYesNo(isWild)..'         '..TRADE..': '..e.GetYesNo(isTradeable))
    local tab = C_PetJournal.GetPetAbilityListTable(speciesID)--技能图标
    table.sort(tab, function(a,b) return a.level< b.level end)
    local abilityIcon=''
    for k, info in pairs(tab) do
        local icon, type = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))
        if abilityIcon~='' then
            if k==4 then
                abilityIcon=abilityIcon..'   '
            end
            abilityIcon=abilityIcon..' '
        end
        abilityIcon=abilityIcon..'|TInterface\\Icons\\Icon_PetFamily_'..PET_TYPE_SUFFIX[type]..':0|t|T'..icon..':0|t'..info.level
    end
    BattlePetTooltipTemplate_AddTextLine(self, abilityIcon)
    if Save.showSource then--来源提示
        BattlePetTooltipTemplate_AddTextLine(self, ' ')
        BattlePetTooltipTemplate_AddTextLine(self, tooltipSource)
    else
        BattlePetTooltipTemplate_AddTextLine(self, '                                         Shfit+'..SHOW..SOURCES, 1,0,1)
    end
    if PetJournalSearchBox and PetJournalSearchBox:IsVisible() then--设置搜索
        PetJournalSearchBox:SetText(speciesName)
    end
    if not self.backgroundColor then--背景颜色
        self.backgroundColor=self:CreateTexture(nil,'BACKGROUND')
        self.backgroundColor:SetAllPoints(self)
        self.backgroundColor:SetAlpha(0.15)
    end
    if (breedQuality ~= -1) then--设置背影颜色
        self.backgroundColor:SetColorTexture(ITEM_QUALITY_COLORS[breedQuality].r, ITEM_QUALITY_COLORS[breedQuality].g, ITEM_QUALITY_COLORS[breedQuality].b, 0.15)
    end
    self.backgroundColor:SetShown(breedQuality~=-1)
end

hooksecurefunc("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
    setBattlePet(BattlePetTooltip, ...)
end)

hooksecurefunc('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
    setBattlePet(FloatingBattlePetTooltip, ...)
end)
--####
--Buff
--####
local function setBuff(type, self, ...)--Buff
    if IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
    setInitItem(self)
    local _, icon, sourceUnit, spellId
    if type=='Buff' then
        _, icon, _, _, _, _, sourceUnit, _, _, spellId= UnitBuff(...)
    elseif type=='Debuff' then
        _, icon, _, _, _, _, sourceUnit, _, _, spellId = UnitDebuff(...)
    elseif type=='Aura' then
        _, icon, _, _, _, _, sourceUnit, _, _, spellId=UnitAura(...)
    end
    local unitInfo
    if sourceUnit=='player' then
        unitInfo=e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'
    elseif sourceUnit=='pet' then
        unitInfo = sourceUnit and '|c'..select(4,GetClassColor(UnitClassBase(sourceUnit)))..PET..'|r' or PET
    elseif sourceUnit and UnitIsPlayer(sourceUnit) then
        unitInfo = e.GetPlayerInfo(sourceUnit, nil, true)
    end
    self:AddDoubleLine((unitInfo or type)..'ID: '..spellId, EMBLEM_SYMBOL..'ID: '..icon)

    local mountID = C_MountJournal.GetMountFromSpell(spellId)
    if mountID then
        setMount(self, mountID)
    end

    if sourceUnit then
        local r, g ,b , hex= GetClassColor(UnitClassBase(sourceUnit))
        if r and g and b then
           self.backgroundColor:SetColorTexture(r, g, b, 0.3)
            --self.backgroundColor:SetShown(true)
        end
        SetPortraitTexture(self.Portrait, sourceUnit)
        self.Portrait:SetShown(true)
    end
end
hooksecurefunc(e.tips, "SetUnitBuff", function(...)
    setBuff('Buff', ...)
end)
hooksecurefunc(e.tips, "SetUnitDebuff", function(...)
    setBuff('Debuff', ...)
end)
hooksecurefunc(e.tips, "SetUnitAura", function(...)
    setBuff('Aura', ...)
end)


--####
--声望
--####
local setFriendshipFaction=function(self, friendshipID)--friend声望
    if IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
    local repInfo = C_GossipInfo.GetFriendshipReputation(friendshipID);
	if ( repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0) then
        local icon = (repInfo.texture and repInfo.texture>0) and repInfo.texture
        if icon then
            setInitItem(self)
            self.Portrait:SetShown(true)
            self.Portrait:SetTexture(icon)
            self:AddDoubleLine(INDIVIDUALS..REPUTATION..'ID: '..friendshipID, icon  and EMBLEM_SYMBOL..'ID: '..icon)
        else
            self:AddDoubleLine(INDIVIDUALS..REPUTATION..'ID: '..friendshipID)
        end
        self:Show()
    end
end
hooksecurefunc(ReputationBarMixin, 'ShowFriendshipReputationTooltip', function(self, friendshipID)--个人声望ReputationFrame.lua
    setFriendshipFaction(e.tips, friendshipID)
end)

local function setMajorFactionRenown(self, majorFactionID)--名望
    if IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
	local majorFactionData = C_MajorFactions.GetMajorFactionData(majorFactionID)
    if majorFactionData then
        local icon= majorFactionData.textureKit
        if icon then
            setInitItem(self)
            self.Portrait:SetShown(true)
            self.Portrait:SetTexture(icon)
            self:AddLine(RENOWN_LEVEL_LABEL..'ID: '..majorFactionID, icon  and 	EMBLEM_SYMBOL..'ID: '..icon)
        else
            self:AddLine(RENOWN_LEVEL_LABEL..'ID: '..majorFactionID)
        end
        self:Show()
    end
end
hooksecurefunc(ReputationBarMixin, 'ShowMajorFactionRenownTooltip', function(self)--Major名望, 没测试ReputationFrame.lua
    setMajorFactionRenown(e.tips, self.factionID)
end)


hooksecurefunc(ReputationBarMixin, 'OnEnter', function(self)--角色栏,声望
    if self.friendshipID or not self.factionID or (C_Reputation.IsMajorFaction(self.factionID) and not C_MajorFactions.HasMaximumRenown(self.factionID)) then
        return
    end
    if IsControlKeyDown() then
        if Save.showTips then
            Save.showTips=nil
        else
            Save.showTips=true
        end
    end
    if not Save.showTips then
        if not UnitAffectingCombat('player') then
            self:AddDoubleLine(id, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        end
        return
    end
    if not self.Container.Name:IsTruncated() then
        local name, description, standingID, _, barMax, barValue, _, _, isHeader, _, hasRep, _, _, factionID, _, _ = GetFactionInfoByID(self.factionID)
        if factionID and not isHeader or (isHeader and hasRep) then
            e.tips:SetOwner(self, "ANCHOR_RIGHT");
            e.tips:AddLine(name..' '..standingID..'/'..MAX_REPUTATION_REACTION, 1,1,1)
            e.tips:AddLine(description, nil,nil,nil, true)
            local gender = UnitSex("player");
            local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
            local barColor = FACTION_BAR_COLORS[standingID]
            factionStandingtext=barColor:WrapTextInColorCode(factionStandingtext)--颜色
            e.tips:AddLine(factionStandingtext..' '..e.MK(barValue, 3)..'/'..e.MK(barMax, 3)..' '..('%i%%'):format(barValue/barMax*100), 1,1,1)
            e.tips:AddLine(REPUTATION..'ID: '..self.factionID or factionID)
            e.tips:Show();
        end
    else
        e.tips:AddLine(REPUTATION..'ID: '..(self.factionID or factionID))
        e.tips:Show()
    end
end)


--#######
--设置单位
--#######
local function setPlayerInfo(guid)--设置玩家信息
    local info=e.UnitItemLevel[guid]
    if info then
        if info.itemLevel and info.itemLevel>1 then
            e.tips.textLeft:SetText(info.col..info.itemLevel..'|r')--设置装等
        end

        local icon= info.specID and select(4, GetSpecializationInfoByID(info.specID))--设置天赋
        if icon then
            e.tips.text2Left:SetText("|T"..icon..':0|t')
        end

        if e.Player.servers[info.realm] then--设置服务器
            e.tips.textRight:SetText('|cnGREEN_FONT_COLOR:*|r')
        elseif info.realm and not e.Player.servers[info.realm] then
            e.tips.textRight:SetText('|cnRED_FONT_COLOR:*|r')
        end
        if info.r and info.b and info.g then
            e.tips.backgroundColor:SetColorTexture(info.r, info.g, info.b, 0.2)--背景颜色
            e.tips.backgroundColor:SetShown(true)
        end
    end
end

local function getPlayerInfo(unit, guid, isPlayer)--取得玩家信息
    if isPlayer then
        local itemLevel=C_PaperDollInfo.GetInspectItemLevel(unit)
        if (itemLevel and itemLevel>1) or not e.UnitItemLevel[guid] then
            local name, realm= UnitFullName(unit)
            local r,g,b, hex = GetClassColor(UnitClassBase(unit))
            e.UnitItemLevel[guid] = {--玩家装等
                itemLevel=itemLevel,
                specID=GetInspectSpecialization(unit),
                name=name,
                realm=realm,
                col='|c'..hex,
                r=r,
                g=g,
                b=b,
            }
        end
    end
    if unit=='mouseover' or unit =='player' then
        setPlayerInfo(guid)
    end
end

local GameTooltip_UnitColor_WoW=GameTooltip_UnitColor--单位框架颜色
local function GameTooltip_UnitColor_Init(unit)--GameTooltip.lua
    local isPlayer=UnitIsPlayer(unit)
    local englishFaction = isPlayer and UnitFactionGroup(unit)--设置单位图标    
    if isPlayer and (englishFaction=='Alliance' or englishFaction=='Horde') then--派系
        e.tips.Portrait:SetAtlas(englishFaction=='Alliance' and e.Icon.alliance or e.Icon.horde)
    elseif UnitIsQuestBoss(unit) then--任务
        e.tips.Portrait:SetAtlas(e.Icon.quest)
    else
        SetPortraitTexture(e.tips.Portrait, unit)
    end
    e.tips.Portrait:SetShown(true)

    local guid=UnitGUID(unit)
    if isPlayer then--取得装等
        if CheckInteractDistance(unit, 1) then
            NotifyInspect(unit);
        end
        getPlayerInfo(unit, guid, isPlayer)
    end

    if e.tips.playerModel.guid~=guid then--3D模型
        e.tips.playerModel:SetUnit(unit)
        e.tips.playerModel.guid=guid
        e.tips.playerModel:SetShown(true)
    end

    local r, g ,b  = GetClassColor(UnitClassBase(unit))--设置颜色
    if r and g and b then
        return r, g ,b
    else
        return GameTooltip_UnitColor_WoW(unit)
    end
end

local GameTooltip_SetDefaultAnchor_WoW=GameTooltip_SetDefaultAnchor--GameTooltip.lua
local function setUnitInit(self)--设置默认提示位置
    if Save.setUnit then
        if not e.tips.playerModel then--单位3D模型
            e.tips.playerModel=CreateFrame("PlayerModel", nil, e.tips)
            e.tips.playerModel:SetFacing(-0.35)
            e.tips.playerModel:SetPoint("BOTTOM", e.tips, 'TOP', 0, -12)
            e.tips.playerModel:SetSize(100, 100)
            e.tips.playerModel:SetShown(false)
        end
        panel:RegisterEvent('INSPECT_READY')
        panel:RegisterEvent('PLAYER_ENTERING_WORLD')
        GameTooltip_UnitColor=GameTooltip_UnitColor_Init
    else
        
        panel:UnregisterEvent('INSPECT_READY')
        panel:UnregisterEvent('PLAYER_ENTERING_WORLD')
        GameTooltip_UnitColor=GameTooltip_UnitColor_WoW
    end
    setInitItem(e.tips, not Save.setUnit)

    if Save.setDefaultAnchor then
        function GameTooltip_SetDefaultAnchor(tooltip, parent)--设置默认提示位置
            tooltip:SetOwner(parent, 'ANCHOR_CURSOR_LEFT')
        end
    else
        GameTooltip_SetDefaultAnchor=GameTooltip_SetDefaultAnchor_WoW
    end
end

local function setUnitInfo(self)--设置单位提示信息
    if not Save.setUnit then
        return
    end
    local name, unit = self:GetUnit();
    local isPlayer = UnitIsPlayer(unit)
    local guid = UnitGUID(unit)
    if isPlayer then
        local isInGuild=IsPlayerInGuildFromGUID(guid)

        local line=_G["GameTooltipTextLeft1"]--名称
        local text=line:GetText()
        text=text:gsub(name, e.Icon.toRight2..name..e.Icon.toLeft2)
        line:SetText(text)

        if isInGuild then
            line=_G["GameTooltipTextLeft2"]
            line:SetText(e.Icon.guild2..line:GetText())
        end

        line=isInGuild and _G["GameTooltipTextLeft3"] or _G["GameTooltipTextLeft2"]
        text=line:GetText()
        text=text:gsub(PLAYER, UnitIsPVP(unit) and '|cnRED_FONT_COLOR:PvP|r' or '|cnGREEN_FONT_COLOR:PvE|r')
        line:SetText('|A:charactercreate-icon-dice:0:0|a'..text)

        local num= isInGuild and 4 or 3
        local player=UnitIsUnit('player', unit)
        for i=num, e.tips:NumLines() do
            local line2=_G["GameTooltipTextLeft"..i]
            if line2 then
                if i==num and player and e.Layer then
                    line2:SetText((e.Player.zh and '位面ID: ' or 'LayerID: ')..e.Layer)
                else
                    line2:Hide()
                end
            end
        end
    elseif not UnitAffectingCombat('player') then
        local _, _, server, _, zone, npc = strsplit("-",guid)
        if zone then
            self:AddDoubleLine((e.Player.zh and '位面ID: ' or 'LayerID: ')..zone..(npc and '  NPCID: '..npc or ''), server and FRIENDS_LIST_REALM..server)
            e.Layer=zone
        end
    end
end
e.tips:HookScript("OnTooltipSetUnit", setUnitInfo)--设置单位提示信息

--****
--隐藏
--****
e.tips:HookScript("OnHide", function(self)
    setInitItem(self, true)
end)
ItemRefTooltip:HookScript("OnHide", function (self)
    setInitItem(self, true)
end)


--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            wowItemsSave=WoWToolsSave and WoWToolsSave['WoW-Items'] or wowItemsSave
            wowCurrencySave=WoWToolsSave and WoWToolsSave['WoW-Currency'] or wowCurrencySave
            setUnitInit(self)--设置默认提示位置
            self.setDefaultAnchor:SetChecked(Save.setDefaultAnchor)--提示位置
            self.setUnit:SetChecked(Save.setUnit)--单位提示

        elseif arg1=='Blizzard_ClassTalentUI' then
            local function setClassTalentSpell(self2, tooltip)--天赋
                local spellID = self2:GetSpellID()
                local spellTexture=spellID and  GetSpellTexture(spellID)
                if not spellTexture then
                    return
                end
                setInitItem(tooltip)--创建物品
                tooltip:AddLine(SPELLS..'ID: '..spellID..'                ' ..EMBLEM_SYMBOL..'ID: '..spellTexture)
                tooltip.Portrait:SetTexture(spellTexture)
                tooltip.Portrait:SetShown(true)
            end
            hooksecurefunc(ClassTalentSelectionChoiceMixin, 'AddTooltipInstructions', setClassTalentSpell)--Blizzard_ClassTalentButtonTemplates.lua--天赋
            hooksecurefunc(ClassTalentButtonSpendMixin, 'AddTooltipInstructions', setClassTalentSpell)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='INSPECT_READY' then--取得装等
        local unit=UnitGUID("mouseover")==arg1 and 'mouseover' or e.GroupGuid[arg1]
        if unit then
            setInitItem(e.tips)
            getPlayerInfo(unit, arg1, true)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        e.Layer=nil
    end
end)

panel.name = addName;--添加新控制面板
panel.parent =id;
InterfaceOptions_AddCategory(panel)

panel.setUnit=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--单位提示
panel.setUnit.Text:SetText(UNITFRAME_LABEL)
panel.setUnit:SetPoint('TOPLEFT')
panel.setUnit:SetScript('OnClick', function(self)
    if Save.setUnit then
        Save.setUnit=nil
    else
        Save.setUnit=true
    end
    setUnitInit(self)
    print(id, addName, UNITFRAME_LABEL, e.GetEnabeleDisable(Save.setUnit))
end)

panel.setDefaultAnchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--设置默认提示位置
panel.setDefaultAnchor.Text:SetText(DEFAULT..RESAMPLE_QUALITY_POINT..': '..FOLLOW..MOUSE_LABEL)
panel.setDefaultAnchor:SetPoint('LEFT', panel.setUnit.Text, 'RIGHT', 20, 0)
panel.setDefaultAnchor:SetScript('OnClick', function(self)
    if Save.setDefaultAnchor then
        Save.setDefaultAnchor=nil
    else
        Save.setDefaultAnchor=true
    end
    setUnitInit(self)
    print(DEFAULT..RESAMPLE_QUALITY_POINT..': '..FOLLOW..MOUSE_LABEL, e.GetEnabeleDisable(Save.setDefaultAnchor))
end)
