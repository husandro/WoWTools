--技能提示， 框
--Blizzard_PetBattleUI.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end

local Buttons--5*3 技能按钮
local size= 52


















local function AbilityButton_UpdateTypeTips(self)
    local petIndex= self:getPetIndex()-- or self.petIndex

    local typeTexture, strongTexture, weakHintsTexture, maxCooldown, petType, noStrongWeakHints, abilityID, texture, _
    if petIndex and not Save().AbilityButton.disabled then
        abilityID, _, texture, maxCooldown, _, _, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(self.petOwner, petIndex, self.abilityIndex)
    end

    if petType then
        typeTexture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]
        if not noStrongWeakHints then
            strongTexture, weakHintsTexture= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)--取得对战宠物, 强弱
        end
    end

    self.StrongTexture:SetTexture(strongTexture or 0)
    self.UpTexture:SetShown(strongTexture)

    self.TypeTexture:SetTexture(typeTexture or 0)

    self.WeakHintsTexture:SetTexture(weakHintsTexture or 0)
    self.DownTexture:SetShown(weakHintsTexture)

    self.MaxCooldownText:SetText(maxCooldown and maxCooldown>0 and maxCooldown or '')

    self.abilityID= abilityID
    self.petType= petType
end













local function AbilityButton_Update(self)
    local petIndex= self:getPetIndex()
    if not petIndex then
        return
    end

    local petOwner= self.petOwner
    local abilityIndex= self.abilityIndex
--冷却
    local cooldown, r,g,b
    local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(petOwner, petIndex, abilityIndex)
    if currentCooldown and currentCooldown>0 then
        cooldown=currentCooldown
        r,g,b= 1,0,1

    elseif currentLockdown and currentCooldown>0 then
        cooldown= currentLockdown
        r,g,b= 0.82, 0.82, 0.82
    end
    r,g,b= r or 1, b or 1, b or 1
    self.CooldownText:SetText(cooldown or '')
    self.CooldownText:SetTextColor(r,g,b)

    local icon=self:GetNormalTexture()
    if icon then
        icon:SetDesaturated(not isUsable)
        icon:SetVertexColor(r,g,b)
    end

--类型，强，弱
    local show= false
    local enemyOwner= petOwner==Enum.BattlePetOwner.Enemy and Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy
    local enemyIndex= C_PetBattles.GetActivePet(enemyOwner)
    local abilityID, _, texture, _, _, _, allyType = C_PetBattles.GetAbilityInfo(petOwner, petIndex, abilityIndex)
 	local enemyType = enemyIndex and C_PetBattles.GetPetType(enemyOwner, enemyIndex)
    if allyType and enemyType then
        local modifier = C_PetBattles.GetAttackModifier(allyType, enemyType) or 1
        if (modifier > 1) then
            self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
            show=true
        elseif (modifier < 1) then
            self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak")
            show=true
        end
    end
    self.BetterIcon:SetShown(show)

--技能，图标
    self:SetNormalTexture(texture or 0)

    --local auraID = PET_BATTLE_PET_TYPE_PASSIVES[petType];
end









local function AbilityButton_CreateTypeTips(btn)
    if btn.StrongTexture then
        return
    end
    btn.StrongTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.StrongTexture:SetPoint('TOPLEFT', btn, -4, 2)
    btn.StrongTexture:SetSize(15,15)


    btn.UpTexture=btn:CreateTexture(nil, 'OVERLAY')
    btn.UpTexture:SetPoint('TOP', btn.StrongTexture,'BOTTOM',0, 4)
    btn.UpTexture:SetSize(10,10)
    btn.UpTexture:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')

    btn.TypeTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.TypeTexture:SetPoint('LEFT', btn, -4, 0)
    btn.TypeTexture:SetSize(15,15)

    btn.DownTexture=btn:CreateTexture(nil, 'OVERLAY')
    btn.DownTexture:SetPoint('TOP', btn.TypeTexture, 'BOTTOM', 0, 3)
    btn.DownTexture:SetSize(10,10)
    btn.DownTexture:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')


    btn.WeakHintsTexture= btn:CreateTexture(nil, 'OVERLAY')
    btn.WeakHintsTexture:SetPoint('BOTTOMLEFT',-4,-2)
    btn.WeakHintsTexture:SetSize(15,15)

    btn.MaxCooldownText=WoWTools_LabelMixin:Create(btn, {color={r=1,g=0,b=0}, justifyH='RIGHT'})--nil, nil, nil,{1,0,0}, 'OVERLAY', 'RIGHT')
    btn.MaxCooldownText:SetPoint('RIGHT',-6,-6)
end















local function Set_Ability_Button(button, index, isEnemy)
    local btn= WoWTools_ButtonMixin:Cbtn(button.frame, {icon='hide', size=size})



    btn.petOwner= button.petOwner
    btn.getPetIndex= button.getPetIndex
    btn.abilityIndex= index

--冷却
    btn.CooldownText=WoWTools_LabelMixin:Create(btn, {justifyH='CENTER', size=32})
    btn.CooldownText:SetPoint('CENTER')

--强弱
    btn.BetterIcon= btn:CreateTexture(nil, 'OVERLAY')
    btn.BetterIcon:SetPoint('BOTTOMRIGHT', 9, -9)
    btn.BetterIcon:SetSize(32, 32)

    AbilityButton_CreateTypeTips(btn)

    btn.CooldownText=WoWTools_LabelMixin:Create(btn, {justifyH='CENTER', size=32})
    btn.CooldownText:SetPoint('CENTER')

--位置
    local x=(index-NUM_BATTLE_PET_ABILITIES)*(size+6)+2
    if isEnemy then
        btn:SetPoint('LEFT', button, 'RIGHT', (index-1)*(size+6)+2, 0)
    else
        btn:SetPoint('RIGHT', button, 'LEFT', (index-NUM_BATTLE_PET_ABILITIES)*(size+6)-2, 0)
    end


    btn:SetScript('OnLeave', function(self)
        PetBattlePrimaryAbilityTooltip:Hide()
    end)

    btn:SetScript('OnEnter', function(self)
        if self.abilityID then
            PetBattleAbilityTooltip_SetAbilityByID(self.petOwner, self:getPetIndex(), self.abilityID)
            PetBattleAbilityTooltip_Show("BOTTOMRIGHT", self, 'TOPLEFT')
        end
    end)

    btn:RegisterEvent("PET_BATTLE_ACTION_SELECTED")
    btn:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')
    btn:RegisterEvent('PET_BATTLE_OVERRIDE_ABILITY')
    btn:RegisterEvent('PET_BATTLE_PET_CHANGED')
    btn:SetScript('OnEvent', function(self)
        AbilityButton_UpdateTypeTips(self)
        AbilityButton_Update(self)
    end)

    AbilityButton_UpdateTypeTips(btn)
    AbilityButton_Update(btn)

    --table.insert(Buttons, btn)
end
















--设置，宠物，信息
local function Set_PetUnit(self)
    local petIndex= self:getPetIndex()
    if not petIndex then
        return
    end
    local petOwner= self.petOwner

    local petType= petIndex and C_PetBattles.GetPetType(petOwner, petIndex)
    if petType then
        self.texture:SetTexture('Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType])
    else
        self.texture:SetAtlas('summon-random-pet-icon_64')
    end
    self.petType= petType

--图标
    --self.portrait:SetTexture(petTexture)
    SetPortraitToTexture(self.portrait, petIndex and C_PetBattles.GetIcon(petOwner, petIndex) or 0)

--生命
    local health= C_PetBattles.GetHealth(petOwner, petIndex) or 0
    self.frame:SetAlpha(health==0 and 0.3 or 1)

    local maxHealth= C_PetBattles.GetMaxHealth(petOwner, petIndex) or 100
    self.bar:SetValue(health/maxHealth*100)

--等级
    self.LevelText:SetText(C_PetBattles.GetLevel(petOwner, petIndex) or '')

--品质
    local rarity= C_PetBattles.GetBreedQuality(petOwner, petIndex)
    local r,g,b
    if ITEM_QUALITY_COLORS[rarity] then
        r,g,b= ITEM_QUALITY_COLORS[rarity].r, ITEM_QUALITY_COLORS[rarity].g, ITEM_QUALITY_COLORS[rarity].b
    end
    r,g,b= r or 1, g or 1, b or 1
    self.LevelText:SetVertexColor(r,g,b)

    self.border:SetVertexColor(r,g,b)

    self.bar:SetStatusBarColor(r,g,b)
end




















--移动按钮, 菜单
local function Init_Button_Menu(self, root)
    local sub, sub2
--打开，宠物手册
    sub=root:CreateButton(
        '|TInterface\\Icons\\PetJournalPortrait:0|t'..(e.onlyChinese and '宠物手册' or PET_JOURNAL),
    function()
        WoWTools_LoadUIMixin:Journal(2)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)

    root:CreateDivider()
--显示
    root:CreateCheckbox(
        e.Icon.left..(e.onlyChinese and '显示' or SHOW),
    function()
        return self.frame:IsShown()
    end, function()
        Save().AbilityButton['hide'..self.name]= not Save().AbilityButton['hide'..self.name] and true or nil
        self:Settings()
    end)

--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        category= WoWTools_PetBattleMixin.Category,
        name= WoWTools_PetBattleMixin.addName6
    })



--显示背景
    WoWTools_MenuMixin:ShowBackground(sub, function()
        return not Save().AbilityButton['hideBackground'..self.name]
    end, function()
        Save().AbilityButton['hideBackground'..self.name]= not Save().AbilityButton['hideBackground'..self.name] and true or nil
        self:Settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(sub, function()
        return self:GetScale() --Save().AbilityButton['scale'..self.name] or (self.name=='Enemy' and 1 or 0.85)
    end, function(value)
        Save().AbilityButton['scale'..self.name]= value
        self:Settings()
    end)


--FrameStrata      
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().AbilityButton['strata'..self.name]= data
        self:Settings()

    end)

    sub:CreateDivider()
--重置
    sub:CreateButton(
        e.onlyChinese and '重置' or RESET,
    function()
        for name in pairs(Save().AbilityButton) do
            if name:find(self.name) then
                Save().AbilityButton[name]=nil
            end
        end
        self:Settings()
        return MenuResponse.Open
    end)
end




















--设置，移动按钮
local function Set_Move_Button(btn, parent)

    function btn:set_alpha()
        self.texture:SetAlpha(
            (GameTooltip:IsOwned(self) or self.frame:IsShown())
            and 1 or 0.3
        )
    end

    function btn:Settings()
        local show= not Save().AbilityButton.disabled
        if show then

            self:ClearAllPoints()
            local p= Save().AbilityButton['point'..self.name]
            if p then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
            else
                self:SetPoint(self.point[1], self.point[2], self.point[3], self.point[4], self.point[5])
            end

            self:SetFrameStrata(Save().AbilityButton['strata'..self.name] or 'MEDIUM')
            self:SetScale(Save().AbilityButton['scale'..self.name] or (self.name=='Enemy' and 1 or 0.75))
            self.frame:SetShown(not Save().AbilityButton['hide'..self.name])
            self.frame.Background:SetShown(not Save().AbilityButton['hideBackground'..self.name])
            self:set_alpha()
        end
        self:SetShown(show)
    end

    function btn:set_tooltip()
        if self.isEnemy then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
        else
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
        end
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_PetBattleMixin.addName5, WoWTools_PetBattleMixin.addName6)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:Show()
    end


    btn:SetScript('OnLeave', function(self)
        e.tips:Hide()
        ResetCursor()
        self:set_alpha()
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_alpha()
        if self.petType then
            WoWTools_PetBattleMixin.Set_TypeButton_Tips(self.petType)
        end
    end)

    btn:SetClampedToScreen(true)
    btn:SetMovable(true)
    btn:RegisterForDrag('RightButton')
    btn:SetScript('OnDragStart', function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    btn:SetScript('OnDragStop', function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save().AbilityButton['point'..self.name]={self:GetPoint(1)}
        Save().AbilityButton['point'..self.name][2]=nil
    end)

    btn:SetScript('OnMouseUp', ResetCursor)
    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='LeftButton' then
            Save().AbilityButton['hide'..self.name]= not Save().AbilityButton['hide'..self.name] and true or nil
            self.frame:SetShown(not Save().AbilityButton['hide'..self.name])


        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Button_Menu)
        end
        self:set_tooltip()
    end)

	btn:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE");
	btn:RegisterEvent("PET_BATTLE_PET_CHANGED");
    btn:RegisterEvent("PET_BATTLE_MAX_HEALTH_CHANGED")
	btn:RegisterEvent("PET_BATTLE_HEALTH_CHANGED")
	btn:RegisterEvent("PET_BATTLE_PET_CHANGED")
	btn:RegisterEvent("PET_BATTLE_PET_TYPE_CHANGED")

    btn:SetScript('OnEvent', function(self, event)
        Set_PetUnit(self)
    end)

    btn:Settings()

--移动按钮，提示
    parent.petUnitButton= btn
    parent:HookScript('OnLeave', function(self)
        self.petUnitButton.selectTexture:SetShown(false)
    end)
    parent:HookScript('OnEnter', function(self)
        self.petUnitButton.selectTexture:SetShown(true)
    end)

    Set_PetUnit(btn)
end

























local function Init_Button()
    Buttons={}

    local Tab={
        {
            name='Enemy',
            petOwner=Enum.BattlePetOwner.Enemy,
            petIndex=1,
            getPetIndex=function() return C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy) end,
            point={'BOTTOMLEFT', PetBattleFrame.BottomFrame, 'TOPLEFT', 15, 100},
            parent=PetBattleFrame.ActiveEnemy,
        }, {
            name='Enemy2',
            petOwner=Enum.BattlePetOwner.Enemy,
            petIndex=2,
            getPetIndex= function() return PetBattleFrame.Enemy2.petIndex end,
            point={'LEFT', PetBattleFrame.Enemy2, 'RIGHT', 14, 0},
            parent= PetBattleFrame.Enemy2,
        }, {
            name='Enemy3',
            petOwner=Enum.BattlePetOwner.Enemy,
            petIndex=3,
            getPetIndex= function() return PetBattleFrame.Enemy3.petIndex end,
            point={'LEFT', PetBattleFrame.Enemy3, 'RIGHT', 14, -0},
            parent= PetBattleFrame.Enemy3,
        }, {
            name='Ally2',
            petOwner=Enum.BattlePetOwner.Ally,
            petIndex=2,
            getPetIndex= function() return PetBattleFrame.Ally2.petIndex end,
            point={'RIGHT', PetBattleFrame.Ally2, 'LEFT', -14, -6},
            parent= PetBattleFrame.Ally2,
        }, {
            name='Ally3',
            petIndex=3,
            petOwner=Enum.BattlePetOwner.Ally,
            getPetIndex= function() return PetBattleFrame.Ally3.petIndex end,
            point={'RIGHT', PetBattleFrame.Ally3, 'LEFT', -14, -10},
            parent= PetBattleFrame.Ally3,
        }
    }

    local isEnemy

    for _, tab in pairs(Tab) do
        local btn= WoWTools_ButtonMixin:Ctype2(tab.parent, {
            name='WoWTools'..tab.name..'AbilityButton',
            atlas='summon-random-pet-icon_64',
            size=23, 23,
            isType2=true,
        })

        isEnemy= tab.petOwner==Enum.BattlePetOwner.Enemy

        btn.isEnemy= isEnemy
        btn.name= tab.name
        btn.petOwner= tab.petOwner
        btn.getPetIndex= tab.getPetIndex
        btn.point=tab.point

        btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", -3, 0)
        btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT")

        btn.border:SetAlpha(1)

        btn.frame= CreateFrame('Frame', nil, btn)
        btn.frame:SetFrameLevel(btn:GetFrameLevel()-1)
        local s= 23+ (size+6)*NUM_BATTLE_PET_ABILITIES+22
        if isEnemy then
            btn.frame:SetPoint('LEFT', btn, -8, 0)
            btn.frame:SetHeight(size+16)
            btn.frame:SetWidth(s)
        else
            btn.frame:SetPoint('RIGHT', btn, 8, 0)
            btn.frame:SetHeight(size+16)
            btn.frame:SetWidth(s)
        end



--头像
        btn.portrait= btn.frame:CreateTexture(nil, 'BORDER')
        btn.portrait:EnableMouse(true)
        btn.portrait:SetSize(26,26)
        if isEnemy then
            btn.portrait:SetPoint('BOTTOMRIGHT', btn, 'TOPRIGHT')
        else
            btn.portrait:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT')
        end
        btn.portrait:SetScript('OnLeave', function(self)
            self:SetAlpha(1)
            PetBattlePrimaryUnitTooltip:Hide()
        end)
        btn.portrait:SetScript('OnEnter',function(self)
            local parent= self:GetParent():GetParent()
            local petOwner= parent.petOwner
            local petIndex= parent:getPetIndex()
            if not petIndex then
                return
            end
            PetBattlePrimaryUnitTooltip:ClearAllPoints();
            PetBattlePrimaryUnitTooltip:SetParent(UIParent);
            PetBattlePrimaryUnitTooltip:SetFrameStrata("TOOLTIP");
            PetBattlePrimaryUnitTooltip:SetPoint("TOP", parent:GetParent(), "BOTTOM", 0, 0)
            PetBattleUnitTooltip_UpdateForUnit(PetBattlePrimaryUnitTooltip, petOwner, petIndex)
            PetBattlePrimaryUnitTooltip:Show()
            self:SetAlpha(0.3)
        end)


--等级
        btn.LevelUnderlay= btn.frame:CreateTexture(nil, 'BORDER')
        btn.LevelUnderlay:SetAtlas('MainPet-LevelBubble')
        btn.LevelUnderlay:SetSize(20,20)
        btn.LevelUnderlay:SetPoint('TOP', btn, 'BOTTOM')
        

        btn.LevelText= WoWTools_LabelMixin:Create(btn.frame, {justifyH='CENTER'})
        btn.LevelText:SetPoint('CENTER', btn.LevelUnderlay)

--显示背景 Background
        WoWTools_TextureMixin:CreateBackground(btn.frame, {isAllPoint=true})

--select,提示
        btn.selectTexture= btn.frame:CreateTexture(nil, 'BACKGROUND', nil, 2)
        btn.selectTexture:SetAtlas('glues-characterSelect-card-selected-hover')
        btn.selectTexture:SetAllPoints()
        btn.selectTexture:Hide()
--索引
        btn.indexText= WoWTools_LabelMixin:Create(btn, {
            color= isEnemy and {r=1,g=0,b=0} or {r=0,g=1,b=0},
            size=16,
        })
        btn.indexText:SetText(tab.petIndex)
        btn.indexText:SetAlpha(0.5)
        if isEnemy then
            btn.indexText:SetPoint('LEFT', -8, 2)
        else
            btn.indexText:SetPoint('RIGHT', 8, 2)
        end

--生命条
        btn.bar= CreateFrame('StatusBar', nil, btn.frame)
        btn.bar:SetFrameLevel(btn.frame:GetFrameLevel()+1)
        btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        btn.bar:SetOrientation("VERTICAL")
        btn.bar:SetSize(4, size)
        btn.bar:SetMinMaxValues(0,100)
        btn.bar:SetValue(0)
        --btn.bar:SetStatusBarColor(1,0,0)
        s= (size+6)*NUM_BATTLE_PET_ABILITIES+26
        if isEnemy then
            btn.bar:SetPoint('RIGHT', btn, 'LEFT', s+4, 0)
        else
            btn.bar:SetPoint('LEFT', btn, 'RIGHT', -s, 0)
        end

        btn.bar.spark= btn.bar:CreateTexture(nil, 'BACKGROUND')
        btn.bar.spark:SetAtlas('objectivewidget-bar-spark-neutral')
        btn.bar.spark:SetSize(12,2)
        btn.bar.spark:SetPoint('TOP')

        btn.bar.spark5= btn.bar:CreateTexture(nil, 'BACKGROUND')
        btn.bar.spark5:SetAtlas('objectivewidget-bar-spark-neutral')
        btn.bar.spark5:SetSize(12,2)
        btn.bar.spark5:SetPoint('CENTER')

        btn.bar.spark0= btn.bar:CreateTexture(nil, 'BACKGROUND')
        btn.bar.spark0:SetAtlas('objectivewidget-bar-spark-neutral')
        btn.bar.spark0:SetSize(12,2)
        btn.bar.spark0:SetPoint('BOTTOM')


--头像
        btn.portrait= btn.frame:CreateTexture(nil, 'BORDER')
        btn.portrait:SetSize(26,26)

        if isEnemy then
            btn.portrait:SetPoint('BOTTOMRIGHT', btn, 'TOPRIGHT')
        else
            btn.portrait:SetPoint('BOTTOMLEFT', btn, 'TOPLEFT')
        end


--移动按钮
        Set_Move_Button(btn, tab.parent)

--技能按钮
        for index= 1, NUM_BATTLE_PET_ABILITIES do
            Set_Ability_Button(btn, index, isEnemy)
        end

        table.insert(Buttons, btn)
    end












--主面板,主技能, 提示
    for _, btn in pairs(PetBattleFrame.BottomFrame.abilityButtons) do
        if btn.BetterIcon then
            btn.petOwner= Enum.BattlePetOwner.Ally
            btn.getPetIndex= function() return C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally) end
            btn.abilityIndex= btn:GetID()
            AbilityButton_CreateTypeTips(btn)
            AbilityButton_UpdateTypeTips(btn)
        end
    end

    hooksecurefunc('PetBattleAbilityButton_UpdateBetterIcon', function(self)
        if not self.BetterIcon then
            return
        end
        if not self.getPetIndex then
            self.petOwner= Enum.BattlePetOwner.Ally
            self.getPetIndex= function() return C_PetBattles.GetActivePet(Enum.BattlePetOwner.Ally) end
            self.abilityIndex= self:GetID()
            AbilityButton_CreateTypeTips(self)
        end
        AbilityButton_UpdateTypeTips(self)
    end)
end


    --对方, 我方， 技能提示， 框
    --hooksecurefunc('PetBattleFrame_UpdateAllActionButtons', Set_Buttons_State)
--[[
    --对方，技能， 冷却
    hooksecurefunc('PetBattleActionButton_UpdateState', function()
        for _, btn in pairs(Buttons) do
            btn:Settings()
        end
    end)]]

    --[[hooksecurefunc('PetBattleUnitFrame_UpdateDisplay', function()
        for _, btn in pairs(PetButtons) do
            Set_PetUnit(btn)
        end
    end)]]















function WoWTools_PetBattleMixin:Init_AbilityButton()
    if self.Save.AbilityButton.disabled or Buttons then
        if Buttons then
            for _, btn in pairs(Buttons) do
                btn:Settings()
            end
        end
    else
        if C_PetBattles.IsInBattle() then
            C_Timer.After(2, Init_Button)
        else
            Init_Button()
        end
    end
end


