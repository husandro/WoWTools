--[[
MK
]]

local e= select(2, ...)
WoWTools_Mixin={}



function WoWTools_Mixin:MK(number, bit)
    if not number then
        return
    end
    bit = bit or 1

    local text= ''
    if number>=1e6 then
        number= number/1e6
        text= 'm'
    elseif number>= 1e4 and e.onlyChinese then
        number= number/1e4
        text='w'
    elseif number>=1e3 then
        number= number/1e3
        text= 'k'
    end
    if bit==0 then
        number= math.modf(number)
        number= number==0 and 0 or number
        return number..text--format('%i', number)..text
    else
        local num, point= math.modf(number)
        if point==0 then
            return num..text
        else---0.5/10^bit
            return format('%0.'..bit..'f', number)..text
        end
    end
end







--版本
function WoWTools_Mixin:GetExpansionText(expacID, questID)
    if not expacID and questID then
        expacID= GetQuestExpansion(questID)
    end
    if expacID and _G['EXPANSION_NAME'..expacID] then
        local text= e.cn(_G['EXPANSION_NAME'..expacID])
        if e.ExpansionLevel >= expacID then
            return text, (e.onlyChinese and '版本' or GAME_VERSION_LABEL)..' '..(expacID+1)
        else
            return '|cff828282'..text..'|r', '|cff828282'..(e.onlyChinese and '版本' or GAME_VERSION_LABEL)..' '..(expacID+1)..'|r'
        end
    end
end




--[[
function e.Is_Chinese_Text(str)--字符中，是否有汉字
    if str then
        for i = 1, #str do
            local uchar = string.byte(str, i)
            -- 如果字符不是单字节ASCII字符（即不在0x00-0x7F之间）
            if uchar > 0x7F then
                -- 这里可以添加更精确的检查来确保是汉字，但简单起见，我们假设所有非ASCII字符都是汉字
                return true
            end
        end
        return false
    end
end
]]




function WoWTools_Mixin:Reload(isControlKeyDown)
    if not (UnitAffectingCombat('player') and e.IsEncouter_Start) or not IsInInstance() then
        if isControlKeyDown and IsControlKeyDown() or not isControlKeyDown then
            C_UI.Reload()
        end
    else
        print(e.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
    end
end



--距离
local LibRangeCheck = LibStub("LibRangeCheck-3.0", true)
function e.GetRange(unit, checkVisible)--WA Prototypes.lua
    return LibRangeCheck:GetRange(unit, checkVisible)
end

--距离
function e.CheckRange(unit, range, operator)
    local min, max= LibRangeCheck:GetRange(unit, true)
    if (operator) then-- == "<=") then
        return (max or 999) <= range
    else
        return (min or 0) >= range
    end
end


function e.Get_CVar_Tooltips(info)--取得CVar信息 e.Get_CVar_Tooltips({name= ,msg=, value=})
    return (info.msg and info.msg..'|n' or '')..info.name..'|n'
    ..(info.value and C_CVar.GetCVar(info.name)== info.value and format('|A:%s:0:0|a', e.Icon.select) or '')
    ..(info.value and (e.onlyChinese and '设置' or SETTINGS)..info.value..' ' or '')
    ..'('..(e.onlyChinese and '当前' or REFORGE_CURRENT)..'|cnGREEN_FONT_COLOR:'..format('%.1f',C_CVar.GetCVar(info.name))..'|r |r'
    ..(e.onlyChinese and '默认' or DEFAULT)..'|cffff00ff'..format('%.1f', C_CVar.GetCVarDefault(info.name))..')|r'
end





function e.PlaySound(soundKitID, setPlayerSound)--播放, 声音 SoundKitConstants.lua e.PlaySound()--播放, 声音
    if not C_CVar.GetCVarBool('Sound_EnableAllSound') or C_CVar.GetCVar('Sound_MasterVolume')=='0' or (not setPlayerSound and not e.setPlayerSound) then
        return
    end
    local channel

    if C_CVar.GetCVarBool('Sound_EnableDialog') and C_CVar.GetCVar("Sound_DialogVolume")~='0' then
        channel= 'Dialog'
    elseif C_CVar.GetCVarBool('Sound_EnableAmbience') and C_CVar.GetCVar("Sound_AmbienceVolume")~='0' then
        channel= 'Ambience'
    elseif C_CVar.GetCVarBool('Sound_EnableSFX') and C_CVar.GetCVar("Sound_SFXVolume")~='0' then
        channel= 'SFX'
    elseif C_CVar.GetCVarBool('Sound_EnableMusic') and C_CVar.GetCVar("Sound_MusicVolume")~='0' then
        channel= 'Music'
    else
        channel= 'Master'
    end
    local success, voHandle= PlaySound(soundKitID or SOUNDKIT.GS_CHARACTER_SELECTION_ENTER_WORLD, channel)--SOUNDKIT.READY_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.LFG_ROLE_CHECK SOUNDKIT.IG_PLAYER_INVITE
    return success, voHandle
end


--公会， 社区，信息
function e.Get_Guild_Enter_Info()
    local clubs= C_Club.GetSubscribedClubs() or {}
    if IsInGuild() then
        local all, online, app = GetNumGuildMembers()
        local guildName, guildRankName, _, realm = GetGuildInfo('player')
        e.tips:AddDoubleLine(guildName..(realm and realm~=e.Player.realm and '-'..realm or ' ')..' ('..all..')', guildRankName)
        local day= GetGuildRosterMOTD()--今天信息
        if day and day~='' then
            e.tips:AddLine('|cffff00ff'..day..'|r', nil,nil, nil, true)
        end
        local col= online>1 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'
        e.tips:AddDoubleLine(col..(e.onlyChinese and '在线成员：' or GUILD_MEMBERS_ONLINE_COLON), col..'|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'..(online-1)..'|r/|A:UI-ChatIcon-App:0:0|a'..(app-1))
        if #clubs>0 then
            e.tips:AddLine(' ')
        end
    end
    local guildClubId= C_Club.GetGuildClubId()
    local all=0
    for _, tab in pairs(clubs) do
        local members= C_Club.GetClubMembers(tab.clubId) or {}
        local online= 0
        for _, memberID in pairs(members) do--CommunitiesUtil.GetOnlineMembers
            local info = C_Club.GetMemberInfo(tab.clubId, memberID) or {}
            if not info.isSelf and info.presence~=Enum.ClubMemberPresence.Offline and info.presence~=Enum.ClubMemberPresence.Unknown then--CommunitiesUtil.GetOnlineMembers()
                online= online+1
                all= all+1
            end
        end
        local icon=(tab.clubId==guildClubId) and '|A:auctionhouse-icon-favorite:0:0|a' or '|T'..tab.avatarId..':0|t'
        local col= online>0 and '|cnGREEN_FONT_COLOR:' or '|cff9e9e9e'
        e.tips:AddDoubleLine(icon..col..tab.name, col..online..icon)--..tab.memberCount
    end
end











