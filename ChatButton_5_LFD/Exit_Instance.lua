local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end

local ExitIns




local function Save_Instance_Num(name)
    name= name or GetInstanceInfo()
    if name then
        Save().wow[name]= (Save().wow[name] or 0)+1
    end
end



local function exit_Instance()
    local ins = IsInInstance()
    if not ExitIns or not ins or IsModifierKeyDown() or LFGDungeonReadyStatus:IsVisible() or LFGDungeonReadyDialog:IsVisible() then
        ExitIns= nil
        StaticPopup_Hide('WoWTools_LFD_ExitIns')
        return
    end
    local name= GetInstanceInfo()

    Save_Instance_Num(name)

    local num= WoWTools_LFDMixin:Get_Instance_Num(name)

    if IsInLFDBattlefield() then
        local currentMapID, _, lfgID = select(8, GetInstanceInfo())
        if lfgID then
            local _, _, subtypeID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgMapID = GetLFGDungeonInfo(lfgID)
            if currentMapID == lfgMapID and subtypeID == LE_LFG_CATEGORY_BATTLEFIELD then
                LFGTeleport(true)
            end
        end
    else
        C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
    end


    print(e.Icon.icon2..WoWTools_LFDMixin.addName,
        e.onlyChinese and '离开' or LEAVE,
        e.cn(name) or e.onlyChinese and '副本' or INSTANCE,
        num
    )
    ExitIns=nil
end

 










local function Init_Frame()
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('LFG_COMPLETION_REWARD')
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:RegisterEvent('ISLAND_COMPLETED')
    frame:RegisterEvent('PVP_MATCH_COMPLETE')

    frame:SetScript('OnEvent', function(self, event)
        if event=='LFG_COMPLETION_REWARD' or event=='LOOT_CLOSED' then--or event=='SCENARIO_COMPLETED' then--自动离开
            if Save().leaveInstance
                and IsInLFGDungeon()
                and IsLFGComplete()
                and not LFGDungeonReadyStatus:IsVisible()
                and not LFGDungeonReadyDialog:IsVisible()
                and not StaticPopup_Visible('WoWTools_LFD_ExitIns') then
                    WoWTools_Mixin:PlaySound()--播放, 声音
                    local leaveSce= 30
                    if Save().autoROLL and event=='LOOT_CLOSED' then
                        leaveSce= WoWTools_LFDMixin.Save.sec
                    end
                    ExitIns=true
                    C_Timer.After(leaveSce, function()
                        exit_Instance()
                    end)
                    StaticPopup_Show('WoWTools_LFD_ExitIns')
                    WoWTools_CooldownMixin:Setup(StaticPopup1, nil, leaveSce, nil, true, true)--冷却条
            end

        elseif event=='PLAYER_ENTERING_WORLD' then
            if IsInInstance() then--自动离开
                self:RegisterEvent('LOOT_CLOSED')
            else
                self:UnregisterEvent('LOOT_CLOSED')
            end
            ExitIns=nil

        elseif event=='ISLAND_COMPLETED' then--离开海岛
            Save_Instance_Num('island')
            if not Save().leaveInstance then
                return
            end
            WoWTools_Mixin:PlaySound()--播放, 声音
            C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE)
            LFGTeleport(true)
            print(e.Icon.icon2..WoWTools_LFDMixin.addName,
                e.onlyChinese and '海岛探险' or ISLANDS_HEADER,
                WoWTools_LFDMixin:Get_Instance_Num('island')
            )
            
        elseif event=='PVP_MATCH_COMPLETE' then--离开战场
            if Save().leaveInstance then
                WoWTools_Mixin:PlaySound()--播放, 声音
                if PVPMatchResults and PVPMatchResults.buttonContainer and PVPMatchResults.buttonContainer.leaveButton then
                    WoWTools_CooldownMixin:Setup(PVPMatchResults.buttonContainer.leaveButton, nil, WoWTools_LFDMixin.Save.sec, nil, true, true)
                end
                print(e.Icon.icon2..WoWTools_LFDMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '离开战场' or LEAVE_BATTLEGROUND), SecondsToTime(WoWTools_LFDMixin.Save.sec))
                C_Timer.After(WoWTools_LFDMixin.Save.sec, function()
                    if not IsModifierKeyDown() then
                        if IsInLFDBattlefield() then
                            ConfirmOrLeaveLFGParty()
                        else
                            ConfirmOrLeaveBattlefield()
                        end
                    end
                end)
            end
        end
    end)
end







local function Init()
    StaticPopupDialogs['WoWTools_LFD_ExitIns']={
        text =WoWTools_Mixin.addName..' '..WoWTools_LFDMixin.addName..'|n|n|cff00ff00'..(e.onlyChinese and '离开' or LEAVE)..'|r: ' ..(e.onlyChinese and '副本' or INSTANCE).. '|cff00ff00 '..WoWTools_LFDMixin.Save.sec..' |r'..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS),
        button1 = e.onlyChinese and '离开' or  LEAVE,
        button2 = e.onlyChinese and '取消' or CANCEL,
        OnAccept=function()
            ExitIns=true
            exit_Instance()
        end,
        OnCancel=function(_, _, d)
            if d=='clicked' then
                ExitIns=nil
                print(e.Icon.icon2..WoWTools_LFDMixin.addName,'|cff00ff00'..(e.onlyChinese and '取消' or CANCEL)..'|r', e.onlyChinese and '离开' or LEAVE)
            end
        end,
        OnUpdate= function(self)
            if IsModifierKeyDown() then
                self:Hide()
                ExitIns=nil
            end
        end,
        EditBoxOnEscapePressed = function(s)
            s:SetAutoFocus(false)
            s:ClearFocus()
            ExitIns=nil
            print(e.Icon.icon2..WoWTools_LFDMixin.addName,'|cff00ff00'..(e.onlyChinese and '取消' or CANCEL)..'|r', e.onlyChinese and '离开' or LEAVE)
            s:GetParent():Hide()
        end,
        whileDead=true, hideOnEscape=true, exclusive=true,
        timeout=WoWTools_LFDMixin.Save.sec}

    Init_Frame()
    LFGDungeonReadyStatus:HookScript('OnShow', function()
        if Save().leaveInstance then
            exit_Instance()
        end
    end)
    LFGDungeonReadyDialog:HookScript('OnShow', function()
        if Save().leaveInstance then
            exit_Instance()
        end
    end)
end






function WoWTools_LFDMixin:Init_Exit_Instance()
    Init()
end