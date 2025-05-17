local function Save()
    return WoWToolsSave['Menu']
end

local TextureTab={--TalentArt
['talents-background-warrior-arms']=true,
['talents-background-warrior-fury']=true,
['talents-background-warrior-protection']=true,

['talents-background-paladin-holy']=true,
['talents-background-paladin-protection']=true,
['talents-background-paladin-retribution']=true,

['talents-background-deathknight-blood']=true,
['talents-background-deathknight-frost']=true,
['talents-background-deathknight-unholy']=true,

['talents-background-hunter-beastmastery']=true,
['talents-background-hunter-marksmanship']=true,
['talents-background-hunter-survival']=true,

['talents-background-shaman-elemental']=true,
['talents-background-shaman-enhancement']=true,
['talents-background-shaman-restoration']=true,

['talents-background-evoker-devastation']=true,
['talents-background-evoker-preservation']=true,
['talents-background-evoker-augmentation']=true,

['talents-background-druid-balance']=true,
['talents-background-druid-feral']=true,
['talents-background-druid-guardian']=true,
['talents-background-druid-restoration']=true,

['talents-background-rogue-assassination']=true,
['talents-background-rogue-outlaw']=true,
['talents-background-rogue-subtlety']=true,

['talents-background-monk-brewmaster']=true,
['talents-background-monk-mistweaver']=true,
['talents-background-monk-windwalker']=true,

['talents-background-demonhunter-havoc']=true,
['talents-background-demonhunter-vengeance']=true,

['talents-background-priest-discipline']=true,
['talents-background-priest-holy']=true,
['talents-background-priest-shadow']=true,

['talents-background-mage-arcane']=true,
['talents-background-mage-fire']=true,
['talents-background-mage-frost']=true,

['talents-background-warlock-affliction']=true,
['talents-background-warlock-demonology']=true,
['talents-background-warlock-destruction']=true,

['UI-Frame-KyrianChoice-ScrollingBG']=true,
['UI-Frame-NecrolordsChoice-ScrollingBG']=true,
['UI-Frame-NightFaeChoice-ScrollingBG']=true,
['UI-Frame-VenthyrChoice-ScrollingBG']=true,
['scoreboard-background-warfronts-darkshore-horde']=true,
['scoreboard-background-islands-alliance']=true,

['legionmission-complete-background-warrior']=true,
['legionmission-complete-background-druid']=true,

['legionmission-complete-background-Paladin']=true,
['legionmission-complete-background-hunter']=true,
['legionmission-complete-background-Rogue']=true,
['legionmission-complete-background-Priest']=true,
['legionmission-complete-background-deathknight']=true,
['legionmission-complete-background-Shaman']=true,
['legionmission-complete-background-Mage']=true,
['legionmission-complete-background-Warlock']=true,
['legionmission-complete-background-Monk']=true,
['legionmission-complete-background-demonhunter']=true,

}







local function Init_Texture_Sub_Menu(_, root, name)
    local sub
    local isAtlas, textureID, icon= WoWTools_TextureMixin:IsAtlas(name, {480, 240})
    if not textureID then
        return
    end
    sub=root:CreateCheckbox(
        '',
    function(data)
        return data.name== Save().bg.icon
    end, function(data)
        if data.name== Save().bg.icon then
            Save().bg.icon=nil
        else
            Save().bg.icon= data.name
        end
        Call_Bg()
    end, {isAtlas=isAtlas, name=textureID, icon=icon})

    sub:AddInitializer(function(button, desc)
        local texture = button:AttachTexture();
        texture:SetSize(64, 32)
        texture:SetPoint("RIGHT")
        if desc.data.isAtlas then
            texture:SetAtlas(desc.data.name)
        else
            texture:SetTexture(desc.data.name)
        end
    end)

    sub:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.icon)
        tooltip:AddLine(desc.data.name)
    end)
    return sub
end


local function Init_Texture_Menu(self, root)
    local num=0
    for name in pairs(Save().bg.texture) do
        local sub=Init_Texture_Sub_Menu(self, root, name)
        if sub then
            sub:CreateCheckbox(
                WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            function(data)
                return Save().bg.texture[data.name]
            end, function(data)
                Save().bg.texture[data.name]= not Save().bg.texture[data.name] and true or nil
                return MenuResponse.Refresh
            end, {name=name})
            num=num+1
        end
    end

    if num>3 then
        root:CreateDivider()
        root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
        function()
            StaticPopup_Show('WoWTools_OK',
            WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL,
            nil,
            {SetValue=function()
                Save().bg.texture={}
            end}
        )
        end)
    end
    root:CreateDivider()

    for name in pairs(TextureTab) do
        Init_Texture_Sub_Menu(self, root, name)
    end

--SetScrollMod
    WoWTools_MenuMixin:SetScrollMode(root)
end






local function Init_Menu(self, root)--隐藏，天赋，背景
    local sub, sub2, sub3
    root:CreateDivider()
--显示背景
    sub=WoWTools_MenuMixin:ShowBackground(root, function()
        return Save().bg.show
    end, function()
        Save().bg.show= not Save().bg.show and true or nil
        WoWTools_SpellMixin:Init_TalentsFrame()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_SpellMixin.addName)
    end)


    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM,
    function()
        return Save().bg.icon
    end, function()
        Save().bg.icon= nil
        Call_Bg()
    end)
    sub2:SetTooltip(function (tooltip)
        local _, textureID, icon= WoWTools_TextureMixin:IsAtlas(Save().bg.icon, {480, 240})
        if textureID then
            tooltip:AddLine(icon)
            tooltip:AddLine(textureID)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 )
        end
    end)

    sub2:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加' or ADD,
    function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND)..'\n\nTexture or Atlas\n',
        nil,
        {
            OnShow=function(s)
                s.button1:SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                s.editBox:SetText('Interface\\AddOns\\WoWTools\\Source\\Background\\')
            end,
            SetValue= function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s.editBox:GetText(), 0))
                if textureID then
                    Save().bg.icon= textureID
                    Call_Bg()
                    if not TextureTab[textureID] then
                        Save().bg.texture[textureID]=true
                    end
                end
            end,
            EditBoxOnTextChanged=function(s)
                s:GetParent().button1:SetEnabled(select(2, WoWTools_TextureMixin:IsAtlas(s:GetText(), 0)))
            end,
        }
    )
    end)

--材质，列表
    Init_Texture_Menu(self, sub2)






--Web
    sub3=sub2:CreateButton(
        'Web',
    function(data)
        WoWTools_TooltipMixin:Show_URL(nil, nil, nil, data.name)
        return MenuResponse.Open
    end, {name=[[https://www.aconvert.com/]]})
    sub3:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
    end)
end





function WoWTools_MenuMixin:BgTexture(root, GetAlphaValue, SetAlphaValue, GetIconValue, SetIconValue, Rest)
    local sub, sub2

    sub= WoWTools_MenuMixin:BgAplha(root, GetAlphaValue, SetAlphaValue, Rest, false)

    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM,
    GetIconValue,
    function(data)
        if data.GetIconValue() then
            data.SetIconValue(nil)
        else
            data.SetIconValue(data.icon)
        end
    end,
    {
        GetIconValue=GetIconValue,
        SetIconValue=SetIconValue,
        icon=GetIconValue(),
    })

    sub2:SetTooltip(function (tooltip, desc)
        local _, textureID, icon= WoWTools_TextureMixin:IsAtlas(desc.data.GetIconValue(), {480, 240})
        if textureID then
            tooltip:AddLine(icon)
            tooltip:AddLine(textureID)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 )
        end
    end)
end