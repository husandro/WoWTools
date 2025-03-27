
WoWTools_CombatMixin={}
local P_Save= {
    textScale=1.2,
    SayTime=120,--每隔
    disabledSayTime= not WoWTools_DataMixin.Player.husandro,
    --AllOnlineTime=true,--进入游戏时,提示游戏,时间

    bat={num= 0, time= 0},--战斗数据
    pet={num= 0,  win=0, capture=0},
    ins={num= 0, time= 0, kill=0, dead=0},
    afk={num= 0, time= 0},


    inCombatScale=1,--战斗中缩放
}










local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_Combat']= WoWToolsSave['ChatButton_Combat'] or P_Save

            WoWTools_CombatMixin.addName= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(WoWTools_DataMixin.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO))
            WoWTools_CombatMixin.CombatButton= WoWTools_ChatMixin:CreateButton('Combat', WoWTools_CombatMixin.addName)

            if WoWTools_CombatMixin.CombatButton then--禁用Chat Button
                if WoWToolsSave['ChatButton_Combat'].SayTime==0 then
                    WoWToolsSave['ChatButton_Combat'].disabledSayTime= true
                    WoWToolsSave['ChatButton_Combat'].SayTime=120
                end

                if WoWToolsSave['ChatButton_Combat'].AllOnlineTime or not WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Time.totalTime then--总游戏时间
                    RequestTimePlayed()
                end

                WoWTools_CombatMixin:Init_Button()
                WoWTools_CombatMixin:Init_TrackButton()
                WoWTools_CombatMixin:Init_SetupMenu()
            end
            self:UnregisterEvent(event)
        end
    end
end)