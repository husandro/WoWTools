local id, e = ...
local addName= CHARACTER
WoWTools_PaperDollMixin={
Save={
    --hide=true,--隐藏CreateTexture

    --EquipmentH=true, --装备管理, true横, false坚
    equipment= e.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1,--装备管理, 缩放
    trackButtonShowItemLeve= e.Player.husandro,--装等
    --trackButtonStrata='',

    --notStatusPlus=true,--禁用，属性 PLUS
    StatusPlus_OnEnter_show_menu=true,--移过图标时，显示菜单

    --notStatusPlusFunc=true, --属性 PLUS Func
    itemLevelBit= 1,--物品等级，位数

},

}

local function Save()
    return WoWTools_PaperDollMixin.Save
end


local panel= CreateFrame("Frame", nil, PaperDollFrame)



--[[local function Is_Load_ElvUI(btn)
    if C_AddOns.IsAddOnLoaded('ElvUI') and not btn.icon then
        btn.icon= btn:CreateTexture()
    end
end]]











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


    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
        WoWTools_PaperDollMixin:Settings_Tab2()--总装等
        WoWTools_PaperDollMixin:Settings_Tab3()
    end)

    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function()--装备管理
        WoWTools_PaperDollMixin:Settings_Tab3()
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    end)
    hooksecurefunc('GearSetButton_SetSpecInfo', function()--装备管理,修该专精
        WoWTools_PaperDollMixin:Settings_Tab3()
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    end)

    C_Timer.After(2, function()
        WoWTools_PaperDollMixin:Init_TrackButton()--装备管理框
    end)
end



























--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            if WoWToolsSave[CHARACTER] then
                WoWTools_PaperDollMixin.Save= WoWToolsSave[CHARACTER]
                WoWToolsSave[CHARACTER]=nil
                
            else
                WoWTools_PaperDollMixin.Save= WoWToolsSave['Plus_PaperDoll'] or WoWTools_PaperDollMixin.Save
            end

            WoWTools_PaperDollMixin.addName= (
                e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a'
                or '|A:charactercreate-gendericon-female-selected:0:0|a'
            )..(e.onlyChinese and '角色' or addName)
            
            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_PaperDollMixin.addName,
                --tooltip= WoWTools_PaperDollMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_PaperDollMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            })



            if not WoWTools_PaperDollMixin.disabled then
                Init()
                self:RegisterEvent('SOCKET_INFO_UPDATE')--宝石，更新    
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_PaperDoll']= Save()
        end

    elseif event=='SOCKET_INFO_UPDATE' then--宝石，更新
        if PaperDollItemsFrame:IsShown() then
            e.call(PaperDollFrame_UpdateStats)
        end
    end
end)
