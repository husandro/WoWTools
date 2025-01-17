--试衣间, 外观列表
--DressUpFrames.lua
local e= select(2, ...)













local function  Set_SetDetails(frame)
    if frame.setEnter then
        return
    end
    frame.setEnter=true
    frame.Icon:EnableMouse(true)
    function frame:get_item_link()
        local link
        if self.transmogID then
            if self.item then
                link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID))
            else
                link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID))
            end
        end
        return link
    end
    frame.Icon:SetScript("OnMouseUp", function(self) self:SetAlpha(0.5) end)
    frame.Icon:SetScript("OnMouseDown", function(self, d)
        local p= self:GetParent()
        local link= p:get_item_link()
        if d=='LeftButton' then
            WoWTools_ChatMixin:Chat(link, nil, true)
        elseif d=='RightButton' then
            WoWTools_LoadUIMixin:Journal(5)
            
            local wcFrame= WardrobeCollectionFrame
            if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
                wcFrame:ClickTab(wcFrame.ItemsTab)
            end
            if p.transmogLocation then
                WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(p.transmogLocation)
            end
            WardrobeCollectionFrameSearchBox:SetText(p.name or '')
        end
        self:SetAlpha(0.3)
    end)
    frame.Icon:SetScript("OnLeave", function(self) GameTooltip_Hide() self:SetAlpha(1) end)
    frame.Icon:SetScript("OnEnter", function(self)
        local p= self:GetParent()
        local link= p:get_item_link()
        if not link then
            return
        end
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:SetHyperlink(link)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, e.Icon.left)
        if p.name then
            e.tips:AddDoubleLine(e.onlyChinese and '搜索' or SEARCH, e.Icon.right)
        end
        e.tips:Show()
        self:SetAlpha(0.5)
    end)

end











function WoWTools_PlusCollectionMixin:Init_DressUpFrames()--试衣间, 外观列表 a
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', Set_SetDetails)
end