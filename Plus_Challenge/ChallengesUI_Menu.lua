local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end



local function Init_Menu(self, root)
    local sub, sub2, name
    local isInCombat= InCombatLockdown()









--副本信息
    name='|A:QuestLegendary:0:0|a'..(WoWTools_DataMixin.onlyChinese and '副本信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, INFO))
    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideIns
    end, function()
        Save().hideIns = not Save().hideIns and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Info()
    end)

--gsub
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().insNamegsub or 0
        end, setValue=function(value)
            Save().insNamegsub=value>0 and value or nil
            WoWTools_ChallengeMixin:ChallengesUI_Info()
        end,
        name=WoWTools_DataMixin.onlyChinese and '截取' or 'gsub',
        minValue=0,
        maxValue=30,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '副本名称' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, NAME))
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '截取' or 'gsub')
            tooltip:AddLine(" ")
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '0-不截取' or '0-Not gsub')
        end,
        step=1,
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().insScale or 1
    end, function(value)
        Save().insScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Info()
    end, function()
        Save().insScale=nil
        Save().insNamegsub=nil
        WoWTools_ChallengeMixin:ChallengesUI_Info()
    end)

--sub 提示
    sub:CreateSpacer()
    sub:CreateTitle(name)











--传送门
    name= '|A:WarlockPortal-Yellow-32x32:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '传送门' or SPELLS)
    sub= root:CreateCheckbox(
    name,
    function()
        return not Save().hidePort
    end, function()
        Save().hidePort = not Save().hidePort and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)
    sub:SetTooltip(function(tooltip)
        if WoWTools_DataMixin.onlyChinese then
            tooltip:AddDoubleLine('提示：', '|cnRED_FONT_COLOR:如果出现错误，请禁用此功能')
            --tooltip:AddDoubleLine('战斗中', '|cnRED_FONT_COLOR:不能关闭，窗口')
        else
            tooltip:AddDoubleLine(LABEL_NOTE, '|cnRED_FONT_COLOR:If you get error, please disable this')
            tooltip:AddDoubleLine(HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, '|cnRED_FONT_COLOR:Cannot close window')
        end
    end)
    sub:SetEnabled(not isInCombat)

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().portScale or 1
    end, function(value)
        Save().portScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end, function()
        Save().portScale=nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

--sub 提示
    sub:CreateSpacer()
    sub:CreateTitle(name)
    WoWTools_MenuMixin:Reload(sub)--重新加载UI



















    root:CreateDivider()
    WoWTools_ChallengeMixin:ChallengesUI_Left_Menu(self, root)


















--宏伟宝库，内，左侧
    local hasRewar= C_WeeklyRewards.HasAvailableRewards()
    name= (hasRewar and '|cnGREEN_FONT_COLOR:' or '')
        ..'|A:'..(WoWTools_DataMixin.Player.Faction=='Alliance' and 'activities-chest-sw' or 'activities-chest-org')..':0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT)
        ..(hasRewar and '|A:BonusLoot-Chest:0:0|a' or '')

    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideActivities
    end, function()
        Save().hideActivities= not Save().hideActivities and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)
    sub:SetTooltip(function(tooltip)
        WoWTools_ChallengeMixin:ActivitiesTooltip(tooltip)--周奖励，提示
    end)

--打开
    sub2=sub:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT,
    function()
        return WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown()
    end, WoWTools_LoadUIMixin.WeeklyRewards)
    sub2:SetTooltip(function (tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '点击预览宏伟宝库' or WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS)
    end)
    sub:CreateDivider()

--PvP信息
    sub:CreateCheckbox(
        'PvP '
        ..(WoWTools_DataMixin.onlyChinese and '信息' or INFO),
    function()
        return not Save().activitiesHidePvP
    end, function()
        Save().activitiesHidePvP= not Save().activitiesHidePvP and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)


--X
    sub:CreateSpacer()
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().activitiesX or 10
        end, setValue=function(value)
            Save().activitiesX=value
            WoWTools_ChallengeMixin:ChallengesUI_Activities()
        end,
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().activitiesY or -53
        end, setValue=function(value)
            Save().activitiesY=value
            WoWTools_ChallengeMixin:ChallengesUI_Activities()
        end,
        name='Y',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().activitiesScale or 1
    end, function(value)
        Save().activitiesScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end, function()
        Save().activitiesScale=nil
        Save().activitiesX=nil
        Save().activitiesY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)

--sub 提示
    sub:CreateSpacer()
    sub:CreateTitle(name)













--公会挑战，内侧，右上角
    local isInGuild= IsInGuild()
    name= '|A:communities-guildbanner-background:0:0|a'
        ..(isInGuild and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '公会挑战' or GUILD_CHALLENGE_LABEL)
    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideGuild
    end, function()
        Save().hideGuild= not Save().hideGuild and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end)
    sub2:SetTooltip(function(tooltip)
        if not isInGuild then
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '无公会' or ERR_GUILD_PLAYER_NOT_IN_GUILD)
        end
    end)
--X
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().guildX or -15
    end, setValue=function(value)
        Save().guildX=value
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end,
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().guildY or -32
    end, setValue=function(value)
        Save().guildY=value
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end,
        name='Y',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().guildScale or 1
    end, function(value)
        Save().guildScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end, function()
        Save().guildScale=nil
        Save().guildX=nil
        Save().guildY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Guild()
    end)

--sub 提示
    sub:CreateSpacer()
    sub:CreateTitle(name)









--词缀, 右下角
    name= '|T463829:0|t'
        ..(C_MythicPlus.GetCurrentSeason()==WoWTools_DataMixin.affixScheduleSeason and '' or '|cff828282')
        ..(WoWTools_DataMixin.onlyChinese and '词缀列表' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, 'Affix', INFO))
    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideAffix
    end, function()
        Save().hideAffix= not Save().hideAffix and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end)
    sub:SetTooltip(function(tooltip)
        local season= C_MythicPlus.GetCurrentSeason() or 0
        tooltip:AddLine(
            format(WoWTools_DataMixin.onlyChinese and '全新赛季词缀：%s' or MYTHIC_PLUS_SEASON_DESC3, season..'')
        )
        if season~=WoWTools_DataMixin.affixScheduleSeason then
            GameTooltip:AddLine(' ')
            GameTooltip:AddLine(
                '|cnRED_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '当前赛季数据不匹配' or 'Current season data mismatch')
            )
        end
    end)


--W
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().affixW or 238
    end, setValue=function(value)
        Save().affixW=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name=WoWTools_DataMixin.onlyChinese and '宽度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH,
        minValue=220,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--H
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().affixH or 177
    end, setValue=function(value)
        Save().affixH=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name=WoWTools_DataMixin.onlyChinese and '高度' or HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT,
        minValue=58,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()


--X
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().affixX or -45
    end, setValue=function(value)
        Save().affixX=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name='X',
        minValue=-2048,
        maxValue=2048,
        step=1,
    })
sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().affixY or 300
    end, setValue=function(value)
        Save().affixY=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end,
        name='Y',
        minValue=-2048,
        maxValue=2048,
        step=1,
    })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().affixScale or 0.4
    end, function(value)
        Save().affixScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end, function()
        Save().affixScale=nil
        Save().affixW=nil
        Save().affixH=nil
        Save().affixX=nil
        Save().affixY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Affix()
    end)

--sub 提示
sub:CreateSpacer()
sub:CreateTitle(name)
















--挑战信息 right
    name= '|A:challenges-medal-gold:0:0|a'
    ..(WoWTools_DataMixin.onlyChinese and '挑战信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYER_DIFFICULTY5, INFO))
    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideRight
    end, function()
        Save().hideRight= not Save().hideRight and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end)

--X
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().rightX or 10
    end, setValue=function(value)
        Save().rightX=value
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end,
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()

--Y
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
    getValue=function()
        return Save().rightY or -53
    end, setValue=function(value)
        Save().rightY=value
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end,
        name='Y',
        minValue=-1024,
        maxValue=1024,
        step=1,
        })
    sub:CreateSpacer()

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().rightScale or 1
    end, function(value)
        Save().rightScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end, function()
        Save().rightScale=nil
        Save().rightX=nil
        Save().rightY=nil
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end)

    --sub 提示
    sub:CreateSpacer()
    sub:CreateTitle(name)






--插入史诗钥石，打开界面
    root:CreateDivider()
    sub=root:CreateButton(
        '|A:ChallengeMode-KeystoneSlotFrame:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '插入史诗钥石' or CHALLENGE_MODE_INSERT_KEYSTONE),
    function()
        ChallengesKeystoneFrame:SetShown(not ChallengesKeystoneFrame:IsShown())
        return MenuResponse.Open
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '显示UI' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, 'UI'))
    end)
--菜单
    WoWTools_ChallengeMixin:ChallengesKeystoneFrame_Menu(self, sub)





--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ChallengeMixin.addName})
end



--[[其他信息
    name= '|A:ChallengeMode-Chest:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '其他信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, INFO))
    sub= root:CreateCheckbox(
        name,
    function()
        return not Save().hideTips
    end, function()
        Save().hideTips= not Save().hideTips and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

--缩放
    WoWTools_MenuMixin:ScaleRoot(self, sub,
    function()
        return Save().tipsScale or 1
    end, function(value)
        Save().tipsScale=value
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end, function()
        Save().tipsScale=nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

--sub 提示
    sub:CreateDivider()
    sub:CreateTitle(name)]]













local function Init()
    local btn= WoWTools_ButtonMixin:Menu(ChallengesFrame)
    btn:SetPoint('RIGHT', PVEFrameCloseButton, 'LEFT')
    btn:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)

    btn:SetupMenu(Init_Menu)

    Init=function()end
end










function WoWTools_ChallengeMixin:ChallengesUI_Menu()
    Init()
end