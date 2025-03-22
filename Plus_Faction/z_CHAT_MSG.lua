local e= select(2, ...)
local FACTION_STANDING_INCREASED= FACTION_STANDING_INCREASED--"你在%s中的声望值提高了%d点。";
local FACTION_STANDING_INCREASED_ACCOUNT_WIDE = FACTION_STANDING_INCREASED_ACCOUNT_WIDE--"你的战团在%s中的声望值提高了%d点。";
















--#############
--声望更新, 提示
--#############
local function EventFilter(_, _, text, ...)
	if not WoWTools_FactionMixin.Save.factionUpdateTips then
		return
	end

	local name
	if text then
		name= text:match(FACTION_STANDING_INCREASED) or text:match(FACTION_STANDING_INCREASED_ACCOUNT_WIDE)
	end

	if not name then
		return
	end

	for i=1, C_Reputation.GetNumFactions() do
		local data= C_Reputation.GetFactionDataByIndex(i) or {}
		local name2= data.name
		local factionID= data.factionID
		if name2==name and factionID then
			local cnName= WoWTools_TextMixin:CN(name)
			if cnName then
				local num= text:match('%d+')
				if num then
					text= format("你在%s中的声望值提高了%s点。", cnName, num)
				else
					text= text:gsub(name, cnName)
				end
			end

			local info= WoWTools_FactionMixin:GetInfo(factionID, nil, true)
			text= text..(info.atla and '|A:'..info.atlas..':0:0|a' or (info.texture and '|T'..info.texture..':0|t') or '')
				..(info.factionStandingtext or '')
				..(info.hasRewardPending or '')..(info.valueText and ' '..info.valueText or '')

			return false, text, ...
		end
	end
end

















local function Init_Check()
    local text
    for i=1, C_Reputation.GetNumFactions() do--声望更新, 提示
        local data= C_Reputation.GetFactionDataByIndex(i) or {}
        local name= data.name
        local factionID= data.factionID
        if name and factionID and C_Reputation.IsFactionParagon(factionID) and select(4, C_Reputation.GetFactionParagonInfo(factionID)) then--奖励
            text= text and text..' ' or ''

            local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            if repInfo and repInfo.texture and repInfo.texture>0 then
                text= text..'|T'..repInfo.texture..':0|t'
            elseif C_Reputation.IsMajorFaction(factionID) then
                local info = C_MajorFactions.GetMajorFactionData(factionID)
                if info and info.textureKit then
                    text= text..'|A:MajorFactions_Icons_'..info.textureKit..'512:0:0|a'
                end
            end
            text= text..WoWTools_TextMixin:CN(name)
        end
    end
    if text then
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_FactionMixin.addName, '|cffff00ff'..text..'|r', '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '你有未领取的奖励' or WEEKLY_REWARDS_UNCLAIMED_TITLE))
    end
end


















function WoWTools_FactionMixin:Init_Chat_MSG()
	FACTION_STANDING_INCREASED= LOCALE_zhCN and '你在(.+)中的声望值提高了.+点。' or WoWTools_TextMixin:Magic(FACTION_STANDING_INCREASED)
	FACTION_STANDING_INCREASED_ACCOUNT_WIDE= LOCALE_zhCN and '你的战团在(.+)中的声望值提高了.+点。' or WoWTools_TextMixin:Magic(FACTION_STANDING_INCREASED_ACCOUNT_WIDE)

    ChatFrame_AddMessageEventFilter('CHAT_MSG_COMBAT_FACTION_CHANGE', EventFilter)

    if self.Save.factionUpdateTips then--声望更新, 提示
        C_Timer.After(4, Init_Check)
    end
end


function WoWTools_FactionMixin:Check_Chat_MSG()
	Init_Check()
end