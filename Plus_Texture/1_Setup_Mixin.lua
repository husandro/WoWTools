
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
    if object and object:GetObjectType()=='Texture' then
        object:SetTexture(0)
    end
end
    --texture:SetAlpha(0)
    --texture:SetShown(false)


--设置，颜色，透明度
function WoWTools_TextureMixin:SetAlphaColor(object, notAlpha, notColor, alphaORmin)
    if object then
        if not notColor and WoWTools_DataMixin.Player.useColor then
            WoWTools_ColorMixin:Setup(object, {type=object:GetObjectType()})
        end
        if not notAlpha then
            if alphaORmin==true then
                object:SetAlpha(self.min)
            else
                object:SetAlpha(alphaORmin or self.min)
            end
        end
    end
end


















--隐藏, frame, 子材质
function WoWTools_TextureMixin:HideFrame(frame, tab)
    if not frame then
        return
    end
    if tab and tab.index then
        local icon= select(tab.index, frame:GetRegions())
        if icon and icon:GetObjectType()=="Texture" then
            icon:SetTexture(0)
        end
    else
        for _, icon in pairs({frame:GetRegions()}) do
            if icon:GetObjectType()=="Texture" then
                icon:SetTexture(0)
                --icon:SetAlpha(0)
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

    if tab and tab.index then
        local icon= select(tab.index, frame:GetRegions())
        if icon and icon:GetObjectType()=="Texture" then
             if not notColor then
                WoWTools_ColorMixin:Setup(icon, {type='Texture'})
            end
            if alpha then
                icon:SetAlpha(alpha)
            end
        end

    else
        for _, icon in pairs({frame:GetRegions()}) do
            if icon:GetObjectType()=="Texture" then
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
};]]
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
}
function WoWTools_TextureMixin:SetNineSlice(frame, min, hide, notAlpha, notBg, isFind)
    if not frame then
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
        if frame.TopEdge then
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
    end
end

--设置，滚动条，颜色
function WoWTools_TextureMixin:SetScrollBar(bar)
    bar= bar and bar.ScrollBar or bar
    if not bar or not bar.Track then
        return
    end

    self:SetAlphaColor(bar.Track.Thumb.Middle, true)
    self:SetAlphaColor(bar.Track.Thumb.Begin, true)
    self:SetAlphaColor(bar.Track.Thumb.End, true)

    if bar.Back then
        self:SetAlphaColor(bar.Back.Texture, true)
    end
    if bar.Forward then
        self:SetAlphaColor(bar.Forward.Texture, true)
    end

    self:HideTexture(bar.Backplate, nil)
    self:SetAlphaColor(bar.Background, nil, true)

    if bar.SetHideIfUnscrollable then
        bar:SetHideIfUnscrollable(true)
    end
end


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
            if icon:GetObjectType()=="Texture" then
                WoWTools_ColorMixin:Setup(icon, {type='Texture'})
            end
        end
    end
    local forward= frame.Slider.Forward or frame.Forward
    if forward then
        for _, icon in pairs({forward:GetRegions()}) do
            if icon:GetObjectType()=="Texture" then
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
    if tab.all then
        tab.alpha=tab.alpha or 0.3
        self:SetFrame(btn, tab)
        --WoWTools_ColorMixin:Setup(btn, {type='Button', alpha=tab.alpha or 0.3})
    else
        WoWTools_ColorMixin:Setup(btn:GetNormalTexture(), {type='Texture', alpha=tab.alpha or 1})
    end
end

--下拉，菜单 set_Menu
function WoWTools_TextureMixin:SetMenu(frame, tab)
    tab= tab or {}
    if frame then
        self:SetAlphaColor(frame.Background, nil, nil, tab.alpha or 0.5)

        if frame.FilterDropdown then
            self:SetAlphaColor(frame.FilterDropdown.Background, nil, nil, tab.alpha or 0.8)
        end
        self:SetAlphaColor(frame.Arrow, nil, nil, tab.alpha or 0.8)
    end
end

--[[TabSystem 
function WoWTools_TextureMixin:SetTabSystem(frame)--TabSystemOwner.lua
    if not frame or not frame.GetTabSet then
        return
    end
    for _, tabID in pairs(frame:GetTabSet() or {}) do
        self:SetTabButton(frame:GetTabButton(tabID))
    end
end]]

function WoWTools_TextureMixin:SetTabButton(frame, alpha)--TabSystemOwner.lua
    if not frame then
        return
    end
    if frame.GetTabSet then
        local btn
        for _, tabID in pairs(frame:GetTabSet()) do
            btn= frame:GetTabButton(tabID)
            if btn then
                self:SetFrame(frame, {alpha=alpha or 0.75})
                if frame.Text then
                    frame.Text:SetShadowOffset(1, -1)
                end
            end
        end
    else
        self:SetFrame(frame, {alpha=alpha or 0.75})
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

--[[function WoWTools_TextureMixin:SetUIFrame(frame)
    --self:SetAlphaColor(frame.TitleContainer, nil, nil, true)
    self:SetNineSlice(frame)
    self:SetAlphaColor(frame:GetName()..'Bg', nil, nil, true)
end]]