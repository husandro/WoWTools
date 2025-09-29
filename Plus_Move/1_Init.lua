

local P_Save={
    --disabledMove=true,--禁用移动
    point={},--移动
    SavePoint= WoWTools_DataMixin.Player.husandro,--保存窗口,位置
    --moveToScreenFuori=WoWTools_DataMixin.Player.husandro,--可以移到屏幕外

    --disabledZoom=true,--禁用缩放
    scale={--缩放
        ['UIWidgetPowerBarContainerFrame']= 0.85,
        ['ZoneAbilityFrame']= 0.85,
        ['BankFrame']=0.85,
    },
    size={},
    disabledSize={},--['CharacterFrame']= true

    --notMoveAlpha=true,--是否设置，移动时，设置透明度
    alpha=0.5,
    disabledAlpha={},

    UIPanelWindows={},
    Esc={['CooldownViewerSettings']=false},--1=移除, 2=添加
}

local function Save()
    return WoWToolsSave['Plus_Move']
end








local function Init()
    WoWTools_MoveMixin:Init_AddButton()--添加，移动/缩放，按钮
    WoWTools_MoveMixin:Init_Class_Power()--职业，能量条

    for name in pairs(WoWTools_MoveMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) then
            do
                WoWTools_MoveMixin.Events[name](WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[name]=nil
        end
    end

     for name in pairs(WoWTools_MoveMixin.Frames) do
        do
            if _G[name] then
                WoWTools_MoveMixin.Frames[name](WoWTools_MoveMixin)
            elseif WoWTools_DataMixin.Player.husandro then
                print(WoWTools_MoveMixin.addName, 'Frames[|cnWARNING_FONT_COLOR:'..name..'|r]', '没有发现')
            end
        end
        WoWTools_MoveMixin.Frames[name]= nil
    end

    WoWTools_DataMixin:Hook('UpdateUIPanelPositions', function(currentFrame)
        if Save().SavePoint then
            WoWTools_MoveMixin:SetPoint(currentFrame)
        end
    end)

    Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Move']= WoWToolsSave['Plus_Move'] or P_Save

            Save().UIPanelWindows= Save().UIPanelWindows or P_Save.UIPanelWindows
            Save().Esc= Save() or P_Save.Esc

            P_Save= nil

            WoWTools_MoveMixin.addName= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)

            WoWTools_MoveMixin:Init_Options()

            if Save().disabled then
                WoWTools_MoveMixin.Events={}
                WoWTools_MoveMixin.Frames={}
                self:UnregisterAllEvents()
            end

        elseif WoWTools_MoveMixin.Events[arg1] and WoWToolsSave then
            do
                WoWTools_MoveMixin.Events[arg1](WoWTools_MoveMixin)
            end
            WoWTools_MoveMixin.Events[arg1]= nil
        end

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
        Init()
        self:UnregisterEvent(event)
    end
end)