local id, e = ...
local addName= INVITE
local Save={InvNoFriend={}, LFGListAceInvite=true, FriendAceInvite=true, InvNoFriendNum=0, restingTips=true, LFGPlus=true}
local InvPlateGuid={}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel


local function getLeader()--取得权限
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end
local function toRaidOrParty(number)--自动, 转团
    if Save.PartyToRaid then
        number= number or GetNumGroupMembers()
        local raid= IsInRaid()
        if number>=5 and not raid then 
            C_PartyInfo.ConvertToRaid();
            print(id, addName, '|cnGREEN_FONT_COLOR:'..CONVERT_TO_RAID..'|r')
        elseif number<6 and raid then 
            C_PartyInfo.ConvertToParty();
            print(id, addName, '|cnGREEN_FONT_COLOR:'..CONVERT_TO_PARTY..'|r')
        end
    end
end

local function isInLFG()--是否有FB, 排除中
    for type=1, NUM_LE_LFG_CATEGORYS do
        if GetLFGQueueStats(type) then 
            return true 
        end
    end
end

local function setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
    panel.texture:SetDesaturated(not getLeader() and true or false)

    if Save.PartyToRaid then
        panel.border:SetAtlas('bag-border')
    else
        panel.border:SetAtlas('bag-reagent-border')
    end

    if not panel.LFGAutoInv and Save.LFGAutoInv then--自动进入,指示图标
        panel.LFGAutoInv=panel:CreateTexture(nil, 'ARTWORK')
        panel.LFGAutoInv:SetPoint('BOTTOMLEFT',3,3)
        panel.LFGAutoInv:SetSize(10,10)
        panel.LFGAutoInv:SetAtlas(e.Icon.toRight)
        panel.LFGAutoInv:SetDesaturated(true)
    end
    if panel.LFGAutoInv then
        panel.LFGAutoInv:SetShown(Save.LFGAutoInv)
    end
    if not panel.InvTar and Save.InvTar then--自动离开,指示图标
        panel.InvTar=panel:CreateTexture(nil, 'ARTWORK')
        panel.InvTar:SetPoint('BOTTOMRIGHT',-7,3)
        panel.InvTar:SetSize(10,10)
        panel.InvTar:SetAtlas(e.Icon.toLeft)
        panel.InvTar:SetDesaturated(true)
    end
    if panel.InvTar then
        panel.InvTar:SetShown(Save.InvTar)
    end

    panel.texture:SetDesaturated(not (Save.LFGListAceInvite and Save.FriendAceInvite))--自动接受,LFD, 好友, 邀请
end

--#######
--邀请玩家
--#######
local InvPlateTimer
local InvUnitFunc=function()--邀请，周围玩家
    if not getLeader() then--取得权限
        print(id,addName, ERR_GUILD_PERMISSIONS)
        return
    end 
    
    local p=C_CVar.GetCVarBool('nameplateShowFriends');
    local all=C_CVar.GetCVarBool('nameplateShowAll');
    if not all then C_CVar.SetCVar('nameplateShowAll', 1) end
    if not p then C_CVar.SetCVar('nameplateShowFriends', 1) end
    
    if InvPlateTimer and not InvPlateTimer:IsCancelled() then
        InvPlateTimer:Cancel()
    end
    
    InvPlateTimer=C_Timer.NewTicker(0.3, function()
            local n=0;
            local co=GetNumGroupMembers();
            local raid=IsInRaid();
            if (not raid and co==5) and not Save.PartyToRaid then 
                print(id, addName, PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
                
            elseif co==40 then
                print(id, addName, RED_FONT_COLOR_CODE..'|r', co, PLAYERS_IN_GROUP)        
            else 
                toRaidOrParty(number)--自动, 转团
                for _, v in pairs(C_NamePlate.GetNamePlates()) do
                    local u = v.namePlateUnitToken or (v.UnitFrame and v.UnitFrame.unit);                
                    local name=GetUnitName(u,true);
                    local guid=UnitGUID(u);
                    if name and guid and not UnitInAnyGroup(u) and not UnitIsAFK(u) and UnitIsConnected(u) and UnitIsPlayer(u) and UnitIsFriend(u, 'player') and not UnitIsUnit('player',u) then
                        if not InvPlateGuid[guid] then 
                            n=n+1 
                        end
                        
                        C_PartyInfo.InviteUnit(name); 
                        InvPlateGuid[guid]=name;                    
                        print(n..')',INVITE ,e.PlayerLink(name, guid));
                        
                        if not raid and n +co>=5  then 
                            print(id, addName, PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
                            break
                        end
                    end
                end
            end
            if not all then C_CVar.SetCVar('nameplateShowAll', 0) end
            if not p then C_CVar.SetCVar('nameplateShowFriends', 0) end
            if n==0 then print(GUILDCONTROL_OPTION7..': '..RED_FONT_COLOR_CODE..NONE..'|r') end
            
            if InvPlateTimer and InvPlateTimer:IsCancelled() then 
                InvPlateTimer:Cancel() 
            end
    end,1)
end

local Time
local function set_LFGListApplicationViewer_UpdateApplicantMember(self, appID, memberIdx, status, pendingStatus)--自动清邀请, 队伍查找器, LFGList.lua
    if not  Save.LFGAutoInv or not UnitIsGroupLeader('player') then
        return
    end
    
    local applicantInfo = C_LFGList.GetApplicantInfo(appID);            
    local status = applicantInfo and applicantInfo.applicationStatus;
    local numInvited = C_LFGList.GetNumInvitedApplicantMembers() --已邀请人数
    local currentCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) --队伍人数            
    
    if status == 'applied'  and self:GetParent().numMembers then
        local to=numInvited + currentCount;
        local raid=IsInRaid();            
        if to>=40 or (not raid and currentCount==5 and not Save.PartyToRaid) then
            return
        end
        toRaidOrParty(to)--自动, 转团,转小队
        self:GetParent().InviteButton:Click();
        
        local applicantID=applicantInfo.applicantID;
        
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
                    LFGListFrame.ApplicationViewer.RefreshButton:Click();
            end);                    
            Time= GetTime();
        end
    end 
end

local function set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    if Save.InvTar and not IsInInstance() then
        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
    else
        panel:UnregisterEvent('PLAYER_TARGET_CHANGED')
    end
end
local function set_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    if not Save.InvTar 
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
    
    local raid=IsInRaid();
    local co=GetNumGroupMembers();
    if (raid and co==40) or (not raid and co==5 and not Save.PartyToRaid) then 
        return 
    end
    
    local name=GetUnitName(u, true);
    if not name then 
        return
    end
    
    toRaidOrParty(number)--自动, 转团

    C_PartyInfo.InviteUnit(name); 
    
    local guid=UnitGUID(u);
    
    InvPlateGuid[guid]=name;--保存到已邀请列表
    
    local info=e.GUID(guid);
    print(addName, INVITE..TARGET, e.GetPlayerInfo(nil, guid, true))
end

local function InvPlateGuidFunc()--从已邀请过列表里, 再次邀请 
    if not getLeader() then--取得权限
        print(id, addName, ERR_GUILD_PERMISSIONS) 
        return
    end 
    local n=0;
    local co=GetNumGroupMembers();
    for guid, name in pairs(InvPlateGuid) do
        local num=n+co
        if num==40 then
            return
        elseif not IsInRaid() and num==5 and not Save.PartyToRaid then 
            print(id, addName, PETITION_TITLE:format('|cff00ff00'..CONVERT_TO_RAID..'|r'))
            return
        end

        toRaidOrParty(num)--自动, 转团,转小队

        C_PartyInfo.InviteUnit(name)
        n=n+1
        print(n..')'..e.PlayerLink(name, guid))
    end
end

--#######
--接受邀请
--#######
local function set_LFGListInviteDialog(self)--队伍查找器, 自动接受邀请
    if not Save.LFGListAceInvite or not self.resultID then
        return
    end
    local status, _, _, role= select(2,C_LFGList.GetApplicationInfo(self.resultID));
    if status=="invited" then 
        local info=C_LFGList.GetSearchResultInfo(self.resultID);
        if self.AcceptButton and self.AcceptButton:IsEnabled() and info then
            print(id, ACCEPT, addName,
                info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and '|T4352494:0|t'..e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore) or '',--地下城史诗,分数
                info.leaderPvpRatingInfo and  info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating>0 and '|A:pvptalents-warmode-swords:0:0|a|cnRED_FONT_COLOR:'..info.leaderPvpRatingInfo.rating..'|r' or '',--PVP 分数
                info.leaderName and COMMUNITY_INVITATION_FRAME_INVITATION_TEXT:format(e.PlayerLink(info.leaderName)..' ') or '',--	%s邀请你加入
                info.name and info.name or '',--名称
                e.Icon[role] or '',
                info.numMembers and PLAYERS_IN_GROUP..'|cff00ff00'..info.numMembers..'|r' or '',--队伍成员数量
                info.autoAccept and '|cnGREEN_FONT_COLOR:'..AUTO_JOIN:gsub(JOIN,INVITE)..'|r' or '',--对方是否开启, 自动邀请
                info.activityID and '|cffff00ff'..C_LFGList.GetActivityFullName(info.activityID)..'|r' or '',--查找器,类型
                info.isWarMode~=nil and info.isWarMode ~= C_PvP.IsWarModeDesired() and '|cnGREEN_FONT_COLOR:'..TALENT_FRAME_LABEL_WARMODE..'|r' or ''
            )
            e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
            self.LFGListInviteDialogTimer=C_Timer.NewTicker(3, function()
                    self.AcceptButton:Click()
            end, 1)
        end
    elseif status=="inviteaccepted" then
        if self.LFGListInviteDialogTimer and not self.LFGListInviteDialogTimer:IsCancelled() then
            self.LFGListInviteDialogTimer:Cancel()
        end
        e.Ccool(self, nil, 3, nil, true, true, nil)--冷却条
        self.LFGListInviteDialogTimer=C_Timer.NewTicker(3, function()
            self.AcknowledgeButton:Click();
        end, 1)
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
    local F=StaticPopup1
    if not F or not F:IsShown() then
        return
    end
    --local tex=StaticPopup1Text;  
    local playerInfo= e.GetPlayerInfo(nil, inviterGUID, true)

    local function setPrint(sec, text)
        print(id, addName, text,
            '|cnGREEN_FONT_COLOR:'..sec.. ' |r'..SECONDS,
            e.PlayerLink(nil, inviterGUID),
            (isTank and e.Icon.TANK or '')..(isHealer and e.Icon.HEALER or '')..(isDamage and e.Icon.DAMAGER or ''),
            questSessionActive and SCENARIOS or '',--场景战役
            isNativeRealm and '|cnGREEN_FONT_COLOR:'..BLIZZARD_STORE_VAS_TRANSFER_REALM..'|r' or ''--转服务器
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
        F.InvTimer = C_Timer.NewTicker(sec, function()
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE")
        end, 1)
        
    elseif Save.InvNoFriend[inviterGUID] then--拒绝
        setPrint(3, '|cnRED_FONT_COLOR:'..DECLINE..'|r',Save.InvNoFriend[inviterGUID]..'/'..Save.InvNoFriendNum)
        F.button3:SetText('|cnRED_FONT_COLOR:'..REMOVE..'|r'..ACCEPT)
        notInviterGUID=inviterGUID
        F.InvTimer = C_Timer.NewTicker(3, function()
            DeclineGroup();
            StaticPopup_Hide("PARTY_INVITE")
            Save.InvNoFriendNum=Save.InvNoFriendNum+1
            Save.InvNoFriend[inviterGUID]=Save.InvNoFriend[inviterGUID]+1
        end, 1)
        
    elseif IsResting() and Save.NoInvInResting and not questSessionActive then--休息区不组队
        setPrint(3, '|cnRED_FONT_COLOR:'..DECLINE..'|r'..CALENDAR_STATUS_OUT..ZONE)

        F.button3:SetText('|cnGREEN_FONT_COLOR:'..ADD..'|r'..DECLINE)
        notInviterGUID=inviterGUID

        F.InvTimer = C_Timer.NewTicker(3, function()
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE");
            Save.InvNoFriendNum=Save.InvNoFriendNum+1
        end, 1)
        
    else--添加 拒绝 陌生人
        F.button3:SetText('|cnGREEN_FONT_COLOR:'..ADD..'|r'..DECLINE)
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
        print(id, addName, ENTER_LFG, '|cnRED_FONT_COLOR:'..CALENDAR_STATUS_OUT..'|r'..ZONE)
    else
        print(id, addName, LEAVE, '|cnRED_FONT_COLOR:'..CALENDAR_STATUS_OUT..'|r'..ZONE)
    end
end

--############
--预创建队伍增强
--############
local function set_LFGPlus()--预创建队伍增强

    local f=LFGListFrame.SearchPanel.RefreshButton;--界面, 添加, 选项    
    f.ace = CreateFrame("CheckButton", nil, f, "InterfaceOptionsCheckButtonTemplate");--自动进组  选项
    f.ace:SetPoint('RIGHT',f, 'LEFT',-90,0)
    f.ace.Text:SetText('|cFFFFD000'..AUTO_JOIN:gsub(JOIN, ACCEPT)..'|r');
    f.ace:SetChecked(Save.LFGListAceInvite);    
    f.ace:SetScript("OnClick", function (s)
            Save.LFGListAceInvite=s:GetChecked();
    end);
    
    f=LFGListFrame.ApplicationViewer.DataDisplay; --自动邀请 选项
    f.inv = CreateFrame("CheckButton",nil, f, "InterfaceOptionsCheckButtonTemplate");
    f.inv:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, -10)
    f.inv.Text:SetText('|cFFFFD000'..AUTO_JOIN:gsub(JOIN, INVITE)..'|r');
    f.inv:SetChecked(Save.LFGAutoInv);
    f.inv:SetScript("OnClick", function(s)
            Save.LFGAutoInv=s:GetChecked();
    end)
    
    f.raid = CreateFrame("CheckButton",nil, f, "InterfaceOptionsCheckButtonTemplate");--转化为团队 选项
    f.raid:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, 8);
    f.raid.Text:SetText('|cFFFFD000'..CONVERT_TO_RAID..'|r');
    f.raid:SetChecked(Save.PartyToRaid);
    
    f.raid:SetScript("OnClick", function(s)
        e.Save.PartyToRaid=s:GetChecked()
    end)    

    hooksecurefunc("LFGListSearchEntry_Update", function(self)----查询,自定义, 预创建队伍, LFG队长分数, 双击加入
        local info = Save.LFGPlus and self.resultID and  C_LFGList.GetSearchResultInfo(self.resultID);
        if info and not info.isDelisted then
            local text=e.GetKeystoneScorsoColor(info.leaderOverallDungeonScore, true);--分数
            text= info.leaderPvpRatingInfo and info.leaderPvpRatingInfo.rating and text..'|A:pvptalents-warmode-swords:0:0|a'..info.leaderPvpRatingInfo.rating or text
            if text~='' then
                local searchResultInfo = C_LFGList.GetSearchResultInfo(self.resultID);
                local activityName = searchResultInfo and C_LFGList.GetActivityFullName(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);            
                self.ActivityName:SetText(text..(activityName or ''));
            end
            self:SetAlpha(text=='' and 0.7 or 1)

            self:SetScript('OnDoubleClick', function(self2)--LFGListApplicationDialogSignUpButton_OnClick(button) LFG队长分数, 双击加入 LFGListSearchPanel_UpdateResults
                if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
                    LFGListFrame.SearchPanel.SignUpButton:Click();
                end                    
                local frame=LFGListApplicationDialog;
                if not frame.TankButton.CheckButton:GetChecked() and not frame.HealerButton.CheckButton:GetChecked() and not frame.DamagerButton.CheckButton:GetChecked() then
                    local id=GetSpecialization()--当前专精
                    if id then 
                        local role = select(5, GetSpecializationInfo(id));
                        if role=='DAMAGER' and frame.DamagerButton:IsShown() then
                            frame.DamagerButton.CheckButton:SetChecked(true);
                            
                        elseif role=='TANK' and frame.TankButton:IsShown() then
                            frame.TankButton.CheckButton:SetChecked(true);
                            
                        elseif role=='HEALER' and frame.HealerButton:IsShown() then
                            frame.HealerButton.CheckButton:SetChecked(true);
                        end    
                        LFGListApplicationDialog_UpdateValidState(frame);
                    end
                end                    
                if frame:IsShown() and frame.SignUpButton:IsEnabled() then
                    frame.SignUpButton:Click();
                end 
            end)
        end
    end)
--[[local buttons= self.ScrollBox and self --LFGListSearchPanel_UpdateResults'
self.ScrollBox:GetFrames() or {}
if not self.searching or self.totalResults~=0  and #buttons~=0 then
for _, button in pairs(buttons) do
]]
end

--初始菜单
--#######
local function InitList(self, level, type)
    local info
    if type then
        if type=='InvUnit' then--邀请单位    
            info={
                text=GUILDCONTROL_OPTION7,
                notCheckable=true,
                isTitle=true,
            }
            UIDropDownMenu_AddButton(info, level)
            
            info={--邀请LFD
                text=DUNGEONS_BUTTON,
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
                tooltipTitle=GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format('|cff00ff00'..LEADER..'|r'),
            }
            UIDropDownMenu_AddButton(info, level);
            
            
           
            info={--邀请目标
                text=INVITE..TARGET,
                checked=Save.InvTar,
                disabled=IsInInstance() and true or nil,
                func=function()
                    Save.InvTar= not Save.InvTar and true or nil
                    set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
                    set_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
                    setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
                end,
                tooltipOnButton=true,
                tooltipTitle=GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format('|cff00ff00'..LEADER..'|r'..NO..'|cnRED_FONT_COLOR:'..INSTANCE..'|r'),
            }
            UIDropDownMenu_AddButton(info, level)

            
            info={--已邀请列表
                text= LFG_LIST_APP_INVITED,--三级列表，已邀请列表
                notCheckable=true,
                menuList='InvUnitAll',
                hasArrow=true,
                func=InvPlateGuidFunc,
                tooltipOnButton=true;
                tooltipTitle=CALENDAR_INVITE_ALL,
            }
            UIDropDownMenu_AddButton(info, level);
            UIDropDownMenu_AddSeparator(level)
            
            info={--转团
                text=CONVERT_TO_RAID,
                func=function()
                    Save.PartyToRaid= not Save.PartyToRaid and true or nil
                    local f=(LFGListFrame and LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer.DataDisplay) and LFGListFrame.ApplicationViewer.DataDisplay.raid
                    if f then 
                        f:SetChecked(Save.PartyToRaid) 
                    end
                    setTexture()--设置图标颜色, 是否有权限, 是否转团
                end,
                tooltipOnButton=true,
                ooltipTitle=GROUP_FINDER_CROSS_FACTION_LISTING_WITHOUT_PLAYSTLE:format('|cff00ff00'..DUNGEONS_BUTTON..'|r'),
                checked= Save.PartyToRaid,
            }
            UIDropDownMenu_AddButton(info, level);
            
            
            info={--预创建队伍增强
                text=SCORE_POWER_UPS:gsub(ITEMS,LFGLIST_NAME),
                func=function()
                    Save.LFGPlus = not Save.LFGPlus and true or nil
                end,
                checked=Save.LFGPlus,
                tooltipOnButton=true,
                tooltipTitle=LFGLIST_NAME,
            }
            UIDropDownMenu_AddButton(info, level)

        elseif type=='InvUnitAll' then--三级列表，已邀请列表
            local n, all=0, 0;
            for guid, name in pairs(InvPlateGuid) do
                if not e.GroupGuid[guid] then
                    info={
                        text=e.GetPlayerInfo(nil, guid, true),
                        notCheckable=true,
                        func=function() 
                            C_PartyInfo.InviteUnit(name)
                        end,
                        tooltipOnButton=true,
                        tooltipTitle=INVITE,
                    }
                    UIDropDownMenu_AddButton(info, level);
                    n=n+1;
                end
                all=all+1
            end
            if n==0 then
                info={
                    text=NONE;
                    notCheckable=true,
                    isTitle=true,
                }
                UIDropDownMenu_AddButton(info, level)
            else
                UIDropDownMenu_AddSeparator(level)
                info={
                    text='|cff00ff00'..CALENDAR_INVITE_ALL..'|r',
                    notCheckable=true,
                    func= InvPlateGuidFunc,
                }
                UIDropDownMenu_AddButton(info, level)
                
                info={
                    text='|cffff0000'..CLEAR_ALL..'|r',
                    notCheckable=true,
                    func=function()
                        InvPlateGuid={}
                    end,
                }
                UIDropDownMenu_AddButton(info, level);     
            end
        
        elseif type=='ACEINVITE' then--自动接受邀请
            info={--队伍查找器
                text=CALENDAR_ACCEPT_INVITATION,
                isTitle=true;
                notCheckable=true;
            }
            UIDropDownMenu_AddButton(info, level)   
            
            info={
                text=DUNGEONS_BUTTON,
                checked=Save.LFGListAceInvite,
                func=function()
                    Save.LFGListAceInvite= not Save.LFGListAceInvite and true or nil
                    setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            info={--好友
                text=FRIENDS,
                checked=Save.FriendAceInvite,
                tooltipOnButton=true,
                tooltipTitle=COMMUNITY_COMMAND_BATTLENET..', '..FRIENDS..', '..GUILD,
                func=function()
                    Save.FriendAceInvite= not Save.FriendAceInvite and true or nil
                    setTexture()--设置图标颜色, 是否有权限, 是否转团, 邀请选项提示
                end,
            }
            UIDropDownMenu_AddButton(info, level)  
        
        elseif type=='NoInv' then--拒绝邀请
            info={
                text=LFG_LIST_APP_INVITE_DECLINED,--三级列表，拒绝邀请列表
                notCheckable=true,
                menuList='NoInvList',
                hasArrow=true,
            }
            UIDropDownMenu_AddButton(info, level)
            
            info={
                text=RED_FONT_COLOR_CODE..CALENDAR_STATUS_OUT..'|r'..ZONE,--休息区拒绝组队  
                checked=Save.NoInvInResting,
                tooltipOnButton=true,
                tooltipTitle=DECLINE..RED_FONT_COLOR_CODE..NO..'|r'..TUTORIAL_TITLE22,
                func=function()
                    Save.NoInvInResting= not Save.NoInvInResting and true or nil
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)
            info={
                text=CALENDAR_STATUS_OUT..ZONE..INFO,
                checked=Save.restingTips,
                func=function()
                    Save.restingTips= not Save.restingTips and true or nil
                    set_PLAYER_UPDATE_RESTING()--设置, 休息区提示
                end,
            }
            UIDropDownMenu_AddButton(info, level)

        elseif type=='NoInvList' then--三级列表，拒绝邀请列表
            local all=0;
            for guid, nu in pairs(Save.InvNoFriend) do        
                local text=e.GetPlayerInfo(nil, guid, true)
                if text then
                    all=all+1
                    info={
                        text=all..') '..text..' |cff00ff00'..nu..'|r';
                        notCheckable=true,
                        func=function() 
                            Save.InvNoFriend[guid]=nil
                            print(id, addName, '|cff00ff00'..REMOVE..'|r: '..text);
                        end,
                        tooltipOnButton=true,
                        tooltipTitle=REMOVE,
                        tooltipText= ITEM_SPELL_CHARGES:format(nu)
                    }
                    UIDropDownMenu_AddButton(info, level)            
                end
            end    
            if all==0 then
                local info={
                    text=NONE,
                    notCheckable=true,
                    isTitle=true,
                }
                UIDropDownMenu_AddButton(info, level)
            else
                UIDropDownMenu_AddSeparator(level)
                info={
                    text='|cff00ff00'..CLEAR_ALL..'|r ',
                    notCheckable=true,
                    func=function()
                        Save.InvNoFriend={}
                        print(id, addName, '|cff00ff00'..CLEAR_ALL..'|r: ', DONE)
                    end,
                }
                UIDropDownMenu_AddButton(info, level)
            end
        end
    else
        info={--邀请成员
            text=e.Icon.left..GUILDCONTROL_OPTION7,
            notCheckable=true,
            menuList='InvUnit',
            func=InvUnitFunc,--邀请，周围玩家
            tooltipOnButton=true,
            tooltipTitle=INVITE..e.Icon.left..SPELL_RANGE_AREA:gsub(SPELL_TARGET_CENTER_CASTER,''),
            hasArrow=true,
            colorCode=not getLeader() and '|cff606060',
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        info = {--接受邀请
            text= CALENDAR_ACCEPT_INVITATION,
            notCheckable=true,
            menuList='ACEINVITE',
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)
        info = {--拒绝邀请
            text=GUILD_INVITE_DECLINE,
            notCheckable=true,
            menuList='NoInv',
            hasArrow=true,
            tooltipOnButton=true,
            tooltipTitle=DECLINE..' '..ITEM_SPELL_CHARGES:format(Save.InvNoFriendNum)
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####

local function Init()
    panel.texture:SetAtlas('communities-icon-addgroupplus')
    setTexture()--设置图标颜色, 是否有权限

    panel.Menu= CreateFrame("Frame",nil, LFDMicroButton, "UIDropDownMenuTemplate")--菜单列表
    UIDropDownMenu_Initialize(panel.Menu, InitList, "MENU")
    
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            InvUnitFunc()--邀请，周围玩家
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)

    set_event_PLAYER_TARGET_CHANGED()--设置, 邀请目标事件
    set_event_PLAYER_UPDATE_RESTING()--设置, 休息区提示事件
    set_LFGPlus()--预创建队伍增强

    LFGListInviteDialog:SetScript("OnHide", function(self)--LFG,,自动接受邀请
        if self.LFGListInviteDialogTimer and not self.LFGListInviteDialogTimer:IsCancelled() then
            self.LFGListInviteDialogTimer:Cancel()
        end
    end)
    LFGListInviteDialog:SetScript("OnShow", set_LFGListInviteDialog)--队伍查找器, 自动接受邀请
    
    hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", set_LFGListApplicationViewer_UpdateApplicantMember)--自动清邀请, 队伍查找器, LFGList.lua

    StaticPopup1:SetScript('OnHide', function(self)--被邀请, 对话框, 取消记时器
        if self.InvTimer and not self.InvTimer:IsCancelled() then
            self.InvTimer:Cancel()
        end
        notInviterGUID=nil
    end)

    StaticPopupDialogs["PARTY_INVITE"].button3= '|cff00ff00'..ALWAYS..'|r'..DECLINE..'|r'--添加总是拒绝按钮
    StaticPopupDialogs["PARTY_INVITE"].OnAlt=function()
        if notInviterGUID then
            if Save.InvNoFriend[notInviterGUID] then
                Save.InvNoFriend[notInviterGUID] =nil
                print(id, addName, '|cnRED_FONT_COLOR:'..REMOVE..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..DECLINE..'|r'..INVITE)
                AcceptGroup()
                StaticPopup_Hide("PARTY_INVITE");
            else
                Save.InvNoFriend[notInviterGUID] =Save.InvNoFriend[notInviterGUID] and Save.InvNoFriend[notInviterGUID]+1 or 1
                Save.InvNoFriendNum=Save.InvNoFriendNum+1;
                DeclineGroup();
                StaticPopup_Hide("PARTY_INVITE");
                print(id,addName, '|cnGREEN_FONT_COLOR:'..ADD..'|r', e.PlayerLink(nil, notInviterGUID) or '', '|cnRED_FONT_COLOR:'..DECLINE..'|r'..INVITE)
            end
        end
    end

    
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:RegisterEvent('GROUP_LEFT')
panel:RegisterEvent('GROUP_ROSTER_UPDATE')

panel:RegisterEvent('PARTY_INVITE_REQUEST')
panel:RegisterEvent('PLAYER_UPDATE_RESTING')----休息区提示

panel:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        setTexture()--设置图标颜色, 是否有权限

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
    end
end)
