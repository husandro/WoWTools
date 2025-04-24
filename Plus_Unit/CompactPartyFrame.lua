--小队, 使用团框架
local function Save()
    return WoWToolsSave['Plus_UnitFrame'] or {}
end











local function set_CompactPartyFrame()--CompactPartyFrame.lua
    if not CompactPartyFrame or CompactPartyFrame.moveFrame or not CompactPartyFrame:IsShown() then
        return
    end
    CompactPartyFrame.title:SetText('')
    CompactPartyFrame.title:Hide()

--新建, 移动, 按钮
    CompactPartyFrame.moveFrame= WoWTools_ButtonMixin:Cbtn(CompactPartyFrame, {icon=true, size=20})
    CompactPartyFrame.moveFrame:SetAlpha(0.3)
    CompactPartyFrame.moveFrame:SetPoint('TOP', CompactPartyFrame, 'TOP',0, 10)
    CompactPartyFrame.moveFrame:SetClampedToScreen(true)
    CompactPartyFrame.moveFrame:SetMovable(true)
    CompactPartyFrame.moveFrame:RegisterForDrag('RightButton')
    CompactPartyFrame.moveFrame:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and not IsModifierKeyDown() then
            local frame= self:GetParent()
            if not frame:IsMovable() then
                frame:SetMovable(true)
            end
            frame:StartMoving()
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnDragStop", function(self)
        local frame=self:GetParent()
        frame:StopMovingOrSizing()
    end)
    CompactPartyFrame.moveFrame:SetScript("OnMouseDown", function(_, d)
        if d=='RightButton' and not IsModifierKeyDown() then
            SetCursor('UI_MOVE_CURSOR')
        elseif d=="LeftButton" then
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName, (WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE)..WoWTools_DataMixin.Icon.right, 'Alt+'..WoWTools_DataMixin.Icon.mid..(WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE), Save().compactPartyFrameScale or 1)
        end
    end)
    CompactPartyFrame.moveFrame:SetScript("OnLeave", ResetCursor)
    CompactPartyFrame.moveFrame:SetScript('OnMouseWheel', function(self, d)--缩放
        if not IsAltKeyDown() then
            return
        end
        if not self:CanChangeAttribute() then
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName, WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE, '|cnRED_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or COMBAT))
            return
        end
        local sacle= Save().compactPartyFrameScale or 1
        if d==1 then
            sacle=sacle+0.05
        elseif d==-1 then
            sacle=sacle-0.05
        end
        if sacle>1.5 then
            sacle=1.5
        elseif sacle<0.5 then
            sacle=0.5
        end
        print(WoWTools_DataMixin.Icon.icon2..WoWTools_UnitMixin.addName, (WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE), sacle)
        CompactPartyFrame:SetScale(sacle)
        Save().compactPartyFrameScale=sacle
    end)
    if Save().compactPartyFrameScale and Save().compactPartyFrameScale~=1 then
        CompactPartyFrame:SetScale(Save().compactPartyFrameScale)
    end
    CompactPartyFrame:SetClampedToScreen(true)
    CompactPartyFrame:SetMovable(true)
end














local function Init()
    set_CompactPartyFrame()--小队, 使用团框架

    hooksecurefunc(CompactPartyFrame,'UpdateVisibility', set_CompactPartyFrame)
    Init=function()end
end









function WoWTools_UnitMixin:Init_CompactPartyFrame()--小队, 使用团框架
    Init()
end