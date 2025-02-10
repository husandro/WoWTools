local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end


local TypeButton
local Buttons={}


local IsInCheck
local function Set_Button_Highlight(petType)
    if IsInCheck
        or not TypeButton
        or not TypeButton.frame:IsVisible()
    then
        return
    end
    IsInCheck= true

    do
        for _, btn in pairs(Buttons) do
            if btn.petTypeID==petType then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
    end
    
    IsInCheck= nil
end

















local function Set_Button_Script(btn, petTypeID)
    btn.petTypeID= petTypeID
    btn.abilityID= PET_BATTLE_PET_TYPE_PASSIVES[petTypeID]

    btn:SetScript('OnMouseDown', function(self)
        if self.petTypeID then
            if CollectionsJournal and not CollectionsJournal:IsShown() and not UnitAffectingCombat('player') then
                SetCollectionsJournalShown(true, 2)
            end
            for index=1,C_PetJournal.GetNumPetTypes() do
                C_PetJournal.SetPetTypeFilter(index, index==self.petTypeID)
            end
        end
    end)
    btn:SetScript('OnEnter', function(self)
        if self.abilityID then
            FloatingPetBattleAbilityTooltip:ClearAllPoints()
            FloatingPetBattleAbilityTooltip:SetPoint("BOTTOMRIGHT", TypeButton, "TOPRIGHT");
            FloatingPetBattleAbility_Show(self.abilityID)
        end
    end)
    btn:SetScript('OnLeave', function(self)
        FloatingPetBattleAbilityTooltip:Hide()
        self:UnlockHighlight()
    end)

    table.insert(Buttons, btn)

    --btn:GetHighlightTexture():SetVertexColor(0, 1, 0, 1)
    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 1)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, -1)
end




















local function Init_Buttons()
    TypeButton.frame:SetSize(1,1)
    TypeButton.frame:SetPoint('RIGHT')

    for petType=1, C_PetJournal.GetNumPetTypes() do
        local btn= WoWTools_ButtonMixin:Ctype2(TypeButton.frame, {
            size={38,38},
            texture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType],
            isType2=true,
        })
        btn:SetPoint('LEFT', TypeButton, 'RIGHT', (petType-1)*34+2, 0)
        Set_Button_Script(btn, petType)

        local strongTexture, weakHintsTexture, stringIndex, weakHintsIndex= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        if strongTexture then
            btn.indicatoUp=TypeButton.frame:CreateTexture()
            btn.indicatoUp:SetAtlas('bags-greenarrow')
            btn.indicatoUp:SetSize(10,10)
            btn.indicatoUp:SetPoint('BOTTOM', btn,'TOP', 0, -2)

            btn.strong= WoWTools_ButtonMixin:Ctype2(TypeButton.frame, {texture=strongTexture,size={25,25}, isType2=true})
            btn.strong:SetPoint('BOTTOM', btn.indicatoUp, 'TOP', 0, -2)
            Set_Button_Script(btn.strong, stringIndex)
        end
        if weakHintsTexture then
            btn.indicatoDown=TypeButton.frame:CreateTexture()
            btn.indicatoDown:SetAtlas('UI-HUD-MicroMenu-StreamDLRed-Up')
            btn.indicatoDown:SetSize(10,10)
            btn.indicatoDown:SetPoint('TOP', btn, 'BOTTOM', 0, 6)

            btn.weakHints= WoWTools_ButtonMixin:Ctype2(TypeButton.frame, {texture=weakHintsTexture, size={25,25}, isType2=true})
            btn.weakHints:SetPoint('TOP', btn.indicatoDown, 'BOTTOM', 0, 2)
            Set_Button_Script(btn.weakHints, weakHintsIndex)
        end
    end

--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(TypeButton.frame,
    {point=function(texture)
        local num= #Buttons
        texture:SetPoint('LEFT', Buttons[1], -2, 0)
        texture:SetPoint('RIGHT', Buttons[num-2], -1, 0)
        texture:SetPoint('TOP', Buttons[2], 0, 1)
        texture:SetPoint('BOTTOM', Buttons[num])
    end})
end


















local function Init_Menu(self, root)
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
        Save().TypeButton.hideFrame= not Save().TypeButton.hideFrame and true or nil
        self:set_Frame_shown()
    end)

--打开选项界面
    root:CreateDivider()
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        category= WoWTools_PetBattleMixin.Category,
        name= WoWTools_PetBattleMixin.addName4
    })

--总是显示
    sub2=sub:CreateCheckbox(
        e.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS,
    function()
        return Save().TypeButton.allShow
    end, function()
        Save().TypeButton.allShow= not Save().TypeButton.allShow and true or nil
        self:set_event()
        self:set_shown()
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_PetBattleMixin.addName4)
        tooltip:AddLine(' ')
        tooltip:AddLine(e.onlyChinese and '自动显示：'
            or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SHOW)..':')
        )
        tooltip:AddLine(e.onlyChinese and '宠物手册' or PET_JOURNAL)
        tooltip:AddLine(e.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(sub, function()
        return Save().TypeButton.showBackground
    end, function()
        Save().TypeButton.showBackground= not Save().TypeButton.showBackground and true or nil
        self:set_Background()
    end)

--缩放
    WoWTools_MenuMixin:Scale(sub, function()
        return Save().TypeButton.scale or 1
    end, function(value)
        Save().TypeButton.scale= value
        self:set_scale()
    end)


--FrameStrata      
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().TypeButton.strata= data
        self:set_scale()
    end)

--重置位置
    WoWTools_MenuMixin:RestPoint(sub, Save().TypeButton.Point, function()
        Save().TypeButton.point= nil
        self:set_point()
        return MenuResponse.Open
    end)
end


























--提示,类型
local function Init(isShow)
    TypeButton= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsPetBattleTypeButton',
        icon='hide',
        --atlas='WildBattlePetCapturable',
        size=23,
        isType2=true
    })
    TypeButton.frame= CreateFrame("Frame", nil, TypeButton)

    Init_Buttons()

    function TypeButton:set_shown(show)
        self:SetShown(
            not Save().TypeButton.disabled
            and (show
                or (Save().TypeButton.allShow and not UnitAffectingCombat('player'))
                or (PetJournal and PetJournal:IsVisible())
                or C_PetBattles.IsInBattle()
            )
        )
    end

    function TypeButton:set_event()
        self:UnregisterAllEvents()
        if not Save().TypeButton.disabled then
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')--显示，隐藏
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end

    function TypeButton:set_Frame_shown()
        local show= not Save().TypeButton.hideFrame
        self.frame:SetShown(show)
        self:SetNormalAtlas(show and e.Icon.icon or 'WildBattlePetCapturable')
        self:SetAlpha(show and 1 or 0.3)
    end

    function TypeButton:set_scale()
        self.frame:SetScale(Save().TypeButton.scale or 1)
        self:SetFrameStrata(Save().TypeButton.strata or 'MEDIUM')
    end

    function TypeButton:set_point()
        self:ClearAllPoints()
        local p= Save().TypeButton.point
        if p then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('RIGHT',-400, 200)
        end
    end

    function TypeButton:set_Background()
        self.frame.Background:SetShown(Save().TypeButton.showBackground)
    end

    function TypeButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_PetBattleMixin.addName, WoWTools_PetBattleMixin.addName4)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        if not C_AddOns.IsAddOnLoaded('Rematch') then
            e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '图标' or EMBLEM_SYMBOL), e.onlyChinese and '过滤器: 宠物类型' or (FILTER..": "..PET_FAMILIES))
        end
        e.tips:Show()
    end




    TypeButton:RegisterForDrag("RightButton")
    TypeButton:SetMovable(true)
    TypeButton:SetClampedToScreen(true)

    TypeButton:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    TypeButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save().TypeButton.point={self:GetPoint(1)}
        Save().TypeButton.point[2]=nil
    end)
    TypeButton:SetScript("OnMouseUp", ResetCursor)
    TypeButton:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' then
            if IsAltKeyDown() then
                SetCursor('UI_MOVE_CURSOR')
            else
                MenuUtil.CreateContextMenu(self, Init_Menu)
            end
        elseif d=='LeftButton' then--显示，隐藏
            Save().TypeButton.hideFrame= not Save().TypeButton.hideFrame and true or nil
            self:set_Frame_shown()
        end
        self:set_tooltip()
    end)



    TypeButton:SetScript('OnLeave', function(self)
        self:set_Frame_shown()
        e.tips:Hide()
    end)
    TypeButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        self:set_tooltip()
        Set_Button_Highlight()
    end)
    TypeButton:SetScript('OnHide', function()
        for _, btn in pairs(Buttons) do
           btn:UnlockHighlight()
        end
    end)

    TypeButton:SetScript('OnEvent', function(self, event)
        if event=='PET_BATTLE_CLOSE' then
            --[[if PetHasActionBar() and not UnitAffectingCombat('player') then--宠物动作条， 显示，隐藏
                PetActionBar:SetShown(true)
            end]]
            if not UnitAffectingCombat('player') then--UIParent.lua
                local data= C_Spell.GetSpellCooldown(125439) or {}
                if data.duration and data.duration<=2  or not data.duration then
                    if (CollectionsJournal and not PetJournal:IsVisible()) or not CollectionsJournal then
                        ToggleCollectionsJournal(2)
                    end
                end
            end
        end
        self:set_shown()
    end)

--HookScript
    --[[PetBattlePrimaryUnitTooltip:HookScript('OnShow', function(self)
        if self.petOwner and self.petIndex then
            local petType= C_PetBattles.GetPetType(self.petOwner, self.petIndex)
            if petType then
                Set_Button_Highlight(petType)
            end
        end
    end)]]

    hooksecurefunc('PetBattleUnitTooltip_UpdateForUnit', function(self, petOwner, petIndex)
        if self~=_G['PetBattlePrimaryUnitTooltip'] then
            return
        end
        local petType= C_PetBattles.GetPetType(petOwner, petIndex)
        if petType then
            Set_Button_Highlight(petType)
        end
    end)

    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo)
        local abilityID = abilityInfo:GetAbilityID()
        local petType = abilityID and select(7, C_PetBattles.GetAbilityInfoByID(abilityID))
        if petType then
            Set_Button_Highlight(petType)
        end
    end)

    function TypeButton:Settings(show)
        self:set_scale()
        self:set_point()
        self:set_Frame_shown()
        self:set_event()
        self:set_Background()
        self:set_shown(show)
    end
    TypeButton:Settings(isShow)

    return true
end




















function WoWTools_PetBattleMixin:Set_TypeButton(show)
    if self.Save.TypeButton.disabled or TypeButton then
        if TypeButton then
            TypeButton:Settings(show)
        end
    end
    if Init(show) then
        Init=function()end
    end
end

function WoWTools_PetBattleMixin:TypeButton_SetShown()
    if TypeButton then
        TypeButton:set_shown()
    end
end

function WoWTools_PetBattleMixin.Set_TypeButton_Tips(petType)
    Set_Button_Highlight(petType)
end