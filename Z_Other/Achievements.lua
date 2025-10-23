local function Save()
    return WoWToolsSave['Plus_Achievement']
end
local addName



local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end
    local uiMapID= WoWTools_WorldMapMixin:GetMapID()
    for mapID, data in pairs(WoWTools_MapIDAchievements) do
       local info= C_Map.GetMapInfo(mapID)
       if info and info.name then
            local sub= root:CreateCheckbox(
                WoWTools_TextMixin:CN(info.name)..' #'..#data,
            function(desc)
                return desc.mapID== uiMapID
            end,
            function()
                return MenuResponse.Open
            end, {mapID= mapID})

            for index, achievementID in pairs(data) do
                local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)
                if name then
                    sub:CreateButton(
                        index..') '
                        ..'|T'..(icon or 0)..':0|t'
                        ..(completed and '|cnGREEN_FONT_COLOR:' or '')

                        ..WoWTools_TextMixin:CN(name),
                    function()
                        return MenuResponse.Open
                    end, {achievementID=achievementID})
                    WoWTools_SetTooltipMixin:Set_Menu(sub)
                end
            end
            WoWTools_MenuMixin:SetScrollMode(sub)
       end
    end
    WoWTools_MenuMixin:SetScrollMode(root)
end



local function Init()
    local btn= CreateFrame('DropdownButton', 'WoWToolsAchievementsMenuButton', AchievementFrameCloseButton, 'WoWToolsMenuButtonTemplate')
    btn:SetPoint('RIGHT', AchievementFrameCloseButton, 'LEFT')
    btn.Text= btn:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    btn.Text:SetPoint('RIGHT', -4, 0)
    
    function btn:set_text()
        local mapID= WoWTools_WorldMapMixin:GetMapID()
        local data= mapID and WoWTools_MapIDAchievements[mapID]
        local num
        if data then
            num= #data
        end
        self.Text:SetText(num or '')
    end
    btn:SetScript('OnShow', function(self)
        self:set_text()
    end)
    btn:SetScript('OnHide', function(self)
        self.Text:SetText('')
    end)
    btn:SetupMenu(Init_Menu)
    btn:set_text()


    Init= function()end
end









local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1== 'WoWTools' then
        WoWToolsSave['Plus_Achievement']= WoWToolsSave['Plus_Achievement'] or {disabled=not WoWTools_DataMixin.Player.husandro}
        addName= '|A:UI-Achievement-Shield-NoPoints:0:0|a'..(WoWTools_DataMixin.onlyChinese and '成就' or ACHIEVEMENTS)

        --添加控制面板
        WoWTools_PanelMixin:OnlyCheck({
            name= addName,
            Value= not Save().disabled,
            GetValue=function() return not Save().disabled end,
            SetValue= function()
                Save().disabled= not Save().disabled and true or nil
                if Save().disabled then
                    print(
                        addName.WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            end,
            --tooltip=,
            layout= WoWTools_OtherMixin.Layout,
            category= WoWTools_OtherMixin.Category,
        })

        if Save().disabled then
            WoWTools_MapIDAchievements={}
            self:UnregisterEvent(event)
        else
            if C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
                Init()
                self:UnregisterEvent(event)
            end
        end

    elseif arg1=='Blizzard_AchievementUI' then
        Init()
        self:UnregisterEvent(event)
    end
end)