WoWTools_TextMixin={}


--[[
. ( ) + - * ? [ ^

MoveAny\libs\D4Lib
local function IsUkrainianLetters(str)
    return str:match("[\192-\199]") ~= nil
end

local function IsRussianLetters(str)
    return str:match("[\192-\255]") ~= nil
end

local function IsChineseLetters(str)
    return str:match("[\228-\233]") ~= nil
end

local function IsKoreanLetters(str)
    return str:match("[\234-\237]") ~= nil
end
text:find("[\228-\233][\128-\191][\128-\191]") then--检查 UTF-8 字符

]]


function WoWTools_TextMixin:ShowText(data, headerText, tab)
    if not canaccesstable(data) then
        print(WoWTools_DataMixin.Icon.icon2..'|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '显示机密数值' or EVENTTRACE_SHOW_SECRET_VALUES))
        return
    end
    tab= tab or {}

    headerText= tostring(headerText)
    headerText= (headerText=='' or headerText=='nil') and WoWTools_DataMixin.addName or headerText

    local onHide= tab.onHide
    local notClear= tab.notClear

    local text

    local function add_text(value)
        text= text and text..'|n' or ''
        if not canaccessvalue(value) then
            text= text..EVENTTRACE_SECRET_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and "显示机密数值" or EVENTTRACE_SHOW_SECRET_VALUES)
        elseif type(value)=='string' then
            text= text..value
        else
            text= text..tostring(value)
        end
    end

    if type(data)~='table' then
        text= add_text(data)
    else
        for _, value in pairs(data) do
            add_text(value)
        end
    end


    local frame= _G['WoWToolsShowTextEditBoxFrame']
    if not frame then
        frame= WoWTools_FrameMixin:Create(nil, {name='WoWToolsShowTextEditBoxFrame'})
        frame.ScrollBox=WoWTools_EditBoxMixin:CreateFrame(frame, {isLink=true})
        frame.ScrollBox:SetPoint('TOPLEFT', 11, -32)
        frame.ScrollBox:SetPoint('BOTTOMRIGHT', -6, 12)

        frame:SetScript('OnHide', function(f)
            if f.onHide then
                do
                    f.onHide(f.ScrollBox:GetText())
                end
                f.onHide=nil
            end
            f.ScrollBox:SetText('')
            f.Header:Setup('' )
        end)
        frame:SetFrameStrata('HIGH')

    elseif notClear then
        local p= frame.ScrollBox:GetText()
        if canaccessvalue(p) and p~='' and text~=p then
            text= p..'|n|n'..text
        end
    end

    frame:Show()
    frame:Raise()

    frame.ScrollBox.editBox:SetText(text or '')
    --frame.ScrollBox.editBox:SetText(text or '')
    frame.Header:Setup(headerText or '' )
    frame.onHide= onHide
    --frame.ScrollBox.ScrollBar:ScrollToEnd()
end
--frame.ScrollBox.editBox:SetCursorPosition(1)










function WoWTools_TextMixin:Magic(text)
    if type(text)~='string' then
        return text
    end

    local tab= {'%.', '%(','%)','%+', '%-', '%*', '%?', '%[', '%^'}
    for _, v in pairs(tab) do
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
    if type(text)~='string' then
        return text
    end

    text= self:CN(text)
    if (select(2, text:gsub("[^\128-\193]", "")) == #text) then
        return text:gsub(".", "%1|n")
    else
        return text:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
    end
end




--取得中文
function WoWTools_TextMixin:CN(text, tab)--{gossipOptionID=, questID=}
    if WoWTools_ChineseMixin and WoWTools_DataMixin.onlyChinese and (text or tab) then
        local data= WoWTools_ChineseMixin:GetData(text, tab)
        if data then
            return data
        end
    end
    return text
end


--截取, 字符
function WoWTools_TextMixin:sub(text, size, letterSize, lower)
    if not canaccessvalue(text)
        or type(text)~='string'
        or text==''
        or not size
        or size==0
    then
        return text
    end

    text= self:CN(text)

    if not text:find("[\228-\233][\128-\191][\128-\191]") then--检查 UTF-8 字符
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





function WoWTools_TextMixin:GetShowHide(sh, all)
    if all then
        if sh then
            return WoWTools_DataMixin.onlyChinese and '显示/|cff626262隐藏' or (SHOW..'/|cff626262'..HIDE)
        elseif sh==false then
            return WoWTools_DataMixin.onlyChinese and '|cff626262显示|r/隐藏' or ('|cff626262'..SHOW..'|r/'..HIDE)
        else
            return WoWTools_DataMixin.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE)
        end
    elseif sh then
		return WoWTools_DataMixin.onlyChinese and '显示' or SHOW
	else
		return DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)
	end
end

function WoWTools_TextMixin:GetEnabeleDisable(ed, all)--启用或禁用字符
    if all then
        if ed==nil then
            return WoWTools_DataMixin.onlyChinese and '启用/禁用' or (ENABLE..'/'..DISABLE)
        elseif ed==true then
            return WoWTools_DataMixin.onlyChinese and '启用/|cff626262禁用' or (ENABLE..'/|cff626262'..DISABLE)
        else
            return WoWTools_DataMixin.onlyChinese and '|cff626262启用|r/禁用' or ('|cff626262'..ENABLE..'|r/'..DISABLE)
        end
    else
        if ed then
            return WoWTools_DataMixin.onlyChinese and '启用' or ENABLE
        else
            return DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)
        end
    end
end

function WoWTools_TextMixin:GetYesNo(yesno)
    if yesno then
        return WoWTools_DataMixin.onlyChinese and '是' or YES
    else
        return DISABLED_FONT_COLOR:WrapTextInColorCode(WoWTools_DataMixin.onlyChinese and '否' or NO)
    end
end


