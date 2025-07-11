--欢迎加入
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end

local raidMS=ERR_RAID_MEMBER_ADDED_S:gsub("%%s", "(.+)")--%s加入了团队。
local partyMS= JOINED_PARTY:gsub("%%s", "(.+)")--%s加入了队伍。
local guildMS= ERR_GUILD_JOIN_S:gsub("%%s", "(.+)")--加入了公会















local function Init()
    if not Save().guildWelcome and Save().groupWelcome then
        return
    end

    EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_SYSTEM", function(_, text)
        if not text then
            return
        end

        local group= Save().groupWelcome and text:match(raidMS) or text:match(partyMS)
        local guild= Save().guildWelcome and text:match(guildMS)

        if group then
            if UnitIsGroupLeader('player') and (Save().welcomeOnlyHomeGroup and IsInGroup(LE_PARTY_CATEGORY_HOME) or not Save().welcomeOnlyHomeGroup) then
                WoWTools_ChatMixin:Chat(WoWToolsPlayerDate['HyperLinkGroupWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '{rt1}欢迎{rt1}' or '{rt1}Hi{rt1}'), group, nil)
            end

        elseif guild and IsInGuild() and text:find(guildMS) then

            C_Timer.After(2, function()
                SendChatMessage(
                    (WoWToolsPlayerDate['HyperLinkGuildWelcomeText'] or (WoWTools_DataMixin.Player.IsCN and '欢迎' or EMOTE103_CMD1:gsub('/','')))
                    ..' '
                    .. guild
                    ..' '..GUILD_INVITE_JOIN,

                    "GUILD"
                )
            end)

        end
    end)

    Init=function()end
end












--欢迎加入
function WoWTools_HyperLink:Init_Welcome()
    Init()
end
