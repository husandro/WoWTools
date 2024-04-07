local id, e = ...
local addName='DaisyTools'
local Save={
    speciesID=2280,
    Pets={},
}


local button
local Pets={
    [2780]= {
        cn='黛西',
        auraID=311796,
        emote='BECKON',
        emteText=EMOTE102_CMD1},--/招手
 }
--[[ Pets[speciesID]={
    name=
    cn=
    guid=
    icon=
    emote=
    auraID= 
    auraName=
    emteText=
}
]]
for _, info in pairs(Pets) do
    e.LoadDate({id=info.auraID, type='spell'})
end














--####
--初始
--####
local function Init()
    e.ToolsSetButtonPoint(button)--设置位置

    function button:set_pets_date(speciesID, tab)
        tab= tab or {}
        local num = C_PetJournal.GetNumCollectedInfo(speciesID)
        if num>0 then
            local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
            self.Pets[speciesID]= {
                name= speciesName,
                cn= tab.cn,
                guid= select(2, C_PetJournal.FindPetIDByName(speciesName)),
                icon= speciesIcon,
                emote= tab.emote,
                emoteText= tab.emoteText,
                auraID= tab.auraID,
                auraName= tab.auraID and GetSpellInfo(tab.auraID) or nil,
            }
            if Save.speciesID== speciesID then
                self.texture:SetTexture(speciesIcon)
            end
            self.NumPet= self.NumPet+1
        end
    end

    function button:init_pets_data()
        self.Pets={}
        self.NumPet=0
        for speciesID, tab in pairs(Pets) do
            self:set_pets_date(speciesID, tab)
        end
        for speciesID, tab in pairs(Save.Pets) do
            self:set_pets_date(speciesID, tab)
        end
        button:set_event()
    end

    function button:get_speciesID_data()
        return self.Pets[Save.speciesID] or {}
    end

    function button:set_auto_summon_tips()
        if Save.autoSummon then
            self.border:SetAtlas('bag-border')
        else
            self.border:SetAtlas('bag-reagent-border')
        end
    end

    function button:summoned_pet()--召唤信息
        local info= self:get_speciesID_data()
        local guid= info.guid
        if not guid then
            self:init_pets_data()
            return
        end

        local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
        local find= (info.guid and summonedPetGUID==guid) and true or false
        if not find and info.auraName and AuraUtil.FindAuraByName(info.auraName, 'player', 'HELPFUL') then
            find=true
            --if not summonedPetGUID then
              --  C_PetJournal.SummonRandomPet(true)
            --end
        end
        if not find and Save.autoSummon
            and not IsStealthed()
            and not IsMounted()
            and not UnitIsDeadOrGhost('player')
            and not UnitIsBattlePet('player')
            and not UnitInBattleground('player')
            and not C_PvP.IsArena()
            and not UnitCastingInfo('player')
            and not UnitChannelInfo('paleyr')
            and not UnitAffectingCombat('player')
            and not UnitInVehicle('player')
        then
            C_PetJournal.SummonPetByGUID(guid)
        end
        local name
        if find then
            name= e.onlyChinese and info.cn or e.WA_Utf8Sub(info.name, 2, 5)
        end
        self.Text:SetText(name or '')
    end

    function button:set_event()

        self:UnregisterAllEvents()
        self:RegisterEvent('NEW_PET_ADDED')
        if self.NumPet>0 and Save.autoSummon and not UnitAffectingCombat('player') then
            local info= self:get_speciesID_data()
            self:RegisterEvent('PLAYER_STOPPED_MOVING')
            self:RegisterEvent('COMPANION_UPDATE')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')

            if info.auraID then
                self:RegisterUnitEvent('UNIT_AURA','player')
            end
            if info.emote then
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
            end
            self:summoned_pet()
        end
    end
    button.Text=e.Cstr(button, {size=10, color=true})-- size,nil,nil, true)
    button.Text:SetPoint('CENTER',0 , -5)



    button:SetScript('OnClick', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            local guid= self:get_speciesID_data().guid
            if guid then
                C_PetJournal.SummonPetByGUID(guid)
            else
                self:init_pets_data()
            end

        elseif not key then
            C_PetJournal.SummonRandomPet(true)
        end
    end)

    button:SetScript('OnMouseWheel', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)--主菜单

                for speciesID, tab in pairs(self.Pets) do
                    local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= format('%s %s', e.onlyChinese and tab.cn or speciesName, e.GetPetCollectedNum(speciesID, nil, true) or ''),
                        icon= speciesIcon,
                        disabled= C_PetJournal.GetNumCollectedInfo(speciesID)==0,
                        checked= Save.speciesID==speciesID,
                        arg1= speciesID,
                        func= function(_, arg1)
                            Save.speciesID= arg1
                            self:summoned_pet()
                        end
                    }, level)
                end

                e.LibDD:UIDropDownMenu_AddSeparator(level)
                e.LibDD:UIDropDownMenu_AddButton({--自动召唤
                text= e.onlyChinese and '自动召唤' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SUMMONS),
                checked=Save.autoSummon,
                keepShownOnClick=true,
                func=function()
                    Save.autoSummon= not Save.autoSummon and true or nil
                    self:summoned_pet()
                    self:set_auto_summon_tips()
                end
            }, level)
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
   end)

   button:SetScript('OnEnter', function(self)
        local info= self:get_speciesID_data()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if info.guid then
            e.tips:SetCompanionPet(info.guid)
        end
        e.tips:AddLine(' ')
        local name = e.onlyChinese and info.cn or info.name
        if name then
            e.tips:AddDoubleLine(name, e.Icon.left)
        end
        e.tips:AddDoubleLine(e.onlyChinese and '随机偏好宠物' or SLASH_RANDOMFAVORITEPET1:gsub('/', ''), e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), e.Icon.mid)
        e.tips:Show()
    end)
    button:SetScript('OnLeave', GameTooltip_Hide)

    button:SetScript('OnEvent', function(self, event, arg1)
        if event=='UNIT_AURA' or event=='PLAYER_STOPPED_MOVING' or (event=='COMPANION_UPDATE' and arg1=='CRITTER') then
            self:summoned_pet()

        elseif event=='PLAYER_TARGET_CHANGED' then
            local info= self:get_speciesID_data()
            if info.emote and UnitIsBattlePetCompanion('target') and C_PetJournal.GetSummonedPetGUID()==info.guid then
                DoEmote(info.emote)--beckon
            end

        elseif event=='PLAYER_REGEN_ENABLED' or event=='PLAYER_REGEN_DISABLED' then
            self:set_event()

        elseif event=='NEW_PET_ADDED' then
            self:init_pets_data()
        end
    end)

    button.NumPet=0
    button.Pets={}
    button:init_pets_data()
    button:set_auto_summon_tips()
end















--###########
--加载保存数据
--###########
local panel= CreateFrame('Frame')
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave[addName..'Tools'] or Save
            Save.Pets= Save.Pets or {}
            Save.speciesID= Save.speciesID or 2780

            if not e.toolsFrame.disabled then
                button= e.Cbtn2({
                    name=nil,
                    parent= e.toolsFrame,
                    click=true,-- right left
                    notSecureActionButton=true,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })

                CollectionsJournal_LoadUI()

                for _, info in pairs(Save.Pets) do
                    e.LoadDate({id=info.auraID, type='spell'})
                end
                C_Timer.After(2.4, function()
                    if UnitAffectingCombat('player')  then
                        self:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        Init()--初始
                    end
                end)
            else
                self:UnregisterAllEvents()
            end
            self:RegisterEvent('PLAYER_LOGOUT')

        elseif arg1=='Blizzard_Collections' then

        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init()
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)