local id, e= ...
local addName= MOUSE_LABEL-- = "鼠标"
local defaultTexture= 'bonusobjectives-bar-starburst'
local defaultGCDTexture= ''
local Save={
    disabled= not e.Player.husandro,
    disabledGCD= not e.Player.husandro,
    color={r=0, g=1, b= 0, a=1},
    usrClassColor=true,
    size=32,--8 64
    gravity=512, -- -512 512
    duration=0.3,--0.1 4
    rotate=32,-- 0 32
    atlasIndex=1,
    rate=0.03,--刷新
    X=40,--移位
    Y=-30,
    alpha=1,--透明
    maxParticles= 50,--数量
    minDistance=3,--距离
    randomTexture=true,--随机, 图片
    --randomTextureInCombat=true,--战斗中，也随机，图片
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

        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura142.tga]],
    },
    GCDTexture={
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura73.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura94.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura103.tga]],
        [[Interface\Addons\WoWTools\Sesource\Mouse\Aura142.tga]],
    },
    gcdSize=15,
    gcdTextureIndex=1,
    gcdAlpha=1,
    gcdX=0,
    gcdY=0,
    --gcdDrawBling=false,
    --gcdReverse=false,
}

local panel= CreateFrame("Frame")
local Color, cursorFrame, gcdFrame

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

--############
--Cursor, 模块
--############
local create_Particle = function(self)
    local part = self.Pool[#self.Pool]
    if part then
        self.Pool[#self.Pool] = nil
        self.Used[#self.Used + 1] = part
        part.life = Save.duration
        local scale = UIParent:GetEffectiveScale()
        local x, y = GetCursorPosition()
        part.x = x / scale + Save.X
        part.y = y / scale + Save.Y
        if self.egim < 0 then
            self.egim = floor(self.egim + 360)
        end
        self.egim = floor(self.egim)
        part.a = - self.egim
        part.vx = 1
        part.vy = 1

        part.va = math.random(-(Save.rotate), Save.rotate)
        part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
        part:Show()
    end
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

    --if Save.rotate then
        part.a = part.a + part.va + delta
        part:SetRotation(math.rad(part.a))
    --end

    local scale = math.max(0.1, part.life / Save.duration)

    part:SetRotation(math.rad(part.a))
    part:SetSize(Save.size * scale, Save.size * scale)
    part:SetPoint("CENTER", UIParent, "BOTTOMLEFT", part.x, part.y)
end


local nowX, nowY = 0, 0
local set_Cursor_Update = function(self, elapsed)
    self.elapsed= (self.elapsed or Save.rate) + elapsed
    if self.elapsed> Save.rate then
        self.elapsed=0
        local oldX, oldY = nowX, nowY
        nowX, nowY = GetCursorPosition()

        local x = nowX - oldX
        local y = nowY - oldY

        if math.sqrt(x * x + y * y) > Save.minDistance then
            self.egim = atan2((nowX - oldX) ,  (nowY - oldY))
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

local function set_Cursor_Texture(self, atlas, texture, onlyRandomTexture)
    if atlas then
        self:SetAtlas(atlas)
    else
        self:SetTexture(texture)
    end

    if not Save.notUseColor then
        self:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
    end

    if not onlyRandomTexture then
        self:SetSize(Save.size, Save.size)
        self.life = 0
        self:SetAlpha(Save.alpha)
        self:Hide()
    end
end

--初始, 设置, Cursor
local function cursor_Init_And_Set(onlyRandomTexture)
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

    local max= cursorFrame.Pool and #cursorFrame.Pool or Save.maxParticles
    cursorFrame.Pool = cursorFrame.Pool or {}
    for i = 1, max do
        if not cursorFrame.Pool[i] then
            cursorFrame.Pool[i] = UIParent:CreateTexture()
            cursorFrame.Pool[i]:SetBlendMode('ADD')
        end
        set_Cursor_Texture(cursorFrame.Pool[i], atlas, texture, onlyRandomTexture)
    end

    if cursorFrame.Used then
        for i=1, #cursorFrame.Used do
            set_Cursor_Texture(cursorFrame.Used[i], atlas, texture, onlyRandomTexture)
        end
    else
        cursorFrame.Used = {}
    end
end

local function set_Curor_Random_Event()--随机, 图片，事件
    if Save.randomTexture and not Save.disabled then
        cursorFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
        cursorFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
        if  UnitAffectingCombat('player') then
            cursorFrame:RegisterEvent('PLAYER_STARTED_MOVING')
            cursorFrame:UnregisterEvent('GLOBAL_MOUSE_DOWN')
        else
            cursorFrame:RegisterEvent('GLOBAL_MOUSE_DOWN')
            cursorFrame:UnregisterEvent('PLAYER_STARTED_MOVING')
        end
    else
       cursorFrame:UnregisterAllEvents()
    end
end

--Curor, 添加控制面板
local function Init_Cursor_Options()
    if panel.sliderMaxParticles or Save.disabled then
        return
    end
    panel.sliderMaxParticles = e.CSlider(panel, {min=50, max=4096, value=Save.maxParticles, setp=1,
    text=e.onlyChinese and '粒子密度' or PARTICLE_DENSITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.maxParticles= value
        print(e.addName, e.cn(addName), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end})
    panel.sliderMaxParticles:SetPoint("TOPLEFT", panel.cursorCheck, 'BOTTOMLEFT', 0, -20)

    local sliderMinDistance = e.CSlider(panel, {min=1, max=10, value=Save.minDistance, setp=1, color=true,
    text=e.onlyChinese and '最小距离' or MINIMUM..TRACKER_SORT_PROXIMITY,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.minDistance= value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderMinDistance:SetPoint("TOPLEFT", panel.sliderMaxParticles, 'BOTTOMLEFT', 0, -20)


    local sliderSize = e.CSlider(panel, {min=8, max=128, value=Save.size, setp=1,
    text=e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.size= value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderSize:SetPoint("TOPLEFT", sliderMinDistance, 'BOTTOMLEFT', 0, -20)

    local sliderX = e.CSlider(panel, {min=-100, max=100, value=Save.X, setp=1, color=true,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.X= value==0 and 0 or value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderX:SetPoint("TOPLEFT", sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderY = e.CSlider(panel, {min=-100, max=100, value=Save.Y, setp=1,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.Y= value==0 and 0 or value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local sliderRate = e.CSlider(panel, {min=0.001, max=0.1, value=Save.rate, setp=0.001, color=true,
    text=e.onlyChinese and '刷新' or REFRESH,
    func=function(self, value)
        value= tonumber(format('%.3f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.rate= value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderRate:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)

    local sliderRotate = e.CSlider(panel, {min=0, max=32, value=Save.rotate, setp=1,
    text=e.onlyChinese and '旋转' or HUD_EDIT_MODE_SETTING_MINIMAP_ROTATE_MINIMAP:gsub(MINIMAP_LABEL, ''),
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.rotate= value==0 and 0 or value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderRotate:SetPoint("TOPLEFT", sliderRate, 'BOTTOMLEFT', 0, -20)

    local sliderDuration = e.CSlider(panel, {min=0.1, max=4, value=Save.duration, setp=0.1, color=true,
    text=e.onlyChinese and '持续时间' or AUCTION_DURATION,
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.duration=  value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderDuration:SetPoint("TOPLEFT", sliderRotate, 'BOTTOMLEFT', 0, -20)

    local sliderGravity = e.CSlider(panel, {min=-512, max=512, value=Save.gravity, setp=1,
    text=e.onlyChinese and '掉落' or BATTLE_PET_SOURCE_1,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gravity= value==0 and 0 or value
        cursor_Init_And_Set()--初始，设置
    end})
    sliderGravity:SetPoint("TOPLEFT", sliderDuration, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = e.CSlider(panel, {min=0.1, max=1, value=Save.alpha, setp=0.1, color=true,
    text=e.onlyChinese and '透明度' or 'Alpha',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.alpha= value
        cursor_Init_And_Set()--初始，设置
    end})
    alphaSlider:SetPoint("TOPLEFT", sliderGravity, 'BOTTOMLEFT', 0, -20)

    local dropDown = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local delColorButton= WoWTools_ButtonMixin:Cbtn(panel, {icon='hide', size={20,20}})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, panel, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(panel, {icon='hide', size={20,20}})--添加, 按钮
    local numColorText= WoWTools_LabelMixin:CreateLabel(panel, {justifyH='RIGHT'})--nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT', 18,5)

    local function set_panel_Texture()--大图片
        local texture= Save.Atlas[Save.atlasIndex]
        texture= texture or defaultTexture
        if get_Texture_type(texture) then
            panel.Texture:SetAtlas(texture)
        else
            panel.Texture:SetTexture(texture)
        end
        addColorEdit:SetText(texture)
        numColorText:SetText(#Save.Atlas)
    end
    set_panel_Texture()

    --下拉，菜单
    local function Init_Menu(self, level)
        for index, texture in pairs(Save.Atlas) do
            local info={
                text= texture,
                icon= texture,
                arg1= index,
                checked= Save.atlasIndex==index,
                func= function(_, arg1)
                    Save.atlasIndex=arg1
                    Save.randomTexture=nil
                    panel.randomTextureCheck:SetChecked(false)
                    e.LibDD:UIDropDownMenu_SetText(self, Save.Atlas[arg1])
                    set_panel_Texture()
                    cursor_Init_And_Set()--初始，设置
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
    dropDown:SetPoint("TOPLEFT", alphaSlider, 'BOTTOMLEFT', -18,-32)
    e.LibDD:UIDropDownMenu_SetWidth(dropDown, 180)
    e.LibDD:UIDropDownMenu_Initialize(dropDown, Init_Menu)
    e.LibDD:UIDropDownMenu_SetText(dropDown, Save.Atlas[Save.atlasIndex] or defaultTexture)
    dropDown.Button:SetScript('OnMouseDown', function(self) e.LibDD:ToggleDropDownMenu(1,nil,self:GetParent(), self, 15,0) end)

    --删除，图片
    delColorButton:SetPoint('LEFT', dropDown, 'RIGHT',-10,0)
    delColorButton:SetSize(20,20)
    delColorButton:SetNormalAtlas('xmarksthespot')
    delColorButton:SetScript('OnClick', function()
        local texture= Save.Atlas[Save.atlasIndex]
        local icon = select(2, get_Texture_type(texture))
        table.remove(Save.Atlas, Save.atlasIndex)
        Save.atlasIndex=1
        print(e.addName, e.cn(addName), e.onlyChinese and '移除' or REMOVE, icon, texture)
        set_panel_Texture()
        cursor_Init_And_Set()
        addColorEdit:SetText(texture or defaultTexture)
        e.LibDD:UIDropDownMenu_SetText(dropDown, Save.Atlas[Save.atlasIndex] or defaultTexture)
        e.LibDD:UIDropDownMenu_Initialize(dropDown, Init_Menu)
    end)

    --添加，自定义，图片
    local function add_Color()
        local text= addColorEdit:GetText() or ''
        if text:gsub(' ','')~='' then
            table.insert(Save.Atlas, text)
            addColorEdit:SetText('')
            numColorText:SetText(#Save.Atlas)
            e.LibDD:UIDropDownMenu_Initialize(dropDown, Init_Menu)
        end
    end
    addColorEdit:SetPoint("TOPLEFT", dropDown, 'BOTTOMLEFT',22,-2)
	addColorEdit:SetSize(192,20)
	addColorEdit:SetAutoFocus(false)
    addColorEdit:ClearFocus()
    addColorEdit:SetScript('OnTextChanged', function(self, userInput)
        if userInput then
            local text= self:GetText()
            if text:gsub(' ','')~='' then
                if  get_Texture_type(text) then
                    panel.Texture:SetAtlas(text)
                else
                    panel.Texture:SetTexture(text)
                end
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)

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

--Cursor, 初始化
local function Cursor_Init()
    cursorFrame= CreateFrame('Frame')
    cursorFrame.egim=0
    cursor_Init_And_Set()
    cursorFrame:SetScript('OnUpdate', set_Cursor_Update)

    set_Curor_Random_Event()--随机, 图片，事件

    cursorFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_STARTED_MOVING' or event=='GLOBAL_MOUSE_DOWN' then
            cursor_Init_And_Set(true)--初始，设置

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:RegisterEvent('PLAYER_STARTED_MOVING')
            self:UnregisterEvent('GLOBAL_MOUSE_DOWN')

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:RegisterEvent('GLOBAL_MOUSE_DOWN')
            self:UnregisterEvent('PLAYER_STARTED_MOVING')
        end
    end)
end



--#########
--GCD, 模块
--#########
--随机GCD，图片
local function set_GCD_Texture()
    local index= Save.randomTexture and random(1, #Save.GCDTexture) or Save.gcdTextureIndex
    gcdFrame.cooldown:SetSwipeTexture(Save.GCDTexture[index] or defaultGCDTexture)
end

--设置 GCD
local function set_GCD()
    gcdFrame.cooldown:Clear()
    if Save.disabledGCD then
        gcdFrame:UnregisterEvent('SPELL_UPDATE_COOLDOWN')
        gcdFrame:SetShown(false)
    else
        gcdFrame:SetSize(Save.gcdSize*2, Save.gcdSize*2)
        set_GCD_Texture()
        if not Save.notUseColor then
            gcdFrame.cooldown:SetSwipeColor(Color.r, Color.g, Color.b, Color.a)
        end
        if Save.randomTexture then
            gcdFrame:SetScript('OnHide', set_GCD_Texture)
        else
            gcdFrame:SetScript('OnHide', nil)
        end
        gcdFrame:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        gcdFrame:SetAlpha(Save.gcdAlpha)
        gcdFrame.cooldown:SetReverse(Save.gcdReverse)--控制冷却动画的方向
        gcdFrame.cooldown:SetDrawBling(Save.gcdDrawBling)--闪光
    end
end

--设置,GCD,位置
local function set_GCD_Frame_Point()
    local x, y = GetCursorPosition()
    gcdFrame:SetPoint("BOTTOMLEFT", x-Save.gcdSize+Save.gcdX, y-Save.gcdSize+Save.gcdY)
end

--显示GCD图片, 提示用
local function show_GCD_Frame_Tips()
    gcdFrame:SetShown(false)
    set_GCD()
    gcdFrame.cooldown:SetCooldown(GetTime(), 1.171)
    gcdFrame:SetShown(true)
end

--################
--GCD, 添加控制面板
--################
local function Init_GCD_Options()
    if panel.sliderSize or Save.disabledGCD then
        return
    end
    panel.sliderSize = e.CSlider(panel, {min=8, max=128, value=Save.gcdSize, setp=1,
    text=e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gcdSize= value
        show_GCD_Frame_Tips()--显示GCD图片
    end})
    panel.sliderSize:SetPoint("TOPLEFT", panel.gcdCheck, 'BOTTOMLEFT', 0, -20)

    local alphaSlider = e.CSlider(panel, {min=0.1, max=1, value=Save.alpha, setp=0.1, color=true,
    text=e.onlyChinese and '透明度' or 'Alpha',
    func=function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gcdAlpha= value
        show_GCD_Frame_Tips()--显示GCD图片
    end})
    alphaSlider:SetPoint("TOPLEFT", panel.sliderSize, 'BOTTOMLEFT', 0, -20)

    local sliderX = e.CSlider(panel, {min=-100, max=100, value=Save.gcdX , setp=1,
    text='X',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gcdX= value==0 and 0 or value
        show_GCD_Frame_Tips()--显示GCD图片
    end})
    sliderX:SetPoint("TOPLEFT", alphaSlider, 'BOTTOMLEFT', 0, -20)

    local sliderY = e.CSlider(panel, {min=-100, max=100, value=Save.gcdY, setp=1, color=true,
    text='Y',
    func=function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gcdY= value==0 and 0 or value
        show_GCD_Frame_Tips()--显示GCD图片
    end})
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -20)

    local checkReverse=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkReverse:SetChecked(Save.gcdReverse)
    checkReverse.text:SetText(e.onlyChinese and '方向' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION)
    checkReverse:SetScript('OnMouseUp', function()
        Save.gcdReverse = not Save.gcdReverse and true or false
        show_GCD_Frame_Tips()--显示GCD图片
    end)
    checkReverse:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -20)

    local checkDrawBling=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    checkDrawBling:SetChecked(Save.gcdReverse)
    checkDrawBling.text:SetText('|TInterface\\Cooldown\\star4:16|tDrawBling')
    checkDrawBling:SetScript('OnMouseUp', function()
        Save.gcdDrawBling = not Save.gcdDrawBling and true or false
        show_GCD_Frame_Tips()--显示GCD图片
    end)
    checkDrawBling:SetPoint("LEFT", checkReverse.text, 'RIGHT', 2, 00)

    local dropDown = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local delColorButton= WoWTools_ButtonMixin:Cbtn(panel, {icon='hide', size={20,20}})--删除, 按钮
    local addColorEdit= CreateFrame("EditBox", nil, panel, 'InputBoxTemplate')--EditBox
    local addColorButton= WoWTools_ButtonMixin:Cbtn(panel, {icon='hide', size={20,20}})--添加, 按钮
    local numColorText= WoWTools_LabelMixin:CreateLabel(panel, {justifyH='RIGHT'})--nil, nil, nil, nil, nil, 'RIGHT')--颜色，数量
    numColorText:SetPoint('RIGHT', dropDown, 'LEFT', 18,5)
    numColorText:SetText(#Save.GCDTexture)

    local function set_panel_Texture()--大图片
        local texture= Save.GCDTexture[Save.gcdTextureIndex]
        texture= texture or defaultGCDTexture
        panel.Texture:SetTexture(texture)
        addColorEdit:SetText(texture)
        numColorText:SetText(#Save.GCDTexture)
    end

    --下拉，菜单
    local function Init_Menu(self, level, menuList)
        for index, texture in pairs(Save.GCDTexture) do
            local info={
                text= texture,
                icon= texture,
                arg1= index,
                checked= Save.gcdTextureIndex==index,
                func= function(_, arg1)
                    Save.gcdTextureIndex=arg1
                    Save.randomTexture=nil
                    panel.randomTextureCheck:SetChecked(false)
                    e.LibDD:UIDropDownMenu_SetText(self, Save.GCDTexture[arg1])
                    set_panel_Texture()
                    show_GCD_Frame_Tips()--显示GCD图片
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
    dropDown:SetPoint("TOPLEFT", checkReverse, 'BOTTOMLEFT', -18,-15)
    e.LibDD:UIDropDownMenu_SetWidth(dropDown, 180)
    e.LibDD:UIDropDownMenu_Initialize(dropDown, Init_Menu)
    e.LibDD:UIDropDownMenu_SetText(dropDown, Save.GCDTexture[Save.gcdTextureIndex] or defaultGCDTexture)
    dropDown.Button:SetScript('OnMouseDown', function(self) e.LibDD:ToggleDropDownMenu(1,nil,self:GetParent(), self, 15,0) end)

    --删除，图片
    delColorButton:SetPoint('LEFT', dropDown, 'RIGHT',-10,0)
    delColorButton:SetSize(20,20)
    delColorButton:SetNormalAtlas('xmarksthespot')
    delColorButton:SetScript('OnClick', function()
        local texture= Save.GCDTexture[Save.gcdTextureIndex]
        local icon = texture and '|T'..texture..':0|t'
        table.remove(Save.GCDTexture, Save.gcdTextureIndex)
        Save.gcdTextureIndex=1
        print(e.addName, e.cn(addName), e.onlyChinese and '移除' or REMOVE, icon, texture)
        set_panel_Texture()
        show_GCD_Frame_Tips()--显示GCD图片
        addColorEdit:SetText(texture or defaultGCDTexture)
        e.LibDD:UIDropDownMenu_SetText(dropDown, Save.GCDTexture[Save.gcdTextureIndex] or defaultGCDTexture)
        e.LibDD:UIDropDownMenu_Initialize(dropDown, Init_Menu)
    end)

    --添加，自定义，图片
    local function add_Color()
        local text= addColorEdit:GetText() or ''
        if text:gsub(' ','')~='' then
            table.insert(Save.GCDTexture, text)
            addColorEdit:SetText('')
            numColorText:SetText(#Save.GCDTexture)
            e.LibDD:UIDropDownMenu_Initialize(dropDown, Init_Menu)
        end
    end
    addColorEdit:SetPoint("TOPLEFT", dropDown, 'BOTTOMLEFT',22,-2)
	addColorEdit:SetSize(192,20)
	addColorEdit:SetAutoFocus(false)
    addColorEdit:ClearFocus()
    addColorEdit:SetScript('OnTextChanged', function(self, userInput)
        if userInput then
            local text= self:GetText()
            if text:gsub(' ','')~='' then
                panel.Texture:SetTexture(text)
            end
        end
    end)
    addColorEdit:SetScript('OnEnterPressed', add_Color)

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

--##########
--GCD, 初始化
--##########
local function GCD_Init()
    gcdFrame= CreateFrame("Frame")
    gcdFrame:SetFrameStrata("TOOLTIP")

    gcdFrame.cooldown= CreateFrame("Cooldown", nil, gcdFrame, 'CooldownFrameTemplate')
    gcdFrame.cooldown:SetHideCountdownNumbers(true)--隐藏数字
    gcdFrame.cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    gcdFrame.cooldown:SetDrawEdge(true)--冷却动画的移动边缘绘制亮线
    gcdFrame.cooldown:SetUseCircularEdge(true)--设置边缘纹理是否应该遵循圆形图案而不是方形编辑框
    gcdFrame:SetShown(false)

    gcdFrame:SetScript('OnEvent', function(self)
        local data= C_Spell.GetSpellCooldown(61304)

        if not data then
            return
        end
        
        if data.isEnabled and data.startTime and data.startTime > 0 and data.duration and data.duration > 0 then
            self.cooldown:SetCooldown(data.startTime, data.duration, data.modRate)
            self:SetShown(true)
        else
            self:SetShown(false)
        end
    end)

    gcdFrame:SetScript('OnShow', set_GCD_Frame_Point)

    gcdFrame:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed = (self.elapsed or 0.01) + elapsed
        if self.elapsed>0.01 then
            self.elapsed=0
            set_GCD_Frame_Point()
        end
    end)

    set_GCD()--设置 GCD
end
















--######
--初始化
--######
local function Init_Options()
    if (Save.disabled and Save.disabledGCD) or panel.Texture then
        return
    end
    --设置, 大图片
    panel.Texture= panel:CreateTexture()--大图片
    panel.Texture:SetPoint('TOPRIGHT', panel, 'TOP', -20, 10)
    panel.Texture:SetSize(80,80)

    local useClassColorCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--职业颜色
    local colorText= WoWTools_LabelMixin:CreateLabel(panel, {color={r=Save.color.r, g=Save.color.g, b=Save.color.b, a=Save.color.a}})--nil, nil, nil, {Save.color.r, Save.color.g, Save.color.b, Save.color.a})--自定义,颜色
    local notUseColorCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--不使用，颜色

    --职业颜色
    useClassColorCheck:SetPoint("BOTTOMLEFT")
    useClassColorCheck.text:SetText(e.onlyChinese and '职业颜色' or CLASS_COLORS)
    useClassColorCheck.text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    useClassColorCheck:SetChecked(Save.usrClassColor)
    useClassColorCheck:SetScript('OnMouseDown', function()
        Save.usrClassColor= not Save.usrClassColor and true or nil
        Save.notUseColor=nil
        notUseColorCheck:SetChecked(false)
        set_Color()
        if cursorFrame then
            cursor_Init_And_Set()--初始，设置
        end
    end)

    --自定义,颜色
    colorText:SetPoint('LEFT', useClassColorCheck.text, 'RIGHT', 4,0)
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
        local setA, setR, setG, setB
        local function func()
            Save.color= {r=setR, g=setG, b=setB, a=setA}
            self:SetTextColor(setR, setG, setB, setA)
            set_Color()
            if cursorFrame then
                cursor_Init_And_Set()--初始，设置
            end
        end
        WoWTools_ColorMixin:ShowColorFrame(self.r, self.g, self.b,self.a, function()
                setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                func()
            end, function()
                setR, setG, setB, setA= valueR, valueG, valueB, valueA
                if usrClassColor then
                    Save.usrClassColor=true
                    useClassColorCheck:SetChecked(true)
                elseif notUseColor then
                    Save.notUseColor=true
                    notUseColorCheck:SetChecked(true)
                end
                func()
            end
        )
    end)
    colorText:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
        e.tips:Show()
    end)
    colorText:SetScript('OnLeave', GameTooltip_Hide)

    --不使用，颜色
    notUseColorCheck:SetPoint("LEFT", colorText, 'RIGHT')
    notUseColorCheck.text:SetText(e.onlyChinese and '无' or NONE)
    notUseColorCheck:SetChecked(Save.notUseColor)
    notUseColorCheck:SetScript('OnMouseDown', function()
        Save.notUseColor= not Save.notUseColor and true or nil
        Save.useClassColorCheck=nil
        useClassColorCheck:SetChecked(false)
        print(e.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    --随机, 图片
    panel.randomTextureCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    panel.randomTextureCheck:SetPoint("LEFT", notUseColorCheck.text, 'RIGHT', 10,0)
    panel.randomTextureCheck.text:SetText('|TInterface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47:0|t'..(e.onlyChinese and '随机图标' or 'Random '..EMBLEM_SYMBOL))
    panel.randomTextureCheck:SetChecked(Save.randomTexture)
    panel.randomTextureCheck:SetScript('OnMouseDown', function()
        Save.randomTexture= not Save.randomTexture and true or nil
        if cursorFrame then
            cursor_Init_And_Set()--初始，设置
            set_Curor_Random_Event()--随机, 事件
        end
    end)
    panel.randomTextureCheck:SetScript('OnLeave', GameTooltip_Hide)
    panel.randomTextureCheck:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '事件' or EVENTS_LABEL)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('Cursor', (e.onlyChinese and '战斗中: 移动' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..': '..NPE_MOVE))
        e.tips:AddDoubleLine(' ', (e.onlyChinese and '其它' or OTHER)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('GCD', e.GetEnabeleDisable(true))
        e.tips:Show()
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsSave[addName] then
                WoWToolsSave[addName]= Save
            else
                Save= WoWToolsSave[addName]
            end
            set_Color()

            if not Save.GCDTexture then
                Save.GCDTexture={
                    [[Interface\Addons\WoWTools\Sesource\Mouse\Aura73.tga]],
                    [[Interface\Addons\WoWTools\Sesource\Mouse\Aura94.tga]],
                    [[Interface\Addons\WoWTools\Sesource\Mouse\Aura103.tga]],
                    [[Interface\Addons\WoWTools\Sesource\Mouse\Aura142.tga]],
                }
                Save.gcdSize=15
                Save.gcdTextureIndex=1
                Save.gcdAlpha=1
                Save.gcdX=0
                Save.gcdY=0
            end

            e.AddPanel_Sub_Category({name=e.Icon.left..(e.onlyChinese and '鼠标' or MOUSE_LABEL)..'|r', frame=panel})

            e.ReloadPanel({panel=panel, addName= e.cn(addName), restTips=true, checked=nil, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
                disabledfunc=nil,
                clearfunc= function() Save=nil WoWTools_Mixin:Reload() end}
            )

            --Cursor, 启用/禁用
            panel.cursorCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            panel.cursorCheck:SetChecked(not Save.disabled)
            panel.cursorCheck:SetPoint("TOPLEFT", 0, -35)
            panel.cursorCheck.text:SetText('1)'..(e.onlyChinese and '启用' or ENABLE).. ' Cursor')
            panel.cursorCheck:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                if not Save.disabled and not cursorFrame then
                    Cursor_Init()
                end
                if cursorFrame then
                    set_Curor_Random_Event()--随机, 图片，事件
                    cursorFrame:SetShown(not Save.disabled)
                end
                Init_Options()
                Init_Cursor_Options()
            end)

            --GCD, 启用/禁用
            panel.gcdCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
            panel.gcdCheck:SetChecked(not Save.disabledGCD)
            panel.gcdCheck:SetPoint("TOPLEFT", panel, 'TOP', 0, -35)
            panel.gcdCheck.text:SetText('2)'..(e.onlyChinese and '启用' or ENABLE).. ' GCD')
            panel.gcdCheck:SetScript('OnMouseDown', function()
                Save.disabledGCD = not Save.disabledGCD and true or nil
                if not Save.disabledGCD and not gcdFrame then
                    GCD_Init()
                end
                if not Save.disabledGCD then
                    show_GCD_Frame_Tips()--显示GCD图片
                else
                    set_GCD()--设置 GCD
                end
                Init_Options()
                Init_GCD_Options()
            end)

            if not Save.disabled then
                C_Timer.After(2, Cursor_Init)
            end
            if not Save.disabledGCD then
                C_Timer.After(2, GCD_Init)
            end


        elseif arg1=='Blizzard_Settings' then
            Init_Options()
            Init_Cursor_Options()
            Init_GCD_Options()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)