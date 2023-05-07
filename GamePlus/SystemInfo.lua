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
    --size= e.Player.husandro and 10
}

local panel= CreateFrame("Frame")
local Labels
local button

local function set_Label_Size_Color()
    for _, label in pairs(Labels) do
        e.Cstr(nil, {size=Save.size, changeFont=label, color=true})--Save.size, nil , Labels.fpsms, true)    
    end
end
local function create_lable(self, text)
    local label= e.Cstr(self, {size=Save.size, color=true})--耐久度    
    local down
    if text=='fps' then
        label.tooltip= function() return format(FPS_FORMATL, math.modf(GetFramerate())) end
    elseif text=='ms' then
        label.tooltip= function() return format(e.onlyChinese and  "延迟：\n%.0f ms （本地）\n%.0f ms （世界）" or MAINMENUBAR_LATENCY_LABEL, select(3, GetNetStats())) end
    elseif text=='money' then
        label.tooltip= e.onlyChinese and '钱' or MONEY

    elseif text=='perksPoints' then
        label.tooltip= e.onlyChinese and '在旅行者日志里查看赢取标币的方法' or TUTORIAL_PERKS_PROGRAM_ACTIVITIES_OPEN
    elseif text=='durabiliy' then
        label.tooltip= e.onlyChinese and '耐久度' or DURABILITY
    elseif text=='equipmentLevel' then
        label.tooltip= e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL 
    end

    label:EnableMouse(true)
    label:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if self2.tooltip then
            
            e.tips:AddLine(type(self2.tooltip)=='function' and self2.tooltip() or self2.tooltip)
            print(self2.tooltip)
        end
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        button:SetButtonState('PUSHED')
    end)
    label:SetScript('OnLeave', function(self2)
        button:SetButtonState('NORMAL')
        e.tips:Hide()
    end)
    if down then
        label:SetScript('OnMouseDown', down)
    end
    return label
end


--########
--设置, 钱
--########
local function set_Money()
    local money=0
    if Save.moneyWoW then
        for _, info in pairs(WoWDate) do
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
        elseif e.Player.useColor then
            Labels.money:SetText(e.MK(money/1e4, Save.moneyBit or 0)..'|TInterface/moneyframe/ui-goldicon:8|t')
        else
            Labels.money:SetText(e.MK(money/1e4, Save.moneyBit or 0)..'|TInterface/moneyframe/ui-silvericon:8|t')
        end
    else
        Labels.money:SetText(GetMoneyString(money,true))
    end
end
local function set_Money_Event()
    if Save.money then
        panel:RegisterEvent('PLAYER_MONEY')
        if not Labels.money then
            Labels.money= create_lable(button, 'money')
        end
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
    local c = 0;
    local m = 0;
    for i = 1, 18 do
        local cur,max = GetInventoryItemDurability(i);
        if cur and max and max>0 then
            c = c + cur;
            m =m + max;
        end
    end
    local du, value= nil, 100
    if m>0 then
        value = floor((c/m) * 100)
        du= format('%i%%', value)--'|T132281:8|t'
        if value<30 then
            du='|cnRED_FONT_COLOR:'..du..'|r';
        elseif value<=60 then
            du='|cnYELLOW_FONT_COLOR:'..du..'|r';
        elseif value<=90 then
            du='|cnGREEN_FONT_COLOR:'..du..'|r';
        end
    end
    Labels.durabiliy:SetText(du or '')
    e.Set_HelpTips({frame=button, topoint=Labels.durabiliy, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<=40})--设置，提示
    return du or ''
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
            text= text..(e.Player.sex==2 and '|A:charactercreate-gendericon-male:0:0|a' or '|A:charactercreate-gendericon-female:0:0|a')
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
        if not Labels.equipmentLevel then
            Labels.equipmentLevel= create_lable(button, 'equipmentLevel')
        end
        C_Timer.After(2, set_EquipmentLevel) --角色图标显示装等  
    else
        if Labels.equipmentLevel then
            Labels.equipmentLevel:SetText('')
        end
    end

    if Save.durabiliy then
        panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        if not Labels.durabiliy then
            Labels.durabiliy= create_lable(button, 'durabiliy')
        end
        set_Durabiliy()
    else
        panel:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        if Labels.durabiliy then
            Labels.durabiliy:SetText('')
        end
    end
end

--设置, fps, ms, 数值
local function set_Fps_Ms(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed > 0.4 then
        self.elapsed = 0

        local value = select(4, GetNetStats()) or 0--ms
        Labels.ms:SetText((value>400 and '|cnRED_FONT_COLOR:'..value..'|r' or value>120 and ('|cnYELLOW_FONT_COLOR:'..value..'|r') or value)..'ms')

        value=GetFramerate() or 0
        value=math.modf(value)
        Labels.fps:SetText((value<10 and '|cnGREEN_FONT_COLOR:'..value..'|r' or value<20 and '|cnYELLOW_FONT_COLOR:'..value..'|r' or value)..'fps')
    end
end
local function set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
    panel.elapsed=0
    panel:SetShown(not Save.hideFpsMs)
    if Save.hideFpsMs then
        if Labels.fps then
            Labels.fps:SetText('')
            Labels.ms:SetText('')
        end
    else
        if not Save.hideFpsMs and not Labels.fps then
            Labels.fps= create_lable(button, 'fps')
            Labels.ms= create_lable(button, 'ms')
            panel:HookScript("OnUpdate", set_Fps_Ms)
        end
    end
end



--[[local function set_System_FPSMS()--设置系统fps ms
    local frame=FramerateLabel
    if Save.SystemFpsMs then
        if not frame or not frame:IsShown() then
            ToggleFramerate()
        end
    else
        if frame and frame:IsShown() then
            ToggleFramerate()
        end
    end
end
]]





--###########
--贸易站, 点数
--Blizzard_EncounterJournal/Blizzard_MonthlyActivities.lua
local function set_perksActivitiesLastPoints_CVar()--贸易站, 点数
    local lastPoints = tonumber(GetCVar("perksActivitiesLastPoints"));
    if lastPoints and lastPoints>0 then
        Labels.perksPoints:SetFormattedText('%i%%', lastPoints/1000*100)
    else
        Labels.perksPoints:SetText('')
    end
end
local function set_perksActivitiesLastPoints_Event()
    if Save.perksPoints then
        if not Labels.perksPoints then
            Labels.perksPoints= create_lable(button, 'perksPoints')
        end
        panel:RegisterEvent('CVAR_UPDATE')
        set_perksActivitiesLastPoints_CVar()
    else
        panel:UnregisterEvent('CVAR_UPDATE')
        if Labels.perksPoints then
            Labels.perksPoints:SetText('')
        end
    end
end


local function set_Point()--设置位置
    if Save.point then
        button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        button:SetPoint('BOTTOMRIGHT',-24, 0)
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
                    label:SetPoint('BOTTOM', MainMenuMicroButton, 'TOP',0,-4)
                    label:SetParent(MainMenuMicroButton)
                elseif text=='ms' then
                    label:SetPoint('TOP', MainMenuMicroButton, 'BOTTOM',0,4)
                    label:SetParent(MainMenuMicroButton)

                elseif text=='money' then
                    label:SetPoint('TOP', MainMenuBarBackpackButton, 0,6)
                    label:SetParent(MainMenuBarBackpackButton)

                elseif text=='perksPoints' then
                    label:SetPoint('TOP', EJMicroButton, 0,6)
                    label:SetParent(EJMicroButton)

                elseif text=='durabiliy' then
                    label:SetPoint('BOTTOM', CharacterMicroButton)
                    label:SetParent(CharacterMicroButton)

                elseif text=='equipmentLevel' then
                    label:SetPoint('TOP', CharacterMicroButton,0,6)
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

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type=='wowMony' then
        info={
            text='WoW',
            checked= Save.moneyWoW,
            func= function()
                Save.moneyWoW= not Save.moneyWoW and true or nil
                set_Money_Event()
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return
    end

    info={
        text= 'fps ms',
        checked= not Save.hideFpsMs,
        tooltipOnButton=true,
        tooltipTitle=format(e.onlyChinese and  "延迟：\n%.0f ms （本地）\n%.0f ms （世界）" or MAINMENUBAR_LATENCY_LABEL, select(3, GetNetStats())),
        func= function()
            Save.hideFpsMs= not Save.hideFpsMs and true or nil
            set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    --[[info={
        text= (e.onlyChinese and '系统' or SYSTEM).. ' fps ms',
        checked= Save.SystemFpsMs,
        func= function()
            Save.SystemFpsMs= not Save.SystemFpsMs and true or nil
            set_System_FPSMS()--设置系统fps ms
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)]]

    local numPlayer, allMoney, text  = 0, 0, ''
    for guid, infoMoney in pairs(WoWDate) do
        if infoMoney.Money then
            text= text~='' and text..'\n' or text
            text= text..e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false})..'  '.. GetCoinTextureString(infoMoney.Money, true)
            numPlayer=numPlayer+1
            allMoney= allMoney + infoMoney.Money
        end
    end
    --e.tips:AddDoubleLine(CHARACTER..numPlayer..' '..FROM_TOTAL..e.MK(allMoney/10000, 3), GetCoinTextureString(allMoney))

    info={
        text= (e.onlyChinese and '钱' or MONEY),
        checked=Save.money,
        menuList='wowMony',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle= (e.onlyChinese and '角色' or CHARACTER)..'|cnGREEN_FONT_COLOR:'..numPlayer..'|r  '..(e.onlyChinese and '总计: ' or FROM_TOTAL)..'|cnGREEN_FONT_COLOR:'..(allMoney >=10000 and e.MK(allMoney/10000, 3) or GetCoinTextureString(allMoney, true))..'|r',
        tooltipText= text,
        func= function()
            Save.money= not Save.money and true or nil
            set_Money_Event()--设置, 钱, 事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text= (e.onlyChinese and '耐久度' or DURABILITY)..': '..set_Durabiliy(),
        checked= Save.durabiliy,
        func= function()
            Save.durabiliy = not Save.durabiliy and true or false
            set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text= (e.onlyChinese and '装备等级' or EQUIPSET_EQUIP..LEVEL),
        checked=Save.equipmetLevel,
        func= function()
            Save.equipmetLevel= not Save.equipmetLevel and true or nil
            set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= (e.onlyChinese and '框架' or DEBUG_FRAMESTACK)..' MicroMenu',
        checked= Save.parent,
        func= function()
            Save.parent= not Save.parent and true or nil
            set_Label_Point(true)--设置parent
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text=e.Icon.mid..(e.onlyChinese and '缩放' or UI_SCALE)..': '..(Save.size or 12),
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text=e.Icon.right..(e.onlyChinese and '移动' or NPE_MOVE),
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info,level)

    info={
        text= (e.onlyChinese and '重置位置' or RESET_POSITION),
        colorCode= not Save.point and '|cff606060',
        notCheckable=true,
        func= function()
            Save.point=nil
            button:ClearAllPoints()
            set_Point()--设置位置
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
    set_Point()--设置位置
    button:SetFrameStrata('HIGH')
    button:SetMovable(true)
    button:RegisterForDrag("RightButton");
    button:SetClampedToScreen(true);
    button:SetScript("OnDragStart", function(self2, d)
        if d=='RightButton' then
            SetCursor('UI_MOVE_CURSOR')
            self2:StartMoving()
            e.LibDD:CloseDropDownMenus()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.point={self:GetPoint(1)}
        Save.point[2]=nil
        ResetCursor()
    end)
    button:SetScript("OnMouseUp", function(self2,d)
        ResetCursor()
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
        set_Label_Size_Color()
        print(id, addName, e.onlyChinese and '字体大小' or FONT_SIZE,'|cnGREEN_FONT_COLOR:'..size)
    end)

    button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
    button:SetButtonState('PUSHED')
    C_Timer.After(4, function()
        button:SetButtonState('NORMAL')
    end)


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
        local curRegion= GetCurrentRegion()
        e.tips:AddLine('realmID '..GetRealmID()..' '..GetNormalizedRealmName(), 1,0.82,0)
        e.tips:AddLine('regionID '..curRegion..' '..GetCurrentRegionName(), 1,0.82,0)

        local info=C_BattleNet.GetGameAccountInfoByGUID(e.Player.guid)
        if info and info.wowProjectID then
            local region=''
            if info.regionID and info.regionID~=curRegion then
                region=' regionID'..(e.onlyChinese and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..info.regionID..'|r'
            end
            e.tips:AddLine('isInCurrentRegion'..e.GetYesNo(info.isInCurrentRegion)..region, 1,1,1)
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinesel and '选项' or SETTINGS_TITLE), e.Icon.mid)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)

    MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
    MainMenuMicroButton:SetScript('OnMouseWheel', function()
        securecallfunction(InterfaceOptionsFrame_OpenToCategory, id)
    end)


    C_Timer.After(2, function()
        set_Label_Size_Color()
        set_Money_Event()--设置,钱,事件
        --set_System_FPSMS()--设置系统fps ms
        set_Fps_Ms_Show_Hide()--设置, fps, ms, 数值
        set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
        set_perksActivitiesLastPoints_Event()--贸易站, 点数
        set_Label_Point()--设置 Label Poinst
    end)
end

panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            local check=e.CPanel('|A:UI-HUD-MicroMenu-GameMenu-Mouseover:0:0|a'..(e.onlyChinese and '系统信息' or addName), not Save.disabled, true)
            check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            check:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT");
                e.tips:ClearLines();
                e.tips:AddDoubleLine('fps ms', e.onlyChinese and '钱' or MONEY)
                e.tips:AddDoubleLine(e.onlyChinese and '耐久度' or DURABILITY, e.onlyChinese and '装等' or (EQUIPSET_EQUIP..LEVEL))
                e.tips:Show();
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)

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
    end
end)


