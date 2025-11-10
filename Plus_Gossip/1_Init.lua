WoWTools_GossipMixin= {}

local P_Save={
    NPC={--禁用NPC
        ['223594']=true,
        ['150122']=true,--荣耀堡法师 50005 我必须向黑暗之门报到。
    },
    gossip= true,

    unique= true,--唯一对话
    gossipOption={--gossipID= text
        --[123201]=2,--跳过，任务
        [123176]=2,--跳过，去11.0地图任务

    },
    choice={},--PlayerChoiceFrame
    movie={},--电影
    stopMovie=true,--如果已播放，停止播放

    quest= true,
    questOption={},
    questRewardCheck={},--{任务ID= index}    
    --autoSortQuest=  WoWTools_DataMixin.Player.husandro,--仅显示当前地图任务
    autoSelectReward= WoWTools_DataMixin.Player.husandro,--自动选择奖励
    showAllQuestNum= WoWTools_DataMixin.Player.husandro,--显示所有任务数量
    
    questPlayText= WoWTools_DataMixin.Player.husandro,
    --questPlayTextStopMove=true,

    scale=1,
    --strata='MEDIUM',
    --bgAlpha=0.5,
    --point=nil,

    --not_Gossip_Text_Icon=true,--自定义，对话，文本

    Gossip_Text_Icon_Size=14,

    --Gossip_Text_Icon_cnFont=nil,--仅限，外文, 修该字体

    --delvesDifficultyMaxLevel=nil,--地下堡指定难度
}


local function Save()
    return WoWToolsSave['Plus_Gossip']
end





















local function Init()
    WoWTools_GossipMixin:Init_Gossip_Data()--自定义，对话，文本

    do
        WoWTools_GossipMixin:Init_Gossip()--对话，初始化
    end

    WoWTools_GossipMixin:Init_Quest()--任务，初始化
    WoWTools_GossipMixin:Init_QuestPlayText()
    WoWTools_GossipMixin:Init_QuestInfo_Display()--任务目标，类型提示

    if Save().gossip then
        C_Timer.After(2, function()
            if SubscriptionInterstitialFrame and SubscriptionInterstitialFrame:IsShown() then
                SubscriptionInterstitialFrame.ClosePanelButton:Click()
            end
        end)
    end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGIN")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Gossip']= WoWToolsSave['Plus_Gossip'] or P_Save
            P_Save=nil

--玩家，自定义，对话，文本
            if WoWToolsSave['Plus_Gossip'].Gossip_Text_Icon_Player then
                WoWToolsPlayerDate['GossipTextIcon']= WoWToolsSave['Plus_Gossip'].Gossip_Text_Icon_Player
                WoWToolsSave['Plus_Gossip'].Gossip_Text_Icon_Player= nil
            end
            WoWToolsPlayerDate['GossipTextIcon']= WoWToolsPlayerDate['GossipTextIcon'] or {
                [55193]={
                    icon='communities-icon-invitemail',
                    name=(WoWTools_DataMixin.onlyChinese and '打开邮件' or OPENMAIL),
                    hex='ffff00ff'
                }
            }

            WoWTools_GossipMixin.addName= '|A:SpecDial_LastPip_BorderGlow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '闲谈选项' or GOSSIP_OPTIONS)

            WoWTools_GossipMixin.addName2= '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '任务选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, GAMEMENU_OPTIONS))

--添加控制面板
            WoWTools_PanelMixin:Check_Button({
                 checkName= WoWTools_GossipMixin.addName,
                 GetValue= function() return not Save().disabled end,
                 SetValue= function()
                     Save().disabled = not Save().disabled and true or nil
                     print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI
                    )
                 end,
                 buttonText= WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION,
                 buttonFunc= function()
                     Save().point=nil
                     if _G['WoWToolsGossipButton'] then
                        _G['WoWToolsGossipButton']:set_Point()
                     end
                     print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION
                    )
                 end,
                 tooltip= WoWTools_GossipMixin.addName,
                 layout= nil,
                 category= nil,
             })

            if Save().disabled then
                self:UnregisterAllEvents()
            else
                if C_AddOns.IsAddOnLoaded('Blizzard_PlayerChoice') then
                    WoWTools_GossipMixin:Init_PlayerChoice()
                end
                if C_AddOns.IsAddOnLoaded('Blizzard_DelvesDifficultyPicker') then
                    WoWTools_GossipMixin:Init_Delves()
                end
            end

        elseif arg1=='Blizzard_PlayerChoice' and WoWToolsSave then
            WoWTools_GossipMixin:Init_PlayerChoice()
            if C_AddOns.IsAddOnLoaded('Blizzard_DelvesDifficultyPicker') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_DelvesDifficultyPicker' and WoWToolsSave then--地下堡
            WoWTools_GossipMixin:Init_Delves()
            if C_AddOns.IsAddOnLoaded('Blizzard_PlayerChoice') then
                self:UnregisterEvent(event)
            end
        end

    elseif event == "PLAYER_LOGIN" then
        Init()
        self:UnregisterEvent(event)
    end
end)