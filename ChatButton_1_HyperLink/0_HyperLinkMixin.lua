WoWTools_HyperLink={}


function WoWTools_HyperLink:CN_Link(link, tabInfo)
    if link then
        local name= link:match('|h%[|c........(.-)|r]|h') or link:match('|h%[(.-)]|h')
        if name then
            local new= WoWTools_TextMixin:CN(name, tabInfo)--汉化
            if new and name~=new then
                name= name:match('|c........(.-)|r') or name
                name= WoWTools_TextMixin:Magic(name)
                link= link:gsub(name, new)
            end
        end
    end
    return link
end


function WoWTools_HyperLink:GetKeyAffix(link, tab)
    if not tab and link then
        tab= {link:match('Hkeystone:%d+:%d+:%d+:(%d+):(%d+):(%d+):(%d+)')}
    end
    local icon
    for _, v in pairs(tab or {}) do
        if v and v ~='0' then
            local texture= select(3, C_ChallengeMode.GetAffixInfo(v))
            if texture and texture>0 then
                icon=(icon or '')..'|T'..texture..':0|t'
            end
        end
    end
    return icon
end


