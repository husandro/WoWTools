
--实时玩家当前坐标

local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end



local btn


local function Init()
    if not Save().ShowPlayerXY then
        return
    end

    btn= WoWTools_ButtonMixin:Cbtn(nil, {
        atlas=WoWTools_DataMixin.Icon.Player:match('|A:(.-):'),
        --size=14,
        name='WoWTools_PlayerXY_Button',
        isMask=true,
    })





    btn:SetMovable(true)
    btn:RegisterForDrag("RightButton")
    btn:SetClampedToScreen(true)
    btn:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    btn:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().PlayerXYPoint={self:GetPoint(1)}
            Save().PlayerXYPoint[2]=nil
        end
    end)
    btn:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
     end)
    btn:SetScript("OnMouseUp", ResetCursor)
    btn:SetScript('OnClick', function(self, d)
        if IsModifierKeyDown() then
            return
        end
        MenuUtil.CreateContextMenu(self, function(...)
            WoWTools_WorldMapMixin:Init_PlayerXY_Option_Menu(...)
        end)
    end)

    function btn:set_tooltip()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_DataMixin.Icon.Player..' XY')
        GameTooltip:AddLine(' ')

        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)

        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)

        GameTooltip:Show()
    end

    btn:SetScript("OnEnter", function(self)
        self:set_tooltip()
    end)
    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
        ResetCursor()
    end)



    btn.Text=WoWTools_LabelMixin:Create(btn, {size=Save().PlayerXYSize, color=true})

    btn:SetScript("OnHide", function(self)
        self.elapsed= nil
    end)

    btn:SetScript("OnUpdate", function(self, elapsed)
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

    function btn:Settings()
        local isShow= Save().ShowPlayerXY
        self:SetShown(isShow)

        if not isShow then
            return
        end

        self:SetScale(Save().PlayerXY_Scale or 1)
        self:ClearAllPoints()
        if not Save().PlayerXYPoint then
            self:SetPoint('BOTTOMRIGHT', WorldMapFrame, 'TOPRIGHT',-50, 5)
        else
            self:SetPoint(Save().PlayerXYPoint[1], UIParent, Save().PlayerXYPoint[3], Save().PlayerXYPoint[4], Save().PlayerXYPoint[5])
        end

        self.Text:ClearAllPoints()
        if Save().PlayerXY_Text_toLeft then
            self.Text:SetPoint('RIGHT', btn, "LEFT")
        else
            self.Text:SetPoint('LEFT', btn, "RIGHT")
        end

        self:SetFrameStrata(Save().PlayerXY_Strata or 'HIGH')

        local size= Save().PlayerXY_Size or 12
        self:SetSize(size, size)
    end

    btn:Settings()

    Init=function()
         btn:Settings()
    end
end












function WoWTools_WorldMapMixin:Init_XY_Player()
    Init()
end