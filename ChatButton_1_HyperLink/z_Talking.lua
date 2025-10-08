--隐藏NPC发言
local function Save()
    return WoWToolsSave['ChatButton_HyperLink'] or {}
end

local VoHandle






local function Init()
    if Save().disabledNPCTalking then
        return
    end

    EventRegistry:RegisterFrameEventAndCallback("TALKINGHEAD_REQUESTED", function()
        if Save().disabledNPCTalking then
            return
        end

        local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()

        TalkingHeadFrame:CloseImmediately()

        if not vo or vo<=0 then
            return
        end

        if ( VoHandle ) then
            StopSound(VoHandle)
            VoHandle = nil
        end

        local success, vo2 = WoWTools_DataMixin:PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
        if ( success ) then
            VoHandle = vo2
        end

        if not Save().disabledTalkingPringText and text then
            print(
            WoWTools_DataMixin.Icon.icon2
                ..'|cffff00ff'..(name or '')
                ..'|r|A:voicechat-icon-textchat-silenced:0:0|a|cff00ff00'
                ..(text or '')
            )
        end
    end)

    Init=function()end
end






--隐藏NPC发言
function WoWTools_HyperLink:Init_NPC_Talking()
    Init()
end