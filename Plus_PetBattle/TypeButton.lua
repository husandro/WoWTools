local function Save()
    return WoWToolsSave['Plus_PetBattle2']
end


local TypeButton
local Buttons={}
local Name= 'WoWToolsPetBattleButton_'

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
        for _, name in pairs(Buttons) do
            local btn= _G[Name..name]
            if btn.petTypeID==petType then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
        end
    end

    IsInCheck= nil
end

















local function Set_Button_Script(btn, petTypeID, name)
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
            PetBattleAbilityTooltip_SetAbilityByID(nil, nil, self.abilityID)
            PetBattleAbilityTooltip_Show("BOTTOMRIGHT", TypeButton, "TOPRIGHT")
        end
    end)
    btn:SetScript('OnLeave', function(self)
        --FloatingPetBattleAbilityTooltip:Hide()
        PetBattlePrimaryAbilityTooltip:Hide()
        self:UnlockHighlight()
    end)

    table.insert(Buttons, name)

    btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 1)
    btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, -1)
end




















local function Init_Buttons()
    TypeButton.frame:SetSize(1,1)
    TypeButton.frame:SetPoint('RIGHT')

    for petType=1, C_PetJournal.GetNumPetTypes() do
        local name= 'petType'..petType
        --[[local btn= CreateFrame('Button', Name..name, UIParent, 'WoWToolsButtonTemplate')
        btn:SetSize(38, 38)
        btn:SetNormalTexture('Interface\\ICONS\\Pet_Type_'..PET_TYPE_SUFFIX[petType])]]
        local btn=WoWTools_ButtonMixin:Cbtn(TypeButton.frame, {
            size=38,
            texture='Interface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType],
            isType2=true,
            name= Name..name
        })
        btn:GetHighlightTexture():SetVertexColor(0,1,0)
        btn:SetPoint('LEFT', TypeButton, 'RIGHT', (petType-1)*34+2, 0)

        Set_Button_Script(btn, petType, name)

        local strongTexture, weakHintsTexture, stringIndex, weakHintsIndex= WoWTools_PetBattleMixin:GetPetStrongWeakHints(petType)
        if strongTexture then
            btn.indicatoUp=TypeButton.frame:CreateTexture()
            btn.indicatoUp:SetAtlas('bags-greenarrow')
            btn.indicatoUp:SetSize(10,10)
            btn.indicatoUp:SetPoint('BOTTOM', btn,'TOP', 0, -2)

            local strongName= name..'Strong'
            btn.strong= WoWTools_ButtonMixin:Cbtn(TypeButton.frame, {
                texture=strongTexture,
                size=25,
                isType2=true,
                name=Name..strongName
            })
            btn.strong:SetPoint('BOTTOM', btn.indicatoUp, 'TOP', 0, -2)
            btn.strong:GetHighlightTexture():SetVertexColor(0,1,0)
            Set_Button_Script(btn.strong, stringIndex, strongName)

        end
        if weakHintsTexture then
            btn.indicatoDown=TypeButton.frame:CreateTexture()
            btn.indicatoDown:SetAtlas('UI-HUD-MicroMenu-StreamDLRed-Up')
            btn.indicatoDown:SetSize(10,10)
            btn.indicatoDown:SetPoint('TOP', btn, 'BOTTOM', 0, 6)

            local WeakHintsName= name..'WeakHints'
            btn.weakHints= WoWTools_ButtonMixin:Cbtn(TypeButton.frame, {
                texture=weakHintsTexture,
                size=25,
                isType2=true,
                name=Name..WeakHintsName
            })
            btn.weakHints:GetHighlightTexture():SetVertexColor(0,1,0)
            btn.weakHints:SetPoint('TOP', btn.indicatoDown, 'BOTTOM', 0, 2)
            Set_Button_Script(btn.weakHints, weakHintsIndex, WeakHintsName)
        end
    end

--显示背景 Background
    WoWTools_TextureMixin:CreateBG(TypeButton.frame,
    {point=function(texture)
        local num= #Buttons
        if num>2 then
            texture:SetPoint('LEFT', _G[Name..Buttons[1]], -2, 0)
            texture:SetPoint('RIGHT', _G[Name..Buttons[num-2]], -1, 0)
            texture:SetPoint('TOP', _G[Name..Buttons[2]], 0, 1)
            texture:SetPoint('BOTTOM', _G[Name..Buttons[num]])
        end
    end})
end


















local function Init_Menu(self, root)
    local sub, sub2
--打开，宠物手册
    sub=root:CreateButton(
        '|TInterface\\Icons\\PetJournalPortrait:0|t'..(WoWTools_DataMixin.onlyChinese and '宠物手册' or PET_JOURNAL),
    function()
        WoWTools_LoadUIMixin:Journal(2)
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(MicroButtonTooltipText(WoWTools_DataMixin.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
    end)

    root:CreateDivider()
--显示
    root:CreateCheckbox(
        WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW),
    function()
        return self.frame:IsShown()
    end, function()
        Save().TypeButton.hideFrame= not Save().TypeButton.hideFrame and true or nil
        self:set_Frame_shown()
    end)

--打开选项界面
    root:CreateDivider()
    sub= WoWTools_PetBattleMixin:OpenOptions(root, WoWTools_PetBattleMixin.addName4)

--总是显示
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '总是显示' or BATTLEFIELD_MINIMAP_SHOW_ALWAYS,
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
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '自动显示：'
            or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SHOW)..':')
        )
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物手册' or PET_JOURNAL)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)
    end)

--显示背景
    WoWTools_MenuMixin:BgAplha(sub,
    function()
        return Save().TypeButton.bgAlpha or 0.5
    end, function(value)
        Save().TypeButton.bgAlpha= value
        self:set_Background()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().TypeButton.scale or 1
    end, function(value)
        Save().TypeButton.scale= value
        self:set_scale()
    end)


--FrameStrata      
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().TypeButton.strata= data
        self:set_scale()
    end)

--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().TypeButton.Point, function()
        Save().TypeButton.point= nil
        self:set_point()
        return MenuResponse.Open
    end)
end


























--提示,类型
local function Init(isShow)
    if Save().TypeButton.disabled then
        return
    end

    TypeButton= WoWTools_ButtonMixin:Cbtn(UIParent, {
        name='WoWToolsPetBattleTypeButton',
        size=23,
        isType2=true,
        notBorder=true,
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
        if show then
            self.texture:SetTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        else
            self.texture:SetAtlas('WildBattlePetCapturable')
        end
        self.texture:SetAlpha(
            (self:IsMouseOver() or show) and 1 or 0.5
        )
    end

    function TypeButton:set_scale()
        self.frame:SetScale(Save().TypeButton.scale or 1)
        self:SetFrameStrata(Save().TypeButton.strata or 'MEDIUM')
    end

    function TypeButton:set_point()
        self:ClearAllPoints()
        local p= Save().TypeButton.point
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('RIGHT', -400, 200)
        end
    end

    function TypeButton:set_Background()
        self.frame.Background:SetAlpha(Save().TypeButton.bgAlpha or 0.5)
    end

    function TypeButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_PetBattleMixin.addName, WoWTools_PetBattleMixin.addName4)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '显示/隐藏' or SHOW..'/'..HIDE, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        if not C_AddOns.IsAddOnLoaded('Rematch') then
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '图标' or EMBLEM_SYMBOL), WoWTools_DataMixin.onlyChinese and '过滤器: 宠物类型' or (FILTER..": "..PET_FAMILIES))
        end
        GameTooltip:Show()
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
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().TypeButton.point={self:GetPoint(1)}
            Save().TypeButton.point[2]=nil
        end
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
        GameTooltip:Hide()
    end)
    TypeButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self.texture:SetAlpha(1)
        Set_Button_Highlight()
    end)
    TypeButton:SetScript('OnHide', function()
        for _, name in pairs(Buttons) do
            _G[Name..name]:UnlockHighlight()
        end
    end)

    TypeButton:SetScript('OnEvent', function(self, event)
        if event=='PET_BATTLE_CLOSE' then
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


    WoWTools_DataMixin:Hook('PetBattleUnitTooltip_UpdateForUnit', function(self, petOwner, petIndex)
        if self~=_G['PetBattlePrimaryUnitTooltip'] then
            return
        end
        local petType= C_PetBattles.GetPetType(petOwner, petIndex)
        if petType then
            Set_Button_Highlight(petType)
        end
    end)

    WoWTools_DataMixin:Hook('SharedPetBattleAbilityTooltip_SetAbility', function(self, abilityInfo)
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

    Init=function(show)
        TypeButton:Settings(show)
    end
end




















function WoWTools_PetBattleMixin:Set_TypeButton(show)
   Init(show)
end

function WoWTools_PetBattleMixin:TypeButton_SetShown()
    if TypeButton then
        TypeButton:set_shown()
    else
        self:Set_TypeButton()
    end
end

function WoWTools_PetBattleMixin.Set_TypeButton_Tips(petType)
    Set_Button_Highlight(petType)
end