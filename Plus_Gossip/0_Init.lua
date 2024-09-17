local id, e = ...

WoWTools_GossipMixin= {
    Save={
    NPC={},
    gossip= true,

    unique= true,--唯一对话
    gossipOption={},--gossipID= text
    choice={},--PlayerChoiceFrame
    movie={},--电影
    stopMovie=true,--如果已播放，停止播放

    quest= true,
    questOption={},
    questRewardCheck={},--{任务ID= index}
    --autoSortQuest=  e.Player.husandro,--仅显示当前地图任务
    autoSelectReward= e.Player.husandro,--自动选择奖励
    showAllQuestNum= e.Player.husandro,--显示所有任务数量

    --scale=1,
    --point=nil,

    --not_Gossip_Text_Icon=true,--自定义，对话，文本
    Gossip_Text_Icon_Player={--玩家，自定义，对话，文本
        [55193]={
            icon='communities-icon-invitemail',
            name=(e.Player.husandro and '打开邮件' or OPENMAIL),
            hex='ffff00ff'}
    },
    Gossip_Text_Icon_Size=18,

    Gossip_Text_Icon_cnFont=true,--仅限，外文, 修该字体

    delvesDifficultyMaxLevel=true,--地下堡指定难度
    addName=nil,
    addName2=nil,
}

}

local function Save()
    return WoWTools_GossipMixin.Save
end





















local function Init()
    WoWTools_GossipMixin:Init_Gossip_Data()--自定义，对话，文本
    do
        WoWTools_GossipMixin:Init_Gossip()--对话，初始化
    end

    WoWTools_GossipMixin:Init_Quest()--任务，初始化

    WoWTools_GossipMixin:Init_QuestInfo_Display()--任务目标，类型提示

    if C_AddOns.IsAddOnLoaded('Blizzard_PlayerChoice') then
        WoWTools_GossipMixin:Init_PlayerChoice()
    end
    if C_AddOns.IsAddOnLoaded('Blizzard_DelvesDifficultyPicker') then
        WoWTools_GossipMixin:Init_Delves()
    end

    if Save().gossip then
        C_Timer.After(2, function()
            if SubscriptionInterstitialFrame and SubscriptionInterstitialFrame:IsShown() then
                SubscriptionInterstitialFrame.ClosePanelButton:Click()
            end
        end)
    end
end













--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED"  then
        if arg1 == id then

            WoWTools_GossipMixin.Save= WoWToolsSave['Plus_Gossip'] or Save()

            WoWTools_GossipMixin.addName= '|A:SpecDial_LastPip_BorderGlow:0:0|a'
                ..(e.onlyChinese and '闲谈选项' or GOSSIP_OPTIONS)

            WoWTools_GossipMixin.addName2= '|A:UI-HUD-UnitFrame-Target-PortraitOn-Boss-Quest:0:0|a'
                ..(e.onlyChinese and '任务选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, GAMEMENU_OPTIONS))

             --添加控制面板
             --e.AddPanel_Header(nil, 'Plus')
            e.AddPanel_Check_Button({
                 checkName= WoWTools_GossipMixin.addName,
                 GetValue= function() return not Save().disabled end,
                 SetValue= function()
                     Save().disabled = not Save().disabled and true or nil
                     print(e.addName, WoWTools_GossipMixin.addName, WoWTools_GossipMixin.addName2, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                 end,
                 buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                 buttonFunc= function()
                     Save().point=nil
                     local btn= WoWTools_GossipMixin.GossipButton
                     if btn then
                        btn:ClearAllPoints()
                        btn:set_Point()
                     end
                     print(e.addName, WoWTools_GossipMixin.addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                 end,
                 tooltip= WoWTools_GossipMixin.addName,
                 layout= nil,
                 category= nil,
             })

            if Save().disabled then
                self:UnregisterEvent('ADDON_LOADED')
            else
                Init()
            end

        elseif arg1=='Blizzard_PlayerChoice' then
            WoWTools_GossipMixin:Init_PlayerChoice()

        elseif arg1=='Blizzard_DelvesDifficultyPicker' then--地下堡
            WoWTools_GossipMixin:Init_Delves()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Gossip']= Save()
        end
    end
end)