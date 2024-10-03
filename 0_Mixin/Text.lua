WoWTools_TextMixin={}






--垂直文字
function WoWTools_TextMixin:Vstr(text)--垂直文字
    if text then
        if (select(2, text:gsub("[^\128-\193]", "")) == #text) then
            return text:gsub(".", "%1|n")
        else
            return text:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
        end
    end
end