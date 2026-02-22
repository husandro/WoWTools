
--实时玩家当前坐标

local function Save()
    return WoWToolsSave['Plus_WorldMap'].PlayerXY
end




--实时玩家当前坐标，选项
local function Init_Menu(self, root)
    local sub

    sub= root:CreateButton(
        '|A:Waypoint-MapPin-ChatIcon:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '分享' or SOCIAL_SHARE_TEXT),
    function()
        WoWTools_WorldMapMixin:SendPlayerPoint()--发送玩家位置
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '分享链接至聊天栏' or CLUB_FINDER_LINK_POST_IN_CHAT)

        local mapID= C_Map.GetBestMapForUnit("player")
        local can= mapID and C_Map.CanSetUserWaypointOnMap(mapID)
        if not can then
            tooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '当前地图不能标记' or "Cannot set waypoints on this map"))
        end
    end)

    sub=root:CreateButton(
        '|A:dressingroom-button-appearancelist-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT),
    function()
        WoWTools_TooltipMixin:Show_URL(nil, nil, nil, self.Text:GetText())
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(self.Text:GetText())
    end)

    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name= WoWTools_WorldMapMixin.addName, name2= '|A:poi-islands-table:0:0|a'..(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)})




--Text Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().textY or -2
        end, setValue=function(value)
            Save().textY= value
            self:Settings()
        end,
        name= 'Y',
        minValue=-23,
        maxValue=23,
        step=1,
        bit=nil,
    })



--延迟容限
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().elapsed or 0.3
        end, setValue=function(value)
            Save().elapsed= value
            self:Settings()
        end,
        name= WoWTools_DataMixin.onlyChinese and '延迟' or LAG_TOLERANCE,
        minValue=0.1,
        maxValue=0.5,
        step=0.01,
        bit='%.2f',
    })

--图像大小
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().size or 23
        end, setValue=function(value)
            Save().size= value
            self:Settings()
        end,
        name= WoWTools_DataMixin.Icon.Player,
        minValue=6,
        maxValue=72,
        step=1,
        bit=nil,
    })
    sub:CreateSpacer()

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
    function()
        return not Save().toLeft
    end, function()
        Save().toLeft= not Save().toLeft and true or nil
        self:Settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().strata= data
        self:Settings()
    end)

--Background
    WoWTools_MenuMixin:BgAplha(sub,
    function()
        return Save().bgAlpha or 0.5
    end, function(value)
        Save().bgAlpha= value
        self:Settings()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        self:Settings()
    end)

--重置数据
    sub:CreateDivider()
    sub:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '重置' or RESET),
    function()
        WoWToolsSave['Plus_WorldMap'].PlayerXY={--实时玩家当前坐标
            textY=-2,
        }
        self:Settings()
        return MenuResponse.Refresh
    end)
end















local function Init()
    if Save().disabled then
        return
    end

    local btn= CreateFrame('DropdownButton', 'WoWToolsPlayerXYButton', UIParent, 'WoWToolsMenu2Template')
    btn:Hide()

    btn.Portrait= btn:CreateTexture(nil, 'BORDER')
    btn.Portrait:SetAllPoints()

    function btn:set_texture()
        SetPortraitTexture(self.Portrait, 'player')--图像
    end


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
            Save().point={self:GetPoint(1)}
            Save().point[2]=nil
        end
    end)
    btn:SetupMenu(Init_Menu)
    btn:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
            self:CloseMenu()
        end
     end)
    btn:SetScript("OnMouseUp", ResetCursor)


    function btn:tooltip(tooltip)
        GameTooltip_SetTitle(tooltip, WoWTools_DataMixin.Icon.Player..' XY'..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
    end
    btn:SetScript("OnLeave", function(self)
        WoWToolsButton_OnLeave(self)
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



    btn:SetScript('OnShow', function(self)
        self:RegisterEvent('PORTRAITS_UPDATED')
        self:set_texture()
    end)
    btn:SetScript('OnHide', function(self)
        self:UnregisterEvent('PORTRAITS_UPDATED')
    end)
    function btn:set_shown()
        self:SetShown(WoWTools_WorldMapMixin:GetPlayerXY() and not Save().disabled)
    end

    btn:SetScript('OnEvent', function(self, event)
        if event=='PORTRAITS_UPDATED' then
            self:set_texture()
        else
            self:set_shown()
        end
    end)

    function btn:Settings()
--大小
        self:SetScale(Save().scale or 1)
--位置
        self:ClearAllPoints()
        local p= Save().point
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])

        elseif WoWTools_DataMixin.Player.husandro then
            self:SetPoint('BOTTOMLEFT', PlayerFrame, 'TOP', -15, -4)
        else
            self:SetPoint('CENTER', 100, -100)
        end
--Strata
        self:SetFrameStrata(Save().strata or 'MEDIUM')
--按钮，大小
        local size= Save().size or 23
        self:SetSize(size, size)
--Text 设置
        self.Text:ClearAllPoints()
        if Save().toLeft then
            self.Text:SetPoint('RIGHT', btn, "LEFT", 0, Save().textY or -2)
            self.Text:SetJustifyH('RIGHT')
        else
            self.Text:SetPoint('LEFT', btn, "RIGHT", 0, Save().textY or -2)
            self.Text:SetJustifyH('LEFT')
        end
--Background
        self.Bg:SetColorTexture(0, 0, 0, Save().bgAlpha or 0.5)
--延迟容限
        self.time= Save().elapsed or 0.3

        self:UnregisterAllEvents()
        if not Save().disabled then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
        end
        self:set_shown()
    end




    btn.elapsed= 1
    btn.time= 0.3
    btn:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > self.time then
            self.elapsed = 0
            local x, y= WoWTools_WorldMapMixin:GetPlayerXY()--玩家当前位置
            if x and y then
                self.Text:SetText(x.. ' '..y)
            else
                self.Text:SetText('')
            end
        end
    end)


    btn:Settings()
    if not btn.Portrait:GetTexture() then
        C_Timer.After(2, function()
            SetPortraitTexture(btn.Portrait, 'player')--图像
        end)
    end

    Init=function()
        _G['WoWToolsPlayerXYButton']:Settings()
    end
end












function WoWTools_WorldMapMixin:Init_XY_Player()
    Init()
end