local id, e = ...
local addName=ROLL
local Save={autoClear=true}

local Tab={}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local rollText=RANDOM_ROLL_RESULT:gsub('%%d','%(%%d%+)')
rollText=rollText:gsub("%%s", "%(%.%-)")
local Max, Min

local function findRolled(name)--查找是否ROLL过
    for _, tab in pairs(Tab) do
        if tab.name==name then
            return true
        end
    end
end
local function setCHAT_MSG_SYSTEM(text)
    local name, roll, minText, maxText=text:match(rollText)
    roll= roll and tonumber(roll)
    if minText=='1' and maxText=='100' and name and roll then
        local unit=e.GroupGuid[name] and e.GroupGuid[name].unit
        if unit then
            if unit=='player' then
                name=e.Player.col..COMBATLOG_FILTER_STRING_ME..'|r'
            else
                name=e.GetPlayerInfo(unit,nil, true)
            end
        end
        if not findRolled(name) then
            if not Max or roll>Max then
                if Max then
                    Min= (not Min or Min>Max) and Max or Min
                end
                Max=roll
            elseif not Min or Min>roll then
                Min=roll
            end
            if not panel.rightTopText then
                panel.rightTopText=e.Cstr(panel, nil, nil, nil,{0,1,0})
                panel.rightTopText:SetPoint('TOPLEFT',2,-3)
            end
            panel.rightTopText:SetText(Max)
            if Min then
                if not panel.rightBottomText then
                    panel.rightBottomText=e.Cstr(panel, nil, nil, nil, {1,0,0})
                    panel.rightBottomText:SetPoint('BOTTOMRIGHT',-2,3)
                end
                panel.rightBottomText:SetText(Min)
            end
        end
        table.insert(Tab, {name=name, roll=roll, date=date('%X'), text=text})
    end
end

local function setRest()--重置
    Tab={}
    Max, Min= nil, nil
    if panel.rightBottomText then
        panel.rightBottomText:SetText('')
    end
    if panel.rightTopText then
        panel.rightTopText:SetText('')
    end
end

local function setAutoClearRegisterEvent()--注册自动清除事件
    if Save.autoClear then
        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
    else
        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info={
        text=CLEAR_ALL,
        notCheckable=true,
        func=function()
            setRest()--重置
        end
    }
    if #Tab==0 then
        info.colorCode='|cff606060'
    end
    UIDropDownMenu_AddButton(info, level)
    info={
        text=AUTO_JOIN:gsub(JOIN,'')..(	CLEAR or KEY_NUMLOCK_MAC),
        checked=Save.autoClear,
        tooltipOnButton=true,
        tooltipTitle=ENTERING_COMBAT..': '..(CLEAR or KEY_NUMLOCK_MAC),
        tooltipText=PVP_RECORD..LFG_LIST_CROSS_FACTION:format(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS),
        func=function()
            Save.autoClear= not Save.autoClear and true or false
            setAutoClearRegisterEvent()--注册自动清除事件
        end
    }
    UIDropDownMenu_AddButton(info, level)
    UIDropDownMenu_AddSeparator(level)

    local tabNew={}
    for _, tab in pairs(Tab) do
        info={
            text=tab.roll..' '..tab.name..' '..tab.date,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=tab.text,
            tooltipText=tab.date..'\n\n'..SEND_MESSAGE..e.Icon.left,
            func=function()
                e.Chat(tab.text)
            end,
        }
        if tabNew[tab.name] then
            info.colorCode='|cff606060'
        end
        if tab.roll==Max then--最高
            info.icon=e.Icon.select
        elseif tab.roll==Min then--最低2
            info.icon=450905
        end
        tabNew[tab.name]=true
        UIDropDownMenu_AddButton(info, level)
    end
    if #Tab>20 then
        UIDropDownMenu_AddSeparator(level)
        info={
            text=CLEAR_ALL,
            notCheckable=true,
            func=function()
                setRest()--重置
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--#######
--注册事件
--#######
local function setRegisterEvent()--注册事件
    if IsInGroup() then
        panel:RegisterEvent('CHAT_MSG_SYSTEM')
        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
    else
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end
end

--####
--初始
--####
local function Init()
    setRegisterEvent()--注册事件
    setAutoClearRegisterEvent()--注册自动清除事件

    panel.texture:SetTexture('Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47')
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' then
            RandomRoll(1, 100)
        else
            ToggleDropDownMenu(1, nil,self.Menu, self, 15,0)
        end
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('GROUP_ROSTER_UPDATE')

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

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        setRegisterEvent()--注册事件

    elseif event=='CHAT_MSG_SYSTEM' then
        setCHAT_MSG_SYSTEM(arg1)

    elseif event=='PLAYER_REGEN_DISABLED' then
        setRest()--重置
    end
end)