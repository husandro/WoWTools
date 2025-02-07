--技能提示， 框
--Blizzard_PetBattleUI.lua
local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end




local Buttons={}
local size= 52





local function Set_Buttons_State()
    for _, btn in pairs(Buttons) do
        btn:Settings()
    end
end








local function PetBattleAbilityButton_UpdateBetterIcon(self)

	self.BetterIcon:SetShown(false)

    local allyOwner= self.petOwner
	local allyIndex = C_PetBattles.GetActivePet(allyOwner)

    local enemyOwner= allyOwner==Enum.BattlePetOwner.Enemy and Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy
    local enemyIndex= C_PetBattles.GetActivePet(enemyOwner)

	if not allyIndex or not enemyIndex then
		return;
	end

	local allyType, noStrongWeakHints = select(7, C_PetBattles.GetAbilityInfo(allyOwner, allyIndex, self.abilityIndex))


	if not allyType or not noStrongWeakHints then
		return;
	end

	local enemyType = C_PetBattles.GetPetType(enemyOwner, enemyIndex)

	local modifier = C_PetBattles.GetAttackModifier(allyType, enemyType)-- or 1

    print(allyType, enemyType, modifier)

	if (modifier > 1) then
		self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong");
		self.BetterIcon:Show()
	elseif (modifier < 1) then
		self.BetterIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Weak");
		self.BetterIcon:Show()
	end
end





--冷却
local function AbilityButton_UpdateCooldown(self)
    local petIndex= self:getPetIndex()
    local cooldown, r,g,b
    local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(self.petOwner, petIndex, self.abilityIndex)
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
    icon:SetDesaturated(not isUsable)
    icon:SetVertexColor(r,g,b)
    local health = C_PetBattles.GetHealth(self.petOwner, petIndex) or 0
    icon:SetAlpha(health==0 and 0.3 or 1)
end











local function Set_Ability_Button(button, index)
    local btn= WoWTools_ButtonMixin:Cbtn(button.frame, {icon='hide', size=size, setID=index})

    btn.petOwner= button.petOwner
    btn.abilityIndex= index
    btn.getPetIndex= button.getPetIndex

--冷却
    btn.CooldownText=WoWTools_LabelMixin:Create(btn, {justifyH='CENTER', size=32})
    btn.CooldownText:SetPoint('CENTER')

--强弱
    btn.BetterIcon= btn:CreateTexture(nil, 'OVERLAY')
    btn.BetterIcon:SetPoint('BOTTOMRIGHT', 9, -9)
    btn.BetterIcon:SetSize(32, 32)


    function btn:set_other()
        AbilityButton_UpdateCooldown(btn)
        --PetBattleAbilityButton_UpdateBetterIcon(btn)
    end

    btn:SetPoint('LEFT', button.frame, (index-1)*size, 0)

    btn:SetScript('OnLeave', function(self)
        PetBattlePrimaryAbilityTooltip:Hide()
    end)

    btn:SetScript('OnEnter', function(self)
        if self.abilityID then
            PetBattleAbilityTooltip_SetAbilityByID(self.petOwner, self:getPetIndex(), self.abilityID)
            PetBattleAbilityTooltip_Show("BOTTOMRIGHT", self, 'TOPLEFT')

        end
        --PetBattleAbilityButton_UpdateBetterIcon(self)
    end)

    btn:SetScript('OnShow', btn.Settings)

    WoWTools_PetBattleMixin:Create_AbilityButton_Tips(btn)

    table.insert(Buttons, btn)
end






--移动按钮
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
        self:settings()
    end)

--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        category= WoWTools_PetBattleMixin.Category,
        name= WoWTools_PetBattleMixin.addName5
    })



--显示背景
    WoWTools_MenuMixin:ShowBackground(sub, function()
        return not Save().AbilityButton['hideBackground'..self.name]
    end, function()
        Save().AbilityButton['hideBackground'..self.name]= not Save().AbilityButton['hideBackground'..self.name] and true or nil
        self:settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(sub, function()
        return Save().AbilityButton['scale'..self.name] or 1
    end, function(value)
        Save().AbilityButton['scale'..self.name]= value
        self:settings()
    end)


--FrameStrata      
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().AbilityButton['strata'..self.name]= data
        self:settings()
    end)

--重置位置
    WoWTools_MenuMixin:RestPoint(sub, Save().AbilityButton['point'..self.name], function()
        Save().AbilityButton['point'..self.name]= nil
        self:set_point()
        return MenuResponse.Open
    end)
end














--移动按钮
local function Set_Button_Settings(btn)
    function btn:set_point()
        self:ClearAllPoints()
        local p= Save().AbilityButton['point'..self.name]
        if p then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint(self.point[1], self.point[2], self.point[3], self.point[4], self.point[5])
        end
    end

    function btn:set_alpha()
        self.texture:SetAlpha(
            (GameTooltip:IsOwned(self) or self.frame:IsShown())
            and 1 or 0.3
        )
    end

    function btn:settings()
        self:SetFrameStrata(Save().AbilityButton['strata'..self.name] or 'MEDIUM')
        self:set_alpha()
        self.frame:SetScale(Save().AbilityButton['scale'..self.name] or 1)
        self.frame:SetShown(not Save().AbilityButton['hide'..self.name])
        self.frame.Background:SetShown(not Save().AbilityButton['hideBackground'..self.name])
    end

    function btn:set_tooltip()
        if self.isEnemy then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
        else
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
        end
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_PetBattleMixin.addName, WoWTools_PetBattleMixin.addName5)
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
        ResetCursor();
        self:StopMovingOrSizing()
        Save().AbilityButton['point'..self.name]={self:GetPoint(1)}
        Save().AbilityButton['point'..self.name][2]=nil
    end)

    btn:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='LeftButton' then
            Save().AbilityButton['hide'..self.name]= not Save().AbilityButton['hide'..self.name] and true or nil
            self:settings()

        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Button_Menu)
        end
        self:set_tooltip()
    end)

    btn:SetScript('OnMouseUp', ResetCursor)



    btn:set_point()
    btn:settings()
end




















local function Init_Button()
    local Tab={
        {
            name='Enemy',
            petOwner=Enum.BattlePetOwner.Enemy,
            petIndex=1,
            getPetIndex=function()
                return C_PetBattles.GetActivePet(Enum.BattlePetOwner.Enemy)
            end,
            point={'BOTTOM', PetBattleFrame.BottomFrame, 'TOP', -50, 100}
        }, {
            name='Enemy2',
            petOwner=Enum.BattlePetOwner.Enemy,
            petIndex=2,
            getPetIndex= function()
                return PetBattleFrame.Enemy2.petIndex
            end,
            point={'LEFT', PetBattleFrame.Enemy2, 'RIGHT', 4, 0},
        }, {
            name='Enemy3',
            petOwner=Enum.BattlePetOwner.Enemy,
            petIndex=3,
            getPetIndex= function()
                return PetBattleFrame.Enemy3.petIndex
            end,
            point={'LEFT', PetBattleFrame.Enemy3, 'RIGHT', 4, 0},
        }, {
            name='Ally2',
            petOwner=Enum.BattlePetOwner.Ally,
            petIndex=2,
            getPetIndex= function()
                return PetBattleFrame.Ally2.petIndex
            end,
            point={'RIGHT', PetBattleFrame.Ally2, 'LEFT', -4, 0},

        }, {
            name='Ally3',
            petIndex=3,
            petOwner=Enum.BattlePetOwner.Ally,
            getPetIndex= function()
                return PetBattleFrame.Ally3.petIndex
            end,
            point={'RIGHT', PetBattleFrame.Ally3, 'LEFT', -4, 0},
        }
    }

    for _, tab in pairs(Tab) do
        local btn= WoWTools_ButtonMixin:Ctype2(PetBattleFrame, {
            name='WoWTools'..tab.name..'AbilityButton',
            atlas='summon-random-pet-icon_128',
            size=23, 23,
            isType2=true,
        })

        btn.isEnemy= tab.petOwner==Enum.BattlePetOwner.Enemy
        btn.name= tab.name
        btn.petOwner= tab.petOwner
        btn.getPetIndex= tab.getPetIndex
        btn.point=tab.point

        btn.frame= CreateFrame('Frame', nil, btn)
        btn.frame:SetSize(size*NUM_BATTLE_PET_ABILITIES, size)
        if btn.isEnemy then
            btn.frame:SetPoint('LEFT', btn, 'RIGHT')
        else
            btn.frame:SetPoint('RIGHT', btn, 'LEFT')
        end

--显示背景 Background
        WoWTools_TextureMixin:CreateBackground(btn.frame,{
            point=function(texture)
                texture:SetPoint('TOPLEFT', -2, 2)
                texture:SetPoint('BOTTOMRIGHT', 2, -2)
            end
        })

--索引
        btn.indexText= WoWTools_LabelMixin:Create(btn, {
            color= btn.isEnemy and {r=1,g=0,b=0} or {r=0,g=1,b=0}
        })
        btn.indexText:SetText(tab.petIndex)
        btn.indexText:SetPoint('BOTTOM', btn, 'TOP')
        --[[if btn.isEnemy then
            btn.indexText:SetPoint('LEFT', btn, 'RIGHT', size*NUM_BATTLE_PET_ABILITIES, 0)
        else
            btn.indexText:SetPoint('RIGHT', btn, 'LEFT', -(size*NUM_BATTLE_PET_ABILITIES), 0)
        end]]

--移动按钮
        Set_Button_Settings(btn)

--技能按钮
        for index= 1, NUM_BATTLE_PET_ABILITIES do
            Set_Ability_Button(btn, index)
        end
    end










    --对方, 我方， 技能提示， 框
    --hooksecurefunc('PetBattleFrame_UpdateAllActionButtons', Set_Buttons_State)

    --对方，技能， 冷却
    hooksecurefunc('PetBattleActionButton_UpdateState', Set_Buttons_State)

    return true
end















function WoWTools_PetBattleMixin:Init_AbilityButton()
    if Init_Button() then
        Init_Button=function()end
        return true
    end

end



