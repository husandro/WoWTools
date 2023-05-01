local id, e = ...
local addName= INVITE
local Save={
    InvNoFriend={},
    --LFGListAceInvite=true,--接受,LFD, 邀请
    FriendAceInvite=true,--接受, 好友, 邀请
    InvNoFriendNum=0,--拒绝, 次数
    restingTips=true,--休息区提示
    ChannelText=e.Player.cn and '1' or 'inv',--频道, 邀请, 事件,内容
    Summon= true,--接受, 召唤

    setFrameFun= e.Player.husandro,--日标框, 向上:密语, 向下:跟随
    frameList={['Target']=true, ['Party1']=true, ['Party2']=true, ['Party3']=true, ['Party4']=true},

    setFucus= e.Player.husandro,--焦点
    focusKey= 'Shift',
}
local InvPlateGuid={}
local button
local panel= CreateFrame("Frame")

local function getLeader()--取得权限
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end

local function isInLFG()--是否有FB, 排除中
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then
            return true
        end
    end
end


--#######
--邀请玩家
--#######
local InvPlateTimer
local InvUnitFunc=function()--邀请，周围玩家
    if not getLeader() then--取得权限
        print(id,addName, '|cnRED_FONT_COLOR:', e.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
        return
    end

    local p=C_CVar.GetCVarBool('nameplateShowFriends')
    if not p then
        if UnitAffectingCombat('player') then
            print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT))
            return
        else
            C_CVar.SetCVar('nameplateShowFriends', '1')
        end
    end

    if InvPlateTimer then InvPlateTimer:Cancel() end
    InvPlateTimer=C_Timer.NewTimer(0.3, function()
        local n=1
        local co=GetNumGroupMembers()
        local raid=IsInRaid()
        if (not raid and co==5)then
            return

        elseif co==40 then
            return
        else
            --toRaidOrParty(co)--自动, 转团
            local tab= C_NamePlate.GetNamePlates() or {}
            for _, v in pairs(tab) do
                local u = v.namePlateUnitToken or v.UnitFrame and v.UnitFrame.unit
                local name=GetUnitName(u,true)
                local guid=UnitGUID(u)
                if name and name~=UNKNOWNOBJECT and guid and not UnitInAnyGroup(u) and not UnitIsAFK(u) and UnitIsConnected(u) and UnitIsPlayer(u) and UnitIsFriend(u, 'player') and not UnitIsUnit('player',u) then
                    if not InvPlateGuid[guid] then
                        C_PartyInfo.InviteUnit(name)
                        InvPlateGuid[guid]=name
                        print(id, '|cnGREEN_FONT_COLOR:'..n..'|r)', e.onlyChinese and '邀请' or INVITE ,e.PlayerLink(name, guid))
                        if not raid and n +co>=5  then
                            print(id, addName, format(PETITION_TITLE, '|cff00ff00'..(e.onlyChinese and '转团' or CONVERT_TO_RAID)..'|r'))
                            break
                        end
                        n=n+1
                    end
                end
            end
        end
        if not p and not UnitAffectingCombat('player') then
            C_CVar.SetCVar('nameplateShowFriends', '0')
        end
        if n==1 then
            print(id, addName, e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
        end
    end)
end

local function set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    if Save.InvTar and not IsInInstance() then
        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
    else
        panel:UnregisterEvent('PLAYER_TARGET_CHANGED')
    end
end
local function set_PLAYER_TARGET_CHANGED()--设置, 邀请目标
    if not Save.InvTar
    --or InvPlateGuid[guid]--已邀请
    or not UnitExists('target')
    or not getLeader()--取得权限
    or UnitInAnyGroup('target')
    or UnitIsAFK('target')
    or not UnitIsConnected('target')
    or not UnitIsPlayer('target')
    or not UnitIsFriend('target', 'player')
    or UnitIsUnit('player','target')
    then
        return
    end

    local raid=IsInRaid()
    local co=GetNumGroupMembers()
    if (raid and co==40) or (not raid and co==5 and not Save.PartyToRaid) then
        return
    end

    local name=GetUnitName('target', true)
    if not name then
        return
    end

    --toRaidOrParty(co)--自动, 转团

    C_PartyInfo.InviteUnit(name)

    local guid=UnitGUID('target')
    if guid then
        InvPlateGuid[guid]=name--保存到已邀请列表
    end
    print(id, addName, e.onlyChinese and '目标' or TARGET, e.GetPlayerInfo({unit=nil, guid=guid, name=name,  reName=false, reRealm=false, reLink=true}))
end

local function InvPlateGuidFunc()--从已邀请过列表里, 再次邀请 
    if not getLeader() then--取得权限
        print(id, addName, ERR_GUILD_PERMISSIONS)
        return
    end
    local n=0
    local co=GetNumGroupMembers()
    for guid, name in pairs(InvPlateGuid) do
        local num=n+co
        if num==40 then
            return
        elseif not IsInRaid() and num==5 and not Save.PartyToRaid then
            print(id, addName, PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
            return
        end

        --toRaidOrParty(num)--自动, 转团,转小队
        if name then
            C_PartyInfo.InviteUnit(name)
            n=n+1

            print(n..')'..e.PlayerLink(name, guid))
        end
    end
end

--###########
--邀请, 对话框
--###########
local notInviterGUID--邀请,对话框, guid
local function set_PARTY_INVITE_REQUEST(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    if not inviterGUID or not name then
        return
    end
    if not StaticPopup1 or not StaticPopup1:IsShown() then
        return
    end
    --local tex=StaticPopup1Text  
    --local playerInfo= e.GetPlayerInfo(nil, inviterGUID, true)

    local function setPrint(sec, text)
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        print(id, addName, text,
            '|cnGREEN_FONT_COLOR:'..sec.. ' |r'..(e.onlyChinese and '秒' or SECONDS),
            (isTank and e.Icon.TANK or '')..(isHealer and e.Icon.HEALER or '')..(isDamage and e.Icon.DAMAGER or ''),
            questSessionActive and (e.onlyChinese and '场景战役' or SCENARIOS) or '',--场景战役
            isNativeRealm and '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '%s其它服务器' or INVITATION_XREALM, e.PlayerLink(nil, inviterGUID)) or e.PlayerLink(nil, inviterGUID)--转服务器
        )
        e.Ccool(StaticPopup1, nil, sec, nil, true, true, nil)--冷却条    
    end

    local friend=e.GetFriend(nil, inviterGUID, nil)
    if friend then--好友
        if not Save.FriendAceInvite then
            e.Ccool(StaticPopup1, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条  
            return
        end
        local sec=isInLFG() and 10 or 3--是否有FB, 排除中
        setPrint(sec, '|cnGREEN_FONT_COLOR:'..ACCEPT..'|r'..FRIENDS)
        if StaticPopup1.InvTimer then StaticPopup1.InvTimer:Cancel() end
        StaticPopup1.InvTimer = C_Timer.NewTimer(sec, function()
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
        end)

    elseif Save.InvNoFriend[inviterGUID] then--拒绝
        setPrint(3, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'..Save.InvNoFriend[inviterGUID]..'/'..Save.InvNoFriendNum)
        StaticPopup1.button3:SetText('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'..(e.onlyChinese and '接受' or ACCEPT))
        notInviterGUID=inviterGUID
        if StaticPopup1.InvTimer then StaticPopup1.InvTimer:Cancel() end
        StaticPopup1.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save.InvNoFriendNum=Save.InvNoFriendNum+1
            Save.InvNoFriend[inviterGUID]=Save.InvNoFriend[inviterGUID]+1
        end)

    elseif IsResting() and Save.NoInvInResting and not questSessionActive then--休息区不组队
        setPrint(3, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '' or DECLINE)..'|r'..(e.onlyChinese and '休息区' or (CALENDAR_STATUS_OUT..ZONE)))

        StaticPopup1.button3:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '拒绝' or DECLINE))
        notInviterGUID=inviterGUID
        if StaticPopup1.InvTimer then StaticPopup1.InvTimer:Cancel() end
        StaticPopup1.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save.InvNoFriendNum=Save.InvNoFriendNum+1
        end)

    else--添加 拒绝 陌生人
        StaticPopup1.button3:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '拒绝' or DECLINE))
        notInviterGUID=inviterGUID

        e.Ccool(StaticPopup1, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
    end
end

--#########
--休息区提示
--#########
local function set_event_PLAYER_UPDATE_RESTING()--设置, 休息区提示事件
    if Save.restingTips then
        panel:RegisterEvent('PLAYER_UPDATE_RESTING')
    else
        panel:UnregisterEvent('PLAYER_UPDATE_RESTING')
    end
end
local function set_PLAYER_UPDATE_RESTING()--设置, 休息区提示
    if IsResting() then
        print(id, addName, e.onlyChinese and '进入' or  ENTER_LFG, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '休息' or CALENDAR_STATUS_OUT)..'|r',  e.onlyChinese and '区域' or ZONE)
    else
        print(id, addName, e.onlyChinese and '离开' or LEAVE, '|cnRED_FONT_COLOR:'..( e.onlyChinese and '休息' or CALENDAR_STATUS_OUT)..'|r', e.onlyChinese and '区域' or ZONE)
    end
end

--#######################
--设置,内容,频道, 邀请,事件
--#######################
local function set_Chanell_Event()--设置,内容,频道, 邀请,事件
    if Save.Channel and Save.ChannelText and UnitIsGroupLeader('player') and not IsInInstance() then
        panel:RegisterEvent('CHAT_MSG_SAY')
        panel:RegisterEvent('CHAT_MSG_WHISPER')
        panel:RegisterEvent('CHAT_MSG_YELL')
    else
        panel:UnregisterEvent('CHAT_MSG_SAY')
        panel:UnregisterEvent('CHAT_MSG_WHISPER')
        panel:UnregisterEvent('CHAT_MSG_YELL')
    end
end

--##########################
--日标框, 向上:密语, 向下:跟随
--##########################
local function set_Frame_Fun()--日标框, 向上:密语, 向下:跟随
    local tab = {
        [TargetFrame]='Target',
        [PartyFrame.MemberFrame1]='Party1',
        [PartyFrame.MemberFrame2]='Party2',
        [PartyFrame.MemberFrame3]='Party3',
        [PartyFrame.MemberFrame4]='Party4',
    }
    for frame, unit in pairs(tab) do
        if Save.setFrameFun and Save.frameList[unit] then--设置, 属性
            frame:SetScript('OnMouseWheel', function(self, d)
                if UnitIsUnit('player', 'target') or not UnitIsPlayer('target') or not UnitIsFriend('player', 'target') then
                    return
                end
                if d==1 then
                    e.Say(nil, UnitName('target'), nil, nil)--密语
                elseif d==-1 then
                    FollowUnit('target')--跟随
                end
            end)

        elseif frame:GetScript('OnMouseWheel') then--取消, 属性
            frame:SetScript('OnMouseWheel', nil)
        end
    end
end

--#################
--Shift+点击设置焦点
--#################
local clearFocusFrame
local function set_Shift_Click_focurs()
    local tab = {
        PlayerFrame,
        PetFrame,
        PartyFrame.MemberFrame1,
        PartyFrame.MemberFrame2,
        PartyFrame.MemberFrame3,
        PartyFrame.MemberFrame4,
        TargetFrame,
        TargetFrameToT,
        Boss1TargetFrame,
        Boss2TargetFrame,
        Boss3TargetFrame,
        Boss4TargetFrame,
        Boss5TargetFrame,
        FocusFrameToT,
    }
    local keyTab={
        'shift-type1',
        'ctrl-type1',
        'alt-type1',
    }
    local key= strlower(Save.focusKey)

    for _, frame in pairs(tab) do--设置焦点
        if frame and frame:CanChangeAttribute() then
            if Save.setFucus then
                frame:SetAttribute(key..'-type1', 'focus')--设置, 属性
            else
                for _, text in pairs(keyTab) do--取得, 所有属性
                    if frame:GetAttribute(text) then
                        frame:SetAttribute(key..'-type1', nil)
                    end
                end
            end
        end
    end

    if Save.setFucus then
        FocusFrame:SetAttribute(key..'-type1','macro')
        FocusFrame:SetAttribute(key..'-macrotext1','/clearfocus')
    else
        if FocusFrame:GetAttribute(key..'-type1') then
            FocusFrame:SetAttribute(key..'-type1', nil)
        end
        if FocusFrame:GetAttribute(key..'-macrotext1') then
            FocusFrame:SetAttribute(key..'-macrotext1', nil)
        end
    end

    if Save.setFucus then
        clearFocusFrame= clearFocusFrame or e.Cbtn(nil, {type=true, name= id..addName..'clearFocusFrame'})
        clearFocusFrame:SetAttribute('type1','macro')
        clearFocusFrame:SetAttribute('macrotext1','/clearfocus')
        e.SetButtonKey(clearFocusFrame, true, strupper(key)..'-BUTTON1', nil)--设置, 快捷键
    elseif clearFocusFrame then
        if clearFocusFrame:GetAttribute(key..'-type1') then
            FocusFrame:SetAttribute(key..'-type1', nil)
        end
        if clearFocusFrame:GetAttribute(key..'-macrotext1') then
            clearFocusFrame:SetAttribute(key..'-macrotext1', nil)
        end
        e.SetButtonKey(clearFocusFrame, false, nil, nil)--清除, 快捷键
    end
end

--#######
--初始菜单
--#######
local function InitList(self, level, type)
    local info
    if type=='InvUnit' then--邀请单位    
        info={
            text= e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7,
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)



        info={
            text= e.onlyChinese and '邀请目标' or INVITE..TARGET,
            checked=Save.InvTar,
            disabled=IsInInstance() and true or nil,

            func=function()
                Save.InvTar= not Save.InvTar and true or nil
                set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
                set_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
                --setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '仅限: 队长 |cnRED_FONT_COLOR:不在副本|r' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE, '|cff00ff00'..LEADER..'|r'..NO..'|cnRED_FONT_COLOR:'..INSTANCE..'|r'),
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={--设置,频道,事件
            text= (e.onlyChinese and '频道' or CHANNEL)..(Save.ChannelText and '|cnGREEN_FONT_COLOR: '..Save.ChannelText..'|r' or ''),--内容,频道, 邀请
            checked=Save.Channel,
            colorCode=not Save.ChannelText and '|cff606060',
            tooltipOnButton=true,
            tooltipTitle=Save.ChannelText or (e.onlyChinese and '无' or NONE),
            tooltipText= e.onlyChinese and '说, 喊, 密语' or (SAY..', '..YELL..', '..WHISPER),
            hasArrow=true,
            menuList='ChannelText',
            func= function()
                Save.Channel = not Save.Channel and true or nil
                set_Chanell_Event()--设置,频道,事件
                --setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={--已邀请列表
            text= e.onlyChinese and '已邀请' or LFG_LIST_APP_INVITED,--三级列表，已邀请列表
            notCheckable=true,
            menuList='InvUnitAll',
            hasArrow=true,
            func=InvPlateGuidFunc,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '邀请全部' or CALENDAR_INVITE_ALL,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='InvUnitAll' then--三级列表，已邀请列表
        local n, all=0, 0
        for guid, name in pairs(InvPlateGuid) do
            if not e.GroupGuid[guid] then
                info={
                    text=e.GetPlayerInfo({unit=nil, guid=guid, name=name,  reName=true, reRealm=true}),
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '邀请' or INVITE,
                    tooltipText=name,
                    notCheckable=true,
                    func=function()
                        C_PartyInfo.InviteUnit(name)
                    end,

                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
                n=n+1
            end
            all=all+1
        end
        if n==0 then
            info={
                text= e.onlyChinese and '无' or NONE,
                notCheckable=true,
                isTitle=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        else
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text= '|cff00ff00'..(e.onlyChinese and '邀请全部' or CALENDAR_INVITE_ALL)..'|r',
                notCheckable=true,
                func= InvPlateGuidFunc,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            info={
                text='|cffff0000'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r',
                notCheckable=true,
                func=function()
                    InvPlateGuid={}
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        return

    elseif type=='ACEINVITE' then--自动接受邀请
        info={
            text= e.onlyChinese and '好友' or FRIENDS,
            checked=Save.FriendAceInvite,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '战网, 好友, 公会' or (COMMUNITY_COMMAND_BATTLENET..', '..FRIENDS..', '..GUILD),
            func=function()
                Save.FriendAceInvite= not Save.FriendAceInvite and true or nil
                --setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '召唤' or SUMMON,
            icon='Raid-Icon-SummonPending',
            checked= Save.Summon,
            tooltipOnButton=true,
            tooltipTitle= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL)..'|r',
            tooltipText= e.onlyChinese and '战斗中\n离开\nalt' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..'\n'..AFK..'\nalt',
            func= function()
                Save.Summon= not Save.Summon and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='NoInv' then
        info={
            text= e.onlyChinese and '拒绝邀请' or LFG_LIST_APP_INVITE_DECLINED,--三级列表，拒绝邀请列表
            notCheckable=true,
            menuList='NoInvList',
            hasArrow=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '|cnRED_FONT_COLOR:休息|r区' or ('|cnRED_FONT_COLOR:'..CALENDAR_STATUS_OUT..'|r'..ZONE),--休息区拒绝组队  
            checked=Save.NoInvInResting,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '拒绝' or DECLINE,
            tooltipText= e.onlyChinese and '好友 |cnRED_FONT_COLOR:否|r' or ('|cnRED_FONT_COLOR:'..NO..'|r'..TUTORIAL_TITLE22),
            func=function()
                Save.NoInvInResting= not Save.NoInvInResting and true or nil
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '休息区信息' or CALENDAR_STATUS_OUT..ZONE..INFO,
            checked=Save.restingTips,
            func=function()
                Save.restingTips= not Save.restingTips and true or nil
                set_PLAYER_UPDATE_RESTING()--设置, 休息区提示
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='NoInvList' then--三级列表，拒绝邀请列表
        local all=0
        for guid, nu in pairs(Save.InvNoFriend) do
            local text=e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true})
            if text then
                all=all+1
                info={
                    text=all..') '..text..' |cff00ff00'..nu..'|r',
                    notCheckable=true,
                    func=function()
                        Save.InvNoFriend[guid]=nil
                        print(id, addName, '|cff00ff00'..REMOVE..'|r: '..text)
                    end,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '移除' or REMOVE,
                    tooltipText= format(e.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, nu)..'\n\n'..(select(7,GetPlayerInfoByGUID(guid)) or ''),
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        if all==0 then
            info={
                text= e.onlyChinese and '无' or NONE,
                notCheckable=true,
                isTitle=true,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        else
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text=e.onlyChinese and '全部清除' or CLEAR_ALL,
                colorCode= '|cff00ff00',
                notCheckable=true,
                func=function()
                    Save.InvNoFriend={}
                    print(id, addName, '|cff00ff00'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r', e.onlyChinese and '完成' or DONE)
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        return

    elseif type=='ChannelText' then--三级列表,修改,频道,关键词
        info={
            text= e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT,--在这里输入关键字。
            notCheckable=true,
            func= function()
                StaticPopupDialogs[id..addName..'CHANNEL']={--设置,内容,频道, 邀请,事件
                    text=id..' '..addName..' '..(e.onlyChinese and '频道' or CHANNEL)..'\n\n'..(e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT),
                    whileDead=1,
                    hideOnEscape=1,
                    exclusive=1,
                    timeout = 60,
                    hasEditBox=1,
                    button1= e.onlyChinese and '修改' or SLASH_CHAT_MODERATE2:gsub('/',''),
                    button2=CANCEL,
                    OnShow = function(self2, data)
                        self2.editBox:SetText(Save.ChannelText or e.Player.cn and '1' or 'inv')
                        --self.button3:SetEnabled(Save.Mounts[FLOOR][data.spellID] and true or false)
                    end,
                    OnAccept = function(self2, data)
                        Save.ChannelText = string.upper(self.editBox:GetText())
                        print(id, addName, e.onlyChinese and '频道' or CHANNEL,'|cnGREEN_FONT_COLOR:'..Save.ChannelText..'|r')
                    end,
                    EditBoxOnTextChanged=function(self2, data)
                        local text= self2:GetText()
                        text=text:gsub(' ','')
                        self2:GetParent().button1:SetEnabled(text~='')
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'CHANNEL')
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='FRAMEFUNC' then--日标框, 向上:密语, 向下:跟随
        info= {
            text= e.onlyChinese and '鼠标滚轮向上滚动: 密语' or (KEY_MOUSEWHEELUP..": "..SLASH_TEXTTOSPEECH_WHISPER),
            icon= 'bags-greenarrow',
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info= {
            text= e.onlyChinese and'鼠标滚轮向下滚动: 跟随' or (KEY_MOUSEWHEELDOWN..': '..FOLLOW),
            icon= 'UI-HUD-MicroMenu-StreamDLRed-Up',
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local tab = {
            'Target',
            'Party1',
            'Party2',
            'Party3',
            'Party4',
        }
        for _, unit in pairs(tab) do
            info={
                text= unit,
                disabled= UnitAffectingCombat('player'),
                checked= Save.frameList[unit],
                arg1=unit,
                func= function(self2, arg1)
                    Save.frameList[arg1]= not Save.frameList[arg1] and true or nil
                    set_Frame_Fun()
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=  e.onlyChinese and '仅限系统(玩家)\n' or (LFG_LIST_CROSS_FACTION:format(SYSTEM..' ('..PLAYER..')')),
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info= {
            text= e.onlyChinese and '友情提示: 可能会出现错误' or ('note: '..ENABLE_ERROR_SPEECH),
            colorCode= '|cffff0000',
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='FOCUSKEY' then
        info= {
            text= (Save.focusKey or 'Shift')..' + '..e.Icon.left..' + '..(e.onlyChinese and '空' or EMPTY)..' = '..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        local tab={
            'Shift',
            'Ctrl',
            'Alt',
        }
        for _, key in pairs(tab) do
            info={
                text= key..' + '.. e.Icon.left,
                checked= Save.focusKey== key,
                disabled= UnitAffectingCombat('player') or Save.focusKey== key,
                arg1= key,
                func= function(_, arg1)
                    Save.focusKey= arg1
                    set_Shift_Click_focurs()--Shift+点击设置焦点
                    print(id,addName, '|cnGREEN_FONT_COLOR:'..Save.focusKey..' + |r'..e.Icon.left, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text= (e.onlyChinese and '仅限系统' or LFG_LIST_CROSS_FACTION:format(SYSTEM)),
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        info= {
            text= e.onlyChinese and'友情提示: 可能会出现错误' or ('note: '..ENABLE_ERROR_SPEECH),
            colorCode= '|cffff0000',
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    info={
        text=e.Icon.left..(e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7),
        notCheckable=true,
        menuList='InvUnit',
        func=InvUnitFunc,--邀请，周围玩家
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '邀请周围玩家' or (INVITE..e.Icon.left..SPELL_RANGE_AREA:gsub(SPELL_TARGET_CENTER_CASTER,'')),
        hasArrow=true,
        colorCode=not getLeader() and '|cff606060',
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    info = {
        text= e.Icon.select2..(e.onlyChinese and '接受邀请' or CALENDAR_ACCEPT_INVITATION),
        notCheckable=true,
        menuList='ACEINVITE',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    info = {
        text= e.Icon.O2..(e.onlyChinese and '拒绝邀请' or GUILD_INVITE_DECLINE),
        notCheckable=true,
        menuList='NoInv',
        hasArrow=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and ('拒绝 '..Save.InvNoFriendNum..' 次') or (DECLINE..' '..format(ITEM_SPELL_CHARGES, Save.InvNoFriendNum))
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)
    e.LibDD:UIDropDownMenu_AddSeparator(level)

    local num= 0
    for _,_ in pairs(Save.frameList) do
        num=num+1
    end
    info={
        text= e.Icon.mid..(e.onlyChinese and '密语/跟随' or (SLASH_TEXTTOSPEECH_WHISPER..'/'..FOLLOW)).. '|cnGREEN_FONT_COLOR:'..num..'|r',
        disabled= UnitAffectingCombat('player'),
        colorCode= num==0 and '|cff606060',
        checked= Save.setFrameFun,
        hasArrow=true,
        menuList='FRAMEFUNC',
        func=function()
            Save.setFrameFun= not Save.setFrameFun and true or nil
            set_Frame_Fun()--日标框, 向上:密语, 向下:跟随
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)


    info={
        text= e.Icon.left..(e.onlyChinese and '焦点' or HUD_EDIT_MODE_FOCUS_FRAME_LABEL)..'|cnGREEN_FONT_COLOR:'..Save.focusKey..'|r',
        checked= Save.setFucus,
        disabled= UnitAffectingCombat('player'),
        hasArrow=true,
        menuList='FOCUSKEY',
        func= function()
            Save.setFucus= not Save.setFucus and true or nil
            set_Shift_Click_focurs()--Shift+点击设置焦点
            if Save.setFucus then
                print(id,addName, '|cnGREEN_FONT_COLOR:\nPlayerFrame','PetFrame','Party1','Party2','Party3','Party4','TargetFrame','TargetFrameToT','Boss1TargetFrame','Boss2TargetFrame','Boss3TargetFrame','Boss4TargetFrame','Boss5TargetFrame', 'FocusFrameToT')
            end
           --print(id,addName, e.GetEnabeleDisable(Save.setFucus), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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

    button.texture:SetAtlas('communities-icon-addgroupplus')
    --setTexture()--设置图标颜色, 是否有权限

    

    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            InvUnitFunc()--邀请，周围玩家
        else
            if not self.Menu then
                self.Menu= CreateFrame("Frame", id..addName..'Menu', self, "UIDropDownMenuTemplate")--菜单列表
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, InitList, "MENU")
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    set_event_PLAYER_UPDATE_RESTING()--设置, 休息区提示事件
    set_Chanell_Event()--设置,内容,频道, 邀请,事件


    StaticPopupDialogs["PARTY_INVITE"].button3= '|cff00ff00'..(e.onlyChinese and '总是' or ALWAYS)..'|r'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'--添加总是拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if notInviterGUID then
            if Save.InvNoFriend[notInviterGUID] then
                Save.InvNoFriend[notInviterGUID] =nil
                print(id, addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'..(e.onlyChinese and '邀请' or INVITE))
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
            else
                Save.InvNoFriend[notInviterGUID] =Save.InvNoFriend[notInviterGUID] and Save.InvNoFriend[notInviterGUID]+1 or 1
                Save.InvNoFriendNum=Save.InvNoFriendNum+1
                DeclineGroup()
                StaticPopup_Hide("PARTY_INVITE")
                print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'..(e.onlyChinese and '邀请' or INVITE))
            end
        end
    end


    --#########
    --接受, 召唤
    --#########
    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"],"OnShow",function(self)--StaticPopup.lua
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        if Save.Summon and not UnitAffectingCombat("player") and PlayerCanTeleport() and not UnitIsAFK('player') and not IsModifierKeyDown() then
            print(id, addName, e.onlyChinese and '召唤' or SUMMON, C_SummonInfo.GetSummonConfirmSummoner(), C_SummonInfo.GetSummonConfirmAreaName())
            e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
            if button.SummonTimer then button.SummonTimer:Cancel() end
            button.SummonTimer= C_Timer.NewTimer(3, function()
                if not UnitAffectingCombat("player") and PlayerCanTeleport() and not UnitIsAFK('player') and not IsModifierKeyDown() then
                    C_SummonInfo.ConfirmSummon()
                    StaticPopup_Hide("CONFIRM_SUMMON")
                end
            end)
        else
            e.Ccool(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
        end
    end)
    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"],"OnCancel",function(self)
        if button.SummonTimer then button.SummonTimer:Cancel() end
    end)


    if UnitAffectingCombat('player') and (Save.setFrameFun or Save.setFucus) then
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
        if Save.setFrameFun then
            set_Frame_Fun()--日标框, 向上:密语, 向下:跟随
        end
        if Save.setFucus then
            set_Shift_Click_focurs()--Shift+点击设置焦点
        end
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('LFG_LIST_APPLICATION_STATUS_UPDATED')

panel:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save
                Save.frameList= Save.frameList or {['Target']=true, ['Party1']=true, ['Party2']=true, ['Party3']=true, ['Party4']=true}--框架, 向上:密语, 向下:跟随
                Save.focusKey= Save.focusKey or 'Shift'--焦点

                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
                Init()

                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent('GROUP_LEFT')
                panel:RegisterEvent('GROUP_ROSTER_UPDATE')
                panel:RegisterEvent('PARTY_INVITE_REQUEST')
                panel:RegisterEvent('PLAYER_UPDATE_RESTING')----休息区提示
                panel:RegisterEvent('PLAYER_ENTERING_WORLD')

                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        --setTexture()--设置图标颜色, 是否有权限
        set_Chanell_Event()--设置,内容,频道, 邀请,事件

    elseif event=='PLAYER_ENTERING_WORLD' then
        if Save.InvTar then
            set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
        end

    elseif event=='PLAYER_TARGET_CHANGED' then
        set_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件

    elseif event=='PARTY_INVITE_REQUEST' then
        set_PARTY_INVITE_REQUEST(arg1, ...)--邀请, 对话框

    elseif event=='PLAYER_UPDATE_RESTING' then
        set_PLAYER_UPDATE_RESTING()--设置, 休息区提示

    elseif event=='PLAYER_ENTERING_WORLD' then
        InvPlateGuid={}
        set_Chanell_Event()--设置,内容,频道, 邀请,事件

    elseif event=='CHAT_MSG_SAY' or event=='CHAT_MSG_YELL' or  event=='CHAT_MSG_WHISPER' then
        local text= arg1 and string.upper(arg1)
        if Save.Channel and text and Save.ChannelText and text:find(Save.ChannelText) then
            local co= GetNumGroupMembers()
            --toRaidOrParty(co)--自动, 转团
            if co<5 or (IsInRaid() and co<40) then
                local guid= select(11, ...)
                local name= ...
                if guid and name and name~=e.Player.ame_server then
                    C_PartyInfo.InviteUnit(name)

                    InvPlateGuid[guid]=name--保存到已邀请列表

                    print(id, addName, CHANNEL, e.PlayerLink(name, guid))
                end
            end
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if Save.setFrameFun then
            set_Frame_Fun()--日标框, 向上:密语, 向下:跟随
        end
        if Save.setFucus then
            set_Shift_Click_focurs()--Shift+点击设置焦点
        end
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
    end
end)