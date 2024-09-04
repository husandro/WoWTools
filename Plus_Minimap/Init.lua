
local id, e = ...

WoWTools_MinimapMixin={
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


       --disabledClockPlus=true,--时钟，秒表
       --时钟
       useServerTimer=true,--小时图，使用服务器, 时间
       --TimeManagerClockButtonScale=1--缩放
       --TimeManagerClockButtonPoint={}--位置

       --秒表
       --showStopwatchFrame=true,--加载游戏时，显示秒表
       --StopwatchFrameScale=1,--缩放

       hideExpansionLandingPageMinimapButton= true,--隐藏，图标
       --moveExpansionLandingPageMinimapButton=true,--移动动图标

       moving_over_Icon_show_menu=e.Player.husandro,--移过图标时，显示菜单
       --hide_MajorFactionRenownFrame_Button=true,--隐藏，派系声望，列表，图标
       --MajorFactionRenownFrame_Button_Scale=1,--缩放
}
}





function WoWTools_MinimapMixin:Init()
    self:Init_InstanceDifficulty()--副本，难度，指示
    self:Init_TrackButton()--小地图, 标记, 文本
end



--加载保存数据
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            WoWTools_MinimapMixin.adddName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)
            WoWTools_MinimapMixin.addName2= '|A:VignetteKillElite:0:0|a'..(e.onlyChinese and '追踪' or TRACKING)
--清除，旧版本，数据
            if WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL]  then
                WoWTools_MinimapMixin.Save= WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL]
                WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL] =nil
            else
                WoWTools_MinimapMixin.Save= WoWToolsSave['Minimap_Plus'] or WoWTools_MinimapMixin.Save
            end
--添加控制面板
            e.AddPanel_Check({
                name= WoWTools_MinimapMixin.adddName,
                GetValue= function() return WoWTools_MinimapMixin.Save.disabled end,
                SetValue= function()
                    WoWTools_MinimapMixin.Save.disabled= not WoWTools_MinimapMixin.Save.disabled and true or nil
                    print(WoWTools_MinimapMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not WoWTools_MinimapMixin.Save.disabled then
                for questID in pairs(WoWTools_MinimapMixin.Save.questIDs or {}) do
                    e.LoadData({id= questID, type=='quest'})
                end
                WoWTools_MinimapMixin:Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Minimap_Plus']= WoWTools_MinimapMixin.Save
        end

    end
end)











--[[



function WoWTools_MinimapMixin:OnEvent(frame, event, arg1)
    print(frame==panel, frame,panel,arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            self.adddName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(e.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)
            self.addName2= '|A:VignetteKillElite:0:0|a'..(e.onlyChinese and '追踪' or TRACKING)
--清除，旧版本，数据
            if WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL]  then
                self.Save= WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL]
                WoWToolsSave[HUD_EDIT_MODE_MINIMAP_LABEL] =nil
            else
                self.Save= WoWToolsSave['Minimap_Plus'] or self.Save
            end
--添加控制面板
            e.AddPanel_Check({
                name= self.adddName,
                GetValue= function() return self.Save.disabled end,
                SetValue= function()
                    self.Save.disabled= not self.Save.disabled and true or nil
                    print(self.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if not self.Save.disabled then
                for questID in pairs(self.Save.questIDs or {}) do
                    e.LoadData({id= questID, type=='quest'})
                end
                self:Init()
            end
            frame:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Minimap_Plus']= self.Save
        end

    end
end
]]