local id, e = ...
local Save={
    --notPrint= e.Player.husandro
}
local addName
--TalkingHeadUI.lua






local panel= CreateFrame("Frame")

function panel:set_event()
    if not Save.disabled then
        self:RegisterEvent('TALKINGHEAD_REQUESTED')
    else
        self:UnregisterEvent('TALKINGHEAD_REQUESTED')
    end
end

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            if WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING)] then
                Save= WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING)]
                WoWToolsSave[format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING)]=nil
            else
                Save= WoWToolsSave['Other_VoiceTalking'] or Save
            end

            addName= '|A:TalkingHeads-Glow-TopSpike:0:0|a'..(e.onlyChinese and '隐藏NPC发言' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING))

            --添加控制面板
            local initializer2= e.AddPanel_Check({
                name= addName,
                tooltip=format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '隐藏' or HIDE , e.onlyChinese and '对话特写头像' or HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL)
                        ..'|n|n'..(e.onlyChinese and '声音' or SOUND)
                        ..'|nChat Button, '..(e.onlyChinese and '超链接图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, EMBLEM_SYMBOL))
                        ..'|n'..(e.onlyChinese and '事件声音' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, EVENTS_LABEL, SOUND)),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    self:set_event()--设置事件
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            e.AddPanel_Check({
                name= e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
                tooltip= addName,
                GetValue= function() return not Save.notPrint end,
                SetValue= function()
                    Save.notPrint= not Save.notPrint and true or nil
                end
            }, initializer2)


            self:set_event()--设置事件
            self:UnregisterEvent(event)
        end

    elseif event=='TALKINGHEAD_REQUESTED' then
        local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
        TalkingHeadFrame:CloseImmediately()
        if vo and vo>0 then
            if ( self.voHandle ) then
                StopSound(self.voHandle)
                self.voHandle = nil
            end
            local success, voHandle = e.PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true)
            if ( success ) then
                self.voHandle = voHandle
            end
        end
        if not Save.notPrint and (text or self.voHandle) then
            print('|cff00ff00'..name..'|r','|cffff00ff'..text..'|r',id, addName, 'soundKitID', vo)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Other_VoiceTalking']=Save()
        end
    end

end)