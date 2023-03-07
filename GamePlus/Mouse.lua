local id, e= ...
local addName= MOUSE_LABEL-- = "鼠标"
local Save={
    color={r=0, g=1, b= 0, a=1},
    usrClassColor=true,

    blendMode= 4,
    size=32,--8 64
    gravity=512, -- -512 512
    duration=0.4,--0.1 4
    rotate=32,-- 0 32
    atlsIndex=1,
    rate=0.03,--刷新
    X=40,--移位
    Y=-30,
}
local panel= CreateFrame("Frame")
local  Color
local Atlas={
    'bonusobjectives-bar-starburst',--星星
    'Adventures-Buff-Heal-Burst',--雪
    'OBJFX_StarBurst',--太阳
    'worldquest-questmarker-glow',--空心圆

    'Relic-Frost-TraitGlow',
    'Relic-Holy-TraitGlow',
    'Relic-Arcane-TraitBG',
    'Relic-Blood-TraitBG',
    'Relic-Holy-TraitBG',
    'Relic-Life-TraitBG',
    'Relic-Life-TraitGlow',
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
    'PowerSwirlAnimation-SpinningGlowys-Soulbinds',
}



local max_particles = 1024
local min_distance = 3
local cursor_old_x, cursor_old_y = 0, 0
local cursor_now_x, cursor_now_y = 0, 0
local egim= 0

local blendModeTab ={
    "DISABLE",
    "BLEND",
    "ALPHAKEY",
    "ADD",
    "MOD",
}

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



local set_Update = function(self, elapsed)
    self.elapsed= self.elapsed+ elapsed
    if self.elapsed> Save.rate then
        self.elapsed=0
        cursor_old_x, cursor_old_y = cursor_now_x, cursor_now_y
        cursor_now_x, cursor_now_y = GetCursorPosition()

        local x = cursor_now_x - cursor_old_x
        local y = cursor_now_y - cursor_old_y
        local m = math.sqrt(x * x + y * y)
        local d = min_distance

        if (m > d) then
            egim = atan2((cursor_now_x - cursor_old_x) ,  (cursor_now_y - cursor_old_y))
            create_Particle(self)
        end

        for i = #self.Used, 1, -1 do
            if (update_Particle(self.Used[i], elapsed)) then
                delete_Particle(self, self.Used[i], i)
            end
        end
    end
end

local function frame_Init_Set(self)
    self= self or panel
    local atlsIndex= Save.atlsIndex or random(1, #Atlas)
    if not atlsIndex then
        atlsIndex= random(1,atlsIndex)
    end
    local alts= Atlas[atlsIndex]
    egim= 0
    self.elapsed=0
    self.Pool = self.Pool or {}
    for i = 1, max_particles, 1 do
        self.Pool[i] = self.Pool[i] or UIParent:CreateTexture(nil, "OVERLAY", nil, -8)
        self.Pool[i]:SetAtlas(alts)
        self.Pool[i]:SetVertexColor(Color.r, Color.g, Color.b, Color.a)
        self.Pool[i]:SetBlendMode(blendModeTab[Save.blendMode])
        self.Pool[i]:SetSize(Save.size, Save.size)
        self.Pool[i].life = 0
        self.Pool[i]:Hide()
    end
    if self.Used then
        for i=1, #self.Used do
            self.Used[i]:Hide()
        end
    end
    self.Used = {}
end

--#####
--初始化
--#####
local function Init()
    frame_Init_Set()
    C_Timer.After(2, function()
        panel:SetScript('OnUpdate', set_Update)
    end)
    --frame2= CreateFrame("Frame", Save.texture2)
    --frame_Init_Set(frame2)

    --local frame3= CreateFrame("Frame", Save.texture3)
    --frame_Init_Set(frame3)
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

    local sliderSize= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderSize:SetPoint("TOPLEFT", reloadButton, 'BOTTOMLEFT', 0, -32)
    sliderSize:SetSize(200,20)
    sliderSize:SetMinMaxValues(8, 128)
    sliderSize:SetValue(Save.size)
    sliderSize.Low:SetText((e.onlyChinese and '缩放' or UI_SCALE)..' 8')
    sliderSize.High:SetText('128')
    sliderSize.Text:SetText(Save.size)
    sliderSize:SetValueStep(1)
    sliderSize:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.size= value
        frame_Init_Set()--初始，设置
    end)

    local sliderX= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderX:SetPoint("TOPLEFT", sliderSize, 'BOTTOMLEFT', 0, -16)
    sliderX:SetSize(200,20)
    sliderX:SetMinMaxValues(-100, 100)
    sliderX:SetValue(Save.X)
    sliderX.Low:SetText('x -100')
    sliderX.High:SetText('100')
    sliderX.Text:SetText(Save.X)
    sliderX:SetValueStep(1)
    sliderX:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.X= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end)

    local sliderY= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderY:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0, -16)
    sliderY:SetSize(200,20)
    sliderY:SetMinMaxValues(-100, 100)
    sliderY:SetValue(Save.Y)
    sliderY.Low:SetText('y -100')
    sliderY.High:SetText('100')
    sliderY.Text:SetText(Save.Y)
    sliderY:SetValueStep(1)
    sliderY:SetScript('OnValueChanged', function(self, value, userInput)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.Y= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end)

    local sliderRate= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderRate:SetPoint("TOPLEFT", sliderY, 'BOTTOMLEFT', 0, -16)
    sliderRate:SetSize(200,20)
    sliderRate:SetMinMaxValues(0.001, 0.1)
    sliderRate:SetValue(Save.rate)
    sliderRate.Low:SetText((e.onlyChinese and '刷新' or REFRESH)..'0.001')
    sliderRate.High:SetText('0.1')
    sliderRate.Text:SetText(Save.rate)
    sliderRate:SetValueStep(0.001)
    sliderRate:SetScript('OnValueChanged', function(self, value)
        value= tonumber(format('%.3f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.rate=  value
        frame_Init_Set()--初始，设置
    end)

    local sliderRotate= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderRotate:SetPoint("TOPLEFT", sliderRate, 'BOTTOMLEFT', 0, -16)
    sliderRotate:SetSize(200,20)
    sliderRotate:SetMinMaxValues(0, 32)
    sliderRotate:SetValue(Save.rotate)
    sliderRotate.Low:SetText((e.onlyChinese and '旋转' or HUD_EDIT_MODE_SETTING_MINIMAP_ROTATE_MINIMAP:gsub(MINIMAP_LABEL, ''))..' 0')
    sliderRotate.High:SetText('32')
    sliderRotate.Text:SetText(Save.rotate)
    sliderRotate:SetValueStep(1)
    sliderRotate:SetScript('OnValueChanged', function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.rotate= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end)

    local sliderDuration= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderDuration:SetPoint("TOPLEFT", sliderRotate, 'BOTTOMLEFT', 0, -16)
    sliderDuration:SetSize(200,20)
    sliderDuration:SetMinMaxValues(0.1, 4)
    sliderDuration:SetValue(Save.duration)
    sliderDuration.Low:SetFormattedText(e.onlyChinese and '持续%s' or SPELL_DURATION, '0.1')
    sliderDuration.High:SetText('4')
    sliderDuration.Text:SetText(Save.duration)
    sliderDuration:SetValueStep(0.1)
    sliderDuration:SetScript('OnValueChanged', function(self, value)
        value= tonumber(format('%.1f', value))
        self:SetValue(value)
        self.Text:SetText(value)
        Save.duration=  value
        frame_Init_Set()--初始，设置
    end)

    local sliderGravity= CreateFrame("Slider", nil, panel, 'OptionsSliderTemplate')
    sliderGravity:SetPoint("TOPLEFT", sliderDuration, 'BOTTOMLEFT', 0, -16)
    sliderGravity:SetSize(200,20)
    sliderGravity:SetMinMaxValues(-512, 512)
    sliderGravity:SetValue(Save.gravity)
    sliderGravity.Low:SetText((e.onlyChinese and '掉落' or BATTLE_PET_SOURCE_1).. '-512')
    sliderGravity.High:SetText('512')
    sliderGravity.Text:SetText(Save.gravity)
    sliderGravity:SetValueStep(1)
    sliderGravity:SetScript('OnValueChanged', function(self, value)
        value= math.floor(value)
        self:SetValue(value)
        self.Text:SetText(value)
        Save.gravity= value==0 and 0 or value
        frame_Init_Set()--初始，设置
    end)

    local useClassColorCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    useClassColorCheck:SetPoint("TOPLEFT", panel.check, 'BOTTOMLEFT', 0, -12)
    useClassColorCheck.text:SetText(e.onlyChinese and '职业颜色' or CLASS_COLORS)
    useClassColorCheck.text:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    useClassColorCheck:SetChecked(Save.usrClassColor)
    useClassColorCheck:SetScript('OnMouseDown', function()
        Save.usrClassColor= not Save.usrClassColor and true or nil
        set_Color()
        frame_Init_Set()--初始，设置
    end)

    local colorText= e.Cstr(panel, nil, nil, nil, {Save.color.r, Save.color.g, Save.color.b, Save.color.a})
    colorText:SetPoint('LEFT', useClassColorCheck.text, 'RIGHT', 4,0)
    colorText:SetText(e.onlyChinese and '自定义 ' or CUSTOM )
    colorText:EnableMouse(true)
    colorText.r, colorText.g, colorText.b, colorText.a= Save.color.r, Save.color.g, Save.color.b, Save.color.a
    colorText:SetScript('OnMouseDown', function(self)
        local valueR, valueG, valueB, valueA= self.r, self.g, self.b, self.a
        e.ShowColorPicker(self.r, self.g, self.b,self.a, function(restore)
            local setA, setR, setG, setB
            if not restore then
                setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
            else
                setR, setG, setB, setA= valueR, valueG, valueB, valueA
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
                if not Save.disabled and not frame2 then
                    Init()
                    Init_Options()

                end
                if Save.disabled then
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
                end
            end)

            if not Save.disabled then
                Init()
                Init_Options()
            end
            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)