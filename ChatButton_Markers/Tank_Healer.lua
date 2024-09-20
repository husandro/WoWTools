local e= select(2, ...)
local function Save()
    return WoWTools_MarkersMixin.Save
end













--设置队伍标记
local function Init()
    local frame=CreateFrame("Frame", nil, WoWTools_MarkersMixin.MarkerButton)
    WoWTools_MarkersMixin.TankHealerFrame= frame

    frame:SetPoint('BOTTOMLEFT',4, 4)
    frame:SetSize(12,12)
    frame:SetFrameLevel(WoWTools_MarkersMixin.MarkerButton:GetFrameLevel()+1)

    frame.autoSetTexture= frame:CreateTexture()
    frame.autoSetTexture:SetAtlas('mechagon-projects')
    frame.autoSetTexture:SetAllPoints()


    function frame:check_Enable(set)
        return (Save().autoSet or set) and WoWTools_GroupMixin:isLeader() and IsInGroup() and not WoWTools_MapMixin:IsInPvPArea()
    end

    function frame:set_TankHealer(set)--设置队伍标记
        if not self:check_Enable(set) then
            return
        end
        local tank, healer
        if IsInRaid() then
            local tab={}--设置团队标记
            for index=1, MAX_RAID_MEMBERS do-- GetNumGroupMembers
                --local online, _, role, _, combatRole = select(8, GetRaidRosterInfo(index))
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
                        WoWTools_MarkersMixin:Set_Taget(unit, 0)
                    end
                end
            end
            table.sort(tab, function(a,b) return a.hp>b.hp end)
            if tab[1] then
                WoWTools_MarkersMixin:Set_Taget(tab[1].unit, Save().tank)--设置,目标,标记
                tank=true
            end
            if tab[2] then
                WoWTools_MarkersMixin:Set_Taget(tab[2].unit, Save().tank2)--设置,目标,标记
                tank=true
            end

        else--设置队伍标记
            for index=1, MAX_PARTY_MEMBERS+1 do
                local unit= index <= MAX_PARTY_MEMBERS and 'party'..index or 'player'
                if UnitExists(unit) and UnitIsConnected(unit) then
                    local role=  UnitGroupRolesAssigned(unit)
                    if role=='TANK' then
                        if not tank then
                            WoWTools_MarkersMixin:Set_Taget(unit, Save().tank)--设置,目标,标记
                            tank=true
                        end
                    elseif role=='HEALER' then
                        if not healer then
                            WoWTools_MarkersMixin:Set_Taget(unit, Save().healer)--设置,目标,标记
                            healer=true
                        end
                    else
                        local raidIndex= GetRaidTargetIndex(unit)
                        if raidIndex and raidIndex>0 and raidIndex<=8 then
                            WoWTools_MarkersMixin:Set_Taget(unit, 0)
                        end
                    end
                end
            end
        end
        return tank or healer
    end



    function frame:set_Event()--设置，事件
        if self:check_Enable() then
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
            self:RegisterEvent('GROUP_LEFT')
            self:RegisterEvent('GROUP_JOINED')

        else
            self:UnregisterEvent('GROUP_ROSTER_UPDATE')
            self:UnregisterEvent('GROUP_LEFT')
            self:UnregisterEvent('GROUP_JOINED')
        end
    end

    function frame:set_Enabel_Event()
        if Save().autoSet then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            self:set_Event()
        else
            self:UnregisterAllEvents()
        end
        self:SetShown(Save().autoSet and true or false)
    end

    frame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' then
            self:set_Event()
        else
            self:set_TankHealer()--设置队伍标记
        end
    end)

    frame:set_Enabel_Event()

    function frame:on_click()
        if self:set_TankHealer(true) then--设置队伍标记
            print(e.addName, WoWTools_MarkersMixin.addName, e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '坦克' or TANK, e.onlyChinese and '治疗' or HEALER)
        else
            print(e.addName, WoWTools_MarkersMixin.addName, e.onlyChinese and '设置' or SETTINGS, e.onlyChinese and '坦克' or TANK, e.onlyChinese and '治疗' or HEALER, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
        end
    end
end





--设置队伍标记
function WoWTools_MarkersMixin:Init_Tank_Healer()
    Init()
end