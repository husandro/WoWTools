local id, e = ...
local Save={
    --notPrint= e.Player.husandro
}
local addName

--TalkingHeadUI.lua










local function Set_Event()--设置事件
    if not Frame then
        Frame= CreateFrame('Frame')
        Frame:SetScript("OnEvent", function(self)
            local _, _, vo, _, _, _, name, text = C_TalkingHead.GetCurrentLineInfo()
            TalkingHeadFrame:CloseImmediately()
            if vo and vo>0 then
                if ( self.voHandle ) then
                    StopSound(self.voHandle);
                    self.voHandle = nil;
                end
                local success, voHandle = e.PlaySound(vo, true)--PlaySound(vo, "Talking Head", true, true);
                if ( success ) then
                    self.voHandle = voHandle;
                end
            end
            if not Save.notPrint and (text or self.voHandle) then
                print('|cff00ff00'..name..'|r','|cffff00ff'..text..'|r',id, e.cn(addName), 'soundKitID', vo)
            end
        end)
    end

    if not Save.disabled then
        Frame:RegisterEvent('TALKINGHEAD_REQUESTED')
    else
        Frame:UnregisterEvent('TALKINGHEAD_REQUESTED')
    end
end








EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~=id then
        return
    end
    local name= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, VOICE_TALKING)
    if WoWToolsSave[name] then
        Save= WoWToolsSave[name]
        WoWToolsSave[name]=nil
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
            Set_Event()--设置事件
            print(WoWTools_Mixin.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled))
        end
    })

    e.AddPanel_Check({
        name= e.onlyChinese and '文本' or LOCALE_TEXT_LABEL,
        tooltip= e.cn(addName),
        GetValue= function() return not Save.notPrint end,
        SetValue= function()
            Save.notPrint= not Save.notPrint and true or nil
        end
    }, initializer2)


    Set_Event()--设置事件

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)


EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['Other_VoiceTalking']=Save
    end
end)