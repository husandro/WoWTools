local P_Save= {
    emoji={'DANCE'},
    chat={},--聊天
    command={},--宏

    useChat={},--自定义，聊天
    useCommand={}--自定义，宏
}
local P_SaveUse={
    use={
        --CLICK={name='', add=''},
    },
    chat={
        [YELL]= '/y '..FIND_A_GROUP
    },
    command={
        [MOUNTS]= "/run C_MountJournal.SummonByID(0)"
    },
}

local function Save()
    return WoWToolsSave['Plus_EmoteButton']
end

local Init_Button

local function SaveUse(name)
    return WoWToolsPlayerDate['EmoteButton'][name]
end

local MainButton
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



local function Get_Name(value, isChat, isCommand, useType)
    local name
    if useType then
        name= value

    elseif isChat then
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



local function Rest_Button()
    StaticPopup_Show('WoWTools_OK',
        addName..'|n|n'..(WoWTools_DataMixin.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
        nil,
    function()
        WoWToolsSave['Plus_EmoteButton']= CopyTable(P_Save)
        MainButton:set_point()
        Init_Button()
    end)
end

local function On_Click(self)
    local value= self.value
    local add= SaveUse('use')[value] and SaveUse('use')[value].add
    if self.useType then
        local va= SaveUse(self.useType)[value]
        if va then
            WoWTools_ChatMixin:SendText(va)
        end
    elseif self.isChat then
        if value=='REPLY' then
            ChatFrameUtil.ReplyTell()

        elseif value=='WHISPER' then
            local name= WoWTools_UnitMixin:UnitGUID('target')
                and UnitIsPlayer('target')
                and UnitIsFriend('target', 'player')
                and GetUnitName("target", true)
                or nil
            WoWTools_ChatMixin:Say(SLASH_YELL1..' ', name, nil, add)
        else
            local va= _G['SLASH_'..value..1]
            if va then
                WoWTools_ChatMixin:Say(va..' '..(add or ''))
            end
        end

    elseif self.isCommand then
        ChatFrameUtil.OpenChat(Get_Name(value, nil, true, nil)..' '..(add or ''))

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
local function On_Enter(self)
    local isUIParent= Save().isUIParent
    if WoWToolsSave['ChatButton'].disabledTooltiip and not isUIParent then--禁用提示
        return
    end

    GameTooltip:SetOwner(self, isUIParent and 'ANCHOR_LEFT' or "ANCHOR_BOTTOMRIGHT")

    local name= self.useType and self.value or Get_Name(self.value, self.isChat, self.isCommand)

    local add
    if self.useType then
        add= self:GetAttribute('macrotext1') or (SaveUse(self.useType) and SaveUse(self.useType)[self.value])
    else
        add= SaveUse('use')[self.value] and SaveUse('use')[self.value].add
    end

    name=WoWTools_TextMixin:CN(name)
    --name= name:gsub('/', '')
    GameTooltip:SetText(WoWTools_DataMixin.Icon.left..name..(self.useType and '' or WoWTools_DataMixin.Icon.right))
    GameTooltip:AddLine(add, 0, 0.8, 1, true)

    GameTooltip:Show()
end
local function Set_Tooltip(tooltip, value, vaName, isChat, isCommand)
    local emoteIndex= not (isChat or isCommand) and EmoteIndex(value)
    tooltip:AddDoubleLine(value, emoteIndex)
    local str= value=='WHISPER' and 'SLASH_SMART_%s%d'
        or ((isChat or isCommand) and 'SLASH_%s%d')
        or 'EMOTE%s_CMD%d'

    vaName= vaName or Get_Name(value, isChat, isCommand)

    for i= 1, 12 do
        local va= _G[format(str, emoteIndex and ''..emoteIndex or value, i)]
        if va then
            va= (va==vaName and '|cffffffff' or '')..va..' '
            tooltip:AddDoubleLine(va, '|cff626262'..i)
        else
            break
        end
    end

    local data= SaveUse('use')[value]
    if data then
        local add, name= data.name, data.add
        if add or name then
            tooltip:AddLine(' ')
            tooltip:AddLine(name, 0, 0.8, 1)
            tooltip:AddLine(add, 0, 0.8, 1, true)
        end
    end
end














local function Init_Button_Menu(self, root)
    local value= self.value
    local valueName= Get_Name(value, self.isChat, self.isCommand, self.useType)
    local cn= WoWTools_TextMixin:CN(valueName)
    cn= cn~=valueName and cn or nil

    local sub=root:CreateButton(
        (SaveUse('use')[value] and SaveUse('use')[value].name and '|cff00ccff' or '')
        ..(WoWTools_DataMixin.onlyChinese and '修改名称' or HUD_EDIT_MODE_RENAME_LAYOUT),
    function()
        StaticPopup_Show('WoWTools_EditText',
            (WoWTools_DataMixin.onlyChinese and '修改名称' or HUD_EDIT_MODE_RENAME_LAYOUT)
            ..'|n|n'
            ..valueName
            ..(cn and '|n'..cn or ''),
            nil,
            {
                OnShow= function(s)
                    local t= SaveUse('use')[value] and SaveUse('use')[value].name
                    s:GetButton3():SetEnabled(t and true or false)
                    if not t then
                        t= cn or valueName
                        t= t:gsub('/', '')
                    end
                    s:GetEditBox():SetText(t)
                end,
                SetValue= function(s)
                    local va= s:GetEditBox():GetText()
                    SaveUse('use')[value]= SaveUse('use')[value] or {}
                    SaveUse('use')[value].name= va
                    Init_Button()
                end,
                OnAlt=function()
                    if SaveUse('use')[value] then
                        SaveUse('use')[value].name=nil
                        Init_Button()
                    end
                end,
            }
        )
    end)
    sub:SetTooltip(function(tooltip)
        Set_Tooltip(tooltip, value, valueName, self.isChat, self.isCommand, self.useType)
    end)




    sub=root:CreateButton(
        (SaveUse('use')[value] and SaveUse('use')[value].add and '|cff00ccff' or '')
        ..(WoWTools_DataMixin.onlyChinese and '添加参数'or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, MACRO)),
    function()
         StaticPopup_Show('WoWTools_EditText',
            addName..'|n|n'..valueName..' |cffffffff('..(WoWTools_DataMixin.onlyChinese and '参数' or MACRO)..')|r'
            ..(cn and '|n'..cn or ''),
            nil,
            {
                OnShow= function(s)
                    local t= SaveUse('use')[value] and SaveUse('use')[value].add
                    s:GetButton3():SetEnabled(t and true or false)
                    if t then
                        s:GetEditBox():SetText(t)
                    end
                    s:GetButton1():SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                end,
                SetValue= function(s)
                    local va= s:GetEditBox():GetText()
                    SaveUse('use')[value]= SaveUse('use')[value] or {}
                    SaveUse('use')[value].add= va
                    Init_Button()
                end,
                OnAlt=function()
                    if SaveUse('use')[value] then
                        SaveUse('use')[value].add=nil
                        Init_Button()
                    end
                end,
                EditBoxOnTextChanged= function(s)
                    local t=s:GetText() or ''
                    s:GetParent().Text:SetText(
                        addName..'|n|n'..valueName..' |cff00ccff'..t..'|r'
                        ..(cn and '|n'..cn or '')
                    )
                end
            }
        )
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(SaveUse('use')[value] and SaveUse('use')[value].add, nil, nil, nil, true)
    end)
    sub:SetEnabled(self.isChat or self.isCommand)

    root:CreateDivider()
    WoWTools_ChatMixin:Open_SettingsPanel(root, addName)
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





















function Init_Button()
    if WoWTools_FrameMixin:IsLocked(MainButton) then
        print(addName,'|cnWARNING_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_COOLDOWN_VIEWER_VISIBLE_SETTING_IN_COMBAT)
        MainButton:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    local isInCombat= InCombatLockdown()


    local isUIParent= Save().isUIParent
    local line= Save().line or 1
    local subNum= Save().subName or (LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN or WoWTools_ChineseMixin) and 1 or 3
    local scale= Save().scale or 1
    local alpha= Save().alpha or 0.5
    local fontScale= Save().fontScale or 1
    local btnW, btnH= Save().width or 32, Save().height or 32
    local isSecure= Save().isSecure

    local _newTab= {}
    for _, value in pairs(Save().chat) do
        table.insert(_newTab, {value=value, isChat=true, isCommand=nil, isSecure=nil, useType=nil})
    end
    for _, value in pairs(Save().useChat) do
        if SaveUse('chat')[value] then
            table.insert(_newTab, {value=value, isChat=true, isCommand=nil, isSecure=nil, useType='chat'})
        end
    end

    for _, value in pairs(Save().emoji) do
        table.insert(_newTab, {value=value, isChat=nil, isCommand=nil, isSecure=nil, useType=nil})
    end


    for _, value in pairs(Save().command) do
        table.insert(_newTab, {value=value, isChat=nil, isCommand=true, isSecure=isSecure, useType=nil})
    end
    for _, value in pairs(Save().useCommand) do
        if SaveUse('command')[value] then
            table.insert(_newTab, {value=value, isChat=nil, isCommand=true, isSecure=true, useType='command'})
        end
    end

    MainButton.pool:ReleaseAll()
    MainButton.poolSecur:ReleaseAll()

    local _buttons={}
    local index=0
    local secureIndex=0

    for i, tab in pairs(_newTab) do
        local canChange= tab.isSecure and not isInCombat or not tab.isSecure
        local valueName= Get_Name(tab.value, tab.isChat, tab.isCommand, tab.useType)
        if canChange then


            local btn= tab.isSecure and MainButton.poolSecur:Acquire() or MainButton.pool:Acquire()
            table.insert(_buttons, btn)

            if tab.useType=='command' then
                btn:SetAttribute('type1', 'macro')
                btn:SetAttribute('type1', 'macro')
                btn:SetAttribute("macrotext1", SaveUse(tab.useType)[tab.value])
                btn:SetScript('OnMouseDown', nil)
                secureIndex= secureIndex+ 1

            elseif tab.isSecure then
                local add= SaveUse('use')[tab.value] and SaveUse('use')[tab.value].add
                btn:SetAttribute('type1', 'macro')
                btn:SetAttribute("macrotext1", valueName..(add and ' '..add or ''))
                btn:SetScript('OnMouseDown', function(self, d)
                    if d=='RightButton' then
                        MenuUtil.CreateContextMenu(self, Init_Button_Menu)
                    end
                end)
                secureIndex= secureIndex+ 1

            else
                index= index+1
                btn:SetScript('OnMouseDown', function(self, d)
                    if d=='RightButton' and not self.useType then
                        MenuUtil.CreateContextMenu(self, Init_Button_Menu)
                    else
                        On_Click(self)
                    end
                end)
            end
            btn:SetScript('OnEnter', On_Enter)


            btn.value= tab.value
            btn.isChat= tab.isChat
            btn.isCommand= tab.isCommand
            btn.isSecure= tab.isSecure
            btn.useType= tab.useType


            local x= isUIParent and 0 or 2.5
            local icon= btn:GetNormalTexture()
            icon:SetPoint('TOPLEFT', x, -x)
            icon:SetPoint('BOTTOMRIGHT', -x, x)
            icon:SetAlpha(alpha)

            icon= btn:GetPushedTexture()
            icon:SetPoint('TOPLEFT', x, -x)
            icon:SetPoint('BOTTOMRIGHT', -x, x)

            btn:SetScale(scale)

            local name= SaveUse('use')[tab.value] and SaveUse('use')[tab.value].name
            if not name then
                name= WoWTools_TextMixin:CN(valueName)
                name= name:gsub('/', '')
            end
            if subNum>0 then
                name= WoWTools_TextMixin:sub(name, subNum)
            end

            btn.Text:SetText(name:upper())
            btn.Text:SetScale(fontScale)
            btnW= btnW==0 and (btn.Text:GetStringWidth()+13) or btnW
            btnH= btnH==0 and (btn.Text:GetStringHeight()+13) or btnH
            btn:SetSize(btnW, btnH)

            btn:SetParent(isUIParent and MainButton or GeneralDockManager)
            btn:ClearAllPoints()
            if isUIParent then
                if i>1 and select(2, math.modf((i-1)/line))==0 then
                    btn:SetPoint('BOTTOM', _buttons[i-line], 'TOP')
                else
                    btn:SetPoint('LEFT', _buttons[i-1] or MainButton, 'RIGHT')
                end
            elseif not _buttons[i-1] then
                btn:SetPoint('BOTTOMRIGHT', ChatFrame1, 'BOTTOMLEFT', -4, 32)
            else
                btn:SetPoint('BOTTOM', _buttons[i-1], 'TOP')
            end

            btn:Show()
        end
    end


    if isUIParent then
        MainButton:set_texture()
        local all= index+ secureIndex
        if all>0 then
            MainButton.Background:SetPoint('TOP', _buttons[all], 0, 1)
            MainButton.Background:SetPoint('RIGHT', _buttons[all>=line and line or all], 1, 0)
            MainButton.Background:SetPoint('BOTTOMLEFT', _buttons[1], -1, -1)
            MainButton.Background:SetAlpha(Save().bgAlpha or 0)
        end
        MainButton.Background:SetShown(index>0)

        MainButton:SetFrameStrata(Save().strata or 'MEDIUM')
    end
    MainButton:SetShown(isUIParent)

    _buttons= nil
    _newTab= nil
end












--添加，自定义
local function Init_UseFrame()
    local typeTab={
        chat= WoWTools_DataMixin.onlyChinese and '聊天' or CHAT,
        command= WoWTools_DataMixin.onlyChinese and '宏' or MACRO,
    }

    local frame= WoWTools_FrameMixin:Create(UIParent, {
        header= addName,
        name='WoWToolsEmoteUseAddFrame',
        size={400, 250},
    })
    frame.type= Save().useFrameType or 'chat'--保存上次值

    local function Get_TypeNum(t)
        t= t or frame.type
        return CountTable(SaveUse(t) or {})
    end

    local menu= CreateFrame("DropdownButton", nil, frame, "WowStyle1DropdownTemplate")
    menu:SetWidth(150)
    menu:SetPoint('TOPLEFT', 13, -32)
    menu:SetDefaultText(WoWTools_DataMixin.onlyChinese and '聊天' or CHAT)


    local list= CreateFrame('DropdownButton', nil, menu, 'WoWToolsMenu2Template')
    list:SetSize(32, 32)
    list:SetPoint('LEFT', menu, 'RIGHT', 5,0)
    list:SetNormalAtlas('chatframe-button-up')
    WoWTools_TextureMixin:SetAlphaColor(list:GetNormalTexture(), nil, nil, 0.5)
    list.Text= list:CreateFontString(nil, 'OVERLAY', 'GameFontWhite')
    list.Text:SetPoint('CENTER')
    function list:set_text()
        self.Text:SetText(Get_TypeNum())
    end
    list:set_text()



    local editName= CreateFrame('EditBox', nil, frame, 'SearchBoxTemplate')
    editName.Instructions:SetText(WoWTools_DataMixin.onlyChinese and '名称' or NAME)
    editName:SetPoint('LEFT', list, 'RIGHT', 7, 0)
    editName:SetPoint('RIGHT', -23*3, 0)
    editName:SetHeight(23)
    editName.searchIcon:SetAtlas('newplayerchat-chaticon-newcomer')


    local add= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
    add:SetNormalAtlas('Garr_Building-AddFollowerPlus')
    add:SetDisabledAtlas('pvptalents-talentborder-empty')
    add:SetPoint('LEFT', editName, 'RIGHT', 2, 0)
    add:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText((WoWTools_DataMixin.onlyChinese and '添加' or ADD)..': |cffffffff'..typeTab[frame.type])
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(frame.value, 0, 0.8,1)
        GameTooltip:AddLine(SaveUse(frame.type)[frame.value], nil, nil, nil, true)
        GameTooltip:Show()
    end)

    local update= CreateFrame('Button', nil, frame, 'WoWToolsButtonTemplate')
    update:SetNormalAtlas('QuestSharing-DialogIcon')
    update:SetDisabledAtlas('QuestSharing-QuestLog-Details-ModifiersReplayIconOff')
    update:SetPoint('LEFT', add, 'RIGHT', 2, 0)
    update:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetText((WoWTools_DataMixin.onlyChinese and '更新' or UPDATE)..': |cffffffff'..typeTab[frame.type])
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(frame.value, 0, 0.8,1)
        GameTooltip:AddLine(SaveUse(frame.type)[frame.value], nil, nil, nil, true)
        GameTooltip:Show()
    end)

    local editText= WoWTools_EditBoxMixin:CreateFrame(frame, {text=typeTab[frame.type]})
    editText:SetPoint("TOPLEFT", menu, 'BOTTOMLEFT', 0, -10)
    editText:SetPoint('BOTTOMRIGHT', -13, 13)


    local TabGroup= CreateTabGroup(editName, editText.editBox)
    editName:SetScript('OnTabPressed', function() TabGroup:OnTabPressed() end)
    editText.editBox:SetScript('OnTabPressed', function() TabGroup:OnTabPressed() end)


    local function Settings()
        local name= editName:GetText() or ''
        local text= editText:GetText() or ''
        local isChat= frame.type=='chat'
        local enabled= name~='' and text~='' and (isChat and text:find('^/.+') or not isChat)

        add:SetEnabled(enabled and not SaveUse(frame.type)[name])
        update:SetEnabled(enabled and SaveUse(frame.type)[frame.value])
    end
    editName:HookScript('OnTextChanged', Settings)
    editText.editBox:HookScript('OnTextChanged', Settings)


    menu:SetupMenu(function(self, root)
        for _, type in pairs({'chat', 'command'}) do
            local sub= root:CreateRadio(
                typeTab[type]..' #'..Get_TypeNum(type),
            function(data)
                return data.type==frame.type
            end, function(data)
                frame.type= data.type
                self:SetDefaultText(typeTab[data.type])
                list:set_text()
                editText.editBox.Instructions:SetText(typeTab[data.type])
                Settings()
                Save().useFrameType= data.type--保存上次值
            end, {type=type})
            if type=='command' then
                sub:SetTooltip(function(tooltip)
                    GameTooltip_AddErrorLine(tooltip, 'SecureActionButtonTemplate')
                end)
            end
        end
    end)



    list:SetupMenu(function(_, root)
        for value, text in pairs(SaveUse(frame.type)) do
            local sub= root:CreateRadio(
                value,
            function(data)
                return data.value==frame.value
            end, function(data)
                frame.value= data.value
                editName:SetText(data.value or '')
                editText:SetText(data.text or '')
                return MenuResponse.Close
            end, {value=value, text=text})
            sub:SetTooltip(function(tooltip, desc)
                tooltip:AddLine(desc.data.text, nil, nil, nil, true)
            end)

            sub:CreateButton(
                '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE),
            function(data)
                 StaticPopup_Show('WoWTools_OK',
                    typeTab[data.type]..'|n'
                    ..(WoWTools_DataMixin.onlyChinese and '删除' or DELETE)
                    ..'|n|n|cff00ccff'
                    ..(data.value or '')
                    ..'|r|n'..(data.text or ''),
                    nil,
                {SetValue=function()
                    SaveUse(data.type)[data.value]=nil
                    list:set_text()
                    Settings()
                    Init_Button()
                end})
                return MenuResponse.Open
            end, {value=value, text=text, type=frame.type})
            sub:SetTooltip(function(tooltip, desc) tooltip:AddLine(desc.data.text, nil, nil, nil, true) end)
        end

        root:CreateDivider()
        root:CreateButton(
            '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
        function()
            StaticPopup_Show('WoWTools_OK',
                typeTab[frame.type]..'|n|n|A:bags-button-autosort-up:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
                nil,
            {SetValue=function()
                WoWToolsPlayerDate['EmoteButton'][frame.type]={}
                list:set_text()
                Settings()
                Init_Button()
            end})
            return MenuResponse.Open
        end)

        WoWTools_MenuMixin:SetScrollMode(root)
    end)

    add:SetScript('OnClick', function()
        SaveUse(frame.type)[editName:GetText()]= editText:GetText()
        Settings()
        list:set_text()
        Init_Button()
    end)
    update:SetScript('OnClick', function()
        SaveUse(frame.type)[editName:GetText()]= editText:GetText()
        Settings()
        Init_Button()
    end)

    Init_UseFrame= function()
        _G['WoWToolsEmoteUseAddFrame']:SetShown(not _G['WoWToolsEmoteUseAddFrame']:IsShown())
    end
end



















local function Set_Menu(root, tab, tabName, rootName)
    local isCommand= tabName=='command'
    local isChat= tabName=='chat'
    local useType= tabName=='useChat' and 'chat' or (tabName=='useCommand' and 'command') or nil

    local sub

    root= root:CreateButton(
        rootName,
    function()
        return MenuResponse.Open
    end, {rightText=#Save()[tabName]})
    WoWTools_MenuMixin:SetRightText(root)

--是否使用，安全按钮
    if isCommand then
        sub= root:CreateCheckbox(
            WoWTools_DataMixin.onlyChinese and '安全按钮' or'Secure Button',
        function()
            return Save().isSecure
        end, function()
            Save().isSecure= not Save().isSecure and true or nil
            Init_Button()
        end)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine('SecureActionButtonTemplate')
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and'友情提示: 可能会出现错误' or 'Note: Errors may occur')
        end)
    end


    --勾选所有
    root:CreateButton(
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
    root:CreateButton(
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
    root:CreateDivider()


    for index, value in pairs(tab) do
        local vaName= Get_Name(value, isChat, isCommand, useType)
        sub=root:CreateCheckbox(
            (SaveUse('use')[value] and (SaveUse('use')[value].add or SaveUse('use')[value].name) and '|cff00ccff' or '')
            ..WoWTools_TextMixin:CN(vaName):gsub('/', ''),
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

        sub:SetTooltip(function(tooltip, desc)
            if useType then
                tooltip:AddLine(SaveUse(useType)[desc.data.vaName])
            else
                Set_Tooltip(tooltip, desc.data.value, desc.data.vaName, isChat, isCommand)
            end
        end)
        sub:AddInitializer(function(btn, desc)
            local font = btn:AttachFontString()
            local offset = desc:HasElements() and -20 or 0
            font:SetPoint("RIGHT", offset, 0)
            font:SetJustifyH("RIGHT")

            local chatShortcut= _G['SLASH_'..desc.data.value..'1']
            chatShortcut= chatShortcut~=desc.data.vaName and chatShortcut or nil

            font:SetTextToFit(
                (chatShortcut and chatShortcut..' ' or '')
                ..'|cff626262'..desc.data.index
            )
            if select(2, math.modf(desc.data.index/2))==0 then
                font:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
                btn.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
            end
        end)

    end

    WoWTools_MenuMixin:SetScrollMode(root)
end


























local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub
    local isRoot= self==MainButton
    local _tab={}

    if not isRoot then
        root= root:CreateButton(
            addName,
        function()
            return MenuResponse.Open
        end, {rightText= MainButton.pool:GetNumActive()+MainButton.poolSecur:GetNumActive()})
        WoWTools_MenuMixin:SetRightText(root)
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
    Set_Menu(root, _tab, 'emoji', WoWTools_DataMixin.onlyChinese and '全部' or ALL)

--聊天
    _tab={'SAY', 'PARTY', 'RAID', 'INSTANCE_CHAT', 'GUILD', 'YELL', 'WHISPER','REPLY',}
    root:CreateDivider()
    Set_Menu(root, _tab, 'chat', WoWTools_DataMixin.onlyChinese and '聊天' or CHAT)

--自定义聊天
    _tab={}
    for value in pairs(SaveUse('chat')) do
        table.insert(_tab, value)
    end
    Set_Menu(root, _tab, 'useChat', WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)

--宏
    root:CreateDivider()
    _tab= {}
    for value in pairs(SLASH_COMMAND) do
        table.insert(_tab, value)
    end
    table.sort(_tab)
    Set_Menu(root, _tab, 'command', WoWTools_DataMixin.onlyChinese and '宏' or MACRO)

--自定义宏
    _tab={}
    for value in pairs(SaveUse('command')) do
        table.insert(_tab, value)
    end
    Set_Menu(root, _tab, 'useCommand', WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)


--添加，自定义
    root:CreateDivider()
    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加自定义' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, CUSTOM),
    function()
        Init_UseFrame()
        return MenuResponse.Open
    end)
--打开选项界面

    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, addName)

--选项


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
        local w= Save().width or 32
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
            maxValue= math.modf(UIParent:GetWidth()/(w==0 and 12 or w)),
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
            return Save().subName or (LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN or WoWTools_ChineseMixin) and 1 or 3
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
    Rest_Button)

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

    MainButton.pool= CreateFramePool('Button', UIParent, 'WoWToolsEmojiButtonTemplate')
    MainButton.poolSecur= CreateFramePool('Button', UIParent, 'WoWToolsEmojiButtonTemplate SecureActionButtonTemplate')
    MainButton.Background=MainButton:CreateTexture(nil, 'BACKGROUND')
    MainButton.Background:SetColorTexture(0,0,0)

    MainButton:SetClampedToScreen(true)

    function MainButton:set_texture()
        if (self.pool:GetNumActive()+self.poolSecur:GetNumActive())==0 or self:IsMouseOver() then
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
        GameTooltip:SetText('|cffffffff'..(self.pool:GetNumActive()+self.poolSecur:GetNumActive()))
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM, WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
        self:set_texture()
    end)
    MainButton:SetMovable(true)
    MainButton:RegisterForDrag("RightButton")
    MainButton:SetScript('OnMouseWheel', function(_, d)
        if d==1 then
            if not _G['WoWToolsEmoteUseAddFrame'] then
                Init_UseFrame()
            else
                _G['WoWToolsEmoteUseAddFrame']:SetShown(true)
            end
        elseif _G['WoWToolsEmoteUseAddFrame'] then
            _G['WoWToolsEmoteUseAddFrame']:SetShown(false)
        end
    end)
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

    MainButton:SetScript('OnEvent', function(self, event)
        Init_Button()
        self:UnregisterEvent(event)
    end)

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
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then
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

            if Save().disabled then
                self:SetScript('OnEvent', nil)
            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end
            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        self:SetScript('OnEvent', nil)
        self:UnregisterEvent(event)
        Init()
    end
end)