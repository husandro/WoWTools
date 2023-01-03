if not IsInGuild() then--仅有公会时加载
    return
end

local id, e = ...
local Save={}
local addName='ChatButtonGuild'

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

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

--#######
--公会信息
--#######
local guildMS= GUILD_INFO_TEMPLATE:gsub('(%%.+)', '')--公会创立
local function set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
    if Save.guildInfo or not e.WoWSave[e.Player.guid].GuildInfo then
        panel:RegisterEvent('CHAT_MSG_SYSTEM')
        GuildInfo()
    else
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    end
end

local function setMsg_CHAT_MSG_SYSTEM(text)--欢迎加入, 信息
    if text:find(guildMS) then
        e.WoWSave[e.Player.guid].GuildInfo= text
        panel:UnregisterEvent('CHAT_MSG_SYSTEM')
    end
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单    
    local info
    local find
    for index=1,  GetNumGuildMembers() do
        local name, rankName, rankIndex, lv, _, zone, publicNote, officerNote, isOnline, status, _, _, _, _, _, _, guid = GetGuildRosterInfo(index)
        if name and guid and isOnline and name~=e.Player.name_server then
            find=true
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
    if find then
        UIDropDownMenu_AddSeparator(level)
    end
    info={
        text=e.onlyChinse and '公会信息' or GUILD_INFORMATION,
        checked=Save.guildInfo,
        tooltipOnButton=true,
        tooltipTitle=e.WoWSave[e.Player.guid].GuildInfo or NONE,
        func=function()
            Save.guildInfo= not Save.guildInfo and true or nil
            set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
        end
    }
    UIDropDownMenu_AddButton(info, level)

    --[[
if CanReplaceGuildMaster() then--弹劾,污染
        info={
            text=GUILD_IMPEACH_POPUP_CONFIRM,
            notCheckable=true,
            func=function()
                ReplaceGuildMaster()
            end
        }
        UIDropDownMenu_AddButton(info, level)
    end

]]

end

--####
--初始
--####
local function Init()
    panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
    WoWToolsChatButtonFrame.last=panel

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    setMembers()--在线人数
    panel.texture:SetAtlas('UI-HUD-MicroMenu-GuildCommunities-Up')
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            e.Say('/g')
        else
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
            --ToggleGuildFrame()
        end
    end)

    if CanReplaceGuildMaster() then--弹劾
        panel.canReplaceGuildMaster=e.Cstr(panel, 10, nil, nil, true, nil, 'CENTER')
        panel.canReplaceGuildMaster:SetPoint('TOP')
        panel.canReplaceGuildMaster:SetText('|cnGREEN_FONT_COLOR:'..GUILD_IMPEACH_POPUP_CONFIRM..'|r')
    end

    set_CHAT_MSG_SYSTEM()--事件, 公会新成员, 队伍新成员
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('GUILD_ROSTER_UPDATE')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='GUILD_ROSTER_UPDATE' then
        setMembers()--在线人数

    elseif event=='CHAT_MSG_SYSTEM' then
        setMsg_CHAT_MSG_SYSTEM(arg1)--欢迎加入, 信息
    end
end)