
WoWTools_MoveMixin={
    Events={}
}

local P_Save={
    --disabledMove=true,--禁用移动
    point={},--移动
    SavePoint= WoWTools_DataMixin.Player.husandro,--保存窗口,位置
    moveToScreenFuori=WoWTools_DataMixin.Player.husandro,--可以移到屏幕外

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

    UIPanelWindows={}
}

local function Save()
    return WoWToolsSave['Plus_Move']
end








local function Init()
    --WoWTools_MoveMixin:Init_Communities()--公会和社区
    WoWTools_MoveMixin:Init_WorldMapFrame()--世界地图
    WoWTools_MoveMixin:Init_CharacterFrame()--角色
    WoWTools_MoveMixin:Init_FriendsFrame()--好友列表
    WoWTools_MoveMixin:Init_PVEFrame()--地下城和团队副本
    WoWTools_MoveMixin:Init_QuestFrame()--任务
    WoWTools_MoveMixin:Init_AddButton()--添加，移动/缩放，按钮
    WoWTools_MoveMixin:Init_Other()
    WoWTools_MoveMixin:Init_Class_Power()--职业，能量条

    for name in pairs(WoWTools_MoveMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) then
            WoWTools_MoveMixin.Events[name]()
            WoWTools_MoveMixin.Events[name]=nil
        end
    end

    hooksecurefunc('UpdateUIPanelPositions', function(currentFrame)
        if Save().SavePoint then
            WoWTools_MoveMixin:SetPoint(currentFrame)
        end
    end)

    Init=function()end
end





local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Move']= WoWToolsSave['Plus_Move'] or P_Save
            Save().UIPanelWindows= Save().UIPanelWindows or {}

            WoWTools_MoveMixin.addName= '|TInterface\\Cursor\\UI-Cursor-Move:0|t'..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)

            WoWTools_MoveMixin:Init_Options()

            if Save().disabled then
                WoWTools_MoveMixin.Events={}
                self:UnregisterEvent(event)
            else
                Init()--初始, 移动
            end

        elseif WoWToolsSave and WoWTools_MoveMixin.Events[arg1] then
            do
                WoWTools_MoveMixin.Events[arg1]()
            end
            WoWTools_MoveMixin.Events[arg1]= nil
        end
    end
end)