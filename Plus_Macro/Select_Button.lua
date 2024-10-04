--选定宏，点击，弹出菜单，自定图标
local e= select(2, ...)












--选定宏，点击，弹出菜单，自定图标
--#############################
local function Init()
    --选定宏，index提示
    MacroFrame.numSelectionLable= WoWTools_LabelMixin:Create(MacroFrameSelectedMacroButton)
    MacroFrame.numSelectionLable:SetAlpha(0.7)
    MacroFrame.numSelectionLable:SetPoint('RIGHT', MacroFrameSelectedMacroButton, 'LEFT', -1,0)
    MacroFrame.numSelectionLable:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.7) end)
    MacroFrame.numSelectionLable:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine( e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)
        e.tips:Show()
        self:SetAlpha(1)
    end)
    hooksecurefunc(MacroFrame, 'SelectMacro', function(self, index)
        self.numSelectionLable:SetText(index and index+MacroFrame.macroBase or '')
    end)

    --选定，宏，提示
    MacroFrameSelectedMacroButton:HookScript('OnEnter', function(self)
        local icon= WoWTools_MacroMixin:SetTooltips(self, WoWTools_MacroMixin:GetSelectIndex())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(
            '|cnGREEN_FONT_COLOR:'
            ..(e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL))
            ..(icon and '|T'..icon..':0|t' or ''),
            e.Icon.left
        )
        e.tips:Show()
    end)
    MacroFrameSelectedMacroButton:HookScript('OnLeave', function()
        e.tips:Hide()
        --Set_Action_Focus()
    end)

    --选定宏，点击，弹出菜单，自定图标
    MacroFrameSelectedMacroButton:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
    MacroFrameSelectedMacroButton:HookScript('OnMouseDown', function(self)
        e.LibDD:UIDropDownMenu_Initialize(MacroFrame.Menu, function()
            if UnitAffectingCombat('player') then
                e.LibDD:UIDropDownMenu_AddButton({
                    text=e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
                    notCheckable=true,
                    isTitle=true,
                }, 1)
                return
            end
            local text= MacroFrameText:GetText()
            text= text and text..'\n' or ''
            local allTab={}

            --添加，物品，法术，图标=物品名称
            local function get_SpellItem_Texture(spell, item)
                if spell then--spell 字符
                    local icon= C_Spell.GetSpellTexture(spell)
                    if icon then
                        local name= C_Spell.GetSpellName(spell) or spell
                        allTab[icon]= name
                    end

                elseif item then
                    local icon= C_Item.GetItemIconByID(item) or select(5, C_Item.GetItemInfoInstant(item))
                    if icon then
                        allTab[icon]=item
                    end
                end
            end

             --法术
            text= text:gsub(SLASH_CAST1..' (.-)\n', function(t)--/施放
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CAST2..' (.-)\n', function(t)--/spell
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CAST3..' (.-)\n', function(t)--/cast
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CAST4..' (.-)\n', function(t)--/法术
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CANCELAURA1..' (.-)\n', function(t)--/cancelaura
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_CANCELAURA2..' (.-)\n', function(t)--/cancelaura
                get_SpellItem_Texture(t:match('](.+)') or t)
                return ''
            end)

            --物品
            text= text:gsub(SLASH_USE1..' (.-)\n', function(t)--/use
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)

            text= text:gsub(SLASH_USE2..' (.-)\n', function(t)--/use
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_USE_TOY1..' (.-)\n', function(t)--/使用玩具
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_USE_TOY2..' (.-)\n', function(t)--/usetoy
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            --物品
            text= text:gsub(SLASH_EQUIP1..' (.-)\n', function(t)--/equip
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)

            text= text:gsub(SLASH_EQUIP2..' (.-)\n', function(t)--/eq
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP3..' (.-)\n', function(t)--/equip
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP4..' (.-)\n', function(t)--/eq
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP_TO_SLOT1..' (.-)\n', function(t)--/equipslot
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)
            text= text:gsub(SLASH_EQUIP_TO_SLOT2..' (.-)\n', function(t)--/equipslot
                get_SpellItem_Texture(nil, t:match('](.+)') or t)
                return ''
            end)

            --区域，技能
            for _, zoneAbilities in pairs(C_ZoneAbility.GetActiveAbilities() or {}) do
                get_SpellItem_Texture(zoneAbilities.spellID)
            end

            for icon, name in pairs(allTab) do
                e.LibDD:UIDropDownMenu_AddButton({
                    text='|T'..icon..':0|t'..name,
                    notCheckable=true,
                    arg1=icon,
                    tooltipOnButton=true,
                    tooltipTitle=e.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL),
                    tooltipText=icon,
                    func= function(_, arg1)
                        WoWTools_MacroMixin:SetMacroTexture(arg1)--修改，当前图标
                    end
                }, 1)
            end


            e.LibDD:UIDropDownMenu_AddButton({
                text='|T134400:0|t'..(e.onlyChinese and '无' or NONE),
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=134400,
                func= function()
                    WoWTools_MacroMixin:SetMacroTexture(134400)--修改，当前图标
                end
            }, 1)

        end, 'MENU')
        e.LibDD:ToggleDropDownMenu(1, nil, MacroFrame.Menu, self, 15,0)--主菜单
    end)
end















function WoWTools_MacroMixin:Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
    Init()
end