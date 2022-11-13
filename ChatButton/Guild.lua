if not IsInGuild() then
    return
end

local id, e = ...
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local function setMembers()--在线人数
    local num = select(2, GetNumGuildMembers())
    num = (num and num>1) and num-1 or nil
    if not panel.membersText and num then
        panel.membersText=e.Cstr(panel, 10, nil, nil, true, nil, 'CENTER')
        panel.membersText:SetPoint('BOTTOM', 0, 7)
    end
    if panel.membersText then
        panel.membersText:SetText(num or '')
    end
end


--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单    
    local info
    for index=1,  GetNumGuildMembers() do
        local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        if name and guid and isOnline and name~=e.Player.name_server then
            print(classDisplayName)
            local map=e.GetUnitMapName('paleyr')
            local text=e.GetPlayerInfo(nil, guid, true, true)--名称
            text=(lv and lv~=MAX_PLAYER_LEVEL) and text..' |cnGREEN_FONT_COLOR:'..lv..'|r' or text--等级
            if zone then--地区
                text= zone==map and text..e.Icon.map2 or text..' '..zone
            end
            text= rankName and text..' '..rankName..(rankIndex or '') or text
            info={
                text=text,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle=publicNote or '',
                tooltipText=officerNote or '',
                icon= status==1 and FRIENDS_TEXTURE_AFK or status==2 and FRIENDS_TEXTURE_DND,
                func=function()
                    e.Say(nil, name)
                end
            }
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

--####
--初始
--####
local function Init()
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    setMembers()--在线人数
    panel.texture:SetAtlas('UI-HUD-MicroMenu-GuildCommunities-Mouseover')
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            e.Say('/g')
        else
            if select(2, GetNumGuildMembers())>1 then
                ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
            else
                ToggleGuildFrame()
            end
        end
    end)

    if CanReplaceGuildMaster() then--弹劾
        panel.canReplaceGuildMaster=e.Cstr(panel, 10, nil, nil, true, nil, 'CENTER')
        panel.canReplaceGuildMaster:SetPoint('TOP')
        panel.canReplaceGuildMaster:SetText('|cnGREEN_FONT_COLOR:'..GUILD_IMPEACH_POPUP_CONFIRM..'|r')
    end
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('GUILD_ROSTER_UPDATE')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:SetShown(false)
            panel:UnregisterAllEvents()
        else
            Init()
        end
    elseif event=='GUILD_ROSTER_UPDATE' then
        setMembers()--在线人数
    end
end)