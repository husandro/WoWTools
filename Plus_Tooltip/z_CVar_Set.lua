

--设置Cvar
function WoWTools_TooltipMixin:Set_CVar(reset, tips, notPrint)
    local tab={
        {   name='missingTransmogSourceInItemTooltips',
            value='1',
            msg=WoWTools_Mixin.onlyChinese and '显示装备幻化来源' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TRANSMOGRIFY, SOURCES)),
        },
        {   name='nameplateOccludedAlphaMult',
            value='0.15',
            msg=WoWTools_Mixin.onlyChinese and '不在视野里, 姓名板透明度' or (SPELL_FAILED_LINE_OF_SIGHT..'('..SHOW_TARGET_CASTBAR_IN_V_KEY..')'..'Alpha'),
        },
        {   name='dontShowEquipmentSetsOnItems',
            value='0',
            msg=WoWTools_Mixin.onlyChinese and '显法装备方案' or EQUIPMENT_SETS:format(SHOW),
        },
        {   name='UberTooltips',
            value='1',
            msg=WoWTools_Mixin.onlyChinese and '显示法术信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, SPELL_MESSAGES)
        },
        {   name="alwaysCompareItems",
             value= "1",
             msg= WoWTools_Mixin.onlyChinese and '总是比较装备' or ALWAYS..COMPARE_ACHIEVEMENTS:gsub(ACHIEVEMENTS, ITEMS)
        },
        {   name="profanityFilter",
            value= '0',
            msg= '禁用语言过虑 /reload',
            zh=true,
        },
        {   name="overrideArchive",
            value= '0',
            msg= '反和谐 /reload',
            zh=true
        },
        {   name='cameraDistanceMaxZoomFactor',
            value= '2.6',
            msg= WoWTools_Mixin.onlyChinese and '视野距离' or FARCLIP
        },
        {   name="showTargetOfTarget",
            value= "1",
            msg= WoWTools_Mixin.onlyChinese and '总是显示目标的目标' or OPTION_TOOLTIP_TARGETOFTARGET5,
        },
        {   name='worldPreloadNonCritical',--https://wago.io/ZtSxpza28
            value='0',--2
            msg= WoWTools_Mixin.onlyChinese and '世界非关键预加载' or 'World Preload Non Critical'
        }
    }

    if tips then
        local text
        for _, info in pairs(tab) do
            if info.zh and LOCALE_zhCN or not info.zh then
                text= (text and text..'|n|n' or '')..WoWTools_Mixin:Get_CVar_Tooltips(info)
            end
        end
        return text
    end

    for _, info in pairs(tab) do
        if info.zh and LOCALE_zhCN or not info.zh then
            if reset then
                local defaultValue = C_CVar.GetCVarDefault(info.name)
                local value = C_CVar.GetCVar(info.name)
                if defaultValue~=value then
                    C_CVar.SetCVar(info.name, defaultValue)
                    if not notPrint then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_TooltipMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '恢复默认设置' or RESET_TO_DEFAULT)..'|r', info.name, defaultValue, info.msg)
                    end
                end
            else
                local value = C_CVar.GetCVar(info.name)
                if value~=info.value then
                    C_CVar.SetCVar(info.name, info.value)
                    if not notPrint then
                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_TooltipMixin.addName, info.name, info.value..'('..value..')', info.msg)
                    end
                end
            end
        end
    end
end





function WoWTools_TooltipMixin:Init_CVar()
    if WoWToolsSave['Plus_Tootips'].setCVar then
        WoWTools_TooltipMixin:Set_CVar(nil, nil, true)--设置CVar

        if LOCALE_zhCN then
            ConsoleExec("portal TW")
            SetCVar("profanityFilter", '0')

            local pre = C_BattleNet.GetFriendGameAccountInfo
    ---@diagnostic disable-next-line: duplicate-set-field
            C_BattleNet.GetFriendGameAccountInfo = function(...)
                local gameAccountInfo = pre(...)
                gameAccountInfo.isInCurrentRegion = true
                return gameAccountInfo
            end
        end
    end
end