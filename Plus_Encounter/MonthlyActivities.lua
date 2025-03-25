--贸易站
--可能会，出错误

local function Save()
    return WoWToolsSave['Adventure_Journal']
end



local function Settings(btn)
    btn:HookScript('OnEnter', function(self3)
        if self3.id and not Save().hideEncounterJournal then
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine('perksActivityID', self3.id)
            GameTooltip:AddDoubleLine((self3.completed and '|cff9e9e9e' or '|cff00ff00')..(WoWTools_Mixin.onlyChinese and '追踪' or TRACKING), WoWTools_DataMixin.Icon.left)
            GameTooltip:AddDoubleLine((not C_PerksActivities.GetPerksActivityChatLink(self3.id) and '|cff9e9e9e' or '|cff00ff00')..(WoWTools_Mixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK), WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_EncounterMixin.addName)
            GameTooltip:Show()
        end
    end)

    btn:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    btn:HookScript('OnClick', function(self3, d)
        if IsModifierKeyDown() or not self3.id or Save().hideEncounterJournal then
            return
        end
        if d=='RightButton' then
            local link=C_PerksActivities.GetPerksActivityChatLink(self3.id)
            WoWTools_ChatMixin:Chat(link, nil, true)


        elseif d=='LeftButton' then
            if self3.tracked then
                C_PerksActivities.RemoveTrackedPerksActivity(self3.id)
            elseif not self3.completed then
                C_PerksActivities.AddTrackedPerksActivity(self3.id)
            end
        end
    end)

    btn.showPerksActivityID= true
end












local function Update(frame)
    if Save().hideEncounterJournal or not frame:GetView() then
        return
    end

    for _, btn in pairs(frame:GetFrames()) do
        if not btn.showPerksActivityID then
            Settings(btn)
        end
    end
end








function WoWTools_EncounterMixin:Init_MonthlyActivities()--贸易站
    hooksecurefunc(EncounterJournalMonthlyActivitiesFrame.ScrollBox, 'SetScrollTargetOffset', Update)
end