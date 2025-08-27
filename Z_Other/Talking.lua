--TalkingHeadUI.lua
local addName
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")







local voHandle
local function TALKINGHEAD_REQUESTED()
    local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
    TalkingHeadFrame:CloseImmediately()
    if vo and vo>0 then
        if voHandle then
            StopSound(voHandle)
            voHandle = nil
        end
        local success, vo2 = WoWTools_Mixin:PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
        if success then
            voHandle = vo2
        end
    end

    if not WoWToolsSave['Other_VoiceTalking'].notPrint and (text or voHandle) then
        print(WoWTools_DataMixin.Icon.icon2,
            '|cff00ff00'..name..'|r',
            '|cffff00ff'..text..'|r',
            addName,
            'soundKitID',
            vo
        )
    end
end




local function Set_Event()
    if not WoWToolsSave['Other_VoiceTalking'].disabled then
        panel:RegisterEvent('TALKINGHEAD_REQUESTED')
    else
        panel:UnregisterEvent('TALKINGHEAD_REQUESTED')
    end
end







local function ADDON_LOADED()
    WoWToolsSave['Other_VoiceTalking']= WoWToolsSave['Other_VoiceTalking'] or {notPrint=true}

    addName= '|A:TalkingHeads-Glow-TopSpike:0:0|a'..(WoWTools_DataMixin.onlyChinese and '隐藏NPC发言' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING))

    --添加控制面板
    local root= WoWTools_PanelMixin:OnlyCheck({
        name= addName,
        tooltip=format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE , WoWTools_DataMixin.onlyChinese and '对话特写头像' or HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
                ..'|n|n'..(WoWTools_DataMixin.onlyChinese and '声音' or SOUND)
                ..'|nChat Button, '..(WoWTools_DataMixin.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
                ..'|n'..(WoWTools_DataMixin.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)),
        GetValue= function() return not WoWToolsSave['Other_VoiceTalking'].disabled end,
        SetValue= function()
            WoWToolsSave['Other_VoiceTalking'].disabled= not WoWToolsSave['Other_VoiceTalking'].disabled and true or nil
            Set_Event()--设置事件
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
        GetValue= function() return not WoWToolsSave['Other_VoiceTalking'].notPrint end,
        tooltip= WoWTools_DataMixin.onlyChinese and '聊天框提示，内容' or 'ChatBox input text',
        SetValue= function()
            WoWToolsSave['Other_VoiceTalking'].notPrint= not WoWToolsSave['Other_VoiceTalking'].notPrint and true or nil
        end,
        layout= WoWTools_OtherMixin.Layout,
        category= WoWTools_OtherMixin.Category,
    }, root)


    Set_Event()--设置事件

    ADDON_LOADED=function()end

    panel:UnregisterEvent('ADDON_LOADED')
end





panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            ADDON_LOADED()
        end

    elseif event=='TALKINGHEAD_REQUESTED' then
        TALKINGHEAD_REQUESTED()
    end
end)