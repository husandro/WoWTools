

local P_Save={
    --hide=true,--隐藏CreateTexture

    --EquipmentH=true, --装备管理, true横, false坚
    equipment= WoWTools_DataMixin.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1,--装备管理, 缩放
    trackButtonShowItemLeve= WoWTools_DataMixin.Player.husandro,--装等
    --trackButtonStrata='',

    --notStatusPlus=true,--禁用，属性 PLUS
    StatusPlus_OnEnter_show_menu=true,--移过图标时，显示菜单

    --notStatusPlusFunc=true, --属性 PLUS Func
    itemLevelBit= 1,--物品等级，位数

    itemSlotScale=1, --栏位，按钮，缩放
}


local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end




--#####
--初始化
--#####
local function Init()
    WoWTools_PaperDollMixin:Init_EquipmentFlyout()--装备弹出
    WoWTools_PaperDollMixin:Init_SetLevel()--更改,等级文本
    WoWTools_PaperDollMixin:Init_ServerInfo()--显示服务器名称--显示服务器名称，装备管理框
    WoWTools_PaperDollMixin:Init_Status_Plus()--属性，增强
    WoWTools_PaperDollMixin:Init_Duration()--总耐久度
    WoWTools_PaperDollMixin:Init_Tab1()--总装等
    WoWTools_PaperDollMixin:Init_Tab2()--头衔数量    
    WoWTools_PaperDollMixin:Init_Tab3()
    WoWTools_PaperDollMixin:Init_InspectUI()--目标, 装备
    WoWTools_PaperDollMixin:Init_ShowHideButton(PaperDollItemsFrame)--显示，隐藏，按钮
    WoWTools_PaperDollMixin:Init_Item_PoaperDll()--物品
    WoWTools_PaperDollMixin:Init_Tab3_Set_Plus()--装备管理，Plus


    WoWTools_DataMixin:Hook('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
        WoWTools_PaperDollMixin:Settings_Tab2()--总装等
        WoWTools_PaperDollMixin:Settings_Tab3()
    end)

    WoWTools_DataMixin:Hook('PaperDollEquipmentManagerPane_Update', function()--装备管理
        WoWTools_PaperDollMixin:Settings_Tab3()
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    end)
    WoWTools_DataMixin:Hook('GearSetButton_SetSpecInfo', function()--装备管理,修该专精
        WoWTools_PaperDollMixin:Settings_Tab3()
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    end)

    Init=function()end
end



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_PaperDoll']= WoWToolsSave['Plus_PaperDoll'] or P_Save
            P_Save= nil

            WoWTools_PaperDollMixin.addName= (WoWTools_DataMixin.Player.Sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')
                                        ..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_PaperDollMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end,
            })

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                Init()
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('SOCKET_INFO_UPDATE')
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
        WoWTools_PaperDollMixin:Init_TrackButton()--装备管理框
        self:UnregisterEvent(event)

    elseif event=='SOCKET_INFO_UPDATE' then
        if PaperDollItemsFrame:IsShown() then
            WoWTools_DataMixin:Call('PaperDollFrame_UpdateStats')
        end
    end
end)