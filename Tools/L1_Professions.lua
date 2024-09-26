local id, e= ...
--[[Save={
    fishingKey='F',
    archaeologyKey='F',
}]]


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














local function Init_KeyButton(index, spellID, spellID2)
    local button=  Create_Button(index)
    if not button then return end
    button.spellID= spellID
    button.spellID2= spellID2

    button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            C_TradeSkillUI.OpenTradeSkill(self.skillLine)
        end
    end)

    button:SetAttribute('type1', 'spell')
    button:SetAttribute('spell1', C_Spell.GetSpellName(spellID) or spellID)--钓鱼

    button:SetScript('OnLeave', GameTooltip_Hide)
    function button:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(
            WoWTools_SpellMixin:GetName(self.spellID)..e.Icon.left,
            e.Icon.right..WoWTools_SpellMixin:GetName(self.spellID2)
        )
        e.tips:AddLine(' ')

        local isKeyValid= WoWTools_KeyMixin:IsKeyValid(self)
        local isInCombat= UnitAffectingCombat('player')
        e.tips:AddDoubleLine(
            (isInCombat and '|cnRED_FONT_COLOR:' or (isKeyValid and '|cff9e9e9e') or '')
            ..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'F'..e.Icon.mid..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP),

            (isInCombat and '|cnRED_FONT_COLOR:' or (isKeyValid and '|cnGREEN_FONT_COLOR:') or '|cff9e9e9e')
            ..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)..e.Icon.mid..(e.onlyChinese and '解除键位' or UNBIND)
        )
        e.tips:Show()
    end
    button:SetScript('OnEnter', function(self)
        WoWTools_KeyMixin:SetTexture(self)
        self:set_tooltip()
    end)
    button:SetScript('OnMouseWheel', function(self, d)
        if UnitAffectingCombat('player') then
            return
        end
        if d==1 then-- 1上, -1下
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
        self:set_tooltip()
    end)
    WoWTools_KeyMixin:Init(button, function() return 'F' end, true)

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



    return button
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

    if fishing and fishing>0 then
        Init_KeyButton(fishing, 131474, 271990)--131474/钓鱼 271990/钓鱼日志
    end

    if archaeology and archaeology>0 then
        local btn= Init_KeyButton(archaeology, 80451,278910)--80451/勘测 278910/考古学
        if btn then
            btn.texture:SetTexture(C_Spell.GetSpellTexture(80451) or 134435)
        end
    end
end













--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            if WoWTools_ToolsButtonMixin:GetButton() then
                C_Timer.After(2, function()
                    if UnitAffectingCombat('player') then
                        self:RegisterEvent('PLAYER_REGEN_ENABLED')
                    else
                       Init()
                    end
                end)
            end
            self:UnregisterEvent('ADDON_LOADED')
        elseif event=='PLAYER_REGEN_ENABLED' then
            Init()
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
end)