local function Save()
    return WoWToolsSave['Plus_Texture']
end



local function SaveBG(name)
    if WoWToolsSave['Plus_Texture'].Bg.Add[name].enabled then
        return WoWToolsSave['Plus_Texture'].Bg.Add[name]--分开设置
    else
        return WoWToolsSave['Plus_Texture'].Bg.All--统一设置
    end
end

local function IsEnabledSaveBg(name)
    return WoWToolsSave['Plus_Texture'].Bg.Add[name].enabled
end

local Icons={}


local TextureTab={--TalentArt
['Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga']=1,
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




local function set_texture(icon, texture, alpha)
    if texture then
        if C_Texture.GetAtlasInfo(texture) then
            icon:SetAtlas(texture)
        else
            icon:SetTexture(texture)
        end
        icon:SetVertexColor(1,1,1,1)
    end
    icon:SetAlpha(alpha)
    icon:SetShown(true)
end

local function Set_BGTexture(icon)
    local name= icon.BgData.name
    local data= SaveBG(name)

    local alpha= data.alpha or 0.5
    local texture= data.texture

    set_texture(icon, texture, alpha)

    if icon.BgData.icons then
        for _, bg in pairs(icon.BgData.icons) do
            set_texture(bg, texture, alpha)
        end
    end
end









--BG, 设置
local function Settings(icon)
    local name= icon.BgData.name
    local texture= SaveBG(name).texture

    local alpha= SaveBG(name).alpha or icon.BgData.alpha or 0.5

--设置
    Set_BGTexture(icon)

    if not IsEnabledSaveBg(name) then
        for bg in pairs(Icons) do
            if bg~=icon then
                Set_BGTexture(bg)
            end
        end
    end

    if icon.BgData.settings then
        icon.BgData.settings(texture, alpha)
    end
end










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
            else--统一设置
                SaveBG(name).texture= texture
            end

            Settings(icon)

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
            tooltip:AddLine(' ')
            if IsEnabledSaveBg(name) then
                GameTooltip_AddColoredLine(tooltip, string.format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, name), HIGHLIGHT_FONT_COLOR)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一设置' or ALL, HIGHLIGHT_FONT_COLOR)
                --GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
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

    return sub
end































--BG, 菜单
local function Init_Menu(frame, root)
    local name= frame.bg_Texture.BgData.name
    local icon= frame.bg_Texture


    local sub, sub2, sub3
--背景
    sub= root:CreateButton(
        '|A:MonkUI-LightOrb:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '背景' or BACKGROUND),
    function()
        return MenuResponse.Open
    end)

--自定义
    sub2= sub:CreateCheckbox(
        string.format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, name),
    function()
        return IsEnabledSaveBg(name)
    end, function()
        WoWToolsSave['Plus_Texture'].Bg.Add[name].enabled= not WoWToolsSave['Plus_Texture'].Bg.Add[name].enabled and true or nil
        Icons[icon]= not IsEnabledSaveBg(name) and true or nil
            
        Settings(icon)
    end)

    sub2:SetTooltip(function(tooltip)
        local textureID, icon2= select(2, WoWTools_TextureMixin:IsAtlas(SaveBG(name).texture, {480, 240}))
        if textureID then
            tooltip:AddLine(icon2)
            tooltip:AddLine(textureID)
        end
    end)



--材质，列表
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

    local num=0
    for texture in pairs(Save().Bg.UseTexture or {}) do
        texture_list(sub2, name, icon,  texture, true)
        num=num+1
    end

--全部清除
    if num>0 then
        WoWTools_MenuMixin:ClearAll(sub2, function()
            Save().Bg.UseTexture={}
        end)
    end
    sub2:CreateDivider()

    for texture in pairs(TextureTab) do
        texture_list(sub2, name, icon, texture, false)
    end
    WoWTools_MenuMixin:SetScrollMode(sub2)






    sub:CreateSpacer()
--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return SaveBG(name).alpha or 0.5
        end,
        setValue=function(value)
            SaveBG(name).alpha=value
            Settings(icon)
            if icon.BgData.setValueFunc then
                icon.BgData.setValueFunc(SaveBG(name).texture, value)
            end
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%.1f',
        tooltip=function(tooltip)
            if IsEnabledSaveBg(name) then
                GameTooltip_AddColoredLine(tooltip, string.format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, name), HIGHLIGHT_FONT_COLOR)
            else
                GameTooltip_AddColoredLine(tooltip, WoWTools_DataMixin.onlyChinese and '统一设置' or ALL, HIGHLIGHT_FONT_COLOR)
                --GameTooltip_AddInstructionLine(tooltip, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end
    })
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




















--创建动画组
local function Create_Anims(frame, tab)
    if frame.AirParticlesFar or frame.backgroundAnims or tab.notAnims then
        return
    end

-- AirParticlesFar 粒子动画

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
    frame.AirParticlesFar:SetBlendMode("ADD")

    if not frame.FullMask then
        frame.FullMask = frame:CreateMaskTexture()
        if isType2 then
            frame.FullMask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask', "CLAMPTOBLACKADDITIVE" , "CLAMPTOBLACKADDITIVE")--ItemButtonTemplate.xml
        else
            frame.FullMask:SetAtlas('UI-HUD-CoolDownManager-Mask')
        end
        frame.FullMask:SetPoint('TOPLEFT', -25, 25)
        frame.FullMask:SetPoint('BOTTOMRIGHT', 25, -25)
    end
    frame.AirParticlesFar:AddMaskTexture(frame.FullMask)

    -- 创建动画组
    frame.backgroundAnims = frame.AirParticlesFar:CreateAnimationGroup()
    frame.backgroundAnims:SetLooping("REPEAT")


    -- Alpha 淡入
    local alphaIn = frame.backgroundAnims:CreateAnimation("Alpha", nil, 'TargetsVisibleWhilePlayingAnimGroupTemplate')
    alphaIn:SetOrder(2)
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(0.7)
    alphaIn:SetDuration(5)
    alphaIn:SetSmoothing("IN")

    -- Alpha 淡出
    local alphaOut = frame.backgroundAnims:CreateAnimation("Alpha", nil, 'TargetsVisibleWhilePlayingAnimGroupTemplate')
    alphaOut:SetOrder(2)
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)
    alphaOut:SetStartDelay(22)
    alphaOut:SetDuration(5)
    alphaOut:SetSmoothing("OUT")

    -- 平移动画1
    local trans1 = frame.backgroundAnims:CreateAnimation("Translation", nil, 'TargetsVisibleWhilePlayingAnimGroupTemplate')
    trans1:SetOrder(1)
    trans1:SetOffset(300, 0)
    trans1:SetDuration(0)

    -- 平移动画2
    local trans2 = frame.backgroundAnims:CreateAnimation("Translation", nil, 'TargetsVisibleWhilePlayingAnimGroupTemplate')
    trans2:SetOrder(2)
    trans2:SetOffset(-600, 0)
    trans2:SetStartDelay(0)
    trans2:SetDuration(27)--27

    -- 平移动画3
    local trans3 = frame.backgroundAnims:CreateAnimation("Translation", nil, 'TargetsVisibleWhilePlayingAnimGroupTemplate')
    trans3:SetOrder(3)
    trans3:SetOffset(600, 0)
    trans3:SetStartDelay(0)
    trans3:SetDuration(0)

    -- 旋转动画
    local rotate = frame.backgroundAnims:CreateAnimation("Rotation", nil, 'TargetsVisibleWhilePlayingAnimGroupTemplate')
    rotate:SetOrder(3)
    rotate:SetDegrees(20)
    rotate:SetDuration(27)



-- 显示时播放动画，隐藏时停止动画
    if frame:IsVisible() then
        frame.backgroundAnims:Play()
    end

    frame:HookScript("OnShow", function(f)
        if not f.backgroundAnims:IsPlaying() then
            f.backgroundAnims:Play()
        end
    end)
    frame:HookScript("OnHide", function(f)
        if f.backgroundAnims:IsPlaying() then
            f.backgroundAnims:Stop()
        end
    end)
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
    isAddBg=true,--是否添加背景
    bgPoint=function(icon)--设置背景位置
    end,
    notAnims=true
    }
)
]]









function WoWTools_TextureMixin:Init_BGMenu_Frame(frame, name, icon, tab)

    if Save().disabled
        or not frame
        or not name
        or (not icon and not tab.isAddBg)
    then
        return
    end

    

    tab= tab or {}

    if not WoWToolsSave['Plus_Texture'].Bg.Add[name] then
        WoWToolsSave['Plus_Texture'].Bg.Add[name]={}
    end

    if tab.isAddBg then
        if not frame.Add_Background then
            frame.Add_Background= frame:CreateTexture(nil, 'BACKGROUND', nil, 2)
            if tab.bgPoint then
                tab.bgPoint(frame.Add_Background)
            else
                frame.Add_Background:SetPoint('TOPLEFT', 3, -3)
                frame.Add_Background:SetPoint('BOTTOMRIGHT',-3, 3)
            end
            --frame.Add_Background:SetAtlas('Tooltip-Glues-NineSlice-Center')
        end
        icon= frame.Add_Background
    end

    icon:SetTextureSliceMargins(24, 24, 24, 24);
    icon:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)

    if not IsEnabledSaveBg(name) then
        Icons[icon]=true
    end

    icon.BgData= {
        name= name,
        alpha= tab.alpha,
        icons= tab.icons,
        settings= tab.settings,
        setValueFunc= tab.setValueFunc,
    }

    if tab.isHook then
        icon.Set_BGTexture= Set_BGTexture
    end

--创建动画组
    Create_Anims(frame, tab)

    Settings(icon)


    if frame.PortraitContainer then
        frame.PortraitContainer:SetSize(48,48)
        frame.PortraitContainer:HookScript('OnLeave', function(s)
            GameTooltip:Hide()
            s.portrait:SetAlpha(1)
        end)
        frame.PortraitContainer:HookScript('OnEnter', function(s)
            GameTooltip:SetOwner(s)
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(
                WoWTools_DataMixin.Icon.icon2..self.addName,
                (WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)..WoWTools_DataMixin.Icon.right
            )
            GameTooltip:Show()
            s.portrait:SetAlpha(0.7)
        end)
        frame.PortraitContainer:HookScript('OnMouseDown', function(s, d)
            if d~='RightButton' then
                return
            end

            MenuUtil.CreateContextMenu(s, Init_Menu)

            s.portrait:SetAlpha(0.3)
        end)
        frame.PortraitContainer:HookScript('OnMouseUp', function(s)
            s.portrait:SetAlpha(0.7)
        end)
        frame.PortraitContainer.bg_Texture= icon
    end
end