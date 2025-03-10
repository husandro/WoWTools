local id, e= ...
local Save={
    fishing='BUTTON1',
    archaeology='F',
    --save_fishing=true,--启动时，设置KEY
    --save_archaeology=true--启动时，设置KEY
}


local function Create_Button(index)
    local name, icon, _, _, _, _, skillLine = GetProfessionInfo(index)

    if not skillLine or not icon then return end

    local button= WoWTools_ToolsButtonMixin:CreateButton({
        name='WoWToolsToolsProfession'..index,
        tooltip='|T'..icon..':0|t'..e.cn(name),
    })
    if button then
        button:SetScript('OnLeave', GameTooltip_Hide)
        button.name= name
        button.icon= icon
        button.skillLine= skillLine
        button.texture:SetTexture(icon)
        return button
    end
end









--主要专业 1, 2
local function Init_Professions(index)
    local button=  Create_Button(index)
    if not button then return end

    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            C_TradeSkillUI.OpenTradeSkill(self.skillLine)
        elseif d=='RightButton' then
            ToggleProfessionsBook()
        end
    end)
    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(
            '|T'..(self.icon or 0)..':0|t'..e.cn(self.name)..e.Icon.left,
            e.Icon.right..MicroButtonTooltipText(e.onlyChinese and '专业' or PROFESSIONS_BUTTON, "TOGGLEPROFESSIONBOOK")..'|A:UI-HUD-MicroMenu-Professions-Mouseover:24:24|a'
        )
        e.tips:Show()
    end)
end








--[[
/cast [@player]烹饪用火
/use 大厨的帽子
]]
local function Init_Cooking(index)
    local button=  Create_Button(index)
    if not button then return end

    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            C_TradeSkillUI.OpenTradeSkill(self.skillLine)
        end
    end)

    local macro
    local name= C_Spell.GetSpellName(818)
    if name then
        macro= '/cast [@player]'..name
    end

    if PlayerHasToy(134020) then
        local toyName=C_Item.GetItemNameByID(134020)--玩具,大厨的帽子
        if toyName then
            macro= (macro and macro..'\n' or '')..'/use '..toyName
        end
    end
    if macro then
        button:SetAttribute('type2', 'macro')
        button:SetAttribute('macrotext2', macro)
        button.tooltip=macro

        function button:set_event()
            e.SetItemSpellCool(self, {spell=818})
        end
        function button:settings()
            if self:IsVisible() then
                self:set_event()
                self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
            else
                e.SetItemSpellCool(self)
                self:UnregisterAllEvents()
            end
        end
        button:SetScript('OnEvent', button.set_event)
        button:SetScript('OnShow', button.settings)
        button:SetScript('OnHide', button.settings)
        button:settings()
    end

    button:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine('|T'..(self.icon or 0)..':0|t'..e.cn(self.name)..e.Icon.left)
        if self.tooltip then
            e.tips:AddLine(' ')
            e.tips:AddLine(self.tooltip..e.Icon.right)

            local data= C_Spell.GetSpellCooldown(818)
            if data and data.duration>0 then
                local spellName= WoWTools_SpellMixin:GetName(818)
                if spellName then
                    e.tips:AddLine(' ')
                    e.tips:AddLine(spellName)
                end
            end
        end
        e.tips:Show()
    end)

end










local function Init_KeyButton_Menu(self, root)
    local isInCombat= not self:CanChangeAttribute()
    local sub, sub2

    root:CreateButton(
        WoWTools_SpellMixin:GetName(self.spellID2),
    function(data)
        C_TradeSkillUI.OpenTradeSkill(data.skillLine)
        return MenuResponse.Open
    end, {skillLine=self.skillLine})

    root:CreateButton(
        '|A:UI-HUD-MicroMenu-Professions-Mouseover:24:24|a'
        ..MicroButtonTooltipText(e.onlyChinese and '专业' or PROFESSIONS_BUTTON, "TOGGLEPROFESSIONBOOK"),
    function()
        ToggleProfessionsBook()
        return MenuResponse.Open
    end)

    root:CreateDivider()
    sub=root:CreateCheckbox(
        (e.onlyChinese and '设置快捷键' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, SETTINGS_KEYBINDINGS_LABEL))
        ..'|cnGREEN_FONT_COLOR:'..(Save[self.type] or ''),
    function()
        return WoWTools_KeyMixin:IsKeyValid(self)
    end, function()
        if self:CanChangeAttribute() then
            self:set_key(not WoWTools_KeyMixin:IsKeyValid(self))
        end
    end)
    sub:SetEnabled(not isInCombat)

--设置KEY
    WoWTools_KeyMixin:SetMenu(self, sub,  {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=e.cn(self.name),
        key=Save[self.type],
        GetKey=function(key)
            Save[self.type]=key
        end,
    })

--启动时，设置KEY
    sub2=sub:CreateCheckbox(
        e.onlyChinese and '保存' or SAVE,
    function()
        return Save['save_'..self.type]
    end, function()
        Save['save_'..self.type]= not Save['save_'..self.type] and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '登入：设置' or (LOG_IN..': '..SETTINGS))
    end)
end











local function Init_KeyButton(index, type)
    local spellID, spellID2, icon= 131474, 271990, 4620674--131474/钓鱼 271990/钓鱼日志
    if type=='archaeology' then
        spellID, spellID2, icon= 80451, 278910, 134435--80451/勘测 278910/考古学
    end

    local button=  Create_Button(index)
    if not button then return end
    button.type=type--fishing archaeology
    button.spellID= spellID
    button.spellID2= spellID2

    button:SetAttribute('type1', 'spell')
    button:SetAttribute('spell1', C_Spell.GetSpellName(spellID) or spellID)--钓鱼
    button.texture:SetTexture(C_Spell.GetSpellTexture(spellID) or icon)

    button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_KeyButton_Menu)
        end
    end)



    button:SetScript('OnLeave', GameTooltip_Hide)
    function button:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(
            WoWTools_SpellMixin:GetName(self.spellID)..e.Icon.left,
            e.Icon.right..(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        )
        e.tips:AddLine(' ')

        local isKeyValid= WoWTools_KeyMixin:IsKeyValid(self)
        local isInCombat= not self:CanChangeAttribute()
        e.tips:AddDoubleLine(
            (isInCombat and '|cnRED_FONT_COLOR:' or (isKeyValid and '|cff9e9e9e') or '')
            ..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..' '..self:GetKey()..e.Icon.mid..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP),

            (isInCombat and '|cnRED_FONT_COLOR:' or (isKeyValid and '|cnGREEN_FONT_COLOR:') or '|cff9e9e9e')
            ..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)..e.Icon.mid..(e.onlyChinese and '解除键位' or UNBIND)
        )
        e.tips:Show()
    end
    function button:set_key(isSetup)
        if isSetup then
            WoWTools_KeyMixin:Setup(self, false)
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
            self:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
            self:RegisterEvent('PET_BATTLE_OPENING_DONE')
            self:RegisterEvent('PET_BATTLE_CLOSE')
            self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', 'player')
            self:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', 'player')
        else
            WoWTools_KeyMixin:Setup(self, true)
            self:UnregisterAllEvents()
        end
    end
    button:SetScript('OnEnter', function(self)
        WoWTools_KeyMixin:SetTexture(self)
        self:set_tooltip()
    end)
    button:SetScript('OnMouseWheel', function(self, d)
        if not self:CanChangeAttribute() then
            print(WoWTools_Mixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
            return
        end
        self:set_key(d==1)-- 1上, -1下
        self:set_tooltip()
    end)


    button:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_REGEN_DISABLED' then
            ClearOverrideBindings(self)
            WoWTools_KeyMixin:SetTexture(self)

        elseif event=='PET_BATTLE_OPENING_DONE'
            or event=='UNIT_ENTERED_VEHICLE'
            or IsMounted()
        then
            WoWTools_KeyMixin:Setup(self, true)

        else
            WoWTools_KeyMixin:Setup(self, false)
        end
        if GameTooltip:IsOwned(self) then
            self:set_tooltip()
        end
    end)

--设置KEY
    function button:GetKey()
        return Save[self.type] or (self.type=='fishing' and 'BUTTON1') or 'F'
    end
    WoWTools_KeyMixin:Init(button, nil, true)

--启动时，设置KEY
    if Save['save_'..type] then
       button:set_key(true)
    end
end












local function Init()
    local prof1, prof2, archaeology, fishing, cooking = GetProfessions()
    if prof1 and prof1>0 then
        Init_Professions(prof1)
    end
    if prof2 and prof2>0 then
        Init_Professions(prof2)
    end
    if cooking and cooking>0 then
        Init_Cooking(cooking)
    end

--钓鱼
    if fishing and fishing>0 then
        Init_KeyButton(fishing, 'fishing')
    end

--考古学
    if archaeology and archaeology>0 then
        Init_KeyButton(archaeology, 'archaeology')
    end
end












--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Save= WoWToolsSave['Tools_Professions'] or Save
            if WoWTools_ToolsButtonMixin:GetButton() then
                --Init()
                C_Timer.After(2, function()
                    if UnitAffectingCombat('player') then
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                    else
                       Init()
                    end
                end)
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init()
        self:UnregisterEvent('PLAYER_REGEN_ENABLED')

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Professions']=Save
        end

    end
end)