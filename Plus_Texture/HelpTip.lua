--隐藏教程


local function Save()
    return WoWToolsSave['Plus_Texture'] or {}
end





local function Init()
    if Save().disabledHelpTip then
        return
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

    if C_CVar.GetCVarBool("showNPETutorials") and not InCombatLockdown() then
        C_CVar.SetCVar("showNPETutorials",'0')
    end

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
    end


    C_Timer.After(2, function()
        --[[if SplashFrame and SplashFrame:IsShown() then新内容 bug
            --SplashFrame:Close();
            C_SplashScreen.SendSplashScreenCloseTelem()
            print(WoWTools_DataMixin.Icon.icon2..WoWTools_TextureMixin.addName,
            '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE)..'|r|n|cff00ff00',
            SplashFrame.Label and SplashFrame.Label:GetText() or ''
        )
        end]]

        if not Save().disabledHelpTip then--错误，提示
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
        end
    end)

    Init=function()end
end






function WoWTools_TextureMixin:Init_HelpTip()--隐藏教程
    Init()
end