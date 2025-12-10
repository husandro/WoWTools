local P_Save={
    --hideHeirloom= true,--传家宝
    --hideSets= true,--套装, 幻化, 界面
    --hideItems= true,--物品, 幻化, 界面
    --Heirlooms_Class_Scale=1,
    --Wardrober_Items_Labels_Scale=1, 
    hideTransmogModelName= not WoWTools_DataMixin.Player.husandro,
}
local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
end








local function Refresh_Pet()
    WoWTools_CollectionMixin:Init_Pet()
    if PetJournal and PetJournal:IsVisible() then
        do
            WoWTools_DataMixin:Call('PetJournal_OnHide', PetJournal)
        end
        WoWTools_DataMixin:Call('PetJournal_OnShow', PetJournal)
        --WoWTools_DataMixin:Call(PetJournal_UpdateAll)
    end
end




local function Init_Menu(self, root)
    if not self:IsMouseOver() then return end

    local sub
--宠物

    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '宠物' or PETS,
    function()
        return not Save().hidePets
    end, function()
        Save().hidePets= not Save().hidePets and true or nil
        Refresh_Pet()
        return MenuResponse.Open
    end)

    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().petListIconSize or 18
        end, setValue=function(value)
            Save().petListIconSize=value
            if not Save().hidePets then
                Refresh_Pet()
            end
        end,
        name=WoWTools_DataMixin.onlyChinese and '图标' or EMBLEM_SYMBOL,
        minValue=0,
        maxValue=47,
        step=1,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '宠物列表' or PROFESSIONS_CURRENT_LISTINGS )
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '技能图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ABILITIES, EMBLEM_SYMBOL))
        end

    })
    sub:CreateSpacer()

    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '重置' or RESET,
    function()
        Save().petListIconSize=nil
        Refresh_Pet()
    end)

--传家宝
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '传家宝' or HEIRLOOMS,
    function()
        return not Save().hideHeirloom
    end, function()
        Save().hideHeirloom= not Save().hideHeirloom and true or nil
        if HeirloomsJournal and HeirloomsJournal:IsShown() then
            HeirloomsJournal:FullRefreshIfVisible()
        end
    end)
    sub:SetEnabled(not PlayerIsTimerunning())

    sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '全职业' or ALL_CLASSES,
    function()
        return not Save().hideHeirloomClassList
    end, function()
        Save().hideHeirloomClassList= not Save().hideHeirloomClassList and true or nil
        WoWTools_CollectionMixin:Init_Heirloom()--传家宝 4
    end)




--外观：物品
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '外观：物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WARDROBE, WARDROBE_ITEMS),
    function()
        return not Save().hideItems
    end, function()
        Save().hideItems= not Save().hideItems and true or nil
        WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化 5
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
    end)

--外观：套装
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '外观：套装' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WARDROBE, WARDROBE_SETS),
    function()
        return not Save().hideSets
    end, function()
        Save().hideSets= not Save().hideSets and true or nil
        WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
    end)


    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_CollectionMixin.addName})
end








local function Init()
    WoWTools_CollectionMixin:Init_Mount()--坐骑 1
    WoWTools_CollectionMixin:Init_Pet()--宠物 2
    WoWTools_CollectionMixin:Init_ToyBox()--玩具 3
    WoWTools_CollectionMixin:Init_Heirloom()--传家宝 4
    WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化,物品 5
    WoWTools_CollectionMixin:Init_Wardrober_Sets()--幻化,套装 5


    local btn= CreateFrame('DropdownButton', 'WoWToolsCollectionsJournalMenuButton', CollectionsJournalCloseButton, 'WoWToolsMenuTemplate')
    --WoWTools_ButtonMixin:Menu(CollectionsJournalCloseButton)
    btn:SetPoint('RIGHT', CollectionsJournalCloseButton, 'LEFT')

    btn:SetupMenu(Init_Menu)

    if WardrobeFrameCloseButton then--12.0没有了
        btn=CreateFrame('DropdownButton', 'WoWToolsWardrobeFrameMenuButton', WardrobeFrameCloseButton, 'WoWToolsMenuTemplate')
        --WoWTools_ButtonMixin:Menu(WardrobeFrameCloseButton)
        btn:SetPoint('RIGHT', WardrobeFrameCloseButton, 'LEFT')
        btn:SetupMenu(Init_Menu)
    end

    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Collection']= WoWToolsSave['Plus_Collection'] or P_Save
            P_Save=nil

            WoWTools_CollectionMixin.addName= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战团收藏' or COLLECTIONS)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_CollectionMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_CollectionMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)
            else
                WoWTools_CollectionMixin:Init_DressUpFrames()--试衣间, 外观列表
                WoWTools_CollectionMixin:Init_Transmog()

                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    Init()
                    self:SetScript('OnEvent', nil)
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_Collections' and WoWToolsSave then
            Init()
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)