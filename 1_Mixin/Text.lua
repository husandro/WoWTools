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
    tab= tab or {}
    local onHide= tab.onHide

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
        end)
        frame:SetFrameStrata('HIGH')
    end



    local text
    if type(data)=='table' then
        for _, str in pairs(data) do
            text= text and text..'|n' or ''
            text= text.. str
        end
    else
        text= data
    end

    frame.ScrollBox:SetText(text or '')
    frame.Header:Setup(headerText or '' )
    frame.onHide= onHide

    frame:SetShown(true)

    --frame.ScrollBox.editBox:SetCursorPosition(1)
    frame.ScrollBox.ScrollBar:ScrollToEnd()
    frame:Raise()
end











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
        text= self:CN(text)
        if (select(2, text:gsub("[^\128-\193]", "")) == #text) then
            return text:gsub(".", "%1|n")
        else
            return text:gsub("([%z\1-\127\194-\244][\128-\191]*)", "%1|n")
        end
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
    if not text or text=='' or not size or size==0  then
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
            return WoWTools_DataMixin.onlyChinese and '|cnGREEN_FONT_COLOR:显示|r/隐藏' or ('|cnGREEN_FONT_COLOR:'..SHOW..'|r/'..HIDE)
        elseif sh==false then
            return WoWTools_DataMixin.onlyChinese and '显示/|cff828282隐藏|r' or (SHOW..'/|cff828282'..HIDE..'|r')
        else
            return WoWTools_DataMixin.onlyChinese and '显示/隐藏' or (SHOW..'/'..HIDE)
        end
    elseif sh then
		return '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW)..'|r'
	else
		return '|cff828282'..(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)..'|r'
	end
end

function WoWTools_TextMixin:GetEnabeleDisable(ed, all)--启用或禁用字符
    if all then
        if ed==nil then
            return WoWTools_DataMixin.onlyChinese and '启用/禁用' or (ENABLE..'/'..DISABLE)
        elseif ed==true then
            return WoWTools_DataMixin.onlyChinese and '|cnGREEN_FONT_COLOR:启用|r/禁用' or ('|cnGREEN_FONT_COLOR:'..ENABLE..'|r/'..DISABLE)
        else
            return WoWTools_DataMixin.onlyChinese and '启用/|cff828282禁用|r' or (ENABLE..'/|cff828282'..DISABLE..'|r')
        end
    else
        if ed then
            return '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '启用' or ENABLE)..'|r'
        else
            return '|cff828282'..(WoWTools_DataMixin.onlyChinese and '禁用' or DISABLE)..'|r'
        end
    end
end

function WoWTools_TextMixin:GetYesNo(yesno, notColor)
    if notColor then
        if yesno then
            return WoWTools_DataMixin.onlyChinese and '是' or YES
        else
            return WoWTools_DataMixin.onlyChinese and '否' or NO
        end
    else

        if yesno then
            return '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '是' or YES)..'|r'
        else
            return '|cff828282'..(WoWTools_DataMixin.onlyChinese and '否' or NO)..'|r'
        end
    end
end


