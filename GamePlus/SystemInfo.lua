local id, e = ...
local addName= SYSTEM_MESSAGES--MAINMENU_BUTTON
local Save={
    equipmetLevel=true,
    durabiliy=true,
    moneyWoW=true,
}

local button=e.Cbtn(nil, {icon='hide',size={12,12}})
local equipmentLevelIcon= ''

local notEquipmentLevelChangeSize
local function set_Text_Size_Color()
    e.Cstr(nil, {size=Save.size, changeFont=button.fpsms, color=true})--Save.size, nil , button.fpsms, true)
    e.Cstr(nil, {size=Save.size, changeFont=button.money, color=true})--, nil , button.money, true)
    e.Cstr(nil, {size=Save.size, changeFont=button.durabiliy, color=true})-- Save.size, nil , button.durabiliy, true)
    if not notEquipmentLevelChangeSize then
        e.Cstr(nil, {size=Save.size, changeFont=button.equipmentLevel, color=true})--nil, nil , button.equipmentLevel, true)
    end
end


local function setMoney()
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
        if e.Player.useColor then
            button.money:SetText(e.MK(money/1e4, 3)..'|TInterface/moneyframe/ui-goldicon:8|t')
        else
            button.money:SetText(e.MK(money/1e4, 3)..'|TInterface/moneyframe/ui-silvericon:8|t')
        end
    else
        button.money:SetText(GetMoneyString(money,true))
    end
end
local function set_Money_Event()--设置, 钱, 事件
    if Save.money then
        button:RegisterEvent('PLAYER_MONEY')
        setMoney()
    else
        button:UnregisterEvent('PLAYER_MONEY')
        button.money:SetText('')
    end
end

local function setDurabiliy()
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
        du= format('%i%%', value)..'|T132281:8|t'
        if value<30 then
            du='|cnRED_FONT_COLOR:'..du..'|r';
        elseif value<=60 then
            du='|cnYELLOW_FONT_COLOR:'..du..'|r';
        elseif value<=90 then
            du='|cnGREEN_FONT_COLOR:'..du..'|r';
        end
    end
    button.durabiliy:SetText(du or '')
    e.Set_HelpTips({frame=button, topoint=button.durabiliy, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=true, show=value<=40})--设置，提示
    return du or ''
end

local function setEquipmentLevel()--角色图标显示装等
    local to, cu= GetAverageItemLevel()
    local text, red
    if to and cu and to>0 then
        text=math.modf(cu)
        if to-cu>5 then
            text='|cnRED_FONT_COLOR:'..text..'|r'
            red= true
        end
        text=text..equipmentLevelIcon
    end
    button.equipmentLevel:SetText(text or '')
    if e.Player.levelMax then
        e.Set_HelpTips({frame=button, topoint=button.equipmentLevel, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, onlyOne=nil, show=red and not C_PvP.IsArena() and not C_PvP.IsBattleground()})--设置，提示
    end
end

local function set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
    if Save.equipmetLevel or Save.durabiliy then
        button:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
        button:RegisterEvent('PLAYER_ENTERING_WORLD')
    else
        button:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
        button:UnregisterEvent('PLAYER_ENTERING_WORLD')
    end

    if Save.equipmetLevel then
        C_Timer.After(2, setEquipmentLevel) --角色图标显示装等  
    else
        button.equipmentLevel:SetText('')
    end

    if Save.durabiliy then
        button:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        setDurabiliy()
    else
        button:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        button.durabiliy:SetText('')
    end
end

local function set_Point()--设置位置
    if Save.point then
        button:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        button:SetPoint('BOTTOMRIGHT',-24, 0)
    end
end

local function set_System_FPSMS()--设置系统fps ms
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

local timeElapsed = 0
local function set_Fps_Ms()--设置, fps, ms, 数值
    button.fpsmsFrame:SetShown(not Save.hideFpsMs)
    if not Save.hideFpsMs then
        timeElapsed=0
    else
        button.fpsms:SetText('')
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
                if Save.money then
                    setMoney()
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
    else
        info={
            text= 'fps ms',
            checked= not Save.hideFpsMs,
            tooltipOnButton=true,
            tooltipTitle=MAINMENUBAR_LATENCY_LABEL:format(select(3, GetNetStats())),
            func= function()
                Save.hideFpsMs= not Save.hideFpsMs and true or nil
                set_Fps_Ms()--设置, fps, ms, 数值
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinese and '系统' or SYSTEM).. ' fps ms',
            checked= Save.SystemFpsMs,
            func= function()
                Save.SystemFpsMs= not Save.SystemFpsMs and true or nil
                set_System_FPSMS()--设置系统fps ms
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)

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
            text= (e.onlyChinese and '耐久度' or DURABILITY)..': '..setDurabiliy(),
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
end

--######
--初始化
--######
local function Init()
    set_Point()--设置位置
    button:SetHighlightAtlas(e.Icon.highlight)
    button:SetPushedAtlas(e.Icon.pushed)
    button:SetFrameStrata('HIGH')

    button.fpsms:SetPoint('BOTTOMRIGHT')
    button.money:SetPoint('BOTTOMRIGHT', button.fpsms, 'BOTTOMLEFT', -4, 0)
    button.durabiliy:SetPoint('BOTTOMRIGHT', button.money, 'BOTTOMLEFT', -4, 0)
    if CharacterMicroButton and CharacterMicroButton:IsVisible() then
        button.equipmentLevel:SetPoint('BOTTOM', CharacterMicroButton)
        button.equipmentLevel:SetParent(CharacterMicroButton)
        notEquipmentLevelChangeSize=true
    else
        button.equipmentLevel:SetPoint('BOTTOMRIGHT', button.durabiliy, 'BOTTOMLEFT', -4, 0)
        equipmentLevelIcon= UnitSex('player')==2 and '|A:charactercreate-gendericon-male:0:0|a' or  '|A:charactercreate-gendericon-female:0:0|a'--e.Icon.player--'|T1030900:0|t'--'|A:charactercreate-icon-customize-torso-selected:0:0|a'
    end
    button.fpsmsFrame:SetPoint('RIGHT')
    button.fpsmsFrame:SetSize(1,1)

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
    button:SetScript("OnDragStop", function(self2)
        self2:StopMovingOrSizing()
        Save.point={self2:GetPoint(1)}
        ResetCursor()
        set_Text_Size_Color()
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
        set_Text_Size_Color()
        print(id, addName, e.onlyChinese and '字体大小' or FONT_SIZE,'|cnGREEN_FONT_COLOR:'..size)
    end)

    button:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        else
            if not self.Menu then
                button.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    button.fpsmsFrame:HookScript("OnUpdate", function (self, elapsed)--fpsms
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.4 then
            timeElapsed = 0
            local t = select(4, GetNetStats())--ms
            if t>400 then
                t='|cnRED_FONT_COLOR:'..t..'|r'
            elseif t>120 then
                t='|cnYELLOW_FONT_COLOR:'..t..'|r'
            end

            local r
            r=GetFramerate() or 0
            r=math.modf(r)--fps
            if r then
                if r<10 then
                    r='|cff00ff00'..r..'|r'
                elseif r<20 then
                    r='|cffffff00'..r..'|r'
                end
                t=t..'ms  '..r..'fps'
            end
            button.fpsms:SetText(t)
        end
    end)


    set_Text_Size_Color()
    if Save.money then--设置,钱,事件
        set_Money_Event()
    end
    set_System_FPSMS()--设置系统fps ms
    set_Fps_Ms()--设置, fps, ms, 数值
    if Save.equipmetLevel or Save.durabiliy then--设置装等,耐久度,事件
        set_Durabiliy_EquipLevel_Event()
    end

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
            --if e.onlyChinese then
                --e.tips:AddLine('跨服'..e.GetYesNo(not info.isInCurrentRegion)..region, 1,1,1)
            --else
            e.tips:AddLine('isInCurrentRegion'..e.GetYesNo(info.isInCurrentRegion)..region, 1,1,1)
            --end
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

    button:SetButtonState('PUSHED')
    C_Timer.After(4, function()
        button:SetButtonState('NORMAL')
    end)
end

button:RegisterEvent("ADDON_LOADED")

button:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsSave[addName] then
                button:SetButtonState('PUSHED')
            end
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

            if not Save.disabled then
                button.fpsms=e.Cstr(button, {size=Save.size, color=true})--fpsms
                button.money=e.Cstr(button, {size=Save.size, color=true})--钱
                button.durabiliy=e.Cstr(button, {size=Save.size, color=true})--耐久度
                button.equipmentLevel=e.Cstr(button, {size=Save.size, color=true})--装等
                button.fpsmsFrame=CreateFrame("Frame",nil, button)--fps,ms,框架
                button.fpsmsFrame:SetShown(false)
                Init()
            end
            button:UnregisterEvent('ADDON_LOADED')
            button:RegisterEvent("PLAYER_LOGOUT")
            button:SetShown(not Save.disabled)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    elseif event=='PLAYER_MONEY' then
        C_Timer.After(0.5, setMoney)

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        setDurabiliy()

    elseif event=='PLAYER_EQUIPMENT_CHANGED' or event=='PLAYER_ENTERING_WORLD' then
        if Save.durabiliy then
            setDurabiliy()
        end
        if Save.equipmetLevel then
            C_Timer.After(0.5, function()
                setEquipmentLevel()--角色图标显示装等
            end)
        end
    end
end)


