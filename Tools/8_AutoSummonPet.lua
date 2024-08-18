local id, e = ...
local addName='DaisyTools'
local Save={
    speciesID=2780,
    --Pets={},
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
    petID=
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
	local _, speciesID, isOwned, _, _, _, _, name = C_PetJournal.GetPetInfoByIndex(index)
	--local needsFanfare = petID and C_PetJournal.PetNeedsFanfare(petID);
    local show= isOwned and speciesID
    if show then
        if not frame.sumButton then
            frame.sumButton=  CreateFrame("CheckButton", nil, frame, "ChatConfigCheckButtonTemplate")--e.Cbtn(frame, {size={20,20}, icon=true})
            frame.sumButton:SetPoint('BOTTOMRIGHT')
            function frame.sumButton:set_alpha()
                self:SetAlpha(Save.speciesID==self.speciesID and 1 or 0)
            end
            frame.sumButton:SetScript('OnLeave', function(self) self:set_alpha() GameTooltip_Hide() end)
            frame.sumButton:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, 'Tools '..e.cn(addName))
                e.tips:AddLine(e.onlyChinese and '自动召唤' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SUMMONS))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(self.speciesID, self.name)
                e.tips:AddDoubleLine(e.onlyChinese and '添加' or ADD, e.Icon.left)
                e.tips:Show()
                self:SetAlpha(1)
            end)
            frame.sumButton:SetScript('OnClick', function(self)
                Save.speciesID=self.speciesID
                if button then
                    button:init_pets_data()
                end
                e.call('PetJournal_UpdatePetList')
            end)
            frame:SetScript('OnLeave', function(self) self.sumButton:set_alpha() end)
            frame:SetScript('OnEnter', function(self) self.sumButton:SetAlpha(1) end)
            frame.sumButton:set_alpha()
        end
        frame.sumButton.speciesID= speciesID
        frame.sumButton.name= name
        frame.sumButton:SetChecked(speciesID==Save.speciesID)
    end
    if frame.sumButton then
        frame.sumButton:SetShown(show)
    end
end















--####
--初始
--####
local function Init()
 
    button.Text=e.Cstr(button, {size=10, color=true})-- size,nil,nil, true)
    button.Text:SetPoint('BOTTOM',0 , -2)

    function button:set_pets_date(tabs)
        for speciesID, info in pairs(tabs or {}) do
            local num = C_PetJournal.GetNumCollectedInfo(speciesID) or 0
            if num>0 then
                local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
                if type(speciesName)=='string' then
                    self.Pets[speciesID]= {
                        name= speciesName,
                        cn= info.cn,
                        petID= select(2, C_PetJournal.FindPetIDByName(speciesName)),
                        icon= speciesIcon,
                        emote= info.emote,
                        emoteText= info.emoteText,
                        auraID= info.auraID,
                        auraName= info.auraID and C_Spell.GetSpellName(info.auraID) or nil,
                    }
                    if Save.speciesID== speciesID then
                        self.texture:SetTexture(speciesIcon or 0)
                    end
                    self.NumPet= self.NumPet+1
                end
            end
        end
    end

    function button:init_pets_data()
        self.Pets={}
        self.NumPet=0
        if not PetsList[Save.speciesID] then
            self:set_pets_date({[Save.speciesID]={}})
        end
        self:set_pets_date(PetsList)

        self:set_event()
        self:summoned_pet()
        self:set_name()
    end

    function button:get_speciesID_data()
        return self.Pets[Save.speciesID] or {}
    end

    function button:set_auto_summon_tips()
        if Save.autoSummon then
            self:LockHighlight()
            --self.border:SetAtlas('bag-border')
        else
            self:UnlockHighlight()
            --self.border:SetAtlas('bag-reagent-border')
        end
    end

    function button:can_summon()
        return not (
                IsStealthed()
                or IsMounted()
                or UnitIsDeadOrGhost('player')
                or UnitIsBattlePet('player')
                or e.Is_In_PvP_Area()--是否在，PVP区域中                
                or UnitCastingInfo('player')
                or UnitChannelInfo('player')
                or UnitAffectingCombat('player')
                or UnitInVehicle('player')
    )
    end

    function button:summoned_pet()--召唤信息
        local info= self:get_speciesID_data()
        if not info.petID then
            return
        end

        local petID = C_PetJournal.GetSummonedPetGUID()
        local find= (petID and petID==info.petID) and true or false
        if not find and info.auraName and AuraUtil.FindAuraByName(info.auraName, 'player', 'HELPFUL') then
            find=true
        end
        if Save.autoSummon and not find and self:can_summon() then
            C_PetJournal.SummonPetByGUID(info.petID)
        end
    end

    function button:set_name()
        local name
        local petID = C_PetJournal.GetSummonedPetGUID()
        if petID then
            local speciesID, customName, _, _, _, _, _, name2= C_PetJournal.GetPetInfoByPetID(petID)
            if speciesID and self.Pets[speciesID] and e.onlyChinese then
                name= self.Pets[speciesID].cn
            end
            name= name or customName or name2
        end
        self.Text:SetText(e.WA_Utf8Sub(name, 2, 5) or "")
    end

    function button:set_event()
        self:UnregisterAllEvents()
        self:RegisterEvent('PLAYER_ENTERING_WORLD')
        if e.Is_In_PvP_Area() then
            return
        end
        self:RegisterEvent('NEW_PET_ADDED')
        local info= self:get_speciesID_data()
        if info.emote then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
        end
        if Save.autoSummon then
            if info.auraID then
                self:RegisterUnitEvent('UNIT_AURA','player')
            end
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            if self.NumPet>0 and not UnitAffectingCombat('player') then
                self:RegisterEvent('PLAYER_STOPPED_MOVING')
                self:RegisterEvent('COMPANION_UPDATE')
                self:summoned_pet()
            end
        end
    end

    button:SetScript('OnClick', function(self, d)
        local key=IsModifierKeyDown()
        if d=='LeftButton' and not key then
            local petID= self:get_speciesID_data().petID
            if petID then
                C_PetJournal.SummonPetByGUID(petID)
            else
                self:init_pets_data()
            end

        elseif not key then
            C_PetJournal.SummonRandomPet(true)
        end
    end)

    function  button:set_menu(speciesID, tab, level)
        tab = tab or {}
        local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        if type(speciesName)=='string' then
            local num= select(3, e.GetPetCollectedNum(speciesID, nil, true))
            e.LibDD:UIDropDownMenu_AddButton({
                text= format('%s %s', e.onlyChinese and tab.cn or speciesName, (num or '')..''),
                icon= speciesIcon,
                disabled= C_PetJournal.GetNumCollectedInfo(speciesID)==0,
                checked= Save.speciesID==speciesID,
                arg1= speciesID,
                --arg2= speciesIcon,
                func= function(_, arg1)
                    Save.speciesID= arg1
                    self:init_pets_data()
                end
            }, level)
        end
    end

    button:SetScript('OnMouseWheel', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)--主菜单

               if not PetsList[Save.speciesID] then
                    self:set_menu(Save.speciesID, nil, level)
                    e.LibDD:UIDropDownMenu_AddSeparator(level)
               end
                for speciesID, info in pairs(PetsList) do
                   self:set_menu(speciesID, info, level)
                end

                e.LibDD:UIDropDownMenu_AddButton({--自动召唤
                text= e.onlyChinese and '自动召唤' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SUMMONS),
                checked=Save.autoSummon,
                keepShownOnClick=true,
                func=function()
                    Save.autoSummon= not Save.autoSummon and true or nil
                    self:init_pets_data()
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
        if info.petID then
            e.tips:SetCompanionPet(info.petID)
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
        if event=='UNIT_AURA' or event=='PLAYER_STOPPED_MOVING' then
            self:summoned_pet()
        elseif event=='COMPANION_UPDATE' and arg1=='CRITTER' then
            self:summoned_pet()
            self:set_name()

        elseif event=='PLAYER_TARGET_CHANGED' then
            local info= self:get_speciesID_data()
            if info.emote and UnitIsBattlePetCompanion('target') and C_PetJournal.GetSummonedPetGUID()==info.petID then
                DoEmote(info.emote)
                if info.auraName and AuraUtil.FindAuraByName(info.auraName, 'player', 'HELPFUL') and self:can_summon() then
                    print(AuraUtil.FindAuraByName(info.auraName, 'player', 'HELPFUL'))
                    C_PetJournal.SummonRandomPet(true)
                end
            end

        elseif event=='PLAYER_REGEN_ENABLED' or event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_ENTERING_WORLD' then
            self:set_event()

        elseif event=='NEW_PET_ADDED' then
            self:init_pets_data()
        end
    end)

    button.NumPet=0
    button.Pets={}
    C_Timer.After(2, function()
        button:init_pets_data()
        button:set_auto_summon_tips()
    end)
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
            --Save.Pets= Save.Pets or {}
            Save.speciesID= Save.speciesID or 2780

            button= WoWTools_ToolsButtonMixin:CreateButton({
                name='SummonPet',
                tooltip='|T3150958:0|t'..(e.onlyChinese and '黛西' or 'Daisy'),
                setParent=true,
                point='LEFT'
            })
            if button then
                --[[for _, info in pairs(Save.Pets) do
                    e.LoadDate({id=info.auraID, type='spell'})
                end]]
                CollectionsJournal_LoadUI()

                Init()
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

    end
end)