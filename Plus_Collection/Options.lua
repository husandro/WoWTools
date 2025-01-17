local e= select(2, ...)

local function Save()
    return WoWTools_PlusCollectionMixin.Save
end








local function Init_Menu(self, root)
    local sub



--传家宝
    sub=root:CreateCheckbox(
        e.onlyChinese and '传家宝' or HEIRLOOMS,
    function()
        return not Save().hideHeirloom
    end, function()
        Save().hideHeirloom= not Save().hideHeirloom and true or nil
        if HeirloomsJournal and HeirloomsJournal:IsShown() then
            HeirloomsJournal:FullRefreshIfVisible()
        end
    end)
    sub:SetEnabled(not e.Is_Timerunning)

    sub:CreateCheckbox(
        e.onlyChinese and '全职业' or ALL_CLASSES,
    function()
        return not Save().hideHeirloomClassList
    end, function()
        Save().hideHeirloomClassList= not Save().hideHeirloomClassList and true or nil
        WoWTools_PlusCollectionMixin:Init_Heirloom()--传家宝 4
    end)




--外观：物品
    sub= root:CreateCheckbox(
        e.onlyChinese and '外观：物品' or format('%: %', WARDROBE, WARDROBE_ITEMS),
    function()
        return not Save().hideItems
    end, function()
        Save().hideItems= not Save().hideItems and true or nil
        WoWTools_PlusCollectionMixin:Init_Wardrober_Items()--幻化 5
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
    end)

--外观：套装
    sub= root:CreateCheckbox(
        e.onlyChinese and '外观：套装' or format('%: %', WARDROBE, WARDROBE_SETS),
    function()
        return not Save().hideSets
    end, function()
        Save().hideSets= not Save().hideSets and true or nil
        WoWTools_PlusCollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
    end)


    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PlusCollectionMixin.addName})
end







local function Init()
    local btn=WoWTools_ButtonMixin:CreateMenu(CollectionsJournalCloseButton)
    btn:SetPoint('RIGHT', CollectionsJournalCloseButton, 'LEFT')

    btn:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)

    local btn2=WoWTools_ButtonMixin:CreateMenu(WardrobeFrameCloseButton)
    btn2:SetPoint('RIGHT', WardrobeFrameCloseButton, 'LEFT')

    btn2:SetScript('OnMouseDown', function(self)
        MenuUtil.CreateContextMenu(self, Init_Menu)
    end)
end




function WoWTools_PlusCollectionMixin:Init_Options()
    Init()
end