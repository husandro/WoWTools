local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end










--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2, col
    local isInBat= UnitAffectingCombat('player')

--超链接图标
    sub= root:CreateCheckbox(
        (C_SocialRestrictions.IsChatDisabled() and '|cff828282' or '')
        ..WoWTools_HyperLink.addName,
    function()
        return Save().linkIcon
    end,
        self.set_OnMouseDown
    )
    sub:SetTooltip(function(tooltip)
        if C_SocialRestrictions.IsChatDisabled() then
            tooltip:AddLine(e.onlyChinese and '社交' or SOCIALS)
            tooltip:AddLine(e.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE)
        end
    end)

--关键词, 内容颜色，和频道名称替换
    sub2=sub:CreateCheckbox(
        e.Player.L.key,
    function()
        return not Save().disabledKeyColor
    end, function()
        Save().disabledKeyColor= not Save().disabledKeyColor and true or nil
    end)

--设置关键词
    sub2:CreateButton(
        '|A:mechagon-projects:0:0|a'..(e.onlyChinese and '设置关键词' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, e.Player.L.key)),
    function()
        if not WoWTools_HyperLink.Category then
            e.OpenPanelOpting()
        end
        e.OpenPanelOpting(WoWTools_HyperLink.Category, WoWTools_HyperLink.addName)
        return MenuResponse.Open
    end)

--玩家信息
    sub2= sub:CreateCheckbox(e.onlyChinese and '玩家信息' or PLAYER_MESSAGES, function()
        return not Save().notShowPlayerInfo
    end, function()
        Save().notShowPlayerInfo= not Save().notShowPlayerInfo and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo('player', nil, nil, {reLink=true}), e.GetEnabeleDisable(true))
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(e.Player.col..UnitName('player'), e.GetEnabeleDisable(false))
    end)

--CVar 名称
    sub2=sub:CreateCheckbox(
        'CVar '..(e.onlyChinese and '名称' or LFG_LIST_TITLE ),
    function()
        return Save().showCVarName
    end, function()
        Save().showCVarName= not Save().showCVarName and true or nil
    end)
    sub2:CreateButton(
        e.onlyChinese and '测试' or 'Test',
    function()
        if issecure() then
            return
        end
        local value= C_CVar.GetCVar('guildMemberNotify')
       if C_CVar.SetCVar('guildMemberNotify', value=='0' and '1' or '0') then
            C_Timer.After(0.3, function()
                C_CVar.SetCVar('guildMemberNotify', value)
            end)
        end
        return MenuResponse.Open
    end)

--关闭聊天
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(
        (C_SocialRestrictions.IsChatDisabled() and '|cnRED_FONT_COLOR:' or '')
        ..(e.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE),
    C_SocialRestrictions.IsChatDisabled,
    function()
        if not issecure() then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(e.onlyChinese and '社交' or SOCIALS)
    end)













--事件声音
    col= isInBat and '|cff828282' or (
            not C_CVar.GetCVarBool('Sound_EnableAllSound')
            or C_CVar.GetCVar('Sound_MasterVolume')=='0'
            or C_CVar.GetCVar('Sound_DialogVolume')=='0'
            or not C_CVar.GetCVarBool('Sound_EnableDialog')
            or issecure()
        ) and '|cff9e9e9e' or ''

    sub=root:CreateCheckbox(
        col
        ..'|A:chatframe-button-icon-voicechat:0:0|a'
        ..(e.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)),
    function()
        return Save().setPlayerSound
    end, function()
        Save().setPlayerSound= not Save().setPlayerSound and true or nil

        if Save().setPlayerSound then
            WoWTools_Mixin:PlaySound()--播放, 声音
        end

        WoWTools_HyperLink:Init_Event_Sound()
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and "播放" or SLASH_STOPWATCH_PARAM_PLAY1)
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_Mixin:Get_CVar_Tooltips({name='Sound_EnableAllSound', msg=e.onlyChinese and '开启声效' or ENABLE_SOUND}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_Mixin:Get_CVar_Tooltips({name='Sound_MasterVolume', msg=e.onlyChinese and '主音量' or MASTER_VOLUME}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_Mixin:Get_CVar_Tooltips({name='Sound_DialogVolume', msg=e.onlyChinese and '对话' or DIALOG_VOLUME}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_Mixin:Get_CVar_Tooltips({name='Sound_EnableDialog', msg=e.onlyChinese and '启用对话' or ENABLE_DIALOG }))
    end)

--禁用，隐藏NPC发言
    sub2=sub:CreateCheckbox(
        e.onlyChinese and '隐藏NPC发言' or (HIDE..' NPC '..VOICE_TALKING),
    function()
        return not Save().disabledNPCTalking
    end, function()
        Save().disabledNPCTalking= not Save().disabledNPCTalking and true or nil
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(e.onlyChinese and '对话特写头像' or HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
    end)

--文本
    sub:CreateCheckbox('|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '文本' or LOCALE_TEXT_LABEL), function()
        return not Save().disabledTalkingPringText
    end, function()
        Save().disabledTalkingPringText= not Save().disabledTalkingPringText and true or nil
    end)

--打开，音频
    sub:CreateDivider()
    sub2=sub:CreateButton(
        col..(e.onlyChinese and '音频' or AUDIO_LABEL),
    function()
        if not issecure() then
            Settings.OpenToCategory(Settings.AUDIO_CATEGORY_ID)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(e.onlyChinese and '选项' or OPTIONS)
    end)













--欢迎加入
    sub=root:CreateCheckbox(
        '|A:socialqueuing-icon-group:0:0|a'
        ..(e.onlyChinese and '欢迎加入' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EMOTE103_CMD1:gsub('/',''), JOIN)),
    function()
        return Save().guildWelcome or Save().groupWelcome
    end, function()
        if Save().guildWelcome or Save().groupWelcome then
            Save().guildWelcome=nil
            Save().groupWelcome=nil
        else
            Save().guildWelcome=true
            Save().groupWelcome=true
        end
        WoWTools_HyperLink:Init_Welcome()
    end)

--公会新成员
    sub2=sub:CreateCheckbox(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER, function()
        return Save().guildWelcome
    end, function()
        Save().guildWelcome= not Save().guildWelcome and true or nil
        WoWTools_HyperLink:Init_Welcome()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(Save().guildWelcomeText)
    end)

    sub2= sub:CreateButton('|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER),
            nil,
            {
                text=Save().guildWelcomeText,
                SetValue= function(self)
                    local text= self.editBox:GetText()
                    Save().guildWelcomeText= text
                    print(e.Icon.icon2.. WoWTools_HyperLink.addName, text)
                end
            }
        )
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(Save().guildWelcomeText)
    end)

--队伍新成员
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC, function ()
        return Save().groupWelcome
    end, function ()
        Save().groupWelcome= not Save().groupWelcome and true or nil
        WoWTools_HyperLink:Init_Welcome()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(Save().groupWelcomeText)
        tooltip:AddLine(' ')
        tooltip:AddLine(e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)

    sub2=sub:CreateCheckbox(e.onlyChinese and '仅限组队邀请' or format(LFG_LIST_CROSS_FACTION, GROUP_INVITE), function ()
        return Save().welcomeOnlyHomeGroup
    end, function ()
        Save().welcomeOnlyHomeGroup= not Save().welcomeOnlyHomeGroup and true or nil
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(tooltip, Save().groupWelcomeText)
        tooltip:AddLine(' ')
        tooltip:AddLine(e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
    end)

    sub2= sub:CreateButton('|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC),
            nil,
            {
                text=Save().groupWelcomeText,
                SetValue= function(frame)
                    local text= frame.editBox:GetText()
                    Save().groupWelcomeText=text
                    print(e.Icon.icon2.. WoWTools_HyperLink.addName, text)
                end
            }
        )
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(Save().groupWelcomeText)
        tooltip:AddLine(' ')
        tooltip:AddLine(e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)

















--文本转语音   
    root:CreateDivider() 
    sub=root:CreateButton(
        (isInBat and '|cff828282' or '')
        ..'|A:chatframe-button-icon-TTS:0:0|a'
        ..(e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH),
        --return C_CVar.GetCVarBool('textToSpeech')
    function ()
        if not InCombatLockdown() then
            C_CVar.SetCVar("textToSpeech", C_CVar.GetCVar('textToSpeech')=='0' and '1' or '0' )
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/tts')
    end)








--etrace

    root:CreateButton('|A:minimap-genericevent-hornicon:0:0|a|cffff00ffETR|rACE', function()
        --[[if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
            C_AddOns.LoadAddOn("Blizzard_EventTrace")
        end]]
        if not EventTrace then
            UIParentLoadAddOn("Blizzard_EventTrace")
        end
            EventTrace:OnShow()
        return MenuResponse.Open
    end)









--fstack
    sub=root:CreateButton('|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK', function ()
        if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
            C_AddOns.LoadAddOn("Blizzard_DebugTools")
        end
        FrameStackTooltip_ToggleDefaults()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Alt|r '..(e.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r '..(e.onlyChinese and '显示' or SHOW))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Shift|r '..(e.onlyChinese and '材质信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TEXTURES_SUBHEADER, INFO)))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (e.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(e.onlyChinese and '类型' or TYPE))
    end)

    sub:CreateCheckbox(
        e.onlyChinese and '增强' or 'Plus',
    function()
        return not Save().disabedFrameStackPlus
    end, function()
        Save().disabedFrameStackPlus= not Save().disabedFrameStackPlus and true or nil
        WoWTools_HyperLink:Blizzard_DebugTools()
    end)








--颜色选择器    
    root:CreateButton(
        '|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '颜色选择器' or COLOR_PICKER),
    function()
        if ColorPickerFrame:IsShown() then
            ColorPickerFrame:Hide()
        else
            WoWTools_ColorMixin:ShowColorFrame(e.Player.r, e.Player.g, e.Player.b, 1, nil, nil)
        end
        return MenuResponse.Open
    end)














--添加按钮
    root:CreateDivider()

--/reload
    sub=WoWTools_MenuMixin:Reload(root, false)

--添加按钮
    sub2=sub:CreateCheckbox(
        e.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button'),
    function ()
        return not Save().not_Add_Reload_Button
    end, function ()
        Save().not_Add_Reload_Button= not Save().not_Add_Reload_Button and true or nil
        if not WoWTools_HyperLink:Init_Reload() then
            print(e.Icon.icon2..WoWTools_HyperLink.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(e.onlyChinese and '添加' or ADD)
        tooltip:AddLine(' ')
        tooltip:AddLine(e.onlyChinese and '主菜单' or MAINMENU_BUTTON)
        tooltip:AddLine(e.onlyChinese and '选项' or OPTIONS)
    end)
end














function WoWTools_HyperLink:Init_Button_Menu()
    self.LinkButton:SetupMenu(Init_Menu)
end