if not ChatFrameUtil.OpenChat then--11.2.7才有
    ChatFrameUtil.ReplyTell= ChatFrame_ReplyTell
    ChatFrameUtil.OpenChat= ChatFrame_OpenChat

    SLASH_COMMAND= {
	TARGET = "TARGET",
	INSPECT = "INSPECT",
	STOPATTACK = "STOPATTACK",
	CAST = "CAST",
	USE = "USE",
	STOPCASTING = "STOPCASTING",
	STOPSPELLTARGET = "STOPSPELLTARGET",
	CANCELAURA = "CANCELAURA",
	CANCELFORM = "CANCELFORM",
	EQUIP = "EQUIP",
	EQUIP_TO_SLOT = "EQUIP_TO_SLOT",
	CHANGEACTIONBAR = "CHANGEACTIONBAR",
	SWAPACTIONBAR = "SWAPACTIONBAR",
	TARGET_EXACT = "TARGET_EXACT",
	TARGET_NEAREST_ENEMY = "TARGET_NEAREST_ENEMY",
	TARGET_NEAREST_ENEMY_PLAYER = "TARGET_NEAREST_ENEMY_PLAYER",
	TARGET_NEAREST_FRIEND = "TARGET_NEAREST_FRIEND",
	TARGET_NEAREST_FRIEND_PLAYER = "TARGET_NEAREST_FRIEND_PLAYER",
	TARGET_NEAREST_PARTY = "TARGET_NEAREST_PARTY",
	TARGET_NEAREST_RAID = "TARGET_NEAREST_RAID",
	CLEARTARGET = "CLEARTARGET",
	TARGET_LAST_TARGET = "TARGET_LAST_TARGET",
	TARGET_LAST_ENEMY = "TARGET_LAST_ENEMY",
	TARGET_LAST_FRIEND = "TARGET_LAST_FRIEND",
	ASSIST = "ASSIST",
	FOCUS = "FOCUS",
	CLEARFOCUS = "CLEARFOCUS",
	MAINTANKON = "MAINTANKON",
	MAINTANKOFF = "MAINTANKOFF",
	MAINASSISTON = "MAINASSISTON",
	MAINASSISTOFF = "MAINASSISTOFF",
	DUEL = "DUEL",
	DUEL_CANCEL = "DUEL_CANCEL",
	PET_ATTACK = "PET_ATTACK",
	PET_FOLLOW = "PET_FOLLOW",
	PET_MOVE_TO = "PET_MOVE_TO",
	PET_STAY = "PET_STAY",
	PET_PASSIVE = "PET_PASSIVE",
	PET_DEFENSIVE = "PET_DEFENSIVE",
	PET_DEFENSIVEASSIST = "PET_DEFENSIVEASSIST",
	PET_AGGRESSIVE = "PET_AGGRESSIVE",
	STOPMACRO = "STOPMACRO",
	CANCELQUEUEDSPELL = "CANCELQUEUEDSPELL",
	CLICK = "CLICK",
	PET_DISMISS = "PET_DISMISS",
	LOGOUT = "LOGOUT",
	QUIT = "QUIT",
	GUILD_UNINVITE = "GUILD_UNINVITE",
	GUILD_PROMOTE = "GUILD_PROMOTE",
	GUILD_DEMOTE = "GUILD_DEMOTE",
	GUILD_LEADER = "GUILD_LEADER",
	GUILD_LEAVE = "GUILD_LEAVE",
	GUILD_DISBAND = "GUILD_DISBAND",
	EQUIP_SET = "EQUIP_SET",
	WORLD_MARKER = "WORLD_MARKER",
	CLEAR_WORLD_MARKER = "CLEAR_WORLD_MARKER",
	STARTATTACK = "STARTATTACK",
	CONSOLE = "CONSOLE",
	CHATLOG = "CHATLOG",
	COMBATLOG = "COMBATLOG",
	UNINVITE = "UNINVITE",
	PROMOTE = "PROMOTE",
	REPLY = "REPLY",
	HELP = "HELP",
	MACROHELP = "MACROHELP",
	TIME = "TIME",
	PLAYED = "PLAYED",
	FOLLOW = "FOLLOW",
	TRADE = "TRADE",
	JOIN = "JOIN",
	LEAVE = "LEAVE",
	LIST_CHANNEL = "LIST_CHANNEL",
	CHAT_HELP = "CHAT_HELP",
	CHAT_PASSWORD = "CHAT_PASSWORD",
	CHAT_OWNER = "CHAT_OWNER",
	CHAT_MODERATOR = "CHAT_MODERATOR",
	CHAT_UNMODERATOR = "CHAT_UNMODERATOR",
	CHAT_CINVITE = "CHAT_CINVITE",
	CHAT_KICK = "CHAT_KICK",
	CHAT_BAN = "CHAT_BAN",
	CHAT_UNBAN = "CHAT_UNBAN",
	CHAT_ANNOUNCE = "CHAT_ANNOUNCE",
	GUILD_INVITE = "GUILD_INVITE",
	GUILD_MOTD = "GUILD_MOTD",
	GUILD_INFO = "GUILD_INFO",
	CHAT_DND = "CHAT_DND",
	WHO = "WHO",
	CHANNEL = "CHANNEL",
	FRIENDS = "FRIENDS",
	REMOVEFRIEND = "REMOVEFRIEND",
	IGNORE = "IGNORE",
	UNIGNORE = "UNIGNORE",
	SCRIPT = "SCRIPT",
	RANDOM = "RANDOM",
	MACRO = "MACRO",
	PVP = "PVP",
	READYCHECK = "READYCHECK",
	BENCHMARK = "BENCHMARK",
	DISMOUNT = "DISMOUNT",
	RESETCHAT = "RESETCHAT",
	ENABLE_ADDONS = "ENABLE_ADDONS",
	DISABLE_ADDONS = "DISABLE_ADDONS",
	STOPWATCH = "STOPWATCH",
	ACHIEVEMENTUI = "ACHIEVEMENTUI",
	UI_ERRORS_OFF = "UI_ERRORS_OFF",
	UI_ERRORS_ON = "UI_ERRORS_ON",
	EVENTTRACE = "EVENTTRACE",
	TABLEINSPECT = "TABLEINSPECT",
	DUMP = "DUMP",
	RELOAD = "RELOAD",
	WARGAME = "WARGAME",
	TARGET_MARKER = "TARGET_MARKER",
	OPEN_LOOT_HISTORY = "OPEN_LOOT_HISTORY",
	RAIDFINDER = "RAIDFINDER",
	API = "API",
	COMMENTATOR_OVERRIDE = "COMMENTATOR_OVERRIDE",
	COMMENTATOR_NAMETEAM = "COMMENTATOR_NAMETEAM",
	COMMENTATOR_ASSIGNPLAYER = "COMMENTATOR_ASSIGNPLAYER",
	RESET_COMMENTATOR_SETTINGS = "RESET_COMMENTATOR_SETTINGS",
	VOICECHAT = "VOICECHAT",
	TEXTTOSPEECH = "TEXTTOSPEECH",
	COUNTDOWN = "COUNTDOWN",
	PET_ASSIST = "PET_ASSIST",
	PET_AUTOCASTON = "PET_AUTOCASTON",
	PET_AUTOCASTOFF = "PET_AUTOCASTOFF",
	PET_AUTOCASTTOGGLE = "PET_AUTOCASTTOGGLE",
	SUMMON_BATTLE_PET = "SUMMON_BATTLE_PET",
	RANDOMPET = "RANDOMPET",
	RANDOMFAVORITEPET = "RANDOMFAVORITEPET",
	DISMISSBATTLEPET = "DISMISSBATTLEPET",
	USE_TOY = "USE_TOY",
	PING = "PING",
	ABANDON = "ABANDON",
	INVITE = "INVITE",
	REQUEST_INVITE = "REQUEST_INVITE",
	CHAT_AFK = "CHAT_AFK",
	RAID_INFO = "RAID_INFO",
	DUNGEONS = "DUNGEONS",
	LEAVEVEHICLE = "LEAVEVEHICLE",
	CALENDAR = "CALENDAR",
	SET_TITLE = "SET_TITLE",
	FRAMESTACK = "FRAMESTACK",
	SOLOSHUFFLE_WARGAME = "SOLOSHUFFLE_WARGAME",
	SOLORBG_WARGAME = "SOLORBG_WARGAME",
	SPECTATOR_WARGAME = "SPECTATOR_WARGAME",
	SPECTATOR_SOLOSHUFFLE_WARGAME = "SPECTATOR_SOLOSHUFFLE_WARGAME",
	SPECTATOR_SOLORBG_WARGAME = "SPECTATOR_SOLORBG_WARGAME",
	GUILDFINDER = "GUILDFINDER",
	TRANSMOG_OUTFIT = "TRANSMOG_OUTFIT",
	COMMUNITY = "COMMUNITY",
	RAF = "RAF",
	EDITMODE = "EDITMODE",
};

end

local P_Save= {
    emoji={'DANCE'},
    chat={},--
    command={},--宏
}
local P_SaveUse={
    use={
        --CLICK={name='', add=''},
    },
    chat={},
    command={},
}

local function Save()
    return WoWToolsSave['Plus_EmoteButton']
end

local function SaveUse()
    return WoWToolsPlayerDate['EmoteButton']
end

local MainButton
local Buttons={}
local MacroBtns={}
local addName


local function Get_Save(value, tabName)
    for index, name in pairs(Save()[tabName]) do
        if name==value then
            return index
        end
    end
    return false
end

local function EmoteIndex(value)
    local i = 1
    local token = _G["EMOTE"..i.."_TOKEN"]
    while ( i < MAXEMOTEINDEX ) do
        if ( token == value ) then
            break
        end
        i = i + 1
        token = _G["EMOTE"..i.."_TOKEN"]
    end
    return i
end



local function Get_Name(value, isChat, isCommand)
    local name

    if isChat then
        name= _G[value..'_MESSAGE']

    elseif isCommand then
        for index= 1, 12 do
            local va= _G["SLASH_"..value..index]
            if not va then
                break
            elseif va and va:find('[\228-\233]') then
                name= va
                break
            else
                name= name or va
                if string.len(va)> string.len(name) then
                    name= va
                end
            end
        end

    else
        local index = EmoteIndex(value)
        local i=1
        name= _G["EMOTE"..index.."_CMD1"]
        local va= name
        while va do
            i= i+1
            va= _G["EMOTE"..index.."_CMD"..i]
            if name:find('[\228-\233]') or not va then
                break
            end
            if string.len(va)> string.len(name) then
                name= va
            end
        end
    end

    return name or _G["SLASH_"..value..'1'] or value
end


local function On_Click(self)
    local value= self.value

    if self.isChat then
        if value=='REPLY' then
            ChatFrameUtil.ReplyTell()
        elseif value=='WHISPER' then
            local name= UnitIsPlayer('target') and UnitIsFriend('target', 'player') and GetUnitName("target", true) or nil
            WoWTools_ChatMixin:Say(SLASH_YELL1..' ', name)
        else
            local va= _G['SLASH_'..value..1]
            if va then
                WoWTools_ChatMixin:Say(va..' ')
            end
        end

    elseif self.isCommand then
        ChatFrameUtil.OpenChat(Get_Name(value, nil, true)..' ')

    else
        if (value == EMOTE454_TOKEN) or (value == EMOTE455_TOKEN) then
            local faction = UnitFactionGroup("player", true)
            if faction == "Alliance" then
                value = EMOTE454_TOKEN
            elseif faction == "Horde" then
                value = EMOTE455_TOKEN
            end
        end
        DoEmote(value)
    end
end

--[[local function SetChatTypeAttribute(chatType)
    local editBox = ChatFrameUtil.OpenChat("")
    editBox:SetAttribute("chatType", chatType)
    editBox:UpdateHeader()
end

local function AddSlashInitializer(root, chatShortcut)
    root:AddInitializer(function(button, description, menu)
        local fontString2 = button:AttachFontString()
        local offset = description:HasElements() and -20 or 0
        fontString2:SetPoint("RIGHT", offset, 0)
        fontString2:SetJustifyH("RIGHT")
        fontString2:SetTextToFit(chatShortcut)

        button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    end)
end]]







local function Create_Button(index)
    Buttons[index]= CreateFrame('Button', 'WoWToolsEmojiButton'..index, ChatFrameMenuButton, 'WoWToolsButtonTemplate')

    local btn=Buttons[index]

    btn:SetNormalAtlas('chatframe-button-up')
    btn:SetPushedAtlas('chatframe-button-down')
    btn:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight')

    local icon= btn:GetNormalTexture()
    icon:ClearAllPoints()
    WoWTools_ColorMixin:Setup(icon, {type='Texture'})

    icon=btn:GetPushedTexture()
    icon:ClearAllPoints()
    WoWTools_ColorMixin:Setup(icon, {type='Texture'})

    btn.text= btn:CreateFontString(nil, 'OVERLAY', 'ChatFontNormal')
    btn.text:SetPoint('CENTER')
    btn.text:SetJustifyH('CENTER')
    WoWTools_ColorMixin:Setup(btn.text, {type='FontString'})

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        local isUIParent= Save().isUIParent
        if WoWToolsSave['ChatButton'].disabledTooltiip and not isUIParent then--禁用提示
            return
        end
        GameTooltip:SetOwner(self, isUIParent and 'ANCHOR_LEFT' or "ANCHOR_BOTTOMRIGHT")
        local name= Get_Name(self.value, self.isChat, self.isCommand)
        name=WoWTools_TextMixin:CN(name)
        name= name:gsub('/', '')
        GameTooltip:SetText(name)
        GameTooltip:Show()
    end)
    btn:SetScript('OnMouseDown', function(self)
        On_Click(self)
    end)


    return btn
end
















local function Init_Button()
     if WoWTools_FrameMixin:IsLocked(MainButton) then
        print(addName,'|cnWARNING_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local w= ChatFrameMenuButton:GetWidth() or 32

    local isUIParent= Save().isUIParent
    local line= Save().line or 1
    local subNum= Save().subName or (LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN) and 1 or 3
    local scale= Save().scale or 1
    local alpha= Save().alpha or 0.5
    local fontScale= Save().fontScale or 1
    local btnW, btnH= Save().width or w, Save().height or w

    local _newTab= {}
    for _, value in pairs(Save().chat) do
        table.insert(_newTab, {value=value, isChat=true})
    end
    for _, value in pairs(Save().emoji) do
        table.insert(_newTab, {value=value})
    end
    for _, value in pairs(Save().command) do
        table.insert(_newTab, {value=value, isCommand=true})
    end



    for index, tab in pairs(_newTab) do

        local btn= Buttons[index]
        if not btn then
            btn= Create_Button(index)
        else
            btn:ClearAllPoints()
        end

        btn.value= tab.value
        btn.isCommand= tab.isCommand
        btn.isChat= tab.isChat

        if isUIParent then
            if index>1 and select(2, math.modf((index-1)/line))==0 then
                btn:SetPoint('BOTTOM', Buttons[index-line], 'TOP')
            else
                btn:SetPoint('LEFT', Buttons[index-1] or MainButton, 'RIGHT')
            end
        else
            btn:SetPoint('BOTTOM', Buttons[index-1] or ChatFrameMenuButton, 'TOP')
        end


        local x= isUIParent and 0 or 2.5
        local icon= btn:GetNormalTexture()
        icon:SetPoint('TOPLEFT', x, -x)
        icon:SetPoint('BOTTOMRIGHT', -x, x)
        icon:SetAlpha(alpha)

        icon= btn:GetPushedTexture()
        icon:SetPoint('TOPLEFT', x, -x)
        icon:SetPoint('BOTTOMRIGHT', -x, x)

        btn:SetParent(isUIParent and MainButton or ChatFrameMenuButton)
        btn:SetScale(scale)

        local name= SaveUse().use[tab.value] and SaveUse().use[tab.value].name
        if not name then
            name= Get_Name(tab.value, tab.isChat, tab.isCommand)
            name= WoWTools_TextMixin:CN(name)
            name= name:gsub('/', '')
        end
        if subNum>0 then
            name= WoWTools_TextMixin:sub(name, subNum)
        end

        btn.text:SetText(name:upper())
        btn.text:SetScale(fontScale)

        btnW= btnW==0 and (btn.text:GetStringWidth()+13) or btnW
        btnH= btnH==0 and (btn.text:GetStringHeight()+13) or btnH

        btn:SetSize(btnW, btnH)

        btn:SetShown(true)
    end


    local numButton= #_newTab
    if isUIParent then
        MainButton:SetFrameStrata(Save().strata or 'MEDIUM')
        MainButton:set_texture()

        if numButton>0 then
            MainButton.Background:SetPoint('TOP', Buttons[numButton], 0, 1)
            MainButton.Background:SetPoint('RIGHT', Buttons[numButton>=line and line or numButton], 1, 0)
            MainButton.Background:SetPoint('BOTTOMLEFT', Buttons[1], -1, -1)
            MainButton.Background:SetAlpha(Save().bgAlpha or 0)
        end
        MainButton.Background:SetShown(numButton>0)
    end
    MainButton:SetShown(isUIParent)

    for i= numButton+1, #Buttons do
        local btn= Buttons[i]
        btn:SetShown(false)
    end

    _newTab= nil
end













local function Rest_Button()
    StaticPopup_Show('WoWTools_RestData',
        addName..'|n'
        ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        nil,
    function()
        WoWToolsSave['Plus_EmoteButton']= CopyTable(P_Save)
        MainButton:set_point()
        Init_Button()
    end)
end


local function Set_Menu(root, tab, tabName, rootName)
    local isCommand= tabName=='command'
    local isChat= tabName=='chat'
    local isEmote=  not isChat and not isCommand

    local sub= root:CreateButton(
        rootName
        ..' #'..#Save()[tabName],
    function()
        return MenuResponse.Open
    end)

    --勾选所有
    sub:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS)
        ..' #'..#tab,
    function()
        for _, value in pairs(tab) do
            if not Get_Save(value, tabName) then
                table.insert(Save()[tabName], value)
            end
        end
        Init_Button()
        return MenuResponse.Refresh
    end)

--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        for _, value in pairs(tab) do
            local index= Get_Save(value, tabName)
            if index then
                table.remove(Save()[tabName], index)
            end
        end
        Init_Button()
        return MenuResponse.Refresh
    end)
    sub:CreateDivider()


    for index, value in pairs(tab) do
        local vaName= Get_Name(value, isChat, isCommand)
        local sub2=sub:CreateCheckbox(
            WoWTools_TextMixin:CN(vaName):gsub('/', ''),
        function(data)
            return Get_Save(data.value, tabName)
        end, function(data)
            local tabIndex= Get_Save(data.value, tabName)
            if tabIndex then
                table.remove(Save()[tabName], tabIndex)
            else
                table.insert(Save()[tabName], data.value)
            end
            Init_Button()
        end, {value=value, vaName=vaName, index=index})

        sub2:SetTooltip(function(tooltip, desc)
            local emoteIndex= isEmote and EmoteIndex(desc.data.value)
            tooltip:AddDoubleLine(desc.data.value, emoteIndex)

            local str= value=='WHISPER' and 'SLASH_SMART_%s%d'
                or ((isChat or isCommand) and 'SLASH_%s%d')
                or 'EMOTE%s_CMD%d'

            for i= 1, 12 do
                local va= _G[format(str, emoteIndex and ''..emoteIndex or desc.data.value, i)]
                if va then
                    va= (va==desc.data.vaName and '|cffffffff' or '')..va..' '
                    tooltip:AddDoubleLine(va, i)
                else
                    break
                end
            end
        end)
        sub2:AddInitializer(function(btn, desc)
            local font = btn:AttachFontString()
            local offset = desc:HasElements() and -20 or 0
            font:SetPoint("RIGHT", offset, 0)
            font:SetJustifyH("RIGHT")

            local chatShortcut= _G['SLASH_'..desc.data.value..'1']
            chatShortcut= chatShortcut~=desc.data.vaName and chatShortcut or nil

            font:SetTextToFit(
                (chatShortcut and chatShortcut..' ' or '')
                ..desc.data.index
            )
            if select(2, math.modf(desc.data.index/2))==0 then
                font:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
                btn.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
            end
        end)

    end

    WoWTools_MenuMixin:SetScrollMode(sub)
end

















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub
    local isRoot= self==MainButton
    local _tab={}

    if not isRoot then
        root= root:CreateButton(addName..' '..(#Save().emoji+#Save().command+ #Save().chat), function() return MenuResponse.Open end)
    end

--表情
    Set_Menu(root, EmoteList, 'emoji', WoWTools_DataMixin.onlyChinese and '表情' or EMOTE_MESSAGE)
--谈话
    Set_Menu(root, TextEmoteSpeechList, 'emoji', WoWTools_DataMixin.onlyChinese and '谈话' or VOICEMACRO_LABEL)
--合集
    for i= 1, MAXEMOTEINDEX do
        local value= _G["EMOTE"..i.."_CMD1"] and _G['EMOTE'..i..'_TOKEN']
        if value then
            table.insert(_tab, value)
        end
    end
    Set_Menu(root, _tab, 'emoji', 'Emote')

--聊天
    _tab={
        'SAY',
        'PARTY',
        'RAID',
        'INSTANCE_CHAT',
        'GUILD',
        'YELL',
        'WHISPER',
        'REPLY',

    }
    Set_Menu(root, _tab, 'chat', WoWTools_DataMixin.onlyChinese and '聊天' or CHAT)
    root:CreateSpacer()

--宏
    _tab= {}
    for value in pairs(SLASH_COMMAND) do
        table.insert(_tab, value)
    end

    table.sort(_tab)
    Set_Menu(root, _tab, 'command', WoWTools_DataMixin.onlyChinese and '宏' or MACRO)



--打开选项界面
    root:CreateDivider()
    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, addName)



--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        StaticPopup_Show('WoWTools_OK',
            addName..'|n|n'
            ..(WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS),
            nil,
        {SetValue=function()
            Save().emoji= {}
            Save().command= {}
            Save().chat= {}
            Init_Button()
        end})
        return MenuResponse.Refresh
    end)


--自定义位置
    sub:CreateDivider()
    sub:CreateCheckbox(
        'UIParent',
    function()
        return Save().isUIParent
    end, function()
        Save().isUIParent= not Save().isUIParent and true or nil
        Init_Button()
        return MenuResponse.CloseAll
    end)

--自定义位置
    if Save().isUIParent then
--FrameStrata
        WoWTools_MenuMixin:FrameStrata(self, sub, function(data)
            return MainButton and MainButton:GetFrameStrata()==data
        end, function(data)
            Save().strata= data
            Init_Button()
            return MenuResponse.Refresh
        end)
--数量
        sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return Save().line or 1
            end,
            setValue=function(value)
                Save().line= value
                Init_Button()
            end,
            name=WoWTools_DataMixin.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL,
            minValue=1,
            maxValue=math.max(#EmoteList+#TextEmoteSpeechList, #Buttons),
            step=1,
        })
--背景 Alpha
        sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
            getValue=function()
                return Save().bgAlpha or 0
            end,
            setValue=function(value)
                Save().bgAlpha= value
                Init_Button()
            end,
            name=WoWTools_DataMixin.onlyChinese and '背景' or BACKGROUND,
            minValue=0,
            maxValue=1,
            step=0.1,
            bit='%0.1f',
        })

        sub:CreateSpacer()
    end



--字体缩放
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().fontScale or 1
        end,
        setValue=function(value)
            Save().fontScale= value
            Init_Button()
        end,
        name=WoWTools_DataMixin.onlyChinese and '字体' or FONT_SIZE,
        minValue=0.2,
        maxValue=4,
        step=0.1,
        bit='%0.1f',
    })

    sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().subName or (LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN) and 1 or 3
        end,
        setValue=function(value)
            Save().subName= value
            Init_Button()
        end,
        name=WoWTools_DataMixin.onlyChinese and '截取' or 'sub',
        minValue=0,
        maxValue=20,
        step=1,
    })

--背景, 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().alpha or 0.5
    end, function(value)--SetValue
        Save().alpha= value
        Init_Button()
    end, nil, true)

    sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().width or 32
        end,
        setValue=function(value)
            Save().width= value
            Init_Button()
        end,
        name=WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH,
        minValue=0,
        maxValue=128,
        step=1,
    })

    sub:CreateSpacer()
        WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().height or 32
        end,
        setValue=function(value)
            Save().height= value
            Init_Button()
        end,
        name=WoWTools_DataMixin.onlyChinese and '高度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT,
        minValue=0,
        maxValue=128,
        step=1,
    })

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        Init_Button()
    end)
    
--重置
    sub:CreateDivider()
    sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
    function()
        StaticPopup_Show('WoWTools_OK',
            addName..'|n|n'
            ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
            nil,
        {SetValue=Rest_Button})
        return MenuResponse.Refresh
    end)

    sub:CreateButton(
        '|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '清除输入数据' or 'Clear input data'),
    function()
        StaticPopup_Show('WoWTools_OK',
            addName..'|n|n|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '清除输入数据' or 'Clear input data'),
            nil,
        {SetValue=function()
            WoWToolsPlayerDate['EmoteButton']= CopyTable(P_SaveUse)
        end})
        return MenuResponse.Refresh
    end)

    _tab=nil
end

















local function Init()
    if Save().disabled then
        MainButton:Hide()
        return
    end

    MainButton.Background=MainButton:CreateTexture(nil, 'BACKGROUND')
    MainButton.Background:SetColorTexture(0,0,0)

    MainButton:SetClampedToScreen(true)

    function MainButton:set_texture()
        if (#Save().emoji+#Save().command+#Save().chat)==0 or self:IsMouseOver() then
            self:SetNormalAtlas('newplayerchat-chaticon-newcomer')
        else
            self:SetNormalTexture(0)
        end
    end
    function MainButton:set_point()
        local p= Save().point
        self:ClearAllPoints()
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('CENTER')
        end
    end

    MainButton:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_texture()
    end)
    MainButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

        GameTooltip:SetText(
            (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..WoWTools_DataMixin.Icon.left
            ..'|cffffffff'..(#Save().emoji+#Save().chat+#Save().command)..'|r'
            ..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)..'(+Alt)'
        )
        GameTooltip:Show()
        self:set_texture()
    end)
    MainButton:SetMovable(true)
    MainButton:RegisterForDrag("RightButton")
    MainButton:SetScript('OnMouseUp', ResetCursor)
    MainButton:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    MainButton:SetScript('OnDragStart', function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    MainButton:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
        ResetCursor()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().point= {self:GetPoint(1)}
            Save().point[2]= nil
        end
    end)

    Menu.ModifyMenu("MENU_CHAT_SHORTCUTS", function(self, root)
        Init_Menu(self, root)
    end)

    MainButton:set_point()
    Init_Button()

    Init=function()
        if not WoWTools_FrameMixin:IsLocked(MainButton) then
            MainButton:SetShown(Save().disabled)
            if not Save().disabled then
                Init_Button()
            end
        else
            print(addName,'|cnWARNING_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_VISIBLE_SETTING_IN_COMBAT)
        end
    end
end
















MainButton= CreateFrame('Button', 'WoWToolsChatEmoteButton', UIParent, 'WoWToolsButtonTemplate')
MainButton:RegisterEvent('ADDON_LOADED')
MainButton:SetScript('OnEvent', function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['Plus_EmoteButton']= WoWToolsSave['Plus_EmoteButton'] or CopyTable(P_Save)
    WoWToolsPlayerDate['EmoteButton']= WoWToolsPlayerDate['EmoteButton'] or CopyTable(P_SaveUse)
    addName= '|A:newplayerchat-chaticon-newcomer:0:0|a'..(WoWTools_DataMixin.onlyChinese and '表情' or EMOTE_MESSAGE)

    WoWTools_PanelMixin:Check_Button({
        checkName= addName,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            Init()
        end,
        buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        buttonFunc= Rest_Button,
        layout= WoWTools_ChatMixin.Layout,
        category= WoWTools_ChatMixin.Category,
        tooltip= WoWTools_DataMixin.onlyChinese and '按钮' or 'Button',
    })

    if not Save().disabled then
        Init()
    end

    self:SetScript('OnEvent', nil)
    self:UnregisterEvent(event)
end)
