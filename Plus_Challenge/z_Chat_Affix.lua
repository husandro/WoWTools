local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end



--赏金
local function Affix_136177()
    local chat={}

    local n=GetNumGroupMembers()
    local IDs2={373113, 373108, 373116, 373121}
    for i=1, n do
        local u= i==n and 'player' or 'party'..i
        local name2= i==n and COMBATLOG_FILTER_STRING_ME or UnitName(u)
        if UnitExists(u) and name2 then
            local buff
            for _, v in pairs(IDs2) do
                local name=WoWTools_AuraMixin:Get(u, v)
                if  name then
                    local link= C_Spell.GetSpellLink(v)
                    if link or name then
                        buff=i..')'..name2..': '..(link or name)
                        break
                    end
                end
            end
            buff=buff or (i..')'..name2..': '..NONE)
            table.insert(chat, buff)
        end
    end

    for _, v in pairs(chat) do
        WoWTools_ChatMixin:Chat(v)
    end
end






local function Chat_Affix()
    local tab = select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}
    for _, info  in pairs(tab) do
        local activeAffixID=select(3, C_ChallengeMode.GetAffixInfo(info))
        if activeAffixID==136177 then--赏金
            C_Timer.After(6, Affix_136177)
            break
        end
    end
end






function WoWTools_ChallengeMixin:Chat_Affix()
    --if not Save().hideKeyUI and Save().slotKeystoneSay then
    if WoWTools_DataMixin.Player.husandro then
        Chat_Affix()
    end
end