--所有，出售物品, 列表








  --双击，取消拍卖
  local function OnDoubleClick_AllAuctionsList(frame)
    if not frame:HasView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        if not btn.setOnDoubleClick then
            btn:SetScript('OnDoubleClick', function(self)
                if self.rowData and self.rowData.auctionID and C_AuctionHouse.CanCancelAuction(self.rowData.auctionID) then
                    local cost= C_AuctionHouse.GetCancelCost(self.rowData.auctionID)
                    local itemLink= WoWTools_AuctionHouseMixin:GetItemLink(self.rowData)
                    C_AuctionHouse.CancelAuction(self.rowData.auctionID)
                    print(
                        WoWTools_AuctionHouseMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)..'|r',
                        itemLink,
                        cost and cost>0 and '|cnWARNING_FONT_COLOR:'..GetMoneyString(cost) or ''
                    )
                end
            end)
            btn.setOnDoubleClick=true
        end
    end
end










--取消,按钮
local function Init_Cancel_Button()

    local cancelButton= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, {
        isUI=true,
        size={100,22},
        text= WoWTools_DataMixin.onlyChinese and '取消' or CANCEL
    })
    cancelButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton, 'LEFT', -4, 0)

    function cancelButton:get_auctionID()
        local tab={}
        if AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:HasView() then
            for _, info in pairs(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:GetFrames() or {}) do
                if info.rowData and info.rowData.auctionID and info.rowData.timeLeftSeconds and C_AuctionHouse.CanCancelAuction(info.rowData.auctionID) then
                    table.insert(tab, info.rowData)
                end
            end
        end
        table.sort(tab, function(a, b)
            return a.timeLeftSeconds< b.timeLeftSeconds
        end)
        if tab[1] and tab[1].auctionID then
            local auctionID= tab[1].auctionID
            local itemLink, itemID, _, isPet = WoWTools_AuctionHouseMixin:GetItemLink(tab[1])
            return auctionID, itemLink, itemID, isPet
        end
    end

    function cancelButton:set_tooltips()
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        local itemLink, itemID, isPet= select(2, self:get_auctionID())
        if itemLink then
            if isPet then
                BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
            else
                GameTooltip:SetHyperlink(itemLink)
            end
            GameTooltip:AddLine(' ')
        elseif itemID then
            GameTooltip:SetItemByID(itemID)
            GameTooltip:AddDoubleLine(' ')
        end
        GameTooltip:AddDoubleLine(' ', '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '取消拍卖将使你失去保证金。' or CANCEL_AUCTION_CONFIRMATION))
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '备注' or LABEL_NOTE, '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '请不要太快' or ERR_GENERIC_THROTTLE))
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_AuctionHouseMixin.addName)
        GameTooltip:Show()
    end

    cancelButton:SetScript('OnLeave', GameTooltip_Hide)
    cancelButton:SetScript('OnEnter', cancelButton.set_tooltips)
    cancelButton:SetScript('OnClick', function(self)
        local auctionID, itemLink= self:get_auctionID()
        if auctionID  then
            if C_AuctionHouse.CanCancelAuction(auctionID) then
                local cost= C_AuctionHouse.GetCancelCost(auctionID)
                C_AuctionHouse.CancelAuction(auctionID)
                print(
                    WoWTools_AuctionHouseMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)..'|r',
                    itemLink or '',
                    cost and cost>0 and '|cnWARNING_FONT_COLOR:'..GetMoneyString(cost) or ''
                )
            else
                print(
                    WoWTools_AuctionHouseMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '出错' or ERRORS)..'|r',
                    itemLink or ''
                )
            end
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:OnClick()
            self:set_tooltips()
        end
    end)
end














--拍卖，数量
local function Init_NumOwnedAuctions()
    local Label= WoWTools_LabelMixin:Create(AuctionHouseFrameAuctionsTab, {color=true})
    Label:SetPoint('LEFT', AuctionHouseFrameAuctionsTab.Text, 'RIGHT', 2, 0)

    local function set_text()
        local num
        if C_AuctionHouse.HasFullOwnedAuctionResults() then
            num= C_AuctionHouse.GetNumOwnedAuctions()
        end
        Label:SetText(num or '')
    end

    local function get_data()
        local sorts ={
            [1] = { sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = false },
            [2] = { sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false }
        }
        C_AuctionHouse.QueryOwnedAuctions(sorts)
    end
   get_data()

    AuctionHouseFrame:HookScript('OnShow', get_data)

    EventRegistry:RegisterFrameEventAndCallback("AUCTION_HOUSE_AUCTION_CREATED", get_data)

    EventRegistry:RegisterFrameEventAndCallback("OWNED_AUCTIONS_UPDATED", set_text)
end













local function Init()

--移动，刷新，按钮
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.CancelAuctionButton, 'LEFT', -4, 0)

--取消,按钮
    Init_Cancel_Button()

--双击，取消拍卖
    WoWTools_DataMixin:Hook(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    WoWTools_DataMixin:Hook(AuctionHouseFrameAuctionsFrame.ItemList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    WoWTools_DataMixin:Hook(AuctionHouseFrameAuctionsFrame.CommoditiesList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)

--拍卖，数量
    Init_NumOwnedAuctions()
end










--所有，出售物品, 列表
function WoWTools_AuctionHouseMixin:Init_AllAuctions()
    if not WoWToolsSave['Plus_AuctionHouse'].disabledAuctionsPlus then
        Init()
    end
end