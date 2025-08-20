--低等级，开启，为测试用



local function Init()
    if WoWTools_DataMixin.Player.IsMaxLevel or not WoWTools_DataMixin.Player.husandro then
        Init=function()end
        return
    end


    local panels = {
        { name = "GroupFinderFrame", addon = nil },
        { name = "PVPUIFrame", addon = "Blizzard_PVPUI" },
        { name = "ChallengesFrame", addon = "Blizzard_ChallengesUI", hideLeftInset = true },
        { name = "DelvesDashboardFrame", addon = "Blizzard_DelvesDashboardUI", hideLeftInset = true },
    }



    PVEFrame:SetScript('OnShow', function(self)
        for index in pairs(panels) do
            PanelTemplates_ShowTab(self, index)
        end

        -- If timerunning enabled, hide PVP and M+, and re-anchor delves to Dungeons tab
        if WoWTools_DataMixin.Is_Timerunning then
            self.tab2:Hide();
            self.tab3:Hide();
            if self.tab4:IsShown() then
                self.tab4:SetPoint("TOPLEFT", self.tab1, "TOPRIGHT", 3, 0);
            end
        else

        -- Otherwise, anchor Delves tab to PVP if M+ hidden, or to M+ if both are shown - to prevent a gap if the player is ineligible for M+ and we hide the tab
            self.tab3:SetShown(true)
            if self.tab4:IsShown() then
                if self.tab2:IsShown() and not self.tab3:IsShown() then
                    self.tab4:SetPoint("TOPLEFT", self.tab2, "TOPRIGHT", 3, 0);
                elseif self.tab2:IsShown() and self.tab3:IsShown() then
                    self.tab4:SetPoint("TOPLEFT", self.tab3, "TOPRIGHT", 3, 0);
                end
            end
        end

        UpdateMicroButtons();

        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

        EventRegistry:TriggerEvent("PlunderstormQueueTutorial.Update")
    end)

    function PVEFrame_ShowFrame(sidePanelName, selection)
        local self = PVEFrame;
        -- find side panel
        local tabIndex;
        if ( sidePanelName ) then
            for index, data in pairs(panels) do
                if ( data.name == sidePanelName ) then
                    tabIndex = index;
                    break;
                end
            end
        else
            -- no side panel specified, check current panel
            if ( self.activeTabIndex ) then
                tabIndex = self.activeTabIndex;
            else
                -- no current panel, go to the first panel
                tabIndex = 1;
            end
        end
        if ( not tabIndex ) then
            return;
        end
        if ( panels[tabIndex].check and not panels[tabIndex].check() ) then
            tabIndex = self.activeTabIndex or 1;
        end

        -- load addon if needed
        if ( panels[tabIndex].addon ) then
            UIParentLoadAddOn(panels[tabIndex].addon);
            panels[tabIndex].addon = nil;
        end

        -- we've loaded the AddOn, so try to dereference the selection if needed
        if ( type(selection) == "string" ) then
            selection = _G[selection];
        end

        -- Hide the left panel if the panel doesn't need it
        if ( panels[tabIndex].hideLeftInset ) then
            PVEFrame_HideLeftInset();
        else
            PVEFrame_ShowLeftInset();
        end

        -- show it
        ShowUIPanel(self);

        self.activeTabIndex = tabIndex;
        PanelTemplates_SetTab(self, tabIndex);
        if ( panels[tabIndex].width ) then
            self:SetWidth(panels[tabIndex].width);
        else
            self:SetWidth(PVE_FRAME_BASE_WIDTH);
        end

        UpdateUIPanelPositions(PVEFrame);

        for index, data in pairs(panels) do
            local panel = _G[data.name];
            if ( index == tabIndex ) then
                panel:Show();
                if( panel.update ) then
                    panel:update(selection);
                end
            elseif ( panel ) then
                panel:Hide();
            end
        end

    end


    EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
        if arg1=='Blizzard_ChallengesUI' then
            C_Timer.After(0.3, function()
                ChallengesKeystoneFrame:Show()
            end)
            EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
        end
    end)


    Init=function()end
end




function WoWTools_ChallengeMixin:Is_HuSandro()
    Init()
end

