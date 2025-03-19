local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end










--主菜单
--#####
local function Init_Menu(self, root)
    local sub, tre, col
    local isInBat= UnitAffectingCombat('player')

    --超链接图标
    sub= root:CreateCheckbox(WoWTools_HyperLink.addName, function()
        return not Save().disabed
    end, function()
        Save().disabed= not Save().disabed and true or nil
        print(e.Icon.icon2.. addName, e.GetEnabeleDisable(not Save().disabed))
        Set_HyperLlinkIcon()
    end)

    --关键词
    sub:CreateCheckbox(e.Player.L.key, function()--关键词, 内容颜色，和频道名称替换
        return not Save().disabledKeyColor
    end, function()
        Save().disabledKeyColor= not Save().disabledKeyColor and true or nil
    end)

    sub:CreateButton('|A:mechagon-projects:0:0|a'..(e.onlyChinese and '设置关键词' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, e.Player.L.key)), function()
        if not Category then
            e.OpenPanelOpting()
        end
        e.OpenPanelOpting(Category, addName)
    end)


    --玩家信息
    sub:CreateDivider()
    tre= sub:CreateCheckbox(e.onlyChinese and '玩家信息' or PLAYER_MESSAGES, function()
        return not Save().notShowPlayerInfo
    end, function()
        Save().notShowPlayerInfo= not Save().notShowPlayerInfo and true or nil
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, WoWTools_UnitMixin:GetPlayerInfo('player', nil, nil, {reLink=true}))
    end)


    --事件声音
    col= isInBat and '|cnRED_FONT_COLOR:' or (
            not C_CVar.GetCVarBool('Sound_EnableAllSound')
            or C_CVar.GetCVar('Sound_MasterVolume')=='0'
            or C_CVar.GetCVar('Sound_DialogVolume')=='0'
            or not C_CVar.GetCVarBool('Sound_EnableDialog')
        ) and '|cff9e9e9e' or ''
    sub=root:CreateCheckbox(col..'|A:chatframe-button-icon-voicechat:0:0|a'..(e.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)), function()
        return Save().setPlayerSound
    end, function()
        if UnitAffectingCombat('player') then
            return
        end
        Save().setPlayerSound= not Save().setPlayerSound and true or nil
        e.setPlayerSound= Save().setPlayerSound
        if Save().setPlayerSound then
            e.PlaySound()--播放, 声音
        end
        Set_PlayerSound()
        print(e.Icon.icon2.. addName, e.onlyChinese and "播放" or SLASH_STOPWATCH_PARAM_PLAY1, e.onlyChinese and '事件声音' or EVENTS_LABEL..SOUND)
    end)
    sub:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_EnableAllSound', msg=e.onlyChinese and '开启声效' or ENABLE_SOUND}))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_MasterVolume', msg=e.onlyChinese and '主音量' or MASTER_VOLUME}))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_DialogVolume', msg=e.onlyChinese and '对话' or DIALOG_VOLUME}))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, e.Get_CVar_Tooltips({name='Sound_EnableDialog', msg=e.onlyChinese and '启用对话' or ENABLE_DIALOG }))
    end)


    --禁用，隐藏NPC发言
    sub:CreateCheckbox(e.onlyChinese and '隐藏NPC发言' or (HIDE..' (NPC) '..VOICE_TALKING), function()
        return not Save().disabledNPCTalking
    end, function()
        Save().disabledNPCTalking= not Save().disabledNPCTalking and true or nil
    end)
    --文本
    sub:CreateCheckbox('|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '文本' or LOCALE_TEXT_LABEL), function()
        return not Save().disabledTalkingPringText
    end, function()
        Save().disabledTalkingPringText= not Save().disabledTalkingPringText and true or nil
    end)


    --欢迎加入
    sub=root:CreateCheckbox(e.onlyChinese and '欢迎加入' or (EMOTE103_CMD1:gsub('/','')..JOIN), function()
        return Save().guildWelcome or Save().groupWelcome
    end, function()
        if Save().guildWelcome or Save().groupWelcome then
            Save().guildWelcome=nil
            Save().groupWelcome=nil
        else
            Save().guildWelcome=true
            Save().groupWelcome=true
        end
        self:Settings()
    end)

    --公会新成员
    tre=sub:CreateCheckbox(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER, function()
        return Save().guildWelcome
    end, function()
        Save().guildWelcome= not Save().guildWelcome and true or nil
        self:Settings()
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save().guildWelcomeText)
    end)

    tre= sub:CreateButton('|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER),
            nil,
            {
                text=Save().guildWelcomeText,
                SetValue= function(self)
                    local text= self.editBox:GetText()
                    Save().guildWelcomeText= text
                    print(e.Icon.icon2.. addName, text)
                end
            }
        )
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save().guildWelcomeText)
    end)

    --队伍新成员
    sub:CreateDivider()
    tre=sub:CreateCheckbox(e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC, function ()
        return Save().groupWelcome
    end, function ()
        Save().groupWelcome= not Save().groupWelcome and true or nil
        self:Settings()
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save().groupWelcomeText)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddInstructionLine(tooltip,  e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)

    tre=sub:CreateCheckbox(e.onlyChinese and '仅限组队邀请' or format(LFG_LIST_CROSS_FACTION, GROUP_INVITE), function ()
        return Save().welcomeOnlyHomeGroup
    end, function ()
        Save().welcomeOnlyHomeGroup= not Save().welcomeOnlyHomeGroup and true or nil
    end)
    tre:SetTooltip(function (tooltip)
        GameTooltip_AddNormalLine(tooltip, Save().groupWelcomeText)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddErrorLine(tooltip, e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
    end)

    tre= sub:CreateButton('|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (e.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:socialqueuing-icon-group:0:0|a'..(e.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC),
            nil,
            {
                text=Save().groupWelcomeText,
                SetValue= function(frame)
                    local text= frame.editBox:GetText()
                    Save().groupWelcomeText=text
                    print(e.Icon.icon2.. addName, text)
                end
            }
        )
    end)
    tre:SetTooltip(function(tooltip)
        GameTooltip_AddNormalLine(tooltip, Save().groupWelcomeText)
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddInstructionLine(tooltip,  e.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)


    --文本转语音    
    sub=root:CreateCheckbox((isInBat and '|cnRED_FONT_COLOR:' or '')..'|A:chatframe-button-icon-TTS:0:0|a'..(e.onlyChinese and '文本转语音' or TEXT_TO_SPEECH), function ()
        return C_CVar.GetCVarBool('textToSpeech')
    end, function ()
        if not UnitAffectingCombat('player') then
            C_CVar.SetCVar("textToSpeech", not C_CVar.GetCVarBool('textToSpeech') and '1' or '0' )
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/tts')
    end)

    --etrace
    root:CreateDivider()
    root:CreateButton('|A:minimap-genericevent-hornicon:0:0|a|cffff00ffETR|rACE', function ()
        if not C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
            C_AddOns.LoadAddOn("Blizzard_EventTrace")
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
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Alt|r '..(e.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Ctrl|r '..(e.onlyChinese and '显示' or SHOW))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Shift|r '..(e.onlyChinese and '材质信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TEXTURES_SUBHEADER, INFO)))
        GameTooltip_AddBlankLineToTooltip(tooltip)
        GameTooltip_AddNormalLine(tooltip, '|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (e.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(e.onlyChinese and '类型' or TYPE))
    end)

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

    root:CreateDivider()
    sub=WoWTools_MenuMixin:Reload(root, false)

    tre=sub:CreateCheckbox(e.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button'), function ()
        return not Save().not_Add_Reload_Button
    end, function ()
        Save().not_Add_Reload_Button= not Save().not_Add_Reload_Button and true or nil
        Init_Add_Reload_Button()
    end)
    tre:SetTooltip(function (tooltip)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '主菜单' or MAINMENU_BUTTON)
        GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '选项' or OPTIONS)
    end)
end














function WoWTools_HyperLink:Init_Button_Menu()
    self.LinkButton:SetupMenu(Init_Menu)
end