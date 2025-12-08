--TransmogWardrobeItemsMixin TransmogFrame.WardrobeCollection.TabContent.ItemsFrame
--TransmogItemModelMixin
local function Init()

    --[[WoWTools_DataMixin:Hook(TransmogFrame.WardrobeCollection.TabContent.ItemsFrame.COLLECTION_TEMPLATES.COLLECTION_ITEM, 'initFunc', function(btn, wardrobeCollection)
        WoWTools_DataMixin:Info(wardrobeCollection)
    end)]]


    local _frame= TransmogFrame.WardrobeCollection.TabContent.ItemsFrame.PagedContent
    _frame.allNumLabel= _frame.PagingControls:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    _frame.allNumLabel:SetPoint('LEFT', _frame.PagingControls.NextPageButton, 'RIGHT', 2, 0)
    WoWTools_DataMixin:Hook(_frame, 'SetDataProvider', function(frame, dataProvider)
        local collection= dataProvider:GetCollection()
        local n= collection and collection[1] and collection[1].elements and #collection[1].elements
        frame.allNumLabel:SetText(n or '')
    end)
    _frame= nil
    Init=function()end
end


--12.0才有 幻化
function WoWTools_CollectionMixin:Init_Transmog()
    if C_AddOns.IsAddOnLoaded('Blizzard_Transmog') then
        Init()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Transmog' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
    end
end

