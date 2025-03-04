--社区 Plus









--公会，社区，在线人数
local function CommunitiesList_ScrollBox(self)
    if not self:GetView() then
        return
    end
    for _, btn in pairs(self:GetFrames() or {}) do
        local online, all= 0, 0
        if btn.clubId then
            local members= C_Club.GetClubMembers(btn.clubId) or {}
            all= #members
            for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
                local info = C_Club.GetMemberInfo(btn.clubId, memberID) or {}
                if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                    online= online+1
                end
            end
        end
        if not btn.onlineText then
            btn.onlineText=WoWTools_LabelMixin:Create(btn, {color={r=1,g=1,b=1}})
            btn.onlineText:SetPoint('TOP', btn.Icon, 'BOTTOM')
        end
        if all>0 then
            btn.onlineText:SetFormattedText('%d/%s%d|r', all, online==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:', online)
        else
            btn.onlineText:SetText('')
        end
    end
end








function WoWTools_GuildMixin:Plus_CommunitiesFrame()
    hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, 'SetScrollTargetOffset', CommunitiesList_ScrollBox)--公会，社区，在线人数
end