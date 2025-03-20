local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end

--隐藏NPC发言
local VoHandle
local function Set_Talking()
    local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
    TalkingHeadFrame:CloseImmediately()

    if not vo or vo<=0 then
        return
    end

    if ( VoHandle ) then
        StopSound(VoHandle)
        VoHandle = nil
    end

    local success, vo2 = e.PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
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
end
