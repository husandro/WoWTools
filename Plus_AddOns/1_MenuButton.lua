
local function Save()
    return WoWTools_AddOnsMixin.Save
end












local function Init_Menu(self, root)
    local sub, num
--快捷键
    num=0
    for _ in pairs(Save().fast) do
        num=num+1
    end
    sub=root:CreateCheckbox(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_Mixin.onlyChinese and '快捷键列表 ' or 'Solution List ')
        ..num,
    function()
        return not Save().hideLeftList
    end, function()
        Save().hideLeftList= not Save().hideLeftList and true or nil
        WoWTools_AddOnsMixin.LeftFrame:settings()
        WoWTools_AddOnsMixin:Set_Left_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '左边列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT, ADDON_LIST))
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().leftListScale or 1
    end, function(value)
        Save().leftListScale= value
        WoWTools_AddOnsMixin.LeftFrame:settings()
    end)
    sub:CreateDivider()

    sub:CreateButton(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)
            '|n'..(WoWTools_Mixin.onlyChinese and '快捷键列表' or 'Solution List'),
            nil,
            {SetValue=function()
                Save().fast={}
                WoWTools_AddOnsMixin:Set_Left_Buttons()
            end}
        )
    end)

--加载插件
    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '插件图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, EMBLEM_SYMBOL)),
    function()
        return Save().load_list
    end, function()
        Save().load_list= not Save().load_list and true or nil
        WoWTools_AddOnsMixin.BottomFrame:Set_Load_Button()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '仅限有图标' or format(LFG_LIST_CROSS_FACTION, EMBLEM_SYMBOL))
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '已经打开' or SPELL_FAILED_ALREADY_OPEN)
    end)

--位置：上面
    sub:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '位置：上面' or (CHOOSE_LOCATION..': '..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP),
    function()
        return Save().load_list_top
    end, function()
        Save().load_list_top= not Save().load_list_top and true or nil
        WoWTools_AddOnsMixin.BottomFrame:set_frame_point()
        WoWTools_AddOnsMixin.BottomFrame:set_button_point()
    end)

--大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().load_list_size or 22
        end, setValue=function(value)
            Save().load_list_size= value
            WoWTools_AddOnsMixin.BottomFrame:set_button_point()
        end,
        name=WoWTools_Mixin.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
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
        ..(WoWTools_Mixin.onlyChinese and '方案列表 ' or 'Solution List ')
        ..num,
    function()
        return not Save().hideRightList
    end, function()
        Save().hideRightList= not Save().hideRightList and true or nil
        WoWTools_AddOnsMixin.RightFrame:settings()
        WoWTools_AddOnsMixin:Set_Right_Buttons()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '右边列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT, ADDON_LIST ))
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '新的方案' or PAPERDOLL_NEWEQUIPMENTSET)
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().rightListScale or 1
    end, function(value)
        Save().rightListScale= value
        WoWTools_AddOnsMixin.RightFrame:settings()
    end)

    sub:CreateDivider()
    sub:CreateButton(
        (num==0 and '|cff9e9e9e' or '')
        ..(WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_Mixin.onlyChinese and '全部清除' or CLEAR_ALL)
            '|n'..(WoWTools_Mixin.onlyChinese and '方案列表' or 'Solution List'),
            nil,
            {SetValue=function()
                Save().buttons={}
                WoWTools_AddOnsMixin:Set_Right_Buttons()
            end}
        )
    end)


--隐藏背景
    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_Mixin.onlyChinese and '隐藏背景' or HIDE_PULLOUT_BG,
    function()
        return not Save().Bg_Alpha1
    end, function()
        Save().Bg_Alpha1= not Save().Bg_Alpha1 and true or nil
        AddonListInset.Bg:SetAlpha(Save().Bg_Alpha1 and 1 or 0.5)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((WoWTools_Mixin.onlyChinese and '改变透明度' or CHANGE_OPACITY)..' 0.5')
    end)

    sub=root:CreateCheckbox(
        (WoWTools_Mixin.onlyChinese and '信息' or INFO)..' Plus',
    function()
        return not Save().disabledInfoPlus
    end, function()
        Save().disabledInfoPlus= not Save().disabledInfoPlus and true
        print(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

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

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if Save().load_list_top  then
            GameTooltip:SetOwner(AddonList, "ANCHOR_RIGHT")
        else
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        end
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AddOnsMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(' ', (WoWTools_Mixin.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)

    btn:SetupMenu(Init_Menu)



    WoWTools_AddOnsMixin.MenuButton= btn
end











function WoWTools_AddOnsMixin:Init_Menu_Button()
    Init()

    C_Timer.After(2, function()--Bg 透明度
        if AddonListInset.Bg:GetAlpha()~=1 and Save().Bg_Alpha1 then
            AddonListInset.Bg:SetAlpha(1)
        end
    end)
end