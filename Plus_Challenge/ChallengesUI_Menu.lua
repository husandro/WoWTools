local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end



local function Init_Menu(self, root)
    local sub
    local isInCombat= InCombatLockdown()
--副本信息
    sub= root:CreateCheckbox(
        '|A:QuestLegendary:0:0|a'
        ..(WoWTools_DataMixin.Player.onlyChinese and '副本信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INSTANCE, INFO)),
    function()
        return not Save().hideIns
    end, function()
        Save().hideIns = not Save().hideIns and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().insScale or 1
    end, function(value)
        Save().insScale= value
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

--传送门
    sub= root:CreateCheckbox(
        '|A:WarlockPortal-Yellow-32x32:0:0|a'
        ..'|cnRED_FONT_COLOR:'
        ..(WoWTools_DataMixin.Player.onlyChinese and '传送门' or SPELLS),
    function()
        return not Save().hidePort
    end, function()
        Save().hidePort = not Save().hidePort and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)
    sub:SetTooltip(function(tooltip)
        if WoWTools_DataMixin.onlyChinese then
            tooltip:AddDoubleLine('提示：', '如果出现错误，请禁用此功能')
            tooltip:AddDoubleLine('战斗中', '不能关闭，窗口')
        else
            tooltip:AddDoubleLine(LABEL_NOTE, 'If you get error, please disable this')
            tooltip:AddDoubleLine(HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, 'Cannot close window')
        end
    end)
    sub:SetEnabled(not isInCombat)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().portScale or 1
    end, function(value)
        Save().portScale= value
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)


--挑战信息 right
    sub= root:CreateCheckbox(
        '|A:challenges-medal-gold:0:0|a'
        ..(WoWTools_DataMixin.Player.onlyChinese and '挑战信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYER_DIFFICULTY5, INFO)),
    function()
        return not Save().hideRight
    end, function()
        Save().hideRight= not Save().hideRight and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Right()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().rightScale or 1
    end, function(value)
        Save().rightScale= value
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
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()


--宏伟宝库
    sub= root:CreateCheckbox(
        '|A:'..(WoWTools_DataMixin.Player.Faction=='Alliance' and 'activities-chest-sw' or 'activities-chest-org')..':0:0|a'
        ..(WoWTools_DataMixin.Player.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT),
    function()
        return not Save().hideActivities
    end, function()
        Save().hideActivities= not Save().hideActivities and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().activitiesScale or 1
    end, function(value)
        Save().activitiesScale= value
        WoWTools_ChallengeMixin:ChallengesUI_Activities()
    end)

--X
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
        name='X',
        minValue=-1024,
        maxValue=1024,
        step=1,
    })
    sub:CreateSpacer()


--其他信息
    sub= root:CreateCheckbox(
        '|A:ChallengeMode-Chest:0:0|a'
        ..(WoWTools_DataMixin.Player.onlyChinese and '其他信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, OTHER, INFO)),
    function()
        return not Save().hideTips
    end, function()
        Save().hideTips= not Save().hideTips and true or nil
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

--缩放
    WoWTools_MenuMixin:Scale(self, sub, function()
        return Save().tipsScale or 1
    end, function(value)
        Save().tipsScale= value
        WoWTools_ChallengeMixin:ChallengesUI_Porta()
    end)

end











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