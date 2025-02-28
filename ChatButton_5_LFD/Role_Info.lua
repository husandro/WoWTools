
--小眼睛, 更新信息
local e= select(2, ...)
local function Save()
    return WoWTools_LFDMixin.Save
end
local Button








--职责确认，信息
local RoleC
local function get_Role_Info(env, Name, isT, isH, isD)
    if env=='LFG_ROLE_CHECK_DECLINED' then
        if Button then
            Button.text:SetText('')
            Button:Hide()
        end
        local co=GetNumGroupMembers()
        if co and co>0 then
            local find
            local u= IsInRaid() and 'raid' or 'party'
            for i=1, co do
                local unit=u..i
                if UnitExists(unit) and not UnitIsUnit('player', unit) then
                    local guid=UnitGUID(unit)
                    local line= WoWTools_UnitMixin:GetOnlineInfo(unit)
                    if line and guid then
                        print(i..')',
                                line,
                                WoWTools_UnitMixin:GetPlayerInfo(unit, guid, nil, {faction=UnitFactionGroup(unit), reLink=true}),
                                '|A:poi-islands-table:0:0|a',
                                WoWTools_MapMixin:GetUnit(unit)
                            )
                        find=true
                    end
                end
            end
        end
        return

    elseif env=='UPDATE_BATTLEFIELD_STATUS' or env=='LFG_QUEUE_STATUS_UPDATE' or env=='GROUP_LEFT' or env=='PLAYER_ROLES_ASSIGNED' then
        if Button then
            Button.text:SetText('')
            Button:Hide()
            RoleC=nil
        end
        return
    end

    if not Name or not (isT or  isH or  isD) then
        return
    end

    if env=='LFG_ROLE_CHECK_ROLE_CHOSEN' then--队长重新排本
        if RoleC and RoleC[Name] then
            local u=RoleC[Name].unit
            if u and UnitIsGroupLeader(u) then
                RoleC=nil
            end
        end
    end

    local co=GetNumGroupMembers()
    if co and co>0 then
        if not RoleC then
            RoleC={}
            local raid=IsInRaid()
            local u= raid and 'raid' or 'party'
            for i=1, co do
                local u2=u..i
                if not raid and i==co then
                    u2='player'
                end
                local guid= UnitExists(u2) and UnitGUID(u2)
                if guid then
                    local info=(
                                WoWTools_UnitMixin:GetOnlineInfo(u2) or '')
                                ..WoWTools_UnitMixin:GetPlayerInfo(u2, guid, nil, {reName=true, reRealm=true}
                            )
                    local name=GetUnitName(u2,true)
                    local player=UnitIsUnit('player', u2)
                    RoleC[name]={
                        info=info,
                        index=i,
                        unit=u2,
                        player=player,
                    }
                end
            end
        end

        local all=0
        local role=''
        if RoleC[Name] then
            if isT then role=role..INLINE_TANK_ICON end
            if isH then role=role..INLINE_HEALER_ICON end
            if isD then role=role..INLINE_DAMAGER_ICON end
            RoleC[Name].role=role
        else
            all=1
        end

        local m=''
        local playerMapID=select(2, WoWTools_MapMixin:GetUnit('player'))
        for k, v in pairs(RoleC) do
            if v then
                if m~='' then m=m..'|n' end
                m=m..(v.role and v.role or v.index..')')..(v.info or k)
                if v.role then
                    all=all+1
                end
                local text, unitMapID=WoWTools_MapMixin:GetUnit(v.unit)
                if text and unitMapID~= playerMapID then
                    m=m..'|cnRED_FONT_COLOR:|A:poi-islands-table:0:0|a'..text..'|r'
                end
            end
        end

        if m~='' and not Button then
            Button=WoWTools_ButtonMixin:Cbtn(nil, {size=20})
            if Save().RoleInfoPoint then
                Button:SetPoint(Save().RoleInfoPoint[1], UIParent, Save().RoleInfoPoint[3], Save().RoleInfoPoint[4], Save().RoleInfoPoint[5])
            else
                Button:SetPoint('TOPLEFT', WoWTools_LFDMixin.LFDButton, 'BOTTOMLEFT', 40, 40)
                Button:SetButtonState('PUSHED')
            end
            Button:RegisterForDrag("RightButton")
            Button:SetMovable(true)
            Button:SetClampedToScreen(true)
            Button:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)
            Button:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save().RoleInfoPoint={self:GetPoint(1)}
                Save().RoleInfoPoint[2]=nil
            end)
            Button:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_LFDMixin.addName)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '全部清除' or CLEAR_ALL, e.Icon.left)
                e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
                e.tips:Show()
            end)
            Button:SetScript('OnLeave', GameTooltip_Hide)
            Button:SetScript('OnMouseDown', function(self, d)
                if d=='RightButton' then--移动光标
                    SetCursor('UI_MOVE_CURSOR')
                elseif d=='LeftButton' then
                    self.text:SetText('')
                    self:SetShown(false)
                end
            end)
            Button:SetScript("OnMouseUp", function(self)
                ResetCursor()
            end)
            Button.text=WoWTools_LabelMixin:Create(Button)
            Button.text:SetPoint('BOTTOMLEFT')--, Button, 'BOTTOMRIGHT')
            Button:SetShown(false)
        end
        if Button then
            Button.text:SetText(m)
            Button:SetShown(m~='')
        end

    elseif Button then
        Button:SetShown(false)
    end
end



















local function Init()
    local frame= CreateFrame('Frame')
    frame:RegisterEvent('LFG_ROLE_CHECK_ROLE_CHOSEN')
    frame:RegisterEvent('LFG_ROLE_CHECK_DECLINED')
    frame:RegisterEvent('LFG_QUEUE_STATUS_UPDATE')
    frame:RegisterEvent('UPDATE_BATTLEFIELD_STATUS')
    frame:RegisterEvent('GROUP_LEFT')
    frame:RegisterEvent('PLAYER_ROLES_ASSIGNED')

    frame:SetScript('OnEvent', function(self, ...)
        get_Role_Info(...)--职责确认        
    end)

end




function WoWTools_LFDMixin:Init_Role_CheckInfo()--职责确认，信息
    Init()
end