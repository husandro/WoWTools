if PlayerGetTimerunningSeasonID() then
    WoWTools_DataMixin.ChallengesSpellTabs={}
    WoWTools_DataMixin.affixSchedule={}
    return
end



local P_Save= {
    --hideIns=true,--隐藏，副本，挑战，信息
    --insScale=0.8,--副本，缩放

    --hideTips=true,--提示信息
    --tipsScale=0.8,--提示信息，缩放
    rightX= 2,--右边，提示，位置
    rightY= -22,

    hidePort= not WoWTools_DataMixin.Player.husandro,--传送门
    portScale=WoWTools_DataMixin.Player.husandro and 0.85 or 1,--传送门, 缩放

    --hideKeyUI=true,--挑战,钥石,插入界面
    slotKeystoneSay=WoWTools_DataMixin.Player.husandro,--插入, KEY时, 说

    EndKeystoneSayText= WoWTools_DataMixin.Player.Region==5 and '{rt1}你们还继续吗? ' or '{rt1}Want to continue? ',
}






local function Save()
    return WoWToolsSave['Plus_Challenges']
end




--[[local function Set_Data()
    local cur= EJ_GetCurrentTier()
    local max= EJ_GetNumTiers()

    if not max or max==0 then
        return
    end

    if max and cur~=max then
        EJ_SelectTier(max)
    end

    local data={}
    local find
    for _, mapChallengeModeID in pairs(C_ChallengeMode.GetMapTable() or {}) do
        local name, mapID  = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
        if mapID and name and not WoWTools_DataMixin.ChallengesSpellTabs[mapID] then
            data[name]= mapID
            find=true
        end
    end

    if not find then
        return
    end

    local dataIndex=1
    local instanceID, name = EJ_GetInstanceByIndex(dataIndex, false)
    while instanceID ~= nil do
        dataIndex = dataIndex + 1;
        local mapID= data[name]
        if mapID then
            WoWTools_DataMixin.ChallengesSpellTabs[mapID]={ins= instanceID}
        end
        instanceID, name = EJ_GetInstanceByIndex(dataIndex, false)
    end

    if not InCombatLockdown() then
        EJ_SelectTier(cur or max)
    end
end]]



local function Init()
    WoWTools_ChallengeMixin:ChallengesUI_Info()
    WoWTools_ChallengeMixin:ChallengesUI_Porta()
    WoWTools_ChallengeMixin:ChallengesUI_Left()
    WoWTools_ChallengeMixin:ChallengesUI_Right()
    WoWTools_ChallengeMixin:ChallengesUI_Activities()
    WoWTools_ChallengeMixin:ChallengesUI_Affix()
    WoWTools_ChallengeMixin:ChallengesUI_Guild()
    WoWTools_ChallengeMixin:ChallengesUI_Menu()
    WoWTools_ChallengeMixin:ChallengesKeystoneFrame()

    Init=function()end
end

















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:RegisterEvent('CHALLENGE_MODE_START')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Challenges']= WoWToolsSave['Plus_Challenges'] or P_Save

            if PlayerGetTimerunningSeasonID() then
                self:UnregisterAllEvents()
                WoWTools_DataMixin.ChallengesSpellTabs={}
                WoWTools_DataMixin.affixSchedule={}
                return
            end

            WoWTools_ChallengeMixin.addName= '|A:UI-HUD-MicroMenu-Groupfinder-Mouseover:0:0|a'..(WoWTools_DataMixin.onlyChinese and '史诗钥石地下城' or CHALLENGES)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_ChallengeMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()

            else

                for _, tab in pairs(WoWTools_DataMixin.ChallengesSpellTabs) do
                    WoWTools_Mixin:Load({id=tab.spell, type='spell'})
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_WeeklyRewards') then
                    WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_ChallengesUI') then
                    Init()
                end
            end

        elseif arg1=='Blizzard_ChallengesUI' and WoWToolsSave then--挑战,钥石,插入界面
            Init()

        elseif arg1=='Blizzard_WeeklyRewards' and WoWToolsSave then
            WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
        end

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        WoWTools_ChallengeMixin:Say_ChallengeComplete()--挑战结束时， 显示按钮

    elseif event=='CHALLENGE_MODE_START' then --赏金, 说 Bounty
        WoWTools_ChallengeMixin:Chat_Affix()

    elseif event=='PLAYER_ENTERING_WORLD' and WoWToolsSave then
        WoWTools_ChallengeMixin:Is_HuSandro()--低等级，开启，为测试用
        WoWTools_ChallengeMixin:AvailableRewards() --打开周奖励时，提示拾取专精

--总是显示
        if Save().allShowEndKeystoneSay then
            WoWTools_ChallengeMixin:Say_ChallengeComplete()--挑战结束时， 显示按钮
        end
        self:UnregisterEvent(event)
    end
end)