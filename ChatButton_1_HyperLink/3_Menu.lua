local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end







--主菜单
--#####
local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

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
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '社交' or SOCIALS)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE)
        end
    end)

--图标尺寸
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().iconSize or 0
        end, setValue=function(value)
            Save().iconSize=value
            WoWTools_HyperLink:Link_Icon_Settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '图标尺寸' or HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
        minValue=0,
        maxValue=32,
        step=1,
        --bit='%.2f',
        tooltip=function(tooltip)
            local s= Save().iconSize or 0
            s= s<8 and 0 or s
            tooltip:AddLine('|T134414..:'..s..':'..s..'|t')
            if not Save().notShowItemCount then
                print(select(2, C_Item.GetItemInfo(6948)), '')
            end
        end
    })
    sub:CreateSpacer()

--关键词, 内容颜色，和频道名称替换
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.Language.key,
    function()
        return not Save().disabledKeyColor
    end, function()
        Save().disabledKeyColor= not Save().disabledKeyColor and true or nil
        for t in pairs(WoWToolsPlayerDate['HyperLinkColorText']) do
            print(t)
            break
        end
    end)

--设置关键词
    sub2:CreateButton(
        '|A:mechagon-projects:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置关键词' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, WoWTools_DataMixin.Language.key)),
    function()
        if not WoWTools_HyperLink.Category then
            WoWTools_PanelMixin:Open()
        end
        WoWTools_PanelMixin:Open(WoWTools_HyperLink.Category, WoWTools_HyperLink.addName)
        return MenuResponse.Open
    end)

--玩家信息
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '玩家信息' or PLAYER_MESSAGES,
    function()
        return not Save().notShowPlayerInfo
    end, function()
        Save().notShowPlayerInfo= not Save().notShowPlayerInfo and true or nil       
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_UnitMixin:GetPlayerInfo('player', nil, nil, {reLink=true}), WoWTools_TextMixin:GetEnabeleDisable(true))
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(WoWTools_DataMixin.Player.col..UnitName('player'), WoWTools_TextMixin:GetEnabeleDisable(false))
    end)


--物品数量
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '物品数量' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, AUCTION_HOUSE_QUANTITY_LABEL),
    function()
        return not Save().notShowItemCount
    end, function()
        Save().notShowItemCount= not Save().notShowItemCount and true or nil
        print(select(2, C_Item.GetItemInfo(6948)), '')
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_ItemMixin:GetCount(6948, {isWoW=true}), nil)
    end)


--地图标记
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '地图标记' or  MAP_PIN,
    function()
            return not Save().notShowMapPin
    end, function()
        Save().notShowMapPin= not Save().notShowMapPin and true or nil
        print(WoWTools_DataMixin.Icon.icon2, '30.00 45.50')
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine('[30.00 45.50]')
    end)





    sub:CreateDivider()
--CVar 名称
    sub2=sub:CreateCheckbox(
        'CVar '..(WoWTools_DataMixin.onlyChinese and '名称' or LFG_LIST_TITLE ),
    function()
        return Save().showCVarName
    end, function()
        Save().showCVarName= not Save().showCVarName and true or nil
    end)
    sub2:CreateButton(
        WoWTools_DataMixin.onlyChinese and '测试' or 'Test',
    function()
        if InCombatLockdown() then
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
    sub2=sub:CreateCheckbox(
        (C_SocialRestrictions.IsChatDisabled() and '|cnWARNING_FONT_COLOR:' or '')
        ..(WoWTools_DataMixin.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE),
    function()
       return C_SocialRestrictions.IsChatDisabled()
    end, function()
        if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID, RESTRICT_CHAT_CONFIG_DISABLE)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or SETTINGS_TITLE)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '社交' or SOCIALS)
    end)













--事件声音
    col= isInBat and '|cff828282' or (
            not C_CVar.GetCVarBool('Sound_EnableAllSound')
            or C_CVar.GetCVar('Sound_MasterVolume')=='0'
            or C_CVar.GetCVar('Sound_DialogVolume')=='0'
            or not C_CVar.GetCVarBool('Sound_EnableDialog')
            or InCombatLockdown()
        ) and '|cff9e9e9e' or ''

    sub=root:CreateCheckbox(
        col
        ..'|A:chatframe-button-icon-voicechat:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)),
    function()
        return Save().setPlayerSound
    end, function()
        Save().setPlayerSound= not Save().setPlayerSound and true or nil

        if Save().setPlayerSound then
            WoWTools_DataMixin:PlaySound()--播放, 声音
        end

        WoWTools_HyperLink:Init_Event_Sound(self)
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and "播放" or SLASH_STOPWATCH_PARAM_PLAY1)
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_EnableAllSound', msg=WoWTools_DataMixin.onlyChinese and '开启声效' or ENABLE_SOUND}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_MasterVolume', msg=WoWTools_DataMixin.onlyChinese and '主音量' or MASTER_VOLUME}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_DialogVolume', msg=WoWTools_DataMixin.onlyChinese and '对话' or DIALOG_VOLUME}))
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin:Get_CVar_Tooltips({name='Sound_EnableDialog', msg=WoWTools_DataMixin.onlyChinese and '启用对话' or ENABLE_DIALOG }))
    end)

--禁用，隐藏NPC发言
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '隐藏NPC发言' or (HIDE..' NPC '..VOICE_TALKING),
    function()
        return not Save().disabledNPCTalking
    end, function()
        Save().disabledNPCTalking= not Save().disabledNPCTalking and true or nil
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '对话特写头像' or HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
    end)

--文本
    sub:CreateCheckbox('|A:communities-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '文本' or LOCALE_TEXT_LABEL), function()
        return not Save().disabledTalkingPringText
    end, function()
        Save().disabledTalkingPringText= not Save().disabledTalkingPringText and true or nil
    end)

--打开，音频
    sub:CreateDivider()
    sub2=sub:CreateButton(
        col..(WoWTools_DataMixin.onlyChinese and '音频' or AUDIO_LABEL),
    function()
        if not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.AUDIO_CATEGORY_ID)--ItemRef.lua
        end
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)
    end)













--欢迎加入
    sub=root:CreateCheckbox(
        '|A:socialqueuing-icon-group:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '欢迎加入' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EMOTE103_CMD1:gsub('/',''), JOIN)),
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
    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER, function()
        return Save().guildWelcome
    end, function()
        Save().guildWelcome= not Save().guildWelcome and true or nil
        WoWTools_HyperLink:Init_Welcome()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWToolsPlayerDate['HyperLinkGuildWelcomeText'])
    end)

    sub2= sub:CreateButton('|A:communities-guildbanner-background:0:0|a'..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (WoWTools_DataMixin.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:communities-guildbanner-background:0:0|a'..(WoWTools_DataMixin.onlyChinese and '公会新成员' or LFG_LIST_GUILD_MEMBER),
            nil,
            {
                text=WoWToolsPlayerDate['HyperLinkGuildWelcomeText'],
                SetValue= function(s)
                    local edit= s.editBox or s:GetEditBox()
                    local text= edit:GetText()
                    WoWToolsPlayerDate['HyperLinkGuildWelcomeText']= text
                    print(WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2, text)
                end,
            }
        )
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWToolsPlayerDate['HyperLinkGuildWelcomeText'])
    end)

--队伍新成员
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC, function ()
        return Save().groupWelcome
    end, function ()
        Save().groupWelcome= not Save().groupWelcome and true or nil
        WoWTools_HyperLink:Init_Welcome()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWToolsPlayerDate['HyperLinkGroupWelcomeText'])
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)

    sub2=sub:CreateCheckbox(WoWTools_DataMixin.onlyChinese and '仅限组队邀请' or format(LFG_LIST_CROSS_FACTION, GROUP_INVITE), function ()
        return Save().welcomeOnlyHomeGroup
    end, function ()
        Save().welcomeOnlyHomeGroup= not Save().welcomeOnlyHomeGroup and true or false
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWToolsPlayerDate['HyperLinkGroupWelcomeText'])
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON)
    end)

    sub2= sub:CreateButton('|A:socialqueuing-icon-group:0:0|a'..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT), function ()
        StaticPopup_Show('WoWTools_EditText',
            (WoWTools_DataMixin.onlyChinese and '欢迎加入' or 'Welcome to join')..'|n|A:socialqueuing-icon-group:0:0|a'..(WoWTools_DataMixin.onlyChinese and '队伍新成员' or SPELL_TARGET_TYPE14_DESC),
            nil,
            {
                text=WoWToolsPlayerDate['HyperLinkGroupWelcomeText'],
                SetValue= function(s)
                    local edit= s.editBox or s:GetEditBox()
                    local text= edit:GetText()
                    WoWToolsPlayerDate['HyperLinkGroupWelcomeText']=text
                    print(
                        WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                        text
                    )
                end
            }
        )
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWToolsPlayerDate['HyperLinkGroupWelcomeText'])
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '仅限队长或团长' or format(LFG_LIST_CROSS_FACTION, LEADER))
    end)

















--文本转语音   
    root:CreateDivider()
    sub=root:CreateButton(
        (isInBat and '|cff828282' or '')
        ..'|A:chatframe-button-icon-TTS:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '文本转语音' or TEXT_TO_SPEECH),
        --return C_CVar.GetCVarBool('textToSpeech')
    function ()
        if not InCombatLockdown() then
            C_CVar.SetCVar("textToSpeech", C_CVar.GetCVar('textToSpeech')=='0' and '1' or '0' )
        end
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine('/tts')
    end)








--etrace
    sub=root:CreateButton('|A:minimap-genericevent-hornicon:0:0|a|cffff00ffETR|rACE', function()
        if EventTrace and EventTrace:IsVisible() then
            EventTrace:Hide()
        else
            if not EventTrace then
                UIParentLoadAddOn("Blizzard_EventTrace")
            end
            EventTrace:Show()
        end

        return MenuResponse.Open
    end)

    sub:CreateCheckbox(
        'Plus',
    function()
        return not Save().hideEventTracePlus
    end, function()
        Save().hideEventTracePlus= not Save().hideEventTracePlus and true or nil
        WoWTools_HyperLink:Blizzard_EventTrace()
        if Save().hideEventTracePlus then
            print(
                WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
        end
    end)

    sub:CreateCheckbox(
        'Print',
    function()
        return Save().eventTracePrint
    end, function()
        Save().eventTracePrint= not Save().eventTracePrint and true or nil
        print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            Save().eventTracePrint and
                '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '开始' or START)
                or ('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '全部清队' or CLEAR_ALL))
            )
        WoWTools_HyperLink:Blizzard_EventTrace()
    end)

    local tab= WoWTools_HyperLink:Get_EventTrace_Print_Tab()
    local newTab={}
    for event, data in pairs(tab) do
        table.insert(newTab, {event= event, index= data.index, num=data.num, arg= data.arg})
    end

    if #newTab>0 then
        table.sort(newTab, function(a, b) return a.index> b.index end)

        sub:CreateDivider()
        for _, info in pairs(newTab) do
            sub2=sub:CreateButton(
                (select(2, math.modf((info.index-1)/2))==0 and '|cff10d3c8' or '|cffd3a21b')..info.index..') '
                ..info.event..' '..info.num,
            function(data)
                WoWTools_ChatMixin:Chat(data.event, nil, true)
                return MenuResponse.Open
            end, info)
            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '分享链接至聊天栏' or CLUB_FINDER_LINK_POST_IN_CHAT)..WoWTools_DataMixin.Icon.left)
                for arg1, num in pairs(desc.data.arg) do
                    tooltip:AddDoubleLine(arg1, num)
                end
            end)
        end
        WoWTools_MenuMixin:SetScrollMode(sub)
    end



--fstack
    sub=root:CreateButton('|A:QuestLegendaryTurnin:0:0|a|cff00ff00FST|rACK', function ()
        if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then
            C_AddOns.LoadAddOn("Blizzard_DebugTools")
        end
        FrameStackTooltip_ToggleDefaults()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function (tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Alt|r '..(WoWTools_DataMixin.onlyChinese and '切换' or HUD_EDIT_MODE_SWITCH))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl|r '..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Shift|r '..(WoWTools_DataMixin.onlyChinese and '材质信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TEXTURES_SUBHEADER, INFO)))
        tooltip:AddLine(' ')
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+C|r '.. (WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)..' \"File\" '..(WoWTools_DataMixin.onlyChinese and '类型' or TYPE))
    end)

    sub:CreateCheckbox(
        'Plus',
    function()
        return not Save().disabedFrameStackPlus
    end, function()
        Save().disabedFrameStackPlus= not Save().disabedFrameStackPlus and true or nil
        WoWTools_HyperLink:Blizzard_DebugTools()
    end)








--颜色选择器    
    root:CreateButton(
        '|A:colorblind-colorwheel:0:0|a'..(WoWTools_DataMixin.onlyChinese and '颜色选择器' or COLOR_PICKER),
    function()
        if ColorPickerFrame:IsShown() then
            ColorPickerFrame:Hide()
        else
            WoWTools_ColorMixin:ShowColorFrame(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b, 1, nil, nil)
        end
        return MenuResponse.Open
    end)














--添加按钮
    root:CreateDivider()

--/reload
    sub=WoWTools_MenuMixin:Reload(root, false)

--添加按钮
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '添加按钮' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, 'Button'),
    function ()
        return not Save().not_Add_Reload_Button
    end, function ()
        Save().not_Add_Reload_Button= not Save().not_Add_Reload_Button and true or nil
        if not Save().not_Add_Reload_Button then
            print(
                WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
                WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
            )
        end
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '主菜单' or MAINMENU_BUTTON)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)
    end)
end














function WoWTools_HyperLink:Init_Button_Menu(btn)
    btn:SetupMenu(Init_Menu)
end