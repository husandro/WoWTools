local id, e = ...

local Save={
    world= e.Player.region==5 and '大脚世界频道' or WORLD,
    myChatFilter= true,--过滤，多次，内容
    myChatFilterNum=70,
}
local addName='ChatButtonWorldChannel'
local button


local Check=function(name)
    if not select(2,GetChannelName(name)) then
        return 0--不存存在
    else
        local tab={GetChatWindowChannels(SELECTED_CHAT_FRAME:GetID())}
        for i= 1, #tab, 2 do
            if tab[i]==name then
                return 1--存在2
            end
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
    if not button.leftClickTips then
        button.leftClickTips=e.Cstr(button, {size=10, color=true, justifyH='CENTER'})--10, nil, nil, true, nil, 'CENTER')
        button.leftClickTips:SetPoint('BOTTOM',0,2)
    end
    button.channelNumber=channelNumber
    local text
    if name then
        text= name=='大脚世界频道' and '世' or e.WA_Utf8Sub(name, 1, 3)
    else
        text= e.onlyChinese and '无' or NONE
    end

    if name == Save.world then
        button.texture:SetAtlas('WildBattlePet')
    elseif texture then
        button.texture:SetTexture(texture)
    else
        button.texture:SetAtlas('128-Store-Main')
    end
    button.leftClickTips:SetText(text)
end

local function sendSay(name, channelNumber)--发送
    Save.lastName= name
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


--#######
--屏蔽内容
--#######
local filterTextTab={}--记录, 屏蔽内容
local function myChatFilter(_, _, msg, name)
    if name== e.Player.name_realm or e.GetFriend(name) or e.GroupGuid[name:gsub('%-'..e.Player.realm, '')] then--自已, 好友
        return

    elseif filterTextTab[msg] and filterTextTab[msg].name== name then
        filterTextTab[msg].num= filterTextTab[msg].num +1
        return true
    elseif strlenutf8(msg)>Save.myChatFilterNum or msg:find('<.->') or msg:find('WTS') then
        if not filterTextTab[msg] then
            filterTextTab[msg]={num=1, name=name}
        else
            filterTextTab[msg].num= filterTextTab[msg].num +1
        end
        return true
    else
        filterTextTab[msg]={num=1, name=name}
    end
end


--#####
--主菜单
--#####
local function get_myChatFilter_Text()
    return (e.onlyChinese and '内容限'..Save.myChatFilterNum..'个字符以内' or ERR_VOICE_CHAT_CHANNEL_NAME_TOO_LONG:gsub(CHANNEL_CHANNEL_NAME,''):gsub('30', Save.myChatFilterNum))
end

local function addMenu(name, channelNumber, level)--添加菜单
    local check=Check(name)
    local text=name
    local clubId=name:match('Community:(%d+)');
    if clubId then
        e.LoadDate({id=clubId, type='club'})
    end
    local communityName, communityTexture
    local clubInfo= clubId and C_Club.GetClubInfo(clubId)--社区名称
    if clubInfo and (clubInfo.shortName or clubInfo.name) then
        text='|cnGREEN_FONT_COLOR:'..(clubInfo.shortName or clubInfo.name)..'|r'
        communityName=clubInfo.shortName or clubInfo.name
        communityTexture=clubInfo.avatarId
    end
    text=((channelNumber and channelNumber>0) and channelNumber..' ' or '')..text--频道数字
    text=text..(button.channelNumber==channelNumber and e.Icon.left or '')--当前点击提示

    local info={
        text= text,
        checked= check==1,
        colorCode= check==0 and '|cffff0000' or check==2 and '|cff606060',
        tooltipOnButton=true,
        tooltipTitle=(e.onlyChinese and '屏蔽' or IGNORE)..' Alt+'..e.Icon.left,
        tooltipText= check==2 and (e.onlyChinese and '已屏蔽' or IGNORED),
        menuList= name==Save.world and 'WORLD',
        hasArrow= name==Save.world,
        icon=communityTexture,
        arg1={texture=communityTexture, name=name, communityName= communityName, channelNumber= channelNumber},
        keepShownOnClick= true,
        func=function(_, arg1)
            if IsAltKeyDown() then
                setJoin(arg1.name, nil, nil, true)--加入,移除,屏蔽
            else
                sendSay(arg1.name, arg1.channelNumber)
                setLeftClickTips(arg1.communityName or arg1.name, arg1.channelNumber, arg1.texture)--设置点击提示,频道字符
            end
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end

local function InitMenu(_, level, type)--主菜单
    local info
    if type=='WORLD' then
        info= {
            text= e.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''),
            notCheckable=true,
            keepShownOnClick= true,
            func= function()
                StaticPopupDialogs[id..addName..'changeNamme']={
                    text=(e.onlyChinese and '修改名称' or EQUIPMENT_SET_EDIT:gsub('/.+',''))..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI ),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=1,
                    button1= e.onlyChinese and '确定' or OKAY,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnShow= function(self2)
                        self2.editBox:SetText(Save.world)
                        self2.button1:SetEnabled(false)
                    end,
                    OnHide= function(self2)
                        self2.editBox:SetText("")
                        e.call('ChatEdit_FocusActiveWindow')
                    end,
                    OnAccept= function(self2, data)
                        Save.world= self2.editBox:GetText()
                        e.Reload()
                    end,
                    EditBoxOnTextChanged=function(self2, data)
                        local text= self2:GetText()
                        self2:GetParent().button1:SetEnabled(text~= Save.world and text:gsub(' ', '')~='')
                    end,
                    EditBoxOnEscapePressed = function(self2)
                        self2:SetAutoFocus(false)
                        self2:ClearFocus()
                        self2:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'changeNamme')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='IGNORE' then--屏蔽刷屏
        for text, tab in pairs(filterTextTab) do
            info={
                text= text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle= format(e.onlyChinese and "%d次" or COMMUNITIES_INVITE_MANAGER_USES, tab.num),
                tooltipText=tab.name,
                arg1= tab.name,
                keepShownOnClick= true,
                func= function(_, arg1)
                    if arg1 then
                        e.Say(nil, arg1)
                    end
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= (e.onlyChinese and '设置' or SETTINGS)..' |cnGREEN_FONT_COLOR:'..Save.myChatFilterNum,
            notCheckable=true,
            func= function()
                StaticPopupDialogs[id..addName..'myChatFilterNum']= {
                    text=id..' '..addName..'|n|n'..get_myChatFilter_Text(),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=true,
                    button1= e.onlyChinese and '修改' or EDIT,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnShow = function(self)
                        self.editBox:SetNumeric(true)
                        self.editBox:SetNumber(Save.myChatFilterNum)
                    end,
                    OnAccept = function(self)
                        local num= self.editBox:GetNumber()
                        Save.myChatFilterNum= num
                        print(id, e.cn(addName), get_myChatFilter_Text())
                    end,
                    EditBoxOnTextChanged=function(self)
                        local num= self:GetNumber() or 0
                        self:GetParent().button1:SetEnabled(num>=10)
                    end,
                    EditBoxOnEscapePressed = function(self2)
                        self2:SetAutoFocus(false)
                        self2:ClearFocus()
                        self2:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'myChatFilterNum')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    local channelNumber2 = GetChannelName(Save.world)
    addMenu(Save.world , channelNumber2, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    local find
    local channels = {GetChannelList()}
    for i = 1, #channels, 3 do
        local channelNumber, name, disabled = channels[i], channels[i+1], channels[i+2]
        if not disabled and channelNumber and name~=Save.world then
            addMenu(name, channelNumber, level)
            find=true
        end
    end

    if find then
        e.LibDD:UIDropDownMenu_AddSeparator(level)
    end
    find=0
    for _, _ in pairs(filterTextTab) do
        find= find+1
    end
    info={
        text= (e.onlyChinese and '屏蔽刷屏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, IGNORE, CLUB_FINDER_REPORT_SPAM)).. (find>0 and ' |cnRED_FONT_COLOR:'..find..'|r' or ''),
        checked= Save.myChatFilter,
        menuList='IGNORE',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle='CHAT_MSG_CHANNEL',
        tooltipText= get_myChatFilter_Text(),
        keepShownOnClick= true,
        func= function()
            Save.myChatFilter= not Save.myChatFilter and true or nil
            if Save.myChatFilter then
                ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
            else
                ChatFrame_RemoveMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
            end
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end



--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    button.texture:SetAtlas('128-Store-Main')

    button:SetScript("OnMouseDown",function(self,d)
        if d=='LeftButton' and self.channelNumber and self.channelNumber>0 then
            e.Say('/'..self.channelNumber)
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
    end)

    if Save.lastName then
        local channelNumber = GetChannelName(Save.lastName)
        if channelNumber and channelNumber>0 then
            button.channelNumber= channelNumber
            setLeftClickTips(Save.lastName, channelNumber)
        end
    end
    if Save.myChatFilter then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", myChatFilter)
    end
end


--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save
                Save.myChatFilterNum= Save.myChatFilterNum or 70
                Save.world= Save.world or CHANNEL_CATEGORY_WORLD

                button= e.Cbtn2({
                    name=nil,
                    parent=WoWToolsChatButtonFrame,
                    click=true,-- right left
                    notSecureActionButton=true,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })

                Init()

                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event== 'PLAYER_ENTERING_WORLD' then
        filterTextTab={}--记录, 屏蔽内容

    end
end)
