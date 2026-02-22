local Layout
local function Save()
    return WoWToolsSave['Plus_Tootips']
end








local function set_Cursor_Tips(self)
    WoWTools_TooltipMixin:Set_Rest_Item(GameTooltip)
    WoWTools_TooltipMixin:Set_Rest_Item(ItemRefTooltip)

    WoWTools_TooltipMixin:Set_PlayerModel(GameTooltip)
    WoWTools_TooltipMixin:Set_PlayerModel(ItemRefTooltip)

    GameTooltip_SetDefaultAnchor(GameTooltip, self or UIParent)
    GameTooltip:SetScale(Save().scale or 1)
    GameTooltip:ClearLines()
    GameTooltip:SetUnit('player')
    GameTooltip:Show()
end









local function Init_Panel()
    local reloadText= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)
    local root


    root= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '跟随鼠标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, FOLLOW, MOUSE_LABEL),
        tooltip= WoWTools_TooltipMixin.addName,
        GetValue= function() return Save().setDefaultAnchor end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().setDefaultAnchor= not Save().setDefaultAnchor and true or false
            if Save().setDefaultAnchor then
                Save().setAnchor=nil
            end
            set_Cursor_Tips()
        end
    })

    WoWTools_PanelMixin:OnlySlider({
        name= 'X',
        GetValue= function() return Save().cursorX or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().cursorX= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlySlider({
        name= 'Y',
        GetValue= function() return Save().cursorY or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().cursorY= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
        tooltip= WoWTools_TooltipMixin.addName,
        GetValue= function() return Save().cursorRight end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().cursorRight= not Save().cursorRight and true or nil
            set_Cursor_Tips()
        end
    }, root)


    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '战斗中：默认' or (HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DEFAULT),
        tooltip= WoWTools_DataMixin.onlyChinese and '重设到默认位置' or HUD_EDIT_MODE_RESET_POSITION,
        GetValue= function() return Save().inCombatDefaultAnchor end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().inCombatDefaultAnchor= not Save().inCombatDefaultAnchor and true or false
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '战斗中：禁用' or (HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..DISABLE),
        tooltip= WoWTools_TooltipMixin.addName,
        GetValue= function() return Save().isInCombatDisabled end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().inCombatDefaultAnchor= not Save().isInCombatDisabled and true or nil
        end
    }, root)

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)

    root= WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '模型' or MODEL,
        tooltip= WoWTools_TooltipMixin.addName,
        GetValue= function() return not Save().hideModel end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().hideModel= not Save().hideModel and true or nil
            set_Cursor_Tips()
        end
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '左' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT,
        tooltip= WoWTools_TooltipMixin.addName,
        GetValue= function() return Save().modelLeft end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().modelLeft= not Save().modelLeft and true or nil
            set_Cursor_Tips()
        end
    }, root)


    --[[WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_DataMixin.onlyChinese and '模型' or MODEL)..' ID',
        tooltip= addName,
        value= Save().showModelFileID,
        category= WoWTools_TooltipMixin.Category,
        func= function()
            Save().showModelFileID= not Save().showModelFileID and true or nil
            set_Cursor_Tips()
        end
    }, root)
]]
    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_BAGS_SIZE,
        GetValue= function() return Save().modelSize or 100 end,
        minValue= 40,
        maxValue= 300,
        setp= 1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelSize= WoWTools_DataMixin:GetFormatter1to10(value2, 40, 300)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlySlider({
        name= 'X',
        GetValue= function() return Save().modelX or 0 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelX= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlySlider({
        name= 'Y',
        GetValue= function() return Save().modelY or -24 end,
        minValue= -240,
        maxValue= 240,
        setp= 1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelY= WoWTools_DataMixin:GetFormatter1to10(value2, -200, 200)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION,
        GetValue= function() return Save().modelFacing or -24 end,
        minValue= -1,
        maxValue= 1,
        setp= 0.1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if not value2 then return end
            Save().modelFacing= WoWTools_DataMixin:GetFormatter1to10(value2, -1, 1)
            set_Cursor_Tips()
        end
    }, root)

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and 'NPC职业颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'NPC', CLASS_COLORS),
        tooltip= WoWTools_TooltipMixin.addName,
        GetValue= function() return not Save().disabledNPCcolor end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().disabledNPCcolor= not Save().disabledNPCcolor and true or nil
        end
    })

    --12.0  可能错误
        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_DataMixin.onlyChinese and '生命值' or HEALTH,
            tooltip= reloadText,
            GetValue= function() return not Save().hideHealth end,
            category= WoWTools_TooltipMixin.Category,
            SetValue= function()
                Save().hideHealth= not Save().hideHealth and true or nil
                WoWTools_TooltipMixin:Init_StatusBar()
            end
        })


--[[<右键点击设置框体>
    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '<右键点击设置框体>' or UNIT_POPUP_RIGHT_CLICK,
        tooltip=  WoWTools_TextMixin:GetShowHide(Save().UNIT_POPUP_RIGHT_CLICK),
        GetValue= function() return Save().UNIT_POPUP_RIGHT_CLICK end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().UNIT_POPUP_RIGHT_CLICK= not Save().UNIT_POPUP_RIGHT_CLICK and true or nil
            print(WoWTools_TooltipMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_TextMixin:GetShowHide(Save().UNIT_POPUP_RIGHT_CLICK), reloadText)
        end
    })]]

    WoWTools_PanelMixin:OnlyCheck({
        name= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, '|A:NPE_Icon:0:0|aCtrl+Shift', WoWTools_DataMixin.onlyChinese and '复制链接' or BROWSER_COPY_LINK),
        tooltip= 'wowhead.com|nraider.io',
        GetValue= function() return Save().ctrl end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().ctrl= not Save().ctrl and true or nil
            set_Cursor_Tips()
        end
    })





    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        GetValue= function() return Save().iconSize or 0 end,
        minValue= 0,
        maxValue= 32,
        setp= 1,
        tooltip= WoWTools_TooltipMixin.addName,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if value2 then
                Save().iconSize= WoWTools_DataMixin:GetFormatter1to10(value2, 0, 32)
                WoWTools_TooltipMixin.iconSize= Save().iconSize
            end
        end
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= (WoWTools_DataMixin.onlyChinese and '物品数值' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, STATUS_TEXT_VALUE))..' mk',
        tooltip= '1k008, 2w008, 3m008',
        GetValue= function() return Save().showItemMK end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().showItemMK= not Save().showItemMK and true or nil
            set_Cursor_Tips()
        end
    })

    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '缩放' or HOUSING_EXPERT_DECOR_SUBMODE_SCALE,
        GetValue= function() return Save().scale or 1 end,
        minValue=0.2,
        maxValue=4,
        step=0.1,
        tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
        category= WoWTools_TooltipMixin.Category,
        SetValue= function(_, _, value2)
            if value2 then
                value2= tonumber(format('%.1f', value2))
                Save().scale= value2
                set_Cursor_Tips()
            end
        end
    })


    WoWTools_PanelMixin:Header(Layout, 'CVar')

    root= WoWTools_PanelMixin:OnlyCheck({
        name= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '锁定设置' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, LOCK, SETTINGS)),
        tooltip= function() return WoWTools_TooltipMixin:Set_CVar(nil, true, true) end,
        GetValue= function() return Save().setCVar end,
        category= WoWTools_TooltipMixin.Category,
        SetValue= function()
            Save().setCVar= not Save().setCVar and true or nil
            Save().graphicsViewDistance=nil
        end
    })

    WoWTools_PanelMixin:OnlyButton({
        buttonText= WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS,
        layout= Layout,
        SetValue= function()
            WoWTools_TooltipMixin:Set_CVar()
            print(WoWTools_DataMixin.onlyChinese and '设置完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COMPLETE))
        end
    }, root)

    WoWTools_PanelMixin:OnlyButton({
        buttonText= WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT,
        layout= Layout,
        SetValue= function()
            WoWTools_TooltipMixin:Set_CVar(true, nil, nil)
            print(WoWTools_DataMixin.onlyChinese and '默认完成' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DEFAULT, COMPLETE))
        end
    }, root)

    WoWTools_PanelMixin:OnlyMenu({
        SetValue= function(value)
            if not InCombatLockdown() then
                if value==1 then
                    C_CVar.SetCVar("ActionButtonUseKeyDown", '1')
                else
                    C_CVar.SetCVar("ActionButtonUseKeyDown", '0')
                end
            end
        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, WoWTools_DataMixin.onlyChinese and '是' or YES)
            container:Add(2, WoWTools_DataMixin.onlyChinese and '不' or NO)
            return container:GetData()
        end,
        GetValue= function() return C_CVar.GetCVarBool("ActionButtonUseKeyDown") and 1 or 2 end,
        name= WoWTools_DataMixin.onlyChinese and '按下快捷键时施法' or ACTION_BUTTON_USE_KEY_DOWN,
        tooltip= function()
            return WoWTools_DataMixin:Get_CVar_Tooltips({
                    name='ActionButtonUseKeyDown',
                    msg=WoWTools_DataMixin.onlyChinese and '在按下快捷键时施法，而不是在松开快捷键时施法。' or OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN,
                }) end,
        category= WoWTools_TooltipMixin.Category,
    })







    local index=0
    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(index..') ')..name:gsub('Blizzard_', ''),
            tooltip= reloadText,
            category= WoWTools_TooltipMixin.Category,
            Value= not Save().no[name],
            GetValue= function() return not Save().no[name] end,
            SetValue= function()
                Save().no[name]= not Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(Layout, 'Event')
    for name in pairs(WoWTools_TooltipMixin.Events) do
        index= index+1
        Add_Options(name)
    end

    index=0
    WoWTools_PanelMixin:Header(Layout, 'Frame')
    for name in pairs(WoWTools_TooltipMixin.Frames) do
        index= index+1
        Add_Options(name)
    end
    Init_Panel=function()end
end






























--初始
local function Init()
    WoWTools_DataMixin:Hook("GameTooltip_SetDefaultAnchor", function(frame, parent)
        if Save().setDefaultAnchor and not (Save().inCombatDefaultAnchor and InCombatLockdown()) then
            frame:ClearAllPoints()
            frame:SetOwner(
                parent,
                Save().cursorRight and 'ANCHOR_CURSOR_RIGHT' or 'ANCHOR_CURSOR_LEFT',
                Save().cursorX or 0,
                Save().cursorY or 0
            )
        end
    end)


    for name in pairs(WoWTools_TooltipMixin.Events)do
        if C_AddOns.IsAddOnLoaded(name) then
            if not Save().no[name] then
                WoWTools_TooltipMixin.Events[name](WoWTools_TooltipMixin)
            end
            WoWTools_TooltipMixin.Events[name]= nil
        end
    end



    EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(owner)
        for name in pairs(WoWTools_TooltipMixin.Frames) do
            if _G[name] and not Save().no[name] then
                WoWTools_TooltipMixin.Frames[name](WoWTools_TooltipMixin)
            elseif WoWTools_DataMixin.Player.husandro then
                print('Tooltip Frames 没有发现|cnWARNING_FONT_COLOR:', name)
            end
            WoWTools_TooltipMixin.Frames[name]= nil
        end
        EventRegistry:UnregisterCallback('PLAYER_ENTERING_WORLD', owner)
    end)



    WoWTools_TooltipMixin:Init_StatusBar()--生命条提示
    WoWTools_TooltipMixin:Init_CVar()

    WoWTools_TooltipMixin:Set_Init_Item(GameTooltip)

--移除，<右键点击设置框体> 替换原生
    if not Save().UNIT_POPUP_RIGHT_CLICK then
        function UnitFrame_UpdateTooltip (self)
            GameTooltip_SetDefaultAnchor(GameTooltip, self);
            if GameTooltip:SetUnit(self.unit, self.hideStatusOnTooltip) then
                self.UpdateTooltip = UnitFrame_UpdateTooltip;
            else
                self.UpdateTooltip = nil;
            end
        end
    end


    Init=function()end
end








--Save().WidgetSetID = Save().WidgetSetID or 0
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Tootips']= WoWToolsSave['Plus_Tootips'] or {
                setDefaultAnchor=true,--指定点
                --AnchorPoint={},--指定点，位置
                --cursorRight=nil,--'ANCHOR_CURSOR_RIGHT',

                setCVar=WoWTools_DataMixin.Player.husandro,
                ShowOptionsCVarTips=WoWTools_DataMixin.Player.husandro,--显示选项中的CVar
                inCombatDefaultAnchor=true,
                ctrl= WoWTools_DataMixin.Player.husandro,--取得网页，数据链接

                --模型
                modelSize=100,--大小
                --modelLeft=true,--左边
                modelX= 0,
                modelY= -15,
                modelFacing= -0.3,--方向
                showModelFileID=WoWTools_DataMixin.Player.husandro,--显示，文件ID
                --WidgetSetID=848,--自定义，监视 WidgetSetID
                --disabledNPCcolor=true,--禁用NPC颜色
                --hideHealth=true,----生命条提示
                --UNIT_POPUP_RIGHT_CLICK= true,--<右键点击设置框体> 12.0移除
                showItemMK=WoWTools_DataMixin.Player.husandro,
                no={}--禁用
            }


            Save().no= Save().no or {}
            WoWTools_TooltipMixin.iconSize= Save().iconSize or 0


            WoWTools_TooltipMixin.Category, Layout= WoWTools_PanelMixin:AddSubCategory({
                name=WoWTools_TooltipMixin.addName,
                disabled= Save().disabled
            })

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init_Panel()
                end,
                buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
                buttonFunc= function()
                    StaticPopup_Show('WoWTools_RestData',
                        WoWTools_TooltipMixin.addName,
                        nil,
                    function()
                        WoWToolsSave['Plus_Tootips']= nil
                    end)
                end,
                tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                layout= Layout,
                category= WoWTools_TooltipMixin.Category,
            })

            WoWTools_TooltipMixin:Init_WoWHeadText()

            if Save().disabled then
                WoWTools_TooltipMixin.Events= {}
                WoWTools_TooltipMixin.Frames= {}
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)

            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('PLAYER_LEAVING_WORLD')
                do
                    Init_Panel()
                end
                Init()--初始
            end



        elseif WoWToolsSave then

            if WoWTools_TooltipMixin.Events[arg1] then
                if not Save().no[arg1] then
                    WoWTools_TooltipMixin.Events[arg1](WoWTools_TooltipMixin)
                end
                WoWTools_TooltipMixin.Events[arg1]=nil
            end
        end


    elseif event=='PLAYER_ENTERING_WORLD' then
        if Save().setCVar and Save().graphicsViewDistance and not InCombatLockdown() then
            C_CVar.SetCVar('graphicsViewDistance', Save().graphicsViewDistance)--https://wago.io/ZtSxpza28
            Save().graphicsViewDistance=nil
        end

    elseif event=='PLAYER_LEAVING_WORLD' then
        if Save() and Save().setCVar then
            if not InCombatLockdown() then
                Save().graphicsViewDistance= C_CVar.GetCVar('graphicsViewDistance')
                SetCVar("graphicsViewDistance", 0)
            else
                Save().graphicsViewDistance=nil
            end
        end
    end
end)
