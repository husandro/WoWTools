--BOSS战时, 指定拾取, 专精

local function Save()
    return WoWToolsSave['Adventure_Journal']
end
local Frame












local function set_Loot_Spec_Texture(self)
    if self.dungeonEncounterID then
        local specID=Save().loot[WoWTools_DataMixin.Player.Class][self.dungeonEncounterID]
        local icon= specID and select(4, GetSpecializationInfoByID(specID))
        self.texture:SetTexture(icon or 'Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        self.texture:SetAlpha(icon and 1 or 0.3)
    end
    self:SetShown(self.dungeonEncounterID)
end















local function Init_All_Class(_, root, num)
    local sub, sub2, n, col, name
    for class= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(class)
        if classInfo and classInfo.classFile then
            Save().loot[classInfo.classFile]= Save().loot[classInfo.classFile] or {}

            col= '|c'..select(4, GetClassColor(classInfo.classFile))
            n=0
            for _ in pairs(Save().loot[classInfo.classFile]) do
                n= n+1
            end

            sub=root:CreateButton(
                (WoWTools_UnitMixin:GetClassIcon(nil, nil, classInfo.classFile) or '')
                ..col
                ..WoWTools_TextMixin:CN(classInfo.className)
                ..(WoWTools_DataMixin.Player.Class==classInfo.classFile and '|A:auctionhouse-icon-favorite:0:0|a' or '')
                ..(n==0 and '' or ' '..n),
            function()
                return MenuResponse.Open
            end)

            for dungeonEncounterID, specID in pairs(Save().loot[classInfo.classFile]) do
                sub2=sub:CreateCheckbox(
                    '|T'..( select(4,  GetSpecializationInfoByID(specID)) or 0)..':0|t'
                    ..col
                    --..WoWTools_TextMixin:CN(self.name, {journalEncounterID=self.journalEncounterID, isName=true}
                    ..dungeonEncounterID,
                function(data)
                    return Save().loot[data.class][data.dungeonEncounterID]==data.specID
                end, function(data)
                    Save().loot[data.class][data.dungeonEncounterID]= not Save().loot[data.class][data.dungeonEncounterID] and data.specID or nil
                end, {
                    dungeonEncounterID=dungeonEncounterID,
                    class=classInfo.classFile,
                    specID=specID,
                })
                sub2:SetTooltip(function(tooltip)
                    tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                end)
            end
            if n>0 then
                sub:CreateDivider()
                name= '|A:bags-button-autosort-up:0:0|a'
                    ..(n==0 and '|cff626262' or '')
                    ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..' '..n
                sub:CreateButton(
                    name,
                function(data)
                    StaticPopup_Show('WoWTools_OK',
                    data.name,
                    nil,
                    {SetValue=function()
                        Save().loot[data.class]={}
                    end})
                    return MenuResponse.Open
                end, {class=classInfo.classFile, name=name})

                WoWTools_MenuMixin:SetScrollMode(sub)
            end
        end
    end

    root:CreateDivider()
    name= '|A:bags-button-autosort-up:0:0|a'
        ..(num==0 and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)..' '..num
    root:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        data.name,
        nil,
        {SetValue=function()
            Save().loot={[WoWTools_DataMixin.Player.Class]={}}
        end})
        return MenuResponse.Open
    end, {name=name})
end










local function Init_Menu(self, root)
    if not self.dungeonEncounterID or not self:IsMouseOver() then
        return
    end
    local sub, num

    local curSpec= GetSpecialization()
    for specIndex= 1, GetNumSpecializations() do
        local specID, name, _ , icon= GetSpecializationInfo(specIndex)
        if icon and specID and name then
            sub=root:CreateRadio(
                '|T'..(icon or 0)..':0|t'
                ..WoWTools_DataMixin.Player.col
                ..WoWTools_TextMixin:CN(name)
                ..(curSpec==specIndex and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
            function(data)
                return Save().loot[WoWTools_DataMixin.Player.Class][data.dungeonEncounterID]== data.specID
            end, function(data)
                if not Save().loot[WoWTools_DataMixin.Player.Class][data.dungeonEncounterID] or Save().loot[WoWTools_DataMixin.Player.Class][data.dungeonEncounterID]~= data.specID then
                    Save().loot[WoWTools_DataMixin.Player.Class][data.dungeonEncounterID]=data.specID
                else
                    Save().loot[WoWTools_DataMixin.Player.Class][data.dungeonEncounterID]=nil
                end
                set_Loot_Spec_Texture(self)
                return MenuResponse.Refresh
            end, {dungeonEncounterID= self.dungeonEncounterID, specID=specID})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION, description.data.specID)
            end)
        end
    end

    root:CreateDivider()

    sub=root:CreateTitle((WoWTools_TextMixin:CN(self.name, {journalEncounterID=self.journalEncounterID, isName=true}) or self.name)..' '..self.dungeonEncounterID)


    num=0
    for _, tab in pairs(Save().loot) do
        for _ in pairs(tab) do
            num= num+1
        end
    end
    sub=root:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '职业' or CLASS)..(num==0 and ' |cff626262' or ' ')..num,
    function()
        return MenuResponse.Open
    end)
    Init_All_Class(self, sub, num)

end









local function Button_OnEnter(self)
    if not Save().hideEncounterJournal and self.encounterID then
        local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfo(self.encounterID)--button.index= button.GetOrderIndex()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        --GameTooltip:ClearLines()
        local cnName= WoWTools_TextMixin:CN(name2, true)
        GameTooltip:SetText(cnName and cnName..' '..name2 or name2)
        GameTooltip:AddLine(' ')

        journalEncounterID= journalEncounterID or self.encounterID
        if journalEncounterID then
            GameTooltip:AddLine('journalEncounterID:|cnGREEN_FONT_COLOR:'..(journalEncounterID or self.encounterID)..'|r')
        end

        GameTooltip:AddDoubleLine(instanceID2 and 'instanceID: '..instanceID2 or ' ', (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID)
        if dungeonEncounterID then
            GameTooltip:AddDoubleLine('dungeonEncounterID: |cffff00ff'..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
            local numKill=Save().wowBossKill[dungeonEncounterID]
            if numKill then
                GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '击杀' or KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..(WoWTools_DataMixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
            end
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
    end
end


























local function Init()
    Frame= CreateFrame('Frame')

    function Frame:set_event()
        if Save().hideEncounterJournal then
            Frame:UnregisterEvent('ENCOUNTER_START')
            Frame:UnregisterEvent('ENCOUNTER_END')
        else
            Frame:RegisterEvent('ENCOUNTER_START')
            Frame:RegisterEvent('ENCOUNTER_END')
        end
    end

    Frame:SetScript('OnEvent', function(self, event, arg1)
        if event=='ENCOUNTER_START' and arg1 then--BOSS战时, 指定拾取, 专精
            local indicatoSpec=Save().loot[WoWTools_DataMixin.Player.Class][arg1]
            if indicatoSpec then
                local loot = GetLootSpecialization()
                local spec = GetSpecialization()
                spec= spec and GetSpecializationInfo(spec)
                local loot2= loot==0 and spec or loot
                if loot2~= indicatoSpec then
                    self.SpceLog= loot--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
                    SetLootSpecialization(indicatoSpec)
                    local _, name, _, icon, role = GetSpecializationInfoByID(indicatoSpec)
                    print(
                        WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r',
                        WoWTools_DataMixin.Icon[role] or '',
                        icon and '|T'..icon..':0|t' or '',
                        name and '|cffff00ff'..WoWTools_TextMixin:CN(name) or ''
                    )
                end
            end

        elseif event=='ENCOUNTER_END' then--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
            if self.SpceLog  then
                SetLootSpecialization(self.SpceLog)
                if self.SpceLog==0 then
                    local spec = GetSpecialization()
                    self.SpceLog= spec and GetSpecializationInfo(spec) or self.SpceLog
                end
                local _, name, _, icon, role = GetSpecializationInfoByID(self.SpceLog)
                print(
                    WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r',
                    WoWTools_DataMixin.Icon[role] or '',
                    icon and '|T'..icon..':0|t' or '',
                    name and '|cffff00ff'..WoWTools_TextMixin:CN(name) or ''
                )
                self.SpceLog=nil
            end
        end
    end)

--BOSS 列表
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(btn, data)--{data={bossID index link rootSectionID, desctiption, name} }
        if not Save().hideEncounterJournal or not data or not data.bossID then
            if btn.LootButton then
                btn.LootButton:SetShown(false)
            end
        end
        
        if not btn.LootButton then
            btn.LootButton= CreateFrame('DropdownButton', nil, btn, 'WoWToolsMenu2Template')
                --WoWTools_ButtonMixin:Menu(btn, {isType2=true, size=26, icon='hide'})
            btn.LootButton:SetPoint('LEFT', btn, 'RIGHT', -5, 0)
            btn.LootButton:SetupMenu(Init_Menu)
            btn.LootButton:SetScript('OnHide', function(self)
                self.texture:SetTexture(0)
                self.dungeonEncounterID= nil
                self.journalEncounterID= nil
                self.name=nil
            end)
            if not btn:GetScript('OnEnter') then
                btn:SetScript('OnLeave', GameTooltip_Hide)
                btn:SetScript('OnEnter', Button_OnEnter)
            else
                btn:HookScript('OnEnter', Button_OnEnter)
            end

            btn.indexLabel= btn:CreateFontString(nil, nil, 'GameFontNormalMed3')
            btn.indexLabel:SetPoint('RIGHT', btn.LootButton, 'LEFT', -2, 0)
            btn.indexLabel:SetTextColor(0.827, 0.659, 0.463)
        end

        local name, _, journalEncounterID, _, _, _, dungeonEncounterID, index

        if btn.encounterID  then
            name, _, journalEncounterID, _, _, _, dungeonEncounterID= EJ_GetEncounterInfo(btn.encounterID)--data.bossID
            index= data and data.index
        end

        btn.LootButton.dungeonEncounterID= dungeonEncounterID
        btn.LootButton.journalEncounterID= journalEncounterID
        btn.LootButton.name= name

        set_Loot_Spec_Texture(btn.LootButton)

        btn.LootButton:SetShown(dungeonEncounterID)
        btn.indexLabel:SetText(index or '')

    end)

    --[[WoWTools_DataMixin:Hook(EncounterJournal.encounter.info.BossesScrollBox, 'SetScrollTargetOffset', function(...)
        Init_ScrollBox(...)
    end)]]

    Frame:set_event()
    Init=function()
        Frame:set_event()
    end
end














function WoWTools_EncounterMixin:Init_Specialization_Loot()
    Init()
end
