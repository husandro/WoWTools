--[[
TextureUtil.lua
CreateBackground(frame, tab)
]]


WoWTools_TextureMixin={
    Events={}
}

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

    frame.Background:SetAtlas('ChallengeMode-guild-background')--' UI-Frame-DialogBox-BackgroundTile ')
    frame.Background:SetAlpha(alpha or 1)
    frame.Background:SetVertexColor(WoWTools_DataMixin.Player.useColor.r, WoWTools_DataMixin.Player.useColor.g, WoWTools_DataMixin.Player.useColor.b)
    return frame.Background
end
--[[
--显示背景 Background
WoWTools_TextureMixin:CreateBackground(frame, {point=function(texture)end, isAllPoint})
]]






function WoWTools_TextureMixin:IsAtlas(texture, size)--Atlas or Texture
    local isAtlas, textureID, icon
    if not texture  or texture=='' then
        return
    end

    local s, s2
    if type(size)=='table' then
        s2, s= size[1], size[2]
    end
    s= s or 0
    s2= s2 or s

    local t= type(texture)
    if t=='number' then
        if texture>0 then
            isAtlas, textureID, icon= false, texture, format('|T%d:%d:%d|t', texture, s, s2)
        end
    elseif t=='string' then
        
        local atlasInfo= C_Texture.GetAtlasInfo(texture)
        isAtlas= atlasInfo and true or false
        textureID= texture
        icon= isAtlas and format('|A:%s:%d:%d|a', texture, s, s2) or format('|T%s:%d:%d|t', texture, s, s2)
    end
    return isAtlas, textureID, icon
end




























local IconFrame
local function Create_IconSelectorPopupFrame()
    IconFrame= CreateFrame('Frame', 'WoWTools_IconSelectorPopupFrame', UIParent, 'IconSelectorPopupFrameTemplate')
    IconFrame:SetFrameStrata('DIALOG')
    IconFrame.IconSelector:SetPoint('BOTTOMRIGHT', -10, 36)

    WoWTools_MoveMixin:Setup(IconFrame, {notSave=true, setSize=true, minW=524, minH=276, maxW=524, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(524, 495)
    end})

    IconFrame:Hide()

    IconFrame.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(WoWTools_DataMixin.onlyChinese and '点击在列表中浏览' or ICON_SELECTION_CLICK)

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







--TipTacItemRef\Texture\wow

local ExpansionIcon = {
	[0] = {  -- Classic Era
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\0.tga",
		textureWidth = 32,
		textureHeight = 16,
		aspectRatio = 31 / 16,
		leftTexel = 0.03125,
		rightTexel = 1,
		topTexel = 0,
		bottomTexel = 1
	},
	[1] = {  -- Burning Crusade
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\1.tga",
		textureWidth = 32,
		textureHeight = 16,
		aspectRatio = 29 / 12,
		leftTexel = 0.0625,
		rightTexel = 0.96875,
		topTexel = 0.125,
		bottomTexel = 0.875
	},
	[2] = {  -- Wrath of the Lich King
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\2.tga",
		textureWidth = 64,
		textureHeight = 32,
		aspectRatio = 36 / 19,
		leftTexel = 0.21875,
		rightTexel = 0.78125,
		topTexel = 0.1875,
		bottomTexel = 0.78125
	},
	[3] = {  -- Cataclysm
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\3.tga",
		textureWidth = 64,
		textureHeight = 16,
		aspectRatio = 38 / 15,
		leftTexel = 0.203125,
		rightTexel = 0.796875,
		topTexel = 0,
		bottomTexel = 0.9375
	},
	[4] = {  -- Mists of Pandaria
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\4.tga",
		textureWidth = 64,
		textureHeight = 16,
		aspectRatio = 46 / 14,
		leftTexel = 0.140625,
		rightTexel = 0.859375,
		topTexel = 0.0625,
		bottomTexel = 0.9375
	},
	[5] = {  -- Warlords of Draenor
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\5.tga",
		textureWidth = 64,
		textureHeight = 16,
		aspectRatio = 46 / 13,
		leftTexel = 0.140625,
		rightTexel = 0.859375,
		topTexel = 0.0625,
		bottomTexel = 0.875
	},
	[6] = {  -- Legion
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\6.tga",
		textureWidth = 64,
		textureHeight = 16,
		aspectRatio = 40 / 15,
		leftTexel = 0.1875,
		rightTexel = 0.8125,
		topTexel = 0,
		bottomTexel = 0.9375
	},
	[7] = {  -- Battle for Azeroth
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\7.tga",
		textureWidth = 64,
		textureHeight = 32,
		aspectRatio = 48 / 17,
		leftTexel = 0.125,
		rightTexel = 0.875,
		topTexel = 0.21875,
		bottomTexel = 0.75
	},
	[8] = {  -- Shadowlands
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\8.tga",
		textureWidth = 64,
		textureHeight = 32,
		aspectRatio = 43 / 17,
		leftTexel = 0.15625,
		rightTexel = 0.828125,
		topTexel = 0.21875,
		bottomTexel = 0.75
	},
	[9] = {  -- Dragonflight
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\9.tga",
		textureWidth = 64,
		textureHeight = 32,
		aspectRatio = 42 / 17,
		leftTexel = 0.171875,
		rightTexel = 0.828125,
		topTexel = 0.21875,
		bottomTexel = 0.75
	},
	[10] = {  -- The War Within
		textureFile = "Interface\\AddOns\\WoWTools\\Source\\Texture\\WoW\\10.tga",
		textureWidth = 64,
		textureHeight = 32,
		aspectRatio = 42 / 17,
		leftTexel = 0.171875,
		rightTexel = 0.828125,
		topTexel = 0.21875,
		bottomTexel = 0.75
	}
}



function WoWTools_TextureMixin:GetWoWLog(expacID, texture)
    local info= ExpansionIcon[expacID]
    if not info then
        return
    end

    if texture then
        texture:SetTexture(info.textureFile)
        texture:SetTexCoord(info.leftTexel, info.rightTexel, info.topTexel, info.bottomTexel)
        return info
    end

    return ("|T%s:%d:%f:%d:%d:%d:%d:%d:%d:%d:%d|t"):format(
        info.textureFile,
        0,
        info.aspectRatio,
        info.xOffset or 0,
        info.yOffset or 0,
        info.textureWidth,
        info.textureHeight,
        info.leftTexel * info.textureWidth,
        info.rightTexel * info.textureWidth,
        info.topTexel * info.textureHeight,
        info.bottomTexel * info.textureHeight
  ), info
end