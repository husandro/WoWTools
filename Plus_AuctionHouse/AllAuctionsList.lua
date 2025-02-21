
--所有，出售物品, 列表
local e= select(2, ...)











  --双击，取消拍卖
  local function OnDoubleClick_AllAuctionsList(frame)
    if not frame:GetView() then
        return
    end
    for _, btn in pairs(frame:GetFrames() or {}) do
        if not btn.setOnDoubleClick then
            btn:SetScript('OnDoubleClick', function(self)
                if self.rowData and self.rowData.auctionID and C_AuctionHouse.CanCancelAuction(self.rowData.auctionID) then
                    local cost= C_AuctionHouse.GetCancelCost(self.rowData.auctionID)
                    local itemLink= WoWTools_AuctionHouseMixin:GetItemLink(self.rowData)
                    C_AuctionHouse.CancelAuction(self.rowData.auctionID)
                    print(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)..'|r', itemLink, cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
                end
            end)
            btn.setOnDoubleClick=true
        end
    end
end










--取消,按钮
local function Init_Cancel_Button()

    local cancelButton= WoWTools_ButtonMixin:Cbtn(AuctionHouseFrameAuctionsFrame.CancelAuctionButton, {type=false, size={100,22}, text= e.onlyChinese and '取消' or CANCEL})
    cancelButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton, 'LEFT', -4, 0)
    function cancelButton:get_auctionID()
        local tab={}
        if AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox:GetView() then
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
            local itemLink, itemID, isPet = WoWTools_AuctionHouseMixin:GetItemLink(tab[1])
            return auctionID, itemLink, itemID, isPet
        end
    end
    function cancelButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        e.tips:ClearLines()
        local itemLink, itemID, isPet= select(2, self:get_auctionID())
        if itemLink then
            if isPet then
                BattlePetToolTip_Show(BattlePetToolTip_UnpackBattlePetLink(itemLink))
            else
                e.tips:SetHyperlink(itemLink)
            end
            e.tips:AddLine(' ')
        elseif itemID then
            e.tips:SetItemByID(itemID)
            e.tips:AddDoubleLine(' ')
        end
        e.tips:AddDoubleLine(' ', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '取消拍卖将使你失去保证金。' or CANCEL_AUCTION_CONFIRMATION))
        e.tips:AddDoubleLine(e.onlyChinese and '备注' or LABEL_NOTE, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要太快' or ERR_GENERIC_THROTTLE))
        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AuctionHouseMixin.addName)
        e.tips:Show()
    end
    cancelButton:SetScript('OnLeave', GameTooltip_Hide)
    cancelButton:SetScript('OnEnter', cancelButton.set_tooltips)
    cancelButton:SetScript('OnClick', function(self)
        local auctionID, itemLink= self:get_auctionID()
        if auctionID  then
            if C_AuctionHouse.CanCancelAuction(auctionID) then
                local cost= C_AuctionHouse.GetCancelCost(auctionID)
                C_AuctionHouse.CancelAuction(auctionID)
                print(WoWTools_Mixin.addName,WoWTools_AuctionHouseMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '取消拍卖' or AUCTION_HOUSE_CANCEL_AUCTION_BUTTON)..'|r', itemLink or '', cost and cost>0 and '|cnRED_FONT_COLOR:'..GetMoneyString(cost) or '')
            else
                print(WoWTools_Mixin.addName,WoWTools_AuctionHouseMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '出错' or ERRORS)..'|r', itemLink or '')
            end
            AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:OnClick()
            self:set_tooltips()
        end
    end)
end







local function Init()
--移动，刷新，按钮
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.CancelAuctionButton, 'LEFT', -4, 0)

--取消,按钮
    Init_Cancel_Button()

--双击，取消拍卖
    hooksecurefunc(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    hooksecurefunc(AuctionHouseFrameAuctionsFrame.ItemList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    hooksecurefunc(AuctionHouseFrameAuctionsFrame.CommoditiesList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
end










--所有，出售物品, 列表
function WoWTools_AuctionHouseMixin:Init_AllAuctions()
    Init()
end