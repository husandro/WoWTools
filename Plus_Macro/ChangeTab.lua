
local function Save()
    return WoWToolsSave['Plus_Macro2']
end
local ScrollBoxBackground














--设置，列表
local function Init_ChangeTab(self, tabID)
    if WoWTools_FrameMixin:IsLocked(MacroFrame) then
        return
    end

    self.MacroSelector:ClearAllPoints()

    local point= Save().toRightLeft

    --if tabID==1 and (point==1 or point==2) then
        if point==1 then--左边
            self.MacroSelector:SetPoint('TOPRIGHT', self, 'TOPLEFT',10,-12)
            self.MacroSelector:SetPoint('BOTTOMLEFT', -319, 0)

        elseif point==2 then--右边
            self.MacroSelector:SetPoint('TOPLEFT', self, 'TOPRIGHT',0,-12)
            self.MacroSelector:SetPoint('BOTTOMRIGHT', 319, 0)

        elseif point==4 then--左|右
            --local h, w= MacroFrame:GetSize()
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
    WoWTools_MacroMixin.NoteEditBox:SetShown(show)
    ScrollBoxBackground:SetShown(show)

--图像
    if tabID==2 then
        MacroFramePortrait:SetAtlas(WoWTools_UnitMixin:GetRaceIcon({unit='player', guid=WoWTools_DataMixin.Player.GUID , race=nil , sex=WoWTools_DataMixin.Player.Sex , reAtlas=true}))
    else
        MacroFramePortrait:SetTexture('Interface\\MacroFrame\\MacroFrame-Icon')
    end
end









local function Set_OnSizeChanged(self)
    local value= math.max(1, math.modf(self:GetWidth()/49))
    if self:GetStride()~= value then
        self:SetCustomStride(value)
        self:Init()
    end
end





local function Init()
    ScrollBoxBackground=WoWTools_TextureMixin:CreateBackground(MacroFrame.MacroSelector.ScrollBox)--, {isAllPoint=true})
    ScrollBoxBackground:SetAllPoints(MacroFrame.MacroSelector.ScrollBox.Shadows)

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

--移动
    WoWTools_MoveMixin:Setup(MacroFrame, {needSize=true, setSize=true, minW=260, minH=250,
        sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 424)
    end})

--设置，列表
    hooksecurefunc(MacroFrame, 'ChangeTab', Init_ChangeTab)

    Init=function()end
end




function WoWTools_MacroMixin:Init_ChangeTab()
    Init()
end




