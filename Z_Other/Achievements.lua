local function Save()
    return WoWToolsSave['Plus_Achievement']
end
local addName

local function InGuildView()
    return AchievementFrame.selectedTab == 2
end


local function Get_InstanceID()
    local instanceID= select(8, GetInstanceInfo())
    return instanceID
end

local function Get_List_Tab(instanceID)
    local mapData
    if WoWTools_MapIDAchievementData and instanceID then
        mapData= WoWTools_MapIDAchievementData[instanceID]
    end
    local to= mapData and #mapData or 0
    if to==0 then
        return
    end

    table.sort(mapData)

    local tab={}
    local co= 0
    to= 0
    local isInGuild= IsInGuild()
    for index, achievementID in pairs(mapData) do
        local _, name, _, completed, _, _, _, _, _, icon, rewardText, isGuild, wasEarnedByMe = GetAchievementInfo(achievementID)

        if name and icon~=136243 then-- and icon~=136243 then
        --isGuild= isGuild or flags==0x4000
--奖励
            local itemID= C_AchievementInfo.GetRewardItemID(achievementID)
            local itemIcon= itemID and select(5, C_Item.GetItemInfoInstant(itemID))
            WoWTools_DataMixin:Load(itemID, 'item')
            table.insert(tab, {
                text= (index<10 and '  ' or '')
                    ..'|cffffffff'
                    ..index..')|r '
                    ..'|T'..(icon or 0)..':0|t'
                    ..(isGuild and not isInGuild and '|cff626262' or (completed and '|cnGREEN_FONT_COLOR:') or '|cffffffff')
                    ..WoWTools_TextMixin:CN(name)
                    ..'|r'
                    ..(itemIcon and '|T'..itemIcon..':0|t' or (rewardText and rewardText~='' and '|A:VignetteLoot:0:0|a') or '')
                    ..(wasEarnedByMe and WoWTools_DataMixin.Icon.Player or '')--此角色，是否完成
                    ..(isGuild and '|A:communities-guildbanner-background:0:0|a' or '' ),
                achievementID= achievementID,
            })
            if isInGuild or not isGuild then
                if completed then--不在公会时，不显示公会成就
                    co=co+1
                end
                to= to+1
            end
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
        function(data)
            WoWTools_LoadUIMixin:Achievement(data.achievementID)
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

--列表
    local tab= Get_List_Tab(self.instanceID)
    if tab then
        Set_Menu(root, tab)
    end

    root:CreateDivider()

    local instanceID= Get_InstanceID()
    if instanceID and instanceID~=self.instanceID then
        local count
        tab, count= Get_List_Tab(instanceID)
        if tab then
            local sub= root:CreateButton(
                (GetInstanceInfo() or instanceID)
                ..(count and ' '..count or ''),
            function()
                return MenuResponse.Open
            end)
            Set_Menu(sub, tab)
        end
    end

--打开选项界面
    WoWTools_MenuMixin:OpenOptions(root, {
        name=addName,
        name2= WoWTools_TextMixin:CN(self.name),
        category=WoWTools_OtherMixin.Category
    })
end










local function Create_Button(frame, point)
    frame.achievementButton= CreateFrame('DropdownButton', nil, frame, 'WoWToolsMenuTemplate')
    frame.achievementButton:SetNormalTexture(0)

    frame.achievementButton.Text= frame.achievementButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')
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
    --frame.achievementButton:SetPushedAtlas('PetList-ButtonSelect')
    --frame.achievementButton:SetHighlightAtlas('PetList-ButtonHighlight')
    frame.achievementButton.tooltip= addName..WoWTools_DataMixin.Icon.icon2

    --[[frame.achievementButton:SetScript('OnLeave', function() GameTooltip:Hide() end)
    frame.achievementButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()

        local tab, count= Get_List_Tab(self.instanceID)

        GameTooltip:AddDoubleLine(
            (self.name or addName)
            ..WoWTools_DataMixin.Icon.icon2..(count and '|cffffffff'..count or ''),
            WoWTools_DataMixin.onlyChinese and '副本' or INSTANCE
        )
        if tab then
            GameTooltip:AddLine(' ')
            for _, data in pairs(tab) do
                GameTooltip:AddLine(data.text)
            end
        end
        GameTooltip:Show()
    end)]]
    frame.achievementButton:SetScript('OnHide', function(self)
        self.Text:SetText('')
    end)

    frame.achievementButton:SetupMenu(Init_Menu)
end











local function Set_Icon(self, achievementID)
    if achievementID==_G['WoWToolsAchievementBackButton'].achievementID
        or achievementID==_G['WoWToolsAchievementNextButton'].achievementID
    then
        return
    end
    self.achievementID= achievementID
    local texture= select(10, GetAchievementInfo(achievementID))
    self:SetNormalTexture(texture or 0)
end



--已完成，背景 alpha
local function Set_AchievementTemplate(self, show)
    local alpha= Save().completedAlpha or 1
    alpha= (self.completed and not self:IsSelected() and not show) and alpha or 1

    WoWTools_TextureMixin:SetFrame(self, {alpha=alpha, notColor=true})
    self.Shield.Icon:SetAlpha(alpha)--点数，外框
end










local function Init_Achievement()
--选中，提示
    local back= CreateFrame('Button', 'WoWToolsAchievementBackButton', AchievementFrame, 'WoWToolsButtonTemplate')
    back:SetFrameStrata('HIGH')
    back:SetSize(20,20)
    back:SetPoint('LEFT', AchievementFrameFilterDropdown, 'RIGHT', 2, 0)
    back:SetNormalTexture(0)--'Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga')
    WoWTools_ButtonMixin:AddMask(back)
    back:SetScript('OnLeave', GameTooltip_Hide)
    back:SetScript('OnEnter', function(self)
        if self.achievementID then
            WoWTools_SetTooltipMixin:Frame(self)
        end
    end)
    back:SetScript('OnClick', function(self)
        WoWTools_LoadUIMixin:Achievement(self.achievementID)
    end)

--点击，提示
    local next= CreateFrame('Button', 'WoWToolsAchievementNextButton', AchievementFrame, 'WoWToolsButtonTemplate')
    next:SetFrameStrata('HIGH')
    next:SetSize(20,20)
    next:SetPoint('LEFT', back, 'RIGHT')
    next:SetNormalTexture(0)--'Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools.tga')
    WoWTools_ButtonMixin:AddMask(next)
    next:SetScript('OnLeave', GameTooltip_Hide)
    next:SetScript('OnEnter', function(self)
        if self.achievementID then
            WoWTools_SetTooltipMixin:Frame(self)
        end
    end)
    next:SetScript('OnClick', function(self)
        WoWTools_LoadUIMixin:Achievement(self.achievementID)
    end)





--选中，提示
    WoWTools_DataMixin:Hook('AchievementFrame_SelectAchievement', function(achievementID)
        Set_Icon(_G['WoWToolsAchievementBackButton'], achievementID)
    end)
--点击，提示
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnClick', function(self)
        Set_Icon(_G['WoWToolsAchievementNextButton'], self.id)
    end)



--已完成，背景 alpha
    Menu.ModifyMenu("MENU_ACHIEVEMENT_FILTER", function(self, root)
        if not self:IsMouseOver() then
            return
        end
        root:CreateDivider()
        local sub= root:CreateButton(
            WoWTools_DataMixin.onlyChinese and '已完成' or CRITERIA_COMPLETED,
        function()
            return MenuResponse.Open
        end)

        WoWTools_MenuMixin:BgAplha(sub, function()
            return Save().completedAlpha or 1
        end, function(value)
            Save().completedAlpha=value
        end, function()
            Save().completedAlpha= nil
        end, true)

--打开选项界面
        WoWTools_MenuMixin:OpenOptions(sub, {
            name=addName,
            category=WoWTools_OtherMixin.Category
        })
    end)








    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLoad', function(btn)
--完成 目标数量
        btn.completedLable= btn.Icon:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')
        btn.completedLable:SetPoint('LEFT', btn.PlusMinus, 'RIGHT', 4,1)
        btn.completedLable:EnableMouse(true)
        btn.completedLable:SetScript('OnLeave', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent(), false)
            self:SetAlpha(1)
            GameTooltip:Hide()
        end)
        btn.completedLable:SetScript('OnEnter', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent(), true)
            self:SetAlpha(0.5)
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip_SetTitle(GameTooltip,
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '进度' or PVP_PROGRESS_REWARDS_HEADER)
            )
            GameTooltip:Show()
        end)
--是否是统计成就
        btn.statisticTexture= btn.Icon:CreateTexture(nil, 'ARTWORK')
        btn.statisticTexture:SetAtlas('racing')
        btn.statisticTexture:SetPoint('LEFT', btn.completedLable, 'RIGHT', 4, -1)
        btn.statisticTexture:SetSize(20,20)
        btn.statisticTexture:EnableMouse(true)
        btn.statisticTexture:SetScript('OnLeave', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent())
            self:SetAlpha(1)
            GameTooltip:Hide()
        end)
        btn.statisticTexture:SetScript('OnEnter', function(self)
            Set_AchievementTemplate(btn, true)
            self:SetAlpha(0.5)
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip_SetTitle(GameTooltip,
                WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '统计' or STATISTICS)
            )
            GameTooltip:Show()
        end)
--是否是此角色完成 wasEarnedByMe
        btn.byMeTexture= btn.Icon:CreateTexture(nil, 'ARTWORK')
        btn.byMeTexture:SetAtlas(WoWTools_DataMixin.Icon.Player:match('|A:(.-):'))
        btn.byMeTexture:SetSize(20,20)
        btn.byMeTexture:SetPoint('TOPLEFT', btn.PlusMinus, 'BOTTOMLEFT')
        btn.byMeTexture:SetScript('OnLeave', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent(), false)
            self:SetAlpha(1)
            GameTooltip:Hide()
        end)
        btn.byMeTexture:SetScript('OnEnter', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent(), true)
            self:SetAlpha(0.5)
            GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
            GameTooltip_SetTitle(GameTooltip,
                WoWTools_DataMixin.Icon.icon2
                ..(WoWTools_DataMixin.onlyChinese and '完成：|cffffffff我|r' or format('%s: %s', COMPLETE, COMBATLOG_FILTER_STRING_ME))
            )
            GameTooltip:Show()
        end)
--奖励提示
        btn.rewardTexture= btn.Icon:CreateTexture(nil, 'ARTWORK')
        btn.rewardTexture:SetPoint('TOPLEFT', btn.byMeTexture, 'BOTTOMLEFT')
        btn.rewardTexture:SetSize(20,20)
        btn.rewardTexture:EnableMouse(true)
        btn.rewardTexture:SetScript('OnLeave', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent(), false)
            GameTooltip:Hide()
            self:SetAlpha(1)
        end)
        btn.rewardTexture:SetScript('OnEnter', function(self)
            Set_AchievementTemplate(self:GetParent():GetParent(), true)
            if self.itemID then
                WoWTools_SetTooltipMixin:Frame(self)
                self:SetAlpha(0.5)
            end
        end)
--成就ID提示
        btn.idLabel= btn.Shield:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall2')
        btn.idLabel:SetPoint('TOP', btn.Shield.Icon)
--点击，Tooltip, 超连接
        btn.Shield:SetScript('OnLeave', function(self)
            Set_AchievementTemplate(self:GetParent(), false)
            self:SetAlpha(1)
            GameTooltip_Hide()
        end)
        btn.Shield:SetScript('OnEnter', function(self)
            Set_AchievementTemplate(self:GetParent(), true)
            local achievementID= self:GetParent().id
            if achievementID then
                GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:SetAchievementByID(achievementID)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine(
                    '|A:communities-icon-chat:0:0|a'
                    ..(WoWTools_DataMixin.onlyChinese and '说' or SAY)
                    ..WoWTools_DataMixin.Icon.icon2,
                    WoWTools_DataMixin.Icon.left
                )
                GameTooltip:Show()
            end
            self:SetAlpha(0.5)
        end)

        btn.Shield:SetScript('OnMouseUp', function(f) f:SetAlpha(0.5) end)
        btn.Shield:SetScript('OnMouseDown', function(f) f:SetAlpha(0.3) end)
        btn.Shield:SetScript('OnClick', function(f)
            local achievementID= f:GetParent().id
            local achievementLink = achievementID and GetAchievementLink(achievementID)
            if achievementLink then
                WoWTools_ChatMixin:Chat(achievementLink)
            end
        end)
        btn.Shield:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
    end)



    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'Init', function(btn)
        Set_AchievementTemplate(btn, nil)

--完成 目标数量
        local id, _, _, isCompleted, _, _, _, _, flags, _, rewardText, _, wasEarnedByMe, _, isStatistic= GetAchievementInfo(btn.id)
        id= id or btn.id or -1
        flags= flags or 0

        local numCriteria = not isCompleted and GetAchievementNumCriteria(id) or 0
        local completedText
        if numCriteria>0 then
            local c, bar
            for i = 1, numCriteria do
                local _, _, completed, _, _, _, flags2, _, quantityString = GetAchievementCriteriaInfo(id, i)
                if not completed then
                    if ( bit.band(flags2, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR ) then
                        if quantityString then
                            bar = (bar and bar..' ' or '')..quantityString
                        end
                    else
                        c = (c or 0)+1
                    end
                end
            end
            completedText= (c and numCriteria>1 and c..'/'..numCriteria..' ' or '')..(bar or '')
        end
        btn.completedLable:SetText(completedText or "")

--成就图标外框，完成颜色提示
        if isCompleted then
            btn.Icon.frame:SetVertexColor(0,1,0)
        else
            btn.Icon.frame:SetVertexColor(1,1,1)
        end

--奖励提示
        local itemID= C_AchievementInfo.GetRewardItemID(id)
        local itemIcon
        if itemID then
            WoWTools_DataMixin:Load(itemID, 'item')
            itemIcon= select(5, C_Item.GetItemInfoInstant(itemID))
        end
        if not itemID and rewardText and rewardText~='' then
            local name= rewardText:match(SCENARIO_BONUS_REWARD..'(.+)')
            if name then
                WoWTools_DataMixin:Load(name, 'item')
                itemID, _, _, _, itemIcon= C_Item.GetItemInfoInstant(name)
            end
        end
        btn.rewardTexture.itemID= itemID
        btn.rewardTexture:SetTexture(itemIcon or 0)
        btn.rewardTexture:SetShown(itemIcon)

--成就ID提示
        if bit.band(flags, ACHIEVEMENT_FLAGS_ACCOUNT) == ACHIEVEMENT_FLAGS_ACCOUNT then
            btn.idLabel:SetText(WoWTools_DataMixin.Icon.net2..'|cff00ccff'..id..'|r')
        else
            btn.idLabel:SetText(id)
        end
--是否是此角色完成 wasEarnedByMe
        btn.byMeTexture:SetShown(wasEarnedByMe)
--是否是统计成就
        btn.statisticTexture:SetShown(isStatistic)
    end)






    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnLeave', function(btn)
        Set_AchievementTemplate(btn, false)
    end)
    WoWTools_DataMixin:Hook(AchievementTemplateMixin, 'OnEnter', function(btn)
        Set_AchievementTemplate(btn, true)
    end)




--副本成就提示
    Create_Button(AchievementFrameCloseButton, function(btn)
        btn:SetPoint('RIGHT', next, 'LEFT', 2, 0)
    end)

    AchievementFrameCloseButton.achievementButton:SetScript('OnShow', function(self)
        self.instanceID= Get_InstanceID()
        self:set_text()
    end)

















    WoWTools_DataMixin:Hook('AchievementFrameComparison_UpdateDataProvider', function()--比较成就, Blizzard_AchievementUI.lua
        local frame= AchievementFrameComparison.AchievementContainer.ScrollBox
        if not frame:HasView() then
            return
        end
        for _, button in pairs(frame:GetFrames() or {}) do
            if not button.OnEnter then
                button:SetScript('OnLeave', GameTooltip_Hide)
                button:SetScript('OnEnter', function(f)
                    if f.id then
                        GameTooltip:SetOwner(AchievementFrameComparison, "ANCHOR_RIGHT",0,-250)
                        GameTooltip:ClearLines()
                        GameTooltip:SetAchievementByID(f.id)
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
    WoWTools_DataMixin:Hook('AchievementFrameComparison_SetUnit', function(unit)--比较成就
        local text= WoWTools_UnitMixin:GetPlayerInfo(unit, nil, nil, {reName=true, reRealm=true})--玩家信息图标
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
    WoWTools_DataMixin:Hook('AchievementFrame_SetFilter', function(value)
        Save().AchievementFrameFilterDropDown = value
    end)


--为目录，添加 完成/总计
    WoWTools_DataMixin:Hook(AchievementCategoryTemplateMixin, 'OnLoad', function(frame)
        frame.completedBar= CreateFrame('StatusBar', nil, frame.Button)
        frame.completedBar:SetHeight(2)
        frame.completedBar:SetPoint('BOTTOMLEFT', frame.Button, 9, 0)
        frame.completedBar:SetPoint('BOTTOMRIGHT', frame.Button, -9, 0)
        frame.completedBar:SetMinMaxValues(0, 100)
        WoWTools_TextureMixin:SetStatusBar(frame.completedBar)

        frame.completedLable= frame.Button:CreateFontString(nil, 'BORDER','GameFontNormalTiny2')
        frame.completedLable:SetPoint('BOTTOMRIGHT', frame.Button)
    end)

    WoWTools_DataMixin:Hook(AchievementCategoryTemplateMixin, 'Init', function(frame, elementData)
        local id = elementData.id
	    local numAchievements, numCompleted
        local isSummary= id == "summary"--总览
        if isSummary then
            numAchievements, numCompleted = GetNumCompletedAchievements(InGuildView())
        else
            numAchievements, numCompleted = AchievementFrame_GetCategoryTotalNumAchievements(id, true);
        end
        if numAchievements and numAchievements>0 and numCompleted and numAchievements> numCompleted then
            local value= numCompleted/numAchievements*100
            frame.completedBar:SetValue(value)
            frame.completedBar:SetShown(true)
            if isSummary then
                frame.completedLable:SetFormattedText('%d%%', numCompleted/numAchievements*100)
            else
                frame.completedLable:SetFormattedText('%d', numAchievements-numCompleted)
            end
            if isSummary then
                frame.completedLable:SetTextColor(WARNING_FONT_COLOR:GetRGB())
            elseif elementData.isChild then
                frame.completedLable:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
            else
                frame.completedLable:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
            end
        else
            frame.completedBar:SetValue(0)
            frame.completedBar:SetShown(false)
            frame.completedLable:SetText('')
        end
    end)

--近期成就，添加，百份比
    local function Get_ValeText(total, completed)
        if total and total>0 and completed then
            return WoWTools_DataMixin:MK(completed, 3).."/"..WoWTools_DataMixin:MK(total, 3)
                ..(completed==total and '|cnWARNING_FONT_COLOR:' or '|cffffd200')
                ..format(' %d%%', completed/total*100)
        end
    end
    WoWTools_DataMixin:Hook('AchievementFrameSummaryCategory_OnShow', function(self)
        local text = Get_ValeText(AchievementFrame_GetCategoryTotalNumAchievements(self:GetID(), true))
        if text then
            self.Text:SetText(text)
        end
    end)
    WoWTools_DataMixin:Hook('AchievementFrameSummaryCategoriesStatusBar_Update', function()
        local text = Get_ValeText(GetNumCompletedAchievements(InGuildView()))
        if text then
            AchievementFrameSummaryCategoriesStatusBarText:SetText(text            )
        end
    end)


    Init_Achievement=function()end
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
            local name, _, instanceID
            if btn.instanceID then
                name, _, _, _, _, _, _, _, _, instanceID= EJ_GetInstanceInfo(btn.instanceID)--journalInstanceID
            end
            btn.achievementButton.instanceID = instanceID
            btn.achievementButton.name=  name
            btn.achievementButton:set_text()
        end
    end
    EncounterJournal.instanceSelect.ScrollBox:HookScript('OnShow', function(frame)
        C_Timer.After(0.1, function()
            Init_Box(frame)
        end)
    end)
    WoWTools_DataMixin:Hook(EncounterJournal.instanceSelect.ScrollBox, 'Update', function(frame)
        Init_Box(frame)
    end)

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
        WoWToolsSave['Plus_Achievement']= WoWToolsSave['Plus_Achievement'] or {completedAlpha=1}
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
                        addName..WoWTools_DataMixin.Icon.icon2,
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
            self:SetScript('OnEvent', nil)
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
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end

    elseif arg1=='Blizzard_EncounterJournal' and WoWToolsSave then
       Init_EncounterJournal()

        if C_AddOns.IsAddOnLoaded('Blizzard_AchievementUI') then
            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)