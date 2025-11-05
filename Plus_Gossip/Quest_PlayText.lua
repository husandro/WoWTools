--文本转语音
local function Save()
    return WoWToolsSave['Plus_Gossip']
end
local menu
local PlayTextTab={}








local function Get_Text()
    local t
--接受，任务
    if QuestInfoDescriptionText:IsVisible() then
        local de, ob
        if QuestInfoFrame.questLog  then
            de = GetQuestLogQuestText()
            ob = select(2, GetQuestLogQuestText())
        else
            de = GetQuestText()
            ob= GetObjectiveText()
        end
        de= de~='' and de or nil
        ob= ob~='' and ob or nil
        if de or ob then
            t= (de or '')
                ..(de and ob and '|n|n' or '')..(ob or '')
        end

    elseif QuestInfoRewardText:IsVisible() then
        t= GetRewardText()

    elseif QuestProgressText:IsVisible() then
        t= GetProgressText()

    elseif GreetingText:IsVisible() then
        t= GetGreetingText()
    end

    if t and t~='' then
        return t
    end
end

local function Player_Text()
    local text= Save().questPlayText and Get_Text()
    if text and not PlayTextTab[text] then
        WoWTools_DataMixin:PlayText(text)
        PlayTextTab[text]=true
    end
end






function WoWTools_GossipMixin:Init_QuestPlayTextMenu(_, root)
    local sub,sub2
--文本转语音 选项
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '文本转语音' or TEXT_TO_SPEECH),
    function()
        return Save().questPlayText
    end, function()
        Save().questPlayText= not Save().questPlayText and true or nil
        PlayTextTab={}
        if Save().questPlayText then
            if Get_Text() then
                Player_Text()
            else
                WoWTools_DataMixin:PlayText(WoWTools_DataMixin.onlyChinese and '这是段文字转语音的样本' or TEXT_TO_SPEECH_SAMPLE_TEXT)
            end
        else
            C_VoiceChat.StopSpeakingText()
        end
        if menu then
            menu:set_texture()
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(Get_Text(), nil, nil, nil, true)
    end)

--自动停止
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动停止' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, SLASH_TEXTTOSPEECH_STOP),
    function()
        return Save().questPlayTextStopMove
    end, function()
        Save().questPlayTextStopMove= not Save().questPlayTextStopMove and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)
        tooltip:AddLine('PLAYER_STARTED_MOVING')
    end)

--文字转语音选项 菜单
    sub:CreateDivider()
    sub:CreateButton(
        (Get_Text() and '' or '|cff626262')
        ..'|A:common-dropdown-icon-play:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '播放' or SLASH_STOPWATCH_PARAM_PLAY1),
    function()
        WoWTools_DataMixin:PlayText(Get_Text())
        return MenuResponse.Open
    end)
    sub:CreateButton(
        '|A:common-dropdown-icon-stop:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP4),
    function()
        PlayTextTab={}
        C_VoiceChat.StopSpeakingText()
        return MenuResponse.Open
    end)

    WoWTools_MenuMixin:TTsMenu(sub)
end





local function Init()

    menu= CreateFrame('DropdownButton', 'WoWToolsQuestPlayTextMenuButton', QuestFrame, 'WoWToolsButtonTemplate')
    menu:SetFrameStrata('HIGH')
    menu:SetFrameLevel(999)
    menu:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    menu:SetSize(18,18)
    menu:SetAlpha(0.5)
    menu.tooltip= WoWTools_DataMixin.onlyChinese and '文本转语音' or TEXT_TO_SPEECH
    function menu:set_point(parent)
        self:SetPoint('BOTTOMLEFT', parent, 'TOPRIGHT', -9, 9)
        self:SetParent(parent:GetParent())
    end
    function menu:set_texture()
        local isEnabled= Save().questPlayText
        self:SetNormalAtlas(isEnabled and 'voicechat-channellist-icon-STT-off' or 'ChallengeMode-icon-redline')
    end
    function menu:set_alpha()
        self:SetAlpha(GameTooltip:IsOwned(self) and 1 or 0.5)
    end
    menu:SetupMenu(function(self, root)
        if not self:IsMouseOver() then
            return
        end

        WoWTools_GossipMixin:Init_QuestPlayTextMenu(self, root)

        root:CreateDivider()


--打开选项界面
        WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_GossipMixin.addName})
    end)

    menu:SetScript('OnShow', function(self)
        if Save().questPlayText then
            self:RegisterEvent('PLAYER_STARTED_MOVING')
        end
    end)
    menu:SetScript('OnEvent', function(self)
        PlayTextTab={}
        if Save().questPlayTextStopMove then
            C_VoiceChat.StopSpeakingText()
        end
        self:UnregisterAllEvents()
    end)
    menu:set_texture()







    QuestInfoDescriptionText:HookScript('OnShow', function(self)
        menu:set_point(self)
        Player_Text()
    end)
    QuestInfoRewardText:HookScript('OnShow', function(self)
        menu:set_point(self)
        Player_Text()
    end)
    QuestProgressText:HookScript('OnShow', function(self)
        menu:set_point(self)
        Player_Text()
    end)
    GreetingText:HookScript('OnShow', function(self)
        menu:set_point(self)
        Player_Text()
    end)


    Init=function()end
end



function WoWTools_GossipMixin:Init_QuestPlayText()
    Init()
end