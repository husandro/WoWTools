local e= select(2, ...)
WoWTools_TextMixin={}


function WoWTools_TextMixin:Magic(text)
    local tab= {'%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^'}
    for _,v in pairs(tab) do
        text= text:gsub(v,'%%'..v)
    end
    tab={
        ['%%%d%$s']= '%(%.%-%)',
        ['%%s']= '%(%.%-%)',
        ['%%%d%$d']= '%(%%d%+%)',
        ['%%d']= '%(%%d%+%)',
    }
    local find
    for k,v in pairs(tab) do
        text= text:gsub(k,v)
        find=true
    end
    if find then
        tab={'%$'}
    else
        tab={'%%','%$'}
    end
    for _, v in pairs(tab) do
        text= text:gsub(v,'%%'..v)
    end
    return text
end



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




--取得中文
function e.cn(text, tab)--{gossipOptionID=, questID=}
    return WoWTools_Chinese_Mixin and WoWTools_Chinese_Mixin:Setup(text, tab) or text
end



function WoWTools_TextMixin:sub(text, size, letterSize, lower)
    if not text or text=='' then
        return text
    end
    local le = strlenutf8(text)
    local le2= strlen(text)

    text= e.cn(text)

    if le==le2 and text:find('%w') then
        text= text:sub(1, letterSize or size)
        return lower and strlower(text) or text
    else
        local i, output = 1, ''
        while (size > 0) do
            local byte = text:byte(i)
            if not byte then
              return output
            end
            if byte < 128 then--ASCII byte
              output = output .. text:sub(i, i)
              size = size - 1
            elseif byte < 192 then--Continuation bytes
              output = output .. text:sub(i, i)
            elseif byte < 244 then--Start bytes
              output = output .. text:sub(i, i)
              size = size - 1
            end
            i = i + 1
        end
        while (true) do
            local byte = text:byte(i)
            if byte and byte >= 128 and byte < 192 then
                output = output .. text:sub(i, i)
            else
                break
            end
            i = i + 1
        end
        return lower and strlower(output) or output
    end
end





function e.GetShowHide(sh, all)
    if all then
        if sh then
            return e.onlyChinese and '|cnGREEN_FONT_COLOR:显示|r/隐藏' or ('|cnGREEN_FONT_COLOR:'..SHOW..'|r/'..HIDE)
        elseif sh==false then
            return e.onlyChinese and '显示/|cnRED_FONT_COLOR:隐藏|r' or (SHOW..'/|cnRED_FONT_COLOR:'..HIDE..'|r')
        else
            return e.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE)
        end
    elseif sh then
		return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '显示' or SHOW)..'|r'
	else
		return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '隐藏' or HIDE)..'|r'
	end
end

function e.GetEnabeleDisable(ed)--启用或禁用字符
    if ed then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '启用' or ENABLE)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r'
    end
end

function e.GetYesNo(yesno)
    if yesno then
        return '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '是' or YES)..'|r'
    else
        return '|cnRED_FONT_COLOR:'..(e.onlyChinese and '否' or NO)..'|r'
    end
end


