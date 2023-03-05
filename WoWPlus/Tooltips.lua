local id, e = ...
local addName= 'Tootips'
local Save={setDefaultAnchor=true, setCVar=e.Player.husandro,inCombatDefaultAnchor=true}
local panel=CreateFrame("Frame")

local function setInitItem(self, hide)--创建物品
    if not self.textLeft then--左上角字符
        self.textLeft=e.Cstr(self, 16)
        self.textLeft:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')
    end
    if not self.text2Left then--左上角字符2
        self.text2Left=e.Cstr(self, 16)
        self.text2Left:SetPoint('LEFT', self.textLeft, 'RIGHT', 5, 0)
    end
    if not self.textRight then--右上角字符
        self.textRight=e.Cstr(self, 10)
        self.textRight:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')
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

local function setMount(self, mountID)--坐骑    
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
    if creatureDisplayInfoID and self.creatureDisplayID~=creatureDisplayInfoID then--3D模型
        self.itemModel:SetShown(true)
        self.itemModel:SetDisplayInfo(creatureDisplayInfoID)
        self.itemModel:SetAnimation(animID)
        self.creatureDisplayID=creatureDisplayInfoID
    end

    self.text2Left:SetText(isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
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
    if creatureDisplayID and self.creatureDisplayID~=creatureDisplayID then--3D模型
        self.itemModel:SetDisplayInfo(creatureDisplayID)
        self.itemModel:SetShown(true)
        self.creatureDisplayID=creatureDisplayID
    end

    if setSearchText and speciesName and PetJournalSearchBox and PetJournalSearchBox:IsVisible() then--宠物手册，设置名称
        PetJournalSearchBox:SetText(speciesName)
    end
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
    local r, g, b, hex= 1,1,1,e.Player.col
    if itemQuality then
        r, g, b, hex= GetItemQualityColor(itemQuality)
        hex=hex and '|c'..hex
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
                self:AddDoubleLine(_G[itemEquipLoc], (e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..slot)--栏位
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
                text= hex..(text or itemLevel)..'|r'
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
        if appearanceID then
            if self.creatureDisplayID~=appearanceID then
                self.itemModel:SetItemAppearance(appearanceID, visualID)
                --self.itemModel:SetItem(itemID, appearanceModID, itemVisualID)
                self.itemModel:SetShown(true)
                self.creatureDisplayID=appearanceID
            end
        end
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
    else
        if setID then--套装
            local collectedNum= select(4, e.GetSetsCollectedNum(setID))
            if collectedNum then
                self.text2Left:SetText(collectedNum)
            end
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
    end

    local spellName, spellID = GetItemSpell(ItemLink)--物品法术
    if spellName and spellID then
        local spellTexture=GetSpellTexture(spellID)
        self:AddDoubleLine((itemName~=spellName and hex..'['..spellName..']|r' or '')..(e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':0|t'..spellTexture or ' ')
    end

    local wowNum= 0--WoW 数量
    local bag= GetItemCount(ItemLink)--物品数量
    local bank= GetItemCount(ItemLink,true) - bag

    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        --local numPlayer=1 --帐号数据 --{score=总分数,itemLink={超连接}, weekLevel=本周最高, weekNum=本周次数, all=总次数},
        for guid, info in pairs(e.WoWSave) do
            if guid and info then
                local find
                for linkItem, _ in pairs(info.Keystone.itemLink) do
                self:AddDoubleLine(' ', linkItem)
                find=true
                end
                if find then
                    self:AddLine(e.GetPlayerInfo(nil, guid, true))
                end
            end
        end
        if e.WoWSave[e.Player.guid] and e.WoWSave[e.Player.guid].Keystone then--挑战分数
            local score= e.WoWSave[e.Player.guid].Keystone.score
            if score and score>0 then
                local numAll= e.WoWSave[e.Player.guid].Keystone.all or 0
                local weekNum= e.WoWSave[e.Player.guid].Keystone.weekNum or 0
                local weekLevel= e.WoWSave[e.Player.guid].Keystone.weekLevel or 0
                self.textLeft:SetText(weekLevel.. e.GetKeystoneScorsoColor(score, true))
                self.text2Left:SetText(weekNum..'/'..numAll)
            end
        end
    else
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(e.WoWSave) do
            if guid and info and guid~=e.Player.guid then
                local tab=info.Item[itemID]
                if tab and tab.bag and tab.bank then
                    self:AddDoubleLine(e.GetPlayerInfo(nil, guid, true), e.Icon.bank2..(tab.bank==0 and '|cff606060'..tab.bank..'|r' or tab.bank)..' '..e.Icon.bag2..(tab.bag==0 and '|cff606060'..tab.bag..'|r' or tab.bag))
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

    self.textRight:SetText(hex..e.MK(wowNum, 3)..e.Icon.wow2..' '..e.MK(bank, 3)..e.Icon.bank2..' '..e.MK(bag, 3)..e.Icon.bag2..'|r')

    --setItemCooldown(self, itemID)--物品冷却

    self.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    self.backgroundColor:SetShown(true)
    self:Show()
end

local function setSpell(self, spellID)--法术
    spellID = spellID or select(2, self:GetSpell())
    local spellTexture= spellID and GetSpellTexture(spellID)
    if not spellID then
        return
    end
    self:AddDoubleLine((e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and '|T'..spellTexture..':0|t'..spellTexture)
    local mountID = C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        setMount(self, mountID)
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
    for guid, info in pairs(e.WoWSave) do--帐号数据
        if guid~=e.Player.guid then
            local quantity=info.Currency[currencyID]
            if quantity and quantity>0 then
                self:AddDoubleLine(e.GetPlayerInfo(nil, guid, true), e.MK(quantity, 3))
                all=all+quantity
                numPlayer=numPlayer+1
            end
        end
    end
    if numPlayer>1 then
        self:AddDoubleLine(e.Icon.wow2..numPlayer..(e.onlyChinese and '角色' or CHARACTER), e.MK(all,3))
    end
    self:Show()
end

local function setAchievement(self, achievementID)--成就
    local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)
    self.textLeft:SetText(points..(e.onlyChinese and '点' or RESAMPLE_QUALITY_POINT))--点数
    self.text2Left:SetText(completed and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已完成' or CRITERIA_COMPLETED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)..'|r')--否是完成
    self.textRight:SetText(isGuild and (e.onlyChinese and '公会' or GUILD) or flags==131072 and e.Icon.wow2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET)  or '')

    self:AddDoubleLine((e.onlyChinese and '成就' or ACHIEVEMENTS)..' '..achievementID, icon and '|T'..icon..':0|t'..icon)
end

local function setQuest(self, questID)
    self:AddDoubleLine(e.GetExpansionText(nil, questID))--任务版本
    self:AddDoubleLine(e.onlyChinese and '任务' or QUESTS_LABEL, questID)
end

--####
--Buff
--####
local function setBuff(type, self, ...)--Buff
    local source= type=='Buff' and select(7, UnitBuff(...)) or type=='Debuff' and select(7, UnitDebuff(...)) or select(7, UnitAura(...))
    if source then
        local r, g ,b , hex= GetClassColor(UnitClassBase(source))

        if r and g and b then
            self.backgroundColor:SetColorTexture(r, g, b, 0.3)
            self.backgroundColor:SetShown(true)
        end
        if source~='player' then
            SetPortraitTexture(self.Portrait, source)
            self.Portrait:SetShown(true)
        end
        local text= source=='player' and (e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                or source=='pet' and PET or UnitIsPlayer(source) and e.GetPlayerInfo(source, nil, true)
                or UnitName(source) or _G[source] or source
        self:AddDoubleLine('|c'..(hex or 'ffffff')..(e.onlyChinese and '来原: '..text or format(e.onlyChinese and '"来源：%s' or RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT, text)..'|r'))
        self:Show()
    end
end

local function set_Aura(self, auraID)--Aura
    local _, _, icon, _, _, _, spellID = GetSpellInfo(auraID)
   if icon and spellID then
        self:AddDoubleLine((e.onlyChinese and '光环' or AURAS)..' '..spellID, '|T'..icon..':0|t'..icon)
        local mountID = C_MountJournal.GetMountFromSpell(spellID)
        if mountID then
            setMount(self, mountID)
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
    local r, g, b, left, right, hex, text

    if value and max then
        r, g, b, hex = GetClassColor(select(2, UnitClass(unit)))
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
                text= '|c'..hex..text..'|r'
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
        self.textRight = e.Cstr(self,18)
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
local function setPlayerInfo(unit, guid)--设置玩家信息
    local info= e.UnitItemLevel[guid]
    if info then
        if info.itemLevel and info.itemLevel>1 then
            e.tips.textLeft:SetText(info.col and info.col..info.itemLevel..'|r' or info.itemLeveljqt)--设置装等
        end

        local icon= info.specID and select(4, GetSpecializationInfoByID(info.specID))--设置天赋
        if icon then
            e.tips.text2Left:SetText("|T"..icon..':0|t')
        end
--[[        if info.realm then
            if e.Player.servers[info.realm] then--设置服务器
                e.tips.textRight:SetText(info.col..info.realm..'|r'..(info.realm~=e.Player.server and '|cnGREEN_FONT_COLOR:*|r' or''))

            elseif info.realm and not e.Player.servers[info.realm] then--不同
                e.tips.textRight:SetText(info.col..info.realm..'|r|cnRED_FONT_COLOR:*|r')

            elseif UnitIsUnit('player', unit) or UnitIsSameServer(unit) then--同
                e.tips.textRight:SetText(info.col..e.Player.server..'|r')
            end
        end]]
        if info.r and info.b and info.g then
            e.tips.backgroundColor:SetColorTexture(info.r, info.g, info.b, 0.2)--背景颜色
            e.tips.backgroundColor:SetShown(true)
        end
    end
end


local function setUnitInfo(self, unit)--设置单位提示信息
    local name, realm= UnitName(unit)
    local isPlayer = UnitIsPlayer(unit)
    local guid = UnitGUID(unit)

    --设置单位图标  
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    if isPlayer then
        if (englishFaction=='Alliance' or englishFaction=='Horde') then--派系
            self.Portrait:SetAtlas(englishFaction=='Alliance' and e.Icon.alliance or e.Icon.horde)
            self.Portrait:SetShown(true)
        end

        if CheckInteractDistance(unit, 1) and CanInspect(unit) then--取得装等
            NotifyInspect(unit);
        end
        --getPlayerInfo(unit, guid)--取得玩家信息
        setPlayerInfo(unit, guid)--取得玩家信息

        local isWarModeDesired=C_PvP.IsWarModeDesired()
        local statusIcon, statusText= e.PlayerOnlineInfo(unit)--单位，状态信息
        if statusIcon and statusText then
           self.textLeft:SetText(statusText..statusIcon)
        else
            local reason=UnitPhaseReason(unit)
            if reason then
                if reason==0 then
                    self.textLeft:SetText(e.onlyChinese and '不同了阶段' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))
                elseif reason==1 then
                    self.textLeft:SetText(e.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.L['LAYER']))
                elseif reason==2 then--战争模
                    self.textLeft:SetText(isWarModeDesired and (e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF) or (e.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON))
                elseif reason==3 then
                    self.textLeft:SetText(e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)
                end
            end
        end

        local isInGuild=IsPlayerInGuildFromGUID(guid)
        local col = e.UnitItemLevel[guid] and e.UnitItemLevel[guid].col or '|c'..select(4,GetClassColor(UnitClassBase(unit)))

        local line=GameTooltipTextLeft1--名称
        if line then
            line:SetText(col..e.Icon.toRight2..name..e.Icon.toLeft2..'|r')
        end

        realm= realm or e.Player.server--服务器
        self.textRight:SetText(col..realm..'|r'..(e.Player.servers[realm] and '|cnGREEN_FONT_COLOR:*' or ''))

       --[[ local text=line:GetText()
        if text then
            text=text:gsub('(%-.+)','')
            text=text:gsub(name, e.Icon.toRight2..name..e.Icon.toLeft2)
            line:SetText(col..text..'|r')
        end]]
        line=isInGuild and GameTooltipTextLeft2
        if line then
            local text=line:GetText()
            if text then
                line:SetText(e.Icon.guild2..col..text:gsub('(%-.+)','')..'|r')
                line= GameTooltipTextRight2
                if line then
                    line:SetText(' ')
                    line:SetShown()
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

            if isPlayer then
                local effectiveLevel= UnitEffectiveLevel(unit)
                if effectiveLevel~=level then
                    text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r) '
                end
            end
            --className= col and col..className..'|r' or className
            --text= text..LEVEL..' '..level..'  '..e.Race(nil, raceFile, sex)..raceName..' '..e.Class(nil, classFilename)..className..(UnitIsPVP(unit) and  '  (|cnRED_FONT_COLOR:PvP|r)' or '  (|cnGREEN_FONT_COLOR:PvE|r)')
            text= text..'  '..e.Class(nil, classFilename)..'  '..e.Race(nil, raceFile, sex)..raceName..'  '..(UnitIsPVP(unit) and  '(|cnRED_FONT_COLOR:PvP|r)' or '(|cnGREEN_FONT_COLOR:PvE|r)')
            text= col and col..text..'|r' or text
            line:SetText(text)

            line= isInGuild and GameTooltipTextRight3 or GameTooltipTextRight2
            if line then
                line:SetText(' ')
                line:SetShown(true)
            end
        end

        local isSelf=UnitIsUnit('player', unit)--我
        local isGroupPlayer= (not isSelf and e.GroupGuid[guid]) and true or nil--队友

        local num= isInGuild and 4 or 3
        local allNum= self:NumLines()
        for i=num, allNum do
            line=_G["GameTooltipTextLeft"..i]
            if line then
                if i==num then
                    if isSelf and (e.Layer or isWarModeDesired) then--位面ID, 战争模式
                        line:SetText(e.Layer and '|A:nameplates-holypower2-on:0:0|a'..col..e.L['LAYER']..' '..e.Layer..'|r' or ' ')
                        if isWarModeDesired then
                            line=_G["GameTooltipTextRight"..i]
                            if line then
                                line:SetText(col..(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE))
                                line:SetShown(true)
                            end
                        end
                    elseif isGroupPlayer then----队友位置
                        local mapID= C_Map.GetBestMapForUnit(unit)--地图ID
                        local mapInfo= mapID and C_Map.GetMapInfo(mapID)
                        if mapInfo and mapInfo.name and _G["GameTooltipTextLeft"..i] then
                            if mapInfo.name then
                                line=_G["GameTooltipTextLeft"..i]
                                line:SetText(e.Icon.map2..col..mapInfo.name)
                                line:SetShown(true)

                                --[[line=_G["GameTooltipTextRight"..i]
                                if line then
                                    line:SetText(' ')
                                    line:SetShown(true)
                                end]]
                            end
                        end
                    else
                        line:Hide()
                    end
                else
                    --[[if allNum==i and isSelf and e.WoWSave[e.Player.guid] and e.WoWSave[e.Player.guid].Keystone then--挑战分数
                        local score= e.WoWSave[e.Player.guid].Keystone.score
                        local numAll= e.WoWSave[e.Player.guid].Keystone.all or 0
                        local weekNum= e.WoWSave[e.Player.guid].Keystone.weekNum or 0
                        local weekLevel= e.WoWSave[e.Player.guid].Keystone.weekLevel or 0

                        if score and score>0 then
                            line:SetText(e.GetKeystoneScorsoColor(score, true)..'  '..col..weekLevel)
                            if _G["GameTooltipTextRight"..i] then
                                _G["GameTooltipTextRight"..i]:SetText(col..weekNum..'/'..numAll)
                                _G["GameTooltipTextRight"..i]:SetShown(true)
                            end
                        else
                            line:Hide()
                        end
                    else
                        line:Hide()
                    end]]
                    line:Hide()
                end
            end
        end

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        setPet(self, UnitBattlePetSpeciesID(unit), true)

    else
        local r,g,b, hex = GetClassColor(UnitClassBase(unit))--颜色
        hex= hex and '|c'..hex or ''
        if GameTooltipTextLeft1 then GameTooltipTextLeft1:SetTextColor(r,g,b) end
        if GameTooltipTextLeft2 then GameTooltipTextLeft2:SetTextColor(r,g,b) end
        if GameTooltipTextLeft3 then GameTooltipTextLeft3:SetTextColor(r,g,b) end
        if GameTooltipTextLeft4 then GameTooltipTextLeft4:SetTextColor(r,g,b) end
            local zone, npc = select(5, strsplit("-", guid))--位面,NPCID
            if zone then
                self:AddDoubleLine(e.L['LAYER']..' '..zone, 'NPC '..npc, r,g,b, r,g,b)
                e.Layer=zone
            end

        --怪物, 图标
        if UnitIsQuestBoss(unit) then--任务
            self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest')
            self.Portrait:SetShown(true)

        elseif UnitIsBossMob(unit) then--世界BOSS
            self.textLeft:SetText(hex..(e.onlyChinese and '首领' or BOSS)..'|r')
            self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            self.Portrait:SetShown(true)
        else
            local classification = UnitClassification(unit);--TargetFrame.lua
            if classification == "rareelite" then--稀有, 精英
                self.textLeft:SetText(hex..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r')
                self.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
                self.Portrait:SetShown(true)

            elseif classification == "rare" then--稀有
                self.textLeft:SetText(hex..(e.onlyChinese and '稀有' or GARRISON_MISSION_RARE)..'|r')
                self.Portrait:SetAtlas('UUnitFrame-Target-PortraitOn-Boss-Rare-Star')
                self.Portrait:SetShown(true)
            else
                SetPortraitTexture(self.Portrait, unit)
                self.Portrait:SetShown(true)
            end
        end

        local type=UnitCreatureType(unit)--生物类型
        if type and not type:find(COMBAT_ALLY_START_MISSION) then
            self.textRight:SetText(hex..type..'|r')
        end
    end

    set_Unit_Health_Bar(GameTooltipStatusBar,unit)--生命条提示

    if self.playerModel:CanSetUnit(unit) then
        if self.playerModel.guid~=guid then--3D模型
            self.playerModel:SetUnit(unit)
            self.playerModel.guid=guid
        end
        self.playerModel:SetShown(true)
    end
end

local function setCVar(reset, tips, notPrint)
    local tab={
        ['missingTransmogSourceInItemTooltips']={
            value='1',
            msg= e.onlyChinese and '显示装备幻化来源' or TRANSMOGRIFY..SOURCES..': '..SHOW,
        },
        ['nameplateOccludedAlphaMult']={
            value='0.15',
            msg= e.onlyChinese and '不在视野里, 姓名板透明度: 0.15' or SPELL_FAILED_LINE_OF_SIGHT..'('..SHOW_TARGET_CASTBAR_IN_V_KEY..')'..CHANGE_OPACITY,
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
--[[        ["showTargetCastbar"]={
            value= "1",
            msg= e.onlyChinese and '显示目标施法条' or SHOW..TARGET..HUD_EDIT_MODE_CAST_BAR_LABEL,
        },]]
    }

    if tips then
        for name, info in pairs(tab) do
            e.tips:AddDoubleLine(name..': '..info.value..' (|cff00ff00'..C_CVar.GetCVar(name)..'|r)', info.msg)
        end
        return
    end

    for name, info in pairs(tab) do
        if info.zh and e.Player.zh or not info.zh then
            if reset then
                local defaultValue = C_CVar.GetCVarDefault(name)
                local value = C_CVar.GetCVar(name)
                if defaultValue~=value then
                    C_CVar.SetCVar(name, defaultValue)
                    if not notPrint then
                        print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r', name, defaultValue, info.msg)
                    end
                end
            elseif Save.setCVar then
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
    local _, _, numSlots, isKnown= GetFlyoutInfo(flyoutID)
    self:AddDoubleLine((not isKnown and '|cnRED_FONT_COLOR:' or '')..'flyoutID|r '..flyoutID, numSlots..' '..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL))
    for slot= 1, numSlots do
        local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            e.LoadSpellItemData(spellID, true)
            local name2, _, icon = GetSpellInfo(spellID)
            if name2 and icon then
                self:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..name2..'|r', spellID..' '..(e.onlyChinese and '法术' or SPELLS))
            else
                self:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r', spellID..' '..(e.onlyChinese and '法术' or SPELLS))
            end
        end
    end
end

--###########
--宠物面板提示
--###########
local function setBattlePet(self, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID < 1 then
        return
    end
    local speciesName, speciesIcon, _, companionID, tooltipSource, _, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    if not self.Portrait then
        setInitItem(self, true)--创建物品
    end

    self.itemModel:SetDisplayInfo(creatureDisplayID)
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
    if not e.tips.playerModel then--单位3D模型
        e.tips.playerModel=CreateFrame("PlayerModel", nil, e.tips)
        e.tips.playerModel:SetFacing(-0.35)
        e.tips.playerModel:SetPoint("BOTTOM", e.tips, 'TOP', 0, -12)
        e.tips.playerModel:SetSize(100, 100)
        e.tips.playerModel:SetShown(false)
    end
    --panel:RegisterEvent('INSPECT_READY')

    setInitItem(ItemRefTooltip)
    setInitItem(e.tips)
    e.tips:HookScript("OnHide", function(self)--隐藏
        setInitItem(self, true)
    end)
    ItemRefTooltip:HookScript("OnHide", function (self)--隐藏
        setInitItem(self, true)
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

        elseif date.id and date.type and date.type~= 25 then
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
        --elseif date.type or date.id then
            --tooltip:AddDoubleLine(date.id and 'ID '..date.id, date.type and 'type '..date.type)
        end
    end)
--[[    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip,date)--宠物手册，设置名称
        local unit= select(2, TooltipUtil.GetDisplayedUnit(tooltip))
        if unit and tooltip==e.tips  and (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
            local speciesID = UnitBattlePetSpeciesID(unit)
            local speciesName= speciesID and C_PetJournal.GetPetInfoBySpeciesID(speciesID)
            if speciesName and PetJournalSearchBox and PetJournalSearchBox:IsVisible()then
                PetJournalSearchBox:SetText(speciesName)
            end
        end
    end)]]

    --****
    --位置
    --****
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
        if Save.setDefaultAnchor then
            if Save.inCombatDefaultAnchor and UnitAffectingCombat('player') then
                if Save.AnchorPoint then
                    self:ClearAllPoints();
                    self:SetPoint(Save.AnchorPoint[1], UIParent, Save.AnchorPoint[3], Save.AnchorPoint[4], Save.AnchorPoint[5])
                end
            else
                self:ClearAllPoints();
                self:SetOwner(parent, 'ANCHOR_CURSOR_LEFT')
            end
        elseif Save.setAnchor and Save.AnchorPoint then
            self:ClearAllPoints();
            self:SetPoint(Save.AnchorPoint[1], UIParent, Save.AnchorPoint[3], Save.AnchorPoint[4], Save.AnchorPoint[5])
        end
    end)

    --#########
    --生命条提示
    --#########
    GameTooltipStatusBar:SetScript("OnValueChanged", function(self)
        local unit= select(2, TooltipUtil.GetDisplayedUnit(GameTooltip))
        if unit then
            set_Unit_Health_Bar(self, unit)
        end
    end);

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
                e.tips:Show();
            elseif factionID or self.factionID then
                e.tips:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..(self.factionID or factionID), completedParagon)
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


    --####
    --Buff
    --####
    hooksecurefunc(e.tips, "SetUnitBuff", function(...)
        setBuff('Buff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitDebuff", function(...)
        setBuff('Debuff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitAura", function(...)
        setBuff('Aura', ...)
    end)

    --###########
    --宠物面板提示
    --###########
    hooksecurefunc("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
        setBattlePet(BattlePetTooltip, ...)
    end)

    hooksecurefunc('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
        setBattlePet(FloatingBattlePetTooltip, ...)
    end)

    hooksecurefunc(e.tips,"SetCompanionPet", function(self, petGUID)--设置宠物信息
        local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
        setPet(self, speciesID)--宠物
    end)


    --##########
    --设置 panel
    --##########
    panel.name = addName;--添加新控制面板
    panel.parent =id;
    InterfaceOptions_AddCategory(panel)

    panel.setDefaultAnchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--设置默认提示位置
    panel.setDefaultAnchor.Text:SetText('1) '..(e.onlyChinese and '跟随鼠标' or FOLLOW..MOUSE_LABEL))
    panel.setDefaultAnchor:SetPoint('TOPLEFT')
    panel.setDefaultAnchor:SetChecked(Save.setDefaultAnchor)--提示位置            
    panel.setDefaultAnchor:SetScript('OnMouseDown', function()
        if Save.setDefaultAnchor then
            Save.setDefaultAnchor=nil
        else
            Save.setDefaultAnchor=true
            Save.setAnchor=nil
            panel.Anchor:SetChecked(false)
        end
        panel.inCombatDefaultAnchor:SetEnabled(Save.setDefaultAnchor)
    end)

    panel.inCombatDefaultAnchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.inCombatDefaultAnchor.Text:SetText(e.onlyChinese and '战斗中：默认' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DEFAULT)
    panel.inCombatDefaultAnchor:SetPoint('LEFT', panel.setDefaultAnchor.Text, 'RIGHT', 20, 0)
    panel.inCombatDefaultAnchor:SetScript('OnMouseDown', function()
        Save.inCombatDefaultAnchor= not Save.inCombatDefaultAnchor and true or nil
    end)
    panel.inCombatDefaultAnchor:SetEnabled(Save.setDefaultAnchor)
    panel.inCombatDefaultAnchor:SetChecked(Save.inCombatDefaultAnchor)

    panel.Anchor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--指定提示位置
    panel.Anchor.Text:SetText('2)' ..(e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION))
    panel.Anchor:SetPoint('TOPLEFT', panel.setDefaultAnchor, 'BOTTOMLEFT', 0, -2)

    panel.Anchor:SetChecked(Save.setAnchor)
    panel.Anchor:SetScript('OnMouseDown', function(self)
        if Save.setAnchor then
            Save.setAnchor=nil
        else
            Save.setAnchor=true
            Save.setDefaultAnchor=nil
            panel.setDefaultAnchor:SetChecked(false)
        end
        panel.inCombatDefaultAnchor:SetEnabled(Save.setDefaultAnchor)
    end)
    panel.Anchor.select=e.Cbtn(panel,true)
    panel.Anchor.select:SetPoint('LEFT', panel.Anchor.text, 'RIGHT',5,0)
    panel.Anchor.select:SetSize(90, 25)
    panel.Anchor.select:SetText(e.onlyChinese and '设置' or SETTINGS)
    panel.Anchor.select:SetScript('OnMouseDown',function(self)
        if not self.frame then
            self.frame=CreateFrame('Frame')
            if Save.AnchorPoint and Save.AnchorPoint[1] and Save.AnchorPoint[3] and Save.AnchorPoint[4] and Save.AnchorPoint[5] then
                self.frame:SetPoint(Save.AnchorPoint[1], UIParent, Save.AnchorPoint[3], Save.AnchorPoint[4], Save.AnchorPoint[5])
            else
                self.frame:SetPoint('BOTTOMRIGHT', 0, 90)
            end
            self.frame:SetSize(140,140)
            self.frame.texture=self.frame:CreateTexture(nil,'ARTWORK')
            self.frame.texture:SetAllPoints(self.frame)
            self.frame.texture:SetTexture('Interface\\RaidFrame\\Absorb-Fill')
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



--设置CVar
    panel.CVar=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.CVar.Text:SetText((e.onlyChinese and '设置' or SETTINGS)..' CVar')
    panel.CVar:SetPoint('TOPLEFT', panel.Anchor, 'BOTTOMLEFT', 0, -30)
    panel.CVar:SetChecked(Save.setCVar)
    panel.CVar:SetScript('OnMouseDown', function()
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

    setCVar(nil, nil, true)--设置CVar

    if Save.setCVar and e.Player.zh then
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
end

--加载保存数据
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板 
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('Tooltip')
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()--初始
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
                end
                if frame.textID then
                    if text then
                        local flags= select(9, GetAchievementInfo(self2.id))
                        if flags==131072 then
                            text= e.Icon.wow2..'|cnGREEN_FONT_COLOR:'..text..'|r'
                        else
                            text= 'ID'..text
                        end
                    end
                    frame.textID:SetText(text or '')
                end

                local icon= frame.texture:GetTextureFileID()
                if icon and not frame.textIcon then
                    frame.textIcon= e.Cstr(frame)
                    frame.textIcon:SetPoint('TOP', frame.texture, 'TOP')
                end
                if frame and frame.textIcon then
                    frame.textIcon:SetText(icon and '|T'..icon..':0|t'..icon or '')
                end
            end)

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
        --elseif arg1=='Blizzard_PerksProgram' then
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end

end)
--[[
local function setItemCooldown(self, itemID)--物品冷却
    local startTime, duration, enable = GetItemCooldown(itemID)
    if duration>4 and enable==1 then
        local t=GetTime()
        if startTime>t then t=t+86400 end
        t=t-startTime
        t=duration-t
        self:AddDoubleLine(ON_COOLDOWN, SecondsToTime(t), 1,0,0, 1,0,0)
    end
end
local function setSpellCooldown(self, spellID)--法术冷却
    local startTime, duration, enable = GetSpellCooldown(spellID)
    if duration and duration>4 and enable==1 and gcdMS~=duration then
        local t=GetTime()
        if startTime>t then t=t+86400 end
        t=t-startTime
        t=duration-t
        self:AddDoubleLine(ON_COOLDOWN, SecondsToTime(t), 1,0,0, 1,0,0)
    end
end
]]