--拍卖行
local function Save()
    return WoWTools_MoveMixin.Save
end




local function Init()
    AuctionHouseFrame.CategoriesList:SetPoint('BOTTOM', AuctionHouseFrame.MoneyFrameBorder.MoneyFrame, 'TOP',0,2)
    AuctionHouseFrame.BrowseResultsFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrameAuctionsFrame.SummaryList.Background:SetPoint('BOTTOM')
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrameAuctionsFrame.BidsList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:ClearAllPoints()
    AuctionHouseFrame.WoWTokenResults.BuyoutLabel:SetPoint('BOTTOM', AuctionHouseFrame.WoWTokenResults.Buyout, 'TOP', 0, 32)
    AuctionHouseFrame.WoWTokenResults.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.CommoditiesBuyFrame.BuyDisplay.Background:SetPoint('BOTTOM')
    AuctionHouseFrame.CommoditiesBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.ItemBuyFrame.ItemList.Background:SetPoint('BOTTOMRIGHT')
    AuctionHouseFrame.ItemBuyFrame.ItemDisplay:SetPoint('RIGHT',-3, 0)
    AuctionHouseFrame.ItemBuyFrame.ItemDisplay.Background:SetPoint('RIGHT')

    hooksecurefunc(AuctionHouseFrame, 'SetDisplayMode', function(self, mode)
        local size= Save().size[self:GetName()]
        local btn= self.ResizeButton
        if not size or not btn then
            return
        end
        
        if mode==AuctionHouseFrameDisplayMode.ItemSell or mode==AuctionHouseFrameDisplayMode.CommoditiesSell then
            self:SetSize(800, 538)
            btn.minWidth = 800
            btn.minHeight = 538
            btn.maxWidth = 800
            btn.maxHeight = 538
        else
            self:SetSize(size[1], size[2])
            btn.minWidth = 600
            btn.minHeight = 320
            btn.maxWidth = nil
            btn.maxHeight = nil
        end
    end)

    WoWTools_MoveMixin:Setup(AuctionHouseFrame, {
        setSize=true,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(800, 538)
        end
    })

    WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemSellFrame, {frame=AuctionHouseFrame})
    WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemSellFrame.Overlay, {frame=AuctionHouseFrame})
    WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

    WoWTools_MoveMixin:Setup(AuctionHouseFrame.CommoditiesSellFrame, {frame=AuctionHouseFrame})
    WoWTools_MoveMixin:Setup(AuctionHouseFrame.CommoditiesSellFrame.Overlay, {frame=AuctionHouseFrame})
    WoWTools_MoveMixin:Setup(AuctionHouseFrame.CommoditiesSellFrame.ItemDisplay, {frame=AuctionHouseFrame})

    WoWTools_MoveMixin:Setup(AuctionHouseFrame.ItemBuyFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
    WoWTools_MoveMixin:Setup(AuctionHouseFrameAuctionsFrame.ItemDisplay, {frame=AuctionHouseFrame, save=true})
end




WoWTools_MoveMixin.ADDON_LOADED['Blizzard_AuctionHouseUI']= Init