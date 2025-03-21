--BOSS战时, 指定拾取, 专精
local e= select(2, ...)
local function Save()
    return WoWTools_EncounterMixin.Save
end
local Frame












local function set_Loot_Spec_Texture(self)
    if self.dungeonEncounterID then
        local specID=Save().loot[e.Player.class][self.dungeonEncounterID]
        local icon= specID and select(4, GetSpecializationInfoByID(specID))
        if icon then
            self.texture:SetTexture(icon)
        else
            self.texture:SetAtlas(e.Icon.icon)
        end
        self:SetAlpha(icon and 1 or 0.3)
    else
        self.texture:SetTexture(0)
    end
    self:SetShown(self.dungeonEncounterID)
end















local function Init_All_Class(self, root, num)
    local sub, sub2, n, col
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
                (WoWTools_UnitMixin:GetClassIcon(nil, classInfo.classFile) or '')
                ..col
                ..e.cn(classInfo.className)
                ..(e.Player.class==classInfo.classFile and '|A:auctionhouse-icon-favorite:0:0|a' or '')
                ..(n==0 and '' or ' '..n),
            function()
                return MenuResponse.Open
            end)

            for dungeonEncounterID, specID in pairs(Save().loot[classInfo.classFile]) do
                sub2=sub:CreateCheckbox(
                    '|T'..( select(4,  GetSpecializationInfoByID(specID)) or 0)..':0|t'
                    ..col
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
                    tooltip:AddLine(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                end)
            end
            if n>0 then
                sub:CreateDivider()
                sub:CreateButton(
                    '|A:bags-button-autosort-up:0:0|a'
                    ..(n==0 and '|cff9e9e9e' or '')
                    ..(e.onlyChinese and '全部清除' or CLEAR_ALL)..' '..n,
                function(data)
                    Save().loot[data.class]={}
                end, {class=classInfo.classFile})
                WoWTools_MenuMixin:SetGridMode(sub, n)
            end
        end
    end

    root:CreateDivider()
    root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(num==0 and '|cff9e9e9e' or '')
        ..(e.onlyChinese and '全部清除' or CLEAR_ALL)..' '..num,
    function()
        Save().loot={[e.Player.class]={}}
    end)
end










local function Init_Menu(self, root)
    if not self.dungeonEncounterID then
        return
    end
    local sub, num

    local curSpec= GetSpecialization()
    for specIndex= 1, GetNumSpecializations() do
        local specID, name, _ , icon= GetSpecializationInfo(specIndex)
        if icon and specID and name then
            sub=root:CreateCheckbox(
                '|T'..(icon or 0)..':0|t'
                ..e.Player.col
                ..e.cn(name)
                ..(curSpec==specIndex and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
            function(data)
                return Save().loot[e.Player.class][data.dungeonEncounterID]== data.specID
            end, function(data)
                if not Save().loot[e.Player.class][data.dungeonEncounterID] or Save().loot[e.Player.class][data.dungeonEncounterID]~= data.specID then
                    Save().loot[e.Player.class][data.dungeonEncounterID]=data.specID
                else
                    Save().loot[e.Player.class][data.dungeonEncounterID]=nil
                end
                set_Loot_Spec_Texture(self)
            end, {dungeonEncounterID= self.dungeonEncounterID, specID=specID})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddDoubleLine(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION, description.data.specID)
            end)
        end
    end
    
    root:CreateDivider()
    sub=root:CreateTitle(e.cn(self.name, {journalEncounterID=self.journalEncounterID})..' '..self.dungeonEncounterID)


    num=0
    for _, tab in pairs(Save().loot) do
        for _ in pairs(tab) do
            num= num+1
        end
    end
    sub=root:CreateButton(
        (e.onlyChinese and '职业' or CLASS)..(num==0 and ' |cff9e9e9e' or ' ')..num,
    function()
        return MenuResponse.Open
    end)
    Init_All_Class(self, sub, num)
    
end









local function Button_OnEnter(self)
    if not Save().hideEncounterJournal and self.encounterID then
        local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfo(self.encounterID)--button.index= button.GetOrderIndex()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        local cnName= e.cn(name2, true)
        GameTooltip:AddDoubleLine(cnName and cnName..' '..name2 or name2,  'journalEncounterID: '..'|cnGREEN_FONT_COLOR:'..(journalEncounterID or self.encounterID)..'|r')
        GameTooltip:AddDoubleLine(instanceID2 and 'instanceID: '..instanceID2 or ' ', (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID or ' ')
        if dungeonEncounterID then
            GameTooltip:AddDoubleLine('dungeonEncounterID: |cffff00ff'..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
            local numKill=Save().wowBossKill[dungeonEncounterID]
            if numKill then
                GameTooltip:AddDoubleLine(e.onlyChinese and '击杀' or KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
            end
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_EncounterMixin.addName)
        GameTooltip:Show()
    end
end








local function set_Loot_Spec(button)
    if not button.LootButton then
        button.LootButton= WoWTools_ButtonMixin:Menu(button, {isType2=true, size=26, icon='hide'})
        button.LootButton:SetPoint('LEFT', button, 'RIGHT', -3, 0)
        button.LootButton:SetupMenu(Init_Menu)

        if not button.OnEnter then
            button:SetScript('OnLeave', GameTooltip_Hide)
            button:SetScript('OnEnter', Button_OnEnter)
        else
            button:HookScript('OnEnter', Button_OnEnter)
        end
    end
    
    local name, _, journalEncounterID, _, _, _, dungeonEncounterID
    if button.encounterID then
        name, _, journalEncounterID, _, _, _, dungeonEncounterID= EJ_GetEncounterInfo(button.encounterID)
    end
    
    button.LootButton.dungeonEncounterID= dungeonEncounterID
    button.LootButton.journalEncounterID= journalEncounterID
    button.LootButton.name= name

    set_Loot_Spec_Texture(button.LootButton)

    button.LootButton:SetShown(not Save().hideEncounterJournal and dungeonEncounterID)
end















local function Init_ScrollBox(frame)
    if not frame:GetView() then
        return
    end
    for _, button in pairs(frame:GetFrames()) do

        set_Loot_Spec(button)
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
            local indicatoSpec=Save().loot[e.Player.class][arg1]
            if indicatoSpec then
                local loot = GetLootSpecialization()
                local spec = GetSpecialization()
                spec= spec and GetSpecializationInfo(spec)
                local loot2= loot==0 and spec or loot
                if loot2~= indicatoSpec then
                    self.SpceLog= loot--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
                    SetLootSpecialization(indicatoSpec)
                    local _, name, _, icon, role = GetSpecializationInfoByID(indicatoSpec)
                    print(e.Icon.icon2..WoWTools_EncounterMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
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
                print(e.Icon.icon2..WoWTools_EncounterMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
                self.SpceLog=nil
            end
        end
    end)


    Frame:set_event()
end













function WoWTools_EncounterMixin:Specialization_Loot_SetEvent()
    if Frame then
        Frame:set_event()
    end
end

function WoWTools_EncounterMixin:Init_Specialization_Loot()
    Init()
    hooksecurefunc(EncounterJournal.encounter.info.BossesScrollBox, 'SetScrollTargetOffset', Init_ScrollBox)
end
