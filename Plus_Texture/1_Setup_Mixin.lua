








--隐藏，材质
function WoWTools_TextureMixin:HideTexture(object)--, notClear)
    if object and object:IsObjectType('Texture') then
        object:SetTexture(0)
        object:SetAlpha(0)
    end
end






--设置，颜色，透明度
function WoWTools_TextureMixin:SetAlphaColor(object, notAlpha, notColor, alphaORmin)
    if object then
        if alphaORmin==0 then
            object:SetAlpha(0)
            return
        end
        if not notColor and object.SetVertexColor then
            object:SetVertexColor(self.Color:GetRGB())
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
            self:HideTexture(icon)
        else
            for _, icon in pairs({frame:GetRegions()}) do
                if not tab.show[icon] then
                    self:HideTexture(icon)
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
    if type(tab)=='number' then
        tab={alpha=tab}
    else
        tab=tab or {}
    end

    local notColor= tab.notColor
    local alpha= tab.notAlpha and 1 or tab.alpha or self.min

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
            self:SetAlphaColor(icon, nil, notColor, alpha)
        end

    else
        local show= tab.show or {}
        for _, icon in pairs({frame:GetRegions()}) do
            if icon:IsObjectType("Texture") and not show[icon] then
                self:SetAlphaColor(icon, nil, notColor, alpha)
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
        
        if frame.clearButton then
            self:SetAlphaColor(frame.clearButton.texture, nil, nil, 1)
        end
        self:SetAlphaColor(frame.searchIcon, nil, nil, 1)

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

    local r,g,b= self.Color:GetRGB()

    alpha= (alpha==nil and 0)
        or (type(alpha)=='number' and alpha)
        or self.min

    frame.NineSlice:SetBorderColor(r, g, b, alpha)
    if not notBg then
        frame.NineSlice:SetCenterColor(0, 0, 0, alpha)
    end
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
function WoWTools_TextureMixin:SetScrollBar(bar)--, isHideBar)
    bar= bar and bar.ScrollBar or bar
    if not bar
        or not bar.Track
        or bar.wowTextureIsHooked
    then
        return
    end

    self:SetFrame(bar.Back, {alpha=0.8})
    self:SetFrame(bar.Forward, {alpha=0.8})
    self:SetFrame(bar.Track, {alpha=0.8})
    self:SetFrame(bar.Track.Thumb, {alpha=0.8})
    self:SetAlphaColor(bar.Backplate, nil, nil, 0)
    self:SetAlphaColor(bar.Background, nil, nil, 0.6)

    bar:SetAlpha(bar:HasScrollableExtent() and 1 or 0)

    WoWTools_DataMixin:Hook(bar, 'Update', function(b)
        b:SetAlpha(b:HasScrollableExtent() and 1 or 0)
    end)

    bar.wowTextureIsHooked=1
end


--Slider
function WoWTools_TextureMixin:SetSlider(frame)
    if not frame or not frame.Slider then
        return
    end

    local slider= frame.Slider.Slider or frame.Slider

    self:SetAlphaColor(slider.Thumb, true)

    if slider.NineSlice then
        self:SetNineSlice(slider, 1, true)
    else
        self:SetAlphaColor(slider.Left, true)
        self:SetAlphaColor(slider.Middle, true)
        self:SetAlphaColor(slider.Right, true)
        self:SetFrame(frame.Back, {alpha=1})
        self:SetFrame(frame.Forward, {alpha=1})

        self:SetAlphaColor(frame.Left, true)
        self:SetAlphaColor(frame.Middle, true)
        self:SetAlphaColor(frame.Right, true)

        if frame.Slider.Slider then
            self:SetFrame(frame.Slider.Back, {alpha=1})
            self:SetFrame(frame.Slider.Forward, {alpha=1})
        end
    end
end


--设置，按钮
function WoWTools_TextureMixin:SetButton(btn, tabOrAlpha)
    if not btn then
        return
    end
    local tab
    if not tabOrAlpha or type(tabOrAlpha)=='number' then
        tab= {alpha=tabOrAlpha or 0.5}
    else
        tab= tabOrAlpha
        tab.alpha=tab.alpha or 0.5
    end

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


function WoWTools_TextureMixin:SetUIButton(btn, alpha)
    if self:Save().UIButton and btn then
        alpha= alpha or 1
        if btn.Left and btn.Right then
            self:SetAlphaColor(btn.Left, nil, nil, alpha)
            self:SetAlphaColor(btn.Right, nil, nil, alpha)
            self:SetAlphaColor(btn.Middle, nil, nil, alpha)
            self:SetAlphaColor(btn.Center, nil, nil, alpha)
        else
            local icon= btn:GetNormalTexture()
            self:SetAlphaColor(icon, nil, nil, alpha)
        end
    end
end

--下拉，菜单 set_Menu
function WoWTools_TextureMixin:SetMenu(frame)
    if frame then
        self:SetAlphaColor(frame.Background, nil, nil, 0.3)
        self:SetAlphaColor(frame.Arrow, nil, nil, 0.7)
        --frame.Text:SetTextColor(PlayerUtil.GetClassColor():GetRGB())
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
end
--TabSystemOwnerMixin TabSystem
]]

--PanelTemplates_TabResize(frame, frame:GetParent().tabPadding or 0 , nil, frame:GetParent().minTabWidth, frame:GetParent().maxTabWidth)
--WoWTools_DataMixin:Hook(TabSystemButtonMixin, 'Init', function(self)

local function Set_CheckBox(self)
    local icon= self.GetNormalTexture and self:GetNormalTexture() or self:GetRegions()
    icon:SetAlpha(self:GetChecked() and 0 or 1)
end

function WoWTools_TextureMixin:SetCheckBox(check, bgAtlas)--, alpha)
--self:SetAlphaColor(icon, nil, nil, alpha or 1)
    if not check
        or not self:Save().CheckBox
        or check.wowTextureIsHooked
    then
        return
    end

    local icon= check.GetNormalTexture and check:GetNormalTexture()
                or (check.GetRegions and check:GetRegions())

    if icon:IsObjectType("Texture") then
        icon:SetAtlas(bgAtlas or 'UI-QuestTrackerButton-QuestItem-Frame')
        icon:ClearAllPoints()
        icon:SetPoint('TOPLEFT', 4, -4)
        icon:SetPoint('BOTTOMRIGHT', -4, 4)
        icon:SetVertexColor(self.Color:GetRGB())

        icon= check:GetHighlightTexture()
        if icon then
           check:SetHighlightAtlas('Forge-ColorSwatchSelection')
        end

        Set_CheckBox(check)
        WoWTools_DataMixin:Hook(check, 'SetChecked', Set_CheckBox)
        check:HookScript('OnLeave', Set_CheckBox)

        check.wowTextureIsHooked=true
    end
end


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

        self:HideFrame(border.SelectedIconArea.SelectedIconButton, {index=1})
        WoWTools_ButtonMixin:AddMask(border.SelectedIconArea.SelectedIconButton, nil, border.SelectedIconArea.SelectedIconButton.Icon)

        border.IconSelectionText:SetText(
            '|A:communities-icon-addchannelplus:0:0|a|cnGREEN_FONT_COLOR:'
            ..(WoWTools_DataMixin.onlyChinese and '将一个图标拖曳至此处来显示' or ICON_SELECTION_DRAG)
        )
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

    local name= frame:GetName()

    if not name then
        return
    end

    self:HideFrame(frame)
    if frame.NineSlice then
        local r,g,b= self.Color:GetRGB()
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

    self:SetAlphaColor(frame.RightBorder, nil, nil, alpha)
end

--DialogBorderTemplate
function WoWTools_TextureMixin:SetBorder(frame, alpha)
    if not frame or not frame.Bg then
        return
    end
    alpha= alpha or self.min or 0.5

    self:SetFrame(frame, alpha)
end



function WoWTools_TextureMixin:SetNavBar(frame)
    local naveBar= frame and (frame.NavBar or frame.navBar)
    if not naveBar then
        return
    end
    self:HideFrame(naveBar.overlay)
    self:HideTexture(naveBar.InsetBorderBottom)
    self:HideTexture(naveBar.InsetBorderRight)
    self:HideTexture(naveBar.InsetBorderLeft)
    self:HideTexture(naveBar.InsetBorderBottomRight)
    self:HideTexture(naveBar.InsetBorderBottomLeft)
    naveBar:DisableDrawLayer('BACKGROUND')
end

function WoWTools_TextureMixin:SetStatusBar(bar, icon, notColor)
    notColor= WoWTools_DataMixin.Player.Class=='PRIEST' or notColor--牧师
    if icon and icon:IsObjectType('Texture') then
        if notColor then
            icon:SetAtlas('UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-Bar-Health')--绿色
        else
            icon:SetAtlas('UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-Bar-Health-Status')
            icon:SetVertexColor(self.Color:GetRGB())
        end
    elseif bar and bar:IsObjectType('StatusBar') then
        if notColor then
            bar:SetStatusBarTexture('UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-Bar-Health')--绿色
        else
            bar:SetStatusBarTexture('UI-HUD-UnitFrame-Target-Boss-Small-PortraitOff-Bar-Health-Status')
            bar:SetStatusBarColor(self.Color:GetRGB())
        end
    end

    if bar then
        self:SetAlphaColor(bar.BarFrame, nil, nil, 0.3)
        self:SetAlphaColor(bar.IconBG, nil, nil, 0.5)
        self:SetAlphaColor(bar.border, nil, nil, 0.3)
        self:HideTexture(bar.BG)
        self:SetAlphaColor(bar.IconBG, nil, nil, 0.5)
        self:SetAlphaColor(bar.Middle, nil, nil, 0.3)
        self:SetAlphaColor(bar.Left, nil, nil, 0.3)
        self:SetAlphaColor(bar.Right, nil, nil, 0.3)
    end
end

--Blizzard_CustomizationUI
function WoWTools_TextureMixin:SetModelZoom(frame)
    if not frame then
        return
    end
    for _, child in pairs({frame:GetChildren()}) do
        if child:IsObjectType('Button') then
            self:SetAlphaColor(child.NormalTexture, true)
        end
    end
end



--列表，总数
function WoWTools_TextureMixin:SetPagingControls(frame)
    if not frame or frame.TotaleText then
        return
    end

    self:SetButton(frame.PrevPageButton, {alpha=1})
    self:SetButton(frame.NextPageButton, {alpha=1})
--总数
    frame.TotaleText= frame:CreateFontString(nil, 'ARTWORK', frame.PageText:GetFontObject():GetName() or 'GameFontHighlight')
    frame.TotaleText:SetTextColor(frame.PageText:GetTextColor())
    frame.TotaleText:SetPoint('LEFT', frame.NextPageButton, 'RIGHT', 2, 0)

    if frame:GetParent().SetDataProvider and not frame.wowTextureIsHooked then
        WoWTools_DataMixin:Hook(frame:GetParent(), 'SetDataProvider', function(f, dataProvider)
            local num= 0
            for _, tab in pairs(dataProvider:GetCollection() or {}) do
                if tab.elements then
                    num= num+ #tab.elements
                end
            end
            f.PagingControls.TotaleText:SetText(num>0 and num or '')
        end)
        frame.wowTextureIsHooked= 1
    end

--去掉文字, 页 这个有BUG
    --frame.currentPageOnlyText='%d'
    --frame.currentPageWithMaxText='%d/%d'
end

    --HousingModelPreviewFrame.ModelPreview.ModelSceneControls.zoomInButton.NormalTexture