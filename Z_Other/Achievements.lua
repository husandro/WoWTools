local function Save()
    return WoWToolsSave['Plus_Achievement']
end
local addName




local function Get_InstanceID()
    local instanceID= select(8, GetInstanceInfo())
    return instanceID
end

local function Get_List_Tab(instanceID)
    local mapData= instanceID and WoWTools_MapIDAchievementData[instanceID]
    local to= mapData and #mapData or 0
    if to==0 then
        return
    end

    table.sort(mapData)

    local tab={}
    local co= 0
    to= 0
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
                co=co+1
            end
            to= to+1
        end
    end

    if to==0 then
        return
    end

    return tab, (co==to and '|cnGREEN_FONT_COLOR:' or '')..co..'/'..to
end

















local function Set_Menu(root, tab)
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
    local tab= Get_List_Tab(self.instanceID)
    if tab then
        Set_Menu(root, tab)
    end

    local instanceID= Get_InstanceID()
    if instanceID and instanceID~=self.instanceID then
        tab= Get_List_Tab(instanceID)
        if tab then
            root:CreateDivider()
            local sub= root:CreateButton(
                GetInstanceInfo() or instanceID,
            function()
                return MenuResponse.Open
            end)
            Set_Menu(sub, tab)
        end
    end
end










local function Create_Button(frame, point)
    frame.achievementButton= CreateFrame('DropdownButton', 'WoWToolsAchievementsMenuButton', frame)

    frame.achievementButton.Text= frame.achievementButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    frame.achievementButton.Text:SetPoint('CENTER')

    function frame.achievementButton:set_text()
        local conut= select(2, Get_List_Tab(self.instanceID))
        self.Text:SetText(conut or '...')
        self:SetWidth(math.max(self.Text:GetStringWidth()+4 , 23))
        self:SetShown(conut)
    end

    point(frame.achievementButton)

    frame.achievementButton:SetSize(23,23)
    frame.achievementButton:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    frame.achievementButton:SetPushedAtlas('PetList-ButtonSelect')
    frame.achievementButton:SetHighlightAtlas('PetList-ButtonHighlight')

    frame.achievementButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    frame.achievementButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        local tab, count= Get_List_Tab(self.instanceID)
        GameTooltip:AddDoubleLine(
            addName..WoWTools_DataMixin.Icon.icon2..(count and '|cffffffff'..count or ''),
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
    frame.achievementButton:SetScript('OnHide', function(self)
        self.Text:SetText('')
    end)

    frame.achievementButton:SetupMenu(Init_Menu)


end











local function Init_Achievement()
    Create_Button(AchievementFrameCloseButton, function(btn) btn:SetPoint('RIGHT', AchievementFrameCloseButton, 'LEFT', -2, 0) end)

    AchievementFrameCloseButton.achievementButton:SetScript('OnShow', function(self)
        self.instanceID= Get_InstanceID()
        self:set_text()
    end)

    Init_Achievement= function()end
end




local function Init_EncounterJournal()
--列表， 添加按钮
    local function Init_Box(frame)
        if not frame:HasView() then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            if not btn.achievementButton then
                Create_Button(btn, function(b) b:SetPoint('TOPRIGHT', 0, 3) end)
            end
            btn.achievementButton.instanceID = btn.instanceID and select(10, EJ_GetInstanceInfo(btn.instanceID)) or nil
            btn.achievementButton:set_text()
        end
    end
    EncounterJournal.instanceSelect.ScrollBox:HookScript('OnShow', function(frame)
        C_Timer.After(0.1, function() Init_Box(frame) end)
    end)
    WoWTools_DataMixin:Hook(EncounterJournal.instanceSelect.ScrollBox, 'Update', function(frame)
        Init_Box(frame)
    end)
   --WoWTools_DataMixin:Hook('EncounterJournal_ListInstances', function(frame)

--SearchBox,右边，添加一个按按钮
    Create_Button(EncounterJournalSearchBox, function(btn) btn:SetPoint('RIGHT', EncounterJournalSearchBox, 'LEFT', -8, 0) end)
    WoWTools_DataMixin:Hook('EncounterJournal_DisplayInstance', function(instanceID)
        EncounterJournalSearchBox.achievementButton.instanceID=  instanceID and select(10, EJ_GetInstanceInfo(instanceID)) or nil
        EncounterJournalSearchBox.achievementButton:set_text()
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
                Init_Achievement()
            end
            if C_AddOns.IsAddOnLoaded('Blizzard_EncounterJournal') then
                Init_EncounterJournal()
            end
        end

    elseif arg1=='Blizzard_AchievementUI' and WoWToolsSave then
        Init_Achievement()
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