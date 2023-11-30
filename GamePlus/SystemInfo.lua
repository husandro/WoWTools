local id, e = ...
local addName= SYSTEM_MESSAGES--MAINMENU_BUTTON
local Save={
    --hideFpsMs=false,
    money=true,
    moneyWoW=true,
    --moneyBit=0,
    equipmetLevel=true,
    durabiliy=true,
    perksPoints=true,
    parent= e.Player.husandro,--父框架
    size= 11,
    --framerateSize=12,
    --frameratePlus=true,--为FramerateText 帧数, 建立一个按钮, 移动, 大小
    --framerateLogIn=false,--进入游戏时,显示系统FPS
}

local panel= CreateFrame("Frame")
local Labels
local button
local MoveFPSFrame--为FramerateText 帧数, 建立一个按钮, 移动, 大小




















--########
--设置, 钱
--########
local function get_Mony_Tips()
    local numPlayer, allMoney= 0, 0
    local tab={}
    for guid, infoMoney in pairs(e.WoWDate or {}) do
        if infoMoney.Money then

            local nameText= e.GetPlayerInfo({guid=guid, faction=infoMoney.faction, reName=true, reRealm=true})
            local moneyText= GetCoinTextureString(infoMoney.Money)

            local class= select(2, GetPlayerInfoByGUID(guid))
            local col= '|c'..select(4, GetClassColor(class))

            numPlayer=numPlayer+1
            allMoney= allMoney + infoMoney.Money

            table.insert(tab, {text=nameText, money=moneyText, col=col, index=infoMoney.Money})
        end
    end
    table.sort(tab, function(a,b) return a.index< b.index end)

    local all=(e.onlyChinese and '角色' or CHARACTER)..'|cnGREEN_FONT_COLOR:'..numPlayer..'|r  '
            ..(e.onlyChinese and '总计: ' or FROM_TOTAL)
            ..'|cnGREEN_FONT_COLOR:'..(allMoney >=10000 and e.MK(allMoney/10000, 3) or GetCoinTextureString(allMoney))..'|r'

            --table.insert(tab, {text= all,
    return all, tab
end























local function create_Set_lable(self, text)--建立,或设置,Labels
    local down
    local label= Labels[text] or e.Cstr(self, {size=Save.size, color=true})
    if Save.parent then
        if text=='money' then
            label.tooltip= function()
                local text2, tab2= get_Mony_Tips()
                e.tips:AddLine(text2)
                e.tips:AddLine(' ')
                local find
                for _, tab in pairs(tab2) do
                    e.tips:AddDoubleLine(tab.text, tab.col..tab.money)
                    find=true
                end
                if find then
                    e.tips:AddLine(' ')
                end
            end
            down= ToggleAllBags

        elseif text=='perksPoints' then
            label.tooltip= function()
                local info=C_CurrencyInfo.GetCurrencyInfo(2032)
                local str=''
                if info and info.quantity and info.iconFileID then
                    str= '|T'..info.iconFileID..':0|t'..info.quantity..'|n'
                end
                e.tips:AddDoubleLine(str..(e.onlyChinese and '旅行者日志进度' or MONTHLY_ACTIVITIES_PROGRESSED), Labels.perksPoints.value)
            end
            down= function() ToggleEncounterJournal() end
        end
    end
--[[
        elseif text=='durabiliy' then
            label.tooltip= e.onlyChinese and '耐久度' or DURABILITY
            down= function() ToggleCharacter("PaperDollFrame"); end
        elseif text=='equipmentLevel' then
            label.tooltip= e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL
            down= function() ToggleCharacter("PaperDollFrame"); end
        end
]]
    if down  then
        label:SetScript('OnLeave', function(self2)
            button:SetButtonState('NORMAL')
            e.tips:Hide()
        end)
        label:EnableMouse(true)
        label:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            if self2.tooltip then
                if type(self2.tooltip)=='function' then
                    self2:tooltip()
                else
                    e.tips:AddLine(self2.tooltip)
                end
                --e.tips:AddLine(type(self2.tooltip)=='function' and self2.tooltip() or self2.tooltip)
            end
            e.tips:AddDoubleLine(id,addName)
            e.tips:Show()
            button:SetButtonState('PUSHED')
        end)
        label:SetScript('OnMouseDown', down)
    else
        label:EnableMouse(false)
        label:SetScript('OnEnter', nil)
        label:SetScript('OnLeave', nil)
        label:SetScript('OnMouseDown', nil)
    end
    return label
end



























--########
--设置, 钱
--########
local function set_Money()
    local money=0
    if Save.moneyWoW then
        for _, info in pairs(e.WoWDate or {}) do
            if info.Money then
                money= money+ info.Money
            end
        end
    else
        money= GetMoney()
    end
    if money>=10000 then
        if Save.parent then
            Labels.money:SetText(e.MK(money/1e4, Save.moneyBit or 0))
        else
            Labels.money:SetText('|TInterface/moneyframe/ui-goldicon:0|t'..e.MK(money/1e4, Save.moneyBit or 0)..' ')
        end
    else
        Labels.money:SetText(GetMoneyString(money,true))
    end
end
local function set_Money_Event()
    if Save.money then
        panel:RegisterEvent('PLAYER_MONEY')
        Labels.money= create_Set_lable(button, 'money')--建立,或设置,Labels
        set_Money()
    else
        panel:UnregisterEvent('PLAYER_MONEY')
        if Labels.money then
            Labels.money:SetText('')
        end
    end
end
























--##################
--设置装等,耐久度,事件
--##################
local function set_Durabiliy()
    local du, value= e.GetDurabiliy(not Save.parent)
    if not Save.parent and du then
        du= du..' '
    end
    Labels.durabiliy:SetText(du or '')
    e.Set_HelpTips({frame=button, topoint=Labels.durabiliy, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<=40})--设置，提示
end
local function set_EquipmentLevel()--装等
    local to, cu= GetAverageItemLevel()
    local text, red
    if to and cu and to>0 then
        text=math.modf(cu)
        if to-cu>5 then
            text='|cnRED_FONT_COLOR:'..text..'|r'
            red= true
        end
        if not Save.parent then
            text= (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..text..' '
        end
    end
    Labels.equipmentLevel:SetText(text or '')
    if e.Player.levelMax then
        e.Set_HelpTips({frame=button, topoint=Labels.equipmentLevel, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=red and not C_PvP.IsArena() and not C_PvP.IsBattleground()})--设置，提示
    end
end
local function set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
    if Save.equipmetLevel or Save.durabiliy then
        panel:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    else
        panel:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
    end

    if Save.equipmetLevel then
        Labels.equipmentLevel= create_Set_lable(button, 'equipmentLevel')--建立,或设置,Labels
        C_Timer.After(2, set_EquipmentLevel) --角色图标显示装等  
    else
        if Labels.equipmentLevel then
            Labels.equipmentLevel:SetText('')
        end
    end

    if Save.durabiliy then
        panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        Labels.durabiliy= create_Set_lable(button, 'durabiliy')--建立,或设置,Labels
        set_Durabiliy()
    else
        panel:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        if Labels.durabiliy then
            Labels.durabiliy:SetText('')
        end
    end
end

























--##################
--设置, fps, ms, 数值
--##################
local function set_Fps_Ms(self, elapsed)
    self.elapsed = (self.elapsed or 0.4) + elapsed
    if self.elapsed > 0.4 then
        self.elapsed = 0
        local latencyHome, latencyWorld= select(3, GetNetStats())--ms
        local ms= math.max(latencyHome, latencyWorld) or 0
        local fps=GetFramerate() or 0
        fps=math.modf(fps)

        if Save.parent then
            Labels.ms:SetText(ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)
            Labels.fps:SetText(fps<10 and '|cnGREEN_FONT_COLOR:'..math.modf(fps)..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..math.modf(fps)..'|r' or math.modf(fps))
        else
            Labels.ms:SetText((ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)..'ms ')
            Labels.fps:SetText((fps<10 and '|cnGREEN_FONT_COLOR:'..math.modf(fps)..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..math.modf(fps)..'|r' or math.modf(fps))..'fps')
        end
    end
end
local function set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
    panel:SetShown(not Save.hideFpsMs)
    if Save.hideFpsMs then
        if Labels.fps then
            Labels.fps:SetText('')
            Labels.ms:SetText('')
        end
    else
        if not Save.hideFpsMs then
            Labels.fps= create_Set_lable(button, 'fps')--建立,或设置,Labels
            Labels.ms= create_Set_lable(button, 'ms')--建立,或设置,Labels
            panel:HookScript("OnUpdate", set_Fps_Ms)
        end
    end
end























--###########
--贸易站, 点数
--Blizzard_EncounterJournal/Blizzard_MonthlyActivities.lua
local function set_perksActivitiesLastPoints_CVar()--贸易站, 点数  MonthlyActivitiesFrameMixin:UpdateActivities(retainScrollPosition, activitiesInfo)
    --local value= GetCVar("perksActivitiesLastPoints")
    local text

    local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo()
    if not activitiesInfo then
        return
    end

    local thresholdMax = 0;
	for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
		if thresholdInfo.requiredContributionAmount > thresholdMax then
			thresholdMax = thresholdInfo.requiredContributionAmount;
		end
	end
    if thresholdMax == 0 then
		thresholdMax = 1000
	end

    local earnedThresholdAmount = 0;
	for _, activity in pairs(activitiesInfo.activities) do
		if activity.completed then
			earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount;
		end
	end
	earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax);
    if earnedThresholdAmount== thresholdMax then
        text= e.Icon.select2
    else
        text= e.MK(thresholdMax- earnedThresholdAmount, 1)
    end

    if not Save.parent then
        text= '|A:activities-complete-diamond:0:0|a'..text..' '
    end

    Labels.perksPoints:SetText(text or '')
    Labels.perksPoints.value= earnedThresholdAmount..'/'..thresholdMax
end
local function set_perksActivitiesLastPoints_Event()
    if Save.perksPoints and not ( IsTrialAccount() or IsVeteranTrialAccount()) then
        Labels.perksPoints= create_Set_lable(button, 'perksPoints')--建立,或设置,Labels
        panel:RegisterEvent('CVAR_UPDATE')
        panel:RegisterEvent('PERKS_ACTIVITY_COMPLETED')
        panel:RegisterEvent('PLAYER_ENTERING_WORLD')
        set_perksActivitiesLastPoints_CVar()
    else
        panel:UnregisterEvent('CVAR_UPDATE')
        panel:UnregisterEvent('PERKS_ACTIVITY_COMPLETED')
        panel:UnregisterEvent('PLAYER_ENTERING_WORLD')
        if Labels.perksPoints then
            Labels.perksPoints:SetText('')
        end
    end
end






























--#################
--设置 Label Poinst
--#################
local function set_Label_Point(clear)--设置 Label Poinst
    local tab={
        'fps',
        'ms',
        'money',
        'perksPoints',
        'durabiliy',
        'equipmentLevel',
    }
    local last
    for _, text in pairs(tab) do
        local label=Labels[text]
        if label then
            if clear then
                label:ClearAllPoints()
            end
            if Save.parent then
                if text=='fps' then
                    label:SetPoint('TOP', MainMenuMicroButton, 0, -3)
                    label:SetParent(MainMenuMicroButton)
                elseif text=='ms' then
                    label:SetPoint('BOTTOM', MainMenuMicroButton, 'BOTTOM')
                    label:SetParent(MainMenuMicroButton)

                elseif text=='money' then
                    label:SetPoint('TOP', MainMenuBarBackpackButton,0,-6)
                    label:SetParent(MainMenuBarBackpackButton)

                elseif text=='perksPoints' then
                    label:SetPoint('TOP', EJMicroButton, 0, -3)
                    label:SetParent(EJMicroButton)

                elseif text=='durabiliy' then
                    label:SetPoint('BOTTOM', CharacterMicroButton)
                    label:SetParent(CharacterMicroButton)

                elseif text=='equipmentLevel' then
                    label:SetPoint('TOP', CharacterMicroButton, 0, -3)
                    label:SetParent(CharacterMicroButton)
                end

            else
                label:SetPoint('RIGHT',last or button, 'LEFT')
                label:SetParent(button)
                last= label
            end
        end
    end
end














--每秒帧数 Plus
--############
local function Init_Framerate_Plus()
    if not Save.frameratePlus then
        return
    end
    MoveFPSFrame= e.Cbtn(FramerateFrame, {size={12,12}, icon='hide'})
    MoveFPSFrame:SetPoint('RIGHT',FramerateFrame.FramerateText)
   
    MoveFPSFrame:SetMovable(true)
    MoveFPSFrame:RegisterForDrag("RightButton");
    MoveFPSFrame:SetClampedToScreen(true)
    MoveFPSFrame:SetScript("OnDragStart", function(_, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            local frame= FramerateFrame
            if not frame:IsMovable()  then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    MoveFPSFrame:SetScript("OnDragStop", function()
        FramerateFrame:StopMovingOrSizing()
        Save.frameratePoint={FramerateFrame:GetPoint(1)}
        Save.frameratePoint[2]=nil
        ResetCursor()
    end)
    MoveFPSFrame:SetScript("OnMouseUp", ResetCursor)
    MoveFPSFrame:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    MoveFPSFrame:SetScript('OnLeave', function()
        e.tips:Hide()
        button:SetButtonState('NORMAL')
    end)
    MoveFPSFrame:SetScript('OnEnter', function(self2)--提示
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '字体大小' or FONT_SIZE, (Save.framerateSize or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        button:SetButtonState('PUSHED')
    end)

    MoveFPSFrame:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save.framerateSize or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<6 and 6 or size
        end
        Save.framerateSize=size
        self:set_size()
        print(id, addName, e.onlyChinese and '字体大小' or FONT_SIZE,'|cnGREEN_FONT_COLOR:'..size)
    end)

    function MoveFPSFrame:set_size()--修改大小
        e.Cstr(nil, {size=Save.framerateSize or 12, changeFont=FramerateFrame.FramerateText, color=true})--Save.size, nil , Labels.fpsms, true)    
    end
    MoveFPSFrame:set_size()


    FramerateFrame.Label:SetText('')--去掉FPS
    FramerateFrame.Label:SetShown(false)
    FramerateFrame:SetMovable(true)
    FramerateFrame:SetClampedToScreen(true)
    FramerateFrame:HookScript('OnShow', function(self)
        if Save.frameratePoint and FramerateFrame then
            self:ClearAllPoints()
            self:SetPoint(Save.frameratePoint[1], UIParent, Save.frameratePoint[3], Save.frameratePoint[4], Save.frameratePoint[5])
        end
    end)
    FramerateFrame:SetFrameStrata('HIGH')

    if Save.framerateLogIn and not FramerateFrame:IsShown() then
        FramerateFrame:Toggle()
    end
end



















--#####
--主菜单
--#####
local function InitMenu(_, level, type)--主菜单
    local info
    if type=='wowMony' then
        info={
            text='WoW',
            checked= Save.moneyWoW,
            func= function()
                Save.moneyWoW= not Save.moneyWoW and true or nil
                set_Money_Event()
                set_Label_Point(true)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return
    elseif type=='LOG_IN' then
        info={
            text= (e.onlyChinese and '登入' or LOG_IN)..' WoW: '..e.GetShowHide(true),
            checked= Save.framerateLogIn,
            func= function()
                Save.framerateLogIn= not Save.framerateLogIn and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinese and '重置位置' or RESET_POSITION),
            tooltipOnButton=true,
            tooltipTitle='CENTER',
            notCheckable=true,
            disabled= not Save.frameratePoint,
            func= function()
                Save.frameratePoint=nil
                if MoveFPSFrame then
                    FramerateFrame:ClearAllPoints()
                    FramerateFrame:SetPoint('CENTER')
                end
                print(id,addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return
    end

    info={
        text= 'fps ms',
        checked= not Save.hideFpsMs,
        tooltipOnButton=true,
        tooltipTitle=format(e.onlyChinese and  "延迟：|n%.0f ms （本地）|n%.0f ms （世界）" or MAINMENUBAR_LATENCY_LABEL, select(3, GetNetStats())),
        func= function()
            Save.hideFpsMs= not Save.hideFpsMs and true or nil
            set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    local text2, tab2= get_Mony_Tips()
    info={
        text= (e.onlyChinese and '钱' or MONEY),
        checked=Save.money,
        menuList='wowMony',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle=text2,
        func= function()
            Save.money= not Save.money and true or nil
            set_Money_Event()--设置, 钱, 事件
            set_Label_Point(true)
        end
    }
    for _, tab3 in pairs(tab2) do
        info.tooltipText= (info.tooltipText or '')..'|n'..tab3.col..tab3.money.. ' '.. tab3.text..'|r'

    end
    e.LibDD:UIDropDownMenu_AddButton(info,level)


    info={
        text= (e.onlyChinese and '旅行者日志进度' or MONTHLY_ACTIVITIES_PROGRESSED),
        checked=Save.perksPoints,
        func= function()
            Save.perksPoints= not Save.perksPoints and true or nil
            set_perksActivitiesLastPoints_Event()--贸易站, 点数
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)


    info={
        text= (e.onlyChinese and '耐久度' or DURABILITY),
        checked= Save.durabiliy,
        func= function()
            Save.durabiliy = not Save.durabiliy and true or false
            set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text= (e.onlyChinese and '装备等级' or EQUIPSET_EQUIP..LEVEL),
        checked=Save.equipmetLevel,
        func= function()
            Save.equipmetLevel= not Save.equipmetLevel and true or nil
            set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
            set_Label_Point(true)
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= (e.onlyChinese and '框架' or DEBUG_FRAMESTACK)..' MicroMenu',
        checked= Save.parent,
        colorCode= not StoreMicroButton:IsVisible() and '|cnRED_FONT_COLOR:',
        func= function()
            Save.parent= not Save.parent and true or nil
            set_Label_Point(true)--设置parent
            for str, label in pairs(Labels) do
                create_Set_lable(label, str)
            end
            set_Money()--设置, 钱
            set_EquipmentLevel()--装等
            set_perksActivitiesLastPoints_CVar()--贸易站, 点数
            set_Durabiliy()--设置装等,耐久度,事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)
    info={
        text= (e.onlyChinese and '每秒帧数:' or FRAMERATE_LABEL)..' Plus',
        checked= Save.frameratePlus,
        menuList='LOG_IN',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '移动/大小' or (NPE_MOVE..'/'..e.Player.L.size),
        tooltipText= (e.onlyChinese and '系统' or SYSTEM)..' FPS',
        func= function()
            Save.frameratePlus= not Save.frameratePlus and true or nil
            if Save.frameratePlus and not MoveFPSFrame then
                Init_Framerate_Plus()--每秒帧数 Plus
            else
                print(id, addName, e.GetEnabeleDisable(Save.frameratePlus) ,e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)




    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= id ..' '.. addName,
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)
end



































--######
--初始化
--######
local function Init()
    Labels={}

    button=e.Cbtn(nil, {icon='hide',size={12,12}})
    button.texture= button:CreateTexture()
    button.texture:SetAllPoints(button)
    button.texture:SetAtlas(e.Icon.icon)
    e.Set_Label_Texture_Color(button.texture, {type='Texture', alpha=0.3})--设置颜色


    button:SetFrameStrata('HIGH')
    button:SetMovable(true)
    button:RegisterForDrag("RightButton");
    button:SetClampedToScreen(true);
    button:SetScript("OnDragStart", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
            e.LibDD:CloseDropDownMenus()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        ResetCursor()
        self:Raise()
    end)
    button:SetScript("OnMouseUp", ResetCursor)
    button:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)

    button:SetScript('OnMouseWheel',function(self, d)
        if IsModifierKeyDown() then
            return
        end
        local size=Save.size or 12
        if d==1 then
            size=size+1
            size = size>72 and 72 or size
        elseif d==-1 then
            size=size-1
            size= size<6 and 6 or size
        end
        Save.size=size
        self:set_Label_Size_Color()
        print(id, addName, e.onlyChinese and '字体大小' or FONT_SIZE,'|cnGREEN_FONT_COLOR:'..size)
    end)

    button:SetScript('OnClick', function(self, d)
        if d=='RightButton' then--移动光标
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        elseif d=='LeftButton' then
            FramerateFrame:Toggle()
        end
    end)
    button:SetScript('OnLeave', function(self2)
        e.tips:Hide()
        if self2.moveFPSFrame then
            self2.moveFPSFrame:SetButtonState('NORMAL')
        end
        self2.texture:SetAlpha(0.3)
    end)
    button:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '每秒帧数' or FRAMERATE_FREQUENCY, format("%.1f", GetFramerate())..e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '缩放' or UI_SCALE, (Save.size or 12)..e.Icon.mid)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        if self2.moveFPSFrame then
            self2.moveFPSFrame:SetButtonState('PUSHED')
        end
        self2.texture:SetAlpha(1)
    end)


    --设置位置
    function button:set_Label_Size_Color()
        for _, label in pairs(Labels) do
            e.Cstr(nil, {size=Save.size, changeFont=label, color=true})--Save.size, nil , Labels.fpsms, true)    
        end
    end
    function button:set_point()
        if Save.point then
            button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
        else
            button:SetPoint('BOTTOMRIGHT',-30, -2)
        end
    end
    button:set_point()
    button:set_Label_Size_Color()


    --#########
    --添加版本号
    --MainMenuBar.lua
    hooksecurefunc('MainMenuBarPerformanceBarFrame_OnEnter', function(self)
        e.tips:AddLine(' ')
        local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
        e.tips:AddLine(version..' '..build.. ' '..date.. ' '..tocversion..(buildType and ' '..buildType or ''), 1,0,1)
        if localizedVersion and localizedVersion~='' then
            e.tips:AddLine((e.onlyChinese and '本地' or REFORGE_CURRENT)..localizedVersion, 1,0,0)
        end
        e.tips:AddLine('realmID '..(GetRealmID() or '')..' '..(GetNormalizedRealmName() or ''), 1,0.82,0)
        e.tips:AddLine('regionID '..e.Player.region..' '..GetCurrentRegionName(), 1,0.82,0)

        local info=C_BattleNet.GetGameAccountInfoByGUID(e.Player.guid)
        if info and info.wowProjectID then
            local region=''
            if info.regionID and info.regionID~=e.Player.region then
                region=' regionID'..(e.onlyChinese and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..info.regionID..'|r'
            end
            e.tips:AddLine('isInCurrentRegion '..e.GetYesNo(info.isInCurrentRegion)..region, 1,1,1)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '选项' or SETTINGS_TITLE), e.Icon.mid)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)

    MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
    MainMenuMicroButton:HookScript('OnMouseWheel', function()
        e.call('InterfaceOptionsFrame_OpenToCategory', id)
    end)

    C_Timer.After(2, function()
        set_Money_Event()--设置,钱,事件
        set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
        set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
        set_perksActivitiesLastPoints_Event()--贸易站, 点数
        set_Label_Point()--设置 Label Poinst
        Init_Framerate_Plus()--每秒帧数 Plus
        if Save.parent and Labels.ms then
            MainMenuMicroButton.MainMenuBarPerformanceBar:ClearAllPoints()
            MainMenuMicroButton.MainMenuBarPerformanceBar:SetPoint('BOTTOM',0,-6)
        end
    end)
end








































panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

             --添加控制面板
             e.AddPanel_Check_Button({
                checkName= '|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '系统信息' or addName),
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled= not Save.disabled and true or nil
                    if not Save.disabled and not button then
                        Init()
                    else
                        print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                    end
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.point=nil
                    if button then
                        Save.point=nil
                        button:ClearAllPoints()
                        button:set_point()--设置位置
                    end
                    print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= addName,
                layout= nil,
                category= nil,
            })


            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_MONEY' then
        C_Timer.After(0.5, set_Money)

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        set_Durabiliy()

    elseif event=='PLAYER_EQUIPMENT_CHANGED' then
        if Save.durabiliy then
            set_Durabiliy()
        end
        if Save.equipmetLevel then
            C_Timer.After(0.5, function()
                set_EquipmentLevel()--角色图标显示装等
            end)
        end

    elseif event=='CVAR_UPDATE' then
        if arg1=='perksActivitiesLastPoints' then
            set_perksActivitiesLastPoints_CVar()--贸易站, 点数
        end
    elseif event=='PERKS_ACTIVITY_COMPLETED' or event=='PLAYER_ENTERING_WORLD' then
        C_Timer.After(2, set_perksActivitiesLastPoints_CVar)--贸易站, 点数
    end
end)


