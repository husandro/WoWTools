local id, e = ...
local addName= e.onlyChinse and '系统信息' and SYSTEM_MESSAGES--MAINMENU_BUTTON
local Save={equipmetLevel=true, durabiliy=true, moneyWoW=true}

local panel=e.Cbtn(nil, nil, nil,nil,nil,true,{12,12})
panel.fpsms=e.Cstr(panel, Save.size)--fpsms
panel.money=e.Cstr(panel, Save.size)--钱
panel.durabiliy=e.Cstr(panel, Save.size)--耐久度
panel.equipmentLevel=e.Cstr(panel, Save.size)--装等
panel.fpsmsFrame=CreateFrame("Frame",nil, panel)--fps,ms,框架
panel.fpsmsFrame:SetShown(false)

local equipmentLevelIcon= ''

local function setStrColor()
    e.Cstr(nil, Save.size, nil , panel.fpsms, true)
    e.Cstr(nil, Save.size, nil , panel.money, true)
    e.Cstr(nil, Save.size, nil , panel.durabiliy, true)
    e.Cstr(nil, Save.size, nil , panel.equipmentLevel, true)
end

local function setMoney()
    local money=0
    if Save.moneyWoW then
        for _, info in pairs(e.WoWSave) do
            if info.Money then
                money= money+ info.Money
            end
        end
    else
        money= GetMoney()
    end
    if money>=10000 then
        panel.money:SetText(e.MK(money/1e4, 3)..'|TInterface/moneyframe/ui-silvericon:6|t')
    else
        panel.money:SetText(GetMoneyString(money,true))
    end
end
local function set_Money_Event()--设置, 钱, 事件
    if Save.money then
        panel:RegisterEvent('PLAYER_MONEY')
        setMoney()
    else
        panel:UnregisterEvent('PLAYER_MONEY')
        panel.money:SetText('')
    end
end

local function setDurabiliy(re)
    local c = 0;
    local m = 0;
    for i = 1, 18 do
        local cur,max = GetInventoryItemDurability(i);
        if cur and max and max>0 then
            c = c + cur;
            m =m + max;
        end
    end
    local du;
    if m>0 then
        du = floor((c/m) * 100)
        if du<30 then
            du='|cnRED_FONT_COLOR:'..du..'%|r';
        elseif du<=60 then
            du='|cnYELLOW_FONT_COLOR:'..du..'%|r';
        elseif du<=90 then
            du='|cnGREEN_FONT_COLOR:'..du..'%|r';
        else
            du=du..'%'
        end
        du=du..'|T132281:8|t';
    end
    if not re then
        panel.durabiliy:SetText(du)
    else
        return du or ''
    end
end
local function setEquipmentLevel()--角色图标显示装等
    local to, cu= GetAverageItemLevel()
    local text
    if to and cu and to>0 then
        text=math.modf(cu)
        if to-cu>5 then
            text='|cnRED_FONT_COLOR:'..text..'|r'
        end
        text=text..equipmentLevelIcon
    end
    panel.equipmentLevel:SetText(text or '')
end
local function set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
    if Save.equipmetLevel or Save.durabiliy then
        panel:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    else
        panel:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
    end

    if Save.equipmetLevel then
        C_Timer.After(2, setEquipmentLevel) --角色图标显示装等  
    else
        panel.equipmentLevel:SetText('')
    end

    if Save.durabiliy then
        panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
        setDurabiliy()
    else
        panel:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
        panel.durabiliy:SetText('')
    end
end

local function set_Point()--设置位置
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('BOTTOMRIGHT',-24, 0)
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
    panel.fpsmsFrame:SetShown(not Save.hideFpsMs)
    if not Save.hideFpsMs then
        timeElapsed=0
    else
        panel.fpsms:SetText('')
    end
end
panel.fpsmsFrame:HookScript("OnUpdate", function (self, elapsed)--fpsms
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 0.4 then
        timeElapsed = 0
        local t = select(4, GetNetStats())--ms
        if t>400 then
            t='|cnRED_FONT_COLOR:'..t..'|r'
        elseif t>120 then
            t='|cnYELLOW_FONT_COLOR:'..t..'|r'
        end

        local r=GetFramerate() or 0
        r=math.modf(r)--fps
        if r then
            if r<10 then
                r='|cff00ff00'..r..'|r'
            elseif r<20 then
                r='|cffffff00'..r..'|r'
            end
            t=t..'ms  '..r..'fps'
        end
        panel.fpsms:SetText(t)
    end
end)

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
        UIDropDownMenu_AddButton(info,level)
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
        UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinse and '系统' or SYSTEM).. ' fps ms',
            checked= Save.SystemFpsMs,
            func= function()
                Save.SystemFpsMs= not Save.SystemFpsMs and true or nil
                set_System_FPSMS()--设置系统fps ms
            end
        }
        UIDropDownMenu_AddButton(info,level)

        local numPlayer, allMoney, text  = 0, 0, ''
        for guid, infoMoney in pairs(e.WoWSave) do
            if infoMoney.Money then
                text= text~='' and text..'\n' or text
                text= text..e.GetPlayerInfo(nil, guid, true)..(guid==e.Player.guid and e.Icon.star2 or '')..'  '.. GetCoinTextureString(infoMoney.Money, true)
                numPlayer=numPlayer+1
                allMoney= allMoney + infoMoney.Money
            end
        end
        --e.tips:AddDoubleLine(CHARACTER..numPlayer..' '..FROM_TOTAL..e.MK(allMoney/10000, 3), GetCoinTextureString(allMoney))

        info={
            text= (e.onlyChinse and '钱' or MONEY),
            checked=Save.money,
            menuList='wowMony',
            hasArrow=true,
            tooltipOnButton=true,
            tooltipTitle= (e.onlyChinse and '角色' or CHARACTER)..'|cnGREEN_FONT_COLOR:'..numPlayer..'|r '..FROM_TOTAL..'|cnGREEN_FONT_COLOR:'..(allMoney >=10000 and e.MK(allMoney/10000, 3) or GetCoinTextureString(allMoney, true))..'|r',
            tooltipText= text,
            func= function()
                Save.money= not Save.money and true or nil
                set_Money_Event()--设置, 钱, 事件
            end
        }
        UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinse and '耐久度' or DURABILITY)..': '..setDurabiliy(true),
            checked= Save.durabiliy,
            func= function()
                Save.durabiliy = not  Save.durabiliy and true or nil
                set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
            end
        }
        UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinse and '装备等级' or EQUIPSET_EQUIP..LEVEL),
            checked=Save.equipmetLevel,
            func= function()
                Save.equipmetLevel= not Save.equipmetLevel and true or nil
                set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
            end
        }
        UIDropDownMenu_AddButton(info,level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text=e.Icon.mid..(e.onlyChinse and '缩放' or UI_SCALE)..': '..(Save.size or 12),
            isTitle=true,
            notCheckable=true,
        }
        UIDropDownMenu_AddButton(info,level)

        info={
            text=e.Icon.right..(e.onlyChinse and '移动' or NPE_MOVE),
            isTitle=true,
            notCheckable=true,
        }
        UIDropDownMenu_AddButton(info,level)

        info={
            text= (e.onlyChinse and '重置位置' or RESET_POSITION),
            colorCode= not Save.point and '|cff606060',
            notCheckable=true,
            func= function()
                Save.point=nil
                panel:ClearAllPoints()
                set_Point()--设置位置
            end
        }
        UIDropDownMenu_AddButton(info,level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text= id ..' '.. addName,
            isTitle=true,
            notCheckable=true,
        }
        UIDropDownMenu_AddButton(info,level)
    end
end

--######
--初始化
--######
local function Init()
    set_Point()--设置位置
    panel:SetHighlightAtlas(e.Icon.highlight)
    panel:SetPushedAtlas(e.Icon.pushed)
    panel:SetFrameStrata('HIGH')

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel.fpsms:SetPoint('BOTTOMRIGHT')
    panel.money:SetPoint('BOTTOMRIGHT', panel.fpsms, 'BOTTOMLEFT', -4, 0)
    panel.durabiliy:SetPoint('BOTTOMRIGHT', panel.money, 'BOTTOMLEFT', -4, 0)
    if CharacterMicroButton and CharacterMicroButton:IsVisible() then
        panel.equipmentLevel:SetPoint('BOTTOM', CharacterMicroButton)
    else
        panel.equipmentLevel:SetPoint('BOTTOMRIGHT', panel.durabiliy, 'BOTTOMLEFT', -4, 0)
        equipmentLevelIcon= UnitSex('player')==2 and '|A:charactercreate-gendericon-male:0:0|a' or  '|A:charactercreate-gendericon-female:0:0|a'--e.Icon.player--'|T1030900:0|t'--'|A:charactercreate-icon-customize-torso-selected:0:0|a'
    end
    panel.fpsmsFrame:SetPoint('RIGHT')
    panel.fpsmsFrame:SetSize(1,1)

    panel:SetMovable(true)
    panel:RegisterForDrag("RightButton");
    panel:SetClampedToScreen(true);
    panel:SetScript("OnDragStart", function(self2, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
            self2:StartMoving()
            CloseDropDownMenus()
        end
    end)
    panel:SetScript("OnDragStop", function(self2)
        self2:StopMovingOrSizing()
        Save.point={self2:GetPoint(1)}
        ResetCursor()
        setStrColor()
    end)
    panel:SetScript("OnMouseUp", function(self2,d)
        ResetCursor()
    end)

    panel:SetScript('OnMouseWheel',function(self, d)
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
        setStrColor()
        print(id, addName, FONT_SIZE..': '..size)
    end)

    panel:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' and not IsAltKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
        ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
    end)
    panel:SetScript('OnLeave', function (self)
        self:SetButtonState('NORMAL')
    end)

    setStrColor()
    if Save.money then set_Money_Event() end--设置,钱,事件
    set_System_FPSMS()--设置系统fps ms
    set_Fps_Ms()--设置, fps, ms, 数值
    if Save.equipmetLevel or Save.durabiliy then
        set_Durabiliy_EquipLevel_Event()--设置装等,耐久度,事件
    end
end

panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsSave and not WoWToolsSave[addName] then
            panel:SetButtonState('PUSHED')
        end
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        local check=e.CPanel(addName, not Save.disabled, true)
        check:SetScript('OnClick', function()
            Save.disabled= not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), REQUIRES_RELOAD)
        end)
        check:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_RIGHT");
            e.tips:ClearLines();
            e.tips:AddDoubleLine('fps ms', MONEY)
            e.tips:AddDoubleLine(DURABILITY, EQUIPSET_EQUIP..LEVEL)
            e.tips:Show();
        end)
        check:SetScript('OnLeave', function() e.tips:Hide() end)

        if Save.disabled then
            panel:UnregisterAllEvents()
        else
            Init()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='PLAYER_MONEY' then
        C_Timer.After(0.5, setMoney)

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        setDurabiliy()

    elseif event=='PLAYER_EQUIPMENT_CHANGED' then
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
