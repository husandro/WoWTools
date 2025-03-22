--技能提示， 框
--Blizzard_PetBattleUI.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end

local Buttons--5*3 技能按钮
local size= 52


--[[
Enum.BattlePetOwner.Weather
Enum.BattlePetOwner.Enemy
Enum.BattlePetOwner.Ally
]]





local function Get_Pet_Quality(petOwner, petIndex)
    local rarity,color,r,g,b,hex
    if petOwner and petIndex then
        rarity= C_PetBattles.GetBreedQuality(petOwner, petIndex)
        color= ITEM_QUALITY_COLORS[rarity]
        if color then
            r,g,b= color.r, color.g, color.b
        end
    end
    return rarity, color, r or 1, g or 0.82, b or 0
end






local function AbilityButton_UpdateTypeTips(self)
    local petIndex= C_PetBattles.IsInBattle() and self:getPetIndex()-- or self.petIndex
    if not petIndex then
        return
    end
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
    local petIndex= C_PetBattles.IsInBattle() and self:getPetIndex()
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
    local enemyOwner= PetBattleUtil_GetOtherPlayer(petOwner)-- petOwner==Enum.BattlePetOwner.Enemy and Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy
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

    --local auraID = PET_BATTLE_PET_TYPE_PASSIVES[petType]
end









local function AbilityButton_CreateTypeTips(btn)
    if btn.StrongTexture then
        return
    end

    btn.StrongTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 1)
    btn.StrongTexture:SetPoint('TOPLEFT', btn, -10, 2)
    btn.StrongTexture:SetSize(20,20)

    btn.UpTexture=btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.UpTexture:SetPoint('TOP', btn.StrongTexture,'BOTTOM',0, 6)
    btn.UpTexture:SetSize(8,8)
    btn.UpTexture:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Strong')

    btn.TypeTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 1)
    btn.TypeTexture:SetPoint('LEFT', btn, -10, 0)
    btn.TypeTexture:SetSize(20,20)

    btn.DownTexture=btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.DownTexture:SetPoint('TOP', btn.TypeTexture, 'BOTTOM', 0, 6)
    btn.DownTexture:SetSize(8,8)
    btn.DownTexture:SetTexture('Interface\\PetBattles\\BattleBar-AbilityBadge-Weak')


    btn.WeakHintsTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 1)
    btn.WeakHintsTexture:SetPoint('BOTTOMLEFT',-10,-2)
    btn.WeakHintsTexture:SetSize(20,20)

    btn.MaxCooldownText=WoWTools_LabelMixin:Create(btn, {color={r=1,g=0,b=0}, justifyH='RIGHT'})--nil, nil, nil,{1,0,0}, 'OVERLAY', 'RIGHT')
    btn.MaxCooldownText:SetPoint('RIGHT', 0, -4)
end











local function Set_Ability_Button(button, index, isEnemy)
    local btn= WoWTools_ButtonMixin:Cbtn(button.frame, {size=size})

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
        btn:SetPoint('LEFT', button, 'RIGHT', (index-1)*(size+10)+6, 0)
    else
        btn:SetPoint('RIGHT', button, 'LEFT', (index-NUM_BATTLE_PET_ABILITIES)*(size+10)-6, 0)
    end


    btn:SetScript('OnLeave', function(self)
        PetBattlePrimaryAbilityTooltip:Hide()
        self:GetParent():GetParent().parent:SetAlpha(1)
    end)

    btn:SetScript('OnEnter', function(self)
        if self.abilityID then
            PetBattleAbilityTooltip_SetAbilityByID(self.petOwner, self:getPetIndex(), self.abilityID)
            PetBattleAbilityTooltip_Show("BOTTOMRIGHT", self, 'TOPLEFT')
        end
        self:GetParent():GetParent().parent:SetAlpha(0.5)
    end)

    btn:RegisterEvent("PET_BATTLE_ACTION_SELECTED")
    btn:RegisterEvent('PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE')
    btn:RegisterEvent('PET_BATTLE_OVERRIDE_ABILITY')
    btn:SetScript('OnEvent', function(self, event)
        AbilityButton_UpdateTypeTips(self)
        AbilityButton_Update(self)
    end)

    AbilityButton_UpdateTypeTips(btn)
    AbilityButton_Update(btn)
end



















--宠物，提示
local function Set_PetUnit_Tooltip(objec)
    objec:EnableMouse(true)
    objec:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        PetBattlePrimaryUnitTooltip:Hide()
    end)
    objec:SetScript('OnEnter',function(self)
        self:SetAlpha(0.3)
        local parent= self:GetParent():GetParent()
        local petOwner= parent.petOwner
        local petIndex= parent:getPetIndex()
        if not petIndex or not C_PetBattles.GetName(petOwner, petIndex) then
            return
        end
        PetBattlePrimaryUnitTooltip:ClearAllPoints()
        PetBattlePrimaryUnitTooltip:SetParent(UIParent)
        PetBattlePrimaryUnitTooltip:SetFrameStrata("TOOLTIP")
        if parent.parent then
            PetBattlePrimaryUnitTooltip:SetPoint("TOP", parent.parent or self, "BOTTOM")
        else
            PetBattlePrimaryUnitTooltip:SetPoint("BOTTOM", self, "TOP")
        end
        PetBattleUnitTooltip_UpdateForUnit(PetBattlePrimaryUnitTooltip, petOwner, petIndex)
        PetBattlePrimaryUnitTooltip:Show()
    end)
end















--光环
local function Create_PetUnit_Aura(btn, index)
    local icon= btn.Auras[index]
    if icon then
        return icon
    end

    local n=3
    local s= math.floor(btn.frame:GetHeight()/ n)

    icon= btn.frame:CreateTexture(nil, 'BORDER', nil, 1)
    icon:SetSize(s,s)
    icon:EnableMouse(true)
    local a,b= math.modf((index-1)/n)
    if b==0 then
        if btn.isEnemy then
            icon:SetPoint('TOPLEFT', btn.frame, 'TOPRIGHT', a*s, 0)
        else
            icon:SetPoint('TOPRIGHT', btn.frame, 'TOPLEFT', -a*s, 0)
        end
    else
        icon:SetPoint('TOP', btn.Auras[index-1], 'BOTTOM')
    end

    icon.buff= btn.frame:CreateTexture(nil, 'BORDER', nil, 2)
    icon.buff:SetPoint('TOPLEFT', icon)
    icon.buff:SetPoint('BOTTOMRIGHT', icon)
    icon.buff:SetAtlas('delves-curios-icon-border')

    icon.turnsText= WoWTools_LabelMixin:Create(btn.frame, {justifyH='RIGHT', size=12, color={r=1,g=1,b=1}})
    icon.turnsText:SetPoint('BOTTOMRIGHT', icon,1,0)

    function icon:set_show(show)
        self:SetShown(show)
        self.buff:SetShown(show)
        self.turnsText:SetShown(show)
    end

    icon:SetScript('OnLeave', function(self)
        PetBattlePrimaryAbilityTooltip:Hide()
        self:GetParent():GetParent().parent:SetAlpha(1)
        self:SetAlpha(1)
    end)

    icon:SetScript('OnEnter', function(self)
        local frame= self:GetParent()
        local button= frame:GetParent()
        if self.abilityID then
            PetBattleAbilityTooltip_SetAbilityByID(button.petOwner, button:getPetIndex(), self.abilityID)
            if button.isEnemy then
                PetBattleAbilityTooltip_Show("BOTTOMRIGHT", frame, 'TOPRIGHT')
            else
                PetBattleAbilityTooltip_Show("BOTTOMLEFT", frame, 'TOPLEFT')
            end
        end
        self:SetAlpha(0.5)
    end)

    table.insert(btn.Auras, icon)
    return icon
end





--光环
local function Set_PetUnit_Aura(self, petOwner, petIndex)
    local num= C_PetBattles.GetNumAuras(petOwner, petIndex) or 0
    for index=1, num do
		local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(petOwner, petIndex, index)

        local abilityID, name, icon= C_PetBattles.GetAbilityInfoByID(auraID)
        local aura= Create_PetUnit_Aura(self, index)


        aura:SetTexture(icon or 0)
        aura.turnsText:SetText(turnsRemaining and turnsRemaining>0 and turnsRemaining or '')

        aura.abilityID= abilityID

        if isBuff then
            aura.buff:SetVertexColor(0,1,0)
        else
            aura.buff:SetVertexColor(1,0,0)
        end

        aura:set_show(icon)
    end
    for index=num+1, #self.Auras do
        self.Auras[index]:set_show(false)
    end
end

















--宠物，属性
local function Crea_PetUnit_Attributes(btn, isEnemy)
    local s=18
    local justifyH= isEnemy and 'LEFT' or 'RIGHT'

--力量
    btn.AttackIcon= btn.frame:CreateTexture(nil, 'BORDER')
    btn.AttackIcon:SetTexture('Interface\\PetBattles\\PetBattle-StatIcons')
    btn.AttackIcon:SetSize(s,s)
    btn.AttackIcon.Text= WoWTools_LabelMixin:Create(btn.frame, {justifyH=justifyH, size=16})

--速度
    btn.SpeedIcon= btn.frame:CreateTexture(nil, 'BORDER')
    btn.SpeedIcon:SetTexture('Interface\\PetBattles\\PetBattle-StatIcons')
    btn.SpeedIcon:SetSize(s,s)
    btn.SpeedIcon:SetPoint('TOP', btn.AttackIcon, 'BOTTOM')
    btn.SpeedIcon.Text= WoWTools_LabelMixin:Create(btn.frame, {justifyH=justifyH, size=16})

--收集
    btn.CollectedIcon= btn.frame:CreateTexture(nil, 'BORDER')
    btn.CollectedIcon:SetAtlas('WildBattlePet')
    btn.CollectedIcon:SetSize(s,s)
    btn.CollectedIcon:SetPoint('TOP', btn.SpeedIcon, 'BOTTOM')
    btn.CollectedIcon.Text= WoWTools_LabelMixin:Create(btn.frame, {justifyH=justifyH, size=16})
    btn.CollectedIcon.Text2= WoWTools_LabelMixin:Create(btn.frame, {justifyH=isEnemy and 'RIGHT' or 'LEFT', size=14})

    if isEnemy then
        btn.AttackIcon:SetPoint('TOPLEFT', btn.bar , 'TOPRIGHT', 4, 4)

        btn.AttackIcon.Text:SetPoint('LEFT', btn.AttackIcon, 'RIGHT')
        btn.SpeedIcon.Text:SetPoint('LEFT', btn.SpeedIcon, 'RIGHT')
        btn.CollectedIcon.Text:SetPoint('LEFT', btn.CollectedIcon, 'RIGHT')
        btn.CollectedIcon.Text2:SetPoint('BOTTOMRIGHT', btn.frame)

        btn.AttackIcon:SetTexCoord(0, 0.5, 0, 0.5)
        btn.SpeedIcon:SetTexCoord(0, 0.5, 0.5, 1)
    else
        btn.AttackIcon:SetPoint('TOPRIGHT', btn.bar, 'TOPLEFT', -4, 4)
        btn.AttackIcon.Text:SetPoint('RIGHT', btn.AttackIcon, 'LEFT')
        btn.SpeedIcon.Text:SetPoint('RIGHT', btn.SpeedIcon, 'LEFT')
        btn.CollectedIcon.Text:SetPoint('RIGHT', btn.CollectedIcon, 'LEFT')
        btn.CollectedIcon.Text2:SetPoint('BOTTOMLEFT', btn.frame)

        btn.AttackIcon:SetTexCoord(0.5, 0, 0, 0.5)
        btn.SpeedIcon:SetTexCoord(0.5, 0, 0.5, 1)
    end

    --Set_PetUnit_Tooltip(btn.AttackIcon)--宠物，提示
    --Set_PetUnit_Tooltip(btn.SpeedIcon)--宠物，提示
    --Set_PetUnit_Tooltip(btn.CollectedIcon)--宠物，提示
end





--属性
local function Set_PetUnit_Attributes(self, petOwner, petIndex)
    local enemyOwner= PetBattleUtil_GetOtherPlayer(petOwner)-- petOwner==Enum.BattlePetOwner.Enemy and Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy
    local enemyIndex= C_PetBattles.GetActivePet(enemyOwner)
    local isWildBattle=  C_PetBattles.IsWildBattle()

--收集
    local num, collected= select(2, WoWTools_PetBattleMixin:Collected(nil, nil, nil, petOwner, petIndex))--总收集数量， 25 25 25， 已收集3/3
    self.CollectedIcon.Text:SetText(collected or '')
    self.CollectedIcon.Text2:SetText(C_PetBattles.IsWildBattle() and num or '')

--力量
    local petPower = C_PetBattles.GetPower(petOwner, petIndex) or 0
    local petEnemyPower = C_PetBattles.GetPower(enemyOwner, enemyIndex) or 0
    self.AttackIcon.Text:SetText(petPower)
    if petPower>petEnemyPower then
        self.AttackIcon.Text:SetTextColor(0,1,0)
    else
        self.AttackIcon.Text:SetTextColor(1,0.82,0)
    end

--速度
    local petSpeed = C_PetBattles.GetSpeed(petOwner, petIndex) or 0
    local petEnemySpeed = C_PetBattles.GetSpeed(enemyOwner, enemyIndex) or 0
    self.SpeedIcon.Text:SetText(petSpeed)
    if petSpeed>petEnemySpeed then
        self.SpeedIcon.Text:SetTextColor(0,1,0)
    else
        self.SpeedIcon.Text:SetTextColor(1,0.82,0)
    end
end








--清除，宠物，信息
local function Clear_PetUnit_All(self)
    self.texture:SetTexture(0)
    self.petType=nil
    self.bar:SetValue(0)
    self.bar.valueText:SetText('')
    self.portrait:SetTexture(0)
    self.LevelText:SetText('')
    self.nameText:SetText("")
    self.displayID=nil
    self.PetModel:ClearModel()--3D

--光环
    for index=1, #self.Auras do
        local icon= self.Auras[index]
        icon.buff:SetTexture(0)
        icon.turnsText:SetText("")
    end

--属性
    self.CollectedIcon.Text:SetText('')
    self.CollectedIcon.Text2:SetText('')
    self.AttackIcon.Text:SetText('')
    self.SpeedIcon.Text:SetText('')
end








--设置，宠物，信息
local function Set_PetUnit(self)
    local petIndex= self:getPetIndex()
    local petOwner= self.petOwner

    local name, speciesName
    if C_PetBattles.IsInBattle() and petIndex and not Save().AbilityButton.disabled then
        name, speciesName= C_PetBattles.GetName(petOwner, petIndex)
    end
    if not name then
        Clear_PetUnit_All(self)
        self:SetShown(false)
        return
    end
    self:SetShown(true)


    local isEnemy= self.isEnemy

    local petType= petIndex and C_PetBattles.GetPetType(petOwner, petIndex)
    if petType then
        self.texture:SetTexture('Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType])
    else
        self.texture:SetAtlas('summon-random-pet-icon_64')
    end
    self.petType= petType


--生命
    local health= C_PetBattles.GetHealth(petOwner, petIndex) or 0
    local maxHealth= C_PetBattles.GetMaxHealth(petOwner, petIndex) or 100

    local value= health/maxHealth*100
    self.frame:SetAlpha(health==0 and 0.5 or 1)
    self.bar:SetValue(value)
    self.bar.valueText:SetFormattedText('%i', value)

--品质
    local r,g,b= select(3, Get_Pet_Quality(petOwner, petIndex))

--图标
    SetPortraitToTexture(self.portrait, petIndex and C_PetBattles.GetIcon(petOwner, petIndex) or 0)
    self.portrait.border:SetVertexColor(r,g,b)

--等级
    self.LevelText:SetText(C_PetBattles.GetLevel(petOwner, petIndex) or '')
    self.LevelText:SetVertexColor(r,g,b)
    self.LevelUnderlay:SetVertexColor(r,g,b)

--按钮，框
    self.border:SetVertexColor(r,g,b)

--名称
    self.nameText:SetText(
        (WoWTools_TextMixin:CN(name) or '')
        ..(speciesName and name~=speciesName and ' ['..speciesName..']' or '')
    )
    self.nameText:SetTextColor(r,g,b)

--3D
    local displayID= C_PetBattles.GetDisplayID(petOwner, petIndex)
    if displayID and displayID~= self.displayID then
        self.PetModel:SetDisplayInfo(displayID)
    end
    self.displayID= displayID

    Set_PetUnit_Aura(self, petOwner, petIndex)--光环
    Set_PetUnit_Attributes(self, petOwner, petIndex)--属性
end




















--移动按钮, 菜单
local function Init_Button_Menu(self, root)
    local sub

--打开，宠物手册
    local petIndex= self:getPetIndex()
    local name= petIndex and C_PetBattles.GetName(self.petOwner, petIndex)
    local icon= name and C_PetBattles.GetIcon(self.petOwner, petIndex)
    local color= name and select(2, Get_Pet_Quality(self.petOwner, petIndex))

    sub=root:CreateButton(
        name and color.hex..'|T'..icon..':0|t'..WoWTools_TextMixin:CN(name)
            or '|TInterface\\Icons\\PetJournalPortrait:0|t'..(WoWTools_Mixin.onlyChinese and '宠物手册' or PET_JOURNAL),
    function(data)
        WoWTools_LoadUIMixin:Journal(2, {petOwner=self.petOwner, petIndex=self:getPetIndex()})
        return MenuResponse.Open
    end, name and true or false)
    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_Mixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
        if desc.data then
            tooltip:AddLine(' ')
            tooltip:AddLine(WoWTools_Mixin.onlyChinese and '在手册中显示该宠物' or PET_SHOW_IN_JOURNAL)
        end
    end)



    root:CreateDivider()
--显示
    root:CreateCheckbox(
        WoWTools_DataMixin.Icon.left..(WoWTools_Mixin.onlyChinese and '显示' or SHOW),
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

--显示名称
    sub:CreateCheckbox(
        '|A:WildBattlePetCapturable:0:0|a'..(WoWTools_Mixin.onlyChinese and '显示名称' or PROFESSIONS_FLYOUT_SHOW_NAME),
    function(data)
        return Save().AbilityButton['showName_'..self.name]
    end, function(data)
        Save().AbilityButton['showName_'..self.name]= not Save().AbilityButton['showName_'..self.name] and true or nil
        self:set_name_shown()
    end)

--3D
    sub:CreateCheckbox(
        '|A:WildBattlePetCapturable:0:0|a'..(WoWTools_Mixin.onlyChinese and '显示3D' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, '3D')),
    function(data)
        return Save().AbilityButton['petmodelShow_'..self.name]
    end, function(data)
        Save().AbilityButton['petmodelShow_'..self.name]= not Save().AbilityButton['petmodelShow_'..self.name] and true or nil
        self.PetModel:Settings()
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(sub, function()
        return not Save().AbilityButton['hideBackground'..self.name]
    end, function()
        Save().AbilityButton['hideBackground'..self.name]= not Save().AbilityButton['hideBackground'..self.name] and true or nil
        self:Settings()
        self.PetModel:Settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
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
        WoWTools_Mixin.onlyChinese and '重置' or RESET,
    function()
        for name2 in pairs(Save().AbilityButton) do
            if name2:find(self.name) then
                Save().AbilityButton[name2]=nil
            end
        end
        self:Settings()
        return MenuResponse.CloseAll
    end)
end




















--设置，移动按钮
local function Set_Move_Button(btn)

    function btn:set_alpha()
        self.texture:SetAlpha(
            (GameTooltip:IsOwned(self) or self.frame:IsShown())
            and 1 or 0.3
        )
    end

    function btn:set_name_shown()
        self.nameText:SetShown(Save().AbilityButton['showName_'..self.name])
    end

    function btn:Settings()
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
        self:set_name_shown()
        Set_PetUnit(self)
        self.PetModel:Settings()--3D
    end

    function btn:set_tooltip()
        if self.isEnemy then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        end
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_PetBattleMixin.addName5, WoWTools_PetBattleMixin.addName6)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end


    btn:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        ResetCursor()
        self:set_alpha()
        btn.parent:SetAlpha(1)
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:set_alpha()
        if self.petType then
            WoWTools_PetBattleMixin.Set_TypeButton_Tips(self.petType)
        end
        btn.parent:SetAlpha(0.5)
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









--3D
    function btn.PetModel:Settings()
        local name=self:GetParent():GetParent().name
        local value= Save().AbilityButton['petmodelCDS_'..name] or 0.9
        self:SetCamDistanceScale(value)
        self:SetShown(Save().AbilityButton['petmodelShow_'..name])

        local showBg= not Save().AbilityButton['hideBackground'..name]
        self.bg:SetShown(showBg)
        self.shadow:SetShown(showBg)
    end
    btn.PetModel:EnableMouseWheel(true)
    btn.PetModel:SetScript('OnMouseWheel', function(self, d)
        local name= self:GetParent():GetParent().name
        local value= (Save().AbilityButton['petmodelCDS_'..name] or 0.9) +(d==-1 and 0.1 or -0.1)
        value= math.min(value, 2)
        value= math.max(value, 0.1)
        Save().AbilityButton['petmodelCDS_'..name]=value
        self:Settings()
    end)


--移动按钮，提示
    btn.parent.petUnitButton= btn
    btn.parent:HookScript('OnLeave', function(self)
        self.petUnitButton.selectTexture:SetShown(false)
    end)
    btn.parent:HookScript('OnEnter', function(self)
        self.petUnitButton.selectTexture:SetShown(true)
    end)

--事件
    btn:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
	btn:RegisterEvent("PET_BATTLE_PET_CHANGED")
    btn:RegisterEvent("PET_BATTLE_MAX_HEALTH_CHANGED")
	btn:RegisterEvent("PET_BATTLE_HEALTH_CHANGED")
	btn:RegisterEvent("PET_BATTLE_PET_TYPE_CHANGED")
    btn:RegisterEvent("PET_BATTLE_OPENING_DONE")
    btn:RegisterEvent("PET_BATTLE_CLOSE")
    btn:SetScript('OnEvent', function(self)
        Set_PetUnit(self)
    end)
    btn:Settings()
end

























local function Init_Button(tab)
    local isEnemy, s, height
    local btn= WoWTools_ButtonMixin:Cbtn(PetBattleFrame, {
        name='WoWTools'..tab.name..'AbilityButton',
        atlas='summon-random-pet-icon_64',
        size=32,
        isType2=true,
    })

    isEnemy= tab.petOwner==Enum.BattlePetOwner.Enemy

    btn.isEnemy= isEnemy
    btn.name= tab.name
    btn.petOwner= tab.petOwner
    btn.getPetIndex= tab.getPetIndex
    btn.point=tab.point
    btn.parent=tab.parent
    btn.parent2=tab.parent2
    btn.Auras={}

    btn.mask:SetPoint("TOPLEFT", btn, "TOPLEFT")
    btn.mask:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT")

    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT",-5,2)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT",0,-2)

    btn.border:ClearAllPoints()
    btn.border:SetPoint("TOPLEFT", btn, "TOPLEFT")
    btn.border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -3,3)

    btn.border:SetAlpha(1)
    btn.border:SetAtlas('Adventurers-Frame-Soulbind-Kyrian')

    btn.frame= CreateFrame('Frame', nil, btn)
    btn.frame:SetFrameLevel(btn:GetFrameLevel()-1)

    s= (size+6)*NUM_BATTLE_PET_ABILITIES +120
    height= size+20
    if isEnemy then
        btn.frame:SetPoint('LEFT', btn, -8, 0)
        btn.frame:SetHeight(height)
        btn.frame:SetWidth(s)
    else
        btn.frame:SetPoint('RIGHT', btn, 8, 0)
        btn.frame:SetHeight(height)
        btn.frame:SetWidth(s)
    end


--3D
    btn.PetModel= CreateFrame("PlayerModel", nil, btn.frame)
    btn.PetModel:SetFacing(isEnemy and 0.3 or -0.3)
    btn.PetModel:SetSize(height, height)
    if isEnemy then
        btn.PetModel:SetPoint('RIGHT', btn.frame, 'LEFT')
    else
        btn.PetModel:SetPoint('LEFT', btn.frame, 'RIGHT')
    end
    btn.PetModel.bg= btn.PetModel:CreateTexture(nil, 'BACKGROUND')
    btn.PetModel.bg:SetAllPoints()
    btn.PetModel.bg:SetAtlas(isEnemy and 'hunter-stable-bg-art_ferocity' or 'hunter-stable-bg-art_cunning')
    btn.PetModel.bg:SetAlpha(0.75)
    if isEnemy then
        btn.PetModel.bg:SetTexCoord(1,0,0,1)
    end

    btn.PetModel.shadow= btn.PetModel:CreateTexture(nil, 'ARTWORK')
    btn.PetModel.shadow:SetAtlas('perks-char-shadow')
    btn.PetModel.shadow:SetSize(height-18, 18)
    btn.PetModel.shadow:SetAlpha(0.7)
    btn.PetModel.shadow:SetPoint(isEnemy and 'BOTTOMRIGHT' or 'BOTTOMLEFT',btn.PetModel, 0,-3)



--名称
    btn.nameText= WoWTools_LabelMixin:Create(btn.frame, {size=16})
    btn.nameText:SetPoint('TOP', 0, 10)
    --Set_PetUnit_Tooltip(btn.nameText)--宠物，提示

--头像
    btn.portrait= btn.frame:CreateTexture(nil, 'BORDER', nil, 1)
    btn.portrait:SetSize(26,26)
    btn.portrait:SetPoint('BOTTOM', btn, 'TOP', isEnemy and -2 or 0, -4)
    Set_PetUnit_Tooltip(btn.portrait)--宠物，提示

--头像, 外框
    btn.portrait.border= btn.frame:CreateTexture(nil, 'BORDER', nil, 2)
    btn.portrait.border:SetSize(28,28)
    btn.portrait.border:SetPoint('CENTER', btn.portrait)
    btn.portrait.border:SetAtlas('Adventurers-Frame-Soulbind-Kyrian')

--等级
    btn.LevelUnderlay= btn.frame:CreateTexture(nil, 'BORDER')
    btn.LevelUnderlay:SetAtlas('Adventurers-Frame-Soulbind-Kyrian')
    btn.LevelUnderlay:SetSize(24,24)
    btn.LevelUnderlay:SetPoint('TOP', btn, 'BOTTOM', -1, 6)
    btn.LevelText= WoWTools_LabelMixin:Create(btn.frame, {justifyH='CENTER', size=14})
    btn.LevelText:SetPoint('CENTER', btn.LevelUnderlay,1,1)
    --Set_PetUnit_Tooltip(btn.LevelUnderlay)--宠物，提示

--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(btn.frame, {isAllPoint=true})

    --btn.Background= btn.frame:CreateTexture(nil, 'BACKGROUND', nil, 1)
    --btn.Background:SetAllPoints()

--select,提示
    btn.selectTexture= btn.frame:CreateTexture(nil, 'BACKGROUND', nil, 2)
    btn.selectTexture:SetAtlas('glues-characterSelect-card-selected-hover')
    btn.selectTexture:SetAllPoints()
    btn.selectTexture:Hide()

--索引
    btn.indexText= WoWTools_LabelMixin:Create(btn, {
        color= isEnemy and {r=1,g=0,b=0, a=0.5} or {r=0,g=1,b=0, a=0.5},
        size=16,
    })
    btn.indexText:SetText(tab.petIndex)
    --btn.indexText:SetAlpha(0.5)
    if isEnemy then
        btn.indexText:SetPoint('LEFT', btn.frame, 0.5, 2)--, -10, 2)
    else
        btn.indexText:SetPoint('RIGHT', btn.frame, -1, 2)--10, 2)
    end

--生命条
    btn.bar= CreateFrame('StatusBar', nil, btn.frame)
    btn.bar:SetFrameLevel(btn.frame:GetFrameLevel()+1)
    btn.bar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
    btn.bar:SetOrientation("VERTICAL")
    btn.bar:SetStatusBarColor(1,0,0)
    btn.bar:SetSize(6, size)
    btn.bar:SetMinMaxValues(0,100)
    btn.bar:SetValue(0)
    s= (size+6)*NUM_BATTLE_PET_ABILITIES +34
    if isEnemy then
        btn.bar:SetPoint('RIGHT', btn, 'LEFT', s+20, 0)
    else
        btn.bar:SetPoint('LEFT', btn, 'RIGHT', -s-20, 0)
    end
    --Set_PetUnit_Tooltip(btn.bar)--宠物，提示

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
    btn.bar.valueText= WoWTools_LabelMixin:Create(btn.bar, {color={r=1,g=0.82,b=0}})
    btn.bar.valueText:SetPoint('BOTTOM', btn.bar, 'TOP')

    Crea_PetUnit_Attributes(btn, isEnemy)--宠物，属性

--移动按钮
    Set_Move_Button(btn)

--技能按钮
    for index= 1, NUM_BATTLE_PET_ABILITIES do
        Set_Ability_Button(btn, index, isEnemy)
    end

    table.insert(Buttons, btn)
end

















local function Init()
    Buttons={}
    for _, tab in pairs({
    {
        name='Enemy',
        petOwner=Enum.BattlePetOwner.Enemy,
        petIndex=1,
        getPetIndex=function() return C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy) end,
        --point={'BOTTOMLEFT', PetBattleFrame.BottomFrame, 'TOPLEFT', 15, 250},
        point={'BOTTOM', -320, 350},
        parent=PetBattleFrame.ActiveEnemy,
    }, {
        name='Enemy2',
        petOwner=Enum.BattlePetOwner.Enemy,
        petIndex=2,
        getPetIndex= function() return PetBattleFrame.Enemy2.petIndex end,
        point={'LEFT', PetBattleFrame.Enemy2, 'RIGHT', 12, -12},
        parent= PetBattleFrame.Enemy2,
    }, {
        name='Enemy3',
        petOwner=Enum.BattlePetOwner.Enemy,
        petIndex=3,
        getPetIndex= function() return PetBattleFrame.Enemy3.petIndex end,
        point={'LEFT', PetBattleFrame.Enemy3, 'RIGHT', 12, -34},
        parent= PetBattleFrame.Enemy3,
    }, {
        name='Ally2',
        petOwner=Enum.BattlePetOwner.Ally,
        petIndex=2,
        getPetIndex= function() return PetBattleFrame.Ally2.petIndex end,
        point={'RIGHT', PetBattleFrame.Ally2, 'LEFT', -12, -12},
        parent= PetBattleFrame.Ally2,
        --parent2= PetBattleFrame.BottomFrame.PetSelectionFrame.Pet2,
    }, {
        name='Ally3',
        petIndex=3,
        petOwner=Enum.BattlePetOwner.Ally,
        getPetIndex= function() return PetBattleFrame.Ally3.petIndex end,
        point={'RIGHT', PetBattleFrame.Ally3, 'LEFT', -12, -34},
        parent= PetBattleFrame.Ally3,
        --parent2= PetBattleFrame.BottomFrame.PetSelectionFrame.Pet3,
    }
    }) do
       Init_Button(tab)
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

















--激活，宠物
local function Init_BottomFrame()

--宠物，属性
    hooksecurefunc('PetBattleFrame_UpdateAllActionButtons', function(self)
        local btn= self.BottomFrame.abilityButtons[1]
        local petOwner= Enum.BattlePetOwner.Ally
        local petIndex= C_PetBattles.GetActivePet(petOwner)

        if not btn or Save().AbilityButton.disabled or not petIndex then
            if btn and btn.set_shown then
                btn:set_shown(false)
            end
            return
        end

        if not btn.frame then
            btn.frame= CreateFrame("Frame", nil, btn)
            btn.frame:SetPoint('RIGHT', btn, 'LEFT', -7, 0)
            btn.frame:SetSize(2, 52)
            btn.bar=btn.frame
            function btn:set_shown(show)
                self.frame:SetShown(show)
            end
            Crea_PetUnit_Attributes(btn, false)
            btn.CollectedIcon.Text2:ClearAllPoints()
            btn.CollectedIcon.Text2:SetPoint('TOPRIGHT', btn.CollectedIcon, 'BOTTOMLEFT')
        end
        Set_PetUnit_Attributes(btn, petOwner, petIndex)--属性
        btn:set_shown(true)
    end)

--更换宠物，索引
    for i=1,NUM_BATTLE_PETS_IN_BATTLE do
        if PetBattleFrame.BottomFrame.PetSelectionFrame['Pet'..i] then
            local frame= PetBattleFrame.BottomFrame.PetSelectionFrame['Pet'..i]
            frame.indexLabel= WoWTools_LabelMixin:Create(frame)
            frame.indexLabel:SetPoint('BOTTOM', frame.SelectedTexture, 'TOP', 0, 2)
            frame.indexLabel:SetText(i)
        end
    end

--PetBattlePrimaryUnitTooltip 技能, 提示
    hooksecurefunc('PetBattleUnitTooltip_UpdateForUnit', function(self, petOwner, petIndex)
        if Save().AbilityButton.disabled then
            return
        end
        local find
        for i=1, NUM_BATTLE_PET_ABILITIES do
            local abilityID, name, icon, maxCooldown, _, numTurns, petType= C_PetBattles.GetAbilityInfo(petOwner, petIndex, i)
            if abilityID and name and self["AbilityName"..i]  then
                self["AbilityName"..i]:SetText(
                    (PET_TYPE_SUFFIX[petType] and '|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':0|t' or '')
                    ..'|T'..(icon or 0)..':0|t'
                    ..WoWTools_TextMixin:CN(name, {spellID=abilityID})
                    ..(numTurns and numTurns>0 and ' |cnGREEN_FONT_COLOR:'..numTurns..'|r' or '')
                    ..(maxCooldown and maxCooldown>1 and '/|cnRED_FONT_COLOR:'..maxCooldown..'|r' or '')
                )
                find=true
            end
        end
        if find then
            self:Show()
        end
    end)



end














function WoWTools_PetBattleMixin:Init_AbilityButton()
    if self.Save.AbilityButton.disabled or Buttons then
        if Buttons then
            for _, btn in pairs(Buttons) do
                btn:Settings()
            end
            WoWTools_Mixin:Call(PetBattleFrame_UpdateAllActionButtons, PetBattleFrame)
        end
    else
        if C_PetBattles.IsInBattle() then
            C_Timer.After(2, Init)
        else
            Init()
        end
        Init_BottomFrame()
    end
end

