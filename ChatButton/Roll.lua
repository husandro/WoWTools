local id, e = ...
local addName=ROLL
local Save={
    autoClear=true,--进入战斗时,清除数据
    save={},--保存数据,最多30个
}

local button
local panel= CreateFrame("Frame")
local Tab={}



local Max, Min
local function findRolled(name)--查找是否ROLL过
    for _, tab in pairs(Tab) do
        if tab.name==name then
            return true
        end
    end
end

local rollText= e.Magic(RANDOM_ROLL_RESULT)--"%s掷出%d（%d-%d）";
local function setCHAT_MSG_SYSTEM(text)
    if not text then
        return
    end
    local name, roll, minText, maxText=text:match(rollText)
    roll=  roll and tonumber(roll)
    if not (name and roll and minText=='1' and maxText=='100') then
        return
    end
    name=name:find('%-') and name or (name..'-'..e.Player.realm)
    if not findRolled(name) then
        if not Max or roll>Max then
            if Max then
                Min= (not Min or Min>Max) and Max or Min
            end
            Max=roll
        elseif not Min or Min>roll then
            Min=roll
        end
        if not button.rightTopText then
            button.rightTopText=e.Cstr(button, {color={r=0,g=1,b=0}})
            button.rightTopText:SetPoint('TOPLEFT',2,-3)
        end
        button.rightTopText:SetText(Max)

        if Min then
            if not button.rightBottomText then
                button.rightBottomText=e.Cstr(button, {color={r=0,g=1,b=0}})
                button.rightBottomText:SetPoint('BOTTOMRIGHT',-2,3)
            end
            button.rightBottomText:SetText(Min)
        end
    end

    local faction,guid
    if name==e.Player.name_realm then
        faction= e.Player.faction
        guid= e.Player.guid
    elseif e.GroupGuid[name] then
        faction= e.GroupGuid[name].faction
        guid= e.GroupGuid[name].guid
    end

    table.insert(Tab, {name=name,
                        roll=roll,
                        date=date('%X'),
                        text=text,
                        guid= guid,
                        faction= faction,
                    })
end


local function get_Save_Max()--清除时,保存数据
    local maxTab, max= nil, 0
    for _, tab in pairs(Tab) do
        if tab.roll and tab.roll>max then
            maxTab= tab
            if tab==100 then
                break
            end
        end
    end
    if maxTab then
        if #Save.save>=30 then
            table.remove(Save.save, 1)
        end
        table.insert(Save.save, maxTab)
    end
end

local function setRest()--重置
    get_Save_Max()--清除时,保存数据
    Tab={}
    Max, Min= nil, nil
    if button.rightBottomText then
        button.rightBottomText:SetText('')
    end
    if button.rightTopText then
        button.rightTopText:SetText('')
    end
end

local function setAutoClearRegisterEvent()--注册自动清除事件
    if Save.autoClear then
        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
        if not button.autoClearTips then
            button.autoClearTips= button:CreateTexture(nil,'OVERLAY')
            button.autoClearTips:SetPoint('BOTTOMLEFT',4, 4)
            button.autoClearTips:SetSize(12,12)
            button.autoClearTips:SetAtlas('bags-button-autosort-up')
            --button.autoClearTips:SetVertexColor(e.Player.r, e.Player.g, e.Player.b)
        end
    else
        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')
    end
    if button.autoClearTips then
        button.autoClearTips:SetShown(Save.autoClear)
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type=='SAVE' then
        for _, tab in pairs(Save.save) do
            info={
                text='|cffffffff'..tab.roll..'|r '..e.GetPlayerInfo({unit=tab.unit, guid=tab.guid, name=tab.name, reName=true, reRealm=true})..' '..tab.date,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=tab.text,
                tooltipText=tab.date..'|n|n'..(e.onlyChinese and '发送信息' or SEND_MESSAGE)..e.Icon.left,
                arg1=tab.text,
                func=function(self2, arg1)
                    e.Chat(arg1)
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        info={
            text= e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2,
            icon= 'bags-button-autosort-up',
            notCheckable=true,
            colorCode= #Save.save==0 and '|cff606060',
            func=function()
                Save.save={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    local tabNew={}
    for _, tab in pairs(Tab) do
        info={
            text='|cffffffff'..tab.roll..'|r '..e.GetPlayerInfo({unit=tab.unit, guid=tab.guid, name=tab.name, reName=true, reRealm=true}) ..' '..tab.date,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle=tab.text,
            tooltipText=tab.date..'|n|n'..(e.onlyChinese and '发送信息' or SEND_MESSAGE)..e.Icon.left,
            arg1=tab.arg1,
            func=function(_, arg1)
                e.Chat(arg1)
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
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    info={
        text= (#Tab>0 and '|A:bags-greenarrow:0:0|a' or '')..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        notCheckable= true,
        colorCode= #Tab==0 and '|cff606060',
        menuList= 'SAVE',
        hasArrow= true,
        func=function()
            setRest()--重置
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '自动清除' or AUTO_JOIN:gsub(JOIN,SLASH_STOPWATCH_PARAM_STOP2),
        icon= 'bags-button-autosort-up',
        checked=Save.autoClear,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '进入战斗时: 清除' or (ENTERING_COMBAT..': '..(SLASH_STOPWATCH_PARAM_STOP2)),
        --tooltipText= e.onlyChinese and '记录仅限有队伍' or (PVP_RECORD..LFG_LIST_CROSS_FACTION:format(HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)),
        func=function()
            Save.autoClear= not Save.autoClear and true or false
            setAutoClearRegisterEvent()--注册自动清除事件
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

   
end


--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    setAutoClearRegisterEvent()--注册自动清除事件

    button.texture:SetTexture('Interface\\PVPFrame\\Icons\\PVP-Banner-Emblem-47')


    button:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' then
            RandomRoll(1, 100)
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save
                Save.save = Save.save or {}

                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

                Init()
                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent('CHAT_MSG_SYSTEM')
            end
            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then

            get_Save_Max()--清除时,保存数据
            WoWToolsSave[addName]=Save
        end

    elseif event=='CHAT_MSG_SYSTEM' then
        setCHAT_MSG_SYSTEM(arg1)

    elseif event=='PLAYER_REGEN_DISABLED' then
        setRest()--重置
    end
end)