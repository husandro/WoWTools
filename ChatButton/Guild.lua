if not IsInGuild() then
    return
end

local id, e = ...
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
panel:SetPoint('LEFT',WoWToolsChatButtonFrame.last, 'RIGHT')--设置位置
WoWToolsChatButtonFrame.last=panel

local function setMembers()--在线人数
    local num = select(2, GetNumGuildMembers())
    num = (num and num>1) and num or nil
    if not panel.membersText and num then
        panel.membersText=e.Cstr(panel, 10, nil, nil, true, nil, 'CENTER')
        panel.membersText:SetPoint('BOTTOM', 0, 7)
    end
    if panel.membersText then
        panel.membersText:SetText(num or '')
    end
end

--####
--初始
--####
local function Init()
    setMembers()--在线人数
    panel.texture:SetAtlas('UI-HUD-MicroMenu-GuildCommunities-Up')
    panel:SetScript('OnMouseDown', function(self, d)
        if d=='LeftButton' then
            e.Say('/g')
        else
            ToggleGuildFrame();
        end
    end)
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