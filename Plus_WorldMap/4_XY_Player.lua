local e= select(2, ...)
--实时玩家当前坐标

local function Save()
    return WoWTools_WorldMapMixin.Save
end



local PlayerButton


local function Init()
    PlayerButton= WoWTools_ButtonMixin:Cbtn(nil, {
        atlas=e.Icon.player:match('|A:(.-):'),
        --size=14,
        name='WoWTools_PlayerXY_Button'
    })





    PlayerButton:SetMovable(true)
    PlayerButton:RegisterForDrag("RightButton")
    PlayerButton:SetClampedToScreen(true)
    PlayerButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    PlayerButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save().PlayerXYPoint={self:GetPoint(1)}
        Save().PlayerXYPoint[2]=nil
    end)
    PlayerButton:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
     end)
    PlayerButton:SetScript("OnMouseUp", ResetCursor)
    PlayerButton:SetScript('OnClick', function(self, d)
        if IsModifierKeyDown() then
            return
        end
        --if d=='RightButton' and not IsModifierKeyDown() then
            --WoWTools_WorldMapMixin:SendPlayerPoint()--发送玩家位置
        MenuUtil.CreateContextMenu(self, function(...)
            WoWTools_WorldMapMixin:Init_PlayerXY_Option_Menu(...)
        end)
    end)

    function PlayerButton:set_tooltip()
        e.tips:ClearLines()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.addName, e.Icon.player..' XY')
        e.tips:AddLine(' ')

        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)

        --[[local mapID= C_Map.GetBestMapForUnit("player")
        local can= mapID and C_Map.CanSetUserWaypointOnMap(mapID)
        e.tips:AddLine(
            e.Icon.right
            ..(can and '' or '|cnRED_FONT_COLOR:')
            ..(e.onlyChinese and '发送位置' or RESET_POSITION:gsub(RESET, SEND_LABEL))
            ..'|A:Waypoint-MapPin-ChatIcon:0:0|a'
        )]]
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)

        e.tips:Show()
    end

    PlayerButton:SetScript("OnEnter", PlayerButton.set_tooltip)
    PlayerButton:SetScript("OnLeave", function()
        e.tips:Hide()
        ResetCursor()
    end)



    PlayerButton.Text=WoWTools_LabelMixin:Create(PlayerButton, {size=Save().PlayerXYSize, color=true})
    

    PlayerButton:HookScript("OnUpdate", function (self, elapsed)
        self.elapsed = (self.elapsed or 0.3) + elapsed
        if self.elapsed > 0.3 then
            self.elapsed = 0
            local x, y= WoWTools_WorldMapMixin:GetPlayerXY()--玩家当前位置
            if x and y then
                self.Text:SetText(x.. ' '..y)
            else
                self.Text:SetText('')
            end
        end
    end)

    function PlayerButton:Settings()
        self:SetShown(Save().ShowPlayerXY)
        self:SetScale(Save().PlayerXY_Scale or 1)
        self:ClearAllPoints()
        if not Save().PlayerXYPoint then
            self:SetPoint('BOTTOMRIGHT', WorldMapFrame, 'TOPRIGHT',-50, 5)
        else
            self:SetPoint(Save().PlayerXYPoint[1], UIParent, Save().PlayerXYPoint[3], Save().PlayerXYPoint[4], Save().PlayerXYPoint[5])
        end

        self.Text:ClearAllPoints()
        if Save().PlayerXY_Text_toLeft then
            self.Text:SetPoint('RIGHT', PlayerButton, "LEFT")
        else
            self.Text:SetPoint('LEFT', PlayerButton, "RIGHT")
        end

        self:SetFrameStrata(Save().PlayerXY_Strata or 'HIGH')

        local size= Save().PlayerXY_Size or 12
        self:SetSize(size, size)
    end

    PlayerButton:Settings()
end












function WoWTools_WorldMapMixin:Init_XY_Player()
    if PlayerButton then
        PlayerButton:Settings()

    elseif self.Save.ShowPlayerXY then
        Init()
    end
end