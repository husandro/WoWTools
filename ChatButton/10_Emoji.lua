local id, e = ...
local addName= 'Emoji'
local Save={
    showEnter=nil,
    On_Click_Show=true,
    Channels={},
    --Point={}
    scale=1,
    show_background=true,
    --show=true
    clickIndex=18,
    numButtonLine=10,
}

local EmojiButton
local Frame

local EmojiText, EmojiText_EN
local TextToTexture--过滤，事件


local Channels={
    "CHAT_MSG_CHANNEL", -- 公共频道
    "CHAT_MSG_SAY",  -- 说
    "CHAT_MSG_YELL",-- 大喊
    "CHAT_MSG_RAID",-- 团队
    "CHAT_MSG_RAID_LEADER", -- 团队领袖
    "CHAT_MSG_PARTY", -- 队伍
    "CHAT_MSG_PARTY_LEADER", -- 队伍领袖
    "CHAT_MSG_GUILD",-- 公会
    "CHAT_MSG_AFK", -- AFK玩家自动回复
    "CHAT_MSG_DND", -- 切勿打扰自动回复
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_COMMUNITIES_CHANNEL", --社区聊天内容        
}


--过滤，事件
local function WoWTools_Emoji_Filter(_, _, msg, ...)
    local str=msg
    for text, icon in pairs(TextToTexture) do
        str= str:gsub(text, icon)
    end
    if str ~=msg then
        return false, str, ...
    end
end


local function send(text, d)--发送信息
    text='{'..text..'}'
    if d =='LeftButton' then
        local ChatFrameEditBox = ChatEdit_ChooseBoxForSend() or DEFAULT_CHAT_FRAME.editBox
        ChatEdit_ActivateChat(ChatFrameEditBox)
        ChatFrameEditBox:Insert(text)

    elseif d=='RightButton' then
        WoWTools_ChatMixin:Chat(text, nil, nil)
    end
end

















local function Init_Buttons()--设置按钮
    Frame.Buttons={}

    for index=1, EmojiButton.numFile+8 do
        local btn= WoWTools_ButtonMixin:Cbtn(Frame, {size=30, setID=index})
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(self)
            e.tips:SetOwner(Frame.Buttons[#Frame.Buttons], "ANCHOR_TOP")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(self.text, '|T'..EmojiButton:get_texture(self:GetID())..':0|t')
            e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '插入' or 'Insert'), (e.onlyChinese and '发送' or SEND_LABEL)..e.Icon.right)
            e.tips:Show()
        end)
        btn:SetScript('OnClick', function(self, d)
            send(self.text, d)
            Save.clickIndex= self:GetID()
            EmojiButton:set_texture()
        end)

        btn:SetNormalTexture(EmojiButton:get_texture(index) or 0)
        btn.text= EmojiButton:get_emoji_text(index)
        table.insert(Frame.Buttons, btn)
    end

    function Frame:set_buttons_point()
        for index, btn in pairs(self.Buttons) do
            btn:ClearAllPoints()
            if index==1 then
                btn:SetPoint('BOTTOMLEFT', Frame, 'BOTTOMRIGHT')
            else
                btn:SetPoint('LEFT', self.Buttons[index-1], 'RIGHT')
            end
        end
        local num= Save.numButtonLine
        for index= num+1 , #self.Buttons, num do
            local btn= self.Buttons[index]
            btn:ClearAllPoints()
            btn:SetPoint('BOTTOM', self.Buttons[index-num], 'TOP')
        end
        self:set_background()
    end

    Frame.texture2= Frame:CreateTexture(nil, 'BACKGROUND')
    Frame.texture2:SetAtlas('UI-Frame-DialogBox-BackgroundTile')
    Frame.texture2:SetAlpha(0.5)

    function Frame:set_background()
        if Save.show_background then
            self.texture2:ClearAllPoints()
            self.texture2:SetPoint('BOTTOMLEFT', self.Buttons[1], -4, -4)
            self.texture2:SetPoint('BOTTOMRIGHT', self.Buttons[Save.numButtonLine], 4, -4)
            self.texture2:SetPoint('TOP', self.Buttons[#self.Buttons], 0, 4)
        end
        self.texture2:SetShown(Save.show_background)
    end

    Frame:set_buttons_point()
end











local function Init_EmojiFrame()
    Frame=WoWTools_ButtonMixin:Cbtn(UIParent, {size={10, 30}, name='WoWToolsChatButtonEmojiFrame'})--控制图标,显示,隐藏
    Frame:SetFrameStrata('HIGH')

    function Frame:set_point()
        self:ClearAllPoints()
        if Save.Point then
            self:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
        else
            self:SetPoint('BOTTOMRIGHT', EmojiButton, 'TOPLEFT', -120, 4)
        end
    end
    function Frame:set_scale()
        self:SetScale(Save.scale or 1)
    end

    Frame:SetShown(Save.show)
    Frame:RegisterForDrag("RightButton")
    Frame:SetMovable(true)
    Frame:SetClampedToScreen(true)


    Frame:SetScript("OnDragStart", function(self,d )
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    Frame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)


    function Frame:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine('ChatButton', addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scale or 1), 'Alt+'..e.Icon.mid)
        --e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:Show()
    end
    Frame:SetScript("OnMouseUp", ResetCursor)
    Frame:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    Frame:SetScript("OnLeave",function()
        ResetCursor()
        e.tips:Hide()
        EmojiButton:SetButtonState('NORMAL')
    end)
    Frame:SetScript('OnEnter', function(self)
        self:set_tooltip()
        EmojiButton:SetButtonState('PUSHED')
    end)
    Frame:SetScript('OnMouseWheel', function(self, d)--缩放
        Save.scale=WoWTools_FrameMixin:ScaleFrame(self, d, Save.scale, nil)
    end)


    --[[Frame:SetScript('OnClick',function(self, d)
        if d=='RightButton' and not IsAltKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Frame_Menu)
        end
    end)]]


    Frame:set_point()
    Frame:set_scale()

    Init_Buttons()--设置按钮
end




















local function Init_Menu(self, root)
    local sub, sub2

    root:CreateCheckbox(e.onlyChinese and '显示' or SHOW, function()
        return Frame:IsShown()
    end, function()
        self:set_frame_shown(not Frame:IsShown())
    end)
    root:CreateDivider()



--显示/隐藏
    --sub2=sub:CreateButton(e.onlyChinese and '显示/隐藏' or format('%s/%s', SHOW, HIDE), function() return MenuResponse.Open end)
--显示
    root:CreateTitle(e.onlyChinese and '显示' or SHOW)
    root:CreateCheckbox('|A:newplayertutorial-drag-cursor:0:0|a'..(e.onlyChinese and '移过图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ENTER_LFG,EMBLEM_SYMBOL)), function()
        return Save.showEnter
    end, function()
        Save.showEnter = not Save.showEnter and true or nil
    end)

    root:CreateCheckbox(e.Icon.left..(e.onlyChinese and '鼠标' or MOUSE_LABEL), function()
        return Save.On_Click_Show
    end, function()
        Save.On_Click_Show= not Save.On_Click_Show and true or false
        self:set_texture()
    end)

--隐藏
    root:CreateTitle(e.onlyChinese and '隐藏' or HIDE)
    root:CreateCheckbox('|A:Warfronts-BaseMapIcons-Horde-Barracks-Minimap:0:0|a'..(e.onlyChinese and '进入战斗' or ENTERING_COMBAT), function()
        return not Save.notHideCombat
    end, function()
        Save.notHideCombat = not Save.notHideCombat and true or nil
        self:set_event()
    end)

    root:CreateCheckbox('|A:transmog-nav-slot-feet:0:0|a'..(e.onlyChinese and '移动' or NPE_MOVE), function()
        return not Save.notHideMoving
    end, function()
        Save.notHideMoving = not Save.notHideMoving and true or nil
        self:set_event()
    end)


    root:CreateDivider()
    sub=root:CreateButton(e.onlyChinese and '选项' or OPTIONS, function()
        return MenuResponse.Open
    end)



    --缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save.scale
    end, function(value)
        Save.scale= value
        Frame:SetShown(true)
        Frame:set_scale()
    end)


--数量
    sub2=sub:CreateButton(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL, function() return MenuResponse.Open end)
    for index= 1, self.numAllFile, 1 do
        if select(2, math.modf(self.numAllFile/index))==0 then
            sub2:CreateCheckbox(
                (index==10 and '|cnGREEN_FONT_COLOR:' or '')
                ..index,
            function(data)
                return Save.numButtonLine==data
            end, function(data)
                Save.numButtonLine= data
                Frame:SetShown(true)
                Frame:set_buttons_point()
                return MenuResponse.Refresh
            end, index)
        end
    end
    sub2:CreateDivider()
    sub2:CreateTitle(Save.numButtonLine..'/'..self.numAllFile)
    sub2:SetGridMode(MenuConstants.VerticalGridDirection, 2)

--聊天频道
    sub2=sub:CreateButton((e.onlyChinese and '聊天频道' or CHAT_CHANNELS)..' '..self.numFilter, function()
        return MenuResponse.Refresh
    end)

    for index, channel in pairs(Channels) do
        sub2:CreateCheckbox('|cff9e9e9e'..index..'|r '..(e.cn(_G[channel]) or channel), function(data)
            return not Save.Channels[data]
        end, function(data)
            Save.Channels[data]= not Save.Channels[data] and true or nil
            self:set_filter_event()
        end, channel)
    end

--背景
    sub:CreateCheckbox(e.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND, function()
        return Save.show_background
    end, function()
        Save.show_background= not Save.show_background and true or nil
        Frame:SetShown(true)
        Frame:set_background()
    end)

    sub2:CreateDivider()
    sub2:CreateButton(e.onlyChinese and '全选' or ALL, function()
        Save.Channels={}
        self:set_filter_event()
        return MenuResponse.Refresh
    end)
    sub2:CreateButton(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, function()
        for _, channel in pairs(Channels) do
            Save.Channels[channel]=true
        end
        self:set_filter_event()
        return MenuResponse.Refresh
    end)

    sub:CreateDivider()
    sub:CreateButton((Save.Point and '' or '|cff9e9e9e')..(e.onlyChinese and '重置位置' or RESET_POSITION), function()
        Save.Point=nil
        Frame:set_point()
        return MenuResponse.Refresh
    end)
end

















--初始
--1US (includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
local function Init()
    EmojiText_EN= {'Angel','Angry','Biglaugh','Clap','Cool','Cry','Cutie','Despise','Dreamsmile','Embarrass','Evil','Excited','Faint','Fight','Flu','Freeze','Frown','Greet','Grimace','Growl','Happy','Heart','Horror','Ill','Innocent','Kongfu','Love','Mail','Makeup','Meditate','Miserable','Okay','Pretty','Puke','Shake','Shout','Shuuuu','Shy','Sleep','Smile','Suprise','Surrender','Sweat','Tear','Tears','Think','Titter','Ugly','Victory','Hero','Wronged','Mario',}

    if e.Player.region==5 then
        EmojiText= {'天使','生气','大笑','鼓掌','酷','哭','可爱','鄙视','美梦','尴尬','邪恶','兴奋','晕','打架','流感','呆','皱眉','致敬','鬼脸','龇牙','开心','心','恐惧','生病','无辜','功夫','花痴','邮件','化妆','沉思','可怜','好','漂亮','吐','握手','喊','闭嘴','害羞','睡觉','微笑','吃惊','失败','流汗','流泪','悲剧','想','偷笑','猥琐','胜利','雷锋','委屈','马里奥'}

    elseif e.Player.region==4 then
        EmojiText= {'天使','生氣','大笑','鼓掌','酷','哭','可愛','鄙視','美夢','尷尬','邪惡','興奮','暈','打架','流感','呆','皺眉','致敬','鬼臉','齜牙','開心','心','恐懼','生病','無辜','功夫','花痴','郵件','化妝','沉思','可憐','好','漂亮','吐','握手','喊','閉嘴','害羞','睡覺','微笑','吃驚','失敗','流汗','流淚','悲劇','想','偷笑','猥瑣','勝利','英雄','委屈','馬里奧'}
    elseif e.Player.region==2 then
        EmojiText= {'천사','화난','웃음','박수','시원함','울음','귀엽다','경멸','꿈','당혹 스러움','악','흥분','헤일로','싸움','독감','머무르기','찡그림','공물','grimface','눈에띄는이빨','행복','심장','두려움','나쁜','순진한','쿵푸','관용구','메일','메이크업','명상','나쁨','좋은','아름다운','침','악수','외침','닥치기','수줍음','수면','웃음','놀라움','실패','땀','눈물','비극','생각하기','shirking','걱정','victory','hero','wronged','Mario'}
    else
        EmojiText= EmojiText_EN
    end

    EmojiButton.numFile= #EmojiText
    EmojiButton.numAllFile= EmojiButton.numFile+8

    TextToTexture={}--过滤，事件
    for index, text in pairs(EmojiText) do
        TextToTexture['{'..text..'}']= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\'..EmojiText_EN[index]..':0|t'
    end


    function EmojiButton:get_emoji_text(index)
        index= index or Save.clickIndex or 18
        if index<=self.numFile then
            return EmojiText[index]
        else
            return 'rt'..(index-self.numFile)
        end
    end
    function EmojiButton:get_texture(index)
        index= index or Save.clickIndex or 18
        if index<=self.numFile then
            return 'Interface\\Addons\\WoWTools\\Sesource\\Emojis\\'..EmojiText_EN[index]
        else
            return 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..(index-self.numFile)
        end
    end

    function EmojiButton:set_texture()
        if Save.On_Click_Show then
            self.texture:SetTexture(self:get_texture(18))
        else
            self.texture:SetTexture(self:get_texture())
        end
    end


    function EmojiButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if Save.On_Click_Show then
            e.tips:AddDoubleLine(e.GetShowHide(not Frame:IsShown()), e.Icon.left)
        else
            e.tips:AddDoubleLine(
                format('|T%s:0|t%s', self:get_texture() or '' , self:get_emoji_text() or ''),
                (self.chatFrameEditBox and (e.onlyChinese and '插入' or 'Insert') or (e.onlyChinese and '发送' or SEND_LABEL))..e.Icon.left
            )
        end
        if self.numFilter==0 then
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '聊天频道' or CHAT_CHANNELS, self.numFilter)
        end
        e.tips:Show()
    end


    function EmojiButton:set_OnLeave()
        self:set_frame_state(false)
        self.chatFrameEditBox=nil
    end

    function EmojiButton:set_OnEnter()
        if Save.showEnter then
            self:set_frame_shown(true)
        end
        self:set_frame_state(true)
        self.chatFrameEditBox= ChatEdit_GetActiveWindow() and true or false
    end



    function EmojiButton:set_filter_event()
        local find=0
        for _, channel in pairs(Channels) do
            if not Save.Channels[channel] then
                ChatFrame_AddMessageEventFilter(channel, WoWTools_Emoji_Filter)
                find= find+1
            else
                ChatFrame_RemoveMessageEventFilter(channel, WoWTools_Emoji_Filter)
            end
        end
        self.texture:SetDesaturated(find==0)
        self.numFilter= find
    end

--Frame, 设置, State
    function EmojiButton:set_frame_state(isEenter)
        if Frame:IsShown() and isEenter then
            Frame:SetButtonState('PUSHED')
        else
            Frame:SetButtonState('NORMAL')
        end
    end

--Frame, 设置, 隐藏/显示
    function EmojiButton:set_frame_shown(show)
        Frame:SetShown(show)
    end

--Frame, 设置, 事件
    function EmojiButton:set_event()
        if Save.notHideCombat then
            self:UnregisterEvent('PLAYER_REGEN_DISABLED')
        else
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
        if Save.notHideMoving then
            self:UnregisterEvent('PLAYER_STARTED_MOVING')
        else
            self:RegisterEvent('PLAYER_STARTED_MOVING')
        end
    end

    EmojiButton:SetScript('OnEvent', function(self)
        self:set_frame_shown(false)
    end)

    Init_EmojiFrame()

    EmojiButton:set_texture()
    EmojiButton:set_event()
    EmojiButton:set_filter_event()

    EmojiButton:SetupMenu(Init_Menu)

    function EmojiButton:set_OnMouseDown()
        if Save.On_Click_Show then
            self:set_frame_shown(not Frame:IsShown())
        else
            send(self:get_emoji_text(),  self.chatFrameEditBox and 'LeftButton' or 'RightButton')
        end
    end
end





local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then
            Save= WoWToolsSave['ChatButton_Emoji'] or Save
            addName= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\Embarrass:0|tEmoji'
            EmojiButton= WoWTools_ChatButtonMixin:CreateButton('Emoji', addName)

            if EmojiButton then--禁用Chat Button
                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Emoji']=Save
        end
    end
end)