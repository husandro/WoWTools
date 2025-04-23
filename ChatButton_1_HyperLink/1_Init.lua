local P_Save={

    linkIcon=true, --超链接，图标
    --notShowPlayerInfo=true,--不处理，玩家信息
    showCVarName=nil,--WoWTools_DataMixin.Player.husandro,

    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    text={--内容颜色,
        [ACHIEVEMENTS]=true,
    },
    disabledKeyColor= not WoWTools_DataMixin.Player.husandro,--禁用，内容颜色，和频道名称替换

    groupWelcome= WoWTools_DataMixin.Player.husandro,--欢迎
    groupWelcomeText= WoWTools_DataMixin.Player.cn and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}',

    guildWelcome= WoWTools_DataMixin.Player.husandro,
    guildWelcomeText= WoWTools_DataMixin.Player.cn and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''),

    welcomeOnlyHomeGroup=true,--仅限, 手动组队

    setPlayerSound= WoWTools_DataMixin.Player.husandro,--播放, 声音
    Cvar={},
    --disabledNPCTalking=true,--禁用，隐藏NPC发言    
    --disabledTalkingPringText=true,--禁用，隐藏NPC发言，文本

    --not_Add_Reload_Button=true,--添加 RELOAD 按钮
    autoHideTableAttributeDisplay=true,--自动关闭，Fstack
}

local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end

local LinkButton








local function Init()
    LinkButton.eventSoundTexture= LinkButton:CreateTexture(nil,'OVERLAY')
    LinkButton.eventSoundTexture:SetPoint('BOTTOMLEFT',4, 4)
    LinkButton.eventSoundTexture:SetSize(12,12)
    LinkButton.eventSoundTexture:SetAtlas('chatframe-button-icon-voicechat')

    function LinkButton:set_tooltip()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        GameTooltip:AddDoubleLine(WoWTools_HyperLink.addName, WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon))
        if isDisabled then
            GameTooltip:AddDoubleLine('|cnRED_FONT_COLOR:' ..(WoWTools_DataMixin.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE), WoWTools_TextMixin:GetEnabeleDisable(true))
        end
        GameTooltip:Show()
    end

    function LinkButton:set_OnMouseDown()
        Save().linkIcon= not Save().linkIcon and true or nil
        WoWTools_HyperLink:Init_Link_Icon()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        print(
            WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName,
            WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon)
        )
        if Save().linkIcon and isDisabled and not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID)--ItemRef.lua
        end
    end

    WoWTools_HyperLink:Init_Button_Menu()
    WoWTools_HyperLink:Init_Link_Icon()--超链接，图标
    WoWTools_HyperLink:Init_Event_Sound()--播放, 事件声音
    WoWTools_HyperLink:Init_NPC_Talking()--隐藏NPC发言
    WoWTools_HyperLink:Init_Welcome()--欢迎加入
    WoWTools_HyperLink:Init_Reload()--添加 RELOAD 按钮

    WoWTools_HyperLink:Blizzard_DebugTools()
    
    WoWTools_HyperLink:Blizzard_Settings()
    WoWTools_HyperLink:Blizzard_EventTrace()
    WoWTools_HyperLink:Init_EventTrace_Print()
end











local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_HyperLink']= WoWToolsSave['ChatButton_HyperLink'] or P_Save

            Save().linkIcon= not Save().disabed
            Save().disabed= nil

            WoWTools_HyperLink.addName= '|A:voicechat-icon-STT-on:0:0|a'..(WoWTools_DataMixin.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
            LinkButton= WoWTools_ChatMixin:CreateButton('HyperLink', WoWTools_HyperLink.addName)

            WoWTools_HyperLink.LinkButton= LinkButton

            if LinkButton then
                Init()

               
            else
                --DEFAULT_CHAT_FRAME.P_AddMessage= nil
                self:UnregisterAllEvents()
            end

        elseif arg1=='Blizzard_Settings' and WoWToolsSave then
            WoWTools_HyperLink:Blizzard_Settings()


        elseif arg1=='Blizzard_DebugTools' and WoWToolsSave then--FSTACK Blizzard_DebugTools.lua
            WoWTools_HyperLink:Blizzard_DebugTools()

        elseif arg1=='Blizzard_EventTrace' and WoWToolsSave then
            WoWTools_HyperLink:Blizzard_EventTrace()
        end
    end
end)

