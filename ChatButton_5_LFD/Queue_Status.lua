--小眼睛, 更新信息

local function Save()
    return WoWToolsSave['ChatButton_LFD'] or {}
end
local Button

















local function get_InviteButton_Frame(index)
    local frame= Button.lfgTextTab[index]
    if not frame then
        local size=16
        frame= CreateFrame("Frame", nil, Button)
        frame:SetSize(20,20)
        if index==1 then
            frame:SetPoint('TOPLEFT', Button.text, 'BOTTOMLEFT')
        else
            frame:SetPoint('TOPLEFT', Button.lfgTextTab[index-1], 'BOTTOMLEFT')
        end


        frame.InviteButton= WoWTools_ButtonMixin:Cbtn(frame, {size=20, atlas='common-icon-checkmark'})
        frame.InviteButton:SetAllPoints()
        --frame.InviteButton:SetPoint('TOPLEFT')
        frame.InviteButton.Size=20

        frame.InviteButton:SetScript('OnClick', function(self2)
            if ( not IsInRaid(LE_PARTY_CATEGORY_HOME)
                and (GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + self2:GetParent().numMembers + C_LFGList.GetNumInvitedApplicantMembers()) > (MAX_PARTY_MEMBERS + 1) )
            then
                local dialog = StaticPopup_Show("LFG_LIST_INVITING_CONVERT_TO_RAID")
                if ( dialog ) then
                    dialog.data = self2:GetParent().applicantID
                end
            else
                C_LFGList.InviteApplicant(self2:GetParent().applicantID)
            end
        end)
        frame.InviteButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.InviteButton:SetScript('OnEnter', function(self2)
            GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(self2:GetParent().applicantID, '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '邀请' or INVITE))
            GameTooltip:AddLine(self2:GetParent().tooltip)
            GameTooltip:Show()
        end)

        frame.ChatButton= WoWTools_ButtonMixin:Cbtn(frame, {size=size, atlas='transmog-icon-chat'})
        frame.ChatButton:SetPoint('BOTTOMLEFT', frame.InviteButton, 'BOTTOMRIGHT')
        frame.ChatButton:SetScript('OnClick', function(self2)
            WoWTools_ChatMixin:Say(nil, self2:GetParent().name)
        end)
        frame.ChatButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.ChatButton:SetScript('OnEnter', function(self2)
            GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine( self2:GetParent().name, WoWTools_DataMixin.onlyChinese and '/密语' or SLASH_SMART_WHISPER2)
            GameTooltip:AddLine(self2:GetParent().tooltip)
            GameTooltip:Show()
        end)



        frame.DeclineButton= WoWTools_ButtonMixin:Cbtn(frame, {size=size, atlas='communities-icon-redx'})
        frame.DeclineButton:SetPoint('BOTTOMLEFT', frame.ChatButton, 'BOTTOMRIGHT')
        frame.DeclineButton:SetScript('OnClick', function(self2)
            --C_LFGList.RemoveApplicant(self2:GetParent().applicantID)
            C_LFGList.DeclineApplicant(self2:GetParent().applicantID)
        end)
        frame.DeclineButton:SetScript('OnLeave', GameTooltip_Hide)
        frame.DeclineButton:SetScript('OnEnter', function(self2)
            GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine( self2:GetParent().applicantID, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '拒绝' or DECLINE))
            GameTooltip:AddLine(self2:GetParent().tooltip)
            GameTooltip:Show()
        end)

        frame.text= WoWTools_LabelMixin:Create(frame, {size=Save().tipsFrameTextSize, color=true})
        frame.text:SetPoint('BOTTOMLEFT', frame.DeclineButton, 'BOTTOMRIGHT')

        Button.lfgTextTab[index]= frame
    end
    return frame
end










local function set_tipsFrame_Tips(text, LFGListTab)
    Button.text:SetText(text or '')
    Button:SetShown(text and true or false)

    table.sort(LFGListTab, function(a, b)
        if a.index== b.index then
            return a.itemLevel> b.itemLevel
        else
            return a.index< b.index
        end
    end)
    for index, tab in pairs(LFGListTab) do
        local frame= get_InviteButton_Frame(index)
        frame.text:SetText((index<10 and ' ' or '')..index..') '..tab.text)
        frame:SetHeight(frame.text:GetHeight()+6)
        frame.applicantID= tab.applicantID
        frame.numMembers= tab.numMembers
        frame.tooltip= tab.text
        frame.name= tab.name
        frame:SetShown(true)
    end

    for index= #LFGListTab+1, #Button.lfgTextTab do
        Button.lfgTextTab[index].text:SetText('')
        Button.lfgTextTab[index]:SetShown(false)
    end



    WoWTools_LFDMixin.LFDButton.leaveInstance:SetShown(Save().leaveInstance)--自动离开,指示图标
end












local function get_Status_Text(status)--列表，状态，信息
    return status=='queued' and ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '在队列中' or BATTLEFIELD_QUEUE_STATUS)..'|r')
        or status=='confirm' and ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '就绪' or READY)..'|r')
        or status=='active' and ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '激活' or SPEC_ACTIVE)..'|r')
        or status=='proposal' and ('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '准备进入' or QUEUED_STATUS_PROPOSAL)..'|r')
        or status=='error' and ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '错误' or ERRORS)..'|r')
        or status=='none' and ('|cnYELLOW_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无' or NONE)..'|r')
        or status=='suspended' and ('|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '暂停' or QUEUED_STATUS_SUSPENDED)..'|r')
        or status or ''
end

















local function Set_Queue_Status()--小眼睛, 信息
    if Save().hideQueueStatus then--列表信息 
        set_tipsFrame_Tips(nil, {})
       return
    end

    local isLeader= LFGListUtil_IsEntryEmpowered()
    local text
    local num= 0
    local pve
    for i=1, NUM_LE_LFG_CATEGORYS do--PVE
        local listNum, listText= WoWTools_LFDMixin:GetQueuedList(i, true, true)
        if listNum and listText then
            listText= listText:gsub('|n', '|n ')
            pve= pve and pve..'|n' or ''
            pve= pve..' '..listText
            pve= pve..' '
            num= num+ listNum
        end
    end
    if pve then
        local _, tank, healer, dps= GetLFGRoles()--检测是否选定角色pve
        text= text and text..'|n' or ''
        text= text..'|A:groupfinder-icon-friend:0:0|a|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and 'PVE' or TRANSMOG_SET_PVE)..'|r'
                ..(tank and INLINE_TANK_ICON or '')
                ..(healer and INLINE_HEALER_ICON or '')
                ..(dps and INLINE_DAMAGER_ICON or '')
                ..' '
        text= text..'|n'..pve..' '
    end

    local pvp
    for i=1, GetMaxBattlefieldID() do --PVP
        local status, mapName, teamSize, _, suspendedQueue, queueType, _, role = GetBattlefieldStatus(i)
        if status and mapName then
            pvp= pvp and pvp..'|n' or ''
            pvp= pvp..'   '..i..') '
                ..WoWTools_TextMixin:CN(mapName)..(queueType and ' ('..queueType..')')
                ..(status~='queued' and ' '..get_Status_Text(status) or '')
                ..(teamSize and teamSize>0 and ' '..teamSize or '')
                ..(suspendedQueue and ('|cnRED_FONT_COLOR: ['..(WoWTools_DataMixin.onlyChinese and '暂停' or QUEUED_STATUS_SUSPENDED)..']|r') or '')
                ..(WoWTools_DataMixin.Icon[role] or '')
                ..' '.. WoWTools_TimeMixin:SecondsToClock(GetBattlefieldTimeWaited(i) / 1000)
                ..' '
        end
    end
    if pvp then
        local tank, healer, dps = GetPVPRoles()
        text= text and text..'|n' or ''
        text= text..'|A:honorsystem-icon-prestige-6:0:0|a|cnGREEN_FONT_COLOR:PvP|r'
            ..(tank and INLINE_TANK_ICON or '')
            ..(healer and INLINE_HEALER_ICON or '')
            ..(dps and INLINE_DAMAGER_ICON or '')
            ..' '
        text= text..'|n'..pvp
    end


    local queueState, _, queuedTime= C_PetBattles.GetPVPMatchmakingInfo() --PET
    if queueState then
        local pet= '|A:worldquest-icon-petbattle:0:0|a|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '宠物对战' or PET_BATTLE_PVP_QUEUE)..'|r'
        if queuedTime then
            pet= pet..' '..WoWTools_TimeMixin:Info(queuedTime, true)
        end
        if queueState~='queued' then
            pet= pet..' '..get_Status_Text(queueState)
        end

        pet= pet..' '
        local abilityID
        for slotIndex= 1, 3 do
            local tab= {C_PetJournal.GetPetLoadOutInfo(slotIndex)}--petID, ability1, ability2, ability3 = C_PetJournal.GetPetLoadOutInfo(slotIndex)
            local petID= tab[1]
            if petID then
                local _, _, level, _, _, _, _, _, icon = C_PetJournal.GetPetInfoByPetID(petID)
                if icon then
                    level= level or 1
                    pet= pet..'|n   '..slotIndex..') '
                        ..'|T'..icon..':0|t'
                        ..' '..(level<25 and '|cnRED_FONT_COLOR:'..level..'|r' or level)
                    for index= 2, 4 do
                        abilityID= tab[index]
                        abilityID= abilityID and tonumber(abilityID)
                        if abilityID then
                            local abilityIcon= select(2, C_PetJournal.GetPetAbilityInfo(abilityID))
                            if abilityIcon then
                                pet= pet..(index==2 and ' ' or '')..'|T'..abilityIcon..':0|t'
                            end
                        end
                    end
                    pet= pet..' '
                end
            end
        end
        text= text and text..'|n' or ''
        text= text..pet
    end

    local lfg--LFG，申请，列表
    local LFGTab= C_LFGList.GetApplications() or {}
    for index, applicantID in pairs(LFGTab) do
        local _, appStatus, _, appDuration, role = C_LFGList.GetApplicationInfo(applicantID)-- id, appStatus, pendingStatus, appDuration, role 
        if appStatus == "applied"  and appDuration and appDuration>0 then--invited,none
            local info = C_LFGList.GetSearchResultInfo(applicantID) or {}

            if info and info.activityID and info.name and not info.autoAccept and not info.isDelisted then

                local pvpRating--PVP分数
                local pvpIcon
                if info.leaderPvpRatingInfo then
                    if info.leaderPvpRatingInfo.tier and info.leaderPvpRatingInfo.tier>0 then
                        pvpIcon= ('|A:honorsystem-icon-prestige-'..info.leaderPvpRatingInfo.tier..':0:0|a')
                    elseif info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating> 0 then
                        pvpIcon= '|A:pvptalents-warmode-swords:0:0|a'
                    end
                    if info.leaderPvpRatingInfo.rating and info.leaderPvpRatingInfo.rating> 0 then
                        pvpRating= info.leaderPvpRatingInfo.rating
                    end
                end

                local numMembers--人数
                if info.numMembers and info.numMembers>0 then
                    numMembers= ' |A:socialqueuing-icon-group:0:0|a'..info.numMembers--..(WoWTools_DataMixin.onlyChinese and '队员' or PLAYERS_IN_GROUP)
                    local friendly
                    if info.numBNetFriends and info.numBNetFriends>0 then
                        friendly = (friendly and friendly..' ' or '')..info.numBNetFriends..WoWTools_DataMixin.Icon.wow2
                    end
                    if info.numCharFriends and info.numCharFriends>0 then
                        friendly = (friendly and friendly..' ' or '')..info.numCharFriends..'|A:recruitafriend_V2_tab_icon:0:0|a'
                    end
                    if info.numGuildMates and info.numGuildMates>0 then
                        friendly = (friendly and friendly..' ' or '')..info.numGuildMates..'|A:communities-guildbanner-background:0:0|a'
                    end
                    if friendly then
                        numMembers= numMembers..' ('..friendly..')'
                    end
                end

                local factionText--指定，派系 info.crossFactionListing
                if info.leaderFactionGroup==0 and WoWTools_DataMixin.Player.Faction=='Alliance' then
                    factionText= format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.Horde)
                elseif info.leaderFactionGroup==1 and WoWTools_DataMixin.Player.Faction=='Horde' then
                    factionText= format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.NONE)
                end

                local roleText--职责
                if role~='NONE' then
                    roleText= WoWTools_DataMixin.Icon[role]
                end

                local activityName = C_LFGList.GetActivityFullName(info.activityID, nil, info.isWarMode)

                lfg= lfg and lfg..'\n   ' or '   '
                lfg= lfg..index..') '..WoWTools_TextMixin:CN(info.name)
                    ..' '.. (WoWTools_TextMixin:CN(activityName) or '')
                    ..(numMembers or '')
                    ..(info.leaderOverallDungeonScore and info.leaderOverallDungeonScore>0 and ' '..WoWTools_ChallengeMixin:KeystoneScorsoColor(info.leaderOverallDungeonScore, true) or '')
                    ..(pvpIcon or '')
                    ..(pvpRating or '')
                    ..(info.questID and '|A:AutoQuest-Badge-Campaign:0:0|a' or '')
                    ..(info.isWarMode and '|A:pvptalents-warmode-swords:0:0|a' or '')
                    ..(factionText or '')
                    ..(roleText or '')
                    ..' '..WoWTools_TimeMixin:SecondsToClock(appDuration)--过期，时间
                    ..' '
            end

        end
    end
    if lfg then
        text= text and text..'|n' or ''
        text= text..'|A:charactercreate-icon-dice:0:0|a|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已登记' or QUEUED_STATUS_SIGNED_UP)..'|r #'..#LFGTab
        text= text..'|n'..lfg
    end

    --已激活LFG
    local LFGListTab= {}
    if C_LFGList.HasActiveEntryInfo() then
        local list
        local info= C_LFGList.GetActiveEntryInfo()

        if info and info.name then
            local applicants =C_LFGList.GetApplicants() or {}--申请人数
            local applicantsNum= #applicants

            local member
            if not info.autoAccept and applicantsNum>0 then
                local n=0
                for _, applicantID in pairs(applicants) do
                    local applicantInfo = C_LFGList.GetApplicantInfo(applicantID)
                    if applicantInfo and applicantInfo.numMembers and applicantInfo.applicationStatus=='applied' then
                        local memberText
                        local roleIndex= 3
                        local unitItemLevel= 0
                        local leaderName
                        for index=1 , applicantInfo.numMembers do
                            local name, class, _, level, itemLevel, honorLevel, tank, healer, dps, _, _, dungeonScore, pvpItemLevel= C_LFGList.GetApplicantMemberInfo(applicantID, index)
                            local icon= WoWTools_UnitMixin:GetClassIcon(nil, nil, class)
                            if icon and name and class then
                                local col= '|c'..select(4, GetClassColor(class))--颜色

                                local levelText--等级
                                if level and level~=MAX_PLAYER_LEVEL then
                                    levelText=' |cnRED_FONT_COLOR:'..level..'|r'
                                end

                                local itemLevelText--装等/PVP装有情
                                if  itemLevel and itemLevel>20 then
                                    itemLevelText= format('%i',itemLevel)
                                    if pvpItemLevel and pvpItemLevel-itemLevel>9 then
                                        itemLevelText= itemLevelText..'/'..format('%i', pvpItemLevel)
                                    end
                                end

                                local realmText--服务器，名称
                                local realm= name:match('%-(.+)')
                                if realm then
                                    local realmTab = WoWTools_RealmMixin:Get_Region(realm)
                                    if realmTab and realmTab.col then
                                        realmText= ' '..name ..' '..realmTab.col
                                    else
                                        realmText= name
                                    end
                                end

                                local scorsoText= WoWTools_ChallengeMixin:KeystoneScorsoColor(dungeonScore, false) or ''--挑战分数，荣誉等级
                                if honorLevel and honorLevel>1 then
                                    scorsoText= scorsoText~='' and scorsoText..' ' or scorsoText
                                    scorsoText= scorsoText..'|A:pvptalents-warmode-swords:0:0|a'..honorLevel
                                    scorsoText=' ['..scorsoText..']'
                                end

                                memberText= memberText and memberText..(isLeader and '|n     ' or '|n          ') or ''
                                memberText= memberText..col

                                    ..(itemLevelText or '')
                                    ..scorsoText

                                    ..(WoWTools_UnitMixin:GetIsFriendIcon(nil, nil, name) or '')
                                    ..icon
                                    ..(tank and INLINE_TANK_ICON or '')
                                    ..(healer and INLINE_HEALER_ICON or '')
                                    ..(dps and INLINE_DAMAGER_ICON or '')


                                    ..(levelText or '')
                                    ..(realmText or '')
                                    ..'|r '

                                local roleIndex2= tank and 1 or healer and 2 or 3--索引
                                roleIndex= roleIndex< roleIndex2 and roleIndex2 or roleIndex
                                if index==1 then
                                    leaderName= name
                                end
                                if itemLevel then--物品等级
                                    unitItemLevel= itemLevel> unitItemLevel and itemLevel or unitItemLevel
                                end
                            end
                        end
                        if memberText and isLeader then--队长, 内容
                            table.insert(LFGListTab, {
                                text= memberText,
                                applicantID= applicantID,
                                index= roleIndex,
                                itemLevel= unitItemLevel,
                                numMembers= applicantInfo.numMembers,
                                name= leaderName,
                            })
                            n=n+1
                            member= member and member..'|n' or ''
                            member= member..'      '.. (n<10 and ' '..n or n)..')'..memberText
                        end
                    end
                end
            end

            local name2= info.activityID and C_LFGList.GetActivityFullName(info.activityID)--名称
            list= '   '..info.name--名称
                ..' |cFF00FF00#'..applicantsNum..'|r'--数量
                ..(info.autoAccept and '|A:runecarving-icon-reagent-empty:0:0|a' or '')--自动邀请
                ..(name2 and ' '..name2 or '')--名称
                ..(info.privateGroup and  (WoWTools_DataMixin.onlyChinese and '私人' or LFG_LIST_PRIVATE) or '')--私人
                ..(info.duration and  ' '..WoWTools_TimeMixin:SecondsToClock(info.duration) or '')--时间

            if member and not isLeader then--不是队长, 显示, 内容
                list= list..'|n'..member
            end
        end
        if list then
            text= (text and text..'|n' or '')
            ..(LFGListUtil_IsEntryEmpowered() and WoWTools_DataMixin.Icon.Player or '|A:auctionhouse-icon-favorite:0:0|a')
            ..(WoWTools_DataMixin.onlyChinese and '招募' or RAF_RECRUITMENT)..(info.autoAccept and ' ('..(WoWTools_DataMixin.onlyChinese and '自动加入' or AUTO_JOIN)..')' or '')
            ..'|n'..list
        end
    end

    set_tipsFrame_Tips(text, LFGListTab)
end













local function Init_Menu(self, root)
    local sub
--队伍查找器
    root:CreateButton(
        MicroButtonTooltipText('队伍查找器', "TOGGLEGROUPFINDER"),
    function ()
        WoWTools_Mixin:Call(PVEFrame_ToggleFrame)
        return MenuResponse.Open
    end)

--离开所有队列
    root:CreateDivider()
    sub=root:CreateButton(
        WoWTools_DataMixin.onlyChinese and '离开所有队列' or LEAVE_ALL_QUEUES,
    function()
        WoWTools_LFDMixin:Leave_All_LFG()
    end)
    sub:SetEnabled(UnitIsGroupLeader("player"))

    root:CreateDivider()
--打开选项界面
    sub= WoWTools_MenuMixin:OpenOptions(root, {
        name=WoWTools_LFDMixin.addName,
        category=WoWTools_ChatMixin.Category
    })


--FrameStrata
    WoWTools_MenuMixin:FrameStrata(sub, function(data)
        return self:GetFrameStrata()==data
    end, function(data)
        Save().queueStatusStrata= data
        self:set_strata()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().tipsScale or 1
    end, function(value)
        Save().tipsScale= value
        self:set_scale()
    end)

    sub:CreateDivider()
--重置位置
    WoWTools_MenuMixin:RestPoint(self, sub, Save().tipsFramePoint, function()
        Save().tipsFramePoint=nil
        self:set_Point()
        return MenuResponse.Open
    end)
end














local function Init()
    Button= WoWTools_ButtonMixin:Cbtn(nil, {
        size=23,
        atlas='UI-HUD-MicroMenu-Groupfinder-Mouseover',
        name='WoWToolsChatToolsLFDTooltipButton'
    })

    function Button:set_Point()
        self:ClearAllPoints()
        if Save().tipsFramePoint then
            Button:SetPoint(Save().tipsFramePoint[1], UIParent, Save().tipsFramePoint[3], Save().tipsFramePoint[4], Save().tipsFramePoint[5])
        else
            Button:SetPoint('BOTTOMLEFT', WoWTools_LFDMixin.LFDButton, 'TOPLEFT',0, 4)
        end
    end

    function Button:set_strata()
        self:SetFrameStrata(Save().queueStatusStrata or 'MEDIUM')
    end

    function Button:set_scale()
        self.text:SetScale(Save().tipsScale or 1)
    end

    function Button:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_LFDMixin.addName, WoWTools_DataMixin.onlyChinese and '列表信息' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SOCIAL_QUEUE_TOOLTIP_HEADER, INFO))
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end

    Button:SetScript("OnDragStart", function(self, d)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    Button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().tipsFramePoint={self:GetPoint(1)}
            Save().tipsFramePoint[2]=nil
        end
    end)

    Button:SetScript("OnMouseDown", function(self, d)
        if d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        else
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
        self:set_tooltip()
    end)
    Button:SetScript('OnMouseUp', ResetCursor)

    Button:SetScript("OnLeave", function()
        GameTooltip:Hide()
        ResetCursor()
        WoWTools_LFDMixin.LFDButton:SetButtonState('NORMAL')
    end)
    Button:SetScript('OnEnter', function(self)
        self:set_tooltip()
        Set_Queue_Status()--小眼睛, 更新信息
        WoWTools_LFDMixin.LFDButton:SetButtonState('PUSHED')
    end)



    Button.text= WoWTools_LabelMixin:Create(Button, {size=Save().tipsFrameTextSize, color=true})--Save().tipsFrameTextSize, nil, nil, true)
    Button.text:SetPoint('BOTTOMLEFT', Button, 'BOTTOMRIGHT')

    Button.lfgTextTab= {}
    Button.lfgTextTab[1]= get_InviteButton_Frame(1)


    Button:set_Point()
    Button:set_scale()--设置, 缩放
    Button:set_strata()
    Button:RegisterForDrag("RightButton")
    Button:SetMovable(true)
    Button:SetClampedToScreen(true)

end




















function WoWTools_LFDMixin:Set_Queue_Status()
    Set_Queue_Status()
end
function WoWTools_LFDMixin:Init_Queue_Status()
    Init()
    hooksecurefunc(QueueStatusFrame, 'Update', Set_Queue_Status)--小眼睛, 更新信息, QueueStatusFrame.luaend
end