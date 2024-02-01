local id, e= ...
local addName= TARGET
local Save= {
    target= true,
    targetTextureNewTab={},
    targetTextureName='common-icon-rotateright',

    targetColor= {r=1,g=1,b=1,a=1},--颜色
    targetInCombat=true,--战斗中，提示
    targetInCombatColor={r=1, g=0, b=0, a=1},--战斗中，颜色
    w=40,
    h=20,
    x=0,
    y=0,
    scale=1.5,
    elapsed=0.5,
    targetFramePoint='LEFT',--'TOP', 'HEALTHBAR','LEFT'
    --top=true,--位于，目标血条，上方

    creature= true,--怪物数量
    --creatureRange=40,
    creatureFontSize=10,
    --creatureToUIParet=true,--放在UIPrent

    quest= true,
    --questShowAllFaction=nil,--显示， 所有玩家派系
    questShowPlayerClass=true,--显示，玩家职业
}











local panel= CreateFrame("Frame")
local targetFrame
local CreatureLabel
local isPvPArena, isIns--, isPvPZone
--local isAddOnPlater--C_AddOns.IsAddOnLoaded("Plater")
--[[
local function get_isAddOnPlater(unit)
    if isAddOnPlater and unit then
        local num= unit:match('%d+')
        if num then
            return _G['NamePlate'..num..'PlaterUnitFrameHealthBar']
        end
    end
end]]





















local function set_Target_Color(self, isInCombat)--设置，颜色
    if isInCombat then
        self:SetVertexColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
    else
        self:SetVertexColor(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a)
    end
end
local function set_Target_Size(self)--设置，大小
    if self then
        self:SetSize(Save.w, Save.h)
    end
end


local function set_Scale_Frame()--缩放
    if not targetFrame then
        return
    end
    if targetFrame.Texture and Save.scale~=1 then
        targetFrame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or Save.elapsed) + elapsed
            if self.elapsed> Save.elapsed then
                self.elapsed=0
                self:SetScale(self:GetScale()==1 and Save.scale or 1)
            end
        end)
    else
        targetFrame:SetScript('OnUpdate', nil)
    end
    targetFrame:SetScale(1)
end



















--########################
--怪物目标, 队员目标, 总怪物
--########################
local function set_Creature_Num()--local distanceSquared, checkedDistance = UnitDistanceSquared(u) inRange = CheckInteractDistance(unit, distIndex)
    if not (Save.creature) then
        if CreatureLabel then
            CreatureLabel:SetText('')
        end
        return
    end

    local k,T,F=0,0,0
    local nameplates= C_NamePlate.GetNamePlates() or {}
    for _, nameplat in pairs(nameplates) do
        local u = nameplat.namePlateUnitToken or nameplat.UnitFrame and nameplat.UnitFrame.unit
        local t= u and u..'target'
        --local range= Save.creatureRange>0 and e.CheckRange(u, Save.creatureRange, '<=') or Save.creatureRange==0

        if UnitExists(t) and UnitExists(u)
            and not UnitIsDeadOrGhost(u)
            and not UnitInParty(u)
            and not UnitIsUnit(u,'player')
            and (not isPvPArena or (isPvPArena and UnitIsPlayer(u)))
            and e.CheckRange(u, 40, true)
            then
            if UnitCanAttack('player',u) then
                k=k+1
                if UnitIsUnit(t,'player') then
                    T=T+1
                end
            elseif UnitIsUnit(t,'player') then
                F=F+1
            end
        end
    end
    if IsInGroup() then
        local raid=IsInRaid()
        for i=1, GetNumGroupMembers() do
            local u
            if raid then--团                         
                u='raid'..i
            else--队里
                u='party'..i
            end
            local t=u..'-target'
            if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsUnit(t, 'player') and not UnitIsUnit(u, 'player') then
                F=F+1
            end
        end
    end
    CreatureLabel:SetText(e.Player.col..(T==0 and '-' or  T)..'|r |cff00ff00'..(F==0 and '-' or F)..'|r '..(k==0 and '-' or k))
end


























--#########
--任务，数量
--#########
local THREAT_TOOLTIP_str= THREAT_TOOLTIP:gsub('%%d', '%%d+')--"%d%% 威胁"
local function find_Text(text)
    if text and not text:find(THREAT_TOOLTIP_str) then
        if text:find('(%d+/%d+)') then
            local min, max= text:match('(%d+)/(%d+)')
            min, max= tonumber(min), tonumber(max)
            if min and max and max> min then
                return max- min
            end
            return true
        elseif text:find('[%d%.]+%%') then
            local value= text:match('([%d%.]+%%)')
            if value and value~='100%' then
                return value
            end
            return true
        end
    end
end


local function Get_Quest_Progress(unit)--GameTooltip.lua --local questID= line and line.id
    if not UnitIsPlayer(unit) then
        local type = UnitClassification(unit)
        if type=='rareelite' or type=='rare' or type=='worldboss' then--or type=='elite'
            return '|A:VignetteEvent:18:18|a'
        end
        local tooltipData = C_TooltipInfo.GetUnit(unit)
        if tooltipData and tooltipData.lines then
            for i = 4, #tooltipData.lines do
                local line = tooltipData.lines[i]
                TooltipUtil.SurfaceArgs(line)
                local text= find_Text(line.leftText)
                if text then
                    return text~=true and text
                end
            end
        end

    elseif not (UnitInParty(unit) or UnitIsUnit('player', unit)) then--if not isIns and isPvPZone and not UnitInParty(unit) then
        local wow= e.GetFriend(nil, UnitGUID(unit), nil)--检测, 是否好友
        local faction= e.GetUnitFaction(unit, nil, Save.questShowAllFaction)--检查, 是否同一阵营
        local text
        if Save.questShowPlayerClass then
            text= e.Class(unit)
        end
        if wow or faction then
            text= (text or '')..(wow or '')..(faction or '')
        end
        return text
    --[[else
        return e.Class(unit)--职业图标]]
    end
end

local function set_questProgress_Text(plate, unit)
    local self= plate and plate.UnitFrame
    if not self then
        return
    end
    local text
    if Save.quest then
        text= Get_Quest_Progress(unit)
        if text and not self.questProgress then
            self.questProgress= e.Cstr(self, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
            self.questProgress:SetPoint('LEFT', self.healthBar or self, 'RIGHT', 2,0)
        end
    end
    if self.questProgress then
        self.questProgress:SetText(text or '')
    end
end



local function set_check_allQust_Plates()
    if not Save.quest or isIns then
        for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
            if plate.UnitFrame.questProgress then
                plate.UnitFrame.questProgress:SetText('')
            end
        end
    else
        for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
            set_questProgress_Text(plate, plate.namePlateUnitToken or plate.UnitFrame and plate.UnitFrame.unit)
        end
    end
end

































--##########################
--设置,指示目标,位置,显示,隐藏
--##########################
local function set_Target()
    local plate= C_NamePlate.GetNamePlateForUnit("target",  issecure())
    if plate then
        local self = plate.UnitFrame
        local frame--= get_isAddOnPlater(plate.UnitFrame.unit)--C_AddOns.IsAddOnLoaded("Plater")
        targetFrame:ClearAllPoints()
        if Save.targetFramePoint=='TOP' then
            if self.SoftTargetFrame.Icon:IsShown() then
                frame= self.SoftTargetFrame
            else
                frame= self.name or self.healthBar
            end
            targetFrame:SetPoint('BOTTOM', frame or self, 'TOP', Save.x, Save.y)

        elseif Save.targetFramePoint=='HEALTHBAR' then
            frame= self.healthBar or self.name or self
            local w, h= frame:GetSize()
            w= w+ Save.w
            h= h+ Save.h
            local n, p
            if self.RaidTargetFrame.RaidTargetIcon:IsVisible() then
                n= self.RaidTargetFrame.RaidTargetIcon:GetWidth()+ self.ClassificationFrame.classificationIndicator:GetWidth()
            elseif self.ClassificationFrame.classificationIndicator:IsVisible() then
                n= self.ClassificationFrame.classificationIndicator:GetWidth()
            end
            if self.questProgress then
                p= self.questProgress:GetWidth()
            end
            n, p= n or 0, p or 0
            targetFrame:SetSize(w+ n+ p, h)
            targetFrame:SetPoint('CENTER', self, Save.x+ (-n+p)/2, Save.y)
        else
            if self.RaidTargetFrame.RaidTargetIcon:IsVisible() then
                frame= self.RaidTargetFrame
            elseif self.ClassificationFrame.classificationIndicator:IsVisible() then
                frame= self.ClassificationFrame.classificationIndicator
            else
                frame= self.healthBar or self.name
            end
            targetFrame:SetPoint('RIGHT', frame or self, 'LEFT',Save.x, Save.y)
        end
        targetFrame:SetShown(true)
    else
        targetFrame:SetShown(false)
    end
end


































--####################################
--设置 targetFrame Target Creature 属性
--####################################
local function set_Created_Texture_Text()
    if  Save.targetFramePoint~='HEALTHBAR' then
        set_Target_Size(targetFrame)--设置，大小
    end
    if not targetFrame.Texture and Save.target then
        targetFrame.Texture= targetFrame:CreateTexture(nil, 'BACKGROUND')
        targetFrame.Texture:SetAllPoints(targetFrame)
    end

    if targetFrame.Texture then
        local isAtlas, texture= e.IsAtlas(Save.targetTextureName)--设置，图片
        if isAtlas then
            targetFrame.Texture:SetAtlas(texture)
        else
            targetFrame.Texture:SetTexture(texture or 0)
        end
        set_Scale_Frame()--缩放
        set_Target_Color(targetFrame.Texture, Save.targetInCombat and UnitAffectingCombat('player'))
        targetFrame.Texture:SetShown(Save.target)
    end

    --怪物数量
    if not CreatureLabel and Save.creature then
        CreatureLabel= e.Cstr(targetFrame, {size=Save.creatureFontSize, color={r=1,g=1,b=1}, layer='BORDER'})--10, nil, nil, {1,1,1}, 'BORDER', 'RIGHT')
        function CreatureLabel:set_point()
            self:ClearAllPoints()
            if Save.targetFramePoint=='LEFT' then
                self:SetPoint('CENTER')
                self:SetJustifyH('RIGHT')
            else
                self:SetPoint('BOTTOM', 0, 8)
                self:SetJustifyH('CENTER')
            end
        end
        CreatureLabel:SetTextColor(1,1,1)
    elseif CreatureLabel then
        e.Cstr(nil, {changeFont=CreatureLabel, size= Save.creatureFontSize})
        CreatureLabel:set_point()
    end

   set_Target()
   set_Creature_Num()
   set_check_allQust_Plates()
end

































--####
--事件
--####
local function set_Register_Event()
    isPvPArena= C_PvP.IsBattleground() or C_PvP.IsArena()
    isIns=  isPvPArena
            or (IsInInstance()
                and (GetNumGroupMembers()>3 or C_ChallengeMode.IsChallengeModeActive())
            )


    targetFrame:UnregisterAllEvents()
    targetFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

    if Save.target or Save.creature then
        targetFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
        targetFrame:RegisterEvent('RAID_TARGET_UPDATE')
        targetFrame:RegisterUnitEvent('UNIT_FLAGS', 'target')
        targetFrame:RegisterEvent('CVAR_UPDATE')
    end

    if Save.target and Save.targetInCombat then
        targetFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
        targetFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
    end

    if Save.creature then
        targetFrame:RegisterEvent('UNIT_TARGET')
    end


    if (not isIns and Save.quest) or Save.creature then
        targetFrame:RegisterEvent('NAME_PLATE_UNIT_ADDED')
        targetFrame:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
    end

    if not isIns and Save.quest  then
        targetFrame:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
        targetFrame:RegisterEvent('SCENARIO_UPDATE')
        targetFrame:RegisterEvent('SCENARIO_CRITERIA_UPDATE')
        targetFrame:RegisterEvent('SCENARIO_COMPLETED')
        targetFrame:RegisterEvent('QUEST_POI_UPDATE')
    end
end





local function set_All_Init()
    do
        set_Register_Event()
    end
    set_Created_Texture_Text()
end

































--####
--初始
--####
local function Init()
    targetFrame= CreateFrame("Frame")
    set_All_Init()

    hooksecurefunc(NamePlateDriverFrame, 'OnSoftTargetUpdate', function()
        if Save.targetFramePoint=='TOP' then
            set_Target()
        end
    end)
    targetFrame:SetScript("OnEvent", function(_, event, arg1)
        if event=='PLAYER_TARGET_CHANGED'
            or event=='RAID_TARGET_UPDATE'
            or event=='UNIT_FLAGS'
        then
            C_Timer.After(0.15, set_Target)

        elseif event=='CVAR_UPDATE' and (arg1=='nameplateShowAll' or arg1=='nameplateShowEnemies' or arg1=='nameplateShowFriends') then
            set_check_allQust_Plates()
            C_Timer.After(0.15, set_Target)

        elseif event=='PLAYER_ENTERING_WORLD' then
            set_All_Init()

        elseif event=='PLAYER_REGEN_DISABLED' then--颜色
            set_Target_Color(targetFrame.Texture, true)

        elseif event=='PLAYER_REGEN_ENABLED' then
            set_Target_Color(targetFrame.Texture, false)

        elseif event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
            C_Timer.After(2, function() set_check_allQust_Plates() end)

        else
            if not isIns and arg1 then
                if event=='NAME_PLATE_UNIT_ADDED' then
                    set_questProgress_Text(C_NamePlate.GetNamePlateForUnit(arg1,  issecure()), arg1)

                elseif event=='NAME_PLATE_UNIT_REMOVED' then
                    local plate = C_NamePlate.GetNamePlateForUnit(arg1,  issecure())
                    if plate and plate.UnitFrame and plate.UnitFrame.questProgress then
                        plate.UnitFrame.questProgress:SetText('')
                    end
                end
            end
            set_Creature_Num()
        end
    end)
end


























--#################
--选项, 添加控制面板      
--#################
local function set_Option()
    if panel.tipTargetTexture or Save.disabled then
        return
    end

    local sel=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel:SetPoint('TOPLEFT', 0, -40)
    sel:SetChecked(Save.target)
    sel:SetScript('OnClick', function()
        Save.target= not Save.target and true or nil
        set_All_Init()
    end)
    sel.Text:SetText(e.Icon.toRight2..(e.onlyChinese and '目标' or addName))
    sel.Text:SetTextColor( Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a)
    sel.Text:EnableMouse(true)
    sel.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a
            local function func()
                Save.targetColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(panel.tipTargetTexture, false)
                set_All_Init()
            end
            e.ShowColorPicker(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a, function()
                    setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save.targetColor={r=1, g=1, b=1, a=1}
            self2:SetTextColor(1, 1, 1, 1)
            set_Target_Color(panel.tipTargetTexture, false)
            set_All_Init()
        end
    end)
    sel.Text:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    sel.Text:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.onlyChinese and '显示敌方姓名板' or BINDING_NAME_NAMEPLATES, e.GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
        e.tips:AddLine(' ')
        local r,g,b,a= Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a
        e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), (e.onlyChinese and '默认' or DEFAULT)..e.Icon.right, r,g,b, 1,1,1)
        e.tips:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        e.tips:AddLine(' ')
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)

    panel.tipTargetTexture= panel:CreateTexture()--目标，图片，提示
    panel.tipTargetTexture:SetPoint("TOP")
    --set_Target_Texture(panel.tipTargetTexture)--设置，图片
    set_Target_Size(panel.tipTargetTexture)--设置，大小
    set_Target_Color(panel.tipTargetTexture, false)--设置，颜色

    local combatCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    combatCheck:SetPoint('LEFT', sel.Text, 'RIGHT', 15,0)
    combatCheck:SetChecked(Save.targetInCombat)
    combatCheck:SetScript('OnClick', function()
        Save.targetInCombat= not Save.targetInCombat and true or nil
        set_All_Init()
    end)
    combatCheck.Text:EnableMouse(true)
    combatCheck.Text:SetText(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    combatCheck.Text:SetTextColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
    combatCheck.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a
            local function func()
                Save.targetInCombatColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(panel.tipTargetTexture, true)
                set_All_Init()
            end
            e.ShowColorPicker(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a, function()
                    setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save.targetInCombatColor={r=1, g=0, b=0, a=1}
            self2:SetTextColor(1, 0, 0, 1)
            set_Target_Color(panel.tipTargetTexture, false)
            set_All_Init()
        end
    end)
    combatCheck.Text:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    combatCheck.Text:SetScript('OnEnter', function(self2)
        local r,g,b,a= Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), (e.onlyChinese and '默认' or DEFAULT)..e.Icon.right, r,g,b, 1,1,1)
        e.tips:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)

    --[[local topCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    topCheck:SetPoint('LEFT', combatCheck.Text, 'RIGHT', 15,0)
    topCheck:SetChecked(Save.top)
    topCheck.Text:SetText('TOP')
    topCheck:SetScript('OnClick', function()
        Save.top= not Save.top and true or nil
        set_All_Init()
    end)]]
    local menuPoint = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    menuPoint:SetPoint("LEFT", combatCheck.Text, 'RIGHT', 15, 0)
    e.LibDD:UIDropDownMenu_SetWidth(menuPoint, 100)
    e.LibDD:UIDropDownMenu_Initialize(menuPoint, function(self, level)
        local tab={
            'TOP',
            'HEALTHBAR',
            'LEFT'
        }
        for _, name in pairs(tab) do
            local info={
                text= name,
                checked= Save.targetFramePoint==name,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '位置' or CHOOSE_LOCATION,
                arg1= name,
                func= function(_, arg1)
                    Save.targetFramePoint= arg1
                    e.LibDD:UIDropDownMenu_SetText(self, arg1)
                    set_All_Init()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end)
    e.LibDD:UIDropDownMenu_SetText(menuPoint, Save.targetFramePoint)

    menuPoint.Button:SetScript('OnClick', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    local sliderX = e.CSlider(panel, {min=-250, max=250, value=Save.x, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.x= value
        set_All_Init()
    end})
    sliderX:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT',0, -12)
    local sliderY = e.CSlider(panel, {min=-250, max=250, value=Save.y, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.y= value
        set_All_Init()
    end})
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT',15,0)
    local sliderW = e.CSlider(panel, {min=10, max=100, value=Save.w, setp=1, w= 100,
    text= 'W',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.w= value
        set_Target_Size(panel.tipTargetTexture)--设置，大小
        set_All_Init()
    end})
    sliderW:SetPoint("LEFT", sliderY, 'RIGHT',15,0)
    local sliderH = e.CSlider(panel, {min=10, max=100, value=Save.h, setp=1, w= 100, color=true,
    text= 'H',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.h= value
        set_Target_Size(panel.tipTargetTexture)--设置，大小
        set_All_Init()
    end})
    sliderH:SetPoint("LEFT", sliderW, 'RIGHT',15,0)



    local sliderScale = e.CSlider(panel, {min=0.4, max=2, value=Save.scale or 1, setp=0.1, w= 100,
    text= e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.scale= value
        if value==1 then
            print(id,e.cn(addName),'|cnRED_FONT_COLOR:', e.onlyChinese and '禁用' or DISABLE)
        else
            print(id,e.cn(addName), '|cnGREEN_FONT_COLOR:', value)
        end
        set_Scale_Frame()--缩放
    end})
    sliderScale:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0,-16)

    local sliderElapsed = e.CSlider(panel, {min=0.3, max=1.5, value=Save.elapsed or 0.5, setp=0.1, w= 100, color=true,
    text= e.onlyChinese and '速度' or SPEED,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.elapsed= value
    end})
    sliderElapsed:SetPoint("LEFT", sliderScale, 'RIGHT',15, 0)


    local menu = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    menu:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT', -16,-82)
    e.LibDD:UIDropDownMenu_SetWidth(menu, 410)
    e.LibDD:UIDropDownMenu_Initialize(menu, function(self, level)
        local tab={
            ['common-icon-rotateright']='a',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Hunters_Mark.tga']='t',
            ['NPE_ArrowDown']='a',
            ['UI-HUD-MicroMenu-StreamDLYellow-Up']='a',
            ['Interface\\AddOns\\WeakAuras\\Media\\Textures\\targeting-mark.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Reticule.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\RedArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NeonReticule.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NeonRedArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\RedChevronArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\PaleRedChevronArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\arrow_tip_green.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\arrow_tip_red.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\skull.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\circles_target.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\red_star.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\greenarrowtarget.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\BlueArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\bluearrow1.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\gearsofwar.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\malthael.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NewRedArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NewSkull.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\PurpleArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Shield.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NeonGreenArrow.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_FelFlamingSkull.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_RedFlamingSkull.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_ShadowFlamingSkull.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_GreenGPS.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_RedGPS.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_WhiteGPS.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_GreenTarget.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_RedTarget.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_WhiteTarget.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_Towards.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_Away.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_SelfTowards.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_SelfAway.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FriendTowards.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FriendAway.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FocusTowards.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FocusAway.tga']='t',
            ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\green_arrow_down_11384.tga']='t',
        }
        for name, _ in pairs(Save.targetTextureNewTab) do
            if tab[name] then
                Save.targetTextureNewTab[name]=nil
            else
                tab[name]= 'use'
            end
        end
        for name, use in pairs(tab) do
            local isAtlas, texture= e.IsAtlas(name)
            if texture then
                local info={
                    
                    text= name:match('.+\\(.+)%.') or name,
                    icon= name,
                    colorCode= use=='use' and '|cff00ff00' or (isAtlas and '|cffff00ff') or nil,
                    tooltipOnButton=true,
                    tooltipTitle= isAtlas and 'Atls' or 'Texture',
                    tooltipText= use=='use' and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自定义' or CUSTOM) or nil,
                    arg1= name,
                    arg2= isAtlas,
                    checked= Save.targetTextureName==name,
                    func= function(_, arg1)
                        Save.targetTextureName= arg1
                        e.LibDD:UIDropDownMenu_SetText(self, arg1)
                        self.edit:SetText(arg1)
                        set_All_Init()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    e.LibDD:UIDropDownMenu_SetText(menu, Save.targetTextureName)
    menu.Button:SetScript('OnClick', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    menu.edit= CreateFrame("EditBox", nil, menu, 'InputBoxTemplate')--EditBox
    menu.edit:SetPoint("TOPLEFT", menu, 'BOTTOMLEFT',22,-2)
	menu.edit:SetSize(420,22)
	menu.edit:SetAutoFocus(false)
    menu.edit:ClearFocus()
    menu.edit.Label= e.Cstr(menu.edit)
    menu.edit.Label:SetPoint('RIGHT', menu.edit, 'LEFT', -4, 0)
    menu.edit:SetScript('OnShow', function(self)
        self:SetText(Save.targetTextureName)
    end)
    menu.edit:SetScript('OnTextChanged', function(self)
        local name, isAtlas
        name= self:GetText() or ''
        name= name:gsub(' ', '')
        name= name=='' and false or name
        if name then
            isAtlas, name= e.IsAtlas(name)
            if name then
                if isAtlas then
                    panel.tipTargetTexture:SetAtlas(name)
                else
                    panel.tipTargetTexture:SetTexture(name)
                end
                self.Label:SetText(isAtlas and 'Atls' or 'Texture')
            else
                panel.tipTargetTexture:SetTexture(0)
            end
        end
        self.del:SetShown(name and Save.targetTextureNewTab[name])
        self.add:SetShown(name and not Save.targetTextureNewTab[name])
    end)

    --删除，图片
    menu.edit.del= e.Cbtn(menu.edit, {atlas='xmarksthespot', size={20,20}})
    menu.edit.del:SetPoint('LEFT', menu, 'RIGHT',-10,0)
    menu.edit.del:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtals, name= e.IsAtlas(parent:GetText())
        if name and Save.targetTextureNewTab[name] then
            Save.targetTextureNewTab[name]= nil
            print(id, e.cn(addName),
                '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r',
                (isAtals and '|A:'..name..':0:0|a' or ('|T'..name..':0|t'))..name
            )
            e.LibDD:UIDropDownMenu_SetText(menu, '')
            parent:SetText("")
            parent:SetText(name)
        end
    end)

    --添加按钮
    menu.edit.add= e.Cbtn(menu.edit, {atlas=e.Icon.select, size={20,20}})--添加, 按钮
    menu.edit.add:SetPoint('LEFT', menu.edit, 'RIGHT', 5,0)
    menu.edit.add:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtlas, icon= e.IsAtlas(parent:GetText())
        if icon and not Save.targetTextureNewTab[icon] then
            Save.targetTextureNewTab[icon]= isAtlas and 'a' or 't'
            parent:SetText('')
            print(id,
                e.cn(addName),
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r',
                (isAtlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'))..icon
            )
        end
    end)
    menu.edit.add:SetScript('OnLeave', GameTooltip_Hide)
    menu.edit.add:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        local atlas, icon= e.IsAtlas(menu.edit:GetText())
        if icon then
            e.tips:AddDoubleLine(atlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'), e.onlyChinese and '添加' or ADD)
            e.tips:AddDoubleLine(atlas and 'Atlas' or 'Texture', icon)
        else
            e.tips:AddLine(e.onlyChinese and '无' or NONE)
        end
        e.tips:Show()
    end)





    local sel2=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel2.Text:SetText(e.onlyChinese and e.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r'
                or (e.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
            )
    sel2:SetPoint('TOPLEFT', menu.edit, 'BOTTOMLEFT', -32, -60)
    sel2:SetChecked(Save.creature)
    sel2:SetScript('OnClick', function()
        Save.creature= not Save.creature and true or nil
        set_All_Init()
    end)

    --[[local sliderRange = e.CSlider(panel, {min=0, max=60, value=Save.creatureRange, setp=1, w= 100 ,
    text=format(e.onlyChinese and '码' or IN_GAME_NAVIGATION_RANGE, ''),
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.creatureRange= value
        set_All_Init()
    end})
    sliderRange:SetPoint("TOPLEFT", sel2.Text, 'BOTTOMLEFT',0, -16)]]

    local sliderCreatureFontSize = e.CSlider(panel, {min=8, max=32, value=Save.creatureFontSize, setp=1, w=100, color=true,
    text= e.Player.L.size,
    func=function(self2, value)--字体大小
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.creatureFontSize= value
        set_All_Init()
    end})
    sliderCreatureFontSize:SetPoint("LEFT", sel2.Text, 'RIGHT',15,0)

    local questCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questCheck.Text:SetText(e.onlyChinese and '任务进度' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, PVP_PROGRESS_REWARDS_HEADER)))
    questCheck:SetPoint('TOPLEFT', sel2, 'BOTTOMLEFT',0,-86)
    questCheck:SetChecked(Save.quest)
    questCheck:SetScript('OnClick', function()
        Save.quest= not Save.quest and true or nil
        set_All_Init()
    end)

    local questAllFactionCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questAllFactionCheck.Text:SetText((e.onlyChinese and '提示所有阵营' or (SHOW..'('..ALL..')'..FACTION))..e.Icon.horde2..e.Icon.alliance2)
    questAllFactionCheck:SetPoint('LEFT', questCheck.Text, 'RIGHT',2,0)
    questAllFactionCheck:SetChecked(Save.questShowAllFaction)
    questAllFactionCheck:SetScript('OnClick', function()
        Save.questShowAllFaction= not Save.questShowAllFaction and true or nil
        set_All_Init()
    end)

    local classCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    classCheck.Text:SetText(e.onlyChinese and '职业' or CLASS)
    classCheck:SetPoint('LEFT', questAllFactionCheck.Text, 'RIGHT',2,0)
    classCheck:SetChecked(Save.questShowPlayerClass)
    classCheck:SetScript('OnClick', function()
        Save.questShowPlayerClass= not Save.questShowPlayerClass and true or nil
        set_All_Init()
    end)
end



































panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Save.targetTextureTab= nil
            Save.targetTextureNewTab= Save.targetTextureNewTab or {}

            Save.targetTextureName= Save.targetTextureName or 'common-icon-rotateright'
            Save.targetColor= Save.targetColor or {r=1,g=1,b=1,a=1}
            Save.targetInCombatColor= Save.targetInCombatColor or {r=1, g=0, b=0, a=1}
            Save.scale= Save.scale or 1.5
            Save.elapsed= Save.elapsed or 0.5

            if Save.top then--1.4.10删除数据
                Save.targetFramePoint= 'TOP'
                Save.top=nil
            else
                Save.targetFramePoint= Save.targetFramePoint or 'LEFT'
            end

            --添加控制面板
            e.AddPanel_Sub_Category({name=e.Icon.toRight2..(e.onlyChinese and '目标指示' or addName)..'|r', frame=panel})

            e.ReloadPanel({panel=panel, addName= e.cn(addName), restTips=nil, checked=not Save.disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
                disabledfunc=function()
                    Save.disabled= not Save.disabled and true or nil
                    if not targetFrame and not Save.disabled  then
                        set_Option()
                        Init()
                    end
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), Save.disabled and (e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')
                end,
                clearfunc= function() Save=nil e.Reload() end}
            )

            if not Save.disabled then
                Init()
            end
        elseif arg1=='Blizzard_Settings' then
            set_Option()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
--NamePlate2PlaterUnitFrameHealthBar