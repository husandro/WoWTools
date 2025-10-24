local function Save()
    return WoWToolsSave['Plus_Achievement']
end
local addName




local function Get_InstanceID()
    local instanceID= select(8, GetInstanceInfo())
    return instanceID
end

local function Get_List_Tab(instanceID)
    local mapData= WoWTools_MapIDAchievementData[instanceID]
    local to= mapData and #mapData or 0
    if to==0 then
        return
    end

    table.sort(mapData)
    local tab={}
    local c= 0
    for index, achievementID in pairs(mapData) do
        local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic = GetAchievementInfo(achievementID)
        if name then

            table.insert(tab, {
                text= (index<10 and '  ' or '')
                    ..'|cffffffff'
                    ..index..')|r '
                    ..'|T'..(icon or 0)..':0|t'
                    ..(completed and '|cnGREEN_FONT_COLOR:' or '|cffffffff')
                    ..WoWTools_TextMixin:CN(name)
                    ..'|r'
                    ..(wasEarnedByMe and WoWTools_DataMixin.Icon.Player or '')--此角色，是否完成
                    ..((isGuild or flags==0x4000) and '|A:communities-guildbanner-background:0:0|a' or '' ),--公会成就
                achievementID= achievementID,
            })

            if completed then
                c=c+1
            end
        end
    end

    return tab, c..'/'..to
end





















local function Init_Menu(self, root)
    if not self:IsMouseOver() then
        return
    end

--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {
        name=addName,
        category=WoWTools_OtherMixin.Category
    })
    root:CreateDivider()
--列表
    local instanceID= Get_InstanceID()
    local tab= Get_List_Tab(instanceID)
    local sub
    if tab then
        for _, d in pairs(tab) do
            sub= root:CreateButton(
                d.text,
            function(desc)
                WoWTools_LoadUIMixin:Achievement(desc.achievementID)
                return MenuResponse.Open
            end, {achievementID=d.achievementID})
            WoWTools_SetTooltipMixin:Set_Menu(sub)
        end
        WoWTools_MenuMixin:SetScrollMode(root)

        root:CreateDivider()
        sub= root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '全部' or ALL,
        function()
            return MenuResponse.Open
        end)
    else
        sub= root
    end

    for insID in pairs(WoWTools_MapIDAchievementData) do
        if instanceID~=insID then
            local data, count= Get_List_Tab(insID)
            if data then
    --标题
                local sub2= sub:CreateButton(
                    insID..(count and ' '..count or ''),
                function()
                    return MenuResponse.Open
                end)
    --列表
                for _, d in pairs(data) do
                    local sub3= sub2:CreateButton(
                        d.text,
                    function(desc)
                        WoWTools_LoadUIMixin:Achievement(desc.achievementID)
                        return MenuResponse.Refresh
                    end, {achievementID=d.achievementID})
                    WoWTools_SetTooltipMixin:Set_Menu(sub3)
                end
    --滚动条
                WoWTools_MenuMixin:SetScrollMode(sub2)
            end
        end
    end

    WoWTools_MenuMixin:SetScrollMode(sub)
end



local function Init()
    local btn= CreateFrame('DropdownButton', 'WoWToolsAchievementsMenuButton', AchievementFrameCloseButton)--, 'WoWToolsMenuButtonTemplate')
    btn:SetSize(23,23)
    btn:SetPoint('RIGHT', AchievementFrameCloseButton, 'LEFT', -2, 0)
    btn:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    btn:SetPushedAtlas('PetList-ButtonSelect')
    btn:SetHighlightAtlas('PetList-ButtonHighlight')
    btn.Text= btn:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
    btn.Text:SetPoint('CENTER')

    function btn:set_text()
        local instanceID= Get_InstanceID()
        local conut= select(2, Get_List_Tab(instanceID))
        self.Text:SetText((instanceID and '' or '|cff626262')..(conut or '0'))
        self:SetWidth(math.max(self.Text:GetStringWidth()+4 , 23))
    end
    btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
    btn:SetScript('OnEnter', function(self)
        local instanceID= Get_InstanceID()
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        local tab, count= Get_List_Tab(instanceID)
        GameTooltip:AddDoubleLine(
            addName..(count and ' |cffffffff'..count or ''),
            WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE
        )
        if tab then
            GameTooltip:AddLine(' ')
            for _, data in pairs(tab) do
                GameTooltip:AddLine(data.text)
            end
        end
        GameTooltip:Show()
    end)
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




local function Init_EncounterJournal()
    WoWTools_DataMixin:Hook(EncounterJournal.instanceSelect.ScrollBox, 'Update', function(frame)
        if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            local journalInstanceID= btn.instanceID
            local instanceID = journalInstanceID and select(10, EJ_GetInstanceInfo(journalInstanceID))
            local mapData= instanceID and WoWTools_MapIDAchievementData[instanceID]
            if not btn.AchievButton and mapData then
                btn.AchievButton= CreateFrame('DropdownButton', 'WoWToolsAchievementsMenuButton', btn)
                btn.AchievButton:SetSize(23,23)
                btn.AchievButton:SetPoint('TOPRIGHT', 0, 2)
                btn.AchievButton:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
                btn.AchievButton:SetPushedAtlas('PetList-ButtonSelect')
                btn.AchievButton:SetHighlightAtlas('PetList-ButtonHighlight')
                btn.AchievButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
                btn.AchievButton:SetScript('OnEnter', function(self)
                    GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
                    GameTooltip:ClearLines()
                    local tab, conut= Get_List_Tab(self.instanceID)

                    GameTooltip:AddDoubleLine(
                        addName..(conut and ' |cffffffff'..conut or ''),
                        WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE
                    )

                    if tab then
                        GameTooltip:AddLine(' ')
                        for _, data in pairs(tab) do
                            GameTooltip:AddLine(data.text)
                        end
                    end
                    GameTooltip:Show()
                end)
--设置，菜单
                btn.AchievButton:SetupMenu(function(self, root)
                    if not self:IsMouseOver() or not self.instanceID then
                        return
                    end
--列表
                    local tab, conut= Get_List_Tab(self.instanceID)
--打开选项界面
                    WoWTools_MenuMixin:OpenOptions(root, {
                        name=addName..(conut and ' '..conut or ''),
                        category=WoWTools_OtherMixin.Category
                    })

                    if tab then
                        root:CreateDivider()
                        for _, d in pairs(tab) do
                            local sub= root:CreateButton(
                                d.text,
                            function(desc)
                                WoWTools_LoadUIMixin:Achievement(desc.achievementID)
                                return MenuResponse.Open
                            end, {achievementID=d.achievementID})
                            WoWTools_SetTooltipMixin:Set_Menu(sub)
                        end
                        WoWTools_MenuMixin:SetScrollMode(root)
                    end
                end)

                btn.AchievButton.Text= btn.AchievButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
                btn.AchievButton.Text:SetPoint('CENTER')
            end


            if btn.AchievButton then
                if btn.AchievButton.Text then
                    local c= 0
                    if mapData then
                        for _, achievementID in pairs(mapData) do
                            if not select(4, GetAchievementInfo(achievementID)) then
                                c= c+1
                            end
                        end
                    end
                    btn.AchievButton.Text:SetText(c)
                end
                btn.AchievButton:SetShown(mapData and true or false)
                btn.AchievButton.instanceID= instanceID
            end
        end
    end)

    Init_EncounterJournal=function()end
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

        if Save().disabled or not WoWTools_MapIDAchievementData then
            WoWTools_MapIDAchievementData={}
            self:UnregisterEvent(event)
        else
            if C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
                Init()
            end
            if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
                Init_EncounterJournal()
            end
        end

    elseif arg1=='Blizzard_AchievementUI' and WoWToolsSave then
        Init()
        if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
            self:UnregisterEvent(event)
        end

    elseif arg1=='Blizzard_EncounterJournal' and WoWToolsSave then
       Init_EncounterJournal()

        if C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
            self:UnregisterEvent(event)
        end
    end
end)