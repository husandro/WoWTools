--选定宏，点击，弹出菜单，自定图标


local function Get_Text_Table()
    local allTab={}
    local text= MacroFrameText:GetText()

    if not text or text:gsub(' ', '')=='' then
        return allTab
    end

    text= text..'\n'

    --添加，物品，法术，图标=物品名称
    local function get_SpellItem_Texture(spell, item)
        if spell then--spell 字符
            local spellID
            local icon= C_Spell.GetSpellTexture(spell)
            local data= C_Spell.GetSpellInfo(spell)
            if data then
                icon= icon or data.iconID
                spellID=data.spellID
                WoWTools_DataMixin:Load({id=spellID, type='spell'})
            end
            if icon then
                allTab[icon]= {
                    name=WoWTools_SpellMixin:GetName(spellID) or C_Spell.GetSpellName(spell) or spell,
                    spellID=spellID
                }
            end

        elseif item then
            WoWTools_DataMixin:Load({id=item, type='item'})
            local itemID= C_Item.GetItemInfoInstant(item)
            local icon= C_Item.GetItemIconByID(item)
            if icon then
                allTab[icon]={
                    name=WoWTools_ItemMixin:GetName(itemID) or item,
                    itemID=itemID
                }
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

    return allTab
end














local function Init_Menu(_, root)
--战斗中
    if WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

    local sub
    local new= Get_Text_Table()

    new[134400]= {name='|T134400:0|t'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)}


    for icon, tab in pairs(new or {}) do
        sub=root:CreateButton(
            tab.name,
        function(data)
            if WoWTools_FrameMixin:IsLocked(MacroFrame) then
                return
            end
            local index= WoWTools_MacroMixin:GetSelectIndex()
            if index then
                if select(3, GetMacroInfo(index))~= MacroFrameText:GetText() then
                    WoWTools_DataMixin:Call('MacroFrameSaveButton_OnClick')
                end
            end
            do
                WoWTools_MacroMixin:SetMacroTexture(data.icon)--修改，当前图标
            end
            return MenuResponse.Refresh
        end, {icon=icon, spellID=tab.spellID, itemID=tab.itemID})

        sub:SetTooltip(function(tooltip, description)
            tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL)))
            if description.data.itemID then
                tooltip:AddLine(' ')
                tooltip:AddLine(WoWTools_ItemMixin:GetName(description.data.itemID))--取得法术，名称
            elseif description.data.spellID then
                tooltip:AddLine(' ')
                tooltip:AddLine(WoWTools_SpellMixin:GetName(description.data.spellID))--取得法术，名称
            end
            local text= MacroFrameText:GetText()
            tooltip:AddLine(' ')
            if text and text:find('#showtooltip') then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:#showtooltip')
            else
                tooltip:AddLine('|cff9e9e9e:#showtooltip')
            end
        end)
    end
    WoWTools_MenuMixin:SetScrollMode(root)
end













--选定宏，点击，弹出菜单，自定图标
local function Init()
    --选定宏，index提示
    MacroFrame.numSelectionLable= WoWTools_LabelMixin:Create(MacroFrameSelectedMacroButton)
    MacroFrame.numSelectionLable:SetAlpha(0.7)
    MacroFrame.numSelectionLable:SetPoint('RIGHT', MacroFrameSelectedMacroButton, 'LEFT', -1,0)
    MacroFrame.numSelectionLable:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.7) end)
    MacroFrame.numSelectionLable:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine( WoWTools_DataMixin.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)
        GameTooltip:Show()
        self:SetAlpha(1)
    end)
    WoWTools_DataMixin:Hook(MacroFrame, 'SelectMacro', function(self, index)
        self.numSelectionLable:SetText(index and index+MacroFrame.macroBase or '')
    end)

    --选定，宏，提示
    MacroFrameSelectedMacroButton:HookScript('OnEnter', function(self)
        local icon= WoWTools_MacroMixin:SetTooltips(self, WoWTools_MacroMixin:GetSelectIndex())
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            '|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '设置图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, EMBLEM_SYMBOL))
            ..(icon and '|T'..icon..':0|t' or ''),
            WoWTools_DataMixin.Icon.left
        )
        GameTooltip:Show()
    end)
    MacroFrameSelectedMacroButton:HookScript('OnLeave', function()
        GameTooltip:Hide()
        --Set_Action_Focus()
    end)

    --选定宏，点击，弹出菜单，自定图标
    --MacroFrameSelectedMacroButton:RegisterForClicks("AnyDown", "AnyUp")--WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    MacroFrameSelectedMacroButton:HookScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, function(...) Init_Menu(...) end)
    end)
end















function WoWTools_MacroMixin:Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
    Init()
end