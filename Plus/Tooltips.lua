local id, e = ...
local addName= 'Tooltips'
local Save={
    setDefaultAnchor=true,--指定点
    --AnchorPoint={},--指定点，位置
    --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',

    setCVar=e.Player.husandro,
    ShowOptionsCVarTips=e.Player.husandro,--显示选项中的CVar
    inCombatDefaultAnchor=true,
    ctrl= e.Player.husandro,--取得网页，数据链接

    --模型
    modelSize=100,--大小
    --modelLeft=true,--左边
    modelX= 0,
    modelY= -24,
    modelFacing= -0.3,--方向
    showModelFileID=e.Player.husandro,--显示，文件ID
    --WidgetSetID=848,--自定义，监视 WidgetSetID
    --disabledNPCcolor=true,--禁用NPC颜色
    --hideHealth=true,----生命条提示
}
local panel=CreateFrame("Frame")
local Initializer, Layout= e.AddPanel_Sub_Category({name=e.Icon.mid..addName})

--全局
--e.Show_WoWHead_URL(isWoWHead, typeOrRegion, typeIDOrRealm, name)

local func={
    --func.Set_PlayerModel(self)
    --func.Set_Spell(self, spellID)--法术
    --func.Set_Mount(self, mountID)--坐骑
    --func.Set_Pet(self, speciesID, setSearchText)--宠物
    --func.Set_Item(self, itemLink, itemID)--物品信息
    --func.Set_Currency(self, currencyID)--货币
    --func.Set_Achievement(self, achievementID)--成就
    --func.Set_Quest(self, questID, info)--任务
    --func.Set_Faction(self, factionID)
    --func.Set_Flyout(self, flyoutID)--法术, 弹出框

    --func.GetItemInfoFromHyperlink(link)--LinkUtil.lua  GetItemInfoFromHyperlink()不能正解，读取 |Hkeystone:
    --func.Set_Init_Item(self, hide)--创建，设置，内容
    --func.Set_Item_Model(self, tab)--设置, 3D模型{unit=, guid=, creatureDisplayID=, animID=, appearanceID=, visualID=, col=}
    --e.Set_Web_Link(tab)
    --func.Set_Unit(self, unit)--设置单位提示信息
    --func.set_All_Aura(self, data)--Aura
    --func.set_Buff(type, self, ...)
}

local COMBAT_ALLY_START_MISSION= COMBAT_ALLY_START_MISSION





function func.Set_PlayerModel(self)
    if not self.playerModel then
        self.playerModel= CreateFrame("PlayerModel", nil, self)--DressUpModel PlayerModel
        --self.playerModel:SetFrameLevel(self:GetFrameLevel()-1)
        --[[
        self.itemModel= CreateFrame("DressUpModel", nil, self)--DressUpModel PlayerModel
        self.itemModel:SetPoint('TOP', self, 'BOTTOM')
        self.itemModel:SetUnit('player')
        self.itemModel:SetSize(Save.modelSize, Save.modelSize)
        self.itemModel:SetModelScale(2)
        self.itemModel:SetFacing(Save.modelFacing)
        ]]
    else
        self.playerModel:ClearAllPoints()
    end
    if Save.modelLeft then
        self.playerModel:SetPoint("RIGHT", self, 'LEFT', Save.modelX, Save.modelY)
    else
        self.playerModel:SetPoint("BOTTOM", self, 'TOP', Save.modelX, Save.modelY)
    end
    self.playerModel:SetSize(Save.modelSize, Save.modelSize)
    self.playerModel:SetFacing(Save.modelFacing)
end

function func.Set_Init_Item(self, hide)--创建，设置，内容
    if not self then
        return
    end
    if not self.textLeft then--左上角字符
        self.textLeft=e.Cstr(self, {size=16})
        self.textLeft:SetPoint('BOTTOMLEFT', self, 'TOPLEFT')

        self.text2Left=e.Cstr(self, {size=16})--左上角字符2
        self.text2Left:SetPoint('LEFT', self.textLeft, 'RIGHT', 5, 0)

        self.textRight=e.Cstr(self, {size=12, justifyH='RIGHT'})--右上角字符
        self.textRight:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT')

        self.text2Right= e.Cstr(self, {size=12, justifyH='RIGHT'})--右上角字符2
        self.text2Right:SetPoint('BOTTOMRIGHT', self.textRight, 'TOPRIGHT')

        self.backgroundColor= self:CreateTexture(nil, 'BACKGROUND',nil, 1)--背景颜色
        self.backgroundColor:SetPoint('TOPLEFT')
        self.backgroundColor:SetPoint('BOTTOMRIGHT')
        --self.backgroundColor:SetAllPoints(self)

        if not self.Portrait then
            self.Portrait= self:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
            self.Portrait:SetPoint('TOPRIGHT',-2, -3)
            self.Portrait:SetSize(40,40)
        end
    end
    if not self.playerModel and not Save.hideModel then
        func.Set_PlayerModel(self)
        self.playerModel:SetShown(false)
    end
    if hide and self.textLeft then
        self.textLeft:SetText('')
        self.text2Left:SetText('')
        self.textRight:SetText('')
        self.text2Right:SetText('')
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
function func.Set_Item_Model(self, tab)--func.Set_Item_Model(self, {unit=, guid=, creatureDisplayID=, animID=, appearanceID=, visualID=, col=})--设置, 3D模型
    if Save.hideModel then
        return
    end
    if tab.unit then
        if self.playerModel.id~=tab.guid then--and self.playerModel:CanSetUnit(tab.unit) then
            self.playerModel:SetUnit(tab.unit)
            self.playerModel.guid=tab.guid
            self.playerModel.id=tab.guid
            self.playerModel:SetShown(true)
            if Save.showModelFileID then
                local modelFileID= self.playerModel:GetModelFileID()
                if modelFileID and modelFileID>0 then
                    self.text2Right:SetText((tab.col or '')..modelFileID)
                end
            end
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
        if self.playerModel.id~=tab.itemID then
            if  tab.appearanceID and tab.visualID then
                self.playerModel:SetItemAppearance(tab.visualID, tab.appearanceID)
            else
                self.playerModel:SetItem(tab.itemID, tab.appearanceID, tab.visualID)
            end
            self.playerModel.id= tab.itemID
            self.playerModel:SetShown(true)
        end
    end
end


--################
--取得网页，数据链接
--################
local wowheadText
local raiderioText
local function Init_StaticPopupDialogs()
    StaticPopupDialogs["WoWTools_Tooltips_LinkURL"] = {
        text= id..' '..Initializer:GetName()..'|n|cffff00ff%s|r |cnGREEN_FONT_COLOR:Ctrl+C |r'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        button1 = e.onlyChinese and '关闭' or CLOSE,
        OnShow = function(self, web)
            self.editBox:SetScript("OnKeyUp", function(s, key)
                if IsControlKeyDown() and key == "C" then
                    print(id, Initializer:GetName(),
                            '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '复制链接' or BROWSER_COPY_LINK)..'|r',
                            s:GetText()
                        )
                    s:GetParent():Hide()
                end
            end)
            self.editBox:SetScript('OnCursorChanged', function(s)
                s:SetText(web)
                s:HighlightText()
            end)
            self.editBox:SetMaxLetters(0)
            self.editBox:SetWidth(self:GetWidth())
            self.editBox:SetFocus()
        end,
        OnHide= function(self)
            self.editBox:SetScript("OnKeyUp", nil)
            self.editBox:SetScript("OnCursorChanged", nil)
            self.editBox:SetText("")
            self.editBox:ClearFocus()
        end,
        EditBoxOnTextChanged= function (self, web)
            self:SetText(web)
            self:HighlightText()
        end,
        EditBoxOnEnterPressed = function(self)
            local parent= self:GetParent()
            parent.button1:Click()
            parent:Hide()
        end,
        EditBoxOnEscapePressed = function(self2)
            self2:SetAutoFocus(false)
            self2:ClearFocus()
            self2:GetParent():Hide()
        end,
        hasEditBox = true,
        editBoxWidth = 320,
        timeout = 0,
        whileDead=true, hideOnEscape=true, exclusive=true,
    }
    if e.onlyChinese then
        raiderioText= 'https://raider.io/cn/characters/%s/%s/%s'
        if not LOCALE_zhCN then
            wowheadText= 'https://www.wowhead.com/cn/%s=%d'
        else
            wowheadText= 'https://www.wowhead.com/cn/%s=%d/%s'
        end
    --[[if LOCALE_zhCN or LOCALE_zhTW or e.onlyChinese then--https://www.wowhead.com/cn/pet-ability=509/汹涌
        wowheadText= 'https://www.wowhead.com/cn/%s=%d/%s'
        raiderioText= 'https://raider.io/cn/characters/%s/%s/%s']]
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
    else
        wowheadText= 'https://www.wowhead.com/%s=%d'
        raiderioText= 'https://raider.io/characters/%s/%s/%s'
    end

end

function e.Show_WoWHead_URL(isWoWHead, typeOrRegion, typeIDOrRealm, name)
   if isWoWHead==true then
        if typeIDOrRealm and type(typeIDOrRealm)~='number' then
            typeIDOrRealm= tonumber(typeIDOrRealm)
        end
        StaticPopup_Show("WoWTools_Tooltips_LinkURL",
            'WoWHead',
            nil,
            format(wowheadText, typeOrRegion or '', typeIDOrRealm or 0, name or '')
        )
    elseif isWoWHead==false then
        StaticPopup_Show("WoWTools_Tooltips_LinkURL",
            'Raider.IO',
            nil,
            format(raiderioText, typeOrRegion or GetCurrentRegionName() or '', typeIDOrRealm or e.Player.realm, name)
        )
    else
        StaticPopup_Show("WoWTools_Tooltips_LinkURL", '', nil, name or '')
   end
end

    --func.Set_Web_Link({frame=self, type='npc', id=companionID, name=speciesName, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
    --func.Set_Web_Link({unitName=name, realm=realm, col=nil})--取得单位, raider.io 网页，数据链接
function func.Set_Web_Link(tab)
    if tab.frame==ItemRefTooltip or tab.frame==FloatingBattlePetTooltip then
        if tab.type and tab.id then
            if not tab.frame.wowhead then
                tab.frame.wowhead=e.Cbtn(tab.frame, {size={20,20},type=false})--取得网页，数据链接
                tab.frame.wowhead:SetPoint('RIGHT',tab.frame.CloseButton, 'LEFT',0,2)
                tab.frame.wowhead:SetNormalAtlas('questlegendary')
                tab.frame.wowhead:SetScript('OnClick', function(f)
                    if f.type and f.id then
                        e.Show_WoWHead_URL(true, f.type, f.id, f.name)
                    end
                    --[[if self.web then
                        StaticPopup_Show("WoWTools_Tooltips_LinkURL",
                            'WoWHead',
                            nil,
                            self.web
                        )
                    end]]
                end)
            end
            tab.frame.wowhead.type= tab.type
            tab.frame.wowhead.id= tab.id
            tab.frame.wowhead= tab.name
            --tab.frame.wowhead.web= format(wowheadText, tab.type, tab.id, tab.name or '')
            tab.frame.wowhead:SetShown(true)
        end
        return
    end
    if not Save.ctrl or UnitAffectingCombat('player')  then
        return
    end

    if tab.id then
        if tab.type=='quest' then
            if not tab.name then
                local index= C_QuestLog.GetLogIndexForQuestID(tab.id)
                local info= index and C_QuestLog.GetInfo(index)
                tab.name= info and info.title
            end
        end
        if tab.isPetUI then
            if tab.frame then
                BattlePetTooltipTemplate_AddTextLine(tab.frame, 'wowhead  Ctrl+Shift')
            end
        elseif tab.frame== e.tips then
            tab.frame:AddDoubleLine((tab.col or '')..'WoWHead', (tab.col or '')..'Ctrl+Shift')
        end
        if IsControlKeyDown() and IsShiftKeyDown() then
            e.Show_WoWHead_URL(true, tab.type, tab.id, tab.name)
            --[[StaticPopup_Show("WoWTools_Tooltips_LinkURL",
                'WoWHead',
                nil,
                format(wowheadText, tab.type, tab.id, tab.name or '')
            )]]
        end
    elseif tab.unitName then
        if tab.frame then
            tab.frame:SetText('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO Ctrl+Shift')
            tab.frame:SetShown(true)
        else
            e.tips:AddDoubleLine('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO', (tab.col or '')..'Ctrl+Shift')
            e.tips:SetShown(true)
        end
        if IsControlKeyDown() and IsShiftKeyDown() then
            e.Show_WoWHead_URL(false, nil, tab.realm or e.Player.realm, tab.unitName)
            --[[StaticPopup_Show("WoWTools_Tooltips_LinkURL",
                'Raider.IO',
                nil,
                format(raiderioText, GetCurrentRegionName() or '', tab.realm or e.Player.realm, tab.unitName)
            )]]
        end
    end
end





















function func.Set_Mount(self, mountID, type)--坐骑
    if mountID==268435455 then
        func.Set_Spell(self, 150544)--法术
        return
    end
    self:AddLine(' ')
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    local creatureName, spellID, _,isActive, isUsable, _, _, isFactionSpecific, faction, _, isCollected, _, isForDragonriding =C_MountJournal.GetMountInfoByID(mountID)
    local spell
    if spellID then
        local icon= select(3, GetSpellInfo(spellID))
        spell= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, (icon and '|T'..icon..':0|t' or '')..(e.onlyChinese and '法术' or SPELLS), spellID)
    end
    self:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '坐骑' or MOUNTS, mountID), spell)

    if isFactionSpecific then
        if faction==0 then
            self.textRight:SetFormattedText(
                e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', e.Icon.Horde, e.onlyChinese and '部落' or THE_HORDE)
            )
        elseif faction==1 then
            self.textRight:SetFormattedText(
                e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', e.Icon.Alliance, e.onlyChinese and '联盟' or THE_ALLIANCE)
            )
        end
    elseif isForDragonriding then
        self.textRight:SetFormattedText(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, e.onlyChinese and '驭空术' or MOUNT_JOURNAL_FILTER_DRAGONRIDING)
    end
    local creatureDisplayInfoID, _, source, isSelfMount, _, _, animID = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        self:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '模型' or MODEL, creatureDisplayInfoID), isSelfMount and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '变形' or TUTORIAL_TITLE61_DRUID) or nil)
    end
    if source then
        self:AddLine(source,nil,nil,nil,true)
    end
    func.Set_Item_Model(self, {creatureDisplayID=creatureDisplayInfoID, animID=animID})--设置, 3D模型

    self.text2Left:SetText(isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')

    local can= isCollected and isUsable and not isActive and not UnitCastingInfo('player')
    if can and IsAltKeyDown() then
        C_MountJournal.SummonByID(mountID)
        print(id, Initializer:GetName(), spellID and GetSpellLink(spellID), '|cnGREEN_FONT_COLOR:Alt+'..(e.onlyChinese and '召唤坐骑' or MOUNT))
    end
    local col= can and '|cnGREEN_FONT_COLOR:' or '|cff606060'
    e.tips:AddDoubleLine(col..(e.onlyChinese and '召唤坐骑' or MOUNT), col..'Alt+')

    if type and MountJournal and MountJournal:IsVisible() and creatureName then
        MountJournalSearchBox:SetText(creatureName)
    end
    func.Set_Web_Link({frame=self, type='spell', id=spellID, name=creatureName, col=nil, isPetUI=false})--取得网页，数据链接    
end

























function func.Set_Pet(self, speciesID, setSearchText)--宠物
    if not speciesID or speciesID< 1 then
        return
    end
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    --print(C_PetJournal.GetPetModelSceneInfoBySpeciesID(speciesID))
    if obtainable then--可得到的
        self:AddLine(' ')

        local AllCollected, CollectedNum, CollectedText= e.GetPetCollectedNum(speciesID)--收集数量
        self.textLeft:SetText(CollectedNum or '')
        self.text2Left:SetText(CollectedText or '')
        self.textRight:SetText(AllCollected or '')

        self:AddDoubleLine((e.onlyChinese and '宠物' or PET)..' '..speciesID..(speciesIcon and '  |T'..speciesIcon..':0|t'..speciesIcon or ''), (creatureDisplayID and (e.onlyChinese and '模型' or MODEL)..' '..creatureDisplayID or '')..(companionID and ' NPC '..companionID or ''))--ID

        local tab = C_PetJournal.GetPetAbilityListTable(speciesID) or {}--技能图标
        table.sort(tab, function(a,b) return a.level< b.level end)
        local abilityIconA, abilityIconB = '', ''
        for k, info in pairs(tab) do
            local icon, type = select(2, C_PetJournal.GetPetAbilityInfo(info.abilityID))
            icon='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[type]..':0|t|T'..(icon or 0)..':0|t'..info.level.. ((k~=3 or k~=6) and '  ' or '')
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
        if not canBattle then
            self:AddLine(e.onlyChinese and '该生物无法对战。' or BATTLE_PET_CANNOT_BATTLE, 1,0,0)
        end
    end
    if tooltipSource then
        self:AddLine(tooltipSource,nil,nil,nil, true)--来源
    end
    if petType then
        self.Portrait:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType])
        self.Portrait:SetShown(true)
    end
    func.Set_Item_Model(self, {creatureDisplayID=creatureDisplayID})--设置, 3D模型

    if setSearchText and speciesName and PetJournalSearchBox and PetJournalSearchBox:IsVisible() then--宠物手册，设置名称
        PetJournalSearchBox:SetText(speciesName)
    end

    func.Set_Web_Link({frame=self, type='npc', id=companionID, name=speciesName, col= nil, isPetUI=false})--取得网页，数据链接
    local btn= _G['WoWTools_PetBattle_Type_TrackButton']--PetBattle.lua 联动
    if btn then
        btn:set_type_tips(petType)
    end
end

function func.GetItemInfoFromHyperlink(link)--LinkUtil.lua  GetItemInfoFromHyperlink()不能正解，读取 |Hkeystone:
	local itemID = link and link:match("|H.-:(%d+).-|h")
	if itemID then
		return tonumber(itemID)
	end
end





















--############
--设置,物品信息
--############
function func.Set_Item(self, itemLink, itemID)
    if not itemLink and not itemID then
        return
    end

    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, classID, subclassID, bindType, expacID, setID =  C_Item.GetItemInfo(itemLink or itemID)
    itemID= itemID or C_Item.GetItemInfoInstant(itemLink or itemID) or func.GetItemInfoFromHyperlink(itemLink)
    --itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent
    if not itemID then
        return
    end

    local r, g, b, col= 1,1,1,e.Player.col
    if itemQuality then
        r, g, b, col= C_Item.GetItemQualityColor(itemQuality)
        col=col and '|c'..col
    end
    self:AddLine(' ')
    if expacID then--版本数据
        self:AddDoubleLine(e.GetExpansionText(expacID))
    end

    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID or itemLink)
    self:AddDoubleLine(format('%s%d %s', e.onlyChinese and '物品' or ITEMS, itemID , setID and (e.onlyChinese and '套装' or WARDROBE_SETS)..setID or ''),
                    itemTexture and '|T'..itemTexture..':0|t'..itemTexture, 1,1,1, 1,1,1)--ID, texture
    if classID and subclassID then
        self:AddDoubleLine((itemType and (e.strText[itemType] or itemType)..' classID'  or 'classID') ..' '..classID, (itemSubType and (e.strText[itemSubType] or itemSubType)..' subID' or 'subclassID')..' '..subclassID)
    end

    if classID==2 or classID==4 then
        itemLevel= itemLink and C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel--装等
        if itemLevel and itemLevel>1 then
            local slot= e.GetItemSlotID(itemEquipLoc)--比较装等
            if slot then
                local slotTexture= select(2, e.GetItemSlotIcon(slot))
                if slotTexture then
                    self.Portrait:SetTexture(slotTexture)
                    self.Portrait:SetShown(true)
                end
                self:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, (e.strText[_G[itemEquipLoc]] or _G[itemEquipLoc] or ''), itemEquipLoc), format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, slot), 1,1,1, 1,1,1)--栏位
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
                self.textLeft:SetText(text)
            end
        end

        local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemLink or itemID)--幻化
        local visualID
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                visualID=sourceInfo.visualID
                self.text2Left:SetText(sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
            end
        end
        func.Set_Item_Model(self, {itemID=itemID, sourceID=sourceID, appearanceID=appearanceID, visualID=visualID, col=col})--设置, 3D模型

        if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
            self.Portrait:SetAtlas('greatVault-lock')
        end

        local specTable = itemLink and C_Item.GetItemSpecInfo(itemLink) or {}--专精图标
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

    elseif C_ToyBox.GetToyInfo(itemID) then--玩具
        self.text2Left:SetText(PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')

    elseif itemID==122284 then-- or C_WowTokenPublic.IsAuctionableWowToken(itemID) then --itemID==122284 then--魔兽世界时光徽章
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            self.textLeft:SetText('|A:token-choice-wow:0:0|a'..C_CurrencyInfo.GetCoinTextureString(price))
        end

    else
        local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if mountID then
            func.Set_Mount(self, mountID, 'item')--坐骑
        elseif speciesID then
            func.Set_Pet(self, speciesID, true)--宠物
        else
        end
    end

    if itemQuality==0 and(classID==2 or classID==15) then
        local petText= e.GetPet9Item(itemID)--宠物兑换, wow9.0
        if petText then
            self:AddLine(petText)
        end
    end

    local spellName, spellID = C_Item.GetItemSpell(itemID)--物品法术
    if spellName and spellID then
        local spellTexture= GetSpellTexture(spellID)
        self:AddDoubleLine((itemName~=spellName and col..'['..spellName..']|r' or '')..(e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':0|t'..spellTexture or ' ')
    end

    local wowNum= 0--WoW 数量    
    local bag= C_Item.GetItemCount(itemID, false, false, false)--物品数量
    local bank= C_Item.GetItemCount(itemID, true, false, true) - bag

    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        for guid, info in pairs(e.WoWDate or {}) do
            if guid and guid~=e.Player.guid and info.Keystone.link then
                e.GetKeystoneScorsoColor(info.Keystone.score, false, nil)
                self:AddDoubleLine(
                    (info.Keystone.weekNum==0 and '|cff6060600|r' or info.Keystone.weekNum or '')
                    ..(info.Keystone.weekMythicPlus and '|cnGREEN_FONT_COLOR:('..info.Keystone.weekMythicPlus..') ' or '')
                    ..e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true})
                    ..e.GetKeystoneScorsoColor(info.Keystone.score, false, nil)..(e.GetKeystoneScorsoColor(info.Keystone.score,true)),
                    info.Keystone.link)
            end
        end
        local text=e.Get_Week_Rewards_Text(1)--得到，周奖励，信息
        --[[
        for _, activities in pairs(C_WeeklyRewards.GetActivities(1) or {}) do--本周完成
            if activities.level and activities.level>=0 and activities.type==1 then--Enum.WeeklyRewardChestThresholdType.MythicPlus 1
                text= (text and text..'/' or '')..activities.level
            end
        end]]
        local score= e.GetKeystoneScorsoColor(C_ChallengeMode.GetOverallDungeonScore(), true)
        if text or score then
            self.textLeft:SetText((text and '|cnGREEN_FONT_COLOR:'..text..'|r ' or '')..(score or ''))
        end
        local info = C_MythicPlus.GetRunHistory(false, true) or {}--本周记录
        local num= 0
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
            self.text2Left:SetText(num..'|cnGREEN_FONT_COLOR:('..completedNum..')|r')
        end

    else
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(e.WoWDate or {}) do
            if guid and guid~=e.Player.guid and info.Item[itemID] then
                local tab=info.Item[itemID]
                self:AddDoubleLine(e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), '|A:Banker:0:0|a'..(tab.bank==0 and '|cff606060'..tab.bank..'|r' or tab.bank)..' '..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff606060'..tab.bag..'|r' or tab.bag))
                bagAll=bagAll +tab.bag
                bankAll=bankAll +tab.bank
                numPlayer=numPlayer +1
            end
        end

        if numPlayer>0 then
            wowNum= bagAll+ bankAll
            self:AddDoubleLine(numPlayer..' '..(e.onlyChinese and '角色' or CHARACTER)..' '..e.MK(wowNum+bag+bank, 3), format('|T%d:0|t', e.Icon.wow)..e.MK(bagAll+bankAll, 3)..' = '..'|A:Banker:0:0|a'..(bankAll==0 and '|cff606060'..bankAll..'|r' or e.MK(bankAll,3))..' '..'|A:bag-main:0:0|a'..(bagAll==0 and '|cff606060'..bagAll..'|r' or e.MK(bagAll, 3)))
        end
    end

    self.textRight:SetText(col..e.MK(wowNum, 3)..format('|T%d:0|t', e.Icon.wow)..' '..e.MK(bank, 3)..'|A:Banker:0:0|a'..' '..e.MK(bag, 3)..'|A:bag-main:0:0|a'..'|r')

    --setItemCooldown(self, itemID)--物品冷却

    self.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    self.backgroundColor:SetShown(true)

    func.Set_Web_Link({frame=self, type='item', id=itemID, name=itemName, col=col, isPetUI=false})--取得网页，数据链接

    self:Show()
end















function func.Set_Spell(self, spellID)--法术
    spellID = spellID or select(2, self:GetSpell())
    if not spellID then
        return
    end
    local name, _, icon, _, _, _, _, originalIcon= GetSpellInfo(spellID)
    local spellTexture=  originalIcon or icon or GetSpellTexture(spellID)
    self:AddLine(' ')
    self:AddDoubleLine((e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and '|T'..spellTexture..':0|t'..spellTexture, 1,1,1, 1,1,1)
    local mountID = spellID~=150544 and C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        func.Set_Mount(self, mountID)
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
        func.Set_Web_Link({frame=self, type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end
end

function func.Set_Currency(self, currencyID)--货币
    local info2 = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info2 then
        return
    end
    self:AddDoubleLine((e.onlyChinese and '货币' or TOKENS)..' '..currencyID, info2.iconFileID and '|T'..info2.iconFileID..':0|t'..info2.iconFileID)
    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= GetFactionInfoByID(factionID)
        if name then
            self:AddDoubleLine(e.onlyChinese and '声望' or REPUTATION, name..' '..factionID)
        end
    end

    local all,numPlayer=0,0
    for guid, info in pairs(e.WoWDate or {}) do--帐号数据
        if guid~=e.Player.guid then
            local quantity=info.Currency[currencyID]
            if quantity and quantity>0 then
                self:AddDoubleLine(e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), e.MK(quantity, 3))
                all=all+quantity
                numPlayer=numPlayer+1
            end
        end
    end
    if numPlayer>1 then
        self:AddDoubleLine(format('|T%d:0|t', e.Icon.wow)..numPlayer..(e.onlyChinese and '角色' or CHARACTER), e.MK(all,3))
    end

    func.Set_Web_Link({frame=self, type='currency', id=currencyID, name=info2.name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency

    self:Show()
end
















function func.Set_Achievement(self, achievementID)--成就
    if not achievementID then
        return
    end
    e.tips:AddLine(' ')
    local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)
    self.textLeft:SetText(points..(e.onlyChinese and '点' or RESAMPLE_QUALITY_POINT))--点数
    self.text2Left:SetText(completed and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已完成' or CRITERIA_COMPLETED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)..'|r')--否是完成
    self.textRight:SetText(isGuild and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '公会' or GUILD) or flags==0x4000 and ('|cffff00ff'..e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))  or '')

    self:AddDoubleLine((e.onlyChinese and '成就' or ACHIEVEMENTS)..' '..(flags==0x20000 and '|cffff00ff'..format('|T%d:0|t', e.Icon.wow)..achievementID..'|r' or achievementID), icon and '|T'..icon..':0|t'..icon)
    if flags==0x20000 then
        self.textRight:SetText(e.Icon.net2..'|cffff00ff'..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))
    end
    func.Set_Web_Link({frame=self, type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
end




















function func.Set_Quest(self, questID, info)----任务
    questID= questID or (info and info.questID or nil)
    if not questID then
        return
    end
    self:AddDoubleLine(e.GetExpansionText(nil, questID))--任务版本

    local lv=C_QuestLog.GetQuestDifficultyLevel(questID)--等级
    local levelText
    if lv then
        if lv<e.Player.level then
            levelText= '|cnGREEN_FONT_COLOR:['..lv..']|r'
        elseif lv>e.Player.level then
            levelText= '|cnRED_FONT_COLOR:['..lv..']|r'
        else
            levelText='|cffffffff['..lv..']|r'
        end
    end
    self:AddDoubleLine((e.onlyChinese and '任务' or QUESTS_LABEL)..(levelText or ''), questID)

    if not info then
        local questLogIndex= C_QuestLog.GetLogIndexForQuestID(questID)
        info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
    end

    local distanceSq= C_QuestLog.GetDistanceSqToQuest(questID)--距离
    if distanceSq and distanceSq>0 then
        local _, x, y = QuestPOIGetIconInfo(questID)
        if x and y then
            x=math.modf(x*100) y=math.modf(y*100)
        end
        e.tips:AddDoubleLine(x and y and 'XY '..x..', '..y or ' ',  format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, e.MK(distanceSq)))
    end

    local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
    local name
    if tagInfo and tagInfo.tagID then
        local atlas, color = e.QuestLogQuests_GetBestTagID(questID, info, tagInfo, nil)
        local col= color and color.hex or ''
        self:AddDoubleLine(col..(atlas or '')..'tagID', col..tagInfo.tagID)
        name= tagInfo.name
    else
        local tagID= C_QuestLog.GetQuestType(questID)
        if tagID and tagID>0 then
            self:AddDoubleLine('tagID', tagID)
        end
    end
    func.Set_Web_Link({frame=self, type='quest', id=questID, name=name or C_QuestLog.GetTitleForQuestID(questID), col=nil, isPetUI=false})--取得网页，数据链接
end



















--####
--Buff
--####
function func.set_All_Aura(self, data)--Aura
    local name, _, icon, _, _, _, spellID = GetSpellInfo(data.id)
   if icon and spellID then
        self:AddLine(' ')
        self:AddDoubleLine((e.onlyChinese and '光环' or AURAS)..' '..spellID, '|T'..icon..':0|t'..icon)
        local mountID = C_MountJournal.GetMountFromSpell(spellID)
        if mountID then
            func.Set_Mount(self, mountID, 'aura')

        else
            func.Set_Web_Link({frame=self, type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
        end
    end
end
function func.set_Buff(type, self, ...)
    local source--local unit= ...
    if type=='Buff' then
        source= select(7, UnitBuff(...))
    elseif type=='Debuff' then
        source= select(7, UnitDebuff(...))
    else
        source= select(7, UnitAura(...))
    end
    if source then--来源
        if source then
            local r, g ,b , col= e.GetUnitColor(source)-- GetClassColor(UnitClassBase(source))
            if r and g and b then
                self.backgroundColor:SetColorTexture(r, g, b, 0.3)
                self.backgroundColor:SetShown(true)
            end
            if source~='player' then
                SetPortraitTexture(self.Portrait, source)
                self.Portrait:SetShown(true)
            end
            local text= source=='player' and (e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                    or source=='pet' and (e.onlyChinese and '宠物' or PET)
                    or UnitIsPlayer(source) and e.GetPlayerInfo({unit=source, reName=true})
                    or UnitName(source) or _G[source] or source
            self:AddLine((col or '|cffffffff') ..format(e.onlyChinese and '来源：%s' or RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT, text)..'|r')
            self:Show()
        end
    end
end



















--####
--声望
--####
function func.Set_Faction(self, factionID, frame)
    local info= e.GetFactionInfo(factionID, nil, true)
    if not info.factionID then return end
    if frame and not self:IsShown() then
        e.tips:SetOwner(frame, "ANCHOR_RIGHT")
        e.tips:AddLine(e.cn(info.name))
        e.tips:AddLine(' ')
        if info.description and info.description~='' then
            e.tips:AddLine(e.cn(info.description), nil,nil,nil, true)
            e.tips:AddLine(' ')
        end
    end
    local icon= info.texture and ('|T'..info.texture..':0|t'..info.texture)
                or (info.atlas and '|A:'..info.atlas..':0:0|a'..info.atlas)
    if info.friendshipID then
        self:AddDoubleLine((e.onlyChinese and '个人声望' or format(QUEST_REPUTATION_REWARD_TITLE, 'NPC'))..' '..info.friendshipID, icon)
    elseif info.isMajorFaction then
        self:AddDoubleLine((e.onlyChinese and '主要阵营' or MAJOR_FACTION_LIST_TITLE)..' '..info.factionID, icon)
    else
        self:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..info.factionID, icon)
    end
    if info.factionStandingtext or info.valueText then
        self:AddDoubleLine(info.factionStandingtext or ' ', (info.hasRewardPending or '')..(info.valueText or '')..(info.valueText and info.isParagon and '|A:Banker:0:0|a' or ''))
    end
    if info.hasRewardPending then
        self:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
    end
    func.Set_Web_Link({frame=self, type='faction', id=info.friendshipID or info.factionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
    self:Show()
end

--[[function func.Set_FriendshipFaction(self, friendshipID)--friend声望
    local repInfo = C_GossipInfo.GetFriendshipReputation(friendshipID)
	if ( repInfo and repInfo.friendshipFactionID and repInfo.friendshipFactionID > 0) then
        local icon = (repInfo.texture and repInfo.texture>0) and repInfo.texture
        self:AddDoubleLine((e.onlyChinese and '个人声望' or (INDIVIDUALS..REPUTATION))..' '..friendshipID, icon and '|T'..icon..':0|t'..icon)
       
        func.Set_Web_Link({frame=self, type='faction', id=friendshipID, name=repInfo.name, col=nil, isPetUI=false})--取得网页，数据链接
        self:Show()
    end
end]]

--[[function func.Set_MajorFactionRenown(self, majorFactionID)--名望
	local info = C_MajorFactions.GetMajorFactionData(majorFactionID)--C_Reputation.IsMajorFaction(majorFactionID)
    if info then
        if info.textureKit then
            self.Portrait:SetShown(true)
            self.Portrait:SetAtlas('MajorFactions_Icons_'..info.textureKit..'512')
            self.textLeft:SetText('|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'..'MajorFactions_Icons_'..info.textureKit..'512')
        end
        local levels = C_MajorFactions.GetRenownLevels(majorFactionID)
        self:AddDoubleLine(
            (e.onlyChinese and '名望' or RENOWN_LEVEL_LABEL)..' '..majorFactionID,
            format(
                e.onlyChinese and '名望等级 %d' or MAJOR_FACTION_RENOWN_LEVEL_TOAST, info.renownLevel)
                ..(levels and '/'..#levels or '')
                ..' '..format('%i%%',info.renownReputationEarned/info.renownLevelThreshold*100
            )
        )
        func.Set_Web_Link({frame=self, type='faction', id=majorFactionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
        self:Show()
    end
end]]
















--#########
--生命条提示
--#########
function func.Set_HealthBar_Unit(frame, unit)
    if Save.hideHealth then
        return
    end
    unit= unit or select(2, TooltipUtil.GetDisplayedUnit(GameTooltip))
    if not unit or frame:GetWidth()<100 then
        frame.text:SetText('')
        frame.textLeft:SetText('')
        frame.textRight:SetText('')
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
            local hp = value / max * 100
            text = ('%i%%'):format(hp)..'  '
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
        frame:SetStatusBarColor(r or 1, g or 1, b or 1)
    end
    frame.text:SetText(text or '')
    frame.textLeft:SetText(left or '')
    frame.textRight:SetText(right or '')
    frame.textLeft:SetTextColor(r or 1, g or 1, b or 1)
    frame.textRight:SetTextColor(r or 1, g or 1, b or 1)
end




local function Int_Health_Bar_Unit()--hooksecurefunc(GameTooltipStatusBar, 'UpdateUnitHealth', function(self)
    if Save.hideHealth then
        return
    end
    GameTooltipStatusBar.text= e.Cstr(GameTooltipStatusBar, {justifyH='CENTER'})
    GameTooltipStatusBar.text:SetPoint('TOP', GameTooltipStatusBar, 'BOTTOM')--生命条
    GameTooltipStatusBar.textLeft = e.Cstr(GameTooltipStatusBar, {justifyH='LEFT'})
    GameTooltipStatusBar.textLeft:SetPoint('TOPLEFT', GameTooltipStatusBar, 'BOTTOMLEFT')--生命条
    GameTooltipStatusBar.textRight = e.Cstr(GameTooltipStatusBar, {size=18, justifyH='RIGHT'})
    GameTooltipStatusBar.textRight:SetPoint('TOPRIGHT',0, -2)--生命条
    GameTooltipStatusBar:HookScript("OnValueChanged", function(self)
        func.Set_HealthBar_Unit(self)
    end)
end





















--#######
--设置单位
--#######
function func.Set_Unit(self)--设置单位提示信息
    local name, unit, guid= TooltipUtil.GetDisplayedUnit(self)
    if not name or not UnitExists(unit) or not guid then
        return
    end

    local realm= select(2, UnitName(unit)) or e.Player.realm--服务器
    local isPlayer = UnitIsPlayer(unit)
    local isSelf= UnitIsUnit('player', unit)--我
    local isGroupPlayer= (not isSelf and e.GroupGuid[guid]) and true or nil--队友
    local r, g, b, col = e.GetUnitColor(unit)--颜色
    local isInCombat= UnitAffectingCombat('player')

    --设置单位图标
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    local textLeft, text2Left
    if isPlayer then
        local hideLine--取得网页，数据链接
        self.Portrait:SetAtlas(e.Icon[englishFaction] or 'Neutral')
        self.Portrait:SetShown(true)

        --取得玩家信息
        local info= e.UnitItemLevel[guid]
        if info then
            if not isInCombat then
                e.GetNotifyInspect(nil, unit)--取得装等
            end
            if info.itemLevel then--设置装等
                if info.itemLevel>1 then
                    col= col or select(4, e.GetUnitColor(unit))
                    textLeft= (col or '|cffffffff')..info.itemLevel..'|r'
                else
                    textLeft= ' '
                end
            end
            if info.specID then
                local icon, role= select(4, GetSpecializationInfoByID(info.specID))--设置天赋
                if icon then
                    text2Left= "|T"..icon..':0|t'..(e.Icon[role] or '')
                end
            end
        else
            e.GetNotifyInspect(nil, unit)--取得装等
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
                    textLeft= (e.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.Player.layer))..(textLeft or '')
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

        local isInGuild= guid and IsPlayerInGuildFromGUID(guid)
        local line=GameTooltipTextLeft1--名称
        if line then
            if isSelf then--魔兽世界时光徽章
                C_WowTokenPublic.UpdateMarketPrice()
                local price= C_WowTokenPublic.GetCurrentMarketPrice()
                if price and price>0 then
                    local all, numPlayer= e.GetItemWoWNum(122284)--取得WOW物品数量
                    GameTooltipTextRight1:SetText(col..all..(numPlayer>1 and '('..numPlayer..')' or '')..'|A:token-choice-wow:0:0|a'..e.MK(price/10000,3)..'|r|A:Front-Gold-Icon:0:0|a')
                    GameTooltipTextRight1:SetShown(true)
                end
            end
            line:SetText((isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or e.GetFriend(nil, guid, nil) or '')
                        ..col..format('|A:%s:0:0|a', e.Icon.toRight)..name..format('|A:%s:0:0|a', e.Icon.toLeft)
                        ..'|r')
        end


        local region= e.Get_Region(realm)--服务器，EU， US
        self.textRight:SetText(col..realm..'|r'..(isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or realm==e.Player.realm and format('|A:%s:0:0|a', e.Icon.select) or e.Player.Realms[realm] and '|A:Adventures-Checkmark:0:0|a' or '')..(region and region.col or ''))

        line=isInGuild and GameTooltipTextLeft2
        if line then
            local text=line:GetText()
            if text then
                line:SetText('|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'..col..text:gsub('(%-.+)','')..'|r')
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

            info= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)--挑战, 分数
            if info and info.currentSeasonScore and info.currentSeasonScore>0 then
                text= text..' '..(e.GetUnitRaceInfo({unit=unit, guid=guid, race=raceFile, sex=sex, reAtlas=false}) or '')
                        ..' '..e.Class(nil, classFilename)
                        ..' '..(UnitIsPVP(unit) and  '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and 'PvP' or PVP)..'|r' or (e.onlyChinese and 'PvE' or TRANSMOG_SET_PVE))
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
                        ..(e.strText[raceFile] or raceName or '')
                        ..' '..(e.Class(nil, classFilename) or '')
                        ..' '..(UnitIsPVP(unit) and '(|cnGREEN_FONT_COLOR:'..(e.onlyChinese and 'PvP' or TRANSMOG_SET_PVP)..'|r)' or ('('..(e.onlyChinese and 'PvE' or TRANSMOG_SET_PVE)..')'))
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
                        line:SetText(e.Player.Layer and '|A:nameplates-holypower2-on:0:0|a'..col..e.Player.L.layer..' '..e.Player.Layer..'|r' or ' ')
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
                                line:SetText('|A:poi-islands-table:0:0|a'..col..mapInfo.name)
                                line:SetShown(true)
                            end
                        end
                    else
                        if not hideLine  then
                            hideLine=line
                            line:SetTextColor(r,g,b)
                        else
                            line:SetText('')
                            line:SetShown(false)
                        end
                    end
                else
                    if not hideLine then
                        hideLine=line
                        line:SetTextColor(r,g,b)
                    else
                        line:SetText('')
                        line:SetShown(false)
                    end
                end
            end
        end
        if isInCombat then
            if hideLine then
                hideLine:SetText('')
                hideLine:SetShown(false)
            end
        else
            func.Set_Web_Link({frame=hideLine, unitName=name, realm=realm, col=nil})--取得单位, raider.io 网页，数据链接
        end

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        func.Set_Pet(self, UnitBattlePetSpeciesID(unit), true)

    else
        if not Save.disabledNPCcolor then
            for i=1, self:NumLines() do
                local line=_G["GameTooltipTextLeft"..i]
                if line then
                    line:SetTextColor(r,g,b)
                end
            end
        end

        local uiWidgetSet= UnitWidgetSet(unit)
        if uiWidgetSet and uiWidgetSet>0 then
            e.tips:AddDoubleLine('WidgetSetID', uiWidgetSet, r,g,b, r,g,b)
        end


        if guid then
            local zone, npc = select(5, strsplit("-", guid))--位面,NPCID
            if zone then
                self:AddDoubleLine(col..e.Player.L.layer..' '..zone, col..'NPC '..npc, r,g,b, r,g,b)
                e.Player.Layer=zone
            end
            func.Set_Web_Link({frame=self, type='npc', id=npc, name=name, col=col, isPetUI=false})--取得网页，数据链接 
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
            local classification = UnitClassification(unit)--TargetFrame.lua
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
            self.textRight:SetText(col..e.cn(type)..'|r')
        end
    end

    self.textLeft:SetText(textLeft or '')
    self.text2Left:SetText(text2Left or '')

    func.Set_HealthBar_Unit(GameTooltipStatusBar, unit)--生命条提示
    func.Set_Item_Model(self, {unit=unit, guid=guid, col= col})--设置, 3D模型

    --[[if isSelf and not isInCombat and Save.WidgetSetID>0 then
        GameTooltip_AddWidgetSet(e.tips, Save.WidgetSetID, 10)
    end]]
end












--########
--设置Cvar
--########
local function set_CVar(reset, tips, notPrint)
    local tab={
        {   name='missingTransmogSourceInItemTooltips',
            value='1',
            msg=e.onlyChinese and '显示装备幻化来源' or TRANSMOGRIFY..SOURCES..': '..SHOW,
        },
        {   name='nameplateOccludedAlphaMult',
            value='0.15',
            msg=e.onlyChinese and '不在视野里, 姓名板透明度' or (SPELL_FAILED_LINE_OF_SIGHT..'('..SHOW_TARGET_CASTBAR_IN_V_KEY..')'..'Alpha'),
        },
        {   name='dontShowEquipmentSetsOnItems',
            value='0',
            msg=e.onlyChinese and '显法装备方案' or EQUIPMENT_SETS:format(SHOW),
        },
        {   name='UberTooltips',
            value='1',
            msg=e.onlyChinese and '显示法术信息' or SPELL_MESSAGES..': '..SHOW,
        },
        {   name="alwaysCompareItems",
             value= "1",
             msg= e.onlyChinese and '总是比较装备' or ALWAYS..COMPARE_ACHIEVEMENTS:gsub(ACHIEVEMENTS, ITEMS)
        },
        {   name="profanityFilter",
            value= '0',
            msg= '禁用语言过虑 /reload',
            zh=true,
        },
        {   name="overrideArchive",
            value= '0',
            msg= '反和谐 /reload',
            zh=true
        },
        {   name='cameraDistanceMaxZoomFactor',
            value= '2.6',
            msg= e.onlyChinese and '视野距离' or FARCLIP
        },
        {   name="showTargetOfTarget",
            value= "1",
            msg= e.onlyChinese and '总是显示目标的目标' or OPTION_TOOLTIP_TARGETOFTARGET5,
        },
        {   name='worldPreloadNonCritical',--https://wago.io/ZtSxpza28
            value='0',--2
            msg= e.onlyChinese and '世界非关键预加载' or 'World Preload Non Critical'
        }
    }

    if tips then
        local text
        for _, info in pairs(tab) do
            if info.zh and LOCALE_zhCN or not info.zh then
                text= (text and text..'|n|n' or '')..e.Get_CVar_Tooltips(info)
            end
        end
        return text
    end

    for _, info in pairs(tab) do
        if info.zh and LOCALE_zhCN or not info.zh then
            if reset then
                local defaultValue = C_CVar.GetCVarDefault(info.name)
                local value = C_CVar.GetCVar(info.name)
                if defaultValue~=value then
                    C_CVar.SetCVar(info.name, defaultValue)
                    if not notPrint then
                        print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r', info.name, defaultValue, info.msg)
                    end
                end
            else
                local value = C_CVar.GetCVar(info.name)
                if value~=info.value then
                    C_CVar.SetCVar(info.name, info.value)
                    if not notPrint then
                        print(id,Initializer:GetName(), info.name, info.value..'('..value..')', info.msg)
                    end
                end
            end
        end
    end
end











--###########
--法术, 弹出框
--###########
function func.Set_Flyout(self, flyoutID)--法术, 弹出框
    local name, _, numSlots, isKnown= GetFlyoutInfo(flyoutID)
    if not name then
        return
    end

    self:AddLine(' ')
    for slot= 1, numSlots do
        local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            e.LoadDate({id=spellID, type='spell'})
            local name2, _, icon = GetSpellInfo(spellID)
            if name2 and icon then
                self:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..e.cn(name2)..'|r', (not isKnown2 and '|cnRED_FONT_COLOR:' or '').. spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            else
                self:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            end
        end
    end

    local icon
    local btn= self:GetOwner()
    if btn and (btn.IconTexture or btn.icon) then
        icon= (btn.IconTexture or btn.icon):GetTextureFileID()
    end
    self:AddLine(' ')
    self:AddDoubleLine((not isKnown and '|cnRED_FONT_COLOR:' or '')..'flyoutID|r '..flyoutID, icon and icon>0 and format('|T%d:0|t%d', icon, icon), 1,1,1, 1,1,1)
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
        func.Set_Init_Item(self, true)--创建物品
    end
    func.Set_Item_Model(self, {creatureDisplayID=creatureDisplayID})--设置, 3D模型
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

    if tooltipSource then
        --tooltipSource= tooltipSource:gsub(':', ':|n')
        --tooltipSource= tooltipSource:gsub('：', ':|n')
        BattlePetTooltipTemplate_AddTextLine(self, tooltipSource)--来源提示
        --print(tooltipSource)
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

    local AllCollected, CollectedNum, CollectedText= e.GetPetCollectedNum(speciesID)--收集数量
    self.textLeft:SetText(CollectedNum or '')
    self.text2Left:SetText(CollectedText or '')
    self.textRight:SetText(not CollectedNum and AllCollected or '')

    func.Set_Web_Link({frame=self, type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})--取得网页，数据链接
end

function func.set_Azerite(self, powerID)--艾泽拉斯之心
    if powerID then
        self:AddLine(' ')
        self:AddDoubleLine('powerID', powerID)
        local info = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
        if info and info.spellID then
            func.Set_Spell(self, info.spellID)--法术
        end
    end
end







































--####
--初始
--####
local function Init()
    --[[func.Set_Init_Item(ItemRefTooltip)
    func.Set_Init_Item(e.tips)
    func.Set_Init_Item(EmbeddedItemTooltip)]]

    --Init_Web_Link()--取得网页，数据链接
    Int_Health_Bar_Unit()--生命条提示
    --Init_StableFrame_Plus()--猎人，兽栏 Plus 10.2.7

    --[[e.tips:HookScript("OnHide", function(self)--隐藏
        func.Set_Init_Item(self, true)
    end)
    ItemRefTooltip:HookScript("OnHide", function (self)--隐藏
        func.Set_Init_Item(self, true)
        if ItemRefTooltip.wowhead then
            ItemRefTooltip.wowhead.web=nil--取得网页，数据链接
            ItemRefTooltip.wowhead:SetShown(false)
        end
    end)
    EmbeddedItemTooltip:HookScript('OnHide', function(self)
        func.Set_Init_Item(self, true)
    end)]]

    --[[Blizzard_UIWidgetTemplateBase.lua
    hooksecurefunc(EmbeddedItemTooltip, 'SetSpellByID', function(self, spellID)--法术 Blizzard_UIWidgetTemplateBase.lua
        if spellID and spellID>0 then
            local _, _, icon, _, _, _, _, originalIcon= GetSpellInfo(spellID)
            local spellTexture=  originalIcon or icon or GetSpellTexture(spellID)
            GameTooltip_AddColoredLine(
                EmbeddedItemTooltip,
                (e.onlyChinese and '法术' or SPELLS)..' '..spellID..(spellTexture and '  |T'..spellTexture..':0|t'..spellTexture or ''),
                self.tooltipColor or HIGHLIGHT_FONT_COLOR, true
            )
        end
    end)
    hooksecurefunc(EmbeddedItemTooltip, 'SetItemByID', function(self, itemID)--物品 Blizzard_UIWidgetTemplateBase.lua
        if itemID and itemID>0 then
            local texture= C_Item.GetItemNameByID(itemID) or select(10, C_Item.GetItemInfo(itemID))
            GameTooltip_AddColoredLine(
                EmbeddedItemTooltip,
                (e.onlyChinese and '物品' or ITEMS)..' '..itemID..(texture and '  |T'..texture..':0|t'..texture or ''),
                self.tooltipColor or HIGHLIGHT_FONT_COLOR, true
            )
        end
    end)]]


    hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', func.Set_Quest)--世界任务ID GameTooltip_AddQuest

    --战斗宠物，技能 SharedPetBattleTemplates.lua
    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo, additionalText)
        local abilityID = abilityInfo:GetAbilityID()
        if abilityID then
            local _, name, icon, _, unparsedDescription, _, petType = C_PetBattles.GetAbilityInfoByID(abilityID)
            local description = SharedPetAbilityTooltip_ParseText(abilityInfo, unparsedDescription)
            self.Description:SetText(description
                                    ..'|n|n|cffffffff'..(e.onlyChinese and '技能' or ABILITIES)
                                    ..' '..abilityID
                                    ..(icon and '  |T'..icon..':0|t'..icon or '')..'|r'
                                    ..(Save.ctrl and not UnitAffectingCombat('player') and '|nWoWHead Ctrl+Shift' or '')
                                )
            func.Set_Web_Link({frame=self, type='pet-ability', id=abilityID, name=name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
            local btn= _G['WoWTools_PetBattle_Type_TrackButton']--PetBattle.lua 联动
            if btn then
                btn:set_type_tips(petType)
            end
        end
    end)

    --装备，对比，提示
    ShoppingTooltip1.Portrait= ShoppingTooltip1:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
    ShoppingTooltip1.Portrait:SetPoint('TOPRIGHT',-2, -3)
    ShoppingTooltip1.Portrait:SetSize(40,40)
    ShoppingTooltip1.Portrait:SetAtlas('Adventures-Target-Indicator')
    ShoppingTooltip1.Portrait:SetAlpha(0.5)

    ShoppingTooltip2.Portrait= ShoppingTooltip2:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
    ShoppingTooltip2.Portrait:SetPoint('TOPRIGHT',-2, -3)
    ShoppingTooltip2.Portrait:SetSize(40,40)
    ShoppingTooltip2.Portrait:SetAtlas('Adventures-Target-Indicator')
    ShoppingTooltip2.Portrait:SetAlpha(0.5)

    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes,  function(tooltip, data)--TooltipUtil.lua
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        if not tooltip.textLeft then
            func.Set_Init_Item(tooltip)
            tooltip:HookScript("OnHide", function(frame)--隐藏
                func.Set_Init_Item(frame, true)
                if frame.wowhead then
                    frame.wowhead.web=nil--取得网页，数据链接
                    frame.wowhead:SetShown(false)
                end
            end)
        end


        --25宏, 11动作条, 4可交互物品, 14装备管理, 0物品 19玩具, 9宠物
        if data.type==2 then--单位
            if tooltip== GameTooltip then
                func.Set_Unit(tooltip)
            end

        elseif data.id and data.type then
            if data.type==0 then
                local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))--物品
                itemLink= itemLink or itemID or data.id
                func.Set_Item(tooltip, itemLink, itemID)
            elseif data.type==19 then
                func.Set_Item(tooltip, nil, data.id)--物品

            elseif data.type==1 then
                func.Set_Spell(tooltip, data.id)--法术

            elseif data.type==5 then
                func.Set_Currency(tooltip, data.id)--货币

            elseif data.type==7 then--Aura
                func.set_All_Aura(tooltip, data)

            elseif data.type==8 then--艾泽拉斯之心
                func.set_Azerite(tooltip, data.id)

            elseif data.type==10 then
                func.Set_Mount(tooltip, data.id)--坐骑

            elseif data.type==12 then--成就
                func.Set_Achievement(tooltip, data.id)

            elseif data.type==22 then--法术弹出框
                func.Set_Flyout(tooltip, data.id)

            elseif data.type==23 then
                func.Set_Quest(tooltip, data.id)--任务

            elseif data.type==25 then--宏
                local frame= GetMouseFocus()
                if frame and frame.action then
                    local type, macroID, subType= GetActionInfo(frame.action)
                    if type=='macro' and macroID then
                        if subType=='spell' then--and macroID or GetMacroSpell(macroID)
                            func.Set_Spell(tooltip, macroID)
                        elseif not subType or subType=='' then
                            local text=GetMacroBody(macroID)
                            if text then
                                tooltip:AddLine(text)
                            end
                        end
                        --tooltip:AddDoubleLine('|cffffffffaction', '|cffffffff'..frame.action)
                    end
                end

            --elseif e.Player.husandro then
              --  tooltip:AddDoubleLine('id '..data.id, 'type '..data.type)
            end
        --elseif e.Player.husandro  and (data.id or data.type) then
          --  tooltip:AddDoubleLine(data.type and 'type '..data.type or ' ', data.id and 'id '..data.id or '')
        end
    end)

    hooksecurefunc(GameTooltip, 'SetSpellBookItem', function(_, slot, unit)--技能收，宠物，技能，提示
        if unit=='pet' and slot then
            local icon=GetSpellBookItemTexture(slot, 'pet')
            local spellID = select(3, GetSpellBookItemName(slot, 'pet'))
            if spellID then
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine((e.onlyChinese and '法术' or SPELLS)..' '..spellID, icon and '|T'..icon..':0|t'..icon)
                local slotType, actionID = GetSpellBookItemInfo(slot, 'pet')
                if slotType and actionID then
                    e.tips:AddDoubleLine('slotType '..slotType, 'actionID '..actionID)
                end
            end
        end
    end)

    --################
    --Buff, 来源, 数据, 不可删除，如果删除，目标buff没有数据
    --################
    hooksecurefunc(e.tips, "SetUnitBuff", function(...)
        func.set_Buff('Buff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitDebuff", function(...)
        func.set_Buff('Debuff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitAura", function(...)
        func.set_Buff('Aura', ...)
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



    --####
    --声望
    --####
    --[[hooksecurefunc(ReputationBarMixin, 'ShowMajorFactionRenownTooltip', function(self)--Major名望, ReputationFrame.lua
        func.Set_Faction(e.tips, self.factionID)
    end)
    hooksecurefunc(ReputationBarMixin, 'ShowFriendshipReputationTooltip', function(self, friendshipID)--个人声望 ReputationFrame.lua
        func.Set_Faction(e.tips, friendshipID)
    end)]]
    hooksecurefunc(ReputationBarMixin, 'OnEnter', function(frame)--角色栏,声望
        func.Set_Faction(e.tips, frame.factionID, frame)
    end)

    hooksecurefunc('ReputationFrame_InitReputationRow',function(_, elementData)--ReputationFrame.lua 声望 界面,
        local factionIndex = elementData.index
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
        func.Set_Pet(self, speciesID)--宠物
    end)

    if Save.setCVar then
        set_CVar(nil, nil, true)--设置CVar
        if LOCALE_zhCN then
            ConsoleExec("portal TW")
            SetCVar("profanityFilter", '0')

            local pre = C_BattleNet.GetFriendGameAccountInfo
---@diagnostic disable-next-line: duplicate-set-field
            C_BattleNet.GetFriendGameAccountInfo = function(...)
                local gameAccountInfo = pre(...)
                gameAccountInfo.isInCurrentRegion = true
                return gameAccountInfo
            end
        end
    end

    --[[if ExtraActionButton1 then
        ExtraActionButton1:HookScript('OnLeave', GameTooltip_Hide)
    end]]


    hooksecurefunc(AreaPOIPinMixin,'TryShowTooltip', function(self)--POI提示 AreaPOIDataProvider.lua
        e.tips:AddLine(' ')
        local uiMapID = self:GetMap() and self:GetMap():GetMapID()
        if self.areaPoiID then
            e.tips:AddDoubleLine('areaPoiID', self.areaPoiID)
        end
        if self.widgetSetID then
            e.tips:AddDoubleLine('widgetSetID', self.widgetSetID)
            for _,widget in ipairs(C_UIWidgetManager.GetAllWidgetsBySetID(self.widgetSetID) or {}) do
                if widget and widget.widgetID and widget.shownState==1 then
                    e.tips:AddDoubleLine('|A:characterupdate_arrow-bullet-point:0:0|awidgetID', widget.widgetID)
                end
            end
        end
        if uiMapID then
            e.tips:AddDoubleLine('uiMapID', uiMapID)
        end
        if self.factionID then
            func.Set_Faction(e.tips, self.factionID)
        end
        if self.areaPoiID and uiMapID then
            local poiInfo= C_AreaPoiInfo.GetAreaPOIInfo(uiMapID, self.areaPoiID)
            if poiInfo and poiInfo.atlasName  then
                e.tips:AddDoubleLine('atlasName', '|A:'..poiInfo.atlasName..':0:0|a'..poiInfo.atlasName)
            end
        end
        e.tips:Show()
    end)

    --#############
    --挑战, AffixID
    --Blizzard_ScenarioObjectiveTracker.lua
    hooksecurefunc(ScenarioChallengeModeAffixMixin, 'OnEnter', function(self)
        if self.affixID then
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
            GameTooltip:SetText(e.cn(name), 1, 1, 1, 1, true)
            GameTooltip:AddLine(e.cn(description), nil, nil, nil, true)
            GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
            func.Set_Web_Link({frame=GameTooltip, type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
    if ScenarioChallengeModeBlock and ScenarioChallengeModeBlock.Affixes and ScenarioChallengeModeBlock.Affixes[1] then
        ScenarioChallengeModeBlock.Affixes[1]:HookScript('OnEnter', function(self)
            if self.affixID then
                local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
                GameTooltip:SetText(e.cn(name), 1, 1, 1, 1, true)
                GameTooltip:AddLine(e.cn(description), nil, nil, nil, true)
                GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
                func.Set_Web_Link({frame=GameTooltip, type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
                GameTooltip:Show()
            end
        end)
    end

    --试衣间
    --DressUpFrames.lua
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'OnEnter', function(self)
        if self.transmogID then
            e.tips:AddDoubleLine('transmogID', self.transmogID)
        end
    end)





    --添加任务ID
    local function create_Quest_Label(frame)
        frame.questIDLabel= e.Cstr(frame, {mouse=true, justifyH='RIGHT'})
        frame.questIDLabel:SetAlpha(0.3)
        frame.questIDLabel:SetScript('OnLeave', function(self) GameTooltip_Hide() self:SetAlpha(0.3) end)
        frame.questIDLabel:SetScript('OnEnter', function(self)
            if self.questID then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                GameTooltip_AddQuest(self, self.questID)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName..e.Icon.left)
                e.tips:Show()
                self:SetAlpha(1)
            end
        end)
        frame.questIDLabel:SetScript('OnMouseDown', function(self)
            if self.questID then
                local info = C_QuestLog.GetQuestTagInfo(self.questID) or {}
                e.Show_WoWHead_URL(true, 'quest', self.questID, info.tagName)
                --[[StaticPopup_Show("WoWTools_Tooltips_LinkURL",
                'WoWHead',
                nil,
                format(wowheadText, 'quest', self.questID, info and info.tagName or '')
                )]]
            end
        end)
    end

    create_Quest_Label(QuestMapFrame.DetailsFrame)
    
    if C_AddOns.IsAddOnLoaded('WoWeuCN_Quests') then
        QuestMapFrame.DetailsFrame.questIDLabel:SetPoint('BOTTOMRIGHT',QuestMapFrame.DetailsFrame, 'TOPRIGHT', -2, 30)
    else
        QuestMapFrame.DetailsFrame.questIDLabel:SetPoint('BOTTOMRIGHT',QuestMapFrame.DetailsFrame, 'TOPRIGHT', -2, 10)
    end

    create_Quest_Label(QuestFrame)
    if C_AddOns.IsAddOnLoaded('WoWeuCN_Quests') then
        QuestFrame.questIDLabel:SetPoint('BOTTOMRIGHT',QuestMapFrame.DetailsFrame, 'TOPRIGHT', 25, 28)
    else
        QuestFrame.questIDLabel:SetPoint('TOPRIGHT', -30, -35)
    end

    hooksecurefunc('QuestMapFrame_ShowQuestDetails', function(questID)
        QuestMapFrame.DetailsFrame.questIDLabel:SetText(questID or '')
        QuestMapFrame.DetailsFrame.questIDLabel.questID= questID
    end)
    QuestFrame:HookScript('OnShow', function(self)
        local questID= QuestInfoFrame.questLog and  C_QuestLog.GetSelectedQuest() or GetQuestID()
        self.questIDLabel:SetText(questID or '')
        self.questIDLabel.questID= questID
    end)






    --任务日志 显示ID
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        local info= self.questLogIndex and C_QuestLog.GetInfo(self.questLogIndex)
        if not info or not info.questID or not HaveQuestData(info.questID) then
            return
        end

        func.Set_Quest(e.tips, info.questID, info)--任务

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

        e.tips:Show()
    end)







    --追踪栏
    hooksecurefunc('BonusObjectiveTracker_OnBlockEnter', function(block)
        if block.id and not block.module.tooltipBlock and block.TrackedQuest then
            e.tips:SetOwner(block, "ANCHOR_LEFT")
            e.tips:ClearLines()
            GameTooltip_AddQuest(block.TrackedQuest or block, block.id)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
        end
    end)

   for i= 1, NUM_OVERRIDE_BUTTONS do-- ActionButton.lua
        if _G['OverrideActionBarButton'..i] then
            hooksecurefunc(_G['OverrideActionBarButton'..i], 'SetTooltip', function(self)
                if self.action then
                    local actionType, ID, subType = GetActionInfo(self.action)
                    if actionType and ID then
                        if actionType=='spell' or actionType =="companion" then
                            func.Set_Spell(e.tips, ID)--法术
                            e.tips:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        elseif actionType=='item' and ID then
                            func.Set_Item(e.tips, nil, ID)
                            e.tips:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        else
                            e.tips:AddDoubleLine('action '..self.action, 'ID '..ID)
                            e.tips:AddDoubleLine(actionType and 'actionType '..actionType, subType and 'subType '..subType)
                        end
                        e.tips:Show()
                    end
                end
            end)
        end
    end

    --显示选项中的CVar
    --Blizzard_SettingControls.lua
    if Save.ShowOptionsCVarTips then
        --[[local function set_onenter(self)
            if self.onEnter or not self.variable then
                return
            end
            self:HookScript('OnEnter', function(frame)
                if not frame.variable then
                    return
                end
                local value, defaultValue, _, _, _, isSecure = C_CVar.GetCVarInfo(frame.variable)
                GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                GameTooltip_AddNormalLine(SettingsTooltip,
                    HIGHLIGHT_FONT_COLOR:WrapTextInColorCode('CVar|cff00ff00'..e.Icon.right..frame.variable..'|r')
                    ..(value and ' ('..(value or '')..'/'..(defaultValue or '')..')' or ''),
                    true)
                if isSecure then
                    GameTooltip_AddNormalLine(SettingsTooltip, '|cnRED_FONT_COLOR:isSecure: true|r', true)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, id.. ' '..addName)
                SettingsTooltip:Show()
            end)
            self:HookScript('OnMouseDown', function(frame, d)
                if d=='RightButton' and frame.variable then
                    e.Chat(frame.variable, nil, true)
                end
            end)
            self.onEnter=true
        end]]
        local function InitTooltip(name, tooltip, variable)
            GameTooltip_AddHighlightLine(SettingsTooltip, e.strText[name] or name)
            if tooltip then
                if type(tooltip) == "function" then
                    GameTooltip_AddNormalLine(SettingsTooltip, tooltip())
                else
                    GameTooltip_AddNormalLine(SettingsTooltip, e.strText[tooltip] or tooltip)
                end
            end
            if variable then
                local value, defaultValue, _, _, _, isSecure = C_CVar.GetCVarInfo(variable)
                GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                GameTooltip_AddNormalLine(SettingsTooltip,
                    HIGHLIGHT_FONT_COLOR:WrapTextInColorCode('CVar |cff00ff00'..variable..'|r')
                    ..(value and ' ('..(value or '')..'/'..(defaultValue or '')..')' or ''),
                    true)
                if isSecure then
                    GameTooltip_AddNormalLine(SettingsTooltip, '|cnRED_FONT_COLOR:isSecure: true|r', true)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, id..Initializer:GetName())
            end
        end
        local function CreateOptionsInitTooltip(setting, name, tooltip, options, variable)--Blizzard_SettingControls.lua
            local initTooltip= function()
                InitTooltip(name, tooltip, variable)
                local optionData = type(options) == 'function' and options() or options
                local default2 = setting:GetDefaultValue()
                local warningOption = nil
                local defaultOption = nil
                for _, option in ipairs(optionData or {}) do
                    local default = option.value == default2
                    if default then
                        defaultOption = option
                    end
                    if option.warning then
                        warningOption = option
                    end
                    if option.tooltip or option.disabled then
                        GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                        if option.label then
                            local optionLabel= e.strText[option.label] or option.label
                            if option.disabled then
                                optionLabel = DISABLED_FONT_COLOR:WrapTextInColorCode(optionLabel)
                            else
                                optionLabel = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(optionLabel)
                            end
                            local optionTooltip= option.tooltip
                            if optionTooltip then
                                optionTooltip= e.strText[optionTooltip] or optionTooltip
                                if option.disabled then
                                    optionTooltip = DISABLED_FONT_COLOR:WrapTextInColorCode(optionTooltip)
                                elseif default and option.recommend then
                                    optionTooltip = GREEN_FONT_COLOR:WrapTextInColorCode(optionTooltip)
                                else
                                    optionTooltip = NORMAL_FONT_COLOR:WrapTextInColorCode(optionTooltip)
                                end
                                GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s: %s", optionLabel, optionTooltip))
                            else
                                GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s:", optionLabel))
                            end
                        end
                        if option.disabled then
                            GameTooltip_AddErrorLine(SettingsTooltip, option.disabled)
                        end
                    end
                end
                if defaultOption and defaultOption.recommend and defaultOption.label then
                    GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                    local label= e.strText[defaultOption.label] or defaultOption.label
                    GameTooltip_AddHighlightLine(SettingsTooltip, string.format("%s: %s", e.onlyChinese and '推荐' or VIDEO_OPTIONS_RECOMMENDED, GREEN_FONT_COLOR:WrapTextInColorCode(label)))
                end

                if warningOption and warningOption.value == setting:GetValue() and warningOption.warning then
                    GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                    local warning= e.strText[warningOption.warning] or warningOption.warning
                    GameTooltip_AddNormalLine(SettingsTooltip, WARNING_FONT_COLOR:WrapTextInColorCode(warning))
                end

                if setting:HasCommitFlag(Settings.CommitFlag.ClientRestart) then
                    GameTooltip_AddBlankLineToTooltip(SettingsTooltip)
                    GameTooltip_AddErrorLine(SettingsTooltip, e.onlyChinese and '更改此选项需要重新启动客户端' or VIDEO_OPTIONS_NEED_CLIENTRESTART)
                end
            end
            return initTooltip
        end


        hooksecurefunc(SettingsCheckBoxControlMixin, 'Init', function(self, initializer)
            --[[self.CheckBox.variable= initializer.data.setting.variable
            set_onenter(self.CheckBox)]]
            local setting = initializer.data.setting
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsSliderControlMixin, 'Init', function(self, initializer)
            --[[self.SliderWithSteppers.Slider.variable= initializer.data.setting.variable
            set_onenter(self.SliderWithSteppers.Slider)]]
            local setting = initializer.data.setting
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)
            self.SliderWithSteppers.Slider:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsDropDownControlMixin, 'Init', function(self, initializer)
            --[[self.DropDown.Button.variable= initializer.data.setting.variable
            set_onenter(self.DropDown.Button)]]
            local setting = self:GetSetting()
            local options = initializer:GetOptions()
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)

            initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options, setting.variable))
            self.DropDown.Button:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsCheckBoxWithButtonControlMixin, 'Init', function(self, initializer)
            --[[self.CheckBox.variable= initializer.data.setting.variable
            set_onenter(self.CheckBox)]]
            local setting = initializer:GetSetting()
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
	        self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsCheckBoxSliderControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
            --[[self.CheckBox.variable= initializer.data.cbSetting.variable
            set_onenter(self.CheckBox)
            self.SliderWithSteppers.Slider.variable= initializer.data.sliderSetting.variable
            set_onenter(self.SliderWithSteppers.Slider)]]
            local cbSetting = initializer.data.cbSetting
            local cbLabel = initializer.data.cbLabel
            local cbTooltip = initializer.data.cbTooltip
            local sliderLabel = initializer.data.sliderLabel
            local sliderTooltip = initializer.data.sliderTooltip
            local cbInitTooltip = GenerateClosure(InitTooltip, cbLabel, cbTooltip, cbSetting.variable)
            self:SetTooltipFunc(cbInitTooltip)
            self.CheckBox:SetTooltipFunc(cbInitTooltip)
            self.SliderWithSteppers.Slider:SetTooltipFunc(GenerateClosure(InitTooltip, sliderLabel, sliderTooltip, cbSetting.variable))
        end)
        hooksecurefunc(SettingsCheckBoxDropDownControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
            --[[self.CheckBox.variable= initializer.data.cbSetting.variable
            set_onenter(self.CheckBox)
            self.DropDown.Button.variable= initializer.data.dropDownSetting.variable
            set_onenter(self.DropDown.Button)]]
            local cbSetting = initializer.data.cbSetting
            local cbLabel = initializer.data.cbLabel
            local cbTooltip = initializer.data.cbTooltip
            local initTooltip= GenerateClosure(InitTooltip, cbLabel, cbTooltip, cbSetting.variable)
	        self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)

            local setting = initializer.data.dropDownSetting
            local options = initializer.data.dropDownOptions
            initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options, setting.variable))
            self.DropDown.Button:SetTooltipFunc(initTooltip)
        end)

        hooksecurefunc(KeyBindingFrameBindingTemplateMixin, 'Init', function(self, initializer)--Blizzard_Keybindings.lua
            local bindingIndex = initializer.data.bindingIndex
            local action, category = GetBinding(bindingIndex)
            local bindingName = GetBindingName(action)
            bindingName= e.strText[bindingName] or bindingName
            local function InitializeKeyBindingButtonTooltip(index)
                local key = select(index, GetBindingKey(action))
                if key then
                    Settings.InitTooltip(format(KEY_BINDING_NAME_AND_KEY, bindingName, GetBindingText(key)), e.onlyChinese and '<右键解除键位>' or KEY_BINDING_TOOLTIP)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, 'bindingIndex |cnGREEN_FONT_COLOR:'..bindingIndex..'|r', true)
                GameTooltip_AddNormalLine(SettingsTooltip, 'action |cnGREEN_FONT_COLOR:'..action..'|r', true)
                if category then
                    GameTooltip_AddNormalLine(SettingsTooltip, category, true)
                end
                GameTooltip_AddNormalLine(SettingsTooltip, id..' '..Initializer:GetName(), true)
            end

            for index, button in ipairs(self.Buttons) do
                button:SetTooltipFunc(GenerateClosure(InitializeKeyBindingButtonTooltip, index))
            end
        end)
    end

    --添加 WidgetSetID
    hooksecurefunc('GameTooltip_AddWidgetSet', function(self, uiWidgetSetID)
        if uiWidgetSetID then
            self:AddLine(format('WidgetSetID %d', uiWidgetSetID))
            self:Show()
        end
    end)
end








































--##############
 --添加新控制面板
--##############
local function set_Cursor_Tips(self)
    func.Set_Init_Item(e.tips, true)
    func.Set_Init_Item(ItemRefTooltip, true)
    func.Set_PlayerModel(e.tips)
    func.Set_PlayerModel(ItemRefTooltip)
    GameTooltip_SetDefaultAnchor(e.tips, self or UIParent)
    e.tips:ClearLines()
    e.tips:SetUnit('player')
    e.tips:Show()
end

local function Init_Panel()
    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    local initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '跟随鼠标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FOLLOW, MOUSE_LABEL),
        tooltip= Initializer:GetName(),
        value= Save.setDefaultAnchor,
        category= Initializer,
        func= function()
            Save.setDefaultAnchor= not Save.setDefaultAnchor and true or nil
            if Save.setDefaultAnchor then
                Save.setAnchor=nil
            end
            set_Cursor_Tips()
        end
    })

        local initializer= e.AddPanelSider({
            name= 'X',
            value= Save.cursorX or 0,
            minValue= -240,
            maxValue= 240,
            setp= 1,
            tooltip= Initializer:GetName(),
            category= Initializer,
            func= function(_, _, value2)
                local value3= e.GetFormatter1to10(value2, -200, 200)
                Save.cursorX= value3
                set_Cursor_Tips()
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.setDefaultAnchor then return true else return false end end)

        initializer= e.AddPanelSider({
            name= 'Y',
            value= Save.cursorY or 0,
            minValue= -240,
            maxValue= 240,
            setp= 1,
            tooltip= Initializer:GetName(),
            category= Initializer,
            func= function(_, _, value2)
                local value3= e.GetFormatter1to10(value2, -200, 200)
                Save.cursorY= value3
                set_Cursor_Tips()
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.setDefaultAnchor then return true else return false end end)

        initializer= e.AddPanel_Check({
            name= e.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
            tooltip= Initializer:GetName(),
            value= Save.cursorRight,
            category= Initializer,
            func= function()
                Save.cursorRight= not Save.cursorRight and true or nil
                set_Cursor_Tips()
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.setDefaultAnchor then return true else return false end end)

        initializer= e.AddPanel_Check({
            name= e.onlyChinese and '战斗中：默认' or (HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DEFAULT),
            tooltip= Initializer:GetName(),
            value= Save.inCombatDefaultAnchor,
            category= Initializer,
            func= function()
                Save.inCombatDefaultAnchor= not Save.inCombatDefaultAnchor and true or nil
                set_Cursor_Tips()
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.setDefaultAnchor then return true else return false end end)


    e.AddPanel_Header(Layout, e.onlyChinese and '设置' or SETTINGS)

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '模型' or MODEL,
        tooltip= Initializer:GetName(),
        value= not Save.hideModel,
        category= Initializer,
        func= function()
            Save.hideModel= not Save.hideModel and true or nil
            set_Cursor_Tips()
        end
    })

    initializer= e.AddPanel_Check({
        name= e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
        tooltip= Initializer:GetName(),
        value= Save.modelLeft,
        category= Initializer,
        func= function()
            Save.modelLeft= not Save.modelLeft and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    initializer= e.AddPanel_Check({
        name= (e.onlyChinese and '模型' or MODEL)..' ID',
        tooltip= Initializer:GetName(),
        value= Save.showModelFileID,
        category= Initializer,
        func= function()
            Save.showModelFileID= not Save.showModelFileID and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= e.Player.L.size,
        value= Save.modelSize or 100,
        minValue= 40,
        maxValue= 300,
        setp= 1,
        tooltip= Initializer:GetName(),
        category= Initializer,
        func= function(_, _, value2)
            local value3= e.GetFormatter1to10(value2, 40, 300)
            Save.modelSize= value3
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= 'X',
        value= Save.modelX or 0,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= Initializer:GetName(),
        category= Initializer,
        func= function(_, _, value2)
            local value3= e.GetFormatter1to10(value2, -200, 200)
            Save.modelX= value3
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= 'Y',
        value= Save.modelY or -24,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= Initializer:GetName(),
        category= Initializer,
        func= function(_, _, value2)
            local value3= e.GetFormatter1to10(value2, -200, 200)
            Save.modelY= value3
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION,
        value= Save.modelFacing or -24,
        minValue= -1,
        maxValue= 1,
        setp= 0.1,
        tooltip= Initializer:GetName(),
        category= Initializer,
        func= function(_, _, value2)
            local value3= e.GetFormatter1to10(value2, -1, 1)
            Save.modelFacing= value3
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    e.AddPanel_Check({
        name= e.onlyChinese and 'NPC职业颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'NPC', CLASS_COLORS),
        tooltip= Initializer:GetName(),
        value= not Save.disabledNPCcolor,
        category= Initializer,
        func= function()
            Save.disabledNPCcolor= not Save.disabledNPCcolor and true or nil
        end
    })

    e.AddPanel_Check({
        name= e.onlyChinese and '生命值' or HEALTH,
        tooltip= Initializer:GetName(),
        value= not Save.hideHealth,
        category= Initializer,
        func= function()
            Save.hideHealth= not Save.hideHealth and true or nil
            print(id, Initializer:GetName(),  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
    e.AddPanel_Check({
        name= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'Ctrl+Shift', e.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        tooltip= 'wowhead.com|nraider.io',
        value= Save.ctrl,
        category= Initializer,
        func= function()
            Save.ctrl= not Save.ctrl and true or nil
            set_Cursor_Tips()
        end
    })


    e.AddPanel_Header(Layout, 'CVar')

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '自动设置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SETTINGS),
        tooltip= function() return set_CVar(nil, true, true) end,
        value= Save.setCVar,
        category= Initializer,
        func= function()
            Save.setCVar= not Save.setCVar and true or nil
            Save.graphicsViewDistance=nil
        end
    })

    initializer= e.AddPanel_Button({
        buttonText= e.onlyChinese and '设置' or SETTINGS,
        layout= Layout,
        func= function()
            set_CVar()
            print(e.onlyChinese and '设置完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COMPLETE))
        end
    })
    initializer:SetParentInitializer(initializer2)

    initializer= e.AddPanel_Button({
        buttonText= e.onlyChinese and '默认' or DEFAULT,
        layout= Layout,
        func= function()
            set_CVar(true, nil, nil)
            print(e.onlyChinese and '默认完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEFAULT, COMPLETE))
        end
    })
    initializer:SetParentInitializer(initializer2)

    e.AddPanel_DropDown({
        SetValueFunc= function(_, _, value)
            if value==1 then
                C_CVar.SetCVar("ActionButtonUseKeyDown", '1')
            else
                C_CVar.SetCVar("ActionButtonUseKeyDown", '0')
            end
        end,
        GetOptionsFunc= function()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, e.onlyChinese and '是' or YES)
            container:Add(2, e.onlyChinese and '不' or NO)
            return container:GetData()
        end,
        value=C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 1 or 2,
        name= e.onlyChinese and '按下快捷键时施法' or ACTION_BUTTON_USE_KEY_DOWN,
        tooltip= function()
            return e.Get_CVar_Tooltips({
                    name='ActionButtonUseKeyDown',
                    msg=e.onlyChinese and '在按下快捷键时施法，而不是在松开快捷键时施法。' or OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
                }) end,
        category=Initializer
    })

    initializer2= e.AddPanel_Check({
        name= (e.onlyChinese and '提示选项CVar名称' or 'Show Option CVar Name'),
        tooltip= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '友情提示: 可能会出现错误' or ('note: '..ENABLE_ERROR_SPEECH)..'|r'),
        value= Save.ShowOptionsCVarTips,
        category= Initializer,
        func= function()
            Save.ShowOptionsCVarTips= not Save.ShowOptionsCVarTips and true or nil
            print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.ShowOptionsCVarTips), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
end
--[[
    --监视， WidgetSetID
    local widgetLabel= e.Cstr(panel)
    widgetLabel:SetPoint('TOPLEFT', ctrlCopy, 'BOTTOMLEFT',0, -8)
    widgetLabel:SetText('WidgetSetID')
    widgetLabel:EnableMouse(true)
    widgetLabel:SetScript('OnLeave', function(self2) self2:SetAlpha(1) e.tips:Hide() end)
    widgetLabel:SetScript('OnEnter', function(self2)
        set_Cursor_Tips(self2)
        self2:SetAlpha(0.3)
    end)
    local widgetEdit= CreateFrame("EditBox", nil, panel, 'InputBoxTemplate')
	widgetEdit:SetPoint('LEFT', widgetLabel, 'RIGHT',6,0)
	widgetEdit:SetSize(100,20)
    widgetEdit:SetAutoFocus(false)
    widgetEdit:SetNumeric(true)
    widgetEdit:SetNumber(Save.WidgetSetID)
    widgetEdit:SetCursorPosition(0)
    widgetEdit:ClearFocus()
    widgetEdit:SetJustifyH('CENTER')
    widgetEdit:SetScript('OnEscapePressed', function(self2) self2:ClearFocus() end)
    widgetEdit:SetScript('OnLeave', GameTooltip_Hide)
	widgetEdit:SetScript('OnEnterPressed', function(self2)
        local num= math.modf(self2:GetNumber())
        if num>=0 then
            Save.WidgetSetID= num
            self2:ClearFocus()
            set_Cursor_Tips(self2)
            print(id, Category:GetName(), 'PlayerFrame WidgetSetID',
                num==0 and e.GetEnabeleDisable(false) or num,
                '|n|cnRED_FONT_COLOR:',
                e.onlyChinese and '备注：如果出现错误，请关闭此功能（0）' or 'note: If you get error, please disable this (0)'
            )
        end
	end)
    widgetLabel= e.Cstr(panel)
    widgetLabel:SetPoint('LEFT', widgetEdit, 'RIGHT',4, 0)
    widgetLabel:SetText('0 '..(e.onlyChinese and '取消' or CANCEL))
end

]]
















local function Init_Event(arg1)
    --if arg1=='Blizzard_PerksProgram' then--Blizzard_PerksProgramProducts.lua
--PerksProgramFrame.PerksProgramTooltip

    if arg1=='Blizzard_AchievementUI' then--成就ID
        hooksecurefunc(AchievementTemplateMixin, 'Init', function(frame)
            if frame.Shield and frame.id then
                if not frame.AchievementIDLabel  then
                    frame.AchievementIDLabel= e.Cstr(frame.Shield)
                    frame.AchievementIDLabel:SetPoint('TOP', frame.Shield.Icon)
                    frame.Shield:SetScript('OnEnter', function(self)
                        local achievementID= self:GetParent().id
                        if achievementID then
                            e.tips:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
                            e.tips:ClearLines()
                            e.tips:SetAchievementByID(achievementID)
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine('|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '说' or SAY), e.Icon.left)
                            e.tips:AddDoubleLine(id, Initializer:GetName())
                            e.tips:Show()
                        end
                        self:SetAlpha(0.5)
                    end)
                    frame.Shield:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip_Hide() end)
                    frame.Shield:SetScript('OnMouseUp', function(self) self:SetAlpha(0.5) end)
                    frame.Shield:SetScript('OnMouseDown', function(self) self:SetAlpha(0.3) end)
                    frame.Shield:SetScript('OnClick', function(self)
                        local achievementID= self:GetParent().id
                        local achievementLink = achievementID and GetAchievementLink(achievementID)
                        if achievementLink then
                            e.Chat(achievementLink)
                        end
                    end)
                    frame.Shield:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
                end
            end
            if frame.AchievementIDLabel then
                local text= frame.id
                local flags= frame.id and select(9, GetAchievementInfo(frame.id))
                if flags==0x20000 then
                    text= e.Icon.net2..'|cff00ccff'..frame.id..'|r'
                end
                frame.AchievementIDLabel:SetText(text or '')
            end
        end)
        hooksecurefunc('AchievementFrameComparison_UpdateDataProvider', function()--比较成就, Blizzard_AchievementUI.lua
            local frame= AchievementFrameComparison.AchievementContainer.ScrollBox
            if not frame:GetView() then
                return
            end
            for _, button in pairs(frame:GetFrames()) do
                if not button.OnEnter then
                    button:SetScript('OnLeave', GameTooltip_Hide)
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
                        button.Player.idText:SetText(e.Icon.net2..'|cffff00ff'..button.id..'|r')
                    else
                        button.Player.idText:SetText(button.id or '')
                    end
                end
            end
        end)
        hooksecurefunc('AchievementFrameComparison_SetUnit', function(unit)--比较成就
            local text= e.GetPlayerInfo({unit=unit, reName=true, reRealm=true})--玩家信息图标
            if text~='' then
                AchievementFrameComparisonHeaderName:SetText(text)
            end
        end)
        if AchievementFrameComparisonHeaderPortrait then
            AchievementFrameComparisonHeader:EnableMouse(true)
            AchievementFrameComparisonHeader:HookScript('OnLeave', GameTooltip_Hide)
            AchievementFrameComparisonHeader:HookScript('OnEnter', function()
                if AchievementFrameComparisonHeaderPortrait.unit then
                    e.tips:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                    e.tips:ClearLines()
                    e.tips:SetUnit(AchievementFrameComparisonHeaderPortrait.unit)
                    e.tips:Show()
                end
            end)
        end

    elseif arg1=='Blizzard_Collections' then--宠物手册， 召唤随机，偏好宠物，技能ID    
        hooksecurefunc('PetJournalSummonRandomFavoritePetButton_OnEnter', function()--PetJournalSummonRandomFavoritePetButton
            func.Set_Spell(e.tips, 243819)
            e.tips:Show()
        end)

    elseif arg1=='Blizzard_ChallengesUI' then--挑战, AffixID
        hooksecurefunc(ChallengesKeystoneFrameAffixMixin, 'OnEnter',function(self)
            if self.affixID then
                local name, description, filedataid = C_ChallengeMode.GetAffixInfo(self.affixID)
                if (self.affixID or self.info) then
                    if (self.info) then
                        local tbl = CHALLENGE_MODE_EXTRA_AFFIX_INFO[self.info.key]
                        name = tbl.name
                        description = string.format(tbl.desc, self.info.pct)
                    else
                        name= e.cn(name)
                        description= e.cn(description)
                    end
                    GameTooltip:SetText(name, 1, 1, 1, 1, true)
                    GameTooltip:AddLine(description, nil, nil, nil, true)
                end
                GameTooltip:AddDoubleLine('affixID '..self.affixID, filedataid and '|T'..filedataid..':0|t'..filedataid or ' ')
                func.Set_Web_Link({frame=GameTooltip, type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
                GameTooltip:Show()
            end
        end)

    elseif arg1=='Blizzard_OrderHallUI' then--要塞，技能树
        hooksecurefunc(GarrisonTalentButtonMixin, 'OnEnter', function(self2)--Blizzard_OrderHallTalents.lua
            local info=self2.talent--C_Garrison.GetTalentInfo(self.talent.id)
            if not info or not info.id then
                return
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('talentID '..info.id, info.icon and '|T'..info.icon..':0|t'..info.icon)
            if info.ability and info.ability.id and info.ability.id>0 then
                e.tips:AddDoubleLine('ability '..info.ability.id, info.ability.icon and '|T'..info.ability.icon..':0|t'..info.ability.icon)
            end
            e.tips:Show()
        end)
        hooksecurefunc(GarrisonTalentButtonMixin, 'SetTalent', function(self2)--是否已激活, 和等级
            local info= self2.talent
            if not info or not info.id then
                return
            end

            if info.researched and not self2.researchedTexture then
                self2.researchedTexture= self2:CreateTexture(nil, 'OVERLAY')
                local w,h= self2:GetSize()
                self2.researchedTexture:SetSize(w/3, h/3)
                self2.researchedTexture:SetPoint('BOTTOMRIGHT')
                self2.researchedTexture:SetAtlas(e.Icon.select)
            end
            if self2.researchedTexture then
                self2.researchedTexture:SetShown(info.researched)
            end

            local rank
            if info.talentMaxRank and info.talentMaxRank>1 and info.talentRank~= info.talentMaxRank then
                if not info.rankText then
                    info.rankText= e.Cstr(self2)
                    info.rankText:SetPoint('BOTTOMLEFT')
                end
                rank= '|cnGREEN_FONT_COLOR:'..(info.talentRank or 0)..'|r/'..info.talentMaxRank
            end
            if info.rankText then
                info.rankText:SetText(rank or '')
            end
        end)

    elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
        hooksecurefunc(FlightMap_FlightPointPinMixin, 'OnMouseEnter', function(self2)
            local info= self2.taxiNodeData
            if info then
                e.tips:AddDoubleLine('nodeID '..(info.nodeID or ''), 'slotIndex '..(info.slotIndex or ''))
                e.tips:Show()
            end
        end)

    elseif arg1=='Blizzard_Professions' then--专业
        hooksecurefunc(Professions, 'SetupProfessionsCurrencyTooltip', function(currencyInfo)--lizzard_Professions.lua
            if currencyInfo then
                local nodeID = ProfessionsFrame.SpecPage:GetDetailedPanelNodeID()
                local currencyTypesID = Professions.GetCurrencyTypesID(nodeID)
                if currencyTypesID then
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    func.Set_Currency(GameTooltip, currencyTypesID)--货币
                    GameTooltip:AddDoubleLine('nodeID', '|cffffffff'..nodeID..'|r')
                end
            end
        end)

    elseif arg1=='Blizzard_ClassTalentUI' then--天赋
        hooksecurefunc(ClassTalentFrame.SpecTab, 'UpdateSpecFrame', function(self)--ClassTalentSpecTabMixin
            if not C_SpecializationInfo.IsInitialized() then
                return
            end
            for frame in self.SpecContentFramePool:EnumerateActive() do
                if not frame.specIDLabel then
                    frame.specIcon= frame:CreateTexture(nil, 'BORDER')
                    frame.specIcon:SetPoint('TOP', frame.RoleIcon, 'BOTTOM', -2, -4)
                    frame.specIcon:SetSize(22,22)

                    frame.specIconBorder= frame:CreateTexture(nil, 'ARTWORK')
                    frame.specIconBorder:SetPoint('CENTER', frame.specIcon,1.2,-1.2)
                    frame.specIconBorder:SetAtlas('bag-border')
                    frame.specIconBorder:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
                    frame.specIconBorder:SetSize(32,32)

                    frame.specIDLabel= e.Cstr(frame, {mouse=true, size=18, copyFont=frame.RoleName})
                    frame.specIDLabel:SetPoint('LEFT', frame.specIcon, 'RIGHT', 12, 0)
                    frame.specIDLabel:SetScript('OnLeave', function(s) s:SetAlpha(1) GameTooltip_Hide() end)
                    frame.specIDLabel:SetScript('OnEnter', function(s)
                        e.tips:SetOwner(s, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddDoubleLine(id, Initializer:GetName())
                        local specIndex= s:GetParent().specIndex
                        if specIndex then
                            local specID, name, _, icon= GetSpecializationInfo(specIndex)
                            if specID then
                                e.tips:AddLine(' ')
                                e.tips:AddDoubleLine(name, e.strText[name])
                                e.tips:AddDoubleLine((e.onlyChinese and '专精' or SPECIALIZATION)..' ID', specID)
                                e.tips:AddDoubleLine((e.onlyChinese and '专精' or SPECIALIZATION)..' Index', specIndex)
                                if icon then
                                    e.tips:AddDoubleLine(icon and '|T'..icon..':0|t'..icon)
                                end
                            end
                        end
                        e.tips:Show()
                        s:SetAlpha(0.5)
                    end)
                end
                local specID, icon, _
                if frame.specIndex then
                    specID, _, _, icon= GetSpecializationInfo(frame.specIndex)
                end
                frame.specIDLabel:SetText(specID or '')
                frame.specIcon:SetTexture(icon or 0)
            end
        end)

    elseif arg1=='Blizzard_PlayerChoice' then
        hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', function(self)
            if self.optionInfo and self.optionInfo.spellID then
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(self.optionInfo.spellID)
                GameTooltip:Show()
            end
        end)

    elseif arg1=='Blizzard_GenericTraitUI' then
        GenericTraitFrame.Currency:HookScript('OnEnter', function(self)
            local currencyInfo = self:GetParent().treeCurrencyInfo and self:GetParent().treeCurrencyInfo[1] or {}
            if not currencyInfo.traitCurrencyID or currencyInfo.traitCurrencyID<=0 then
                return
            end
            local overrideIcon = select(4, C_Traits.GetTraitCurrencyInfo(currencyInfo.traitCurrencyID))
            e.tips:AddDoubleLine(format('traitCurrencyID: %d', currencyInfo.traitCurrencyID), format('|T%d:0|t%d', overrideIcon or 0, overrideIcon or 0))
            e.tips:Show()
        end)
    end


end












--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('PLAYER_LEAVING_WORLD')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
local eventTab={}
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave['Tootips'] then
                Save= WoWToolsSave['Tootips']
                WoWToolsSave['Tootips']=nil
            else
                Save= WoWToolsSave[addName] or Save
            end
            Save.modelSize= Save.modelSize or 100
            Save.modelX= Save.modelX or 0
            Save.modelY= Save.modelY or -24
            Save.modelFacing= Save.modelFacing or -0.5

            --Save.WidgetSetID = Save.WidgetSetID or 0
            e.AddPanel_Check({
                name= e.onlyChinese and '启用' or ENABLE,
                tooltip= Initializer:GetName(),
                value= not Save.disabled,
                category= Initializer,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            Init_StaticPopupDialogs()--全局

            if Save.disabled then
                self:UnregisterAllEvents()
                eventTab=nil
                func={}
            else
                Init()--初始
                do
                    for _, evt in pairs(eventTab or {}) do
                        Init_Event(evt)
                    end
                end
                eventTab=nil
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()

        else
            if eventTab then
                table.insert(eventTab, arg1)
            else
                Init_Event(arg1)
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_LEAVING_WORLD' then
        if Save.setCVar then
            if not UnitAffectingCombat('player') then
                Save.graphicsViewDistance= C_CVar.GetCVar('graphicsViewDistance')
                SetCVar("graphicsViewDistance", 0)
            else
                Save.graphicsViewDistance=nil
            end
        end

    elseif event=='PLAYER_ENTERING_WORLD' then--https://wago.io/ZtSxpza28
        if Save.setCVar and Save.graphicsViewDistance and not UnitAffectingCombat('player') then
            C_CVar.SetCVar('graphicsViewDistance', Save.graphicsViewDistance)
            Save.graphicsViewDistance=nil
        end
    end
end)