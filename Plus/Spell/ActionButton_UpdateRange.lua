--法术按键, 颜色 ActionButton.lua
local function Init()
    if not WoWToolsSave['Plus_Spell'].actionButtonRangeColor then
        return
    end

    WoWTools_DataMixin:Hook('ActionButton_UpdateRangeIndicator', function(frame, checksRange, inRange)

        if not canaccessvalue(checksRange)
            or not canaccessvalue(inRange)
            or not canaccessvalue(frame.UpdateUsable)
        then
            return
        end

        if not frame.setHooksecurefunc and frame.UpdateUsable then
            WoWTools_DataMixin:Hook(frame, 'UpdateUsable', function(self)
                local isUsable= C_ActionBar.IsUsableAction(self.action)
                if canaccessvalue(isUsable) and isUsable and C_ActionBar.HasRangeRequirements(self.action) and C_ActionBar.IsActionInRange(self.action)==false then
                    self.icon:SetVertexColor(1,0,0)
                end
            end)
            frame.setHooksecurefunc= true
        end

    local hotKey= frame.HotKey:GetText()
       if not canaccessvalue(hotKey) then
            return
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
    end)


    Init=function()end
end





function WoWTools_SpellMixin:Init_ActionButton_UpdateRange()--法术按键, 颜色
    Init()
end