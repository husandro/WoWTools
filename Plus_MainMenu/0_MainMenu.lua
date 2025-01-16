local id, e = ...

WoWTools_PlusMainMenuMixin={
    Save={
    plus=true,
    size=10,
    enabledMainMenuAlpha= true,
    mainMenuAlphaValue=0.5,

    --frameratePlus=true,--系统 fps plus
    --framerateLogIn=true,--自动，打开
},
addName=nil,
Labels={}
}






























local function Init()
    WoWTools_PlusMainMenuMixin:Settings()
    

    WoWTools_PlusMainMenuMixin:Init_Character()--角色
    WoWTools_PlusMainMenuMixin:Init_Professions()--专业
    WoWTools_PlusMainMenuMixin:Init_Talent()--天赋
    WoWTools_PlusMainMenuMixin:Init_Achievement()--成就
    WoWTools_PlusMainMenuMixin:Init_Quest()--任务
    WoWTools_PlusMainMenuMixin:Init_Guild()--公会
    WoWTools_PlusMainMenuMixin:Init_LFD()--地下城查找器
    WoWTools_PlusMainMenuMixin:Init_Collections()--收藏
    WoWTools_PlusMainMenuMixin:Init_EJ()--冒险指南
    WoWTools_PlusMainMenuMixin:Init_Store()--商店
    WoWTools_PlusMainMenuMixin:Init_Help()--帮助
    WoWTools_PlusMainMenuMixin:Init_Bag()--背包
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_PlusMainMenuMixin.Save= WoWToolsSave['Plus_MainMenu'] or WoWTools_PlusMainMenuMixin.Save
            WoWToolsSave[HUD_EDIT_MODE_MICRO_MENU_LABEL..' Plus']= nil--清除，旧版本数据


            WoWTools_PlusMainMenuMixin.addName= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '菜单Plus' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_MICRO_MENU_LABEL, 'Plus'))
            WoWTools_PlusMainMenuMixin:Init_Category()


            if not WoWTools_PlusMainMenuMixin.Save.disabled then
                Init()
            end
            WoWTools_PlusMainMenuMixin:Init_Framerate_Plus()--系统，fts
            
        elseif arg1=='Blizzard_Settings' then
            WoWTools_PlusMainMenuMixin:Init_Options()--初始, 选项
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_MainMenu']= WoWTools_PlusMainMenuMixin.Save
        end
    end
end)