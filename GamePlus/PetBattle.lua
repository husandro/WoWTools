local id, e = ...
local Save={}
local addName= SHOW_PET_BATTLES_ON_MAP_TEXT
local panel=CreateFrame("Frame")

--宠物战斗界面收集数
--Blizzard_PetBattleUI.lua
hooksecurefunc('PetBattleUnitFrame_UpdateDisplay',function(self)
    if Save.disabled then
        return
    end
    local petOwner = self.petOwner
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
                    t=t..'|A:Soulbinds_Tree_Conduit_Icon_Attack:0:0|a'..power..'\n'..'|A:Soulbinds_Tree_Conduit_Icon_Utility:0:0|a'..speed
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
            local _, _, _, maxCooldown, _, numTurns, petType = C_PetBattles.GetAbilityInfo(Enum.BattlePetOwner.Ally, activePet, self:GetID());
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
--对方, 我方， 技能提示， 框
hooksecurefunc('PetBattleFrame_UpdateAllActionButtons', function(self)
    if Save.disabled then
        return
    end
    if not panel.EnemyFrame then
        panel.EnemyFrame=CreateFrame('Frame', nil, PetBattleFrame.BottomFrame)
        if Save.EnemyFramePoint then
            panel.EnemyFrame:SetPoint(Save.EnemyFramePoint[1], UIParent, Save.EnemyFramePoint[3], Save.EnemyFramePoint[4], Save.EnemyFramePoint[5])
        else
            panel.EnemyFrame:SetPoint('BOTTOMLEFT', PetBattleFrame.BottomFrame , 'TOPLEFT',60,250)
        end
        panel.EnemyFrame:SetSize(150, 50)
        panel.EnemyFrame:SetClampedToScreen(true)
        panel.EnemyFrame:SetMovable(true)
        panel.EnemyFrame:RegisterForDrag('LeftButton', 'RightButton')
        panel.EnemyFrame:SetScript('OnDragStart', function(self2,d) if not IsModifierKeyDown() then self2:StartMoving() end end)
        panel.EnemyFrame:SetScript('OnDragStop', function(self2)
            ResetCursor();
            self2:StopMovingOrSizing();
            Save.EnemyFramePoint={self2:GetPoint(1)}
            Save.EnemyFramePoint[2]=nil
            print(id, addName,'Alt+' ..e.Icon.right,TRANSMOGRIFY_TOOLTIP_REVERT)
        end)
        panel.EnemyFrame:SetScript('OnMouseDown', function(self2, d)
            if d=='RightButton' and IsAltKeyDown() then
                self2:ClearAllPoints()
                self2:SetPoint('BOTTOMLEFT', PetBattleFrame.BottomFrame , 'TOPLEFT',40,40)
            else
                SetCursor('UI_MOVE_CURSOR')
            end
        end)
        panel.EnemyFrame:SetScript('OnMouseUp', function() ResetCursor() end)
        panel.EnemyFrame:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(NPE_MOVE, e.Icon.left)
            e.tips:Show()
            self2.textrue:SetAlpha(1)
        end)
        panel.EnemyFrame:SetScript('OnLeave', function(self2)
            e.tips:Hide()
            self2.textrue:SetAlpha(0.5)
        end)
        panel.EnemyFrame.textrue=panel.EnemyFrame:CreateTexture(nil, 'BACKGROUND')
        panel.EnemyFrame.textrue:SetAllPoints(frame)
        panel.EnemyFrame.textrue:SetAtlas('Adventures-Missions-Shadow')
        panel.EnemyFrame.textrue:SetAlpha(0.5)
        for index=1, NUM_BATTLE_PETS_IN_BATTLE +2 do
            local frame
            local allyIndex
            if index==1 then
                frame=panel.EnemyFrame
            elseif index<=NUM_BATTLE_PETS_IN_BATTLE then
                frame=PetBattleFrame['Enemy'..index]
            else
                allyIndex=(index-NUM_BATTLE_PETS_IN_BATTLE)+1
                frame=PetBattleFrame['Ally'..allyIndex]
            end
            for i = 1, NUM_BATTLE_PET_ABILITIES do
                if frame and not frame[i] then
                    frame[i]=e.Cbtn(frame, nil, true)
                    frame[i]:SetSize(40,40)
                    if i==1 then
                        if index==1 then
                            frame[i]:SetPoint('LEFT',5, 0)
                        else
                            if allyIndex then
                                frame[i]:SetPoint('RIGHT', frame, 'LEFT',-20,0)
                            else
                                frame[i]:SetPoint('LEFT', frame, 'RIGHT',20,0)
                            end
                        end
                    else
                        if allyIndex then
                            frame[i]:SetPoint('RIGHT', frame[i-1], 'LEFT', -5, 0)
                        else
                            frame[i]:SetPoint('LEFT', frame[i-1], 'RIGHT', 5, 0)
                        end
                    end
                    frame[i]:SetScript('OnEnter', function(self2)
                        if self2.abilityID then
                            if ( self2.requiredLevel ) then
                                PetBattleAbilityTooltip_SetAbilityByID(self2.petOwner, self2.petIndex, self2.abilityID, format(PET_ABILITY_REQUIRES_LEVEL, self2.requiredLevel));
                            else
                                PetBattleAbilityTooltip_SetAbilityByID(self2.petOwner, self2.petIndex, self2.abilityID);
                            end
                            PetBattleAbilityTooltip_Show("BOTTOMLEFT", self2, "TOPLEFT");
                        end
                    end)
                    frame[i]:SetScript('OnLeave', function() PetBattlePrimaryAbilityTooltip:Hide() end)
                    frame[i].texture=frame[i]:CreateTexture(nil,'OVERLAY')
                    frame[i].texture:SetPoint('BOTTOMRIGHT', 10, -10)
                    frame[i].texture:SetSize(30,30)
    
                    frame[i].strong=frame[i]:CreateTexture(nil,'OVERLAY')
                    frame[i].strong:SetPoint('TOPLEFT', -5, 3)
                    frame[i].strong:SetSize(20,20)
                    frame[i].strong.type=frame[i]:CreateTexture(nil,'OVERLAY')
                    frame[i].strong.type:SetPoint('LEFT', frame[i].strong, 'RIGHT', -5, 0)
                    frame[i].strong.type:SetSize(15,15)
                    frame[i].strong.type:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')
    
                    frame[i].petTypeTexture=frame[i]:CreateTexture(nil,'OVERLAY')
                    frame[i].petTypeTexture:SetPoint('LEFT', -5, 0)
                    frame[i].petTypeTexture:SetSize(20,20)
    
                    frame[i].weakHints=frame[i]:CreateTexture(nil,'OVERLAY')
                    frame[i].weakHints:SetPoint('BOTTOMLEFT', -5, -3)
                    frame[i].weakHints:SetSize(20,20)
                    frame[i].weakHints.type=frame[i]:CreateTexture(nil,'OVERLAY')
                    frame[i].weakHints.type:SetPoint('LEFT', frame[i].weakHints, 'RIGHT',-5,0)
                    frame[i].weakHints.type:SetSize(15,15)
                    frame[i].weakHints.type:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')
                end
            end
        end
    end

	
    --local activeEnemy = C_PetBattles.GetActivePet(target);
    for index=1, NUM_BATTLE_PETS_IN_BATTLE +2 do
        local frame,petIndex
        local allyIndex,target=nil, Enum.BattlePetOwner.Enemy
        if index==1 then
            frame=panel.EnemyFrame
            petIndex=C_PetBattles.GetActivePet(target)
        elseif index<=NUM_BATTLE_PETS_IN_BATTLE then
            frame=PetBattleFrame['Enemy'..index]
            petIndex=frame.petIndex
        else
            allyIndex=(index-NUM_BATTLE_PETS_IN_BATTLE)+1
            frame=PetBattleFrame['Ally'..allyIndex]
            target=Enum.BattlePetOwner.Ally
            petIndex=frame.petIndex
        end
        
        for i = 1, NUM_BATTLE_PET_ABILITIES do
            
            local abilityID, _, icon, _, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(target, petIndex, i);
            local find
            if abilityID and icon and petType then
                local speciesID = C_PetBattles.GetPetSpeciesID(target, petIndex)
                local abilities = speciesID and C_PetJournal.GetPetAbilityListTable(speciesID)
                if not abilities and abilities[i] then
                    frame[i].requiredLevel=abilities[i] and abilities[i].level or nil
                else
                    frame[i].requiredLevel=nil
                end
                frame[i].abilityID=abilityID
                frame[i].petOwner=target
                frame[i].petIndex=petIndex--提示用

                frame[i]:SetNormalTexture(icon)--设置图标
                frame[i].petTypeTexture:SetTexture('Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType])--设置类型
                local strong, weakhints=e.GetPetStrongWeakHints(petType)
                frame[i].strong:SetTexture(strong)
                frame[i].weakHints:SetTexture(weakhints)
                find=true
            else
                frame[i].requiredLevel=nil
                frame[i].petIndex=nil
                frame[i].abilityID=nil
                frame[i].petOwner=nil
                frame[i]:SetNormalTexture(e.Icon.icon)
            end
            frame[i].strong:SetShown(find)
            frame[i].petTypeTexture:SetShown(find)
            frame[i].weakHints:SetShown(find)
            frame[i].weakHints.type:SetShown(find)
            frame[i].strong.type:SetShown(find)

            find=nil
            local target2= target==Enum.BattlePetOwner.Ally and Enum.BattlePetOwner.Enemy or Enum.BattlePetOwner.Ally
            if abilityID and icon and petType and not noStrongWeakHints then
                local playerPetSlot = C_PetBattles.GetActivePet(target2);
                local playerType = playerPetSlot and C_PetBattles.GetPetType(target2, playerPetSlot);
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
    end
end)

--对方，技能， 冷却
hooksecurefunc('PetBattleActionButton_UpdateState', function(self)
    if Save.disabled then
        return
    end
    local activeEnemy = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy);
    for i = 1, NUM_BATTLE_PET_ABILITIES do
        local frame=PetBattleFrame.BottomFrame.EnemyFrame
        if frame and frame[i] then
            local text
            local abilityID, name = C_PetBattles.GetAbilityInfo(Enum.BattlePetOwner.Enemy, activeEnemy, i);
            if name and abilityID then
                local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(Enum.BattlePetOwner.Enemy, activeEnemy, i)
                if currentCooldown and currentCooldown>0 then
                    if not frame[i].cooldownText then
                        frame[i].cooldownText=e.Cstr(frame[i], 20 , nil, nil, {1, 0, 0}, 'OVERLAY')
                        frame[i].cooldownText:SetPoint('CENTER')
                    end
                    text=currentCooldown
                end
            end
            if frame[i].cooldownText then
                frame[i].cooldownText:SetText(text)
            end
        end
    end
end)

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

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