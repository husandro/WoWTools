--试衣间, 外观列表
--DressUpFrames.lua
--DressUpCustomSetDetailsSlotMixin



local function GetItemLink(self)
    local link
    if self.transmogID then
        if type(self.item)=='table' and self.item.GetItemLink then--12.0更新如下
            link= self.item:GetItemLink()
        elseif self.item then
            link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID))
        else
            link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID))
        end
    end
    return link
end


local function Set_SetDetails(frame)
    if frame.chatButton then return end--:IsMouseEnabled() 

    frame.chatButton= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
    frame.chatButton:SetNormalAtlas('transmog-icon-chat')
    frame.chatButton:SetPoint("RIGHT")
    frame.chatButton:SetSize(18,18)
    frame.chatButton:SetAlpha(0.5)
    frame.chatButton.alpha=0.5
    frame.chatButton.tooltip=function(self, tooltip)
        local link= GetItemLink(self:GetParent())
        if link then
            tooltip:SetHyperlink(link)
        end
    end
    frame.chatButton:SetScript('OnClick', function()
        local link= GetItemLink(frame)
        if link then
            WoWTools_ChatMixin:Chat(link, nil, true)
        end
    end)

    frame.findButton= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
    frame.findButton:SetNormalAtlas('common-search-magnifyingglass')
    frame.findButton:SetPoint('RIGHT', frame.chatButton, 'LEFT')
    frame.findButton:SetSize(18,18)
    frame.findButton:SetAlpha(0.5)
    frame.findButton.alpha=0.5
    frame.findButton.tooltip=function(self, tooltip)
        local link= GetItemLink(self:GetParent())
        if link then
            tooltip:SetHyperlink(link)
        end
    end
    frame.findButton:SetScript('OnClick', function(self)
        local p= self:GetParent()
            WoWTools_LoadUIMixin:Journal(5)
        local wcFrame= WardrobeCollectionFrame
        if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
            wcFrame:ClickTab(wcFrame.ItemsTab)
        end
        if p.transmogLocation then
            WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(p.transmogLocation)
        end
        WardrobeCollectionFrameSearchBox:SetText(p.name or '')
    end)

    frame.Icon:EnableMouse(true)
    frame.Icon:SetScript("OnMouseUp", function(self)
        self:SetAlpha(0.3)
    end)

    frame.Icon:SetScript("OnMouseDown", function(self, d)
        local p= self:GetParent()
        local link= GetItemLink(p)
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
    frame.Icon:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        self:SetAlpha(1)
    end)

    frame.Icon:SetScript("OnEnter", function(self)
        local p= self:GetParent()
        local link= GetItemLink(p)
        if not link then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:SetHyperlink(link)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, WoWTools_DataMixin.Icon.left)
        if p.name then
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '搜索' or SEARCH, WoWTools_DataMixin.Icon.right)
        end
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

end













--DressUpOutfitDetailsSlotMixin 12.0没有了
--DressUpCustomSetDetailsSlotMixin 12.0才有
local function Init()
    WoWTools_DataMixin:Hook(DressUpFrameTransmogSetMixin, 'SetData', function(frame, setID, setLink, setItems)
 
    end)
    WoWTools_DataMixin:Hook(DressUpCustomSetDetailsSlotMixin or DressUpOutfitDetailsSlotMixin, 'SetDetails', Set_SetDetails)
    Init=function()end
end



function WoWTools_CollectionMixin:Init_DressUpFrames()--试衣间, 外观列表
    Init()
end