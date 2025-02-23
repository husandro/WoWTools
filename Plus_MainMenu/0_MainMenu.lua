local id, e = ...

WoWTools_MainMenuMixin={
    Save={
    plus=true,
    size=10,
    enabledMainMenuAlpha= true,
    mainMenuAlphaValue=0.7,

    --frameratePlus=true,--系统 fps plus
    --framerateLogIn=true,--自动，打开
},
addName=nil,
Labels={}
}

--MainMenuBarMicroButtons.lua





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_MainMenuMixin.Save= WoWToolsSave['Plus_MainMenu'] or WoWTools_MainMenuMixin.Save

            local addName= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '菜单Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_MICRO_MENU_LABEL, 'Plus'))
            WoWTools_MainMenuMixin.addName= addName

            WoWTools_MainMenuMixin:Init_Category()

            if not WoWTools_MainMenuMixin.Save.disabled then
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
            end
            WoWTools_MainMenuMixin:Init_Framerate_Plus()--系统，fts

        elseif arg1=='Blizzard_Settings' then
            WoWTools_MainMenuMixin:Init_Options()--初始, 选项
            self:UnregisterEvent(event)

        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_MainMenu']= WoWTools_MainMenuMixin.Save
        end
    end
end)