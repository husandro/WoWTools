--目标，移动，速度


local function Save()
    return WoWToolsSave['Plus_Attributes'] or {}
end




local btn


local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

--右
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '右' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT,
    function()
        return not Save().targetMoveTextToLeft
    end, function()
        Save().targetMoveTextToLeft= not Save().targetMoveTextToLeft and true or nil
        btn:Settings()
    end)

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '名字' or NAME,
    function()
        return not Save().disableTargetName
    end, function()
        Save().disableTargetName= not Save().disableTargetName and true or nil
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, root, function()
        return Save().scaleTargetMove or 1
    end, function(value)
        Save().scaleTargetMove= value
        btn:Settings()
    end)

--FrameStrata
    WoWTools_MenuMixin:FrameStrata(self, root, function(data)
        return btn:GetFrameStrata()==data
    end, function(data)
        Save().strataTargetMove= data
        btn:Settings()
    end)


--重置位置
    WoWTools_MenuMixin:RestPoint(self, root, Save().targetMovePoint, function()
        Save().targetMovePoint=nil
        btn:Settings()
        return MenuResponse.Open
    end)

--选项
    root:CreateDivider()
    WoWTools_AttributesMixin:Open_Options(root)

end









local function Init()
    btn= WoWTools_ButtonMixin:Cbtn(UIParent, {
        isType2=true,
        size=23,
        name='WoWToolsAttributesTargetMoveButton'
    })
    btn:Hide()

    btn.Text= WoWTools_LabelMixin:Create(btn)
    btn.nameText=WoWTools_LabelMixin:Create(btn)


    function btn:Is_Exists()
        return UnitExists('target') and not UnitIsUnit('player', 'target')
    end

    function btn:Settings()
        self:ClearAllPoints()
        local p= Save().targetMovePoint
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        elseif _G['WoWToolsAttributesButton'] then
            self:SetPoint('BOTTOM', _G['WoWToolsAttributesButton'], 'TOP', 0, 2)
        else
            self:SetPoint('CENTER',100, -100)
        end

        self.Text:ClearAllPoints()
        self.nameText:ClearAllPoints()
        if Save().targetMoveTextToLeft then
            self.Text:SetPoint('RIGHT', self, 'LEFT')
            self.nameText:SetPoint('LEFT', self, 'RIGHT', -2, 0)
        else
            self.Text:SetPoint('LEFT', self, 'RIGHT', -2, 0)
            self.nameText:SetPoint('RIGHT', self, 'LEFT', 2, 0)
        end


        if Save().showTargetSpeed then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
            self:SetShown(self:Is_Exists())
        else
            self:UnregisterEvent('PLAYER_TARGET_CHANGED')
            self:SetShown(false)
        end

        self:SetFrameStrata(Save().strataTargetMove or 'MEDIUM')
        self:SetScale(Save().scaleTargetMove or 1)
    end

    function btn:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_AttributesMixin.addName, '|A:common-icon-rotateright:0:0|a'..(WoWTools_DataMixin.onlyChinese and '目标移动' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TARGET, NPE_MOVE)))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end


    btn:RegisterForDrag("RightButton")
    btn:SetMovable(true)
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
            Save().targetMovePoint={self:GetPoint(1)}
            Save().targetMovePoint[2]=nil
        end
    end)

    btn:SetScript('OnMouseDown', function(self)
        if not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
        self:set_tooltip()
    end)

    btn:SetScript('OnLeave', function()
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltip()
    end)

    btn:SetScript('OnEvent', function(self)
        SetPortraitTexture(self.texture, 'target')
        local exists= self:Is_Exists()
        local col= exists and RAID_CLASS_COLORS[select(2, UnitClass("target"))]--.colorStr
        if col then
            self.border:SetVertexColor(col.r, col.g, col.b)
            self.Text:SetTextColor(col.r, col.g, col.b)
            self.nameText:SetTextColor(col.r, col.g, col.b)
        end
        self.elapsed= nil
        self:SetShown(exists)
    end)
    btn:SetScript('OnHide', function(self)
        self.elapsed= nil
    end)
    btn:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3) +elapsed

        if self.elapsed< 0.3 then
            return
        end

        self.elapsed=0

        self.nameText:SetFormattedText(
            '%s%s',
            not WoWToolsSave['Plus_Attributes'].disableTargetName and GetUnitName('target', false) or '',
            WoWTools_MarkerMixin:GetIcon(nil, 'target')
        )

        local value= GetUnitSpeed('target') or 0
        if value==0 then
            self.Text:SetText('|cff8282820')
        else
            self.Text:SetFormattedText(
                '%.0f',
                (value)*100/BASE_MOVEMENT_SPEED
            )
        end
    end)




    btn:Settings()
end













function WoWTools_AttributesMixin:Init_Target_Speed()
    if btn then
        btn:Settings()
        return
    end
    if not WoWToolsSave['Plus_Attributes'].showTargetSpeed then
        return
    end

    Init()
end

function WoWTools_AttributesMixin:Target_Speed_Menu(...)
    Init_Menu(...)
end