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
	if (not currentMsg) then
		return ""
	end
    local number
	local chatNumber = string.match(currentMsg, "(%d+) |4year:years;")
	if (chatNumber) then
        number= tonumber(chatNumber)
		if (number == 0) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4year:years;", chatNumber .. " year")
		elseif (number > 1) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4year:years;", chatNumber .. " years")
		else
			currentMsg = currentMsg --Do nothing.
		end
	end
	chatNumber = string.match(currentMsg, "(%d+) |4day:days;")
	if (chatNumber) then
        number= tonumber(chatNumber)
		if (number == 0) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4day:days;", chatNumber .. " day")
		elseif (number > 1) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4day:days;", chatNumber .. " days")
		else
			currentMsg = currentMsg --Do nothing.
		end
	end
	chatNumber = string.match(currentMsg, "(%d+) |4hour:hours;")
	if (chatNumber) then
        number= tonumber(chatNumber)
		if (number == 0) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4hour:hours;", chatNumber .. " hour")
		elseif (number > 1) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4hour:hours;", chatNumber .. " hours")
		else
			currentMsg = currentMsg --Do nothing.
		end
	end
	chatNumber = string.match(currentMsg, "(%d+) |4minute:minutes;")
	if (chatNumber) then
        number= tonumber(chatNumber)
		if (number == 0) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4minute:minutes;", chatNumber .. " minute")
		elseif (number > 1) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4minute:minutes;", chatNumber .. " minutes")
		else
			currentMsg = currentMsg --Do nothing.
		end
	end
	chatNumber = string.match(currentMsg, "(%d+) |4second:seconds;")
	if (chatNumber) then
        number= tonumber(chatNumber)
		if (number == 0) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4second:seconds;", chatNumber .. " second")
		elseif (number > 1) then
			currentMsg = string.gsub(currentMsg, "(%d+) |4second:seconds;", chatNumber .. " seconds")
		else
			currentMsg = currentMsg --Do nothing.
		end
	end
	currentMsg = string.gsub(currentMsg, "|T.-|t", "")
	return currentMsg
end



local function Get_Text(btn)
	local index= btn.index or 1

	local maxLines = _G["ChatFrame" .. index]:GetNumMessages() or 0
	local tab={}
	for i = 1, maxLines do
		local currentMsg, r, g, b, chatTypeID = _G["ChatFrame" .. index]:GetMessageInfo(i)
		currentMsg= currentMsg or ''

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

		--source
		table.insert(tab, currentMsg)
	end


	WoWTools_TextMixin:ShowText(
		tab,
		_G['ChatFrame'..index..'Tab']:GetText()
	)

end



local function Init()
	for index = 1, NUM_CHAT_WINDOWS do
		local frame= _G['ChatFrame'..index..'ButtonFrame']
		if not frame then
			return
		end

		local btn=WoWTools_ButtonMixin:Cbtn(frame, {
			atlas= 'poi-workorders',
			name='WoWToolsChatCopyButton'..index,
			addTexture=true,
			szie=32,
		})

		btn:SetNormalTexture('chatframe-button-up')
		btn:SetPushedAtlas('chatframe-button-down')
		btn:SetHighlightAtlas('chatframe-button-highlight')
		WoWTools_TextureMixin:SetButton(btn)
		btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 8, -8)
        btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -8, 8)

		btn.index= index

		btn:SetPoint('BOTTOM', ChatFrameMenuButton, 'TOP', 0, 32)
		btn:SetScript('OnClick', function(b)
			Get_Text(b)
		end)
	end

	Init=function()end
end
function WoWTools_HyperLink:Init_CopyChat()
	Init()
end
