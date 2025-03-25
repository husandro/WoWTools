
local function Save()
    return WoWToolsSave['Plus_Cursor']
end

local function Set_Color()--颜色
    if Save().notUseColor then
        WoWTools_CursorMixin.Color={r=1,g=1,b=1}
    elseif Save().usrClassColor then
        WoWTools_CursorMixin.Color={r=WoWTools_DataMixin.Player.r, g=WoWTools_DataMixin.Player.g, b= WoWTools_DataMixin.Player.b, a=1}
    else
        WoWTools_CursorMixin.Color= Save().color
    end
end

local PanelFrame














--Curor, 添加控制面板
local function Init_Cursor_Options()
    if Save().disabledCursor then return end

    PanelFrame.sliderMaxParticles = WoWTools_PanelMixin:Slider(PanelFrame, {min=50, max=4096, value=Save().maxParticles, setp=1,
    text=WoWTools_Mixin.onlyChinese and '粒子密度' or PARTICLE_DENSITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().maxParticles= value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    PanelFrame.sliderMaxParticles:SetPoint("TOPLEFT", PanelFrame.cursorCheck, 'BOTTOMLEFT', 0, -20)

    local sliderMinDistance = WoWTools_PanelMixin:Slider(PanelFrame, {min=1, max=10, value=Save().minDistance, setp=1, color=true,
    text=WoWTools_Mixin.onlyChinese and '最小距离' or MINIMUM..TRACKER_SORT_PROXIMITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().minDistance= value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderMinDistance:SetPoint("TOPLEFT", PanelFrame.sliderMaxParticles, 'BOTTOMLEFT', 0, -20)


    local sliderSize = WoWTools_PanelMixin:Slider(PanelFrame, {min=8, max=256, value=Save().size, setp=1,
    text=WoWTools_Mixin.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_BAGS_SIZE ,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().size= value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderSize:SetPoint("TOPLEFT", sliderMinDistance, 'BOTTOMLEFT', 0, -20)

    local sliderX = WoWTools_PanelMixin:Slider(PanelFrame, {min=-100, max=100, value=Save().X, setp=1, color=true,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().X= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderX:SetPoint("TOPLEFT", sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderY = WoWTools_PanelMixin:Slider(PanelFrame, {min=-100, max=100, value=Save().Y, setp=1,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().Y= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local sliderRate = WoWTools_PanelMixin:Slider(PanelFrame, {min=0.001, max=0.1, value=Save().rate, setp=0.001, color=true,
    text=WoWTools_Mixin.onlyChinese and '刷新' or REFRESH,
    func=function(self, value)
        value= tonumber(format('%.3f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().rate= value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderRate:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)

    local sliderRotate = WoWTools_PanelMixin:Slider(PanelFrame, {min=0, max=32, value=Save().rotate, setp=1,
    text=WoWTools_Mixin.onlyChinese and '旋转' or HUD_EDIT_MODE_SETTING_MINIMAP_ROTATE_MINIMAP:gsub(MINIMAP_LABEL, ''),
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().rotate= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderRotate:SetPoint("TOPLEFT", sliderRate, 'BOTTOMLEFT', 0, -20)

    local sliderDuration = WoWTools_PanelMixin:Slider(PanelFrame, {min=0.1, max=4, value=Save().duration, setp=0.1, color=true,
    text=WoWTools_Mixin.onlyChinese and '持续时间' or AUCTION_DURATION,
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().duration=  value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderDuration:SetPoint("TOPLEFT", sliderRotate, 'BOTTOMLEFT', 0, -20)

    local sliderGravity = WoWTools_PanelMixin:Slider(PanelFrame, {min=-512, max=512, value=Save().gravity, setp=1,
    text=WoWTools_Mixin.onlyChinese and '掉落' or BATTLE_PET_SOURCE_1,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gravity= value==0 and 0 or value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    sliderGravity:SetPoint("TOPLEFT", sliderDuration, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = WoWTools_PanelMixin:Slider(PanelFrame, {min=0.1, max=1, value=Save().alpha, setp=0.1, color=true,
    text=WoWTools_Mixin.onlyChinese and '透明度' or 'Alpha',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().alpha= value
        WoWTools_CursorMixin:Cursor_Settings()
    end})
    alphaSlider:SetPoint("TOPLEFT", sliderGravity, 'BOTTOMLEFT', 0, -20)


    local dropDown = CreateFrame("DropdownButton", nil, PanelFrame, "WowStyle1DropdownTemplate")--下拉，菜单
    local delColorButton= WoWTools_ButtonMixin:Cbtn(PanelFrame, {size=20})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, PanelFrame, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(PanelFrame, {size=20})--添加, 按钮
    local numColorText= WoWTools_LabelMixin:Create(PanelFrame, {justifyH='RIGHT'})--nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT')

    local function set_panel_Texture()--大图片
        local texture= Save().Atlas[Save().atlasIndex]
        texture= texture or WoWTools_CursorMixin.DefaultTexture
        if WoWTools_TextureMixin:IsAtlas(texture) then
            PanelFrame.Texture:SetAtlas(texture)
        else
            PanelFrame.Texture:SetTexture(texture)
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
                PanelFrame.randomTextureCheck:SetChecked(false)
                self:SetDefaultText(data.icon)
                set_panel_Texture()
                WoWTools_CursorMixin:Cursor_Settings()
            end, {index=index, icon=icon, texture=texture})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(select(3, WoWTools_TextureMixin:IsAtlas(description.data.texture, 64)))
                tooltip:AddLine(description.data.texture)
                tooltip:AddLine(WoWTools_Mixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
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
        local icon = select(3, WoWTools_TextureMixin:IsAtlas(texture))
        table.remove(Save().Atlas, Save().atlasIndex)
        Save().atlasIndex=1
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_CursorMixin.addName, WoWTools_Mixin.onlyChinese and '移除' or REMOVE, icon, texture)
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
                if WoWTools_TextureMixin:IsAtlas(text) then
                    PanelFrame.Texture:SetAtlas(text)
                else
                    PanelFrame.Texture:SetTexture(text)
                end
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)
    addColorEdit:SetScript('OnHide', addColorEdit.ClearFocus)

    --添加按钮
    addColorButton:SetPoint('LEFT', addColorEdit, 'RIGHT', 5,0)
    addColorButton:SetNormalAtlas('common-icon-checkmark')
    addColorButton:SetScript('OnClick', add_Color)
    addColorButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine('Atlas', 'Texture')
        GameTooltip:Show()
    end)
    addColorButton:SetScript('OnLeave', GameTooltip_Hide)

    Init_Cursor_Options=function()end
end

















--GCD, 添加控制面板
local function Init_GCD_Options()
    if Save().disabledGCD then return end

    PanelFrame.sliderSize = WoWTools_PanelMixin:Slider(PanelFrame, {min=8, max=256, value=Save().gcdSize, setp=1,
    text=WoWTools_Mixin.onlyChinese and '尺寸' or HUD_EDIT_MODE_SETTING_BAGS_SIZE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdSize= value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    PanelFrame.sliderSize:SetPoint("TOPLEFT", PanelFrame.gcdCheck, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = WoWTools_PanelMixin:Slider(PanelFrame, {min=0.1, max=1, value=Save().alpha, setp=0.1, color=true,
    text=WoWTools_Mixin.onlyChinese and '透明度' or 'Alpha',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdAlpha= value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    alphaSlider:SetPoint("TOPLEFT", PanelFrame.sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderX = WoWTools_PanelMixin:Slider(PanelFrame, {min=-100, max=100, value=Save().gcdX , setp=1,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdX= value==0 and 0 or value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    sliderX:SetPoint("TOPLEFT", alphaSlider, 'BOTTOMLEFT', 0, -20)

    local sliderY = WoWTools_PanelMixin:Slider(PanelFrame, {min=-100, max=100, value=Save().gcdY, setp=1, color=true,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save().gcdY= value==0 and 0 or value
        WoWTools_CursorMixin:GCD_Settings(true)
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local checkReverse=CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")
    checkReverse:SetChecked(Save().gcdReverse)
    checkReverse.text:SetText(WoWTools_Mixin.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION)
    checkReverse:SetScript('OnMouseUp', function()
        Save().gcdReverse = not Save().gcdReverse and true or false
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    checkReverse:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)

    local checkDrawBling=CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")
    checkDrawBling:SetChecked(Save().gcdReverse)
    checkDrawBling.text:SetText('|TInterface\\Cooldown\\star4:16|tDrawBling')
    checkDrawBling:SetScript('OnMouseUp', function()
        Save().gcdDrawBling = not Save().gcdDrawBling and true or false
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    checkDrawBling:SetPoint("LEFT", checkReverse.text, 'RIGHT', 2, 00)

    local dropDown = CreateFrame("DropdownButton", nil, PanelFrame, "WowStyle1DropdownTemplate")--下拉，菜单
    local delColorButton= WoWTools_ButtonMixin:Cbtn(PanelFrame, {size=20})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, PanelFrame, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(PanelFrame, {size=20})--添加, 按钮
    local numColorText= WoWTools_LabelMixin:Create(PanelFrame, {justifyH='RIGHT'})--nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT')
    numColorText:SetText(#Save().GCDTexture)

    local function set_panel_Texture()--大图片
        local texture= Save().GCDTexture[Save().gcdTextureIndex]
        texture= texture or WoWTools_CursorMixin.DefaultGCDTexture
        PanelFrame.Texture:SetTexture(texture)
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
                PanelFrame.randomTextureCheck:SetChecked(false)
                self:SetDefaultText(data.icon)
                set_panel_Texture()
                WoWTools_CursorMixin:GCD_Settings(true)
            end, {index=index, icon=icon, texture=texture})
            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(select(3, WoWTools_TextureMixin:IsAtlas(description.data.texture, 64)))
                tooltip:AddLine(description.data.texture)
                tooltip:AddLine(WoWTools_Mixin.onlyChinese and '指定' or COMBAT_ALLY_START_MISSION)
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
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_CursorMixin.addName, WoWTools_Mixin.onlyChinese and '移除' or REMOVE, icon, texture)
        set_panel_Texture()
        WoWTools_CursorMixin:GCD_Settings(true)
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
                PanelFrame.Texture:SetTexture(text)
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)
    addColorEdit:SetScript('OnHide', addColorEdit.ClearFocus)

    --添加按钮
    addColorButton:SetPoint('LEFT', addColorEdit, 'RIGHT', 5,0)
    addColorButton:SetNormalAtlas('common-icon-checkmark')
    addColorButton:SetScript('OnClick', add_Color)
    addColorButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(format(WoWTools_Mixin.onlyChinese and "仅限%s" or LFG_LIST_CROSS_FACTION , 'Texture'))
        GameTooltip:Show()
    end)
    addColorButton:SetScript('OnLeave', GameTooltip_Hide)

    Init_GCD_Options=function()end
end



















local function Init_Options()
    if (Save().disabledCursor and Save().disabledGCD) then
        return
    end

    --设置, 大图片
    PanelFrame.Texture= PanelFrame:CreateTexture()--大图片
    PanelFrame.Texture:SetPoint('TOPRIGHT', PanelFrame, 'TOP', -20, 10)
    PanelFrame.Texture:SetSize(80,80)

    local useClassColorCheck= CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")--职业颜色
    local colorText= WoWTools_LabelMixin:Create(PanelFrame, {color={r=Save().color.r, g=Save().color.g, b=Save().color.b, a=Save().color.a}})--nil, nil, nil, {Save().color.r, Save().color.g, Save().color.b, Save().color.a})--自定义,颜色
    local notUseColorCheck= CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")--不使用，颜色

    --职业颜色
    useClassColorCheck:SetPoint("BOTTOMLEFT")
    useClassColorCheck.text:SetText(WoWTools_Mixin.onlyChinese and '职业颜色' or CLASS_COLORS)
    useClassColorCheck.text:SetTextColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
    useClassColorCheck:SetChecked(Save().usrClassColor)
    useClassColorCheck:SetScript('OnMouseDown', function()
        Save().usrClassColor= not Save().usrClassColor and true or nil
        Save().notUseColor=nil
        notUseColorCheck:SetChecked(false)
        Set_Color()
        WoWTools_CursorMixin:Cursor_Settings()
        WoWTools_CursorMixin:GCD_Settings(true)
    end)

    --自定义,颜色
    colorText:SetPoint('LEFT', useClassColorCheck.text, 'RIGHT', 4,0)
    colorText:SetText('|A:colorblind-colorwheel:0:0|a'..(WoWTools_Mixin.onlyChinese and '自定义 ' or CUSTOM))
    colorText:EnableMouse(true)
    colorText.r, colorText.g, colorText.b, colorText.a= Save().color.r, Save().color.g, Save().color.b, Save().color.a
    colorText:SetScript('OnMouseDown', function(self)
        local usrClassColor= Save().usrClassColor
        local notUseColor= Save().notUseColor
        Save().usrClassColor=nil
        Save().notUseColor=nil
        useClassColorCheck:SetChecked(false)
        notUseColorCheck:SetChecked(false)

        local valueR, valueG, valueB, valueA= self.r, self.g, self.b, self.a
        local setA, setR, setG, setB
        local function func()
            Save().color= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            Set_Color()
            WoWTools_CursorMixin:Cursor_Settings()
            WoWTools_CursorMixin:GCD_Settings(true)
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= valueR, valueG, valueB, valueA
                if usrClassColor then
                    Save().usrClassColor=true
                    WoWTools_CursorMixin:Cursor_Settings()
                    WoWTools_CursorMixin:GCD_Settings(true)
                    useClassColorCheck:SetChecked(true)
                elseif notUseColor then
                    Save().notUseColor=true
                    WoWTools_CursorMixin:Cursor_Settings()
                    WoWTools_CursorMixin:GCD_Settings(true)
                    notUseColorCheck:SetChecked(true)
                end
                func()
            end
        )
    end)
    colorText:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '设置' or SETTINGS, (WoWTools_Mixin.onlyChinese and '颜色' or COLOR)..WoWTools_DataMixin.Icon.left)
        GameTooltip:Show()
    end)
    colorText:SetScript('OnLeave', GameTooltip_Hide)

    --不使用，颜色
    notUseColorCheck:SetPoint("LEFT", colorText, 'RIGHT')
    notUseColorCheck.text:SetText(WoWTools_Mixin.onlyChinese and '无' or NONE)
    notUseColorCheck:SetChecked(Save().notUseColor)
    notUseColorCheck:SetScript('OnMouseDown', function()
        Save().notUseColor= not Save().notUseColor and true or nil
        Set_Color()
        useClassColorCheck:SetChecked(false)
        WoWTools_CursorMixin:Cursor_Settings()
        WoWTools_CursorMixin:GCD_Settings(true)
    end)

    --随机, 图片
    PanelFrame.randomTextureCheck= CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")
    PanelFrame.randomTextureCheck:SetPoint("LEFT", notUseColorCheck.text, 'RIGHT', 10,0)
    PanelFrame.randomTextureCheck.text:SetText('|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(WoWTools_Mixin.onlyChinese and '随机图标' or 'Random '..EMBLEM_SYMBOL))
    PanelFrame.randomTextureCheck:SetChecked(Save().randomTexture)
    PanelFrame.randomTextureCheck:SetScript('OnMouseDown', function()
        Save().randomTexture= not Save().randomTexture and true or nil
        WoWTools_CursorMixin:Cursor_Settings()
        WoWTools_CursorMixin:GCD_Settings(true)
    end)
    PanelFrame.randomTextureCheck:SetScript('OnLeave', GameTooltip_Hide)
    PanelFrame.randomTextureCheck:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(WoWTools_Mixin.onlyChinese and '事件' or EVENTS_LABEL)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('Cursor', (WoWTools_Mixin.onlyChinese and '战斗中: 移动' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..NPE_MOVE))
        GameTooltip:AddDoubleLine(' ', (WoWTools_Mixin.onlyChinese and '其它' or OTHER)..WoWTools_DataMixin.Icon.left)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('GCD', WoWTools_TextMixin:GetEnabeleDisable(true))
        GameTooltip:Show()
    end)

    Init_Options=function()end
end



















local function Init()
    Set_Color()

    PanelFrame= CreateFrame('Frame')

    WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_CursorMixin.addName,
        frame= PanelFrame,
        disabled= Save().disabledCursor and  Save().disabledGCD,
    })

    WoWTools_PanelMixin:ReloadButton({
        panel=PanelFrame,
        addName=WoWTools_CursorMixin.addName,
        restTips=true,
        checked=nil,
        clearTips=nil,
        reload=false,--重新加载UI, 重置, 按钮
        disabledfunc=nil,
        clearfunc= function()
            WoWToolsSave['Plus_Cursor']=nil
            WoWTools_Mixin:Reload()
        end}
    )

--Cursor, 启用/禁用
    PanelFrame.cursorCheck=CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")
    PanelFrame.cursorCheck:SetChecked(not Save().disabledCursor)
    PanelFrame.cursorCheck:SetPoint("TOPLEFT", 0, -35)
    PanelFrame.cursorCheck.text:SetText('1)'..(WoWTools_Mixin.onlyChinese and '启用' or ENABLE).. ' Cursor')
    PanelFrame.cursorCheck:SetScript('OnMouseDown', function()
        Save().disabledCursor = not Save().disabledCursor and true or nil
        WoWTools_CursorMixin:Cursor_Settings(true)
    end)

--GCD, 启用/禁用
    PanelFrame.gcdCheck=CreateFrame("CheckButton", nil, PanelFrame, "InterfaceOptionsCheckButtonTemplate")
    PanelFrame.gcdCheck:SetChecked(not Save().disabledGCD)
    PanelFrame.gcdCheck:SetPoint("TOPLEFT", PanelFrame, 'TOP', 0, -35)
    PanelFrame.gcdCheck.text:SetText('2)'..(WoWTools_Mixin.onlyChinese and '启用' or ENABLE).. ' GCD')
    PanelFrame.gcdCheck:SetScript('OnMouseDown', function()
        Save().disabledGCD = not Save().disabledGCD and true or nil
        WoWTools_CursorMixin:GCD_Settings(true)
    end)

    Init=function()end
end











function WoWTools_CursorMixin:Init_Panel()
    
    Init()
end





function WoWTools_CursorMixin:Blizzard_Settings()
    Init_Options()
    Init_Cursor_Options()
    Init_GCD_Options()
end