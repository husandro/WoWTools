local id, e = ...
local addName= 'Tootips'
local Save={
    setDefaultAnchor=true,--指定点
    --AnchorPoint={},--指定点，位置
    --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',
    setCVar=e.Player.husandro,
    inCombatDefaultAnchor=true,
    ctrl= e.Player.husandro,--取得网页，数据链接
}
local panel=CreateFrame("Frame")

local function setInitItem(self, hide)--创建物品
    if not self.textLeft then--左上角字符
        self.textLeft=e.Cstr(self, {size=16})
        self.textLeft:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
    end
    if not self.text2Left then--左上角字符2
        self.text2Left=e.Cstr(self, {size=16})
        self.text2Left:SetPoint('LEFT', self.textLeft, 'RIGHT', 5, 0)
    end
    if not self.textRight then--右上角字符
        self.textRight=e.Cstr(self, {size=12, justifyH='RIGHT'})
        self.textRight:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
    end
    if not self.backgroundColor then--背景颜色
        self.backgroundColor=self:CreateTexture(nil,'BACKGROUND')
        self.backgroundColor:SetAllPoints(self)
    end
    if not self.playerModel and not Save.hideModel then
        self.playerModel=CreateFrame("PlayerModel", nil, self)--DressUpModel PlayerModel
        self.playerModel:SetFacing(-0.35)
        self.playerModel:SetPoint("BOTTOM", self, 'TOP', 0, -12)
        self.playerModel:SetSize(Save.modelSize or 100, Save.modelSize or 100)
        self.playerModel:SetShown(false)
    end

    if not self.Portrait then--右上角图标
        self.Portrait=self:CreateTexture(nil, 'BORDER')
        self.Portrait:SetPoint('TOPRIGHT',-2, -3)
        self.Portrait:SetSize(40,40)
    end

    if hide then
        self.textLeft:SetText('')
        self.text2Left:SetText('')
        self.textRight:SetText('')
        self.Portrait:SetShown(false)
        self.backgroundColor:SetShown(false)
        if self.playerModel then
            self.playerModel:ClearModel()
            self.playerModel:SetShown(false)
            self.playerModel.id=nil
        end
    end
end

--###########
--设置, 3D模型
--###########
local function set_Item_Model(self, tab)--set_Item_Model(self, {unit=nil, guid=nil, creatureDisplayID=nil, animID=nil, appearanceID=nil, visualID=nil})--设置, 3D模型
    if Save.hideModel then
        return
    end
    if tab.unit then
        if self.playerModel.id~=tab.guid and self.playerModel:CanSetUnit(tab.unit) then
            self.playerModel:SetUnit(tab.unit)
            self.playerModel.guid=tab.guid
            self.playerModel.id=tab.guid
            self.playerModel:SetShown(true)
        end
    elseif tab.creatureDisplayID  then
        if self.playerModel.id~= tab.creatureDisplayID then
            self.playerModel:SetDisplayInfo(tab.creatureDisplayID)
            if tab.animID then
                self.playerModel:SetAnimation(tab.animID)
            end
            self.playerModel.id=tab.creatureDisplayID
            self.playerModel:SetShown(true)
        end
    elseif tab.itemID then
        if self.playerModel.id~= tab.itemID then
            self.playerModel:SetItem(tab.itemID, tab.appearanceID, tab.visualID)
            self.playerModel.id= tab.itemID
            self.playerModel:SetShown(true)
        end
    end
end


--################
--取得网页，数据链接
--################
StaticPopupDialogs["WowheadQuickLinkUrl"] = {
    text= '|cffff00ff%s|r |cnGREEN_FONT_COLOR:CTRL+C |r'..BROWSER_COPY_LINK,
    button1 = e.onlyChinese and '关闭' or CLOSE,
    OnShow = function(self, web)
        self.editBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() s:GetParent():Hide() end)
        self.editBox:SetScript("OnEnterPressed", function(s) s:ClearFocus() s:GetParent():Hide() end)
        self.editBox:SetScript("OnKeyUp", function(s, key)
            if IsControlKeyDown() and key == "C" then
                s:ClearFocus() s:GetParent():Hide()
                print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r', s:GetText())
            end
        end)
        self.editBox:SetScript('OnEditFocusLost', function(self2)
            self2:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
        end)
        self.editBox:SetScript('OnEditFocusGained', function(s)
            s:SetTextColor(0,1,0)
            s:HighlightText()
        end)
        self.editBox:SetMaxLetters(0)
        self.editBox:SetWidth(self:GetWidth())
        self.editBox:SetText(web)
        self.editBox:HighlightText()
        self.editBox:SetAutoFocus(false)
        self.editBox:SetFocus(true)
        self.editBox:SetTextColor(0,1,0)
    end,
    hasEditBox = true,
    editBoxWidth = 240,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    --preferredIndex = 3,
}

local wowheadText= 'https://www.wowhead.com/%s=%d/%s'
local raiderioText= 'https://raider.io/characters/%s/%s/%s'
if LOCALE_zhCN or LOCALE_zhTW then
    wowheadText= 'https://www.wowhead.com/cn/%s=%d/%s'
    raiderioText= 'https://raider.io/cn/characters/%s/%s/%s'
elseif LOCALE_deDE then
    wowheadText= 'https://www.wowhead.com/de/%s=%d/%s'
    raiderioText= 'https://raider.io/de/characters/%s/%s/%s'
elseif LOCALE_esES or LOCALE_esMX then
    wowheadText= 'https://www.wowhead.com/es/%s=%d/%s'
    raiderioText= 'https://raider.io/es/characters/%s/%s/%s'
elseif LOCALE_frFR then
    wowheadText= 'https://www.wowhead.com/fr/%s=%d/%s'
    raiderioText= 'https://raider.io/fr/characters/%s/%s/%s'
elseif LOCALE_itIT then
    wowheadText= 'https://www.wowhead.com/it/%s=%d/%s'
    raiderioText= 'https://raider.io/it/characters/%s/%s/%s'
elseif LOCALE_ptBR then
    wowheadText= 'https://www.wowhead.com/pt/%s=%d/%s'
    raiderioText= 'https://raider.io/br/characters/%s/%s/%s'
elseif LOCALE_ruRU then
    wowheadText= 'https://www.wowhead.com/ru/%s=%d/%s'
    raiderioText= 'https://raider.io/ru/characters/%s/%s/%s'
elseif LOCALE_koKR then
    wowheadText= 'https://www.wowhead.com/ko/%s=%d/%s'
    raiderioText= 'https://raider.io/kr/characters/%s/%s/%s'
end

ItemRefTooltip.wowhead=e.Cbtn(ItemRefTooltip, {size={20,20},type=false})--取得网页，数据链接
ItemRefTooltip.wowhead:SetPoint('RIGHT',ItemRefTooltip.CloseButton, 'LEFT',0,2)
ItemRefTooltip.wowhead:SetNormalAtlas('questlegendary')
ItemRefTooltip.wowhead:SetScript('OnClick', function(self)
    if self.web then
        StaticPopup_Show("WowheadQuickLinkUrl",
            'WoWHead',
            nil,
            self.web
        )
    end
end)
ItemRefTooltip.wowhead:SetShown(false)

--get_Web_Link({frame=self, type='npc', id=companionID, name=speciesName, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
--get_Web_Link({unitName=name, realm=realm, col=nil})--取得单位, raider.io 网页，数据链接
local RegionName= GetCurrentRegionName()
local function get_Web_Link(tab)
    if tab.frame==ItemRefTooltip then
        if tab.type and tab.id then
            ItemRefTooltip.wowhead.web=format(wowheadText, tab.type, tab.id, tab.name or '')
            ItemRefTooltip.wowhead:SetShown(true)
        end
    elseif Save.ctrl and  not UnitAffectingCombat('player') then
        if tab.id then
            if tab.type=='quest' then
                if not tab.name then
                    local index= C_QuestLog.GetLogIndexForQuestID(tab.id)
                    local info= index and C_QuestLog.GetInfo(index)
                    tab.name= info and info.title
                end
            end
            local web=format(wowheadText, tab.type, tab.id, tab.name or '')
            if tab.isPetUI then
                if tab.frame then
                    BattlePetTooltipTemplate_AddTextLine(tab.frame, 'wowhead  Ctrl+Shift')
                end
            else
                tab.frame:AddDoubleLine((tab.col or '')..'WoWHead', (tab.col or '')..'Ctrl+Shift')
            end
            if IsControlKeyDown() and IsShiftKeyDown() then
                StaticPopup_Show("WowheadQuickLinkUrl",
                    'WoWHead',
                    nil,
                    web
                )
            end
        elseif tab.unitName then
            if tab.frame then
                tab.frame:SetText(e.Icon.info2..tab.col..'Raider.IO Shift+Ctrl')
                tab.frame:SetShown(true)
            else
                e.tips:AddDoubleLine(e.Icon.info2..(tab.col or '')..'Raider.IO', (tab.col or '')..'Ctrl+Shift')
                e.tips:SetShown(true)
            end
            if IsControlKeyDown() and IsShiftKeyDown() then
                StaticPopup_Show("WowheadQuickLinkUrl",
                    'Raider.IO',
                    nil,
                    format(raiderioText, RegionName, tab.realm or e.Player.realm, tab.unitName)
                )
            end
        end
    elseif tab.frame and not tab.isPetUI then
        tab.frame:SetText('')
        tab.frame:SetShown(false)
    end
end

local function setMount(self, mountID)--坐骑 
    self:AddLine(' ')
    local name, spellID, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected=C_MountJournal.GetMountInfoByID(mountID)
    self:AddDoubleLine((e.onlyChinese and '坐骑' or MOUNTS)..' '..mountID, spellID and (e.onlyChinese and '召唤技能' or (SUMMON..ABILITIES))..' '..spellID)
    if isFactionSpecific then
        self.textRight:SetText(not faction and ' ' or format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, faction==0 and e.Icon.horde2..(e.onlyChinese and '部落' or THE_HORDE) or e.Icon.alliance2..(e.onlyChinese and '联盟' or THE_ALLIANCE) or ''))
    end
    local creatureDisplayInfoID, description, source, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        self:AddDoubleLine((e.onlyChinese and '模型' or MODEL)..' '..creatureDisplayInfoID, (e.onlyChinese and '变形' or TUTORIAL_TITLE61_DRUID)..' '..e.GetYesNo(isSelfMount))
    end
    if source then
        self:AddLine(source,nil,nil,nil,true)
    end
    set_Item_Model(self, {creatureDisplayID=creatureDisplayInfoID, animID=animID, itemID=nil, appearanceID=nil, visualID=nil})--设置, 3D模型

    self.text2Left:SetText(isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')

    get_Web_Link({frame=self, type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
end


local function setPet(self, speciesID, setSearchText)--宠物
    if not speciesID or speciesID< 1 then
        return
    end
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if obtainable then--可得到的
        self:AddLine(' ')

        local AllCollected, CollectedNum, CollectedText= e.GetPetCollectedNum(speciesID)--收集数量
        self.textLeft:SetText(CollectedNum or '')
        self.text2Left:SetText(CollectedText or '')
        self.textRight:SetText(AllCollected or '')

        self:AddDoubleLine((e.onlyChinese and '宠物' or PET)..' '..speciesID..(speciesIcon and '  |T'..speciesIcon..':0|t'..speciesIcon or ''), (creatureDisplayID and (e.onlyChinese and '模型' or MODEL)..' '..creatureDisplayID or '')..(companionID and ' NPC '..companionID or ''))--ID

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
        if not isTradeable then
            self:AddLine(e.onlyChinese and '该宠物不可交易' or BATTLE_PET_NOT_TRADABLE, 1,0,0)
        end
    end
    if tooltipSource then
        self:AddLine(tooltipSource,nil,nil,nil, true)--来源
    end
    if petType then
        self.Portrait:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType])
        self.Portrait:SetShown(true)
    end
    set_Item_Model(self, {creatureDisplayID=creatureDisplayID, animID=nil, itemID=nil, appearanceID=nil, visualID=nil})--设置, 3D模型

    if setSearchText and speciesName and PetJournalSearchBox and PetJournalSearchBox:IsVisible() then--宠物手册，设置名称
        PetJournalSearchBox:SetText(speciesName)
    end

    get_Web_Link({frame=self, type='npc', id=companionID, name=speciesName, col= nil, isPetUI=false})--取得网页，数据链接
end

--############
--设置,物品信息
--############
local function setItem(self, ItemLink)
    if not ItemLink then
        return
    end
    local itemName, _, itemQuality, itemLevel, _, _, _, _, _, _, _, _, _, bindType, expacID, setID = GetItemInfo(ItemLink)
    local itemID, itemType, itemSubType, itemEquipLoc, itemTexture, classID, subclassID = GetItemInfoInstant(ItemLink)
    itemID = itemID or ItemLink:match(':(%d+):')
    local r, g, b, col= 1,1,1,e.Player.col
    if itemQuality then
        r, g, b, col= GetItemQualityColor(itemQuality)
        col=col and '|c'..col
    end
    if expacID then--版本数据
        self:AddDoubleLine(e.GetExpansionText(expacID))
    end
    self:AddDoubleLine(itemID and (e.onlyChinese and '物品' or ITEMS)..' '.. itemID or ' ' , itemTexture and '|T'..itemTexture..':0|t'..itemTexture)--ID, texture
    if classID and subclassID then
        self:AddDoubleLine((itemType and itemType..' classID'  or 'classID') ..' '..classID, (itemSubType and itemSubType..' subID' or 'subclassID')..' '..subclassID)
    end

    if classID==2 or classID==4 then
        itemLevel= GetDetailedItemLevelInfo(ItemLink) or itemLevel--装等
        if itemLevel and itemLevel>1 then
            local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]--比较装等
            if slot then
                self:AddDoubleLine(_G[itemEquipLoc]..' '..itemEquipLoc, (e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..slot)--栏位
                local slotLink=GetInventoryItemLink('player', slot)
                local text
                if slotLink then
                    local slotItemLevel= GetDetailedItemLevelInfo(slotLink)
                    if slotItemLevel then
                        local num=itemLevel-slotItemLevel
                        if num>0 then
                            text=itemLevel..e.Icon.up2..'|cnGREEN_FONT_COLOR:+'..num..'|r'
                        elseif num<0 then
                            text=itemLevel..e.Icon.down2..'|cnRED_FONT_COLOR:'..num..'|r'
                        end
                    end
                else
                    text=itemLevel..e.Icon.up2
                end
                text= col..(text or itemLevel)..'|r'
                self.textLeft:SetText(text)
            end
        end

        local appearanceID, sourceID =C_TransmogCollection.GetItemInfo(ItemLink)--幻化
        local visualID
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                visualID=sourceInfo.visualID
                self.text2Left:SetText(sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
            end
        end
        set_Item_Model(self, {creatureDisplayID=nil, animID=nil, itemID=itemID, appearanceID=appearanceID, visualID=visualID})--设置, 3D模型

        if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
            self.Portrait:SetAtlas(e.Icon.unlocked)
        end

        local specTable = GetItemSpecInfo(ItemLink) or {}--专精图标
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

    --[[elseif setID then--套装
        local collectedNum= select(4, e.GetSetsCollectedNum(setID))
        if collectedNum then
            self.text2Left:SetText(collectedNum)
        end]]
    elseif C_ToyBox.GetToyInfo(itemID) then--玩具
        self.text2Left:SetText(PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
    else
        local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if mountID then
            setMount(self, mountID)--坐骑
        elseif speciesID then
            setPet(self, speciesID, true)--宠物
        end
    end

    local spellName, spellID = GetItemSpell(ItemLink)--物品法术
    if spellName and spellID then
        local spellTexture=GetSpellTexture(spellID)
        self:AddDoubleLine((itemName~=spellName and col..'['..spellName..']|r' or '')..(e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':0|t'..spellTexture or ' ')
    end

    local wowNum= 0--WoW 数量
    local bag= GetItemCount(ItemLink)--物品数量
    local bank= GetItemCount(ItemLink,true) - bag

    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        --local numPlayer=1 --帐号数据 --{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数},
        for guid, info in pairs(WoWDate) do
            if guid and info then
                local find
                for linkItem, _ in pairs(info.Keystone.itemLink) do
                self:AddDoubleLine(' ', linkItem)
                find=true
                end
                if find then
                    self:AddLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}))
                end
            end
        end
        if WoWDate[e.Player.guid] and WoWDate[e.Player.guid].Keystone then--挑战分数
            local score= WoWDate[e.Player.guid].Keystone.score
            if score and score>0 then
                local numAll= WoWDate[e.Player.guid].Keystone.all or 0
                local weekNum= WoWDate[e.Player.guid].Keystone.weekNum or 0
                local weekLevel= WoWDate[e.Player.guid].Keystone.weekLevel or 0
                self.textLeft:SetText(weekLevel.. e.GetKeystoneScorsoColor(score, true))
                self.text2Left:SetText(weekNum..'/'..numAll)
            end
        end
    else
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(WoWDate) do
            if guid and info and guid~=e.Player.guid then
                local tab=info.Item[itemID]
                if tab and tab.bag and tab.bank then
                    self:AddDoubleLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}), e.Icon.bank2..(tab.bank==0 and '|cff606060'..tab.bank..'|r' or tab.bank)..' '..e.Icon.bag2..(tab.bag==0 and '|cff606060'..tab.bag..'|r' or tab.bag))
                    bagAll=bagAll +tab.bag
                    bankAll=bankAll +tab.bank
                    numPlayer=numPlayer +1
                end
            end
        end
        if numPlayer>0 then
            wowNum= bagAll+ bankAll
            self:AddDoubleLine(numPlayer..' '..(e.onlyChinese and '角色' or CHARACTER)..' '..e.MK(wowNum+bag+bank, 3), e.Icon.wow2..e.MK(bagAll+bankAll, 3)..' = '..e.Icon.bank2..(bankAll==0 and '|cff606060'..bankAll..'|r' or e.MK(bankAll,3))..' '..e.Icon.bag2..(bagAll==0 and '|cff606060'..bagAll..'|r' or e.MK(bagAll, 3)))
        end
    end

    self.textRight:SetText(col..e.MK(wowNum, 3)..e.Icon.wow2..' '..e.MK(bank, 3)..e.Icon.bank2..' '..e.MK(bag, 3)..e.Icon.bag2..'|r')

    --setItemCooldown(self, itemID)--物品冷却

    self.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    self.backgroundColor:SetShown(true)

    get_Web_Link({frame=self, type='item', id=itemID, name=itemName, col=col, isPetUI=false})--取得网页，数据链接

    self:Show()
end

local function setSpell(self, spellID)--法术
    spellID = spellID or select(2, self:GetSpell())
    if not spellID then
        return
    end
    local name, _, icon, _, _, _, _, originalIcon= GetSpellInfo(spellID)
    local spellTexture=  originalIcon or icon or GetSpellTexture(spellID)
    self:AddDoubleLine((e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and '|T'..spellTexture..':0|t'..spellTexture)
    local mountID = C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        setMount(self, mountID)
    else
        local overrideSpellID = FindSpellOverrideByID(spellID)
        if overrideSpellID and overrideSpellID~=spellID then
            e.LoadDate({id=overrideSpellID, type='spell'})--加载 item quest spell
            local link= GetSpellLink(overrideSpellID)
            local name2, _, icon2, _, _, _, _, originalIcon2= GetSpellInfo(overrideSpellID)
            link= link or name2
            link= link and link..overrideSpellID or ('overrideSpellID '..overrideSpellID)
            if link then
                spellTexture=  originalIcon2 or icon2 or GetSpellTexture(overrideSpellID)
                e.tips:AddDoubleLine(format(e.onlyChinese and '代替%s' or REPLACES_SPELL, link), spellTexture and '|T'..spellTexture..':0|t'..spellTexture)
            end
        end
        get_Web_Link({frame=self, type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end
end

local function setCurrency(self, currencyID)--货币
    local info2 = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if info2 then
        self:AddDoubleLine((e.onlyChinese and '货币' or TOKENS)..' '..currencyID, info2.iconFileID and '|T'..info2.iconFileID..':0|t'..info2.iconFileID)
    end
    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= GetFactionInfoByID(factionID)
        if name then
            self:AddDoubleLine(e.onlyChinese and '声望' or REPUTATION, name..' '..factionID)
        end
    end

    local all,numPlayer=0,0
    for guid, info in pairs(WoWDate) do--帐号数据
        if guid~=e.Player.guid then
            local quantity=info.Currency[currencyID]
            if quantity and quantity>0 then
                self:AddDoubleLine(e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}), e.MK(quantity, 3))
                all=all+quantity
                numPlayer=numPlayer+1
            end
        end
    end
    if numPlayer>1 then
        self:AddDoubleLine(e.Icon.wow2..numPlayer..(e.onlyChinese and '角色' or CHARACTER), e.MK(all,3))
    end

    get_Web_Link({frame=self, type='currency', id=currencyID, name=info2.name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency

    self:Show()
end

local function setAchievement(self, achievementID)--成就
    if not achievementID then
        return
    end
    e.tips:AddLine(' ')
    local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)
    self.textLeft:SetText(points..(e.onlyChinese and '点' or RESAMPLE_QUALITY_POINT))--点数
    self.text2Left:SetText(completed and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已完成' or CRITERIA_COMPLETED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)..'|r')--否是完成
    self.textRight:SetText(isGuild and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '公会' or GUILD) or flags==0x4000 and ('|cffff00ff'..e.Icon.wow2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))  or '')

    self:AddDoubleLine((e.onlyChinese and '成就' or ACHIEVEMENTS)..' '..(flags==0x20000 and '|cffff00ff'..e.Icon.wow2..achievementID..'|r' or achievementID), icon and '|T'..icon..':0|t'..icon)
    if flags==0x20000 then
        self.textRight:SetText(e.Icon.wow2..'|cffff00ff'..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))
    end
    get_Web_Link({frame=self, type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
end

local function setQuest(self, questID)
    self:AddDoubleLine(e.GetExpansionText(nil, questID))--任务版本
    self:AddDoubleLine(e.onlyChinese and '任务' or QUESTS_LABEL, questID)
    local info = C_QuestLog.GetQuestTagInfo(questID)
    get_Web_Link({frame=self, type='quest', id=questID, name=info and info.tagName, col=nil, isPetUI=false})--取得网页，数据链接
end

--####
--Buff
--####
local function set_Aura(self, auraID)--Aura
    local name, _, icon, _, _, _, spellID = GetSpellInfo(auraID)
   if icon and spellID then
        self:AddDoubleLine((e.onlyChinese and '光环' or AURAS)..' '..spellID, '|T'..icon..':0|t'..icon)
        local mountID = C_MountJournal.GetMountFromSpell(spellID)
        if mountID then
            setMount(self, mountID)
        else
            get_Web_Link({frame=self, type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
        end
    end
end


--####
--声望
--####
local setFriendshipFaction=function(self, friendshipID)--friend声望
    local repInfo = C_GossipInfo.GetFriendshipReputation(friendshipID);
	if ( repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0) then
        local icon = (repInfo.texture and repInfo.texture>0) and repInfo.texture
        self:AddDoubleLine((e.onlyChinese and '个人声望' or (INDIVIDUALS..REPUTATION))..' '..friendshipID, icon and '|T'..icon..':0|t'..icon)
        get_Web_Link({frame=self, type='faction', id=friendshipID, name=repInfo.name, col=nil, isPetUI=false})--取得网页，数据链接
        self:Show()
    end
end

local function setMajorFactionRenown(self, majorFactionID)--名望
	local info = C_Reputation.IsMajorFaction(majorFactionID) and C_MajorFactions.GetMajorFactionData(majorFactionID)
    if info then
        if info.textureKit then
            self.Portrait:SetShown(true)
            self.Portrait:SetAtlas('MajorFactions_Icons_'..info.textureKit..'512')
            self.textLeft:SetText('|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'..'MajorFactions_Icons_'..info.textureKit..'512')
        end
        self:AddDoubleLine((e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..' '..majorFactionID, format(e.onlyChinese and '名望等级 %d' or MAJOR_FACTION_RENOWN_LEVEL_TOAST, info.renownLevel)..' '..('%i%%'):format(info.renownReputationEarned/info.renownLevelThreshold*100))
        get_Web_Link({frame=self, type='faction', id=majorFactionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
        self:Show()
    end
end


--#########
--生命条提示
--#########
local function set_Unit_Health_Bar(self, unit)
    if self:GetWidth()<100 then
        return
    end
    local value= unit and UnitHealth(unit)
    local max= unit and UnitHealthMax(unit)
    local r, g, b, left, right, col, text

    if value and max then
        r, g, b, col = GetClassColor(select(2, UnitClass(unit)))
        if UnitIsFeignDeath(unit) then
            text= e.onlyChinese and '假死' or BOOST2_HUNTERBEAST_FEIGNDEATH:match('|cFFFFFFFF(.+)|r') or NO..DEAD
        elseif value <= 0 then
            text = '|A:poi-soulspiritghost:0:0|a'..'|cnRED_FONT_COLOR:'..(e.onlyChinese and '死亡' or DEAD)..'|r'
        else
            local hp = value / max * 100;
            text = ('%i%%'):format(hp)..'  ';
            if hp<30 then
                text = '|A:GarrisonTroops-Health-Consume:0:0|a'..'|cnRED_FONT_COLOR:' .. text..'|r'
            elseif hp<60 then
                text='|cnGREEN_FONT_COLOR:'..text..'|r'
            elseif hp<90 then
                text='|cnYELLOW_FONT_COLOR:'..text..'|r'
            else
                text= '|c'..col..text..'|r'
            end
            left =e.MK(value, 2)
        end
        right = e.MK(max, 2)
        self:SetStatusBarColor(r, g, b)
    end
    if not self.text and text then
        self.text= e.Cstr(self)
        self.text:SetPoint('TOP', self, 'BOTTOM')--生命条
        self.text:SetJustifyH("CENTER");
    end
    if self.text then
        self.text:SetText(text or '');
    end
    if not self.textLeft and right then
        self.textLeft = e.Cstr(self)
        self.textLeft:SetPoint('TOPLEFT', self, 'BOTTOMLEFT')--生命条
        self.textLeft:SetJustifyH("LEFT");
        self.textRight = e.Cstr(self, {size=18})
        self.textRight:SetPoint('TOPRIGHT',0,-2)--生命条
        --self.textRight:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT')--生命条
        self.textRight:SetJustifyH("Right");
    end
    if self.textLeft then
        self.textLeft:SetText(left or '')
        self.textRight:SetText(right or '')
        if r and g and b then
            self.textLeft:SetTextColor(r,g,b)
            self.textRight:SetTextColor(r,g,b)
        end
    end
end

--#######
--设置单位
--#######
local function setUnitInfo(self, unit)--设置单位提示信息
    local name, realm= UnitName(unit)
    local isPlayer = UnitIsPlayer(unit)
    local guid = UnitGUID(unit)
    local isSelf=UnitIsUnit('player', unit)--我
    local isGroupPlayer= (not isSelf and e.GroupGuid[guid]) and true or nil--队友
    local r, g, b, col = GetClassColor(UnitClassBase(unit))--颜色
          col= col and '|c'..col or ''
    --设置单位图标  
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    if isPlayer then
        local hideLine--取得网页，数据链接

        if (englishFaction=='Alliance' or englishFaction=='Horde') then--派系
            self.Portrait:SetAtlas(englishFaction=='Alliance' and e.Icon.alliance or e.Icon.horde)
            self.Portrait:SetShown(true)
        end

        if CheckInteractDistance(unit, 1) and CanInspect(unit) then--取得装等
            NotifyInspect(unit);
        end

        --取得玩家信息
        local textLeft, text2Left
        local info= e.UnitItemLevel[guid]
        if info then
            if info.itemLevel and info.itemLevel>1 then--设置装等
                textLeft= col..info.itemLevel..'|r'
            end
            local icon= info.specID and select(4, GetSpecializationInfoByID(info.specID))--设置天赋
            if icon then
                text2Left="|T"..icon..':0|t'
            end
        end
        self.backgroundColor:SetColorTexture(r, g, b, 0.2)--背景颜色
        self.backgroundColor:SetShown(true)

        local isWarModeDesired=C_PvP.IsWarModeDesired()--争模式
        local statusIcon, statusText= e.PlayerOnlineInfo(unit)--单位，状态信息
        if statusIcon and statusText then
            textLeft= (textLeft or '')..statusIcon..statusText

        elseif isGroupPlayer then--队友
            local reason=UnitPhaseReason(unit)
            if reason then
                if reason==0 then
                    textLeft= (e.onlyChinese and '不同了阶段' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))..(textLeft or '')
                elseif reason==1 then
                    textLeft= (e.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.Player.LayerText))..(textLeft or '')
                elseif reason==2 then--战争模
                    textLeft= (isWarModeDesired and (e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF) or (e.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON))..(textLeft or '')
                elseif reason==3 then
                    textLeft= (e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..(textLeft or '')
                end
            end
        end
        if not IsInInstance() and UnitHasLFGRandomCooldown(unit) then
            text2Left= (text2Left or '')..'|T236347:0|t'
        end
        if textLeft then
            self.textLeft:SetText(textLeft)
        end
        if text2Left then
            self.text2Left:SetText(text2Left)
        end

        local isInGuild= guid and IsPlayerInGuildFromGUID(guid)
        local line=GameTooltipTextLeft1--名称
        if line then
            if isSelf then--魔兽世界时光徽章
                local price= C_WowTokenPublic.GetCurrentMarketPrice()
                C_WowTokenPublic.UpdateMarketPrice()
                if price then
                    GameTooltipTextRight1:SetText('|A:token-choice-wow:0:0|a'..col..e.MK(price/10000,2)..'|r|A:Front-Gold-Icon:0:0|a')
                    GameTooltipTextRight1:SetShown(true)
                end
            end
            line:SetText((isSelf and e.Icon.star2 or e.GetFriend(nil, guid, nil) or '')
                         ..col..e.Icon.toRight2..name..e.Icon.toLeft2
                         ..'|r')
        end

        realm= realm or e.Player.realm--服务器
        local region= e.Get_Region(realm)--服务器，EU， US
        self.textRight:SetText(col..realm..'|r'..(isSelf and e.Icon.star2 or realm==e.Player.realm and e.Icon.select2 or e.Player.Realms[realm] and '|A:Adventures-Checkmark:0:0|a' or '')..(region and region.col or ''))

        line=isInGuild and GameTooltipTextLeft2
        if line then
            local text=line:GetText()
            if text then
                line:SetText(e.Icon.guild2..col..text:gsub('(%-.+)','')..'|r')
                if GameTooltipTextRight2 then
                    GameTooltipTextRight2:SetText(' ')
                    GameTooltipTextRight2:SetShown(false)
                end
            end
        end

        line= isInGuild and GameTooltipTextLeft3 or GameTooltipTextLeft2
        if line then
            local classFilename= select(2, UnitClass(unit))--职业名称
            local sex = UnitSex(unit)
            local raceName, raceFile= UnitRace(unit)
            local level= UnitLevel(unit)
            local text= sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a'

            if MAX_PLAYER_LEVEL==level then
                text= text.. level
            else
                text= text..'|cnGREEN_FONT_COLOR:'..level..'|r'
            end

            local effectiveLevel= UnitEffectiveLevel(unit)
            if effectiveLevel~=level then
                text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r) '
            end

            local info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
            if info and info.currentSeasonScore and info.currentSeasonScore>0 then
                text= text..' '..(e.GetUnitRaceInfo({unit=unit, guid=guid, race=raceFile, sex=sex, reAtlas=false}) or '')
                        ..' '..e.Class(nil, classFilename)
                        ..' '..(UnitIsPVP(unit) and  '|cnGREEN_FONT_COLOR:PvP|r' or 'PvE')
                        ..'  '..e.GetKeystoneScorsoColor(info.currentSeasonScore,true)

                if info.runs and info.runs then
                    local bestRunLevel=0
                    for _, run in pairs(info.runs) do
                        if run.bestRunLevel and run.bestRunLevel>bestRunLevel then
                            bestRunLevel=run.bestRunLevel
                        end
                    end
                    if bestRunLevel>0 then
                        text= text..' ('..bestRunLevel..')'
                    end
                end
            else
                text= text..' '..(e.GetUnitRaceInfo({unit=unit, guid=guid, race=raceFile, sex=sex, reAtlas=false})  or '')
                        ..(raceName or '')
                        ..' '..(e.Class(nil, classFilename) or '')
                        ..' '..(UnitIsPVP(unit) and '(|cnGREEN_FONT_COLOR:PvP|r)' or '(PvE)')
            end
            text= col and col..text..'|r' or text
            line:SetText(text)

            line= isInGuild and GameTooltipTextRight3 or GameTooltipTextRight2
            if line then
                line:SetText(' ')
                line:SetShown(true)
            end
        end

        local num= isInGuild and 4 or 3
        local allNum= self:NumLines()
        for i=num, allNum do
            line=_G["GameTooltipTextLeft"..i]
            if line then
                if i==num then
                    if isSelf then--位面ID, 战争模式
                        line:SetText(e.Player.Layer and '|A:nameplates-holypower2-on:0:0|a'..col..e.Player.LayerText..' '..e.Player.Layer..'|r' or ' ')
                        line=_G["GameTooltipTextRight"..i]
                        if line then
                            if isWarModeDesired then
                                line:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE))
                            else
                                line:SetText(col..(e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF))
                            end
                            line:SetShown(true)
                        end
                    elseif isGroupPlayer then--队友位置
                        local mapID= C_Map.GetBestMapForUnit(unit)--地图ID
                        local mapInfo= mapID and C_Map.GetMapInfo(mapID)
                        if mapInfo and mapInfo.name and _G["GameTooltipTextLeft"..i] then
                            if mapInfo.name then
                                line=_G["GameTooltipTextLeft"..i]
                                line:SetText(e.Icon.map2..col..mapInfo.name)
                                line:SetShown(true)
                            end
                        end
                    else
                        if not hideLine  then
                            hideLine=line
                        else
                            line:SetText('')
                            line:SetShown(false)
                        end
                    end
                else
                    if not hideLine then
                        hideLine=line
                    else
                        line:SetText('')
                        line:SetShown(false)
                    end
                end
            end
        end
        get_Web_Link({frame=hideLine, unitName=name, realm=realm, col=col})--取得单位, raider.io 网页，数据链接

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        setPet(self, UnitBattlePetSpeciesID(unit), true)

    else
        for i=1, self:NumLines() do
            local line=_G["GameTooltipTextLeft"..i]
            if line then
                line:SetTextColor(r,g,b)
            end
        end

        if guid then
            local zone, npc = select(5, strsplit("-", guid))--位面,NPCID
            if zone then
                self:AddDoubleLine(col..e.Player.LayerText..' '..zone, col..'NPC '..npc, r,g,b, r,g,b)
                e.Player.Layer=zone
            end
            get_Web_Link({frame=self, type='npc', id=npc, name=name, col=col, isPetUI=false})--取得网页，数据链接
        end

        --怪物, 图标
        if UnitIsQuestBoss(unit) then--任务
            self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest')
            self.Portrait:SetShown(true)

        elseif UnitIsBossMob(unit) then--世界BOSS
            self.textLeft:SetText(col..(e.onlyChinese and '首领' or BOSS)..'|r')
            self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            self.Portrait:SetShown(true)
        else
            local classification = UnitClassification(unit);--TargetFrame.lua
            if classification == "rareelite" then--稀有, 精英
                self.textLeft:SetText(col..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r')
                self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
                self.Portrait:SetShown(true)

            elseif classification == "rare" then--稀有
                self.textLeft:SetText(col..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r')
                self.Portrait:SetAtlas('UUnitFrame-Target-PortraitOn-Boss-Rare-Star')
                self.Portrait:SetShown(true)
            else
                SetPortraitTexture(self.Portrait, unit)
                self.Portrait:SetShown(true)
            end
        end

        local type=UnitCreatureType(unit)--生物类型
        if type and not type:find(COMBAT_ALLY_START_MISSION) then
            self.textRight:SetText(col..type..'|r')
        end

    end

    if not Save.hideHealth then
        set_Unit_Health_Bar(GameTooltipStatusBar,unit)--生命条提示
    end

    set_Item_Model(self, {unit=unit, guid=guid, creatureDisplayID=nil, animID=nil, appearanceID=nil, visualID=nil})--设置, 3D模型
end

local function setCVar(reset, tips, notPrint)
    local tab={
        ['missingTransmogSourceInItemTooltips']={
            value='1',
            msg= e.onlyChinese and '显示装备幻化来源' or TRANSMOGRIFY..SOURCES..': '..SHOW,
        },
        ['nameplateOccludedAlphaMult']={
            value='0.15',
            msg= e.onlyChinese and '不在视野里, 姓名板透明度' or (SPELL_FAILED_LINE_OF_SIGHT..'('..SHOW_TARGET_CASTBAR_IN_V_KEY..')'..CHANGE_OPACITY),
        },
        ['dontShowEquipmentSetsOnItems']={
            value='0',
            msg= e.onlyChinese and '显法装备方案' or EQUIPMENT_SETS:format(SHOW),
        },
        ['UberTooltips']={
            value='1',
            msg= e.onlyChinese and '显示法术信息' or SPELL_MESSAGES..': '..SHOW,
        },
        ["alwaysCompareItems"]={
             value= "1",
             msg= e.onlyChinese and '总是比较装备' or ALWAYS..COMPARE_ACHIEVEMENTS:gsub(ACHIEVEMENTS, ITEMS)
        },
        ["profanityFilter"]={value= '0',msg= '禁用语言过虑 /reload', zh=true},
        ["overrideArchive"]={value= '0',msg= '反和谐 /reload', zh=true},
        ['cameraDistanceMaxZoomFactor']={value= '2.6', msg= e.onlyChinese and '视野距离' or FARCLIP},

        ["showTargetOfTarget"]={
            value= "1",
            msg= e.onlyChinese and '总是显示目标的目标' or OPTION_TOOLTIP_TARGETOFTARGET5,
        },
    }

    if tips then
        for name, info in pairs(tab) do
            if info.zh and LOCALE_zhCN or not info.zh then
                local curValue= C_CVar.GetCVar(name)
                e.tips:AddDoubleLine(
                    (curValue== info.value and '|cnGREEN_FONT_COLOR:' or '')
                    ..name..' '
                    ..(e.onlyChinese and '设置' or SETTINGS)..'|cffff00ff'..info.value..'|r'
                    ..' ('..(e.onlyChinese and '当前' or REFORGE_CURRENT)..'|cffff00ff'..C_CVar.GetCVar(name)..'|r) |r'
                    ..(e.onlyChinese and '默认' or DEFAULT)..'|cffff00ff'..C_CVar.GetCVarDefault(name)..'|r',
                    info.msg)
            end
        end
        return
    end

    for name, info in pairs(tab) do
        if info.zh and LOCALE_zhCN or not info.zh then
            if reset then
                local defaultValue = C_CVar.GetCVarDefault(name)
                local value = C_CVar.GetCVar(name)
                if defaultValue~=value then
                    C_CVar.SetCVar(name, defaultValue)
                    if not notPrint then
                        print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r', name, defaultValue, info.msg)
                    end
                end
            else
                local value = C_CVar.GetCVar(name)
                if value~=info.value then
                    C_CVar.SetCVar(name, info.value)
                    if not notPrint then
                        print(id,addName ,name, info.value..'('..value..')', info.msg)
                    end
                end
            end
        end
    end
end

local function set_FlyoutInfo(self, flyoutID)--法术, 弹出框
    self:AddLine(' ')
    local _, _, numSlots, isKnown= GetFlyoutInfo(flyoutID)
    for slot= 1, numSlots do
        local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            e.LoadDate({id=spellID, type='spell'})
            local name2, _, icon = GetSpellInfo(spellID)
            if name2 and icon then
                self:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..name2..'|r', (not isKnown2 and '|cnRED_FONT_COLOR:' or '').. spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            else
                self:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            end
        end
    end
    self:AddLine(' ')
    self:AddDoubleLine((not isKnown and '|cnRED_FONT_COLOR:' or '')..'flyoutID|r '..flyoutID, numSlots..' '..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL))
    self:AddDoubleLine(id, addName)
end

--###########
--宠物面板提示
--###########
local function set_Battle_Pet(self, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID < 1 then
        return
    end
    local speciesName, speciesIcon, _, companionID, tooltipSource, _, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if not self.Portrait then
        setInitItem(self, true)--创建物品
    end
    set_Item_Model(self, {creatureDisplayID=creatureDisplayID, animID=nil, itemID=nil, appearanceID=nil, visualID=nil})--设置, 3D模型
    --self.itemModel:SetDisplayInfo(creatureDisplayID)
    if obtainable then
        local numCollected, limit = C_PetJournal.GetNumCollectedInfo(speciesID)
        if numCollected==0 then
            BattlePetTooltipTemplate_AddTextLine(self, format(e.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN, 0, limit), 1,0,0)
        end
    end
    BattlePetTooltipTemplate_AddTextLine(self, (e.onlyChinese and '宠物' or PET)..' '..speciesID..'                  |T'..speciesIcon..':0|t'..speciesIcon)
    BattlePetTooltipTemplate_AddTextLine(self, 'NPC '..companionID..'                  '..(e.onlyChinese and '模型' or MODEL)..' '..creatureDisplayID)

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

    BattlePetTooltipTemplate_AddTextLine(self, tooltipSource)--来源提示

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

    local AllCollected, CollectedNum, CollectedText= e.GetPetCollectedNum(speciesID)--收集数量
    self.textLeft:SetText(CollectedNum or '')
    self.text2Left:SetText(CollectedText or '')
    self.textRight:SetText(not CollectedNum and AllCollected or '')

    get_Web_Link({frame=self, type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})--取得网页，数据链接
end

local function set_Azerite(self, powerID)--艾泽拉斯之心
    if powerID then
        self:AddLine(' ')
        self:AddDoubleLine('powerID', powerID)
        local info = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
        if info and info.spellID then
            setSpell(self, info.spellID)--法术
        end
    end
end




--####
--初始
--####
local function Init()
    setInitItem(ItemRefTooltip)
    setInitItem(e.tips)
    e.tips:HookScript("OnHide", function(self)--隐藏
        setInitItem(self, true)
    end)
    ItemRefTooltip:HookScript("OnHide", function (self)--隐藏
        setInitItem(self, true)
        ItemRefTooltip.wowhead.web=nil--取得网页，数据链接
        ItemRefTooltip.wowhead:SetShown(false)
    end)

    hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', setQuest)--世界任务ID GameTooltip_AddQuest

    --战斗宠物，技能 SharedPetBattleTemplates.lua
    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo, additionalText)
        local abilityID = abilityInfo:GetAbilityID();
        if abilityID then
            local _, _, icon, _, unparsedDescription = C_PetBattles.GetAbilityInfoByID(abilityID)
            local description = SharedPetAbilityTooltip_ParseText(abilityInfo, unparsedDescription)
            self.Description:SetText(description..'\n\n'..(e.onlyChinese and '技能' or ABILITIES)..' '..abilityID..(icon and '  |T'..icon..':0|t'..icon or ''))
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes,  function(tooltip,date)
        if tooltip~=GameTooltip and tooltip~=ItemRefTooltip then
            return
        end
        --25宏, 11动作条, 4矿, 14装备管理
        if date.type==2 then--单位
            if tooltip==e.tips then
                local unit= select(2, TooltipUtil.GetDisplayedUnit(tooltip))
                if unit then
                    setUnitInfo(tooltip, unit)
                end
            end

        elseif date.id and date.type then--and date.type~= 25 then
            if date.type==0 or date.type==19 then--TooltipUtil.lua 0物品 19玩具
                local itemID, itemLink=TooltipUtil.GetDisplayedItem(tooltip)
                itemLink= itemLink or itemID or date.id
                setItem(tooltip, itemLink)

            elseif date.type==1 then
                setSpell(tooltip, date.id)--法术

            elseif date.type==5 then
                setCurrency(tooltip, date.id)--货币

            elseif date.type==7 then--Aura
                set_Aura(tooltip, date.id)

            elseif date.type==8 then--艾泽拉斯之心
                set_Azerite(tooltip, date.id)

            elseif date.type==10 then
                setMount(tooltip, date.id)--坐骑

            elseif date.type==12 then--成就
                setAchievement(tooltip, date.id)

            elseif date.type==22 then--法术弹出框
                set_FlyoutInfo(tooltip, date.id)

            elseif date.type==23 then
                setQuest(tooltip, date.id)--任务

            elseif e.Player.husandro then
                tooltip:AddDoubleLine('id '..date.id, 'type '..date.type)
            end
        end
    end)


    --****
    --位置
    --****
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
        if Save.setDefaultAnchor and not (Save.inCombatDefaultAnchor and UnitAffectingCombat('player')) then
            self:ClearAllPoints()
            self:SetOwner(parent, Save.cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT', Save.cursorX or 0, Save.cursorY or 0)
        end
    end)

    --#########
    --生命条提示
    --#########
    if not Save.hideHealth then
        GameTooltipStatusBar:SetScript("OnValueChanged", function(self)
            local unit= select(2, TooltipUtil.GetDisplayedUnit(GameTooltip))
            if unit then
                set_Unit_Health_Bar(self, unit)
            end
        end);
    end

    --####
    --声望
    --####
    hooksecurefunc(ReputationBarMixin, 'ShowMajorFactionRenownTooltip', function(self)--Major名望, ReputationFrame.lua
        setMajorFactionRenown(e.tips, self.factionID)
    end)
    hooksecurefunc(ReputationBarMixin, 'ShowFriendshipReputationTooltip', function(self, friendshipID)--个人声望 ReputationFrame.lua
        setFriendshipFaction(e.tips, friendshipID)
    end)
    hooksecurefunc(ReputationBarMixin, 'OnEnter', function(self)--角色栏,声望
        if self.friendshipID or not self.factionID or (C_Reputation.IsMajorFaction(self.factionID) and not C_MajorFactions.HasMaximumRenown(self.factionID)) then
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
            local name, description, standingID, barMin, barMax, barValue, _, _, isHeader, _, hasRep, _, _, factionID, _, _ = GetFactionInfoByID(self.factionID)
            if factionID and not isHeader or (isHeader and hasRep) then
                e.tips:SetOwner(self, "ANCHOR_RIGHT");
                e.tips:AddLine(name..' '..standingID..'/'..MAX_REPUTATION_REACTION, 1,1,1)
                e.tips:AddLine(description, nil,nil,nil, true)
                e.tips:AddLine(' ')
                local gender = UnitSex("player");
                local factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender)
                local barColor = FACTION_BAR_COLORS[standingID]
                factionStandingtext=barColor:WrapTextInColorCode(factionStandingtext)--颜色
                if barValue and barMax then
                    if barMax==0 then
                        e.tips:AddLine(factionStandingtext..' '..('%i%%'):format( (barMin-barValue)/barMin*100), 1,1,1)
                    else
                        e.tips:AddLine(factionStandingtext..' '..e.MK(barValue, 3)..'/'..e.MK(barMax, 3)..' '..('%i%%'):format(barValue/barMax*100), 1,1,1)
                    end
                    e.tips:AddLine(' ')
                end

                e.tips:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..self.factionID or factionID, completedParagon)
                get_Web_Link({frame=e.tips, type='faction', id=factionID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
                e.tips:Show();
            elseif factionID or self.factionID then
                e.tips:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..(self.factionID or factionID), completedParagon)
                get_Web_Link({frame=e.tips, type='faction', id=factionID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
                e.tips:Show()
            end
        end
    end)

    hooksecurefunc('ReputationFrame_InitReputationRow',function(factionRow, elementData)--ReputationFrame.lua 声望 界面,
        local factionIndex = elementData.index;
        local factionID
        if ( factionIndex == GetSelectedFaction() ) then
            if ( ReputationDetailFrame:IsShown() ) then
                factionID= select(14, GetFactionInfo(factionIndex))
            end
        end
        if factionID and not ReputationDetailFrame.factionIDText then
            ReputationDetailFrame.factionIDText=e.Cstr(ReputationDetailFrame)
            ReputationDetailFrame.factionIDText:SetPoint('TOPLEFT', 6, -6)
        end
        if ReputationDetailFrame.factionIDText then
            ReputationDetailFrame.factionIDText:SetText(factionID and (e.onlyChinese and '声望' or REPUTATION)..' '..factionID or '')
        end
    end)

    --###########
    --宠物面板提示
    --###########
    hooksecurefunc("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
        set_Battle_Pet(BattlePetTooltip, ...)
    end)

    hooksecurefunc('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
        set_Battle_Pet(FloatingBattlePetTooltip, ...)
    end)

    hooksecurefunc(e.tips,"SetCompanionPet", function(self, petGUID)--设置宠物信息
        local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
        setPet(self, speciesID)--宠物
    end)

    setCVar(nil, nil, true)--设置CVar

    if Save.setCVar and LOCALE_zhCN then
        ConsoleExec("portal TW")
        SetCVar("profanityFilter", '0')

        local pre = C_BattleNet.GetFriendGameAccountInfo
        C_BattleNet.GetFriendGameAccountInfo = function(...)
            local gameAccountInfo = pre(...)
            gameAccountInfo.isInCurrentRegion = true
            return gameAccountInfo;
        end
    end

    if ExtraActionButton1 then
        ExtraActionButton1:SetScript('OnLeave', function()
            e.tips:Hide()
        end)
    end

    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)--POI提示 AreaPOIDataProvider.lua
        local uiMapID = self:GetMap() and self:GetMap():GetMapID()
        if self.areaPoiID then
            GameTooltip:AddDoubleLine('areaPoiID', self.areaPoiID)
        end
        if self.widgetSetID then
            GameTooltip:AddDoubleLine('widgetSetID', self.widgetSetID)
        end
        if uiMapID then
            GameTooltip:AddDoubleLine('mapID', uiMapID)
        end
        if self.factionID then
            setMajorFactionRenown(GameTooltip, self.factionID)--名望
        end
        if self.areaPoiID and uiMapID then
            local poiInfo= C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID)
            if poiInfo and poiInfo.atlasName  then
                GameTooltip:AddDoubleLine('atlasName', '|A:'..poiInfo.atlasName..':0:0|a'..poiInfo.atlasName)
            end
        end
        GameTooltip:Show()
    end)

    --#############
    --挑战, AffixID
    --Blizzard_ScenarioObjectiveTracker.lua
    if ScenarioChallengeModeAffixMixin then
        hooksecurefunc( ScenarioChallengeModeAffixMixin, 'OnEnter',function(self2)
            if self2.affixID then
                local _, _, filedataid = C_ChallengeMode.GetAffixInfo(self2.affixID)
                GameTooltip:AddDoubleLine('affixID '..self2.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ');
                GameTooltip:Show();
            end
        end)
    end

    local function create_Quest_Label(self)--添加任务ID
        if not self.questIDLabel then
            self.questIDLabel= e.Cstr(self)
            self.questIDLabel:EnableMouse(true)
            self.questIDLabel:SetScript('OnLeave', function() e.tips:Hide() end)
            self.questIDLabel:SetScript('OnEnter', function(self2)
                if self2.questID then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    securecallfunction(GameTooltip_AddQuest, self2, self2.questID)
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                end
            end)
        end
        return self.questIDLabel
    end
    hooksecurefunc('QuestMapFrame_ShowQuestDetails', function(questID)
        local label= QuestMapFrame.DetailsFrame.questIDLabel
        if not label then
            label= create_Quest_Label(QuestMapFrame.DetailsFrame)
            label:SetPoint('BOTTOMRIGHT',QuestMapFrame.DetailsFrame, 'TOPRIGHT', 20, 10)
        end
        label:SetText(questID or '')
        label.questID= questID
    end)
    QuestFrame:HookScript('OnShow', function(self)
        local questID= QuestInfoFrame.questLog and  C_QuestLog.GetSelectedQuest() or GetQuestID()
        local label= self.questIDLabel
        if not label then
            label= create_Quest_Label(self)
            label:SetPoint('TOPRIGHT', self, -30,-35)
        end
        label:SetText(questID or '')
        label.questID= questID
    end)

    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)--任务日志 显示ID
        local info= self.questLogIndex and C_QuestLog.GetInfo(self.questLogIndex)
        if not info or not info.questID or not HaveQuestData(info.questID) then
            return
        end
        e.tips:AddDoubleLine(e.GetExpansionText(nil, info.questID))--任务版本
        local lv=C_QuestLog.GetQuestDifficultyLevel(info.questID)--ID

        e.tips:AddDoubleLine((e.onlyChinese and '任务' or QUESTS_LABEL)..(lv and '['..lv..']' or ''), info.questID)
        local distanceSq= C_QuestLog.GetDistanceSqToQuest(info.questID)--距离
        if distanceSq then
            local _, x, y = QuestPOIGetIconInfo(info.questID)
            if x and y then
                x=math.modf(x*100) y=math.modf(y*100)
            end
            e.tips:AddDoubleLine(x and y and 'XY '..x..', '..y,  (e.onlyChinese and '距离' or TRACK_QUEST_PROXIMITY_SORTING)..' '..e.MK(distanceSq))--format(IN_GAME_NAVIGATION_RANGE, e.MK(distanceSq)))
        end
        if IsInGroup() then
            local n=GetNumGroupMembers()
            if n >1 then
                local acceto=0
                local u= IsInRaid() and 'raid' or 'party'
                for i=1, n do
                    local u2
                    if u=='party' and i==n then
                        u2='player'
                    else
                        u2=u..i
                    end
                    if C_QuestLog.IsUnitOnQuest(u2, info.questID) then
                        acceto=acceto+1
                    end
                end
                e.tips:AddDoubleLine((e.onlyChinese and '共享' or SHARE_QUEST)..' '..(acceto..'/'..(n-1)), e.GetYesNo(C_QuestLog.IsPushableQuest(info.questID)))
            end
        end
        get_Web_Link({frame=e.tips, type='quest', id=info.questID, name=info.title, col=nil, isPetUI=false})--取得网页，数据链接
        e.tips:Show()
    end)
end

local function set_Cursor_Tips(self)
    GameTooltip_SetDefaultAnchor(e.tips, self or UIParent)
    --e.tips:SetOwner(UIParent, 'ANCHOR_CURSOR_LEFT', Save.cursorX, Save.cursorY)
    e.tips:ClearLines()
    e.tips:SetUnit('player')
    e.tips:Show()
end
--##########
--设置 panel
--##########
local function Init_Panel()
    panel.name = e.Icon.mid..addName;--添加新控制面板
    panel.parent= id
    InterfaceOptions_AddCategory(panel)


    e.ReloadPanel({panel=panel, addName= addName, restTips=true, checked=not Save.disabled,--重新加载UI, 重置, 按钮
        disabledfunc=function()
            Save.disabled= not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
        clearfunc= function() Save=nil e.Reload() end}
    )


    local setDefaultAnchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--设置默认提示位置
    local inCombatDefaultAnchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    local Anchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--指定提示位置

    setDefaultAnchor.text:SetText(e.onlyChinese and '跟随鼠标' or FOLLOW..MOUSE_LABEL)
    setDefaultAnchor:SetPoint('TOPLEFT', 0, -48)
    setDefaultAnchor:SetChecked(Save.setDefaultAnchor)--提示位置
    setDefaultAnchor:SetScript('OnLeave', function() e.tips:Hide() end)
    setDefaultAnchor:SetScript('OnMouseDown', function(self)
        Save.setDefaultAnchor= not Save.setDefaultAnchor and true or nil
        if Save.setDefaultAnchor then
            Save.setAnchor=nil
            Anchor:SetChecked(false)
        end
        set_Cursor_Tips(self)
    end)


    local sliderCursorX = e.Create_Slider(panel, {w=100, min=-150, max=150, value=Save.cursorX or 0, setp=1, color=nil,
    text='X',
    func=function(self, value)
        value= tonumber(format('%i', value))
        value= value==0 and 0 or value
        self:SetValue(value)
        self.Text:SetText(value)
        Save.cursorX= value
        set_Cursor_Tips(self)
    end})
    sliderCursorX:SetPoint('TOPLEFT', setDefaultAnchor, 'BOTTOMRIGHT', 0, -16)
    sliderCursorX:SetScript('OnLeave', function() e.tips:Hide() end)

    local sliderCursorY = e.Create_Slider(panel, {w=100, min=-150, max=150, value=Save.cursorY or 0, setp=1, color=true,
    text='Y',
    func=function(self, value)
        value= tonumber(format('%i', value))
        value= value==0 and 0 or value
        self:SetValue(value)
        self.Text:SetText(value)
        Save.cursorY= value
        set_Cursor_Tips(self)
    end})
    sliderCursorY:SetPoint("LEFT", sliderCursorX, 'RIGHT',20,0)
    sliderCursorY:SetScript('OnLeave', function() e.tips:Hide() end)

    inCombatDefaultAnchor.text:SetText(e.onlyChinese and '战斗中：默认' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DEFAULT)
    inCombatDefaultAnchor:SetPoint('TOPLEFT', sliderCursorX.Low, 'BOTTOMLEFT',0,-16)
    inCombatDefaultAnchor:SetChecked(Save.inCombatDefaultAnchor)
    inCombatDefaultAnchor:SetScript('OnMouseDown', function()
        Save.inCombatDefaultAnchor= not Save.inCombatDefaultAnchor and true or nil
    end)

    local courorRightCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--指定提示位置
    courorRightCheck.text:SetText(e.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT)
    courorRightCheck:SetPoint('LEFT', inCombatDefaultAnchor.text, 'RIGHT',2,0)
    courorRightCheck:SetChecked(Save.cursorRight)
    courorRightCheck:SetScript('OnMouseDown', function(self)
        Save.cursorRight= not Save.cursorRight and true or nil
        set_Cursor_Tips(self)
    end)
    courorRightCheck:SetScript('OnLeave', function() e.tips:Hide() end)


    local modelCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    modelCheck.text:SetText(e.onlyChinese and '模型' or MODEL)
    modelCheck:SetPoint('TOPLEFT', panel, 'TOP', 0, -48)
    modelCheck:SetChecked(not Save.hideModel)
    modelCheck:SetScript('OnMouseDown', function(self)
        Save.hideModel= not Save.hideModel and true or nil
        setInitItem(e.tips, true)--创建物品
        setInitItem(ItemRefTooltip, true)
        set_Cursor_Tips(self)
    end)
    modelCheck:SetScript('OnLeave', function() e.tips:Hide() end)

    local sliderModelSize = e.Create_Slider(panel, {w=100, min=50, max=200, value=Save.modelSize or 100, setp=1, color=nil,
    text=e.onlyChinese and '大小' or 'Size',
    func=function(self, value)
        value= tonumber(format('%i', value))
        value= value==0 and 0 or value
        self:SetValue(value)
        self.Text:SetText(value)
        if ItemRefTooltip.playerModel then
            ItemRefTooltip.playerModel:SetSize(value, value)
        end
        if e.tips.playerModel then
            e.tips.playerModel:SetSize(value, value)
        end
        Save.modelSize= value
        set_Cursor_Tips(self)
    end})
    sliderModelSize:SetPoint("LEFT", modelCheck.text, 'RIGHT',10,0)
    sliderModelSize:SetScript('OnLeave', function() e.tips:Hide() end)

    local healthCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    healthCheck.text:SetText(e.onlyChinese and '生命值 ' or HEALTH)
    healthCheck:SetPoint('TOPLEFT', modelCheck, 'BOTTOMLEFT')
    healthCheck:SetChecked(not Save.hideHealth)
    healthCheck:SetScript('OnMouseDown', function(self)
        Save.hideHealth= not Save.hideHealth and true or nil
        print(id, addName,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local ctrlCopy=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    ctrlCopy.text:SetText('Ctrl+Shift'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..' (wowhead Raider.IO)')
    ctrlCopy:SetPoint('TOPLEFT', healthCheck, 'BOTTOMLEFT')
    ctrlCopy:SetChecked(Save.ctrl)
    ctrlCopy:SetScript('OnMouseDown', function(self)
        Save.ctrl= not Save.ctrl and true or nil
    end)

   --设置CVar
    local cvar=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    cvar.text:SetText((e.onlyChinese and '设置' or SETTINGS)..' CVar')
    cvar:SetPoint('BOTTOMLEFT')
    cvar:SetChecked(Save.setCVar)
    cvar:SetScript('OnMouseDown', function()
        if Save.setCVar then
            Save.setCVar=nil
            setCVar(true)
        else
            Save.setCVar=true
            setCVar()
        end
    end)
    cvar:SetScript('OnEnter',function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        setCVar(nil, true)
        e.tips:Show()
    end)
    cvar:SetScript('OnLeave', function() e.tips:Hide() end)
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Init_Panel()--设置 panel

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()--初始
                if e.onlyChinese then
                    raiderioText= 'https://raider.io/cn/characters/%s/%s/%s'
                end
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_AchievementUI' then--成就ID
            hooksecurefunc(AchievementTemplateMixin, 'Init', function(self2)
                local frame= self2.Icon
                if not frame then
                    return
                end
                local text= self2.id
                if text and not frame.textID  then
                    frame.textID= e.Cstr(frame)
                    frame.textID:SetPoint('BOTTOM', frame.texture, 'BOTTOM')
                    frame.textID:EnableMouse(true)
                    frame:SetScript('OnEnter', function(self3)
                        if self3.ID then
                            e.tips:SetOwner(self3, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetAchievementByID(self3.ID)
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(id, addName)
                            e.tips:Show()
                        end
                    end)
                    frame.textID:SetScript('OnLeave', function() e.tips:Hide() end)
                end
                if frame.textID then
                    frame.ID=text
                    if text then
                        local flags= select(9, GetAchievementInfo(self2.id))
                        if flags==0x20000 then
                            text= e.Icon.wow2..'|cffff00ff'..text..'|r'
                        end
                    end
                    frame.textID:SetText(text or '')
                end
            end)
            hooksecurefunc('AchievementFrameComparison_UpdateDataProvider', function()--比较成就, Blizzard_AchievementUI.lua
                for _, button in pairs(AchievementFrameComparison.AchievementContainer.ScrollBox:GetFrames()) do
                    if not button.OnEnter then
                        button:SetScript('OnLeave', function() e.tips:Hide() end)
                        button:SetScript('OnEnter', function(self3)
                            if self3.id then
                                e.tips:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                                e.tips:ClearLines()
                                e.tips:SetAchievementByID(self3.id)
                                e.tips:Show()
                            end
                        end)
                        if button.Player and button.Player.Icon and not button.Player.idText then
                            button.Player.idText= e.Cstr(button.Player)
                            button.Player.idText:SetPoint('LEFT', button.Player.Icon, 'RIGHT', 0, 10)
                        end
                    end
                    if button.Player and button.Player.idText then
                        local flags= button.id and select(9, GetAchievementInfo(button.id))
                        if flags==0x20000 then
                            button.Player.idText:SetText(e.Icon.wow2..'|cffff00ff'..button.id..'|r')
                        else
                            button.Player.idText:SetText(button.id or '')
                        end
                    end
                end
            end)
            hooksecurefunc('AchievementFrameComparison_SetUnit', function(unit)--比较成就
                local text= e.GetPlayerInfo({unit=unit, guid=unit and UnitGUID(unit), name=nil,  reName=true, reRealm=true, reLink=false})--玩家信息图标
                if text~='' then
                    AchievementFrameComparisonHeaderName:SetText(text)
                end
            end)
            if AchievementFrameComparisonHeaderPortrait then
                local function func()
                    if AchievementFrameComparisonHeaderPortrait.unit then
                        e.tips:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                        e.tips:ClearLines()
                        e.tips:SetUnit(AchievementFrameComparisonHeaderPortrait.unit)
                        e.tips:Show()
                    end
                end
                AchievementFrameComparisonHeader:EnableMouse(true)
                AchievementFrameComparisonHeader:SetScript('OnLeave', function() e.tips:Hide() end)
                AchievementFrameComparisonHeader:SetScript('OnEnter', func)

            end

        elseif arg1=='Blizzard_Collections' then--宠物手册， 召唤随机，偏好宠物，技能ID    
            hooksecurefunc('PetJournalSummonRandomFavoritePetButton_OnEnter', function()--PetJournalSummonRandomFavoritePetButton
                setSpell(e.tips, 243819)
                e.tips:Show()
            end)

        elseif arg1=='Blizzard_ChallengesUI' then--挑战, AffixID
            hooksecurefunc(ChallengesKeystoneFrameAffixMixin,'OnEnter',function(self2)--Blizzard_ChallengesUI.lua
                if self2.affixID then
                    if self2.affixID then
                        local _, _, filedataid = C_ChallengeMode.GetAffixInfo(self2.affixID)
                        GameTooltip:AddDoubleLine('affixID '..self2.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ');
                        GameTooltip:Show();
                    end
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)

    --#### 不知什么用,
    --Buff
    --[[####
    local function setBuff(type, self, ...)--Buff
        local source= type=='Buff' and select(7, UnitBuff(...)) or type=='Debuff' and select(7, UnitDebuff(...)) or select(7, UnitAura(...))
        if source then
            local r, g ,b , col= GetClassColor(UnitClassBase(source))
    
            if r and g and b then
                self.backgroundColor:SetColorTexture(r, g, b, 0.3)
                self.backgroundColor:SetShown(true)
            end
            if source~='player' then
                SetPortraitTexture(self.Portrait, source)
                self.Portrait:SetShown(true)
            end
            local text= source=='player' and (e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                    or source=='pet' and PET
                    or UnitIsPlayer(source) and e.GetPlayerInfo({unit=source, guid=UnitGUID(source), name=nil,  reName=true, reRealm=true, reLink=false})
                    or UnitName(source) or _G[source] or source
            self:AddDoubleLine('|c'..(col or 'ffffff')..(e.onlyChinese and '来原: '..text or format(e.onlyChinese and '"来源：%s' or RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT, text)..'|r'))
            self:Show()
        end
    end
    [hooksecurefunc(e.tips, "SetUnitBuff", function(...)
        setBuff('Buff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitDebuff", function(...)
        setBuff('Debuff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitAura", function(...)
        setBuff('Aura', ...)
    end)]]