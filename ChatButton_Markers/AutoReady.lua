local e= select(2, ...)
local AutoReadyFrame
local function Save()
    return WoWTools_MarkersMixin.Save
end








--自动就绪
local function Init()
    AutoReadyFrame= CreateFrame('Frame', nil, WoWTools_MarkersMixin.MarkerButton)
    WoWTools_MarkersMixin.AutoReadyFrame= AutoReadyFrame

    AutoReadyFrame:RegisterEvent('READY_CHECK')
    AutoReadyFrame:SetScript('OnEvent', function(self, _, arg1, arg2)
        e.PlaySound(SOUNDKIT.READY_CHECK)--播放, 声音
        if Save().autoReady==1 or Save().autoReady==2 then
            if arg1 and arg1~=UnitName('player') then
                if self.autoReadyTime then
                    self.autoReadyTime:Cancel()
                end
                self.autoReadyTime= C_Timer.NewTimer(3, function()
                    if ReadyCheckFrame and ReadyCheckFrame:IsShown() then
                        ConfirmReadyCheck(Save().autoReady==1 and 1 or nil)
                    end
                end)
                e.Ccool(ReadyCheckListenerFrame, nil, 3, nil, true)--冷却条
            end
        else
            e.Ccool(ReadyCheckListenerFrame, nil, arg2 or 35, nil, true, true)--冷却条
        end
    end)


    local frame=ReadyCheckListenerFrame--自动就绪事件, 提示
    if not frame then
        if e.Player.husandro then
            print('没有 ReadyCheckListenerFrame 自动就绪')
        end
        return
    end


    frame:HookScript('OnHide',function (self)
        if AutoReadyFrame.autoReadyTime then
            AutoReadyFrame.autoReadyTime:Cancel()
        end
    end)

    frame:HookScript('OnUpdate', function(self)
        if AutoReadyFrame.autoReadyTime and not AutoReadyFrame.autoReadyTime:IsCancelled() and IsModifierKeyDown() then
            AutoReadyFrame.autoReadyTime:Cancel()
            e.Ccool(ReadyCheckListenerFrame)
        end
    end)

    frame.autoReadyText= WoWTools_LabelMixin:CreateLabel(frame)
    frame.autoReadyText:SetPoint('BOTTOM', frame, 'TOP')
    frame:HookScript('OnShow',function(self)
        local text=''
        if Save().autoReady==1 then
            text=WoWTools_MarkersMixin.addName
            ..'|n|cnGREEN_FONT_COLOR:'
            ..(e.onlyChinese and '自动就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, READY))
            ..format('|A:%s:0:0|a', e.Icon.select)
        elseif Save().autoReady==2 then
            text=WoWTools_MarkersMixin.addName..'|n|cnRED_FONT_COLOR:'
            ..(e.onlyChinese and '自动未就绪' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, NOT_READY_FEMALE))
            ..'|r'..format('|A:%s:0:0|a', e.Icon.disabled)
        end
        self.autoReadyText:SetText(text)
    end)
end



function WoWTools_MarkersMixin:Init_AutoReady()
    Init()
end