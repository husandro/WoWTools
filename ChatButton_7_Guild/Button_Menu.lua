local e= select(2, ...)
local function Save()
    return WoWTools_GuildMixin.Save
end








--主菜单
local function Init_Menu(self, root)
    local sub, text

--公会在线列表
    local total, online = GetNumGuildMembers()
    if online>1 then
        local map=WoWTools_MapMixin:GetUnit('paleyr')
        local maxLevel= GetMaxLevelForLatestExpansion()
        for index=1, total, 1 do
            local name, _, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
            if name and guid and isOnline and guid~=e.Player.guid then
                text=status==1 and format('|T:%s:0|t', FRIENDS_TEXTURE_AFK) or status==2 and format('|T:%s:0|t', FRIENDS_TEXTURE_DND) or ''
                if rankIndex ==0 then
                    text= text..'|TInterface\\GroupFrame\\UI-Group-LeaderIcon:0|t'
                elseif rankIndex == 1 then
                    text= text..'|TInterface\\GroupFrame\\UI-Group-AssistantIcon:0|t'
                end

                text=text..WoWTools_UnitMixin:GetPlayerInfo({guid=guid, name=name, reName=true, reRealm=true})
                text=(lv and lv~=maxLevel) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
                if zone and zone==map then--地区
                    text= text..'|A:poi-islands-table:0:0|a'
                end
               -- text= rankName and text..' '..rankName..(rankIndex or '') or text


                sub=root:CreateButton(text, function(data)
                    WoWTools_ChatMixin:Say(nil, data.name)
                    return MenuResponse.Open
                end, {publicNote=publicNote, officerNote=officerNote, name=name, zone=zone})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine((e.onlyChinese and '密语' or SLASH_TEXTTOSPEECH_WHISPER)..' '..SLASH_WHISPER1..' '..description.data.name)
                    tooltip:AddLine(' ')
                    tooltip:AddLine(description.data.zone)
                    tooltip:AddLine(description.data.publicNote)
                    tooltip:AddLine(description.data.officerNote)
                end)
            end
        end
        root:CreateDivider()
        WoWTools_MenuMixin:SetScrollMode(root)
    end

    if CanReplaceGuildMaster() then--弹劾
        sub=root:CreateButton(e.onlyChinese and '弹劾' or GUILD_IMPEACH_POPUP_CONFIRM, ToggleGuildFrame)
        sub:SetTooltip(function(tooltip)
            tooltip:AddLine(e.onlyChinese and '你所在公会的领袖已被标记为非活动状态。你现在可以争取公会领导权。是否要移除公会领袖？' or GUILD_IMPEACH_POPUP_TEXT, nil,nil,nil, true)
        end)
        root:CreateDivider()
    end

    sub=root:CreateCheckbox(e.onlyChinese and '公会信息' or GUILD_INFORMATION, function()
        return Save().guildInfo
    end, function()
        Save().guildInfo= not Save().guildInfo and true or nil
        self:settings()--事件, 公会新成员, 队伍新成员
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine()
        tooltip:AddLine(e.WoWDate[e.Player.guid].GuildInfo)
    end)


end




function WoWTools_GuildMixin:Init_Menu()
    self.GuildButton:SetupMenu(Init_Menu)
end