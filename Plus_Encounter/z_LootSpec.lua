--[[
LootSpec= {
    [encounterID] = {
        class={
                classFile= lootSpecID,
            },
        bossID= journalEncounterID,
        
    },
    ...
}

]]
local function Save()
    return WoWToolsSave['Adventure_Journal']
end






local function Init_Menu(self, root)
    if not self:IsMouseOver() or not self.journalInstanceID then
        return
    end
    local sub
    local curID= PlayerUtil.GetCurrentSpecID()
    local dungeonEncounterID= select(7, EJ_GetEncounterInfo(self.journalInstanceID))

    for specIndex= 1, C_SpecializationInfo.GetNumSpecializationsForClassID(self.classID) or 0 do
         local specID, name, _ , icon= GetSpecializationInfo(specIndex)
        if icon and specID and name then
            sub=root:CreateRadio(
                '|T'..(icon or 0)..':0|t'
                ..WoWTools_DataMixin.Player.col
                ..WoWTools_TextMixin:CN(name)
                ..(curID==specID and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
            function(data)
                    local d= Save().LootSpec[dungeonEncounterID]
                    return d and d[WoWTools_DataMixin.Player.Class]==data.specID

            end, function(data)
                Save().LootSpec[dungeonEncounterID]= Save().LootSpec[dungeonEncounterID] or {}
                Save().LootSpec[dungeonEncounterID][self.classFile]= data.specID
                self.settings(self)
                return MenuResponse.Refresh
            end, {dungeonEncounterID= self.dungeonEncounterID, specID=specID})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION, description.data.specID)
            end, {specID= specID, })
        end
    end
end





local function Init_Button(btn)
    btn.specButtons={}

    local index= 0

    for class= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(class)
        if classInfo and classInfo.classFile then
            local s= 20
            btn.specButtons[index]= CreateFrame('DropdownButton', nil, btn, 'WoWToolsMenu2Template')
            btn.specButtons[index]:SetSize(s,s)
            btn.specButtons[index]:SetFrameStrata('HIGH')
            btn.specButtons[index]:SetPoint('BOTTOMRIGHT', (-index*s)-5, -8)
            btn.specButtons[index].classID= classInfo.classID
            btn.specButtons[index].classFile= classInfo.classFile
            btn.specButtons[index].name= classInfo.name

            btn.specButtons[index].settings= function(self)--{bossID index link rootSectionID, desctiption, name}
            print(self.name, self.classFile)
                if not self.journalEncounterID then
                    return
                end
                --print(self.journalInstanceID )

                local  dungeonEncounterID= select(7, EJ_GetEncounterInfo(self.journalInstanceID))

                local data= dungeonEncounterID and Save().LootSpec[dungeonEncounterID]
                local lootSpecID= data and data[WoWTools_DataMixin.Player.Class]
                local icon= lootSpecID and select(4, GetSpecializationInfoByID(lootSpecID))

                if icon then
                    self.texture:SetTexture(icon)
                else
                    self.texture:SetAtlas(WoWTools_UnitMixin:GetClassIcon(nil, nil, self.classFile, {reAtlas=true}) or '')
                end

                self.texture:SetAlpha(icon and 1 or 0.5)
            end

            btn.specButtons[index]:SetupMenu(Init_Menu)
            index= index+1
        end
    end

    btn.indexLabel= btn:CreateFontString(nil, nil, 'GameFontNormalMed3')
    btn.indexLabel:SetPoint('TOPRIGHT', -5, -5)
    btn.indexLabel:SetTextColor(0.827, 0.659, 0.463)
end











--设置拾取专精
local function Set_LootSpec(self, encounterID)
    local data= Save().LootSpec[encounterID]
    local lootSpecID= data and data[WoWTools_DataMixin.Player.Class]
    local logID

    if lootSpecID then
        local loot= GetLootSpecialization() or 0
        local curID= PlayerUtil.GetCurrentSpecID()

        loot= loot==0 and curID or loot

        if loot>0 and loot~= lootSpecID then
            logID= curID

            SetLootSpecialization(lootSpecID)

            local _, name, _, icon, role = GetSpecializationInfoByID(lootSpecID)
            if name then
               print(
                    WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)..'|r',
                    (WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)
                    ..(WoWTools_DataMixin.Icon[role] or '')
                    ..(icon and '|T'..icon..':0|t' or '')
                    ..(name and '|cffff00ff'..WoWTools_TextMixin:CN(name) or '')
                )
            end
        end
    end

    self.spceLog= logID
end

--还原拾取专精
local function Rest_LootSpec(self)
    if not self.spceLog  then
        return
    end
    local loot= GetLootSpecialization() or 0
    loot= loot==0 and PlayerUtil.GetCurrentSpecID() or loot
    if loot~= self.spceLog then
        SetLootSpecialization(self.spceLog)

        local _, name, _, icon, role = GetSpecializationInfoByID(self.spceLog)

        if name then
            print(
                WoWTools_EncounterMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '还原' or RESET)..'|r',
                (WoWTools_DataMixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)
                ..(WoWTools_DataMixin.Icon[role] or '')
                ..(icon and '|T'..icon..':0|t' or '')
                ..(name and '|cffff00ff'..WoWTools_TextMixin:CN(name) or '')
            )
        end
    end
    self.spceLog= nil
end









local function Init()
    Save().LootSpec= Save().LootSpec or {}


    if Save().hideLootSpec then
        return
    end

    local frame= CreateFrame('Frame', 'WoWToolsEJLootFrame')

    function frame:set_event()
        self:UnregisterAllEvents()
        if not Save().hideLootSpec then
            self:RegisterEvent('ENCOUNTER_START')
            self:RegisterEvent('ENCOUNTER_END')
        end
    end

    frame:SetScript('OnEvent', function(self, event, encounterID)
        if event=='ENCOUNTER_START' and encounterID then--BOSS战时, 指定拾取, 专精
            Set_LootSpec(self, encounterID)

        elseif event=='ENCOUNTER_END' then--BOSS战时, 指定拾取, 专精, 还原, 专精拾取
            Rest_LootSpec(self)
        end
    end)

--BOSS 列表
    WoWTools_DataMixin:Hook(EncounterBossButtonMixin, 'Init', function(self, data)--{data={bossID index link rootSectionID, desctiption, name} }
        if not self.specButtons then
            Init_Button(self)
        end

        local scale= Save().lootScale or 1
        local show= not Save().hideLootSpec
        for _, btn in pairs(self.specButtons) do
            btn.journalEncounterID= data.bossID
            if show then
                
                --info= data
                --for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR|r') for k2,v2 in pairs(v) do print('|cffffff00',k2,v2, '|r') end print('|cffff0000---',k, '---END|r') else print(k,v) end end print('|cffff00ff——————————|r')
                btn.settings(btn)
                btn:SetScale(scale)
            end
            btn:SetShown(show)
        end
        self.indexLabel:SetText(show and data.index or '')
    end)



    Init=function()
        _G['WoWToolsEJLootFrame']:set_event()
    end
end




function WoWTools_EncounterMixin:Init_LootSpec()
    Init()
end
