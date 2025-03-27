
local function Save()
    return WoWToolsSave['ChatButton_Markers'] or {}
end








--队伍标记工具, 选项，菜单
local function Init(self, root)
    local frame= _G['WoWToolsChatButtonMarkersFrame']

    if not frame or WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end
    local sub

    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,
    function()
        return Save().showMakerFrameHotKey
    end, function()
        Save().showMakerFrameHotKey= not Save().showMakerFrameHotKey and true or nil
        
        frame:set_all_hotkey()--设置全部，快捷键
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '提示' or CHARACTER_CUSTOMIZATION_TUTORIAL_TITLE)
    end)

    --位于上方
    WoWTools_MenuMixin:ToTop(root, {
        name=nil,
        GetValue=function()
            return Save().H
        end,
        SetValue=function()
            Save().H = not Save().H and true or nil
            if frame then
                frame:set_button_point()
            end
        end,
        tooltip=false,
    })



--FrameStrata
    WoWTools_MenuMixin:FrameStrata(root, function(data)
            return frame:GetFrameStrata()==data
    end, function(data)
        Save().FrameStrata= data
        frame:set_frame_strata()
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
        frame:set_background()
    end)



--重置位置
    WoWTools_MenuMixin:RestPoint(self, root, Save().markersFramePoint, function()
        Save().markersFramePoint=nil
        frame:ClearAllPoints()
        frame:Init_Set_Frame()
        print(WoWTools_DataMixin.addName, self.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
    end)

    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, nil)
end














function WoWTools_MarkerMixin:Init_MarkerTools_Menu(frame, root)
    Init(frame, root)
end

