local id, e = ...
local addName
local Save={
    specButton={
    --isUIParent=true
    --scale=1
    --isToTOP=true
    --point={}
    --strata='MEDIUM'
    --hideInCombat=true
    }
}
local SpecFrame







--天赋, 点数 Blizzard_SharedTalentButtonTemplates.lua Blizzard_ClassTalentButtonTemplates.lua
local function set_UpdateSpendText(btn)
    local info= btn.nodeInfo-- C_Traits.GetNodeInfo btn:GetSpellID()
    local text
    if info then
        if info.currentRank and info.maxRanks and info.currentRank>0 and info.maxRanks~= info.currentRank then
            text= '/'..info.maxRanks
        end
        if text and not btn.maxText then
            btn.maxText= WoWTools_LabelMixin:Create(btn, {fontType=btn.SpendText})--nil, btn.SpendText)
            btn.maxText:SetPoint('LEFT', btn.SpendText, 'RIGHT')
            btn.maxText:SetTextColor(1, 0, 1)
            btn.maxText:EnableMouse(true)
            btn.maxText:SetScript('OnLeave', GameTooltip_Hide)
            btn.maxText:SetScript('OnEnter', function(self)
                if self.maxRanks then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '最高等级' or TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, self.maxRanks)
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, addName)
                    GameTooltip:Show()
                end
            end)
        end
    end
    if btn.maxText then
        btn.maxText.maxRanks= info and info.maxRanks
        btn.maxText:SetText(text or '')
    end
end















--法术按键, 颜色 ActionButton.lua
local function set_ActionButton_UpdateRangeIndicator(frame, checksRange, inRange)
    if not frame.setHooksecurefunc and frame.UpdateUsable then
        hooksecurefunc(frame, 'UpdateUsable', function(self, _, isUsable)
            if IsUsableAction(self.action) and ActionHasRange(self.action) and IsActionInRange(self.action)==false then
                self.icon:SetVertexColor(1,0,0)
            end
        end)
        frame.setHooksecurefunc= true
    end

    if ( frame.HotKey:GetText() == RANGE_INDICATOR ) then
        if ( checksRange ) then
            if ( inRange ) then
                if frame.UpdateUsable then
                    frame:UpdateUsable()
                end
            else
                frame.icon:SetVertexColor(1,0,0)
            end
        end
    else
        if ( checksRange and not inRange ) then
            frame.icon:SetVertexColor(1,0,0)
        elseif frame.UpdateUsable then
            frame:UpdateUsable()
        end
    end

end





















local function Init_Spec_Menu(self, root)
    local isInCombat= InCombatLockdown()
    local sub, sub2
    root:CreateTitle(self.name)

--激活
    sub= root:CreateCheckbox(
        self.icon..(WoWTools_Mixin.onlyChinese and '激活' or SPEC_ACTIVE),
    function()
        return self.isActive
    end, function()
        self:Set_Active()
        return MenuResponse.Close
    end, {specIndex= self.specIndex})
    WoWTools_SetTooltipMixin:Set_Menu(sub)
    sub:SetEnabled(not isInCombat)

--拾取
    sub= root:CreateCheckbox(
        '|A:VignetteLoot:0:0|a'..(WoWTools_Mixin.onlyChinese and '专精拾取' or SELECT_LOOT_SPECIALIZATION),
    function()
        return self.isLoot

    end, function()
        SetLootSpecialization(self.lootID~=self.specID and self.specID or 0)
        return MenuResponse.Close
    end, {specIndex= self.specIndex})
    WoWTools_SetTooltipMixin:Set_Menu(sub)

    sub= root:CreateCheckbox(
        '|A:pvptalents-warmode-swords:0:0|a'..(WoWTools_Mixin.onlyChinese and '战争模式' or PVP_LABEL_WAR_MODE),
    function()
        return C_PvP.IsWarModeDesired()
    end,function()
        C_PvP.ToggleWarMode()
        return MenuResponse.Close
    end)
    sub:SetEnabled(C_PvP.CanToggleWarMode(not C_PvP.IsWarModeDesired()))

if isInCombat then
    return
end






    root:CreateDivider()

--打开选项界面
    sub=WoWTools_MenuMixin:OpenOptions(root, {name=addName, category=WoWTools_OtherMixin.Category})


--SetParent
    sub2=sub:CreateCheckbox(
        (PlayerSpellsFrame and '' or '|cff828282')
        ..(WoWTools_Mixin.onlyChinese and '天赋和法术书' or PLAYERSPELLS_BUTTON),
    function()
        return not Save.specButton.isUIParent
    end, function()
        Save.specButton.isUIParent= not Save.specButton.isUIParent and true or nil
        SpecFrame:Settings()
        SpecFrame:set_point()
        return MenuResponse.Close
    end)
    sub2:SetTooltip(function(tooltip)
        local isUIParent= Save.specButton.isUIParent
        tooltip:AddLine('SetParent')
        tooltip:AddDoubleLine(' ',  (isUIParent and '|cnGREEN_FONT_COLOR:' or '').. 'UIParent')
        tooltip:AddDoubleLine(' ', (isUIParent and '' or '|cnGREEN_FONT_COLOR:').. 'PlayerSpellsFrame')
    end)

    if Save.specButton.isUIParent then

--向上
        WoWTools_MenuMixin:ToTop(sub2, {GetValue=function()
            return Save.specButton.isToTOP
        end, SetValue=function ()
            Save.specButton.isToTOP= not Save.specButton.isToTOP and true or nil
            SpecFrame:Settings()

        end})

--FrameStrata
        WoWTools_MenuMixin:FrameStrata(sub2, function(data)
            return SpecFrame:GetFrameStrata()==data
        end, function(data)
            Save.specButton.strata= data
            SpecFrame:set_strata()
        end)

--战斗中隐藏
        sub2:CreateCheckbox(
            WoWTools_Mixin.onlyChinese and '战斗中隐藏'
            or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, HIDE),
        function()
            return Save.specButton.hideInCombat
        end, function()
            Save.specButton.hideInCombat= not Save.specButton.hideInCombat and true or nil
            SpecFrame:Settings()
        end)
    end




--    sub:CreateDivider()
--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save.specButton.scale or 1
    end, function(value)
        Save.specButton.scale= value
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
        if InCombatLockdown() then
            return
        end
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
        if d=='RightButton' and IsAltKeyDown() then
            if SpecFrame:IsMovable() then
                SpecFrame:StartMoving()
            end
        end
    end)
    btn:SetScript("OnDragStop", function()
        SpecFrame:StopMovingOrSizing()
        ResetCursor()
        Save.specButton.point= {SpecFrame:GetPoint(1)}
        Save.specButton.point[2]= nil
    end)


    btn:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            self:Set_Active()
        elseif d=='RightButton' and SpecFrame:IsMovable() and IsAltKeyDown() then
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
                    ..(self.isActive and (WoWTools_Mixin.onlyChinese and '已激活' or COVENANT_SANCTUM_UPGRADE_ACTIVE)
                    or (WoWTools_Mixin.onlyChinese and '激活' or SPEC_ACTIVE))
                    ..WoWTools_DataMixin.Icon.left,

                    WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
                )
                if SpecFrame:IsMovable() then
                    tooltip:AddDoubleLine(' ', 'Alt+'..WoWTools_DataMixin.Icon.right..(WoWTools_Mixin.onlyChinese and '移动' or NPE_MOVE))
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
local function Init_Spec_Button()
    local numSpec= GetNumSpecializations(false, false) or 0
    if SpecFrame or numSpec==0 or (not Save.specButton.isUIParent and not PlayerSpellsFrame) then--not C_SpecializationInfo.IsInitialized() or
        return
    end

    SpecFrame= CreateFrame('Frame', 'WoWToolsOtherSpecFrame', Save.specButton.isUIParent and UIParent or PlayerSpellsFrame)
    SpecFrame:SetSize(10,10)

    SpecFrame.numSpec= numSpec
    SpecFrame.Buttons={}

    for index=1, numSpec do
        Create_Spec_Button(index)
    end



    function SpecFrame:Settings()
        local isToTOP= Save.specButton.isToTOP
        local isUIParent= Save.specButton.isUIParent
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
        self:SetScale(Save.specButton.scale or 1)

        if isUIParent then
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end

    function SpecFrame:set_strata()
        self:SetFrameStrata(Save.specButton.strata or 'MEDIUM')
    end

    function SpecFrame:set_point()
      self:ClearAllPoints()
        if Save.specButton.isUIParent then
            local p= Save.specButton.point
            if p then
                self:SetPoint(p[1], UIParent, p[3], p[4], p[5])

            elseif PlayerSpellsFrame and PlayerSpellsFrame:IsVisible() then
                self:SetPoint('TOP', PlayerSpellsFrame, 'BOTTOM', -self.numSpec*10-2, 0)
            else
                self:SetPoint('CENTER', -150, 150)
            end

            self:SetParent(UIParent)
            self:set_strata()

        elseif PlayerSpellsFrame then
            self:SetParent(PlayerSpellsFrame)
            self:SetPoint('TOP', PlayerSpellsFrame, 'BOTTOM', -numSpec*10-18, 0)
            self:SetFrameStrata('HIGH')
        else
            print(addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
        end
    end

    SpecFrame:SetScript('OnEvent', function(self, event)
        local hide= Save.specButton.hideInCombat
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
end






























local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            Save= WoWToolsSave['Other_SpellFrame'] or Save
            Save.specButton= Save.specButton or {}

            addName= '|A:UI-HUD-MicroMenu-SpellbookAbilities-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '法术Frame' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, 'Frame'))

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                tooltip= WoWTools_Mixin.onlyChinese and '法术距离, 颜色'
                        or (
                            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SPELLS, TRACKER_SORT_PROXIMITY)..': '.. COLOR

                    ),
                Value= not Save.disabled,
                GetValue=function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save.disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if Save.disabled then
                self:UnregisterEvent(event)
            else
                C_Timer.After(1, Init_Spec_Button)

    --法术按键, 颜色
                hooksecurefunc('ActionButton_UpdateRangeIndicator', set_ActionButton_UpdateRangeIndicator)
            end

        elseif arg1=='Blizzard_PlayerSpells' then--天赋
            hooksecurefunc(ClassTalentButtonSpendMixin, 'UpdateSpendText', set_UpdateSpendText)--天赋, 点数 

            Init_Spec_Button()

            hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
                frame.Button.ActionBarHighlight:SetVertexColor(0,1,0)
                if (frame.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout) then
                    frame.Button.Arrow:SetVertexColor(1,0,1)
                    frame.Button.Border:SetVertexColor(1,0,1)
                else
                    frame.Button.Arrow:SetVertexColor(1,1,1)
                    frame.Button.Border:SetVertexColor(1,1,1)
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            WoWToolsSave['Other_SpellFrame']=Save
        end
    end
end)