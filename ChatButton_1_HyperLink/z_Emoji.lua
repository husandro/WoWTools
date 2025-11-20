local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end
local Button


--[[
EmoteList = {
	"WAVE",
	"BOW",
	"DANCE",
	"APPLAUD",
	"BEG",
	"CHICKEN",
	"CRY",
	"EAT",
	"FLEX",
	"KISS",
	"LAUGH",
	"POINT",
	"ROAR",
	"RUDE",
	"SALUTE",
	"SHY",
	"TALK",
	"STAND",
	"SIT",
	"SLEEP",
	"KNEEL",
	"LEAN",
}
]]


local function Init_Frame()
    if not Save().emojiUIParent then
        return
    end

    Button=CreateFrame('DropdownButton', 'WoWToolsMoveEmojiButton', UIParent, 'WoWToolsMenuTemplate')
    Button:RegisterForMouse('LeftButtonDown', "LeftButtonUp")
    Button:SetNormalTexture(0)
    Button:SetMovable(true)
    Button:RegisterForDrag("RightButton")
    Button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            --self:SetMovable
            -- frame:StopMovingOrSizing()
            --StartMoving()
        end
    end)
    --Button:SetNormalTexture(0)

    function Button:settings()
        local p= Save().emojiPoint
        self:ClearAllPoints()
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            self:SetPoint('BOTTOM', WoWTools_ChatMixin:GetButtonForName('HyperLink'), 'TOP', 0, 10)
        end
        self:SetShown(Save().emojiUIParent)
    end

    Button:settings()
    Button:SetupMenu(function(self, root)
        WoWTools_HyperLink:EmojiButton_Menu(self, root)
    end)

    Init_Frame=function()
        Button:settings()
    end
end







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





local Buttons={}






local function Create_Button(index, w, h)
    Buttons[index]= CreateFrame('Button', 'WoWToolsEmojiButton'..index, ChatFrameMenuButton, 'WoWToolsButtonTemplate')

    local btn=Buttons[index]

    btn:SetSize(w,h)
    btn:SetNormalAtlas('chatframe-button-up')
    btn:SetPushedAtlas('chatframe-button-down')
    btn:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight')
    WoWTools_ColorMixin:Setup(btn:GetNormalTexture(), {type='Texture'})
    WoWTools_ColorMixin:Setup(btn:GetPushedTexture(), {type='Texture'})

    btn.lable= btn:CreateFontString(nil, 'BORDER', 'ChatFontNormal')
    btn.lable:SetPoint('CENTER')
    WoWTools_ColorMixin:Setup(btn.lable, {type='FontString'})

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', function(self)
        if WoWToolsSave['ChatButton'].disabledTooltiip then--禁用提示
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetText(Get_EmojiName(self.value))
        GameTooltip:Show()
    end)
    btn:SetScript('OnClick', function(self)
        DoEmote(self.value)
    end)


    return btn
end











local function Set_Button(self, isUIParent, scale, alpha)
    
end








local function Init_Button()

    Init_Frame()

    local index=1

    local w,h= ChatFrameMenuButton:GetSize()
    local isUIParent= Save().emojiUIParent
    local scale= Save().emojiScale or 1
    local alpha= Save().emojiAlpha or 0.5

    for _, value in ipairs(Save().emoji) do
        local btn= Buttons[index]
        if not btn then
            btn= Create_Button(index, w, h)
        else
            btn:ClearAllPoints()
        end

        btn.value= value

        local name
        if WoWTools_DataMixin.onlyChinese then
            name = Get_EmojiName(value)
            name= WoWTools_TextMixin:CN(name)
            name= name:gsub('/', '')
        else
            name= value
        end
        btn.lable:SetText(WoWTools_TextMixin:sub(name, 1, 2))

        local x= isUIParent and 0 or 2.5
        local icon= btn:GetNormalTexture()
        icon:ClearAllPoints()
        icon:SetPoint('TOPLEFT', x, -x)
        icon:SetPoint('BOTTOMRIGHT', -x, x)
        icon= btn:GetPushedTexture()
        icon:ClearAllPoints()
        icon:SetPoint('TOPLEFT', x, -x)
        icon:SetPoint('BOTTOMRIGHT', -x, x)

        btn:SetParent(isUIParent and UIParent or ChatFrameMenuButton)

        btn:SetScale(scale)

        btn:GetNormalTexture():SetAlpha(alpha)

        if isUIParent then
            btn:SetPoint('LEFT', Button, 'RIGHT', (index-1)*w, 0)
        else
            btn:SetPoint('BOTTOM', ChatFrameMenuButton, 'TOP', 0, (index-1)*w)
        end

        btn:SetShown(true)

        index= index+1
    end

    for i= index, #Buttons do
        local btn= Buttons[i]
        btn:SetShown(false)
    end
end








local function Init_Menu(self, root)
    local sub
    local isRoot= self==Button

    if not isRoot then
        root= root:CreateButton(
            '|A:newplayerchat-chaticon-newcomer:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '表情' or EMOTE_MESSAGE),
        function()
            return MenuResponse.Open
        end)
    end

    for _, value in ipairs(EmoteList) do
        sub=root:CreateCheckbox(
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
        sub:SetTooltip(function(tooltip, desc)
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
        Init_Button()
        return MenuResponse.Refresh
    end)
--撤选所有
    sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or EVENTTRACE_BUTTON_DISABLE_FILTERS,
     function()
        Save().emoji= {}
        Init_Button()
        return MenuResponse.Refresh
    end)
    sub:CreateDivider()

--自定义位置
    sub:CreateCheckbox(
        'UIParent',
    function()
        return Save().emojiUIParent
    end, function()
        Save().emojiUIParent= not Save().emojiUIParent and true or nil
        Init_Button()
    end)


--背景, 透明度
    WoWTools_MenuMixin:BgAplha(sub,
    function()--GetValue
        return Save().emojiAlpha or 0.5
    end, function(value)--SetValue
        Save().emojiAlpha= value
        Init_Button()
    end, nil, true)

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub, function()
        return Save().emojiScale or 1
    end, function(value)
        Save().emojiScale= value
        Init_Button()
    end, function()
        Save().emoji={'DANCE'}
        Save().emojiScale= nil
        Save().emojiAlpha= nil
        Init_Button()
    end)
end








local function Init()

    Save().emoji= Save().emoji or {}

    Menu.ModifyMenu("MENU_CHAT_SHORTCUTS", function(self, root)
        Init_Menu(self, root, false)
    end)

    Init_Button()

    Init=function()end
end









function WoWTools_HyperLink:Init_EmojiButton()
    Init()
end
function WoWTools_HyperLink:EmojiButton_Menu(...)
    Init_Menu(...)
end