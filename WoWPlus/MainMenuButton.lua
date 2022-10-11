local id, e = ...
local addName=MAINMENU_BUTTON
local Save={equipmetLevel=true}

local panel=CreateFrame('Button', nil, UIParent)
panel:SetSize(12,12)
panel:SetHighlightAtlas(e.Icon.highlight)
panel:SetPushedAtlas(e.Icon.pushed)
panel:SetFrameStrata('HIGH')

panel.fpsms=e.Cstr(panel, Save.size)--fpsms
panel.fpsms:SetPoint('BOTTOMRIGHT')

panel.money=e.Cstr(panel, Save.size)--钱
panel.money:SetPoint('BOTTOMRIGHT', panel.fpsms, 'BOTTOMLEFT', -4, 0)

panel.durabiliy=e.Cstr(panel,Save.size)--耐久度
panel.durabiliy:SetPoint('BOTTOMRIGHT', panel.money, 'BOTTOMLEFT', -4, 0)

local function setStrColor()
    local color= not Save.point and {r=0.65, g=0.65, b=0.65}
    e.Cstr(nil,Save.size, nil ,panel.fpsms, color)
    e.Cstr(nil,Save.size, nil ,panel.money, color)
    e.Cstr(nil,Save.size, nil ,panel.durabiliy, color)
end
local function setInit()
    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('BOTTOMRIGHT',-24, 0)
    end
    setStrColor()
end

panel:SetMovable(true)
panel:RegisterForDrag("RightButton");
panel:SetClampedToScreen(true);
panel:SetScript("OnDragStart", function(self2, d)
    if d=='RightButton' and not IsModifierKeyDown() then
        SetCursor('UI_MOVE_CURSOR')
        self2:StartMoving()
    end
end)
panel:SetScript("OnDragStop", function(self2)
    self2:StopMovingOrSizing()
    Save.point={self2:GetPoint(1)}
    print(id, addName, '|cFF00FF00Alt+'..e.Icon.right..KEY_BUTTON2..'|r: '.. TRANSMOGRIFY_TOOLTIP_REVERT)
    ResetCursor()
    setStrColor()
end)
panel:SetScript("OnMouseUp", function(self2,d)
    if d=='RightButton' and IsAltKeyDown() then
        self2:ClearAllPoints();
        self2:SetPoint('BOTTOMRIGHT',-24, 0)
        Save.point=nil
        setStrColor()
    end
    ResetCursor()
end)

local function setMoney()
    if not Save.money then
        return
    end
    local money = GetMoney()
    if money>10000 then
        panel.money:SetText(e.MK(money/1e4, 3)..'|TInterface/moneyframe/ui-silvericon:6|t')
    else
        panel.money:SetText('')
    end
end

local function setDurabiliy(re)
    if not Save.durabiliy and not re then
        return
    end
    local c = 0;
    local m = 0;
    for i = 1, 18 do
        local cur,max = GetInventoryItemDurability(i);
        if cur and max and max>0 then
            c = c + cur;
            m =m + max;
        end
    end
    local du='';
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
    if Save.durabiliy then
        panel.durabiliy:SetText(du)
    end
    if re then
       return du
    end
end

local timeElapsed = 0
panel:HookScript("OnUpdate", function (self, elapsed)--fpsms
    if Save.disabled then
        return
    end
    timeElapsed = timeElapsed + elapsed        
    if timeElapsed > 0.5 then
        timeElapsed = 0
        local t = select(4, GetNetStats())--ms
        if t>400 then 
            t='|cnRED_FONT_COLOR:'..t..'|r'
        elseif t>120 then
            t='|cnYELLOW_FONT_COLOR:'..t..'|r'
        else
            t='|cnGREEN_FONT_COLOR:'..t..'|r'
        end

        local r=math.modf(GetFramerate())--fps
        if r<10 then
            r='|cff00ff00'..r..'|r'
        elseif r<20 then
            r='|cffffff00'..r..'|r'
        elseif r>30 then
            r='|cff00ff00'..r..'|r'
        end
        t=t..'ms  '..r..'fps'

        panel.fpsms:SetText(t)
    end
end)

local function setEquipmentLevel()--角色图标显示装等
    local to, cu=GetAverageItemLevel()
    if to and cu and to>0 and Save.equipmetLevel then
        if not panel.playerEquipmentLevel then
            panel.playerEquipmentLevel=e.Cstr(CharacterMicroButton)
           -- panel.playerEquipmentLevel:SetPoint('BOTTOM', CharacterMicroButton ,'TOP',0,0)
           panel.playerEquipmentLevel:SetPoint('TOP', CharacterMicroButton ,'BOTTOM',0,6)
        end
        panel.playerEquipmentLevel:SetText(math.modf(cu))
        if to-cu>5 then
            panel.playerEquipmentLevel:SetTextColor(1,0,0)
        else
            panel.playerEquipmentLevel:SetTextColor(0.65, 0.65, 0.65)
        end
    else
        if panel.playerEquipmentLevel then panel.playerEquipmentLevel:SetText('') end
    end
end

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
    local key=IsModifierKeyDown()
    if d=='LeftButton' and not key then--fpsms
        if Save.disabled then
            Save.disabled=nil
        else
            Save.disabled=true
            panel.fpsms:SetText('')
        end
        print(id, addName, 'FpsMs', e.GetShowHide(not Save.disabled))
    elseif d=='LeftButton' and IsAltKeyDown() then--money
        if Save.money then
            Save.money=nil
            panel.money:SetText('')
        else
            Save.money=true
            setMoney()
        end
        print(id, addName, MONEY, e.GetShowHide(Save.money))
    elseif d=='LeftButton' and IsControlKeyDown() then--耐久度
        if Save.durabiliy then
            Save.durabiliy=nil
            panel.durabiliy:SetText("")
        else
            Save.durabiliy=true
            setDurabiliy()
        end
        print(id, addName, DURABILITY, e.GetShowHide(Save.durabiliy))
    elseif d=='LeftButton' and IsShiftKeyDown() then--角色图标显示装等
        if Save.equipmetLevel then
            Save.equipmetLevel=nil
        else
            Save.equipmetLevel=true
        end
        setEquipmentLevel()
        print(id,addName, EQUIPSET_EQUIP..LEVEL, e.GetShowHide(Save.equipmetLevel))
    end
end)

panel:SetScript('OnEnter', function()
    if UnitAffectingCombat('player') then
        return
    end
    e.tips:SetOwner(panel.money, "ANCHOR_LEFT",0, 30);
    e.tips:ClearLines();
    e.tips:AddLine(id, addName)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine('FpsMs: '..e.GetShowHide(not Save.disabled), e.Icon.left)
    e.tips:AddDoubleLine(MONEY..': '..e.GetShowHide(Save.money), 'Alt+'..e.Icon.left)
    local du=setDurabiliy(true)
    du = du and ' '..du or ''
    e.tips:AddDoubleLine(DURABILITY..du..': '..e.GetShowHide(Save.durabiliy), 'Ctrl+'..e.Icon.left)
    e.tips:AddDoubleLine(EQUIPSET_EQUIP..LEVEL..': '..e.GetShowHide(Save.equipmetLevel), 'Shift+'..e.Icon.left)
    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(UI_SCALE..': '..(Save.size or 12), e.Icon.mid)
    e.tips:AddDoubleLine(NPE_MOVE,e.Icon.right)
    e.tips:Show();
end)
panel:SetScript('OnLeave', function() e.tips:Hide() end)

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("PLAYER_MONEY")
panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
panel:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
        setInit()
        setMoney()
        setDurabiliy()
       C_Timer.After(2, setEquipmentLevel) --角色图标显示装等        
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='PLAYER_MONEY' then
        setMoney(panel)
    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        setDurabiliy()
        setEquipmentLevel()--角色图标显示装等
    elseif event=='PLAYER_EQUIPMENT_CHANGED' then
        setEquipmentLevel()--角色图标显示装等
    end
end)
