local e= select(2, ...)
local function Save()
    return WoWTools_PetBattleMixin.Save
end


local TrackButton
local Buttons={}



local function Set_Button_Highlight(petType)
    if not TrackButton or not TrackButton:IsShown() or not TrackButton.setFrame:IsShown() then
        return
    end
    for _, btn in pairs(Buttons) do
        if btn.petTypeID==petType then
            btn:LockHighlight()
        else
            btn:UnlockHighlight()
        end
    end
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
            FloatingPetBattleAbilityTooltip:SetPoint("BOTTOMRIGHT", TrackButton, "TOPRIGHT");
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
    TrackButton.setFrame:SetSize(1,1)
    TrackButton.setFrame:SetPoint('RIGHT')

    for petType=1, C_PetJournal.GetNumPetTypes() do
        local btn= WoWTools_ButtonMixin:Ctype2(TrackButton.setFrame, {
            size={38,38},
            texture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType],
            isType2=true,
        })
        btn:SetPoint('LEFT', TrackButton, 'RIGHT', (petType-1)*34+2, 0)
        Set_Button_Script(btn, petType)

        local strongTexture, weakHintsTexture, stringIndex, weakHintsIndex= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        if strongTexture then
            btn.indicatoUp=TrackButton.setFrame:CreateTexture()
            btn.indicatoUp:SetAtlas('bags-greenarrow')
            btn.indicatoUp:SetSize(10,10)
            btn.indicatoUp:SetPoint('BOTTOM', btn,'TOP', 0, -2)

            btn.strong= WoWTools_ButtonMixin:Ctype2(TrackButton.setFrame, {texture=strongTexture,size={25,25}, isType2=true})
            btn.strong:SetPoint('BOTTOM', btn.indicatoUp, 'TOP', 0, -2)
            Set_Button_Script(btn.strong, stringIndex)
        end
        if weakHintsTexture then
            btn.indicatoDown=TrackButton.setFrame:CreateTexture()
            btn.indicatoDown:SetAtlas('UI-HUD-MicroMenu-StreamDLRed-Up')
            btn.indicatoDown:SetSize(10,10)
            btn.indicatoDown:SetPoint('TOP', btn, 'BOTTOM', 0, 6)

            btn.weakHints= WoWTools_ButtonMixin:Ctype2(TrackButton.setFrame, {texture=weakHintsTexture, size={25,25}, isType2=true})
            btn.weakHints:SetPoint('TOP', btn.indicatoDown, 'BOTTOM', 0, 2)
            Set_Button_Script(btn.weakHints, weakHintsIndex)
        end
    end

--显示背景 Background
    WoWTools_TextureMixin:CreateBackground(TrackButton.setFrame,
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
        return self.setFrame:IsShown()
    end, function()
        Save().TrackButton.hideFrame= not Save().TrackButton.hideFrame and true or nil
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
        return Save().TrackButton.allShow
    end, function()
        Save().TrackButton.allShow= not Save().TrackButton.allShow and true or nil
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
        return Save().MoveButton.showBackground
    end, function()
        Save().MoveButton.showBackground= not Save().MoveButton.showBackground and true or nil
        self:set_Background()
    end)

--缩放
    WoWTools_MenuMixin:Scale(sub, function()
        return Save().TrackButton.scale or 1
    end, function(value)
        Save().TrackButton.scale= value
        self:set_scale()
    end)


--FrameStrata      
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().TrackButton.strata= data
        self:set_scale()
    end)

--重置位置
    WoWTools_MenuMixin:RestPoint(sub, Save().MoveButton.Point, function()
        Save().TrackButton.point= nil
        self:set_point()
        return MenuResponse.Open
    end)
end


























--提示,类型
local function Init(isShow)
    TrackButton= WoWTools_ButtonMixin:Cbtn(nil, {
        name='WoWToolsPetBattleTypeTrackButton',
        icon='hide',
        --atlas='WildBattlePetCapturable',
        size=23,
        isType2=true
    })
    TrackButton.setFrame= CreateFrame("Frame", nil, TrackButton)
    WoWTools_PetBattleMixin.TrackButton= TrackButton

    Init_Buttons()

    function TrackButton:set_shown(show)
        self:SetShown(
            not Save().TrackButton.disabled
            and (show
                or (Save().TrackButton.allShow and not UnitAffectingCombat('player'))
                or PetJournal and PetJournal:IsVisible() or C_PetBattles.IsInBattle()
            )
        )
    end

    function TrackButton:set_event()
        self:UnregisterAllEvents()
        if Save().TrackButton.allShow and not Save().TrackButton.disabled then
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')--显示，隐藏
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterAllEvents('PLAYER_REGEN_ENABLED')
        end
    end

    function TrackButton:set_Frame_shown()
        local show= not Save().TrackButton.hideFrame
        self.setFrame:SetShown(show)
        self:SetNormalAtlas(show and e.Icon.icon or 'WildBattlePetCapturable')
        self:SetAlpha(show and 1 or 0.3)
    end

    function TrackButton:set_scale()
        self.setFrame:SetScale(Save().TrackButton.scale or 1)
        self:SetFrameStrata(Save().TrackButton.strata or 'MEDIUM')
    end

    function TrackButton:set_point()
        self:ClearAllPoints()
        local p= Save().TrackButton.point
        if p then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('RIGHT',-400, 200)
        end
    end

    function TrackButton:set_Background()
        self.setFrame.Background:SetShown(Save().MoveButton.showBackground)
    end

    function TrackButton:set_tooltip()
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




    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetMovable(true)
    TrackButton:SetClampedToScreen(true)

    TrackButton:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save().TrackButton.point={self:GetPoint(1)}
        Save().TrackButton.point[2]=nil
    end)
    TrackButton:SetScript("OnMouseUp", ResetCursor)
    TrackButton:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' then
            if IsAltKeyDown() then
                SetCursor('UI_MOVE_CURSOR')
            else
                MenuUtil.CreateContextMenu(self, Init_Menu)
            end
        elseif d=='LeftButton' then--显示，隐藏
            Save().TrackButton.hideFrame= not Save().TrackButton.hideFrame and true or nil
            self:set_Frame_shown()
        end
        self:set_tooltip()
    end)



    TrackButton:SetScript('OnLeave', function(self)
        self:set_Frame_shown()
        e.tips:Hide()
    end)
    TrackButton:SetScript('OnEnter', function(self)
        self:SetAlpha(1)
        self:set_tooltip()
        Set_Button_Highlight()
    end)
    TrackButton:SetScript('OnHide', function()
        for _, btn in pairs(Buttons) do
           btn:UnlockHighlight()
        end
    end)

    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PET_BATTLE_CLOSE' then
            if PetHasActionBar() and not UnitAffectingCombat('player') then--宠物动作条， 显示，隐藏
                PetActionBar:SetShown(true)
            end
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
    PetBattlePrimaryUnitTooltip:HookScript('OnShow', function(self)
        if self.petOwner and self.petIndex then
            local petType= C_PetBattles.GetPetType(self.petOwner, self.petIndex)
            if petType then
                Set_Button_Highlight(petType)
            end
        end
    end)
    hooksecurefunc('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo)
        local petType = abilityInfo and abilityInfo.abilityID and select(7, C_PetBattles.GetAbilityInfoByID(abilityInfo.abilityID))
        if petType then
            Set_Button_Highlight(petType)
        end
    end)

    function TrackButton:Settings(show)
        self:set_scale()
        self:set_point()
        self:set_Frame_shown()
        self:set_shown(show)
        self:set_event()
        self:set_Background()
    end
    TrackButton:Settings(isShow)

    return true
end




















function WoWTools_PetBattleMixin:Set_TrackButton(show)
    if self.Save.TrackButton.disabled or TrackButton then
        if TrackButton then
            TrackButton:set_shown(show)
        end
    end
    if Init(show) then
        Init=function()end
    end
end


function WoWTools_PetBattleMixin.Set_TrackButton_Tips(petType)
    Set_Button_Highlight(petType)
end