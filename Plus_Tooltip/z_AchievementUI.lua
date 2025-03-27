


local function Save()
    return WoWToolsSave['Plus_Tootips']
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
                        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
                        GameTooltip:ClearLines()
                        GameTooltip:SetAchievementByID(achievementID)
                        GameTooltip:AddLine(' ')
                        GameTooltip:AddDoubleLine('|A:communities-icon-chat:0:0|a'..(WoWTools_DataMixin.onlyChinese and '说' or SAY), WoWTools_DataMixin.Icon.left)
                        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_TooltipMixin.addName)
                        GameTooltip:Show()
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
                frame.Shield:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
            end
        end
        if frame.AchievementIDLabel then
            local text= frame.id
            local flags= frame.id and select(9, GetAchievementInfo(frame.id))
            if flags==0x20000 then
                text= WoWTools_DataMixin.Icon.net2..'|cff00ccff'..frame.id..'|r'
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
                        GameTooltip:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                        GameTooltip:ClearLines()
                        GameTooltip:SetAchievementByID(self3.id)
                        GameTooltip:Show()
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
                    button.Player.idText:SetText(WoWTools_DataMixin.Icon.net2..'|cffff00ff'..button.id..'|r')
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
                GameTooltip:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                GameTooltip:ClearLines()
                GameTooltip:SetUnit(unit)
                GameTooltip:Show()
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