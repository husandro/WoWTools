local id, e = ...
local Save={}
local addName= SHOW_PET_BATTLES_ON_MAP_TEXT

--宠物战斗界面收集数
--Blizzard_PetBattleUI.lua
hooksecurefunc('PetBattleUnitFrame_UpdateDisplay',function(self)
    if Save.disabled then
        return
    end
    local  petOwner = self.petOwner
    local petIndex = self.petIndex
    local t
    if petOwner and petIndex then
        if C_PetBattles.IsWildBattle() and petIndex <= C_PetBattles.GetNumPets(petOwner) then
            local speciesID = C_PetBattles.GetPetSpeciesID(petOwner, petIndex)
            if speciesID then
                local numOwned, maxAllowed = C_PetJournal.GetNumCollectedInfo(speciesID)
                if maxAllowed and maxAllowed>0 then
                    if numOwned == maxAllowed  then
                        t='|cnRED_FONT_COLOR:'..numOwned..'|r/'.. maxAllowed
                    else
                        t='|cnGREEN_FONT_COLOR:'..numOwned..'|r/'.. maxAllowed
                    end
                    local rarity = C_PetBattles.GetBreedQuality(petOwner, petIndex)
                    local hex= rarity and select(4, GetItemQualityColor(rarity-1))
                    if hex then
                        t='|c'..hex..t..'|r'
                    else
                        if numOwned==maxAllowed then
                            t= '|cnRED_FONT_COLOR:'..t..'|r'
                        end
                    end
                end
                local speed = C_PetBattles.GetSpeed(petOwner, petIndex)
                local power = C_PetBattles.GetPower(petOwner, petIndex)
                if speed and power then
                    t=t and t..'\n' or ''
                    t=t.. speed..'\n'..power
                end
               --[[ local petType = select(3, C_PetJournal.GetPetInfoBySpeciesID(speciesID))
                if petType and petIndex>1 then
                    t=t and t..'\n' or ''
                    t=t..'|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':0|t'
                end]]
            end
        end
    end
    if not self.text and t then
        self.text=e.Cstr(self, 10 ,nil, nil, nil, nil, 'RIGHT')
        self.text:SetPoint('TOPRIGHT', self.Icon, 'TOPRIGHT', 4, 2)
    end
    if self.text then
        self.text:SetText(t or'')
    end
end)

--Blizzard_PetBattleUI.lua
--宠物 frme 技能, 提示
hooksecurefunc('PetBattleUnitTooltip_UpdateForUnit',function(self, petOwner, petIndex)
    if ( petOwner ~= Enum.BattlePetOwner.Ally and not C_PetBattles.IsPlayerNPC(petOwner) ) or Save.disabled then
         return
    end
    for i=1, NUM_BATTLE_PET_ABILITIES do
        local abilityID,name, icon, maxCooldown, unparsedDescription, numTurns, petType= C_PetBattles.GetAbilityInfo(petOwner, petIndex, i);
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
end)  

--Blizzard_PetBattleUIPetBattle-StatIconsI.lua
--显示当前宠物, 速度指示, 力量数据
hooksecurefunc('PetBattleFrame_UpdateSpeedIndicators', function(self)
    if Save.disabled then
        return
    end
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
        ally.power.text=e.Cstr(self)
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
        enemy.power.text=e.Cstr(self)
        enemy.power.text:SetPoint('RIGHT', enemy.power, 'LEFT')
    end

    ally.speed:SetShown(allySpeed>=enemySpeed)
    enemy.speed:SetShown(enemySpeed>=allySpeed)
    ally.power.text:SetText(allyPower)
    enemy.power.text:SetText(enemyPower)
end)

--主面板,主技能, 提示
hooksecurefunc('PetBattleAbilityButton_UpdateBetterIcon' ,function(self)
    if Save.disabled then
        return
    end
    local typeTexture, text, strongTexture, weakHintsTexture
    if self.BetterIcon then
        local activePet = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally);
        if activePet then
            local abilityID, _, _, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(Enum.BattlePetOwner.Ally, activePet, self:GetID());
            if petType and PET_TYPE_SUFFIX[petType] then
                typeTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]--"Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType]
                if numTurns and numTurns>1 then
                    text='|cnGREEN_FONT_COLOR:'..numTurns..'|r'
                end
                if maxCooldown and maxCooldown>0 then
                    text= text and text..'/' or ''
                    text=text..'|cnRED_FONT_COLOR:'..maxCooldown..'|r'
                end
            
                strongTexture, weakHintsTexture= e.GetPetStrongWeakHints(petType)--取得对战宠物, 强弱
                
                if not self.weakHints then
                    self.weakHints=self:CreateTexture(nil, 'ARTWORK')
                    self.weakHints:SetPoint('BOTTOMLEFT',-2,-2)
                    self.weakHints:SetSize(20,20)
                    self.weakHints.type=self:CreateTexture(nil, 'ARTWORK')
                    self.weakHints.type:SetPoint('LEFT', self.weakHints, 'RIGHT',-4,0)
                    self.weakHints.type:SetSize(18,18)
                    self.weakHints.type:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')
              
                    self.petType=self:CreateTexture(nil,'ARTWORK')
                    self.petType:SetPoint('BOTTOMLEFT', self.weakHints, 'TOPLEFT', 0, -3)
                    self.petType:SetSize(20,20)
               
                    self.strong=self:CreateTexture(nil, 'ARTWORK')
                    self.strong:SetPoint('BOTTOMLEFT', self.petType, 'TOPLEFT',0, -3)
                    self.strong:SetSize(20,20)
                    self.strong.type=self:CreateTexture(nil, 'ARTWORK')
                    self.strong.type:SetPoint('LEFT', self.strong, 'RIGHT',-4,0)
                    self.strong.type:SetSize(18,18)
                    self.strong.type:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')
               
                    self.text=e.Cstr(self)
                    self.text:SetPoint('RIGHT')
                end
            end
        end
    end
    if self.weakHints then
        if weakHintsTexture then
            self.weakHints:SetTexture(weakHintsTexture)
        end
        self.weakHints:SetShown(weakHintsTexture)
        self.weakHints.type:SetShown(weakHintsTexture)
   
        if typeTexture then 
            self.petType:SetTexture(typeTexture)
        end
        self.petType:SetShown(typeTexture)
    
        if strongTexture then
            self.strong:SetTexture(strongTexture)
        end
        self.strong:SetShown(strongTexture)
        self.strong:SetShown(strongTexture)
    
        self.text:SetText(text or '')
    end
end)

--Blizzard_PetBattleUI.lua
--技能提示
hooksecurefunc('PetBattleFrame_UpdateAllActionButtons', function(self)
    local frame=PetBattleFrame.BottomFrame.EnemyFrame
    if not frame then
        frame=CreateFrame('Frame', nil, PetBattleFrame.BottomFrame)
        if Save.EnemyFramePoint then
            frame:SetPoint(Save.EnemyFramePoint[1], UIParent, Save.EnemyFramePoint[3], Save.EnemyFramePoint[4], Save.EnemyFramePoint[5])
        else
            frame:SetPoint('BOTTOMLEFT', PetBattleFrame.BottomFrame , 'TOPLEFT',40,40)
        end
        frame:SetSize(140, 50)
        frame.textrue=frame:CreateTexture(nil, 'BACKGROUND')
        frame.textrue:SetAllPoints(frame)
        frame.textrue:SetAtlas('Adventures-Missions-Shadow')
        frame.textrue:SetAlpha(0.7)
        PetBattleFrame.BottomFrame.EnemyFrame=frame
        for i=1, NUM_BATTLE_PET_ABILITIES do
            frame[i]=e.Cbtn(frame, nil, true)
            frame[i]:SetSize(40,40)
            if i==1 then
                frame[i]:SetPoint('LEFT',5, 0)
            else
                frame[i]:SetPoint('LEFT', frame[i-1], 'RIGHT', 5, 0)
            end
            frame[i]:SetScript('OnEnter', function(self2)
                if self2.abilityID then
                    if ( self2.requiredLevel ) then
                        PetBattleAbilityTooltip_SetAbilityByID(Enum.BattlePetOwner.Enemy, self2.petIndex, self2.abilityID, format(PET_ABILITY_REQUIRES_LEVEL, self2.requiredLevel));
                    else
                        PetBattleAbilityTooltip_SetAbilityByID(Enum.BattlePetOwner.Enemy, self2.petIndex, self2.abilityID);
                    end
                    PetBattleAbilityTooltip_Show("BOTTOMLEFT", self2, "TOPLEFT");
                end
            end)
            frame[i]:SetScript('OnLeave', function() PetBattlePrimaryAbilityTooltip:Hide() end)
            frame[i].texture=frame[i]:CreateTexture()
            frame[i].texture:SetPoint('BOTTOMRIGHT')
            frame[i].texture:SetSize(20,20)
        end
    end
	local activeEnemy = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy);
    for i = 1, NUM_BATTLE_PET_ABILITIES do
        local abilityID, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(Enum.BattlePetOwner.Enemy, activeEnemy, i);
        if abilityID and icon and petType then
            local speciesID = C_PetBattles.GetPetSpeciesID(Enum.BattlePetOwner.Enemy, activeEnemy)
            local abilities = speciesID and C_PetJournal.GetPetAbilityListTable(speciesID)
            if not abilities and abilities[i] then
                frame[i].requiredLevel=abilities[i] and abilities[i].level or nil
            else
                frame[i].requiredLevel=nil
            end
            frame[i].petIndex=activeEnemy
            frame[i].abilityID=abilityID
            frame[i]:SetNormalTexture(icon)
        else
            frame[i].requiredLevel=nil
            frame[i].petIndex=nil
            frame[i].abilityID=nil
            frame[i]:SetNormalTexture(e.Icon.icon)
        end
        local find
        if abilityID and icon and petType then
            local playerPetSlot = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally);
            local playerType = playerPetSlot and C_PetBattles.GetPetType(Enum.BattlePetOwner.Ally, playerPetSlot);
            local modifier = playerType and C_PetBattles.GetAttackModifier(petType, playerType);
            if modifier then
                if (modifier > 1) then
                    frame[i].texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong");
                    find=true
                elseif (modifier < 1) then
                    frame[i].texture:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak");
                    find=true
                end
            end
        end
        frame[i].texture:SetShown(find)
    end
end)
--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save

            local check=e.CPanel(addName, not Save.disabled, true)
            check:SetScript('OnClick', function()
            if Save.disabled then
                Save.disabled=nil
            else
                Save.disabled=true
            end
            print(id, addName, e.GetEnabeleDisable(not Save.disabled))
        end)
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)