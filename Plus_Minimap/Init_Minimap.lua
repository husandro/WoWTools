
local id, e = ...

WoWTools_MinimapMixin={
    addName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..HUD_EDIT_MODE_MINIMAP_LABEL,
    addName2= '|A:VignetteKillElite:0:0|a'..TRACKING,
Save={
    scale=e.Player.husandro and 1 or 0.85,
    ZoomOut=true,--更新地区时,缩小化地图
    ZoomOutInfo=true,--小地图, 缩放, 信息

    vigentteButton=e.Player.husandro,
    vigentteButtonShowText=true,
    vigentteSound= e.Player.husandro,--播放声音
    vigentteButtonTextScale=1,
    hideVigentteCurrentOnMinimap=nil,--当前，小地图，标记
    hideVigentteCurrentOnWorldMap=nil,--当前，世界地图，标记
    questIDs={},--世界任务, 监视, ID {[任务ID]=true}
    areaPoiIDs={[7492]= 2025},--{[areaPoiID]= 地图ID}
    uiMapIDs= {},--地图ID 监视, areaPoiIDs，
    currentMapAreaPoiIDs=true,--当前地图，监视, areaPoiIDs，
    textToDown= e.Player.husandro,--文本，向下

    miniMapPoint={},--保存小图地, 按钮位置

    --disabledInstanceDifficulty=true,--副本，难图，指示
    --hideMPortalRoomLabels=true,--'10.2 副本，挑战专送门'


    --时钟
    useServerTimer=true,--小时图，使用服务器, 时间

    --秒表
    StopwatchOnClickPause=e.Player.husandro,--移过暂停

    hideExpansionLandingPageMinimapButton= true,--隐藏，图标
    --moveExpansionLandingPageMinimapButton=true,--移动动图标

    moving_over_Icon_show_menu=e.Player.husandro,--移过图标时，显示菜单
    --hide_MajorFactionRenownFrame_Button=true,--隐藏，派系声望，列表，图标
    --MajorFactionRenownFrame_Button_Scale=1,--缩放

    --Initializer
},

Init_InstanceDifficulty=function()end,

Init_TimeManager=function()end,
Show_TimeManager_Menu=function()end,
Rest_TimeManager_Point=function()end,

Init_TrackButton=function()end,
Rest_TrackButton_Point=function()end,
Init_Icon=function()end,

Init_CovenantRenown=function()end,
}






local function Init_Menu(self, root)
    WoWTools_MinimapMixin:Garrison_Menu(self, root)
end


function WoWTools_MinimapMixin:Open_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end


--打开选项界面
function WoWTools_MinimapMixin:OpenPanel(root)
    return WoWTools_MenuMixin:OpenOptions(root, {name=self.addName})
end


function WoWTools_MinimapMixin:Init()
    self:Init_InstanceDifficulty()--副本，难度，指示
    self:Init_TrackButton()--小地图, 标记, 文本
    self:Init_Icon()
end




















--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_MinimapMixin.addName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)
            WoWTools_MinimapMixin.addName2= '|A:VignetteKillElite:0:0|a'..(e.onlyChinese and '追踪' or TRACKING)
--清除，旧版本，数据
            if WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL]  then
                WoWTools_MinimapMixin.Save= WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL]
                WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL] =nil
            else
                WoWTools_MinimapMixin.Save= WoWToolsSave['Minimap_Plus'] or WoWTools_MinimapMixin.Save
            end
--添加控制面板
            --[[WoWTools_MinimapMixin.Initializer= e.AddPanel_Check({
                name= WoWTools_MinimapMixin.addName,
                GetValue= function() return WoWTools_MinimapMixin.Save.disabled end,
                SetValue= function()
                    WoWTools_MinimapMixin.Save.disabled= not WoWTools_MinimapMixin.Save.disabled and true or nil
                    print(WoWTools_MinimapMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })]]

           e.AddPanel_Check_Button({
                checkName= WoWTools_MinimapMixin.addName,
                GetValue= function() return not WoWTools_MinimapMixin.Save.disabled end,
                SetValue= function()
                    WoWTools_MinimapMixin.Save.disabled= not WoWTools_MinimapMixin.Save.disabled and true or nil
                    print(WoWTools_MinimapMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    if StopwatchFrame.rest_point then
                        StopwatchFrame:rest_point()
                    end
                    WoWTools_MinimapMixin:Rest_TimeManager_Point()--重置，TimeManager位置
                    WoWTools_MinimapMixin:Rest_TrackButton_Point()--重置，TrackButton位置
                    print(e.addName, self.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end
            })


            if WoWTools_MinimapMixin.Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')

            else
                for questID in pairs(WoWTools_MinimapMixin.Save.questIDs or {}) do
                    e.LoadData({id= questID, type=='quest'})
                end
                WoWTools_MinimapMixin:Init()


                if C_AddOns.IsAddOnLoaded('Blizzard_TimeManager') then--秒表
                    WoWTools_MinimapMixin:Init_TimeManager()
                end
            end


        elseif arg1=='Blizzard_TimeManager' then
            WoWTools_MinimapMixin:Init_TimeManager()--秒表

        elseif arg1=='Blizzard_MajorFactions' then
           -- WoWTools_MinimapMixin:Init_MajorFactionRenownFrame()

        elseif arg1=='Blizzard_CovenantRenown' then
            WoWTools_MinimapMixin:Init_CovenantRenown()

        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Minimap_Plus']= WoWTools_MinimapMixin.Save
        end

    end
end)













