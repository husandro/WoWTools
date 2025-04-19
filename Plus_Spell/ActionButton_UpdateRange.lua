

--法术按键, 颜色 ActionButton.lua
local function set_ActionButton_UpdateRangeIndicator(frame, checksRange, inRange)
    if not frame.setHooksecurefunc and frame.UpdateUsable then
        hooksecurefunc(frame, 'UpdateUsable', function(self, _, isUsable)
            if IsUsableAction(self.action) and ActionHasRange(self.action) and IsActionInRange(self.action)==false then
                self.icon:SetVertexColor(1,0,0)
            end
        end)
        frame.setHooksecurefunc= true
    end

    if ( frame.HotKey:GetText() == RANGE_INDICATOR ) then
        if ( checksRange ) then
            if ( inRange ) then
                if frame.UpdateUsable then
                    frame:UpdateUsable()
                end
            else
                frame.icon:SetVertexColor(1,0,0)
            end
        end
    else
        if ( checksRange and not inRange ) then
            frame.icon:SetVertexColor(1,0,0)
        elseif frame.UpdateUsable then
            frame:UpdateUsable()
        end
    end

end




local function Init()
    hooksecurefunc('ActionButton_UpdateRangeIndicator', set_ActionButton_UpdateRangeIndicator)
    Init=function()end
end





function WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
    if self.actionButtonRangeColor then
        Init()
    end
end