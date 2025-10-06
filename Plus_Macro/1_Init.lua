


local P_Save={
    --disabled= not WoWTools_DataMixin.Player.husandro,
    toRightLeft=3, -- 1,2, 3, 4 左边 右边 默认 左|右
    spellButton=WoWTools_DataMixin.Player.husandro,
    --旧版本 mcaro={},-- {name=tab.name, icon=tab.icon, body=tab.body}
    macro={},--{[|T..icon..:0|t..name..spllID..itemName]={name=tab.name, icon=tab.icon, body=tab.body}}

    --hideBottomList=true,隐藏底部，列表
    bottomListScale=1,
}

local function Save()
    return WoWToolsSave['Plus_Macro2']
end






local function Init()
    if WoWTools_FrameMixin:IsLocked(MacroFrame) then
        EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
            WoWTools_MacroMixin:Init_Set_UI()
            WoWTools_MacroMixin:Init_Button()--宏列表，位置
            WoWTools_MacroMixin:Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
            WoWTools_MacroMixin:Init_List_Button()--命令，按钮，列表
            WoWTools_MacroMixin:Init_AddNew_Button()--创建，空，按钮
            WoWTools_MacroMixin:Init_ChangeTab()
            WoWTools_MacroMixin:Init_MacroButton_Plus()

            EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
        end)

    else
        WoWTools_MacroMixin:Init_Set_UI()
        WoWTools_MacroMixin:Init_Button()--宏列表，位置
        WoWTools_MacroMixin:Init_Select_Macro_Button()--选定宏，点击，弹出菜单，自定图标
        WoWTools_MacroMixin:Init_List_Button()--命令，按钮，列表
        WoWTools_MacroMixin:Init_AddNew_Button()--创建，空，按钮
        WoWTools_MacroMixin:Init_ChangeTab()
        WoWTools_MacroMixin:Init_MacroButton_Plus()
    end

    Init=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")




panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Macro2']= WoWToolsSave['Plus_Macro2'] or CopyTable(P_Save)
            WoWToolsSave['Plus_Macro']=nil
            P_Save= nil

            WoWTools_MacroMixin.addName= '|TInterface\\MacroFrame\\MacroFrame-Icon:0|t'..(WoWTools_DataMixin.onlyChinese and '宏' or MACRO)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_MacroMixin.addName,
                tooltip= ('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中错误' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ERRORS)))
                    ..'|r|n'..(WoWTools_DataMixin.onlyChinese and '备注：如果错误，请取消此选项' or 'note: If you get error, please disable this'),
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_MacroMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled  then
                self:UnregisterEvent(event)

            else
                if C_AddOns.IsAddOnLoaded("MacroToolkit") then
                    print(
                        WoWTools_DataMixin.addName,
                        WoWTools_MacroMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(false), 'MacroToolkit',
                        WoWTools_DataMixin.onlyChinese and '插件' or ADDONS
                    )
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_MacroUI') then
                    Init()
                    self:UnregisterEvent(event)
                end

                self:RegisterEvent("PLAYER_LOGOUT")
            end


        elseif arg1=='Blizzard_MacroUI' and WoWToolsSave then
            if InCombatLockdown() then
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
            else
                Init()
            end
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        Init()
        self:UnregisterEvent(event)

    elseif event == "PLAYER_LOGOUT" then
        if not WoWTools_DataMixin.ClearAllSave then
            local edit= _G['WoWToolsMacroPlusNoteEditBox']
            if edit and edit:IsVisible() then
                edit:Hide()
            end
        end
    end
end)