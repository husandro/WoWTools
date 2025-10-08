--启用/禁用 CPU分析功能

local function Init()
    if InCombatLockdown() or not WoWTools_DataMixin.Player.husandro then-- or not WoWTools_DataMixin.isRetail then
        return
    end

    local isEnabled= C_AddOnProfiler.IsEnabled()

    if not C_CVar.GetCVarInfo('addonProfilerEnabled') then
        C_CVar.RegisterCVar("addonProfilerEnabled", isEnabled and "1" or '0')
    end

    if WoWToolsSave['Plus_AddOns'].addonProfilerEnabled then
        if not isEnabled then
            C_CVar.SetCVar("addonProfilerEnabled", "1")
            print(
               WoWTools_AddOnsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnGREEN_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '启用CPU分析功能' or format(ADDON_LIST_PERFORMANCE_PEAK_CPU, ENABLE))
                ..'|r',
                WoWTools_DataMixin.onlyChinese and '当前：' or ITEM_UPGRADE_CURRENT,
                WoWTools_TextMixin:GetEnabeleDisable(C_AddOnProfiler.IsEnabled())
            )
        end
    else
        if isEnabled then
            C_CVar.SetCVar("addonProfilerEnabled", "0")
            print(
                WoWTools_AddOnsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                '|cnWARNING_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '禁用CPU分析功能' or format(ADDON_LIST_PERFORMANCE_PEAK_CPU, DISABLE))
                ..'|r',
                WoWTools_DataMixin.onlyChinese and '当前：' or ITEM_UPGRADE_CURRENT,
                WoWTools_TextMixin:GetEnabeleDisable(C_AddOnProfiler.IsEnabled())
            )
        end
    end
end




function WoWTools_AddOnsMixin:Set_AddonProfiler()
    Init()
end