local id, e = ...
local addName='Tooltips'
local Save={setDefaultAnchor=true, showUnit=true, showTips=true, showSource=true, showWoWInfo=true, showAchievement=true}
local panel=CreateFrame("Frame")
local wowSave={}
local wowBossKilled={}

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

local function setItemCooldown(self, itemID)--物品冷却
    local startTime, duration, enable = GetItemCooldown(itemID)
    if duration>0 and enable==1 then
        local t=GetTime()
        if startTime>t then t=t+86400 end
        t=t-startTime
        t=duration-t
        self:AddDoubleLine(ON_COOLDOWN, SecondsToTime(t), 1,0,0, 1,0,0)
    end
end
local function setSpellCooldown(self, spellID)--法术冷却
    local startTime, duration, enable = GetSpellCooldown(spellID)
    if duration>0 and enable==1 then
        local t=GetTime()
        if startTime>t then t=t+86400 end
        t=t-startTime
        t=duration-t
        self:AddDoubleLine(ON_COOLDOWN, SecondsToTime(t), 1,0,0, 1,0,0)
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
local function GetPetCollected(speciesID)--宠物, 收集数量
    local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
    if nunumCollected==0 then
        return '|cnRED_FONT_COLOR:'..ITEM_PET_KNOWN:format(0, limit)..'|r', numCollected
    elseif limit and numCollected==limit and limit>0 then
        return '|cnGREEN_FONT_COLOR:'..ITEM_PET_KNOWN:format(numCollected, limit)..'|r', numCollected
    else
        return ITEM_PET_KNOWN:format(numCollected, limit), numCollected
    end
end
local function GetMountCollected(mountID)--坐骑, 收集数量
    if select(11, C_MountJournal.GetMountInfoByID(mountID)) then
        return '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r'
    else
        return '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r'
    end
end
local function GetItemCollected(link, sourceID, icon)--物品是否收集
    sourceID= sourceID or link and select(2,C_TransmogCollection.GetItemInfo(link))
    local sourceInfo = sourceID and C_TransmogCollection.GetSourceInfo(sourceID)
    if sourceInfo then
        if sourceInfo.isCollected then
            if icon then
                return e.Icon.okTransmog2, sourceInfo.isCollected
            else
                return '|cnGREEN_FONT_COLOR:'..COLLECTED..'|r', sourceInfo.isCollected
            end
        else
            if icon then
                return e.Icon.transmogHide2, sourceInfo.isCollected
            else
                return '|cnRED_FONT_COLOR:'..NOT_COLLECTED..'|r', sourceInfo.isCollected
            end
        end
    end
end

local function setMount(self, mountID)--坐骑    
    local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected=C_MountJournal.GetMountInfoByID(mountID)
    self:AddDoubleLine(MOUNTS..'ID: '..mountID, spellID and SUMMON..ABILITIES..'ID: '..spellID)
    if isFactionSpecific then
        self:AddDoubleLine(not faction and ' ' or LFG_LIST_CROSS_FACTION:format(faction==0 and e.Icon.horde2..THE_HORDE or e.Icon.alliance2..THE_ALLIANCE or ''), ' ')
    end
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        self:AddDoubleLine(MODEL..'ID: '..creatureDisplayInfoID, TUTORIAL_TITLE61_DRUID..': '..(isSelfMount and YES or NO))
    end
    if source then
        self:AddDoubleLine(source,' ')
    end
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
        local text, numCollected= GetPetCollected(speciesID)
        local numPets, numOwned = C_PetJournal.GetNumPets()
        if numPets and numOwned and numPets>0 then
            self.textRight:SetText(e.MK(numOwned,3)..'/'..e.MK(numPets,3).. (' %i%%'):format(numOwned/numPets*100))
            text= numCollected and numCollected==0 and  text or ' '
            if numCollected and numCollected>0 and not UnitAffectingCombat('player') then
                local text2
                for index= 1 ,numOwned do
                    local petID, speciesID2, _, _, level = C_PetJournal.GetPetInfoByIndex(index)
                    if speciesID2==speciesID and petID and level then
                        local rarity = select(5, C_PetJournal.GetPetStats(petID))
                        local col= rarity and select(4, GetItemQualityColor(rarity-1))
                        if col then
                        text2= text2 and text2..' ' or ''
                        text2= text2..'|c'..col..level..'|r'
                        end
                    end
                end
                if text2 then
                    self.textLeft:SetText(text2)
                end
            end
        end
        self:AddDoubleLine(text, companionID and 'NPCID: '..companionID or ' ')
    end
    self:AddDoubleLine(PET..'ID: '..speciesID, MODEL..'ID: '..creatureDisplayID)--ID

    local tab = C_PetJournal.GetPetAbilityListTable(speciesID)--技能图标
    table.sort(tab, function(a,b) return a.level< b.level end)
    local abilityIconA, abilityIconB = '', ''
    for k, info in pairs(tab) do
        local icon, type = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))
        icon='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[type]..':0|t|T'..icon..':0|t'..info.level.. ((k~=3 or k~=6) and '  ' or '')
        if k>3 then
            abilityIconA=abilityIconA..icon
        else
            abilityIconB=abilityIconB..icon
        end
    end
    self:AddDoubleLine(abilityIconA, abilityIconB)

    if Save.showSource then--来源提示
        self:AddLine(' ')
        self:AddLine(tooltipSource,nil,nil,nil, true)
    end

    --self.Portrait:SetTexture('Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType])--宠物类型图标
    if petType then
        self.Portrait:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType])
        self.Portrait:SetShown(true)
    end
    if creatureDisplayID and self.creatureDisplayID~=creatureDisplayID then--3D模型
        self.itemModel:SetDisplayInfo(creatureDisplayID)
        self.itemModel:SetShown(true)
        self.creatureDisplayID=creatureDisplayID
    end
end
hooksecurefunc(e.tips,"SetCompanionPet", function(self, petGUID)--设置宠物信息
    local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
    setPet(self, speciesID)--宠物
end)

local function setItem(self)--物品
    local link=select(2, self:GetItem())
    if not Save.showTips or UnitAffectingCombat('player') or not link then
        return
    end
    --setInitItem(self)--创建物品
    if not C_Item.IsItemDataCachedByID(link) then C_Item.RequestLoadItemDataByID(link) end
    local itemName, _, itemQuality, itemLevel, _, _, _, _, _, _, _, _, _, bindType, expacID, setID = GetItemInfo(link)
    local itemID, itemType, itemSubType, itemEquipLoc, itemTexture, classID, subclassID = GetItemInfoInstant(link)
    if not itemID then
        return
    end
    local r, g, b, hex= 1,1,1,e.Player.col
    if itemQuality then
        r, g, b, hex= GetItemQualityColor(itemQuality)
        hex=hex and '|c'..hex
    end

    self:AddDoubleLine(expacID and _G['EXPANSION_NAME'..expacID], expacID and GAME_VERSION_LABEL..': '..expacID+1)--版本
    self:AddDoubleLine(itemID and ITEMS..'ID: '.. itemID or ' ' , itemTexture and EMBLEM_SYMBOL..'ID: '..itemTexture)--ID, texture
    if classID and subclassID then
        self:AddDoubleLine((itemType and itemType..' classID'  or 'classID') ..': '..classID, (itemSubType and itemSubType..' subID' or 'subclassID')..': '..subclassID)
    end
    self.Portrait:SetTexture(itemTexture)
    self.Portrait:SetShown(true)

    local specTable = GetItemSpecInfo(link) or {}--专精图标
    local specTableNum=#specTable
    if specTableNum>0 then
        --local num=math.modf(specTableNum/2)
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
        self:AddDoubleLine((itemName~=spellName and spellName..'('..SPELLS..')' or SPELLS)..'ID: '..spellID, spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':0|t'..spellTexture or ' ')
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

    if C_Item.IsItemKeystoneByID(itemID) then--挑战, 没测试
        if Save.showWoWInfo then
            local numPlayer=0 --帐号数据 --{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数},
            for name_server, info in pairs(wowSave) do
                local tab=info.keystones
                if #tab.itemLink > 0 then
                    name_server=name_server:gsub('-'..e.Player.server, '')
                    local r2,g2,b2=GetClassColor(info.class)
                    local race=e.Race(nil, info.race, info.sex)
                    self:AddDoubleLine(race..e.Class(nil,info.class)..name_server..(tab.score and ' '..tab.score or ''), (info.weekLevel and '(|cnGREEN_FONT_COLOR:'..info.weekLevel..'|r) ' or '')..(tab.weekNum or 0)..'/'..(tab.all or 0))
                    local linka,linkb
                    for _, linkc in pairs(tab.itemLink) do
                        if not linka then
                            linka=linkc
                        elseif not linkb then
                            linkb=linkc
                        else
                            self:AddDoubleLine(race..linkc,' ')
                        end
                    end
                    if linka or link then
                        self:AddDoubleLine(linka and race..linka or ' ', linkb and linkb..race)
                    end
                    numPlayer=numPlayer+1
                end
            end
        end
    else
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for name_server, info in pairs(wowSave) do
            if name_server~=e.Player.name_server then
                local tab=info.items[itemID]
                if tab then
                    if Save.showWoWInfo then
                        name_server=name_server:gsub('-'..e.Player.server, '')
                        local r2,g2,b2=GetClassColor(info.class)
                        self:AddDoubleLine(e.Race(nil, info.race, info.sex)..e.Icon.bag2..tab.bag..' '..e.Icon.bank2..tab.bank, name_server..e.Class(nil,info.class), r2,g2,b2, r2,g2,b2)
                    end
                    bagAll=bagAll+tab.bag
                    bankAll=bankAll+tab.bank
                    numPlayer=numPlayer+1
                end
            end
        end
        if numPlayer>1 then
            self:AddDoubleLine(e.Icon.wow2..e.Icon.bag2..e.MK(bagAll,3)..' '..e.Icon.bank2..e.MK(bankAll, 3), e.MK(bagAll+bankAll, 3)..' '..e.Icon.wow2..' '..numPlayer)
        end
    end

    setItemCooldown(self, itemID)--物品冷却

    self.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    self.backgroundColor:SetShown(true)
end

local function setSpell(self)--法术
    local bat=UnitAffectingCombat('player')
    if not Save.showTips then
        return
    end
    local spellID = select(2, self:GetSpell())
    local spellTexture=spellID and  GetSpellTexture(spellID)
    if not spellTexture then
        return
    end
    self:AddDoubleLine(SPELLS..'ID: '..spellID, EMBLEM_SYMBOL..'ID: '..spellTexture)
    --setInitItem(self)--创建物品
    self.Portrait:SetTexture(spellTexture)
    self.Portrait:SetShown(true)

    local mountID = C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        setMount(self, mountID)
    end

    setSpellCooldown(self, spellID)--法术冷却
end

local function setCurrency(self, currencyID)--货币
    if not Save.showTips then
        return
    end
    local info2 = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if info2 then
        self:AddDoubleLine(TOKENS..'ID: '..currencyID, EMBLEM_SYMBOL..'ID: '..info2.iconFileID)
        --setInitItem(self)--创建物品
        self.Portrait:SetTexture(info2.iconFileID)
        self.Portrait:SetShown(true)
    end
    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= GetFactionInfoByID(factionID)
        if name then
            self.AddDoubleLine(REPUTATION, name)
        end
    end

    local all,numPlayer=0,0
    for name_server, info in pairs(wowSave) do--帐号数据
        if name_server~=e.Player.name_server then
            local quantity=info.currencys[currencyID]
            if quantity then
                if Save.showWoWInfo then
                    name_server=name_server:gsub('-'..e.Player.server, '')
                    local r2,g2,b2=GetClassColor(info.class)
                    self:AddDoubleLine(e.Race(nil, info.race, info.sex)..e.MK(quantity, 3), name_server..e.Class(nil,info.class), r2,g2,b2, r2,g2,b2)
                end
                all=all+quantity
                numPlayer=numPlayer+1
            end
        end
    end
    if numPlayer>1 then
        self:AddDoubleLine(e.Icon.wow2..e.MK(all,3), '#'..numPlayer)
    end
    self:Show()
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
        --setInitItem(self)--创建物品
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
    --setInitItem(self, true)
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
    if not speciesID or speciesID <= 0 or not Save.showTips then
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
        abilityIcon=abilityIcon..'|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[type]..':0|t|T'..icon..':0|t'..info.level
    end
    BattlePetTooltipTemplate_AddTextLine(self, abilityIcon)
    if Save.showSource then--来源提示
        BattlePetTooltipTemplate_AddTextLine(self, ' ')
        BattlePetTooltipTemplate_AddTextLine(self, tooltipSource)
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
    if not Save.showTips then
        return
    end
    --setInitItem(self)
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
    self:AddDoubleLine((unitInfo or type)..' ID: '..spellId, EMBLEM_SYMBOL..'ID: '..icon)

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
        if not UnitIsUnit(sourceUnit, 'player') then
            SetPortraitTexture(self.Portrait, sourceUnit)
            self.Portrait:SetShown(true)
        end
    end
    self:Show()
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
    if not Save.showTips then
        return
    end
    local repInfo = C_GossipInfo.GetFriendshipReputation(friendshipID);
	if ( repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0) then
        local icon = (repInfo.texture and repInfo.texture>0) and repInfo.texture
        if icon then
            --setInitItem(self)
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
    if not Save.showTips then
        return
    end
	local majorFactionData = C_MajorFactions.GetMajorFactionData(majorFactionID)
    if majorFactionData then
        local icon= majorFactionData.textureKit
        if icon then
            --setInitItem(self)
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
    if not Save.showTips or self.friendshipID or not self.factionID or (C_Reputation.IsMajorFaction(self.factionID) and not C_MajorFactions.HasMaximumRenown(self.factionID)) then
        return
    end

    local isParagon = C_Reputation.IsFactionParagon(self.factionID)--奖励			
	local completedParagon--完成次数
	if ( isParagon ) then--奖励
		local currentValue, threshold, _, _, tooLowLevelForParagon = C_Reputation.GetFactionParagonInfo(self.factionID)
		if not tooLowLevelForParagon then
			local completed= math.modf(currentValue/threshold)--完成次数
			if completed>0 then
				completedParagon=QUEST_REWARDS.. ' '..completed..' '..VOICEMACRO_LABEL_CHARGE1
			end
		end
	end

    if not self.Container.Name:IsTruncated() then
        local name, description, standingID, _, barMax, barValue, _, _, isHeader, _, hasRep, _, _, factionID, _, _ = GetFactionInfoByID(self.factionID)
        if factionID and not isHeader or (isHeader and hasRep) then
            e.tips:SetOwner(self, "ANCHOR_RIGHT");
            e.tips:AddLine(name..' '..standingID..'/'..MAX_REPUTATION_REACTION, 1,1,1)
            e.tips:AddLine(description, nil,nil,nil, true)
            e.tips:AddLine(' ')
            local gender = UnitSex("player");
            local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
            local barColor = FACTION_BAR_COLORS[standingID]
            factionStandingtext=barColor:WrapTextInColorCode(factionStandingtext)--颜色
            e.tips:AddLine(factionStandingtext..' '..e.MK(barValue, 3)..'/'..e.MK(barMax, 3)..' '..('%i%%'):format(barValue/barMax*100), 1,1,1)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(REPUTATION..'ID: '..self.factionID or factionID, completedParagon)
            e.tips:Show();
        end
    else
        e.tips:AddDoubleLine(REPUTATION..'ID: '..(self.factionID or factionID), completedParagon)
        e.tips:Show()
    end
end)

--#########
--生命条提示
--#########
local function set_Unit_Health_Bar(self, value)
    if not Save.showUnit then
        return
    end
    local text, textLeft, textRight = '', '', ''
    if value then
        local min, max = self:GetMinMaxValues();
        if value >= min and value <= max then
            if value <= 0 then
                text = '|A:poi-soulspiritghost:0:0|a'..'|cnRED_FONT_COLOR:'.. DEAD..'|r'
                textLeft = '0'
            else
                local hp = value / max * 100;
                text = ('%i%%'):format(hp)..'  ';
                if hp<30 then
                    text = '|A:GarrisonTroops-Health-Consume:0:0|a'..'|cnRED_FONT_COLOR:' .. text..'|r'
                elseif hp<60 then
                    text='|cnGREEN_FONT_COLOR:'..text..'|r'
                elseif hp<90 then
                    text='|cnYELLOW_FONT_COLOR:'..text..'|r'
                end
                textLeft = e.MK(value,3)
            end
            textRight = e.MK(max,3)
        end
    end
    if not self.text then
        self.text= e.Cstr(self)
        self.text:SetPoint('CENTER', self, 'CENTER')--生命条
        self.text:SetJustifyH("CENTER");
    end
    self.text:SetText(text);
    if not self.textLeft then
        self.textLeft = e.Cstr(self)
        self.textLeft:SetPoint('TOPLEFT', self, 'BOTTOMLEFT')--生命条
        self.textLeft:SetJustifyH("LEFT");
        self.textRight = e.Cstr(self)
        self.textRight:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')--生命条
        self.textRight:SetJustifyH("Right");
    end

    local unit = "mouseover";
    local focus = GetMouseFocus();
    if (focus and focus.unit) then
        unit = focus.unit;
    end
    local r, g, b = GetClassColor(select(2, UnitClass(unit)));
    self.textLeft:SetText(textLeft)
    self.textRight:SetText(textRight)
    self.textLeft:SetTextColor(r,g,b)
    self.textRight:SetTextColor(r,g,b)
    self:SetStatusBarColor(r, g, b)
end
GameTooltipStatusBar:SetScript("OnValueChanged", set_Unit_Health_Bar);

--#######
--设置单位
--#######
local function setPlayerInfo(unit, guid)--设置玩家信息
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
            e.tips.textRight:SetText(info.col..info.realm..'|r'..(info.realm~=e.Player.server and '|cnGREEN_FONT_COLOR:*|r' or''))

        elseif info.realm and not e.Player.servers[info.realm] then--不同
            e.tips.textRight:SetText(info.col..info.realm..'|r|cnRED_FONT_COLOR:*|r')

        elseif UnitIsUnit('player', unit) or UnitIsSameServer(unit) then--同
            e.tips.textRight:SetText(info.col..e.Player.server..'|r')
        end
        if info.r and info.b and info.g then
            e.tips.backgroundColor:SetColorTexture(info.r, info.g, info.b, 0.2)--背景颜色
            e.tips.backgroundColor:SetShown(true)
        end
    end
end

local function getPlayerInfo(unit, guid)--取得玩家信息
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
    setPlayerInfo(unit, guid)
end

local function setUnitInfo(self)--设置单位提示信息
    local name, unit = self:GetUnit()
    if not Save.showUnit or not unit then
        return
    end
    local isPlayer = UnitIsPlayer(unit)
    local guid = UnitGUID(unit)

    --设置单位图标  
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    if isPlayer then
        if (englishFaction=='Alliance' or englishFaction=='Horde') then--派系
            e.tips.Portrait:SetAtlas(englishFaction=='Alliance' and e.Icon.alliance or e.Icon.horde)
            e.tips.Portrait:SetShown(true)
        end
        
        if CheckInteractDistance(unit, 1) then--取得装等
            NotifyInspect(unit);
        end
        getPlayerInfo(unit, guid)--取得玩家信息

        local isWarModeDesired=C_PvP.IsWarModeDesired()
        local reason=UnitPhaseReason(unit)
        if reason then
            if reason==0 then--不同了阶段
                self.textLeft:SetText(ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))
            elseif reason==1 then--不在同位面
                self.textLeft:SetText(ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.L['LAYER']))
            elseif reason==2 then--战争模式
                self.textLeft:SetText(isWarModeDesired and ERR_PVP_WARMODE_TOGGLE_OFF or ERR_PVP_WARMODE_TOGGLE_ON)
            elseif reason==3 then
                self.textLeft:SetText(PLAYER_DIFFICULTY_TIMEWALKER)
            end
        end
    
        local isInGuild=IsPlayerInGuildFromGUID(guid)
        local col = e.UnitItemLevel[guid] and e.UnitItemLevel[guid].col
        local line=GameTooltipTextLeft1--名称
        local text=line:GetText()
        text=text:gsub('(%-.+)','')
        text=text:gsub(name, e.Icon.toRight2..(col and col..name..'|r' or name)..e.Icon.toLeft2)
        line:SetText(text)

        line=isInGuild and GameTooltipTextLeft2
        if line then
            line:SetText(e.Icon.guild2..line:GetText())
        end

        line=isInGuild and GameTooltipTextLeft3 or GameTooltipTextLeft2
        if line then
            local className, classFilename= UnitClass(unit);--职业名称
            local sex = UnitSex(unit)
            local raceName, raceFile= UnitRace(unit)
            local level=UnitLevel(unit)
            --[[text=line:GetText()
            text=text:gsub(PLAYER, UnitIsPVP(unit) and '|cnRED_FONT_COLOR:PvP|r' or '|cnGREEN_FONT_COLOR:PvE|r')
            line:SetText('|A:charactercreate-icon-customize-body-selected:0:0|a'..text)]]
            text= sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a'
            level= MAX_PLAYER_LEVEL>level and '|cnGREEN_FONT_COLOR:'..level..'|r' or level
            className= col and col..className..'|r' or className
            text= text..LEVEL..' '..level..'  '..e.Race(nil, raceFile, sex)..raceName..' '..e.Class(nil, classFilename)..className..(UnitIsPVP(unit) and  '  (|cnRED_FONT_COLOR:PvP|r)' or '  (|cnGREEN_FONT_COLOR:PvE|r)')
            --text= col and col..text..'|r' or text
            line:SetText(text)
        end

        
        local isSelf=UnitIsUnit('player', unit)--我
--[[
        line=isInGuild and GameTooltipTextLeft4 or GameTooltipTextLeft3
        if line then
            if e.Layer and isSelf then--显示位面,隐然,部落,联盟
                line:SetText(e.L['LAYER']..' '..e.Layer)
            else
                --line:Hide()
            end
        end


]]

        local num= isInGuild and 4 or 3
        for i=num, e.tips:NumLines() do
            local line=_G["GameTooltipTextLeft"..i]
            if line then
                if i==num and isSelf and (e.Layer or isWarModeDesired) then
                    line:SetText(e.Layer and e.L['LAYER']..' '..e.Layer or ' ')
                    if isWarModeDesired then
                        line=_G["GameTooltipTextRight"..i]
                        if line then
                            line:SetText(PVP_LABEL_WAR_MODE)
                            line:SetShown(true)
                        end
                    end
                elseif not UnitInParty(unit) or isSelf then
                    line:Hide()
                end
            end
        end

        
        if not isSelf and e.GroupGuid[guid]  then--队友位置
            local mapID= C_Map.GetBestMapForUnit(unit)--地图ID
            if mapID then
                local mapName=C_Map.GetMapInfo(mapID).name;
                if mapName then
                    line=isInGuild and GameTooltipTextRight4 or GameTooltipTextRight3
                    if line then
                        line:SetText(mapName..e.Icon.map2)
                        line:SetShown(true)
                    end
                end
            end
        end


    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        setPet(self, UnitBattlePetSpeciesID(unit))

    else
        local r,g,b, hex = GetClassColor(UnitClassBase(unit))--颜色
        hex= hex and '|c'..hex or ''
        GameTooltipTextLeft1:SetTextColor(r,g,b)

        if not UnitAffectingCombat('player') then--位面,NPCID
            local _, _, server, _, zone, npc = strsplit("-",guid)
            if zone then
                self:AddDoubleLine(e.L['LAYER']..' '..zone, 'NPCID '..npc)--, server and FRIENDS_LIST_REALM..server)
                e.Layer=zone
            end
        end

        --怪物, 图标
        if UnitIsQuestBoss(unit) then--任务
            e.tips.Portrait:SetAtlas(UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest)
            e.tips.Portrait:SetShown(true)

        elseif UnitIsBossMob(unit) then--世界BOSS
            self.textLeft:SetText(hex..RAID_INFO_WORLD_BOSS..'|r')
            e.tips.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            e.tips.Portrait:SetShown(true)
        else
            local classification = UnitClassification(unit);--TargetFrame.lua
            if classification == "rareelite" then--稀有, 精英
                self.textLeft:SetText(hex..GARRISON_MISSION_RARE..'|r')
                self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
                e.tips.Portrait:SetShown(true)

            elseif classification == "rare" then--稀有
                self.textLeft:SetText(hex..GARRISON_MISSION_RARE..'|r')
                e.tips.Portrait:SetAtlas('UUnitFrame-Target-PortraitOn-Boss-Rare-Star')
                e.tips.Portrait:SetShown(true)
            end
        end

        local type=UnitCreatureType(unit)--生物类型
        if type and not type:find(COMBAT_ALLY_START_MISSION) then
            self.textRight:SetText(hex..type..'|r') 
        end
    end

    set_Unit_Health_Bar(GameTooltipStatusBar, UnitHealth(unit))--生命条提示

    if e.tips.playerModel.guid~=guid then--3D模型
        e.tips.playerModel:SetUnit(unit)
        e.tips.playerModel.guid=guid
    end
    e.tips.playerModel:SetShown(true)
end
e.tips:HookScript("OnTooltipSetUnit", setUnitInfo)--设置单位提示信息



local function setUnitInit(self)--设置默认提示位置
    if Save.showUnit then
        if not e.tips.playerModel then--单位3D模型
            e.tips.playerModel=CreateFrame("PlayerModel", nil, e.tips)
            e.tips.playerModel:SetFacing(-0.35)
            e.tips.playerModel:SetPoint("BOTTOM", e.tips, 'TOP', 0, -12)
            e.tips.playerModel:SetSize(100, 100)
            e.tips.playerModel:SetShown(false)
        end
        panel:RegisterEvent('INSPECT_READY')
    else
        panel:UnregisterEvent('INSPECT_READY')
    end
end
--****
--位置
--****
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
    if Save.setDefaultAnchor then
        self:ClearAllPoints();
        self:SetOwner(parent, 'ANCHOR_CURSOR_LEFT')
    elseif Save.setAnchor and Save.AnchorPoint then
        self:ClearAllPoints();
        self:SetPoint(Save.AnchorPoint[1], UIParent, Save.AnchorPoint[3], Save.AnchorPoint[4], Save.AnchorPoint[5])
    end
end)


--****
--隐藏/
--****
setInitItem(e.tips)
e.tips:HookScript("OnShow", function(self)
    if Save.inCombatHideTips and UnitAffectingCombat('player') then 
        self:Hide()
    end
end)
ItemRefTooltip:HookScript("OnShow", function(self)
    setInitItem(self)
end)
e.tips:HookScript("OnHide", function(self)
    setInitItem(self, true)
end)
ItemRefTooltip:HookScript("OnHide", function (self)
    setInitItem(self, true)
end)


--#######
--冒险指南EncounterJournal
--#######

local function EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
    local self=EncounterJournal
    if not self or Save.hideEncounterJournal_All_Info_Text then
        if self and self.AllText then
            self.AllText:SetText('')
        end
        return
    end
    if not self.AllText then
        self.AllText=e.Cstr(self)
        self.AllText:SetPoint('TOPLEFT', self, 'TOPRIGHT',40,0)
    end
    local m=''

    local tab=wowSave[e.Player.name_server].instance.ins
    local text=''
    for insName, info in pairs(tab) do
        text= text~='' and text..'\n' or text
        text= text..'|T450908:0|t'..insName
        for difficultyName, index in pairs(info) do
            text=text..'\n     '..index..' '..difficultyName
        end
    end
    if text~='' then
        m= m~='' and m..'\n\n'..text or text
    end

    text=''--世界BOSS
    tab=wowSave[e.Player.name_server].worldboss.boss
    local num=0
    for bossName, _ in pairs(tab) do
        num=num+1
        text= text~='' and text..' ' or text
        text=text.. bossName
    end
    if text~='' then
        m= m~='' and m..'\n\n' or m
        m=m..num..' |cnGREEN_FONT_COLOR:'..text..'|r'
    end

    tab=wowSave[e.Player.name_server].rare.boss--稀有怪
    text, num='',0
    for name, _ in pairs(tab) do
        text=text~='' and text..' ' or text
        name=name:gsub('·.+','')
        name=name:gsub('%-.+','')
        name=name:gsub('<.+>', '')
        text=text..name
        num=num+1
    end
    if text~='' then
        m= m~='' and m..'\n\n' or m
        m= m..num..' '..'|cnGREEN_FONT_COLOR:'..text..'|r'
    end

    --周奖励,副本,PVP,团本
    tab = {}
    local activityInfo =  C_WeeklyRewards.GetActivities()--Blizzard_WeeklyRewards.lua
    for  _ , info in pairs(activityInfo) do
        local difficulty
        if info.type == Enum.WeeklyRewardChestThresholdType.Raid then
            difficulty = DifficultyUtil.GetDifficultyName(info.level);
        elseif info.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
            difficulty =  string.format(WEEKLY_REWARDS_MYTHIC, info.level);
        elseif info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            difficulty =  PVPUtil.GetTierName(info.level);
        elseif info.type== Enum.WeeklyRewardChestThresholdType.AlsoReceive then
            difficulty =  WEEKLY_REWARDS_ALSO_RECEIVE;
        elseif info.type== Enum.WeeklyRewardChestThresholdType.Concession then
            difficulty =  WEEKLY_REWARDS_GET_CONCESSION;
        end
        tab[info.type]=tab[info.type] or {}
        tab[info.type][info.index] = {
            level = info.level,
            difficulty = difficulty or NONE,
            progress = info.progress,
            threshold = info.threshold,
            unlocked = info.progress >= info.threshold,
            rewards = info.rewards,
        }
    end
    text=''
    for type,v in pairs(tab) do
        local head
        if type == Enum.WeeklyRewardChestThresholdType.Raid then
            head = RAIDS
        elseif type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
            head = MYTHIC_DUNGEONS
        elseif type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
            head = PVP
        end
        if head then
            text = text~='' and text..'\n' or text
            text = text..'|T450908:0|t'..head
            if he==MYTHIC_DUNGEONS then
                local weekLevel=wowSave[e.Player.name_server].keystones.weekLevel--本周最高
                if weekLevel then
                    text=text..' |cnGREEN_FONT_COLOR:'..weekLevel..'|r'
                end
            end
            for x,r in pairs(v) do
                text = text~='' and text..'\n' or text
                text = text..'     '
                if r.unlocked then
                    text = text..'|cnGREEN_FONT_COLOR:'..x..')'..r.difficulty.. ' '..'|cnGREEN_FONT_COLOR:'..COMPLETE..'|r'
                else
                    text = text..x..')'..r.difficulty.. ' '..r.progress.."/"..r.threshold
                end
                if r.level and r.level>0 then
                    text=text..' '..r.level
                end
                if r.rewards then
                    if r.rewards.type==1 then
                        text=text..' '..ITEMS
                    elseif r.rewards.type==2 then
                        text=text..' '..CURRENCY
                    elseif r.rewards==3 then
                        text=text..' '..QUESTS_LABEL
                    end
                end
            end
        end
    end
    m= m~='' and m..'\n\n'..text or text

    --征服点数 Conquest 1602 1191/勇气点数
    tab={1191, 1602, 1792}
    text=''
    for _,v in pairs(tab) do
        local info=C_CurrencyInfo.GetCurrencyInfo(v)
        if info and info.quantity and info.quantity>=0 and info.name then
            local max=info.maxQuantity
            local totalEarned=info.totalEarned
            local t=(info.iconFileID and '|T'..info.iconFileID..':0|t' or '')..info.name..': '
            t=t..e.MK(info.quantity,3)..((info.maxQuantity and info.maxQuantity>0) and '/'..e.MK(info.maxQuantity,3) or '')
            if info.maxQuantity and info.maxQuantity>0 and info.maxQuantity==info.quantity then
                t='|cnRED_FONT_COLOR:'..t..'|r'
            end
            text= text~='' and text..'\n'..t or t
        end
    end
    if text~='' then
        m= m~='' and m..'\n\n'..text or text
    end
    --本周还可获取奖励
    if C_WeeklyRewards.CanClaimRewards() then
        m=m..'\n\n|cFF00FF00'.. string.format(LFD_REWARD_DESCRIPTION_WEEKLY,1)..'|r|T134140:0|t'
    end
    self.AllText:SetText(m)
end

local function set_EncounterJournal_World_Tips(self2)--所有角色已击杀世界BOSS提示
    e.tips:SetOwner(self2, "ANCHOR_LEFT");
    e.tips:ClearLines();
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddDoubleLine(ADVENTURE_JOURNAL, CHANNEL_CATEGORY_WORLD..'BOSS/'..GARRISON_MISSION_RARE..e.Icon.left..e.GetShowHide(Save.showWorldBoss))
    local find
    for name_server, info in pairs(wowSave) do
        local showName
        name_server=name_server:gsub('-'..e.Player.server, '')
        local r2,g2,b2=GetClassColor(info.class)

        local tab=info.worldboss and info.worldboss.boss--世界BOSS
        if tab then
            local text=''
            for bossName, _ in pairs(tab) do
                text= text~='' and text..' ' or text
                bossName=bossName:gsub('·.+','')
                bossName=bossName:gsub('%-.+','')
                bossName=bossName:gsub('<.+>', '')
                text=text.. bossName
            end
            if text~='' then
                e.tips:AddDoubleLine(e.Race(nil, info.race, info.sex)..e.Class(nil,info.class)..name_server, text, r2,g2,b2, r2,g2,b2)
                find=true
                showName=true
            end
        end

        tab=info.rare.boss--稀有怪
        if tab then
            local text, numAll='',0
            for name, num in pairs(tab) do
                text=text~='' and text..' ' or text
                name=name:gsub('·.+','')
                name=name:gsub('%-.+','')
                name=name:gsub('<.+>', '')
                text=text..name..(num>1 and '|cnGREEN_FONT_COLOR:'..num..'|r' or '')
                numAll=numAll+1
            end
            if text~='' then
                if not showName then
                    e.tips:AddLine(e.Race(nil, info.race, info.sex)..e.Class(nil,info.class)..name_server, r2,g2,b2)
                end
                e.tips:AddLine('(|cnGREEN_FONT_COLOR:'..numAll..'|r)'..text, r2,g2,b2, true)
                find=true
            end
        end
    end
    if not find then
        e.tips:AddDoubleLine(NONE, ' ', 1,0,0)
    end
    e.tips:Show()
end

local function MoveFrame(self, savePointName)
    self:RegisterForDrag("RightButton")
    self:SetClampedToScreen(true)
    self:SetMovable(true)
    self:SetScript("OnDragStart", function(self2) self2:StartMoving() end);
    self:SetScript("OnDragStop", function(self2)
            ResetCursor()
            self2:StopMovingOrSizing()
            Save[savePointName]={self2:GetPoint(1)}
    end);
    self:SetScript('OnLeave', function() e.tips:Hide() end)
    self:EnableMouseWheel(true)
    self:SetScript('OnMouseWheel', function(self2, d)
        local size=Save.EncounterJournalFontSize or 12
        if d==1 then
            size=size+1
        else
            size=size-1
        end
        size= size<6 and 6 or size
        size= size>72 and 72 or size
        Save.EncounterJournalFontSize=size
        e.Cstr(nil, size, nil, self2.Text)
        print(id, addName, 	FONT_SIZE, size)
    end)
end
local function setWorldbossText()--显示世界BOSS击杀数据Text
    if Save.showWorldBoss then
        if not panel.WorldBoss then
            panel.WorldBoss=e.Cbtn(UIParent, nil, not Save.hideWorldBossText)
            if Save.WorldBossPoint then
                panel.WorldBoss:SetPoint(Save.WorldBossPoint[1], UIParent, Save.WorldBossPoint[3], Save.WorldBossPoint[4], Save.WorldBossPoint[5])
            else
                if IsAddOnLoaded('Blizzard_EncounterJournal') then
                    panel.WorldBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -65,5)
                else
                    panel.WorldBoss:SetPoint('CENTER')
                end
            end
            panel.WorldBoss:SetSize(14,14)
            panel.WorldBoss:SetScript('OnEnter', function(self2)
                if UnitAffectingCombat('player') then
                    return
                end
                e.tips:SetOwner(self2, "ANCHOR_LEFT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddDoubleLine(ADVENTURE_JOURNAL, CHANNEL_CATEGORY_WORLD..'BOSS/'..GARRISON_MISSION_RARE)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.GetShowHide(not Save.hideWorldBossText), e.Icon.left)
                e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
                e.tips:AddDoubleLine(FONT_SIZE, (Save.EncounterJournalFontSize or 12)..e.Icon.mid)
                e.tips:Show()
            end)
            panel.WorldBoss:SetScript('OnClick', function(self2, d)
                if d=='LeftButton' then
                    if Save.hideWorldBossText then
                        Save.hideWorldBossText=nil
                    else
                        Save.hideWorldBossText=true
                    end
                    panel.WorldBoss:SetNormalAtlas(Save.hideWorldBossText and e.Icon.disabled or e.Icon.icon)
                    panel.WorldBoss.Text:SetShown(not Save.hideWorldBossText)
                end
            end)
            MoveFrame(panel.WorldBoss, 'WorldBossPoint')
            panel.WorldBoss.Text=e.Cstr(panel.WorldBoss, Save.EncounterJournalFontSize)
            panel.WorldBoss.Text:SetPoint('TOPLEFT')
        end

        local text2=''
        for name_server, info in pairs(wowSave) do
            local showName
            name_server=name_server:gsub('-'..e.Player.server, '')
            local col='|c'..select(4, GetClassColor(info.class))
            local tab=info.worldboss and info.worldboss.boss
            if tab then
                local text, numAll='',0
                for bossName, _ in pairs(tab) do
                    numAll=numAll+1
                    if text~='' then
                        text= select(2, math.modf(numAll/5))==0 and text..'\n       ' or text..' '
                    end
                    text=text.. bossName

                end
                if text~='' then
                    text2=e.Race(nil, info.race, info.sex)..e.Class(nil,info.class)..col..name_server.. '\n'
                    numAll='('..numAll..')'
                    text2=text2..string.rep(' ', 6 - string.len(numAll))..'|cnGREEN_FONT_COLOR:'..numAll..'|r'..text..'|r'
                    showName=true
                end
            end

            tab=info.rare.boss--稀有怪
            if tab then
                local text, numAll='', 0
                for name, num in pairs(tab) do
                    if text~='' then
                        text= select(2, math.modf(numAll/5))==0 and text..'\n       ' or text..' '
                    end
                    text=text..name..(num>1 and '|cnGREEN_FONT_COLOR:'..num..'|r' or '')
                    numAll=numAll+1
                end
                if text~='' then
                    if not showName then
                        text2=e.Race(nil, info.race, info.sex)..e.Class(nil,info.class)..col..name_server..'\n'
                    else
                        text2= text2~='' and text2..'\n' or text2
                    end
                    numAll='('..numAll..')'
                    text2=text2..string.rep(' ', 6 - string.len(numAll))
                    text2=text2..'|cnGREEN_FONT_COLOR:'..numAll..'|r'..col..text..'|r'
                end
            end
        end

        panel.WorldBoss.Text:SetText(text2~='' and text2 or NONE)
    end
    if panel.WorldBoss then
        panel.WorldBoss:SetShown(Save.showWorldBoss)
        panel.WorldBoss.Text:SetShown(not Save.hideWorldBossText)
    end
end

local function setInstanceBossText()--显示副本击杀数据
    if Save.showInstanceBoss then
        if not panel.instanceBoss then
            panel.instanceBoss=e.Cbtn(UIParent, nil, not Save.hideInstanceBossText)
            if Save.instanceBossPoint then
                panel.instanceBoss:SetPoint(Save.instanceBossPoint[1], UIParent, Save.instanceBossPoint[3], Save.instanceBossPoint[4], Save.instanceBossPoint[5])
            else
                if IsAddOnLoaded('Blizzard_EncounterJournal') then
                    panel.instanceBoss:SetPoint('BOTTOMRIGHT',EncounterJournal, 'TOPRIGHT', -45,20)
                else
                    panel.instanceBoss:SetPoint('CENTER')
                end
            end
            panel.instanceBoss:SetSize(14,14)
            panel.instanceBoss:SetScript('OnEnter', function(self2)
                if UnitAffectingCombat('player') then
                    return
                end
                e.tips:SetOwner(self2, "ANCHOR_LEFT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddDoubleLine(ADVENTURE_JOURNAL, INSTANCE)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.GetShowHide(not Save.hideInstanceBossText), e.Icon.left)
                e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
                e.tips:AddDoubleLine(FONT_SIZE, (Save.EncounterJournalFontSize or 12)..e.Icon.mid)
                e.tips:Show()
            end)
            panel.instanceBoss:SetScript('OnClick', function(self2, d)
                if d=='LeftButton' then
                    if Save.hideInstanceBossText then
                        Save.hideInstanceBossText=nil
                    else
                        Save.hideInstanceBossText=true
                    end
                    panel.instanceBoss:SetNormalAtlas(Save.hideInstanceBossText and e.Icon.disabled or e.Icon.icon)
                    panel.instanceBoss.Text:SetShown(not Save.hideInstanceBossText)
                end
            end)
            MoveFrame(panel.instanceBoss, 'instanceBossPoint')
            panel.instanceBoss.Text=e.Cstr(panel.instanceBoss, Save.EncounterJournalFontSize)
            panel.instanceBoss.Text:SetPoint('TOPLEFT')
        end

        local text=''
        for name_server, info in pairs(wowSave) do
            local tab= info.instance.ins
            if tab then
                local showName
                local col='|c'..select(4, GetClassColor(info.class))
                for name, instanceInfo in pairs(tab) do
                    if instanceInfo then
                        for difficultyName, killed in pairs(instanceInfo) do
                            if not showName then
                                name_server=name_server:gsub('-'..e.Player.server, '')
                                text=text~='' and text..'\n' or text
                                text=text..e.Race(nil, info.race, info.sex)..e.Class(nil,info.class)..col..name_server..'|r'
                                showName=true
                            end
                            text=text..'\n       '..col..name..' '..difficultyName..' '.. killed..'|r'
                        end
                    end
                end
            end
        end
        panel.instanceBoss.Text:SetText(text~='' and text or NONE)
    end
    if panel.instanceBoss then
        panel.instanceBoss:SetShown(Save.showInstanceBoss)
        panel.instanceBoss.Text:SetShown(not Save.hideInstanceBossText)
    end
end

local function setEncounterJournal()--冒险指南界面
    local self=EncounterJournal
    self.btn= e.Cbtn(self.TitleContainer, nil, not Save.hideEncounterJournal)--按钮, 总开关
    self.btn:SetPoint('RIGHT',-22, -2)
    self.btn:SetSize(22, 22)
    self.btn:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddDoubleLine(ADVENTURE_JOURNAL, e.GetEnabeleDisable(not Save.hideEncounterJournal))
        e.tips:AddDoubleLine(QUEST_REWARDS, e.GetShowHide(not Save.hideEncounterJournal_All_Info_Text))
        e.tips:Show()
    end)
    self.btn:SetScript('OnClick', function(self2, d)
        if d=='LeftButton' then
            if Save.hideEncounterJournal then
                Save.hideEncounterJournal=nil
            else
                Save.hideEncounterJournal=true
            end
            self.instance:SetShown(not Save.hideEncounterJournal)
            self.worldboss:SetShown(not Save.hideEncounterJournal)
            self.btn:SetNormalAtlas(Save.hideEncounterJournal and e.Icon.disabled or e.Icon.icon )
        elseif d=='RightButton' then
            if Save.hideEncounterJournal_All_Info_Text then
                Save.hideEncounterJournal_All_Info_Text=nil
            else
                Save.hideEncounterJournal_All_Info_Text=true
            end
            EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
        end
    end)
    self.btn:SetScript("OnLeave",function() e.tips:Hide() end)

    self.instance =e.Cbtn(self.TitleContainer, nil ,true)--所有角色副本
    self.instance:SetPoint('RIGHT', self.btn, 'LEFT')
    self.instance:SetNormalAtlas('animachannel-icon-kyrian-map')
    self.instance:SetSize(22,22)
    self.instance:SetScript('OnEnter',function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT");
        e.tips:ClearLines();
        e.tips:AddDoubleLine(INSTANCE..e.Icon.left..e.GetShowHide(Save.showInstanceBoss), DUNGEON_ENCOUNTER_DEFEATED)
        for name_server, info in pairs(wowSave) do
            local tab= info.instance.ins
            if tab then
                local showName
                local r2,g2,b2=GetClassColor(info.class)
                for name, instanceInfo in pairs(tab) do
                    if instanceInfo then
                        for difficultyName, killed in pairs(instanceInfo) do
                            if not showName then
                                e.tips:AddDoubleLine(e.Race(nil, info.race, info.sex)..e.Class(nil,info.class)..name_server, ' ', r2,g2,b2)
                                showName=true
                            end
                            e.tips:AddDoubleLine('       '..name..' '..difficultyName, killed, r2,g2,b2, r2,g2,b2)
                        end
                    end
                end
            end
        end
        e.tips:Show()
    end)--提示
    self.instance:SetScript('OnClick', function()
            if  Save.showInstanceBoss then
                Save.showInstanceBoss=nil
            else
                Save.showInstanceBoss=true
                Save.hideInstanceBossText=nil
            end
            setInstanceBossText()
    end)
    self.instance:SetScript("OnLeave",function() e.tips:Hide() end)

    self.worldboss =e.Cbtn(self.TitleContainer, nil ,true)--所有角色已击杀世界BOSS
    self.worldboss:SetPoint('RIGHT', self.instance, 'LEFT')
    self.worldboss:SetNormalAtlas('poi-soulspiritghost')
    self.worldboss:SetSize(22,22)
    self.worldboss:SetScript('OnEnter',set_EncounterJournal_World_Tips)--提示
    self.worldboss:SetScript('OnClick', function(self2, d)
        if  Save.showWorldBoss then
            Save.showWorldBoss=nil
        else
            Save.showWorldBoss=true
            Save.hideWorldBossText=nil
        end
        setWorldbossText()
    end)
    self.worldboss:SetScript("OnLeave",function() e.tips:Hide() end)

    self.instance:SetShown(not Save.hideEncounterJournal)
    self.worldboss:SetShown(not Save.hideEncounterJournal)
    setWorldbossText()
    setInstanceBossText()


    --Blizzard_EncounterJournal.lua
    local function EncounterJournal_ListInstances_set_Instance(button,showTips)
        local text,find='',nil
        if button.instanceID==1205 or button.instanceID==1192 or button.instanceID==1028 or button.instanceID==822 or button.instanceID==557 or button.instanceID==322 then--世界BOSS
            if showTips then
                set_EncounterJournal_World_Tips(button)--角色世界BOSS提示
                find=true
            else
                for name_server, info in pairs(wowSave) do
                    if name_server==e.Player.name_server then
                        local r2,g2,b2=GetClassColor(info.class)
                        local tab=info.worldboss and info.worldboss.boss--世界BOSS
                        local num=0
                        if tab then
                            for bossName, _ in pairs(tab) do
                                num=num+1
                                text= text~='' and text..' ' or text
                                text=text.. bossName
                            end
                        end
                    end
                end
            end
        else
            local n=GetNumSavedInstances()
            for i=1, n do
                local name, _, reset, _, _, _, _, _, _, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i);
                if button.tooltipTitle==name and (not reset or reset>0) and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 then
                    local num=encounterProgress..'/'..numEncounters..'|r'
                    num= encounterProgress==numEncounters and '|cnGREEN_FONT_COLOR:'..num..'|r' or num
                    if showTips then
                        if find then
                            e.tips:AddLine(' ')
                        end

                        e.tips:AddDoubleLine(name..'(|cnGREEN_FONT_COLOR:'..difficultyName..'|r): ',num);
                        local t;
                        for j=1,numEncounters do
                            local bossName,_,isKilled = GetSavedInstanceEncounterInfo(i,j);
                            local t2= bossName;
                            if t then t2=t2..' ('..j else t2=j..') '..t2 end;
                            if isKilled then t2='|cFFFF0000'..t2..'|r' end;
                            if j==numEncounters or t then
                                if not t then t=t2 t2=nil end;
                                e.tips:AddDoubleLine(t,t2);
                                t=nil;
                            else
                                t=t2;
                            end;
                        end;
                        find=true
                    else
                        text=text~='' and text..'\n' or text
                        difficultyName=difficultyName:gsub('%(', '')
                        difficultyName=difficultyName:gsub('%)', '')
                        difficultyName=difficultyName:gsub('（', ' ')
                        difficultyName=difficultyName:gsub('）', '')
                        text=text..difficultyName..' '..num
                    end
                end;
            end;
        end
        if not showTips then
            return text
        else
            return find
        end
    end
    hooksecurefunc('EncounterJournal_ListInstances', function()--界面, 副本击杀
        if Save.hideEncounterJournal then
            for _, button in pairs(self.instanceSelect.ScrollBox:GetFrames()) do
                if button and button.tipsText then
                    button.tipsText:SetText('')
                end
            end
            return
        end
        --setInitItem(e.tips)--创建物品
        for _, button in pairs(self.instanceSelect.ScrollBox:GetFrames()) do--ScrollBox.lua
            if button and button.tooltipTitle and button.instanceID then--button.bgImage:GetTexture() button.name:GetText()
                local text=EncounterJournal_ListInstances_set_Instance(button)
                if not button.tipsText and text~=''then
                    button.tipsText=e.Cstr(button,14, button.name)
                    button.tipsText:SetPoint('BOTTOMRIGHT', -8, 8)
                    button.tipsText:SetWidth(174)
                    button.tipsText:SetJustifyH('RIGHT')
                    button.tipsText:SetWordWrap(true)
                end
                if button.tipsText then
                    button.tipsText:SetText(text)
                end

                button:SetScript('OnEnter', function (self3)
                    if Save.hideEncounterJournal then
                        return
                    end
                    e.tips:SetOwner(self3, "ANCHOR_LEFT");
                    e.tips:ClearLines();
                    e.tips:AddDoubleLine(id, addName, ADVENTURE_JOURNAL)
                    e.tips:AddLine(' ')
                    if EncounterJournal_ListInstances_set_Instance(button,true) then
                        e.tips:AddLine(' ')
                    end
                    local texture=button.bgImage:GetTexture()
                    e.tips:AddDoubleLine('journalInstanceID: '..button.instanceID, texture and EMBLEM_SYMBOL..'ID: '..texture)
                    if texture then
                        e.tips.Portrait:SetTexture(texture)
                        e.tips.Portrait:SetShown(true)
                    end
                    e.tips:Show()
                end)
                button:SetScript('OnLeave', function() e.tips:Hide() end)
            end
       end
    end)

    --Boss, 战利品, 信息
    hooksecurefunc(EncounterJournalItemMixin,'Init',function(self2, elementData)--Blizzard_EncounterJournal.lua
        if Save.hideEncounterJournal or not self2.link or not self2.itemID then
            return
        end
        if self2.name then--幻化
            local text, collected = GetItemCollected(self2.link, nil, true)--物品是否收集, 返回图标
            if text then
                if not collected then
                    self2.name:SetText(self2.name:GetText()..text)
                end
            else
                local mountID = C_MountJournal.GetMountFromItem(self2.itemID)--坐骑物品
                local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(self2.itemID))--宠物物品
                text=speciesID and GetPetCollected(speciesID) or mountID and GetMountCollected(mountID)--宠物, 收集数量
                if text then
                    self2.name:SetText(self2.name:GetText()..text)
                end
            end
        end
        if self2.slot then--专精图标
            local specTable = GetItemSpecInfo(self2.link) or {}
            local specTableNum=#specTable
            if specTableNum>0 then
                local specA=''
                local class
                table.sort(specTable, function (a2, b2) return a2<b2 end)
                for k,  specID in pairs(specTable) do
                    local icon2, _, classFile=select(4, GetSpecializationInfoByID(specID))
                    if icon2 and classFile then
                        icon2='|T'..icon2..':0|t'
                        specA = specA..((class and class~=classFile) and '  ' or '')..icon2
                        class=classFile
                    end
                end
                if specA~='' then
                    self2.slot:SetText((self2.slot:GetText() or '')..specA)
                end
            end
        end
    end)
    --boss, ID, 信息
    hooksecurefunc('EncounterJournal_DisplayInstance', function(instanceID, noButton)--Blizzard_EncounterJournal.lua
        local self2 = self.encounter;
        if Save.hideEncounterJournal or not instanceID then
            if self2.instance.Killed then
                self2.instance.Killed:SetText('')
            end
            return
        end
        local name, description, bgImage, buttonImage1, loreImage, buttonImage, dungeonAreaMapID = EJ_GetInstanceInfo(instanceID)
        if description then
            local mapName, parentMapID
            if dungeonAreaMapID and dungeonAreaMapID > 0 then
                local mapInfo= C_Map.GetMapInfo(dungeonAreaMapID)
                if mapInfo then
                    mapName= mapInfo.name
                    parentMapID= mapInfo.parentMapID
                    if parentMapID then
                        mapInfo=C_Map.GetMapInfo(parentMapID)
                        if mapInfo and mapInfo.name then
                            parentMapID=mapInfo.name..'UiMapID: '..parentMapID
                        end
                    end
                end
            end
            local text='journalInstanceID: '..instanceID
            --..((dungeonAreaMapID and dungeonAreaMapID>0) and ' UiMapID: '..dungeonAreaMapID or '')
            ..(mapName and '|n'..mapName..'UiMapID: '..dungeonAreaMapID or '')
            ..(parentMapID and '|n'.. parentMapID or '')
            ..(buttonImage and '|n|T'..buttonImage..':0|t'..buttonImage or '')
            ..((buttonImage1 and buttonImage1~=buttonImage) and '|n|T'..buttonImage1..':0|t'..buttonImage1 or '')
            ..(bgImage and '|n|T'..bgImage..':0|t'..bgImage or '')
            ..(loreImage and '|n|T'..loreImage..':0|t'..loreImage or '')
            self2.instance.LoreScrollingFont:SetText(description..'\n'..text)
        end
        if not noButton then
            for _, button in pairs(self2.info.BossesScrollBox:GetFrames()) do
                button:SetScript('OnEnter', function(self3)
                    local index=self3.GetOrderIndex()
                    if not Save.hideEncounterJournal and index then
                        local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfoByIndex(index)
                        e.tips:SetOwner(self3, "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(id, addName)
                        e.tips:AddLine(' ')
                        if instanceID2 then
                            e.tips:AddDoubleLine(name2, 'instanceID: '..instanceID2)
                        end
                        if journalEncounterID then
                            e.tips:AddDoubleLine('journalEncounterID: '..'|cnGREEN_FONT_COLOR:'..journalEncounterID..'|r', (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID or ' ')
                        end
                        if dungeonEncounterID then
                            e.tips:AddDoubleLine('dungeonEncounterID: '..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
                            local numKill=wowBossKilled[dungeonEncounterID]
                            if numKill then
                                e.tips:AddDoubleLine(KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..VOICEMACRO_LABEL_CHARGE1)
                            end
                        end

                        e.tips:Show()
                    end
                end)
                button:SetScript('OnLeave', function() e.tips:Hide() end)
            end
        end
        if self2.instance.mapButton then
            self2.instance.mapButton:SetScript('OnEnter', function(self3)--综述,小地图提示
                local instanceName, description2, _, _, _, _, dungeonAreaMapID2 = EJ_GetInstanceInfo();
                if dungeonAreaMapID2 and instanceName then
                    e.tips:SetOwner(self3, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(instanceName, 'UiMapID: '..dungeonAreaMapID2)
                    e.tips:AddLine(' ')
                    e.tips:AddLine(description2, nil,nil,nil, true)
                    e.tips:Show()
                end
            end)
            self2.instance.mapButton:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        if not self2.instance.Killed then--综述, 添加副本击杀情况
            self2.instance.Killed=e.Cstr(self2.instance, 14, self2.instance.title)
            self2.instance.Killed:SetPoint('BOTTOMRIGHT', -33, 126)
            self2.instance.Killed:SetJustifyH('RIGHT')
        end
        self2.instance.Killed.instanceID=instanceID
        self2.instance.Killed.tooltipTitle=name
        self2.instance.Killed:SetText(EncounterJournal_ListInstances_set_Instance(self2.instance.Killed))
    end)
    --战利品, 套装, 收集数
    hooksecurefunc(self.LootJournalItems.ItemSetsFrame,'ConfigureItemButton', function(self2, button)--Blizzard_LootJournalItems.lua
        local has = C_TransmogCollection.PlayerHasTransmogByItemInfo(button.itemID)
        if has==false and not button.tex and not Save.hideEncounterJournal then
            button.tex=button:CreateTexture()
            button.tex:SetSize(16,16)
            button.tex:SetPoint('BOTTOMRIGHT',2,-2)
            button.tex:SetAtlas(e.Icon.transmogHide)
        end
        if button.tex then
            button.tex:SetShown(has==false and not Save.hideEncounterJournal)
        end
    end)
    --战利品, 套装 , 收集数量
    local function lootSet(self2)
        if Save.hideEncounterJournal then
            return
        end
        local buttons = self2.buttons;
        local offset = HybridScrollFrame_GetOffset(self2)
        for i = 1, #buttons do
            local button= buttons[i];
            local index = offset + i;
            if ( index <= #self2.itemSets ) then
                local setID=self2.itemSets[index].setID
                local collected= setID and GetSetsCollectedNum(setID)--收集数量
                if collected and self2.itemSets[index].name then
                    button.SetName:SetText(self2.itemSets[index].name..collected)
                end
            end
        end
    end
    hooksecurefunc(self.LootJournalItems.ItemSetsFrame, 'UpdateList', lootSet);
    hooksecurefunc('HybridScrollFrame_Update', function(self2)
            if self2==self.LootJournalItems.ItemSetsFrame then
                lootSet(self2)
            end
    end)

    --BOSS技能 Blizzard_EncounterJournal.lua
    local function EncounterJournal_SetBullets_setLink(text)--技能加图标
        local find
        text=text:gsub('|Hspell:.-]|h',function(link)
            local t=link
            local icon= select(3, GetSpellInfo(link)) or GetSpellTexture(link:match('Hspell:(%d+)'))
            if icon then
                find=true
                return '|T'..icon..':0|t'..link
            end
        end)
        if find then
            return text
        end
    end
    hooksecurefunc('EncounterJournal_SetBullets', function(object, description, hideBullets)
        if Save.hideEncounterJournal then
            return
        end
        if not string.find(description, "%$bullet;") then
            local text=EncounterJournal_SetBullets_setLink(description)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight());
            end
            return
        end
        local desc = strtrim(string.match(description, "(.-)%$bullet;"))
        if (desc) then
            local text=EncounterJournal_SetBullets_setLink(desc)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight());
            end
        end

        local bullets = {}
        local k = 1;
        local parent = object:GetParent();
        for v in string.gmatch(description,"%$bullet;([^$]+)") do
            tinsert(bullets, v);
        end
        for j = 1,#bullets do
            local text = strtrim(bullets[j]).."|n|n";
            if (text and text ~= "") then
                text=EncounterJournal_SetBullets_setLink(text)
			    local bullet = parent.Bullets and parent.Bullets[k];
                if text and bullet then
                    bullet.Text:SetText(text);
                    if (bullet.Text:GetContentHeight() ~= 0) then
                        bullet:SetHeight(bullet.Text:GetContentHeight());
                    end
                end
                k = k + 1;
            end
        end
    end)
    hooksecurefunc('EncounterJournal_OnClick', function(self2, d)--右击发送超链接
        if d=='RightButton' and self2.link and not Save.hideEncounterJournal then
            if not ChatEdit_GetActiveWindow() then
                ChatFrame_OpenChat(self2.link, SELECTED_DOCK_FRAME)
            else
                ChatEdit_InsertLink(self2.link)
            end
            return
        end
    end)
    hooksecurefunc('EncounterJournal_UpdateButtonState', function(self2)--技能提示
        self2:EnableMouse(true)
        self2:RegisterForClicks("LeftButtonDown","RightButtonDown")
        self2:SetScript("OnEnter", function(self3)
            local frame2=self3:GetParent()
            local spellID= frame2 and frame2.spellID
            if spellID and not Save.hideEncounterJournal then
                e.tips:SetOwner(self3, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(spellID)
                e.tips:Show()
            end
        end)
        self2:SetScript('OnLeave', function() e.tips:Hide() end)
    end)
    --BOSS模型
    hooksecurefunc('EncounterJournal_DisplayCreature', function(self2, forceUpdate)
        if not Save.hideEncounterJournal and self.creatureDisplayID and not self.creatureDisplayIDText then
            local modelScene = self.encounter.info.model;
            self.creatureDisplayIDText=e.Cstr(modelScene,14, modelScene.imageTitle)
            self.creatureDisplayIDText:SetPoint('BOTTOMLEFT', 5, 2)
        end
        if self.creatureDisplayIDText then
            self.creatureDisplayIDText:SetText((self.creatureDisplayID and not Save.hideEncounterJournal) and MODEL..'ID: '..self.creatureDisplayID or '')
        end
    end)

    --记录上次选择版本
    hooksecurefunc('EncounterJournal_TierDropDown_Select', function(_, tier)
        Save.EncounterJournalTier=tier
    end)

    --记录上次选择TAB
    hooksecurefunc('EJ_ContentTab_Select', function(id2)
        Save.EncounterJournalSelectTabID=id2
    end)
    if not Save.hideEncounterJournal then
        local numTier=EJ_GetNumTiers()
        if numTier and Save.EncounterJournalTier and Save.EncounterJournalTier<=numTier then
            EJ_SelectTier(Save.EncounterJournalTier)
        end
        if Save.EncounterJournalSelectTabID then
            EJ_ContentTab_Select(Save.EncounterJournalSelectTabID)
        end
    end
end


--#######
--更新数据
--#######
local function updateChallengeMode()--{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数} 地下城挑战
    local tab={itemLink=wowSave[e.Player.name_server].keystones.itemLink}
    local score=C_ChallengeMode.GetOverallDungeonScore();
    if score and score>0 then
        tab.score=score--总分数
        tab.all=#C_MythicPlus.GetRunHistory(true, true)--总次数
        tab.week=e.Player.week
        local info = C_MythicPlus.GetRunHistory(false, true)
        if info and #info>0 then
            tab.weekNum=#info--本周次数
            local activities=C_WeeklyRewards.GetActivities(1)
            if activities then
                local lv=0
                for _,v in pairs(activities) do
                    if v and v.level then
                        if v.level and v.level >lv then
                            lv=v.level;
                        end
                    end
                end
                if lv > 0 then
                    tab.weekLevel=lv--本周最高
                end
            end
        end
    end
    wowSave[e.Player.name_server].keystones=tab
end

local function updateItems()--更新物品
    wowSave[e.Player.name_server].keystones.itemLink={}
    wowSave[e.Player.name_server].items={}--{itemID={bag=包, bank=银行}}
    for bagID=0, NUM_BAG_SLOTS do
        for slotID=1,GetContainerNumSlots(bagID) do
            local itemID = GetContainerItemID(bagID, slotID)
            if itemID then
                if C_Item.IsItemKeystoneByID(itemID) then--挑战
                    local itemLink=GetContainerItemLink(bagID, slotID)
                    if itemLink then
                        table.insert(wowSave[e.Player.name_server].keystones.itemLink, itemLink)
                    end
                else
                    local bag=GetItemCount(itemID)--物品ID
                    wowSave[e.Player.name_server].items[itemID]={
                        bag=bag,
                        bank=GetItemCount(itemID,true)-bag,
                    }
                end
            end
        end
    end

    wowSave[e.Player.name_server].money=GetMoney()
end

local function updateCurrency(arg1)--更新货币 {currencyID = 数量}
    if arg1 then
        local info = C_CurrencyInfo.GetCurrencyInfo(arg1)
        if info and info.quantity then
            wowSave[e.Player.name_server].currencys[arg1]=info.quantity
        end
    else
        for i=1, C_CurrencyInfo.GetCurrencyListSize() do
            local link =C_CurrencyInfo.GetCurrencyListLink(i)
            local currencyID = link and C_CurrencyInfo.GetCurrencyIDFromLink(link)
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyID and info and info.quantity then
                wowSave[e.Player.name_server].currencys[currencyID]=info.quantity
            end
        end
    end
end

local function undateInstance(encounterID, encounterName)--副本, 世界BOSS
    local tab=wowSave[e.Player.name_server].worldboss.boss or {}--已杀世界BOSS
    for i=1, GetNumSavedWorldBosses() do--{week=周数, boss={name=true}}}
        local bossName,_,reset=GetSavedWorldBossInfo(i)
        if bossName and (not reset or reset>0) then
            bossName=bossName:gsub(',.+','')
            tab[bossName] = true
        end
    end
    if encounterName  then
        encounterName=encounterName:gsub(',.+','')
        tab[encounterName]=true
    end
    wowSave[e.Player.name_server].worldboss={
        week=e.Player.week,
        boss=tab
    }

    tab={}
    for i=1, GetNumSavedInstances() do--副本
        local name, _, reset, difficulty, _, _, _, _, _, difficultyName, numEncounters, encounterProgress, extendDisabled = GetSavedInstanceInfo(i)
        if reset and reset>0 and numEncounters and encounterProgress and numEncounters>0 and encounterProgress>0 and difficultyName then
            local killed = encounterProgress ..'/'..numEncounters;
            killed = encounterProgress ==numEncounters and '|cnGREEN_FONT_COLOR:'..killed..'|r' or killed
            difficultyName=e.GetDifficultyColor(difficultyName, difficulty)
            tab[name] = tab[name] or {}
            tab[name][difficultyName]=killed
        end
    end
    wowSave[e.Player.name_server].instance = {
        week=e.Player.week,
        ins=tab
    }
end

local function setRareEliteKilled(unit)--稀有怪数据
    if unit=='loot' then
        unit='target'
        local classification = UnitExists(unit) and UnitClassification(unit)
        if classification == "rare" or classification == "rareelite" then
            local name=UnitName(unit)
            local num=name and wowSave[e.Player.name_server].rare.boss[name]
            if name and not num then
                wowSave[e.Player.name_server].rare.boss[name]=1
                setWorldbossText()
            end
        end
    elseif UnitIsDead(unit) then
        local classification = UnitClassification(unit)
        if classification == "rare" or classification == "rareelite" then
            local threat = UnitThreatSituation('player',unit)
            if threat and threat>0 then
                local name=UnitName(unit)
                if name then
                    local num=wowSave[e.Player.name_server].rare.boss[name]
                    wowSave[e.Player.name_server].rare.boss[name]=num and num + 1 or 1
                    setWorldbossText()--显示世界BOSS击杀数据
                end
            end
        end
    end
end

local function setCVar(reset, tips)
    local tab={
        ['missingTransmogSourceInItemTooltips']={
            value='1',
            msg=TRANSMOGRIFY..SOURCES..': '..SHOW,
        },
        ['nameplateOccludedAlphaMult']={
            value='0.15',
            msg=SPELL_FAILED_LINE_OF_SIGHT..'('..SHOW_TARGET_CASTBAR_IN_V_KEY..')'..CHANGE_OPACITY,
        },
        ['dontShowEquipmentSetsOnItems']={
            value='0',
            msg=EQUIPMENT_SETS:format(SHOW)
        },
        ['UberTooltips']={
            value='1',
            msg=SPELL_MESSAGES..': '..SHOW,
        }
    }
    if tips then
        for name, info in pairs(tab) do
            e.tips:AddDoubleLine(name..': '..info.value..' (|cff00ff00'..C_CVar.GetCVar(name)..'|r)', info.msg)
        end
        return
    end
    for name, info in pairs(tab) do
        if reset then
            local defaultValue = C_CVar.GetCVarDefault(name)
            local value = C_CVar.GetCVar(name)
            if defaultValue~=value then
                C_CVar.SetCVar(name, defaultValue)
                print(id, addName, '|cnGREEN_FONT_COLOR:'..RESET_TO_DEFAULT..'|r', name, defaultValue, info.msg)
            end
        elseif Save.setCVar then
            local value = C_CVar.GetCVar(name)
            if value~=info.value then
                C_CVar.SetCVar(name, info.value)
                print(id,addName ,name, info.value..'('..value..')', info.msg)
            end
        end
    end
end



--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')
panel:RegisterEvent('BOSS_KILL')
panel:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
panel:RegisterEvent('BAG_UPDATE_DELAYED')
panel:RegisterEvent('UPDATE_INSTANCE_INFO')
panel:RegisterEvent('CHALLENGE_MODE_MAPS_UPDATE')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:RegisterEvent('WEEKLY_REWARDS_UPDATE')

panel:RegisterEvent('ZONE_CHANGED_NEW_AREA')--e.Layer=nil

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            wowBossKilled= WoWToolsSave and WoWToolsSave['Boss_Killed'] or {}--{encounterID=数量}怪物击杀数量

            wowSave=WoWToolsSave and WoWToolsSave['WoW-All-Save'] or {}

            wowSave[e.Player.name_server] = wowSave[e.Player.name_server] or {--默认数据
                class=e.Player.class,
                race=select(2,UnitRace('player')),
                sex=UnitSex('player'),
                items={},--{itemID={bag=包, bank=银行}},
                keystones={itemLink={}},--{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数,week=周数},
                currencys={},--{currencyID = 数量}
                instance={},
                worldboss={},--{week=周数, boss=table}
                rare={day=date('%x'), boss={}},
            }

            setUnitInit(self)--设置默认提示位置

            for name_server, info in pairs(wowSave) do--清队不是本周数据
                local tab=info.keystones
                if tab and tab.week and  tab.week~=e.Player.week then
                    wowSave[name_server].keystones={itemLink={}}
                end
                tab=info.instance
                if tab and tab.week and tab.week~=e.Player.week then
                    wowSave[name_server].instance={}
                end
                tab=info.worldboss
                if tab and tab.week and tab.week~=e.Player.week then
                    wowSave[name_server].worldboss={}
                end
                tab=info.rare
                if tab then
                    local day=date('%x')
                    if tab.day~=day then
                        wowSave[name_server].rare={day=day,boss={}}
                    end
                end
            end

            updateItems()
            RequestRaidInfo()
            C_MythicPlus.RequestMapInfo()
            setWorldbossText()--显示世界BOSS击杀数据
            setInstanceBossText()--显示副本击杀数据

            setCVar()--设置CVar
            panel.setUnit:SetChecked(Save.showUnit)--单位提示
            panel.setDefaultAnchor:SetChecked(Save.setDefaultAnchor)--提示位置            
            panel.CVar:SetChecked(Save.setCVar)
            panel.setTips:SetChecked(Save.showTips)
            panel.showSource:SetChecked(Save.showSource)
            panel.showWoWInfo:SetChecked(Save.showWoWInfo)
            panel.Anchor:SetChecked(Save.setAnchor)
            panel.setAchievement:SetChecked(Save.showAchievement)

        elseif arg1=='Blizzard_ClassTalentUI' then
            local function setClassTalentSpell(self2, tooltip)--天赋
                local spellID = self2:GetSpellID()
                local spellTexture=spellID and  GetSpellTexture(spellID)
                if not spellTexture then
                    return
                end
                --setInitItem(tooltip)--创建物品
                tooltip:AddLine(SPELLS..'ID: '..spellID..'                ' ..EMBLEM_SYMBOL..'ID: '..spellTexture)
                tooltip.Portrait:SetTexture(spellTexture)
                tooltip.Portrait:SetShown(true)
            end
            hooksecurefunc(ClassTalentSelectionChoiceMixin, 'AddTooltipInstructions', setClassTalentSpell)--Blizzard_ClassTalentButtonTemplates.lua--天赋
            hooksecurefunc(ClassTalentButtonSpendMixin, 'AddTooltipInstructions', setClassTalentSpell)

        elseif arg1=='Blizzard_EncounterJournal' then---冒险指南
            setEncounterJournal()
            EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据

        elseif arg1=='Blizzard_AchievementUI' then--成就ID
            hooksecurefunc(AchievementTemplateMixin, 'Init', function(self2,elementData)--Blizzard_AchievementUI.lua
                if not Save.showAchievement then
                    return
                end
                local category = elementData.category;
                local achievementID,  description, icon, _
                if self2.index then
                    achievementID, _, _, _, _, _, _, description, _, icon= GetAchievementInfo(category, self2.index);
                else
                    achievementID, _, _, _, _, _, _, description, _, icon = GetAchievementInfo(self2.id);
                end
                self2.HiddenDescription:SetText(description..' ID: '..achievementID..(icon and ' |T'..icon..':0|t'..icon or ''))
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            updateCurrency()
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
            WoWToolsSave['WoW-All-Save'] = wowSave
            WoWToolsSave['Boss_Killed'] = wowBossKilled
        end

    elseif event=='INSPECT_READY' then--取得装等
        local unit=UnitGUID("mouseover")==arg1 and 'mouseover' or (e.GroupGuid[arg1] and e.GroupGuid[arg1].unit)
        if unit then
            --setInitItem(e.tips)
            getPlayerInfo(unit, arg1)
        end
    elseif event=='ZONE_CHANGED_NEW_AREA' then
        e.Layer=nil 

    elseif event=='PLAYER_ENTERING_WORLD' then
        e.Layer=nil
        if IsInInstance() then--稀有怪
            panel:UnregisterEvent('UNIT_FLAGS')
            panel:UnregisterEvent('LOOT_OPENED')
        else
            panel:RegisterEvent('UNIT_FLAGS')
            panel:RegisterEvent('LOOT_OPENED')
        end

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        C_MythicPlus.RequestMapInfo()

    elseif event=='BOSS_KILL' then
        if not IsInInstance() then
            undateInstance(arg1, arg2)
            setWorldbossText()--显示世界BOSS击杀数据
        else
            RequestRaidInfo()
        end
        wowBossKilled[arg1]=wowBossKilled[arg1] and wowBossKilled[arg1]+1 or 1--Boss击杀数量
    elseif event=='CURRENCY_DISPLAY_UPDATE' then
        updateCurrency(arg1)

    elseif event=='BAG_UPDATE_DELAYED' then
        updateItems()

    elseif event=='UPDATE_INSTANCE_INFO' then
        undateInstance()
        setInstanceBossText()--显示副本击杀数据
        EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据

    elseif event=='CHALLENGE_MODE_MAPS_UPDATE' then
        updateChallengeMode()

    elseif event=='UNIT_FLAGS' then--稀有怪
        setRareEliteKilled(arg1)
    elseif event=='LOOT_OPENED' then
        setRareEliteKilled('loot')
    elseif event=='WEEKLY_REWARDS_UPDATE' then
        EncounterJournal_Set_All_Info_Text()--冒险指南,右边,显示所数据
    end
end)




panel.name = addName;--添加新控制面板
panel.parent =id;
InterfaceOptions_AddCategory(panel)



panel.setTips=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--提示
panel.setTips.Text:SetText(ITEMS..INFO..':')
panel.setTips:SetPoint('TOPLEFT')

panel.setTips:SetScript('OnClick', function(self)
    if Save.showTips then
        Save.showTips=nil
    else
        Save.showTips=true
    end
end)

panel.showSource=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--来源
panel.showSource.Text:SetText(SOURCES)
panel.showSource:SetPoint('LEFT', panel.setTips.Text, 'RIGHT', 20, 0)
panel.showSource:SetScript('OnClick', function(self)
    if Save.showSource then
        Save.showSource=nil
    else
        Save.showSource=true
    end
end)

panel.showWoWInfo=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--帐号提示信息
panel.showWoWInfo.Text:SetText('WOW'..CHARACTER)
panel.showWoWInfo:SetPoint('LEFT', panel.showSource.Text, 'RIGHT', 20, 0)
panel.showWoWInfo:SetScript('OnClick', function(self)
    if Save.showWoWInfo then
        Save.showWoWInfo=nil
    else
        Save.showWoWInfo=true
    end
end)

panel.setUnit=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--单位提示
panel.setUnit.Text:SetText(COVENANT_MISSIONS_UNITS..INFO)
panel.setUnit:SetPoint('TOPLEFT', panel.setTips, 'BOTTOMLEFT', 0, -2)
panel.setUnit:SetScript('OnClick', function(self)
    if Save.showUnit then
        Save.showUnit=nil
    else
        Save.showUnit=true
    end
    setUnitInit(self)
end)

panel.setAchievement=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--成就ID
panel.setAchievement.Text:SetText(ACHIEVEMENTS..BINDING_HEADER_INTERFACE..' ID')
panel.setAchievement:SetPoint('TOPLEFT', panel.setUnit, 'BOTTOMLEFT', 0, -2)
panel.setAchievement:SetScript('OnClick', function()
    if Save.showAchievement then
        Save.showAchievement=nil
    else
        Save.showAchievement=true
    end
end)

panel.setDefaultAnchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--设置默认提示位置
panel.setDefaultAnchor.Text:SetText(DEFAULT..RESAMPLE_QUALITY_POINT..': '..FOLLOW..MOUSE_LABEL)
panel.setDefaultAnchor:SetPoint('TOPLEFT', panel.setAchievement, 'BOTTOMLEFT', 0, -20)
panel.setDefaultAnchor:SetScript('OnClick', function()
    if Save.setDefaultAnchor then
        Save.setDefaultAnchor=nil
    else
        Save.setDefaultAnchor=true
        Save.setAnchor=nil
        panel.Anchor:SetChecked(false)
    end
end)

panel.Anchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--指定提示位置
panel.Anchor.Text:SetText(COMBAT_ALLY_START_MISSION)
panel.Anchor:SetPoint('LEFT', panel.setDefaultAnchor.Text, 'RIGHT', 20, 0)
panel.Anchor:SetScript('OnClick', function(self)
    if Save.setAnchor then
        Save.setAnchor=nil
    else
        Save.setAnchor=true
        Save.setDefaultAnchor=nil
        panel.setDefaultAnchor:SetChecked(false)
    end
end)
panel.Anchor.select=e.Cbtn(panel,true)
panel.Anchor.select:SetPoint('LEFT', panel.Anchor.Text, 'RIGHT')
panel.Anchor.select:SetSize(80, 25)
panel.Anchor.select:SetText(SETTINGS)
panel.Anchor.select:SetScript('OnClick',function(self)
    if not self.frame then
        self.frame=CreateFrame('Frame',nil, UIParent)
        if Save.AnchorPoint and Save.AnchorPoint[1] and Save.AnchorPoint[3] and Save.AnchorPoint[4] and Save.AnchorPoint[5] then
            self.frame:SetPoint(Save.AnchorPoint[1], UIParent, Save.AnchorPoint[3], Save.AnchorPoint[4], Save.AnchorPoint[5])
        else
            self.frame:SetPoint('BOTTOMRIGHT', 0, 90)
        end
        self.frame:SetSize(140,140)
        self.frame.texture=self.frame:CreateTexture(nil,'ARTWORK')
        self.frame.texture:SetAllPoints(self.frame)
        self.frame.texture:SetAtlas('ForgeBorder-CornerBottomRight')
        self.frame.texture2=self.frame:CreateTexture(nil, 'BACKGROUND')
        self.frame.texture2:SetAllPoints(self.frame)
        --self.frame.texture2:SetAlpha(0.5)
        self.frame.texture2:SetAtlas('Adventures-Missions-Shadow')
    else
        if self.frame:IsShown() then
            self.frame:SetShown(false)
        else
            self.frame:SetShown(true)
        end
    end
    self.frame:RegisterForDrag("LeftButton", "RightButton")
    self.frame:SetClampedToScreen(true)
    self.frame:SetMovable(true)
    self.frame:SetScript("OnDragStart", function(self2) self2:StartMoving() end);
    self.frame:SetScript("OnDragStop", function(self2)
            ResetCursor();
            self2:StopMovingOrSizing();
            Save.AnchorPoint={self2:GetPoint(1)}
    end);
    self.frame:SetScript('OnMouseUp',function()
        ResetCursor()
    end)
end)

panel.inCombatHideTips=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--设置默认提示位置
panel.inCombatHideTips.Text:SetText(HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..HIDE)
panel.inCombatHideTips:SetPoint('TOPLEFT', panel.setDefaultAnchor, 'BOTTOMLEFT', 0, -2)
panel.inCombatHideTips:SetScript('OnClick', function()
    if Save.inCombatHideTips then
        Save.inCombatHideTips=nil
    else
        Save.inCombatHideTips=true
    end
end)


--设置CVar
panel.CVar=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
panel.CVar.Text:SetText(SETTINGS..' CVar')
panel.CVar:SetPoint('TOPLEFT', panel.inCombatHideTips, 'BOTTOMLEFT', 0, -30)
panel.CVar:SetScript('OnClick', function()
    if Save.setCVar then
        Save.setCVar=nil
        setCVar(true)
    else
        Save.setCVar=true
        setCVar()
    end
end)
panel.CVar:SetScript('OnEnter',function(self)
    e.tips:SetOwner(self, "ANCHOR_LEFT")
    e.tips:ClearLines()
    e.tips:AddDoubleLine(id, addName)
    e.tips:AddLine(' ')
    setCVar(nil, true)
    e.tips:Show()
end)
panel.CVar:SetScript('OnLeave', function() e.tips:Hide() end)
