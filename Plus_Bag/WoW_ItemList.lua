

local function Init()
    local btn= WoWTools_ButtonMixin:Cbtn(ContainerFrameCombinedBags.CloseButton, {
        name= 'WoWToolsWoWItemListButton',
        atlas= 'glues-characterSelect-iconShop-hover',
    })
    btn:SetPoint('RIGHT', ContainerFrameCombinedBags.CloseButton, 'LEFT', -23, 0)
    
    btn:SetScript('OnLeave', function()
        GameTooltip_Hide()
    end)
    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_DataMixin.onlyChinese and '战团物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS))
        GameTooltip:Show()
    end)


    Init=function()end
end




function WoWTools_BagMixin:Init_WoW_ItemList()
    Init()
end