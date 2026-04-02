local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end



--赏金
local function Affix_136177()
    local chat, data, link= {}, nil, nil
    local n=GetNumGroupMembers()
    for i=1, n do
        local unit= i==n and 'player' or 'party'..i
        if WoWTools_UnitMixin:UnitExists(unit) then
            link= WoWTools_UnitMixin:GetLink(unit, nil, nil, true) or unit
            data= WoWTools_AuraMixin:Get(unit, {
                [373113]=true,
                [373108]=true,
                [373116]=true,
                [373121]=true,
            })
            if data then
                table.insert(chat, i..')'..link..': '..(C_Spell.GetSpellLink(data.spellId) or data.name))
            else
                table.insert(chat, link..': '..NONE)
            end
        end
    end

    if #chat>0 then
        print(
            WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2
        )
        for _, v in pairs(chat) do
            WoWTools_ChatMixin:Chat(v)
        end
    end
end






local function Chat_Affix()
    if Save().hideAffixSay then
        return
    end

    local chat

    for _, affixID  in pairs(select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}) do
        local name,_, filedataid = C_ChallengeMode.GetAffixInfo(affixID)
        if filedataid == 136177 then--赏金
            C_Timer.After(6, Affix_136177)
            return
        elseif affixID~=9 and affixID~=10 and name and name~='' then
            chat= (chat and chat..', ' or '')..name
        end
    end

    if chat then
        print(
            WoWTools_ChallengeMixin.addName..WoWTools_DataMixin.Icon.icon2
        )
        WoWTools_ChatMixin:Chat(PLAYER_DIFFICULTY5..': '..chat)
    end
end





function WoWTools_ChallengeMixin:Chat_Affix()
    Chat_Affix()
end