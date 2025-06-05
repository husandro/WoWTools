local function Save()
    return WoWToolsSave['Plus_Texture']
end



local function SaveBG(name)
    if Save().Bg.Add[name].enabled then
        return Save().Bg.Add[name]--分开设置
    else
        return Save().Bg.All--统一设置
    end
end

local function IsEnabledSaveBg(name)
    return Save().Bg.Add[name].enabled
end


local RestIcon= 'Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga'





local TextureTab={
[RestIcon]=1,
['Interface\\AddOns\\WoWTools\\Source\\Background\\White.tga']=1,

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
}



local Icons={}
--从 Icons 添加 或 移除
local function Remove_Add_Icons(icon, enabled)
    enabled= enabled==true and true or nil
    Icons[icon]= enabled
    if icon.BgData and icon.BgData.icons then
        for _, bg in pairs(icon.BgData.icons) do
            Icons[bg]=enabled
        end
    end
end



local function set_texture(icon, texture, alpha)
    if C_Texture.GetAtlasInfo(texture) then
        icon:SetAtlas(texture)
    else
        icon:SetTexture(texture)
    end
    icon:SetVertexColor(1,1,1)
    icon:SetAlpha(alpha)
    icon:SetShown(true)
end

local function Set_BGTexture(icon)
    if not icon or not icon.BgData then
        return
    end

    local name= icon.BgData.name
    local data= SaveBG(name)

    local alpha= data.alpha or 0.5
    local texture= data.texture or icon.p_texture or RestIcon

    set_texture(icon, texture, alpha)

    if icon.BgData.icons then
        for _, bg in pairs(icon.BgData.icons) do
            set_texture(bg, texture, alpha)
        end
    end
end






--BG, 设置
local function Settings(icon, frame)
    icon= frame and frame.bg_Texture or icon

--单独设置
    if icon then
        Set_BGTexture(icon)

        if icon.BgData.settings then
            local name= icon.BgData.name
            local alpha= SaveBG(name).alpha or icon.BgData.alpha or 0.5
            icon.BgData.settings(SaveBG(name).texture, alpha)
        end
    else
--统一设置
        for bg in pairs(Icons) do
            Set_BGTexture(bg)
        end
    end
end















--材质，列表, 菜单
local function texture_list(root, name, icon, texture, isAdd)
    local sub
    local isAtlas, textureID, icon2= WoWTools_TextureMixin:IsAtlas(texture, {480, 240})
    if not textureID then
        return
    end

    sub=root:CreateRadio(
        '',
    function()
        return texture== SaveBG(name).texture
    end, function()
        if IsEnabledSaveBg(name) then--仅限
            SaveBG(name).texture= SaveBG(name).texture~=texture and texture or nil
            Settings(icon)
        else--统一设置
            SaveBG(name).texture= texture
            Settings()
        end

        if icon.BgData.setValueFunc then
            icon.BgData.setValueFunc(SaveBG(name).texture, SaveBG(name).alpha or 0.5)
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
        tooltip:AddLine('Alpha '..(SaveBG(name).alpha or 0.5))
    end)

    if isAdd then
        sub:CreateButton(
            WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
        function()
            StaticPopup_Show('WoWTools_OK',
            WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            nil,
            {SetValue=function()
                Save().Bg.UseTexture[texture]= nil
            end})
            return MenuResponse.Open
        end)
    end
end










--材质，列表
local function Texture_List_Menu(root, icon, name)
    root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '添加' or ADD,
    function()
        StaticPopup_Show('WoWTools_EditText',
        (WoWTools_DataMixin.onlyChinese and '显示背景' or HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND)
        ..'\n\nTexture or Atlas\n',
        nil,
        {
            OnShow=function(s)
                s.button1:SetText(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
                s.editBox:SetText('Interface\\AddOns\\WoWTools\\Source\\Background\\')
            end,
            SetValue= function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s.editBox:GetText(), 0))
                if textureID then
                    Save().Bg.UseTexture[textureID]= true
                end
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName, textureID)
            end,
            OnAlt=function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s.editBox:GetText(), 0))
                Save().Bg.UseTexture[textureID]= nil
            end,
            EditBoxOnTextChanged=function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s:GetText(), 0))
                local enabled= textureID
                    and textureID:gsub(' ', '')~='' and textureID~='Interface\\AddOns\\WoWTools\\Source\\Background\\'

                local isAdd= Save().Bg.UseTexture[textureID]
                local isTextureTab= TextureTab[textureID]

                s:GetParent().button1:SetEnabled(enabled and not isAdd and not isTextureTab)
                s:GetParent().button3:SetEnabled(enabled and isAdd and not isTextureTab)
            end,
        }
    )
    end)

    --[[local newTab={}

    for texture in pairs(Save().Bg.UseTexture or {}) do
        table.insert(newTab, texture)
    end]]

    local find
    for texture in pairs(Save().Bg.UseTexture or {}) do
        texture_list(root, name, icon,  texture, true)
        find=true
    end

--全部清除
    if find then
        WoWTools_MenuMixin:ClearAll(root, function()
            Save().Bg.UseTexture={}
        end)
    end
    root:CreateDivider()

    for texture in pairs(TextureTab) do
        texture_list(root, name, icon, texture, false)
    end
    WoWTools_MenuMixin:SetScrollMode(root)

end


















local function Add_Settings(name, enabled)
    local icon= _G[name] and _G[name].bg_Texture
    if icon then
        Remove_Add_Icons(icon, enabled)--从 Icons 添加 或 移除
        Settings(icon)
    end
end





--分开设置, 列表
local function Add_Frame_Menu(_, root)
    local sub, sub2
    sub=root:CreateButton(
        '|A:charactercreate-icon-dice:0:0|aFrames',
        --..(WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM),
    function()
        return MenuResponse.Open
    end)

    local find
    local newTab={}

    for name, tab in pairs(Save().Bg.Add) do
        tab.name= name
        table.insert(newTab, tab)
        find=true
    end

    if not find then
        return
    end

    table.sort(newTab, function(a, b) return a.name < b.name end)




    for index, tab in pairs(newTab) do
        local isAtlas, textureID, icon2= WoWTools_TextureMixin:IsAtlas(tab.texture, {480, 240})
        sub2= sub:CreateCheckbox(
            '|cffff8000'..index..'|r '
            ..tab.name
            ..' |cnGREEN_FONT_COLOR:'..(tab.alpha or 0.5),
        function(data)
            return Save().Bg.Add[data.name].enabled
        end, function(data)
            local enabled= Save().Bg.Add[data.name].enabled

            Save().Bg.Add[data.name].enabled= not enabled and true or nil
            Add_Settings(data.name, not enabled)

            return MenuResponse.Refresh
        end, {
            name=tab.name,
            alpha=tab.alpha,
            texture=tab.texture,
            icon2=icon2,
        })

        sub2:AddInitializer(function(button)
            local t = button:AttachTexture()
            t:SetSize(248, 64)
            t:SetPoint("LEFT", 20, 0)
            if isAtlas then
                t:SetAtlas(textureID)
            else
                t:SetTexture(textureID or RestIcon)
            end
        end)

        sub2:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.icon2)
            tooltip:AddLine(desc.data.name)
            if IsEnabledSaveBg(desc.data.name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..desc.data.name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一' or ALL, HIGHLIGHT_FONT_COLOR)
            end
            tooltip:AddLine(desc.data.texture)
            tooltip:AddLine('Alpha '..(desc.data.alpha or 0.5))
        end)
    end

    WoWTools_MenuMixin:SetScrollMode(sub)

    sub:CreateDivider()
--勾选所有
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '勾选所有' or CHECK_ALL,
    function()
        for name in pairs(Save().Bg.Add) do
            Save().Bg.Add[name].enabled= true
            Add_Settings(name, true)
        end
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(string.format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, ''))
    end)

--撤选所有
    sub2=sub:CreateButton(
        WoWTools_DataMixin.onlyChinese and '撤选所有' or UNCHECK_ALL,
    function()
        for name in pairs(Save().Bg.Add) do
            Save().Bg.Add[name].enabled= false
            Add_Settings(name, false)
        end
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '统一' or ALL)
    end)

--全部清除
    sub:CreateDivider()
    sub2= WoWTools_MenuMixin:ClearAll(sub, function()
        for f in pairs(Save().Bg.Add) do
            f=_G[f]
            if f and f.bg_Texture then
                Remove_Add_Icons(f.bg_Texture, nil)--从 Icons 添加 或 移除
            end
        end
        Save().Bg.Add={}
        WoWTools_Mixin:Reload()
    end)

    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
    end)
end





















--BG, 主菜单
local function Init_Menu(frame, root, isSub)
    local name= frame.bg_Texture.BgData.name
    local icon= frame.bg_Texture


    local sub, sub2, sub3

    if isSub then
    --背景
        sub= root:CreateButton(
            '|A:MonkUI-LightOrb:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '背景' or BACKGROUND),
        function()
            return MenuResponse.Open
        end)
    else
        root:CreateTitle('|A:MonkUI-LightOrb:0:0|a'..(WoWTools_DataMixin.onlyChinese and '背景' or BACKGROUND))
        sub=root
    end



--自定义，设置，分开或统一
    sub2= sub:CreateCheckbox(
        string.format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, ''),
    function()
        return IsEnabledSaveBg(name)
    end, function()
        Save().Bg.Add[name].enabled= not Save().Bg.Add[name].enabled and true or nil

        local enabled= not IsEnabledSaveBg(name) and true or nil

        Remove_Add_Icons(icon, enabled)--从 Icons 添加 或 移除
        Settings(icon)
        return MenuResponse.Refresh
    end)
    sub2:SetTooltip(function(tooltip)
        local textureID, icon2= select(2, WoWTools_TextureMixin:IsAtlas(SaveBG(name).texture, {480, 240}))
        tooltip:AddLine(icon2)
        tooltip:AddLine((IsEnabledSaveBg(name) and '|cnGREEN_FONT_COLOR:' or '')..name)
        if textureID then
            tooltip:AddLine(textureID)
        else
            GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '无' or NONE)--红色
        end
    end)

--材质，列表
    Texture_List_Menu(sub2, icon, name)



    sub:CreateSpacer()
--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return SaveBG(name).alpha or 0.5
        end,
        setValue=function(value)
            SaveBG(name).alpha=value
            Settings(IsEnabledSaveBg(name) and icon or nil)
            if icon.BgData.setValueFunc then
                icon.BgData.setValueFunc(SaveBG(name).texture, SaveBG(name).alpha or 0.5)
            end
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                tooltip:AddLine('|cnGREEN_FONT_COLOR:'..name)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一' or ALL, HIGHLIGHT_FONT_COLOR)
            end
            if not SaveBG(name).texture then
                tooltip:AddLine(' ')
                GameTooltip_AddErrorLine(tooltip, WoWTools_DataMixin.onlyChinese and '无' or NONE)--红色
            end
        end
    })
    sub:CreateSpacer()

--分开设置, 列表
    Add_Frame_Menu(frame, root)
    sub:CreateSpacer()

--打开选项界面
    sub2=WoWTools_MenuMixin:OpenOptions(sub, {name=WoWTools_TextureMixin.addName, category=WoWTools_TextureMixin.Category})
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




--重新加载UI
    sub2:CreateDivider()
    WoWTools_MenuMixin:Reload(sub2)

end


























-- 根据框架大小更新动画偏移量和速度的函数
local function UpdateAnimationOffsets(self)
    local width, height = self:GetSize()
    -- 动画从右下角到左上角
    local xOffset = -width
    local yOffset = height


    self.backgroundAnims.moveAnim:SetOffset(xOffset, yOffset )    -- 右下到左上
    self.backgroundAnims.resetPos:SetOffset(-xOffset, -yOffset)  -- 回到右下

    -- 根据对角线长度设置动画持续时间，保证速度一致
    local distance = math.sqrt(xOffset * xOffset + yOffset * yOffset)
    local speed = 10 -- 像素每秒，可根据需要调整
    local duration = distance / speed
    self.backgroundAnims.moveAnim:SetDuration(duration)
end














--创建动画组
local function Create_Anims(frame, tab)
    if frame.AirParticlesFar or frame.backgroundAnims or tab.notAnims then
        return
    end

    local texture= tab.texture
    local atlas= tab.atlas or 'talents-animations-particles'
    local isType2= tab.isType2

    frame.AirParticlesFar = frame:CreateTexture(nil, 'BACKGROUND', nil, 7)

    if texture then
        frame.AirParticlesFar:SetTexture(texture)
    else
        frame.AirParticlesFar:SetAtlas(atlas)
    end
    frame.AirParticlesFar:SetAllPoints()
    frame.AirParticlesFar:SetTexCoord(1, 0, 1, 0)
    -- 设置混合模式为ADD，使粒子效果更亮 DISABLE, BLEND, ALPHAKEY, ADD, MOD
    frame.AirParticlesFar:SetBlendMode("ADD")

    if not frame.FullMask then
        frame.FullMask = frame:CreateMaskTexture()
        if isType2 then
            frame.FullMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
        else
            frame.FullMask:SetAtlas('UI-HUD-CoolDownManager-Mask')--UI-HUD-CoolDownManager-Mask
        end
        frame.FullMask:SetPoint('TOPLEFT', -15, 15)
        frame.FullMask:SetPoint('BOTTOMRIGHT', 15, -15)
    end
    frame.AirParticlesFar:AddMaskTexture(frame.FullMask)

    -- 创建动画组
    frame.backgroundAnims = frame.AirParticlesFar:CreateAnimationGroup()
    frame.backgroundAnims:SetLooping("REPEAT") -- 设置循环播放


    local alpha = 0.75

    -- 透明度变化动画
    local fadeIn = frame.backgroundAnims:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0) -- 从透明
    fadeIn:SetToAlpha(alpha)   -- 变为不透明
    fadeIn:SetDuration(0)  -- 持续0秒
    fadeIn:SetOrder(1)     -- 第一个播放

    -- 创建淡出动画
    local fadeOut = frame.backgroundAnims:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(alpha)    -- 从不透明
    fadeOut:SetToAlpha(0)        -- 变为透明
    fadeOut:SetDuration(0)       -- 持续0秒
    fadeOut:SetOrder(2)          -- 第二个播放

    -- 移动动画：从右下角移动到左上角
    frame.backgroundAnims.moveAnim = frame.backgroundAnims:CreateAnimation("Translation")
    frame.backgroundAnims.moveAnim:SetOrder(1)           -- 第一个播放

    -- 重置位置动画：瞬间回到原位
    frame.backgroundAnims.resetPos = frame.backgroundAnims:CreateAnimation("Translation")
    frame.backgroundAnims.resetPos:SetDuration(0)        -- 瞬间完成
    frame.backgroundAnims.resetPos:SetOrder(2)           -- 第二个播放

    UpdateAnimationOffsets(frame)
    frame.backgroundAnims:SetPlaying(frame:IsVisible())

    -- 添加事件监听
    frame:HookScript("OnSizeChanged", function(self)
        UpdateAnimationOffsets(self)
        self.backgroundAnims:SetPlaying(true)
    end)

    frame.AirParticlesFar:SetScript("OnShow", function(self)
        self:GetParent().backgroundAnims:SetPlaying(true)
    end)

    frame.AirParticlesFar:SetScript("OnHide", function(self)
         self:GetParent().backgroundAnims:SetPlaying(false)
    end)
end











local function Set_Frame_Menu(frame, icon, tab)
    local self= frame.bgMenuButton or frame.PortraitButton or frame.PortraitContainer or tab.PortraitContainer
    if not self then
        return
    end

    if self== frame.PortraitContainer then
        self:SetSize(48,48)
    end

    function self:set_texture_alpha()
        local t= self.portrait or self.Icon
        if not t then
            return
        end
        t:SetAlpha(GameTooltip:IsOwned(self) and 0.5 or 1)
    end

    self:HookScript('OnLeave', function(s)
        GameTooltip:Hide()
        self:set_texture_alpha()
    end)
    self:HookScript('OnEnter', function(s)
        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(s)
            GameTooltip:ClearLines()
        else
            GameTooltip:AddLine(' ')
        end
        GameTooltip:AddDoubleLine(
            WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName,
            (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()
        self:set_texture_alpha()
    end)
    self:HookScript('OnMouseDown', function(s, d)
        if d=='RightButton' then
            MenuUtil.CreateContextMenu(s, function(_, root)
                Init_Menu(s, root, false)
            end)
        end
    end)

    self.bg_Texture= icon
    frame.bg_Texture= icon
end










local function Create_Button(frame, tab)
    if not tab.isNewButton then
        return
    end

    local closeButton= frame.ClosePanelButton or frame.CloseButton

    local p= tab.isNewButton==true and (closeButton or frame) or tab.isNewButton

    frame.bgMenuButton= WoWTools_ButtonMixin:Cbtn(p, {
        size=23,
        name=tab.name..'BGMenuButton',
        texture='Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools',
    })

    local icon= frame.bgMenuButton:GetNormalTexture()
    icon:ClearAllPoints()
    icon:SetPoint('CENTER')
    icon:SetSize(16,16)
    icon:SetAlpha(0.5)

    if tab.newButtonPoint then
        tab.newButtonPoint(frame.bgMenuButton)
    elseif closeButton then
        frame.bgMenuButton:SetPoint('RIGHT', closeButton, 'LEFT')
    end

    if closeButton then
        frame.bgMenuButton:SetFrameStrata(closeButton:GetFrameStrata())
        frame.bgMenuButton:SetFrameLevel(closeButton:GetFrameLevel()+1)
    end
end









local function Get_Icon_Texture(icon)
    if icon.GetAtlas then
        return icon:GetAtlas()
    elseif icon.GetTextureFileID then
        return icon:GetTextureFileID()
    end
end


local function Create_Background(frame, icon, tab)
    if not icon then
        if frame.Background then
            frame.Background:ClearAllPoints()
            frame.Background:SetPoint('TOPLEFT', 3, -3)
            frame.Background:SetPoint('BOTTOMRIGHT',-3, 3)
            frame.Background.p_texture= Get_Icon_Texture(frame.Background)
        else
            frame.Background= frame:CreateTexture(nil, 'BACKGROUND', nil, -8)-- -8 7
            frame.Background:SetPoint('TOPLEFT', 3, -3)
            frame.Background:SetPoint('BOTTOMRIGHT',-3, 3)
        end
    else

        icon.p_texture= Get_Icon_Texture(icon)

        for _, t in pairs(tab.icons or {}) do
            t.p_texture= Get_Icon_Texture(t)
        end
    end
    return icon or frame.Background
end












--[[
WoWTools_TextureMixin:Init_BGMenu_Frame(
    frame,--框架, frame.PortraitContainer
    name,--名称
    icon,--Texture
    {
    icons={},--Textures,是否修改其它图片 {icon1, icon2, ...}
    setValueFunc=function(textureName, alphaValue)--当菜单修改时，调用
    end,
    settings=function(textureName, alphaValue)--设置内容时，调用
    end,
    isHook=true,--是否Hook icon.Set_BGTexture= Set_BGTexture
    
    notAnims=true,
    PortraitContainer=Frame.PortraitContainer,

    isNewButton=true,
    newButtonPoint=function(btn)
    end
    }
)
]]


function WoWTools_TextureMixin:Init_BGMenu_Frame(frame, icon, tab)
    if Save().disabled
        or not frame
    then
        return
    end

    tab= tab or {}

    local name= tab.name or frame:GetName()
    if not name or name=='' then
        return
    end

    Save().Bg.Add[name]= Save().Bg.Add[name] or {}

    tab.name= name

    icon= Create_Background(frame, icon, tab)

    --icon:SetTextureSliceMargins(24, 24, 24, 24);
    --icon:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)

    icon.BgData= {
        name= name,
        alpha= tab.alpha,
        icons= tab.icons,
        settings= tab.settings,
        setValueFunc= tab.setValueFunc,
    }

     if not IsEnabledSaveBg(name) then--从 Icons 添加 或 移除
        Remove_Add_Icons(icon, true)
    end

    if tab.isHook then
        icon.Set_BGTexture= Set_BGTexture
    end

--创建动画组
    Create_Anims(frame, tab)
--BG, 设置
    Settings(icon)
--创建，菜单按钮
    Create_Button(frame, tab)
--设置，调用，菜单
    Set_Frame_Menu(frame, icon, tab)
end