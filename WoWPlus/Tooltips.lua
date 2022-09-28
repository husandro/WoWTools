local id, e = ...
local addName='Tooltips'
local Save={}

local function setInitItem(self, hide)--创建物品
    if not self.textLeft then--左上角字符
        self.textLeft=e.Cstr(self, 18)
        self.textLeft:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
        --self.textLeft:SetPoint('TOPLEFT', self, 'BOTTOMLEFT')下
    end
    if not self.text2Left then--左上角字符2
        self.text2Left=e.Cstr(self, 18)
        self.text2Left:SetPoint('LEFT', self.Text, 'RIGHT', 5, 0)
    end
    if not self.textRight then--右上角字符
        self.textRight=e.Cstr(self, 18)
        self.textRight:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
        --self.textRight:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')--下
    end
    if not self.backgroundQualityColor then--背景颜色
        self.backgroundQualityColor=self:CreateTexture(nil,'BACKGROUND')
        self.backgroundQualityColor:SetAllPoints(self)
        self.backgroundQualityColor:SetAlpha(0.15)
    end
    if not self.itemModel then--3D模型
        self.itemModel=CreateFrame("PlayerModel", nil, self);
        self.itemModel:SetFacing(0.35)
        self.itemModel:SetPoint("TOPRIGHT", self, 'TOPLEFT')
        self.itemModel:SetSize(250, 250)
    end
    if not self.textureTopRight then--右上角图标
        self.textureTopRight=self:CreateTexture()
        self.textureTopRight:SetPoint('TOPRIGHT',-2, -3)
        self.textureTopRight:SetSize(40,40)
        --self.textureTopRight:SetMask(e.Icon.mask)
    end

    if hide then
        self.textLeft:SetText('')
        self.text2Left:SetText('')
        self.textRight:SetText('')
        self.itemModel:ClearModel()
        self.itemModel:SetShown(false)
        self.textureTopRight:SetShown(false)
        self.backgroundQualityColor:SetShown(false)
        self.creatureDisplayID=nil--物品
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
    self:AddDoubleLine(MOUNTS..' ID: '..mountID, SUMMON..ABILITIES..' ID: '..spellID)
    if isFactionSpecific then
        self:AddDoubleLine(not faction and ' ' or LFG_LIST_CROSS_FACTION:format(faction==0 and e.Icon.horde2..THE_HORDE or e.Icon.alliance2..THE_ALLIANCE or ''), e.GetShowHide(not shouldHideOnChar) )
    end
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)
    self:AddDoubleLine(MODEL..' ID: '..creatureDisplayInfoID, TUTORIAL_TITLE61_DRUID..': '..(isSelfMount and YES or NO))
    self:AddDoubleLine(source,' ')

    if creatureDisplayInfoID and self.creatureDisplayID~=creatureDisplayInfoID then--3D模型
        self.itemModel:SetDisplayInfo(creatureDisplayInfoID)
        self.itemModel:SetShown(true)
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
    self:AddDoubleLine(PET..' ID: '..speciesID, MODEL..' ID: '..creatureDisplayID)--ID

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

    self.textureTopRight:SetTexture('Interface\\Icons\\Icon_PetFamily_'..PET_TYPE_SUFFIX[petType])--宠物类型图标
    self.textureTopRight:SetShown(true)

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
        self:AddDoubleLine(addName, 'Ctrl+'..SHOW, 1,0,1, 1,0,1)
        return
    end
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
    self.textLeft:SetText(itemLevel and hex..itemLevel..'|r' or '')

    if classID==2 or classID==4 then--幻化
        local appearanceID, sourceID =C_TransmogCollection.GetItemInfo(link)
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
            self.textureTopRight:SetAtlas(e.Icon.unlocked)
            self.textureTopRight:SetShown(true)
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
                hasTransmog = setMount(self, mountID, true)--坐骑
            elseif speciesID then
                setPet(self, speciesID)--宠物
            end
        end
    end
    

    local bag= GetItemCount(link)--物品数量
    local bank= GetItemCount(link,true) - bag
    self.textRight:SetText((bag>0 or bank>0) and hex..bank..e.Icon.bank2..' '..bag..e.Icon.bag2..'|r' or '')

    self.backgroundQualityColor:SetColorTexture(r,g,b)--颜色
    self.backgroundQualityColor:SetShown(true)
end

e.tips:SetScript('OnTooltipSetItem', setItem)--物品
ItemRefTooltip:SetScript('OnTooltipSetItem', setItem)--物品

--宠物面板提示
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
        BattlePetTooltipTemplate_AddTextLine(self, addName..': Ctrl+'..SHOW, 1,0,1)
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
    if not self.backgroundQualityColor then--背景颜色
        self.backgroundQualityColor=self:CreateTexture(nil,'BACKGROUND')
        self.backgroundQualityColor:SetAllPoints(self)
        self.backgroundQualityColor:SetAlpha(0.15)
    end
    if (breedQuality ~= -1) then--设置背影颜色
        self.backgroundQualityColor:SetColorTexture(ITEM_QUALITY_COLORS[breedQuality].r, ITEM_QUALITY_COLORS[breedQuality].g, ITEM_QUALITY_COLORS[breedQuality].b)
    end
    self.backgroundQualityColor:SetShown(breedQuality~=-1)
end
hooksecurefunc("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
    setBattlePet(BattlePetTooltip, ...)
end)
hooksecurefunc('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
    setBattlePet(FloatingBattlePetTooltip, ...)
end)

hooksecurefunc(e.tips, 'SetToyByItemID', function(self)--玩具
    setItem(self)
    self:Show()
end)

local function setBuff(type, self, ...)
    setInitItem(self)
    local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod
    if type=='Buff' then
        type='Buff: '
        name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod= UnitBuff(...)
    elseif type=='Debuff' then
        t=' |cffff0000Debuff|r: '
        name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitDebuff(...)
    elseif type=='Aura' then
        name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod=UnitAura(...)
    end
    self:AddDoubleLine(type..'ID: '..spellId, '|T'..icon..':0|t'..icon)

    local mountID = C_MountJournal.GetMountFromSpell(spellId)
    if mountID then
        setMount(self, mountID)
    end
    --self:Show()
--[[
    local m='';
    if source=='player' then
        m=m..e.Ccol(COMBATLOG_FILTER_STRING_ME, source);
    elseif source=='pet' then
        m=m..e.Ccol(PET_TYPE_PET, source)
    elseif source then        
        m=m..e.Mark(source)..(e.Race(source) or '')..(e.Class(source) or '')..e.Role(source);
        
        local name=UnitName(source)--名字
        if name then
            m=m..e.Ccol(name, source)..' ';
        else
            source=source or source;
            m=m..source..' ';
        end
    end
    
    m=m..t..spellId;
    
    local mountID = C_MountJournal.GetMountFromSpell(spellId);
    if mountID then
        model= select(2, e.Mount(self, mountID));
    end
    
    if model then
        local t=Tip.M1:GetDisplayInfo();
        if not t or t~=model then Tip.M1:SetDisplayInfo(model) end
        if not Tip.M1:IsShown() then Tip.M1:Show() end
        
    elseif Tip.M1:IsShown() then
        Tip.M1:Hide();        
        
    end
    
    if icon then  icon=' |T'..icon..':0|t'..icon end   
    
    if isStealable  then m=m..' |cff00ff00'..ACTION_SPELL_STOLEN_DEBUFF..'|r' end
    self:AddDoubleLine(m, icon);
    self:Show();]]
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