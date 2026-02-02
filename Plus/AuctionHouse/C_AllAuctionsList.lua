--所有，出售物品, 列表








  --[[双击，取消拍卖
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
end]]

local function get_auctionID()
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
        local itemLink, itemID, battlePetSpeciesID = WoWTools_AuctionHouseMixin:GetItemLink(tab[1])
        local isPet= battlePetSpeciesID and true or false
        return auctionID, itemLink, itemID, isPet
    end
end


--[[
/run if not CA then local f=CreateFrame("Button","CA",nil,"SecureActionButtonTemplate")
f:SetAttribute("type","click")
f:SetAttribute("clickbutton",AuctionHouseFrame.AuctionsFrame.CancelAuctionButton)end
/click CA LeftButton 1
/click StaticPopup1Button1
]]

local function Cancel_Auction()
   local auctionID, itemLink= get_auctionID()
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

    function cancelButton:set_tooltips()
        if not self:IsMouseOver() then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:ClearLines()
        local itemLink, itemID, isPet= select(2, get_auctionID())
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
        Cancel_Auction()
        self:set_tooltips()
    end)
    WoWTools_TextureMixin:SetUIButton(cancelButton)

--[[
    local all= CreateFrame('Button', 'WoWToolsAuctionHouseAllCancelButton', cancelButton, 'UIPanelButtonTemplate')
    all:SetPoint('RIGHT', cancelButton, 'LEFT', -2, 0)
    all:SetSize(100,22)
    all.text=WoWTools_DataMixin.onlyChinese and '全部取消' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, CANCEL)
    all:SetText(all.text)

    function all:Stop()
        self.isRun= nil
        self:set_event()
    end

    hooksecurefunc(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox, 'SetDataProvider', function()
        if all.isRun then
            print('a')
            Cancel_Auction()
        end
    end)

    function all:set_event()
        if self.isRun then
            --self:RegisterEvent('AUCTION_HOUSE_THROTTLED_SYSTEM_READY')
            self:SetScript('OnUpdate', function(b)
                if IsModifierKeyDown() or C_AuctionHouse.GetNumOwnedAuctions()==0 then
                    self:Stop()
                end
            end)
            self:SetText('...')
        else
            self:UnregisterAllEvents()
            self:SetScript('OnUpdate', nil)
            self:SetText(self.text)
        end
    end

    all:SetScript('OnHide', all.Stop)
    all:SetScript('OnClick', function(self)
        self.isRun = not self.isRun and true or nil
        --all:set_event()
        if self.isRun then
            Cancel_Auction()
        end
    end)

    all:SetScript('OnEvent', function(self)
        if not self.time or self.time:IsCancelled() then
            self.time= C_Timer.NewTimer(2, function()
                Cancel_Auction()
            end)
        end
    end)
    WoWTools_TextureMixin:SetUIButton(all)]]
    Init_Cancel_Button= function()end
end




















local function Init()
    if WoWToolsSave['Plus_AuctionHouse'].disabledAuctionsPlus then
        return
    end

--移动，刷新，按钮
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:ClearAllPoints()
    AuctionHouseFrameAuctionsFrame.AllAuctionsList.RefreshFrame.RefreshButton:SetPoint('RIGHT', AuctionHouseFrameAuctionsFrame.CancelAuctionButton, 'LEFT', -4, 0)


--双击，取消拍卖
    for _, frame in pairs({
        AuctionHouseFrameAuctionsFrame.AllAuctionsList,
        AuctionHouseFrameAuctionsFrame.ItemList,
        AuctionHouseFrameAuctionsFrame.CommoditiesList,
    }) do

        ScrollUtil.RegisterAlternateRowBehavior(frame.ScrollBox, function(btn)
            if btn:GetScript('OnDoubleClick') then
                return
            end
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
        end)
    end
    --[[WoWTools_DataMixin:Hook(AuctionHouseFrameAuctionsFrame.AllAuctionsList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    WoWTools_DataMixin:Hook(AuctionHouseFrameAuctionsFrame.ItemList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    WoWTools_DataMixin:Hook(AuctionHouseFrameAuctionsFrame.CommoditiesList.ScrollBox, 'Update', OnDoubleClick_AllAuctionsList)
    ]]

--拍卖，数量
    local frame= CreateFrame('Frame', nil, AuctionHouseFrameAuctionsTab)
    frame:SetPoint('BOTTOMRIGHT', AuctionHouseFrameAuctionsTab, -4, 4)
    frame:SetSize(1,1)

    function frame:set_event()
        self:RegisterEvent('AUCTION_HOUSE_AUCTION_CREATED')
        self:RegisterEvent('OWNED_AUCTIONS_UPDATED')
    end
    function frame:updata_data()
        C_AuctionHouse.QueryOwnedAuctions({
            [1] = { sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = false },
            [2] = { sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false }
        })
    end

    frame.label= frame:CreateFontString('WoWToolsAuctionHouseNumOwnedLabel', 'ARTWORK', 'GameFontHighlightSmall2')
    frame.label:SetPoint('BOTTOMRIGHT')
    frame.label:SetTextColor(GREEN_FONT_COLOR:GetRGB())

    frame:SetScript('OnEvent', function(self)
        local num
        if C_AuctionHouse.HasFullOwnedAuctionResults() then
            num= C_AuctionHouse.GetNumOwnedAuctions()
            if num==0 then
                num= DISABLED_FONT_COLOR:WrapTextInColorCode('0')
            else
                num= WoWTools_DataMixin:MK(C_AuctionHouse.GetNumOwnedAuctions(), 3)
            end
        end
        self.label:SetText(num or '')
    end)
    frame:SetScript('OnShow', function(self)
        self:set_event()
        self:updata_data()
    end)
    frame:SetScript('OnHide', function(self)
        self:UnregisterAllEvents()
        self.label:SetText('')
    end)
    frame:set_event()
    frame:updata_data()





--取消,按钮
    Init_Cancel_Button()

    Init= function()end
end










--所有，出售物品, 列表
function WoWTools_AuctionHouseMixin:Init_AllAuctions()
    Init()
end