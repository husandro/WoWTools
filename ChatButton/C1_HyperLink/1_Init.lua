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

    not_Add_Reload_Button= not WoWTools_DataMixin.Player.husandro,--添加 RELOAD 按钮
    autoHideTableAttributeDisplay=true,--自动关闭，Fstack

    --hideEventTracePlus=true 隐藏 EventTrace Plus
    --eventTracePrint 事件输出

    showCopyChatButton=true,--显示 复制聊天 按钮
    --copyChatSetText=nil,--处理，文本

    --[[Emote={
        emoji={
            'DANCE'
        },
        voice={},
    }]]
}

local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end










local function Init()
    local btn= WoWTools_ChatMixin:GetButtonForName('HyperLink')
    WoWTools_HyperLink:Init_EventTrace()
    WoWTools_HyperLink:Blizzard_Settings()
    WoWTools_HyperLink:Init_Menu()

    btn.eventSoundTexture= btn:CreateTexture(nil,'OVERLAY')
    btn.eventSoundTexture:SetPoint('BOTTOMLEFT',4, 4)
    btn.eventSoundTexture:SetSize(12,12)
    btn.eventSoundTexture:SetAtlas('chatframe-button-icon-voicechat')

    function btn:set_tooltip()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        GameTooltip:AddDoubleLine(WoWTools_HyperLink.addName, WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon))
        if isDisabled then
            GameTooltip:AddDoubleLine('|cnWARNING_FONT_COLOR:' ..(WoWTools_DataMixin.onlyChinese and '关闭聊天' or RESTRICT_CHAT_CONFIG_DISABLE), WoWTools_TextMixin:GetEnabeleDisable(true))
        end
        GameTooltip:Show()
    end

    function btn:set_OnMouseDown()
        Save().linkIcon= not Save().linkIcon and true or false
        WoWTools_HyperLink:Init_Link_Icon()
        local isDisabled= C_SocialRestrictions.IsChatDisabled()
        print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_TextMixin:GetEnabeleDisable(not isDisabled and Save().linkIcon)
        )
        if Save().linkIcon and isDisabled and not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
            Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID)--ItemRef.lua
        end
    end

    WoWTools_HyperLink:Init_Link_Icon()--超链接，图标
    WoWTools_HyperLink:Init_Event_Sound()--播放, 事件声音

--聊天频道，名称 增强
    WoWTools_DataMixin:Hook(ChannelRosterButtonMixin, 'UpdateName', function(self)
        if self:IsLocalPlayer() then
            local region= WoWTools_RealmMixin:Get_Region(WoWTools_DataMixin.Player.Realm)
            self.Name:SetText(
                (region and region.col or '')
                ..'|A:recipetoast-icon-star:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME)
            )
        else
            local guid= self.playerLocation and self.playerLocation:GetGUID()
            local name= guid and self:GetMemberName()
            if name then
                local t=''
--欧美，服务器语言
                local region= WoWTools_RealmMixin:Get_Region(name:match('%-(.+)') or '', guid)
                if region then
                    t= t..region.col
                end
--种族
                t= t..(WoWTools_UnitMixin:GetRaceIcon(nil, guid) or '')
--职业
                t= t..(WoWTools_UnitMixin:GetClassIcon(nil, guid) or '')
--等级
                local data= WoWTools_DataMixin.UnitItemLevel[guid]
                if data then
--专精
                    if data.specID then
                        t= t..'|T'..(select(4, GetSpecializationInfoByID(data.specID)) or 0)..':0|t'
                    end
--装等
                    if data.itemLevel then
                        t= t..'|cnGREEN_FONT_COLOR:[|r|cffffffff'..data.itemLevel..'|r|cnGREEN_FONT_COLOR:]|r'
                    end
                end
--处理，服务器名称
                if name:find('%-') then
                    if name:find('%-'..WoWTools_DataMixin.Player.Realm) then
                        t= t..name:gsub('%-'..WoWTools_DataMixin.Player.Realm, '')
                    elseif C_PlayerInfo.UnitIsSameServer(self.playerLocation) then
                        t= t..name..'|cnGREEN_FONT_COLOR:*|r'
                    end
                else
                    t= t..name
                end

                self.Name:SetText(t)
            end
        end
    end)

    Init=function()end
end








local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_HyperLink']= WoWToolsSave['ChatButton_HyperLink'] or P_Save
            P_Save=nil

            Save().disabedFrameStackPlus= nil

            WoWToolsPlayerDate['HyperLinkColorText']= WoWToolsPlayerDate['HyperLinkColorText'] or {[ACHIEVEMENTS]=true}
            WoWToolsPlayerDate['HyperLinkGuildWelcomeText']= WoWToolsPlayerDate['HyperLinkGuildWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '欢迎' or EMOTE103_CMD1:gsub('/',''))
            WoWToolsPlayerDate['HyperLinkGroupWelcomeText']= WoWToolsPlayerDate['HyperLinkGroupWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}')

            WoWTools_HyperLink.addName= '|A:voicechat-icon-STT-on:0:0|a'..(WoWTools_DataMixin.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))


            if WoWTools_ChatMixin:CreateButton('HyperLink', WoWTools_HyperLink.addName) then
                Init()
                self:RegisterEvent('PLAYER_ENTERING_WORLD')--需要这个，表情，中文化，需要这个
            else

                self:SetScript('OnEvent', nil)
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_HyperLink:Init_NPC_Talking()--隐藏NPC发言
        WoWTools_HyperLink:Init_Welcome()--欢迎加入
        WoWTools_HyperLink:Init_Reload()--添加 RELOAD 按钮
        --WoWTools_HyperLink:Init_EmojiButton()
        --WoWTools_HyperLink:Init_CopyChat()
    end
end)

