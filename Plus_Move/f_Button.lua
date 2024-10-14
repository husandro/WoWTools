--创建, 一个移动按钮
local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end








--####
--缩放
--[[####
local function set_Zoom_Frame(frame, tab)--notZoom, zeroAlpha, name, point=left)--放大
    if frame.ResizeButton or tab.notZoom or Save().disabledZoom then --or not tab.name or _G['MoveZoomInButtonPer'..tab.name] or _G['WoWToolsResizeButton'..tab.name] then
        return
    end

    frame.ResizeButton= WoWTools_ButtonMixin:Cbtn(frame, {atlas='UI-HUD-Minimap-Zoom-In', size={18,18}, name='MoveZoomInButtonPer'..tab.name})
    WoWTools_ColorMixin:SetLabelTexture(frame.ResizeButton, {type='Button'})

    frame.ResizeButton.name= tab.name
    frame.ResizeButton.target= frame
    frame.ResizeButton.alpha= tab.zeroAlpha and 0 or 0.2
    frame.ResizeButton:SetFrameLevel(frame.ResizeButton:GetFrameLevel() +5)

    if frame.moveButton then
        frame.ResizeButton:SetPoint('RIGHT', frame.moveButton, 'LEFT')

    elseif tab.point=='left' then
        frame.ResizeButton:SetPoint('RIGHT', frame, 'LEFT')

    elseif frame.Header then
        frame.ResizeButton:SetPoint('LEFT')

    elseif frame.TitleContainer then
        frame.ResizeButton:SetPoint('LEFT', 35,-2)

    elseif frame.SpellButtonContainer then
        frame.ResizeButton:SetPoint('BOTTOM', frame.SpellButtonContainer, 'TOP', -20,0)

    elseif frame.BorderFrame and frame.BorderFrame.TitleContainer then
        frame.ResizeButton:SetPoint('LEFT', 35,-2)

    else
        frame.ResizeButton:SetPoint('BOTTOMLEFT', frame, 'TOPLEFT')
    end

    frame.ResizeButton:SetScript('OnClick', function(self, d)
        if UnitAffectingCombat('player') then
            return
        end
        local n= Save().scale[self.name] or 1
        if d=='LeftButton' then
            n= n+ 0.05
        elseif d=='RightButton' then
            n= n- 0.05
        end
        n= n>3 and 3 or n
        n= n< 0.5 and 0.5 or n
        Save().scale[self.name]= n
        self.target:SetScale(n)
        self:set_Tooltips()
    end)

    frame.ResizeButton:SetScript('OnMouseWheel', function(self,d)
        if UnitAffectingCombat('player') then
            return
        end
        local n= Save().scale[self.name] or 1
        if d==-1 then
            n= n+ 0.05
        elseif d==1 then
            n= n- 0.05
        end
        n= n>4 and 4 or n
        n= n< 0.4 and 0.4 or n
        Save().scale[self.name]= n
        self.target:SetScale(n)
        self:set_Tooltips()
    end)

    frame.ResizeButton:SetAlpha(frame.ResizeButton.alpha)
    frame.ResizeButton:SetScript("OnLeave", function(self)
        e.tips:Hide()
        self:SetAlpha(self.alpha)
    end)
    function frame.ResizeButton:set_Tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MoveMixin.addName)
        e.tips:AddLine(self.name)
        e.tips:AddLine(' ')
        local col= UnitAffectingCombat('player') and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩放' or UI_SCALE).. ' |cnGREEN_FONT_COLOR:'..(format('%.2f', Save().scale[self.name] or 1)), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(col..(e.onlyChinese and '放大' or ZOOM_IN), e.Icon.left)
        e.tips:AddDoubleLine(col..(e.onlyChinese and '缩小' or ZOOM_OUT), e.Icon.right)
        e.tips:Show()
    end
    frame.ResizeButton:SetScript("OnEnter",function(self)
        self:set_Tooltips()
        self:SetAlpha(1)
    end)

    if Save().scale[tab.name] and Save().scale[tab.name]~=1 then
        frame:SetScale(Save().scale[tab.name])
    end
    if tab.zeroAlpha then
        frame:HookScript('OnEnter', function(self)
            self.ResizeButton:SetAlpha(1)
            if self.moveButton then
                self.moveButton:SetAlpha(1)
            end
        end)
        frame:HookScript('OnLeave', function(self)
            self.ResizeButton:SetAlpha(0)
            if self.moveButton then
                self.moveButton:SetAlpha(0)
            end
        end)
    end
end]]






local function Create_Button(frame)
    local btn= WoWTools_ButtonMixin:Cbtn(frame, {texture='Interface\\Cursor\\UI-Cursor-Move', size={22,22}})
    btn:SetPoint('BOTTOM', frame, 'TOP')
    btn:SetFrameLevel(9999)
    btn:SetScript("OnEnter",function(self)
        self:SetAlpha(1)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, WoWTools_MoveMixin.addName)
        e.tips:AddLine(format('|cffff00ff%s|r', self:GetParent():GetName() or ''))
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, self.click=='RightButton' and e.Icon.right or e.Icon.left)
        e.tips:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        ResetCursor()
        e.tips:Hide()
        self:SetAlpha(self.alpha or 0.2)
    end)

    return btn
end




--(frame, {frame=nil, save=true, zeroAlpha=nil, notZoom=nil})
function WoWTools_MoveMixin:CreateButton(frame, tab)
    if not frame or Save().disabledMove or frame.moveButton then
        return
    end

    tab= tab or {}
    local name= tab.name or frame:GetName()

    if not name then
        return name
    end
    local alpha= tab.alpha or 0.2
    frame.moveButton= Create_Button(frame)
    frame.moveButton.alpha= alpha
    frame.moveButton:SetAlpha(alpha)

    tab.frame= frame
    tab.name= name
    WoWTools_MoveMixin:Setup(frame.moveButton, tab)
end