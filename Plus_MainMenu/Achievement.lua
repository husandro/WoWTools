--成就






local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(AchievementMicroButton,  {size=WoWToolsSave['Plus_MainMenu'].size, color=true})
    frame.Text:SetPoint('TOP', AchievementMicroButton, 0,  -3)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local num
        num= GetTotalAchievementPoints() or 0
        num = num==0 and '' or WoWTools_Mixin:MK(num, 1)
        self.Text:SetText(num)
    end
    frame:RegisterEvent('ACHIEVEMENT_EARNED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    AchievementMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine((GetTotalAchievementPoints() or 0)..' '..(WoWTools_Mixin.onlyChinese and '成就点数' or ACHIEVEMENT_POINTS))
        if IsInGuild() then
            local guid= GetTotalAchievementPoints(true) or 0
            GameTooltip:AddLine(guid..' '..(WoWTools_Mixin.onlyChinese and '公会成就' or GUILD_ACHIEVEMENTS_TITLE))
        end
        GameTooltip:Show()
    end)

    Init=function()end
end


function WoWTools_MainMenuMixin:Init_Achievement()--成就
    Init()
end