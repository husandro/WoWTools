

local e= select(2, ...)
local function Save()
    return WoWTools_TooltipMixin.Save
end




local function Blizzard_AchievementUI()
    hooksecurefunc(AchievementTemplateMixin, 'Init', function(frame)
        if frame.Shield and frame.id then
            if not frame.AchievementIDLabel  then
                frame.AchievementIDLabel= WoWTools_LabelMixin:Create(frame.Shield)
                frame.AchievementIDLabel:SetPoint('TOP', frame.Shield.Icon)
                frame.Shield:SetScript('OnEnter', function(self)
                    local achievementID= self:GetParent().id
                    if achievementID then
                        e.tips:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
                        e.tips:ClearLines()
                        e.tips:SetAchievementByID(achievementID)
                        e.tips:AddLine(' ')
                        e.tips:AddDoubleLine('|A:communities-icon-chat:0:0|a'..(e.onlyChinese and '说' or SAY), e.Icon.left)
                        e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_TooltipMixin.addName)
                        e.tips:Show()
                    end
                    self:SetAlpha(0.5)
                end)
                frame.Shield:SetScript('OnLeave', function(self) self:SetAlpha(1) GameTooltip_Hide() end)
                frame.Shield:SetScript('OnMouseUp', function(self) self:SetAlpha(0.5) end)
                frame.Shield:SetScript('OnMouseDown', function(self) self:SetAlpha(0.3) end)
                frame.Shield:SetScript('OnClick', function(self)
                    local achievementID= self:GetParent().id
                    local achievementLink = achievementID and GetAchievementLink(achievementID)
                    if achievementLink then
                        WoWTools_ChatMixin:Chat(achievementLink)
                    end
                end)
                frame.Shield:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
            end
        end
        if frame.AchievementIDLabel then
            local text= frame.id
            local flags= frame.id and select(9, GetAchievementInfo(frame.id))
            if flags==0x20000 then
                text= e.Icon.net2..'|cff00ccff'..frame.id..'|r'
            end
            frame.AchievementIDLabel:SetText(text or '')
        end
    end)
    hooksecurefunc('AchievementFrameComparison_UpdateDataProvider', function()--比较成就, Blizzard_AchievementUI.lua
        local frame= AchievementFrameComparison.AchievementContainer.ScrollBox
        if not frame:GetView() then
            return
        end
        for _, button in pairs(frame:GetFrames() or {}) do
            if not button.OnEnter then
                button:SetScript('OnLeave', GameTooltip_Hide)
                button:SetScript('OnEnter', function(self3)
                    if self3.id then
                        e.tips:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                        e.tips:ClearLines()
                        e.tips:SetAchievementByID(self3.id)
                        e.tips:Show()
                    end
                end)
                if button.Player and button.Player.Icon and not button.Player.idText then
                    button.Player.idText= WoWTools_LabelMixin:Create(button.Player)
                    button.Player.idText:SetPoint('LEFT', button.Player.Icon, 'RIGHT', 0, 10)
                end
            end
            if button.Player and button.Player.idText then
                local flags= button.id and select(9, GetAchievementInfo(button.id))
                if flags==0x20000 then
                    button.Player.idText:SetText(e.Icon.net2..'|cffff00ff'..button.id..'|r')
                else
                    button.Player.idText:SetText(button.id or '')
                end
            end
        end
    end)
    hooksecurefunc('AchievementFrameComparison_SetUnit', function(unit)--比较成就
        local text= WoWTools_UnitMixin:GetPlayerInfo({unit=unit, reName=true, reRealm=true})--玩家信息图标
        if text~='' then
            AchievementFrameComparisonHeaderName:SetText(text)
        end
    end)
    if AchievementFrameComparisonHeaderPortrait then
        AchievementFrameComparisonHeader:EnableMouse(true)
        AchievementFrameComparisonHeader:HookScript('OnLeave', GameTooltip_Hide)
        AchievementFrameComparisonHeader:HookScript('OnEnter', function()
            local unit= AchievementFrameComparisonHeaderPortrait.unit
            if unit then
                e.tips:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                e.tips:ClearLines()
                e.tips:SetUnit(unit)
                e.tips:Show()
            end
        end)
    end
    if Save().AchievementFrameFilterDropDown then--保存，过滤
        AchievementFrame_SetFilter(Save().AchievementFrameFilterDropDown)
    end
    hooksecurefunc('AchievementFrame_SetFilter', function(value)
        Save().AchievementFrameFilterDropDown = value
    end)

    WoWTools_TooltipMixin.AddOn.Blizzard_AchievementUI=nil
end















function WoWTools_TooltipMixin.AddOn:Blizzard_AchievementUI()
    Blizzard_AchievementUI()
end