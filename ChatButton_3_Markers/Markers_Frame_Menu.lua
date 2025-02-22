local e=select(2, ...)
local function Save()
    return WoWTools_MarkerMixin.Save
end









--队伍标记工具, 选项，菜单
local function Init(self, root)
    if not self.MakerFrame or WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end
    local sub

    sub= root:CreateCheckbox(
        e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,
    function()
        return Save().showMakerFrameHotKey
    end, function()
        Save().showMakerFrameHotKey= not Save().showMakerFrameHotKey and true or nil
        self.MakerFrame:set_all_hotkey()--设置全部，快捷键
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '提示' or CHARACTER_CUSTOMIZATION_TUTORIAL_TITLE)
    end)

    --位于上方
    WoWTools_MenuMixin:ToTop(root, {
        name=nil,
        GetValue=function()
            return Save().H
        end,
        SetValue=function()
            Save().H = not Save().H and true or nil
            if self.MakerFrame then
                self.MakerFrame:set_button_point()
            end
        end,
        tooltip=false,
    })



--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
            return self.MakerFrame:GetFrameStrata()==data
    end, function(data)
        Save().FrameStrata= data
        self.MakerFrame:set_frame_strata()
    end)

    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().markersScale
    end, function(value)
        Save().markersScale= value
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_scale()
        end
    end)

--显示背景
    WoWTools_MenuMixin:ShowBackground(root,
    function()
        return Save().showMakerFrameBackground
    end, function()
        Save().showMakerFrameBackground= not Save().showMakerFrameBackground and true or nil
        self.MakerFrame:set_background()
    end)



--重置位置
    WoWTools_MenuMixin:RestPoint(self, root, Save().markersFramePoint, function()
        Save().markersFramePoint=nil
        self.MakerFrame:ClearAllPoints()
        self.MakerFrame:Init_Set_Frame()
        print(WoWTools_Mixin.addName, self.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
    end)

    root:CreateDivider()
    WoWTools_ChatButtonMixin:Open_SettingsPanel(root, nil)
end














function WoWTools_MarkerMixin:Init_MarkerTools_Menu(frame, root)
    Init(frame, root)
end

