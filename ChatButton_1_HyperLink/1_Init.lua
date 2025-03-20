
local id, e = ...
local addName
WoWTools_HyperLink={
    Save={

    linkIcon=true, --超链接，图标
    --notShowPlayerInfo=true,--不处理，玩家信息
    showCVarName=e.Player.husandro,

    channels={--频道名称替换 
        --['世界'] = '[世]',
    },
    text={--内容颜色,
        [ACHIEVEMENTS]=true,
    },
    disabledKeyColor= not e.Player.husandro,--禁用，内容颜色，和频道名称替换

    groupWelcome= e.Player.husandro,--欢迎
    groupWelcomeText= e.Player.cn and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}',

    guildWelcome= e.Player.husandro,
    guildWelcomeText= e.Player.cn and '宝贝，欢迎你加入' or EMOTE103_CMD1:gsub('/',''),

    welcomeOnlyHomeGroup=true,--仅限, 手动组队

    setPlayerSound= e.Player.husandro,--播放, 声音
    Cvar={},
    --disabledNPCTalking=true,--禁用，隐藏NPC发言    
    --disabledTalkingPringText=true,--禁用，隐藏NPC发言，文本

    --not_Add_Reload_Button=true,--添加 RELOAD 按钮
    autoHideTableAttributeDisplay=true,--自动关闭，Fstack
}}

local function Save()
    return WoWTools_HyperLink.Save
end

local LinkButton










local function Init_Button()
    LinkButton.eventSoundTexture= LinkButton:CreateTexture(nil,'OVERLAY')
    LinkButton.eventSoundTexture:SetPoint('BOTTOMLEFT',4, 4)
    LinkButton.eventSoundTexture:SetSize(12,12)
    LinkButton.eventSoundTexture:SetAtlas('chatframe-button-icon-voicechat')

 --事件, 声音, 提示图标


    --[[function LinkButton:HandlesGlobalMouseEvent(buttonName, event)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName == "RightButton"
    end
    function LinkButton:Settings()
        self.texture:SetAtlas(not Save().disabed and e.Icon.icon or e.Icon.disabled)
        self.setPlayerSoundTips:SetShown(Save().setPlayerSound)

        self:UnregisterAllEvents()
--欢迎加入, 信息
        if Save().groupWelcome or Save().guildWelcome then
            self:RegisterEvent('CHAT_MSG_SYSTEM')
        end
--事件, 声音
        if Save().setPlayerSound then
            self:RegisterEvent('START_TIMER')
            self:RegisterEvent('STOP_TIMER_OF_TYPE')
        end
--隐藏NPC发言
        if not Save().disabledNPCTalking then
            self:RegisterEvent('TALKINGHEAD_REQUESTED')
        end
    end

    LinkButton:SetScript('OnEvent', function(_, event, arg1, arg2, arg3)
        if event=='CHAT_MSG_SYSTEM' then
            --Event_CHAT_MSG_SYSTEM(arg1)

        elseif event=='START_TIMER' then
            --Event_START_TIMER(arg1, arg2, arg3)

        elseif event=='STOP_TIMER_OF_TYPE' then
            --Event_STOP_TIMER_OF_TYPE()

        elseif event=='TALKINGHEAD_REQUESTED' then
            --Set_Talking()
        end
    end)

    

    LinkButton:Settings()]]

end












local function Init()

    Init_Button()
    WoWTools_HyperLink:Init_Button_Menu()
    WoWTools_HyperLink:Init_Link_Icon()--超链接，图标
    WoWTools_HyperLink:Init_Event_Sound()--播放, 事件声音
    WoWTools_HyperLink:Init_NPC_Talking()--隐藏NPC发言
    WoWTools_HyperLink:Init_Welcome()--欢迎加入
    WoWTools_HyperLink:Blizzard_DebugTools()--fstack 增强 TableAttributeDisplay

    --[[if not Save.disabed then--使用，禁用
        Set_HyperLlinkIcon()
    end


    LFGListInviteDialog:SetScript("OnShow", Set_LFGListInviteDialog_OnShow)--队伍查找器, 接受邀请
    Init_Add_Reload_Button()--添加 RELOAD 按钮
    Set_PlayerSound()--事件, 声音]]



end
















local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then
            WoWTools_HyperLink.Save= WoWToolsSave['ChatButton_HyperLink'] or Save()

            Save().linkIcon= not Save().disabed
            Save().disabed= nil
            
            addName= '|A:voicechat-icon-STT-on:0:0|a'..(e.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
            LinkButton= WoWTools_ChatMixin:CreateButton('HyperLink', addName)

            WoWTools_HyperLink.LinkButton= LinkButton
            WoWTools_HyperLink.addName= addName

            if LinkButton then
                Init()

            else
                DEFAULT_CHAT_FRAME.P_AddMessage= nil
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_Settings' then
            WoWTools_HyperLink:Init_Panel()
            if C_AddOns.IsAddOnLoaded('Blizzard_DebugTools') then
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_DebugTools' then--FSTACK Blizzard_DebugTools.lua
            WoWTools_HyperLink:Blizzard_DebugTools()
            if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                self:UnregisterEvent(event)
            end
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_HyperLink']= Save()
        end
    end
end)

