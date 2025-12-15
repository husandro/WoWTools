local function Save()
    return WoWToolsSave['Plus_Gossip']
end



local function Check(name)
    if StaticPopupDialogs[name] then
        return true, StaticPopupDialogs[name].timeout
    end
end


local ADDON_ACTION_FORBIDDEN_OwnerID
local function Init()
    local timeout= Save().gossip and 0.1 or nil


--该过场动画不可用

    StaticPopupDialogs["ERROR_CINEMATIC"].timeout= 0

    StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= timeout
    if timeout then
        if not ADDON_ACTION_FORBIDDEN_OwnerID then
            ADDON_ACTION_FORBIDDEN_OwnerID= EventRegistry:RegisterFrameEventAndCallback("ADDON_ACTION_FORBIDDEN", function(_, arg1, ...)
                 print(
                    WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    WARNING_FONT_COLOR:WrapTextInColorCode(format(
                        WoWTools_DataMixin.onlyChinese and '%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN,
                        arg1 or '')
                    ),
                    ...
                )
            end)
        end
    else
        EventRegistry:UnregisterCallback('ADDON_LOADED', ADDON_ACTION_FORBIDDEN_OwnerID)
    end
end



function WoWTools_GossipMixin:Init_StaticPopupDialogs()
    Init()
end