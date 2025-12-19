if CombatLogGetCurrentEventInfo then--12.0才有
    return
end
--[[
12.0才有 幻化
这个有保护，注意操作
TransmogWardrobeItemsMixin
TransmogWardrobeSetsMixin
TransmogWardrobeCustomSetsMixin

ShowEquippedGearSpellFrameMixin

TransmogCharacterMixin

TransmogSetBaseModelMixin
TransmogItemModelMixin
TransmogSetModelMixin
TransmogCustomSetModelMixin

TransmogWardrobeSituationsMixin
TransmogSituationMixin
]]

local function Save()
    return WoWToolsSave['Plus_Move']
end

local ListTab={
    OutfitCollection= {minValue= 83, rest=312, title=TRANSMOG_OUTFIT_NAME_DEFAULT},--外观方案
    CharacterPreview= {minValue=300, rest=657, title=MODEL},--模型
}

local function Set_TransmogWidth(onlyName)
    if not WoWTools_FrameMixin:IsLocked(TransmogFrame) then
        if onlyName then
            TransmogFrame[onlyName]:SetWidth(Save()['Transmog'..onlyName..'Width'] or ListTab[onlyName].rest)
        else
            for name, data in pairs(ListTab) do
                TransmogFrame[name]:SetWidth(Save()['Transmog'..name..'Width'] or data.rest)
            end
        end
    end
end


local function Rest_Size()
    for name in pairs(ListTab) do
        Save()['Transmog'..name..'Width']= nil
    end
    if not WoWTools_FrameMixin:IsLocked(TransmogFrame) then
        TransmogFrame:SetSize(1618, 883)
        Set_TransmogWidth()
        WoWTools_CollectionMixin:Refresh_TransmogItems()
    end
end


--增加，按钮宽度，按钮 WoWToolsTransmogOutfitCollectionResizeButton WoWToolsTransmogCharacterPreviewResizeButton
local function Create_ResizeButton(name, data)
    local btn= CreateFrame('Button', 'WoWToolsTransmog'..name..'ResizeButton', TransmogFrame[name], 'WoWToolsButtonTemplate')

    btn.minValue= data.minValue
    btn.name= name
    btn.tooltip= data.title
    btn.alpha= 0.2

    btn:SetPoint('BOTTOMRIGHT', TransmogFrame[name], 7, -2)
    btn:SetSize(12,23)
    if name=='CharacterPreview' then
        btn:SetNormalAtlas('uitools-icon-chevron-left')
        btn:SetFrameLevel(TransmogFrame.WardrobeCollection.TabContent.ItemsFrame:GetFrameLevel()+1)
    else
        btn:SetNormalAtlas('uitools-icon-chevron-right')
    end
    btn:SetHighlightTexture(0)
    WoWTools_TextureMixin:SetAlphaColor(btn:GetNormalTexture(), nil, nil, btn.alpha)


    btn:SetScript('OnLeave', function(self)
        self:GetNormalTexture():SetAlpha(self.alpha)
        GameTooltip:Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        self:GetNormalTexture():SetAlpha(1)
        GameTooltip_ShowSimpleTooltip(GameTooltip,
            WoWTools_DataMixin.Icon.icon2..
            format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH, self.tooltip)
            ..WoWTools_DataMixin.Icon.left,
            nil, nil, self
        )
    end)

    function btn.set_width(self)
        self:SetScript('OnUpdate', nil)
        Save()['Transmog'..self.name..'Width']= math.floor(self:GetParent():GetWidth())
        if self._eventOwner then
            EventRegistry:UnregisterCallback('PLAYER_REGEN_DISABLED', self._eventOwner)
            self._eventOwner=nil
        end
    end
    btn:SetScript('OnHide', function(self)
        if self:GetScript('OnUpdate') then
            self:set_width()
        end
    end)
    btn:SetScript('OnMouseUp', function(self)
        self:set_width()
        WoWTools_CollectionMixin:Refresh_TransmogItems()
        ResetCursor()
    end)
    btn:SetScript('OnMouseDown', function(self)
        local p= self:GetParent()
        if WoWTools_FrameMixin:IsLocked(p) then
            return
        else
            self._eventOwner=EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", function()
                self:set_width()
            end)
        end
        SetCursor('Interface\\CURSOR\\Crosshair\\UI-Cursor-SizeRight')
        local w= p:GetWidth()
        local x= GetCursorPosition()
        local scale= p:GetEffectiveScale()
        self:SetScript('OnUpdate', function()
            local w2= w- (x- GetCursorPosition())*scale
            w2= math.min(w2, TransmogFrame:GetWidth()/2)
            w2= math.max(w2, self.minValue)
            w2= math.floor(w2)
            p:SetWidth(w2)
        end)
    end)
end

















local function Init()
    if WoWTools_DataMixin.onlyChinese and not LOCALE_zhCN then
        ListTab.OutfitCollection.title= '外观方案'
        ListTab.CharacterPreview.title= '模型'
    end
    for name, data in pairs(ListTab) do
        data.rest= math.floor(TransmogFrame[name]:GetWidth())
    end

    TransmogFrame.HelpPlateButton:SetFrameLevel(WorldMapFrame.BorderFrame.TitleContainer:GetFrameLevel()+1)








--左边
    TransmogFrame.OutfitCollection:SetPoint('BOTTOM')
--方案，列表按钮
    WoWTools_DataMixin:Hook(TransmogOutfitEntryMixin, 'OnLoad', function(frame)
        frame.OutfitButton:SetPoint('RIGHT', frame, -3, 0)
        frame.OutfitButton.Glow:SetPoint('LEFT')
        frame.OutfitButton.Glow:SetPoint('RIGHT')
        frame.OutfitButton.GlowPurple:SetPoint('LEFT')
        frame.OutfitButton.GlowPurple:SetPoint('RIGHT')
        frame.OutfitButton.HighlightTexture:SetPoint('RIGHT')
        frame.OutfitButton.NormalTexture:SetPoint('RIGHT')
        frame.OutfitButton.Selected:SetPoint('RIGHT')
        frame.OutfitButton.SelectedPurple:SetPoint('LEFT')
        frame.OutfitButton.SelectedPurple:SetPoint('RIGHT')
        frame.OutfitButton.TextContent:SetPoint('RIGHT', -10, 0)
    end)
--保存外观方案按钮
    TransmogFrame.OutfitCollection.SaveOutfitButton:ClearAllPoints()
    TransmogFrame.OutfitCollection.SaveOutfitButton:SetPoint('BOTTOM', 9, 9)
    TransmogFrame.OutfitCollection.SaveOutfitButton:SetText(WoWTools_DataMixin.onlyChinese and '保存' or SAVE)
    TransmogFrame.OutfitCollection.SaveOutfitButton:SetWidth(TransmogFrame.OutfitCollection.SaveOutfitButton:GetTextWidth()+24)
--移动，购买外观方案栏位
    TransmogFrame.OutfitCollection.PurchaseOutfitButton:ClearAllPoints()
    TransmogFrame.OutfitCollection.PurchaseOutfitButton:SetPoint('RIGHT', TransmogFrame.OutfitCollection.SaveOutfitButton, 'LEFT')
    TransmogFrame.OutfitCollection.PurchaseOutfitButton:SetSize(23, 23)
    TransmogFrame.OutfitCollection.PurchaseOutfitButton.Text:SetText("")
    TransmogFrame.OutfitCollection.PurchaseOutfitButton.Icon:ClearAllPoints()
    TransmogFrame.OutfitCollection.PurchaseOutfitButton.Icon:SetPoint('TOPLEFT', 4, -4)
    TransmogFrame.OutfitCollection.PurchaseOutfitButton.Icon:SetPoint('BOTTOMRIGHT', -4, 4)
    TransmogFrame.OutfitCollection.PurchaseOutfitButton:SetScript('OnEnter', function(button)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '购买外观方案栏位' or TRANSMOG_PURCHASE_OUTFIT_SLOT)
        local maxSlot= C_TransmogOutfitInfo.GetMaxNumberOfUsableOutfits()
        if not button:IsEnabled() then
            GameTooltip_AddErrorLine(GameTooltip, format(
                WoWTools_DataMixin.onlyChinese and '已达到%d个外观方案栏位的上限' or TRANSMOG_PURCHASE_OUTFIT_SLOT_TOOLTIP_DISABLED,
                maxSlot
            ), true)
        else
            local source = Enum.TransmogOutfitEntrySource.PlayerPurchased
	        local unlockedOutfitCount = C_TransmogOutfitInfo.GetNumberOfOutfitsUnlockedForSource(source)
            GameTooltip_AddInstructionLine(GameTooltip, format(
                WoWTools_DataMixin.onlyChinese and '总上限：%s%s/%s' or CURRENCY_TOTAL_CAP,
                '',
                format('%d', unlockedOutfitCount),
                format('%d', maxSlot)
            ))
		end
        GameTooltip:Show()
    end)
--钱
    TransmogFrame.OutfitCollection.MoneyFrame:ClearAllPoints()
    TransmogFrame.OutfitCollection.MoneyFrame:SetPoint('BOTTOMLEFT', TransmogFrame.CharacterPreview, 9, 3)

--锁定外观，按钮
    TransmogFrame.OutfitCollection.ShowEquippedGearSpellFrame:SetPoint('RIGHT')
--方案，列表
    TransmogFrame.OutfitCollection.OutfitList:SetPoint('RIGHT')
    TransmogFrame.OutfitCollection.OutfitList:SetPoint('BOTTOM', TransmogFrame.OutfitCollection.SaveOutfitButton, 'TOP', 0, 9)
    TransmogFrame.OutfitCollection.DividerBar:SetPoint('BOTTOMRIGHT', 2, 0)
--分割线
    TransmogFrame.OutfitCollection.OutfitList.DividerTop:SetPoint('RIGHT', -26, 0)
    TransmogFrame.OutfitCollection.OutfitList.DividerTop:SetPoint('LEFT', 13, 0)
    TransmogFrame.OutfitCollection.OutfitList.DividerBottom:SetPoint('RIGHT', -26, 0)
    TransmogFrame.OutfitCollection.OutfitList.DividerBottom:SetPoint('LEFT', 13, 0)














--中间
    TransmogFrame.CharacterPreview:SetPoint('BOTTOM')
    TransmogFrame.CharacterPreview.Background:SetPoint('BOTTOMRIGHT')
    TransmogFrame.CharacterPreview.Gradients.GradientLeft:SetPoint('TOPLEFT')
    TransmogFrame.CharacterPreview.Gradients.GradientLeft:SetPoint('BOTTOMLEFT')
    TransmogFrame.CharacterPreview.Gradients.GradientRight:SetPoint('TOPRIGHT')
    TransmogFrame.CharacterPreview.Gradients.GradientRight:SetPoint('BOTTOMRIGHT')
--取消所有的待定改动, 按钮
    TransmogFrame.CharacterPreview.ClearAllPendingButton:ClearAllPoints()
    TransmogFrame.CharacterPreview.ClearAllPendingButton:SetPoint('BOTTOMRIGHT', -46, 25)


--隐藏已忽略栏位
    WoWTools_DataMixin:Hook(TransmogFrame.CharacterPreview, 'RefreshHideIgnoredToggle', function(frame)
        local icon= frame.HideIgnoredToggle.Checkbox:GetRegions()
        if icon then
            icon:SetAlpha(C_CVar.GetCVarBool("transmogHideIgnoredSlots") and 0 or 1)
        end
    end)
    TransmogFrame.CharacterPreview.HideIgnoredToggle:ClearAllPoints()
    TransmogFrame.CharacterPreview.HideIgnoredToggle:SetPoint('BOTTOM', TransmogFrame.CharacterPreview.ClearAllPendingButton, 'TOP')
    TransmogFrame.CharacterPreview.HideIgnoredToggle.Text:SetText()
    function TransmogFrame.CharacterPreview.HideIgnoredToggle.Checkbox:set_icon()
        local icon= self:GetRegions()
        if icon then
            if self:IsMouseOver() then
                icon:SetAlpha(1)
            else
                icon:SetAlpha(C_CVar.GetCVarBool("transmogHideIgnoredSlots") and 0 or 1)
            end
        end
    end
    TransmogFrame.CharacterPreview.HideIgnoredToggle.Checkbox:SetScript('OnLeave', function(self)
        self:set_icon()
        GameTooltip:Hide()
    end)
    TransmogFrame.CharacterPreview.HideIgnoredToggle.Checkbox:SetScript('OnEnter', function(self)
        self:set_icon()
        GameTooltip_ShowSimpleTooltip(GameTooltip,
            WoWTools_DataMixin.onlyChinese and '隐藏已忽略栏位' or TRANSMOG_HIDE_UNASSIGNED_SLOTS,
            C_CVar.GetCVarBool("transmogHideIgnoredSlots") and GREEN_FONT_COLOR or SimpleTooltipConstants.NoOverrideColor,
            SimpleTooltipConstants.DoNotWrapText,
            self,
            "ANCHOR_LEFT"
        )
    end)
    WoWTools_DataMixin:Call(TransmogFrame.CharacterPreview.RefreshHideIgnoredToggle, TransmogFrame.CharacterPreview)--原生，没有加上
    C_Timer.After(0.3, function()
        TransmogFrame.CharacterPreview.HideIgnoredToggle.Checkbox:set_icon()
    end)
--自定义套装 <Anchor point="TOPLEFT" x="26" y="-72"/> <Anchor point="BOTTOMRIGHT" x="-26" y="10"/>
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.PagedContent:SetPoint('TOPLEFT', 26, -26)
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.PagedContent:SetPoint('BOTTOMRIGHT', -26, 10)
--新增自定义套装
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:ClearAllPoints()
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:SetPoint('BOTTOMRIGHT', -28, 13)

    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:SetText('')
    --TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:SetWidth(TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:GetHeight())
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:SetSize(32,32)
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton.texture= TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:CreateTexture(nil, 'BORDER')
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton.texture:SetPoint('CENTER')
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton.texture:SetSize(16,16)
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton.texture:SetAtlas('transmog-icon-add')
    WoWTools_DataMixin:Hook(TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton, 'SetEnabled', function(frame, enabled)
        frame.texture:SetDesaturated(not enabled)
    end)
    TransmogFrame.WardrobeCollection.TabContent.CustomSetsFrame.NewCustomSetButton:HookScript('OnEnter', function(frame)
        if frame:IsEnabled() then
            GameTooltip_ShowSimpleTooltip(GameTooltip, WoWTools_DataMixin.onlyChinese and '新增自定义套装' or TRANSMOG_CUSTOM_SET_NEW, nil, nil, frame, 'ANCHOR_RIGHT')
        end
    end)








--右边
    TransmogFrame.WardrobeCollection:SetPoint('BOTTOMRIGHT')
    TransmogFrame.WardrobeCollection.TabContent:SetPoint('BOTTOMRIGHT')
    TransmogFrame.WardrobeCollection.TabContent.Background:SetPoint('BOTTOMRIGHT', -4, 4)
    TransmogFrame.WardrobeCollection.TabContent.Border:SetPoint('BOTTOMRIGHT', 8, -8)

--情景
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.Situations:SetPoint('RIGHT', -43, 0)
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.Situations:SetPoint('BOTTOM', 0, 43)

    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.DescriptionText:SetPoint('RIGHT', -23, 0)--TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.DefaultsButton, 'LEFT', -4,0)
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.DescriptionText:SetPoint('BOTTOM', TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.EnabledToggle, 'TOP', 0, 4)
--默认，按钮
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.DefaultsButton:ClearAllPoints()
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.DefaultsButton:SetPoint('BOTTOMRIGHT', TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.Situations, 'TOPRIGHT', 0, 13)

    WoWTools_DataMixin:Hook(TransmogSituationMixin, 'OnLoad', function(frame)
        frame.Title:SetPoint('TOPRIGHT', frame, 'TOP')
        frame.Dropdown:SetPoint('LEFT', frame.Title, 'RIGHT')--<Anchor point="LEFT" x="35" y="0"/>
    end)
    WoWTools_DataMixin:Hook(TransmogFrame.WardrobeCollection.TabContent.SituationsFrame, 'Refresh', function(frame)
        for pool in frame.SituationFramePool:EnumerateActive() do
            pool:SetPoint('RIGHT')
        end
    end)
--应用改动，按钮
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.ApplyButton:ClearAllPoints()
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.ApplyButton:SetPoint('BOTTOM', TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.Situations, 0, 23)
    TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.ApplyButton:SetFrameLevel(TransmogFrame.WardrobeCollection.TabContent.SituationsFrame.ApplyButton:GetFrameLevel()+1)











--增加，按钮宽度，按钮
    for name, data in pairs(ListTab) do
        Create_ResizeButton(name, data)
    end

    Set_TransmogWidth()









    WoWTools_MoveMixin:Setup(TransmogFrame, {
        minW=830, minH=510,
    onShowFunc=true,
    scaleStopFunc=function(frame, btn)
        WoWTools_CollectionMixin:Refresh_TransmogItems()
        Save().scale[btn.name]= frame:GetScale()
    end,
    sizeUpdateFunc=function()
        WoWTools_CollectionMixin:Refresh_TransmogItems()
    end,
    sizeRestFunc=function()
        Rest_Size()
    end,
    addMenu=function(_, root)
        root= root:CreateButton(WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH, function() return MenuResponse.Open end)

        local maxValue= TransmogFrame:GetWidth()*0.8

        for name, data in pairs(ListTab) do
            root:CreateSpacer()
            local sub= WoWTools_MenuMixin:CreateSlider(root, {
                getValue=function(_, desc)
                    return Save()['Transmog'..desc.data.name..'Width'] or desc.data.rest
                end, setValue=function(value, _, desc)
                    Save()['Transmog'..desc.data.name..'Width']=  value
                    Set_TransmogWidth(desc.data.name)
                    WoWTools_CollectionMixin:Refresh_TransmogItems()
                end,
                name=data.title,
                minValue=data.minValue,
                maxValue=maxValue,
                step=1,
            })
            sub:SetData({name=name, rest=data.rest})
        end

        root:CreateSpacer()
        root:CreateButton(WoWTools_DataMixin.onlyChinese and '重置' or RESET, Rest_Size)
    end})

    Init=function()end
end














function WoWTools_MoveMixin.Events:Blizzard_Transmog()
    if WoWTools_FrameMixin:IsLocked(TransmogFrame) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            Init()
            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)
    else
        Init()
    end
end