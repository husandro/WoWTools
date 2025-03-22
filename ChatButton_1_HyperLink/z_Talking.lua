--隐藏NPC发言
local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end

local VoHandle






local function Init()

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

        local success, vo2 = WoWTools_Mixin:PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
        if ( success ) then
            VoHandle = vo2
        end

        if not Save().disabledTalkingPringText and text then
            print(e.Icon.icon2
                ..'|cffff00ff'..(name or '')
                ..'|r|A:voicechat-icon-textchat-silenced:0:0|a|cff00ff00'
                ..(text or '')
            )
        end
    end)

    return true
end






--隐藏NPC发言
function WoWTools_HyperLink:Init_NPC_Talking()
    if not self.Save.disabledNPCTalking and Init() then
        Init=function()end
    end
end