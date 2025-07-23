
local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
end



function WoWTools_TextureMixin:SetColorTexture(object, tab)
    if object then
        tab= tab or {}
        tab.isColorTexture=true
        tab.type=object:GetObjectType()
        tab.alpha= tab.alpha or self.alpha or self.min or Save().alpha or 0.5
        WoWTools_ColorMixin:Setup(object, tab)
    end
end






--隐藏，材质
function WoWTools_TextureMixin:HideTexture(object)--, notClear)
    if object and object:IsObjectType('Texture') then
        object:SetTexture(0)
    end
end






--设置，颜色，透明度
function WoWTools_TextureMixin:SetAlphaColor(object, notAlpha, notColor, alphaORmin)
    if object then
        if alphaORmin==0 then
            object:SetAlpha(0)
            return
        end
        if not notColor then
            WoWTools_ColorMixin:Setup(object, {type=object:GetObjectType()})
        end
        if not notAlpha then
            if alphaORmin==true then
                object:SetAlpha(self.min or 0.5)
            else
                object:SetAlpha(alphaORmin or self.min or 0.5)
            end
        end
    end
end


















--隐藏, frame, 子材质
function WoWTools_TextureMixin:HideFrame(frame, tab)
    if not frame or not frame.GetRegions then
        return
    end

    tab= tab or {}
    tab.show= tab.show or {}

    if tab.isSub then
        local t
        for _, f in pairs({RematchFrame.LoadoutPanel:GetChildren()})do
            t= f:GetObjectType()
            if t=='Frame' or t=='Button' then
                self:HideFrame(f)
                if f.NineSlice then
                    self:SetNineSlice(f)
                end
            end
        end
    else
        if tab.index then
            local icon= select(tab.index, frame:GetRegions())
            if icon and icon:IsObjectType("Texture") then
                icon:SetTexture(0)
            end
        else
            for _, icon in pairs({frame:GetRegions()}) do
                if icon:IsObjectType("Texture") and not tab.show[icon] then
                    icon:SetTexture(0)
                end
            end
        end
    end
end

--透明度, 颜色, frame, 子材质
function WoWTools_TextureMixin:SetFrame(frame, tab)
    if not frame or not frame.GetRegions then
        return
    end
    tab=tab or {}

    local notColor= tab.notColor
    local alpha
    if not tab.notAlpha then
        alpha= tab.alpha or self.min
    end

    if tab.isSub then
        local t
        for _, f in pairs({RematchFrame.LoadoutPanel:GetChildren()})do
            t= f:GetObjectType()
            if t=='Frame' or t=='Button' then
                self:SetFrame(f, {alpha=alpha, notColor=notColor})
                if f.NineSlice then
                    self:SetNineSlice(f, alpha)
                end
            end
        end

    elseif tab and tab.index then
        local icon= select(tab.index, frame:GetRegions())
        if icon and icon:IsObjectType("Texture") then
             if not notColor then
                WoWTools_ColorMixin:Setup(icon, {type='Texture'})
            end
            if alpha then
                icon:SetAlpha(alpha)
            end
        end

    else
        local show= tab.show or {}
        for _, icon in pairs({frame:GetRegions()}) do
            if icon:IsObjectType("Texture") and not show[icon] then
                if not notColor then
                    WoWTools_ColorMixin:Setup(icon, {type='Texture'})
                end
                if alpha then
                    icon:SetAlpha(alpha)
                end
            end
        end
    end
end

--搜索框 set_SearchBox
function WoWTools_TextureMixin:SetEditBox(frame, tab)
    if not frame then-- or not frame.SearchBox then
        return
    end
    tab= tab or {}
    local alpha= tab.alpha or true

    if self.Left then
        self:SetAlphaColor(frame.Middle, nil, nil, alpha)
        self:SetAlphaColor(frame.Left, nil, nil, alpha)
        self:SetAlphaColor(frame.Right, nil, nil, alpha)
        self:SetAlphaColor(frame.Mid, nil, nil, alpha)
        local alpha2= type(alpha)=='number' and alpha<0 and alpha or true
        if frame.clearButton then
            self:SetAlphaColor(frame.clearButton.texture, nil, nil, alpha2)
        end
        self:SetAlphaColor(frame.searchIcon, nil, nil, alpha2)

    else
        self:SetFrame(frame, tab)
    end
end


--[[
NineSlice.lua
NineSlicePanelMixin
NineSlicePanelMixin:SetBorderColor(r, g, b, a)
NineSlicePanelMixin:SetCenterColor(r, g, b, a)
NineSlicePanelMixin:SetVertexColor(r, g, b, a)
local nineSliceSetup =
{
	{ pieceName = "TopLeftCorner", point = "TOPLEFT", fn = SetupCorner, },
	{ pieceName = "TopRightCorner", point = "TOPRIGHT", mirrorHorizontal = true, fn = SetupCorner, },
	{ pieceName = "BottomLeftCorner", point = "BOTTOMLEFT", mirrorVertical = true, fn = SetupCorner, },
	{ pieceName = "BottomRightCorner", point = "BOTTOMRIGHT", mirrorHorizontal = true, mirrorVertical = true, fn = SetupCorner, },
	{ pieceName = "TopEdge", point = "TOPLEFT", relativePoint = "TOPRIGHT", relativePieces = { "TopLeftCorner", "TopRightCorner" }, fn = SetupEdge, tileHorizontal = true },
	{ pieceName = "BottomEdge", point = "BOTTOMLEFT", relativePoint = "BOTTOMRIGHT", relativePieces = { "BottomLeftCorner", "BottomRightCorner" }, mirrorVertical = true, tileHorizontal = true, fn = SetupEdge, },
	{ pieceName = "LeftEdge", point = "TOPLEFT", relativePoint = "BOTTOMLEFT", relativePieces = { "TopLeftCorner", "BottomLeftCorner" }, tileVertical = true, fn = SetupEdge, },
	{ pieceName = "RightEdge", point = "TOPRIGHT", relativePoint = "BOTTOMRIGHT", relativePieces = { "TopRightCorner", "BottomRightCorner" }, mirrorHorizontal = true, tileVertical = true, fn = SetupEdge, },
	{ pieceName = "Center", fn = SetupCenter, },
};
local NineSliceTabs={
    'TopEdge',
    'BottomEdge',
    'LeftEdge',
    'RightEdge',
    'TopLeftCorner',
    'TopRightCorner',
    'BottomRightCorner',
    'BottomLeftCorner',--8

    'Center',
    'Background',
    'Bg',
}]]
function WoWTools_TextureMixin:SetNineSlice(frame, alpha, notBg)
    if frame and not frame.NineSlice then
        for _, t in pairs({frame:GetChildren()})do
            if t.NineSlice then
                frame= t
                break
            end
        end
    end

    if not frame or not frame.NineSlice then
        return
    end

    local col= WoWTools_DataMixin.Player.UseColor
    local r,g, b= col.r, col.g, col.b

    alpha= (alpha==nil and 0)
        or (type(alpha)=='number' and alpha)
        or self.min

    frame.NineSlice:SetBorderColor(r, g, b, alpha)
    frame.NineSlice:SetCenterColor(0, 0, 0, notBg and 0.5 or 0)
end

--function WoWTools_TextureMixin:SetNineSlice(frame, min, hide, notAlpha, notBg, isFind)
    --[[if not frame then
        return
    end

    local f= frame.NineSlice
    if not f and isFind then
        for _, t in pairs({frame:GetChildren()})do
            if t.NineSlice then
                f= t.NineSlice
                break
            end
        end
    end

    if not f then
        if frame.TopEdge or not isFind then
            f=frame
        else
            return
        end
    end

    local alpha= min and (type(min)=='number' and min or self.min) or 0.3
    for index, text in pairs(NineSliceTabs) do
        if hide then
            self:HideTexture(f[text])
        else
            self:SetAlphaColor(f[text], notAlpha, nil, alpha)
        end
        if notBg and index==8 then
            break
        end
    end]]


--设置，滚动条，颜色
function WoWTools_TextureMixin:SetScrollBar(bar, isAutoHide)
    bar= bar and bar.ScrollBar or bar
    if not bar or not bar.Track then
        return
    end

    self:SetFrame(bar.Back, {alpha=0.8})
    self:SetFrame(bar.Forward, {alpha=0.8})
    self:SetFrame(bar.Track, {alpha=0.8})
    self:SetFrame(bar.Track.Thumb, {alpha=0.8})
    
    self:SetAlphaColor(bar.Backplate, nil, nil, 0)
    self:SetAlphaColor(bar.Background, nil, nil, 0.5)

    if isAutoHide then
        bar:SetHideIfUnscrollable(true)
    end
end
    --[[if not bar:GetParent():IsProtected() then
        bar:SetHideIfUnscrollable(true)
        --bar.hideIfUnscrollable =true
    else
        bar.scrollBarHideIfUnscrollable=true
    end]]

    --bar.scrollBarHideIfUnscrollable=true
    --[[if bar.SetHideIfUnscrollable and not tab.notHide then--货币转移，出错, 这鸟BUG
       bar:SetHideIfUnscrollable(true)
    end]]



--Slider
function WoWTools_TextureMixin:SetSlider(frame)
    if not frame or not frame.Slider then
        return
    end

    local thumb= frame.Slider.Slider and frame.Slider.Slider.Thumb or frame.Slider.Thumb
    self:SetAlphaColor(thumb, true)

    local back= frame.Slider.Back or frame.Back
    if back then
        for _, icon in pairs({back:GetRegions()}) do
            if icon:IsObjectType("Texture") then
                WoWTools_ColorMixin:Setup(icon, {type='Texture'})
            end
        end
    end
    local forward= frame.Slider.Forward or frame.Forward
    if forward then
        for _, icon in pairs({forward:GetRegions()}) do
            if icon:IsObjectType("Texture") then
                WoWTools_ColorMixin:Setup(icon, {type='Texture'})
            end
        end
    end

    local middle= frame.Slider.Slider and frame.Slider.Slider.Middle or frame.Slider.Middle
    local right= frame.Slider.Slider and frame.Slider.Slider.Right or frame.Slider.Right
    local left= frame.Slider.Slider and frame.Slider.Slider.Left or frame.Slider.Left
    WoWTools_ColorMixin:Setup(middle, {type='Texture'})
    WoWTools_ColorMixin:Setup(right, {type='Texture'})
    WoWTools_ColorMixin:Setup(left, {type='Texture'})
end


--设置，按钮
function WoWTools_TextureMixin:SetButton(btn, tab)
    if not btn then
        return
    end
    tab= tab or {}
    tab.alpha=tab.alpha or 0.5
    if not tab.show then
        tab.show= {}
        local p= btn:GetPushedTexture()
        local d= btn:GetDisabledTexture()
        local h= btn:GetHighlightTexture()
        if p then tab.show[p]=true end
        if d then tab.show[d]=true end
        if h then tab.show[h]=true end
    end
    self:SetFrame(btn, tab)

    self:HideTexture(btn.Ring)
end


--下拉，菜单 set_Menu
function WoWTools_TextureMixin:SetMenu(frame)
    if frame then
        self:SetAlphaColor(frame.Background, nil, nil, 0.3)
        self:SetAlphaColor(frame.Arrow, nil, nil, 0.7)

        WoWTools_ColorMixin:Setup(frame.Text, {type='FontString'})
    end
end
    --[[if frame.Arrow and frame.Background and frame.Text then
        self:SetAlphaColor(frame.Arrow, nil, nil, 0.7)

        frame.Text:ClearAllPoints()
        frame.Text:SetPoint('RIGHT', frame.Arrow, 'LEFT', 1, 3.5)
        frame.Text:SetJustifyH('RIGHT')

        frame.Background:SetTexture(0)
        frame.Background:SetColorTexture(0,0,0, 0.3)

        frame.Background:ClearAllPoints()
        frame.Background:SetPoint('TOPLEFT', frame.Text, -2, 2)
        frame.Background:SetPoint('BOTTOMRIGHT', frame.Text, 4, -2)]]




--[[TabSystem 
function WoWTools_TextureMixin:SetTabSystem(frame)--TabSystemOwner.lua
    if not frame or not frame.GetTabSet then
        return
    end
    for _, tabID in pairs(frame:GetTabSet() or {}) do
        self:SetTabButton(frame:GetTabButton(tabID))
    end
end
--TabSystemOwnerMixin TabSystem
]]

--PanelTemplates_TabResize(frame, frame:GetParent().tabPadding or 0 , nil, frame:GetParent().minTabWidth, frame:GetParent().maxTabWidth)
--hooksecurefunc(TabSystemButtonMixin, 'Init', function(self)
    
function WoWTools_TextureMixin:SetTabButton(frame, alpha)--TabSystemOwner.lua
    if not frame then
        return
    end
    alpha= alpha or self.tabAlpha
    if frame.GetTabSet then
        for _, tabID in pairs(frame:GetTabSet()) do
            local btn= frame:GetTabButton(tabID)
            if btn then
                self:SetFrame(btn, {alpha=alpha})
                if btn.Text then
                    btn.Text:SetShadowOffset(1, -1)
                end
            end
        end
    else
        self:SetFrame(frame, {alpha=alpha})
        if frame.Text then
            frame.Text:SetShadowOffset(1, -1)
        end
    end
end


function WoWTools_TextureMixin:SetInset(frame, alphaORmin)
    if not frame then
        return
    end
    self:SetAlphaColor(frame.InsetBorderLeft, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.InsetBorderBottom, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.InsetBorderRight, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.InsetBorderTop, nil, nil, alphaORmin)

    self:SetAlphaColor(frame.InsetBorderTopRight, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.InsetBorderTopLeft, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.InsetBorderBottomRight, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.InsetBorderBottomLeft, nil, nil, alphaORmin)


    self:SetAlphaColor(frame.LeftBorder, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.RightBorder, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.TopBorder, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.BottomBorder, nil, nil, alphaORmin)

    self:SetAlphaColor(frame.TopRightCorner, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.TopLeftCorner, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.BotRightCorner, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.BotLeftCorner, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.BottomRightCorner, nil, nil, alphaORmin)
    self:SetAlphaColor(frame.BottomLeftCorner, nil, nil, alphaORmin)

end




--IconSelectorPopupFrameTemplateMixin
function WoWTools_TextureMixin:SetIconSelectFrame(frame)
    if not frame then
        return
    end

    local border= frame.BorderBox
    if border then
        self:SetFrame(border)
        self:SetMenu(border.IconTypeDropdown)
        self:SetEditBox(border.IconSelectorEditBox)

        --[[self:SetFrame(border.SelectedIconArea.SelectedIconButton, {show={
            [border.SelectedIconArea.SelectedIconButton.Icon]=true,
            [border.SelectedIconArea.SelectedIconButton.Highlight]=true,
        }})]]
        self:HideFrame(border.SelectedIconArea.SelectedIconButton, {index=1})
        WoWTools_ButtonMixin:AddMask(border.SelectedIconArea.SelectedIconButton, nil, border.SelectedIconArea.SelectedIconButton.Icon)

        border.IconSelectionText:SetText(
            '|A:communities-icon-addchannelplus:0:0|a|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '将一个图标拖曳至此处来显示' or ICON_SELECTION_DRAG)
        )

--清除，焦点
        frame:HookScript('OnShow', function(f)
            if f.BorderBox.IconSelectorEditBox:HasFocus() then
                f.BorderBox.IconSelectorEditBox:ClearFocus()
            end
        end)
    end

    self:SetScrollBar(frame.IconSelector)

    if frame.DepositSettingsMenu then--银行
        self:SetFrame(frame.DepositSettingsMenu)
        self:SetMenu(frame.DepositSettingsMenu.ExpansionFilterDropdown)
    end
    if frame.BG then
        frame.BG:SetTexture(0)
        frame.BG:SetColorTexture(0,0,0,1)
    end
end




local function set_frame(frame)
    if frame then
        WoWTools_TextureMixin:HideFrame(frame)
        if frame.NineSlice then
            frame.NineSlice:SetVertexColor(0,0,0,0)
        end
    end
end

--[[
frames={...},
isChildren=true,
bg={..} or true,
]]
function WoWTools_TextureMixin:SetAllFrames(frame, tab)
    tab= tab or {}

--自定义
    local frames= tab.frames
    local isChildren= tab.isChildren
    local bg= tab.bg

    local col= WoWTools_DataMixin.Player.UseColor
    local r,g, b= col.r, col.g, col.b
    local name= frame:GetName()

    if not name then
        return
    end

    self:HideFrame(frame)
    if frame.NineSlice then
        frame.NineSlice:SetBorderColor(r, g, b, 0.3)
        frame.NineSlice:SetCenterColor(0,0,0,0)
    end
--Header
    set_frame(frame.Header)

--CloseButton
    local clearButton= frame.ClosePanelButton or frame.CloseButton or _G[name..'CloseButton']
    self:SetButton(clearButton)

--Inset
    set_frame(frame.Inset or _G[name..'Inset'])

--CostFrame
    set_frame(frame.CostFrame or _G[name..'CostFrame'])

--moneyInset
    local moneyInset= _G[name..'MoneyInset']
    if moneyInset then
        set_frame(moneyInset)
        self:HideFrame(_G[name..'MoneyBg'])
    end

--自定义
--frames
    if frames then
        for _, f in pairs(tab.frames) do
            set_frame(f)
        end
    end

--isChildren
    if isChildren then
        for _, f in pairs({frame:GetChildren()})do
            if f:IsObjectType('Frame') then
                set_frame(f)
            end
        end
    end

--Bg
    if bg then
        self:Init_BGMenu_Frame(frame,
            bg==true
            and {
                isNewButton= not (frame.PortraitButton or frame.PortraitContainer) and clearButton,
            }
            or bg
        )
    end
end
--[[function WoWTools_TextureMixin:SetUIFrame(frame)
    --self:SetAlphaColor(frame.TitleContainer, nil, nil, true)
    self:SetNineSlice(frame)
    self:SetAlphaColor(frame:GetName()..'Bg', nil, nil, true)
end]]




--公会银行就用这个 BaseBasicFrameTemplate
function WoWTools_TextureMixin:SetBaseFrame(frame, alpha)
    if not frame or not frame.TopLeftCorner then
        return
    end

    alpha= alpha or self.min or 0.5

--OVERLAY
    self:SetAlphaColor(frame.TopLeftCorner, nil, nil, alpha)
    self:SetAlphaColor(frame.TopRightCorner, nil, nil, alpha)
    self:SetAlphaColor(frame.TopBorder, nil, nil, alpha)
--BORDER
    self:SetAlphaColor(frame.BotLeftCorner, nil, nil, alpha)
    self:SetAlphaColor(frame.BotRightCorner, nil, nil, alpha)
    self:SetAlphaColor(frame.BottomBorder, nil, nil, alpha)
    self:SetAlphaColor(frame.LeftBorder, nil, nil, alpha)
    self:SetAlphaColor(frame.RightBorder, nil, nil, alpha)
end