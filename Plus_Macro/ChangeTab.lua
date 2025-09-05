
local function Save()
    return WoWToolsSave['Plus_Macro2']
end


















local function Set_OnSizeChanged(self)
    local value= math.max(1, math.modf(self:GetWidth()/49))
    if self:GetStride()~= value then
        self:SetCustomStride(value)
        self:Init()
    end
end





local function Init()
--ScrollFrame
    MacroFrameScrollFrame:ClearAllPoints()
    MacroFrameScrollFrame:SetPoint('TOPLEFT', MacroFrame, 'LEFT', 12, -60)
    MacroFrameScrollFrame:SetPoint('BOTTOMRIGHT', -32, 30)

--宏列表，按钮宽，数量
    MacroFrame.MacroSelector:HookScript('OnSizeChanged', function(self)--Blizzard_ScrollBoxSelector.lua
        if InCombatLockdown() then
            EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                Set_OnSizeChanged(self)
                EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
            end)
        else
            Set_OnSizeChanged(self)
        end
    end)



--设置，列表
    WoWTools_DataMixin:Hook(MacroFrame, 'ChangeTab', function(self, tabID)
        if WoWTools_FrameMixin:IsLocked(MacroFrame) then
            return
        end

        self.MacroSelector:ClearAllPoints()

        local point= Save().toRightLeft
            if point==1 then--左边
                self.MacroSelector:SetPoint('TOPRIGHT', self, 'TOPLEFT',10,-12)
                self.MacroSelector:SetPoint('BOTTOMLEFT', -319, 0)

            elseif point==2 then--右边
                self.MacroSelector:SetPoint('TOPLEFT', self, 'TOPRIGHT',0,-12)
                self.MacroSelector:SetPoint('BOTTOMRIGHT', 319, 0)

            elseif point==4 then--左|右
                self.MacroSelector:SetPoint('TOPLEFT', self, 12, -66)
                self.MacroSelector:SetPoint('BOTTOMRIGHT', self, 'BOTTOM', 0, 45)

        else--默认
            self.MacroSelector:SetPoint('TOPLEFT', 12,-66)
            self.MacroSelector:SetPoint('BOTTOMRIGHT', self, 'RIGHT', -6, 0)
        end

        MacroFrameScrollFrame:ClearAllPoints()
        if point==4 then
            MacroFrameScrollFrame:SetPoint('TOPLEFT', self.MacroSelector, 'TOPRIGHT', 0, -52)
            MacroFrameScrollFrame:SetPoint('BOTTOMLEFT', self.MacroSelector, 'BOTTOMRIGHT', 0, -16)
            MacroFrameScrollFrame:SetPoint('RIGHT', self, -34, 0)
        else
            MacroFrameScrollFrame:SetPoint('TOPLEFT', self, 'LEFT', 12, -60)
            MacroFrameScrollFrame:SetPoint('BOTTOMRIGHT', -32, 30)
        end


        local show=(point==1 or point==2) and true or false
        if _G['WoWToolsMacroPlusNoteEditBox'] then
            _G['WoWToolsMacroPlusNoteEditBox']:SetShown(show)
        end

    --图像    
        if tabID==2 then
            MacroFramePortrait:SetAtlas(WoWTools_UnitMixin:GetRaceIcon('player', nil, nil, {reAtlas=true}))
        else
            MacroFramePortrait:SetTexture('Interface\\MacroFrame\\MacroFrame-Icon')
        end
    end)

    Init=function()end
end




function WoWTools_MacroMixin:Init_ChangeTab()
    Init()
end




