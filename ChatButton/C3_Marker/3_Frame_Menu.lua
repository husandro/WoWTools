
local function Save()
    return WoWToolsSave['ChatButton_Markers'] or {}
end








--队伍标记工具, 选项，菜单
local function Init(self, root)
    local frame= _G['WoWToolsChatButtonMarkersFrame']

    if not frame or WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end
    local sub,sub2

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


--打开选项，信号系统
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '信号系统' or PING_SYSTEM_LABEL,
    function()
        if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.PINGSYSTEM_CATEGORY_ID)--Blizzard_SettingsDefinitions_Frame/PingSystem.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or SETTINGS_TITLE)
    end)

--打开选项，队伍标记
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '队伍标记' or BINDING_HEADER_RAID_TARGET,
    function()
        if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.KEYBINDINGS_CATEGORY_ID, BINDING_HEADER_RAID_TARGET)--Blizzard_SettingsDefinitions_Frame/PingSystem.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or SETTINGS_TITLE)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)
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
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
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
    WoWTools_MenuMixin:BgAplha(root,
    function()
        return Save().MakerFrameBgAlpha or 0.5
    end, function(value)
        Save().MakerFrameBgAlpha=value
        frame:set_background()
    end)




--重置位置
    WoWTools_MenuMixin:RestPoint(self, root, Save().markersFramePoint, function()
        Save().markersFramePoint=nil
        frame:ClearAllPoints()
        frame:Init_Set_Frame()
        print(
            WoWTools_MarkerMixin.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
        )
    end)

    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, nil)
end














function WoWTools_MarkerMixin:Init_MarkerTools_Menu(frame, root)
    Init(frame, root)
end

