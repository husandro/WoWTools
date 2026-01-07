local function Save()
    return WoWToolsSave['Plus_Texture'].Bg
end

local BGName= 'WoWTools_BG'


local RestIcon= 'Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga'

local function SaveData(name)
    if Save().Add[name].enabled then
        return Save().Add[name]--分开设置
    else--统一设置
        local data= Save().All or {}
        data.alpha= data.alpha or 0.5
        data.texture= data.texture or RestIcon
        return data
    end
end

local function IsEnabledSaveBg(name)
    return Save().Add[name].enabled
end


local function Get_Alpha(name, icon)
    return SaveData(name).alpha or icon.BgData.alpha or 0.5
end

local function Get_NineSlice_Alpha(name, icon)
    return SaveData(name).nineSliceAlpha or icon.BgData.nineSliceAlpha or 0
end

local function Get_Portrait_Alpha(name, icon)
    return SaveData(name).portraitAlpha or icon.BgData.portraitAlpha or 1
end



local TextureTab={
[RestIcon]=1,
['Interface\\AddOns\\WoWTools\\Source\\Background\\White.tga']=1,
['Interface\\DialogFrame\\UI-DialogBox-Background']=1,
['Interface\\DialogFrame\\UI-DialogBox-Background-Dark']=1,
['Interface\\DialogFrame\\UI-DialogBox-Gold-Background']=1,
['Interface\\Tooltips\\UI-Tooltip-Background']=1,
['Interface\\Tooltips\\UI-Tooltip-Background-Azerite']=1,
['Interface\\Tooltips\\UI-Tooltip-Background-Corrupted']=1,
['Interface\\Tooltips\\UI-Tooltip-Background-Maw']=1,


['talents-background-warrior-arms']=1,
['talents-background-warrior-fury']=1,
['talents-background-warrior-protection']=1,

['talents-background-paladin-holy']=1,
['talents-background-paladin-protection']=1,
['talents-background-paladin-retribution']=1,

['talents-background-deathknight-blood']=1,
['talents-background-deathknight-frost']=1,
['talents-background-deathknight-unholy']=1,

['talents-background-hunter-beastmastery']=1,
['talents-background-hunter-marksmanship']=1,
['talents-background-hunter-survival']=1,

['talents-background-shaman-elemental']=1,
['talents-background-shaman-enhancement']=1,
['talents-background-shaman-restoration']=1,

['talents-background-evoker-devastation']=1,
['talents-background-evoker-preservation']=1,
['talents-background-evoker-augmentation']=1,

['talents-background-druid-balance']=1,
['talents-background-druid-feral']=1,
['talents-background-druid-guardian']=1,
['talents-background-druid-restoration']=1,

['talents-background-rogue-assassination']=1,
['talents-background-rogue-outlaw']=1,
['talents-background-rogue-subtlety']=1,

['talents-background-monk-brewmaster']=1,
['talents-background-monk-mistweaver']=1,
['talents-background-monk-windwalker']=1,

['talents-background-demonhunter-havoc']=1,
['talents-background-demonhunter-vengeance']=1,

['talents-background-priest-discipline']=1,
['talents-background-priest-holy']=1,
['talents-background-priest-shadow']=1,

['talents-background-mage-arcane']=1,
['talents-background-mage-fire']=1,
['talents-background-mage-frost']=1,

['talents-background-warlock-affliction']=1,
['talents-background-warlock-demonology']=1,
['talents-background-warlock-destruction']=1,

['UI-Frame-KyrianChoice-ScrollingBG']=1,
['UI-Frame-NecrolordsChoice-ScrollingBG']=1,
['UI-Frame-NightFaeChoice-ScrollingBG']=1,
['UI-Frame-VenthyrChoice-ScrollingBG']=1,
['scoreboard-background-warfronts-darkshore-horde']=1,
['scoreboard-background-islands-alliance']=1,

['legionmission-complete-background-warrior']=1,
['legionmission-complete-background-druid']=1,

['legionmission-complete-background-Paladin']=1,
['legionmission-complete-background-hunter']=1,
['legionmission-complete-background-Rogue']=1,
['legionmission-complete-background-Priest']=1,
['legionmission-complete-background-deathknight']=1,
['legionmission-complete-background-Shaman']=1,
['legionmission-complete-background-Mage']=1,
['legionmission-complete-background-Warlock']=1,
['legionmission-complete-background-Monk']=1,
['legionmission-complete-background-demonhunter']=1,
['Artifacts-DeathKnightFrost-BG']=1,
['Artifacts-Shaman-BG']=1,
['hunter-stable-bg-art_cunning']=1,
['hunter-stable-bg-art_ferocity']=1,
['hunter-stable-bg-art_tenacity']=1,
['pvpqueue-bg-alliance']=1,
['pvpqueue-bg-horde']=1,
['UI-Frame-CypherChoice-FX-BottomGlow']=1,
['ui-frame-genericplayerchoice-cardframe-bottomglow']=1,

--[[['QuestBG-Alliance']=1,
['QuestBG-Horde']=1,
['QuestBG-Parchment']=1,
['talenttree-alliance-background']=1,
['talenttree-horde-background']=1,]]
}






local function PlayStop_Anims(self)
    local play= self:IsDrawLayerEnabled('BACKGROUND')
            and self:IsVisible()
            and not Save().Anims.disabled
            and self.AirParticlesFar:GetAlpha()>0

    self.AirParticlesFar:SetShown(play)
    self.backgroundAnims:SetPlaying(play)
end

-- 根据框架大小更新动画偏移量和速度的函数
local function Update_Animation(self)
    local width, height= 0, 0
    if self and self.backgroundAnims and self.backgroundAnims.fadeIn then
        width, height= self[BGName]:GetSize()
    end

    if width==0 or height==0 then
        if self.backgroundAnims then
            self.backgroundAnims:SetPlaying(false)
            self.AirParticlesFar:SetShown(false)
        end
        return
    end

    -- 动画从左上角到右下角
    local xOffset = width
    local yOffset = -height

    self.backgroundAnims.moveAnim:SetOffset(xOffset, yOffset)    -- 左上到右下
    self.backgroundAnims.resetPos:SetOffset(-xOffset, -yOffset)  -- 回到左上

    -- 根据对角线长度设置动画持续时间，保证速度一致
    local distance = math.sqrt(xOffset * xOffset + yOffset * yOffset)
    local speed = Save().Anims.speed or 10 -- 像素每秒，可根据需要调整
    local duration = distance / speed
    self.backgroundAnims.moveAnim:SetDuration(duration)

    local alpha = Save().Anims.alpha or 0.75
    self.backgroundAnims.fadeIn:SetToAlpha(alpha)   -- 变为不透明
    self.backgroundAnims.fadeOut:SetFromAlpha(alpha)    -- 从不透明

    PlayStop_Anims(self)
end


local function Set_BGTexture(self, name)
    local icon= self[BGName]
    if not icon then
        return
    end

    name= name or self:GetName()
    local data= SaveData(name)

    local alpha= Get_Alpha(name, icon)
    local nineSliceAlpha= Get_NineSlice_Alpha(name, icon)
    local portraitAlpha= Get_Portrait_Alpha(name, icon)
    local texture= data.texture



    if texture and C_Texture.GetAtlasInfo(texture) then
        icon:SetAtlas(texture)
    else
        icon:SetTexture(texture or 0)
    end
    icon:SetVertexColor(1,1,1)
    icon:SetAlpha(alpha)

    if icon.BgData.settings then
        icon.BgData.settings(icon, texture, alpha, nineSliceAlpha, portraitAlpha)
    end

--Frame.Background
    if self.Background then
        self.Background:SetAlpha(texture and 0 or alpha)
    end

--NineSlice
    if self.NineSlice then
        WoWTools_TextureMixin:SetNineSlice(self, nineSliceAlpha)
    elseif self.Border then
        WoWTools_TextureMixin:SetFrame(self.Border, {alpha=nineSliceAlpha, show={[self.Border.Bg]=true}})
    elseif self.BorderContainer then
        WoWTools_TextureMixin:SetFrame(self.BorderContainer, {alpha=nineSliceAlpha})
    else
--BaseFrame 外框
        WoWTools_TextureMixin:SetBaseFrame(self, nineSliceAlpha)
    end



--PortraitContainer
    if self.PortraitOverlay then--公会
        self.PortraitOverlay:SetAlpha(portraitAlpha)
    elseif self.PortraitContainer then
        WoWTools_TextureMixin:SetAlphaColor(self.PortraitContainer.portrait, nil, true, portraitAlpha)
    elseif self.Emblem then--公会银行就用这个
        WoWTools_TextureMixin:SetFrame(self.Emblem, {notColor=true, alpha=portraitAlpha})
    elseif self.Header then
        WoWTools_TextureMixin:SetFrame(self.Header, {alpha=portraitAlpha})
    end

--DrawLayer
    self:SetDrawLayerEnabled('BACKGROUND', not Save().Add[name].notLayer)

--动画
    Update_Animation(self)
end



--BG, 设置
local function Settings(self)
--单独设置
    if self then
        Set_BGTexture(self)
    else
--统一设置
        for name in pairs(Save().Add) do
            self=_G[name]
            if self then
                Set_BGTexture(self, name)
            end
        end
    end
end















--材质，列表, 菜单
local function texture_list(self, root, name, icon, texture, isAdd)
    local sub
    local isAtlas, textureID, icon2= WoWTools_TextureMixin:IsAtlas(texture, {480, 240})
    if not textureID then
        return
    end

    sub=root:CreateRadio(
        '',
    function()
        return texture== SaveData(name).texture
    end, function()
        if IsEnabledSaveBg(name) then--仅限
            SaveData(name).texture= SaveData(name).texture~=texture and texture or nil
            Settings(self)
        else--统一设置
            SaveData(name).texture= texture
            Settings()
        end
        return MenuResponse.Refresh
    end)

    sub:AddInitializer(function(button)
        local t = button:AttachTexture()
        t:SetSize(248, 64)
        t:SetPoint("RIGHT")
        if isAtlas then
            t:SetAtlas(texture)
        else
            t:SetTexture(texture)
        end
    end)

    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(icon2)
        tooltip:AddLine(texture)
        if IsEnabledSaveBg(name) then
            tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
        else
            GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一设置' or ALL, HIGHLIGHT_FONT_COLOR)
        end
        tooltip:AddLine('Alpha '..Get_Alpha(name, icon))
    end)

    if isAdd then
        sub:CreateButton(
            WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        function()
            StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
            ..'|n|n'..texture:gsub('Interface\\AddOns\\WoWTools\\Source\\Background\\', ''),
            nil,
            {SetValue=function()
                WoWToolsPlayerDate['BGTexture'][texture]= nil
                print(WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, texture)
            end})
            return MenuResponse.Open
        end)
    end
end










--材质，列表
local function Texture_List_Menu(self, root, icon, name)
    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加' or ADD,
    function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND)
        ..'\n\nTexture or Atlas\n',
        nil,
        {
            OnShow=function(s)
                local b1= s.button1 or s:GetButton1()
                local edit= s.editBox or s:GetEditBox()
                b1:SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                edit:SetText('Interface\\AddOns\\WoWTools\\Source\\Background\\')
            end,
            SetValue= function(s)
                local edit= s.editBox or s:GetEditBox()
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(edit:GetText(), 0))
                if textureID then
                    WoWToolsPlayerDate['BGTexture'][textureID]= true
                end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName, textureID)
            end,
            OnAlt=function(s)
                local edit= s.editBox or s:GetEditBox()
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(edit:GetText(), 0))
                WoWToolsPlayerDate['BGTexture'][textureID]= nil
            end,
            EditBoxOnTextChanged=function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s:GetText(), 0))
                local enabled= textureID
                    and textureID:gsub(' ', '')~='' and textureID~='Interface\\AddOns\\WoWTools\\Source\\Background\\'

                local isAdd= WoWToolsPlayerDate['BGTexture'][textureID]
                local isTextureTab= TextureTab[textureID]

                local p= s:GetParent()
                local b1= p:GetButton1()
                local b3= p.button3 or p:GetButton3()
                b1:SetEnabled(enabled and not isAdd and not isTextureTab)
                b3:SetEnabled(enabled and isAdd and not isTextureTab)
            end,
        }
    )
    end)

    local newTab={}

    for texture in pairs(WoWToolsPlayerDate['BGTexture']) do
        table.insert(newTab, texture)
    end
    table.sort(newTab)

    local find
    for _, texture in pairs(newTab) do
        texture_list(self, root, name, icon,  texture, true)
        find=true
    end

--全部清除
    if find then
        WoWTools_MenuMixin:ClearAll(root, function()
            WoWToolsPlayerDate['BGTexture']={}
        end)
    end
    root:CreateDivider()


    newTab={}
    for texture in pairs(TextureTab) do
        table.insert(newTab, texture)
    end
    table.sort(newTab)

    for _, texture in pairs(newTab) do
        texture_list(self, root, name, icon, texture, false)
    end
    WoWTools_MenuMixin:SetScrollMode(root)

end





















--分开设置, 列表
local function Add_Frame_Menu(self, root)
    local sub, sub2
    sub=root:CreateButton(
        '|A:charactercreate-icon-dice:0:0|aFrames',
    function()
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '统一/分开' or 'Unified/Separated')
    end)

    local find
    local newTab={}

    for name, tab in pairs(Save().Add) do
        tab.name= name
        table.insert(newTab, tab)
        find=true
    end

    if not find then
        return
    end



--勾选所有
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL,
    function()
        for name in pairs(Save().Add) do
            Save().Add[name].enabled= true
        end
        Settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(string.format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, ''))
    end)

--撤选所有
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL,
    function()
        for name in pairs(Save().Add) do
            Save().Add[name].enabled= false
        end
        Settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '统一' or ALL)
    end)

--全部清除
    sub:CreateDivider()
    sub2= WoWTools_MenuMixin:ClearAll(sub, function()
        Save().Add={}
        WoWTools_DataMixin:Reload()
    end)

    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)

    sub:CreateDivider()



    local frameName= self:GetName()
    table.sort(newTab, function(a, b)
        if a.enabled and b.enabled then
            return a.name < b.name
        else
            return a.enabled
        end
    end)

    for index, tab in pairs(newTab) do
        local isAtlas, _, icon2= WoWTools_TextureMixin:IsAtlas(tab.texture, {480, 240})
        sub2= sub:CreateCheckbox(
            '|cffff8000'..index..'|r '
            ..(tab.name== frameName and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
            ..tab.name
            ..'|r'
            ..' |cnGREEN_FONT_COLOR:'..(tab.alpha or 0.5),
        function(data)
            return Save().Add[data.name].enabled
        end, function(data)
            local enabled= Save().Add[data.name].enabled

            Save().Add[data.name].enabled= not enabled and true or nil

            if _G[data.name] then
                Settings(_G[data.name])
            end

            return MenuResponse.Refresh
        end, {
            name= tab.name,
            alpha= tab.alpha,
            texture= tab.texture,
            icon2= icon2,
            isAtlas= isAtlas,
        })

        if tab.texture then
            sub2:AddInitializer(function(btn, desc)
                local t = btn:AttachTexture()
                t:SetSize(248, 64)
                t:SetPoint("LEFT", 20, 0)

                local layer, sublayer = btn.fontString:GetDrawLayer()
                t:SetDrawLayer(layer, sublayer+1)

                if desc.data.isAtlas then
                    t:SetAtlas(desc.data.texture)
                else
                    t:SetTexture(desc.data.texture or 0)--RestIcon)
                end
            end)
        end

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.icon2)
            tooltip:AddLine(desc.data.name)
            if IsEnabledSaveBg(desc.data.name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..desc.data.name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一' or ALL, HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine(desc.data.texture)
            tooltip:AddLine('Alpha |cnGREEN_FONT_COLOR:'..(desc.data.alpha or 0.5))
            local label= _G[desc.data.name..'TitleText']
            local text= label and label:GetText()
            if text and text~='' then
               tooltip:AddLine('|cffff00ff'..text)
            end
        end)

        sub2:CreateButton(
            (_G[tab.name] and '' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '显示' or SHOW),
        function(data)
            if _G[data.name] then
                ShowUIPanel(_G[data.name])
            end
            return MenuResponse.Open
        end, {name=tab.name})
    end

    WoWTools_MenuMixin:SetScrollMode(sub)

end





















--BG, 主菜单
local function Init_Menu(self, root, isSub)
    local icon= self[BGName]
    local name= self:GetName()
    local sub, sub2, sub3

    sub= root:CreateCheckbox(
        --'|A:MonkUI-LightOrb:0:0|a'
        WoWTools_DataMixin.Icon.icon2
        ..(WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND),
    function()
        return self:IsDrawLayerEnabled('BACKGROUND')
    end, function()
        local enabled= Save().Add[name].notLayer
        Save().Add[name].notLayer= not enabled and true or nil
        Settings(self)
        if self.backgroundAnims then
            self.backgroundAnims:SetPlaying(enabled or false)
        end
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(name)
        tooltip:AddDoubleLine(
            'IsDrawLayerEnabled("BACKGROUND")',
            WoWTools_TextMixin:GetEnabeleDisable(self:IsDrawLayerEnabled('BACKGROUND'))
        )
    end)

    if not isSub then
        sub= root
    else
        sub:CreateTitle(name)
    end
    sub:CreateSpacer()

--自定义，设置，分开或统一
    sub2= sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '仅限' or string.format(LFG_LIST_CROSS_FACTION, ''),
    function()
        return IsEnabledSaveBg(name)
    end, function()
        Save().Add[name].enabled= not Save().Add[name].enabled and true or nil

        Settings()
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        local textureID, icon2= select(2, WoWTools_TextureMixin:IsAtlas(SaveData(name).texture, {480, 240}))
        tooltip:AddLine(icon2)
        tooltip:AddLine((IsEnabledSaveBg(name) and '|cnGREEN_FONT_COLOR:' or '')..name)
        if textureID then
            tooltip:AddLine(textureID)
        else
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '无' or NONE)--红色
        end
    end)

--材质，列表
    Texture_List_Menu(self, sub2, icon, name)



    sub:CreateSpacer()
--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return  Get_Alpha(name, icon)
        end,
        setValue=function(value)
            SaveData(name).alpha=value
            Settings(IsEnabledSaveBg(name) and self or nil)
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一' or ALL, HIGHLIGHT_FONT_COLOR)
            end
            if not SaveData(name).texture then
                tooltip:AddLine(' ')
                GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '无' or NONE)--红色
            end
        end
    })
    sub:CreateSpacer()

--NineSlice 透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Get_NineSlice_Alpha(name, icon)
        end,
        setValue=function(value)
            SaveData(name).nineSliceAlpha=value
            Settings(IsEnabledSaveBg(name) and self or nil)
        end,
        name= ((self.NineSlice or self.TopBorder or self.Border or self.BorderContainer) and '' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '边框' or EMBLEM_BORDER),
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一' or ALL, HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine('NineSlice')
        end
    })
    sub:CreateSpacer()

--头像
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Get_Portrait_Alpha(name, icon)
        end,
        setValue=function(value)
            SaveData(name).portraitAlpha=value
            Settings(IsEnabledSaveBg(name) and self or nil)
        end,
        name= ((self.PortraitContainer or self.Emblem or self.Header) and '' or '|cff626262')
            ..(WoWTools_DataMixin.onlyChinese and '头像' or 'Portrait'),
        minValue=0,
        maxValue=1,
        step=0.05,
        bit='%.2f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一' or ALL, HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine('PortraitContainer')
        end
    })
    sub:CreateSpacer()

    if self.addMenu then
        self:addMenu(root)
    end

--分开设置, 全部列表
    Add_Frame_Menu(self, sub)
    --sub:CreateSpacer()


--动画
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '动画' or ANIMATION,
    function()
        return not Save().Anims.disabled
    end, function()
        Save().Anims.disabled= not Save().Anims.disabled and true or nil
        Settings()
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
    end)


--透明度
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().Anims.alpha or 0.75
        end,
        setValue=function(value)
            Save().Anims.alpha=value
            Settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_OPACITY,
        minValue=0.1,
        maxValue=1,
        step=0.05,
        bit='%.2f',
    })
    sub2:CreateSpacer()

--速度
    sub2:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub2, {
        getValue=function()
            return Save().Anims.speed or 10
        end,
        setValue=function(value)
            Save().Anims.speed=value
            Settings()
        end,
        name=WoWTools_DataMixin.onlyChinese and '速度' or SPEED,
        minValue=1,
        maxValue=130,
        step=1,
        --bit='%.2f',
    })
    sub2:CreateSpacer()

--打开选项界面
    --sub:CreateSpacer()
    sub2=WoWTools_MenuMixin:OpenOptions(sub, {
        category= WoWTools_TextureMixin.Category,
        name= name,
        name2= WoWTools_TextureMixin.addName,
    })
--Web
    sub3=sub2:CreateButton(
        '|A:QuestLegendary:0:0|aWeb',
    function(data)
        WoWTools_TooltipMixin:Show_URL(nil, nil, nil, data.name)
        return MenuResponse.Open
    end, {name=[[https://www.aconvert.com/]]})
    sub3:SetTooltip(function(tooltip, desc)
        tooltip:AddLine(desc.data.name)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '复制' or CALENDAR_COPY_EVENT)
    end)



--关闭
    sub3= sub2:CreateButton(
        '|A:RedButton-Exit:0:0|a'
        ..(WoWTools_FrameMixin:IsLocked(self) and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '关闭' or CLOSE),
    function()
        HideUIPanel(self)
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(name)
    end)

    sub2:CreateDivider()
--重新加载UI
    WoWTools_MenuMixin:Reload(sub2)
end









































--创建动画组
local function Create_Anims(self, icon, tab)
    if self.AirParticlesFar
        or self.backgroundAnims
        or tab.notAnims
        or Save().Anims.disabled
    then
        return
    end

    local texture= tab.texture
    local atlas= tab.atlas or 'talents-animations-particles'
    local isType2= tab.isType2

    self.AirParticlesFar = self:CreateTexture(nil, 'BACKGROUND', nil, 7)

    if texture then
        self.AirParticlesFar:SetTexture(texture)
    else
        self.AirParticlesFar:SetAtlas(atlas)
    end


    self.AirParticlesFar:SetAllPoints(icon)
    self.AirParticlesFar:SetTexCoord(1, 0, 1, 0)

    -- 设置混合模式为ADD，使粒子效果更亮 DISABLE, BLEND, ALPHAKEY, ADD, MOD
    self.AirParticlesFar:SetBlendMode("ADD")

    if not self.FullMask then
        self.FullMask = self:CreateMaskTexture()
        if isType2 then
            self.FullMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
        else
            self.FullMask:SetAtlas('UI-HUD-CoolDownManager-Mask')--UI-HUD-CoolDownManager-Mask
        end
        self.FullMask:SetPoint('TOPLEFT', icon, -15, 15)
        self.FullMask:SetPoint('BOTTOMRIGHT', icon, 15, -15)
    end
    self.AirParticlesFar:AddMaskTexture(self.FullMask)

    -- 创建动画组
    self.backgroundAnims = self.AirParticlesFar:CreateAnimationGroup()
    self.backgroundAnims:SetLooping("REPEAT") -- 设置循环播放

    -- 透明度变化动画
    self.backgroundAnims.fadeIn = self.backgroundAnims:CreateAnimation("Alpha")
    self.backgroundAnims.fadeIn:SetFromAlpha(0) -- 从透明
    --self.backgroundAnims.fadeIn:SetToAlpha(alpha)   -- 变为不透明
    self.backgroundAnims.fadeIn:SetDuration(0)  -- 持续0秒
    self.backgroundAnims.fadeIn:SetOrder(1)     -- 第一个播放

    -- 创建淡出动画
    self.backgroundAnims.fadeOut = self.backgroundAnims:CreateAnimation("Alpha")
    --self.backgroundAnims.fadeOut:SetFromAlpha(alpha)    -- 从不透明
    self.backgroundAnims.fadeOut:SetToAlpha(0)        -- 变为透明
    self.backgroundAnims.fadeOut:SetDuration(0)       -- 持续0秒
    self.backgroundAnims.fadeOut:SetOrder(2)          -- 第二个播放

    -- 移动动画：从右下角移动到左上角
    self.backgroundAnims.moveAnim = self.backgroundAnims:CreateAnimation("Translation")
    self.backgroundAnims.moveAnim:SetOrder(1)           -- 第一个播放

    -- 重置位置动画：瞬间回到原位
    self.backgroundAnims.resetPos = self.backgroundAnims:CreateAnimation("Translation")
    self.backgroundAnims.resetPos:SetDuration(0)        -- 瞬间完成
    self.backgroundAnims.resetPos:SetOrder(2)           -- 第二个播放


-- 添加事件监听
    self:HookScript("OnSizeChanged", function(frame)
        Update_Animation(frame)
    end)

    self:HookScript("OnShow", function(frame)
        Update_Animation(frame)
        PlayStop_Anims(frame)
    end)

    self:HookScript("OnHide", function(frame)
        frame.backgroundAnims:Stop()
    end)
end









--设置 菜单
--记录 [BGName]
local function Set_Frame_Menu(frame, tab)

    frame.addMenu= tab.addMenu

    if tab.menuTag then
        Menu.ModifyMenu(tab.menuTag, function(_, root)
            Init_Menu(frame, root, true)
        end)
        return
    end


    local self= frame.bgMenuButton or frame.PortraitButton or frame.PortraitContainer or tab.PortraitContainer
    if not self then
        return
    end


    if self==frame.PortraitButton then
        self:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
        self.isRightShowButton=true

    elseif self== frame.PortraitContainer then
        self:SetSize(48,48)
    end


    if frame.PortraitContainer then
        frame.PortraitContainer.CircleMask:SetPoint('TOPLEFT', frame.PortraitContainer.portrait, 'TOPLEFT', 3.5, -3)
        frame.PortraitContainer.CircleMask:SetPoint('BOTTOMRIGHT', frame.PortraitContainer.portrait, 'BOTTOMRIGHT', -3, 3.5)
    end

    function self:set_texture_alpha()
        local t= self.portrait or self.Icon
        if t then
            t:SetAlpha(
                self:IsMouseOver() and 0.5
                or (self.portrait and Get_Portrait_Alpha(frame:GetName(), frame[BGName]))
                or 1
            )
        end
    end

    self:HookScript('OnLeave', function(s)
        GameTooltip:Hide()
        self:set_texture_alpha()
    end)
    self:HookScript('OnEnter', function(s)
        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(s, 'ANCHOR_LEFT')
            GameTooltip:ClearLines()
        else
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddLine(
            WoWTools_TextureMixin.addName..WoWTools_DataMixin.Icon.icon2
            ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
            ..(
                s.isRightShowButton
                and WoWTools_DataMixin.Icon.right
                or WoWTools_DataMixin.Icon.left
            )
        )
        GameTooltip:Show()
        self:set_texture_alpha()
    end)

    self:HookScript('OnMouseDown', function(s, d)
        if d=='RightButton' and s.isRightShowButton or not s.isRightShowButton then
            MenuUtil.CreateContextMenu(s, function(_, root)
                Init_Menu(frame, root, false)
            end)
        end
    end)
end










local function Create_Button(self, tab)
    if not tab.isNewButton then
        return
    end

    local closeButton= self.ClosePanelButton
                    or self.CloseButton
                    or _G[(tab.name or self:GetName())..'CloseButton']

    local p= tab.isNewButton==true and self or tab.isNewButton

    self.bgMenuButton= WoWTools_ButtonMixin:Cbtn(p, {
        size=23,
        name=tab.name..'BGMenuButton',
        texture='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools',
    })
    --self.bgMenuButton.isLeftShowMenu=true

    local icon= self.bgMenuButton:GetNormalTexture()
    icon:ClearAllPoints()
    icon:SetPoint('CENTER')
    icon:SetSize(12,12)
    icon:SetAlpha(tab.newButtonAlpha or 0.5)

    if tab.newButtonPoint then
        tab.newButtonPoint(self.bgMenuButton, self[BGName])

    elseif closeButton then
        self.bgMenuButton:SetPoint('RIGHT', closeButton, 'LEFT')
    end

    if closeButton then
        self.bgMenuButton:SetFrameStrata(closeButton:GetFrameStrata())
        self.bgMenuButton:SetFrameLevel(closeButton:GetFrameLevel()+1)
    end
end















--[[
WoWTools_TextureMixin:Init_BGMenu_Frame(frame, {
    name=名称,
    enabled=true,仅限
    
    alpha=0,--默认alpha
    nineSliceAlpha=tab.nineSliceAlpha,
    portraitAlpha=tab.portraitAlpha,
    
    settings=function(icon, textureName, alphaValue, nineSliceAlpha, portraitAlpha)--设置内容时，调用
    end,

    notAnims=true,
    menuTag='MENU_FCF_TAB',--菜单中，添加子菜单
    addMenu(frame, root),
    PortraitContainer=Frame.PortraitContainer,

    isNewButton=true,
    newButtonAlpha=1,
    newButtonPoint=function(btn)
    end

    bgPoint=function(icon)
    end
})
]]


function WoWTools_TextureMixin:Init_BGMenu_Frame(frame, tab)
    tab= tab or {}

    local name
    if not frame then
        if WoWTools_DataMixin.Player.husandro then
            print(frame, 'Init_BGMenu_Frame',WARNING_FONT_COLOR:WrapTextInColorCode('没发现frame'))
        end
        return

    else
        name= frame:GetName()
        if not name and tab.name then-- and not WoWTools_FrameMixin:IsLocked(frame) then
            if frame then
                function frame:GetName()
                    return tab.name
                end
            end
            name= tab.name

        elseif not name or name=='' then
            return
        end
    end

    self:SetNineSlice(tab.NineSlice or frame)

    tab.name= name

    Save().Add[name]= Save().Add[name] or {
        enabled=tab.enabled,
        texture=tab.texture,
        alpha=tab.alpha,
        notLayer=tab.notLayer,
    }

--创建图片
    frame[BGName]= frame:CreateTexture(nil, 'BACKGROUND', nil, -8)

    if not tab.bgPoint then
        frame[BGName]:SetPoint('TOPLEFT', 3, -3)
        frame[BGName]:SetPoint('BOTTOMRIGHT',-3, 3)
    end
--调用，设置
    if tab.bgPoint then
        tab.bgPoint(frame[BGName])
    end

    --frame:SetTextureSliceMargins(24, 24, 24, 24);
    --fram:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)

    frame[BGName].BgData= {
        alpha= tab.alpha,
        nineSliceAlpha= tab.nineSliceAlpha,
        portraitAlpha=tab.portraitAlpha,
        settings= tab.settings,
    }

--创建动画组
    Create_Anims(frame, frame[BGName], tab)
--创建，菜单按钮
    Create_Button(frame, tab)
--设置，调用，菜单
    Set_Frame_Menu(frame, tab)
--BG, 设置
    Settings(frame)
end






function WoWTools_TextureMixin:Get_BGName()
    return BGName
end