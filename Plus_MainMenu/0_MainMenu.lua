

WoWTools_MainMenuMixin={
    Labels={}
}
local P_Save={
    plus=true,
    size=10,
    enabledMainMenuAlpha= true,
    mainMenuAlphaValue=0.7,

    --frameratePlus=true,--系统 fps plus
    --framerateLogIn=true,--自动，打开
}
--MainMenuBarMicroButtons.lua





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_MainMenu']= WoWToolsSave['Plus_MainMenu'] or P_Save

            WoWTools_MainMenuMixin.addName= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(WoWTools_Mixin.onlyChinese and '菜单Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_MICRO_MENU_LABEL, 'Plus'))

            WoWTools_MainMenuMixin:Init_Category()

            if not WoWToolsSave['Plus_MainMenu'].disabled then
                WoWTools_MainMenuMixin:Settings()
                WoWTools_MainMenuMixin:Init_Character()--角色
                WoWTools_MainMenuMixin:Init_Professions()--专业
                WoWTools_MainMenuMixin:Init_Talent()--天赋
                WoWTools_MainMenuMixin:Init_Achievement()--成就
                WoWTools_MainMenuMixin:Init_Quest()--任务
                WoWTools_MainMenuMixin:Init_Guild()--公会
                WoWTools_MainMenuMixin:Init_LFD()--地下城查找器
                WoWTools_MainMenuMixin:Init_Collections()--收藏
                WoWTools_MainMenuMixin:Init_EJ()--冒险指南
                WoWTools_MainMenuMixin:Init_Store()--商店
                WoWTools_MainMenuMixin:Init_Help()--帮助
                WoWTools_MainMenuMixin:Init_Bag()--背包

                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    WoWTools_MainMenuMixin:Init_Options()--初始, 选项
                    self:UnregisterEvent(event)
                end
            end

            WoWTools_MainMenuMixin:Init_Framerate_Plus()--系统，fts

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_MainMenuMixin:Init_Options()--初始, 选项
            self:UnregisterEvent(event)
        end
    end
end)