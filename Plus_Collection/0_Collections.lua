local id, e = ...
WoWTools_CollectionMixin={
    Save={
        --hideHeirloom= true,--传家宝
        --hideSets= true,--套装, 幻化, 界面
        --hideItems= true,--物品, 幻化, 界面
        --Heirlooms_Class_Scale=1,
        --Wardrober_Items_Labels_Scale=1, 
    },
}

local function Save()
    return WoWTools_CollectionMixin.Save
end



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_CollectionMixin.Save= WoWToolsSave['Plus_Collection'] or Save()
            
            local addName= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '战团收藏' or COLLECTIONS)
            WoWTools_CollectionMixin.addName= addName

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else
                WoWTools_CollectionMixin:Init_DressUpFrames()--试衣间, 外观列表 a
            end

        elseif arg1=='Blizzard_Collections' then
            WoWTools_CollectionMixin:Init_Mount()--坐骑 1
            WoWTools_CollectionMixin:Init_Pet()--宠物 2
            WoWTools_CollectionMixin:Init_ToyBox()--玩具 3
            WoWTools_CollectionMixin:Init_Heirloom()--传家宝 4
            WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化,物品 5
            WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
            WoWTools_CollectionMixin:Init_Options()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Collection']=Save()
        end
    end
end)