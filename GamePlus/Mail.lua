if IsAddOnLoaded('Postal') then
    return
end

local id, e= ...
local addName= BUTTON_LAG_MAIL
local Save={
    player= {},--保存玩家数据
}


--#######
--设置菜单
--#######
local function Init_Menu(self, level, type)
    local info
    if type=='SELF' then
        local find
        for guid, _ in pairs(WoWDate) do
            local name, realm = select(6, GetPlayerInfoByGUID(guid))
            local name_realm= name
            if realm and realm~='' and realm~=e.Player.realm then
                name_realm= name_realm..'-'..realm
            end
            info={
                text= e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true, reLink=false}),
                icon= 'auctionhouse-icon-favorite',
                notCheckable= true,
                arg1= name_realm,
                func=function(self2, arg1)
                    SendMailNameEditBox:SetText(arg1)
                    SendMailNameEditBox:SetCursorPosition(0)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            find=true
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
            if game and game.name and game.guid then
                local text=e.GetPlayerInfo({unit=nil, guid=game.guid, name=game.name,  reName=true, reRealm=true, reLink=false})--角色信息
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
                    arg1= game.name,
                    func=function(self2, arg1)
                        SendMailNameEditBox:SetText(arg1)
                        SendMailNameEditBox:SetCursorPosition(0)
                    end
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
                local name_realm= wowInfo.characterName
                if wowInfo.realmName and wowInfo.realmName~= e.Player.realm then
                    name_realm= name_realm..'-'..wowInfo.realmName
                end

                local text= e.GetPlayerInfo({unit=nil, guid=wowInfo.playerGuid, name= wowInfo.characterName,  reName=true, reRealm=true, reLink=false})--角色信息
                if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
                    text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                end
                info={
                    text= text,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= wow and wow.note or '',
                    tooltipText= name_realm,
                    arg1= name_realm,
                    func=function(self2, arg1)
                        if arg1 then
                            SendMailNameEditBox:SetText(arg1)
                            SendMailNameEditBox:SetCursorPosition(0)
                        end
                    end
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
        text= e.onlyChinese and '战网' or COMMUNITY_COMMAND_BATTLENET,
        hasArrow= true,
        notCheckable=true,
        menuList= 'WOW',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '好友' or FRIEND,
        hasArrow= true,
        notCheckable=true,
        menuList= 'FRIEND',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info={
        text= e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME,
        hasArrow= true,
        notCheckable=true,
        menuList= 'SELF',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
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
        C_Timer.After(0.3, function()
            if GetInboxNumItems()==0 then--如果没有信，转到，发信
                MailFrameTab_OnClick(self2, 2)
            end
        end)
    end)

    SendMailNameEditBox.tipsText= e.Cstr(btn)
    SendMailNameEditBox.tipsText:SetPoint('BOTTOM', btn, 'TOP')
    SendMailNameEditBox:SetScript('OnTextChanged', function(self2)
        self2.tipsText:SetText(e.GetPlayerInfo({name=self2:GetText()}))
    end)


end


local panel= CreateFrame("Frame")
panel:RegisterEvent('ADDON_LOADED')
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
    end

end)