local P_Save= {
    emoji={'DANCE'},
    command={},
    --subNum= 0
}
local function Save()
    return WoWToolsSave['Plus_EmoteButton']
end

local Button
local Buttons={}
local addName

--[[
local List = {
	["WAVE"]="招",
	["BOW"]="鞠",
	["DANCE"]="跳",
	["APPLAUD"]="鼓",
	["BEG"]="乞",
	["CHICKEN"]="鸡",
	["CRY"]="哭",
	["EAT"]="吃",
	["FLEX"]="强",
	["KISS"]="吻",
	["LAUGH"]="笑",
	["POINT"]="指",
	["ROAR"]="咆",
	["RUDE"]="粗",
	["SALUTE"]="敬",
	["SHY"]="羞",
	["TALK"]="谈",
	["STAND"]="站",
	["SIT"]="坐",
	["SLEEP"]="睡",
	["KNEEL"]="跪",
	["LEAN"]="靠",

    ["HELPME"]="救",
	["INCOMING"]="敌",
	["CHARGE"]="冲",
	["FLEE"]="逃",
	["ATTACKMYTARGET"]="功",
	["OOM"]="魔",
	["FOLLOW"]="跟",
	["WAIT"]="等",
	["HEALME"]="治",
	["CHEER"]="呼",
	["OPENFIRE"]="开",
	["RASP"]="鲁",
	["HELLO"]="好",
	["BYE"]="见",
	["NOD"]="头",
	["NO"]="不",
	["THANK"]="谢",
	["WELCOME"]="欢",
	["CONGRATULATE"]="祝",
	["FLIRT"]="逃",
	["JOKE"]="笑",
	["TRAIN"]="火",
}]]











local function Get_EmojiName(value)
    local i = 1
    local token = _G["EMOTE"..i.."_TOKEN"]
    while ( i < MAXEMOTEINDEX ) do
        if ( token == value ) then
            break
        end
        i = i + 1
        token = _G["EMOTE"..i.."_TOKEN"]
    end
    return _G["EMOTE"..i.."_CMD1"] or value, i
end
local function Get_Save(value)
    for index, name in pairs(Save().emoji) do
        if name==value then
            return index
        end
    end
    return false
end

local function Get_CommandName(value)
    local name
    for i= 1, 12 do
        local va= _G['SLASH_SMART_'..value..i] or _G["SLASH_"..value..i]
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
    return name
end
local function Get_CommandSave(value)
    for index, name in pairs(Save().command) do
        if name==value then
            return index
        end
    end
    return false
end
local function On_Click(self)
    local value= self.value
    if self.isCommand then
        if value=='WHISPER' then
            local editBox = ChatFrameUtil.OpenChat(SLASH_SMART_WHISPER1.." ")
			editBox:SetText(SLASH_SMART_WHISPER1.." "..editBox:GetText())
        elseif value=='REPLY' then
            ChatFrameUtil.ReplyTell()
        else
            ChatFrameUtil.OpenChat(Get_CommandName(value)..' ')
        end
        --[[local editBox = ChatFrameUtil.OpenChat("")
        editBox:SetAttribute("chatType", emote)
        editBox:UpdateHeader()]]
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

local function SetChatTypeAttribute(chatType)
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
end







local function Create_Button(index, w)
    Buttons[index]= CreateFrame('Button', 'WoWToolsEmojiButton'..index, ChatFrameMenuButton, 'WoWToolsButtonTemplate')

    local btn=Buttons[index]

    btn:SetSize(w,w)
    btn:SetNormalAtlas('chatframe-button-up')
    btn:SetPushedAtlas('chatframe-button-down')
    btn:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight')

    local icon= btn:GetNormalTexture()
    icon:ClearAllPoints()
    WoWTools_ColorMixin:Setup(icon, {type='Texture'})

    icon=btn:GetPushedTexture()
    icon:ClearAllPoints()
    WoWTools_ColorMixin:Setup(icon, {type='Texture'})

    btn.text= btn:CreateFontString(nil, 'BORDER', 'ChatFontNormal')
    btn.text:SetPoint('CENTER')
    WoWTools_ColorMixin:Setup(btn.text, {type='FontString'})

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        local isUIParent= Save().isUIParent
        if WoWToolsSave['ChatButton'].disabledTooltiip and not Save().isUIParent then--禁用提示
            return
        end
        GameTooltip:SetOwner(self, isUIParent and 'ANCHOR_LEFT' or "ANCHOR_BOTTOMRIGHT")
        
        local name= self.isCommand and Get_CommandName(self.value) or Get_EmojiName(self.value)
        name=WoWTools_TextMixin:CN(name)
        name= name:gsub('/', '')
        GameTooltip:SetText(name)
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function(self)
        On_Click(self)
    end)


    return btn
end















local function Init_Button()
    local w= ChatFrameMenuButton:GetWidth() or 32

    local isUIParent= Save().isUIParent
    local line= Save().line or 1
    local subNum= Save().subName or (LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN) and 1 or 3
    local scale= Save().scale or 1
    local alpha= Save().alpha or 0.5
    local fontScale= Save().fontScale or 1
    local btnW, btnH= Save().width or w, Save().height or w

    local _newTab= {}
    for _, value in pairs(Save().emoji) do
        table.insert(_newTab, {value=value})
    end
    for _, value in pairs(Save().command) do
        table.insert(_newTab, {value=value, isCommand=true})
    end

    for index, tab in pairs(_newTab) do

        local btn= Buttons[index]
        if not btn then
            btn= Create_Button(index, w)
        else
            btn:ClearAllPoints()
        end

        btn.value= tab.value
        btn.isCommand= tab.isCommand

        if isUIParent then
            if index>1 and select(2, math.modf((index-1)/line))==0 then
                btn:SetPoint('BOTTOM', Buttons[index-line], 'TOP')
            else
                btn:SetPoint('LEFT', Buttons[index-1] or Button, 'RIGHT')
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

        btn:SetParent(isUIParent and Button or ChatFrameMenuButton)
        btn:SetScale(scale)

        btn:SetSize(btnW, btnH)

        --[[local name = WoWTools_DataMixin.onlyChinese and List[value]
        --if not name then
            --if LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN or LOCALE_ruRU then
                name= Get_EmojiName(value)
                name= name:gsub('/', '')
            --end
            --name= name or value
        --end]]
        local name= tab.isCommand and Get_CommandName(tab.value) or Get_EmojiName(tab.value)
        name= WoWTools_TextMixin:CN(name)
        name= name:gsub('/', '')
        if subNum>0 then
            name= WoWTools_TextMixin:sub(name, subNum)
        end
        btn.text:SetText(name)
        btn.text:SetScale(fontScale)



        btn:SetShown(true)
    end


    local numButton= #_newTab
    if isUIParent then
        Button:SetFrameStrata(Save().strata or 'MEDIUM')
        Button:set_texture()

        if numButton>0 then
            Button.Background:SetPoint('TOP', Buttons[numButton], 0, 1)
            Button.Background:SetPoint('RIGHT', Buttons[numButton>=line and line or numButton], 1, 0)
            Button.Background:SetPoint('BOTTOMLEFT', Buttons[1], -1, -1)
            Button.Background:SetAlpha(Save().bgAlpha or 0)
        end
        Button.Background:SetShown(numButton>0)
    end
    Button:SetShown(isUIParent)

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
        Button:set_point()
        Init_Button()
    end)
end







local function Set_Emote_Menu(root, tab, name)
    local sub=root:CreateButton(name, function() return MenuResponse.Open end)

--勾选所有
    sub:CreateButton(
        (WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS)
        ..' #'..#tab,
    function()
        for _, value in ipairs(tab) do
            if not Get_Save(value) then
                table.insert(Save().emoji, value)
            end
        end
        Init_Button()
        return MenuResponse.Refresh
    end)

--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        for _, value in ipairs(tab) do
            local index= Get_Save(value)
            if index then
                table.remove(Save().emoji, index)
            end
        end
        Init_Button()
        return MenuResponse.Refresh
    end)
    sub:CreateDivider()

    for index, value in ipairs(tab) do
        local chaName, tokenIndex= Get_EmojiName(value)
        local sub2=sub:CreateCheckbox(
            WoWTools_TextMixin:CN(chaName):gsub('/', ''),
        function(data)
            return Get_Save(data.value)
        end, function(data)
            local tabIndex= Get_Save(data.value)
            if tabIndex then
                table.remove(Save().emoji, tabIndex)
            else
                table.insert(Save().emoji, data.value)
            end
            Init_Button()
        end, {value=value, tokenIndex= tokenIndex,chaName=chaName, index=index})

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddDoubleLine(desc.data.value, desc.data.tokenIndex)
            for i= 1, 12 do
                local va= _G["EMOTE"..desc.data.tokenIndex.."_CMD"..i]
                if va then
                    if va~=desc.data.chaName then
                        tooltip:AddDoubleLine(va, i)
                    end
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
            font:SetTextToFit(
                (chatShortcut and chatShortcut..' ' or '')..
                index
            )
            if select(2, math.modf(desc.data.index/2))==0 then
                font:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
                btn.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
            end
        end)
    end

    WoWTools_MenuMixin:SetScrollMode(sub)
end



local function Se_Command_Menu(root)
    
    local index=0
    local sub= root:CreateButton(WoWTools_DataMixin.onlyChinese and '命令' or COMMAND)

    for name in pairs(SLASH_COMMAND) do
        local chatName= Get_CommandName(name)
        if chatName then
            index= index+1
            local sub2=sub:CreateCheckbox(
                Get_CommandName(name),
            function(data)
                return Get_CommandSave(data.name)
            end, function(data)
                local index2= Get_CommandSave(data.name)
                if index2 then
                    table.remove(Save().command, index2)
                else
                    table.insert(Save().command, data.name)
                end
                Init_Button()
            end, {name=name, index=index})

            sub2:SetTooltip(function(tooltip, desc)
                tooltip:AddDoubleLine(desc.data.name, desc.data.index)
                for i= 2, 12 do
                    local va= _G["SLASH_"..desc.data.name..i]
                    if va then
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
                font:SetTextToFit(
                    desc.data.index
                )
                if select(2, math.modf(desc.data.index/2))==0 then
                    font:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
                    btn.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
                end
            end)
        end
    end
    WoWTools_MenuMixin:SetScrollMode(sub)
end














local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2
    local isRoot= self==Button

    if not isRoot then
        root= root:CreateButton(addName..' '..(#Save().emoji+#Save().command), function() return MenuResponse.Open end)
    end

--表情
    sub=Set_Emote_Menu(root, EmoteList, WoWTools_DataMixin.onlyChinese and '表情' or EMOTE_MESSAGE)
--谈话
    Set_Emote_Menu(root, TextEmoteSpeechList, WoWTools_DataMixin.onlyChinese and '谈话' or VOICEMACRO_LABEL)
--其它
    local _tab={}
    for i= 1, MAXEMOTEINDEX do
        local value= _G['EMOTE'..i..'_TOKEN']
        if value then
            table.insert(_tab, value)
        end
    end
    Set_Emote_Menu(root, _tab, WoWTools_DataMixin.onlyChinese and '全部' or ALL)

if WoWTools_DataMixin.Player.husandro then
    Se_Command_Menu(root)
end

--打开选项界面
    root:CreateDivider()
    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, addName)



--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        Save().emoji= {}
        Save().command= {}
        Init_Button()
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
            return Button and Button:GetFrameStrata()==data
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
        step=0.01,
        bit='%0.2f',
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
        minValue=8,
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
        minValue=8,
        maxValue=128,
        step=1,
    })

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        Init_Button()
    end, Rest_Button)

    _tab=nil
end

















local function Init()
    if Save().disabled then
        Button:Hide()
        return
    end

    Button.Background=Button:CreateTexture(nil, 'BACKGROUND')
    Button.Background:SetColorTexture(0,0,0)

    Button:SetClampedToScreen(true)

    function Button:set_texture()
        if (#Save().emoji+#Save().command)==0 or GameTooltip:IsOwned(self) then
            self:SetNormalAtlas('newplayerchat-chaticon-newcomer')
        else
            self:SetNormalTexture(0)
        end
    end
    function Button:set_point()
        local p= Save().point
        Button:ClearAllPoints()
        if p and p[1] then
            Button:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            Button:SetPoint('CENTER')
        end
    end

    Button:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:set_texture()
    end)
    Button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')

        GameTooltip:SetText(
            (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.left
            ..WoWTools_DataMixin.Icon.icon2
            ..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)..'(+Alt)'
        )
        GameTooltip:Show()
        self:set_texture()
    end)
    Button:SetMovable(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
        end
    end)
    Button:SetScript('OnDragStart', function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:SetScript('OnDragStop', function(self)
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

    Button:set_point()
    Init_Button()

    Init=function()
        if Save().disabled then
            Button:Hide()
        else
            Init_Button()
        end

    end
end
















Button= CreateFrame('Button', 'WoWToolsChatEmoteButton', UIParent, 'WoWToolsButtonTemplate')
Button:RegisterEvent('ADDON_LOADED')
Button:SetScript('OnEvent', function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWToolsSave['Plus_EmoteButton']= WoWToolsSave['Plus_EmoteButton'] or CopyTable(P_Save)

    addName= '|A:newplayerchat-chaticon-newcomer:0:0|a'..(WoWTools_DataMixin.onlyChinese and '表情' or EMOTE_MESSAGE)

    WoWTools_PanelMixin:Check_Button({
        checkName= addName,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            Init()
        end,
        buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        buttonFunc= function()
           Rest_Button()
        end,
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
