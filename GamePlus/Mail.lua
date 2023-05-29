if IsAddOnLoaded('Postal') then
    return
end

local id, e= ...
local addName= BUTTON_LAG_MAIL
local Save={
    player= {--保存玩家数据
        --{name='Fuocco', text=nil},
    },
}

if e.Player.husandro and #Save.player==0 then
    Save.player= {
        'Zans-Nemesis',
        'Qisi-Nemesis',
        'Sandroxx-Nemesis',
        'Fuocco-Nemesis',
        'Sm-Nemesis',
        'Xiaod-Nemesis',
        'Dz-Nemesis',
        'Ws-Nemesis',
        'Sosi-Nemesis',
        'Maggoo-Nemesis',
        'Dhb-Nemesis',
        'Ms-Nemesis',--最大存20个
    }
end


local function set_Text_SendMailNameEditBox(_, name)--设置，发送名称，文
    if name then
        name= name:gsub('%-'..e.Player.realm, '')
        SendMailNameEditBox:SetText(name)
        SendMailNameEditBox:SetCursorPosition(0)
    end
end

local function get_Name_For_guid(guid)--取得名称-服务器
    local name, realm = select(6, GetPlayerInfoByGUID(guid))
    if name then
        realm= (not realm or realm=='') and e.Player.realm or realm
        return name..'-'..realm
    end
end

local function get_Name_Info(name, notName)--取得名称，信息
    local text= e.GetPlayerInfo({name=name, reName=not notName, reRealm=true})
    if text=='' then
        for guid, _ in pairs(WoWDate) do
            local name2, realm = select(6, GetPlayerInfoByGUID(guid))
            realm= (not realm or realm=='') and e.Player.realm or realm
            if name==(name2..'-'..realm) then
                return e.Icon.star2..e.GetPlayerInfo({guid=guid, reName=not notName, realm=true})
            end
        end
        if notName then
            return ''
        else
            name= name:gsub('%-'..e.Player.realm, '')
            return name
        end
    end
    return text
end

--#######
--设置菜单
--#######
local function Init_Menu(self, level, type)
    local info
    if type=='SELF' then
        local find
        for guid, _ in pairs(WoWDate) do
            if guid and guid~= e.Player.guid then
                info={
                    text= e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}),
                    icon= 'auctionhouse-icon-favorite',
                    notCheckable= true,
                    arg1= get_Name_For_guid(guid),
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        return

    elseif type=='FRIEND'  then
        local map=e.GetUnitMapName('player')
        local find
        for i=1 , C_FriendList.GetNumFriends() do
            local game=C_FriendList.GetFriendInfoByIndex(i)
            if game and game.guid then
                local text= e.GetPlayerInfo({unit=nil, guid=game.guid,  reName=true, reRealm=true, reLink=false})--角色信息
                text= (game.level and game.level~=MAX_PLAYER_LEVEL and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                if game.area and game.connected then
                    if game.area == map then--地区
                        text= text..e.Icon.map2
                    else
                        text= text..' |cnGREEN_FONT_COLOR:'..game.area..'|r'
                    end
                elseif not game.connected then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                info={
                    text=text,
                    icon= WoWDate[game.guid] and 'auctionhouse-icon-favorite',
                    notCheckable= true,
                    tooltipOnButton=true,
                    tooltipTitle=game.notes,
                    arg1= get_Name_For_guid(game.guid),
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        return

    elseif type=='WOW' then
        local find
        for i=1 ,BNGetNumFriends() do
            local wow=C_BattleNet.GetFriendAccountInfo(i);
            local wowInfo= wow and wow.gameAccountInfo
            if wowInfo and wowInfo.playerGuid and wowInfo.characterName and wowInfo.wowProjectID==1 then
                local name=get_Name_For_guid(wowInfo.playerGuid)

                local text= e.GetPlayerInfo({unit=nil, guid=wowInfo.playerGuid, name= wowInfo.characterName,  reName=true, reRealm=true, reLink=false})--角色信息
                if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
                    text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                end

                info={
                    text= text,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= wow and wow.note or '',
                    tooltipText= name,
                    arg1= name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find=true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
        return
    end

    info={
        text= e.Icon.wow2..(e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET),
        hasArrow= true,
        notCheckable=true,
        menuList= 'WOW',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= '|A:groupfinder-icon-friend:0:0|a'..(e.onlyChinese and '好友' or FRIEND),
        hasArrow= true,
        notCheckable=true,
        menuList= 'FRIEND',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
        hasArrow= true,
        notCheckable=true,
        menuList= 'SELF',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end



local function Init_Send_Player_button()
    SendMailFrame.SendPlayer= SendMailFrame.SendPlayer or {}
    for index, name in pairs(Save.player) do
        local label= SendMailFrame.SendPlayer[index]
        if not label then
            label= e.Cstr(SendMailFrame, {justifyH='RIGHT', mouse=true})
            if index==1 then
                label:SetPoint('TOPRIGHT', SendMailFrame.ClearPlayerLable, 'BOTTOMRIGHT', 0, -12)
            else
                label:SetPoint('TOPRIGHT', SendMailFrame.SendPlayer[index-1], 'BOTTOMRIGHT')
            end

            label:SetScript('OnMouseDown', function(self2)
                set_Text_SendMailNameEditBox(nil, self2.name)
            end)
            label:SetScript('OnLeave', function() e.tips:Hide() end)
            label:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(self2:GetText() or ' ',self2.name or (e.onlyChinese and '无' or NONE))
                e.tips:AddDoubleLine(id,addName)
                e.tips:Show()
            end)
            SendMailFrame.SendPlayer[index]= label
        else
            label:SetShown(true)
        end

        label.name= name
        label:SetText(get_Name_Info(name)..' '..(index<10 and ' ' or '')..'|cnGREEN_FONT_COLOR:('..index)
    end

    for index= #Save.player+1, #SendMailFrame.SendPlayer do
        SendMailFrame.SendPlayer[index]:SetShown(false)
        SendMailFrame.SendPlayer[index]:SetText('')
    end
end


local SendName
local function set_Send_Name()--SendName，设置，发送成功，名字
    if SendName then
        local find
        for _, name in pairs(Save.player) do
            if name==SendName then
                find=true
                break
            end
        end
        if not find then
            table.insert(Save.player, 1, SendName)
            if #Save.player>20 then
                table.remove(Save.player, #Save.player)
            end
        end
        Init_Send_Player_button()
        SendName=nil
    end
end

local function Init()--SendMailNameEditBox
    local btn= e.Cbtn(SendMailFrame,{size={22,22}, atlas='common-icon-rotateleft'})
    btn:SetPoint('TOP', 15, -33)
    btn:SetScript('OnClick', function(self2)
        if not self2.Menu then
            self2.Menu= CreateFrame("Frame", id..addName..'Menu', self2, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self2.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self2.Menu, self2, 15, 0)
    end)

    MailFrame:HookScript('OnShow', function(self2)
        if not SendMailFrame.ClearPlayerLable then
            SendMailFrame.ClearPlayerLable= e.Cstr(SendMailFrame, {justifyH='RIGHT', mouse=true})
            SendMailFrame.ClearPlayerLable:SetPoint('TOPRIGHT', SendMailFrame, 'TOPLEFT', 0, -40)
            SendMailFrame.ClearPlayerLable:SetText(not e.onlyChinese and SLASH_STOPWATCH_PARAM_STOP2 or "清除")
            SendMailFrame.ClearPlayerLable:SetScript('OnMouseDown', function(_, d)
                if IsAltKeyDown() and d=='LeftButton' then
                    Save.player={}
                    Init_Send_Player_button()
                end
            end)
            SendMailFrame.ClearPlayerLable:SetScript('OnLeave', function() e.tips:Hide() end)
            SendMailFrame.ClearPlayerLable:SetScript('OnEnter', function(self3)
                e.tips:SetOwner(self3, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine((not e.onlyChinese and CLEAR_ALL or "全部清除")..' |cnGREEN_FONT_COLOR:#'..#Save.player, '|cnGREEN_FONT_COLOR:Alt+'.. e.Icon.left)
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
        end
        Init_Send_Player_button()
        C_Timer.After(0.3, function()
            if GetInboxNumItems()==0 then--如果没有信，转到，发信
                MailFrameTab_OnClick(self2, 2)
            end
        end)
    end)

    SendMailNameEditBox.tipsText= e.Cstr(btn)
    SendMailNameEditBox.tipsText:SetPoint('BOTTOM', btn, 'TOP')
    SendMailNameEditBox:SetScript('OnTextChanged', function(self2)
        local name= self2:GetText()
        if name and not name:find('%-') then
            name= name..'-'..e.Player.realm
        end
        self2.tipsText:SetText(get_Name_Info(name, true))
    end)

    SendMailMailButton:HookScript('OnClick', function()--SendName，设置，发送成功，名字
        SendName= SendMailNameEditBox:GetText()
        if SendName and not SendName:find('%-') then
            SendName= SendName..'-'..e.Player.realm
        end
    end)
end


local panel= CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('MAIL_SEND_SUCCESS')
panel:RegisterEvent('MAIL_FAILED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            --添加控制面板
            local check=e.CPanel(e.Icon.bank2..(e.onlyChinese and '商人' or addName), not Save.disabled, true)
            check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end

            panel:UnregisterEvent('ADDON_LOADED')
            panel:RegisterEvent('PLAYER_LOGOUT')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='MAIL_SEND_SUCCESS' then
        set_Send_Name()--SendName，设置，发送成功，名字

    elseif event=='MAIL_FAILED' then
        SendName=nil
    end

end)