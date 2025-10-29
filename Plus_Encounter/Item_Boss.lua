--Boss, 战利品, 信息

local function Save()
    return WoWToolsSave['Adventure_Journal']
end
local ITEM_CLASSES_ALLOWED= format(ITEM_CLASSES_ALLOWED, '(.+)')
local ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"









local function Init(btn)
    if not btn:IsVisible() then
       return
    end

    local itemText--专精图标, 幻化，坐骑，宠物
    local tips--itemText提示用
    local classText--物品专精
    local upText--升级：

    local show= not Save().hideEncounterJournal

    if show and btn.link then
        local slotText= btn.slot and btn.slot:GetText() or ''--是装备物品
        if slotText~='' then
            local specTable = C_Item.GetItemSpecInfo(btn.link) or {}--专精图标
            local specTableNum=#specTable
            if specTableNum>0 then
                local specA=''
                local class
                table.sort(specTable, function (a2, b2) return a2<b2 end)
                tips= WoWTools_DataMixin.onlyChinese and '拾取专精' or format(PROFESSIONS_SPECIALIZATION_TITLE, UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT )
                for _,  specID in pairs(specTable) do
                    local _, name,_, icon2, _, classFile= GetSpecializationInfoByID(specID)
                    if icon2 and classFile then
                        specA = specA..((class and class~=classFile) and '  ' or '')..'|T'..icon2..':0|t'
                        class=classFile
                        tips= tips..'|n|T'..icon2..':0|t'..WoWTools_TextMixin:CN(name)
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
                    ..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
                    ..(not isSelf and ' |cffffffff'..(WoWTools_DataMixin.onlyChinese and '其他职业' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, CLASS))..'|r' or '')
            end
        else
            local itemID= btn.itemID or C_Item.GetItemInfoInstant(btn.link)
            if itemID then
                itemText= WoWTools_CollectedMixin:Mount(nil, itemID)--坐骑物品
                itemText= itemText or select(3, WoWTools_PetBattleMixin:Collected(nil, itemID, true))--宠物物品
                itemText= itemText or WoWTools_CollectedMixin:Toy(itemID)--玩具,是否收集
            end
        end

        local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=btn.link, text={ITEM_CLASSES_ALLOWED, ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT}})--物品提示，信息 format(ITEM_CLASSES_ALLOWED, '(.+)') --"职业：%s"
        classText= dateInfo.text[ITEM_CLASSES_ALLOWED]
        upText= dateInfo.text[ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT]
        if classText then
            if WoWTools_ChineseMixin then--汉化
                classText= (classText..PLAYER_LIST_DELIMITER):gsub('.-'..PLAYER_LIST_DELIMITER, function(a)
                    return WoWTools_TextMixin:CN(a)
                end)
            end
            local class=UnitClass('player')
            if not classText:find(class) then
                classText= '|cff9e9e9e'..classText..'|r'
            end
        end
    end

    if not btn.itemText then
        btn.itemText= WoWTools_LabelMixin:Create(btn, {mouse=true})--, color={r=1, g=1, b=1}})
        btn.itemText:SetPoint('BOTTOMRIGHT', btn.armorType, 'TOPRIGHT', 0, 2)
        btn.itemText:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
        btn.itemText:SetScript('OnEnter', function(self)
            if self.tips then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self.tips)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
                GameTooltip:Show()
            end
            self:SetAlpha(0.3)
        end)

        btn.upText= WoWTools_LabelMixin:Create(btn)--, { color={r=1, g=1, b=1}})
        btn.upText:SetPoint('BOTTOMRIGHT', btn.itemText, 'TOPRIGHT', 0, 2)

--调整位置
        btn.name:SetPoint('TOPLEFT', btn.icon, 'TOPRIGHT', 7, -11)
        btn.slot:ClearAllPoints()
        btn.slot:SetPoint('TOPLEFT', btn.name, 'BOTTOMLEFT', 0, -4)
        btn.classLabel= WoWTools_LabelMixin:Create(btn)
        btn.classLabel:SetPoint('BOTTOMLEFT', btn.name, 'TOPLEFT', 0 ,2)

        btn.spellTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
        btn.spellTexture:SetSize(16,16)
        btn.spellTexture:SetPoint('LEFT', btn.IconBorder, 'RIGHT', -10, 0)
        btn.spellTexture:SetScript('OnMouseDown', function(self)
            if self.spellID then
                WoWTools_ChatMixin:Chat( C_Spell.GetSpellLink(self.spellID) or self.spellID, nil, true)
            end
        end)
        btn.spellTexture:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
        btn.spellTexture:SetScript('OnEnter', function(self)
            if self.spellID then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(self.spellID)
                GameTooltip:Show()
            end
            self:SetAlpha(0.5)
        end)
    end

    btn.itemText:SetText(itemText or '')
    btn.itemText.tips= tips


    --拾取, 职业
    if classText and WoWTools_ChineseMixin then
        classText= classText:gsub('(.-),', function(t)
            local a= WoWTools_TextMixin:CN(t:gsub('^ ', ''))
            if a and a~=t then
                return a..', '
            end
        end)
    end
    btn.classLabel:SetText(classText or '')
    btn.upText:SetText(upText or '')

--显示, 物品, 属性
    WoWTools_ItemMixin:SetItemStats(btn, show and btn.link, {point= btn.IconBorder})

--物品法术，提示
    local spellID
    if show and (btn.link or btn.itemID) then
        spellID= select(2, C_Item.GetItemSpell(btn.link or btn.itemID))
    end

    btn.spellTexture.spellID= spellID
    btn.spellTexture:SetShown(spellID and true or false)
    if spellID then
       WoWTools_DataMixin:Load(spellID, 'spell')
        SetPortraitToTexture(btn.spellTexture, C_Spell.GetSpellTexture(spellID) or 'soulbinds_tree_conduit_icon_utility')
    end
end














--Blizzard_EncounterJournal.lua
function WoWTools_EncounterMixin:Init_EncounterJournalItemMixin()--Boss, 战利品, 信息
    WoWTools_DataMixin:Hook(EncounterJournalItemMixin, 'Init', Init)
end