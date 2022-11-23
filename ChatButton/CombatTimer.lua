local id, e = ...
local addName= COMBAT..TIME_LABEL:gsub(':','')
local Save= {textScale=1.2, classColor=true, Say=120}--Say=120, insTime=true, insKill=true, insDead=true, col=true}
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

local OnLineTime--在线时间
local OnCombatTime--战斗时间
local OnAFKTime--AFK时间
local LastText--最后时间提示

local chatStarTime
local function setText()--设置显示内容
    local text
    if OnCombatTime then--战斗时间
        local combat, sec = e.GetTimeInfo(OnCombatTime, not Save.timeTypeText)
        if Save.Say then--喊话
            sec=math.floor(sec);
            if sec ~= chatStarTime and sec > 0 and sec%Save.Say==0  then
                chatStarTime=sec
                e.Chat(COMBAT..' '..SecondsToClock(sec):gsub('：',':'), nil, true)
            end            
        end
        text= text and text..'\n' or ''
        text= text .. COMBAT..'|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a'..combat
    end
    if OnAFKTime then
        text= text and text..'\n' or ''
        text= text .. AFK..e.Icon.clock2..e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)
    end
    
    panel.text:SetText(text or LastText or '')
end

local function check_Event()--检测事件
    if not panel.updatFrame then
        return
    end

    local time=GetTime()
    if UnitIsAFK('player') then
      --[[
  if not OnAFKTime then
            PlaySoundFile('Applause')
        end
]]
        OnAFKTime= OnAFKTime or time 
        LastText=nil

    elseif OnAFKTime then 
        LastText= e.Icon.clock2..'|cnGREEN_FONT_COLOR:'..AFK..e.GetTimeInfo(OnAFKTime, not Save.timeTypeText)..'|r'
        print(id, addName, LastText);
        OnAFKTime=nil;
    end

    if UnitAffectingCombat('player') then
        OnCombatTime= OnCombatTime or time
        LastText=nil
    elseif OnCombatTime then
        local text, sec=e.GetTimeInfo(OnCombatTime, not Save.timeTypeText)
        LastText= '|A:warfronts-basemapicons-horde-barracks-minimap:0:0|a|cnGREEN_FONT_COLOR:'..COMBAT..text..'|r'
        if sec>8 then
            print(id, addName, LastText);
        end
        OnCombatTime=nil
        chatStarTime=nil
    end

    panel.updatFrame:SetShown((OnAFKTime or OnCombatTime) and true or false)--设置更新数据,显示/隐藏 panel.updatFrame
    setText()--设置显示内容
end


local function setTexture()--设置,图标, 颜色
    local texture
    if not Save.specializationTexture then
        local faction=UnitFactionGroup('player')
        if faction=='Alliance' then
            texture= 255130
        elseif faction=='Horde' then
            texture= 2565244
        end
    else
        local specializationID=GetSpecialization()--当前专精
        if specializationID then
            texture = select(4, GetSpecializationInfo(specializationID))
        end
    end
    if texture then 
        panel.texture:SetTexture(texture)
    else
        panel.texture:SetAtlas('Mobile-MechanicIcon-Powerful')
    end
    
    if Save.classColor then
        local r,g,b= GetClassColor(UnitClassBase('player'))
        if panel.text then
            panel.text:SetTextColor(r,g,b)
        end
        panel.texture2:SetColorTexture(r,g,b)
    else
        if panel.text then
            panel.text:SetTextColor(0.8, 0.8, 0.8)
        end
        panel.texture2:SetColorTexture(1,0,0)
    end
end

local function setTextFrame()--设置显示内容, 父框架panel.textFrame, 内容panel.text
    if Save.disabledText then
        return
    end
    panel.textFrame=e.Cbtn(panel, nil, nil, nil, nil, true, {20,20})
    if Save.textFramePoint then
        panel.textFrame:SetPoint(Save.textFramePoint[1], UIParent, Save.textFramePoint[3], Save.textFramePoint[4], Save.textFramePoint[5])
    else
        panel.textFrame:SetPoint('BOTTOMLEFT', panel, 'BOTTOMRIGHT')
    end
    panel.textFrame:RegisterForDrag("RightButton")
    panel.textFrame:SetMovable(true)
    panel.textFrame:SetClampedToScreen(true)
    panel.textFrame:SetScript("OnDragStart", function(self, d)
        if not IsModifierKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel.textFrame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.textFramePoint={self:GetPoint(1)}
        Save.textFramePoint[2]=nil
        print(id, addName, RESET_POSITION, 'Alt+'..e.Icon.right)
    end)
    panel.textFrame:SetScript("OnMouseDown", function(self,d)
        if d=='LeftButton' then--提示移动
            panel.text:SetText('')
            print(id,addName, (CLEAR or KEY_NUMLOCK_MAC)..e.Icon.left, '|cnGREEN_FONT_COLOR:'..NPE_MOVE..e.Icon.right, '|cnGREEN_FONT_COLOR:'..UI_SCALE..'Alt+'..e.Icon.mid)

        elseif d=='RightButton' and not IsModifierKeyDown() then--移动光标
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and IsAltKeyDown() then--还原
            Save.textFramePoint=nil
            panel.textFrame:ClearAllPoints()
            panel.textFrame:SetPoint('BOTTOMLEFT', panel, 'BOTTOMRIGHT')
        end
    end)
    panel.textFrame:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    panel.textFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if IsAltKeyDown() then
            local text=panel.text:GetText()
            if not text or text=='' then
                panel.text:SetText(UI_SCALE)
            end
            local sacle=Save.textScale or 1
            if d==1 then
                sacle=sacle+0.1
            elseif d==-1 then
                sacle=sacle-0.1
            end
            if sacle>3 then
                sacle=3
            elseif sacle<0.6 then
                sacle=0.6
            end
            print(id, addName, UI_SCALE, sacle)
            panel.text:SetScale(sacle)
            Save.textScale=sacle
        end
    end)
   
    panel.text=e.Cstr(panel.textFrame)
    panel.text:SetPoint('BOTTOMLEFT')
    if Save.textScale and Save.textScale~=1 then
        panel.text:SetScale(Save.textScale)
    end

    panel.updatFrame=CreateFrame("Frame")
    panel.updatFrame:SetShown(true)

    local timeElapsed = 0
    panel.updatFrame:HookScript("OnUpdate", function (self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.3 then
            timeElapsed = 0
            setText()--设置显示内容
        end
    end)

    check_Event()--检测事件

    C_Timer.After(2, function()
        setTexture()--设置,图标, 颜色
    end)
end
--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type=='SETTINGS' then
        info={--图标类型
            text=EMBLEM_SYMBOL..': |cnGREEN_FONT_COLOR:'..(not Save.specializationTexture and FACTION or SPECIALIZATION)..'|r',
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=TYPE,
            tooltipText= FACTION..'\n'..SPECIALIZATION,
            func= function()
                Save.specializationTexture= not Save.specializationTexture and true or nil
                setTexture()--设置,图标
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--时间类型
            text=TIME_LABEL..' |cnGREEN_FONT_COLOR:'..(Save.timeTypeText and SecondsToTime(35) or '00:35')..'|r',
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=TYPE,
            tooltipText='00:35\n'..SecondsToTime(35),
            func= function()
                Save.timeTypeText= not Save.timeTypeText and true or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)


        info={--职业颜色
            text=CLASS_COLORS,
            checked= Save.classColor,
            colorCode= Save.classColor and e.Player.col or '|cffd0d0d0',
            func=function()
                Save.classColor= not Save.classColor and true or nil
                setTexture()--设置,图标, 颜色
            end
        }
        UIDropDownMenu_AddButton(info, level)

        info={--战斗时间,时间戳
            text=COMBAT..'|A:communities-icon-chat:0:0|a'..EVENTTRACE_TIMESTAMP..'120',
            checked= Save.Say and true or nil,
            tooltipOnButton=true,
            tooltipTitle=SAY,
            func= function()
                Save.Say= not Save.Say and 120 or nil
            end
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={--重置所有
            text=RESET..ALL,
            colorCode='|cffff0000',
            tooltipOnButton=true,
            tooltipTitle=RELOADUI,
            tooltipText=SLASH_RELOAD1,
            notCheckable=true,
            func=function()
                Save=nil
                C_UI.Reload()
            end
        }
        UIDropDownMenu_AddButton(info, level)
        
    else
        info={--在线时间
            text=GUILD_ONLINE_LABEL..e.Icon.clock2..TIME_LABEL:gsub(':','')..' '..e.GetTimeInfo(OnLineTime, not Save.timeTypeText),
            isTitle=true,
            notCheckable=true
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)

        info={
            text=SETTINGS,
            notCheckable=true,
            hasArrow=true,
            menuList='SETTINGS',
            colorCode= Save.disabledText and '|cff606060',
        }
        UIDropDownMenu_AddButton(info, level)
        
        info={
            text=INFO,
            checked=Save.disabledText,
            func=function()
                Save.disabledText= not Save.disabledText and true or nil
                print(id, addName, '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD)
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end


--####
--初始
--####
local function Init()
    OnLineTime=GetTime()

    if Save.point then
        panel:SetPoint(Save.point[1], UIParent, Save.point[3], Save.point[4], Save.point[5])
    else
        panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    end

    panel.texture2=panel:CreateTexture(nil, 'OVERLAY')
    panel.texture2:SetAllPoints(panel)
    panel.texture2:AddMaskTexture(panel.mask)
    panel.texture2:SetShown(false)

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")--菜单框架
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnMouseDown', function(self, d)
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
    end)

   
    setTextFrame()--设置显示内容,框架 panel.textFrame,内容 panel.text
end


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')
panel:RegisterEvent('PLAYER_FLAGS_CHANGED')--AFK

panel:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
--panel:RegisterEvent('PLAYER_ENTERING_WORLD')



panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel.texture2:SetShown(false)
        check_Event()--检测事件

    elseif event=='PLAYER_REGEN_DISABLED' then
        panel.texture2:SetShown(true)
        check_Event()--检测事件

    elseif event=='PLAYER_SPECIALIZATION_CHANGED' then
        setTexture()--设置,图标

    --elseif event=='PLAYER_ENTERING_WORLD' then

    elseif event=='PLAYER_FLAGS_CHANGED' then
        check_Event()--检测事件
    end
end)

