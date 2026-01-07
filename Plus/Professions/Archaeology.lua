--考古学
local function Save()
    return WoWToolsSave['Plus_Professions']
end




--local ArcheologyButton
--item=87399/修复的遗物





















local function Init_ArchaeologyFrame()
    if not C_AddOns.IsAddOnLoaded("Blizzard_ArchaeologyUI") then
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_ArchaeologyUI' then
                Init_ArchaeologyFrame()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
        return
    end


    WoWTools_DataMixin:Hook(ArchaeologyFrame.completedPage, 'UpdateFrame', function(self)--提示
        if not IsArtifactCompletionHistoryAvailable() then
            return
        end
        for i=1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do--12
            local btn=  self["artifact"..i]
            if btn and btn:IsShown() then
                local name, _, rarity, _, _,  _, _, _, _, completionCount = GetArtifactInfoByRace(btn.raceIndex, btn.projectIndex);
                local raceName = GetArchaeologyRaceInfo(btn.raceIndex)
                if raceName and name and completionCount and completionCount>0 then
                    local sub= raceName
                    if rarity == 0 then
                        name= '|cffffffff'..name..'|r'
                        sub= sub.."-"..WoWTools_ItemMixin.QualityText[1]--普通
                    else
                        name='|cff0070dd'..name..'|r'
                        sub= sub.."-"..WoWTools_ItemMixin.QualityText[3]--精良
                    end
                    btn.artifactName:SetText(name)
                    btn.artifactSubText:SetText(sub..' |cnGREEN_FONT_COLOR:'..completionCount..'|r')
                end
            end
        end
    end)

--增加一个按钮， 提示物品
    WoWTools_DataMixin:Hook('ArchaeologyFrame_CurrentArtifactUpdate', function()
        local itemID= select(3, GetArchaeologyRaceInfo(ArchaeologyFrame.artifactPage.raceID))
        local btn= ArchaeologyFrame.artifactPagGameTooltipButton
        if itemID then
            if not btn then
                btn= WoWTools_ButtonMixin:Cbtn(ArchaeologyFrame.artifactPage, {
                    frameType='ItemButton',
                })
                btn:SetPoint('RIGHT', ArchaeologyFrameArtifactPageSolveFrameStatusBar, 'LEFT', -39, 0)
                btn:SetScript('OnLeave', function() GameTooltip:Hide() end)
                btn:SetScript('OnEnter', function(frame)
                    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    if frame.itemID then
                        GameTooltip:SetItemByID(frame.itemID)
                    end
                    GameTooltip:AddLine(WoWTools_DataMixin.addName, WoWTools_ProfessionMixin.addName)
                    GameTooltip:Show()
                end)

                btn.btn2= WoWTools_ButtonMixin:Cbtn(ArchaeologyFrame.artifactPage, {
                    frameType='ItemButton',
                })
                btn.btn2:SetPoint('BOTTOM', btn, 'TOP', 0, 7)
                btn.btn2:SetScript('OnLeave', function() GameTooltip:Hide() end)
                btn.btn2:SetScript('OnEnter', function(frame)
                    GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetItemByID(87399)
                    GameTooltip:AddLine(WoWTools_DataMixin.addName, WoWTools_ProfessionMixin.addName)
                    GameTooltip:Show()
                end)

                function btn:set_Event()
                    if self:IsShown() then
                        self:RegisterEvent('BAG_UPDATE_DELAYED')
                    else
                        self:UnregisterAllEvents()
                        self:Reset()
                    end
                end
                btn:SetScript("OnShow", btn.set_Event)
                btn:SetScript("OnHide", btn.set_Event)
                function btn:set_Item()
                    local num
                    if self.itemID then
                        self:SetItem(self.itemID)
                        num= C_Item.GetItemCount(self.itemID, true, false, true)
                        self:SetItemButtonCount(num)
                        self:SetAlpha(num==0 and 0.3 or 1)
                    end
                    self.btn2:SetItem(87399)
                    num= C_Item.GetItemCount(87399, true, false, true)
                    self.btn2:SetItemButtonCount(num)
                    self.btn2:SetAlpha(num==0 and 0.3 or 1)
                end
                btn:SetScript('OnEvent', btn.set_Item)
                ArchaeologyFrame.artifactPagGameTooltipButton= btn
            end
            btn.itemID= itemID
            btn:set_Item()
            btn:set_Event()
        end
        if btn then
            btn:SetShown((itemID and ArchaeologyFrame:IsVisible()) and true or false)
        end
    end)

    ArchaeologyFrameInfoButton:SetFrameStrata('DIALOG')

    Init_ArchaeologyFrame=function()end
end
















local function Init_ProgressBar()
    local btn= CreateFrame('Button', 'WoWToolsArcheologyProgressBarSounButton', ArcheologyDigsiteProgressBar, 'WoWToolsButtonTemplate') --WoWTools_ButtonMixin:Cbtn(ArcheologyDigsiteProgressBar, {size=20})

    btn:SetPoint('RIGHT', ArcheologyDigsiteProgressBar, 'LEFT', 0, -4)
    function btn:set_atlas()
        self:SetNormalAtlas(Save().ArcheologySound and 'chatframe-button-icon-voicechat' or 'chatframe-button-icon-speaker-off')
    end
    btn.tooltip= WoWTools_DataMixin.Icon.icon2..(WoWTools_DataMixin.onlyChinese and '声音提示' or  SOUND)


    function btn:play_sound()
        WoWTools_DataMixin:PlaySound()
        WoWTools_FrameMixin:HelpFrame({frame=ArcheologyDigsiteProgressBar, point='left', topoint=self, size={40,40}, color={r=1,g=0,b=0,a=1}, show=true, hideTime=3, y=0})--设置，提示
    end

    btn:SetScript('OnClick', function(self)
        Save().ArcheologySound= not Save().ArcheologySound and true or false
        self:set_atlas()
        self:set_event()
        if Save().ArcheologySound then
            self:play_sound()
        end
    end)

    function btn:set_event()
        self:UnregisterAllEvents()
        if self:IsVisible() and Save().ArcheologySound then
            self:RegisterUnitEvent('UNIT_AURA', 'player')
        end
        self:set_atlas()
    end
    btn:SetScript('OnEvent', function(self, _, _, tab)
        if tab and tab.addedAuras then
            for _, info in pairs(tab.addedAuras) do
                if canaccesstable(info) and canaccessvalue(info.spellId) and info.spellId==210837 then
                    self:play_sound()
                    break
                end
            end
        end
    end)
    btn:SetScript('OnShow', btn.set_event)
    btn:SetScript('OnHide', btn.set_event)

    btn:set_event()





--ArcheologyDigsiteProgressBar.researchFieldID


    local bar= CreateFrame('Button', 'WoWToolsArcheologyProgressBarBranchButton', ArcheologyDigsiteProgressBar, 'WoWToolsButtonTemplate')

    bar.texture= bar:CreateTexture(nil, "BORDER")
    bar.texture:SetPoint('TOPLEFT')
    bar.texture:SetSize(36, 36)--23x23 显示图片太小了，只能大些

    bar.Text= bar:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    bar.Text:SetPoint('BOTTOM', bar, 'TOP')

    bar.Text2= bar:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    bar.Text2:SetPoint('TOPRIGHT', bar, 'BOTTOMRIGHT')
    bar.Text2:EnableMouse(true)
    bar.Text2:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip:Hide()
    end)
    bar.Text2:SetScript('OnEnter', function(self)
        self:SetAlpha(0.3)
        local itemID= self:GetParent().raceItemID
        if not itemID then
            return
        end
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        GameTooltip:SetItemByID(itemID)
        GameTooltip:Show()
    end)

    bar:SetPoint('LEFT', ArcheologyDigsiteProgressBar, 'RIGHT', 0, -4)
    bar.tooltip= WoWTools_DataMixin.Icon.left
        ..(WoWTools_DataMixin.onlyChinese and '考古学' or PROFESSIONS_ARCHAEOLOGY)
        ..WoWTools_DataMixin.Icon.icon2
        ..(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL)
        ..WoWTools_DataMixin.Icon.right
    bar:SetNormalTexture(WoWTools_DataMixin.Icon.icon)

    function bar:open()
        if not ArchaeologyFrame then
            ArchaeologyFrame_LoadUI()
        end
        if not ArchaeologyFrame:IsShown() then
            ArchaeologyFrame_Show()
        end
        if ArchaeologyFrame.selectedTab~=ArchaeologyFrameSummarytButton:GetID() then
            ArchaeologyFrame_OnTabClick(ArchaeologyFrameSummarytButton)
        end
    end

    bar:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            bar:open()
            if self.branchID then
                local raceName= GetArchaeologyRaceInfoByID(self.branchID)
                for i= 1, GetNumArchaeologyRaces() do
                    if GetArchaeologyRaceInfo(i)==raceName then
                        if GetNumArtifactsByRace(i)>0 then
                            ArchaeologyFrame_ShowArtifact(i)
                        end
                        break
                    end
                end
            end
            return
        end

        MenuUtil.CreateContextMenu(self, function(_, root)
            local sub=root:CreateCheckbox(
                (select(3, GetProfessions()) and '' or '|cff626262')
                ..(WoWTools_DataMixin.onlyChinese and '自动显示' or  format(GARRISON_FOLLOWER_NAME, SELF_CAST_AUTO, SHOW)),
            function()
                return Save().showArcheologyBar
            end, function()
                Save().showArcheologyBar= not Save().showArcheologyBar and true or nil
                self:set_event()
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine('PLAYER_STOPPED_MOVING')
            end)

            root:CreateDivider()

            for i= 1, GetNumArchaeologyRaces() do
                local num=GetNumArtifactsByRace(i)
                if num>0 then
                    local name, _, _,  cur, need, max =  GetArchaeologyRaceInfo(i)
                    if name and cur and need and max then
                        sub= root:CreateButton(
                            '|cffffd200'
                            ..WoWTools_TextMixin:CN(name)
                            ..'|r ('
                            ..(need==max and '|cnWARNING_FONT_COLOR:' or (cur>=need and '|cnGREEN_FONT_COLOR:' or ''))
                            ..cur..'/'..need..'|r) #|cffffffff'
                            ..'|cffff8040'..(num-1),
                        function(data)
                            bar:open()
                            ArchaeologyFrame_ShowArtifact(data.rightText)
                            return MenuResponse.Open
                        end, {rightText=i})
                        WoWTools_MenuMixin:SetRightText(sub)
                    end
                end
            end

            root:CreateDivider()
            WoWTools_MenuMixin:OpenOptions(root, {name=WoWTools_ProfessionMixin.addName})

            WoWTools_MenuMixin:SetGridMode(root)
        end)
    end)

    function bar:settings()
        if not self.branchID or not self:IsVisible() then
            return
        end
        local _, raceTextureID, raceItemID, numFragmentsCollected, numFragmentsRequired, maxFragments= GetArchaeologyRaceInfoByID(self.branchID)

        self.texture:SetTexture(raceTextureID or 0)
        if raceTextureID then
            self:SetNormalTexture(0)
        end

        if numFragmentsCollected and numFragmentsRequired then
            self.Text:SetText(numFragmentsCollected..'/'..numFragmentsRequired)

            if numFragmentsCollected==maxFragments then
                self.Text:SetTextColor(WARNING_FONT_COLOR:GetRGB())
            elseif numFragmentsCollected >= numFragmentsRequired then
                self.Text:SetTextColor(GREEN_FONT_COLOR:GetRGB())
            else
                self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
            end
        else
            self.Text:SetText('')
        end

        local count=''
        if raceItemID then
            WoWTools_DataMixin:Load(raceItemID, 'item')
            count= WoWTools_ItemMixin:GetCount(raceItemID, {notZero=true}) or ''
            local icon= select(5, C_Item.GetItemInfoInstant(raceItemID))
            if icon then
                count= count..'|T'..icon..':0|t'
            end
        end
        self.Text2:SetText(count)

        self.raceItemID= raceItemID
    end

    function bar:set_event()
        self:UnregisterEvent('PLAYER_STOPPED_MOVING')
        self:UnregisterEvent('PLAYER_ENTERING_WORLD')

        if Save().showArcheologyBar and select(3, GetProfessions()) then
            self:RegisterEvent('PLAYER_ENTERING_WORLD')
            if not IsInInstance() then
                self:RegisterEvent('PLAYER_STOPPED_MOVING')
            end
        end
    end

    function bar:show_bar()
        if CanScanResearchSite() then
            ArcheologyDigsiteProgressBar:SetShown(true)
        end
    end
    bar:SetScript('OnHide', function(self)
        self:UnregisterEvent('CHAT_MSG_CURRENCY')
    end)
    bar:SetScript('OnShow', function(self)
        self:RegisterEvent('CHAT_MSG_CURRENCY')
        self:settings()
    end)

    bar:RegisterEvent('ARCHAEOLOGY_SURVEY_CAST')
    bar:RegisterEvent('ARCHAEOLOGY_FIND_COMPLETE')
    bar:RegisterEvent('ARTIFACT_DIGSITE_COMPLETE')

    bar:RegisterEvent('RESEARCH_ARTIFACT_COMPLETE')--当通过考古学解决某个物品时触发。
    bar:RegisterEvent('RESEARCH_ARTIFACT_UPDATE')

    bar:SetScript('OnEvent', function(self, event, ...)
        if event=='PLAYER_STOPPED_MOVING' then
            self:show_bar()
            return
        elseif event=='PLAYER_ENTERING_WORLD' then
            self:set_event()
            return
        end

        local researchBranchID
        if event=='ARCHAEOLOGY_SURVEY_CAST' or event=='ARCHAEOLOGY_FIND_COMPLETE' then
            researchBranchID= select(3, ...)
        elseif event=='ARTIFACT_DIGSITE_COMPLETE' then
            researchBranchID= ...
        end

        self.branchID= researchBranchID or self.branchID
        self:settings()
    end)


    if Save().showArcheologyBar and select(3, GetProfessions()) then
        bar:show_bar()
    end

    bar:set_event()
    Init_ProgressBar=function()end
end











function WoWTools_ProfessionMixin:Init_Archaeology()
    Init_ArchaeologyFrame()
    Init_ProgressBar()
end