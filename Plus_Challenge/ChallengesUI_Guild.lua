local function Save()
    return WoWToolsSave['Plus_Challenges'] or {}
end
local Frame

local function Set_List()
    local data= C_ChallengeMode.GetGuildLeaders()
    print('guild' , data)
    if not data then
        return
    end
    info= data
    for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('|cffff0000---',k, '---END') else print(k,v) end end print('|cffff00ff——————————')

end




local function Init()
    if not IsInGuild() or Save().hideGuild then
        return
    end

    Frame= CreateFrame('Frame', nil, ChallengesFrame)
    Frame:SetFrameLevel(PVEFrame.TitleContainer:GetFrameLevel()+1)

    Frame:SetSize(1,1)
    Frame:Hide()

    function Frame:Settings()
        local show= not Save().hideGuild
        self:SetPoint('TOPLEFT', ChallengesFrame, 'TOPLEFT', Save().guildX or 10, Save().guildY or -53)
        self:SetShown(show)
        self:SetScale(Save().guildScale or 1)
        if show then
            Set_List()
        end 
     end

     Frame:Settings()

    Init=function()
        Frame:Settings()
    end
end


function WoWTools_ChallengeMixin:ChallengesUI_Guild()
    if not IsInGuild() or not WoWTools_DataMixin.Player.husandro then
        return
    end
    Init()
end