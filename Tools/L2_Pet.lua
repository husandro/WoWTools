
local addName
local P_Save={
    speciesID=2780,

    Pets={
        [2780]=true,--speciesID
    },
}


local button
local function Save()
    return WoWToolsSave['Tools_Daisy']
end

local PetsList={
    [2780]= {
        cn='黛西',
        auraID=311796,
        emote='BECKON',
        emteText=EMOTE102_CMD1},--/招手
 }

for _, info in pairs(PetsList) do
    WoWTools_Mixin:Load({id=info.auraID, type='spell'})
end







--Blizzard_Collections
local function Init_PetJournal_InitPetButton(frame, elementData)
	local index = elementData.index;
	local _, speciesID, _, _, _, _, _, name = C_PetJournal.GetPetInfoByIndex(index)


    if not frame.sumButton then
        frame.sumButton=  CreateFrame("CheckButton", nil, frame, "ChatConfigCheckButtonTemplate")
        frame.sumButton:SetPoint('RIGHT')

        function frame.sumButton:set_alpha()
            self:SetAlpha(Save().Pets[self.speciesID] and 1 or 0)
        end

        frame.sumButton:SetScript('OnLeave', function(self) self:set_alpha() GameTooltip:Hide() end)
        frame.sumButton:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, addName)
            GameTooltip:Show()
            self:SetAlpha(1)
        end)

        frame.sumButton:SetScript('OnClick', function(self)
            Save().Pets[self.speciesID]=not Save().Pets[self.speciesID] and true or nil
        end)

        frame:HookScript('OnLeave', function(self) self.sumButton:set_alpha() end)
        frame:HookScript('OnEnter', function(self) self.sumButton:SetAlpha(1) end)
    end

    frame.sumButton:set_alpha()
    frame.sumButton.speciesID= speciesID
    frame.sumButton.name= name
    frame.sumButton:SetChecked(Save().Pets[speciesID])
    frame.sumButton:SetShown(speciesID and speciesID>0)
end


















local function Init_Menu(self, root)
    local sub
    local num=0
--自动召唤
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动召唤' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SUMMONS),
    function()
        return Save().autoSummon
    end, function()
        Save().autoSummon= not Save().autoSummon and true or nil
        self:init_pets_data()
        self:set_auto_summon_tips()
    end)
    root:CreateDivider()

--列表
    for speciesID in pairs(Save().Pets) do
        local speciesName, speciesIcon= C_PetJournal.GetPetInfoBySpeciesID(speciesID)
        sub=root:CreateRadio(
            (C_PetJournal.GetNumCollectedInfo(speciesID)==0 and '|cff9e9e9e' or '')
            ..('|T'..(speciesIcon or 0)..':0|t'..(speciesName or speciesID)),
        function(data)
            return data.speciesID==Save().speciesID
        end, function(data)
            Save().speciesID=data.speciesID
            self:init_pets_data()
            return MenuResponse.Refresh
        end, {speciesID=speciesID})
        WoWTools_SetTooltipMixin:Set_Menu(sub)
        num= num+1
    end

--全部清除
    if num>1 then
        root:CreateDivider()
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            Save().Pets={[2780]=true}
            if PetJournal_UpdatePetList then
                WoWTools_Mixin:Call(PetJournal_UpdatePetList)
            end
        end)
    end

--打开选项界面
    if num>0 then
        root:CreateDivider()
    end
    WoWTools_ToolsMixin:OpenMenu(root, addName)--打开, 选项界面，菜单

--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root, nil)
end













--初始
local function Init()

    button.Text=WoWTools_LabelMixin:Create(button, {size=10, color=true})-- size,nil,nil, true)
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
                    if Save().speciesID== speciesID then
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

        if not PetsList[Save().speciesID] then
            self:set_pets_date({[Save().speciesID]={}})
        end
        self:set_pets_date(PetsList)

        self:set_event()
        self:summoned_pet()
        self:set_name()
    end

    function button:get_speciesID_data()
        return self.Pets[Save().speciesID] or {}
    end

    function button:set_auto_summon_tips()
        if Save().autoSummon then
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
                or WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中                
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
        if Save().autoSummon and not find and self:can_summon() then
            C_PetJournal.SummonPetByGUID(info.petID)
        end
    end

    function button:set_name()
        local name
        local petID = C_PetJournal.GetSummonedPetGUID()
        if petID then
            local speciesID, customName, _, _, _, _, _, name2= C_PetJournal.GetPetInfoByPetID(petID)
            if speciesID and self.Pets[speciesID] and WoWTools_DataMixin.onlyChinese then
                name= self.Pets[speciesID].cn
            end
            name= name or customName or name2
        end
        self.Text:SetText(WoWTools_TextMixin:sub(name, 2, 5) or "")
    end

    function button:set_event()
        self:UnregisterAllEvents()
        self:RegisterEvent('LOADING_SCREEN_DISABLED')
        if WoWTools_MapMixin:IsInPvPArea() then
            return
        end
        self:RegisterEvent('NEW_PET_ADDED')
        local info= self:get_speciesID_data()
        if info.emote then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
        end
        if Save().autoSummon then
            if info.auraID then
                self:RegisterUnitEvent('UNIT_AURA', 'player')
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
        if d=='LeftButton' then
            local petID= self:get_speciesID_data().petID
            if petID then
                C_PetJournal.SummonPetByGUID(petID)
            else
                self:init_pets_data()
            end

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)


    button:SetScript('OnMouseWheel', function()
        C_PetJournal.SummonRandomPet(true)
   end)

   button:SetScript('OnEnter', function(self)
        local info= self:get_speciesID_data()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if info.petID then
            GameTooltip:SetCompanionPet(info.petID)
        end
        GameTooltip:AddLine(' ')
        local name = WoWTools_DataMixin.onlyChinese and info.cn or info.name
        if name then
            GameTooltip:AddDoubleLine(name, WoWTools_DataMixin.Icon.left)
        end
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '随机偏好宠物' or SLASH_RANDOMFAVORITEPET1:gsub('/', ''), WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU), WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
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

        elseif event=='PLAYER_REGEN_ENABLED' or event=='PLAYER_REGEN_DISABLED' or event=='LOADING_SCREEN_DISABLED' then
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
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Tools_Daisy']= WoWToolsSave['Tools_Daisy'] or P_Save

            Save().speciesID= Save().speciesID or 2780

            addName= '|T3150958:0|t'..(WoWTools_DataMixin.onlyChinese and '黛西' or 'Daisy')

            button= WoWTools_ToolsMixin:CreateButton({
                name='SummonPet',
                tooltip=addName,
            })

            if button then
                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    hooksecurefunc('PetJournal_InitPetButton', Init_PetJournal_InitPetButton)
                    self:UnregisterEvent(event)
                end
            else
                self:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            hooksecurefunc('PetJournal_InitPetButton', Init_PetJournal_InitPetButton)
            self:UnregisterEvent(event)
        end

    elseif event == "LOADING_SCREEN_DISABLED"  then
        if button then
            Init()
        end
        self:UnregisterEvent(event)
    end
end)