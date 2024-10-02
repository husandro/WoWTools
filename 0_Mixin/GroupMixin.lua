WoWTools_GroupMixin={}

--队长(团长)或助理
function WoWTools_GroupMixin:isLeader()--队长(团长)或助理
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player')
end

--在团长或助理
function WoWTools_GroupMixin:isRaidLeader()--在团长或助理
    return IsInRaid() and (UnitIsGroupAssistant('player') or UnitIsGroupLeader('player'))
end






--[[社区列表
function WoWTools_GroupMixin:GetClubList(all)--社区列表
    local online, new=0, {}
    
    local guildClubId= C_Club.GetGuildClubId()
    for _, tab in pairs(C_Club.GetSubscribedClubs() or {}) do
        if tab and tab.clubId then

            local members= tab and C_Club.GetClubMembers(tab.clubId)
            local isGuildClub= tab.clubId==guildClubId
            
            if members and (not isGuildClub or all) then

                local clubOnline=0
                local playerList={}
                for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
                    local info = C_Club.GetMemberInfo(tab.clubId, memberID) or {}
                    if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                        online= online+1
                        clubOnline= clubOnline+1
                        table.insert(playerList, info)
                    end
                end

                tab.isGuildClub= isGuildClub
                tab.clubOnline= clubOnline
                tab.num= members
                tab.player=playerList
                table.insert(new, tab)
            end
        end
    end
    return online, new
end]]