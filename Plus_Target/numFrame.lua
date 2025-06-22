--怪物目标, 队员目标, 总怪物

local Frame
local numFrame
local numButton

local function Save()
    return WoWToolsSave['Plus_Target']
end


local EventTab= {
    'NAME_PLATE_UNIT_ADDED',
    'NAME_PLATE_UNIT_REMOVED',
    'UNIT_TARGET',
    'PLAYER_ENTERING_WORLD'
    --'FORBIDDEN_NAME_PLATE_UNIT_ADDED',
    --'FORBIDDEN_NAME_PLATE_UNIT_REMOVED',
}











--local distanceSquared, checkedDistance = UnitDistanceSquared(u) inRange = CheckInteractDistance(unit, distIndex)
local function Set_Text(self)
    local k,T,F=0,0,0
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        local unit = plate.UnitFrame and plate.UnitFrame.unit
        if UnitCanAttack('player', unit)
            and (self.isPvPArena and UnitIsPlayer(unit) or not self.isPvPArena)
            and WoWTools_UnitMixin:CheckRange(unit, 40, true)
        then
            k=k+1
            if UnitIsUnit(unit..'target','player') then
                T=T+1
            end
        end
    end
    if IsInRaid() then
        for i=1, MAX_RAID_MEMBERS do
            local unit='raid'..i..'target'
            if UnitIsUnit(unit, 'player') and not UnitIsUnit(unit, 'player') then
                F=F+1
            end
        end
    elseif IsInGroup() then
        for i=1, MAX_PARTY_MEMBERS do
            if UnitIsUnit('party'..i..'target', 'player') then
                F=F+1
            end
        end
    end
    self.Text:SetText(WoWTools_DataMixin.Player.col..(T==0 and '-' or  T)..'|r |cff00ff00'..(F==0 and '-' or F)..'|r '..(k==0 and '-' or k))

end


local function Get_IsInPvPZone(self)
    self.isPvPArena= WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
end




















local function Init_Button()
    numButton= WoWTools_ButtonMixin:Cbtn(nil, {size=23})

    numButton.Text= WoWTools_LabelMixin:Create(numButton, {size=Save().creatureFontSize, color={r=1,g=1,b=1}})
    numButton.Text:SetScript('OnLeave', function(self) self:GetParent():SetButtonState('NORMAL') end)
    numButton.Text:SetScript('OnEnter', function(self) self:GetParent():SetButtonState('PUSHED') end)
    numButton.Text:SetPoint('LEFT', numButton, 'RIGHT')

    function numButton:set_point()
        self:ClearAllPoints()
        local p= Save().creaturePoint
        if p and p[1] then
            self:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        elseif WoWTools_DataMixin.Player.husandro then
            self:SetPoint('BOTTOM', _G['PlayerFrame'], 'TOP', 0,24)
        else
            self:SetPoint('CENTER', -50, 20)
        end
    end

    numButton:RegisterForDrag("RightButton")
    numButton:SetMovable(true)
    numButton:SetClampedToScreen(true)

    numButton:SetScript("OnMouseUp", ResetCursor)
    numButton:SetScript("OnMouseDown", function(_, d)
        if IsAltKeyDown() and d=='RightButton' then--移动光标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    numButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    numButton:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        if WoWTools_FrameMixin:IsInSchermo(self) then
            Save().creaturePoint={self:GetPoint(1)}
            Save().creaturePoint[2]=nil
        end
    end)
    numButton:SetScript("OnClick", function(self, d)
        if d=='RightButton' and IsControlKeyDown() then--还原
            Save().creaturePoint=nil
            self:set_point()
            print(WoWTools_DataMixin.addName , WoWTools_TargetMixin.addName, WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION)
        elseif d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    numButton:SetScript('OnMouseWheel', function(self, d)--缩放
        if not IsAltKeyDown() then
            return
        end
        local n=Save().creatureFontSize or 10
        if d==1 then
            n=n+1
        elseif d==-1 then
            n=n-1
        end
        n= n>72 and 72 or n
        n= n<8 and 8 or n
        Save().creatureFontSize=n
        WoWTools_LabelMixin:Create(nil, {changeFont=self.Text, size=n})
        self:set_tooltip()
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_TargetMixin.addName, (WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE), '|cnGREEN_FONT_COLOR:'..Save().creatureFontSize)
    end)

    function numButton:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_TargetMixin.addName)
        GameTooltip:AddLine(' ')
        if WoWTools_DataMixin.onlyChinese then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and WoWTools_DataMixin.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r')
        else
            GameTooltip:AddLine(WoWTools_DataMixin.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '重置位置' or RESET_POSITION, 'Ctrl+'..WoWTools_DataMixin.Icon.right)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE)..'|cnGREEN_FONT_COLOR:'..Save().creatureFontSize, 'Alt+'..WoWTools_DataMixin.Icon.mid)
        GameTooltip:Show()
    end
    numButton:SetScript('OnLeave', GameTooltip_Hide)
    numButton:SetScript("OnEnter", numButton.set_tooltip)

    return numButton
end





















local function Init_Frame()
    numFrame= CreateFrame('Frame')
    numFrame.Text= WoWTools_LabelMixin:Create(_G['WoWToolTarget_TargetFrame'], {size=Save().creatureFontSize, color={r=1,g=1,b=1}})--10, nil, nil, {1,1,1}, 'BORDER', 'RIGHT')
    function numFrame:set_point()
        self.Text:ClearAllPoints()
        if Save().TargetFramePoint=='LEFT' then
            self.Text:SetPoint('CENTER')
            self.Text:SetJustifyH('RIGHT')
        else
            self.Text:SetPoint('BOTTOM', 0, 8)
            self.Text:SetJustifyH('CENTER')
        end
    end

    return numFrame
end















local function Init()
    if numButton then
        numButton:UnregisterAllEvents()
        numButton.Text:SetText("")
        numButton:SetShown(false)
        numButton.isPvPArena= nil
    end
    if numFrame then
        numFrame:UnregisterAllEvents()
        numFrame.Text:SetText("")
        numFrame:SetShown(false)
        numFrame.isPvPArena= nil
    end

    if Save().creature then
        if Save().creatureUIParent or not Save().target then
            Frame= numButton or Init_Button()
        else
            Frame= numFrame or Init_Frame()
        end

        Frame:SetScript('OnEvent', function(self, event)
            if event=='PLAYER_ENTERING_WORLD' then
                Get_IsInPvPZone(self)
            end
            Set_Text(self)
        end)

        WoWTools_LabelMixin:Create(nil, {changeFont=Frame.Text, size= Save().creatureFontSize})
        FrameUtil.RegisterFrameForEvents(Frame, EventTab)
        Frame:set_point()
        Set_Text(Frame)
        Get_IsInPvPZone(Frame)
        Frame:SetShown(true)

    else
        Frame= nil
    end
end














function WoWTools_TargetMixin:Init_numFrame()
    Init()
end