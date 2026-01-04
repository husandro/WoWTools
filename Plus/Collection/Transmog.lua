--[[
12.0才有 幻化
TransmogWardrobeItemsMixin TransmogFrame.WardrobeCollection.TabContent.ItemsFrame
TransmogItemModelMixin
]]

local function Save()
    return WoWToolsSave['Plus_Collection']
end



local function Create_ModelName(frame)
    frame.Name= frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    frame.Name:SetPoint('BOTTOMLEFT')
    frame.Name:SetPoint('BOTTOMRIGHT')
    frame.Name:SetJustifyH('CENTER')
    frame.Name:EnableMouse(true)
    frame.Name:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip_Hide()
    end)
    frame.Name:SetScript('OnEnter', function(self)
        local p=self:GetParent()
        local itemLink=  p.GetAppearanceLink and p:GetAppearanceLink()
        if itemLink then
            GameTooltip:SetOwner(p, 'ANCHOR_LEFT')
            GameTooltip:ClearLines()
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()
        end
        self:SetAlpha(0.3)
    end)
    frame.nameBG= frame:CreateTexture(nil, 'ARTWORK', nil, 6)
    frame.nameBG:SetColorTexture(0, 0, 0, 0.8)
    frame.nameBG:SetPoint('TOPLEFT', frame.Name)
    frame.nameBG:SetPoint('BOTTOMRIGHT', frame.Name)
    frame.nameBG:Hide()
end
    --[[frame.indexLabel= frame:CreateFontString(nil, 'ARTWORK', 'GameNormalNumberFont')
    frame.indexLabel:SetPoint('TOPRIGHT', -2,-2)
    frame.indexLabel:SetAlpha(0.5)]]








local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '模型: 显示名称' or (MODEL..': '..PROFESSIONS_FLYOUT_SHOW_NAME),
    function()
        return not Save().hideTransmogModelName
    end, function()
        Save().hideTransmogModelName= not Save().hideTransmogModelName and true or nil
        WoWTools_CollectionMixin:Refresh_TransmogItems()
    end)


    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_CollectionMixin.addName})
end










local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Transmog') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Transmog' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

    local menu= CreateFrame('DropdownButton', 'WoWToolsTransmogMenuButton', TransmogFrameCloseButton, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', TransmogFrameCloseButton, 'LEFT')
    menu:SetupMenu(Init_Menu)

    TransmogFrame.OutfitCollection.SaveOutfitButton:HookScript('OnEnter', function(self)
        local cost = not self:IsEnabled() and C_TransmogOutfitInfo.GetPendingTransmogCost()
        if cost then
            GameTooltip_ShowDisabledTooltip(GameTooltip, self,
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '你的钱不够。' or ERR_NOT_ENOUGH_MONEY),
                'ANCHOR_RIGHT'
            )
        end
    end)



--模型: 显示名称
--物品
    WoWTools_DataMixin:Hook(TransmogItemModelMixin, 'OnLoad', function(self)
        Create_ModelName(self)
    end)

    WoWTools_DataMixin:Hook(TransmogItemModelMixin, 'UpdateItem', function(self)
        local itemLink
        if not Save().hideTransmogModelName then
            itemLink= WoWTools_ItemMixin:GetName(nil, self:GetAppearanceLink() or self:GetIllusionLink(), nil, {notCount=true, label=self.Name})
        end
        self.Name:SetText(itemLink or '')
        self.nameBG:SetShown(itemLink)
    end)
--套装，自定义套装
    WoWTools_DataMixin:Hook(TransmogSetBaseModelMixin, 'OnLoad', function(self)
        Create_ModelName(self)
    end)
--套装
    WoWTools_DataMixin:Hook(TransmogSetModelMixin, 'UpdateSet', function(self)
        local name
        if self.elementData and not Save().hideTransmogModelName then
            local totalQuality = 0
            local numTotalSlots = 0
            local waitingOnQuality = false
            local primaryAppearances = C_TransmogSets.GetSetPrimaryAppearances(self.elementData.set.setID)
            for _, primaryAppearance in pairs(primaryAppearances) do
                numTotalSlots = numTotalSlots + 1
                local sourceInfo = C_TransmogCollection.GetSourceInfo(primaryAppearance.appearanceID)
                if sourceInfo and sourceInfo.quality then
                    totalQuality = totalQuality + sourceInfo.quality
                else
                    waitingOnQuality = true
                end
            end

            --self.elementData.set.collected 
            local setInfo = C_TransmogSets.GetSetInfo(self.elementData.set.setID)
            name= setInfo and setInfo.name

            if name then
                name= WoWTools_TextMixin:CN(name)
                if not waitingOnQuality then
                    local setQuality = (numTotalSlots > 0 and totalQuality > 0) and Round(totalQuality / numTotalSlots) or Enum.ItemQuality.Common
                    local colorData = ColorManager.GetColorDataForItemQuality(setQuality)
                    if colorData then
                        name= colorData.color:WrapTextInColorCode(name)
                    end
                end
                local label= setInfo.label
                if label then
                    label= WoWTools_TextMixin:CN(label)
                    name= name..'|n'..(self.elementData.set.collected and label or DISABLED_FONT_COLOR:WrapTextInColorCode(label))
                end
            end
        end
        self.Name:SetText(name)
        self.nameBG:SetShown(name)
    end)



--自定义套装
    WoWTools_DataMixin:Hook(TransmogCustomSetModelMixin, 'UpdateSet', function(self)
        local name
        if self.elementData and not Save().hideTransmogModelName then
            local icon
            name, icon= C_TransmogCollection.GetCustomSetInfo(self.elementData.customSetID)
            if name then
                if not self.elementData.isCollected then
                    name= WHITE_FONT_COLOR:WrapTextInColorCode(name)
                end
                if icon then
                    name= '|T'..icon..':0|t'..name
                end
            end
        end
        self.Name:SetText(name)
        self.nameBG:SetShown(name)
    end)

    Init=function()end
end











--12.0才有
function WoWTools_CollectionMixin:Init_Transmog()
    Init()
end

