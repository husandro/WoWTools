WoWTools_GroupMixin={}

function WoWTools_GroupMixin:isLeader()--队长(团长)或助理
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player')
end

function WoWTools_GroupMixin:isRaidLeader()--在团长或助理
    return IsInRaid() and (UnitIsGroupAssistant('player') or UnitIsGroupLeader('player'))
end