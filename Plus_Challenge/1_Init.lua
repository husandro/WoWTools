if (not WoWTools_DataMixin.Player.IsMaxLevel and not WoWTools_DataMixin.Player.husandro) or PlayerGetTimerunningSeasonID() then
    WoWTools_DataMixin.ChallengesSpellTabs={}
    return
end

for _, tab in pairs(WoWTools_DataMixin.ChallengesSpellTabs) do
    WoWTools_Mixin:Load({id=tab.spell, type='spell'})
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
}






local function Save()
    return WoWToolsSave['Plus_Challenges']
end


local function Init()

    WoWTools_ChallengeMixin:ChallengesUI_Porta()--史诗钥石地下城, 界面
    WoWTools_ChallengeMixin:ChallengesUI_Left()
    WoWTools_ChallengeMixin:ChallengesUI_Right()
    WoWTools_ChallengeMixin:ChallengesUI_Activities()
    WoWTools_ChallengeMixin:ChallengesUI_Menu()

    WoWTools_ChallengeMixin:ChallengesKeystoneFrame()
end



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('CHALLENGE_MODE_COMPLETED')
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Challenges']= WoWToolsSave['Plus_Challenges'] or P_Save

            if PlayerGetTimerunningSeasonID() then
                self:UnregisterAllEvents()
                WoWTools_DataMixin.ChallengesSpellTabs={}
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
                if C_AddOns.IsAddOnLoaded('Blizzard_WeeklyRewards') then
                    WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_ChallengesUI') then
                    Init()
                end

            end

        elseif arg1=='Blizzard_ChallengesUI' and WoWToolsSave then--挑战,钥石,插入界面
            Init()
            
            if C_AddOns.IsAddOnLoaded('Blizzard_WeeklyRewards') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_WeeklyRewards' and WoWToolsSave then
            WoWTools_ChallengeMixin:Blizzard_WeeklyRewards()

            if C_AddOns.IsAddOnLoaded('Blizzard_ChallengesUI') then
                self:UnregisterEvent(event)
            end
        end

    elseif event=='CHALLENGE_MODE_COMPLETED' then
        WoWTools_ChallengeMixin:Say_ChallengeComplete()

    elseif event=='LOADING_SCREEN_DISABLED' then
        WoWTools_ChallengeMixin:Is_HuSandro()--低等级，开启，为测试用
        WoWTools_ChallengeMixin:AvailableRewards() --打开周奖励时，提示拾取专精
        self:UnregisterEvent(event)
    end
end)










--panel:RegisterEvent('CHALLENGE_MODE_START')
--[[elseif event=='CHALLENGE_MODE_START' then -赏金, 说 Bounty
    if Save().hideKeyUI then
        return
    end
    local tab = select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}
    for _, info  in pairs(tab) do
        local activeAffixID=select(3, C_ChallengeMode.GetAffixInfo(info))
        if activeAffixID==136177 then
            C_Timer.After(6, function()
                local chat={}

                local n=GetNumGroupMembers()
                local IDs2={373113, 373108, 373116, 373121}
                for i=1, n do
                    local u= i==n and 'player' or 'party'..i
                    local name2=i==n and COMBATLOG_FILTER_STRING_M or UnitName(u)
                    if UnitExists(u) and name2 then
                        local buff
                        for _, v in pairs(IDs2) do
                            local name=WoWTools_AuraMixin:Get(u, v)
                            if  name then
                                local link= C_Spell.GetSpellLink(v)
                                if link or name then
                                    buff=i..')'..name2..': '..(link or name)
                                    break
                                end
                            end
                        end
                        buff=buff or (i..')'..name2..': '..NONE)
                        table.insert(chat, buff)
                    end
                end

                for _, v in pairs(chat) do
                    if not Save().slotKeystoneSay then
                        print(v)
                    else
                        WoWTools_ChatMixin:Chat(v)
                    end
                end
            end)
            break
        end
    end
end]]
