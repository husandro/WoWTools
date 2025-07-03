





--要塞,任务，列表
local function Get_Garrison_List_Num(followerType)
    local num, all, text= 0, 0, ''
    if followerType then
        local missions = C_Garrison.GetInProgressMissions(followerType) or {}--GarrisonBaseUtils.lua
        for _, mission in ipairs(missions) do
            if (mission.isComplete == nil) then
                mission.isComplete = mission.timeLeftSeconds == 0
            end
            if mission.isComplete then
                num = num + 1
            end
            all = all + 1
        end
        if all==0 then
            text= ''--format('|cff9e9e9e%d/%d|r', num, all)
        elseif num==0 then
            text= format('|cff9e9e9e%d|r/%d', num, all)
        elseif all==num then
            text= format('|cffff00ff%d/%d|r', num, all)..format('|A:%s:0:0|a', 'common-icon-checkmark')
        else
            text= format('|cnGREEN_FONT_COLOR:%d|r/%d', num, all)
        end
    end
    return text
end







--LuaEnum.lua
local GarrisonList
local function Init_GarrisonList()
    GarrisonList={

    --[[{name=WoWTools_DataMixin.onlyChinese and '巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TITLE,
    garrisonType= Enum.GarrisonType.Type_9_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled=false,--not C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower),
    atlas= 'dragonflight-landingbutton-up',
    tooltip= WoWTools_DataMixin.onlyChinese and '点击显示巨龙群岛概要' or DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
    func= function()
        ToggleExpansionLandingPage()
    end,
    },]]
    {name=WoWTools_DataMixin.onlyChinese and '卡兹阿加概要' or WAR_WITHIN_LANDING_PAGE_TITLE,--Blizzard_WarWithinLandingPage.lua
    garrisonType= Enum.ExpansionLandingPageType.WarWithin,
    --garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled= not C_PlayerInfo.IsExpansionLandingPageUnlockedForPlayer(LE_EXPANSION_WAR_WITHIN),
    check= function() return ExpansionLandingPage and ExpansionLandingPage:IsShown() end,
    atlas= 'warwithin-landingbutton-up',
    --tooltip= WoWTools_DataMixin.onlyChinese and '点击这里显示卡兹阿加概要' or DRAGONFLIGHT_LANDING_PAGE_TOOLTIP,
    func= function()
        ToggleExpansionLandingPage()
    end,
    },

    {name='-'},

    {name=  WoWTools_DataMixin.onlyChinese and '盟约圣所' or GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
    garrisonType= Enum.GarrisonType.Type_9_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower,
    disabled= C_Covenants.GetActiveCovenantID()==0,
    atlas= function()
        local info= C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID() or 0) or {}
        local icon=''
        if info.textureKit then
            icon= format('CovenantChoice-Celebration-%sSigil', info.textureKit or '')
        end
        return icon
    end,
    --tooltip= WoWTools_DataMixin.onlyChinese and '点击显示圣所报告' or GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP,
    },

    --[[{name=  WoWTools_DataMixin.onlyChinese and '任务' or GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
    garrisonType= Enum.GarrisonType.Type_8_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower,
    atlas= string.format("bfa-landingbutton-%s-up", WoWTools_DataMixin.Player.Faction),
    tooltip= WoWTools_DataMixin.onlyChinese and '点击显示任务报告' or GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP,
    },]]

    {name=  WoWTools_DataMixin.onlyChinese and '职业大厅' or ORDERHALL_MISSION_REPORT:match('(.-)%\n') or ORDER_HALL_LANDING_PAGE_TITLE,
    garrisonType= Enum.GarrisonType.Type_7_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower,
    frame='OrderHallMissionFrame',
    atlas= WoWTools_UnitMixin:GetClassIcon('player', nil, nil, {reAltlas=true}),--职业图标 -- WoWTools_DataMixin.Player.Class == "EVOKER" and "UF-Essence-Icon-Active" or string.format("legionmission-landingbutton-%s-up", WoWTools_DataMixin.Player.Class),
    --tooltip= WoWTools_DataMixin.onlyChinese and '点击显示职业大厅报告' or MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP,
    },

    {name= WoWTools_DataMixin.onlyChinese and '要塞' or GARRISON_LOCATION_TOOLTIP,
    garrisonType= Enum.GarrisonType.Type_6_0_Garrison,
    garrFollowerTypeID= Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower,
    garrFollowerTypeID2=Enum.GarrisonFollowerType.FollowerType_6_0_Boat,
    atlas= format("GarrLanding-MinimapIcon-%s-Up", WoWTools_DataMixin.Player.Faction),
    atlas2= format('Islands-%sBoat', WoWTools_DataMixin.Player.Faction),
    --tooltip= WoWTools_DataMixin.onlyChinese and '点击显示要塞报告' or MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP,
    },



}

end














--要塞报告 GarrisonBaseUtils.lua
function WoWTools_MinimapMixin:Garrison_Menu(_, root)
    local sub

--宏伟宝库
    local hasRewar= C_WeeklyRewards.HasAvailableRewards()
    sub=root:CreateCheckbox(
        (hasRewar and '|cnGREEN_FONT_COLOR:' or '')
        ..'|A:gficon-chest-evergreen-greatvault-collect:0:0|a'..(WoWTools_DataMixin.onlyChinese and '宏伟宝库' or RATED_PVP_WEEKLY_VAULT)
        ..(hasRewar and '|A:BonusLoot-Chest:0:0|a' or ''),
    function()
        return WeeklyRewardsFrame and WeeklyRewardsFrame:IsShown()
    end, WoWTools_LoadUIMixin.WeeklyRewards)
    sub:SetTooltip(function(tooltip)
        WoWTools_ChallengeMixin:ActivitiesTooltip(tooltip)--周奖励，提示
    end)



--驭空术
    --[[local DRAGONRIDING_INTRO_QUEST_ID = 68798;
    local DRAGONRIDING_ACCOUNT_ACHIEVEMENT_ID = 15794;
    local DRAGONRIDING_TRAIT_SYSTEM_ID = 1;
    local DRAGONRIDING_TREE_ID = 672;]]

    local numDragonriding=''
    local dragonridingConfigID = C_Traits.GetConfigIDBySystemID(1)
    if dragonridingConfigID then
        local treeCurrencies = C_Traits.GetTreeCurrencyInfo(dragonridingConfigID, 672, false)
        local num = treeCurrencies and treeCurrencies[1] and treeCurrencies[1].quantity
        if num then
            numDragonriding= format(' %s%d|r |T%d:0|t', num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:', num, select(4, C_Traits.GetTraitCurrencyInfo(2563)) )
        end
    end
    root:CreateCheckbox(
        format('|A:dragonriding-barbershop-icon-protodrake:0:0|a%s%s', WoWTools_DataMixin.onlyChinese and '驭空术' or GENERIC_TRAIT_FRAME_DRAGONRIDING_TITLE, numDragonriding),
    function()
        return GenericTraitFrame and GenericTraitFrame:IsShown() and GenericTraitFrame:GetConfigID() == C_Traits.GetConfigIDBySystemID(Enum.ExpansionLandingPageType.Dragonflight)
    end, function()
        WoWTools_LoadUIMixin:Dragonriding()
    end)

    do
        if not GarrisonList then
            Init_GarrisonList()
        end
    end

    for _, info in pairs(GarrisonList) do
        if info.name=='-' then
            root:CreateDivider()

        else
            local has= C_Garrison.HasGarrison(info.garrisonType)
            local num, num2= '', ''
            if has and info.garrFollowerTypeID then
                num= ' '..Get_Garrison_List_Num(info.garrFollowerTypeID)
                if info.garrFollowerTypeID2 then
                    num2= format(' |A:%s:0:0|a%s', info.atlas2 or '',  Get_Garrison_List_Num(info.garrFollowerTypeID2))
                end
            end
            local atlas= type(info.atlas)=='function' and info.atlas() or info.atlas or ''

            sub=root:CreateCheckbox(
                format('|A:%s:0:0|a%s%s%s', atlas, info.name, num, num2),
            info.check or function(data)
                return GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==data.garrisonType
            end, function(data)
                if data.func then
                    data.func()
                else
                    if GarrisonLandingPage and GarrisonLandingPage:IsShown() and GarrisonLandingPage.garrTypeID==data.garrisonType then
                        GarrisonLandingPage:Hide()
                    else
                        ShowGarrisonLandingPage(data.garrisonType)
                    end
                end
            end, {
                garrisonType= info.garrisonType,
                tooltip= info.tooltip,
                func=info.func
            })
            --[[sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(description.data.tooltip)
            end)]]


            local disabled
            if info.disabled~=nil then
                disabled= info.disabled
            else
                disabled= not has
            end
            sub:SetEnabled(not disabled and true or false)

--盟约 9.0
            if info.garrisonType== Enum.GarrisonType.Type_9_0_Garrison then
                for covenantID=1, 4 do
                    local info2 = C_Covenants.GetCovenantData(covenantID)
                    local tab = C_CovenantSanctumUI.GetRenownLevels(covenantID)
                    if info2 and info2.name and tab then
                        local level= 0
                        for i=#tab, 1, -1 do
                            if not tab[i].locked then
                                level= tab[i].level
                                break
                            end
                        end

                        sub:CreateButton(
                            (info2.textureKit and format('|A:SanctumUpgrades-%s-32x32:0:0|a', info2.textureKit) or '')
                            ..WoWTools_TextMixin:CN(info2.name)..' '..level,
                        function(data)
                            WoWTools_LoadUIMixin:CovenantRenown(nil, data.covenantID)
                            return MenuResponse.Open
                        end, {covenantID=covenantID})

                    end
                end
            end
        end
    end
end