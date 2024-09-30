local e= select(2, ...)
local function Save()
    return WoWTools_TokensMixin.Save
end










local function Init_TrackButton_Menu(_, root)
    if Save().itemButtonUse and WoWTools_MenuMixin:CheckInCombat(root) or not WoWTools_TokensMixin.TrackButton then
        return
    end

    local sub

--显示
    root:CreateCheckbox(
        e.onlyChinese and '显示' or SHOW,
    function()
        return Save().str
    end, function ()
        Save().str= not Save().str and true or nil
        WoWTools_TokensMixin.TrackButton:set_Texture()
        WoWTools_TokensMixin.TrackButton.Frame:set_shown()
    end)

--显示名称
    root:CreateDivider()
    root:CreateCheckbox(
        e.onlyChinese and '显示名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, NAME),
    function ()
        return Save().nameShow
    end, function ()
        Save().nameShow= not Save().nameShow and true or nil
        WoWTools_TokensMixin:Set_TrackButton_Text()
    end)

--向右平移
    root:CreateCheckbox(
        (e.onlyChinese and '向右平移' or BINDING_NAME_STRAFERIGHT)..'|A:NPE_ArrowRight:0:0|a',
    function ()
        return Save().toRightTrackText
    end, function ()
        Save().toRightTrackText = not Save().toRightTrackText and true or nil
        for _, btn in pairs(WoWTools_TokensMixin.TrackButton.btn) do
            btn.text:ClearAllPoints()
            btn:set_Text_Point()
        end
    end)

--上
    sub=root:CreateCheckbox(
        (e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP)..'|A:bags-greenarrow:0:0|a',
    function ()
        return Save().toTopTrack
    end, function ()
        Save().toTopTrack = not Save().toTopTrack and true or nil
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
    end)

--reload
    WoWTools_MenuMixin:Reload(sub)

    --缩放
    WoWTools_MenuMixin:Scale(root, function()
        return Save().scaleTrackButton
    end, function(value)
        Save().scaleTrackButton= value
        WoWTools_TokensMixin.TrackButton:set_scale()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
        return WoWTools_TokensMixin.TrackButton:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        WoWTools_TokensMixin.TrackButton:set_strata()
    end)

--物品
    --root:CreateDivider()
    --WoWTools_TokensMixin:MenuList_Item(WoWTools_TokensMixin.TrackButton, root)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_TokensMixin.addName})
end







function WoWTools_TokensMixin:Init_TrackButton_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end