local id, e = ...

local Save={}
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local Check=function(name)
    if not select(2,GetChannelName(name)) then
        if name=='大脚世界频道' then
            panel.texture:SetShown(false)
        end
        return 0--不存存在
    else
        local tab={GetChatWindowChannels(SELECTED_CHAT_FRAME:GetID())}
        for i= 1, #tab, 2 do
            if tab[i]==name then
                if name=='大脚世界频道' then
                    panel.texture:SetDesaturated(false)
                    panel.texture:SetShown(true)
                end
                return 1--存在2
            end
        end

        if name=='大脚世界频道' then
            panel.texture:SetDesaturated(true)
            panel.texture:SetShown(true)
        end
        return 2--屏蔽
    end
end

local function setJoin(name, join, leave, remove)--加入,移除, 屏蔽
    if leave then
        LeaveChannelByName(name);
    elseif join then
        JoinPermanentChannel(name);
        ChatFrame_AddChannel(SELECTED_CHAT_FRAME, name);
    elseif remove then
        ChatFrame_RemoveChannel(SELECTED_CHAT_FRAME, name);
    end
    C_Timer.After(1, function() Check(name) end)
end

local function setLeftClickTips(name, channelNumber, texture)--设置点击提示,频道字符
    channelNumber= (channelNumber and channelNumber>0) and channelNumber or nil
    if channelNumber then
        panel.channelNumber=channelNumber
    end
    if channelNumber and not panel.leftClickTips then
        panel.leftClickTips=e.Cstr(panel, 10, nil, nil, true, nil, 'CENTER')
        panel.leftClickTips:SetPoint('BOTTOM',0,7)
    end
    if panel.leftClickTips and channelNumber then
        panel.channelNumber=channelNumber
        local text
        if texture then
            text='|T'..texture..':0|t'
        else
            text=name=='大脚世界频道' and '世' or e.WA_Utf8Sub(name, 1, 4)
        end
        panel.leftClickTips:SetText(text)
    end
end

local function sendSay(name, channelNumber)--发送
    local check=Check(name)
    if check==0 or not channelNumber or channelNumber==0 then
        setJoin(name, true)
        C_Timer.After(1, function()
            local channelNumber2 = GetChannelName(name)
            if channelNumber2 and channelNumber2>0 then
                e.Say('/'..channelNumber2)
                setLeftClickTips(name, channelNumber2)--设置点击提示,频道字符
            else
                e.Say(SLASH_JOIN4..' '..name)
            end
        end)
    else
        if check==2 and SELECTED_CHAT_FRAME:GetID()~=2 then
            setJoin(name, true)
        end
        if channelNumber then
            setLeftClickTips(name, channelNumber)--设置点击提示,频道字符
            e.Say('/'..channelNumber);
        else
            e.Say(SLASH_JOIN4..' '..name)
        end
    end    
end

--#####
--主菜单
--#####
local function addMenu(name, channelNumber, level)--添加菜单
    local check=Check(name)
    local text=name
    local clubId=name:match('Community:(%d+)');
    local communityName, communityTexture
    local info= clubId and C_Club.GetClubInfo(clubId)--社区名称
    if info and (info.shortName or info.name) then 
        text='|cnGREEN_FONT_COLOR:'..(info.shortName or info.name)..'|r'
        communityName=info.shortName or info.name
        communityTexture=info.avatarId
    end
    text=((channelNumber and channelNumber>0) and channelNumber..' ' or '')..text--频道数字
    text=text..(panel.channelNumber==channelNumber and e.Icon.left or '')--当前点击提示

    local info={
        text= text,
        checked= check==1,
        colorCode= check==0 and '|cffff0000' or check==2 and '|cff606060',
        tooltipOnButton=true,
        tooltipTitle=IGNORE..' Alt+'..e.Icon.left,
        tooltipText= check==2 and IGNORED,
        icon=communityTexture,
        func=function()
            if IsAltKeyDown() then
                setJoin(name, nil, nil, true)--加入,移除,屏蔽
            else
                sendSay(name, channelNumber)
                setLeftClickTips(communityName or name, channelNumber, communityTexture)--设置点击提示,频道字符
            end
        end
    }
    UIDropDownMenu_AddButton(info, level)

    if not panel.channelNumber then
        setLeftClickTips(communityName or name, channelNumber)--设置点击提示,频道字符
    end
end

local function InitMenu(self, level, type)--主菜单
    local info
    if e.Player.zh then
        local channelNumbern = GetChannelName('大脚世界频道')
        addMenu('大脚世界频道' , channelNumbern, level)
        UIDropDownMenu_AddSeparator(level)
    end
    local channels = {GetChannelList()}
    for i = 1, #channels, 3 do
        local channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
        if not disabled and name~='大脚世界频道' then
            addMenu(name, channelNumber, level)
        end
    end
end

--####
--初始
--####
local function Init()  
    if e.Player.zh then
        panel.texture:SetAtlas('WildBattlePetCapturable')
    else
        panel.texture:SetAtlas('128-Store-Main')
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript("OnMouseDown",function(self,d)
        if d=='LeftButton' then
            if panel.channelNumber and panel.channelNumber>0 then
                e.Say('/'..panel.channelNumber)
            else
                ToggleDropDownMenu(1, nil,self.Menu, self, 15,0)    
            end
        elseif d=='RightButton' then
            ToggleDropDownMenu(1, nil,self.Menu, self, 15,0)
        end
    end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
            return
        end
        Save= WoWToolsSave and WoWToolsSave[addName] or Save
        Init()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)
