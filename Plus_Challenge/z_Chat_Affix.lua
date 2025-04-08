local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end



--赏金
local function Affix_136177()
    local chat={}

    local n=GetNumGroupMembers()
    for i=1, n do
        local unit= i==n and 'player' or 'party'..i
        local link= WoWTools_UnitMixin:GetLink(unit, nil, nil, true)
        if UnitExists(unit) then
            local buff
            for _, spellID in pairs({373113, 373108, 373116, 373121}) do
                local name=WoWTools_AuraMixin:Get(unit, spellID)
                if name then
                    buff=i..')'..link..': '..(C_Spell.GetSpellLink(spellID) or name)
                    break
                end
            end
            buff=buff or (WoWTools_UnitMixin:GetLink(unit, nil, nil, true)..': '..NONE)
            table.insert(chat, buff)
        end
    end

    if #chat>0 then
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName)
        for _, v in pairs(chat) do
            WoWTools_ChatMixin:Chat(v)
        end
    end
end






local function Chat_Affix()
    if Save().hideAffixSay then
        return
    end

    local chat, name,_, filedataid

    for _, affixID  in pairs(select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}) do
        name,_, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
        if filedataid == 136177 then--赏金
            C_Timer.After(6, Affix_136177)
            return
        elseif affixID~=9 and affixID~=10 and name and name~='' then
            chat= (chat and chat..', ' or '')..name
        end
    end

    if chat then
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_ChallengeMixin.addName)
        WoWTools_ChatMixin:Chat(PLAYER_DIFFICULTY5..': '..chat)
    end
end





function WoWTools_ChallengeMixin:Chat_Affix()
    Chat_Affix()
end