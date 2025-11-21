local P_Save= {
    emoji={'DANCE'}
}
local function Save()
    return WoWToolsSave['Plus_EmoteButton']
end

local Button
local Buttons={}
local addName


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
}











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
    return _G["EMOTE"..i.."_CMD1"] or value
end
local function Get_Save(value)
    for index, name in pairs(Save().emoji) do
        if name==value then
            return index
        end
    end
    return false
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
        local name= WoWTools_TextMixin:CN(Get_EmojiName(self.value))
        name= name:gsub('/', '')
        GameTooltip:SetText(name)
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function(self)
        local emote= self.value
        if (emote == EMOTE454_TOKEN) or (emote == EMOTE455_TOKEN) then
            local faction = UnitFactionGroup("player", true)
            if faction == "Alliance" then
                emote = EMOTE454_TOKEN
            elseif faction == "Horde" then
                emote = EMOTE455_TOKEN
            end
        end
        DoEmote(emote)
    end)


    return btn
end















local function Init_Button()
    local index= 0
    local w= ChatFrameMenuButton:GetWidth() or 32

    local isUIParent= Save().isUIParent
    local line= Save().line or 1

    local scale= Save().scale or 1
    local alpha= Save().alpha or 0.5
    local fontScale= Save().fontScale or 1

    for _, value in pairs(Save().emoji) do
        index= index+1

        local btn= Buttons[index]
        if not btn then
            btn= Create_Button(index, w)
        else
            btn:ClearAllPoints()
        end

        btn.value= value

        local name = WoWTools_DataMixin.onlyChinese and List[value]
        if not name then
            if LOCALE_koKR or LOCALE_zhTW or LOCALE_zhCN then
                name= Get_EmojiName(value)
                name= name:gsub('/', '')
            end
            name= name or value
        end

        name= WoWTools_TextMixin:sub(name, 1, 3)

        btn.text:SetText(name)
        btn.text:SetScale(fontScale)

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

        if isUIParent then
            if index>1 and select(2, math.modf((index-1)/line))==0 then
                btn:SetPoint('BOTTOM', Buttons[index-line], 'TOP')
            else
                btn:SetPoint('LEFT', Buttons[index-1] or Button, 'RIGHT')
            end
        else
            btn:SetPoint('BOTTOM', Buttons[index-1] or ChatFrameMenuButton, 'TOP')
        end

        btn:SetShown(true)
    end


    if isUIParent then
        Button:SetFrameStrata(Save().strata or 'MEDIUM')
        Button:set_texture()

        if index>0 then
            Button.Background:SetPoint('TOP', Buttons[index], 0, 1)
            Button.Background:SetPoint('RIGHT', Buttons[index>=line and line or index], 1, 0)
            Button.Background:SetPoint('BOTTOMLEFT', Buttons[1], -1, -1)
            Button.Background:SetAlpha(Save().bgAlpha or 0)
        end
    end
    Button:SetShown(isUIParent)

    for i= index+1, #Buttons do
        local btn= Buttons[i]
        btn:SetShown(false)
    end
end













local function Rest_Button()
    StaticPopup_Show('WoWTools_RestData',
        addName..'|n'
        ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        nil,
    function()
        WoWToolsSave['Plus_EmoteButton']= P_Save
        Button:set_point()
        Init_Button()
    end)
end













local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local sub, sub2
    local isRoot= self==Button

    if not isRoot then
        root= root:CreateButton(addName..' '..#Save().emoji, function() return MenuResponse.Open end)
    end

--表情
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '表情' or EMOTE_MESSAGE,
    function()
        return MenuResponse.Open
    end)
    for _, value in ipairs(EmoteList) do
        sub2=sub:CreateCheckbox(
            Get_EmojiName(value),
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
        end, {value=value})
        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(WoWTools_DataMixin.Icon.icon2..desc.data.value)
        end)
    end

--谈话
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '谈话' or VOICEMACRO_LABEL,
    function()
        return MenuResponse.Open
    end)
    for _, value in ipairs(TextEmoteSpeechList) do
        sub2=sub:CreateCheckbox(
            Get_EmojiName(value),
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
        end, {value=value})
        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(WoWTools_DataMixin.Icon.icon2..desc.data.value)
        end)
    end



--打开选项界面
    root:CreateDivider()
    sub= WoWTools_ChatMixin:Open_SettingsPanel(root, WoWTools_HyperLink.addName)


--勾选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or EVENTTRACE_BUTTON_ENABLE_FILTERS,
    function()
        Save().emoji= EmoteList
        for _, value in ipairs(TextEmoteSpeechList) do
            table.insert(Save().emoji, value)
        end
        Init_Button()
        return MenuResponse.Refresh
    end)
--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        Save().voice= {}
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
        return MenuResponse.Close
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


--背景, 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().alpha or 0.5
    end, function(value)--SetValue
        Save().alpha= value
        Init_Button()
    end, nil, true)

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

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().scale or 1
    end, function(value)
        Save().scale= value
        Init_Button()
    end, Rest_Button)
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
        if #Save().emoji==0 or GameTooltip:IsOwned(self) then
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
            ..' '..WoWTools_DataMixin.Icon.icon2
            ..' |cffffffffAlt+|r'..WoWTools_DataMixin.Icon.right..(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)
        )
        GameTooltip:Show()
        self:set_texture()
    end)
    Button:SetMovable(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            if IsAltKeyDown() then
                SetCursor('UI_MOVE_CURSOR')
            end
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

    WoWToolsSave['Plus_EmoteButton']= WoWToolsSave['Plus_EmoteButton'] or P_Save

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
