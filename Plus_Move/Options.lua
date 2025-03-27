--添加控制面板


local function Save()
    return WoWToolsSave['Plus_Move']
end

local Category, Layout







local function Init_Options()
    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

    --移动
    local initializer2
    --[[= WoWTools_PanelMixin:OnlyCheck({
        name= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE),
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return not Save().disabledMove end,
        category= Category,
        SetValue= function()
            Save().disabledMove= not Save().disabledMove and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledMove), WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
        end
    })]]

    WoWTools_PanelMixin:Check_Button({
        checkName= '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '保存位置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SAVE, CHOOSE_LOCATION:gsub(CHOOSE , ''))),
        tooltip= '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '危险！' or VOICEMACRO_1_Sc_0),
        GetValue= function() return Save().SavePoint end,
        SetValue=function()
            Save().SavePoint= not Save().SavePoint and true or nil
        end,
        buttonText= WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        buttonFunc= function()
            StaticPopupDialogs[WoWTools_MoveMixin.addName..'MoveZoomClearPoint']= {
                text = WoWTools_MoveMixin.addName..'|n|n'
                ..(WoWTools_DataMixin.onlyChinese and '保存位置' or (Save()..CHOOSE_LOCATION:gsub(CHOOSE , ''))),
                button1 = '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
                button2 = WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function()
                    Save().point={}
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_DataMixin.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
            }
            StaticPopup_Show(WoWTools_MoveMixin.addName..'MoveZoomClearPoint')
        end,
        layout= Layout,
        category=Category,
    })


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '可以移到屏幕外' or 'Can be moved off screen',
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return Save().moveToScreenFuori end,
        category= Category,
        SetValue= function()
            Save().moveToScreenFuori= not Save().moveToScreenFuori and true or nil
        end
    })
    --initializer:SetParentInitializer(initializer2, function() if Save().disabledMove then return false else return true end end)

    --[[缩放
    WoWTools_PanelMixin:Check_Button({
        checkName= '|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE),
        GetValue= function() return not Save().disabledZoom end,
        SetValue= function()
            Save().disabledZoom= not Save().disabledZoom and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabledZoom), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,

        buttonText= (WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        buttonFunc= function()
            StaticPopupDialogs[WoWTools_MoveMixin.addName..'MoveZoomClearZoom']= {
                text = WoWTools_MoveMixin.addName..'|n|n'
                ..('|A:UI-HUD-Minimap-Zoom-In:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)),
                button1 = '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE),
                button2 = WoWTools_DataMixin.onlyChinese and '取消' or CANCEL,
                button3=  '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE),
                whileDead=true, hideOnEscape=true, exclusive=true,
                OnAccept=function()
                    Save().scale={}
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, (WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
                OnAlt=function()
                    Save().size={}
                    Save().disabledSize={}
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_DataMixin.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
                end,
            }
            StaticPopup_Show(WoWTools_MoveMixin.addName..'MoveZoomClearZoom')
        end,

        tooltip= WoWTools_MoveMixin.addName,
        layout= Layout,
        category= Category
    })]]

    WoWTools_Mixin:Check_Slider({
        checkName= WoWTools_DataMixin.onlyChinese and '移动时Frame透明' or MAP_FADE_TEXT:gsub(WORLD_MAP, 'Frame'),
        checkGetValue= function() return not Save().notMoveAlpha end,
        checkTooltip= WoWTools_DataMixin.onlyChinese and '当你开始移动时，Frame变为透明状态。' or OPTION_TOOLTIP_MAP_FADE:gsub(string.lower(WORLD_MAP), 'Frame'),
        checkSetValue= function()
            Save().notMoveAlpha= not Save().notMoveAlpha and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,

        sliderGetValue= function() return Save().alpha or 0.5 end,
        minValue= 0,
        maxValue= 0.9,
        step= 0.1,
        sliderSetValue= function(_, _, value2)
            if value2 then
                Save().alpha= WoWTools_Mixin:GetFormatter1to10(value2, 0, 1)
            end
        end,
        layout= Layout,
        category= Category,
    })
   -- initializer:SetParentInitializer(initializer2, function() if Save().disabledZoom then return false else return true end end)
end











local function Init_Add()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_MoveMixin.addName,
        disabled= Save().disabled,
    })
    WoWTools_MoveMixin.Category= Category

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_MoveMixin.addName,
        GetValue= function() return not Save().disabled end,
        category= Category,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_MoveMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })

    if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        Init_Options()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Settings' then
                Init_Options()
                EventRegistry:UnregisterCallback(arg1, owner)
            end
        end)
    end
end



function WoWTools_MoveMixin:Init_Options()
    Init_Add()
end