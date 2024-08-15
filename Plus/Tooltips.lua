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
    modelY= -15,
    modelFacing= -0.3,--方向
    showModelFileID=e.Player.husandro,--显示，文件ID
    --WidgetSetID=848,--自定义，监视 WidgetSetID
    --disabledNPCcolor=true,--禁用NPC颜色
    --hideHealth=true,----生命条提示
}

local Initializer, Layout= e.AddPanel_Sub_Category({name=e.Icon.mid..addName})

--全局
--e.Show_WoWHead_URL(isWoWHead, typeOrRegion, typeIDOrRealm, name)

local func={}
--[[
func:Set_PlayerModel(self)
func:Set_Width(tooltip)--设置，宽度
func:Set_Spell(self, spellID)法术
func:Set_Mount(self, mountID)坐骑
func:Set_Pet(self, speciesID, setSearchText)宠物
func:Set_Item(self, itemLink, itemID)物品信息
func:Set_Currency(self, currencyID)货币
func:Set_Achievement(self, achievementID)成就
func:Set_Quest(self, questID, info)任务
func:Set_Faction(self, factionID)
func:Set_Flyout(self, flyoutID)法术, 弹出框

func:Set_Init_Item(self, hide)创建，设置，内容
func:Set_Item_Model(self, tab)设置, 3D模型{unit=, guid=, creatureDisplayID=, animID=, appearanceID=, visualID=}
func:Set_All_Aura(self, data)Aura
func:Set_Buff(type, self, ...)
func:Set_Unit(self, unit)设置单位提示信息
func:Set_Unit_Player(tooltip, name, unit, guid)
func:Set_Unit_NPC(tooltip, name, unit, guid)

]]





function func:GetItemInfoFromHyperlink(link)--LinkUtil.lua  GetItemInfoFromHyperlink()不能正解，读取 |Hkeystone:
	local itemID = link and link:match("|H.-:(%d+).-|h")
	if itemID then
		return tonumber(itemID)
	end
end



function func:Set_PlayerModel(tooltip)
    if not tooltip.playerModel then
        tooltip.playerModel= CreateFrame("PlayerModel", nil, tooltip)--DressUpModel PlayerModel        
        --[[
        tooltip.playerModel:SetFrameLevel(tooltip:GetFrameLevel()-1)
        tooltip.itemModel= CreateFrame("DressUpModel", nil, tooltip)--DressUpModel PlayerModel
        tooltip.itemModel:SetPoint('TOP', tooltip, 'BOTTOM')
        tooltip.itemModel:SetUnit('player')
        tooltip.itemModel:SetSize(Save.modelSize, Save.modelSize)
        tooltip.itemModel:SetModelScale(2)
        tooltip.itemModel:SetFacing(Save.modelFacing)
        ]]
    else
        tooltip.playerModel:ClearAllPoints()
    end
    if Save.modelLeft then
        tooltip.playerModel:SetPoint("RIGHT", tooltip, 'LEFT', Save.modelX, Save.modelY)
    else
        tooltip.playerModel:SetPoint("BOTTOM", tooltip, 'TOP', Save.modelX, Save.modelY)
    end
    tooltip.playerModel:SetSize(Save.modelSize, Save.modelSize)
    tooltip.playerModel:SetFacing(Save.modelFacing)
end

function func:Set_Init_Item(tooltip, hide)--创建，设置，内容
    if not tooltip then
        return
    end
    if not tooltip.textLeft then--左上角字符
        tooltip.textLeft=e.Cstr(tooltip, {size=16})
        tooltip.textLeft:SetPoint('BOTTOMLEFT', tooltip, 'TOPLEFT')

        tooltip.text2Left=e.Cstr(tooltip, {size=16})--左上角字符2
        tooltip.text2Left:SetPoint('LEFT', tooltip.textLeft, 'RIGHT', 5, 0)

        tooltip.textRight=e.Cstr(tooltip, {size=12, justifyH='RIGHT'})--右上角字符
        tooltip.textRight:SetPoint('BOTTOMRIGHT', tooltip, 'TOPRIGHT')

        tooltip.text2Right= e.Cstr(tooltip, {size=12, justifyH='RIGHT'})--右上角字符2
        tooltip.text2Right:SetPoint('BOTTOMRIGHT', tooltip.textRight, 'TOPRIGHT', 0, 4)

        tooltip.backgroundColor= tooltip:CreateTexture(nil, 'BACKGROUND',nil, 1)--背景颜色
        tooltip.backgroundColor:SetPoint('TOPLEFT')
        tooltip.backgroundColor:SetPoint('BOTTOMRIGHT')
        --tooltip.backgroundColor:SetAllPoints(tooltip)

        if not tooltip.Portrait then
            tooltip.Portrait= tooltip:CreateTexture(nil, 'BACKGROUND',nil, 2)--右上角图标
            tooltip.Portrait:SetPoint('TOPRIGHT',-2, -3)
            tooltip.Portrait:SetSize(40,40)
        end
        tooltip:HookScript("OnHide", function(frame)--隐藏
            func:Set_Init_Item(frame, true)
        end)
    end
    if not tooltip.playerModel and not Save.hideModel then
        func:Set_PlayerModel(tooltip)
        tooltip.playerModel:SetShown(false)
    end
    if hide and tooltip.textLeft then
        tooltip.textLeft:SetText('')
        tooltip.text2Left:SetText('')
        tooltip.textRight:SetText('')
        tooltip.text2Right:SetText('')

        tooltip.textLeft:SetTextColor(1, 0.82, 0)
        tooltip.text2Left:SetTextColor(1, 0.82, 0)
        tooltip.textRight:SetTextColor(1, 0.82, 0)
        tooltip.text2Right:SetTextColor(1, 0.82, 0)

        tooltip.Portrait:SetShown(false)
        tooltip.backgroundColor:SetShown(false)
        if tooltip.playerModel then
            tooltip.playerModel:ClearModel()
            tooltip.playerModel:SetShown(false)
            tooltip.playerModel.id=nil
        end
        if tooltip.WoWHeadButton then
            tooltip.WoWHeadButton:rest()
        end
    end
end



--###########
--设置, 3D模型
--###########
function func:Set_Item_Model(tooltip, tab)--func:Set_Item_Model(tooltip, {unit=, guid=, creatureDisplayID=, animID=, appearanceID=, visualID=})--设置, 3D模型
    if Save.hideModel or not tooltip.playerModel then
        return
    end
    if tab.unit then
        if tooltip.playerModel.id~=tab.guid then--and tooltip.playerModel:CanSetUnit(tab.unit) then
            tooltip.playerModel:SetUnit(tab.unit)
            tooltip.playerModel.guid=tab.guid
            tooltip.playerModel.id=tab.guid
            tooltip.playerModel:SetShown(true)

        end
    elseif tab.creatureDisplayID  then
        if tooltip.playerModel.id~= tab.creatureDisplayID then
            tooltip.playerModel:SetDisplayInfo(tab.creatureDisplayID)
            if tab.animID then
                tooltip.playerModel:SetAnimation(tab.animID)
            end
            tooltip.playerModel.id=tab.creatureDisplayID
            tooltip.playerModel:SetShown(true)
        end
    elseif tab.itemID then
        if tooltip.playerModel.id~=tab.itemID then
            if  tab.appearanceID and tab.visualID then
                tooltip.playerModel:SetItemAppearance(tab.visualID, tab.appearanceID)
            else
                tooltip.playerModel:SetItem(tab.itemID, tab.appearanceID, tab.visualID)
            end
            tooltip.playerModel.id= tab.itemID
            tooltip.playerModel:SetShown(true)
        end
    end
end
















--设置，宽度
function func:Set_Width(tooltip)
    local w= tooltip:GetWidth()
    local w2= tooltip.textLeft:GetStringWidth()+ tooltip.text2Left:GetStringWidth()+ tooltip.textRight:GetStringWidth()
    if w<w2 then
        tooltip:SetMinimumWidth(w2)
    end
end















--################
--取得网页，数据链接
--################
local WoWHead
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
    if e.onlyChinese or LOCALE_zhTW then
        WoWHead= 'https://www.wowhead.com/cn/'
        if not LOCALE_zhCN then
            wowheadText= 'https://www.wowhead.com/cn/%s=%d'
        else
            wowheadText= 'https://www.wowhead.com/cn/%s=%d/%s'
        end
        raiderioText= 'https://raider.io/cn/characters/%s/%s/%s'
    --[[if LOCALE_zhCN or LOCALE_zhTW or e.onlyChinese then--https://www.wowhead.com/cn/pet-ability=509/汹涌
        wowheadText= 'https://www.wowhead.com/cn/%s=%d/%s'
        raiderioText= 'https://raider.io/cn/characters/%s/%s/%s']]
    elseif LOCALE_deDE then
        WoWHead= 'https://www.wowhead.com/de/'
        wowheadText= 'https://www.wowhead.com/de/%s=%d/%s'
        raiderioText= 'https://raider.io/de/characters/%s/%s/%s'
    elseif LOCALE_esES or LOCALE_esMX then
        WoWHead= 'https://www.wowhead.com/es/'
        wowheadText= 'https://www.wowhead.com/es/%s=%d/%s'
        raiderioText= 'https://raider.io/es/characters/%s/%s/%s'
    elseif LOCALE_frFR then
        WoWHead= 'https://www.wowhead.com/fr/'
        wowheadText= 'https://www.wowhead.com/fr/%s=%d/%s'
        raiderioText= 'https://raider.io/fr/characters/%s/%s/%s'
    elseif LOCALE_itIT then
        WoWHead= 'https://www.wowhead.com/it/'
        wowheadText= 'https://www.wowhead.com/it/%s=%d/%s'
        raiderioText= 'https://raider.io/it/characters/%s/%s/%s'
    elseif LOCALE_ptBR then
        WoWHead= 'https://www.wowhead.com/pt/'
        wowheadText= 'https://www.wowhead.com/pt/%s=%d/%s'
        raiderioText= 'https://raider.io/br/characters/%s/%s/%s'
    elseif LOCALE_ruRU then
        WoWHead= 'https://www.wowhead.com/ru/'
        wowheadText= 'https://www.wowhead.com/ru/%s=%d/%s'
        raiderioText= 'https://raider.io/ru/characters/%s/%s/%s'
    elseif LOCALE_koKR then
        WoWHead= 'https://www.wowhead.com/ko/'
        wowheadText= 'https://www.wowhead.com/ko/%s=%d/%s'
        raiderioText= 'https://raider.io/kr/characters/%s/%s/%s'
    else
        WoWHead= 'https://www.wowhead.com/'
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


function func:Set_Web_Link(tooltip, tab)
    if tooltip==ItemRefTooltip or tooltip==FloatingBattlePetTooltip then
        if tab.type and tab.id then
            if not tooltip.WoWHeadButton then
                tooltip.WoWHeadButton=e.Cbtn(tooltip, {size={20,20}, type=false})--取得网页，数据链接
                tooltip.WoWHeadButton:SetPoint('RIGHT',tooltip.CloseButton, 'LEFT',0,2)
                tooltip.WoWHeadButton:SetNormalAtlas('questlegendary')
                tooltip.WoWHeadButton:SetScript('OnClick', function(f)
                    if f.type and f.id then
                        e.Show_WoWHead_URL(true, f.type, f.id, f.name)
                    end
                end)
                function tooltip.WoWHeadButton:rest()
                    self.type=nil
                    self.id=nil
                    self.name=nil
                    self:SetShown(false)
                end
            end
            tooltip.WoWHeadButton.type= tab.type
            tooltip.WoWHeadButton.id= tab.id
            tooltip.WoWHeadButton.name= tab.name
            tooltip.WoWHeadButton:SetShown(true)
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
        if IsControlKeyDown() and IsShiftKeyDown() then
            e.Show_WoWHead_URL(true, tab.type, tab.id, tab.name)
        else
            if tab.isPetUI then
                if tooltip then
                    BattlePetTooltipTemplate_AddTextLine(tooltip, 'wowhead  Ctrl+Shift')
                end
            elseif tooltip== e.tips then
                tooltip:AddDoubleLine((tab.col or '')..'WoWHead', (tab.col or '')..'Ctrl+Shift')
            end
        end

    elseif tab.unitName then
        if IsControlKeyDown() and IsShiftKeyDown() then
            e.Show_WoWHead_URL(false, nil, tab.realm or e.Player.realm, tab.unitName)
        else
            if tooltip then
                tooltip:SetText('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO Ctrl+Shift')
                tooltip:Show(true)
            else
                e.tips:AddDoubleLine('|A:questlegendary:0:0|a'..(tab.col or '')..'Raider.IO', (tab.col or '')..'Ctrl+Shift')
                e.tips:Show(true)
            end
        end

    elseif tab.name and tooltip then
        if IsControlKeyDown() and IsShiftKeyDown() then
            e.Show_WoWHead_URL(nil, nil, nil, tab.name)
        else
            tooltip:AddDoubleLine((tab.col or '')..'WoWHead', (tab.col or '')..'Ctrl+Shift')
            tooltip:Show()
        end
    end
end





















function func:Set_Mount(tooltip, mountID, type)--坐骑
    if mountID==268435455 then
        func:Set_Spell(tooltip, 150544)--法术
        return
    end

    tooltip:AddLine(' ')
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    local creatureName, spellID, _,isActive, isUsable, _, _, isFactionSpecific, faction, _, isCollected, _, isForDragonriding =C_MountJournal.GetMountInfoByID(mountID)
    local spell
    if spellID then
        local icon= C_Spell.GetSpellTexture(spellID) or 0
        spell= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, (icon and '|T'..icon..':0|t' or '')..(e.onlyChinese and '法术' or SPELLS), spellID)
    end
    tooltip:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '坐骑' or MOUNTS, mountID), spell)

    if isFactionSpecific then
        if faction==0 then
            tooltip.textRight:SetFormattedText(
                e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', e.Icon.Horde, e.onlyChinese and '部落' or THE_HORDE)
            )
        elseif faction==1 then
            tooltip.textRight:SetFormattedText(
                e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION,
                format('|A:%s:0:0|a', e.Icon.Alliance, e.onlyChinese and '联盟' or THE_ALLIANCE)
            )
        end
    elseif isForDragonriding then
        tooltip.textRight:SetFormattedText(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, e.onlyChinese and '驭空术' or MOUNT_JOURNAL_FILTER_DRAGONRIDING)
    end
    local creatureDisplayInfoID, _, source, isSelfMount, _, _, animID = C_MountJournal.GetMountInfoExtraByID(mountID)
    if creatureDisplayInfoID then
        tooltip:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '模型' or MODEL, creatureDisplayInfoID), isSelfMount and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '变形' or TUTORIAL_TITLE61_DRUID) or nil)
    end

    if source then--显示来源
        tooltip:AddLine(' ')
        tooltip:AddLine(e.cn(source), nil,nil,nil,true)
    end

    func:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayInfoID, animID=animID})--设置, 3D模型

    tooltip.text2Left:SetText(isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')

    local can= isCollected and isUsable and not isActive and not UnitCastingInfo('player')
    if can and IsAltKeyDown() then
        C_MountJournal.SummonByID(mountID)
        print(id, Initializer:GetName(), spellID and C_Spell.GetSpellLink(spellID), '|cnGREEN_FONT_COLOR:Alt+'..(e.onlyChinese and '召唤坐骑' or MOUNT))
    end
    local col= can and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'
    tooltip:AddDoubleLine(col..(e.onlyChinese and '召唤坐骑' or MOUNT), col..'Alt+')

    if type and MountJournal and MountJournal:IsVisible() and creatureName then
        MountJournalSearchBox:SetText(creatureName)
    end
    func:Set_Web_Link(tooltip, {type='spell', id=spellID, name=creatureName, col=nil, isPetUI=false})--取得网页，数据链接    
end

























function func:Set_Pet(tooltip, speciesID, setSearchText)--宠物
    if not speciesID or speciesID< 1 then
        return
    end
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)

    if obtainable then--可得到的
        tooltip:AddLine(' ')

        local AllCollected, CollectedNum, CollectedText= e.GetPetCollectedNum(speciesID)--收集数量
        tooltip.textLeft:SetText(CollectedNum or '')
        tooltip.text2Left:SetText(CollectedText or '')
        tooltip.textRight:SetText(AllCollected or '')

        tooltip:AddDoubleLine((e.onlyChinese and '宠物' or PET)..' '..speciesID..(speciesIcon and '  |T'..speciesIcon..':0|t'..speciesIcon or ''), (creatureDisplayID and (e.onlyChinese and '模型' or MODEL)..' '..creatureDisplayID or '')..(companionID and ' NPC '..companionID or ''))--ID

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
        tooltip:AddDoubleLine(abilityIconA, abilityIconB)
        if not isTradeable then
            tooltip:AddLine(e.onlyChinese and '该宠物不可交易' or BATTLE_PET_NOT_TRADABLE, 1,0,0)
        end
        if not canBattle then
            tooltip:AddLine(e.onlyChinese and '该生物无法对战。' or BATTLE_PET_CANNOT_BATTLE, 1,0,0)
        end
    end

    tooltip:AddLine(' ')
    local sourceInfo= e.cn(nil, {speciesID=speciesID}) or {}
    local cnName= e.cn(nil, {npcID=companionID, isName=true})

    if cnName then
        tooltip:AddLine('|cffffffff'..cnName..'|r')
    end

    if tooltipDescription or sourceInfo[1] then
        tooltip:AddLine(sourceInfo[1] or tooltipDescription, nil,nil,nil, true)--来源
    end
    if tooltipSource or sourceInfo[2] then
        tooltip:AddLine(sourceInfo[2] or tooltipSource,nil,nil,nil, true)--来源
    end

    if petType then
        tooltip.Portrait:SetTexture("Interface\\TargetingFrame\\PetBadge-"..PET_TYPE_SUFFIX[petType])
        tooltip.Portrait:SetShown(true)
    end
    func:Set_Item_Model(tooltip, {creatureDisplayID=creatureDisplayID})--设置, 3D模型

    if setSearchText and speciesName and PetJournalSearchBox and PetJournalSearchBox:IsVisible() then--宠物手册，设置名称
        PetJournalSearchBox:SetText(speciesName)
    end

    func:Set_Web_Link(tooltip, {type='npc', id=companionID, name=speciesName, col= nil, isPetUI=false})--取得网页，数据链接
    local btn= _G['WoWTools_PetBattle_Type_TrackButton']--PetBattle.lua 联动
    if btn then
        btn:set_type_tips(petType)
    end
end
































--############
--设置,物品信息
--############
function func:Set_Item(tooltip, itemLink, itemID)
    if not itemLink and not itemID then
        return
    end

    local itemName, _, itemQuality, itemLevel, _, itemType, itemSubType, _, itemEquipLoc, itemTexture, _, classID, subclassID, bindType, expacID, setID =  C_Item.GetItemInfo(itemLink or itemID)
    itemID= itemID or C_Item.GetItemInfoInstant(itemLink or itemID) or func:GetItemInfoFromHyperlink(itemLink)
    --itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent
    if not itemID then
        return
    end

    local r, g, b, col= 1,1,1,e.Player.col
    if itemQuality then
        r, g, b, col= C_Item.GetItemQualityColor(itemQuality)
        col=col and '|c'..col
    end
    tooltip:AddLine(' ')
    if expacID then--版本数据
        tooltip:AddDoubleLine(e.GetExpansionText(expacID))
    end

    itemTexture= itemTexture or C_Item.GetItemIconByID(itemID or itemLink)
    tooltip:AddDoubleLine(format('%s%d %s', e.onlyChinese and '物品' or ITEMS, itemID , setID and (e.onlyChinese and '套装' or WARDROBE_SETS)..setID or ''),
                    itemTexture and '|T'..itemTexture..':0|t'..itemTexture, 1,1,1, 1,1,1)--ID, texture
    if classID and subclassID then
        tooltip:AddDoubleLine((e.cn(itemType) or 'itemType')..classID, (e.cn(itemSubType) or 'itemSubType')..subclassID)
    end

    if classID==2 or classID==4 then
        itemLevel= itemLink and C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel--装等
        if itemLevel and itemLevel>1 then
            local slot= e.GetItemSlotID(itemEquipLoc)--比较装等
            if slot then
                local slotTexture= select(2, e.GetItemSlotIcon(slot))
                if slotTexture then
                    tooltip.Portrait:SetTexture(slotTexture)
                    tooltip.Portrait:SetShown(true)
                end
                tooltip:AddDoubleLine(format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.cn(_G[itemEquipLoc]) or '', itemEquipLoc), format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, slot), 1,1,1, 1,1,1)--栏位
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
                tooltip.textLeft:SetText(text)
            end
        end

        local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemLink or itemID)--幻化
        local visualID
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo then
                visualID=sourceInfo.visualID
                tooltip.text2Left:SetText(sourceInfo.isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')
            end
        end
        func:Set_Item_Model(tooltip, {itemID=itemID, sourceID=sourceID, appearanceID=appearanceID, visualID=visualID})--设置, 3D模型

        if bindType==LE_ITEM_BIND_ON_EQUIP or bindType==LE_ITEM_BIND_ON_USE then--绑定装备,使用时绑定
            tooltip.Portrait:SetAtlas('greatVault-lock')
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
            tooltip:AddDoubleLine(specA, ' ')
        end

    elseif C_ToyBox.GetToyInfo(itemID) then--玩具
        tooltip.text2Left:SetText(PlayerHasToy(itemID) and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r')

    elseif itemID==122284 then-- or C_WowTokenPublic.IsAuctionableWowToken(itemID) then --itemID==122284 then--魔兽世界时光徽章
        C_WowTokenPublic.UpdateMarketPrice()
        local price= C_WowTokenPublic.GetCurrentMarketPrice()
        if price and price>0 then
            tooltip.textLeft:SetText('|A:token-choice-wow:0:0|a'..C_CurrencyInfo.GetCoinTextureString(price))
        end

    else
        local mountID = C_MountJournal.GetMountFromItem(itemID)--坐骑物品
        local speciesID = select(13, C_PetJournal.GetPetInfoByItemID(itemID))
        if mountID then
            func:Set_Mount(tooltip, mountID, 'item')--坐骑
        elseif speciesID then
            func:Set_Pet(tooltip, speciesID, true)--宠物
        else
        end
    end

    if itemQuality==0 and(classID==2 or classID==15) then
        local petText= e.GetPet9Item(itemID)--宠物兑换, wow9.0
        if petText then
            tooltip:AddLine(petText)
        end
    end

    local spellName, spellID = C_Item.GetItemSpell(itemID)--物品法术
    if spellName and spellID then
        local spellTexture= C_Spell.GetSpellTexture(spellID)
        tooltip:AddDoubleLine((itemName~=spellName and col..'['..spellName..']|r' or '')..(e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and spellTexture~=itemTexture  and '|T'..spellTexture..':0|t'..spellTexture or ' ')
    end

    local wowNum= 0--WoW 数量    
    local bag= C_Item.GetItemCount(itemID, false, false, false)--物品数量
    local bank= C_Item.GetItemCount(itemID, true, false, true) - bag

    if C_Item.IsItemKeystoneByID(itemID) then--挑战
        for guid, info in pairs(e.WoWDate or {}) do
            if guid and guid~=e.Player.guid and info.Keystone.link then
                e.GetKeystoneScorsoColor(info.Keystone.score, false, nil)
                tooltip:AddDoubleLine(
                    (info.Keystone.weekNum==0 and '|cff9e9e9e0|r' or info.Keystone.weekNum or '')
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
            tooltip.textLeft:SetText((text and '|cnGREEN_FONT_COLOR:'..text..'|r ' or '')..(score or ''))
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
            tooltip.text2Left:SetText(num..'|cnGREEN_FONT_COLOR:('..completedNum..')|r')
        end

    else
        local bagAll,bankAll,numPlayer=0,0,0--帐号数据
        for guid, info in pairs(e.WoWDate or {}) do
            if guid and guid~=e.Player.guid and info.Item[itemID] then
                local tab=info.Item[itemID]
                tooltip:AddDoubleLine(e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), '|A:Banker:0:0|a'..(tab.bank==0 and '|cff9e9e9e'..tab.bank..'|r' or tab.bank)..' '..'|A:bag-main:0:0|a'..(tab.bag==0 and '|cff9e9e9e'..tab.bag..'|r' or tab.bag))
                bagAll=bagAll +tab.bag
                bankAll=bankAll +tab.bank
                numPlayer=numPlayer +1
            end
        end

        if numPlayer>0 then
            wowNum= bagAll+ bankAll
            tooltip:AddDoubleLine(numPlayer..' '..(e.onlyChinese and '角色' or CHARACTER)..' '..e.MK(wowNum+bag+bank, 3), format('|T%d:0|t', e.Icon.wow)..e.MK(bagAll+bankAll, 3)..' = '..'|A:Banker:0:0|a'..(bankAll==0 and '|cff9e9e9e'..bankAll..'|r' or e.MK(bankAll,3))..' '..'|A:bag-main:0:0|a'..(bagAll==0 and '|cff9e9e9e'..bagAll..'|r' or e.MK(bagAll, 3)))
        end
    end

    tooltip.textRight:SetText(col..e.MK(wowNum, 3)..format('|T%d:0|t', e.Icon.wow)..' '..e.MK(bank, 3)..'|A:Banker:0:0|a'..' '..e.MK(bag, 3)..'|A:bag-main:0:0|a'..'|r')

    --setItemCooldown(tooltip, itemID)--物品冷却

    tooltip.backgroundColor:SetColorTexture(r, g, b, 0.15)--颜色
    tooltip.backgroundColor:SetShown(true)

    func:Set_Web_Link(tooltip, {type='item', id=itemID, name=itemName, col=col, isPetUI=false})--取得网页，数据链接

    tooltip:Show()
end















function func:Set_Spell(tooltip, spellID)--法术    
    spellID = spellID or select(2, tooltip:GetSpell())
    local name, icon, originalIcon
    local spellInfo= spellID and C_Spell.GetSpellInfo(spellID)
    if spellInfo then
        name= spellInfo.name
        icon= spellInfo.iconID
        originalIcon= spellInfo.originalIconID
    end
    if not name then
        return
    end

    local spellTexture=  originalIcon or icon
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((e.onlyChinese and '法术' or SPELLS)..' '..spellID, spellTexture and '|T'..spellTexture..':0|t'..spellTexture, 1,1,1, 1,1,1)
    local mountID = spellID~=150544 and C_MountJournal.GetMountFromSpell(spellID)--坐骑
    if mountID then
        func:Set_Mount(tooltip, mountID)
    else
        --[[local overrideSpellID = FindSpellOverrideByID(spellID)
        if overrideSpellID and overrideSpellID~=spellID then
            e.LoadDate({id=overrideSpellID, type='spell'})--加载 item quest spell
            local link= C_Spell.GetSpellLink(overrideSpellID)
            if link then

            local name2, _, icon2, _, _, _, _, originalIcon2= C_Spell.GetSpellInfo(overrideSpellID)
            link= link or name2
            link= link and link..overrideSpellID or ('overrideSpellID '..overrideSpellID)
            if link then
                spellTexture=  originalIcon2 or icon2 or C_Spell.GetSpellTexture(overrideSpellID)
                e.tips:AddDoubleLine(format(e.onlyChinese and '代替%s' or REPLACES_SPELL, link), spellTexture and '|T'..spellTexture..':0|t'..spellTexture)
            end
        end]]
        func:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end
end

function func:Set_Currency(tooltip, currencyID)--货币
    local info2 = currencyID and C_CurrencyInfo.GetCurrencyInfo(currencyID)
    if not info2 then
        return
    end
    tooltip:AddDoubleLine((e.onlyChinese and '货币' or TOKENS)..' '..currencyID, info2.iconFileID and '|T'..info2.iconFileID..':0|t'..info2.iconFileID)
    local factionID = C_CurrencyInfo.GetFactionGrantedByCurrency(currencyID)--派系声望
    if factionID and factionID>0 then
        local name= (C_Reputation.GetFactionDataByID(factionID) or {}).name
        if name then
            tooltip:AddDoubleLine(e.onlyChinese and '声望' or REPUTATION, e.cn(name)..' '..factionID)
        end
    end

    local all,numPlayer=0,0
    for guid, info in pairs(e.WoWDate or {}) do--帐号数据
        if guid~=e.Player.guid then
            local quantity=info.Currency[currencyID]
            if quantity and quantity>0 then
                tooltip:AddDoubleLine(e.GetPlayerInfo({guid=guid, faction=info.faction, reName=true, reRealm=true}), e.MK(quantity, 3))
                all=all+quantity
                numPlayer=numPlayer+1
            end
        end
    end
    if numPlayer>1 then
        tooltip:AddDoubleLine(format('|T%d:0|t', e.Icon.wow)..numPlayer..(e.onlyChinese and '角色' or CHARACTER), e.MK(all,3))
    end

    func:Set_Web_Link(tooltip, {type='currency', id=currencyID, name=info2.name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency

    tooltip:Show()
end
















function func:Set_Achievement(tooltip, achievementID)--成就
    if not achievementID then
        return
    end

    tooltip:AddLine(' ')
    local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)
    tooltip.textLeft:SetText(points..(e.onlyChinese and '点' or RESAMPLE_QUALITY_POINT))--点数
    tooltip.text2Left:SetText(completed and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已完成' or CRITERIA_COMPLETED)..'|r' or '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未完成' or ACHIEVEMENTFRAME_FILTER_INCOMPLETE)..'|r')--否是完成
    tooltip.textRight:SetText(isGuild and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '公会' or GUILD) or flags==0x4000 and ('|cffff00ff'..e.Icon.net2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))  or '')

    tooltip:AddDoubleLine((e.onlyChinese and '成就' or ACHIEVEMENTS)..' '..(flags==0x20000 and '|cffff00ff'..format('|T%d:0|t', e.Icon.wow)..achievementID..'|r' or achievementID), icon and '|T'..icon..':0|t'..icon)
    if flags==0x20000 then
        tooltip.textRight:SetText(e.Icon.net2..'|cffff00ff'..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET))
    end
    func:Set_Web_Link(tooltip, {type='achievement', id=achievementID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
end




















function func:Set_Quest(tooltip, questID, info)----任务
    questID= questID or (info and info.questID or nil)
    if not questID then
        return
    end
    tooltip:AddDoubleLine(e.GetExpansionText(nil, questID))--任务版本

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
    tooltip:AddDoubleLine((e.onlyChinese and '任务' or QUESTS_LABEL)..(levelText or ''), questID)

    if not info then
        local questLogIndex= C_QuestLog.GetLogIndexForQuestID(questID)
        info = questLogIndex and C_QuestLog.GetInfo(questLogIndex)
    end


    --[[
    local distanceSq= C_QuestLog.GetDistanceSqToQuest(questID)--距离
    if distanceSq and distanceSq>0 then
        local _, x, y = QuestPOIGetIconInfo(questID)--QuestPOIGetIconInfo已弃
        if x and y then
            x=math.modf(x*100) y=math.modf(y*100)
        end
        tooltip:AddDoubleLine(x and y and 'XY '..x..', '..y or ' ',  format(e.onlyChinese and '%s码' or IN_GAME_NAVIGATION_RANGE, e.MK(distanceSq)))
    end]]

    local tagInfo = C_QuestLog.GetQuestTagInfo(questID)
    local name
    if tagInfo and tagInfo.tagID then
        local atlas, color = e.QuestLogQuests_GetBestTagID(questID, info, tagInfo, nil)
        local col= color and color.hex or ''
        tooltip:AddDoubleLine(col..(atlas or '')..'tagID', col..tagInfo.tagID)
        name= tagInfo.name
    else
        local tagID= C_QuestLog.GetQuestType(questID)
        if tagID and tagID>0 then
            tooltip:AddDoubleLine('tagID', tagID)
        end
    end
    func:Set_Web_Link(tooltip, {type='quest', id=questID, name=name or C_QuestLog.GetTitleForQuestID(questID), col=nil, isPetUI=false})--取得网页，数据链接
end



















--####
--Buff
--####
function func:Set_All_Aura(tooltip, data)--Aura
    local spellID= data.id
    local name= C_Spell.GetSpellName(spellID)
    local icon= C_Spell.GetSpellTexture(spellID)
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((e.onlyChinese and '光环' or AURAS)..' '..spellID, icon and '|T'..icon..':0|t'..icon)
    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if mountID then
        func:Set_Mount(tooltip, mountID, 'aura')
    else
        func:Set_Web_Link(tooltip, {type='spell', id=spellID, name=name, col=nil, isPetUI=false})--取得网页，数据链接
    end
end


function func:Set_Buff(type, tooltip, ...)
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
            if r and g and b and tooltip.backgroundColor then
                tooltip.backgroundColor:SetColorTexture(r, g, b, 0.3)
                tooltip.backgroundColor:SetShown(true)
            end
            if source~='player' and tooltip.Portrait then
                SetPortraitTexture(tooltip.Portrait, source)
                tooltip.Portrait:SetShown(true)
            end
            local text= source=='player' and (e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
                    or source=='pet' and (e.onlyChinese and '宠物' or PET)
                    or UnitIsPlayer(source) and e.GetPlayerInfo({unit=source, reName=true})
                    or UnitName(source) or _G[source] or source
            tooltip:AddLine((col or '|cffffffff') ..format(e.onlyChinese and '来源：%s' or RUNEFORGE_LEGENDARY_POWER_SOURCE_FORMAT, text)..'|r')
            tooltip:Show()
        end
    end
end



















--####
--声望
--####
function func:Set_Faction(tooltip, factionID)--, frame)
    local info= factionID and e.GetFactionInfo(factionID, nil, true)
    if not info.factionID then
        return
    end
    local icon= info.texture and ('|T'..info.texture..':0|t'..info.texture)
                or (info.atlas and '|A:'..info.atlas..':0:0|a'..info.atlas)
    if info.friendshipID then
        tooltip:AddDoubleLine((e.onlyChinese and '个人' or format(QUEST_REPUTATION_REWARD_TITLE, 'NPC'))..' '..info.friendshipID, icon)
    elseif info.isMajor then
        tooltip:AddDoubleLine((e.onlyChinese and '阵营' or MAJOR_FACTION_LIST_TITLE)..' '..info.factionID, icon)
    else
        tooltip:AddDoubleLine((e.onlyChinese and '声望' or REPUTATION)..' '..info.factionID, icon)
    end
    if info.factionStandingtext or info.valueText then
        tooltip:AddDoubleLine(info.factionStandingtext or ' ', (info.hasRewardPending or '')..(info.valueText or '')..(info.valueText and info.isParagon and '|A:Banker:0:0|a' or ''))
    end
    if info.hasRewardPending then
        tooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
    end
    func:Set_Web_Link(tooltip, {type='faction', id=info.friendshipID or info.factionID, name=info.name, col=nil, isPetUI=false})--取得网页，数据链接
    tooltip:Show()
end













--#########
--生命条提示
--#########
function func:Set_HealthBar_Unit(frame, unit)
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




local function Int_Health_Bar_Unit()--hooksecurefunc(GameTooltipStatusBar, 'UpdateUnitHealth', function(tooltip)
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
        func:Set_HealthBar_Unit(self)
    end)
end
















--#############
--设置单位, 玩家
--#############
function func:Set_Unit_Player(tooltip, name, unit, guid)
    local realm= select(2, UnitName(unit)) or e.Player.realm--服务器
    local isPlayer = UnitIsPlayer(unit)
    local isSelf= UnitIsUnit('player', unit)--我
    local isGroupPlayer= (not isSelf and e.GroupGuid[guid]) and true or nil--队友
    local r, g, b, col = e.GetUnitColor(unit)--颜色
    local isInCombat= UnitAffectingCombat('player')
    local englishFaction = isPlayer and UnitFactionGroup(unit)
    local textLeft, text2Left, textRight, text2Right='', '', '', ''
    local tooltipName=tooltip:GetName() or 'GameTooltip'


    tooltip.Portrait:SetAtlas(e.Icon[englishFaction] or 'Neutral')
    tooltip.Portrait:SetShown(true)

    --取得玩家信息
    local info= e.UnitItemLevel[guid]
    if info then
        if not isInCombat then
            e.GetNotifyInspect(nil, unit)--取得装等
        end
        if info.itemLevel then--设置装等
            if info.itemLevel>1 then
                textLeft= info.itemLevel
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

    tooltip.backgroundColor:SetColorTexture(r, g, b, 0.2)--背景颜色
    tooltip.backgroundColor:SetShown(true)

    local isWarModeDesired= C_PvP.IsWarModeDesired()--争模式
    local statusIcon, statusText= e.PlayerOnlineInfo(unit)--单位，状态信息
    if statusIcon and statusText then
        textLeft= textLeft..statusIcon..statusText

    elseif isGroupPlayer then--队友
        local reason=UnitPhaseReason(unit)
        if reason then
            if reason==0 then
                textLeft= (e.onlyChinese and '不同了阶段' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', MAP_BAR_THUNDER_ISLE_TITLE0:gsub('1','')))..textLeft
            elseif reason==1 then
                textLeft= (e.onlyChinese and '不在同位面' or ERR_ARENA_TEAM_PLAYER_NOT_IN_TEAM_SS:format('', e.Player.layer))..textLeft
            elseif reason==2 then--战争模
                textLeft= (isWarModeDesired and (e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF) or (e.onlyChinese and '开启战争模式' or ERR_PVP_WARMODE_TOGGLE_ON))..textLeft
            elseif reason==3 then
                textLeft= (e.onlyChinese and '时空漫游' or PLAYER_DIFFICULTY_TIMEWALKER)..textLeft
            end
        end
    end
    if not IsInInstance() and UnitHasLFGRandomCooldown(unit) then
        text2Left= text2Left..'|T236347:0|t'
    end

    local region= e.Get_Region(realm)--服务器，EU， US
    textRight=realm..(isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or realm==e.Player.realm and format('|A:%s:0:0|a', e.Icon.select) or e.Player.Realms[realm] and '|A:Adventures-Checkmark:0:0|a' or '')..(region and region.col or '')

    if isSelf then
        local titleID= GetCurrentTitle()
        if titleID and titleID>1 then
            local titleName= GetTitleName(titleID)
            text2Right= e.cn(titleName, {titleID= titleID})
            text2Right= text2Right and text2Right:gsub('%%s', '')
        end
    else
        local lineLeft1=_G[tooltipName..'TextLeft1']--名称
        if lineLeft1 then
            text2Right= lineLeft1:GetText():gsub(name, '')
        end
    end

    tooltip.textLeft:SetText(textLeft)
    tooltip.text2Left:SetText(text2Left)
    tooltip.textRight:SetText(textRight)
    tooltip.text2Right:SetText(text2Right)

    tooltip.textLeft:SetTextColor(r, g, b)
    tooltip.text2Left:SetTextColor(r, g, b)
    tooltip.textRight:SetTextColor(r, g, b)
    tooltip.text2Right:SetTextColor(r, g, b)



    local lineLeft1=_G[tooltipName..'TextLeft1']--名称
    if lineLeft1 then
        lineLeft1:SetText(
            (isSelf and '|A:auctionhouse-icon-favorite:0:0|a' or e.GetFriend(nil, guid, nil) or '')
            ..'|A:common-icon-rotateright:0:0|a'..name..'|A:common-icon-rotateleft:0:0|a'
        )
        local lineRight1= _G[tooltipName..'TextRight1']
        if lineRight1 then
            local text= ' '
            if isSelf then--魔兽世界时光徽章
                C_WowTokenPublic.UpdateMarketPrice()
                local price= C_WowTokenPublic.GetCurrentMarketPrice()
                if price and price>0 then
                    local all, numPlayer= e.GetItemWoWNum(122284)--取得WOW物品数量
                    text= all..(numPlayer>1 and '('..numPlayer..')' or '')..'|A:token-choice-wow:0:0|a'..e.MK(price/10000,3)..'|A:Front-Gold-Icon:0:0|a'
                end
            end
            lineRight1:SetText(text)
            lineRight1:SetShown(true)
        end
    end


    local isInGuild= IsPlayerInGuildFromGUID(guid)
    local lineLeft2= isInGuild and _G[tooltipName..'TextLeft2']
    if lineLeft2 then
        local text=lineLeft2:GetText()
        if text then
            lineLeft2:SetText('|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'..text:gsub('(%-.+)',''))
            local lineRight2= _G[tooltipName..'TextRight2']
            if lineRight2 then
                lineRight2:SetText(' ')
            end
        end
    end

    local lineLeft3= isInGuild and _G[tooltipName..'TextLeft3'] or _G[tooltipName..'TextLeft2']
    if lineLeft3 then
        local classFilename= select(2, UnitClass(unit))--职业名称
        local sex = UnitSex(unit)
        local raceName, raceFile= UnitRace(unit)
        local level= UnitLevel(unit)
        local text= sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a'

        if GetMaxLevelForLatestExpansion()==level then
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
                    ..(e.cn(raceName) or e.cn(raceFile) or '')
                    ..' '..(e.Class(nil, classFilename) or '')
                    ..' '..(UnitIsPVP(unit) and '(|cnGREEN_FONT_COLOR:'..(e.onlyChinese and 'PvP' or TRANSMOG_SET_PVP)..'|r)' or ('('..(e.onlyChinese and 'PvE' or TRANSMOG_SET_PVE)..')'))
        end
        lineLeft3:SetText(text)

        local lineRight3= isInGuild and _G[tooltipName..'TextRight3'] or _G[tooltipName..'TextRight2']
        if lineRight3 then
            lineRight3:SetText(' ')
        end
    end

    local hideLine--取得网页，数据链接
    local num= isInGuild and 4 or 3
    for i=1, tooltip:NumLines() or 0, 1 do
        local lineLeft=_G[tooltipName..'TextLeft'..i]
        if lineLeft then
            local show=true
            if i==num then
                if isSelf then--位面ID, 战争模式
                    lineLeft:SetText(e.Player.Layer and '|A:nameplates-holypower2-on:0:0|a'..e.Player.L.layer..' '..e.Player.Layer or ' ')
                    local lineRight= _G[tooltipName..'TextRight'..i]
                    if lineRight then
                        if isWarModeDesired then
                            lineRight:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE))
                        else
                            lineRight:SetText(e.onlyChinese and '关闭战争模式' or ERR_PVP_WARMODE_TOGGLE_OFF)
                        end
                        lineLeft:SetShown(true)
                    end
                elseif isGroupPlayer then--队友位置
                    local mapID= C_Map.GetBestMapForUnit(unit)--地图ID
                    if mapID then
                        local mapInfo= C_Map.GetMapInfo(mapID)
                        if mapInfo and mapInfo.name then
                            lineLeft:SetText('|A:poi-islands-table:0:0|a'..mapInfo.name)
                            lineLeft:SetShown(true)
                        end
                    end
                else
                    if not hideLine  then
                        hideLine=lineLeft
                    else
                        show=false
                    end
                end
            elseif i>num then
                if not hideLine then
                    hideLine=lineLeft
                else
                    show=false
                end
            end
            if show then
                lineLeft:SetTextColor(r,g,b)
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight and lineRight:IsShown()then
                    lineRight:SetTextColor(r,g,b)
                end
            else
                lineLeft:SetShown(false)
                local lineRight= _G[tooltipName..'TextRight'..i]
                if lineRight then
                    lineRight:SetShown(false)
                end
            end
        end
    end
    if isInCombat then
        if hideLine then
            hideLine:SetShown(false)
        end
    else
        func:Set_Web_Link(hideLine, {unitName=name, realm=realm, col=col})--取得单位, raider.io 网页，数据链接
    end

    func:Set_HealthBar_Unit(GameTooltipStatusBar, unit)--生命条提示
    func:Set_Item_Model(tooltip, {unit=unit, guid=guid})--设置, 3D模型

    func:Set_Width(tooltip)--设置，宽度
end

































--#############
--设置单位, NPC
--#############
function func:Set_Unit_NPC(tooltip, name, unit, guid)
    local textLeft, text2Left, textRight, text2Right=' ', '', '', ''

    --怪物, 图标
    if UnitIsQuestBoss(unit) then--任务
        tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest')
        tooltip.Portrait:SetShown(true)

    elseif UnitIsBossMob(unit) then--世界BOSS
        text2Left= e.onlyChinese and '首领' or BOSS
        tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
        tooltip.Portrait:SetShown(true)
    else
        local classification = UnitClassification(unit)--TargetFrame.lua
        if classification == "rareelite" then--稀有, 精英
            text2Left= e.onlyChinese and '稀有' or GARRISON_MISSION_RARE
            tooltip.Portrait:SetAtlas('UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare')
            tooltip.Portrait:SetShown(true)

        elseif classification == "rare" then--稀有
            text2Left= e.onlyChinese and '稀有' or GARRISON_MISSION_RARE
            tooltip.Portrait:SetAtlas('UUnitFrame-Target-PortraitOn-Boss-Rare-Star')
            tooltip.Portrait:SetShown(true)
        else
            SetPortraitTexture(tooltip.Portrait, unit)
            tooltip.Portrait:SetShown(true)
        end
    end

    local type=UnitCreatureType(unit)--生物类型
    if type and not type:find(COMBAT_ALLY_START_MISSION) then
        textRight=e.cn(type)
    end

    local uiWidgetSet= UnitWidgetSet(unit)
    if uiWidgetSet and uiWidgetSet>0 then
        e.tips:AddDoubleLine('WidgetSetID', uiWidgetSet)
    end

    local zone, npc
    if guid then
        zone, npc = select(5, strsplit("-", guid))--位面,NPCID
        if zone then
            tooltip:AddDoubleLine(e.Player.L.layer..' '..zone, 'NPC '..npc)
            e.Player.Layer=zone
        end
        func:Set_Web_Link(tooltip, {type='npc', id=npc, name=name, isPetUI=false})--取得网页，数据链接 
    end

    --NPC 中文名称
    local data= e.cn(nil, {unit=unit, npcID=npc})
    if data then
        textLeft= data[1]
        text2Right= data[2]
    end

    tooltip.textLeft:SetText(textLeft)
    tooltip.text2Left:SetText(text2Left)
    tooltip.textRight:SetText(textRight)
    tooltip.text2Right:SetText(text2Right)

    if not Save.disabledNPCcolor then
        local r, g, b = e.GetUnitColor(unit)--颜色
        local tooltipName=tooltip:GetName() or 'GameTooltip'
        for i=1, tooltip:NumLines() do
            local lineLeft=_G[tooltipName.."TextLeft"..i]
            if lineLeft then
                lineLeft:SetTextColor(r, g, b)
            end
            local lineRight=_G[tooltipName.."TextRight"..i]
            if lineRight and lineRight:IsShown() then
                lineRight:SetTextColor(r, g, b)
            end
        end
        tooltip.textLeft:SetTextColor(r, g, b)
        tooltip.text2Left:SetTextColor(r, g, b)
        tooltip.textRight:SetTextColor(r, g, b)
        tooltip.text2Right:SetTextColor(r, g, b)
    end

    func:Set_HealthBar_Unit(GameTooltipStatusBar, unit)--生命条提示
    func:Set_Item_Model(tooltip, {unit=unit, guid=guid})--设置, 3D模型

    func:Set_Width(tooltip)--设置，宽度
end
















--#######
--设置单位
--#######
function func:Set_Unit(tooltip)--设置单位提示信息
    local name, unit, guid= TooltipUtil.GetDisplayedUnit(tooltip)
    if not name or not UnitExists(unit) or not guid then
        return
    end
    if UnitIsPlayer(unit) then
        func:Set_Unit_Player(tooltip, name, unit, guid)

    elseif (UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then--宠物TargetFrame.lua
        func:Set_Pet(tooltip, UnitBattlePetSpeciesID(unit), true)

    else
        func:Set_Unit_NPC(tooltip, name, unit, guid)
    end
end
--[[if isSelf and not isInCombat and Save.WidgetSetID>0 then
    GameTooltip_AddWidgetSet(e.tips, Save.WidgetSetID, 10)
end]]
























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
function func:Set_Flyout(tooltip, flyoutID)--法术, 弹出框
    local name, _, numSlots, isKnown= GetFlyoutInfo(flyoutID)
    if not name then
        return
    end

    tooltip:AddLine(' ')
    for slot= 1, numSlots do
        local flyoutSpellID, overrideSpellID, isKnown2, spellName = GetFlyoutSlotInfo(flyoutID, slot)
        local spellID= overrideSpellID or flyoutSpellID
        if spellID then
            e.LoadDate({id=spellID, type='spell'})
            local name2= e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true})
            local icon= C_Spell.GetSpellTexture(spellID)
            if name2 and icon then
                tooltip:AddDoubleLine('|T'..icon..':0|t'..(not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..e.cn(name2)..'|r', (not isKnown2 and '|cnRED_FONT_COLOR:' or '').. spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            else
                tooltip:AddDoubleLine((not isKnown2 and ' |cnRED_FONT_COLOR:' or '')..spellName..'|r',(not isKnown2 and '|cnRED_FONT_COLOR:' or '')..spellID..' '..(e.onlyChinese and '法术' or SPELLS)..'('..slot)
            end
        end
    end

    local icon
    local btn= tooltip:GetOwner()
    if btn and (btn.IconTexture or btn.icon) then
        icon= (btn.IconTexture or btn.icon):GetTextureFileID()
    end
    tooltip:AddLine(' ')
    tooltip:AddDoubleLine((not isKnown and '|cnRED_FONT_COLOR:' or '')..'flyoutID|r '..flyoutID, icon and icon>0 and format('|T%d:0|t%d', icon, icon), 1,1,1, 1,1,1)
end






























--###########
--宠物面板提示
--###########
local function Set_Battle_Pet(self, speciesID, level, breedQuality, maxHealth, power, speed, customName)
    if not speciesID or speciesID < 1 then
        return
    end
    local speciesName, speciesIcon, _, companionID, tooltipSource, tooltipDescription, _, _, _, _, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
    func:Set_Item_Model(self, {creatureDisplayID=creatureDisplayID})--设置, 3D模型
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

    local npcName= e.cn(nil, {npcID=companionID, isName=true})--中文名称
    if npcName then
        BattlePetTooltipTemplate_AddTextLine(self, npcName)
    end

    local sourceInfo= e.cn(nil, {speciesID=speciesID}) or {}
    tooltipDescription= sourceInfo[1] or tooltipDescription
    if tooltipDescription then
        BattlePetTooltipTemplate_AddTextLine(self, tooltipDescription, nil, nil, nil, true)--来源提示
    end
    tooltipSource= sourceInfo[2] or tooltipSource
    if tooltipSource then
        BattlePetTooltipTemplate_AddTextLine(self, tooltipSource, nil, nil, nil, true)--来源提示--来源
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

    func:Set_Web_Link(self, {type='npc', id=companionID, name=speciesName, col=nil, isPetUI=true})--取得网页，数据链接
    self:Show()
end

function func:set_Azerite(tooltip, powerID)--艾泽拉斯之心
    if powerID then
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine('powerID', powerID)
        local info = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
        if info and info.spellID then
            func:Set_Spell(tooltip, info.spellID)--法术
        end
    end
end





























local function Init_Hook()
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
            func:Set_Web_Link(self, {type='pet-ability', id=abilityID, name=name, col=nil, isPetUI=false})--取得网页，数据链接 npc item spell currency
            local btn= _G['WoWTools_PetBattle_Type_TrackButton']--PetBattle.lua 联动
            if btn then
                btn:set_type_tips(petType)
            end
        end
    end)


        hooksecurefunc(GameTooltip, 'SetSpellBookItem', function(self, slot, unit)--宠物，技能书，提示        
            if unit==Enum.SpellBookSpellBank.Pet and slot then
                local data= C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Pet)
                if data then
                    self:AddLine(' ')
                    self:AddDoubleLine(data.spellID and (e.onlyChinese and '法术' or SPELLS)..' '..data.spellID or ' ', data.iconID and '|T'..data.iconID..':0|t'..data.iconID)
                    if data.actionID or data.itemType then
                        self:AddDoubleLine(data.itemType and 'itemType '..data.itemType or ' ', 'actionID '..data.actionID)
                    end
                    --self:Show()
                end
            end
        end)


    --####
    --声望
    --####
        hooksecurefunc(ReputationEntryMixin, 'ShowStandardTooltip', function(self)
            func:Set_Faction(GameTooltip, self.elementData.factionID)
        end)
        hooksecurefunc(ReputationEntryMixin, 'ShowMajorFactionRenownTooltip', function(self)
            func:Set_Faction(GameTooltip, self.elementData.factionID)
        end)
        hooksecurefunc(ReputationEntryMixin, 'ShowFriendshipReputationTooltip', function(self)
            func:Set_Faction(GameTooltip, self.elementData.factionID)
        end)
        hooksecurefunc(ReputationEntryMixin, 'ShowParagonRewardsTooltip', function(self)
            func:Set_Faction(EmbeddedItemTooltip, self.elementData.factionID)
        end)
        hooksecurefunc(ReputationEntryMixin, 'OnClick', function(frame)
            local self= ReputationFrame.ReputationDetailFrame
            if not self.factionIDText then
                self.factionIDText=e.Cstr(self)
                self.factionIDText:SetPoint('BOTTOM', self, 'TOP', 0,-4)
            end
            self.factionIDText:SetText(frame.elementData.factionID or '')
        end)
        ReputationFrame.ReputationDetailFrame:HookScript('OnShow', function(self)
            local selectedFactionIndex = C_Reputation.GetSelectedFaction();
            local factionData = C_Reputation.GetFactionDataByIndex(selectedFactionIndex);
            if factionData or factionData.factionID> 0 then
                if not self.factionIDText then
                    self.factionIDText=e.Cstr(self)
                    self.factionIDText:SetPoint('BOTTOM', self, 'TOP', 0,-4)
                end
                self.factionIDText:SetText(factionData.factionID)
            end
        end)



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
            func:Set_Faction(e.tips, self.factionID)
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
            func:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
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
                func:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
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
                --GameTooltip_AddQuest(self, self.questID)
                --e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName..e.Icon.left)
                e.tips:AddDoubleLine((e.onlyChinese and '任务' or QUESTS_LABEL)..' ID', self.questID)
                e.tips:Show()
                self:SetAlpha(1)
            end
        end)
        frame.questIDLabel:SetScript('OnMouseDown', function(self)
            if self.questID then
                local info = C_QuestLog.GetQuestTagInfo(self.questID) or {}
                e.Show_WoWHead_URL(true, 'quest', self.questID, info.tagName)
            end
        end)
        function frame.questIDLabel:settings(questID)
            local num= (questID and questID>0) and questID
            self:SetText(num or '')
            self.questID= num
        end
        return frame.questIDLabel
    end
    
    local label= create_Quest_Label(QuestMapDetailsScrollFrame)
    label:SetPoint('BOTTOMRIGHT', QuestMapDetailsScrollFrame, 'TOPRIGHT', 0, 4)
    hooksecurefunc('QuestMapFrame_ShowQuestDetails', function(questID)
        QuestMapDetailsScrollFrame.questIDLabel:settings(questID)
    end)

    label= create_Quest_Label(QuestFrame)
    if _G['WoWeuCN_Tooltips_BlizzardOptions'] then
        label:SetPoint('BOTTOMRIGHT',QuestMapFrame.DetailsFrame.BackFrame, 'TOPRIGHT', 25, 28)
    else
        label:SetPoint('TOPRIGHT', -30, -35)
    end
    QuestFrame:HookScript('OnShow', function(self)
        local questID= QuestInfoFrame.questLog and  C_QuestLog.GetSelectedQuest() or GetQuestID()
        self.questIDLabel:settings(questID)
    end)


    
    --任务日志 显示ID
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        local info= self.questLogIndex and C_QuestLog.GetInfo(self.questLogIndex)
        if not info or not info.questID or not HaveQuestData(info.questID) then
            return
        end

        func:Set_Quest(e.tips, info.questID, info)--任务

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

    --添加 WidgetSetID
    hooksecurefunc('GameTooltip_AddWidgetSet', function(self, uiWidgetSetID)
        if uiWidgetSetID then
            self:AddDoubleLine('WidgetSetID', uiWidgetSetID)
            self:Show()
        end
    end)


    for i= 1, NUM_OVERRIDE_BUTTONS do-- ActionButton.lua
        if _G['OverrideActionBarButton'..i] then
            hooksecurefunc(_G['OverrideActionBarButton'..i], 'SetTooltip', function(self)
                if self.action then
                    local actionType, ID, subType = GetActionInfo(self.action)
                    if actionType and ID then
                        if actionType=='spell' or actionType =="companion" then
                            func:Set_Spell(e.tips, ID)--法术
                            e.tips:AddDoubleLine('action '..self.action, subType and 'subType '..subType)
                        elseif actionType=='item' and ID then
                            func:Set_Item(e.tips, nil, ID)
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
end





















    --[[TooltipDataRules.lua 
    Enum.TooltipDataType = {
		Item = 0,
		Spell = 1,
		Unit = 2,
		Corpse = 3,
		Object = 4,
		Currency = 5,
		BattlePet = 6,
		UnitAura = 7,
		AzeriteEssence = 8,
		CompanionPet = 9,
		Mount = 10,
		PetAction = 11,
		Achievement = 12,
		EnhancedConduit = 13,
		EquipmentSet = 14,
		InstanceLock = 15,
		PvPBrawl = 16,
		RecipeRankInfo = 17,
		Totem = 18,
		Toy = 19,
		CorruptionCleanser = 20,
		MinimapMouseover = 21,
		Flyout = 22,
		Quest = 23,
		QuestPartyProgress = 24,
		Macro = 25,
		Debug = 26,
	},
    TooltipDataProcessor.AllTypes
    Blizzard_SharedXMLGame/Tooltip/TooltipDataRules.lua
]]

local function Init_Settings()
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

    TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip)
        if not tooltip.textLeft then
            func:Set_Init_Item(tooltip)--创建，设置，内容
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        func:Set_Unit(tooltip)--单位
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))--物品
        itemLink= itemLink or itemID or data.id
        func:Set_Item(tooltip, itemLink, itemID)
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(tooltip, data)
        if tooltip==ShoppingTooltip1 or ShoppingTooltip2==tooltip then
            return
        end
        local itemLink, itemID= select(2, TooltipUtil.GetDisplayedItem(tooltip))--物品
        itemLink= itemLink or itemID or data.id
        func:Set_Item(tooltip, itemLink, itemID)
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(tooltip, data)
        func:Set_Spell(tooltip, data.id)--法术
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(tooltip, data)
        func:Set_Currency(tooltip, data.id)--货币
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.UnitAura, function(tooltip, data)
        func:Set_All_Aura(tooltip, data)--Aura
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.AzeriteEssence, function(tooltip, data)
        func:set_Azerite(tooltip, data.id)--艾泽拉斯之心
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Mount, function(tooltip, data)
        func:Set_Mount(tooltip, data.id)--坐骑
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Flyout, function(tooltip, data)
        func:Set_Flyout(tooltip, data.id)--法术弹出框
    end)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, function(tooltip, data)
        func:Set_Achievement(tooltip, data.id)--成就
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(tooltip)
        local frame= tooltip:GetOwner()--宏 11版本
        if frame and frame.action then
            local type, macroID, subType= GetActionInfo(frame.action)
            if type=='macro' and macroID then
                if subType=='spell' then--and macroID or GetMacroSpell(macroID)
                    func:Set_Spell(tooltip, macroID)
                elseif not subType or subType=='' then
                    local text=GetMacroBody(macroID)
                    if text then
                        tooltip:AddLine(text)
                    end
                end
            end
        end
    end)

    --###########
    --宠物面板提示
    --###########
    --func:Set_Init_Item(BattlePetTooltip, true)--创建物品
    hooksecurefunc("BattlePetToolTip_Show", function(...)--BattlePetTooltip.lua 
        Set_Battle_Pet(BattlePetTooltip, ...)
    end)

    hooksecurefunc('FloatingBattlePet_Show', function(...)--FloatingPetBattleTooltip.lua
        Set_Battle_Pet(FloatingBattlePetTooltip, ...)
    end)

    hooksecurefunc(GameTooltip, "SetCompanionPet", function(self, petGUID)--设置宠物信息
        local speciesID= petGUID and C_PetJournal.GetPetInfoByPetID(petGUID)
        func:Set_Pet(self, speciesID)--宠物
    end)

    hooksecurefunc('GameTooltip_AddQuestRewardsToTooltip', function(self)--世界任务ID GameTooltip_AddQuest
        func:Set_Quest(self)
    end)

    --################
    --Buff, 来源, 数据, 不可删除，如果删除，目标buff没有数据
    --################
    hooksecurefunc(e.tips, "SetUnitBuff", function(...)
        func:Set_Buff('Buff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitDebuff", function(...)
        func:Set_Buff('Debuff', ...)
    end)
    hooksecurefunc(e.tips, "SetUnitAura", function(...)
        func:Set_Buff('Aura', ...)
    end)
end
















--####
--初始
--####
local function Init()
    Int_Health_Bar_Unit()--生命条提示
    Init_Hook()
    Init_Settings()



    --****
    --位置
    --****
    hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
        if Save.setDefaultAnchor and not (Save.inCombatDefaultAnchor and UnitAffectingCombat('player')) then
            self:ClearAllPoints()
            self:SetOwner(parent, Save.cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT', Save.cursorX or 0, Save.cursorY or 0)
        end
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
end
    --[[追踪栏
    hooksecurefunc('BonusObjectiveTracker_OnBlockEnter', function(block)
        if block.id and not block.module.tooltipBlock and block.TrackedQuest then
            e.tips:SetOwner(block, "ANCHOR_LEFT")
            e.tips:ClearLines()
            GameTooltip_AddQuest(block.TrackedQuest or block, block.id)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
        end
    end)]]

    --显示选项中的CVar 11版本
    --[[Blizzard_SettingControls.lua
    if Save.ShowOptionsCVarTips then
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
            local setting = initializer.data.setting
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsSliderControlMixin, 'Init', function(self, initializer)
            local setting = initializer.data.setting
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)
            self.SliderWithSteppers.Slider:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsDropDownControlMixin, 'Init', function(self, initializer)
            local setting = self:GetSetting()
            local options = initializer:GetOptions()
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
            self:SetTooltipFunc(initTooltip)

            initTooltip = GenerateClosure(CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options, setting.variable))
            self.DropDown.Button:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsCheckBoxWithButtonControlMixin, 'Init', function(self, initializer)
            local setting = initializer:GetSetting()
            local initTooltip= GenerateClosure(InitTooltip, initializer:GetName(), initializer:GetTooltip(), setting.variable)
	        self:SetTooltipFunc(initTooltip)
            self.CheckBox:SetTooltipFunc(initTooltip)
        end)
        hooksecurefunc(SettingsCheckBoxSliderControlMixin, 'Init', function(self, initializer)--Blizzard_SettingControls.lua
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
    end]]










































--##############
 --添加新控制面板
--##############
local function set_Cursor_Tips(self)
    func:Set_Init_Item(GameTooltip, true)
    func:Set_Init_Item(ItemRefTooltip, true)
    func:Set_PlayerModel(GameTooltip)
    func:Set_PlayerModel(ItemRefTooltip)
    GameTooltip_SetDefaultAnchor(GameTooltip, self or UIParent)
    GameTooltip:ClearLines()
    GameTooltip:SetUnit('player')
    GameTooltip:Show()
end

local function Init_Panel()
    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)

    local initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '跟随鼠标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FOLLOW, MOUSE_LABEL),
        tooltip= Initializer:GetName(),
        GetValue= function() return Save.setDefaultAnchor end,
        category= Initializer,
        SetValue= function()
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
            GetValue= function() return Save.cursorRight end,
            category= Initializer,
            SetValue= function()
                Save.cursorRight= not Save.cursorRight and true or nil
                set_Cursor_Tips()
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.setDefaultAnchor then return true else return false end end)

        initializer= e.AddPanel_Check({
            name= e.onlyChinese and '战斗中：默认' or (HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DEFAULT),
            tooltip= Initializer:GetName(),
            GetValue= function() return Save.inCombatDefaultAnchor end,
            category= Initializer,
            SetValue= function()
                Save.inCombatDefaultAnchor= not Save.inCombatDefaultAnchor and true or nil
                set_Cursor_Tips()
            end
        })
        initializer:SetParentInitializer(initializer2, function() if Save.setDefaultAnchor then return true else return false end end)


    e.AddPanel_Header(Layout, e.onlyChinese and '设置' or SETTINGS)

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '模型' or MODEL,
        tooltip= Initializer:GetName(),
        GetValue= function() return not Save.hideModel end,
        category= Initializer,
        SetValue= function()
            Save.hideModel= not Save.hideModel and true or nil
            set_Cursor_Tips()
        end
    })

    initializer= e.AddPanel_Check({
        name= e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
        tooltip= Initializer:GetName(),
        GetValue= function() return Save.modelLeft end,
        category= Initializer,
        SetValue= function()
            Save.modelLeft= not Save.modelLeft and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save.hideModel then return false else return true end end)

    --[[initializer= e.AddPanel_Check({
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
]]
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
        GetValue= function() return not Save.disabledNPCcolor end,
        category= Initializer,
        SetValue= function()
            Save.disabledNPCcolor= not Save.disabledNPCcolor and true or nil
        end
    })

    e.AddPanel_Check({
        name= e.onlyChinese and '生命值' or HEALTH,
        tooltip= Initializer:GetName(),
        GetValue= function() return not Save.hideHealth end,
        category= Initializer,
        SetValue= function()
            Save.hideHealth= not Save.hideHealth and true or nil
            print(id, Initializer:GetName(),  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
    e.AddPanel_Check({
        name= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'Ctrl+Shift', e.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        tooltip= 'wowhead.com|nraider.io',
        GetValue= function() return Save.ctrl end,
        category= Initializer,
        SetValue= function()
            Save.ctrl= not Save.ctrl and true or nil
            set_Cursor_Tips()
        end
    })


    e.AddPanel_Header(Layout, 'CVar')

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '自动设置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SETTINGS),
        tooltip= function() return set_CVar(nil, true, true) end,
        GetValue= function() return Save.setCVar end,
        category= Initializer,
        SetValue= function()
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
        SetValue= function(_, _, value)
            if value==1 then
                C_CVar.SetCVar("ActionButtonUseKeyDown", '1')
            else
                C_CVar.SetCVar("ActionButtonUseKeyDown", '0')
            end
        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, e.onlyChinese and '是' or YES)
            container:Add(2, e.onlyChinese and '不' or NO)
            return container:GetData()
        end,
        GetValue= function() return C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 1 or 2 end,
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
        GetValue= function() return Save.ShowOptionsCVarTips end,
        category= Initializer,
        SetValue= function()
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





















local function Init_Blizzard_AchievementUI()
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
        for _, button in pairs(frame:GetFrames() or {}) do
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
            local unit= AchievementFrameComparisonHeaderPortrait.unit
            if unit then
                e.tips:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                e.tips:ClearLines()
                e.tips:SetUnit(unit)
                e.tips:Show()
            end
        end)
    end
    if Save.AchievementFrameFilterDropDown then--保存，过滤
        AchievementFrame_SetFilter(Save.AchievementFrameFilterDropDown)
    end
    hooksecurefunc('AchievementFrame_SetFilter', function(value)
        Save.AchievementFrameFilterDropDown = value
    end)
end















---宠物手册， 召唤随机，偏好宠物，技能ID 
local function Init_Blizzard_Collections()
    hooksecurefunc('PetJournalSummonRandomFavoritePetButton_OnEnter', function()--PetJournalSummonRandomFavoritePetButton
        func:Set_Spell(e.tips, 243819)
        e.tips:Show()
    end)
end

















--挑战, AffixID
local function Init_Blizzard_ChallengesUI()
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
            func:Set_Web_Link(GameTooltip, {type='affix', id=self.affixID, name=name, isPetUI=false})--取得网页，数据链接
            GameTooltip:Show()
        end
    end)
end













--要塞，技能树
local function Init_Blizzard_OrderHallUI()
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
end


















--飞行点，加名称
local function Init_Blizzard_FlightMap()
    hooksecurefunc(FlightMap_FlightPointPinMixin, 'OnMouseEnter', function(self2)
        local info= self2.taxiNodeData
        if info then
            e.tips:AddDoubleLine('nodeID '..(info.nodeID or ''), 'slotIndex '..(info.slotIndex or ''))
            e.tips:Show()
        end
    end)
end













--专业
local function Init_Blizzard_Professions()
    hooksecurefunc(Professions, 'SetupProfessionsCurrencyTooltip', function(currencyInfo)--lizzard_Professions.lua
        if currencyInfo then
            local nodeID = ProfessionsFrame.SpecPage:GetDetailedPanelNodeID()
            local currencyTypesID = Professions.GetCurrencyTypesID(nodeID)
            if currencyTypesID then
                GameTooltip_AddBlankLineToTooltip(GameTooltip)
                func:Set_Currency(GameTooltip, currencyTypesID)--货币
                GameTooltip:AddDoubleLine('nodeID', '|cffffffff'..nodeID..'|r')
            end
        end
    end)

    --专精，技能，查询
    hooksecurefunc(ProfessionsSpecPathMixin, 'OnEnter',function(self)
        if self.nodeID then--self.nodeInfo.ID
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('nodeID '..self.nodeID, self.entryID and 'entryID '..self.entryID)

            local name= WoWHead..'profession-trait/'..(self.nodeID or '')
            func:Set_Web_Link(GameTooltip, {name=name})
            GameTooltip:Show()
        end
    end)
end



















--天赋
local function Init_Blizzard_ClassTalentUI()
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
                            e.tips:AddLine(name)
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
end

















local function Init_Blizzard_PlayerChoice()
    hooksecurefunc(PlayerChoicePowerChoiceTemplateMixin, 'OnEnter', function(self)
        if self.optionInfo and self.optionInfo.spellID then
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.optionInfo.spellID)
            GameTooltip:Show()
        end
    end)
end

















local function Init_Blizzard_GenericTraitUI()
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










local function Init_Event()
    if C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
        Init_Blizzard_AchievementUI()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
        Init_Blizzard_Collections()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_ChallengesUI') then
        Init_Blizzard_ChallengesUI()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_OrderHallUI') then
        Init_Blizzard_OrderHallUI()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_FlightMap') then
        Init_Blizzard_FlightMap()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_Professions') then
        Init_Blizzard_Professions()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_ClassTalentUI') then
        Init_Blizzard_ClassTalentUI()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_PlayerChoice') then
        Init_Blizzard_PlayerChoice()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_GenericTraitUI') then
        Init_Blizzard_GenericTraitUI()
    end
end

















--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LEAVING_WORLD')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
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
                GetValue= function() return not Save.disabled end,
                category= Initializer,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            Init_StaticPopupDialogs()--全局

            if Save.disabled then
                self:UnregisterAllEvents()
                func={}
            else

                Init()--初始
                Init_Event()                
            end
            self:RegisterEvent("PLAYER_LOGOUT")

            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                Init_Panel()
            end

        elseif arg1=='Blizzard_Settings' then
            Init_Panel()

        elseif arg1=='Blizzard_AchievementUI' then--成就ID
            Init_Blizzard_AchievementUI()

        elseif arg1=='Blizzard_Collections' then--宠物手册， 召唤随机，偏好宠物，技能ID    
            Init_Blizzard_Collections()

        elseif arg1=='Blizzard_ChallengesUI' then
            Init_Blizzard_ChallengesUI()

        elseif arg1=='Blizzard_OrderHallUI' then
            Init_Blizzard_OrderHallUI()

        elseif arg1=='Blizzard_FlightMap' then--飞行点，加名称
            Init_Blizzard_FlightMap()

        elseif arg1=='Blizzard_Professions' then
            Init_Blizzard_Professions()

        elseif arg1=='Blizzard_ClassTalentUI' then
            Init_Blizzard_ClassTalentUI()

        elseif arg1=='Blizzard_PlayerChoice' then
            Init_Blizzard_PlayerChoice()

        elseif arg1=='Blizzard_GenericTraitUI' then
            Init_Blizzard_GenericTraitUI()
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