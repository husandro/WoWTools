WoWTools_CollectionMixin={}

local P_Save={}
    --hideHeirloom= true,--传家宝
    --hideSets= true,--套装, 幻化, 界面
    --hideItems= true,--物品, 幻化, 界面
    --Heirlooms_Class_Scale=1,
    --Wardrober_Items_Labels_Scale=1, 

local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
end

local function Init()
    WoWTools_CollectionMixin:Init_Mount()--坐骑 1
    WoWTools_CollectionMixin:Init_Pet()--宠物 2
    WoWTools_CollectionMixin:Init_ToyBox()--玩具 3
    WoWTools_CollectionMixin:Init_Heirloom()--传家宝 4
    WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化,物品 5
    WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    WoWTools_CollectionMixin:Init_Options()
    return true
end

local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Collection']= WoWToolsSave['Plus_Collection'] or P_Save
            
            WoWTools_CollectionMixin.addName= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战团收藏' or COLLECTIONS)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_CollectionMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_CollectionMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else
                WoWTools_CollectionMixin:Init_DressUpFrames()--试衣间, 外观列表 a

                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    if Init() then
                        Init=function()end
                    end
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            if Init() then
                Init=function()end
            end
            self:UnregisterEvent(event)
        end
    end
end)