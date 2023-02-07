local id, e = ...
local addName= 'Emoji'
local Save={Channels={}, disabled= not e.Player.zh and not e.Player.husandro }
local panel=e.Cbtn2('WoWToolsChatButtonEmoji', WoWToolsChatButtonFrame, true, false)

local frame--控制图标,显示,隐藏
local File={'Angel','Angry','Biglaugh','Clap','Cool','Cry','Cutie','Despise','Dreamsmile','Embarrass','Evil','Excited','Faint','Fight','Flu','Freeze','Frown','Greet','Grimace','Growl','Happy','Heart','Horror','Ill','Innocent','Kongfu','Love','Mail','Makeup','Meditate','Miserable','Okay','Pretty','Puke','Shake','Shout','Shuuuu','Shy','Sleep','Smile','Suprise','Surrender','Sweat','Tear','Tears','Think','Titter','Ugly','Victory','Volunteer','Wronged','Mario',}
local Channels={
    "CHAT_MSG_CHANNEL", -- 公共频道
    "CHAT_MSG_SAY",  -- 说
    "CHAT_MSG_YELL",-- 大喊
    "CHAT_MSG_RAID",-- 团队
    "CHAT_MSG_RAID_LEADER", -- 团队领袖
    "CHAT_MSG_PARTY", -- 队伍
    "CHAT_MSG_PARTY_LEADER", -- 队伍领袖
    "CHAT_MSG_GUILD",-- 公会
    "CHAT_MSG_AFK", -- AFK玩家自动回复
    "CHAT_MSG_DND", -- 切勿打扰自动回复
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_BN_WHISPER",
    "CHAT_MSG_BN_WHISPER_INFORM",
    "CHAT_MSG_COMMUNITIES_CHANNEL", --社区聊天内容        
}

local function setframeEvent()--设置隐藏事件
    if Save.notHideCombat then
        frame:UnregisterEvent('PLAYER_REGEN_DISABLED')
    else
        frame:RegisterEvent('PLAYER_REGEN_DISABLED')
    end
    if Save.notHideMoving then
        frame:UnregisterEvent('PLAYER_STARTED_MOVING')
    else
        frame:RegisterEvent('PLAYER_STARTED_MOVING')
    end
end

local function setButtons()--设置按钮
    local size= e.toolsFrame.size or 30
    local last, index, line=frame, 0, nil
    local function send(text, d)--发送信息
        text='{'..text..'}'
        if d =='LeftButton' then
            local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
            ChatFrameEditBox:Insert(text)
            ChatEdit_ActivateChat(ChatFrameEditBox)
        elseif d=='RightButton' then
            e.Chat(text)
        end
    end
    local function setPoint(button, text)--设置位置, 操作
        if index>0 and select(2, math.modf(index / 10))==0 then
            button:SetPoint('BOTTOMLEFT', line, 'TOPLEFT')
            line=button
        else
            button:SetPoint('BOTTOMLEFT', last, 'BOTTOMRIGHT')
            if index==0 then line=button end
        end
        button:SetScript('OnMouseDown', function(self, d) send(text, d) end)
        button:SetScript('OnEnter', function(self)
            e.tips:SetOwner(frame, "ANCHOR_RIGHT", 0,125)
            e.tips:ClearLines()
            e.tips:AddLine(text)
            e.tips:Show()
        end)
        button:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    for i, texture in pairs(File) do
        local button=e.Cbtn(frame,nil,nil,nil,nil, true,{size,size})
        setPoint(button, e.L['EMOJI'][i])
        button:SetNormalTexture('Interface\\Addons\\WoWTools\\Sesource\\Emojis\\'..texture)
        last=button
        index=index+1
    end
    for i= 1, 8 do
        local button=e.Cbtn(frame,nil,nil,nil,nil, true,{size,size})
        setPoint(button, 'rt'..i)
        button:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..i)
        last=button
        index=index+1
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)
    local info
    if type then
        info={
            text= e.onlyChinse and '全选' or  MENU_EDIT_SELECT_ALL or ALL,--全选
            notCheckable=true,
            func=function()
                Save.Channels={}
                print(id, addName, e.onlyChinse and '聊天频道' or CHAT_CHANNELS,  e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinse and '清除' or  CLEAR or KEY_NUMLOCK_MAC,--全清
            notCheckable=true,
            func=function()
                for _, channel in pairs(Channels) do
                    Save.Channels[channel]=true
                end
                print(id, addName, e.onlyChinse and '聊天频道' or CHAT_CHANNELS,  e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        for _, channel in pairs(Channels) do
            info={
                text=_G[channel] or channel,
                checked=not Save.Channels[channel],
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD,
                tooltipText=channel,
                func=function()
                    Save.Channels[channel]= not Save.Channels[channel] and true or nil
                    print(id, addName, e.onlyChinse and '聊天频道' or CHAT_CHANNELS,  e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end
    else
        info={
            text= e.onlyChinse and '进入战斗' or ENTERING_COMBAT,--进入战斗时, 隐藏
            checked=not Save.notHideCombat,
            func=function() Save.notHideCombat = not Save.notHideCombat and true or nil setframeEvent() end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '隐藏' or HIDE,
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '移动' or NPE_MOVE,--移动时, 隐藏
            checked=not Save.notHideMoving,
            func=function() Save.notHideMoving = not Save.notHideMoving and true or nil setframeEvent() end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '隐藏' or HIDE,
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinse and '过移图标时' or ENTER_LFG..EMBLEM_SYMBOL,--过移图标时,显示
            checked=Save.showEnter,
            func=function() Save.showEnter = not Save.showEnter and true or nil end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '显示' or SHOW,
        }
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinse and '聊天频道' or CHAT_CHANNELS,
            notCheckable=true,
            menuList='Channels',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
        info={
            text= e.onlyChinse and '重置' or RESET,
            notCheckable=true,
            func=function() Save=nil C_UI.Reload() end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '重新加载UI' or RELOADUI,
            colorCode='|cffff0000'
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####
local function Init()
    panel:SetPoint('LEFT', WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=panel

    frame=e.Cbtn(panel,nil,nil,nil,nil, true,{10, e.toolsFrame.size or 30})--控制图标,显示,隐藏
    if Save.Point then
        frame:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
    else
        frame:SetPoint('BOTTOMRIGHT',panel, 'TOPLEFT', -120,2)
    end
    frame:SetShown(false)
    frame:RegisterForDrag("RightButton")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    setframeEvent()--设置隐藏事件
    frame:SetScript('OnEvent', function(self) self:SetShown(false) end)
    frame:SetScript("OnDragStart", function(self,d )
        if not IsModifierKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
        print(id, addName, RESET_POSITION, 'Alt+'..e.Icon.right)
    end)
    frame:SetScript('OnMouseDown',function(self, d)
        local key=IsModifierKeyDown()
        if d=='RightButton' and IsAltKeyDown() then--还原
            Save.Point=nil
            self:ClearAllPoints()
            self:SetPoint('BOTTOMRIGHT',panel, 'TOPLEFT', -120,2)
        elseif d=='RightButton' and not key then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        elseif d=='LeftButton' then--提示信息
            print(id, addName, NPE_MOVE..e.Icon.right)
        end
    end)
    frame:SetScript("OnMouseUp", function(self, d)
        ResetCursor()
    end)
    frame:SetScript("OnLeave",function()
        ResetCursor()
    end)

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    setButtons()--设置按钮

    panel.texture:SetTexture('Interface\\Addons\\WoWTools\\Sesource\\Emojis\\greet')
    panel:SetScript('OnEnter', function()
        if Save.showEnter then
            frame:SetShown(true)
        end
    end)
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            frame:SetShown(not frame:IsShown())
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)--主菜单
        end
    end)

    local Tab={}
    for index, text in pairs(e.L['EMOJI']) do
        Tab['{'..text..'}']= '|TInterface\\Addons\\WoWTools\\Sesource\\Emojis\\'..File[index]..':0|t'
    end
    local function ChatEmoteFilter(self, event, msg, ...)
        local str=msg
        for text, icon in pairs(Tab) do
            str= str:gsub(text, icon)
        end
        if str ~=msg then
            return false, str, ...
        end
    end

    for _, channel in pairs(Channels) do
        if not Save.Channels[channel] then
            ChatFrame_AddMessageEventFilter(channel, ChatEmoteFilter)
        end
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            local sel=CreateFrame("CheckButton", nil, WoWToolsChatButtonFrame.sel, "InterfaceOptionsCheckButtonTemplate")
            sel.text:SetText('Emoji')
            sel:SetPoint('LEFT', WoWToolsChatButtonFrame.sel.text, 'RIGHT')
            sel:SetChecked(not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.GetEnabeleDisable(not WoWToolsChatButtonFrame.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            if WoWToolsChatButtonFrame.disabled or Save.disabled then--禁用Chat Button
                self:SetShown(false)
                panel:UnregisterAllEvents()

            else
                Save.Channels= Save.Channels or {}
                if not Save.disabled then
                    Init()
                end
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
