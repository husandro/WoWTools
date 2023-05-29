if IsAddOnLoaded('Postal') then
    return
end

local id, e= ...
local addName= BUTTON_LAG_MAIL
local Save={
    player= {--保存玩家数据
        --{name='Fuocco', text=nil},
    },
    --sacleClearPlayerButton=1.2,--清除历史数据，缩放
    --showOffLine=true,--显示离线成员
}

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
local function Init_Menu(self, level, menuList)
    local info
    if menuList=='SELF' then
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

    elseif menuList=='FRIEND'  then
        local find
        for i=1 , C_FriendList.GetNumFriends() do
            local game=C_FriendList.GetFriendInfoByIndex(i)
            if game and game.guid and (game.connected or Save.showOffLine) then

                local text= e.GetPlayerInfo({unit=nil, guid=game.guid,  reName=true, reRealm=true, reLink=false})--角色信息
                text= (game.level and game.level~=MAX_PLAYER_LEVEL and game.level>0) and text .. ' |cff00ff00'..game.level..'|r' or text--等级
                if game.area and game.connected then
                    text= text..' '..game.area
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

    elseif menuList=='WOW' then
        local find
        for i=1 ,BNGetNumFriends() do
            local wow=C_BattleNet.GetFriendAccountInfo(i);
            local wowInfo= wow and wow.gameAccountInfo
            if wowInfo
                and wowInfo.playerGuid
                --and wowInfo.characterName
                and wowInfo.wowProjectID==1
                and (wowInfo.isOnline or Save.showOffLine)
            then
                local name=get_Name_For_guid(wowInfo.playerGuid) or wowInfo.characterName

                local text= e.GetPlayerInfo({guid=wowInfo.playerGuid, reName=true, reRealm=true})--角色信息

                if wowInfo.characterLevel and wowInfo.characterLevel~=MAX_PLAYER_LEVEL and wowInfo.characterLevel>0 then--等级
                    text=text ..' |cff00ff00'..wowInfo.characterLevel..'|r'
                end
                if not wowInfo.isOnline then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                info={
                    text= text,
                    icon= WoWDate[wowInfo.playerGuid] and 'auctionhouse-icon-favorite',
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

    elseif menuList=='GUILD' then
        local find
        for index=1,  GetNumGuildMembers() do
            local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and guid~=e.Player.guid and (isOnline or Save.showOffLine) then

                local text= e.GetPlayerInfo({unit=nil, guid=guid,  reName=true, reRealm=true, reLink=false})--角色信息

                text= (lv and lv~=MAX_PLAYER_LEVEL and lv>0) and text .. ' |cff00ff00'..lv..'|r' or text--等级
                if zone and isOnline then
                    text= text..' '..zone
                elseif not isOnline then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                text= rankName and text..' '..rankName..(rankIndex and ' '..rankIndex or '') or text
                info={
                    text=text,
                    icon= WoWDate[guid] and 'auctionhouse-icon-favorite',
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=publicNote or '',
                    tooltipText=officerNote or '',
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

    elseif menuList=='GROUP' then
        local find
        local u=  IsInRaid() and 'raid' or 'party'--取消队友标记
        for i=1, GetNumGroupMembers() do
            local unit= u..i
            local isOnline= UnitIsConnected(unit)
            if (Save.showOffLine or isOnline) and not UnitIsUnit('player', unit) then
                local name= GetUnitName(unit, true)
                local text=  i..')'.. (i<10 and '  ' or ' ')..e.GetPlayerInfo({unit= unit, reName=true, reRealm=true})

                local lv= UnitLevel(unit)
                text= (lv and lv~=MAX_PLAYER_LEVEL and lv>0) and text .. ' |cff00ff00'..lv..'|r' or text--等级
                if not isOnline then
                    text= text..' '..(e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE)
                end

                info={
                    text= text,
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle= name,
                    arg1= name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                find= true
            end
        end
        if not find then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end

    elseif menuList and type(menuList)=='number' then--社区
        local num=0
        local members= C_Club.GetClubMembers(menuList) or {}
        for index, memberID in pairs(members) do
            local tab = C_Club.GetMemberInfo(menuList, memberID) or {}
            if tab.guid and tab.name and (tab.zone or Save.showOffLine) and not tab.isSelf then
                local faction= tab.faction==Enum.PvPFaction.Alliance and 'Alliance' or tab.faction==Enum.PvPFaction.Horde and 'Horde'
                local  text= e.GetPlayerInfo({guid=tab.guid,  reName=true, reRealm=true, factionName=faction})--角色信息

                text= (tab.level and tab.level~=MAX_PLAYER_LEVEL and tab.level>0) and text .. ' |cff00ff00'..tab.level..'|r' or text--等级
                if tab.zone then
                    text= text..' '..tab.zone
                end

                info={
                    text= index..(index<10 and ')  ' or ') ')..text,
                    icon= WoWDate[tab.guid] and 'auctionhouse-icon-favorite',
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=tab.memberNote or '',
                    tooltipText=tab.officerNote,
                    arg1= tab.name,
                    func= set_Text_SendMailNameEditBox,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                num=num+1
                if num>100 then
                    break
                end
            end
        end
        if num>0 then
            e.LibDD:UIDropDownMenu_AddButton({text=e.onlyChinese and '无' or NONE, notCheckable=true, isTitle=true}, level)
        end
    end

    if menuList then
        return
    end

    info={
        text= '|A:auctionhouse-icon-favorite:0:0|a'..(e.onlyChinese and '我' or COMBATLOG_FILTER_STRING_ME),
        hasArrow= true,
        notCheckable=true,
        menuList= 'SELF',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
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
        text= '|A:communities-guildbanner-background:0:0|a'..(e.onlyChinese and '公会' or GUILD),
        disabled= not IsInGuild(),
        hasArrow= true,
        notCheckable=true,
        menuList= 'GUILD',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= '|A:UI-HUD-UnitFrame-Player-Group-GuideIcon-2x:0:0|a'..(e.onlyChinese and '队员' or PLAYERS_IN_GROUP),
        disabled= GetNumGroupMembers()<2,
        hasArrow= true,
        notCheckable=true,
        menuList= 'GROUP',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
 

    local clubs= C_Club.GetSubscribedClubs() or {}--社区
    if #clubs>0 then
        e.LibDD:UIDropDownMenu_AddSeparator(level)
    end
    for _, tab in pairs(clubs) do
        info={
            text= (tab.avatarId and '|T'..tab.avatarId..':0|t' or '')..(tab.shortName or tab.name),
            hasArrow= true,
            notCheckable=true,
            menuList= tab.clubId,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text= e.onlyChinese and '离线' or FRIENDS_LIST_OFFLINE,
        icon= 'mechagon-projects',
        checked= Save.showOffLine,
        tooltipOnButton= true,
        tooltipTitle= not e.onlyChinese and COMMUNITIES_MEMBER_LIST_SHOW_OFFLINE or "显示离线成员",
        tooltipText= e.GetEnabeleDisable(Save.showOffLine),
        func= function()
            Save.showOffLine= not Save.showOffLine and true or nil
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    info={
        text= id..' '..addName,
        icon= 'UI-HUD-Minimap-Mail-Mouseover',
        notCheckable= true,
        isTitle=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
end



local function Init_Send_Player_button()
    local self= SendMailFrame
    self.SendPlayer= self.SendPlayer or {}
    for index, name in pairs(Save.player) do
        local label= self.SendPlayer[index]
        if not label then
            label= e.Cstr(self.ClearPlayerButton, {justifyH='RIGHT', mouse=true})
            if index==1 then
                label:SetPoint('TOPRIGHT', self.ClearPlayerButton, 'BOTTOMRIGHT', 0, -6)
            else
                label:SetPoint('TOPRIGHT', self.SendPlayer[index-1], 'BOTTOMRIGHT')
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
            self.SendPlayer[index]= label
        else
            label:SetShown(true)
        end

        label.name= name
        label:SetText(get_Name_Info(name)..' '..(index<10 and ' ' or '')..'|cnGREEN_FONT_COLOR:('..index)
    end

    for index= #Save.player+1, #self.SendPlayer do
        self.SendPlayer[index]:SetShown(false)
        self.SendPlayer[index]:SetText('')
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

local function set_GetTargetNameButton_Texture(self)
    if UnitExists('target') and UnitIsPlayer('target') and not UnitIsUnit('player', 'target') then
        local name, atlas= GetUnitName('target', true), e.GetUnitRaceInfo({unit= 'target', reAtlas=true})
        if name and atlas then
            self.name=name
            self:SetNormalAtlas(atlas)
            self:SetShown(true)
            return
        end
    end
    self.name=nil
    self:SetShown(false)
end

local function Init_Settings_Button(self)
    if not self or self.ClearPlayerButton then
        return
    end

    --下拉，菜单
    local btn= e.Cbtn(self,{size={22,22}, atlas='common-icon-rotateleft'})
    btn:SetPoint('TOP', 15, -33)
    btn:SetScript('OnClick', function(self2)
        if not self2.Menu then
            self2.Menu= CreateFrame("Frame", id..addName..'Menu', self2, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self2.Menu, Init_Menu, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self2.Menu, self2, 15, 0)
    end)

    --提示，内容
    SendMailNameEditBox.tipsText= e.Cstr(btn)
    SendMailNameEditBox.tipsText:SetPoint('BOTTOM', btn, 'TOP')
    SendMailNameEditBox:SetScript('OnTextChanged', function(self2)
        local name= self2:GetText()
        if name and not name:find('%-') then
            name= name..'-'..e.Player.realm
        end
        self2.tipsText:SetText(get_Name_Info(name, true))
    end)

    --目标，名称
    self.GetTargetNameButton= e.Cbtn(self, {size={20,20}})
    self.GetTargetNameButton:SetPoint('LEFT', btn, 'RIGHT',2,2)
    self.GetTargetNameButton:SetScript('OnEvent', set_GetTargetNameButton_Texture)
    self.GetTargetNameButton:SetScript('OnClick', function(self2)
        if self2.name then
            set_Text_SendMailNameEditBox(nil, self2.name)
        end
    end)
    self.GetTargetNameButton:SetScript('OnLeave', function() e.tips:Hide() end)
    self.GetTargetNameButton:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(GetUnitName('target', true), e.GetPlayerInfo({unit='target', reName=true, reRealm=true}))
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    set_GetTargetNameButton_Texture(self.GetTargetNameButton)

    --历史记录
    self.ClearPlayerButton= e.Cbtn(self, {size={18,18}, atlas='bags-button-autosort-up'})
    self.ClearPlayerButton:SetPoint('TOPRIGHT', self, 'TOPLEFT', 0, -30)
    self.ClearPlayerButton:SetText(not e.onlyChinese and SLASH_STOPWATCH_PARAM_STOP2 or "清除")
    self.ClearPlayerButton:SetScript('OnClick', function(_, d)
        if IsAltKeyDown() and d=='LeftButton' then
            Save.player={}
            Init_Send_Player_button()
        end
    end)
    self.ClearPlayerButton:SetScript('OnMouseWheel', function(self2, d)
        local num= Save.sacleClearPlayerButton or 1
        if d==1 then
            num= num- 0.05
        elseif d==-1 then
            num= num+ 0.05
        end
        num= num<0.5 and 0.5 or num>2 and 2 or num
        print(id, addName,e.onlyChinese and '缩放' or UI_SCALE, '|cnGREEN_FONT_COLOR:'..(Save.sacleClearPlayerButton or 1) )
        Save.sacleClearPlayerButton= num
        self2:SetScale(num)
    end)
    self.ClearPlayerButton:SetScript('OnLeave', function() e.tips:Hide() end)
    self.ClearPlayerButton:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((not e.onlyChinese and CLEAR_ALL or "全部清除")..' |cnGREEN_FONT_COLOR:#'..#Save.player..'|r/20', '|cnGREEN_FONT_COLOR:Alt+'.. e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.sacleClearPlayerButton or 1), e.Icon.mid)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    if Save.sacleClearPlayerButton then
        self.ClearPlayerButton:SetScale(Save.sacleClearPlayerButton)
    end
end

local function Init()--SendMailNameEditBox
    MailFrame:HookScript('OnShow', function(self2)
        Init_Settings_Button(SendMailFrame)--目标，名称
        Init_Send_Player_button()
        C_Timer.After(0.3, function()
            if GetInboxNumItems()==0 then--如果没有信，转到，发信
                MailFrameTab_OnClick(self2, 2)
            end
        end)

        SendMailFrame.GetTargetNameButton:RegisterEvent('PLAYER_TARGET_CHANGED')--目标，名称
        set_GetTargetNameButton_Texture(SendMailFrame.GetTargetNameButton)--目标，名称

    end)

    MailFrame:HookScript('OnHide', function()
        SendMailFrame.GetTargetNameButton:UnregisterAllEvents()--目标，名称
        SendName=nil--设置，发送成功，名字
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
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            if e.Player.husandro and #Save.player==0 then
                local region= GetCurrentRegion()--1US(includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
                if region~=3 then
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
            end

            --添加控制面板
            local check=e.CPanel('|A:UI-HUD-Minimap-Mail-Mouseover:0:0|a'..(e.onlyChinese and '邮件' or addName), not Save.disabled, true)
            check:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()

                panel:RegisterEvent('MAIL_SEND_SUCCESS')
                panel:RegisterEvent('MAIL_FAILED')

                panel:UnregisterEvent('ADDON_LOADED')
            end
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