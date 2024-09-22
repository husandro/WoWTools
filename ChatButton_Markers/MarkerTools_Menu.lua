local e=select(2, ...)
local function Save()
    return WoWTools_MarkerMixin.Save
end









--队伍标记工具, 选项，菜单
function WoWTools_MarkerMixin:Init_MarkerTools_Menu(root)
    if not self.MakerFrame or WoWTools_MenuMixin:CheckInCombat(root) then
        return
    end

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

    WoWTools_MenuMixin:Scale(root, function()
        return Save().markersScale
    end, function(value)
        Save().markersScale= value
        local btn= _G['WoWTools_MarkerFrame_Move_Button']
        if btn then
            btn:set_scale()
        end
    end)

    --重置位置
    root:CreateDivider()
    WoWTools_MenuMixin:RestPoint(root, Save().markersFramePoint and self.MakerFrame:CanChangeAttribute(), function()
        Save().markersFramePoint=nil
        self.MakerFrame:ClearAllPoints()
        self.MakerFrame:Init_Set_Frame()
        print(e.addName, self.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
    end)
end





