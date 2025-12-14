

local function Init()
    if C_CVar.GetCVarBool("showNPETutorials") and not InCombatLockdown() then
        C_CVar.SetCVar("showNPETutorials",'0')
    end

    WoWTools_DataMixin:Hook(HelpTip, 'Show', function(self, parent)--隐藏所有HelpTip HelpTip.lua
        local find
        for frame in self.framePool:EnumerateActive() do
            local btn= frame.OkayButton:IsShown() and frame.OkayButton or (frame.CloseButton:IsShown() and frame.CloseButton)
            if btn then
                find=true
                btn:Click()
            end
        end
        if not find then
            self:HideAll(parent)
        end
    end)


--Blizzard_TutorialPointerFrame.lua 隐藏, 新手教程
    WoWTools_DataMixin:Hook(TutorialPointerFrame, 'Show',function(self, content, direction, anchorFrame)
        if not anchorFrame or not self.DirectionData[direction] then
            return
        end
        local ID=self.NextID
        if ID then
            C_Timer.After(2, function()
                TutorialPointerFrame:Hide(ID-1)
                print(
                    WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName,
                    '|cffff00ff',
                    WoWTools_TextMixin:CN(content)
                )
            end)
        end
    end)

    WoWTools_DataMixin:Hook(ReportFrame, 'UpdateThankYouMessage', function(self, showThankYouMessage)
        if showThankYouMessage then
            C_Timer.After(1, function()
                if self:IsShown() then
                    self:Hide()
                    print(
                        WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName,
                        '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '感谢您的举报！' or ERR_REPORT_SUBMITTED_SUCCESSFULLY)..'|r',
                        WoWTools_DataMixin.onlyChinese and '关闭' or CLOSE
                    )
                end
            end)
        end
    end)

    if SplashFrame then
        WoWTools_TextureMixin:SetButton(SplashFrame.TopCloseButton)
        WoWTools_TextureMixin:SetUIButton(SplashFrame.BottomCloseButton)
    end

    C_Timer.After(2, function()
        if ScriptErrorsFrame then
            if ScriptErrorsFrame:IsShown() then
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName)
                print(WoWTools_TextMixin:CN(ScriptErrorsFrame.ScrollFrame.Text:GetText()))
                ScriptErrorsFrame.Close:Click()
            end
            ScriptErrorsFrame:HookScript('OnShow', function(self)
                print(WoWTools_TextureMixin.addName, WoWTools_TextureMixin.addName)
                print(WoWTools_TextMixin:CN(self.ScrollFrame.Text:GetText()))
                ScriptErrorsFrame.Close:Click()
            end)
        end
    end)
end








local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then
            if WoWTools_OtherMixin:AddOption(
                'HelpTip',
                '|A:newplayertutorial-drag-cursor:0:0|a'..(WoWTools_DataMixin.onlyChinese and '隐藏教程' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, SHOW_TUTORIALS)),
                nil
            ) then
                Init()
            end

            Init=function()end

            self:SetScript('OnEvent', nil)
            self:UnregisterEvent(event)
        end
    end
end)