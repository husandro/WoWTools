--local e= select(2, ...)
local function Save()
    return WoWTools_MarkerMixin.Save
end




local function Is_Enable(set)
    if (Save().autoSet or set) and not WoWTools_MapMixin:IsInPvPArea() then
        if IsInGroup() then
            if IsInRaid() then
                return WoWTools_GroupMixin:isLeader()
            else
                return true
            end
        else
            return Save().isSelf or Save().target
        end
    end
end












local function Set_TankHealer(set)--设置队伍标记
    if not Is_Enable(set) then
        return
    end

    local tank, healer, isSelf
    if IsInRaid() then
        local tab={}--设置团队标记
        for index=1, MAX_RAID_MEMBERS do
            local name, _, _, _, _, _, _, online, _, role, _, combatRole= GetRaidRosterInfo(index)
            local unit= 'raid'..index
            if (role=='TANK' or combatRole=='TANK') and online then
                table.insert(tab, {
                    unit=unit,
                    hp=UnitHealthMax(unit)
                })
            elseif name then
                local raidIndex= GetRaidTargetIndex(unit)
                if raidIndex and raidIndex>0 and raidIndex<=8 then
                    WoWTools_MarkerMixin:Set_Taget(unit, 0)
                end
            end
        end
        table.sort(tab, function(a,b) return a.hp>b.hp end)
        if tab[1] then
            WoWTools_MarkerMixin:Set_Taget(tab[1].unit, Save().tank)--设置,目标,标记
            tank=true
        end
        if tab[2] then
            WoWTools_MarkerMixin:Set_Taget(tab[2].unit, Save().tank2)--设置,目标,标记
            tank=true
        end

    elseif IsInGroup() then--设置队伍标记
        for index=1, MAX_PARTY_MEMBERS+1 do
            local unit= index <= MAX_PARTY_MEMBERS and 'party'..index or 'player'
            if UnitExists(unit) and UnitIsConnected(unit) then
                local role=  UnitGroupRolesAssigned(unit)
                if role=='TANK' then
                    if not tank then
                        WoWTools_MarkerMixin:Set_Taget(unit, Save().tank)--设置,目标,标记
                        tank=true
                    end
                elseif role=='HEALER' then
                    if not healer then
                        WoWTools_MarkerMixin:Set_Taget(unit, Save().healer)--设置,目标,标记
                        healer=true
                    end
                else
                    local raidIndex= GetRaidTargetIndex(unit)
                    if raidIndex and raidIndex>0 and raidIndex<=8 then
                        WoWTools_MarkerMixin:Set_Taget(unit, 0)
                    end
                end
            end
        end

    else
        if Save().isSelf then
            WoWTools_MarkerMixin:Set_Taget('player', Save().isSelf or (set and 0))--设置,目标,标记
            isSelf= true
        end
        if Save().target then
            WoWTools_MarkerMixin:Set_Taget('target', Save().target or (set and 0))--设置,目标,标记
            isSelf= true
        end
        
    end
    return tank or healer or isSelf
end












--设置队伍标记
local function Init()
    local frame=CreateFrame("Frame", nil, WoWTools_MarkerMixin.MarkerButton)
    WoWTools_MarkerMixin.TankHealerFrame= frame

    frame:SetPoint('BOTTOMLEFT',4, 4)
    frame:SetSize(12,12)
    frame:SetFrameLevel(WoWTools_MarkerMixin.MarkerButton:GetFrameLevel()+1)

    frame.autoSetTexture= frame:CreateTexture()
    frame.autoSetTexture:SetAtlas('mechagon-projects')
    frame.autoSetTexture:SetAllPoints()






    function frame:set_event()--设置，事件
        if Is_Enable() then
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_LEFT')
            self:RegisterEvent('GROUP_JOINED')
            if Save().target and not IsInGroup() then
                self:RegisterEvent('PLAYER_TARGET_CHANGED')
            end
        else
            self:UnregisterEvent('GROUP_ROSTER_UPDATE')
            self:UnregisterEvent('GROUP_LEFT')
            self:UnregisterEvent('GROUP_JOINED')
            self:UnregisterEvent('PLAYER_TARGET_CHANGED')
        end
    end

    function frame:set_Enabel_Event()
        if Save().autoSet then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:set_event()
        else
            self:UnregisterAllEvents()
        end
        self:SetShown(Save().autoSet and true or false)
    end

    frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_event()
        else
            Set_TankHealer()--设置队伍标记
        end
    end)
    frame:set_Enabel_Event()


    function frame:on_click()
        Set_TankHealer(true)
            --print(WoWTools_Mixin.addName, WoWTools_MarkerMixin.addName, e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '坦克' or TANK, e.onlyChinese and '治疗' or HEALER)
        --else
          --  print(WoWTools_Mixin.addName, WoWTools_MarkerMixin.addName, e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '坦克' or TANK, e.onlyChinese and '治疗' or HEALER, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
        --end
    end

    C_Timer.After(2, function()
        Set_TankHealer()
    end)
end







--设置队伍标记
function WoWTools_MarkerMixin:Init_Tank_Healer()
    Init()
end