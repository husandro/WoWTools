 --冒险指南













local function Get_Perks_Info()
    local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo()--贸易站, 点数Blizzard_MonthlyActivities.lua
    if not activitiesInfo then
        return
    end
    local thresholdMax = 0
    for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
        if thresholdInfo.requiredContributionAmount > thresholdMax then
            thresholdMax = thresholdInfo.requiredContributionAmount
        end
    end
    thresholdMax= thresholdMax == 0 and 1000 or thresholdMax
    local earnedThresholdAmount = 0
    for _, activity in pairs(activitiesInfo.activities) do
        if activity.completed then
            earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount
        end
    end
    earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax)
    return earnedThresholdAmount, thresholdMax, C_CurrencyInfo.GetCurrencyInfo(2032), activitiesInfo
end










local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(EJMicroButton,  {size=WoWToolsSave['Plus_MainMenu'].size, color=true})
    frame.Text:SetPoint('TOP', EJMicroButton, 0,  -3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local text
        local cur, max, info= Get_Perks_Info()
        if cur then
            info =info or {}
            if cur== max then
                text= (info.quantity and WoWTools_DataMixin:MK(info.quantity, 1) or format('|A:%s:0:0|a', 'common-icon-checkmark'))
            else
                text= format('%i%%', cur/max*100)
            end
        end
        self.Text:SetText(text or '')
    end
    frame:RegisterEvent('CVAR_UPDATE')
    frame:RegisterEvent('PERKS_ACTIVITY_COMPLETED')
    frame:RegisterEvent('PERKS_ACTIVITIES_UPDATED')
    frame:SetScript('OnEvent', frame.settings)
    C_Timer.After(2, function() frame:settings() end)

    EJMicroButton:HookScript('OnEnter', function()
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end

        GameTooltip:AddLine(' ')

        local cur, max, info= Get_Perks_Info()
        if cur then
            info= info or {}

            if info.quantity then
                GameTooltip:AddDoubleLine(
                    (info.iconFileID  and '|T'..info.iconFileID..':0|t' or '|A:activities-complete-diamond:0:0|a')
                    ..info.quantity,
                    WoWTools_TextMixin:CN(info.name)
                )
            end
            GameTooltip:AddDoubleLine((cur==max and '|cnGREEN_FONT_COLOR:' or '|cffff00ff')..cur..'|r/'..max..format(' %i%%', cur/max*100), WoWTools_DataMixin.onlyChinese and '旅行者日志进度' or MONTHLY_ACTIVITIES_PROGRESSED)
            GameTooltip:AddLine(' ')
        end

        local col= InCombatLockdown() and '|cff626262' or '|cffffffff'

        GameTooltip:AddLine(
            col
            --..(WoWTools_DataMixin.onlyChinese and '地下城' or DUNGEONS)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        GameTooltip:AddLine(
            col
            --..(WoWTools_DataMixin.onlyChinese and '旅行者日志' or MONTHLY_ACTIVITIES_TAB)..'|r'
            ..(WoWTools_DataMixin.onlyChinese and '旅程' or JOURNEYS_LABEL)..'|r'
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddLine(
            col
            ..(WoWTools_DataMixin.onlyChinese and '团队副本' or RAIDS)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        GameTooltip:Show()
    end)

    EJMicroButton:HookScript('OnClick', function(_, d)
        if not d~='RightButton'
            or KeybindFrames_InQuickKeybindMode()
            or Kiosk.IsEnabled()
            or DISALLOW_FRAME_TOGGLING
        then
            return
        end

        --if ToggleEncounterJournal() then
            --MonthlyActivitiesFrame_OpenFrame()
        WoWTools_LoadUIMixin:MajorFaction()
        
    end)

    EJMicroButton:EnableMouseWheel(true)
    EJMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end

        EncounterJournal_LoadUI()

        do
            if not EncounterJournal:IsShown() then
                ToggleEncounterJournal()
                MonthlyActivitiesFrame_OpenFrame()
            end
        end

        if d==1 then
            EJ_ContentTab_Select(EncounterJournal.dungeonsTab:GetID())

        elseif d==-1 then
            EJ_ContentTab_Select(EncounterJournal.raidsTab:GetID())
        end
    end)

    Init=function()end
end











function WoWTools_MainMenuMixin:Init_EJ()--冒险指南
    Init()
end