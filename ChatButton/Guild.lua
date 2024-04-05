
local id, e = ...
local Save={}
local addName='ChatButtonGuild'
local button
local panel= CreateFrame("Frame")

--#######
--在线人数
--#######
local function set_Guild_Members()
    local num = select(2, GetNumGuildMembers())
    num = (num and num>1) and num-1 or nil
    if not button.membersText and num then
        button.membersText=e.Cstr(button, {size=10, color=true, justifyH='CENTER'})-- 10, nil, nil, true, nil, 'CENTER')
        button.membersText:SetPoint('BOTTOM', 0, 7)
    end
    if button.membersText then
        button.membersText:SetText(num or '')
    end
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
local function set_RequestToJoinFrame(self)
    local text
    if self.MessageFrame and self.MessageFrame.MessageScroll and self.MessageFrame.MessageScroll.EditBox then
        local avgItemLevel, _, avgItemLevelPvp = GetAverageItemLevel()
        if avgItemLevel then
            local cd= e.Player.region==1 or e.Player.region==3--1US(includes Brazil and Oceania) 2Korea 3Europe (includes Russia) 4Taiwan 5China
            text= format(cd and 'Item Level %d' or CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, avgItemLevel)
            if avgItemLevelPvp and avgItemLevelPvp- avgItemLevel>=10 then
                text= text..'|n'..format(cd and 'PvP Item Level %d' or ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT, avgItemLevelPvp)--PvP物品等级 %d
            end
            self.MessageFrame.MessageScroll.EditBox:SetText(text)
        end
    end

    local text2
    if self.SpecsPool and self.SpecsPool.activeObjects then--专精，职责，图标，自动选取当前专精
        local currSpecID= GetSpecializationInfo(GetSpecialization() or 0)
        for frame, _ in pairs(self.SpecsPool.activeObjects) do
            if frame.specID then
                local _, name, _, icon, role
                _, name, _, icon, role =GetSpecializationInfoByID(frame.specID)
                if frame.CheckBox and frame.CheckBox.Click and currSpecID== frame.specID then
                    frame.CheckBox:Click()--自动选取当前专精
                    text2= (icon and '|T'..icon..':0|t' or '')..(e.Icon[role] or '')..name
                end
                _, name, _, icon, role =GetSpecializationInfoByID(frame.specID)
                if name and frame.SpecName then
                    frame.SpecName:SetText((icon and '|T'..icon..':0|t' or '')..(e.Icon[role] or '')..name)
                end
            end
        end
    end
    if self.Apply and self.Apply:IsEnabled() and self.Apply.Click
        and not IsModifierKeyDown()
        and not Save.notAutoRequestToJoinClub
    then
        print(id, e.cn(addName), '|cnGREEN_FONT_COLOR:'..self.Apply:GetText()..'|r', text2, '|cffff00ff'..(text or ''))
        self.Apply:Click()
    end
end

--####################
--设置，自动申请，check
--####################
local function set_check(search)
    if not search then
        return
    end
    local w=search:GetHeight()
    search:SetWidth(search:GetWidth()- w)
    local point, relativeTo, relativePoint, offsetX, offsetY=search:GetPoint()
    search:ClearAllPoints()
    search:SetPoint(point, relativeTo, relativePoint, offsetX-(w/2), offsetY)
    local check= CreateFrame("CheckButton", nil, search, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint('LEFT', search, 'RIGHT',-2, -1)
    check:SetChecked(not Save.notAutoRequestToJoinClub)
    check:SetScript('OnClick', function()
        Save.notAutoRequestToJoinClub= not Save.notAutoRequestToJoinClub and true or nil
    end)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine('|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '自动申请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SIGN_UP)), e.GetEnabeleDisable(not Save.notAutoRequestToJoinClub))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
    end)
    check:SetScript('OnShow', function(self2)
        self2:SetChecked(not Save.notAutoRequestToJoinClub)
    end)
end


















--#####
--主菜单
--#####
local function InitMenu(_, level)--主菜单    
    local info
    local find
    local map=e.GetUnitMapName('paleyr')
    for index=1,  GetNumGuildMembers() do
        local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        if name and guid and isOnline and name~=e.Player.name_realm then
            find=true
            local text=e.GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})
            text=(lv and lv~=MAX_PLAYER_LEVEL) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
            if zone then--地区
                text= zone==map and text..e.Icon.map2 or text..' '..zone
            end
            text= rankName and text..' '..rankName..(rankIndex or '') or text
            info={
                text=text,
                notCheckable=true,
                colorCode= not IsInGuild() and '|cff606060' or nil,
                tooltipOnButton=true,
                tooltipTitle=publicNote or '',
                tooltipText=officerNote or '',
                icon= status==1 and FRIENDS_TEXTURE_AFK or status==2 and FRIENDS_TEXTURE_DND,
                arg1=name,
                keepShownOnClick=true,
                func=function(self2, arg1)
                    e.Say(nil, arg1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
    if find then
        e.LibDD:UIDropDownMenu_AddSeparator(level)
    end
    info={
        text=e.onlyChinese and '公会信息' or GUILD_INFORMATION,
        checked=Save.guildInfo,
        tooltipOnButton=true,
        tooltipTitle= e.WoWDate[e.Player.guid].GuildInfo or (e.onlyChinese and '无' or NONE),
        keepShownOnClick=true,
        func=function()
            Save.guildInfo= not Save.guildInfo and true or nil
            set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level)

    if CanReplaceGuildMaster() then--弹劾
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        e.LibDD:UIDropDownMenu_AddButton({
            text=e.onlyChinese and '弹劾' or GUILD_IMPEACH_POPUP_CONFIRM,
            isTitle=true,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '你所在公会的领袖已被标记为非活动状态。你现在可以争取公会领导权。是否要移除公会领袖？' or GUILD_IMPEACH_POPUP_TEXT,
        }, level)
    end
end




















--####
--初始
--####
local function Init()
    button= e.Cbtn2({
        name=nil,
        parent=WoWToolsChatButtonFrame,
        click=true,-- right left
        notSecureActionButton=true,
        notTexture=nil,
        showTexture=true,
        sizi=nil,
    })

    button:SetPoint('LEFT', WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=button

    set_Guild_Members()--在线人数
    button.texture:SetAtlas('UI-HUD-MicroMenu-GuildCommunities-Up')

    e.Set_Label_Texture_Color(button.texture, {type='Texture'})--设置颜色

    button:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            e.Say('/g')
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
            --ToggleGuildFrame()
        end
    end)

    if CanReplaceGuildMaster() then--弹劾
        local label= e.Cstr(button, {size=10, color=true, justifyH='CENTER'})
        label:SetPoint('TOP')
        label:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '弹劾' or  e.WA_Utf8Sub(GUILD_IMPEACH_POPUP_CONFIRM, 2, 5,true))..'|r')
    end


    C_Timer.After(2, set_CHAT_MSG_SYSTEM)--事件, 公会新成员, 队伍新成员
end



--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsChatButtonFrame.disabled then--禁用Chat Button
                Save= WoWToolsSave[addName] or Save
                Init()
                self:RegisterEvent('PLAYER_LOGOUT')
                self:RegisterEvent('GUILD_ROSTER_UPDATE')
                self:RegisterEvent('PLAYER_GUILD_UPDATE')
                --panel:RegisterUnitEvent('PLAYER_GUILD_UPDATE', "player")
            end

        elseif arg1=='Blizzard_Communities' then
            set_check(ClubFinderGuildFinderFrame.OptionsList.Search and ClubFinderGuildFinderFrame.OptionsList and ClubFinderGuildFinderFrame.OptionsList.Search)
            set_check(ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search and ClubFinderCommunityAndGuildFinderFrame.OptionsList and ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search)

            hooksecurefunc(ClubFinderGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_RequestToJoinFrame)
            hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_RequestToJoinFrame)

            --[[hooksecurefunc(CommunitiesFrame.MemberList.ScrollBox, 'Update', function(self)                
                for _, btn in pairs(self:GetFrames()) do
                    local info= btn.memberInfo or {}
                    if info.guid then
                        local name= e.GetPlayerInfo({guid=info.guid, reName=true, reRealm=true}):gsub('|A:UI-HUD-MicroMenu-GuildCommunities-Mouseover:0:0|a', '')
                        if name~='' then
                           -- btn.NameFrame.Name:SetText(name)
                        end
                    end
                end
            end)
            hooksecurefunc(CommunitiesMemberListEntryMixin, 'UpdatePresence', function(frame)
                frame:HookScript('OnClick', function(f)
                    if f.memberInfo and f.memberInfo.guid and IsAltKeyDown() then
                        --C_GuildInfo.RemoveFromGuild(f.memberInfo.guid)
                    end
                end)
            end)]]
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='GUILD_ROSTER_UPDATE' or event=='PLAYER_GUILD_UPDATE' then
        set_Guild_Members()--在线人数

    elseif event=='CHAT_MSG_SYSTEM' then
        setMsg_CHAT_MSG_SYSTEM(arg1)--欢迎加入, 信息

    elseif event=='PLAYER_GUILD_UPDATE' then
        set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    end
end)