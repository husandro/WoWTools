local id, e = ...
WoWTools_CombatMixin={
    Save= {
    textScale=1.2,
    SayTime=120,--每隔
    disabledSayTime= not e.Player.husandro,
    --AllOnlineTime=true,--进入游戏时,提示游戏,时间

    bat={num= 0, time= 0},--战斗数据
    pet={num= 0,  win=0, capture=0},
    ins={num= 0, time= 0, kill=0, dead=0},
    afk={num= 0, time= 0},


    inCombatScale=1.3,--战斗中缩放
}
}








local function Init()
    if WoWTools_CombatMixin.Save.AllOnlineTime or not e.WoWDate[e.Player.guid].Time.totalTime then--总游戏时间
        RequestTimePlayed()
    end


    WoWTools_CombatMixin:Init_Button()
    WoWTools_CombatMixin:Init_TrackButton()
    WoWTools_CombatMixin:Init_SetupMenu()
end





local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then

            WoWTools_CombatMixin.Save= WoWToolsSave['ChatButton_Combat'] or WoWTools_CombatMixin.Save

            local addName= '|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(e.onlyChinese and '战斗信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMBAT, INFO))
            local CombatButton= WoWTools_ChatButtonMixin:CreateButton('Combat', addName)

            WoWTools_CombatMixin.CombatButton= CombatButton
            WoWTools_CombatMixin.addName= addName

            if CombatButton then--禁用Chat Button
                if WoWTools_CombatMixin.Save.SayTime==0 then
                    WoWTools_CombatMixin.Save.disabledSayTime= true
                    WoWTools_CombatMixin.Save.SayTime=120
                end

                Init()
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Combat']= WoWTools_CombatMixin.Save
        end
    end
end)