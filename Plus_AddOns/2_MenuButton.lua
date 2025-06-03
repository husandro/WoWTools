
local function Save()
    return WoWToolsSave['Plus_AddOns'] or {}
end












local function Init_Menu(self, root)
    local sub, num
    --local isInCombat= InCombatLockdown()
--快捷键
    num=0
    for _ in pairs(Save().fast) do
        num=num+1
    end
    sub=root:CreateCheckbox(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_DataMixin.onlyChinese and '快捷键列表 ' or 'Solution List ')
        ..num,
    function()
        return not Save().hideLeftList
    end, function()
        Save().hideLeftList= not Save().hideLeftList and true or nil
        _G['WoWToolsAddOnsLeftFrame']:settings()
        WoWTools_AddOnsMixin:Set_Left_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '左边列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT, ADDON_LIST))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().leftListScale or 1
    end, function(value)
        Save().leftListScale= value
        _G['WoWToolsAddOnsLeftFrame']:settings()
    end)
    sub:CreateDivider()

    sub:CreateButton(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            '|n'..(WoWTools_DataMixin.onlyChinese and '快捷键列表' or 'Solution List'),
            nil,
            {SetValue=function()
                Save().fast={}
                WoWTools_AddOnsMixin:Set_Left_Buttons()
            end}
        )
    end)

--加载插件
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '插件图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, EMBLEM_SYMBOL)),
    function()
        return Save().load_list
    end, function()
        Save().load_list= not Save().load_list and true or nil
        WoWTools_AddOnsMixin:Set_Load_Button()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '仅限有图标' or format(LFG_LIST_CROSS_FACTION, EMBLEM_SYMBOL))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '已经打开' or SPELL_FAILED_ALREADY_OPEN)
    end)

--位置：上面
    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '位置：上面' or (CHOOSE_LOCATION..': '..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP),
    function()
        return Save().load_list_top
    end, function()
        Save().load_list_top= not Save().load_list_top and true or nil
        _G['WoWToolsAddOnsBottomFrame']:set_frame_point()
        _G['WoWToolsAddOnsBottomFrame']:set_button_point()
    end)

--大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().load_list_size or 22
        end, setValue=function(value)
            Save().load_list_size= value
            _G['WoWToolsAddOnsBottomFrame']:set_button_point()
        end,
        name=WoWTools_DataMixin.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        minValue=8,
        maxValue=72,
        step=1,
    })
    sub:CreateSpacer()


--方案列表    
    num=0
    for _ in pairs(Save().buttons) do
        num=num+1
    end
    sub=root:CreateCheckbox(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_DataMixin.onlyChinese and '方案列表 ' or 'Solution List ')
        ..num,
    function()
        return not Save().hideRightList
    end, function()
        Save().hideRightList= not Save().hideRightList and true or nil
        _G['WoWToolsAddOnsRightFrame']:settings()
        WoWTools_AddOnsMixin:Set_Right_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '右边列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT, ADDON_LIST ))
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET)
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().rightListScale or 1
    end, function(value)
        Save().rightListScale= value
        _G['WoWToolsAddOnsRightFrame']:settings()
    end)

    sub:CreateDivider()
    sub:CreateButton(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
            '|n'..(WoWTools_DataMixin.onlyChinese and '方案列表' or 'Solution List'),
            nil,
            {SetValue=function()
                Save().buttons={}
                WoWTools_AddOnsMixin:Set_Right_Buttons()
            end}
        )
    end)


--隐藏背景
    root:CreateDivider()
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND,
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '改变透明度' or CHANGE_OPACITY)..' 0.5')
    end)


    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().Bg_Alpha or 0.5
        end, setValue=function(value)
            Save().Bg_Alpha=value
            self:set_bg()
        end,
        name=WoWTools_DataMixin.onlyChinese and '改变透明度' or CHANGE_OPACITY ,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
    })
    sub:CreateSpacer()






    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '信息' or INFO)..' Plus',
    function()
        return not Save().disabledInfoPlus
    end, function()
        Save().disabledInfoPlus= not Save().disabledInfoPlus and true
        print(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--[[11.1.5无效
if WoWTools_DataMixin.Player.husandro then
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '启用CPU分析功能' or format(ADDON_LIST_PERFORMANCE_PEAK_CPU, ENABLE),
    function()
        return Save().addonProfilerEnabled
    end, function()
        if not InCombatLockdown() then
            Save().addonProfilerEnabled = not Save().addonProfilerEnabled  and true or nil
            WoWTools_AddOnsMixin:Set_AddonProfiler()
        end
    end)
    sub:SetEnabled(not isInCombat)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(
            ( C_CVar.GetCVarInfo('addonProfilerEnabled') and '' or '|cff9e9e9e')
            ..'CVar addonProfilerEnabled'
        )
    end)
end]]

    root:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(root)

--打开选项界面
    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_AddOnsMixin.addName})
end














local function Init()
    local btn= WoWTools_ButtonMixin:Menu(AddonListCloseButton, {name='WoWTool_AddOnsOptionsButton'})
    btn:SetPoint('RIGHT', AddonListCloseButton, 'LEFT', -2, 0)

--提升 Strata
    AddonListCloseButton:SetFrameStrata(AddonList.TitleContainer:GetFrameStrata())
    AddonListCloseButton:GetFrameLevel(AddonList.TitleContainer:GetFrameLevel()+1)

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if Save().load_list_top  then
            GameTooltip:SetOwner(AddonList, "ANCHOR_RIGHT")
        else
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        end
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', (WoWTools_DataMixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    btn:SetupMenu(Init_Menu)

    function btn:set_bg()
        AddonListInset.Bg:SetAlpha(Save().Bg_Alpha or 0.5)
    end
    btn:set_bg()

    WoWTools_AddOnsMixin.MenuButton= btn
end











function WoWTools_AddOnsMixin:Init_Menu_Button()
    Init()
end