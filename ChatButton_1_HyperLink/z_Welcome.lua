--欢迎加入
local function Save()
    return WoWToolsSave['ChatButton_HyperLink']
end

local raidMS=ERR_RAID_MEMBER_ADDED_S:gsub("%%s", "(.+)")--%s加入了团队。
local partyMS= JOINED_PARTY:gsub("%%s", "(.+)")--%s加入了队伍。
local guildMS= ERR_GUILD_JOIN_S:gsub("%%s", "(.+)")--加入了公会















local function Init()
    EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_SYSTEM", function(_, text)
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
                SendChatMessage(
                    (Save().guildWelcomeText or EMOTE103_CMD1:gsub('/',''))
                    ..' '
                    .. guild
                    ..' '..GUILD_INVITE_JOIN,

                    "GUILD"
                )
            end)

        end
    end)

    return true
end












--欢迎加入
function WoWTools_HyperLink:Init_Welcome()
    if (Save().guildWelcome or Save().groupWelcome) and Init() then
       Init=function()end
    end
end
