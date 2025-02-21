--添加新控制面板 Blizzard_Settings
local e= select(2, ...)
local function Save()
    return WoWTools_TooltipMixin.Save
end

local Category, Layout







local function set_Cursor_Tips(self)
    WoWTools_TooltipMixin:Set_Init_Item(GameTooltip, true)
    WoWTools_TooltipMixin:Set_Init_Item(ItemRefTooltip, true)

    WoWTools_TooltipMixin:Set_PlayerModel(GameTooltip)
    WoWTools_TooltipMixin:Set_PlayerModel(ItemRefTooltip)

    GameTooltip_SetDefaultAnchor(GameTooltip, self or UIParent)

    GameTooltip:ClearLines()
    GameTooltip:SetUnit('player')
    GameTooltip:Show()
end









local function Init_Panel()
    local addName= WoWTools_TooltipMixin.addName

    e.AddPanel_Header(Layout, e.onlyChinese and '选项' or OPTIONS)


    local initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '跟随鼠标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FOLLOW, MOUSE_LABEL),
        tooltip= addName,
        GetValue= function() return Save().setDefaultAnchor end,
        category= Category,
        SetValue= function()
            Save().setDefaultAnchor= not Save().setDefaultAnchor and true or nil
            if Save().setDefaultAnchor then
                Save().setAnchor=nil
            end
            set_Cursor_Tips()
        end
    })

    local initializer= e.AddPanelSider({
        name= 'X',
        GetValue= function() return Save().cursorX or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().cursorX= e.GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().setDefaultAnchor then return true else return false end end)

    initializer= e.AddPanelSider({
        name= 'Y',
        GetValue= function() return Save().cursorY or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().cursorY= e.GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().setDefaultAnchor then return true else return false end end)

    initializer= e.AddPanel_Check({
        name= e.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
        tooltip= addName,
        GetValue= function() return Save().cursorRight end,
        category= Category,
        SetValue= function()
            Save().cursorRight= not Save().cursorRight and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().setDefaultAnchor then return true else return false end end)

    initializer= e.AddPanel_Check({
        name= e.onlyChinese and '战斗中：默认' or (HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DEFAULT),
        tooltip= addName,
        GetValue= function() return Save().inCombatDefaultAnchor end,
        category= Category,
        SetValue= function()
            Save().inCombatDefaultAnchor= not Save().inCombatDefaultAnchor and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().setDefaultAnchor then return true else return false end end)


    e.AddPanel_Header(Layout, e.onlyChinese and '设置' or SETTINGS)

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '模型' or MODEL,
        tooltip= addName,
        GetValue= function() return not Save().hideModel end,
        category= Category,
        SetValue= function()
            Save().hideModel= not Save().hideModel and true or nil
            set_Cursor_Tips()
        end
    })

    initializer= e.AddPanel_Check({
        name= e.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
        tooltip= addName,
        GetValue= function() return Save().modelLeft end,
        category= Category,
        SetValue= function()
            Save().modelLeft= not Save().modelLeft and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().hideModel then return false else return true end end)

    --[[initializer= e.AddPanel_Check({
        name= (e.onlyChinese and '模型' or MODEL)..' ID',
        tooltip= addName,
        value= Save().showModelFileID,
        category= Category,
        func= function()
            Save().showModelFileID= not Save().showModelFileID and true or nil
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().hideModel then return false else return true end end)
]]
    initializer= e.AddPanelSider({
        name= e.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_BAGS_SIZE,
        GetValue= function() return Save().modelSize or 100 end,
        minValue= 40,
        maxValue= 300,
        setp= 1,
        tooltip= addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelSize= e.GetFormatter1to10(value2, 40, 300)
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= 'X',
        GetValue= function() return Save().modelX or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelX= e.GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= 'Y',
        GetValue= function() return Save().modelY or -24 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelY= e.GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().hideModel then return false else return true end end)

    initializer= e.AddPanelSider({
        name= e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION,
        GetValue= function() return Save().modelFacing or -24 end,
        minValue= -1,
        maxValue= 1,
        setp= 0.1,
        tooltip= addName,
        category= Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelFacing= e.GetFormatter1to10(value2, -1, 1)
            set_Cursor_Tips()
        end
    })
    initializer:SetParentInitializer(initializer2, function() if Save().hideModel then return false else return true end end)

    e.AddPanel_Check({
        name= e.onlyChinese and 'NPC职业颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'NPC', CLASS_COLORS),
        tooltip= addName,
        GetValue= function() return not Save().disabledNPCcolor end,
        category= Category,
        SetValue= function()
            Save().disabledNPCcolor= not Save().disabledNPCcolor and true or nil
        end
    })

    e.AddPanel_Check({
        name= e.onlyChinese and '生命值' or HEALTH,
        tooltip= addName,
        GetValue= function() return not Save().hideHealth end,
        category= Category,
        SetValue= function()
            Save().hideHealth= not Save().hideHealth and true or nil
            print(WoWTools_Mixin.addName, WoWTools_TooltipMixin.addName,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
    e.AddPanel_Check({
        name= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, '|A:NPE_Icon:0:0|aCtrl+Shift', e.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        tooltip= 'wowhead.com|nraider.io',
        GetValue= function() return Save().ctrl end,
        category= Category,
        SetValue= function()
            Save().ctrl= not Save().ctrl and true or nil
            set_Cursor_Tips()
        end
    })


    e.AddPanel_Header(Layout, 'CVar')

    initializer2= e.AddPanel_Check({
        name= e.onlyChinese and '自动设置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SETTINGS),
        tooltip= function() return WoWTools_TooltipMixin:Set_CVar(nil, true, true) end,
        GetValue= function() return Save().setCVar end,
        category= Category,
        SetValue= function()
            Save().setCVar= not Save().setCVar and true or nil
            Save().graphicsViewDistance=nil
        end
    })

    initializer= e.AddPanel_Button({
        buttonText= e.onlyChinese and '设置' or SETTINGS,
        layout= Layout,
        SetValue= function()
            WoWTools_TooltipMixin:Set_CVar()
            print(e.onlyChinese and '设置完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COMPLETE))
        end
    })
    initializer:SetParentInitializer(initializer2)

    initializer= e.AddPanel_Button({
        buttonText= e.onlyChinese and '默认' or DEFAULT,
        layout= Layout,
        SetValue= function()
            WoWTools_TooltipMixin:Set_CVar(true, nil, nil)
            print(e.onlyChinese and '默认完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEFAULT, COMPLETE))
        end
    })
    initializer:SetParentInitializer(initializer2)

    e.AddPanel_DropDown({
        SetValue= function(value)
            if value==1 then
                C_CVar.SetCVar("ActionButtonUseKeyDown", '1')
            else
                C_CVar.SetCVar("ActionButtonUseKeyDown", '0')
            end
        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, e.onlyChinese and '是' or YES)
            container:Add(2, e.onlyChinese and '不' or NO)
            return container:GetData()
        end,
        GetValue= function() return C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 1 or 2 end,
        name= e.onlyChinese and '按下快捷键时施法' or ACTION_BUTTON_USE_KEY_DOWN,
        tooltip= function()
            return e.Get_CVar_Tooltips({
                    name='ActionButtonUseKeyDown',
                    msg=e.onlyChinese and '在按下快捷键时施法，而不是在松开快捷键时施法。' or OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
                }) end,
        category= Category
    })

    initializer2= e.AddPanel_Check({
        name= (e.onlyChinese and '提示选项CVar名称' or 'Show Option CVar Name'),
        tooltip= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '友情提示: 可能会出现错误' or (LABEL_NOTE..': '..ENABLE_ERROR_SPEECH)..'|r'),
        GetValue= function() return Save().ShowOptionsCVarTips end,
        category= Category,
        SetValue= function()
            Save().ShowOptionsCVarTips= not Save().ShowOptionsCVarTips and true or nil
            print(WoWTools_Mixin.addName, WoWTools_TooltipMixin.addName, e.GetEnabeleDisable(not Save().ShowOptionsCVarTips), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

    WoWTools_TooltipMixin.AddOn.Blizzard_Settings=nil
end













function WoWTools_TooltipMixin.AddOn.Blizzard_Settings()
    Init_Panel()
end





function WoWTools_TooltipMixin:Init_Category()
    Category, Layout= e.AddPanel_Sub_Category({
        name=self.addName,
        disabled=Save().disabled
    })


    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= self.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
            print(WoWTools_Mixin.addName, self.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
end