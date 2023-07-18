local id, e= ...
local addName= TARGET
local Save= {
    target= true,
    targetTextureTab={
        ['common-icon-rotateright']='atlas',
    },
    targetTextureName='common-icon-rotateright',

    targetInCombat=true,--战斗中，提示
    targetInCombatColor={r=1, g=0, b=0, a=1},--战斗中，颜色
    w=40,
    h=20,
    x=0,
    y=0,
    --top=true,--位于，目标血条，上方

    creature= true,--怪物数量
    creatureRange=35,
    creatureFontSize=10,

    quest= true,
    --questShowAllFaction=nil,--显示， 所有玩家派系
    questShowPlayerClass=true,--显示，玩家职业
}

local panel= CreateFrame("Frame")
local targetFrame
local isPvPArena, isIns--, isPvPZone
--local isAddOnPlater--IsAddOnLoaded("Plater")
--[[
local function get_isAddOnPlater(unit)
    if isAddOnPlater and unit then
        local num= unit:match('%d+')
        if num then
            return _G['NamePlate'..num..'PlaterUnitFrameHealthBar']
        end
    end
end]]

local function set_Target_Texture(self)--设置，图片
    if self then
        if Save.targetTextureTab[Save.targetTextureName]=='atlas' then
            self:SetAtlas(Save.targetTextureName)
        else
            self:SetTexture(Save.targetTextureName)
        end
    end
end
local function set_Target_Color(self, isInCombat)--设置，颜色
    if isInCombat then
        self:SetVertexColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
    else
        self:SetVertexColor(1,1,1,1)
    end
end
local function set_Target_Size(self)--设置，大小
    if self then
        self:SetSize(Save.w, Save.h)
    end
end

--########################
--怪物目标, 队员目标, 总怪物
--########################
--local distanceSquared, checkedDistance = UnitDistanceSquared(u)
local createRun
local function set_Creature_Num()
    if not (Save.creature and targetFrame:IsShown()) or createRun then
        return
    end
    createRun=true
    local k,T,F=0,0,0
    local nameplates= C_NamePlate.GetNamePlates() or {}
    for _, nameplat in pairs(nameplates) do
        local u = nameplat.namePlateUnitToken or nameplat.UnitFrame and nameplat.UnitFrame.unit
        local t= u and u..'target'
        local range= Save.creatureRange>0 and e.CheckRange(u, Save.creatureRange, '<=') or Save.creatureRange==0
        if t and UnitExists(u)
            and not UnitIsDeadOrGhost(u)
            and not UnitInParty(u)
            and not UnitIsUnit(u,'player')
            and (not isPvPArena or (isPvPArena and UnitIsPlayer(u)))
            and range
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
            if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsUnit(t, 'player') and not UnitIsUnit(u,'player') then
                F=F+1
            end
        end
    end
    targetFrame.Creature:SetText(e.Player.col..(T==0 and '-' or  T)..'|r |cff00ff00'..(F==0 and '-' or F)..'|r '..(k==0 and '-' or k))
    createRun=nil
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
        for i = 4, #tooltipData.lines do
            local line = tooltipData.lines[i]
            TooltipUtil.SurfaceArgs(line)
            local text= find_Text(line.leftText)
            if text then
                return text~=true and text
            end
        end

    elseif not UnitInParty(unit) then--if not isIns and isPvPZone and not UnitInParty(unit) then
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
    if UnitExists(unit) and plate and plate.UnitFrame and Save.quest then
        local text= Get_Quest_Progress(unit)
        if text and not plate.questProgress then
            local frame=  plate.UnitFrame and plate.UnitFrame.healthBar or plate
            plate.questProgress= e.Cstr(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
            plate.questProgress:SetPoint('LEFT', frame, 'RIGHT', 2,0)
        end
        if plate.questProgress then
            plate.questProgress:SetText(text or '')
        end
    end
end

local questChanging
local function set_check_All_Plates()
    local plates= C_NamePlate.GetNamePlates() or {}
    if not Save.quest then--清除
        for _, plate in pairs(plates) do
            if plate.questProgress then
                plate.questProgress:SetText('')
            end
        end
        questChanging=nil
    elseif not questChanging then--设置
        questChanging=true
        for _, plate in pairs(plates) do
            set_questProgress_Text(plate, plate.namePlateUnitToken or plate.UnitFrame and plate.UnitFrame.unit)
        end
        questChanging=nil
    end

end

--##########################
--设置,指示目标,位置,显示,隐藏
--##########################
local function set_Target()
    local plate = C_NamePlate.GetNamePlateForUnit("target")
    if plate and plate.UnitFrame then
        local frame--= get_isAddOnPlater(plate.UnitFrame.unit)--IsAddOnLoaded("Plater")
        if not frame then
            if plate.UnitFrame.RaidTargetFrame and plate.UnitFrame.RaidTargetFrame.RaidTargetIcon:IsShown() then
                frame= plate.UnitFrame.RaidTargetFrame
            elseif plate.UnitFrame.ClassificationFrame and plate.UnitFrame.ClassificationFrame.classificationIndicator:IsShown() then
                frame= plate.UnitFrame.ClassificationFrame.classificationIndicator
            elseif plate.UnitFrame.healthBar then
                frame= plate.UnitFrame.healthBar
            end
        end

        targetFrame:ClearAllPoints()
        if Save.top then
            targetFrame:SetPoint('BOTTOM', frame or plate, 'TOP', Save.x, Save.y)
        else
            targetFrame:SetPoint('RIGHT', frame or plate, 'LEFT',Save.x, Save.y)
        end
        if Save.target then
           targetFrame.Target:SetShown(true)
        end
        set_Creature_Num()
    end
    targetFrame:SetShown(plate and true or false)
end


--####################################
--设置 targetFrame Target Creature 属性
--####################################
local function set_Created_Texture_Text()
    set_Target_Size(targetFrame)--设置，大小
    if not targetFrame.Target and Save.target then
        targetFrame.Target= targetFrame:CreateTexture(nil, 'BACKGROUND')
        targetFrame.Target:SetAllPoints(targetFrame)
    end
    set_Target_Texture(targetFrame.Target)--设置，图片
    if targetFrame.Target then
        set_Target_Color(targetFrame.Target, Save.targetInCombat and UnitAffectingCombat('player'))
        targetFrame.Target:SetShown(false)
    end
    if not targetFrame.Creature and Save.creature then
        targetFrame.Creature= e.Cstr(targetFrame, {size=Save.creatureFontSize, color={r=1,g=1,b=1}, layer='BORDER', justifyH='RIGHT'})--10, nil, nil, {1,1,1}, 'BORDER', 'RIGHT')
        targetFrame.Creature:SetPoint('RIGHT', -8, 0)
        targetFrame.Creature:SetTextColor(1,1,1)
    end
    if targetFrame.Creature then
        targetFrame.Creature:SetText('')
    end
    targetFrame:SetShown(false)
end


--####
--事件
--####
local function set_Register_Event()
    --isPvPArena= C_PvP.IsBattleground() or C_PvP.IsArena()
    isIns= IsInInstance() and GetNumGroupMembers()>2 or C_PvP.IsBattleground() or C_PvP.IsArena()

    targetFrame:UnregisterAllEvents()
    targetFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

    if Save.target or Save.creature then
        targetFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
        targetFrame:RegisterEvent('RAID_TARGET_UPDATE')
        targetFrame:RegisterUnitEvent('UNIT_FLAGS', 'target')
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

--####
--初始
--####
local function Init()
    targetFrame= CreateFrame("Frame")
    set_Created_Texture_Text()
    set_Register_Event()
    set_check_All_Plates()

    targetFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_TARGET_CHANGED' or event=='PLAYER_ENTERING_WORLD' or event=='RAID_TARGET_UPDATE' or event=='UNIT_FLAGS' then
            C_Timer.After(0.15, set_Target)

            if event=='PLAYER_ENTERING_WORLD' then
                set_Register_Event()
            end

        elseif event=='PLAYER_REGEN_DISABLED' then--颜色
            set_Target_Color(targetFrame.Target, true)

        elseif event=='PLAYER_REGEN_ENABLED' then
            set_Target_Color(targetFrame.Target, false)

        elseif event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
            C_Timer.After(2, set_check_All_Plates)

        else
            if not isIns and arg1 then
                if event=='NAME_PLATE_UNIT_ADDED' then
                    set_questProgress_Text(C_NamePlate.GetNamePlateForUnit(arg1), arg1)

                elseif event=='NAME_PLATE_UNIT_REMOVED' then
                    local plate = C_NamePlate.GetNamePlateForUnit(arg1)
                    if plate and plate.questProgress then
                        plate.questProgress:SetText('')
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
    local sel=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel:SetPoint('TOPLEFT', 0, -40)
    sel.Text:SetText(e.Icon.toRight2..(e.onlyChinese and '目标' or addName))
    sel:SetChecked(Save.target)
    sel:SetScript('OnClick', function()
        Save.target= not Save.target and true or nil
        set_Register_Event()
        set_Created_Texture_Text()
    end)
    sel:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.onlyChinese and '显示敌方姓名板' or BINDING_NAME_NAMEPLATES, e.GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
        e.tips:Show()
    end)
    sel:SetScript('OnLeave', function() e.tips:Hide() end)

    panel.tipTargetTexture= panel:CreateTexture()--目标，图片，提示
    panel.tipTargetTexture:SetPoint("TOP")
    set_Target_Texture(panel.tipTargetTexture)--设置，图片
    set_Target_Size(panel.tipTargetTexture)--设置，大小

    local combatCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    combatCheck:SetPoint('LEFT', sel.Text, 'RIGHT', 15,0)
    combatCheck:SetChecked(Save.targetInCombat)
    combatCheck:SetScript('OnClick', function()
        Save.targetInCombat= not Save.targetInCombat and true or nil
        set_Register_Event()
        set_Created_Texture_Text()
        set_Target()
    end)
    combatCheck.Text:EnableMouse(true)
    combatCheck.Text:SetText(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    combatCheck.Text:SetTextColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
    combatCheck.Text:SetScript('OnMouseDown', function(self2)
        local setR, setG, setB, setA
        local R,G,B,A= Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a
        local function func()
            Save.targetInCombatColor={r=setR, g=setG, b=setB, a=setA}
            self2:SetTextColor(setR, setG, setB, setA)
            set_Target_Color(panel.tipTargetTexture, true)
        end
        e.ShowColorPicker(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a, function()
                setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                func()
            end, function()
                setR, setG, setB, setA= R,G,B,A
                func()
            end
        )
    end)
    combatCheck.Text:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    combatCheck.Text:SetScript('OnEnter', function(self2)
        local r,g,b,a= Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.Icon.toRight2..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT), (e.onlyChinese and '颜色' or COLOR)..e.Icon.left, r,g,b, r,g,b)
        e.tips:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)

    local topCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    topCheck:SetPoint('LEFT', combatCheck.Text, 'RIGHT', 15,0)
    topCheck:SetChecked(Save.top)
    topCheck.Text:SetText('TOP')
    topCheck:SetScript('OnClick', function()
        Save.top= not Save.top and true or nil
        set_Target()
    end)
    
    local sliderX = e.Create_Slider(panel, {min=-250, max=250, value=Save.x, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.x= value
        set_Target()--设置,指示目标,位置,显示,隐藏
    end})
    sliderX:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT',0, -12)
    local sliderY = e.Create_Slider(panel, {min=-250, max=250, value=Save.y, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.y= value
        set_Target()--设置,指示目标,位置,显示,隐藏
    end})
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT',15,0)
    local sliderW = e.Create_Slider(panel, {min=10, max=100, value=Save.w, setp=1, w= 100,
    text= 'W',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.w= value
        set_Target_Size(targetFrame)--设置，大小
        set_Target_Size(panel.tipTargetTexture)--设置，大小
    end})
    sliderW:SetPoint("LEFT", sliderY, 'RIGHT',15,0)
    local sliderH = e.Create_Slider(panel, {min=10, max=100, value=Save.h, setp=1, w= 100, color=true,
    text= 'H',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.h= value
        set_Target_Size(targetFrame)--设置，大小
        set_Target_Size(panel.tipTargetTexture)--设置，大小
    end})
    sliderH:SetPoint("LEFT", sliderW, 'RIGHT',15,0)


    local sel2=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel2.text:SetText(e.onlyChinese and e.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r'
                or (e.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
            )
    sel2:SetPoint('TOPLEFT', sel, 'BOTTOMLEFT',0, -60)
    sel2:SetChecked(Save.creature)
    sel2:SetScript('OnClick', function()
        Save.creature= not Save.creature and true or nil
        set_Register_Event()
        set_Created_Texture_Text()
    end)

    local sliderRange = e.Create_Slider(panel, {min=0, max=60, value=Save.creatureRange, setp=1, w= 100 ,
    text=format(e.onlyChinese and '码' or IN_GAME_NAVIGATION_RANGE''),
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.creatureRange= value
        set_Creature_Num()
    end})
    sliderRange:SetPoint("LEFT", sel2.text, 'RIGHT',12, 0)

    local sliderCreatureFontSize = e.Create_Slider(panel, {min=8, max=32, value=Save.creatureFontSize, setp=1, w=100, color=true,
    text=e.onlyChinese and '大小' or FONT_SIZE,
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.creatureFontSize= value
        e.Cstr(nil, {changeFont=targetFrame.Creature, size=value})
        set_Creature_Num()
    end})
    sliderCreatureFontSize:SetPoint("LEFT", sliderRange, 'RIGHT',15,0)

    local questCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questCheck.Text:SetText(e.onlyChinese and '任务进度' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, PVP_PROGRESS_REWARDS_HEADER)))
    questCheck:SetPoint('TOPLEFT', sel2, 'BOTTOMLEFT',0,-24)
    questCheck:SetChecked(Save.quest)
    questCheck:SetScript('OnClick', function()
        Save.quest= not Save.quest and true or nil
        set_check_All_Plates()
    end)

    local questAllFactionCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questAllFactionCheck.Text:SetText((e.onlyChinese and '提示所有阵营' or (SHOW..'('..ALL..')'..FACTION))..e.Icon.horde2..e.Icon.alliance2)
    questAllFactionCheck:SetPoint('LEFT', questCheck.Text, 'RIGHT',2,0)
    questAllFactionCheck:SetChecked(Save.questShowAllFaction)
    questAllFactionCheck:SetScript('OnClick', function()
        Save.questShowAllFaction= not Save.questShowAllFaction and true or nil
        set_check_All_Plates()
    end)

    local classCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    classCheck.Text:SetText(e.onlyChinese and '职业' or CLASS)
    classCheck:SetPoint('LEFT', questAllFactionCheck.Text, 'RIGHT',2,0)
    classCheck:SetChecked(Save.questShowPlayerClass)
    classCheck:SetScript('OnClick', function()
        Save.questShowPlayerClass= not Save.questShowPlayerClass and true or nil
        set_check_All_Plates()
    end)
end

panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.targetTextureTab= Save.targetTexture or {['common-icon-rotateright']='atlas',}
            Save.targetTextureName= Save.targetTextureName or 'common-icon-rotateright'
            Save.targetInCombatColor= Save.targetInCombatColor or {r=1, g=0, b=0, a=1}

            panel.name = e.Icon.toRight2..(e.onlyChinese and '目标指示' or addName)..'|r'
            panel.parent = id
            InterfaceOptions_AddCategory(panel)

            e.ReloadPanel({panel=panel, addName= addName, restTips=true, checked=true, clearTips=nil,--重新加载UI, 重置, 按钮
                disabledfunc=function()
                    Save.disabled= not Save.disabled and true or nil
                    if not targetFrame and not Save.disabled  then
                        set_Option()
                        Init()
                    end
                    print(id, addName, e.GetEnabeleDisable(not Save.disabled), Save.disabled and (e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')
                end,
                clearfunc= function() Save=nil e.Reload() end}
            )

            if not Save.disabled then
                --isAddOnPlater= IsAddOnLoaded("Plater")
                set_Option()
                Init()
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
--NamePlate2PlaterUnitFrameHealthBar