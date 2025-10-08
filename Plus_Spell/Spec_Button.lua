local function Save()
    return WoWToolsSave['Plus_Spell']
end


local SpecFrame


















local function Init_Spec_Menu(self, root)
    local sub, sub2
    root:CreateTitle(self.name)


--专精
    root:CreateDivider()
    if WoWTools_MenuMixin:Set_Specialization(root) then
        root:CreateDivider()
    end

--打开选项界面
    sub=WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_SpellMixin.addName,
        category=WoWTools_SpellMixin.Category
    })


--SetParent
    sub2=sub:CreateCheckbox(
        (PlayerSpellsFrame and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '天赋和法术书' or PLAYERSPELLS_BUTTON),
    function()
        return not Save().specButton.isUIParent
    end, function()
        Save().specButton.isUIParent= not Save().specButton.isUIParent and true or nil
        SpecFrame:Settings()
        SpecFrame:set_point()
        return MenuResponse.Close
    end)
    sub2:SetTooltip(function(tooltip)
        local isUIParent= Save().specButton.isUIParent
        tooltip:AddLine('SetParent')
        tooltip:AddDoubleLine(' ',  (isUIParent and '|cnGREEN_FONT_COLOR:' or '').. 'UIParent')
        tooltip:AddDoubleLine(' ', (isUIParent and '' or '|cnGREEN_FONT_COLOR:').. 'PlayerSpellsFrame')
    end)

    if Save().specButton.isUIParent then

--向上
        WoWTools_MenuMixin:ToTop(sub2, {GetValue=function()
            return Save().specButton.isToTOP
        end, SetValue=function ()
            Save().specButton.isToTOP= not Save().specButton.isToTOP and true or nil
            SpecFrame:Settings()

        end})

--FrameStrata
        WoWTools_MenuMixin:FrameStrata(self, sub2, function(data)
            return SpecFrame:GetFrameStrata()==data
        end, function(data)
            Save().specButton.strata= data
            SpecFrame:set_strata()
        end)

--战斗中隐藏
        sub2:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '战斗中隐藏'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, HIDE),
        function()
            return Save().specButton.hideInCombat
        end, function()
            Save().specButton.hideInCombat= not Save().specButton.hideInCombat and true or nil
            SpecFrame:Settings()
        end)
    end




--    sub:CreateDivider()
--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().specButton.scale or 1
    end, function(value)
        Save().specButton.scale= value
        SpecFrame:Settings()
    end)

    sub:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(sub)
end

















local function Create_Spec_Button(index)
    local specID, name, _, texture= GetSpecializationInfo(index, false, false, nil, UnitSex("player"))
    local btn= WoWTools_ButtonMixin:Cbtn(SpecFrame, {
        texture= texture,
        name='WoWToolsPlayerSpellsFrameSpecButton'..index,
        size=32,
        isMask=true,
    })

    btn.specIndex= index
    btn.specID= specID
    btn.icon='|T'..(texture or 0)..':0|t'
    btn.name= WoWTools_TextMixin:CN(name)

    btn.LootIcon= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
    btn.LootIcon:SetSize(14,14)
    btn.LootIcon:SetPoint('TOPLEFT', -2, 2)
    btn.LootIcon:SetAtlas('VignetteLoot')

    btn.RoleIcon= btn:CreateTexture(nil, 'OVERLAY')
    btn.RoleIcon:SetSize(16,16)
    btn.RoleIcon:SetPoint('BOTTOMRIGHT', 2, -1.2)
    btn.RoleIcon:SetAtlas(GetMicroIconForRoleEnum(GetSpecializationRoleEnum(index, false, false)), TextureKitConstants.IgnoreAtlasSize)

    btn.SelectIcon= btn:CreateTexture(nil, 'OVERLAY')
    btn.SelectIcon:SetAllPoints()
    btn.SelectIcon:SetAtlas('ChromieTime-Button-Selection')
    btn.SelectIcon:SetVertexColor(0,1,0)

    function btn:Set_Active()
        if self.isActive then
            WoWTools_LoadUIMixin:SpellBook(2)
            --if PlayerSpellsFrame then
                --PlayerSpellsUtil.OpenToClassSpecializationsTab()
        else
            C_SpecializationInfo.SetSpecialization(self.specIndex)
            return true
        end
    end


    btn:RegisterForDrag("RightButton")
    btn:SetScript('OnDragStart', function(self, d)
        if d=='RightButton' and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(SpecFrame) and SpecFrame:IsMovable() then
            SpecFrame:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function()
        local self= SpecFrame

        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().specButton.point= {self:GetPoint(1)}
            Save().specButton.point[2]= nil
        end
    end)


    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            self:Set_Active()
        elseif d=='RightButton' and SpecFrame:IsMovable() and IsAltKeyDown() and not WoWTools_FrameMixin:IsLocked(SpecFrame) then
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, Init_Spec_Menu)
        end
    end)


    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
        ResetCursor()
    end)
    btn:SetScript('OnEnter', function(self)
        WoWTools_SetTooltipMixin:Frame(self, GameTooltip, {
            specIndex= self.specIndex,
            tooltip= function(tooltip)
                tooltip:AddLine(' ')
                tooltip:AddDoubleLine(
                    (self.isActive and '|cnGREEN_FONT_COLOR:'
                        or (InCombatLockdown() and '|cff828282')
                        or '|cffffffff'
                    )
                    ..(self.isActive and (WoWTools_DataMixin.onlyChinese and '已激活' or COVENANT_SANCTUM_UPGRADE_ACTIVE)
                    or (WoWTools_DataMixin.onlyChinese and '激活' or SPEC_ACTIVE))
                    ..WoWTools_DataMixin.Icon.left,

                    WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
                )
                if SpecFrame:IsMovable() then
                    tooltip:AddDoubleLine(' ', 'Alt+'..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE))
                end
            end
        })
    end)


    function btn:settings()
        local spec= GetSpecialization(nil, false, 1)
        local lootID= GetLootSpecialization()
        local isActive= spec==self.specIndex
        local isLoot= lootID==0 and isActive or self.specID==lootID

        self.isActive= isActive
        self.isLoot= isLoot
        self.lootID= lootID

        self.SelectIcon:SetShown(isActive)

        if isLoot then
            if lootID==0 then
                self.LootIcon:SetVertexColor(0,1,0)
            else
                self.LootIcon:SetVertexColor(1,1,1)
            end
        end
        self.LootIcon:SetShown(isLoot)
    end
    btn:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
    btn:RegisterEvent('ACTIVE_PLAYER_SPECIALIZATION_CHANGED')
    btn:SetScript('OnEvent',  btn.settings)
    btn:settings()

    table.insert(SpecFrame.Buttons, btn)
end



















--天赋，添加专精按钮
local function Init()
    local numSpec= GetNumSpecializations(false, false) or 0
    if numSpec==0 or (not Save().specButton.isUIParent and not PlayerSpellsFrame) then--not C_SpecializationInfo.IsInitialized() or
        return
    end

    SpecFrame= CreateFrame('Frame', 'WoWToolsOtherSpecFrame', Save().specButton.isUIParent and UIParent or PlayerSpellsFrame)
    SpecFrame:SetSize(10,10)

    SpecFrame.numSpec= numSpec
    SpecFrame.Buttons={}

    for index=1, numSpec do
        Create_Spec_Button(index)
    end



    function SpecFrame:Settings()
        local isToTOP= Save().specButton.isToTOP
        local isUIParent= Save().specButton.isUIParent
        for index, btn in pairs(self.Buttons) do
            btn:ClearAllPoints()
            if isToTOP and isUIParent then
                btn:SetPoint('BOTTOMLEFT', self.Buttons[index-1] or self, 'TOPLEFT', 0, 1)
            else
                btn:SetPoint('TOPLEFT', self.Buttons[index-1] or self, 'TOPRIGHT', 1, 0)
            end
        end



        self:SetMovable(isUIParent and true or false)
        self:SetClampedToScreen(isUIParent and true or false)
        self:SetScale(Save().specButton.scale or 1)

        if isUIParent then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end

    function SpecFrame:set_strata()
        self:SetFrameStrata(Save().specButton.strata or 'MEDIUM')
    end

    function SpecFrame:set_point()
      self:ClearAllPoints()
        if Save().specButton.isUIParent then
            local p= Save().specButton.point
            if p and p[1] then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])

            --[[elseif PlayerSpellsFrame and PlayerSpellsFrame:IsVisible() then
                self:SetPoint('TOP', PlayerSpellsFrame, 'BOTTOM', -self.numSpec*10-2, 0)
            else]]
                self:SetPoint('CENTER', -150, 150)
            end

            self:SetParent(UIParent)
            self:set_strata()

        elseif PlayerSpellsFrame then
            --[[self:SetParent(PlayerSpellsFrame)
            self:SetPoint('TOP', PlayerSpellsFrame, 'BOTTOM', -self.numSpec*10-18, 0)
            self:SetFrameStrata('HIGH')
            self:SetParent(PlayerSpellsFrame.TalentsFrame)
            self:SetPoint('BOTTOM', PlayerSpellsFrame.TalentsFrame.ApplyButton, 'TOP', -self.numSpec*10-18, 25)]]
            self:SetParent(PlayerSpellsFrame.TalentsFrame)
            self:SetPoint('TOP', PlayerSpellsFrame.TalentsFrame.ApplyButton, 'BOTTOM', -self.numSpec*10-18, 0)

        else
            print(
                WoWTools_SpellMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
            )
        end
    end

    SpecFrame:SetScript('OnEvent', function(self, event)
        local hide= Save().specButton.hideInCombat
        local show= event=='PLAYER_REGEN_ENABLED'
        if hide then
            self:SetShown(show)
        else
            for _, btn in pairs(self.Buttons) do
                btn:SetShown(show or btn.isActive)
            end
            self:SetShown(true)
        end
    end)

    SpecFrame:Settings()
    SpecFrame:set_point()


    Init=function()end
end













function WoWTools_SpellMixin:Init_Spec_Button()
    if Save().specButton.enabled then
        Init()
    end
end