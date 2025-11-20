local function Save()
    return WoWToolsSave['Adventure_Journal']
end

local ITEM_CLASSES_ALLOWED= format(ITEM_CLASSES_ALLOWED, '(.+)')
local ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"










--BOSS 列表 按钮
local function Create_BossButtonList(btn)
--索引
    btn.indexLabel= btn:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed3')
    btn.indexLabel:SetPoint('TOPRIGHT', -8, -7)
    btn.indexLabel:SetTextColor(0.827, 0.659, 0.463)
    btn.indexLabel:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    btn.indexLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '索引' or 'index')
            ..' |cffffffff'..(self:GetText() or '')
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    btn.killedLabel= btn:CreateFontString(nil, 'OVERLAY', 'GameFontNormalMed3')
    btn.killedLabel:SetTextColor(0.827, 0.659, 0.463)
    btn.killedLabel:SetPoint('RIGHT', btn.indexLabel, 'LEFT', -5, 0)
    btn.killedLabel:EnableMouse(true)
    btn.killedLabel:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    btn.killedLabel:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(
            WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED)
            ..' |cffffffff'..(self:GetText() or '')
        )
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)
--全部清除
    btn.killedLabel:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self:GetParent(), function(_, root)
            local num= 0
            for _ in pairs(WoWToolsPlayerDate['BossKilled']) do
                num= num+1
            end
            root:CreateButton(
                WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
            function()
                StaticPopup_Show('WoWTools_OK',
                    '|A:bags-button-autosort-up:0:0|a|cnWARNING_FONT_COLOR:'
                    ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
                    ..'|r|n|n'
                    ..(WoWTools_DataMixin.onlyChinese and '击败首领：记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LFG_LIST_BOSSES_DEFEATED, EVENTTRACE_LOG_HEADER)),
                    nil,
                    {SetValue=function()
                    WoWToolsPlayerDate['BossKilled']={}
                        WoWTools_DataMixin:Call('EncounterJournal_Refresh')
                    end}
                )
                return MenuResponse.Open
            end)
        end)
    end)

--增加 OnEnter
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if not self.encounterID then
            return
        end

        local bossName, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID= EJ_GetEncounterInfo(self.encounterID)--button.index= button.GetOrderIndex()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")

        local cn= WoWTools_TextMixin:CN(bossName) or bossName
        bossName= cn~=bossName and cn..' '..bossName or bossName or self.encounterID
        GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..bossName)
--journalEncounterID journalInstanceID
        journalEncounterID= journalEncounterID or self.encounterID
        GameTooltip:AddDoubleLine('journalEncounterID |cffffffff'..journalEncounterID, journalInstanceID  and 'journalInstanceID |cffffffff'..journalInstanceID)
--instanceID sectionID
        GameTooltip:AddDoubleLine(instanceID and 'instanceID |cffffffff'..instanceID or ' ', rootSectionID  and 'sectionID |cffffffff'..rootSectionID)

        if dungeonEncounterID then
            GameTooltip:AddDoubleLine('encounterID |cffffffff'..dungeonEncounterID)
            local numKill=WoWToolsPlayerDate['BossKilled'][dungeonEncounterID] or 0
--已击败
            GameTooltip:AddLine(
                format(WoWTools_DataMixin.onlyChinese and '%s（|cffffffff%d|r次）' or REAGENT_COST_CONSUME_CHARGES,
                WoWTools_DataMixin.onlyChinese and '已击败' or DUNGEON_ENCOUNTER_DEFEATED,
                numKill)
            )
        end
        GameTooltip:Show()
    end)
end
















--Boss, 战利品, 物品信息
local function Create_LootItems(btn)
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



























local function Init()
    if Save().hideEncounterJournal then
        return
    end


--BOSS 列表 按钮
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(self, data)
        if not data.bossID then
            return
        end

        if not self.indexLabel then
            Create_BossButtonList(self)
        end

        self.indexLabel:SetText(data.index or '')
        local encounterID= select(7, EJ_GetEncounterInfo(data.bossID))
        local numKill=WoWToolsPlayerDate['BossKilled'][encounterID] or 0
        if numKill>0 then
            self.killedLabel:SetFormattedText(WoWTools_DataMixin.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, numKill)
        else
            self.killedLabel:SetText('')
        end
    end)














--综述,小地图提示
    EncounterJournal.encounter.instance.mapButton:SetScript('OnLeave', GameTooltip_Hide)
    EncounterJournal.encounter.instance.mapButton:SetScript('OnEnter', function(self)
        local name, description, bgImage, buttonImage1, loreImage, buttonImage2, dungeonAreaMapID, link, _, mapID= EJ_GetInstanceInfo()
        if not name then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(
            link or name,
            (dungeonAreaMapID and 'uiMapID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..dungeonAreaMapID..'|r' or '')
            ..(mapID and ' instanceID'..WoWTools_DataMixin.Icon.icon2..'|cffffffff'..mapID..'|r' or '')
        )
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(description, nil,nil,nil, true)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(bgImage and '|T'..bgImage..':26|t'..bgImage, loreImage and '|T'..loreImage..':26|t'..loreImage)
        GameTooltip:AddDoubleLine(buttonImage1 and '|T'..buttonImage1..':26|t'..buttonImage1, buttonImage2 and '|T'..buttonImage2..':26|t'..buttonImage2)
        --GameTooltip:AddLine(' ')
        --GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
    end)












--Boss, 战利品, 物品信息
    WoWTools_DataMixin:Hook(EncounterJournalItemMixin, 'Init', function(btn)
        local itemText--专精图标, 幻化，坐骑，宠物
        local tips--itemText提示用
        local classText--物品专精
        local upText--升级：

        if btn.link then

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
                    classText= '|cff626262'..classText..'|r'
                end
            end
        end
        if not btn.itemText then
            Create_LootItems(btn)
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
    end)





















--技能提示，OnEnter, OnMouseDown发超链接
    WoWTools_DataMixin:Hook('EncounterJournal_UpdateButtonState', function(frame)
        WoWTools_DataMixin:Load(frame:GetParent().spellID, 'spell')
        if frame.isHooked then
            return
        end
        frame:HookScript("OnEnter", function(self)
            local p= self:GetParent()
            local spellID= p.spellID or 0--self3.link    
            local sectionID= p.myID
            if spellID<1 then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(spellID)
            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.Icon.right
                ..'|cnGREEN_FONT_COLOR:<'
                ..(WoWTools_DataMixin.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT)
                ..'>|r'
                ..(IsInGroup() and '|A:communities-icon-chat:0:0|a' or '')
            )
            if sectionID then
                local difficulty= EJ_GetDifficulty()
                GameTooltip:AddDoubleLine(
                    NORMAL_FONT_COLOR:WrapTextInColorCode('sectionID')..'|cffffffff'..WoWTools_DataMixin.Icon.icon2..sectionID,
                    difficulty and 'difficulty|cffffffff'..WoWTools_DataMixin.Icon.icon2..difficulty or WoWTools_EncounterMixin.addName
                )
            else
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
            end
            GameTooltip:Show()
        end)
        frame:HookScript('OnMouseDown', function(self, d)
            local spellID= d=='RightButton' and self:GetParent().spellID or 0
            if spellID>0 then
                local link= C_Spell.GetSpellLink(spellID) or spellID
                WoWTools_ChatMixin:Chat(link, nil, not IsInGroup())
            end
        end)
        frame.isHooked=true
    end)













--Boss技能加图标
    local function Add_SpellIcon(text)
        local find
        text=text:gsub('|Hspell:.-]|h',function(link)
            local texture= link:match('Hspell:(%d+)')
            if texture then
                local icon= C_Spell.GetSpellTexture(texture)
                if icon then
                    find=true
                    return '|T'..icon..':0|t'..link
                end
            end
        end)
        if find then
            return text
        end
    end
    WoWTools_DataMixin:Hook('EncounterJournal_SetBullets', function(object, description)
        if not string.find(description, "%$bullet") then
            local text=Add_SpellIcon(description)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight())
            end
            return
        end
        local desc = strtrim(string.match(description, "(.-)%$bullet"))
        if (desc) then
            local text=Add_SpellIcon(desc)
            if text then
                object.Text:SetText(text)
                object:SetHeight(object.Text:GetContentHeight())
            end
        end
        local bullets = {}
        local k = 1
        local parent = object:GetParent()
        for v in string.gmatch(description,"%$bullet([^$]+)") do
            tinsert(bullets, v)
        end
        for j = 1,#bullets do
            local text = strtrim(bullets[j]).."|n|n"
            if (text and text ~= "") then
                text=Add_SpellIcon(text)
                local bullet = parent.Bullets and parent.Bullets[k]
                if text and bullet then
                    bullet.Text:SetText(text)
                    if (bullet.Text:GetContentHeight() ~= 0) then
                        bullet:SetHeight(bullet.Text:GetContentHeight())
                    end
                end
                k = k + 1
            end
        end
    end)














--BOSS模型
    WoWTools_DataMixin:Hook('EncounterJournal_DisplayCreature', function(self)
        local text=''
        local model= EncounterJournal.encounter.info.model
        if not model.creatureDisplayIDText then
            model.creatureDisplayIDText= model:CreateFontString(nil, nil, 'QuestTitleFontBlackShadow')
            model.creatureDisplayIDText:SetPoint('BOTTOM', model.imageTitle, 'TOP', 0 , 20)
        end
        if EncounterJournal.iconImage  then
            text= text..'|T'..EncounterJournal.iconImage..':0|t'..EncounterJournal.iconImage..'|n'
        end
        if self.id then
            text= text..'JournalEncounterCreatureID '.. self.id..'|n'
        end
        if self.uiModelSceneID  then
            text= text..'uiModelSceneID '..self.uiModelSceneID..'|n'
        end
        text= text..'CreatureDisplayID ' .. self.displayInfo
        local name= WoWTools_TextMixin:CN(self.name, true)--汉化
        if name then
            text= text..'|n'..name
        end
        model.creatureDisplayIDText:SetText(text)
    end)












--贸易站 任务，提示
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'ShowTooltip', function(self)
        local data = self:GetData()
        local id= data and data.ID
        if not id then
            return
        end
        GameTooltip:AddLine(
            '|cnGREEN_FONT_COLOR:<'
            ..(WoWTools_DataMixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)..WoWTools_DataMixin.Icon.right
            ..'>'
        )
        GameTooltip:AddLine(
            'perksActivityID|cffffffff'
            ..WoWTools_DataMixin.Icon.icon2
            ..id
        )
        GameTooltip:Show()
    end)
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'OnClick', function(self, d)
        local data = self:GetData()
        local id= data and data.ID
        if id and d=='RightButton' then
            local link=C_PerksActivities.GetPerksActivityChatLink(id)
            WoWTools_ChatMixin:Chat(link, nil, true)
        end
    end)
    WoWTools_DataMixin:Hook(MonthlyActivitiesButtonMixin, 'Init', function(self)
        self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    end)










--套装, 收集数
    WoWTools_DataMixin:Hook(LootJournalItemSetButtonMixin, 'Init', function(frame, data)
        local text
        if not frame.setNum then
            frame.setNum= WoWTools_LabelMixin:Create(frame)
            frame.setNum:SetPoint('RIGHT', frame.SetName)
        end
        if data and data.setID then
            text= WoWTools_CollectedMixin:SetID(data.setID, true)--套装, 收集数
        end
        for _, btn in pairs(frame.ItemButtons or {}) do
            if btn.itemID then
                if C_Item.IsItemDataCachedByID(btn.itemID) then
                    WoWTools_ItemMixin:SetItemStats(btn, btn.itemLink, {hideLevel=true, hideSet=true, itemID=btn.itemID})
                else
                    C_Timer.After(1, function()
                        WoWTools_ItemMixin:SetItemStats(btn, btn.itemLink, {hideLevel=true, hideSet=true})
                    end)
                end
            end
        end
        frame.setNum:SetText(text or '')
    end)

--套装信息 物品信息 LootJournalItemSetsMixin
    WoWTools_DataMixin:Hook(EncounterJournal.LootJournalItems.ItemSetsFrame, 'ConfigureItemButton', function(_, btn)
        WoWTools_ItemMixin:SetItemStats(btn, btn.itemLink, {
            itemID=btn.itemID,
            hideLevel=true,
            hideSet=true
        })
    end)










    Init=function()end
end






function WoWTools_EncounterMixin:Init_Plus()
    Init()
end