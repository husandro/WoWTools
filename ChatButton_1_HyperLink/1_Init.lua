
local id, e = ...
local addName
WoWTools_HyperLink={
    Save={
    --disabed=true, --使用，禁用
    --notShowPlayerInfo=true,--不处理，玩家信息

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

DEFAULT_CHAT_FRAME.ADD= DEFAULT_CHAT_FRAME.AddMessage














local function Init_Button()
    LinkButton.setPlayerSoundTips= LinkButton:CreateTexture(nil,'OVERLAY')
    LinkButton.setPlayerSoundTips:SetPoint('BOTTOMLEFT',4, 4)
    LinkButton.setPlayerSoundTips:SetSize(12,12)
    LinkButton.setPlayerSoundTips:SetAtlas('chatframe-button-icon-voicechat')

end







local function Init()
    Init_Button()

    e.setPlayerSound= Save().setPlayerSound--播放, 声音

    WoWTools_HyperLink:Init_Button_Menu()

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
            
            addName= '|A:bag-reagent-border-empty:0:0|a'..(e.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
            LinkButton= WoWTools_ChatMixin:CreateButton('HyperLink', addName)

            WoWTools_HyperLink.LinkButton= LinkButton
            WoWTools_HyperLink.addName= addName

            if LinkButton then
                Init()

            else
                DEFAULT_CHAT_FRAME.ADD= nil
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

