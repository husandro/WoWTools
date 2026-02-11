
local function Save()
    return WoWToolsSave['ChatButtonGuild']
end










--###############
--自动选取当前专精
--###############
local function set_RequestToJoinFrame(frame)
    if WoWTools_FrameMixin:IsLocked(frame) then
        return
    end

    local text
    local edit= frame.MessageFrame.MessageScroll.EditBox
    local avgItemLevel, _, avgItemLevelPvp = GetAverageItemLevel()
    if avgItemLevel then
        local cd= WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3
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
        local currSpecID= C_SpecializationInfo.GetSpecializationInfo(GetSpecialization() or 0)

        for btn in frame.SpecsPool:EnumerateActive() do
            local check= not currSpecID or currSpecID==btn.specID
            local box= btn.Checkbox or btn.CheckBox
            if box then
                if check and not box:GetChecked() then
                    box:Click()--自动选取当前专精
                end
                _, name, _, icon, role= GetSpecializationInfoByID(btn.specID)
                if name then
                    name= '|T'..(icon or 0)..':0|t'..(WoWTools_DataMixin.Icon[role] or '')..WoWTools_TextMixin:CN(name)
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
        print(
            WoWTools_GuildMixin.addName..WoWTools_DataMixin.Icon.icon2,
            frame.ClubName:GetText(),
            WoWTools_TextMixin:CN(frame.Apply:GetText()),
            '|n',
            text,
            '|n|cffff00ff',
            text2
        )
        frame.Apply:Click()
    end
end








--####################
--设置，自动申请，check
--####################
local function set_check(frame)
    local check= WoWTools_ButtonMixin:Cbtn(frame, {
        isCheck=true,
    })
    check:SetPoint('RIGHT', frame, 'LEFT', 0, 12)
    check:SetChecked(not Save().notAutoRequestToJoinClub)
        check:SetScript('OnShow', function(self2)
        self2:SetChecked(not Save().notAutoRequestToJoinClub)
    end)

    function check:settings()
        Save().notAutoRequestToJoinClub= not Save().notAutoRequestToJoinClub and true or nil
    end
    function check:tooltip()
         GameTooltip:AddDoubleLine(WoWTools_ChatMixin.addName, WoWTools_GuildMixin.addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(
            '|A:communities-icon-addgroupplus:0:0|a'
            ..(WoWTools_DataMixin.onlyChinese and '自动申请' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SIGN_UP))
            ..WoWTools_DataMixin.Icon.left,

            WoWTools_TextMixin:GetEnabeleDisable(not Save().notAutoRequestToJoinClub)
        )
    end
end








local function Init()
    if not IsVeteranTrialAccount() then
        set_check(ClubFinderGuildFinderFrame.OptionsList.SearchBox)
        set_check(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)
        WoWTools_DataMixin:Hook(ClubFinderGuildFinderFrame.RequestToJoinFrame, 'Initialize', function(...)
            set_RequestToJoinFrame(...)
        end)
        WoWTools_DataMixin:Hook(ClubFinderCommunityAndGuildFinderFrame.RequestToJoinFrame, 'Initialize', function(...)
            set_RequestToJoinFrame(...)
        end)
    end
    Init=function()end
end






function WoWTools_GuildMixin:Init_ClubFinder()
    Init()
end