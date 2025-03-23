if WoWTools_AuctionHouseMixin.disabled then
    return
end


local function Set_Update(frame)
    if not frame:GetView() then
        return
    end

    for _, btn in pairs(frame:GetFrames() or {}) do

        local all, num= 0, 0
        local isRefundable= false--可退款

        for _, itemID in pairs( btn.categoryID and C_AccountStore.GetCategoryItems(btn.categoryID) or {}) do
            local itemInfo= C_AccountStore.GetItemInfo(itemID)
            if itemInfo then

                local refund= itemInfo.status == Enum.AccountStoreItemStatus.Refundable
                isRefundable = isRefundable  or refund

                all= all+1

                if itemInfo.status == Enum.AccountStoreItemStatus.Owned or refund then
                    num= num+1
                end
            end
        end
        if not btn.Text2 then
            btn.Text2= WoWTools_LabelMixin:Create(btn, {color={r=1, g=1, b=1}})
            btn.Text2:SetPoint('BOTTOMRIGHT', -4, 10)

            btn.IsRefundable= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
            btn.IsRefundable:SetPoint('TOPRIGHT', -4, -2)
            btn.IsRefundable:SetSize(14, 14)
            btn.IsRefundable:SetAtlas('UI-RefreshButton')
            btn.IsRefundable:SetScript('OnLeave', GameTooltip_Hide)
            btn.IsRefundable:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '可以退款' or PLUNDERSTORE_REFUND_BUTTON_TEXT, WoWTools_Mixin.addName)
                GameTooltip:Show()
            end)
        end
        btn.Text2:SetText(
            all>0 and (
                (all==num and '|cnGREEN_FONT_COLOR:' or '')
                ..num..'/'..all
            )
            or ''
        )
        btn.IsRefundable:SetShown(isRefundable)
    end
end


function WoWTools_AuctionHouseMixin:Init_AccountStore()
    hooksecurefunc(AccountStoreFrame.CategoryList.ScrollBox, 'Update', Set_Update)
end