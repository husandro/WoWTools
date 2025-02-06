
--对方, 技能提示， 框
--Blizzard_PetBattleUI.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end





local EnemyButton














local function Init_Menu(self, root)

end








local function Create_Button(index, petOwner, frame)
    local btn=WoWTools_ButtonMixin:Cbtn(frame, {icon='hide', size={40,40}})--nil, true)
    btn:SetSize(40,40)
    if index==1 then
        if index==1 then
            btn:SetPoint('LEFT',5, 0)
        else
            if allyIndex then
                btn:SetPoint('RIGHT', frame, 'LEFT',-20,0)
            else
                btn:SetPoint('LEFT', frame, 'RIGHT',20,0)
            end
        end
    else
        if allyIndex then
            btn:SetPoint('RIGHT', frame[index-1], 'LEFT', -5, 0)
        else
            btn:SetPoint('LEFT', frame[index-1], 'RIGHT', 5, 0)
        end
    end
    btn:SetScript('OnEnter', function(self2)
        if self2.abilityID then                       
            PetBattleAbilityTooltip_SetAbilityByID(self2.petOwner, self2.petIndex, self2.abilityID);

            PetBattleAbilityTooltip_Show("BOTTOMLEFT", self2, "TOPLEFT");
        end
    end)
    btn:SetScript('OnLeave', function() PetBattlePrimaryAbilityTooltip:Hide() end)

    btn.icon= btn:CreateTexture(nil,'BACKGROUND')
    btn.icon:SetAllPoints()

    btn.storngORweak=btn:CreateTexture(nil,'BORDER')
    btn.storngORweak:SetPoint('BOTTOMRIGHT', 10, -10)
    btn.storngORweak:SetSize(30,30)

    btn.strong=btn:CreateTexture(nil,'BORDER')
    btn.strong:SetPoint('TOPLEFT', -4, 2)
    btn.strong:SetSize(15,15)

    btn.up=btn:CreateTexture(nil,'ARTWORK')
    btn.up:SetPoint('TOP', btn.strong,'BOTTOM',0, 5)
    btn.up:SetSize(8,8)
    btn.up:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')


    btn.petTypeTexture=btn:CreateTexture(nil,'BORDER', nil, 1)
    btn.petTypeTexture:SetPoint('LEFT', -4, 0)
    btn.petTypeTexture:SetSize(15,15)

    btn.down=btn:CreateTexture(nil,'ARTWORK')
    btn.down:SetPoint('TOP', btn.petTypeTexture,'BOTTOM',0,5)
    btn.down:SetSize(8,8)
    btn.down:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')

    btn.weakHints=btn:CreateTexture(nil,'BORDER')
    btn.weakHints:SetPoint('BOTTOMLEFT', -4, -2)
    btn.weakHints:SetSize(15,15)
end







local function Init_Button()
    --EnemyButton=CreateFrame('Frame', nil, PetBattleFrame.BottomFrame)
    EnemyButton= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsEnemyAbilityButton',
        icon='hide',
        atlas='summon-random-pet-icon_32',
        size=23,
        isType2=true
    })

    EnemyButton.setFrame= CreateFrame("Frame", nil, EnemyButton)
    EnemyButton.setFrame:SetSize(1,1)
    EnemyButton.setFrame:SetPoint('RIGHT')

    function EnemyButton:set_point()
        self:ClearAllPoints()
        local p= Save().EnemyButton.point
        if p then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('BOTTOMLEFT', PetBattleFrame.BottomFrame , 'TOPLEFT',60,250)
        end
    end

    function EnemyButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_PetBattleMixin.addName1, WoWTools_PetBattleMixin.addName5)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:Show()
        self.textrue:SetAlpha(1)
    end


    EnemyButton:SetClampedToScreen(true)
    EnemyButton:SetMovable(true)
    EnemyButton:RegisterForDrag('RightButton')
    EnemyButton:SetScript('OnDragStart', function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    EnemyButton:SetScript('OnDragStop', function(self)
        ResetCursor();
        self:StopMovingOrSizing();
        Save().EnemyButton.point={self:GetPoint(1)}
        Save().EnemyButton.point[2]=nil
    end)

    EnemyButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)

    EnemyButton:SetScript('OnMouseUp', ResetCursor)
    EnemyButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self.texture:SetAlpha(1)
    end)
    EnemyButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self.textrue:SetAlpha(0.3)
        SetCursor('UI_MOVE_CURSOR')
    end)
    
    --[[EnemyButton.textrue=EnemyButton:CreateTexture(nil, 'BACKGROUND')
    EnemyButton.textrue:SetAllPoints()
    EnemyButton.textrue:SetAtlas('Adventures-Missions-Shadow')
    EnemyButton.textrue:SetAlpha(0.5)]]

    for index=1, NUM_BATTLE_PETS_IN_BATTLE do
        Create_Button(index)
    end

    --[[for index=1, NUM_BATTLE_PETS_IN_BATTLE +2 do
        local frame
        local allyIndex
        if index==1 then
            frame=EnemyButton
        elseif index<=NUM_BATTLE_PETS_IN_BATTLE then
            frame=PetBattleFrame['Enemy'..index]
        else
            allyIndex=(index-NUM_BATTLE_PETS_IN_BATTLE)+1
            frame=PetBattleFrame['Ally'..allyIndex]
        end
        for i = 1, NUM_BATTLE_PET_ABILITIES do
            Create_Button(index, allyIndex)

        end
    end]]



    EnemyButton:set_point()
    return true
end


















local function set_PetBattleFrame_UpdateAllActionButtons(self)
   


    for index=1, NUM_BATTLE_PETS_IN_BATTLE +2 do
        local frame,petIndex
        local allyIndex,target= nil, Enum.BattlePetOwner.Enemy
        if index==1 then
            frame=EnemyButton
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

            if abilityID and icon and petType then
                frame[i].abilityID=abilityID
                frame[i].petOwner=target
                frame[i].petIndex=petIndex--提示用

                frame[i].icon:SetTexture(icon)--设置图标
                frame[i].petTypeTexture:SetTexture('Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType])--设置类型

                local strong, weakhints
                if not noStrongWeakHints then
                    strong, weakhints= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
                end
                frame[i].strong:SetTexture(strong or 0)
                frame[i].weakHints:SetTexture(weakhints or 0)


                local target2= target==Enum.BattlePetOwner.Ally and Enum.BattlePetOwner.Enemy or Enum.BattlePetOwner.Ally
                local texture
                if abilityID and icon and petType and not noStrongWeakHints then
                    local playerPetSlot = C_PetBattles.GetActivePet(target2);
                    local playerType = playerPetSlot and C_PetBattles.GetPetType(target2, playerPetSlot);
                    local modifier = playerType and C_PetBattles.GetAttackModifier(petType, playerType);
                    if modifier then
                        if (modifier > 1) then
                            texture= "Interface\\PetBattles\\BattleBar-AbilityBadge-Strong"
                        elseif (modifier < 1) then
                            texture="Interface\\PetBattles\\BattleBar-AbilityBadge-Weak"
                        end
                    end
                end
                frame[i].storngORweak:SetTexture(texture or 0)

                frame[i].up:SetShown(not noStrongWeakHints)
                frame[i].down:SetShown(not noStrongWeakHints)

                frame[i]:SetShown(true)
            else
                frame[i]:SetShown(false)
            end
        end
    end
end









--对方，技能， 冷却
local function set_PetBattleActionButton_UpdateState()

    local activeEnemy = C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy);
    for i = 1, NUM_BATTLE_PET_ABILITIES do
        local frame= Buttons[i]--PetBattleFrame.BottomFrame.EnemyFrame
        if frame and frame[i] then
            local text, isUsable, currentCooldown, currentLockdown
            local abilityID, name = C_PetBattles.GetAbilityInfo(Enum.BattlePetOwner.Enemy, activeEnemy, i);
            if name and abilityID then
                isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(Enum.BattlePetOwner.Enemy, activeEnemy, i)

                if currentCooldown and currentCooldown>0 then
                    text=currentCooldown
                elseif currentLockdown and currentCooldown>0 then
                    text= currentLockdown
                end

            end
            if text and not frame[i].cooldownText then
                frame[i].cooldownText=WoWTools_LabelMixin:Create(frame[i], {size=22, color={r=1,g=0,b=0}})
                frame[i].cooldownText:SetPoint('CENTER')
                text=currentCooldown
            end
            if frame[i].cooldownText then
                frame[i].cooldownText:SetText(text or '')
            end
            frame[i].icon:SetDesaturated(not isUsable)

            if currentCooldown and currentCooldown>0 then
                frame[i].icon:SetVertexColor(0.62, 0.62, 0.62)
            elseif currentLockdown and currentLockdown>0 then
                frame[i].icon:SetVertexColor(1, 0, 0)
            else
                frame[i].icon:SetVertexColor(1, 1, 1)
            end
        end
    end
end





function WoWTools_PetBattleMixin:Init_EnemyButton()
    Init_Button()

    hooksecurefunc('PetBattleFrame_UpdateAllActionButtons', set_PetBattleFrame_UpdateAllActionButtons)
    --对方，技能， 冷却
    hooksecurefunc('PetBattleActionButton_UpdateState', set_PetBattleActionButton_UpdateState)
end