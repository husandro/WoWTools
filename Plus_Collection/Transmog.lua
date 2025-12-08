--TransmogWardrobeItemsMixin TransmogFrame.WardrobeCollection.TabContent.ItemsFrame
--TransmogItemModelMixin

local function Save()
    return WoWToolsSave['Plus_Collection']
end




local function Init()

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

