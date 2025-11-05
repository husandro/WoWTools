--文本转语音
local function Save()
    return WoWToolsSave['Plus_Gossip']
end
local PlayTextTab={}








local function Get_QuestDescription()
    local desc
    if ( QuestInfoFrame.questLog ) then
        desc = GetQuestLogQuestText()
    else
        desc = GetQuestText()
    end
    if desc and desc~='' then
        return desc
    end
end
local function Play_QuestDescription(isPlay)
    local desc= (isPlay or Save().questPlayText) and Get_QuestDescription()
    if desc and not PlayTextTab[desc] then
        WoWTools_DataMixin:PlayText(desc)
        PlayTextTab[desc]=true
    end
end









function WoWTools_GossipMixin:Init_QuestPlayTextMenu(_, root)
    local sub,sub2
    sub=root:CreateCheckbox(
        (WoWTools_DataMixin.onlyChinese and '文本转语音' or TEXT_TO_SPEECH),
    function()
        return Save().questPlayText
    end, function()
        Save().questPlayText= not Save().questPlayText and true or nil
        PlayTextTab={}
        if Save().questPlayText then
            if Get_QuestDescription() then
                Play_QuestDescription()
            else
                WoWTools_DataMixin:PlayText(WoWTools_DataMixin.onlyChinese and '这是段文字转语音的样本' or TEXT_TO_SPEECH_SAMPLE_TEXT)
            end
        else
            C_VoiceChat.StopSpeakingText()
        end
        _G['WoWToolsQuestPlayTextMenuButton']:set_texture()
    end)

    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自动停止' or format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, SLASH_TEXTTOSPEECH_STOP),
    function()
        return Save().questPlayTextStopMove
    end, function()
        Save().questPlayTextStopMove= Save().questPlayTextStopMove and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)
        tooltip:AddLine('PLAYER_STARTED_MOVING')
    end)

--文字转语音选项 菜单
    sub:CreateDivider()
    WoWTools_MenuMixin:TTsMenu(sub)
end





local function Init()

    local menu= CreateFrame('DropdownButton', 'WoWToolsQuestPlayTextMenuButton', QuestFrame, 'WoWToolsButtonTemplate')
    menu:SetFrameStrata('HIGH')
    menu:SetFrameLevel(999)
    menu:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    menu:SetSize(18,18)
    menu:SetAlpha(0.5)
    menu:SetPoint('TOPRIGHT', QuestInfoDescriptionText)
    menu.tooltip= WoWTools_DataMixin.onlyChinese and '文本转语音' or TEXT_TO_SPEECH
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
        root:CreateButton(
            '|A:common-dropdown-icon-play:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '播放' or SLASH_STOPWATCH_PARAM_PLAY1),
        function()
            C_VoiceChat.StopSpeakingText()
            Play_QuestDescription(true)
            return MenuResponse.Open
        end)
        root:CreateButton(
            '|A:common-dropdown-icon-stop:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '停止' or SLASH_STOPWATCH_PARAM_STOP4),
        function()
            C_VoiceChat.StopSpeakingText()
            Play_QuestDescription(true)
            return MenuResponse.Open
        end)

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
        _G['WoWToolsQuestPlayTextMenuButton']:SetParent(self:GetParent())
        Play_QuestDescription()
    end)


    Init=function()end
end



function WoWTools_GossipMixin:Init_QuestPlayText()
    Init()
end