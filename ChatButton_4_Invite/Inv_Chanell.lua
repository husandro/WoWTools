local e= select(2, ...)
local function Save()
    return WoWTools_InviteMixin.Save
end










local function Init()
    local frame= CreateFrame('Frame')
    WoWTools_InviteMixin.InvChanellFrame= frame


    function frame:set_event()
        if not Save().Channel then
            self:UnregisterAllEvents()
            WoWTools_InviteMixin.InvPlateGuid={}
        else
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:RegisterEvent('GROUP_LEFT')
            self:RegisterEvent('GROUP_ROSTER_UPDATE')

            if WoWTools_InviteMixin:Get_Leader()
                and not IsInInstance()
            then
                self:RegisterEvent('CHAT_MSG_SAY')
                self:RegisterEvent('CHAT_MSG_WHISPER')
                self:RegisterEvent('CHAT_MSG_YELL')
            else
                self:UnregisterEvent('CHAT_MSG_SAY')
                self:UnregisterEvent('CHAT_MSG_WHISPER')
                self:UnregisterEvent('CHAT_MSG_YELL')
            end
        end
    end


    frame:SetScript('OnEvent', function(self, event, arg1, ...)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_event()
            WoWTools_InviteMixin.InvPlateGuid={}

        elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
            self:set_event()

        elseif event=='CHAT_MSG_SAY' or event=='CHAT_MSG_YELL' or  event=='CHAT_MSG_WHISPER' then
            local text= arg1 and string.upper(arg1)
            if Save().Channel and text and text:find(Save().ChannelText) then
                local co= GetNumGroupMembers()
                --toRaidOrParty(co)--自动, 转团
                if co<5 or (IsInRaid() and co<40) then
                    local guid= select(11, ...)
                    local name= ...
                    if guid and name and name~=e.Player.ame_server then
                        C_PartyInfo.InviteUnit(name)

                        WoWTools_InviteMixin.InvPlateGuid[guid]=name--保存到已邀请列表

                        print(WoWTools_DataMixin.Icon.icon2..WoWTools_InviteMixin.addName, WoWTools_Mixin.onlyChinese and '频道' or CHANNEL, WoWTools_UnitMixin:GetLink(name, guid))
                    end
                end
            end
        end
    end)

    frame:set_event()
end









function WoWTools_InviteMixin:Init_Chanell()
    Init()
end

