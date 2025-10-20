--这个功能，灵感来源：ChatCopyPaste 插件
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end

local Init_Button

local JunkTabs={}
for _, name in pairs({--. ( ) + - * ? [ ^
	D_DAYS,--"%d|4天:天;";
	D_HOURS,--"%d|4小时:小时;";
	D_MINUTES,--"%d|4分钟:分钟;";
	D_SECONDS,"%d|4秒:秒;";
}) do
	JunkTabs[name:gsub('%%d', '%(%%d%+%)')]= {name:match('|4(.-):(.-);')}
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

	return currentMsg
end















local function Get_Text(index)
	index= index or 1

	local frame=_G["ChatFrame" .. index]
	local numMessage= frame and frame:GetNumMessages() or 0

	if numMessage==0 then
		return
	end

	local tab={}
	local copyChatSetText= Save().copyChatSetText--不处理，文本

	for i = 1, numMessage do
		local currentMsg, r, g, b, chatTypeID = frame:GetMessageInfo(i)

		currentMsg= currentMsg or ''

		if copyChatSetText then--处理，文本

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

		table.insert(tab, currentMsg)
	end


	WoWTools_TextMixin:ShowText(
		tab,
		_G['ChatFrame'..index..'Tab']:GetText()
	)
end













local function Init_Menu(frame, root)
	local index= frame:GetName():match('%d+') or '1'

	local self= _G['ChatFrame'..index]
	if not self then
		return
	end
	local sub

	sub=root:CreateButton(
		(self:GetNumMessages()==0 and '|cff606060' or '')
		..'|A:poi-workorders:0:0|a'
		..(WoWTools_DataMixin.onlyChinese and '复制聊天' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CALENDAR_COPY_EVENT, CHAT)),
	function()
		Get_Text(index)
		return MenuResponse.Open
	end)
	sub:SetTooltip(function(tooltip)
		local tab=  _G['ChatFrame'..index..'Tab']
		if tab then
			tooltip:AddLine(tab:GetText())
		end
		tooltip:AddLine(
			WoWTools_DataMixin.Icon.icon2
			..(WoWTools_DataMixin.onlyChinese and '聊天' or CHAT)
			..' |cnGREEN_FONT_COLOR:#'
			..self:GetNumMessages()
		)
	end)
--选项
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '显示按钮' or SHOW_QUICK_BUTTON,
	function()
		return Save().showCopyChatButton
	end, function()
		Save().showCopyChatButton= not Save().showCopyChatButton and true or false
		for i= 1, NUM_CHAT_WINDOWS do
			Init_Button(i)
		end
	end)

--处理文本
	sub:CreateCheckbox(
		WoWTools_DataMixin.onlyChinese and '处理文本' or 'Processing text',
	function()
			return Save().copyChatSetText
	end, function()
		Save().copyChatSetText= not Save().copyChatSetText and true or nil
	end)

--打开，选项面板
	sub:CreateDivider()
	WoWTools_ChatMixin:Open_SettingsPanel(sub, WoWTools_HyperLink.addName)
end













function Init_Button(index)
	local enabled= Save().showCopyChatButton and true or false
	local frame= _G['ChatFrame'..index]
	if not frame then
		return
	elseif frame.CopyChatButton then
		if frame.ResizeButton then
			frame.ScrollToBottomButton:SetPoint('BOTTOMRIGHT', frame.ResizeButton, 'TOPRIGHT', -2, enabled and 15 or -1)-- -2,-2
		end
		frame.CopyChatButton:SetShown(enabled)
		return

	elseif not enabled then
		return
	end

	frame.CopyChatButton= CreateFrame('Button', 'WoWToolsChatCopyButton'..index, frame)

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

		local num = self:GetParent():GetNumMessages() or 0
		local col= num==0 and '|cff606060'
		GameTooltip:SetText(
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
		if d~='RightButton' then
			Get_Text(self:GetParent():GetName():match('%d+') or '1')
		else
			MenuUtil.CreateContextMenu(self, Init_Menu)
		end
	end)
end














local function Init()
	if Save().showCopyChatButton then
		for index = 1, NUM_CHAT_WINDOWS do
			Init_Button(index)
		end
	end

	if ChatFrameMixin and ChatFrameMixin.OnLoad then
		WoWTools_DataMixin:Hook(ChatFrameMixin, 'OnLoad', function(frame)
			local index = frame:GetName():match("(%d+)")
			if index then
				Init_Button(index)
			end
		end)
	elseif ChatFrame_OnLoad then --11.2.7没有了
		WoWTools_DataMixin:Hook('ChatFrame_OnLoad', function(frame)
			local index = frame:GetName():match("(%d+)")
			if index then
				Init_Button(index)
			end
		end)
	end

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


	Menu.ModifyMenu("MENU_FCF_TAB", function(...)
		Init_Menu(...)
	end)


	Init=function()end
end














function WoWTools_HyperLink:Init_CopyChat()
	Init()
end













