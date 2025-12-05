
function WoWTools_TooltipMixin.Events:Blizzard_HousingDashboard()
    local menu= CreateFrame('DropdownButton', 'WoWToolsHousingDashboardMenuButton', HousingDashboardFrameCloseButton, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', HousingDashboardFrameCloseButton, 'LEFT')
    menu:SetupMenu(function(btn, root)
        if not btn:IsMouseOver() then
            return
        end
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

    end)
end

function WoWTools_TooltipMixin.Events:Blizzard_HousingTemplates()
    
--Blizzard_HousingCatalogEntry.lua
    WoWTools_DataMixin:Hook(HousingCatalogEntryMixin, 'OnLoad', function(btn)
        btn.InfoText:SetFontObject('GameFontWhite')--有点大
        btn.InfoText:ClearAllPoints()
        btn.InfoText:SetPoint('BOTTOMRIGHT' , -6, 2)

--是否可摧毁，此装饰无法被摧毁，也不会计入住宅收纳箱的容量限制
        btn.canDeleteLabel= btn:CreateFontString(nil, nil, 'GameFontWhite')
        btn.canDeleteLabel:SetPoint('BOTTOMRIGHT', btn.InfoText, 'TOPRIGHT')


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

        btn.CustomizeIcon:ClearAllPoints()--size 16,16
        btn.CustomizeIcon:SetPoint('TOP', btn.trackableButton, 'BOTTOM')

    --可放置，室内，提示
        btn.Indoors= btn:CreateTexture()
        btn.Indoors:SetPoint('TOP', btn.CustomizeIcon, 'BOTTOM')
        btn.Indoors:SetSize(16,16)
        btn.Indoors:SetAtlas('house-room-limit-icon')
        btn.Indoors:SetAlpha(0.7)

--可放置，室外，提示
        btn.Outdoors= btn:CreateTexture()
        btn.Outdoors:SetPoint('TOP', btn.Indoors, 'BOTTOM')
        btn.Outdoors:SetSize(16,16)
        btn.Outdoors:SetAtlas('house-outdoor-budget-icon')
        btn.Outdoors:SetAlpha(0.7)

--可获得首次收集奖励
        btn.firstXP= btn:CreateTexture()
        btn.firstXP:SetPoint('TOP', btn.Outdoors,'BOTTOM', -1, 4)
        btn.firstXP:SetSize(20,20)
        btn.firstXP:SetAtlas('GarrMission_CurrencyIcon-Xp')
        btn.firstXP:SetAlpha(0.7)

--空间，大小
        btn.placementCostLabel= btn:CreateFontString(nil, nil, 'GameFontWhite')
        btn.placementCostLabel:SetPoint('TOP', btn.firstXP, 'BOTTOM', 3, 4)
        btn.placementCostLabel:SetAlpha(0.7)
--预览不可用
        btn.notAsset= btn:CreateTexture()
        btn.notAsset:SetPoint('LEFT', btn.trackableButton, 'RIGHT')
        btn.notAsset:SetSize(16,16)
        btn.notAsset:SetAtlas('transmog-icon-hidden')
    end)

    WoWTools_DataMixin:Hook(HousingCatalogEntryMixin, 'UpdateVisuals', function(btn)
        local isTrackable= nil
        local placementCost, r,g,b, show, isXP, isIndoors, isOutdoors, canDelete, isNotAsset
        local entryInfo= btn:HasValidData() and btn.entryInfo
        
        if entryInfo or self:Save().disabledHousingItemsPlus then
            show= ContentTrackingUtil.IsContentTrackingEnabled()--追踪当前可用
                and C_ContentTracking.IsTrackable(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)--追踪功能对此物品可用

            isTrackable= show and C_ContentTracking.IsTracking(Enum.ContentTrackingType.Decor, entryInfo.entryID.recordID)--正在追踪

            r,g,b= WoWTools_ItemMixin:GetColor(entryInfo.quality)
            placementCost= entryInfo.placementCost

            if btn:IsBundleEntry() then
                --self.InfoText:SetText(self.bundleEntryInfo.quantity)
            elseif btn:IsInMarketView() then
            else
                local numPlaced= entryInfo.numPlaced or 0--已放置
                local numStored=  entryInfo.numStored or 0--储存空间
                if numPlaced>0 or numStored>0 then
                    btn.InfoText:SetText(numPlaced..'/'..numStored..'|A:house-chest-icon:0:0|a')
                end
                if entryInfo.quantity + entryInfo.remainingRedeemable > 0 and C_HousingCatalog.CanDestroyEntry(entryInfo.entryID) then
                    canDelete= (entryInfo.quantity>0 and  entryInfo.quantity or '')..'|A:Islands-MarkedArea:0:0|a'
                end
            end

            isXP= entryInfo.firstAcquisitionBonus and entryInfo.firstAcquisitionBonus>0
            isIndoors= entryInfo.isAllowedIndoors
            isOutdoors= entryInfo.isAllowedOutdoors

            isNotAsset= not entryInfo.asse
        end

        btn.Background:SetVertexColor(r or 1, g or 1, b or 1, 1)
        btn.placementCostLabel:SetText(placementCost and '|A:House-Decor-budget-icon:0:0|a'..placementCost or '')

        btn.trackableButton:SetShown(show)
        btn.trackableButton.texture:SetDesaturated(isTrackable==false)
        btn.trackableButton.texture:SetAlpha(isTrackable==true and 1 or 0.3)

        btn.firstXP:SetShown(isXP)
        btn.Indoors:SetShown(isIndoors)
        btn.Outdoors:SetShown(isOutdoors)
        btn.notAsset:SetShown(isNotAsset)

        btn.canDeleteLabel:SetText(canDelete or '')
        
    end)



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
        end
        tooltip:Show()
    end)

--列表，数量
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'OnLoad', function(frame)
        frame.numItemLabel= frame:CreateFontString(nil, nil, 'GameFontWhite')
        frame.numItemLabel:SetPoint('LEFT', frame.CategoryText, 'RIGHT', 4, 0)
    end)

    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'SetCatalogElements', function(frame)
        local num= not self:Save().disabledHousingItemsPlus and frame.ScrollBox:GetDataProviderSize()
        frame.numItemLabel:SetText(num or '')
    end)
    WoWTools_DataMixin:Hook(ScrollingHousingCatalogMixin, 'ClearCatalogData', function(frame)
        frame.numItemLabel:SetText('')
    end)
end