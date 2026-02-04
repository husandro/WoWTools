---@diagnostic disable: unused-function, undefined-global
local function Load_Item(self, id, isSet)
    if not C_Item.IsItemDataCachedByID(id) then
        ItemEventListener:AddCancelableCallback(id, function()
            Save_Item(self, id, isSet)
        end)
    else
        Save_Item(self, id, isSet)
    end
end