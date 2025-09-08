local P_Save={

    linkIcon=true, --超链接，图标
    --notShowPlayerInfo=true,--不处理，玩家信息
    showCVarName=nil,--WoWTools_DataMixin.Player.husandro,

    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    --[[text={--内容颜色,
        [ACHIEVEMENTS]=true,
    },]]
    disabledKeyColor= not WoWTools_DataMixin.Player.husandro,--禁用，内容颜色，和频道名称替换

    groupWelcome= WoWTools_DataMixin.Player.husandro,--欢迎
    --groupWelcomeText= WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}',

    guildWelcome= WoWTools_DataMixin.Player.husandro,
    --guildWelcomeText= WoWTools_DataMixin.Player.IsCN and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''),

    welcomeOnlyHomeGroup=true,--仅限, 手动组队

    setPlayerSound= WoWTools_DataMixin.Player.husandro,--播放, 声音
    Cvar={},
    --disabledNPCTalking=true,--禁用，隐藏NPC发言    
    --disabledTalkingPringText=true,--禁用，隐藏NPC发言，文本

    --not_Add_Reload_Button=true,--添加 RELOAD 按钮
    autoHideTableAttributeDisplay=true,--自动关闭，Fstack

    --hideEventTracePlus=true 隐藏 EventTrace Plus
    --eventTracePrint 事件输出

    showCopyChatButton=true,--显示 复制聊天 按钮
    copyChatSetText=nil--处理，文本
}

local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end










local function Init(btn)
    btn.eventSoundTexture= btn:CreateTexture(nil,'OVERLAY')
    btn.eventSoundTexture:SetPoint('BOTTOMLEFT',4, 4)
    btn.eventSoundTexture:SetSize(12,12)
    btn.eventSoundTexture:SetAtlas('chatframe-button-icon-voicechat')

    function btn:set_tooltip()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        GameTooltip:AddDoubleLine(WoWTools_HyperLink.addName, WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon))
        if isDisabled then
            GameTooltip:AddDoubleLine('|cnRED_FONT_COLOR:' ..(WoWTools_DataMixin.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE), WoWTools_TextMixin:GetEnabeleDisable(true))
        end
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        Save().linkIcon= not Save().linkIcon and true or false
        WoWTools_HyperLink:Init_Link_Icon(self)
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon)
        )
        if Save().linkIcon and isDisabled and not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID)--ItemRef.lua
        end
    end


    WoWTools_HyperLink:Init_Button_Menu(btn)
    WoWTools_HyperLink:Init_Link_Icon(btn)--超链接，图标
    WoWTools_HyperLink:Init_Event_Sound(btn)--播放, 事件声音
    WoWTools_HyperLink:Init_NPC_Talking()--隐藏NPC发言
    WoWTools_HyperLink:Init_Welcome()--欢迎加入
    WoWTools_HyperLink:Init_Reload()--添加 RELOAD 按钮

    WoWTools_HyperLink:Init_CopyChat()


    Init=function()end
end









local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_HyperLink']= WoWToolsSave['ChatButton_HyperLink'] or P_Save

            WoWToolsPlayerDate['HyperLinkColorText']= WoWToolsPlayerDate['HyperLinkColorText'] or {[ACHIEVEMENTS]=true}
            WoWToolsPlayerDate['HyperLinkGuildWelcomeText']= WoWToolsPlayerDate['HyperLinkGuildWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '欢迎' or EMOTE103_CMD1:gsub('/',''))
            WoWToolsPlayerDate['HyperLinkGroupWelcomeText']= WoWToolsPlayerDate['HyperLinkGroupWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}')

            WoWTools_HyperLink.addName= '|A:voicechat-icon-STT-on:0:0|a'..(WoWTools_DataMixin.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))


            if WoWTools_ChatMixin:CreateButton('HyperLink', WoWTools_HyperLink.addName) then
                Init(WoWTools_ChatMixin:GetButtonForName('HyperLink'))

                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    WoWTools_HyperLink:Blizzard_Settings(self)
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_DebugTools') then
                    WoWTools_HyperLink:Blizzard_DebugTools()
                end

                if C_AddOns.IsAddOnLoaded('Blizzard_EventTrace') then
                    WoWTools_HyperLink:Blizzard_EventTrace()
                end
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_HyperLink:Blizzard_Settings(self)


        elseif arg1=='Blizzard_DebugTools' and WoWToolsSave then--FSTACK Blizzard_DebugTools.lua
            WoWTools_HyperLink:Blizzard_DebugTools()

        elseif arg1=='Blizzard_EventTrace' and WoWToolsSave then
            WoWTools_HyperLink:Blizzard_EventTrace()
        end
    end
end)

