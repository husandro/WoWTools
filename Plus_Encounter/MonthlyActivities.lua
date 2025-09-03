--贸易站

--[[
    if self.tracked then
        C_PerksActivities.RemoveTrackedPerksActivity(self.id)
    elseif not self.completed then
        C_PerksActivities.AddTrackedPerksActivity(self.id)
    end
    
MonthlySupersedeActivitiesButtonMixin
MonthlyActivitiesButtonMixin
]]


local function Init()
--任务，提示
    hooksecurefunc(MonthlyActivitiesButtonMixin, 'ShowTooltip', function(self)
        local data = self:GetData()
        local id= data and data.ID
        if not id then
            return
        end
        GameTooltip:AddLine(
            '|cnGREEN_FONT_COLOR:<'
            ..(WoWTools_DataMixin.onlyChinese and '超链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK)..WoWTools_DataMixin.Icon.right
            ..'>'
        )
        GameTooltip:AddLine(
            'perksActivityID|cffffffff'
            ..WoWTools_DataMixin.Icon.icon2
            ..id
        )
        GameTooltip:Show()
    end)


    hooksecurefunc(MonthlyActivitiesButtonMixin, 'OnClick', function(self, d)
        local data = self:GetData()
        local id= data and data.ID
        if id and d=='RightButton' then
            local link=C_PerksActivities.GetPerksActivityChatLink(id)
            WoWTools_ChatMixin:Chat(link, nil, true)
        end

    end)


    hooksecurefunc(MonthlyActivitiesButtonMixin, 'Init', function(self)
        self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    end)





    Init=function()end
end



function WoWTools_EncounterMixin:Init_MonthlyActivities()--贸易站
    Init()
end