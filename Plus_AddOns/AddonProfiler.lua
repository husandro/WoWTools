--启用/禁用 CPU分析功能

local function Init()
    if InCombatLockdown() or WoWTools_DataMixin.isRetail then
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
                WoWTools_DataMixin.Icon.icon2..WoWTools_AddOnsMixin.addName,
                '|cnGREEN_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '启用CPU分析功能' or format(ADDON_LIST_PERFORMANCE_PEAK_CPU, ENABLE))
            )
        end
    else
        if isEnabled then
            C_CVar.SetCVar("addonProfilerEnabled", "0")
            print(
                WoWTools_DataMixin.Icon.icon2..WoWTools_AddOnsMixin.addName,
                '|cnRED_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '禁用CPU分析功能' or format(ADDON_LIST_PERFORMANCE_PEAK_CPU, DISABLE)),
                'CVar addonProfilerEnabled'
                
            )
        end
    end
end




function WoWTools_AddOnsMixin:Set_AddonProfiler()
    Init()
end