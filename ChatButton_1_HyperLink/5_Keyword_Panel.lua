--颜色: 关键词
local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end


local LinkButton









--local Category, Layout
local function Init()
    local frame= CreateFrame('Frame')

    local Category= e.AddPanel_Sub_Category({
        name= WoWTools_HyperLink.addName,
        frame=frame,
        category=WoWTools_ChatMixin.Category,
        disabled=not WoWTools_HyperLink.LinkButton
    })

    WoWTools_HyperLink.Category= Category

    local function Cedit(self)
        local edit= CreateFrame('Frame',nil, self, 'ScrollingEditBoxTemplate')--ScrollTemplates.lua
        edit:SetPoint('CENTER')
        edit:SetSize(500,250)
        edit.texture= edit:CreateTexture(nil, "BACKGROUND")
        edit.texture:SetAllPoints()
        edit.texture:SetAtlas('CreditsScreen-Background-0')
        --edit.texture:SetAlpha(0.3)

        return edit
    end

    local str=WoWTools_LabelMixin:Create(frame)--内容加颜色
    str:SetPoint('TOPLEFT')
    str:SetText(e.onlyChinese and '颜色: 关键词 (|cnGREEN_FONT_COLOR:空格|r) 分开' or (COLOR..': '..KBASE_DEFAULT_SEARCH_TEXT..'|cnGREEN_FONT_COLOR:( '..KEY_SPACE..' )|r'))
    local editBox=Cedit(frame)
    editBox:SetPoint('TOPLEFT', str, 'BOTTOMLEFT',0,-5)

    if Save().text then
        local s=''
        for k, _ in pairs(Save().text) do
            if s~='' then s=s..' ' end
            s=s..k
        end
        editBox:SetText(s)
    end
    local btn=CreateFrame('Button', nil, editBox, 'UIPanelButtonTemplate')
    btn:SetSize(80,28)
    btn:SetText(e.onlyChinese and '更新' or UPDATE)
    btn:SetPoint('BOTTOMRIGHT')
    btn:SetScript('OnMouseDown', function(self)
        Save().text={}
        local n=0
        local s=self:GetParent():GetInputText() or ''
        if s:gsub(' ','')~='' then
            s=s..' '
            s=s:gsub('|n', ' ')
            s=s:gsub('.- ', function(t)
                t=t:gsub(' ','')
                if t and t~='' then
                    t=WoWTools_TextMixin:Magic(t)
                    Save().text[t]=true
                    n=n+1
                    print(n..')'..(e.onlyChinese and '颜色' or COLOR), t)
                end
            end)
        end
        print(e.Icon.icon2.. WoWTools_HyperLink.addName, e.onlyChinese and '颜色' or COLOR, '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local str2=WoWTools_LabelMixin:Create(frame)--频道名称替换
    str2:SetPoint('TOPLEFT', editBox, 'BOTTOMLEFT', 0,-20)
    str2:SetText(e.onlyChinese and '频道名称替换: 关键词|cnGREEN_FONT_COLOR:=|r替换' or (CHANNEL_CHANNEL_NAME..': '..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL..'  |cnGREEN_FONT_COLOR:= |r'))
    local editBox2=Cedit(frame)
    editBox2:SetPoint('TOPLEFT', str2, 'BOTTOMLEFT',0,-5)
    if Save().channels then
        local t3=''
        for k, v in pairs(Save().channels) do
            if t3~='' then t3=t3..'|n' end
            t3=t3..k..'='..v
        end
       editBox2:SetText(t3)
    end
    local btn2=CreateFrame('Button', nil, editBox2, 'UIPanelButtonTemplate')
    btn2:SetSize(80,28)
    btn2:SetText(e.onlyChinese and '更新' or UPDATE)
    btn2:SetPoint('BOTTOMRIGHT')
    btn2:SetScript('OnMouseDown', function(self)
        Save().channels={}
        local n=0
        local s=self:GetParent():GetInputText() or ''
        if s:gsub(' ','')~='' then
            s=s..' '
            s=s:gsub('|n', ' ')
            s=s:gsub('.-=.- ', function(t)
                local name,name2=t:match('(.-)=(.-) ')
                if name and name2 and name~='' and name2~='' then
                    name=WoWTools_TextMixin:Magic(name)
                    Save().channels[name]=name2
                    n=n+1
                    print(n..')'..(e.onlyChinese and '频道' or CHANNELS)..': ',name, e.onlyChinese and '替换' or REPLACE, name2)
                end
            end)
        end
        print(e.Icon.icon2.. WoWTools_HyperLink.addName, e.onlyChinese and '频道名称替换' or (CHANNEL_CHANNEL_NAME..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL), '|cnGREEN_FONT_COLOR:#'..n..(e.onlyChinese and '完成' or COMPLETE)..'|r',  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
end













function WoWTools_HyperLink:Init_Panel()
    Init()
end