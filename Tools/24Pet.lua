local id, e = ...
local addName='DaisyTools'
local Save={
    speciesID=2280,
    Pets={},
}


local button
local PetsList={
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
for _, info in pairs(PetsList) do
    e.LoadDate({id=info.auraID, type='spell'})
end







--Blizzard_Collections
local function Init_PetJournal_InitPetButton(frame, elementData)
	local index = elementData.index;
	local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(index)
	local needsFanfare = petID and C_PetJournal.PetNeedsFanfare(petID);
    local show= isOwned and speciesID and not PetsList[speciesID]
    if show then
        if not frame.sumButton then
            frame.sumButton=  CreateFrame("CheckButton", nil, frame, "ChatConfigCheckButtonTemplate")--e.Cbtn(frame, {size={20,20}, icon=true})
            frame.sumButton:SetPoint('RIGHT')
            frame.sumButton:SetScript('OnLeave', GameTooltip_Hide)
            frame.sumButton:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, 'Tools '..e.cn(addName))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(self.speciesID, self.name)
                e.tips:AddDoubleLine(e.onlyChinese and '添加' or ADD, e.Icon.left)
                e.tips:Show()
            end)
            frame.sumButton:SetScript('OnClick', function(self)
                Save.Pets[self.speciesID]= not Save.Pets[self.speciesID] and {} or nil
                Save.speciesID=self.speciesID
                button:init_pets_data()
                e.call('PetJournal_UpdatePetList')
                
            end)
        end
        frame.sumButton.speciesID= speciesID
        frame.sumButton.name= name
        frame.sumButton:SetChecked(Save.Pets[speciesID] and true or false)
    end
    if frame.sumButton then
        frame.sumButton:SetShown(show)
    end
end















--####
--初始
--####
local function Init()
    function button:set_pets_date(tabs)
        for speciesID, tab in pairs(tabs or {}) do
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
    end

    function button:init_pets_data()
        self.Pets={}
        self.NumPet=0
        self:set_pets_date(PetsList)
        self:set_pets_date(Save.Pets)
        self:summoned_pet()
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

                for speciesID, tab in pairs(Save.Pets) do
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
                for speciesID, tab in pairs(PetsList) do
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
                    size=nil,
                })

                for _, info in pairs(Save.Pets) do
                    e.LoadDate({id=info.auraID, type='spell'})
                end

                Init()

                C_Timer.After(2.4, function()
                    if UnitAffectingCombat('player')  then
                        self:RegisterEvent("PLAYER_REGEN_ENABLED")
                    else
                        e.ToolsSetButtonPoint(button)--设置位置--初始
                    end
                end)

                CollectionsJournal_LoadUI()
            else
                self:UnregisterAllEvents()
            end
            self:RegisterEvent('PLAYER_LOGOUT')

        elseif arg1=='Blizzard_Collections' then
            hooksecurefunc('PetJournal_InitPetButton', Init_PetJournal_InitPetButton)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        e.ToolsSetButtonPoint(button)--设置位置
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)