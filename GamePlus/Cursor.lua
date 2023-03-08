local id, e= ...
local addName= MOUSE_LABEL-- = "鼠标"
local defaultTexture= 'bonusobjectives-bar-starburst'
local Save={
    color={r=0, g=1, b= 0, a=1},
    usrClassColor=true,
    --blendMode= 4,--觉得，没必要
    size=32,--8 64
    gravity=512, -- -512 512
    duration=0.4,--0.1 4
    rotate=32,-- 0 32
    atlasIndex=1,
    rate=0.03,--刷新
    X=40,--移位
    Y=-30,
    alpha=1,--透明
    maxParticles= 50,--数量
    minDistance=3,--距离
    randomTexture=true,--随机, 图片
    randomTextureInCombat=true,--战斗中，也随机，图片
    Atlas={
        'bonusobjectives-bar-starburst',--星星
        'Adventures-Buff-Heal-Burst',--雪
        'OBJFX_StarBurst',--太阳
        'worldquest-questmarker-glow',--空心圆
        'Relic-Frost-TraitGlow',
        'Relic-Holy-TraitGlow',
        'Relic-Life-TraitGlow',
        'Relic-Iron-TraitGlow',
        'Relic-Wind-TraitGlow',
        'Relic-Water-TraitGlow',
        'Azerite-Trait-RingGlow',
        'AzeriteFX-Whirls',
        'ArtifactsFX-Whirls',
        'ArtifactsFX-SpinningGlowys',
        'Azerite-TitanBG-Glow-Rank2',
        '!ItemUpgrade_FX_FrameDecor_IdleGlow',
        'Artifacts-Anim-Sparks',
        'AftLevelup-SoftCloud',
        'BossBanner-RedLightning',
        'Cast_Channel_Sparkles_01',
        'ChallengeMode-Runes-GlowLarge',
        'ChallengeMode-Runes-Shockwave',
        'CovenantSanctum-Reservoir-Idle-Kyrian-Speck',
        'CovenantSanctum-Reservoir-Idle-Kyrian-Glass',
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura121]],
    }
}

local panel= CreateFrame("Frame")
local Color, Frame
--[[
local blendModeTab ={
    "DISABLE",
    "BLEND",
    "ALPHAKEY",
    "ADD",
    "MOD",
}]]

local egim= 0
local create_Particle = function(self)
    local part = self.Pool[#self.Pool]
    self.Pool[#self.Pool] = nil
    self.Used[#self.Used + 1] = part
    part.life = Save.duration
    local scale = UIParent:GetEffectiveScale()
    local x, y = GetCursorPosition()
    part.x = x / scale + Save.X
    part.y = y / scale + Save.Y
    if egim < 0 then
        egim = floor(egim + 360)
    end
    egim = floor(egim)
    part.a = - egim
    part.vx = 1
    part.vy = 1

    part.va = math.random(-(Save.rotate), Save.rotate)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
    part:Show()
    return part
end

local delete_Particle = function(self, part, index)
    part:Hide()
    self.Pool[#self.Pool + 1] = table.remove(self.Used, index)
end


local update_Particle = function(part,  delta)
    part.life = part.life - delta

    if (part.life < 0) then
        return true
    end

    part.vy = part.vy - Save.gravity * delta
    part.x = part.x + part.vx * delta
    part.y = part.y + part.vy * delta

    if Save.rotate then
        part.a = part.a + part.va + delta
        part:SetRotation(math.rad(part.a))
    end

    local scale = math.max(0.1, part.life / Save.duration)

    part:SetRotation(math.rad(part.a))
    part:SetSize(Save.size * scale, Save.size * scale)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
end


--local oldX, oldY = 0, 0
local nowX, nowY = 0, 0
local set_Update = function(self, elapsed)
    self.elapsed= self.elapsed+ elapsed
    if self.elapsed> Save.rate then
        self.elapsed=0
        local oldX, oldY = nowX, nowY
        nowX, nowY = GetCursorPosition()

        local x = nowX - oldX
        local y = nowY - oldY

        if math.sqrt(x * x + y * y) > Save.minDistance then
            egim = atan2((nowX - oldX) ,  (nowY - oldY))
            create_Particle(self)
        end

        for i = #self.Used, 1, -1 do
            if (update_Particle(self.Used[i], elapsed)) then
                delete_Particle(self, self.Used[i], i)
            end
        end
    end
end

local function get_Texture_type(texture)--取得格式, atlas 或 texture
   if texture then
        texture= strupper(texture)
        if not texture:find('ADDONS') then
            return true, '|A:'..texture..':0:0|a'
        else
            return false, '|T'..texture..':0|t'
        end
    end
end

local function set_Texture(self, atlas, texture, setRandomTexture)
    if atlas then
        self:SetAtlas(atlas)
    else
        self:SetTexture(texture)
    end

    if not Save.notUseColor then
        self:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
    end

    if not setRandomTexture then
        self:SetSize(Save.size, Save.size)
        self.life = 0
        self:SetAlpha(Save.alpha)
        self:Hide()
    end
end
local function frame_Init_Set(setRandomTexture)
    local atlasIndex= Save.randomTexture and random(1, #Save.Atlas) or Save.atlasIndex
    local atlas,texture
    if get_Texture_type(Save.Atlas[atlasIndex]) then
        atlas= Save.Atlas[atlasIndex]
    else
        texture= Save.Atlas[atlasIndex]
    end
    if not atlas and not texture then
        atlas= defaultTexture
    end

    local max= Frame.Pool and #Frame.Pool or Save.maxParticles
    Frame.Pool = Frame.Pool or {}
    for i = 1, max do
        if not Frame.Pool[i] then
            Frame.Pool[i] = UIParent:CreateTexture()
            Frame.Pool[i]:SetBlendMode('ADD')--blendModeTab[Save.blendMode])
        end
        set_Texture(Frame.Pool[i], atlas, texture, setRandomTexture)
    end

    if Frame.Used then
        for i=1, #Frame.Used do
            set_Texture(Frame.Used[i], atlas, texture, setRandomTexture)
        end
    else
        Frame.Used = {}
    end

    --egim= 0
    if not setRandomTexture then
        Frame.elapsed=0
    end
end



--####
--颜色
--####
local function set_Color()
    if Save.usrClassColor then
        Color={r=e.Player.r, g=e.Player.g, b= e.Player.b, a=1}
    else
        Color=Save.color
    end
end

--随机, 图片，事件
local function set_Random_Event()
    if Save.randomTexture and not Save.disabled then
        panel:RegisterEvent('PLAYER_STARTED_MOVING')
    else
        panel:UnregisterEvent('PLAYER_STARTED_MOVING')
    end
end

--#####
--初始化
--#####
local function Init()
    Frame= CreateFrame('Frame')
    frame_Init_Set()
    Frame:SetScript('OnUpdate', set_Update)
    if Save.randomTexture then
        set_Random_Event()--随机, 图片，事件
    end
end

--###########
--添加控制面板
--###########
local function Init_Options()
    local reloadButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--重新加载UI
    reloadButton:SetPoint('TOPLEFT')
    reloadButton:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)
    reloadButton:SetSize(120, 28)
    reloadButton:SetScript('OnMouseUp', e.Reload)

    local restButton= e.Cbtn(panel, true, nil, nil, nil, nil, {20,20})--重置
    restButton:SetNormalAtlas('bags-button-autosort-up')
    restButton:SetPoint("TOPRIGHT")
    restButton:SetScript('OnMouseUp', function()
        StaticPopupDialogs[id..addName..'restAllSetup']={
            text =id..'  '..addName..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..'|r '..(e.onlyChinese and '保存' or SAVE)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..' /reload',
            button1 = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET),
            button2 = e.onlyChinese and '取消' or CANCEL,
            whileDead=true,timeout=30,hideOnEscape = 1,
            OnAccept=function(self)
                Save=nil
                e.Reload()
            end,
        }
        StaticPopup_Show(id..addName..'restAllSetup')
    end)


    local sliderMaxParticles = e.Create_Slider(panel, {min=50, max=4096, value=Save.maxParticles, setp=1,
    text=e.onlyChinese and '粒子密度' or PARTICLE_DENSITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.maxParticles= value
        print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end})
    sliderMaxParticles:SetPoint("TOPLEFT", reloadButton, 'BOTTOMLEFT', 0, -32)

    local sliderMinDistance = e.Create_Slider(panel, {min=1, max=10, value=Save.minDistance, setp=1,
    text=e.onlyChinese and '最小距离' or MINIMUM..TRACKER_SORT_PROXIMITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.minDistance= value
        frame_Init_Set()--初始，设置
    end})
    sliderMinDistance:SetPoint("TOPLEFT", sliderMaxParticles, 'BOTTOMLEFT', 0, -32)


    local sliderSize = e.Create_Slider(panel, {min=8, max=128, value=Save.size, setp=1,
    text=e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.size= value
        frame_Init_Set()--初始，设置
    end})
    sliderSize:SetPoint("TOPLEFT", sliderMinDistance, 'BOTTOMLEFT', 0, -32)

    local sliderX = e.Create_Slider(panel, {min=-100, max=100, value=Save.X, setp=1,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.X= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end})
    sliderX:SetPoint("TOPLEFT", sliderSize, 'BOTTOMLEFT', 0, -32)

    local sliderY = e.Create_Slider(panel, {min=-100, max=100, value=Save.Y, setp=1,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.Y= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -32)

    local sliderRate = e.Create_Slider(panel, {min=0.001, max=0.1, value=Save.rate, setp=0.001,
    text=e.onlyChinese and '刷新' or REFRESH,
    func=function(self, value)
        value= tonumber(format('%.3f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.rate= value
        frame_Init_Set()--初始，设置
    end})
    sliderRate:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -32)

    local sliderRotate = e.Create_Slider(panel, {min=0, max=32, value=Save.rotate, setp=1,
    text=e.onlyChinese and '旋转' or HUD_EDIT_MODE_SETTING_MINIMAP_ROTATE_MINIMAP:gsub(MINIMAP_LABEL, ''),
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.rotate= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end})
    sliderRotate:SetPoint("TOPLEFT", sliderRate, 'BOTTOMLEFT', 0, -32)

    local sliderDuration = e.Create_Slider(panel, {min=0.1, max=4, value=Save.duration, setp=0.1,
    text=e.onlyChinese and '持续时间' or AUCTION_DURATION,
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.duration=  value
        frame_Init_Set()--初始，设置
    end})
    sliderDuration:SetPoint("TOPLEFT", sliderRotate, 'BOTTOMLEFT', 0, -32)

    local sliderGravity = e.Create_Slider(panel, {min=-512, max=512, value=Save.gravity, setp=1,
    text=e.onlyChinese and '掉落' or BATTLE_PET_SOURCE_1,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gravity= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end})
    sliderGravity:SetPoint("TOPLEFT", sliderDuration, 'BOTTOMLEFT', 0, -32)

    local alphaSlider = e.Create_Slider(panel, {min=0.1, max=1, value=Save.alpha, setp=0.1,
    text=e.onlyChinese and '透明度' or CHANGE_OPACITY,
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.alpha= value
        frame_Init_Set()--初始，设置
    end})
    alphaSlider:SetPoint("TOPLEFT", sliderGravity, 'BOTTOMLEFT', 0, -32)

    local useClassColorCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--职业颜色
    local colorText= e.Cstr(panel, nil, nil, nil, {Save.color.r, Save.color.g, Save.color.b, Save.color.a})--自定义,颜色
    local notUseColorCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--不使用，颜色

    useClassColorCheck:SetPoint("TOPLEFT", panel.check, 'BOTTOMLEFT', 0, -12)--职业颜色
    useClassColorCheck.text:SetText(e.onlyChinese and '职业颜色' or CLASS_COLORS)
    useClassColorCheck.text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    useClassColorCheck:SetChecked(Save.usrClassColor)
    useClassColorCheck:SetScript('OnMouseDown', function()
        Save.usrClassColor= not Save.usrClassColor and true or nil
        Save.notUseColor=nil
        notUseColorCheck:SetChecked(false)
        set_Color()
        frame_Init_Set()--初始，设置
    end)

    colorText:SetPoint('LEFT', useClassColorCheck.text, 'RIGHT', 4,0)----自定义,颜色
    colorText:SetText('|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '自定义 ' or CUSTOM))
    colorText:EnableMouse(true)
    colorText.r, colorText.g, colorText.b, colorText.a= Save.color.r, Save.color.g, Save.color.b, Save.color.a
    colorText:SetScript('OnMouseDown', function(self)
        local usrClassColor= Save.usrClassColor
        local notUseColor= Save.notUseColor
        Save.usrClassColor=nil
        Save.notUseColor=nil
        useClassColorCheck:SetChecked(false)
        notUseColorCheck:SetChecked(false)
        local valueR, valueG, valueB, valueA= self.r, self.g, self.b, self.a
        e.ShowColorPicker(self.r, self.g, self.b,self.a, function(restore)
            local setA, setR, setG, setB
            if not restore then
                setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
            else
                setR, setG, setB, setA= valueR, valueG, valueB, valueA
                if usrClassColor then
                    Save.usrClassColor=true
                    useClassColorCheck:SetChecked(true)
                elseif notUseColor then
                    Save.notUseColor=true
                    notUseColorCheck:SetChecked(true)
                end
            end
            Save.color= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            set_Color()
            frame_Init_Set()--初始，设置
        end)
    end)
    colorText:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '颜色' or COLOR)
        e.tips:Show()
    end)
    colorText:SetScript('OnLeave', function() e.tips:Hide() end)


    notUseColorCheck:SetPoint("LEFT", colorText, 'RIGHT', 2, 0)--不使用，颜色
    notUseColorCheck.text:SetText(e.onlyChinese and '无' or NONE)
    notUseColorCheck:SetChecked(Save.notUseColor)
    notUseColorCheck:SetScript('OnMouseDown', function()
        Save.notUseColor= not Save.notUseColor and true or nil
        Save.useClassColorCheck=nil
        useClassColorCheck:SetChecked(false)
        print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    local dropDown = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local panelTexture= panel:CreateTexture()--大图片
    local delColorButton= e.Cbtn(panel, nil, nil, nil, nil, true, {20,20})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, panel, 'InputBoxTemplate')--EditBox
    local addColorButton= e.Cbtn(panel, nil, nil, nil, nil, true, {20,20})--添加, 按钮
    local randomTextureCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--随机, 图片
    local numColorText= e.Cstr(panel, nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT', 18,5)

    --设置, 大图片
    local function set_panel_Texture()
        local texture= Save.Atlas[Save.atlasIndex]
        texture= texture or defaultTexture
        if get_Texture_type(texture) then
            panelTexture:SetAtlas(texture)
        else
            panelTexture:SetTexture(texture)
        end
        addColorEdit:SetText(texture)
        numColorText:SetText(#Save.Atlas)
    end

    --下拉，菜单
    local function Init_Menu(self, level, menuList)
        for index, texture in pairs(Save.Atlas) do
            local info={
                text= texture,
                icon= texture,
                arg1= index,
                checked= Save.atlasIndex==index,
                func= function(_, arg1)
                    Save.atlasIndex=arg1
                    Save.randomTexture=nil
                    randomTextureCheck:SetChecked(false)
                    UIDropDownMenu_SetText(self, Save.Atlas[arg1])
                    set_panel_Texture()
                    frame_Init_Set()--初始，设置
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end
    end
    dropDown:SetPoint("TOPLEFT", useClassColorCheck, 'BOTTOMLEFT', -18,0)
    UIDropDownMenu_SetWidth(dropDown, 280)
    UIDropDownMenu_Initialize(dropDown, Init_Menu)
    UIDropDownMenu_SetText(dropDown, Save.Atlas[Save.atlasIndex] or defaultTexture)

    --大图片
    panelTexture:SetPoint("BOTTOMRIGHT", dropDown, 'TOPRIGHT', -50,0)
    panelTexture:SetSize(80,80)
    set_panel_Texture()

    --删除，图片
    delColorButton:SetPoint('LEFT', dropDown, 'RIGHT')
    delColorButton:SetSize(20,20)
    delColorButton:SetNormalAtlas('xmarksthespot')
    delColorButton:SetScript('OnClick', function()
        local texture= Save.Atlas[Save.atlasIndex]
        local icon = select(2, get_Texture_type(texture))
        table.remove(Save.Atlas, Save.atlasIndex)
        Save.atlasIndex=1
        print(id, addName, e.onlyChinese and '移除' or REMOVE, icon, texture)
        set_panel_Texture()
        frame_Init_Set()
        addColorEdit:SetText(texture or defaultTexture)
        UIDropDownMenu_SetText(dropDown, Save.Atlas[Save.atlasIndex] or defaultTexture)
        UIDropDownMenu_Initialize(dropDown, Init_Menu)
    end)

    --添加，自定义，图片
    local function add_Color()
        local text= addColorEdit:GetText() or ''
        if text:gsub(' ','')~='' then
            table.insert(Save.Atlas, text)
            addColorEdit:SetText('')
            numColorText:SetText(#Save.Atlas)
            UIDropDownMenu_Initialize(dropDown, Init_Menu)
        end
    end
    addColorEdit:SetPoint("TOPLEFT", dropDown, 'BOTTOMLEFT',25,-2)
	addColorEdit:SetSize(285,20)
	addColorEdit:SetAutoFocus(false)
    addColorEdit:SetScript('OnTextChanged', function(self, userInput)
        if userInput then
            local text= self:GetText()
            if text:gsub(' ','')~='' then
                if  get_Texture_type(text) then
                    panelTexture:SetAtlas(text)
                else
                    panelTexture:SetTexture(text)
                end
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)
    addColorButton:SetPoint('LEFT', addColorEdit, 'RIGHT')--添加按钮
    addColorButton:SetNormalAtlas(e.Icon.select)
    addColorButton:SetScript('OnClick', add_Color)


    randomTextureCheck:SetPoint("TOPLEFT", addColorEdit, 'BOTTOMLEFT',-10,-4)
    randomTextureCheck.text:SetText('|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(e.onlyChinese and '随机' or 'Random'))
    randomTextureCheck:SetChecked(Save.randomTexture)
    randomTextureCheck:SetScript('OnMouseDown', function()
        Save.randomTexture= not Save.randomTexture and true or nil
        frame_Init_Set()--初始，设置
        set_Random_Event()--随机, 事件
    end)
    randomTextureCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '事件' or EVENTS_LABEL, e.onlyChinese and '移动' or NPE_MOVE)
        e.tips:Show()
    end)
    randomTextureCheck:SetScript('OnLeave', function() e.tips:Hide() end)

    --战斗中， 随机，图片
    local randomTextureInCombatCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--随机, 图片
    randomTextureInCombatCheck:SetPoint("LEFT", randomTextureCheck.text, 'RIGHT', 2,0)
    randomTextureInCombatCheck.text:SetText(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    randomTextureInCombatCheck:SetChecked(Save.randomTextureInCombat)
    randomTextureInCombatCheck:SetScript('OnMouseDown', function()
        Save.randomTextureInCombat= not Save.randomTextureInCombat and true or nil
    end)
    randomTextureInCombatCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine((e.onlyChinese and '高' or HIGH )..' CPU')
        e.tips:Show()
    end)
    randomTextureInCombatCheck:SetScript('OnLeave', function() e.tips:Hide() end)
end



--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            set_Color()

            panel.name = e.Icon.left..(e.onlyChinese and '鼠标' or   MOUSE_LABEL)
            panel.parent =id
            InterfaceOptions_AddCategory(panel)

            panel.check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            panel.check:SetChecked(not Save.disabled)
            panel.check:SetPoint('TOPLEFT', panel, 'TOP')
            panel.check.text:SetText(e.onlyChinese and '启用/禁用' or (ENABLE..'/'..DISABLE))
            panel.check:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                if not Save.disabled and not Frame then
                    Init()
                    Init_Options()
                end
                Frame:SetShown(not Save.disabled)
            end)

            if not Save.disabled then
                C_Timer.After(2, function()
                    Init()
                    Init_Options()
                end)
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_STARTED_MOVING' then
        if Save.randomTextureInCombat or not UnitAffectingCombat('player') then
            frame_Init_Set(true)--初始，设置
        end
    end
end)