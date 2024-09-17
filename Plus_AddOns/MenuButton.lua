
local e= select(2, ...)
local function Save()
    return WoWTools_AddOnsMixin.Save
end







local function Init_Menu(self, root)
    local sub

--加载插件
    sub=root:CreateCheckbox(
        e.onlyChinese and '插件图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, EMBLEM_SYMBOL),
    function()
        return Save().load_list
    end, function()
        Save().load_list= not Save().load_list and true or nil
        self.LoadFrame:Set_Load_Button()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '仅限有图标' or format(LFG_LIST_CROSS_FACTION, EMBLEM_SYMBOL))
    end)

--位置：上面
    sub:CreateCheckbox(
        e.onlyChinese and '位置：上面' or (CHOOSE_LOCATION..': '..HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP),
    function()
        return Save().load_list_top
    end, function()
        Save().load_list_top= not Save().load_list_top and true or nil
        self.LoadFrame:set_frame_point()
        self.LoadFrame:set_button_point()
    end)

--大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().load_list_size or 22
        end, setValue=function(value)
            Save().load_list_size= value
            self.LoadFrame:set_button_point()
        end,
        name=e.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        minValue=8,
        maxValue=72,
        step=1,
    })
    sub:CreateSpacer()



--隐藏背景
    sub=root:CreateCheckbox(
        e.onlyChinese and '隐藏背景' or HIDE_PULLOUT_BG,
    function()
        return not Save().Bg_Alpha1
    end, function()
        Save().Bg_Alpha1= not Save().Bg_Alpha1 and true or nil
        AddonListInset.Bg:SetAlpha(Save().Bg_Alpha1 and 1 or 0.5)
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((e.onlyChinese and '改变透明度' or CHANGE_OPACITY)..' 0.5')
    end)
end














local function Init()
    local btn= WoWTools_ButtonMixin:CreateMenu(AddonListCloseButton, {name='WoWTool_AddOnsOptionsButton'})
    btn:SetPoint('RIGHT', AddonListCloseButton, 'LEFT', -2, 0)
    btn:SetFrameStrata(AddonListCloseButton:GetFrameStrata())
    btn:SetFrameLevel(AddonListCloseButton:GetFrameLevel())

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if Save().load_list_top  then
            e.tips:SetOwner(AddonList, "ANCHOR_RIGHT")
        else
            e.tips:SetOwner(self, "ANCHOR_LEFT")
        end
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_AddOnsMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:Show()
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