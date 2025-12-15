local function Save()
    return WoWToolsSave['Plus_Gossip']
end



--[[local function Check(name)
    if StaticPopupDialogs[name] then
        return true, StaticPopupDialogs[name].timeout
    end
end]]


local FORBIDDEN_ID

local Err={}

local function Init()
    local timeout= Save().gossip and 0.1 or nil


    StaticPopupDialogs["ERROR_CINEMATIC"].timeout= timeout and 1 or nil

    StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"].timeout= timeout

    if timeout then
        if not FORBIDDEN_ID then
            FORBIDDEN_ID= EventRegistry:RegisterFrameEventAndCallback("ADDON_ACTION_FORBIDDEN", function(_, arg1, func)
                if not Err[arg1] or not Err[arg1][func] then
                    Err[arg1]= Err[arg1] or {}
                    Err[arg1][func]=true
                    print(
                        WoWTools_GossipMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WARNING_FONT_COLOR:WrapTextInColorCode(format(
                            WoWTools_DataMixin.onlyChinese and '%s|r已被禁用，因为该功能只对暴雪的UI开放。\n你可以禁用这个插件并重新装载UI。' or ADDON_ACTION_FORBIDDEN,
                            arg1 or '')
                        ),
                        func
                    )
                end
            end)
        end
    elseif FORBIDDEN_ID  then
        EventRegistry:UnregisterCallback('ADDON_LOADED', FORBIDDEN_ID)
    end
end



function WoWTools_GossipMixin:Init_StaticPopupDialogs()
    Init()
end