local id, e = ...


WoWTools_PlusCollectionMixin={
    Save={
        --hideHeirloom= true,--传家宝
        --hideSets= true,--套装, 幻化, 界面
        --hideItems= true,--物品, 幻化, 界面
        

        --Heirlooms_Class_Scale=1,
        --Wardrober_Items_Labels_Scale=1, 
    },

    addName=nil
}


local function Save()
    return WoWTools_PlusCollectionMixin.Save
end




local function Init()
    WoWTools_PlusCollectionMixin:Init_Mount()--坐骑 1
    WoWTools_PlusCollectionMixin:Init_Pet()--宠物 2
    WoWTools_PlusCollectionMixin:Init_ToyBox()--玩具 3
    WoWTools_PlusCollectionMixin:Init_Heirloom()--传家宝 4
    WoWTools_PlusCollectionMixin:Init_Wardrober_Items()--幻化,物品 5
    WoWTools_PlusCollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    WoWTools_PlusCollectionMixin:Init_Options()
end






local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[COLLECTIONS] then
                WoWTools_PlusCollectionMixin.Save= WoWToolsSave[COLLECTIONS]
                WoWToolsSave[COLLECTIONS]=nil
            else
                WoWTools_PlusCollectionMixin.Save= WoWToolsSave['Plus_Collection'] or Save()
            end

            WoWTools_PlusCollectionMixin.addName= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(e.onlyChinese and '战团收藏' or COLLECTIONS)

            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_PlusCollectionMixin.addName,
                tooltip= 'Plus',
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName,WoWTools_PlusCollectionMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if not Save().disabled then
                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    Init()
                    self:UnregisterEvent('ADDON_LOADED')
                end

                WoWTools_PlusCollectionMixin:Init_DressUpFrames()--试衣间, 外观列表 a
            else
                self:UnregisterEvent('ADDON_LOADED')
            end


        elseif arg1=='Blizzard_Collections' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Collection']=Save()
        end

    end
end)
