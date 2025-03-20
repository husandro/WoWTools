local e= select(2, ...)

local function Save()
    return WoWTools_HyperLink.Save
end
















local function Init(LinkButton)
    LinkButton.setPlayerSoundTips= LinkButton:CreateTexture(nil,'OVERLAY')
    LinkButton.setPlayerSoundTips:SetPoint('BOTTOMLEFT',4, 4)
    LinkButton.setPlayerSoundTips:SetSize(12,12)
    LinkButton.setPlayerSoundTips:SetAtlas('chatframe-button-icon-voicechat')
    
 --事件, 声音, 提示图标


    --[[function LinkButton:HandlesGlobalMouseEvent(buttonName, event)
        return event == "GLOBAL_MOUSE_DOWN" and buttonName == "RightButton"
    end
    function LinkButton:Settings()
        self.texture:SetAtlas(not Save().disabed and e.Icon.icon or e.Icon.disabled)
        self.setPlayerSoundTips:SetShown(Save().setPlayerSound)

        self:UnregisterAllEvents()
--欢迎加入, 信息
        if Save().groupWelcome or Save().guildWelcome then
            self:RegisterEvent('CHAT_MSG_SYSTEM')
        end
--事件, 声音
        if Save().setPlayerSound then
            self:RegisterEvent('START_TIMER')
            self:RegisterEvent('STOP_TIMER_OF_TYPE')
        end
--隐藏NPC发言
        if not Save().disabledNPCTalking then
            self:RegisterEvent('TALKINGHEAD_REQUESTED')
        end
    end

    LinkButton:SetScript('OnEvent', function(_, event, arg1, arg2, arg3)
        if event=='CHAT_MSG_SYSTEM' then
            --Event_CHAT_MSG_SYSTEM(arg1)

        elseif event=='START_TIMER' then
            --Event_START_TIMER(arg1, arg2, arg3)

        elseif event=='STOP_TIMER_OF_TYPE' then
            --Event_STOP_TIMER_OF_TYPE()

        elseif event=='TALKINGHEAD_REQUESTED' then
            --Set_Talking()
        end
    end)

    

    LinkButton:Settings()]]
    
end






function WoWTools_HyperLink:Init_Button()
    Init(self.LinkButton)
end

