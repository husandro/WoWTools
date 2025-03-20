local function Save()
    return WoWTools_HyperLink.Save
end




--#############
--欢迎加入, 信息
--#############
local raidMS=ERR_RAID_MEMBER_ADDED_S:gsub("%%s", "(.+)")--%s加入了团队。
local partyMS= JOINED_PARTY:gsub("%%s", "(.+)")--%s加入了队伍。
local guildMS= ERR_GUILD_JOIN_S:gsub("%%s", "(.+)")--加入了公会

local function Event_CHAT_MSG_SYSTEM(text)--欢迎加入, 信息
    if not text then
        return
    end
    local group= Save().groupWelcome and text:match(raidMS) or text:match(partyMS)
    local guild= Save().guildWelcome and text:match(guildMS)
    if group then
        if UnitIsGroupLeader('player') and (Save().welcomeOnlyHomeGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) or not Save().welcomeOnlyHomeGroup) then
            WoWTools_ChatMixin:Chat(Save().groupWelcomeText or EMOTE103_CMD1:gsub('/',''), group, nil)
        end
    elseif guild and IsInGuild() and text:find(guildMS) then
        C_Timer.After(2, function()
            SendChatMessage(Save().guildWelcomeText..' '.. guild.. ' ' ..GUILD_INVITE_JOIN, "GUILD")
        end)
    end
end




