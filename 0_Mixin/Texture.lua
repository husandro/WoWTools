--[[
CreateBackground(frame, tab)
]]

WoWTools_TextureMixin={}

local e= select(2, ...)

function WoWTools_TextureMixin:CreateBackground(frame, tab)
    if frame.Background then
        return frame.Background
    end

    tab= tab or {}

    local point= tab.point
    local isAllPoint= tab.isAllPoint
    local alpha= tab.alpha or 0.5

    frame.Background= frame:CreateTexture(nil, 'BACKGROUND')
    if isAllPoint==true then
        frame.Background:SetAllPoints()
    elseif type(point)=='function' then
        point(frame.Background)
    end

    frame.Background:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
    frame.Background:SetAlpha(alpha or 0.5)
    frame.Background:SetVertexColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b)

    return frame.Background
end
--[[
--显示背景 Background
WoWTools_TextureMixin:CreateBackground(frame, {point=function(texture)end, isAllPoint})
]]






function WoWTools_TextureMixin:IsAtlas(texture, size)--Atlas or Texture
    local isAtlas, textureID, icon
    if texture and texture~='' then
        local t= type(texture)
        size= size or 0
        if t=='number' then
            if texture>0 then
                isAtlas, textureID, icon= false, texture, format('|T%d:%d|t', texture, size)
            end
        elseif t=='string' then
            texture= texture:gsub(' ', '')
            if texture~='' then
                local atlasInfo= C_Texture.GetAtlasInfo(texture)
                isAtlas= atlasInfo and true or false
                textureID= texture
                icon= isAtlas and format('|A:%s:%d:%d|a', texture, size, size) or format('|T%s:%d|t', texture, size)
            end
        end
    end
    return isAtlas, textureID, icon
end




























local IconFrame
local function Create_IconSelectorPopupFrame()
    IconFrame= CreateFrame('Frame', 'WoWTools_IconSelectorPopupFrame', UIParent, 'IconSelectorPopupFrameTemplate')
    IconFrame:SetFrameStrata('DIALOG')
    IconFrame.IconSelector:SetPoint('BOTTOMRIGHT', -10, 36)

    WoWTools_MoveMixin:Setup(IconFrame, {notSave=true, setSize=true, minW=524, minH=276, maxW=524, sizeRestFunc=function(btn)
        btn.target:SetSize(524, 495)
    end})

    IconFrame:Hide()

    IconFrame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(e.onlyChinese and '点击在列表中浏览' or ICON_SELECTION_CLICK)

    IconFrame.BorderBox.IconSelectorEditBox:SetAutoFocus(false)

    IconFrame:SetScript('OnShow', function(self)
        IconSelectorPopupFrameTemplateMixin.OnShow(self)
        if self.iconDataProvider==nil then
            self.iconDataProvider= CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None)
        end
        self:SetIconFilter(self:GetIconFilter() or IconSelectorPopupFrameIconFilterTypes.All)
        self:Update()
        self.BorderBox.IconSelectorEditBox:OnTextChanged()
        local function OnIconSelected(_, icon)
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon)
        end
        self.IconSelector:SetSelectedCallback(OnIconSelected)
    end)

    IconFrame:SetScript('OnHide', function(self)
        self.BorderBox.IconSelectorEditBox:SetText("")
        self.BorderBox.IconSelectorEditBox:ClearFocus()
        IconSelectorPopupFrameTemplateMixin.OnHide(self)
        self.iconDataProvider:Release()
        self.iconDataProvider = nil

        self.text=nil
        self.texture=nil
        self.SetValue=nil
    end)

    function IconFrame:Update()
        if not self.texture or self.texture==0 then
            self.origName = ""
            local initialIndex = 1
            self.IconSelector:SetSelectedIndex(initialIndex)
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex))
        else
            self.BorderBox.IconSelectorEditBox:HighlightText()
            self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(self.texture))
            self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self.texture)
        end
        local getSelection = GenerateClosure(self.GetIconByIndex, self)
        local getNumSelections = GenerateClosure(self.GetNumIcons, self)
        self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections)
        self.IconSelector:ScrollToSelectedIndex()
        self:SetSelectedIconText()

        self.BorderBox.IconSelectorEditBox:SetText(self.text or '')
    end

    function IconFrame:OkayButton_OnClick()
        local iconTexture = self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture() or 0
        local text2= self.BorderBox.IconSelectorEditBox:GetText()
        IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self)
        self.setValue(iconTexture, text2)
    end
end











function WoWTools_TextureMixin:Edit_Text_Icon(frame, tab)
    if not IconFrame then
        Create_IconSelectorPopupFrame()
    else
        IconFrame:SetShown(false)
    end
    IconFrame:ClearAllPoints()
    IconFrame:SetPoint('TOPLEFT', frame, 'RIGHT', 2, 20)

    IconFrame.text= tab.text
    IconFrame.texture= tab.texture
    IconFrame.setValue= tab.SetValue

    IconFrame:SetShown(true)
end