--播放, 事件声音
local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end

local TimerType
local Timer0
local Timer1
local Timer2
local Timer3
local Timer4








local function Set_PlayerSound()--事件, 声音
    if not Save().setPlayerSound then
        return
    end

    if not C_CVar.GetCVarBool('Sound_EnableAllSound') then
        C_CVar.SetCVar('Sound_EnableAllSound', '1')
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_EnableAllSound|r', WoWTools_Mixin.onlyChinese and '开启声效' or ENABLE_SOUND)
    end
    if C_CVar.GetCVar('Sound_MasterVolume')=='0' then
        C_CVar.SetCVar('Sound_MasterVolume', '1.0')
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_MasterVolume|r', WoWTools_Mixin.onlyChinese and '主音量' or MASTER_VOLUME, '1')
    end

    if C_CVar.GetCVar('Sound_DialogVolume')=='0' then
        C_CVar.SetCVar('Sound_DialogVolume', '1.0')
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_DialogVolume|r',WoWTools_Mixin.onlyChinese and '对话' or DIALOG_VOLUME, '1')
    end
    if not C_CVar.GetCVarBool('Sound_EnableDialog') then
        C_CVar.SetCVar('Sound_EnableDialog', '1')
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_EnableDialog|r', WoWTools_Mixin.onlyChinese and '启用对话' or ENABLE_DIALOG)
    end

end










local function Init_Settings()

    EventRegistry:RegisterFrameEventAndCallback("START_TIMER", function(owner, arg1, arg2, arg3)
        if not Save().setPlayerSound then
            return
        end
        if arg2==0 and arg3==0 then
            TimerType= nil
            if Timer4 then Timer4:Cancel() end
            if Timer3 then Timer3:Cancel() end
            if Timer2 then Timer2:Cancel() end
            if Timer1 then Timer1:Cancel() end
            if Timer0 then Timer0:Cancel() end

        elseif arg1 and arg2 and arg2>3 and not TimerType then
            TimerType=arg1
            if arg2>20 then
                Timer4= C_Timer.NewTimer(arg2-10, function()--3
                    WoWTools_Mixin:PlaySound()
                end)
            elseif arg2>=7 then
                WoWTools_Mixin:PlaySound()
            end
            Timer3= C_Timer.NewTimer(arg2-3, function()--3
                WoWTools_Mixin:PlaySound(115003)
            end)
            Timer2= C_Timer.NewTimer(arg2-2, function()--2
                WoWTools_Mixin:PlaySound(115003)
            end)
            Timer1= C_Timer.NewTimer(arg2-1, function()--1
                WoWTools_Mixin:PlaySound(115003)
            end)
            Timer0= C_Timer.NewTimer(arg2, function()--0
                WoWTools_Mixin:PlaySound(114995 )--63971)
                TimerType=nil
            end)
        end
    end)

    EventRegistry:RegisterFrameEventAndCallback("STOP_TIMER_OF_TYPE", function()
        TimerType= nil
        if Timer4 then Timer4:Cancel() end
        if Timer3 then Timer3:Cancel() end
        if Timer2 then Timer2:Cancel() end
        if Timer1 then Timer1:Cancel() end
        if Timer0 then Timer0:Cancel() end
    end)

    
    return true
end










local function Init()
    local enabled= Save().setPlayerSound

    WoWTools_DataMixin.IsSetPlayerSound= enabled--播放, 事件声音

    if enabled and Init_Settings() then
        Init_Settings=function() end
    end

    if enabled then
        if InCombatLockdown() then
            EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner, arg1)
                Set_PlayerSound()
                EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
            end)
        else
            Set_PlayerSound()
        end
    end

    WoWTools_HyperLink.LinkButton.eventSoundTexture:SetShown(enabled)
end




function WoWTools_HyperLink:Init_Event_Sound()
    Init()
end