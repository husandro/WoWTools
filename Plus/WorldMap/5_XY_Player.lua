
--实时玩家当前坐标

local function Save()
    return  WoWToolsSave['Plus_WorldMap']
end





local function Init()
    if not Save().ShowPlayerXY then
        return
    end

    local btn= CreateFrame('Button', 'WoWToolsPlayerXYButton', UIParent, 'WoWToolsButtonTemplate')
    btn:SetNormalAtlas(WoWTools_DataMixin.Icon.Player:match('|A:(.-):'))
    WoWTools_ButtonMixin:AddMask(btn, nil, nil, 'UI-HUD-UnitFrame-Player-Portrait-Mask')

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

    function btn:tootip()
        GameTooltip_SetTitle(GameTooltip, WoWTools_DataMixin.Icon.Player..' XY'..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
    end
    btn:SetScript("OnLeave", function(self)
        WoWToolsButton_OnEnter(self)
        ResetCursor()
    end)


--Text
    btn.Text= btn:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal')
    btn.Text:SetShadowOffset(1, -1)
    WoWTools_ColorMixin:SetLabelColor(btn.Text)

--Background
    btn.Bg= btn:CreateTexture(nil, "BACKGROUND")
    btn.Bg:SetPoint('TOPLEFT', btn.Text, -1.5, 1)
    btn.Bg:SetPoint('BOTTOMRIGHT', btn.Text, 1, -1)

    function btn:Settings()
        local isShow= Save().ShowPlayerXY
        self:SetShown(isShow)

        if not isShow then
            return
        end
--大小
        self:SetScale(Save().PlayerXY_Scale or 1)
--位置
        self:ClearAllPoints()
        local p= Save().PlayerXYPoint
        if not p then
            self:Setpoint('CENTER', 100, -100)

        elseif WoWTools_DataMixin.Player.husandro then
            self:SetPoint('BOTTOM', PlayerFrame, 'TOP')

        else
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        end
--Strata
        self:SetFrameStrata(Save().PlayerXY_Strata or 'HIGH')
--按钮，大小
        local size= Save().PlayerXY_Size or 23
        self:SetSize(size, size)
--Text 设置
        self.Text:ClearAllPoints()
        if Save().PlayerXY_Text_toLeft then
            self.Text:SetPoint('RIGHT', btn, "LEFT", 0, Save().PlayerXY_TextY or -3)
            self.Text:SetJustifyH('RIGHT')
        else
            self.Text:SetPoint('LEFT', btn, "RIGHT", 0, Save().PlayerXY_TextY or -3)
            self.Text:SetJustifyH('LEFT')
        end
--Background
        self.Bg:SetColorTexture(0, 0, 0, Save().PlayerXY_BGAlpha or 0.5)
--延迟容限
        self.SElapsed= Save().PlayerXY_Elapsed or 0.3
    end
    btn:Settings()


    local Elapsed= 1
    btn:SetScript("OnUpdate", function(self, elapsed)
        Elapsed = Elapsed + elapsed
        if Elapsed > self.SElapsed then
            Elapsed = 0
            local x, y= WoWTools_WorldMapMixin:GetPlayerXY()--玩家当前位置
            if x and y then
                self.Text:SetText(x.. ' '..y)
            else
                self.Text:SetText('')
            end
        end
    end)

    Init=function()
        _G['WoWToolsPlayerXYButton']:Settings()
    end
end












function WoWTools_WorldMapMixin:Init_XY_Player()
    Init()
end