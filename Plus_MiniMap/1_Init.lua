WoWTools_MinimapMixin={}



local P_Save={
    scale=WoWTools_DataMixin.Player.husandro and 1 or 0.85,
    ZoomOut=true,--更新地区时,缩小化地图
    ZoomOutInfo=true,--小地图, 缩放, 信息

    vigentteButton=WoWTools_DataMixin.Player.husandro,
    vigentteButtonShowText=true,
    vigentteSound= WoWTools_DataMixin.Player.husandro,--播放声音
    vigentteButtonTextScale=1,
    hideVigentteCurrentOnMinimap=nil,--当前，小地图，标记
    hideVigentteCurrentOnWorldMap=nil,--当前，世界地图，标记
    questIDs={},--世界任务, 监视, ID {[任务ID]=true}
    areaPoiIDs={[7943]= 2248},--{[areaPoiID]= 地图ID}
    uiMapIDs= {},--地图ID 监视, areaPoiIDs，
    currentMapAreaPoiIDs=true,--当前地图，监视, areaPoiIDs，
    textToDown= WoWTools_DataMixin.Player.husandro,--文本，向下

    miniMapPoint={},--保存小图地, 按钮位置

    --disabledInstanceDifficulty=true,--副本，难图，指示
    --hideMPortalRoomLabels=true,--'10.2 副本，挑战专送门'


    --时钟
    useServerTimer=true,--小时图，使用服务器, 时间

    --秒表
    StopwatchOnClickPause=WoWTools_DataMixin.Player.husandro,--移过暂停

    hideExpansionLandingPageMinimapButton= true,--隐藏，图标
    --moveExpansionLandingPageMinimapButton=true,--移动动图标

    moving_over_Icon_show_menu=WoWTools_DataMixin.Player.husandro,--移过图标时，显示菜单

    Icons={--收集图标
        noAdd={--过滤
            --['BugSack']=true,
        },
        hideAdd={--隐藏
            ['WoWTools']=true,
        },
        userAdd={},--自定义
        numLine=1,
        hideInMove= not WoWTools_DataMixin.Player.husandro,--移动时，隐藏
        hideInCombat=not WoWTools_DataMixin.Player.husandro,--进入战斗，隐藏
        isEnterShow=true,--Enter显示
        alphaBG=0,--bg
        bgAlpha=0.75,--收集图标
        borderAlpha=0.5,
        bgAlpha2=0.75,--Minimap上
        borderAlpha2=0.5,
    },
}



local function Save()
    return  WoWToolsSave['Minimap_Plus']
end













local function Init()
    for questID in pairs(Save().questIDs or {}) do
        WoWTools_Mixin:Load({id= questID, type=='quest'})
    end
    do
        WoWTools_MinimapMixin:Init_Icon()--添加，图标
    end

    WoWTools_MinimapMixin:Init_InstanceDifficulty()--副本，难度，指示
    WoWTools_MinimapMixin:Init_TrackButton()--小地图, 标记, 文本
    WoWTools_MinimapMixin:Init_ExpansionLanding()
    WoWTools_MinimapMixin:Init_Minimap_Zoom()--缩放数值, 缩小化地图

--CVar 镇民
    Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(_, root)
        local sub=root:CreateCheckbox(
            (InCombatLockdown() and '|cff606060' or '')
            ..(WoWTools_DataMixin.onlyChinese and '镇民' or TOWNSFOLK_TRACKING_TEXT)
            ..WoWTools_DataMixin.Icon.icon2,
        function()
            return C_CVar.GetCVarBool("minimapTrackingShowAll") and true or false
        end, function()
            if not InCombatLockdown() then
                if C_CVar.SetCVar('minimapTrackingShowAll', not C_CVar.GetCVarBool("minimapTrackingShowAll") and '1' or '0' ) then
                    return MenuResponse.CloseAll
                end
            end
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(WoWTools_MinimapMixin.addName..WoWTools_DataMixin.Icon.icon2)
            tooltip:AddLine([[SetCVar("minimapTrackingShowAll", "1")]])
        end)
        sub:AddInitializer(function(button)
            local rightTexture = button:AttachTexture()
            rightTexture:SetSize(20, 20)
            rightTexture:SetPoint("RIGHT")
            rightTexture:SetAtlas('poi-town')
            local fontString = button.fontString
            fontString:SetPoint("RIGHT", rightTexture, "LEFT")
        end)
    end)

    Init=function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Minimap_Plus']= WoWToolsSave['Minimap_Plus'] or P_Save

            Save().Icons= Save().Icons or P_Save.Icons
            
            Save().MajorFactionRenownFrame_Button_Scale=nil
			Save().hide_MajorFactionRenownFrame_Button=nil
            Save().Icons.hideBackground= nil

            WoWTools_MinimapMixin.addName= '|A:UI-HUD-Minimap-Tracking-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '小地图' or HUD_EDIT_MODE_MINIMAP_LABEL)
            WoWTools_MinimapMixin.addName2= '|A:VignetteKillElite:0:0|a'..(WoWTools_DataMixin.onlyChinese and '追踪' or TRACKING)

           WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_MinimapMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..WoWTools_MinimapMixin.addName,
                            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                        )
                    else
                        Init()
                        WoWTools_MinimapMixin:Init_TimeManager()--秒表
                        WoWTools_MinimapMixin:Init_Collection_Icon()--收集插件图标
                    end

                end,
                buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    if StopwatchFrame.rest_point then
                        StopwatchFrame:rest_point()
                    end

                    WoWTools_MinimapMixin:Rest_TimeManager_Point()--重置，TimeManager位置
                    WoWTools_MinimapMixin:Rest_TrackButton_Point()--重置，TrackButton位置

                    Save().Icons.point=nil
                    WoWTools_MinimapMixin:Init_Collection_Icon()--重置，收集图标，按钮位置
                    
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_MinimapMixin.addName,
                        WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
                    )
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()

            else
                Init()

                if C_AddOns.IsAddOnLoaded('Blizzard_TimeManager') then
                    WoWTools_MinimapMixin:Init_TimeManager()--秒表
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_TimeManager' and WoWToolsSave then
            WoWTools_MinimapMixin:Init_TimeManager()--秒表
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
        WoWTools_MinimapMixin:Init_Collection_Icon()--收集插件图标
        self:UnregisterEvent(event)
    end
end)