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
            self:SetNormalTexture(icon)
        else
            self:SetNormalAtlas(e.Icon.icon)
        end
        self:SetAlpha(icon and 1 or 0.3)
    end
    self:SetShown(self.dungeonEncounterID)
end










local function set_Loot_Spec_Menu_Init(self, level, type)
    local info
    if type=='CLEAR' then
        for class= 1, GetNumClasses() do
            local classInfo = C_CreatureInfo.GetClassInfo(class)
            if classInfo and classInfo.classFile then
                Save().loot[classInfo.classFile]= Save().loot[classInfo.classFile] or {}
                local n=0
                for _, _ in pairs(Save().loot[classInfo.classFile]) do
                    n= n+1
                end
                local col= select(4, GetClassColor(classInfo.classFile))
                col= col and '|c'..col or col
                info={
                    text= (WoWTools_UnitMixin:GetClassIcon(nil, classInfo.classFile) or '')..e.cn(classInfo.className)..(e.Player.class==classInfo.classFile and '|A:auctionhouse-icon-favorite:0:0|a' or '')..(n>0 and ' |cnGREEN_FONT_COLOR:#'..n..'|r' or ''),
                    colorCode= col,
                    notCheckable=true,
                    arg1= classInfo.classFile,
                    arg2= classInfo.className,
                    hasArrow= n>0,
                    menuList= classInfo.classFile,
                    func= function(_, arg1, arg2)
                        Save().loot[arg1]={}
                        print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_UnitMixin:GetClassIcon(nil, arg1), arg2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)))
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '全部清除' or CLEAR_ALL,
            icon='bags-button-autosort-up',
            notCheckable=true,
            func= function()
                Save().loot={[e.Player.class]={}}
                print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '全部清除' or CLEAR_ALL, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)))
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    elseif type then
        local col= select(4, GetClassColor(type))
        col= col and '|c'..col or col
        for dungeonEncounterID, specID in pairs(Save().loot[type]) do
            info={
                text='dungeonEncounterID |cnGREEN_FONT_COLOR:'..dungeonEncounterID..'|r',
                icon= select(4,  GetSpecializationInfoByID(specID)),
                colorCode= col,
                notCheckable= true,
                arg1=type,
                arg2=dungeonEncounterID,
                func= function(_, arg1, arg2)
                    Save().loot[arg1][arg2]=nil
                    print(e.addName, WoWTools_EncounterMixin.addName, e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, WoWTools_UnitMixin:GetClassIcon(nil, arg1), arg2, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH)))
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        return
    end

    local curSpec= GetSpecialization()
    local find
    for specIndex= 1, GetNumSpecializations() do
        local specID, name, _ , icon= GetSpecializationInfo(specIndex)
        if icon and specID and name then
            e.LibDD:UIDropDownMenu_AddButton({
                text=e.cn(name)..(curSpec==specIndex and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
                colorCode= e.Player.col,
                icon=icon,
                checked= Save().loot[e.Player.class][self.dungeonEncounterID]== specID,
                tooltipOnButton=true,
                tooltipTitle= self.encounterID and EJ_GetEncounterInfo(self.encounterID) or '',
                tooltipText= 'specID '..specID..'|n'..(self.dungeonEncounterID and 'dungeonEncounterID '..self.dungeonEncounterID or ''),
                arg1= {
                    dungeonEncounterID=self.dungeonEncounterID,
                    specID= specID,
                    button=self.button},
                func=function(_,arg1)
                    if not Save().loot[e.Player.class][arg1.dungeonEncounterID] or Save().loot[e.Player.class][arg1.dungeonEncounterID]~= arg1.specID then
                        Save().loot[e.Player.class][arg1.dungeonEncounterID]=arg1.specID
                    else
                        Save().loot[e.Player.class][arg1.dungeonEncounterID]=nil
                    end
                    set_Loot_Spec_Texture(arg1.button)
                end
            }, level)
            find=true
        end
    end
    if find then
        info= {
            text= e.onlyChinese and '无' or NONE,
            icon= 'xmarksthespot',
            checked= not Save().loot[e.Player.class][self.dungeonEncounterID],
            arg1= self.dungeonEncounterID,
            arg2= self.button,
            --keepShownOnClick=true,
            func=function(_,arg1, arg2)
                Save().loot[e.Player.class][arg1]=nil
                set_Loot_Spec_Texture(arg2)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    local name=self.encounterID and EJ_GetEncounterInfo(self.encounterID)
    if name and self.dungeonEncounterID then
        info= {
            text= e.cn(name)..' '..self.dungeonEncounterID,
            notCheckable=true,
            isTitle=true,
        }
    end
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        notCheckable=true,
        hasArrow=true,
        menuList='CLEAR',
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    --e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION,
        icon= WoWTools_UnitMixin:GetClassIcon('player', e.Player.class, true) or  'Banker',
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    info={
        text=WoWTools_EncounterMixin.addName,
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

local function set_Loot_Spec(button)
    if not button.LootButton then
        button.LootButton= WoWTools_ButtonMixin:Cbtn(button, {size={20,20}, icon='hide'})
        button.LootButton:SetPoint('LEFT', button, 'RIGHT')
        button.LootButton:SetNormalAtlas(e.Icon.icon)
        button.LootButton:SetScript('OnMouseDown', function(self)
            local menu= EncounterJournal.encounter.LootSpecMenu
            if not menu then
                menu= CreateFrame("Frame", nil, EncounterJournal.encounter, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(menu, set_Loot_Spec_Menu_Init, 'MENU')
            end
            menu.dungeonEncounterID=self.dungeonEncounterID
            menu.button=self
            menu.encounterID= self.encounterID
            e.LibDD:ToggleDropDownMenu(1, nil, menu, self, 15,0)
        end)
    end
    local dungeonEncounterID= button.encounterID and select(7, EJ_GetEncounterInfo(button.encounterID))
    button.LootButton.dungeonEncounterID= dungeonEncounterID
    button.LootButton.encounterID= button.encounterID
    set_Loot_Spec_Texture(button.LootButton)
    button.LootButton:SetShown(not Save().hideEncounterJournal)
end





















local function Init_ScrollBox(frame)
    if not frame:GetView() then
        return
    end
    for _, button in pairs(frame:GetFrames()) do
        if not button.OnEnter then
            button:SetScript('OnEnter', function(self)
                if not Save().hideEncounterJournal and self.encounterID then
                    local name2, _, journalEncounterID, rootSectionID, _, journalInstanceID, dungeonEncounterID, instanceID2= EJ_GetEncounterInfo(self.encounterID)--button.index= button.GetOrderIndex()
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    local cnName= e.cn(name2, true)
                    e.tips:AddDoubleLine(cnName and cnName..' '..name2 or name2,  'journalEncounterID: '..'|cnGREEN_FONT_COLOR:'..(journalEncounterID or self.encounterID)..'|r')
                    e.tips:AddDoubleLine(instanceID2 and 'instanceID: '..instanceID2 or ' ', (rootSectionID and rootSectionID>0) and 'JournalEncounterSectionID: '..rootSectionID or ' ')
                    if dungeonEncounterID then
                        e.tips:AddDoubleLine('dungeonEncounterID: |cffff00ff'..dungeonEncounterID, (journalInstanceID and journalInstanceID>0) and 'journalInstanceID: '..journalInstanceID or ' ' )
                        local numKill=Save().wowBossKill[dungeonEncounterID]
                        if numKill then
                            e.tips:AddDoubleLine(e.onlyChinese and '击杀' or KILLS, '|cnGREEN_FONT_COLOR:'..numKill..' |r'..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
                        end
                    end
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(e.addName, WoWTools_EncounterMixin.addName)
                    e.tips:Show()
                end
            end)
            button:SetScript('OnLeave', GameTooltip_Hide)
        end
        set_Loot_Spec(button)
    end
end






local function Init()
    Frame= CreateFrame("Frame")

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
                    print(e.addName, WoWTools_EncounterMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
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
                print(e.addName, WoWTools_EncounterMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION)..'|r', e.Icon[role], icon and '|T'..icon..':0|t', name and '|cffff00ff'..name)
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
