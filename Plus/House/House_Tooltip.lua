--[[
	<Button name="HousingCatalogDecorEntryTemplate" mixin="HousingCatalogDecorEntryMixin" inherits="BaseHousingCatalogEntryTemplate" virtual="true"/>
	<Button name="HousingCatalogRoomEntryTemplate" mixin="HousingCatalogRoomEntryMixin" inherits="BaseHousingCatalogEntryTemplate" virtual="true">
]]
function WoWTools_TooltipMixin.Events:Blizzard_HousingDashboard()
    local menu= CreateFrame('DropdownButton', 'WoWToolsHousingDashboardMenuButton', HousingDashboardFrameCloseButton, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', HousingDashboardFrameCloseButton, 'LEFT')
    menu:SetupMenu(function(btn, root)
        if not btn:IsMouseOver() then
            return
        end
--物品信息 plus
        local sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO),
        function()
            return not self:Save().disabledHousingItemsPlus
        end, function()
            self:Save().disabledHousingItemsPlus= not self:Save().disabledHousingItemsPlus and true or nil
        end)
        sub:SetTooltip(function (tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
        end)

--摧毁
        WoWTools_OtherMixin:OpenOption(root,
            '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and 'DELETE' or DELETE_ITEM_CONFIRM_STRING),
            '|A:XMarksTheSpot:0:0|a'..(WoWTools_DataMixin.onlyChinese and '摧毁' or HOUSING_DECOR_STORAGE_ITEM_DESTROY_CONFIRMATION_STRING)
        )

        root:CreateDivider()
        self:OpenOption(root)
    end)
end











function WoWTools_TooltipMixin.Events:Blizzard_HousingTemplates()
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










    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'AddTooltipTrackingLines', function(btn, tooltip)
        local entryInfo= not self:Save().disabledHousingItemsPlus and btn:HasValidData() and btn.entryInfo
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
        local num= not self:Save().disabledHousingItemsPlus and frame.ScrollBox:GetDataProviderSize()
        frame.numItemLabel:SetText(num or '')
    end)
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'ClearCatalogData', function(frame)
        frame.numItemLabel:SetText('')
    end)








    if not HousingCatalogDecorEntryMixin.OnLoad then--12.0才有
        return
    end

    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'OnLoad', function(btn)
--有点大
        btn.InfoText:SetFontObject('GameFontWhite')
        btn.InfoText:ClearAllPoints()
        btn.InfoText:SetPoint('BOTTOMRIGHT' , -6, 2)
--可制定
        btn.CustomizeIcon:ClearAllPoints()--size 16,16
        btn.CustomizeIcon:SetPoint('BOTTOM', btn.InfoText, 'TOP')


--添加，追踪，按钮
        btn.trackableButton= CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate')
        btn.trackableButton:SetSize(18,18)
        btn.trackableButton:SetPoint('TOPLEFT', 3, -2)
        btn.trackableButton.texture= btn.trackableButton:CreateTexture(nil, 'BORDER')
        btn.trackableButton.texture:SetAllPoints()
        btn.trackableButton.texture:SetAtlas('Waypoint-MapPin-Tracked')
        btn.trackableButton:SetScript('OnLeave', GameTooltip_Hide)
        btn.trackableButton.tooltip= self.addName..WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)
        btn.trackableButton:SetScript('OnClick', function(b)
            local recordID= b:GetParent().entryInfo.entryID.recordID
            if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID) then
                C_ContentTracking.StopTracking(Enum.ContentTrackingType.Decor, recordID, Enum.ContentTrackingStopType.Manual)
            else
                C_ContentTracking.StartTracking(Enum.ContentTrackingType.Decor, recordID)
            end
            C_Timer.After(0.2, function()
                local isTrackable = C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, recordID)
                b.texture:SetDesaturated(not isTrackable)
                b.texture:SetAlpha(isTrackable and 1 or 0.5)
            end)
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
    end)

    WoWTools_DataMixin:Hook(HousingCatalogDecorEntryMixin, 'UpdateVisuals', function(btn)

        local isTrackable= nil
        local placementCost, r,g,b, show, isXP, isIndoors, isOutdoors, isCanDelete, isNotAsset
        local entryInfo= not self:Save().disabledHousingItemsPlus and btn:HasValidData() and btn.entryInfo

        if entryInfo then
            show= ContentTrackingUtil.IsContentTrackingEnabled()--追踪当前可用
                and C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)--追踪功能对此物品可用

            isTrackable= show and C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)--正在追踪

            r,g,b= WoWTools_ItemMixin:GetColor(entryInfo.quality)
            placementCost= entryInfo.placementCost

            if btn.IsBundleEntry and btn:IsBundleEntry() then--12.0没有了 IsBundleEntry 
            elseif btn.IsInMarketView and btn:IsInMarketView() then
            else
                local numPlaced= entryInfo.numPlaced or 0--已放置
                local numStored=  entryInfo.numStored or 0--储存空间
                if numPlaced>0 or numStored>0 then
                    btn.InfoText:SetText(numPlaced..'/'..numStored..'|A:house-chest-icon:0:0|a')
                end
                isCanDelete= C_HousingCatalog.CanDestroyEntry(entryInfo.entryID)
            end

            isXP= entryInfo.firstAcquisitionBonus and entryInfo.firstAcquisitionBonus>0
            isIndoors= entryInfo.isAllowedIndoors
            isOutdoors= entryInfo.isAllowedOutdoors

            isNotAsset= not entryInfo.asset
        end

        btn.Background:SetVertexColor(r or 1, g or 1, b or 1, 1)
        btn.placementCostLabel:SetText(placementCost and '|A:House-Decor-budget-icon:0:0|a'..placementCost or ' ')

        btn.trackableButton:SetShown(show)
        btn.trackableButton.texture:SetDesaturated(isTrackable==false)
        btn.trackableButton.texture:SetAlpha(isTrackable==true and 1 or 0.3)

        btn.firstXP:SetShown(isXP)
        btn.Indoors:SetShown(isIndoors)
        btn.Outdoors:SetShown(isOutdoors)
        btn.notAsset:SetShown(isNotAsset)
        btn.canDelete:SetShown(isCanDelete==false)
    end)
end