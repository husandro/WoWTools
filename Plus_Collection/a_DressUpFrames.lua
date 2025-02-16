--试衣间, 外观列表
--DressUpFrames.lua
local e= select(2, ...)











local SlotsIcon = {
    "|A:transmog-nav-slot-head:0:0|a",--1
    "|A:transmog-nav-slot-shoulder:0:0|a",--2
    "|A:transmog-nav-slot-back:0:0|a",--3
    "|A:transmog-nav-slot-chest:0:0|a",--4
    "|A:transmog-nav-slot-shirt:0:0|a",--5
    "|A:transmog-nav-slot-tabard:0:0|a",--6
    "|A:transmog-nav-slot-wrist:0:0|a",--7
    "|A:transmog-nav-slot-hands:0:0|a",--8
    "|A:transmog-nav-slot-waist:0:0|a",--9
    "|A:transmog-nav-slot-legs:0:0|a",--10
    "|A:transmog-nav-slot-feet:0:0|a",--11
    "|T135139:0|t",--12魔杖
    '|T132392:0|t',--13单手斧
    '|A:transmog-nav-slot-mainhand:0:0|a',--14单手剑
    '|T133476:0|t',--15单手锤
    '|T132324:0|t',--16匕首
    '|T132965:0|t',--17拳套
    '|A:transmog-nav-slot-secondaryhand:0:0|a',--18副手
    '|T652302:0|t',--19副手物品    
    '|T132400:0|t',--20双手斧
    '|T135327:0|t',--21双手剑
    '|T133044:0|t',--22双手锤
    '|T135145:0|t',--23法杖
    '|T135129:0|t',--24长柄武器
    '|T135490:0|t',--25弓
    '|T135610:0|t',--26枪械
    '|T135530:0|t',--27弩
    '|A:transmog-nav-slot-enchant:0:0|a',--28 e.onlyChinese and '武器附魔' or WEAPON_ENCHANTMENT,
    '|A:ElementalStorm-Lesser-Earth:0:0|a',--29'军团再临"神器
}







local function Set_SetDetails(frame)
    if frame.setEnter or frame:IsVisible() then
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











function WoWTools_CollectionMixin:Init_DressUpFrames()--试衣间, 外观列表 a
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', Set_SetDetails)
end