local e= select(2, ...)
local function Save()
    return WoWTools_ProfessionMixin.Save
end




local ArcheologyButton
e.LoadData({id=87399, type='item'})

















local function Init_ArcheologyDigsiteProgressBar_OnShow(frame)
    if not frame.tipsButton then
        frame.tipsButton= WoWTools_ButtonMixin:Cbtn(frame, {size={20,20}, icon='hide'})
        frame.tipsButton:SetPoint('RIGHT', frame, 'LEFT', 0, -4)
        function frame.tipsButton:set_atlas()
            self:SetNormalAtlas(Save().ArcheologySound and 'chatframe-button-icon-voicechat' or 'chatframe-button-icon-speaker-off')
        end
        function frame.tipsButton:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '声音提示' or  SOUND, e.GetEnabeleDisable(Save().ArcheologySound))
            e.tips:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName)
            e.tips:Show()
        end
        frame.tipsButton:SetAlpha(0.3)
        frame.tipsButton:SetScript('OnLeave', function(self) GameTooltip_Hide() self:SetAlpha(0.3) end)
        frame.tipsButton:SetScript('OnEnter', function(self)
            self:set_tooltips()
            self:SetAlpha(1)
        end)

        function frame.tipsButton:play_sound()
            e.PlaySound()
            WoWTools_FrameMixin:HelpFrame({frame=ArcheologyDigsiteProgressBar, point='left', topoint=self, size={40,40}, color={r=1,g=0,b=0,a=1}, show=true, hideTime=3, y=0})--设置，提示
        end

        frame.tipsButton:SetScript('OnClick', function(self)
            Save().ArcheologySound= not Save().ArcheologySound and true or nil
            self:set_atlas()
            self:set_event()
            self:set_tooltips()
            if Save().ArcheologySound then
                self:play_sound()
            end
        end)

        function frame.tipsButton:set_event()
            if self:IsVisible() and Save().ArcheologySound then
                self:RegisterUnitEvent('UNIT_AURA', 'player')
            else
                self:UnregisterAllEvents()
            end
        end
        frame.tipsButton:SetScript('OnEvent', function(self, _, _, tab)
            if tab and tab.addedAuras then
                for _, info in pairs(tab.addedAuras) do
                    if info.spellId==210837 then
                        self:play_sound()
                        break
                    end
                end
            end
        end)
        frame.tipsButton:SetScript('OnShow', frame.tipsButton.set_event)
        frame.tipsButton:SetScript('OnHide', frame.tipsButton.set_event)

        frame.tipsButton:set_event()
        frame.tipsButton:set_atlas()

        ArcheologyDigsiteProgressBar:HookScript('OnHide', function(self)
            self.tipsButton:set_event()
        end)
    end

    if ArcheologyButton and not ArcheologyButton.keyButton then
        ArcheologyButton.keyButton= WoWTools_ButtonMixin:Cbtn(frame, {size={20,20}, icon='hide'})
        ArcheologyButton.keyButton:SetPoint('LEFT', frame, 'RIGHT', 0, -4)
        ArcheologyButton.keyButton.text=WoWTools_LabelMixin:Create(ArcheologyButton.keyButton, {color={r=0, g=1, b=0}, size=14})
        ArcheologyButton.keyButton.text:SetPoint('CENTER')

        ArcheologyButton.keyButton:SetScript('OnLeave', GameTooltip_Hide)
        ArcheologyButton.keyButton:SetScript('OnEnter', ArcheologyButton.set_tooltip)

        ArcheologyButton.keyButton:SetScript('OnMouseWheel', function(_, d)
            if not UnitAffectingCombat('player') then
                ArcheologyButton:set_OnMouseWheel(d)
            end
        end)

        ArcheologyButton.keyButton.index=3
        ArcheologyButton.keyButton.spellID= ArcheologyButton.spellID
        ArcheologyButton.keyButton.index= ArcheologyButton.index

        function ArcheologyButton.keyButton:set_text()
            local text= ArcheologyButton.text:GetText() or ''
            self.text:SetText(text)
            if text=='' then
                self:SetNormalAtlas('newplayertutorial-icon-key')
            else
                self:SetNormalTexture(134435)
            end
            self:SetAlpha(text=='' and 0.3 or 1)
        end

        ArcheologyButton.keyButton:set_text()
    end
end













local function Init()
    hooksecurefunc(ArchaeologyFrame.completedPage, 'UpdateFrame', function(self)--提示
        if not IsArtifactCompletionHistoryAvailable() then
            return
        end
        for i=1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
            local btn=  self["artifact"..i]
            if btn and btn:IsShown() then
                local name, _, rarity, _, _,  _, _, _, _, completionCount = GetArtifactInfoByRace(btn.raceIndex, btn.projectIndex);
                local raceName = GetArchaeologyRaceInfo(btn.raceIndex)
                if raceName and name and completionCount and completionCount>0 then
                    local sub= raceName
                    if rarity == 0 then
                        name= '|cffffffff'..name..'|r'
                        sub= sub.."-|cffffffff"..(e.onlyChinese and '普通' or ITEM_QUALITY1_DESC).."|r"
                    else
                        name='|cff0070dd'..name..'|r'
                        sub= sub.."-|cff0070dd"..(e.onlyChinese and '精良' or ITEM_QUALITY3_DESC).."|r"
                    end
                    btn.artifactName:SetText(name)
                    btn.artifactSubText:SetText(sub..' |cnGREEN_FONT_COLOR:'..completionCount..'|r')
                end
            end
        end
    end)

    --增加一个按钮， 提示物品

    hooksecurefunc('ArchaeologyFrame_CurrentArtifactUpdate', function()
        local itemID= select(3, GetArchaeologyRaceInfo(ArchaeologyFrame.artifactPage.raceID))
        local btn= ArchaeologyFrame.artifactPage.tipsButton
        if itemID then
            if not btn then
                btn= WoWTools_ButtonMixin:Cbtn(ArchaeologyFrame.artifactPage, {button='ItemButton', icon='hide'})
                btn:SetPoint('RIGHT', ArchaeologyFrameArtifactPageSolveFrameStatusBar, 'LEFT', -39, 0)
                btn:SetScript('OnLeave', function() e.tips:Hide() end)
                btn:SetScript('OnEnter', function(frame)
                    e.tips:SetOwner(frame, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    if frame.itemID then
                        e.tips:SetItemByID(frame.itemID)
                    end
                    e.tips:AddLine(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName)
                    e.tips:Show()
                end)

                btn.btn2= WoWTools_ButtonMixin:Cbtn(ArchaeologyFrame.artifactPage, {button='ItemButton', icon='hide'})
                btn.btn2:SetPoint('BOTTOM', btn, 'TOP', 0, 7)
                btn.btn2:SetScript('OnLeave', function() e.tips:Hide() end)
                btn.btn2:SetScript('OnEnter', function(frame)
                    e.tips:SetOwner(frame, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetItemByID(87399)
                    e.tips:AddLine(WoWTools_Mixin.addName, WoWTools_ProfessionMixin.addName)
                    e.tips:Show()
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
                ArchaeologyFrame.artifactPage.tipsButton= btn
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
end










function WoWTools_ProfessionMixin:Init_Archaeology()
    Init()
    ArcheologyDigsiteProgressBar:HookScript('OnShow', Init_ArcheologyDigsiteProgressBar_OnShow)
end