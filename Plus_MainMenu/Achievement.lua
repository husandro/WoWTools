--成就
local e= select(2, ...)





local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(AchievementMicroButton,  {size=WoWTools_PlusMainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', AchievementMicroButton, 0,  -3)
    table.insert(WoWTools_PlusMainMenuMixin.Labels, frame.Text)

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
        e.tips:AddLine(' ')
        e.tips:AddLine((GetTotalAchievementPoints() or 0)..' '..(e.onlyChinese and '成就点数' or ACHIEVEMENT_POINTS))
        if IsInGuild() then
            local guid= GetTotalAchievementPoints(true) or 0
            e.tips:AddLine(guid..' '..(e.onlyChinese and '公会成就' or GUILD_ACHIEVEMENTS_TITLE))
        end
        e.tips:Show()
    end)
end


function WoWTools_PlusMainMenuMixin:Init_Achievement()--成就
    Init()
end