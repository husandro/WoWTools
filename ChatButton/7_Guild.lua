
local id, e = ...
local Save={}
local addName
local GuildButton
local panel= CreateFrame("Frame")

--#######
--在线人数
--#######
local function set_Guild_Members()
    local online=1
    if GuildButton and IsInGuild() then
        online = select(2, GetNumGuildMembers()) or 0
    end
    GuildButton.membersText:SetText(online>1 and online-1 or '')
end

--#######
--公会信息
--#######
local guildMS= GUILD_INFO_TEMPLATE:gsub('(%%.+)', '')--公会创立
local function set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    if not IsInGuild() then
        if e.WoWDate[e.Player.guid] then
            e.WoWDate[e.Player.guid].GuildInfo=nil
        end
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    else
        if Save.guildInfo or not e.WoWDate[e.Player.guid].GuildInfo then
            panel:RegisterEvent('CHAT_MSG_SYSTEM')
            GuildInfo()
        else
            panel:UnregisterEvent('CHAT_MSG_SYSTEM')
        end
    end
end
















--#############
--欢迎加入, 信息
--#############
local function setMsg_CHAT_MSG_SYSTEM(text)
    if text:find(guildMS) then
        e.WoWDate[e.Player.guid].GuildInfo= text
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    end
end















--###############
--自动选取当前专精
--###############
local function set_RequestToJoinFrame(frame)
    local text
    local edit= frame.MessageFrame.MessageScroll.EditBox
    local avgItemLevel, _, avgItemLevelPvp = GetAverageItemLevel()
    if avgItemLevel then
        local cd= e.Player.region==1 or e.Player.region==3
        text= format(cd and 'Level %d' or UNIT_LEVEL_TEMPLATE, UnitLevel('player') or 0)
        text= text..'|n' ..format((cd and 'Item' or ITEMS)..' %d', avgItemLevel or 0)
        text= text..'|n'..format('PvP %d', avgItemLevelPvp or 0)--PvP物品等级 %d
        local data= C_PlayerInfo.GetPlayerMythicPlusRatingSummary('player') or {}
        if data.currentSeasonScore then
            text= text..'|n'..(cd and 'Challenge' or PLAYER_DIFFICULTY5)..' '..data.currentSeasonScore
        end
        edit:SetText(text)
    end


    local text2
    if frame.SpecsPool then--专精，职责，图标，自动选取当前专精
        local _, name, _, icon, role
        local currSpecID= GetSpecializationInfo(GetSpecialization() or 0)

        for btn in frame.SpecsPool:EnumerateActive() do
            local check= not currSpecID or currSpecID==btn.specID
            local box= btn.Checkbox or btn.CheckBox
            if box then
                if check and not box:GetChecked() then
                    box:Click()--自动选取当前专精
                end
                _, name, _, icon, role= GetSpecializationInfoByID(btn.specID)
                if name then
                    name= '|T'..(icon or 0)..':0|t'..(e.Icon[role] or '')..e.cn(name)
                    if check then
                        text2= (text2 and text2..', ' or '').. name
                    end
                    btn.SpecName:SetText(name)
                end
            end
        end
    end
    if frame.Apply and frame.Apply:IsEnabled() and frame.Apply.Click
        and not IsModifierKeyDown()
        and not Save.notAutoRequestToJoinClub
    then
        print(e.addName, addName, frame.ClubName:GetText(), e.cn(frame.Apply:GetText()), '|n', text, '|n|cffff00ff',text2)
        frame.Apply:Click()
    end
end

--####################
--设置，自动申请，check
--####################
local function set_check(frame)
    local check= CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint('RIGHT', frame, 'LEFT', 0, 12)
    check:SetChecked(not Save.notAutoRequestToJoinClub)
    check:SetScript('OnClick', function()
        Save.notAutoRequestToJoinClub= not Save.notAutoRequestToJoinClub and true or nil
    end)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '自动申请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SIGN_UP))..e.Icon.left, e.GetEnabeleDisable(not Save.notAutoRequestToJoinClub))
        e.tips:Show()
    end)
    check:SetScript('OnShow', function(self2)
        self2:SetChecked(not Save.notAutoRequestToJoinClub)
    end)
end



















--主菜单
local function Init_Menu(_, root)
    local sub, text

--公会在线列表
    local total, online = GetNumGuildMembers()
    if online>1 then
        local map=WoWTools_MapMixin:GetUnit('paleyr')
        local maxLevel= GetMaxLevelForLatestExpansion()
        for index=1, total, 1 do
            local name, _, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and isOnline and guid~=e.Player.guid then
                text=status==1 and format('|T:%s:0|t', FRIENDS_TEXTURE_AFK) or status==2 and format('|T:%s:0|t', FRIENDS_TEXTURE_DND) or ''
                if rankIndex ==0 then
                    text= text..'|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t'
                elseif rankIndex == 1 then
                    text= text..'|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t'
                end

                text=text..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})
                text=(lv and lv~=maxLevel) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
                if zone and zone==map then--地区
                    text= text..'|A:poi-islands-table:0:0|a'
                end
               -- text= rankName and text..' '..rankName..(rankIndex or '') or text


                sub=root:CreateButton(text, function(data)
                    WoWTools_ChatMixin:Say(nil, data.name)
                    return MenuResponse.Open
                end, {publicNote=publicNote, officerNote=officerNote, name=name, zone=zone})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine((e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..' '..SLASH_WHISPER1..' '..description.data.name)
                    tooltip:AddLine(' ')                    
                    tooltip:AddLine(description.data.zone)
                    tooltip:AddLine(description.data.publicNote)
                    tooltip:AddLine(description.data.officerNote)
                end)
            end
        end
        root:CreateDivider()
        WoWTools_MenuMixin:SetScrollMode(root)
    end

    if CanReplaceGuildMaster() then--弹劾
        sub=root:CreateButton(e.onlyChinese and '弹劾' or GUILD_IMPEACH_POPUP_CONFIRM, ToggleGuildFrame)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '你所在公会的领袖已被标记为非活动状态。你现在可以争取公会领导权。是否要移除公会领袖？' or GUILD_IMPEACH_POPUP_TEXT, nil,nil,nil, true)
        end)
        root:CreateDivider()
    end

    sub=root:CreateCheckbox(e.onlyChinese and '公会信息' or GUILD_INFORMATION, function()
        return Save.guildInfo
    end, function()
        Save.guildInfo= not Save.guildInfo and true or nil
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine()
        tooltip:AddLine(e.WoWDate[e.Player.guid].GuildInfo)
    end)


end
























--[[
btn.background= btn:CreateTexture(nil, 'BACKGROUND')
btn.background:SetAllPoints(btn)
btn.background:SetAtlas('bag-reagent-border-empty')
btn.background:SetAlpha(0.5)
btn.background:AddMaskTexture(btn.mask)

btn.texture=btn:CreateTexture(nil, 'BORDER')
btn.texture:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
btn.texture:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -6, 6)
btn.texture:AddMaskTexture(btn.mask)

btn.border=btn:CreateTexture(nil, 'ARTWORK')
btn.border:SetAllPoints(btn)
btn.border:SetAtlas('bag-reagent-border')
]]


--####
--初始
--####
--local data=  C_GuildInfo.GetGuildTabardInfo('player')

    --[[GuildButton.background2= GuildButton:CreateTexture(nil, 'BACKGROUND', nil, 2)
    GuildButton.background2:SetAllPoints()
    GuildButton.background2:SetAtlas('UI-Achievement-Guild-Flag-Short')
    GuildButton.background2:AddMaskTexture(GuildButton.mask)]]
    
    --[[GuildButton.border2= GuildButton:CreateTexture(nil, 'BORDER', nil, 2)
    GuildButton.border2:SetAllPoints()
    GuildButton.border2:SetAtlas('UI-Achievement-Guild-Flag-Short')
    GuildButton.border2:AddMaskTexture(GuildButton.mask)]]
    
local function Init()
    GuildButton.membersText=WoWTools_LabelMixin:Create(GuildButton, {color={r=1,g=1,b=1}})-- 10, nil, nil, true, nil, 'CENTER')
    GuildButton.membersText:SetPoint('TOPRIGHT', -3, 0)

    function GuildButton:settings()
        if IsInGuild() then--GuildUtil.lua
            self.texture:ClearAllPoints()
            self.texture:SetPoint('CENTER', -1.5, 1)
            self.texture:SetSize(18,18)

            SetSmallGuildTabardTextures(
                'player',
                self.texture,
                nil,--self.background2,
                nil,--self.border,
                C_GuildInfo.GetGuildTabardInfo('player')
            )
        else
            GuildButton.texture:SetAtlas('UI-HUD-MicroMenu-GuildCommunities-Up')
        end
        set_Guild_Members()--在线人数
    end

    GuildButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:state_leave()
    end)
    GuildButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if not IsInGuild() then
            e.tips:AddLine('|cff9e9e9e'..(e.onlyChinese and '无公会' or ITEM_REQ_PURCHASE_GUILD))
        end
        e.Get_Guild_Enter_Info()--公会， 社区，信息
        e.tips:Show()
        self:state_enter()--Init_Menu)
        if IsInGuild() then
            C_GuildInfo.GuildRoster()
        end
    end)

    GuildButton:SetScript('OnClick', function(self, d)
        if not IsInGuild() then
            ToggleGuildFrame()
        else
            if d=='LeftButton' then
                WoWTools_ChatMixin:Say('/g')
            else
                if IsInGuild() then
                    MenuUtil.CreateContextMenu(self, Init_Menu)
                    e.tips:Hide()
                else
                    ToggleGuildFrame()
                end
            end
        end
    end)  

    if not IsVeteranTrialAccount() then--试用帐号
        set_check(ClubFinderGuildFinderFrame.OptionsList.SearchBox)
        set_check(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)
        hooksecurefunc(ClubFinderGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_RequestToJoinFrame)
        hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_RequestToJoinFrame)
    end


    hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, 'SetScrollTargetOffset', function(self)
        if not self:GetView() then
            return
        end
        for _, btn in pairs(self:GetFrames() or {}) do
            local online, all= 0, 0
            if btn.clubId then
                local members= C_Club.GetClubMembers(btn.clubId) or {}
                all= #members
                for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
                    local info = C_Club.GetMemberInfo(btn.clubId, memberID) or {}
                    if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                        online= online+1
                    end
                end
            end
            if not btn.onlineText then
                btn.onlineText=WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
                btn.onlineText:SetPoint('TOP', btn.Icon, 'BOTTOM')
            end
            if all>0 then
                btn.onlineText:SetFormattedText('%d/%s%d|r', all, online==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:', online)
            else
                btn.onlineText:SetText('')
            end
        end
    end)


    C_Timer.After(2, function()
        if IsInGuild()then
            if CanReplaceGuildMaster() then--弹劾
                local label= WoWTools_LabelMixin:Create(GuildButton, {size=10, color=true, justifyH='CENTER'})
                label:SetPoint('TOP')
                label:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '弹劾' or  WoWTools_TextMixin:sub(GUILD_IMPEACH_POPUP_CONFIRM, 2, 5,true))..'|r')
            end
        else
            GuildButton:settings()
        end

        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    end)
end



















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave['ChatButtonGuild'] or Save
            addName= '|A:UI-HUD-MicroMenu-GuildCommunities-Up:0:0|a'..(e.onlyChinese and '公会' or GUILD)
            GuildButton= WoWTools_ChatButtonMixin:CreateButton('Guild', addName)

            if GuildButton then--禁用Chat Button
                Init()
                self:RegisterEvent('GUILD_ROSTER_UPDATE')
                self:RegisterEvent('PLAYER_GUILD_UPDATE')
            end
            self:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['ChatButtonGuild']=Save
        end

    elseif event=='GUILD_ROSTER_UPDATE' or event=='PLAYER_GUILD_UPDATE' then
        GuildButton:settings()


    elseif event=='CHAT_MSG_SYSTEM' then
        setMsg_CHAT_MSG_SYSTEM(arg1)--欢迎加入, 信息

    elseif event=='PLAYER_GUILD_UPDATE' then
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
        set_Guild_Members()
    end
end)