--[[
这个功能，灵感来源：ChatCopyPaste 插件
NUM_CHAT_WINDOWS
Constants.ChatFrameConstants.MaxChatWindows

function FCF_GetNextOpenChatWindowIndex()
	for i = C_ChatInfo.GetNumReservedChatWindows() + 1, Constants.ChatFrameConstants.MaxChatWindows do
		if ( not FCF_IsChatWindowIndexActive(i) ) then
			return i;
		end
	end

	return nil;
end
]]
local function Save()
    return WoWToolsSave['Plus_ChatCopy'] or {}
end

local Init_Button
local addName

local JunkTabs={}
for _, name in pairs({--. ( ) + - * ? [ ^
	D_DAYS,--"%d|4天:天;";
	D_HOURS,--"%d|4小时:小时;";
	D_MINUTES,--"%d|4分钟:分钟;";
	D_SECONDS,"%d|4秒:秒;";
}) do
	JunkTabs[name:gsub('%%d', '%(%%d%+%)')]= {name:match('|4(.-):(.-);')}
end



local function Init_AllButton()
	for index =1, Constants.ChatFrameConstants.MaxChatWindows do
		if FCF_GetChatFrameByID(index) then
			Init_Button(index)
		end
	end
end





local function createBnetString(id, msg)
	id = tonumber(id)
	local totalBNFriends = BNGetNumFriends()
	for friendIndex = 1, totalBNFriends do
		local presenceID, tag
		local data = C_BattleNet.GetFriendAccountInfo(friendIndex)
		if (data) then
			presenceID = data.bnetAccountID
			tag = data.battleTag
		end
		if (tag and id == presenceID) then
			tag = strsplit("#", tag)
			return gsub(msg, "|HBNplayer:.*:.*:.*:BN_WHISPER:.*:", "[" .. tag .. "]:")
		end
	end
	return msg
end


local function removeChatJunk(currentMsg)
	if currentMsg=='' then
		return currentMsg
	end

	for text, tab in pairs(JunkTabs) do
		local chatNumber = string.match(currentMsg, text)
		local number= chatNumber and tonumber(chatNumber)
		if number then
			if number == 0 then
				currentMsg = string.gsub(currentMsg, text, chatNumber..tab[1])
			elseif (number > 1) then
				currentMsg = string.gsub(currentMsg, text, chatNumber..tab[2])
			end
		end
	end

	currentMsg = string.gsub(currentMsg, "|T.-|t", "")
	currentMsg = string.gsub(currentMsg, "|A.-|a", "")

	return currentMsg
end














--frame.fontStringPool:EnumerateActive()

local function Get_Text(index)
	index= index or 1

	local frame= FCF_GetChatFrameByID(index)
	if not frame then
		return
	end

	local numMessage= frame:GetNumMessages() or 0

	if numMessage==0 then
		if WoWTools_DataMixin.Player.husandro then
			print('GetNumMessages', frame:GetName(), index , numMessage)
		end
	end

	local tab={}

	local isSetText= Save().isSetText--不处理，文本

	for i = 1, numMessage do
		local currentMsg, r, g, b, chatTypeID = frame:GetMessageInfo(i)

		if not currentMsg and WoWTools_DataMixin.Player.husandro then
			print('没有发现 currentMsg')
		end

		currentMsg= currentMsg or ''

		if isSetText then--处理，文本

			local colorCode = false
			currentMsg = removeChatJunk(currentMsg)

			if (string.match(currentMsg, "k:(%d+):(%d+):BN_WHISPER:")) then
				local presenceID = string.match(currentMsg, "k:(%d+):%d+:BN_WHISPER:")
				currentMsg = createBnetString(presenceID, currentMsg)
			end

			if (r and g and b and chatTypeID) then
				colorCode = RGBToColorCode(r, g, b)
				currentMsg = string.gsub(currentMsg, "|r", "|r" .. colorCode)
				currentMsg = colorCode .. currentMsg
			end

			if (string.find(currentMsg, GUILD_MOTD_LABEL2)) then--GUILD_MOTD_LABEL2 公会今日信息
				currentMsg = RGBTableToColorCode(ChatTypeInfo.GUILD) .. currentMsg
			end
		end

		currentMsg= tostring(currentMsg)

		table.insert(tab, currentMsg)
	end


	WoWTools_TextMixin:ShowText(
		tab,
		_G['ChatFrame'..index..'Tab']:GetText()
	)
end













local function Print_Text(isLogging, isChat)
	local t
	if isChat then
		if isLogging then
			t= WoWTools_DataMixin.onlyChinese and '聊天记录保存在Logs/WoWChatLog.txt中' or CHATLOGENABLED
		else
			t=WoWTools_DataMixin.onlyChinese and '聊天记录已被禁止。' or CHATLOGDISABLED
		end
	else
		if isLogging then
			t= WoWTools_DataMixin.onlyChinese and '战斗记录保存在Logs/WoWCombatLog中' or COMBATLOGENABLED
		else
			t= WoWTools_DataMixin.onlyChinese and '战斗记录已被禁止。' or COMBATLOGDISABLED
		end
	end
	local info = ChatTypeInfo["SYSTEM"]
	DEFAULT_CHAT_FRAME:AddMessage('|A:poi-workorders:0:0|a'..WoWTools_DataMixin.Icon.icon2..t, info.r, info.g, info.b, info.id)
end















local function Init_Menu(frame, root)
    if not frame or not frame:IsMouseOver() then
        return
    end

	local index= frame:GetName():match('%d+') or '1'

	local self= _G['ChatFrame'..index]
	if not self or not self.GetNumMessages then
		return
	end

	local sub, sub2
	local num= self:GetNumMessages()

	sub=root:CreateButton(
		'|A:poi-workorders:0:0|a'
		..(num==0 and '|cff606060' or '')
		..(WoWTools_DataMixin.onlyChinese and '复制聊天' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_COPY_EVENT, CHAT)),
	function()
		Get_Text(index)
		return MenuResponse.Open
	end, {rightText=num})
	sub:SetTooltip(function(tooltip)
		local tab=  _G['ChatFrame'..index..'Tab']
		if tab then
			tooltip:AddLine(tab:GetText())
		end
		tooltip:AddLine(
			WoWTools_DataMixin.Icon.icon2
			..(WoWTools_DataMixin.onlyChinese and '聊天' or CHAT)
			..WoWTools_DataMixin.Icon.left
			..'|cnGREEN_FONT_COLOR:#'
			..self:GetNumMessages()
		)
	end)
	WoWTools_MenuMixin:SetRightText(sub)

--选项
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '显示按钮' or SHOW_QUICK_BUTTON,
	function()
		return Save().isShowButton
	end, function()
		Save().isShowButton= not Save().isShowButton and true or false
		Init_AllButton()
	end)

--处理文本
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '处理文本' or 'Processing text',
	function()
			return Save().isSetText
	end, function()
		Save().isSetText= not Save().isSetText and true or nil
	end)

--聊天记录
	sub:CreateDivider()
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '/聊天记录' or SLASH_CHATLOG2,
	function()
		return C_ChatInfo.IsLoggingChat()
	end, function()
		if C_ChatInfo.IsLoggingChat() then
			LoggingChat(false)
			Save().IsLoggingChat= false
		else
			LoggingChat(true)
			Save().IsLoggingChat= true
		end
		Print_Text(C_ChatInfo.IsLoggingChat(), true)
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '聊天记录保存在Logs/WoWChatLog.txt中' or CHATLOGENABLED)
	end)

--战斗日志
	sub2=sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '/战斗日志' or SLASH_COMBATLOG1,
	function()
		return C_ChatInfo.IsLoggingCombat()
	end, function()
		if C_ChatInfo.IsLoggingCombat() then
			LoggingCombat(false)
			Save().IsLoggingCombat= false
		else
			LoggingCombat(true)
			Save().IsLoggingCombat= true
		end
		Print_Text(C_ChatInfo.IsLoggingCombat(), false)
	end)
	sub2:SetTooltip(function(tooltip)
		tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '战斗记录保存在Logs/WoWCombatLog中' or COMBATLOGENABLED)
	end)

--打开，选项面板
	sub:CreateDivider()
	WoWTools_ChatMixin:Open_SettingsPanel(sub, addName)
end












function Init_Button(index)
	local enabled= Save().isShowButton and true or false
	local frame= FCF_GetChatFrameByID(index)

	if not frame or not enabled or not frame.GetNumMessages or frame.CopyChatButton then
		if frame and frame.CopyChatButton then
			if frame.ResizeButton then
				frame.ScrollToBottomButton:SetPoint('BOTTOMRIGHT', frame.ResizeButton, 'TOPRIGHT', -2, enabled and 15 or -1)-- -2,-2
			end
			frame.CopyChatButton:SetShown(enabled)
		end
		return
	end

	frame.CopyChatButton= CreateFrame('Button', 'WoWToolsChatCopyButton'..index, frame, nil, index)

	frame.CopyChatButton:SetNormalAtlas('poi-workorders')
    frame.CopyChatButton:SetPushedAtlas('PetList-ButtonSelect')
    frame.CopyChatButton:SetHighlightAtlas('PetList-ButtonHighlight')

	frame.CopyChatButton:SetSize(17, 15)
	WoWTools_TextureMixin:SetButton(frame.CopyChatButton, {alpha=1})
	frame.CopyChatButton:SetAlpha(frame.ScrollBar:GetAlpha() or 0.65)

	if frame.ResizeButton then
		frame.ScrollToBottomButton:SetPoint('BOTTOMRIGHT', frame.ResizeButton, 'TOPRIGHT', -2, 15)
	end
	frame.CopyChatButton:SetPoint('TOP', frame.ScrollToBottomButton, 'BOTTOM', 0, -2)

	frame.CopyChatButton:SetScript('OnLeave', function()
		GameTooltip:Hide()
		WoWTools_ChatMixin:GetButtonForName('HyperLink'):SetButtonState('NORMAL')
	end)

	frame.CopyChatButton:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()

		local tab=  _G['ChatFrame'..index..'Tab']
		if tab then
			GameTooltip:AddLine(tab:GetText()..' |cff626262'..index)
		end

		local num = self:GetParent():GetNumMessages() or 0
		local col= num==0 and '|cff606060'
		GameTooltip:AddLine(
			(col or '|cffffffff')
			..(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
			..(col or'|cnGREEN_FONT_COLOR:#')
			..num
			..'|r|r'
			..WoWTools_DataMixin.Icon.left
			..WoWTools_DataMixin.Icon.right
			..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
		)
		GameTooltip:Show()
		WoWTools_ChatMixin:GetButtonForName('HyperLink'):SetButtonState('PUSHED')
		WoWTools_DataMixin:Call(FCF_FadeInScrollbar, self:GetParent())
	end)

	frame.CopyChatButton:SetScript('OnMouseDown', function(self, d)
		if d=='LeftButton' then
			Get_Text(self:GetID())
		else
			MenuUtil.CreateContextMenu(self, Init_Menu)
		end
	end)
end














local function Init()
	local isLoggingChat= C_ChatInfo.IsLoggingChat()
	local chat= Save().IsLoggingChat
	if chat~=nil and chat~=isLoggingChat then
		LoggingChat(chat)
		Print_Text(C_ChatInfo.IsLoggingChat(), true)
	end

	local isLoggingCombat= C_ChatInfo.IsLoggingCombat()
	local combat = Save().IsLoggingCombat
	if combat~=nil and isLoggingCombat ~=combat then
		LoggingCombat(combat)
		Print_Text(C_ChatInfo.IsLoggingCombat(), false)
	end

	if Save().isShowButton then
		Init_AllButton()
	end

	WoWTools_DataMixin:Hook(ChatFrameMixin, 'OnLoad', function(frame)
		if Save().isShowButton and frame then
			local index = frame:GetName():match("(%d+)")
			if index then
				Init_Button(tonumber(index))
			end
		end
	end)

	WoWTools_DataMixin:Hook('FCF_OpenNewWindow', function(name)
		if Save().isShowButton and name then
			local index = name:match("(%d+)")
			if index then
				Init_Button(tonumber(index))
			end
		end
	end)

	WoWTools_DataMixin:Hook('FCF_FadeInScrollbar', function(chatFrame)
		local btn= chatFrame.CopyChatButton
		if btn and btn:IsShown() then
			UIFrameFadeIn(btn, CHAT_FRAME_FADE_TIME, btn:GetAlpha(), 0.65)
		end
	end)

	WoWTools_DataMixin:Hook('FCF_FadeOutScrollbar', function(chatFrame)
		local btn= chatFrame.CopyChatButton
		if btn and btn:IsShown() then
			UIFrameFadeOut(btn, CHAT_FRAME_FADE_OUT_TIME, btn:GetAlpha(), 0)
		end
	end)




	Menu.ModifyMenu("MENU_FCF_TAB", Init_Menu)


	Init=function()end
end













local frame= CreateFrame('Frame')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, arg1)
	--if event=='ADDON_LOADED' then
	if arg1~= 'WoWTools' then
		return
	end

	WoWToolsSave['Plus_ChatCopy']= WoWToolsSave['Plus_ChatCopy'] or {isShowButton=true}
	addName= '|A:poi-workorders:0:0|a'..(WoWTools_DataMixin.onlyChinese and '复制聊天' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_COPY_EVENT, CHAT))

	WoWTools_PanelMixin:OnlyCheck({
		name= addName,
		GetValue= function() return not Save().disabled end,
		SetValue= function()
			Save().disabled= not Save().disabled and true or nil
			Init()
		end,
		layout= WoWTools_ChatMixin.Layout,
		category= WoWTools_ChatMixin.Category,
		tooltip= WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
	})

	if Save().disabled then
		self:SetScript('OnEvent', nil)
	else
		Init()
		self:SetScript('OnEvent', nil)
	end
	self:UnregisterEvent(event)
end)











