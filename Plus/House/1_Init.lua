--[[
	<Button name="HousingCatalogDecorEntryTemplate" mixin="HousingCatalogDecorEntryMixin" inherits="BaseHousingCatalogEntryTemplate" virtual="true"/>
	<Button name="HousingCatalogRoomEntryTemplate" mixin="HousingCatalogRoomEntryMixin" inherits="BaseHousingCatalogEntryTemplate" virtual="true">
]]

local function Save()
    return WoWToolsSave['Plus_House']
end




local function Set_Texture(texture)
    if texture:IsObjectType('Texture') then
        texture:SetSize(16,16)
    end
    texture:SetAlpha(0.7)
    texture:EnableMouse(true)
    texture:SetScript('OnLeave', WoWToolsButton_OnLeave)
    function texture:set_alpha()
        self:SetAlpha(self:IsMouseOver() and 0.2 or 0.7)
    end
    texture:SetScript('OnEnter', WoWToolsButton_OnEnter)
end






local function Create_Button(btn)
--有点大
    btn.InfoText:SetFontObject('GameFontWhite')
    btn.InfoText:ClearAllPoints()
    btn.InfoText:SetPoint('BOTTOMRIGHT' , -6, 2)
--可制定
    btn.CustomizeIcon:ClearAllPoints()--size 16,16
    btn.CustomizeIcon:SetPoint('BOTTOM', btn.InfoText, 'TOP')


--添加，追踪，按钮
    btn.trackableButton= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
    btn.trackableButton:Hide()
    btn.trackableButton:SetSize(18,18)
    btn.trackableButton:SetPoint('TOPLEFT', 3, -2)
    btn.trackableButton.texture= btn.trackableButton:CreateTexture(nil, 'BORDER')
    btn.trackableButton.texture:SetAllPoints()
    btn.trackableButton.texture:SetAtlas('Waypoint-MapPin-Tracked')
    btn.trackableButton:SetScript('OnLeave', GameTooltip_Hide)

    function btn.trackableButton:get_entryInfo()
        return self:GetParent().entryInfo
    end
    function btn.trackableButton:tooltip()
        if not self:IsMouseOver() then
            return
        end
        local entryInfo= self:get_entryInfo()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText(WoWTools_TooltipMixin.addName..WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING))

        local obj= WoWTools_HouseMixin:GetObjectiveText(entryInfo)
        if obj then
            GameTooltip:AddLine(' ')
            GameTooltip_AddHighlightLine(GameTooltip, obj, true)
        end

        GameTooltip:Show()
    end

    function btn.trackableButton:settings()
        local entryInfo= self:get_entryInfo()
        local isTrackable
        if entryInfo then
            local recordID= entryInfo.entryID.recordID
            isTrackable = C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID)
        end
        self.texture:SetDesaturated(not isTrackable)
        self.texture:SetAlpha(isTrackable and 1 or 0.5)
    end

    function btn.trackableButton:set_event()
        self:RegisterEvent('CONTENT_TRACKING_UPDATE')
    end

    btn.trackableButton:SetScript('OnEvent', function(frame)
        frame:settings()
    end)
    btn.trackableButton:SetScript('OnHide', function(frame)
        frame:UnregisterAllEvents()
    end)
    btn.trackableButton:SetScript('OnShow', function(frame)
        frame:set_event()
        frame:settings()
    end)
    btn.trackableButton:SetScript('OnEnter', function(frame)
        frame:settings()
        frame:tooltip()
        C_Timer.After(1, function() frame:tooltip() end)
    end)


    btn.trackableButton:SetScript('OnClick', function(self)
        local entryInfo= self:get_entryInfo()
        if not entryInfo then
            return
        end
        local recordID= self:GetParent().entryInfo.entryID.recordID
        if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID) then
            C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, recordID, Enum.ContentTrackingStopType.Manual)
        else
            C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, recordID)
        end
        C_Timer.After(0.3, function()
            self:settings()
            if self:IsMouseOver() then
                self:tooltip()
            end
        end)
        self:tooltip()
    end)

--可放置，室内，提示
    btn.Indoors= btn:CreateTexture()
    btn.Indoors:SetPoint('TOP', btn.trackableButton, 'BOTTOM')
    btn.Indoors:SetAtlas('house-room-limit-icon')
    btn.Indoors.tooltip= WoWTools_DataMixin.onlyChinese and '只能放置在室内' or HOUSING_DECOR_ONLY_PLACEABLE_INSIDE
    Set_Texture(btn.Indoors)
--可放置，室外，提示
    btn.Outdoors= btn:CreateTexture()
    btn.Outdoors:SetPoint('TOP', btn.Indoors, 'BOTTOM')
    btn.Outdoors:SetAtlas('house-outdoor-budget-icon')
    btn.Outdoors.tooltip= WoWTools_DataMixin.onlyChinese and '只能放置在室外' or HOUSING_DECOR_ONLY_PLACEABLE_OUTSIDE
    Set_Texture(btn.Outdoors)
--是否可摧毁，此装饰无法被摧毁，也不会计入住宅收纳箱的容量限制
    btn.canDelete= btn:CreateTexture()
    btn.canDelete:SetPoint('TOPLEFT', btn.Outdoors, 'BOTTOMLEFT')
    btn.canDelete:SetAtlas('Objective-Fail')
    btn.canDelete.tooltip= WoWTools_DataMixin.onlyChinese and '此装饰无法被摧毁，也不会计入住宅收纳箱的容量限制' or HOUSING_DECOR_STORAGE_ITEM_CANNOT_DESTROY
    Set_Texture(btn.canDelete)
    btn.canDelete:SetAlpha(1)
    function btn.canDelete:set_alpha()
        self:SetAlpha(self:IsMouseOver() and 0.3 or 1)
    end
--可获得首次收集奖励
    btn.firstXP= btn:CreateTexture()
    btn.firstXP:SetPoint('TOP', btn.canDelete,'BOTTOM', -1, 4)
    btn.firstXP:SetAtlas('GarrMission_CurrencyIcon-Xp')
    btn.firstXP.tooltip= WoWTools_DataMixin.onlyChinese and '|cnLIGHTBLUE_FONT_COLOR:可获得首次收集奖励|r' or HOUSING_DECOR_FIRST_ACQUISITION_AVAILABLE
    Set_Texture(btn.firstXP)
    btn.firstXP:SetSize(20,20)
--空间，大小
    btn.placementCostLabel= btn:CreateFontString(nil, nil, 'GameFontWhite')
    btn.placementCostLabel:SetPoint('TOPLEFT', btn.firstXP, 'BOTTOMLEFT', 5, 5)
    btn.placementCostLabel.tooltip= WoWTools_DataMixin.onlyChinese and '装饰放置成本|cnNORMAL_FONT_COLOR:|n放置此装饰所需占用的装饰放置预算|r' or HOUSING_DECOR_PLACEMENT_COST_TOOLTIP
    Set_Texture(btn.placementCostLabel)

--预览不可用
    btn.notAsset= btn:CreateTexture()
    btn.notAsset:SetPoint('LEFT', btn.trackableButton, 'RIGHT')
    btn.notAsset:SetSize(16,16)
    btn.notAsset:SetAtlas('transmog-icon-hidden')

--索引
    btn.indexLabel= btn:CreateFontString(nil, 'BORDER', 'GameFontDisable')
    btn.indexLabel:SetFontHeight(10)
    btn.indexLabel:SetPoint('TOPLEFT',0, 7)

--选定，提示
    btn.selectBG= btn:CreateTexture()
    --btn.selectBG:SetAllPoints()
    btn.selectBG:SetPoint('TOPLEFT', -16, 18)
    btn.selectBG:SetAlpha(0.5)
    btn.selectBG:SetPoint('BOTTOMRIGHT', 16, -18)
    btn.selectBG:SetAtlas('AlliedRace-UnlockingFrame-BottomButtonsMouseOverGlow')

    function btn:set_selectBG()
        C_Timer.After(0.1, function()
            local show=false
            local data= self.entryInfo
                    and HousingDashboardFrame
                    and HousingDashboardFrame:IsVisible()
                    and HousingDashboardFrame.CatalogContent.PreviewFrame.catalogEntryInfo

            if data and  self.entryInfo.name== data.name then
                show=true
            end
            self.selectBG:SetShown(show)
        end)
    end

    EventRegistry:RegisterCallback("HousingCatalogEntry.OnInteract", btn.set_selectBG, btn)
    btn:set_selectBG()

    btn:HookScript('OnShow', function(self)
        EventRegistry:RegisterCallback("HousingCatalogEntry.OnInteract", self.set_selectBG, self)
        self:set_selectBG()
    end)
    btn:HookScript('OnHide', function(self)
        EventRegistry:UnregisterCallback("HousingCatalogEntry.OnInteract", self);
        self.Background:SetAlpha(1)
    end)
end

































local function Init_HousingTemplates()

    if not C_AddOns.IsAddOnLoaded('Blizzard_HousingTemplates') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_HousingTemplates' then
                Init_HousingTemplates()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'AddTooltipTrackingLines', function(btn, tooltip)
        local entryInfo= btn:HasValidData() and btn.entryInfo
        if not entryInfo then
            return
        end
        tooltip:AddLine(' ')
        local textLeft, portrait= WoWTools_TooltipMixin:Set_HouseItem(tooltip, entryInfo)
        if tooltip.textLeft then
            tooltip.textLeft:SetText(textLeft or '')
            tooltip.Portrait:settings(portrait)
            local r,g,b= WoWTools_ItemMixin:GetColor(entryInfo.quality)
            tooltip:Set_BG_Color(r,g,b, 0.15)
        end
        tooltip:Show()
    end)







--列表，数量
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'OnLoad', function(frame)
        frame.numItemLabel= frame:CreateFontString(nil, nil, 'GameFontWhite')
        frame.numItemLabel:SetPoint('LEFT', frame.CategoryText, 'RIGHT', 5, 0)
        frame.numItemLabel:SetScript('OnLeave', WoWToolsButton_OnLeave)
        frame.numItemLabel:SetScript('OnEnter', WoWToolsButton_OnEnter)
        frame.numItemLabel.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '家具数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_QUANTITY_LABEL, CATALOG_SHOP_TYPE_DECOR))
        function frame.numItemLabel:set_alpha()
            self:SetAlpha(self:IsMouseOver() and 0.5 or 1)
        end
    end)

    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'SetCatalogElements', function(frame)
        local num= frame.ScrollBox:GetDataProviderSize()
        frame.numItemLabel:SetText(WoWTools_DataMixin:MK(num, 3) or '')
    end)
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'ClearCatalogData', function(frame)
        frame.numItemLabel:SetText('')
    end)



    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'OnLoad', Create_Button)

    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'UpdateVisuals', function(btn)

        --local isTrackable= nil
        local placementCost, r,g,b, show, isXP, isIndoors, isOutdoors, isCanDelete, isNotAsset
        local entryInfo= btn:HasValidData() and btn.entryInfo

        if entryInfo then
            r,g,b= WoWTools_ItemMixin:GetColor(entryInfo.quality)
            placementCost= entryInfo.placementCost

            if btn.InfoText:IsShown() then
                local numPlaced, quantity
                if btn:IsBundleItem() then
                    numPlaced= btn:GetNumDecorPlaced()
                    quantity= btn.bundleItemInfo.quantity

                elseif btn:IsInMarketView() then

                elseif btn.entryInfo.isUniqueTrophy then

                elseif btn.entryInfo.showQuantity then
                    numPlaced= entryInfo.numPlace
                    if entryInfo.quality and entryInfo.remainingRedeemable then
                        quantity= entryInfo.quantity + entryInfo.remainingRedeemable
                    end
                end
                if numPlaced and quantity then
                    numPlaced= numPlaced==0 and '|cff6262620|r' or numPlaced
                    quantity= quantity==0 and '|cff6262620|r' or quantity
                    btn.InfoText:SetText(numPlaced..'/'..quantity..'|A:house-chest-icon:0:0|a')
                end
            end

            if entryInfo.entryID then
                isCanDelete= C_HousingCatalog.CanDestroyEntry(entryInfo.entryID)

                show= ContentTrackingUtil.IsContentTrackingEnabled()--追踪当前可用
                    and C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)--追踪功能对此物品可用

                --isTrackable= show and C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)--正在追踪

            end
            isXP= entryInfo.firstAcquisitionBonus and entryInfo.firstAcquisitionBonus>0
            isIndoors= entryInfo.isAllowedIndoors
            isOutdoors= entryInfo.isAllowedOutdoors
            isNotAsset= not entryInfo.asset
        end

        btn.Background:SetVertexColor(r or 1, g or 1, b or 1, 1)
        btn.placementCostLabel:SetText(placementCost and '|A:House-Decor-budget-icon:0:0|a'..placementCost or ' ')

        btn.trackableButton:SetShown(show)

        btn.firstXP:SetShown(isXP)
        btn.Indoors:SetShown(isIndoors)
        btn.Outdoors:SetShown(isOutdoors)
        btn.notAsset:SetShown(isNotAsset)
        btn.canDelete:SetShown(isCanDelete==false)

        btn.indexLabel:SetText(btn.GetElementDataIndex and btn:GetElementDataIndex() or '')
    end)

    Init_HousingTemplates=function()end
end


    --[[WoWTools_DataMixin:Hook(HousingCatalogCategoryMixin, 'Init', function(frame, categoryInfo)
        info= categoryInfo
        for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR|r') for k2,v2 in pairs(v) do print('|cffffff00',k2,v2, '|r') end print('|cffff0000---',k, '---END|r') else print(k,v) end end print('|cffff00ff——————————|r')
    end)]]

















local function Add_label(frame, name, layoutIndex, text)
    frame.TextContainer[name]= frame.TextContainer:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    frame.TextContainer[name]:SetJustifyH('LEFT')
    frame.TextContainer[name]:SetHeight(0)
    frame.TextContainer[name].layoutIndex= layoutIndex
    frame.TextContainer[name].expand= true
    if text then
        frame.TextContainer[name]:SetText(text)
    end
    frame.TextContainer:AddLayoutChildren(frame.TextContainer[name])
end


local function Set_EntryInfo(frame, entryInfo)
        if not frame:IsVisible() then
            return
        end

        entryInfo= entryInfo or frame.catalogEntryInfo

        local obj, r,g,b

--来源
        if entryInfo then
            if (not entryInfo.sourceText or entryInfo.sourceText=='') then
                obj= WoWTools_HouseMixin:GetObjectiveText(entryInfo)
            end
            r,g,b= WoWTools_ItemMixin:GetColor(entryInfo.quality)
        end
        frame:SetTextOrHide(frame.TextContainer.TrackingObjectiveText, obj)
        
--拥有数量
        local totalOwned = entryInfo.numPlaced + entryInfo.quantity + entryInfo.remainingRedeemable;
	    local totalOwnedText = format('|A:house-decor-budget-icon:0:0|a%d |A:house-chest-icon:16:16|a %d', entryInfo.numPlaced, totalOwned)
        frame:SetTextOrHide(frame.TextContainer.NumOwned, totalOwnedText);

--关键词
        frame:SetTextOrHide(frame.TextContainer.TagsText, WoWTools_HouseMixin:GetTagsText(entryInfo))
--室内，外
        frame.TextContainer.InDoorsText:SetShown(entryInfo.isAllowedIndoors)
        frame.TextContainer.OutDoorsText:SetShown(entryInfo.isAllowedOutdoors)
--品质
        frame.NameContainer.Name:SetTextColor(r or 1, g or 1, b or 1)

--设置，内容
        frame.TextContainer:SetFixedWidth(frame.TextContainer:GetWidth())
        frame.TextContainer:Layout()
    end






local function Init_HousingModelPreview()

    if not C_AddOns.IsAddOnLoaded('Blizzard_HousingModelPreview') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_HousingModelPreview' then
                Init_HousingModelPreview()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

    WoWTools_DataMixin:Hook(HousingModelPreviewMixin, 'OnLoad', function(frame)
        local layoutIndex=3
        for _, label in pairs({AddonList.ForceLoad:GetRegions()}) do
            layoutIndex= math.max(label.layoutIndex or 0, layoutIndex)
        end
--来源
        Add_label(frame, 'TrackingObjectiveText', layoutIndex+1)
--关键词
        Add_label(frame, 'TagsText', layoutIndex+2)
--室内，外
        Add_label(frame, 'InDoorsText', layoutIndex+3, '|A:house-room-limit-icon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '室内' or HOUSING_CATALOG_FILTERS_INDOORS))
        Add_label(frame, 'OutDoorsText', layoutIndex+4, '|A:house-outdoor-budget-icon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '室外' or HOUSING_CATALOG_FILTERS_OUTDOORS))
    end)


    

    WoWTools_DataMixin:Hook(HousingModelPreviewMixin, 'PreviewCatalogEntryInfo', function(frame, entryInfo)
        Set_EntryInfo(frame, entryInfo)
        C_Timer.After(1, function() Set_EntryInfo(frame) end)
    end)

    Init_HousingModelPreview=function()end
end



















--住宅信息板
local function Init_HousingDashboard()
    if not C_AddOns.IsAddOnLoaded('Blizzard_HousingDashboard') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_HousingDashboard' then
                Init_HousingDashboard()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

    local menu= CreateFrame('DropdownButton', 'WoWToolsHousingDashboardMenuButton', HousingDashboardFrameCloseButton, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', HousingDashboardFrameCloseButton, 'LEFT')
    menu:SetupMenu(function(btn, root)
        if not btn:IsMouseOver() then
            return
        end

        local sub=WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_HouseMixin.addName})
--摧毁
        WoWTools_OtherMixin:OpenOption(sub,
            '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and 'DELETE' or DELETE_ITEM_CONFIRM_STRING),
            '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)
        )
    end)

--添加一个图标
    HousingDashboardFrame.CatalogContent.PreviewFrame.TextContainer.CollectionBonus:SetText(
        '|A:GarrMission_CurrencyIcon-Xp:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '|cnLIGHTBLUE_FONT_COLOR:可获得首次收集奖励|r' or HOUSING_DECOR_FIRST_ACQUISITION_AVAILABLE)
    )

    Init_HousingDashboard=function()end
end














local panel= CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['Plus_House']= WoWToolsSave['Plus_House'] or {}
    WoWTools_HouseMixin.addName= '|A:house-chest-icon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '住宅' or AUCTION_CATEGORY_HOUSING)

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_HouseMixin.addName,
        GetValue= function() return not Save().disabled end,
        func= function()
            Save().disabled= not Save().disabled and true or nil
        end,
        tooltip= WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
    })

    if not Save().disabled then
        Init_HousingDashboard()
        Init_HousingTemplates()
        Init_HousingModelPreview()
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)

