local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end

--#########
--事件, 声音
--#########
local function Set_PlayerSound()--事件, 声音
    if not Save().setPlayerSound or UnitAffectingCombat('player') then
        return
    end

    if not C_CVar.GetCVarBool('Sound_EnableAllSound') then
        C_CVar.SetCVar('Sound_EnableAllSound', '1')
        print(e.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_EnableAllSound|r', e.onlyChinese and '开启声效' or ENABLE_SOUND)
    end
    if C_CVar.GetCVar('Sound_MasterVolume')=='0' then
        C_CVar.SetCVar('Sound_MasterVolume', '1.0')
        print(e.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_MasterVolume|r', e.onlyChinese and '主音量' or MASTER_VOLUME, '1')
    end

    if C_CVar.GetCVar('Sound_DialogVolume')=='0' then
        C_CVar.SetCVar('Sound_DialogVolume', '1.0')
        print(e.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_DialogVolume|r',e.onlyChinese and '对话' or DIALOG_VOLUME, '1')
    end
    if not C_CVar.GetCVarBool('Sound_EnableDialog') then
        C_CVar.SetCVar('Sound_EnableDialog', '1')
        print(e.Icon.icon2..WoWTools_HyperLink.addName, '|cnGREEN_FONT_COLOR:CVar Sound_EnableDialog|r', e.onlyChinese and '启用对话' or ENABLE_DIALOG)
    end
    
end



local function Event_STOP_TIMER_OF_TYPE()
    LinkButton.timerType= nil
    if LinkButton.timer4 then LinkButton.timer4:Cancel() end
    if LinkButton.timer3 then LinkButton.timer3:Cancel() end
    if LinkButton.timer2 then LinkButton.timer2:Cancel() end
    if LinkButton.timer1 then LinkButton.timer1:Cancel() end
    if LinkButton.timer0 then LinkButton.timer0:Cancel() end
end




local function Event_START_TIMER(arg1, arg2, arg3)
    if not Save().setPlayerSound then
        return
    end
    if arg2==0 and arg3==0 then
        LinkButton.timerType= nil
        if LinkButton.timer4 then LinkButton.timer4:Cancel() end
        if LinkButton.timer3 then LinkButton.timer3:Cancel() end
        if LinkButton.timer2 then LinkButton.timer2:Cancel() end
        if LinkButton.timer1 then LinkButton.timer1:Cancel() end
        if LinkButton.timer0 then LinkButton.timer0:Cancel() end

    elseif arg1 and arg2 and arg2>3 and not LinkButton.timerType then
        LinkButton.timerType=arg1
        if arg2>20 then
            LinkButton.timer4= C_Timer.NewTimer(arg2-10, function()--3
                e.PlaySound()
            end)
        elseif arg2>=7 then
            e.PlaySound()
        end
        LinkButton.timer3= C_Timer.NewTimer(arg2-3, function()--3
            e.PlaySound(115003)
        end)
        LinkButton.timer2= C_Timer.NewTimer(arg2-2, function()--2
            e.PlaySound(115003)
        end)
        LinkButton.timer1= C_Timer.NewTimer(arg2-1, function()--1
            e.PlaySound(115003)
        end)
        LinkButton.timer0= C_Timer.NewTimer(arg2, function()--0
            e.PlaySound(114995 )--63971)
            LinkButton.timerType=nil
        end)
    end
end