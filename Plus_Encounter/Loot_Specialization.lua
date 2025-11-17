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







local function Init_Button(btn)
    btn.specButtons={}
    local index= 0

    for class= 1, GetNumClasses() do
        local classInfo = C_CreatureInfo.GetClassInfo(class)
        if classInfo and classInfo.classFile then
            btn.specButtons[index]= CreateFrame('DropdownButton', nil, btn, 'WoWToolsMenu2Template')
            btn.specButtons[index]:SetSize(16,16)
            btn.specButtons[index]:SetFrameStrata('HIGH')
            btn.specButtons[index]:SetPoint('BOTTOMLEFT', index*23, 0)
            btn.specButtons[index].classID= classInfo.classID
            btn.specButtons[index].classFile= classInfo.classFile
            btn.specButtons[index].name= classInfo.name
            btn.specButtons[index].settings= function(self, data)
                local icon
                local alpha= 1

                icon= WoWTools_UnitMixin:GetClassIcon(nil, nil, self.classFile, {reAtlas=true})
                self.texture:SetAtlas(icon)
                self.texture:SetAlpha(alpha or 0.5)
            end
            index= index+1
        end
    end
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
        if Save().hideEncounterJournal then
            self:UnregisterAllEvents()
        else
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
        for _, btn in pairs(self.specButtons) do
            btn:settings(data)
        end
    end)



    Init=function()
        _G['WoWToolsEJLootFrame']:set_event()
    end
end




function WoWTools_EncounterMixin:Init_Specialization_Loot()
    Init()
end
