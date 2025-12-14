--颜色: 关键词
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end










--local Category, Layout
local function Init()
    if not C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Settings' then
                Init()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end

    local frame= CreateFrame('Frame')

    local Category= WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_HyperLink.addName,
        frame=frame,
        category=WoWTools_ChatMixin.Category,
        disabled=not frame
    })

    WoWTools_HyperLink.Category= Category

    local editBox=WoWTools_EditBoxMixin:CreateFrame(frame, {
        text= WoWTools_DataMixin.onlyChinese and '来人 成就' or ('Inv '..ACHIEVEMENTS)
    })
    editBox:SetPoint('TOPLEFT', 8, -22)
    editBox:SetPoint('BOTTOMRIGHT', frame, 'RIGHT', -8, 20)

    local s=''
    for k, _ in pairs(WoWToolsPlayerDate['HyperLinkColorText']) do
        if s~='' then s=s..' ' end
        s=s..k
    end
    editBox:SetText(s)

    local btn= WoWTools_ButtonMixin:Cbtn(editBox, {-- CreateFrame('Button', nil, editBox, 'UIPanelButtonTemplate')
        size={80, 23},
        isUI=true,
        text=WoWTools_DataMixin.onlyChinese and '更新' or UPDATE
    })

    btn:SetPoint('TOPRIGHT', editBox, 'BOTTOMRIGHT')
    btn:SetScript('OnClick', function(self)
        WoWToolsPlayerDate['HyperLinkColorText']={}
        local n=0
        local s2=self:GetParent():GetText()
        s2=s2..' '
        s2=s2:gsub('\n', ' ')
        s2=s2:gsub('.- ', function(t)
            t=t:gsub(' ','')
            if t and t~='' then
                t=WoWTools_TextMixin:Magic(t)
                WoWToolsPlayerDate['HyperLinkColorText'][t]=true
                n=n+1
                print(n..')|cnGREEN_FONT_COLOR:', t)
            end
        end)
        print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            WoWTools_DataMixin.Language.key,
            WoWTools_DataMixin.onlyChinese and '颜色' or COLOR,
            '|cnGREEN_FONT_COLOR:#'..n..(WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)..'|r'
        )
        self:GetParent().ChangeTexture:SetShown(false)
    end)

    local label=WoWTools_LabelMixin:Create(frame)--内容加颜色
    label:SetPoint('BOTTOMLEFT', editBox, 'TOPLEFT', 0, 6)
    label:SetText(
        WoWTools_DataMixin.onlyChinese
        and '颜色: 关键词 (|cnGREEN_FONT_COLOR:空格|r) 分开'
        or (COLOR..': '..KBASE_DEFAULT_SEARCH_TEXT..'|cnGREEN_FONT_COLOR:( '..KEY_SPACE..' )|r')
    )

    editBox.ChangeTexture= editBox:CreateTexture()
    editBox.ChangeTexture:SetSize(20,20)
    editBox.ChangeTexture:SetAtlas('tradeskills-star')
    editBox.ChangeTexture:SetPoint('RIGHT', btn, 'LEFT')
    editBox.editBox:HookScript('OnTextChanged', function(self)
        self:GetParent().ChangeTexture:SetShown(true)
    end)
    editBox.ChangeTexture:Hide()







    local editBox2=WoWTools_EditBoxMixin:CreateFrame(frame, {
        text= WoWTools_DataMixin.onlyChinese and '大脚世界频道=世' or (GENERAL..'=G')
    })
    editBox2:SetPoint('TOPLEFT', frame, 'LEFT',8,-10)
    editBox2:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -8, 30)

    s=''
    for k, v in pairs(Save().channels or {}) do
        if s~='' then s=s..'\n' end
        s=s..k..'='..v
    end
    editBox2:SetText(s)

    local btn2=WoWTools_ButtonMixin:Cbtn(editBox2, {size={80, 23}, isUI=true})
    btn2:SetPoint('TOPRIGHT', editBox2, 'BOTTOMRIGHT')
    btn2:SetText(WoWTools_DataMixin.onlyChinese and '更新' or UPDATE)
    btn2:SetScript('OnMouseDown', function(self)
        Save().channels={}
        local n=0
        local s2=self:GetParent():GetText() or ''
        s2=s2..' '
        s2=s2:gsub('\n', ' ')
        s2=s2:gsub('  ', '')
        s2=s2:gsub('.-=.- ', function(t)
            local name,name2=t:match('(.-)=(.-) ')
            if name and name2 and name~='' and name2~='' then
                name=WoWTools_TextMixin:Magic(name)
                Save().channels[name]=name2
                n=n+1
                print(n..')',name,'|cnGREEN_FONT_COLOR:=|r', name2)
            end
        end)

        print(
            WoWTools_HyperLink.addName..WoWTools_DataMixin.Icon.icon2,
            '|cnGREEN_FONT_COLOR:'..n..'|r',
            WoWTools_DataMixin.onlyChinese and '频道名称替换' or (CHANNEL_CHANNEL_NAME..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL)
        )
        self:GetParent().ChangeTexture:SetShown(false)
    end)

    local label2=WoWTools_LabelMixin:Create(frame)--频道名称替换
    label2:SetPoint('BOTTOMLEFT', editBox2, 'TOPLEFT', 0, 6)
    label2:SetText(WoWTools_DataMixin.onlyChinese and '频道名称替换: 关键词|cnGREEN_FONT_COLOR:=|r替换' or (CHANNEL_CHANNEL_NAME..': '..COMMUNITIES_SETTINGS_SHORT_NAME_LABEL..'  |cnGREEN_FONT_COLOR:= |r'))

    editBox2.ChangeTexture= editBox2:CreateTexture()
    editBox2.ChangeTexture:SetSize(20,20)
    editBox2.ChangeTexture:SetAtlas('tradeskills-star')
    editBox2.ChangeTexture:SetPoint('RIGHT', btn2, 'LEFT')
    editBox2.editBox:HookScript('OnTextChanged', function(self)
        self:GetParent().ChangeTexture:SetShown(true)
    end)
    editBox2.ChangeTexture:Hide()


    Init=function()end
end













function WoWTools_HyperLink:Blizzard_Settings()
    Init()
end