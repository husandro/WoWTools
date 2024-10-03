--Boss, 战利品, 信息
local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end
local ITEM_CLASSES_ALLOWED= format(ITEM_CLASSES_ALLOWED, '(.+)')
local ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"









local function Init(btn)
    local itemText--专精图标, 幻化，坐骑，宠物
    local tips--itemText提示用
    local classText--物品专精
    local upText--升级：


    local slotText= btn.slot and btn.slot:GetText()
    local isEquipItem= not Save().hideEncounterJournal and slotText and slotText~=''--是装备物品
    if not Save().hideEncounterJournal and btn.link then
        if isEquipItem then
            local specTable = C_Item.GetItemSpecInfo(btn.link) or {}--专精图标
            local specTableNum=#specTable
            if specTableNum>0 then
                local specA=''
                local class
                table.sort(specTable, function (a2, b2) return a2<b2 end)
                tips= e.onlyChinese and '拾取专精' or format(PROFESSIONS_SPECIALIZATION_TITLE, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT )
                for _,  specID in pairs(specTable) do
                    local _, name,_, icon2, _, classFile= GetSpecializationInfoByID(specID)
                    if icon2 and classFile then
                        specA = specA..((class and class~=classFile) and '  ' or '')..'|T'..icon2..':0|t'
                        class=classFile
                        tips= tips..'|n|T'..icon2..':0|t'..e.cn(name)
                    end
                end
                if specA~='' then
                    itemText= (itemText or '')..specA
                end

            end
            --物品是否收集, 返回图标, 幻化
            local item, collected, isSelf = WoWTools_CollectedMixin:Item(btn.link, nil, true)
            if item and not collected then
                itemText= (itemText or '')..item
                tips= tips and tips..'|n|n' or ''
                tips= tips
                    ..item
                    ..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
                    ..(not isSelf and ' |cffffffff'..(e.onlyChinese and '其他职业' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, CLASS))..'|r' or '')
            end
        else
            local itemID= btn.itemID or C_Item.GetItemInfoInstant(btn.link)
            if itemID then
                itemText= WoWTools_CollectedMixin:Mount(nil, itemID)--坐骑物品
                itemText= itemText or select(3, WoWTools_CollectedMixin:Pet(nil, itemID, true))--宠物物品
                itemText= itemText or WoWTools_CollectedMixin:Toy(itemID)--玩具,是否收集
            end
        end

        local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=btn.link, text={ITEM_CLASSES_ALLOWED, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT}, red=true})--物品提示，信息 format(ITEM_CLASSES_ALLOWED, '(.+)') --"职业：%s"
        classText= dateInfo.text[ITEM_CLASSES_ALLOWED]
        upText= dateInfo.text[ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT]
        if classText then
            if WoW_Tools_Chinese_CN then--汉化

                classText= string.gsub(classText..', ', '(.-), ', function(a)
                    local b= e.cn(a)
                    if b then
                        return b..' '
                    end
                end)
            end
            local className= UnitClass('player')
            local locaClass= className and not classText:find(className) or dateInfo.red

            if locaClass then
                classText =  '|cff9e9e9e'..classText..'|r'
            end
        end

    end

    if itemText and not btn.itemText then
        btn.itemText= WoWTools_LabelMixin:Create(btn, {mouse=true, fontName='GameFontBlack', notFlag=true, color={r=0.25, g=0.1484375, b=0.02}, notShadow=true, layer='OVERLAY'})
        btn.itemText:SetPoint('TOPRIGHT', -10,-4)
        btn.itemText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
        btn.itemText:SetScript('OnEnter', function(self)
            if self.tips then
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddLine(self.tips)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                e.tips:Show()
            end
            self:SetAlpha(0.3)
        end)
    end
    if btn.itemText then
        btn.itemText:SetText(itemText or '')
        btn.itemText.tips= tips
    end

    --拾取, 职业
    if classText and not btn.classLable then
        btn.classLable= WoWTools_LabelMixin:Create(btn, {fontName='GameFontBlack', notFlag=true, color={r=0.25, g=0.1484375, b=0.02}, notShadow=true, layer='OVERLAY'})
        btn.classLable:SetPoint('BOTTOM', btn.IconBorder, 'BOTTOMRIGHT', 140, 4)--<Size x="321" y="45"/>
    end
    if btn.classLable then
        btn.classLable:SetText(classText or '')
    end

    if upText and not btn.upText then
        btn.upText= WoWTools_LabelMixin:Create(btn, {fontName='GameFontBlack', notFlag=true, color={r=0.25, g=0.1484375, b=0.02}, notShadow=true, layer='OVERLAY'})
        btn.upText:SetPoint('TOPRIGHT', -10,-16)
    end
    if btn.upText then
        btn.upText:SetText(upText or '')
    end

    --显示, 物品, 属性
    WoWTools_ItemStatsMixin:SetItem(btn, not Save().hideEncounterJournal and btn.link, {point= btn.IconBorder})

    local spellID--物品法术，提示
    if (btn.link or btn.itemID) and not Save().hideEncounterJournal then
        spellID= select(2, C_Item.GetItemSpell(btn.link or btn.itemID))
        if spellID and not btn.spellTexture then
            btn.spellTexture= btn:CreateTexture(nil, 'OVERLAY')
            btn.spellTexture:SetSize(16,16)
            btn.spellTexture:SetPoint('LEFT', btn.IconBorder, 'RIGHT',-6,0)
            btn.spellTexture:SetScript('OnMouseDown', function(self)
                if self.spellID then
                    WoWTools_ChatMixin:Chat( C_Spell.GetSpellLink(self.spellID) or self.spellID, nil, true)
                end
            end)
            btn.spellTexture:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.spellTexture:SetScript('OnEnter', function(self)
                if self.spellID then
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetSpellByID(self.spellID)
                    e.tips:Show()
                end
                self:SetAlpha(0.5)
            end)
        end
    end
    if btn.spellTexture then
        btn.spellTexture.spellID= spellID
        btn.spellTexture:SetShown(spellID and true or false)
        if spellID then
            e.LoadData({id=spellID, type='spell'})
            SetPortraitToTexture(btn.spellTexture, C_Spell.GetSpellTexture(spellID) or 'soulbinds_tree_conduit_icon_utility')
        end
    end
end














--Blizzard_EncounterJournal.lua
function WoWTools_EncounterMixin:Init_EncounterJournalItemMixin()--Boss, 战利品, 信息
    hooksecurefunc(EncounterJournalItemMixin, 'Init', Init)
end