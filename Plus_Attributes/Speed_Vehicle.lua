





--载具，移动，速度
local function Init()
    local vehicleTabs={
        'MainMenuBarVehicleLeaveButton',--没有车辆，界面
        'OverrideActionBarLeaveFrameLeaveButton',--有车辆，界面
        'MainMenuBarVehicleLeaveButton',--Taxi, 移动, 速度
    }
    for _, name in pairs(vehicleTabs) do
        local frame= _G[name]
        if frame then
            frame.speedText= WoWTools_LabelMixin:Create(frame, {mouse=true})
            frame.speedText:SetPoint('TOP')
            frame.speedText:SetScript('OnLeave', GameTooltip_Hide)
            frame.speedText:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '当前' or REFORGE_CURRENT, WoWTools_Mixin.onlyChinese and '移动速度' or STAT_MOVEMENT_SPEED)
                GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_AttributesMixin.addName)
                GameTooltip:Show()
            end)
            frame.speedText:SetScript('OnMouseDown', function(self)
                local f= self:GetParent()
                if f.OnClicked then
                    f.OnClicked(f)
                end
            end)
            frame:HookScript('OnUpdate', function(self, elapsed)
                self.elapsed= (self.elapsed or 0.3) + elapsed
                if self.elapsed>0.3 then
                    self.elapsed= 0
                    local unit= PlayerFrame.displayedUnit or PlayerFrame.unit or 'player'
                    local speed= GetUnitSpeed(unit) or 0
                    self.speedText:SetText(math.modf(speed* 100 / BASE_MOVEMENT_SPEED))
                end
            end)
        end
    end
end








function WoWTools_AttributesMixin:Init_Vehicle_Speed()
    if self.Save.disabledVehicleSpeed then
        return
    end

    do
        Init()
    end
    Init=function()end
end