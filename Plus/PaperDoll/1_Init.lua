local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end





local function Settings()
    WoWTools_PaperDollMixin:Settings_Tab2()--头衔数量
    WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    WoWTools_PaperDollMixin:Settings_Tab3()--标签, 内容,提示


    WoWTools_DataMixin:Call('PaperDollFrame_SetLevel')
    WoWTools_DataMixin:Call('PaperDollFrame_UpdateStats')

    for _, slot in pairs(WoWTools_PaperDollMixin.ItemButtons) do
        local btn2= _G[slot]
        if btn2 then
            WoWTools_DataMixin:Call('PaperDollItemSlotButton_Update', btn2)
        end
    end

    if InspectFrame and InspectLevelText.set_font_size then
        InspectLevelText:set_font_size()
        InspectFrame:set_status_label()--目标，属性
        InspectFrame.ShowHideButton:settings()
        if InspectFrame:IsShown() then
            WoWTools_DataMixin:Call('InspectPaperDollFrame_UpdateButtons')--InspectPaperDollFrame.lua
            WoWTools_DataMixin:Call('InspectPaperDollFrame_SetLevel')--目标,天赋 装等
        end
    end
end



local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub

    root:CreateCheckbox(
        WoWTools_PaperDollMixin.addName,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        Settings()
    end)


--装备管理
    root:CreateCheckbox(
        WoWTools_PaperDollMixin.addName2,
    function()
        return Save().equipment
    end, function()
        Save().EquipSet.disabled= not Save().EquipSet.disabled and true or nil
        WoWTools_PaperDollMixin:Init_EquipButton()
    end)


--属性
    root:CreateDivider()
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES,
    function()
        return not Save().notStatusPlus
    end, function ()
        Save().notStatusPlus= not Save().notStatusPlus and true or nil
        WoWTools_PaperDollMixin:Init_Status()
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--属性小数
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '属性小数' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, STAT_CATEGORY_ATTRIBUTES, 'Decimals'),
    function()
        return not Save().notStatusPlusFunc
    end, function ()
        Save().notStatusPlusFunc= not Save().notStatusPlusFunc and true or nil
        WoWTools_PaperDollMixin:Init_Status_Bit()
    end, {rightText= Save().itemLevelBit or -1})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '急速' or SPELL_HASTE)..': |cffffffff9037|r|cnGREEN_FONT_COLOR:[+13%]|r  13|cffff00ff.69|r%')
        tooltip:AddLine(' ')
        GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
    WoWTools_MenuMixin:SetRightText(sub)


--小数点
    local bitColor=  Save().notStatusPlusFunc and '|cff626262' or ''
    for i=-1, 4 do
        sub:CreateRadio(
            bitColor
            ..(i==-1 and (WoWTools_DataMixin.onlyChinese and '无' or NONE)
             or ((WoWTools_DataMixin.onlyChinese and '小数点 ' or 'bit ')..i)),
        function(data)
            return Save().itemLevelBit==data.bit
        end, function(data)
            Save().itemLevelBit= data.bit
            WoWTools_DataMixin:Call('PaperDollFrame_UpdateStats')
            return MenuResponse.Refresh
        end, {bit=i})
    end



 --服务器
    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '服务器' or VAS_REALM_LABEL,
    function()
        return not Save().notRealm
    end, function()
        Save().notRealm= not Save().notRealm and true or nil
        WoWTools_PaperDollMixin:Init_Reaml()
    end)



    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '等级' or LEVEL,
    function()
        return not Save().notLevel
    end, function()
        Save().notLevel= not Save().notLevel and true or nil
        WoWTools_PaperDollMixin:Init_SetLevel()--更改,等级文本

    end)
--打开选项界面
    root:CreateDivider()
    sub= WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_PaperDollMixin.addName})

--reload
    WoWTools_MenuMixin:Reload(sub)
end




















local function Init()
    --WoWTools_PaperDollMixin:Init_ShowHideButton(PaperDollItemsFrame)--显示，隐藏，按钮
    local menu= CreateFrame('DropdownButton', 'WoWToolsPaperDollMenuButton', PaperDollFrame, 'WoWToolsMenuTemplate')
    menu:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT')
    menu:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    menu:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    menu:SetupMenu(Init_Menu)


    WoWTools_PaperDollMixin:Init_EquipmentFlyout()--装备弹出
    WoWTools_PaperDollMixin:Init_Status()--属性，增强
    WoWTools_PaperDollMixin:Init_Status_Bit()--属性，位数

    WoWTools_PaperDollMixin:Init_Reaml()--服务器
    WoWTools_PaperDollMixin:Init_SetLevel()--更改,等级文本


    WoWTools_PaperDollMixin:Init_Tab1()--总装等
    WoWTools_PaperDollMixin:Init_Tab2()--头衔数量    
    WoWTools_PaperDollMixin:Init_Tab3()
    WoWTools_PaperDollMixin:Init_InspectUI()--目标, 装备

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

            WoWToolsSave['Plus_PaperDoll']= WoWToolsSave['Plus_PaperDoll'] or {
                
                
                StatusPlus_OnEnter_show_menu=true,--移过图标时，显示菜单
                itemLevelBit= 1,--物品等级，位数
                itemSlotScale=1, --栏位，按钮，缩放

                EquipSet={--装备管理，数据
                    disabled= not WoWTools_DataMixin.Player.husandro,
                    itemLevel= WoWTools_DataMixin.Player.husandro,
                }
            }

            if not Save().EquipSet then--旧数据
                Save().EquipSet= {
                    disabled= Save().equipment,
                    point= Save().Equipment,
                    toRight= Save().EquipmentH,
                    scale= Save().equipmentFrameScale,
                    strata= Save().trackButtonStrata,

                    itemLevel= Save().trackButtonShowItemLeve,
                    itemLevelScale= Save().trackButtonTextScale,
                }
                Save().equipment= nil
                Save().Equipment= nil
                Save().EquipmentH= nil
                Save().equipmentFrameScale=nil
                Save().trackButtonStrata= nil

                Save().trackButtonTextScale= nil
                Save().trackButtonShowItemLeve= nil
            end



            WoWTools_PaperDollMixin.addName= (WoWTools_DataMixin.Player.Sex==Enum.UnitSex.Female and '|A:charactercreate-gendericon-female-selected:0:0|a' or '|A:charactercreate-gendericon-male-selected:0:0|a')
                                        ..(WoWTools_DataMixin.onlyChinese and '角色' or CHARACTER)

            WoWTools_PaperDollMixin.addName2= '|A:bags-icon-equipment:0:0|a'..(WoWTools_DataMixin.onlyChinese and '装备管理' or EQUIPMENT_MANAGER)

            --WoWTools_PaperDollMixin.addName3= '|A:loottoast-arrow-orange:0:0|a'..(WoWTools_DataMixin.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES)

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

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_PaperDollMixin:Init_EquipButton()--装备管理框

        if WoWTools_DataMixin.Player.husandro then WoWTools_LoadUIMixin:OpenPaperDoll() end

        self:UnregisterEvent(event)

    elseif event=='SOCKET_INFO_UPDATE' then
        if PaperDollItemsFrame:IsShown() then
            WoWTools_DataMixin:Call('PaperDollFrame_UpdateStats')
        end
    end
end)