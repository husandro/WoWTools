local e= select(2, ...)




function WoWTools_TextureMixin:SetColorTexture(object, tab)
    if object then
        tab= tab or {}
        tab.isColorTexture=true
        tab.type=object:GetObjectType()
        tab.alpha= tab.alpha or self.alpha or self.min or self.Save.alpha or 0.5
        WoWTools_ColorMixin:Setup(object, tab)
    end
end






--隐藏，材质
function WoWTools_TextureMixin:HideTexture(texture, notClear)
    if not texture then
        return
    end
    if not notClear and texture:GetObjectType()=='Texture' then
        texture:SetTexture(0)
    end
    texture:SetShown(false)
end

--设置，颜色，透明度
function WoWTools_TextureMixin:SetAlphaColor(object, notAlpha, notColor, alphaORmin)
    if object then
        if not notColor and e.Player.useColor then
            WoWTools_ColorMixin:Setup(object, {type=object:GetObjectType()})
        end
        if not notAlpha then
            if alphaORmin==true then
                object:SetAlpha(self.min or 0.5)
            else
                object:SetAlpha(alphaORmin or self.Save.alpha or self.min or 0.5)
            end
        end
    end
end


















--隐藏, frame, 子材质
function WoWTools_TextureMixin:HideFrame(frame, tab)
    if not frame then
        return
    end
    local hideIndex= tab and tab.index
    for index, icon in pairs({frame:GetRegions()}) do
        if icon:GetObjectType()=="Texture" then
            if hideIndex then
                if hideIndex==index then
                    icon:ClearAllPoints()
                    icon:SetShown(false)
                    break
                end
            else
                icon:SetShown(false)
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
    local indexTexture= tab.index
    local notColor= tab.notColor
    local alpha
    if not tab.notAlpha then
        alpha= tab.isMinAlpha and self.min or tab.alpha or self.Save.alpha
    end
    for index, icon in pairs({frame:GetRegions()}) do
        if icon:GetObjectType()=="Texture" then
            if indexTexture then
                if indexTexture== index then
                    if not notColor then
                        WoWTools_ColorMixin:Setup(icon, {type='Texture'})
                    end
                    if alpha then
                        icon:SetAlpha(alpha)
                    end
                    break
                end
            else
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
function WoWTools_TextureMixin:SetSearchBox(frame, tab)
    if not frame then-- or not frame.SearchBox then
        return
    end
    tab= tab or {}
    local alpha= tab.alpha or true

    self:SetAlphaColor(frame.Middle, nil, nil, alpha)
    self:SetAlphaColor(frame.Left, nil, nil, alpha)
    self:SetAlphaColor(frame.Right, nil, nil, alpha)
    self:SetAlphaColor(frame.Mid, nil, nil, alpha)
    local alpha2= type(alpha)=='number' and alpha<0 and alpha or true
    if frame.clearButton then
        self:SetAlphaColor(frame.clearButton.texture, nil, nil, alpha2)
    end
    self:SetAlphaColor(frame.searchIcon, nil, nil, alpha2)
end

--NineSlice
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
function WoWTools_TextureMixin:SetNineSlice(frame, min, hide, notAlpha, notBg)
    if not frame or not frame.NineSlice then
        return
    end
    local alpha= min and self.min or nil
    for index, text in pairs(NineSliceTabs) do
        if not hide then
            self:SetAlphaColor(frame.NineSlice[text], notAlpha, nil, alpha)
        else
            self:HideTexture(frame.NineSlice[text])
        end
        if notBg and index==8 then
            break
        end
    end
end

--设置，滚动条，颜色
function WoWTools_TextureMixin:SetScrollBar(frame)
    local bar= frame and frame.ScrollBar or frame
    if bar then
        if bar.Track then
            self:SetAlphaColor(bar.Track.Thumb.Middle, true)
            self:SetAlphaColor(bar.Track.Thumb.Begin, true)
            self:SetAlphaColor(bar.Track.Thumb.End, true)
        end
        if bar.Back then
            self:SetAlphaColor(bar.Back.Texture, true)
        end
        if bar.Forward then
            self:SetAlphaColor(bar.Forward.Texture, true)
        end
        self:HideTexture(bar.Backplate, nil)
        self:SetAlphaColor(bar.Background, nil, true)
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
        WoWTools_ColorMixin:Setup(btn, {type='Button', alpha=tab.alpha or 1})
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

--TabSystem 
function WoWTools_TextureMixin:SetTabSystem(frame)--TabSystemOwner.lua
    if not frame or not frame.GetTabSet then
        return
    end
    for _, tabID in pairs(frame:GetTabSet() or {}) do
        local btn= frame:GetTabButton(tabID)
        self:SetFrame(btn, {notAlpha=true})
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
end

--[[function WoWTools_TextureMixin:SetUIFrame(frame)
    --self:SetAlphaColor(frame.TitleContainer, nil, nil, true)
    self:SetNineSlice(frame)
    self:SetAlphaColor(frame:GetName()..'Bg', nil, nil, true)
end]]