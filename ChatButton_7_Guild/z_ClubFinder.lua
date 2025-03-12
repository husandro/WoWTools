local e= select(2, ...)
local function Save()
    return WoWTools_GuildMixin.Save
end










--###############
--自动选取当前专精
--###############
local function set_RequestToJoinFrame(frame)
    if e.LockFrame(frame) then
        return
    end

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
        and not Save().notAutoRequestToJoinClub
    then
        print(WoWTools_ChatButtonMixin.addName, WoWTools_GuildMixin.addName, frame.ClubName:GetText(), e.cn(frame.Apply:GetText()), '|n', text, '|n|cffff00ff',text2)
        frame.Apply:Click()
    end
end








--####################
--设置，自动申请，check
--####################
local function set_check(frame)
    local check= CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint('RIGHT', frame, 'LEFT', 0, 12)
    check:SetChecked(not Save().notAutoRequestToJoinClub)
    check:SetScript('OnClick', function()
        Save().notAutoRequestToJoinClub= not Save().notAutoRequestToJoinClub and true or nil
    end)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_ChatButtonMixin.addName, WoWTools_GuildMixin.addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '自动申请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SIGN_UP))..e.Icon.left, e.GetEnabeleDisable(not Save().notAutoRequestToJoinClub))
        e.tips:Show()
    end)
    check:SetScript('OnShow', function(self2)
        self2:SetChecked(not Save().notAutoRequestToJoinClub)
    end)
end








local function Init()
    if IsVeteranTrialAccount() then--试用帐号
        return
    end
    set_check(ClubFinderGuildFinderFrame.OptionsList.SearchBox)
    set_check(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)
    hooksecurefunc(ClubFinderGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_RequestToJoinFrame)
    hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame, 'Initialize', set_RequestToJoinFrame)
end






function WoWTools_GuildMixin:Init_ClubFinder()
    Init()
end