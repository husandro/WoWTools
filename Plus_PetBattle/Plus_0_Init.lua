
--宠物对战 Plus
local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end




--###################
--宠物 frme 技能, 提示
--###################
local function set_PetBattleUnitTooltip_UpdateForUnit(self, petOwner, petIndex)
    if ( petOwner ~= Enum.BattlePetOwner.Ally and not C_PetBattles.IsPlayerNPC(petOwner) ) or Save().disabled then--Blizzard_PetBattleUI.lua
         return
    end
    for i=1, NUM_BATTLE_PET_ABILITIES do
        local abilityID,name, icon, maxCooldown, _, numTurns, petType= C_PetBattles.GetAbilityInfo(petOwner, petIndex, i);
        local abilityName = self["AbilityName"..i];
        if ( abilityID and name and abilityName ) then
            local t='';
            if type and PET_TYPE_SUFFIX[petType] then
                t=t..'|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':0|t'
            end
            if icon then
                t=t..'|T'..icon..':0|t'
            end
            t=t..name..(numTurns and numTurns>0 and '|cnGREEN_FONT_COLOR:'..numTurns..'|r' or '')..(maxCooldown and maxCooldown>1 and '/|cnRED_FONT_COLOR:'..maxCooldown..'|r' or '')--' '..abilityID;

            abilityName:SetText(t);
        end
    end
end









--#############################
--显示当前宠物, 速度指示, 力量数据
--#############################
local function set_PetBattleFrame_UpdateSpeedIndicators(self)--Blizzard_PetBattleUIPetBattle-StatIconsI.lua
    local ally=self.ActiveAlly.PetType
    local enemy=self.ActiveEnemy.PetType

    local allyActive = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally);
	local allySpeed = C_PetBattles.GetSpeed(Enum.BattlePetOwner.Ally, allyActive);
    local allyPower = C_PetBattles.GetPower(Enum.BattlePetOwner.Ally, allyActive)

    local enemyActive = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy);
	local enemySpeed = C_PetBattles.GetSpeed(Enum.BattlePetOwner.Enemy, enemyActive);
    local enemyPower = C_PetBattles.GetPower(Enum.BattlePetOwner.Enemy, enemyActive)

    if not ally.speed then
        ally.speed=ally:CreateTexture()
        ally.speed:SetTexture('Interface\\PetBattles\\PetBattle-StatIcons')
        ally.speed:SetSize(16,16)
        ally.speed:SetPoint('BOTTOMLEFT', ally, 'BOTTOMRIGHT' )
        ally.speed:SetTexCoord(0.0,0.5,0.5, 1.0)

        ally.power=ally:CreateTexture()
        ally.power:SetTexture('Interface\\PetBattles\\PetBattle-StatIcons')
        ally.power:SetSize(16,16)
        ally.power:SetPoint('BOTTOM', ally.speed , 'TOP' )
        ally.power:SetTexCoord(0.0, 0.5, 0.0, 0.5)
        ally.power.text=WoWTools_LabelMixin:Create(self)
        ally.power.text:SetPoint('LEFT', ally.power, 'RIGHT')

        enemy.speed=enemy:CreateTexture()
        enemy.speed:SetTexture('Interface\\PetBattles\\PetBattle-StatIcons')
        enemy.speed:SetSize(16,16)
        enemy.speed:SetPoint('BOTTOMRIGHT', enemy, 'BOTTOMLEFT' )
        enemy.speed:SetTexCoord(0.0,0.5,0.5, 1.0)
        enemy.speed:SetRotation(60)

        enemy.power=enemy:CreateTexture()
        enemy.power:SetTexture('Interface\\PetBattles\\PetBattle-StatIcons')
        enemy.power:SetSize(16,16)
        enemy.power:SetPoint('BOTTOM', enemy.speed , 'TOP' )
        enemy.power:SetTexCoord(0.0, 0.5, 0.0, 0.5)
        enemy.power.text=WoWTools_LabelMixin:Create(self)
        enemy.power.text:SetPoint('RIGHT', enemy.power, 'LEFT')
    end

    ally.speed:SetShown(allySpeed>=enemySpeed)
    enemy.speed:SetShown(enemySpeed>=allySpeed)
    ally.power.text:SetText(allyPower)
    enemy.power.text:SetText(enemyPower)

     C_Timer.After(2.5, function()
        if PetHasActionBar() and not UnitAffectingCombat('player') then--宠物动作条， 显示，隐藏
            PetActionBar:SetShown(false)
        end
    end)
end













--#################
--主面板,主技能, 提示
--#################
local function set_PetBattleAbilityButton_UpdateBetterIcon(self)
    local typeTexture, Cooldown, strongTexture, weakHintsTexture
    if self.BetterIcon then
        local activePet = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally);
        if activePet then
            local _, _, _, maxCooldown, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(Enum.BattlePetOwner.Ally, activePet, self:GetID());
            Cooldown=maxCooldown
            if petType and PET_TYPE_SUFFIX[petType] then
                typeTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]--"Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]
                if not noStrongWeakHints then
                    strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱
                end
                if not self.petType then
                    self.strong= self:CreateTexture(nil, 'OVERLAY')
                    self.strong:SetPoint('TOPLEFT', self,-4, 2)
                    self.strong:SetSize(15,15)


                    self.up=self:CreateTexture(nil, 'OVERLAY')
                    self.up:SetPoint('TOP', self.strong,'BOTTOM',0, 4)
                    self.up:SetSize(10,10)
                    self.up:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')




                    self.petType= self:CreateTexture(nil, 'OVERLAY')
                    self.petType:SetPoint('LEFT', self, -4, 0)
                    self.petType:SetSize(15,15)

                    self.down=self:CreateTexture(nil, 'OVERLAY')
                    self.down:SetPoint('TOP', self.petType, 'BOTTOM', 0, 3)
                    self.down:SetSize(10,10)
                    self.down:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')


                    self.weakHints= self:CreateTexture(nil, 'OVERLAY')
                    self.weakHints:SetPoint('BOTTOMLEFT',-4,-2)
                    self.weakHints:SetSize(15,15)

                    self.text=WoWTools_LabelMixin:Create(self, {color={r=1,g=0,b=0}, justifyH='RIGHT'})--nil, nil, nil,{1,0,0}, 'OVERLAY', 'RIGHT')
                    self.text:SetPoint('RIGHT',-6,-6)
                end
            end
        end
    end
    if self.petType then
        self.weakHints:SetTexture(weakHintsTexture or 0)
        self.petType:SetTexture(typeTexture or 0)
        self.strong:SetTexture(strongTexture or 0)
        self.up:SetShown(weakHintsTexture and typeTexture and strongTexture)
        self.down:SetShown(weakHintsTexture and typeTexture and strongTexture)
        self.text:SetText(Cooldown and Cooldown>0 and Cooldown or '')

    end
end















--#################
--宠物战斗界面收集数
--#################
local function set_PetBattleUnitFrame_UpdateDisplay(self)--Blizzard_PetBattleUI.lua
    local petOwner = self.petOwner
    local petIndex = self.petIndex
    local t
    if petOwner and petIndex then
        if C_PetBattles.IsWildBattle() and petIndex <= C_PetBattles.GetNumPets(petOwner) then
            local speciesID = C_PetBattles.GetPetSpeciesID(petOwner, petIndex)
            if speciesID then
                local CollectedNum, CollectedText= select(2, WoWTools_CollectedMixin:Pet(speciesID))--总收集数量， 25 25 25， 已收集3/3
                t= CollectedNum or CollectedText
                local speed = C_PetBattles.GetSpeed(petOwner, petIndex)
                local power = C_PetBattles.GetPower(petOwner, petIndex)
                if speed and power then
                    t=t and t..'|n' or ''
                    t=t..power..'|n'..speed
                    --t=t..'|A:Soulbinds_Tree_Conduit_Icon_Attack:0:0|a'..power..'|n'..'|A:Soulbinds_Tree_Conduit_Icon_Utility:0:0|a'..speed
                end
            end
        end
    end
    if not self.text and t then
        self.text=WoWTools_LabelMixin:Create(self, {justifyH='RIGHT'})--12 ,nil, nil, nil, nil, 'RIGHT')
        self.text:SetPoint('TOPRIGHT', self.Icon, 'TOPRIGHT', 6, 2)
    end
    if self.text then
        self.text:SetText(t or'')
    end
end

















local function Init()


    --宠物战斗界面收集数
    hooksecurefunc('PetBattleUnitFrame_UpdateDisplay',set_PetBattleUnitFrame_UpdateDisplay)

    --宠物 frme 技能, 提示
    hooksecurefunc('PetBattleUnitTooltip_UpdateForUnit', set_PetBattleUnitTooltip_UpdateForUnit)

    --显示当前宠物, 速度指示, 力量数据
    hooksecurefunc('PetBattleFrame_UpdateSpeedIndicators', set_PetBattleFrame_UpdateSpeedIndicators)

    --主面板,主技能, 提示
    hooksecurefunc('PetBattleAbilityButton_UpdateBetterIcon', set_PetBattleAbilityButton_UpdateBetterIcon)

    

    return true
end












function WoWTools_PetBattleMixin:Set_Plus()
    if not self.Save.Plus.disabled then
        local isHook= Init()
        if isHook then
            --self:Init_EnemyButton()
            Init=function() end
        end
        return isHook
    end
end