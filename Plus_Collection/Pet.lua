--宠物 2
--Blizzard_PetCollection.lua

local function Save()
    return WoWToolsSave['Plus_Collection']
end






local function Set_Script_Type(texture)
    texture:EnableMouse(true)

    texture:SetScript('OnEnter', function(self)
        if self.abilityID then
            PetJournal_ShowAbilityTooltip(self, self.abilityID)
            self:SetAlpha(0.3)
        end
    end)
    texture:SetScript('OnLeave', function(self)
        PetJournal_HideAbilityTooltip(self)
        self:SetAlpha(1)
    end)
end





--类型
local function Set_Type(frame, petType, isRight)
    if not frame.indicatoUp then
        frame.typeTexture= frame:CreateTexture(nil, 'OVERLAY', nil, 7)
        if isRight then
            frame.typeTexture:SetPoint('RIGHT', frame.icon, 'LEFT', 0, -1)
        else
            frame.typeTexture:SetPoint('LEFT', frame.icon, 'RIGHT', 0, -1)
        end
        frame.typeTexture:SetSize(14,14)

        frame.indicatoUp=frame:CreateTexture(nil, 'OVERLAY', nil, 6)
        frame.indicatoUp:SetAtlas('bags-greenarrow')
        frame.indicatoUp:SetSize(8,8)
        frame.indicatoUp:SetPoint('BOTTOM', frame.typeTexture,'TOP', 0, -3)

        frame.indicatoDown=frame:CreateTexture(nil, 'OVERLAY', nil, 6)
        frame.indicatoDown:SetAtlas('UI-HUD-MicroMenu-StreamDLRed-Up')
        frame.indicatoDown:SetSize(8,8)
        frame.indicatoDown:SetPoint('TOP', frame.typeTexture,'BOTTOM', 0, 4)

        frame.strongTexture= frame:CreateTexture(nil, 'OVERLAY', nil, 7)
        frame.strongTexture:SetPoint('BOTTOM', frame.indicatoUp, 'TOP', 0, -4)
        frame.strongTexture:SetSize(14,14)

        frame.weakTexture=frame:CreateTexture(nil, 'OVERLAY', nil, 7)
        frame.weakTexture:SetPoint('TOP', frame.indicatoDown, 'BOTTOM', 0, 4)
        frame.weakTexture:SetSize(14,14)

        Set_Script_Type(frame.typeTexture)
        Set_Script_Type(frame.strongTexture)
        Set_Script_Type(frame.weakTexture)
    end

    local strongTexture, weakHintsTexture, strongIndex, weakHintsIndex
    if not Save().hidePets then
        strongTexture, weakHintsTexture, strongIndex, weakHintsIndex= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
    else
        petType= nil
    end

    frame.typeTexture:SetTexture(petType and 'Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType] or 0)
    frame.typeTexture.abilityID= PET_BATTLE_PET_TYPE_PASSIVES[petType]

    frame.strongTexture:SetTexture(strongTexture or 0)
    frame.strongTexture.abilityID= PET_BATTLE_PET_TYPE_PASSIVES[strongIndex]

    frame.weakTexture:SetTexture(weakHintsTexture or 0)
    frame.weakTexture.abilityID= PET_BATTLE_PET_TYPE_PASSIVES[weakHintsIndex]

    frame.indicatoUp:SetShown(strongTexture)
    frame.indicatoDown:SetShown(weakHintsTexture)
end





















local function Init()
    if Save().hidePets then
        return
    end

--增加，总数
    PetJournal.PetCount.Label:ClearAllPoints()--太长了，
    PetJournal.PetCount.Label:SetPoint('RIGHT', PetJournal.PetCount.Count, 'LEFT', -2, 0)
    PetJournal.PetCount.Label:SetJustifyH('RIGHT')

    WoWTools_DataMixin:Hook('PetJournal_UpdatePetList', function()
        if not PetJournal:IsVisible() or Save().hidePets then
            return
        end
        PetJournal.PetCount.Count:SetFormattedText('%d/%d', C_PetJournal.GetNumPets())
    end)

--列表
    WoWTools_DataMixin:Hook('PetJournal_InitPetButton', function(pet, data)
        local abilityIconA, abilityIconB
        if not Save().hidePets and Save().petListIconSize~=0 then
            abilityIconA, abilityIconB= WoWTools_PetBattleMixin:GetAbilityIcon(data.speciesID, data.index, data.petID, true, Save().petListIconSize or 18)
        end
        if not pet.abilityLabel then
            pet.abilityLabel= WoWTools_LabelMixin:Create(pet, {layer='OVERLAY'})
            pet.abilityLabel:SetPoint('BOTTOMRIGHT', 2, -1)
            pet.subName:SetPoint('RIGHT', -4, 0)
            pet.name:SetPoint('RIGHT', -4, 0)

            function pet.abilityLabel:set_shown()
                self:SetShown(PetJournalPetCard.petIndex ~= self.index and not self:IsMouseOver())
            end
            pet:HookScript('OnEnter', function(self)
                self.abilityLabel:SetShown(false)
            end)
            pet:HookScript('OnLeave', function(self)
                self.abilityLabel:set_shown()
            end)
            pet.dragButton:HookScript('OnEnter', function(self)
                self:GetParent().abilityLabel:SetShown(false)
            end)
            pet.dragButton:HookScript('OnLeave', function(self)
                self:GetParent().abilityLabel:set_shown()
            end)
        end
        pet.abilityLabel.index= data.index
        pet.abilityLabel:SetText((abilityIconA or '')..(abilityIconB or ''))
        pet.abilityLabel:set_shown()
    end)


--PetCard
    WoWTools_DataMixin:Hook('PetJournal_UpdatePetCard', function(self)
        local frame= self.TypeInfo
        local speciesID= frame.speciesID
        local petType= frame:IsShown() and speciesID and select(3, C_PetJournal.GetPetInfoBySpeciesID(speciesID))
        if not petType then
            return
        end

        if not frame.indicatoUp then
            frame.indicatoUp=frame:CreateTexture(nil, 'OVERLAY', nil, 6)
            frame.indicatoUp:SetAtlas('bags-greenarrow')
            frame.indicatoUp:SetSize(8,8)
            frame.indicatoUp:SetPoint('LEFT', frame.typeIcon,'RIGHT', 3, 3)

            frame.indicatoDown=frame:CreateTexture(nil, 'OVERLAY', nil, 5)
            frame.indicatoDown:SetAtlas('UI-HUD-MicroMenu-StreamDLRed-Up')
            frame.indicatoDown:SetSize(8,8)
            frame.indicatoDown:SetPoint('TOP', frame.indicatoUp,'BOTTOM', 0, 3)

            frame.strongTexture= frame:CreateTexture(nil, 'OVERLAY', nil, 7)
            frame.strongTexture:SetPoint('BOTTOM', frame.indicatoUp, 'TOP', 0, -4)
            frame.strongTexture:SetSize(18, 18)

            frame.weakTexture=frame:CreateTexture(nil, 'OVERLAY', nil, 7)
            frame.weakTexture:SetPoint('TOP', frame.indicatoDown, 'BOTTOM', 0, 3)
            frame.weakTexture:SetSize(18, 18)

            Set_Script_Type(frame.strongTexture)
            Set_Script_Type(frame.weakTexture)
        end

        local strongTexture, weakHintsTexture, strongIndex, weakHintsIndex
        if not Save().hidePets then
            strongTexture, weakHintsTexture, strongIndex, weakHintsIndex= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        end

        frame.strongTexture:SetTexture(strongTexture or 0)
        frame.strongTexture.abilityID= PET_BATTLE_PET_TYPE_PASSIVES[strongIndex]

        frame.weakTexture:SetTexture(weakHintsTexture or 0)
        frame.weakTexture.abilityID= PET_BATTLE_PET_TYPE_PASSIVES[weakHintsIndex]

        frame.indicatoUp:SetShown(strongTexture)
        frame.indicatoDown:SetShown(weakHintsTexture)


        local abilities = C_PetJournal.GetPetAbilityList(speciesID)
        local spellFrame
	    for i=1,6 do--NUM_PET_ABILITIES
            spellFrame = self["spell"..i];
            if abilities[i] and spellFrame and spellFrame:IsShown() then
                petType = select(3, C_PetJournal.GetPetAbilityInfo(abilities[i]))
                Set_Type(spellFrame, petType, false)
            end
        end

    end)



--1,2,3 PetCard, 技能
    WoWTools_DataMixin:Hook('PetJournal_UpdatePetLoadOut', function()
        local frame, petType, nextAbilityID
        local isEnabled= not Save().hidePets
        for i=1, 3 do--MAX_ACTIVE_PETS
            local loadoutPlate = PetJournal.Loadout["Pet"..i]
            local petID = C_PetJournal.GetPetLoadOutInfo(i)
            petType = petID and select(10, C_PetJournal.GetPetInfoByPetID(petID))
--类型
            Set_Type(loadoutPlate, petType, true)

            for abilityIndex= 1, 3 do--CompanionLoadOutSpellTemplate
                frame= loadoutPlate['spell'..abilityIndex]
                petType = isEnabled and frame.abilityID and select(3, C_PetJournal.GetPetAbilityInfo(frame.abilityID))

                if not frame.typeTexture then
                    frame.typeTexture= frame:CreateTexture(nil, 'OVERLAY', nil, 7)
                    frame.typeTexture:SetPoint('BOTTOM', frame.icon, 'TOP')
                    frame.typeTexture:SetSize(18, 18)

                    frame.nextSpellTexture= frame:CreateTexture(nil, 'OVERLAY', nil, 7)
                    frame.nextSpellTexture:SetPoint('TOPLEFT', frame.icon, 'BOTTOMLEFT', 0, -3)
                    frame.nextSpellTexture:SetSize(18, 18)

                    frame.nextTypeTexture= frame:CreateTexture(nil, 'OVERLAY', nil, 6)
                    frame.nextTypeTexture:SetPoint('BOTTOMLEFT', frame.nextSpellTexture, 'BOTTOMRIGHT', -4, 0)
                    frame.nextTypeTexture:SetSize(18, 18)

                    frame.FlyoutArrow:ClearAllPoints()
                    frame.FlyoutArrow:SetPoint('BOTTOMLEFT', -2, -7)

                    loadoutPlate.xpBar.rankText:ClearAllPoints()
                    loadoutPlate.xpBar.rankText:SetPoint('BOTTOMRIGHT', loadoutPlate.xpBar, 'TOPRIGHT', 0, -2)
                    loadoutPlate.xpBar.rankText:SetJustifyH('RIGHT')
                end
                frame.typeTexture:SetTexture(petType and 'Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType] or 0)

--显示，没用选中，技能
                nextAbilityID= frame.abilityID == loadoutPlate.abilities[abilityIndex] and loadoutPlate.abilities[abilityIndex+3] or loadoutPlate.abilities[abilityIndex]

                local nextAbilityIcon, nextAbilityType
                if frame.abilityID and nextAbilityID and isEnabled then
                    nextAbilityIcon, nextAbilityType= select(2, C_PetJournal.GetPetAbilityInfo(nextAbilityID))
                end
                frame.nextTypeTexture:SetTexture(nextAbilityType and 'Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[nextAbilityType] or 0)
                frame.nextSpellTexture:SetTexture(nextAbilityIcon or 0)
            end
        end
    end)

    Init=function()end
end





function WoWTools_CollectionMixin:Init_Pet()--宠物 2
    Init()
end