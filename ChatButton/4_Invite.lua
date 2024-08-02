local id, e = ...
local addName
local Save={
    InvNoFriend={},
    --LFGListAceInvite=true,--接受,LFD, 邀请
    FriendAceInvite=true,--接受, 好友, 邀请
    InvNoFriendNum=0,--拒绝, 次数
    restingTips=true,--休息区提示
    ChannelText=e.Player.cn and '1' or 'inv',--频道, 邀请, 事件,内容
    Summon= true,--接受, 召唤

    setFrameFun= e.Player.husandro,--跟随，密语
    --已删除 frameList={['Target']=true, ['Party1']=true, ['Party2']=true, ['Party3']=true, ['Party4']=true},

    setFucus= e.Player.husandro,--焦点
    overSetFocus= e.Player.husandro,--移过是，
    focusKey= 'Shift',
}
local InvPlateGuid={}
local InviteButton
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
        print(id, addName, '|cnRED_FONT_COLOR:', e.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
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
            local tab= C_NamePlate.GetNamePlates(issecure()) or {}
            for _, v in pairs(tab) do
                local u = v.namePlateUnitToken or v.UnitFrame and v.UnitFrame.unit
                if u then
                    local name= GetUnitName(u,true)
                    local guid= UnitGUID(u)
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
    print(id, addName, e.onlyChinese and '目标' or TARGET, e.GetPlayerInfo({guid=guid, name=name, reLink=true}))
end

local function InvPlateGuidFunc()--从已邀请过列表里, 再次邀请 
    if not getLeader() then--取得权限
        print(id, addName, e.onlyChinese and '你没有权利这样做' or ERR_GUILD_PERMISSIONS)
        return
    end
    local n=0
    local co=GetNumGroupMembers()
    for guid, name in pairs(InvPlateGuid) do
        local num=n+co
        if num==40 then
            return
        elseif not IsInRaid() and num==5 and not Save.PartyToRaid then
            print(id, addName, e.onlyChinese and '请求：转化为团队' or  PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
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

    local function setPrint(sec, text)
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        print(id, 'ChatButton', addName, text,
            '|cnGREEN_FONT_COLOR:'..sec.. ' |r'..(e.onlyChinese and '秒' or SECONDS),
            (isTank and e.Icon.TANK or '')..(isHealer and e.Icon.HEALER or '')..(isDamage and e.Icon.DAMAGER or ''),
            questSessionActive and (e.onlyChinese and '场景战役' or SCENARIOS) or '',--场景战役
            isNativeRealm and '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '%s其它服务器' or INVITATION_XREALM,
            e.PlayerLink(nil, inviterGUID))--转服务器
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
        setPrint(sec, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '接受' or ACCEPT)..'|r'..(e.onlyChinese and '好友' or FRIENDS))
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







































--Shift+点击设置焦点
--跟随，密语
--鼠标按键 1是左键、2是右键、3是中键
local ClearFoucsFrame
local function Init_Shift_Click_Focus()
    if not Save.setFucus then
        return
    end

    local key= strlower(Save.focusKey)

    ClearFoucsFrame= e.Cbtn(nil, {type=true, name='WoWToolsClearFocusButton'})--清除，焦点
    --ClearFoucsFrame:SetAttribute('type1','macro')
    --ClearFoucsFrame:SetAttribute('macrotext','/clearfocus')

    ClearFoucsFrame:SetAttribute('type1','focus')
    ClearFoucsFrame:SetAttribute('unit', nil)

    e.SetButtonKey(ClearFoucsFrame, true, strupper(key)..'-BUTTON2', nil)--设置, 快捷键



    ClearFoucsFrame.key= key
    ClearFoucsFrame.frames={}

    function ClearFoucsFrame:set_event(frame)
        if UnitAffectingCombat('player') then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
        end
        self.frames[frame]=true
    end

    --跟随，密语
    function ClearFoucsFrame:set_say_follow(frame)
        if not Save.setFrameFun or not frame or not frame:CanChangeAttribute() then--or not (frame.unit and frame:GetAttribute('unit')) then
            return
        end
        frame:EnableMouseWheel(true)
        frame:HookScript('OnMouseWheel', function(f, d)
            local unit= f.unit or f:GetAttribute('unit')
            if UnitExists(unit)
                and UnitIsPlayer(unit)
                and not UnitIsUnit('player', unit)
                and UnitIsFriend('player', unit)
            then
                if d==1 then
                    e.Say(nil, UnitName(unit), nil, nil)--密语
                elseif d==-1 then
                    FollowUnit(unit)--跟随
                end
            end
        end)
    end

    --设置, 属性
    function ClearFoucsFrame:set_key(frame)
        if not frame then
            return
        end
        if frame:CanChangeAttribute() then
            if frame==FocusFrame then
                --frame:SetAttribute(key..'-type1','macro')
                --frame:SetAttribute(key..'-macrotext1','/clearfocus')
                frame:SetAttribute(key..'-type1', 'focus')
                frame:SetAttribute('unit', nil)
            else
                frame:SetAttribute(self.key..'-type1', 'focus')--设置, 属性
            end
        else
            self:set_event(frame)
        end
    end

    ClearFoucsFrame:SetScript('OnEvent', function(self)
        for frame, _ in pairs(self.frames) do
            self:set_key(frame)
        end
        self.frames={}
        self:UnregisterAllEvents()
    end)



    local tab = {
        PlayerFrame,
        PetFrame,
        TargetFrame,
        TargetFrameToT,
        FocusFrameToT,
        FocusFrame,
    }
    for i=1, MAX_BOSS_FRAMES do--boss
        local frame= _G['Boss'..i..'TargetFrame']
        if frame then
            table.insert(tab, frame)
            table.insert(tab, frame.BossButton)--UnitFrame.lua
            table.insert(tab, frame.TotButton)
        end
    end

    for i=1, MAX_PARTY_MEMBERS do--队伍
        local member= 'MemberFrame'..i
        if PartyFrame and PartyFrame[member] then
            table.insert(tab, PartyFrame[member])
            table.insert(tab, PartyFrame[member].potFrame)--UnitFrame.lua
        end
        table.insert(tab, _G['CompactPartyFrameMember'..i])

        local frame= _G['CompactPartyFrameMember'..i]
        if frame then
            table.insert(tab, frame)
        end
    end



    for _, frame in pairs(tab) do--设置焦点
        if frame then
            ClearFoucsFrame:set_key(frame)
            ClearFoucsFrame:set_say_follow(frame)
        end
    end



    --设置单位焦点
    local btn= e.Cbtn(nil, {type=true, name='WoWToolsOverFocusButton'})
    btn:SetAttribute("type1", "focus")
    btn:SetAttribute('unit', 'mouseover')
    e.SetButtonKey(btn, true, strupper(key)..'-BUTTON1', nil)--设置, 快捷键

    hooksecurefunc("CreateFrame", function(_, name, _, template)--为新的框架，加属性
        local frame= name and _G[name]
        if template
            and (
                template:find("SecureUnitButtonTemplate")
            )
            and frame
            and not frame:GetAttribute(ClearFoucsFrame.key..'-type1')
        then
            ClearFoucsFrame:set_key(frame)
            ClearFoucsFrame:set_say_follow(frame)
        end
    end)



    hooksecurefunc('CompactRaidGroup_InitializeForGroup', function(self, groupIndex)
        for i=1, MEMBERS_PER_RAID_GROUP do
            local frame= _G[self:GetName().."Member"..i]
            ClearFoucsFrame:set_key(frame)
            ClearFoucsFrame:set_say_follow(frame)
        end
    end)

end













local function set_SummonTips()--召唤，提示
    if Save.Summon and not InviteButton.summonTips then
        InviteButton.summonTips= InviteButton:CreateTexture(nil,'OVERLAY')
        InviteButton.summonTips:SetPoint('BOTTOMLEFT',2, 2)
        InviteButton.summonTips:SetSize(15,16)
        InviteButton.summonTips:SetAtlas('Raid-Icon-SummonPending')
    end
    if InviteButton.summonTips then
        InviteButton.summonTips:SetShown(Save.Summon)
    end
end






























--#######
--初始菜单
--#######
local function InitList(self, level, menuList)
    local info
    if menuList=='InvUnit' then--邀请单位    
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7,
            notCheckable=true,
            isTitle=true,
        }, level)



        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '邀请目标' or INVITE..TARGET,
            checked=Save.InvTar,
            disabled=IsInInstance() and true or nil,
            keepShownOnClick=true,
            func=function()
                Save.InvTar= not Save.InvTar and true or nil
                set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
                set_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
                --setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '仅限: 队长 |cnRED_FONT_COLOR:不在副本|r' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE, '|cff00ff00'..LEADER..'|r'..NO..'|cnRED_FONT_COLOR:'..INSTANCE..'|r'),
        }, level)

        e.LibDD:UIDropDownMenu_AddButton({--设置,频道,事件
            text= (e.onlyChinese and '频道' or CHANNEL)..(Save.ChannelText and '|cnGREEN_FONT_COLOR: '..Save.ChannelText..'|r' or ''),--内容,频道, 邀请
            checked=Save.Channel,
            colorCode=not Save.ChannelText and '|cff606060',
            tooltipOnButton=true,
            tooltipTitle=Save.ChannelText or (e.onlyChinese and '无' or NONE),
            tooltipText= e.onlyChinese and '说, 喊, 密语' or (SAY..', '..YELL..', '..WHISPER),
            hasArrow=true,
            menuList='ChannelText',
            keepShownOnClick=true,
            func= function()
                Save.Channel = not Save.Channel and true or nil
                set_Chanell_Event()--设置,频道,事件
                --setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end
        }, level)

        e.LibDD:UIDropDownMenu_AddButton({--已邀请列表
            text= e.onlyChinese and '已邀请' or LFG_LIST_APP_INVITED,--三级列表，已邀请列表
            notCheckable=true,
            menuList='InvUnitAll',
            hasArrow=true,
            keepShownOnClick=true,
            func=InvPlateGuidFunc,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '邀请全部' or CALENDAR_INVITE_ALL,
        }, level)

    elseif menuList=='InvUnitAll' then--三级列表，已邀请列表
        local n, all=0, 0
        for guid, name in pairs(InvPlateGuid) do
            if not e.GroupGuid[guid] then
                e.LibDD:UIDropDownMenu_AddButton({
                    text=e.GetPlayerInfo({unit=nil, guid=guid, name=name,  reName=true, reRealm=true}),
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '邀请' or INVITE,
                    tooltipText=name,
                    notCheckable=true,
                    keepShownOnClick=true,
                    func=function()
                        C_PartyInfo.InviteUnit(name)
                    end,
                }, level)
                n=n+1
            end
            all=all+1
        end
        if n==0 then
            e.LibDD:UIDropDownMenu_AddButton({
                text= e.onlyChinese and '无' or NONE,
                notCheckable=true,
                isTitle=true,
            }, level)
        else
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            e.LibDD:UIDropDownMenu_AddButton({
                text= '|cff00ff00'..(e.onlyChinese and '邀请全部' or CALENDAR_INVITE_ALL)..'|r',
                notCheckable=true,
                keepShownOnClick=true,
                func= InvPlateGuidFunc,
            }, level)

            e.LibDD:UIDropDownMenu_AddButton({
                text='|cffff0000'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r',
                notCheckable=true,
                keepShownOnClick=true,
                func=function()
                    InvPlateGuid={}
                end,
            }, level)
        end

    elseif menuList=='ACEINVITE' then--自动接受邀请
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '好友' or FRIENDS,
            checked=Save.FriendAceInvite,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '战网, 好友, 公会' or (COMMUNITY_COMMAND_BATTLENET..', '..FRIENDS..', '..GUILD),
            keepShownOnClick=true,
            func=function()
                Save.FriendAceInvite= not Save.FriendAceInvite and true or nil
                --setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end,
        }, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '召唤' or SUMMON,
            icon='Raid-Icon-SummonPending',
            checked= Save.Summon,
            tooltipOnButton=true,
            tooltipTitle= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '取消' or CANCEL)..'|r',
            tooltipText= e.onlyChinese and '战斗中|n离开|nalt' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT..'|n'..AFK..'|nalt',
            keepShownOnClick=true,
            func= function()
                Save.Summon= not Save.Summon and true or nil
                set_SummonTips()--召唤，提示
            end
        }, level)

    elseif menuList=='NoInv' then
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '拒绝邀请' or LFG_LIST_APP_INVITE_DECLINED,--三级列表，拒绝邀请列表
            notCheckable=true,
            menuList='NoInvList',
            keepShownOnClick=true,
            hasArrow=true,
        }, level)

        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '|cnRED_FONT_COLOR:休息|r区' or ('|cnRED_FONT_COLOR:'..CALENDAR_STATUS_OUT..'|r'..ZONE),--休息区拒绝组队  
            checked=Save.NoInvInResting,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '拒绝' or DECLINE,
            tooltipText= e.onlyChinese and '好友 |cnRED_FONT_COLOR:否|r' or ('|cnRED_FONT_COLOR:'..NO..'|r'..TUTORIAL_TITLE22),
            keepShownOnClick=true,
            func=function()
                Save.NoInvInResting= not Save.NoInvInResting and true or nil
            end,
        }, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '休息区信息' or CALENDAR_STATUS_OUT..ZONE..INFO,
            checked=Save.restingTips,
            keepShownOnClick=true,
            func=function()
                Save.restingTips= not Save.restingTips and true or nil
                set_PLAYER_UPDATE_RESTING()--设置, 休息区提示
            end,
        }, level)

    elseif menuList=='NoInvList' then--三级列表，拒绝邀请列表
        local all=0
        for guid, nu in pairs(Save.InvNoFriend) do
            local text=e.GetPlayerInfo({unit=nil, guid=guid, name=nil,  reName=true, reRealm=true})
            if text then
                all=all+1
                e.LibDD:UIDropDownMenu_AddButton({
                    text=all..') '..text..' |cff00ff00'..nu..'|r',
                    notCheckable=true,
                    keepShownOnClick=true,
                    func=function()
                        Save.InvNoFriend[guid]=nil
                        print(id, addName, '|cff00ff00'..(e.onlyChinese and '移除' or REMOVE)..'|r: '..text)
                    end,
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '移除' or REMOVE,
                    tooltipText= format(e.onlyChinese and '%d次' or ITEM_SPELL_CHARGES, nu)..'|n|n'..(select(7,GetPlayerInfoByGUID(guid)) or ''),
                }, level)
            end
        end
        if all==0 then
            e.LibDD:UIDropDownMenu_AddButton({
                text= e.onlyChinese and '无' or NONE,
                notCheckable=true,
                isTitle=true,
            }, level)
        else
            e.LibDD:UIDropDownMenu_AddSeparator(level)
            e.LibDD:UIDropDownMenu_AddButton({
                text=e.onlyChinese and '全部清除' or CLEAR_ALL,
                colorCode= '|cff00ff00',
                notCheckable=true,
                keepShownOnClick=true,
                func=function()
                    Save.InvNoFriend={}
                    print(id, addName, '|cff00ff00'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r', e.onlyChinese and '完成' or DONE)
                end,
            }, level)
        end

    elseif menuList=='ChannelText' then--三级列表,修改,频道,关键词
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT,--在这里输入关键字。
            notCheckable=true,
            keepShownOnClick=true,
            func= function()

                StaticPopupDialogs[id..addName..'ChatButton_CHANNEL']= {--设置,内容,频道, 邀请,事件
                    text=id..' '..addName..' '..(e.onlyChinese and '频道' or CHANNEL)..'|n|n'..(e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT),
                    whileDead=true, hideOnEscape=true, exclusive=true,
                    hasEditBox=true,
                    button1= e.onlyChinese and '修改' or EDIT,
                    button2= e.onlyChinese and '取消' or CANCEL,
                    OnShow = function(frame)
                        frame.editBox:SetText(Save.ChannelText or e.Player.cn and '1' or 'inv')
                    end,
                    OnHide= function(frame)
                        frame.editBox:ClearFocus()
                    end,
                    OnAccept = function(frame)
                        Save.ChannelText = string.upper(frame.editBox:GetText())
                        print(id, addName, e.onlyChinese and '频道' or CHANNEL,'|cnGREEN_FONT_COLOR:'..Save.ChannelText..'|r')
                    end,
                    EditBoxOnTextChanged=function(frame)
                        local text= frame:GetText()
                        text=text:gsub(' ','')
                        frame:GetParent().button1:SetEnabled(text~='')
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'CHANNEL')
            end
        }, level)


    elseif menuList=='FOCUSKEY' then
        for _, key in pairs({'Shift', 'Ctrl', 'Alt'}) do
            e.LibDD:UIDropDownMenu_AddButton({
                text= key..' + '.. e.Icon.left,
                checked= Save.focusKey== key,
                disabled= UnitAffectingCombat('player') or Save.focusKey== key,
                arg1= key,
                func= function(_, arg1)
                    Save.focusKey= arg1
                    print(id, addName, '|cnGREEN_FONT_COLOR:'..arg1..'|r'..e.Icon.left, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            }, level)
        end
        e.LibDD:UIDropDownMenu_AddButton({
            text= format('%s+%s%s=%s',
                Save.focusKey,
                e.Icon.right,
                e.onlyChinese and '空' or EMPTY,
                e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2
            ),
            colorCode= '|cffff0000',
            notCheckable=true,
            isTitle=true,
        }, level)

        --[[e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= e.onlyChinese and '设置单位焦点' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SET_FOCUS, COVENANT_MISSIONS_UNITS),
            checked= Save.overSetFocus,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
            func=function()
                Save.overSetFocus= not Save.overSetFocus and true or nil
            end
        }, level)]]

        --跟随，密语
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text= format('|A:bags-greenarrow:0:0|a%s', e.onlyChinese and '鼠标滚轮向上滚动: 密语' or (KEY_MOUSEWHEELUP..": "..SLASH_TEXTTOSPEECH_WHISPER))..
            format('|n|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a%s', e.onlyChinese and'鼠标滚轮向下滚动: 跟随' or (KEY_MOUSEWHEELDOWN..': '..FOLLOW)),
            checked=Save.setFrameFun,
            keepShownOnClick=true,
            func=function()
                Save.setFrameFun= not Save.setFrameFun and true or nil
                print(id, addName, e.GetEnabeleDisable(Save.setFrameFun), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        }, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text=e.onlyChinese and'友情提示: 可能会出现错误' or 'note: errors may occur',
            notCheckable=true,
            isTitle=true,
        }, level)
    end

    if menuList then
        return
    end





    e.LibDD:UIDropDownMenu_AddButton({
        text=e.Icon.left..(e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7),
        notCheckable=true,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '邀请周围玩家' or (INVITE..e.Icon.left..SPELL_RANGE_AREA:gsub(SPELL_TARGET_CENTER_CASTER,'')),
        hasArrow=true,
        menuList='InvUnit',
        colorCode=not getLeader() and '|cff606060',
        keepShownOnClick=true,
        func=InvUnitFunc,--邀请，周围玩家
    }, level)

    e.LibDD:UIDropDownMenu_AddButton({
        text= format('|A:%s:0:0|a', e.Icon.select)..(e.onlyChinese and '接受邀请' or CALENDAR_ACCEPT_INVITATION),
        notCheckable=true,
        menuList='ACEINVITE',
        keepShownOnClick=true,
        hasArrow=true,
    }, level)

    e.LibDD:UIDropDownMenu_AddButton({
        text= format('|A:%s:0:0|a%s', e.Icon.disabled, e.onlyChinese and '拒绝邀请' or GUILD_INVITE_DECLINE),
        notCheckable=true,
        menuList='NoInv',
        hasArrow=true,
        tooltipOnButton=true,
        keepShownOnClick=true,
        tooltipTitle= e.onlyChinese and ('拒绝 '..Save.InvNoFriendNum..' 次') or (DECLINE..' '..format(ITEM_SPELL_CHARGES, Save.InvNoFriendNum))
    }, level)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    e.LibDD:UIDropDownMenu_AddButton({
        text= e.Icon.left..(e.onlyChinese and '焦点' or HUD_EDIT_MODE_FOCUS_FRAME_LABEL)..(Save.setFucus and '|cnGREEN_FONT_COLOR:'..Save.focusKey..'|r' or ''),
        checked= Save.setFucus,
        disabled= UnitAffectingCombat('player'),
        hasArrow=true,
        menuList='FOCUSKEY',
        --keepShownOnClick=true,
        func= function()
            Save.setFucus= not Save.setFucus and true or nil
            print(id, addName, e.GetEnabeleDisable(Save.setFucus), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }, level)
end






















--接受, 召唤
local function Init_CONFIRM_SUMMON()

    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate",function(self)
        if IsModifierKeyDown() or self.isCancelledAuto or not Save.Summon then
            if not self.isCancelledAuto then
                e.Ccool(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
                if self.SummonTimer and not self.SummonTimer:IsCancelled() then self.SummonTimer:Cancel() end--取消，计时
            end
            self.isCancelledAuto=true
            return
        end

        if not UnitAffectingCombat("player") and PlayerCanTeleport() then--启用，召唤
            if not self.enabledAutoSummon then
                self.enabledAutoSummon= true
                if self.SummonTimer and not self.SummonTimer:IsCancelled() then
                    self.SummonTimer:Cancel()
                end
                e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
                self.SummonTimer= C_Timer.NewTimer(3, function()
                    if not UnitAffectingCombat("player") and PlayerCanTeleport() then
                        C_SummonInfo.ConfirmSummon()
                        StaticPopup_Hide("CONFIRM_SUMMON")
                        if IsInGroup() and not IsInRaid() then
                            local text
                            if (e.Player.region==1 or e.Player.region==3) then
                                text = 'thx, sum me'
                            elseif e.Player.region==5 then
                                text= '谢谢你的，召唤'
                            else
                                text= VOICEMACRO_16_Dw_1 ..', '..SUMMON
                            end
                            e.Chat('{rt1}'..text..'{rt1}', nil, nil)
                        end
                    end
                end)
            end

        elseif self.enabledAutoSummon then--取消，召唤
            e.Ccool(self, nil, C_SummonInfo.GetSummonConfirmTimeLeft(), nil, true, true, nil)--冷却条
            if self.SummonTimer and not self.SummonTimer:IsCancelled() then self.SummonTimer:Cancel() end--取消，计时
            self.enabledAutoSummon=nil
        end
    end)

    StaticPopupDialogs["CONFIRM_SUMMON"].OnHide= function(self)
        if self.SummonTimer then self.SummonTimer:Cancel() end
        --if self.cooldown then self.cooldown:Clear() end
        self.enabledAutoSummon=nil
        self.isCancelled=nil
    end

    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnShow",function()--StaticPopup.lua
        e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
        local name= C_SummonInfo.GetSummonConfirmSummoner()
        local info= e.GroupGuid[name]
        if info and info.guid then
            local playerInfo=e.GetPlayerInfo({guid=info.guid, reLink=true})
            name= playerInfo~='' and playerInfo or name
        end
        print(id, addName, e.onlyChinese and '召唤' or SUMMON, name, '|A:poi-islands-table:0:0|a|cnGREEN_FONT_COLOR:', C_SummonInfo.GetSummonConfirmAreaName())
    end)
end
































local function Init_Menu(_, root)
    local sub, sub2, sub3, tab, col

    sub=root:CreateButton((getLeader() and '' or '|cff606060')..(e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7), InvUnitFunc)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '周围玩家' or 'Players around')
    end)

    sub2=sub:CreateCheckbox((IsInInstance() and '|cff606060' or '')..(e.onlyChinese and '邀请目标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, TARGET)), function()
        return Save.InvTar
    end, function()
        if IsInInstance() then
            return
        end
        Save.InvTar= not Save.InvTar and true or nil
        set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
        set_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '仅限队长' or format(LFG_LIST_CROSS_FACTION, LEADER))
        tooltip:AddLine(e.onlyChinese and '不在副本中' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NO, INSTANCE))
    end)

    sub2=sub:CreateCheckbox((e.onlyChinese and '频道' or CHANNEL)..(Save.ChannelText and '|cnGREEN_FONT_COLOR: '..Save.ChannelText..'|r' or ''), function()
        return Save.Channel
    end, function()
        Save.Channel = not Save.Channel and true or nil
        set_Chanell_Event()--设置,频道,事件
    end)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(Save.ChannelText or (e.onlyChinese and '无' or NONE))
        tooltip:AddLine(e.onlyChinese and '说, 喊, 密语' or (SAY..', '..YELL..', '..WHISPER))
    end)

    sub2:CreateButton(e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT, function()
        StaticPopupDialogs[id..'ChatButton_CHANNEL']= {--设置,内容,频道, 邀请,事件
            text=id..' '..addName..' '..(e.onlyChinese and '频道' or CHANNEL)..'|n|n'..(e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT),
            whileDead=true, hideOnEscape=true, exclusive=true,
            hasEditBox=true,
            button1= e.onlyChinese and '修改' or EDIT,
            button2= e.onlyChinese and '取消' or CANCEL,
            OnShow = function(frame)
                frame.editBox:SetText(Save.ChannelText or e.Player.cn and '1' or 'inv')
            end,
            OnHide= function(frame)
                frame.editBox:ClearFocus()
            end,
            OnAccept = function(frame)
                Save.ChannelText = string.upper(frame.editBox:GetText())
                print(id, addName, e.onlyChinese and '频道' or CHANNEL,'|cnGREEN_FONT_COLOR:'..Save.ChannelText..'|r')
            end,
            EditBoxOnTextChanged=function(frame)
                local text= frame:GetText()
                text=text:gsub(' ','')
                frame:GetParent().button1:SetEnabled(text~='')
            end,
            EditBoxOnEscapePressed = function(s)
                s:GetParent():Hide()
            end,
        }
        StaticPopup_Show(id..'ChatButton_CHANNEL')
    end)

    sub2=sub:CreateButton(e.onlyChinese and '已邀请' or LFG_LIST_APP_INVITED, InvPlateGuidFunc)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '再次邀请' or CALENDAR_INVITE_ALL)
    end)

    local n, all=0, 0
    for guid, name in pairs(InvPlateGuid) do
        if not e.GroupGuid[guid] then
            sub3= sub2:CreateButton(e.GetPlayerInfo({unit=nil, guid=guid, name=name,  reName=true, reRealm=true}), function(data)
                C_PartyInfo.InviteUnit(name)
            end, name)
            sub3:SetTooltip(function(tooltip)
                tooltip:AddLine(e.onlyChinese and '再次邀请' or INVITE)
            end)
            n=n+1
        end
        all=all+1
    end

    sub2:CreateDivider()
    sub2:CreateButton(e.onlyChinese and '再次邀请' or INVITE, InvPlateGuidFunc)
    sub2:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function()
        InvPlateGuid={}
    end)

    if all>30 then
        local line= math.ceil(all/30)
        sub2:SetGridMode(MenuConstants.VerticalGridDirection, 3)
    end














end
























--####
--初始
--####
local function Init()
    InviteButton.texture:SetAtlas('communities-icon-addgroupplus')

    set_SummonTips()--召唤，提示

    InviteButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            InvUnitFunc()--邀请，周围玩家
        else
            MenuUtil.CreateContextMenu(self, Init_Menu)
            e.tips:Hide()
        end
    end)

    InviteButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:state_leave()
    end)
    InviteButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(addName, e.Icon.left)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or MAINMENU, e.Icon.right)
        e.tips:Show()
        self:state_enter()
    end)


    set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    set_event_PLAYER_UPDATE_RESTING()--设置, 休息区提示事件
    set_Chanell_Event()--设置,内容,频道, 邀请,事件
    Init_Shift_Click_Focus()--Shift+点击设置焦点

    hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate", Init_CONFIRM_SUMMON)


    StaticPopupDialogs["PARTY_INVITE"].button3= '|cff00ff00'..(e.onlyChinese and '总是' or ALWAYS)..'|r'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'--添加总是拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if notInviterGUID then
            if Save.InvNoFriend[notInviterGUID] then
                Save.InvNoFriend[notInviterGUID] =nil
                print(id, 'ChatButton', addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'..(e.onlyChinese and '邀请' or INVITE))
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
            else
                Save.InvNoFriend[notInviterGUID] =Save.InvNoFriend[notInviterGUID] and Save.InvNoFriend[notInviterGUID]+1 or 1
                Save.InvNoFriendNum=Save.InvNoFriendNum+1
                DeclineGroup()
                StaticPopup_Hide("PARTY_INVITE")
                print(id, 'ChatButton', addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'..(e.onlyChinese and '邀请' or INVITE))
            end
        end
        notInviterGUID=nil
    end
end

































--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if WoWToolsSave[INVITE] then--处理，上版本数据
                Save= WoWToolsSave[INVITE]
                Save.frameList= nil --Save.frameList or {['Target']=true, ['Party1']=true, ['Party2']=true, ['Party3']=true, ['Party4']=true}--框架, 向上:密语, 向下:跟随
                Save.focusKey= Save.focusKey or 'Shift'--焦点
            else
                Save= WoWToolsSave['ChatButton_Invite'] or Save
            end

            InviteButton= WoWToolsChatButtonMixin:CreateButton('Invite')

            if InviteButton then
                addName= '|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '邀请' or INVITE)
                Init()

                self:RegisterEvent('GROUP_LEFT')
                self:RegisterEvent('GROUP_ROSTER_UPDATE')
                self:RegisterEvent('PARTY_INVITE_REQUEST')
                self:RegisterEvent('PLAYER_UPDATE_RESTING')----休息区提示
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                self:RegisterEvent('LFG_LIST_APPLICATION_STATUS_UPDATED')
            end
            self:UnregisterEvent('ADDON_LOADED')
        end


    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButton_Invite']=Save
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

                    print(id, addName, e.onlyChinese and '频道' or CHANNEL, e.PlayerLink(name, guid))
                end
            end
        end
    end
end)