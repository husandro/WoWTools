local function Save()
    return WoWToolsSave['Plus_Texture'].BG or {}
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
--['Interface\\AddOns\\WoWTools\\Source\\Background\\Black.tga']=true,

}








local function texture_list(root, name, icon, tab, texture, isAdd)

        local sub
        local isAtlas, textureID, icon2= WoWTools_TextureMixin:IsAtlas(texture, {480, 240})
        if not textureID then
            return
        end

        local descData= {
            name= name,
            icon= icon,
            tab= tab,
            texture= texture,

            isAtlas= isAtlas,
            icon2= icon2,
        }

        sub=root:CreateCheckbox(
            '',
        function(data)
            return data.texture== Save()[data.name].texture
        end, function(data)
            if Save()[data.name].texture==data.texture then
                Save()[data.name].texture= nil
            else
                Save()[data.name].texture= data.texture
            end

            WoWTools_TextureMixin:SetBG_Settings(data.name, data.icon, tab)
            if tab.setFunc then
                tab.setFunc(Save()[name].texture, Save()[name].alpha)
            end
        end, descData)

        sub:AddInitializer(function(button, desc)
            local t = button:AttachTexture();
            t:SetSize(248, 64)
            t:SetPoint("RIGHT")
            if desc.data.isAtlas then
                t:SetAtlas(desc.data.texture)
            else
                t:SetTexture(desc.data.texture)
            end
        end)

        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(desc.data.icon2)
            tooltip:AddLine(desc.data.name)
            tooltip:AddLine(desc.data.texture)
        end)

        if isAdd then
            sub:CreateButton(
                WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            function(data)
                StaticPopup_Show('WoWTools_OK',
                WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
                nil,
                {SetValue=function()
                    Save().ADD[data.texture]= nil
                end})
                return MenuResponse.Open
            end, descData)
        end

    return sub
end













local function set_texture(self, texture, alpha)
    if not self then
        return
    end
    alpha= alpha or 0.3
    if texture then
        if C_Texture.GetAtlasInfo(texture) then
            self:SetAtlas(texture)
        else
            self:SetTexture(texture)
        end
        self:SetVertexColor(1,1,1,1)
        self:SetAlpha(alpha)
    else
        WoWTools_TextureMixin:SetAlphaColor(self, nil, nil, alpha)
    end
    self:SetShown(true)
end

local function Set_BGTexture(self)
    if not self then
        return
    end

    local alpha= self.set_BGData.alpha
    local texture= self.set_BGData.texture

    set_texture(self, texture, alpha)

    if self.set_BGData.tab.icons then
        for _, bg in pairs(self.set_BGData.tab.icons) do
            set_texture(bg, texture, alpha)
        end
    end
end








--BG, 设置
function WoWTools_TextureMixin:SetBG_Settings(name, icon, tab)
    if not icon or WoWToolsSave['Plus_Texture'].disabled then
        return
    end

    Save()[name]= Save()[name] or {}
    tab= tab or {}
    local texture= Save()[name].texture

    local isInitial= not icon.set_BGData

    icon.set_BGData= {
        texture= texture,
        alpha= Save()[name].alpha or self.min or 0.3,

        p_texture= icon.set_BGData and icon.set_BGData.p_texture or icon:GetAtlas() or icon:GetTextureFileID(),
        tab=tab,--icons= tab.icons,
        name= name,
        icon= icon,
    }

--初始
    if isInitial then
--初始，禁用时，退出
        if not texture then
--仅设置 alpha
            Set_BGTexture(icon)
            return
        end
--Hook
        if tab.isHook then
            icon.Set_BGTexture= Set_BGTexture
        end
    end

--数据
    if not texture then
        icon.set_BGData.texture= icon.set_BGData.p_texture
    end

--设置
    do
        Set_BGTexture(icon)
    end

    if not texture then
        icon.set_BGData.texture= nil
    end
end













--BG, 菜单
function WoWTools_TextureMixin:BGMenu(root, name, icon, tab)
    if WoWToolsSave['Plus_Texture'].disabled or Save().disabled or not icon or not name then
        return
    end
    Save()[name]= Save()[name] or {}
    tab= tab or {}

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
        WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM,
    function()
        return Save()[name].texture
    end, function(data)
        Save()[name].texture= not Save()[name].texture and data.texture or nil

        self:SetBG_Settings(name, icon, tab)

    end, {texture=Save()[name].texture})

    sub2:SetTooltip(function(tooltip, desc)
        local textureID, icon2= select(2, WoWTools_TextureMixin:IsAtlas(Save()[name].texture or desc.data.texture, {480, 240}))
        if textureID then
            textureID= textureID:match('.+\\(.+)') or textureID
            tooltip:AddLine(icon2)
            tooltip:AddLine(textureID)
            --tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2 )
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
                    Save().ADD[textureID]= true
                end
                print(WoWTools_DataMixin.Icon.icon2..self.addName, textureID)
            end,
            OnAlt=function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s.editBox:GetText(), 0))
                Save().ADD[textureID]= nil
            end,
            EditBoxOnTextChanged=function(s)
                local textureID= select(2, WoWTools_TextureMixin:IsAtlas(s:GetText(), 0))
                local enabled= textureID
                    and textureID:gsub(' ', '')~='' and textureID~='Interface\\AddOns\\WoWTools\\Source\\Background\\'

                local isAdd= Save().ADD[textureID]
                local isTextureTab= TextureTab[textureID]

                s:GetParent().button1:SetEnabled(enabled and not isAdd and not isTextureTab)
                s:GetParent().button3:SetEnabled(enabled and isAdd and not isTextureTab)
            end,
        }
    )
    end)

    local num=0
    for texture in pairs(Save().ADD) do
        texture_list(sub2, name, icon, tab, texture, true)
        num=num+1
    end

--全部清除
    if num>0 then
        WoWTools_MenuMixin:ClearAll(sub2, function()
            Save().ADD={}
        end)
    end
    sub2:CreateDivider()

    for texture in pairs(TextureTab) do
        texture_list(sub2, name, icon, tab, texture, false)
    end
    WoWTools_MenuMixin:SetScrollMode(sub2)






    sub:CreateSpacer()
--透明度
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save()[name].alpha or 0.3
        end,
        setValue=function(value)
            Save()[name].alpha=value
            self:SetBG_Settings(name, icon, tab)
            if tab.setFunc then
                tab.setFunc(Save()[name].texture, Save()[name].alpha)
            end
        end,
        name=WoWTools_DataMixin.onlyChinese and '透明度' or CHANGE_OPACITY,
        minValue=0,
        maxValue=1,
        step=0.1,
        bit='%.1f',
        tooltip=name
    })
    sub:CreateSpacer()






--打开选项界面
    sub2=WoWTools_MenuMixin:OpenOptions(sub, {name=self.addName, category=self.Category})
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

    return true
end





























function WoWTools_TextureMixin:Init_BGMenu_Frame(frame, name, icon, tab)
    if WoWToolsSave['Plus_Texture'].disabled or not frame then
        return
    end

    name= name or frame:GetName()

    if not name or not icon then
        return
    end

    self:SetBG_Settings(name, icon, tab)


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
            MenuUtil.CreateContextMenu(s, function(_, root)
                self:BGMenu(root, s.bg_Texture.set_BGData.name, s.bg_Texture, s.bg_Texture.set_BGData.tab)
            end)
            s.portrait:SetAlpha(0.3)
        end)
        frame.PortraitContainer:HookScript('OnMouseUp', function(s)
            s.portrait:SetAlpha(0.7)
        end)
        frame.PortraitContainer.bg_Texture= icon
    end


    

end
