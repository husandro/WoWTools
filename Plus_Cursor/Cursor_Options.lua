local e= select(2, ...)
local function Save()
    return WoWTools_CursorMixin.Save
end









--Curor, 添加控制面板
local function Init(Frame)
    if Frame.sliderMaxParticles or Save().disabled then
        return
    end
    Frame.sliderMaxParticles = e.CSlider(Frame, {min=50, max=4096, value=Save().maxParticles, setp=1,
    text=e.onlyChinese and '粒子密度' or PARTICLE_DENSITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().maxParticles= value
        print(e.addName, WoWTools_CursorMixin.addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end})
    Frame.sliderMaxParticles:SetPoint("TOPLEFT", Frame.cursorCheck, 'BOTTOMLEFT', 0, -20)

    local sliderMinDistance = e.CSlider(Frame, {min=1, max=10, value=Save().minDistance, setp=1, color=true,
    text=e.onlyChinese and '最小距离' or MINIMUM..TRACKER_SORT_PROXIMITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().minDistance= value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderMinDistance:SetPoint("TOPLEFT", Frame.sliderMaxParticles, 'BOTTOMLEFT', 0, -20)


    local sliderSize = e.CSlider(Frame, {min=8, max=128, value=Save().size, setp=1,
    text=e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().size= value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderSize:SetPoint("TOPLEFT", sliderMinDistance, 'BOTTOMLEFT', 0, -20)

    local sliderX = e.CSlider(Frame, {min=-100, max=100, value=Save().X, setp=1, color=true,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().X= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderX:SetPoint("TOPLEFT", sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderY = e.CSlider(Frame, {min=-100, max=100, value=Save().Y, setp=1,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().Y= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local sliderRate = e.CSlider(Frame, {min=0.001, max=0.1, value=Save().rate, setp=0.001, color=true,
    text=e.onlyChinese and '刷新' or REFRESH,
    func=function(self, value)
        value= tonumber(format('%.3f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().rate= value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderRate:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)

    local sliderRotate = e.CSlider(Frame, {min=0, max=32, value=Save().rotate, setp=1,
    text=e.onlyChinese and '旋转' or HUD_EDIT_MODE_SETTING_MINIMAP_ROTATE_MINIMAP:gsub(MINIMAP_LABEL, ''),
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().rotate= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderRotate:SetPoint("TOPLEFT", sliderRate, 'BOTTOMLEFT', 0, -20)

    local sliderDuration = e.CSlider(Frame, {min=0.1, max=4, value=Save().duration, setp=0.1, color=true,
    text=e.onlyChinese and '持续时间' or AUCTION_DURATION,
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().duration=  value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderDuration:SetPoint("TOPLEFT", sliderRotate, 'BOTTOMLEFT', 0, -20)

    local sliderGravity = e.CSlider(Frame, {min=-512, max=512, value=Save().gravity, setp=1,
    text=e.onlyChinese and '掉落' or BATTLE_PET_SOURCE_1,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gravity= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    sliderGravity:SetPoint("TOPLEFT", sliderDuration, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = e.CSlider(Frame, {min=0.1, max=1, value=Save().alpha, setp=0.1, color=true,
    text=e.onlyChinese and '透明度' or 'Alpha',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().alpha= value
        WoWTools_CursorMixin:Cursor_Settings()--初始，设置
    end})
    alphaSlider:SetPoint("TOPLEFT", sliderGravity, 'BOTTOMLEFT', 0, -20)


    local dropDown = CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    local delColorButton= WoWTools_ButtonMixin:Cbtn(Frame, {icon='hide', size={20,20}})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(Frame, {icon='hide', size={20,20}})--添加, 按钮
    local numColorText= WoWTools_LabelMixin:Create(Frame, {justifyH='RIGHT'})--nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT')

    local function set_panel_Texture()--大图片
        local texture= Save().Atlas[Save().atlasIndex]
        texture= texture or WoWTools_CursorMixin.DefaultTexture
        if WoWTools_CursorMixin:GetTextureType(texture) then
            Frame.Texture:SetAtlas(texture)
        else
            Frame.Texture:SetTexture(texture)
        end
        addColorEdit:SetText(texture)
        numColorText:SetText(#Save().Atlas)
    end
    set_panel_Texture()

--下拉，菜单
    dropDown:SetPoint("TOPLEFT", alphaSlider, 'BOTTOMLEFT', 0,-32)
    dropDown:SetWidth(195)
    dropDown.Text:ClearAllPoints()
    dropDown.Text:SetPoint('CENTER')
    dropDown:SetDefaultText(Save().Atlas[Save().atlasIndex] or select(3, WoWTools_TextureMixin:IsAtlas(WoWTools_CursorMixin.DefaultTexture, 0)))
    dropDown:SetupMenu(function(self, root)
        local sub
        local num=0
        for index, texture in pairs(Save().Atlas) do
            local icon= select(3, WoWTools_TextureMixin:IsAtlas(texture, 0)) or texture
            sub=root:CreateCheckbox(
                icon,
            function(data)
                return Save().atlasIndex==data.index
            end, function(data)
                Save().atlasIndex=data.index
                Save().randomTexture=nil
                Frame.randomTextureCheck:SetChecked(false)
                self:SetDefaultText(data.icon)
                set_panel_Texture()
                WoWTools_CursorMixin:Cursor_Settings()--初始，设置
            end, {index=index, icon=icon, texture=texture})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(select(3, WoWTools_TextureMixin:IsAtlas(description.data.texture, 64)))
                tooltip:AddLine(description.data.texture)
                tooltip:AddLine(e.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
            end)
            sub:AddInitializer(function(btn)
                btn.fontString:ClearAllPoints()
                btn.fontString:SetPoint('CENTER')
            end)
            num= index
        end
        WoWTools_MenuMixin:SetScrollMode(root, num)
    end)


    --删除，图片
    delColorButton:SetPoint('LEFT', dropDown, 'RIGHT', 2,0)
    delColorButton:SetSize(20,20)
    delColorButton:SetNormalAtlas('xmarksthespot')
    delColorButton:SetScript('OnClick', function()
        local texture= Save().Atlas[Save().atlasIndex]
        local icon = select(2, WoWTools_CursorMixin:GetTextureType(texture))
        table.remove(Save().Atlas, Save().atlasIndex)
        Save().atlasIndex=1
        print(e.addName, WoWTools_CursorMixin.addName, e.onlyChinese and '移除' or REMOVE, icon, texture)
        set_panel_Texture()
        WoWTools_CursorMixin:Cursor_Settings()
        addColorEdit:SetText(texture or WoWTools_CursorMixin.DefaultTexture)
    end)

    --添加，自定义，图片
    local function add_Color()
        local text= addColorEdit:GetText() or ''
        if text:gsub(' ','')~='' then
            table.insert(Save().Atlas, text)
            addColorEdit:SetText('')
            numColorText:SetText(#Save().Atlas)
        end
    end
    addColorEdit:SetPoint("TOPLEFT", dropDown, 'BOTTOMLEFT',2,-2)
	addColorEdit:SetSize(192,20)
	addColorEdit:SetAutoFocus(false)
    addColorEdit:ClearFocus()
    addColorEdit:SetScript('OnTextChanged', function(self, userInput)
        if userInput then
            local text= self:GetText()
            if text:gsub(' ','')~='' then
                if  WoWTools_CursorMixin:GetTextureType(text) then
                    Frame.Texture:SetAtlas(text)
                else
                    Frame.Texture:SetTexture(text)
                end
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)
    addColorEdit:SetScript('OnHide', addColorEdit.ClearFocus)

    --添加按钮
    addColorButton:SetPoint('LEFT', addColorEdit, 'RIGHT', 5,0)
    addColorButton:SetNormalAtlas(e.Icon.select)
    addColorButton:SetScript('OnClick', add_Color)
    addColorButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine('Atlas')
        e.tips:AddDoubleLine('Texture', (e.onlyChinese and '需求' or NEED)..' \\Interface')
        e.tips:Show()
    end)
    addColorButton:SetScript('OnLeave', GameTooltip_Hide)
end











function WoWTools_CursorMixin:Init_Cursor_Options()
    Init(self.OptionsFrame)
end