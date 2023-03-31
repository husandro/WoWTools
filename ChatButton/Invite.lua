local id, e = ...
local addName= INVITE
local Save={InvNoFriend={},
            --LFGListAceInvite=true,--接受,LFD, 邀请
            FriendAceInvite=true,--接受, 好友, 邀请
            InvNoFriendNum=0,--拒绝, 次数
            restingTips=true,--休息区提示
            LFGPlus= true,--预创建队伍增强
            ChannelText=e.Player.cn and '1' or 'inv',--频道, 邀请, 事件,内容
            Summon= true,--接受, 召唤
}
local InvPlateGuid={}
local button
local panel= CreateFrame("Frame")

local function getLeader()--取得权限
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end
--[[
local function toRaidOrParty(number)--自动, 转团
    if Save.PartyToRaid then
        number= number or GetNumGroupMembers()
        local raid= IsInRaid()
        if number>5 and not raid then
            C_PartyInfo.ConvertToRaid()
            print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转团' or CONVERT_TO_RAID)..'|r')
        elseif number<5 and raid then
            C_PartyInfo.ConvertToParty()
            print(id, addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '转小队' or CONVERT_TO_RAID)..'|r')
        end
    end
end
--]]
local function isInLFG()--是否有FB, 排除中
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then
            return true
        end
    end
end

--[[local function setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
    button.texture:SetDesaturated(not getLeader() and true or false)

    if Save.PartyToRaid then
        button.border:SetAtlas('bag-border')
    else
        button.border:SetAtlas('bag-reagent-border')
    end

    if not button.LFGAutoInv and Save.LFGAutoInv then--邀请LFG,指示图标
        button.LFGAutoInv=button:CreateTexture(nil, 'ARTWORK')
        button.LFGAutoInv:SetPoint('BOTTOMLEFT',3,3)
        button.LFGAutoInv:SetSize(10,10)
        button.LFGAutoInv:SetAtlas(e.Icon.toRight)
        button.LFGAutoInv:SetDesaturated(true)
    end
    if button.LFGAutoInv then
        button.LFGAutoInv:SetShown(Save.LFGAutoInv)
    end
    if not button.InvTar and (Save.InvTar or (Save.Channel and Save.ChannelText)) then--邀请目标, 频道, 指示图标
        button.InvTar=button:CreateTexture(nil, 'ARTWORK')
        button.InvTar:SetPoint('BOTTOMRIGHT',-7,3)
        button.InvTar:SetSize(10,10)
        button.InvTar:SetAtlas(e.Icon.toLeft)
        button.InvTar:SetDesaturated(true)
    end
    if button.InvTar then
        button.InvTar:SetShown((Save.Channel and Save.ChannelText))
    end

    button.texture:SetDesaturated(not Save.FriendAceInvite)--自动接受,LFD, 好友, 邀请
end]]

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
                local u = v.namePlateUnitToken or (v.UnitFrame and v.UnitFrame.unit)
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
--[[
local Time
local function set_LFGListApplicationViewer_UpdateApplicantMember(self, appID, memberIdx, status2, pendingStatus)--自动清邀请, 队伍查找器, LFGList.lua
    if not  Save.LFGAutoInv or not UnitIsGroupLeader('player') then
        return
    end

    local applicantInfo = C_LFGList.GetApplicantInfo(appID)
    local status = applicantInfo and applicantInfo.applicationStatus
    local numInvited = C_LFGList.GetNumInvitedApplicantMembers() --已邀请人数
    local currentCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) --队伍人数            

    if status == 'applied'  and self:GetParent().numMembers then
        local to=numInvited + currentCount
        local raid=IsInRaid()
        if to>=40 or (not raid and currentCount==5 and not Save.PartyToRaid) then
            return
        end
        --toRaidOrParty(to)--自动, 转团,转小队
        self:GetParent().InviteButton:Click()

        local applicantID=applicantInfo.applicantID

        if not Time or GetTime() > Time + 1 then--刷新 
            local name, class, _, level, itemLevel, honorLevel, tank, healer, damage, assignedRole, relationship, dungeonScore= C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
            print(id, addName,
                level and MAX_PLAYER_LEVEL~=level and '|cff00ff00'..level..'|r' or '',--等级
                e.Class(nil, class) or '',--职业图标
                (tank and e.Icon.TANK or '')..(healer and e.Icon.HEALER or '')..(damage and e.Icon.DAMAGER or ''),
                itemLevel and itemLevel>1 and BAG_FILTER_EQUIPMENT..'|cnGREEN_FONT_COLOR:'..('%i'):format(itemLevel)..'|r' or '',
                e.PlayerLink(name) or '',
                dungeonScore and e.GetKeystoneScorsoColor(dungeonScore) or '',
                honorLevel and honorLevel>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..honorLevel or ''
            )

            C_Timer.After(1,function()
                if LFGListFrame.ApplicationViewer.RefreshButton:IsEnabled() then
                    LFGListFrame.ApplicationViewer.RefreshButton:Click()
                end
            end)
            Time= GetTime()
        end
    end
end
]]
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
    print(id, addName, TARGET, guid and e.GetPlayerInfo(nil, guid, true) or name)
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
--[[
--#######
--接受邀请
--#######
local function set_LFGListInviteDialog(self)--队伍查找器, 自动接受邀请
    if not Save.LFGListAceInvite or not self.resultID then
        return
    end
    local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID))
    if status=="invited" then
        local info= C_LFGList.GetSearchResultInfo(self.resultID)
        if self.AcceptButton and self.AcceptButton:IsEnabled() and info then
            print(id, e.onlyChinese and '接受' or ACCEPT, addName,
                info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and '|T4352494:0|t'..e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore) or '',--地下城史诗,分数
                info.leaderPvpRatingInfo and  info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r' or '',--PVP 分数
                info.leaderName and (e.onlyChinese and '%s邀请你加入' or COMMUNITY_INVITATION_FRAME_INVITATION_TEXT):format(e.PlayerLink(info.leaderName)..' ') or '',--	%s邀请你加入
                info.name and info.name or '',--名称
                e.Icon[role] or '',
                info.numMembers and (e.onlyChinese and '队员' or PLAYERS_IN_GROUP)..'|cff00ff00 '..info.numMembers..'|r' or '',--队伍成员数量
                info.autoAccept and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自动邀请' or AUTO_JOIN:gsub(JOIN,INVITE))..'|r' or '',--对方是否开启, 自动邀请
                info.activityID and '|cffff00ff'..C_LFGList.GetActivityFullName(info.activityID)..'|r' or '',--查找器,类型
                info.isWarMode~=nil and info.isWarMode ~= C_PvP.IsWarModeDesired() and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '战争模式' or TALENT_FRAME_LABEL_WARMODE)..'|r' or ''
            )
            e.PlaySound(SOUNDKIT.IG_PLAYER_INVITE)--播放, 声音
            e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
            if self.LFGListInviteDialogTimer then self.LFGListInviteDialogTimer:Cancel() end
            self.LFGListInviteDialogTimer=C_Timer.NewTimer(3, function()
                if self.AcceptButton:IsEnabled() then
                    self.AcceptButton:Click()
                end
            end)
        end
    elseif status=="inviteaccepted" then
        e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
        if self.LFGListInviteDialogTimer then self.LFGListInviteDialogTimer:Cancel() end
        self.LFGListInviteDialogTimer=C_Timer.NewTimer(3, function()
            if self.AcknowledgeButton:IsEnabled() then
                self.AcknowledgeButton:Click()
            end
        end)
    end
end
]]
--###########
--邀请, 对话框
--###########
local notInviterGUID--邀请,对话框, guid
local function set_PARTY_INVITE_REQUEST(name, isTank, isHealer, isDamage, isNativeRealm, allowMultipleRoles, inviterGUID, questSessionActive)
    if not inviterGUID or not name then
        return
    end
    local F=StaticPopup1
    if not F or not F:IsShown() then
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
        e.Ccool(F, nil, sec, nil, true, true, nil)--冷却条    
    end

    local friend=e.GetFriend(name, inviterGUID)
    if friend then--好友
        if not Save.FriendAceInvite then
            e.Ccool(F, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条  
            return
        end
        local sec=isInLFG() and 10 or 3--是否有FB, 排除中
        setPrint(sec, '|cnGREEN_FONT_COLOR:'..ACCEPT..'|r'..FRIENDS)
        if F.InvTimer then F.InvTimer:Cancel() end
        F.InvTimer = C_Timer.NewTimer(sec, function()
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
        end)

    elseif Save.InvNoFriend[inviterGUID] then--拒绝
        setPrint(3, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '拒绝' or DECLINE)..'|r'..Save.InvNoFriend[inviterGUID]..'/'..Save.InvNoFriendNum)
        F.button3:SetText('|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'..(e.onlyChinese and '接受' or ACCEPT))
        notInviterGUID=inviterGUID
        if F.InvTimer then F.InvTimer:Cancel() end
        F.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save.InvNoFriendNum=Save.InvNoFriendNum+1
            Save.InvNoFriend[inviterGUID]=Save.InvNoFriend[inviterGUID]+1
        end)

    elseif IsResting() and Save.NoInvInResting and not questSessionActive then--休息区不组队
        setPrint(3, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '' or DECLINE)..'|r'..(e.onlyChinese and '休息区' or (CALENDAR_STATUS_OUT..ZONE)))

        F.button3:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '拒绝' or DECLINE))
        notInviterGUID=inviterGUID
        if F.InvTimer then F.InvTimer:Cancel() end
        F.InvTimer = C_Timer.NewTimer(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            Save.InvNoFriendNum=Save.InvNoFriendNum+1
        end)

    else--添加 拒绝 陌生人
        F.button3:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '拒绝' or DECLINE))
        notInviterGUID=inviterGUID

        e.Ccool(F, nil, STATICPOPUP_TIMEOUT, nil, true, true, nil)--冷却条
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

--############
--预创建队伍增强
--############
local function set_LFGPlus()--预创建队伍增强
    if not Save.LFGPlus then
        return
    end
    --[[local f=LFGListFrame.SearchPanel.RefreshButton--界面, 添加, 选项    
    f.ace = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate")--自动进组  选项
    f.ace:SetPoint('RIGHT',f, 'LEFT',-90,0)
    f.ace.Text:SetText('|cFFFFD000'..(e.onlyChinese and '自动接受' or AUTO_JOIN:gsub(JOIN, ACCEPT))..'|r')
    f.ace:SetChecked(Save.LFGListAceInvite)
    f.ace:SetScript("OnMouseDown", function (s)
            Save.LFGListAceInvite=s:GetChecked()
    end)

    f=LFGListFrame.ApplicationViewer.DataDisplay --自动邀请 选项
    f.inv = CreateFrame("CheckButton",nil, f, "InterfaceOptionsCheckButtonTemplate")
    f.inv:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, -10)
    f.inv.Text:SetText('|cFFFFD000'..(e.onlyChinese and '自动邀请' or AUTO_JOIN:gsub(JOIN, INVITE))..'|r')
    f.inv:SetChecked(Save.LFGAutoInv)
    f.inv:SetScript("OnMouseDown", function(s)
            Save.LFGAutoInv=s:GetChecked()
    end)

    f.raid = CreateFrame("CheckButton",nil, f, "InterfaceOptionsCheckButtonTemplate")--转化为团队 选项
    f.raid:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 8)
    f.raid.Text:SetText('|cFFFFD000'..(e.onlyChinese and '转团' or CONVERT_TO_RAID)..'|r')
    f.raid:SetChecked(Save.PartyToRaid)

    f.raid:SetScript("OnMouseDown", function(s)
        Save.PartyToRaid=s:GetChecked()
    end)
]]
    local function getIndex(values, val)
        local index={}
        for k,v in pairs(values) do
            index[v]=k
        end
        return index[val]
    end
    hooksecurefunc("LFGListSearchEntry_Update", function(self)----查询,自定义, 预创建队伍, LFG队长分数, 双击加入 LFGList.lua
        local resultID = self.resultID
        if not C_LFGList.HasSearchResultInfo(resultID) then
            return
	    end
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        local categoryID= LFGListFrame.SearchPanel.categoryID
        local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
        local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or searchResultInfo.isDelisted

        local text, color, autoAccept = '', nil, nil
        if not isAppFinished then
            text, color=e.GetKeystoneScorsoColor(searchResultInfo.leaderOverallDungeonScore, true)--地下城, 分数
            if searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating and searchResultInfo.leaderPvpRatingInfo.rating>0 then--PVP, 分数
                local text2, color2=e.GetKeystoneScorsoColor(searchResultInfo.leaderPvpRatingInfo.rating)
                if searchResultInfo.isWarMode then
                    text= '|A:pvptalents-warmode-swords:0:0|a'..text2..' '..text
                else
                    text= text..' |A:pvptalents-warmode-swords:0:0|a'..text2
                end
                color= searchResultInfo.isWarMode and color2 or color
            end
            color= color or {r=1,g=1,b=1}
            if searchResultInfo.numBNetFriends and searchResultInfo.numBNetFriends>0 then--好友, 数量
                text= text..' '..e.Icon.wow2..searchResultInfo.numBNetFriends
            end
            if searchResultInfo.numCharFriends and searchResultInfo.numCharFriends>0 then--好友, 数量
                text= text..' |A:socialqueuing-icon-group:0:0|a'..searchResultInfo.numCharFriends
            end
            if searchResultInfo.numGuildMates and searchResultInfo.numGuildMates>0 then--好友, 数量
                text= text..' |A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a'..searchResultInfo.numCharFriends
            end
            autoAccept= searchResultInfo.autoAccept--自动, 邀请
        end
        if text~='' and not self.scorsoText then
            self.scorsoText= e.Cstr(self)
            self.scorsoText:SetPoint('TOPLEFT', self.DataDisplay.Enumerate,0,5)
        end
        if self.scorsoText then
            self.scorsoText:SetText(text)
            if color then
                self.Name:SetTextColor(color.r, color.g, color.b)
            end
        end
        if autoAccept and not self.autoAcceptTexture then--自动, 邀请
            self.autoAcceptTexture=self:CreateTexture(nil,'OVERLAY')
            self.autoAcceptTexture:SetPoint('LEFT')
            self.autoAcceptTexture:SetAtlas(e.Icon.select)
            self.autoAcceptTexture:SetSize(12,12)
            self.autoAcceptTexture:EnableMouse(true)
            self.autoAcceptTexture:SetScript('OnEnter', function(self2)
                 e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '自动接受' or LFG_LIST_AUTO_ACCEPT)
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
            end)
            self.autoAcceptTexture:SetScript("OnLeave", function() e.tips:Hide() end)
        end
        if self.autoAcceptTexture then
            self.autoAcceptTexture:SetShown(autoAccept)
        end

        local realm, realmText
        if searchResultInfo.leaderName and not isAppFinished then
            local server= searchResultInfo.leaderName:match('%-(.+)') or e.Player.server
            server=e.Get_Region(server)--服务器，EU， US {col, text}
            realm= server and server.col
            realmText=server and server.realm
        end
        if realm and not self.realmText then
            self.realmText= e.Cstr(self)
            --self.realmText:SetPoint('BOTTOMLEFT', self, 0, -2)
            self.realmText:SetPoint('BOTTOMLEFT', self.DataDisplay.Enumerate,0,-3)
            self.realmText:EnableMouse(true)
            self.realmText:SetScript('OnEnter', function(self2)
                if self2.realm then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(e.onlyChinese and '服务器' or VAS_REALM_LABEL, '|cnGREEN_FONT_COLOR:'..self2.realm)
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:Show()
                end
           end)
           self.realmText:SetScript("OnLeave", function() e.tips:Hide() end)
        end
        if self.realmText then
            self.realmText.realm= realmText
            self.realmText:SetText(realm or '')
        end

        self:SetScript('OnDoubleClick', function(self2)--LFGListApplicationDialogSignUpButton_OnClick(button) LFG队长分数, 双击加入 LFGListSearchPanel_UpdateResults
            if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
                LFGListFrame.SearchPanel.SignUpButton:Click()
            end
            local frame=LFGListApplicationDialog
            if not frame.TankButton.CheckButton:GetChecked() and not frame.HealerButton.CheckButton:GetChecked() and not frame.DamagerButton.CheckButton:GetChecked() then
                local specID=GetSpecialization()--当前专精
                if specID then
                    local role = select(5, GetSpecializationInfo(specID))
                    if role=='DAMAGER' and frame.DamagerButton:IsShown() then
                        frame.DamagerButton.CheckButton:SetChecked(true)

                    elseif role=='TANK' and frame.TankButton:IsShown() then
                        frame.TankButton.CheckButton:SetChecked(true)

                    elseif role=='HEALER' and frame.HealerButton:IsShown() then
                        frame.HealerButton.CheckButton:SetChecked(true)
                    end
                    LFGListApplicationDialog_UpdateValidState(frame)
                end
            end
            if frame:IsShown() and frame.SignUpButton:IsEnabled() then
                frame.SignUpButton:Click()
            end
        end)


        local orderIndexes = {}--https://wago.io/klC4qqHaF
        if categoryID == 2 and not isAppFinished then--_G["ShowRIORaitingWA1NotShowClasses"] ~= true
            for i=1, searchResultInfo.numMembers do
                local role, class = C_LFGList.GetSearchResultMemberInfo(self.resultID, i)
                local orderIndex = getIndex(LFG_LIST_GROUP_DATA_ROLE_ORDER, role)
                table.insert(orderIndexes, {orderIndex, class})
            end
            table.sort(orderIndexes, function(a,b) return a[1] < b[1] end)
        end
        local xOffset = -88
        for i = 1, 5 do
            local texture = "tex"..i
            if orderIndexes[i] then
                local class = orderIndexes[i][2]
                local classColor = RAID_CLASS_COLORS[class]
                local r, g, b= classColor:GetRGBA()
                if (not self.DataDisplay.Enumerate[texture]) then
                    self.DataDisplay.Enumerate[texture] = self.DataDisplay.Enumerate:CreateTexture(nil, "OVERLAY")
                    self.DataDisplay.Enumerate[texture]:SetSize(10, 3)
                    self.DataDisplay.Enumerate[texture]:SetPoint("RIGHT", self.DataDisplay.Enumerate, "RIGHT", xOffset, -10)
                end
                self.DataDisplay.Enumerate[texture]:SetColorTexture(r, g, b, 0.75)
                self.DataDisplay.Enumerate[texture]:SetShown(true)

            elseif self.DataDisplay.Enumerate[texture] then
                self.DataDisplay.Enumerate[texture]:SetShown(false)
            end
            xOffset = xOffset + 18
        end
    end)

    hooksecurefunc('LFGListUtil_SetSearchEntryTooltip', function(tooltip, resultID, autoAcceptOption)
        local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
        local _, appStatus, pendingStatus = C_LFGList.GetApplicationInfo(resultID)
        local isAppFinished = LFGListUtil_IsStatusInactive(appStatus) or LFGListUtil_IsStatusInactive(pendingStatus) or searchResultInfo.isDelisted
        if isAppFinished then
            return
        end
        local tab={}
        for i=1, searchResultInfo.numMembers do
            local role, classFile = C_LFGList.GetSearchResultMemberInfo(resultID, i)
            if classFile then
                tab[classFile]= tab[classFile] or {num=0, role={}}
                tab[classFile].num= tab[classFile].num +1
                table.insert(tab[classFile].role, {role=role, index= role=='TANK' and 1 or role=='HEALER' and 2 or 3})
            end
        end
        tooltip:AddLine(' ')
        for i=1,  GetNumClasses() do
            local classInfo = C_CreatureInfo.GetClassInfo(i)
            if classInfo and classInfo.classFile then
                local col='|c'..select(4, GetClassColor(classInfo.classFile))
                local text
                if tab[classInfo.classFile] then
                    local num=tab[classInfo.classFile].num
                    text= ' '..col..num..'|r'
                    local roleText=' '
                    table.sort(tab[classInfo.classFile].role, function(a,b) return a.index< b.index end)
                    for _, role in pairs(tab[classInfo.classFile].role) do
                        if e.Icon[role.role] then
                            roleText= roleText..e.Icon[role.role]
                        end
                    end
                    text= text.. roleText
                end
                tooltip:AddDoubleLine(e.Class(nil, classInfo.classFile).. (text or ''), col..i)
            end
            tooltip:Show()
        end

    end)
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

--初始菜单
--#######
local function InitList(self, level, type)
    --#####
    --对话框
    --#####
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
            self2.editBox:SetText(Save.ChannelText or (e.Player.cn and '1' or 'inv'))
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
            s:GetParent():Hide()
        end,
    }

    local info
    if type=='InvUnit' then--邀请单位    
        info={
            text= e.onlyChinese and '邀请成员' or GUILDCONTROL_OPTION7,
            notCheckable=true,
            isTitle=true,
        }
        UIDropDownMenu_AddButton(info, level)

        --[[info={--邀请LFD
            text= e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON,
            func=function()
                Save.LFGAutoInv= not Save.LFGAutoInv and true or nil
                local f=(LFGListFrame and LFGListFrame.ApplicationViewer) and LFGListFrame.ApplicationViewer.DataDisplay.inv
                if f then
                    f:SetChecked(Save.LFGAutoInv)
                end
                setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end,
            checked=Save.LFGAutoInv,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '仅限: |cnRED_FONT_COLOR:队长|r' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE, '|cff00ff00'..LEADER..'|r'),
        }
        UIDropDownMenu_AddButton(info, level)]]

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
        UIDropDownMenu_AddButton(info, level)

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
        UIDropDownMenu_AddButton(info, level)

        info={--已邀请列表
            text= e.onlyChinese and '已邀请' or LFG_LIST_APP_INVITED,--三级列表，已邀请列表
            notCheckable=true,
            menuList='InvUnitAll',
            hasArrow=true,
            func=InvPlateGuidFunc,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '邀请全部' or CALENDAR_INVITE_ALL,
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)

        --[[info={--转团
            text=e.onlyChinese and '转团' or CONVERT_TO_RAID,
            func=function()
                Save.PartyToRaid= not Save.PartyToRaid and true or nil
                local f=(LFGListFrame and LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer.DataDisplay) and LFGListFrame.ApplicationViewer.DataDisplay.raid
                if f then
                    f:SetChecked(Save.PartyToRaid)
                end
                --setTexture()--设置图标颜色, 是否有权限, 是否转团
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '仅限队伍查找器' or format(GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE, '|cff00ff00'..DUNGEONS_BUTTON..'|r'),
            checked= Save.PartyToRaid,
        }
        UIDropDownMenu_AddButton(info, level)]]


        info={
            text= e.onlyChinese and '预创建队伍增强' or SCORE_POWER_UPS:gsub(ITEMS,LFGLIST_NAME),
            func=function()
                Save.LFGPlus = not Save.LFGPlus and true or nil
                print(id, addName, e.GetEnabeleDisable(Save.LFGPlus), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end,
            checked=Save.LFGPlus,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '预创建队伍' or LFGLIST_NAME,
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='InvUnitAll' then--三级列表，已邀请列表
        local n, all=0, 0
        for guid, name in pairs(InvPlateGuid) do
            if not e.GroupGuid[guid] then
                info={
                    text=e.GetPlayerInfo(nil, guid, true),
                    tooltipOnButton=true,
                    tooltipTitle= e.onlyChinese and '邀请' or INVITE,
                    tooltipText=name,
                    notCheckable=true,
                    func=function()
                        C_PartyInfo.InviteUnit(name)
                    end,

                }
                UIDropDownMenu_AddButton(info, level)
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
            UIDropDownMenu_AddButton(info, level)
        else
            UIDropDownMenu_AddSeparator(level)
            info={
                text= '|cff00ff00'..(e.onlyChinese and '邀请全部' or CALENDAR_INVITE_ALL)..'|r',
                notCheckable=true,
                func= InvPlateGuidFunc,
            }
            UIDropDownMenu_AddButton(info, level)

            info={
                text='|cffff0000'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r',
                notCheckable=true,
                func=function()
                    InvPlateGuid={}
                end,
            }
            UIDropDownMenu_AddButton(info, level)
        end

    elseif type=='ACEINVITE' then--自动接受邀请
        --[[info={--队伍查找器
            text= e.onlyChinese and '接受邀请' or CALENDAR_ACCEPT_INVITATION,
            isTitle=true,
            notCheckable=true,
        }
        UIDropDownMenu_AddButton(info, level)

        info={
            text= e.onlyChinese and '队伍查找器' or DUNGEONS_BUTTON,
            checked=Save.LFGListAceInvite,
            func=function()
                Save.LFGListAceInvite= not Save.LFGListAceInvite and true or nil
                setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
            end,
        }
        UIDropDownMenu_AddButton(info, level)]]

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
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
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
        UIDropDownMenu_AddButton(info, level)

    elseif type=='NoInv' then
        info={
            text= e.onlyChinese and '拒绝邀请' or LFG_LIST_APP_INVITE_DECLINED,--三级列表，拒绝邀请列表
            notCheckable=true,
            menuList='NoInvList',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)

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
        UIDropDownMenu_AddButton(info, level)

        UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '休息区信息' or CALENDAR_STATUS_OUT..ZONE..INFO,
            checked=Save.restingTips,
            func=function()
                Save.restingTips= not Save.restingTips and true or nil
                set_PLAYER_UPDATE_RESTING()--设置, 休息区提示
            end,
        }
        UIDropDownMenu_AddButton(info, level)

    elseif type=='NoInvList' then--三级列表，拒绝邀请列表
        local all=0
        for guid, nu in pairs(Save.InvNoFriend) do
            local text=e.GetPlayerInfo(nil, guid, true)
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
                UIDropDownMenu_AddButton(info, level)
            end
        end
        if all==0 then
            info={
                text= e.onlyChinese and '无' or NONE,
                notCheckable=true,
                isTitle=true,
            }
            UIDropDownMenu_AddButton(info, level)
        else
            UIDropDownMenu_AddSeparator(level)
            info={
                text=e.onlyChinese and '全部清除' or CLEAR_ALL,
                colorCode= '|cff00ff00',
                notCheckable=true,
                func=function()
                    Save.InvNoFriend={}
                    print(id, addName, '|cff00ff00'..(e.onlyChinese and '全部清除' or CLEAR_ALL)..'|r', e.onlyChinese and '完成' or DONE)
                end,
            }
            UIDropDownMenu_AddButton(info, level)
        end

    elseif type=='ChannelText' then--三级列表,修改,频道,关键词
        info={
            text= e.onlyChinese and '关键词' or KBASE_DEFAULT_SEARCH_TEXT,--在这里输入关键字。
            notCheckable=true,
            func= function()
                StaticPopup_Show(id..addName..'CHANNEL')
            end
        }
        UIDropDownMenu_AddButton(info, level)

    else
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
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        info = {
            text= e.onlyChinese and '接受邀请' or CALENDAR_ACCEPT_INVITATION,
            notCheckable=true,
            menuList='ACEINVITE',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        info = {
            text= e.onlyChinese and '拒绝邀请' or GUILD_INVITE_DECLINE,
            notCheckable=true,
            menuList='NoInv',
            hasArrow=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and ('拒绝 '..Save.InvNoFriendNum..' 次') or (DECLINE..' '..format(ITEM_SPELL_CHARGES, Save.InvNoFriendNum))
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####
local function Init()
    button:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    button.texture:SetAtlas('communities-icon-addgroupplus')
    --setTexture()--设置图标颜色, 是否有权限

    button.Menu= CreateFrame("Frame",nil, LFDMicroButton, "UIDropDownMenuTemplate")--菜单列表
    UIDropDownMenu_Initialize(button.Menu, InitList, "MENU")

    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            InvUnitFunc()--邀请，周围玩家
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    set_event_PLAYER_UPDATE_RESTING()--设置, 休息区提示事件
    set_LFGPlus()--预创建队伍增强
    set_Chanell_Event()--设置,内容,频道, 邀请,事件

    --[[LFGListInviteDialog:SetScript("OnHide", function(self)--LFG,,自动接受邀请
        if self.LFGListInviteDialogTimer then
            self.LFGListInviteDialogTimer:Cancel()
        end
    end)
    --LFGListInviteDialog:SetScript("OnShow", set_LFGListInviteDialog)--队伍查找器, 自动接受邀请

    --hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", set_LFGListApplicationViewer_UpdateApplicantMember)--自动清邀请, 队伍查找器, LFGList.lua

    StaticPopup1:SetScript('OnHide', function(self)--被邀请, 对话框, 取消记时器
        if self.InvTimer then
            self.InvTimer:Cancel()
        end
        notInviterGUID=nil
    end)]]

    StaticPopupDialogs["PARTY_INVITE"].button3= '|cff00ff00'..ALWAYS..'|r'..DECLINE..'|r'--添加总是拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if notInviterGUID then
            if Save.InvNoFriend[notInviterGUID] then
                Save.InvNoFriend[notInviterGUID] =nil
                print(id, addName, '|cnRED_FONT_COLOR:'..REMOVE..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..DECLINE..'|r'..INVITE)
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
            else
                Save.InvNoFriend[notInviterGUID] =Save.InvNoFriend[notInviterGUID] and Save.InvNoFriend[notInviterGUID]+1 or 1
                Save.InvNoFriendNum=Save.InvNoFriendNum+1
                DeclineGroup()
                StaticPopup_Hide("PARTY_INVITE")
                print(id,addName, '|cnGREEN_FONT_COLOR:'..ADD..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..DECLINE..'|r'..INVITE)
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

                button=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
                Init()

                panel:RegisterEvent("PLAYER_LOGOUT")
                panel:RegisterEvent('GROUP_LEFT')
                panel:RegisterEvent('GROUP_ROSTER_UPDATE')
                panel:RegisterEvent('PARTY_INVITE_REQUEST')
                panel:RegisterEvent('PLAYER_UPDATE_RESTING')----休息区提示
                panel:RegisterEvent('PLAYER_ENTERING_WORLD')
            end
            panel:UnregisterEvent('ADDON_LOADED')
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
    end
end)
