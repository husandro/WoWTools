local e= select(2, ...)
local function Save()
    return WoWTools_CursorMixin.Save
end








--GCD, 添加控制面板
local function Init(Frame)
    if Frame.sliderSize or Save().disabledGCD then
        return
    end
    Frame.sliderSize = e.CSlider(Frame, {min=8, max=128, value=Save().gcdSize, setp=1,
    text=e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdSize= value
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
    end})
    Frame.sliderSize:SetPoint("TOPLEFT", Frame.gcdCheck, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = e.CSlider(Frame, {min=0.1, max=1, value=Save().alpha, setp=0.1, color=true,
    text=e.onlyChinese and '透明度' or 'Alpha',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdAlpha= value
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
    end})
    alphaSlider:SetPoint("TOPLEFT", Frame.sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderX = e.CSlider(Frame, {min=-100, max=100, value=Save().gcdX , setp=1,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdX= value==0 and 0 or value
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
    end})
    sliderX:SetPoint("TOPLEFT", alphaSlider, 'BOTTOMLEFT', 0, -20)

    local sliderY = e.CSlider(Frame, {min=-100, max=100, value=Save().gcdY, setp=1, color=true,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdY= value==0 and 0 or value
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local checkReverse=CreateFrame("CheckButton", nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    checkReverse:SetChecked(Save().gcdReverse)
    checkReverse.text:SetText(e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION)
    checkReverse:SetScript('OnMouseUp', function()
        Save().gcdReverse = not Save().gcdReverse and true or false
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
    end)
    checkReverse:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)

    local checkDrawBling=CreateFrame("CheckButton", nil, Frame, "InterfaceOptionsCheckButtonTemplate")
    checkDrawBling:SetChecked(Save().gcdReverse)
    checkDrawBling.text:SetText('|TInterface\\Cooldown\\star4:16|tDrawBling')
    checkDrawBling:SetScript('OnMouseUp', function()
        Save().gcdDrawBling = not Save().gcdDrawBling and true or false
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
    end)
    checkDrawBling:SetPoint("LEFT", checkReverse.text, 'RIGHT', 2, 00)

    local dropDown = CreateFrame("DropdownButton", nil, Frame, "WowStyle1DropdownTemplate")--下拉，菜单
    local delColorButton= WoWTools_ButtonMixin:Cbtn(Frame, {icon='hide', size={20,20}})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, Frame, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(Frame, {icon='hide', size={20,20}})--添加, 按钮
    local numColorText= WoWTools_LabelMixin:Create(Frame, {justifyH='RIGHT'})--nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT')
    numColorText:SetText(#Save().GCDTexture)

    local function set_panel_Texture()--大图片
        local texture= Save().GCDTexture[Save().gcdTextureIndex]
        texture= texture or WoWTools_CursorMixin.DefaultGCDTexture
        Frame.Texture:SetTexture(texture)
        addColorEdit:SetText(texture)
        numColorText:SetText(#Save().GCDTexture)
    end


    --下拉，菜单
    dropDown:SetPoint("TOPLEFT", checkReverse, 'BOTTOMLEFT', 0,-15)
    dropDown:SetWidth(195)
    dropDown.Text:ClearAllPoints()
    dropDown.Text:SetPoint('CENTER')
    dropDown:SetDefaultText(Save().Atlas[Save().gcdTextureIndex] or select(3, WoWTools_TextureMixin:IsAtlas(WoWTools_CursorMixin.DefaultGCDTexture, 0)))
    dropDown:SetupMenu(function(self, root)
        local sub
        local num=0
        for index, texture in pairs(Save().GCDTexture) do
            local icon= select(3, WoWTools_TextureMixin:IsAtlas(texture, 0)) or texture
            sub=root:CreateCheckbox(
                icon,
            function(data)
                return Save().gcdTextureIndex==data.index
            end, function(data)
                Save().gcdTextureIndex=data.index
                Save().randomTexture=nil
                Frame.randomTextureCheck:SetChecked(false)
                self:SetDefaultText(data.icon)
                set_panel_Texture()
                WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
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
    delColorButton:SetPoint('LEFT', dropDown, 'RIGHT',2,0)
    delColorButton:SetSize(20,20)
    delColorButton:SetNormalAtlas('xmarksthespot')
    delColorButton:SetScript('OnClick', function()
        local texture= Save().GCDTexture[Save().gcdTextureIndex]
        local icon = texture and '|T'..texture..':0|t'
        table.remove(Save().GCDTexture, Save().gcdTextureIndex)
        Save().gcdTextureIndex=1
        print(e.addName, WoWTools_CursorMixin.addName, e.onlyChinese and '移除' or REMOVE, icon, texture)
        set_panel_Texture()
        WoWTools_CursorMixin:ShowGCDTips()--显示GCD图片
        addColorEdit:SetText(texture or WoWTools_CursorMixin.DefaultGCDTexture)
    end)

    --添加，自定义，图片
    local function add_Color()
        local text= addColorEdit:GetText() or ''
        if text:gsub(' ','')~='' then
            table.insert(Save().GCDTexture, text)
            addColorEdit:SetText('')
            numColorText:SetText(#Save().GCDTexture)
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
                Frame.Texture:SetTexture(text)
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
        e.tips:AddLine(format(e.onlyChinese and "仅限%s" or LFG_LIST_CROSS_FACTION , 'Texture'))
        e.tips:Show()
    end)
    addColorButton:SetScript('OnLeave', GameTooltip_Hide)
end





function WoWTools_CursorMixin:Init_GCD_Options()
    Init(self.OptionsFrame)
end