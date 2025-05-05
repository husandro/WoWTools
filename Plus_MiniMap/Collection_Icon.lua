local function Save()
    return  WoWToolsSave['Minimap_Plus']
end





local function Init()
    if not Save().collectionIcon then
        return
    end


    Init=function()end
end








function WoWTools_MinimapMixin:Init_Collection_Icon()
    Init()
end
