--隐藏教程
local e= select(2, ...)

local function Save()
    return WoWTools_TextureMixin.Save
end





local function Init()
    if Save().disabledHelpTip then
        return
    end

    hooksecurefunc(HelpTip, 'Show', function(self, parent)--隐藏所有HelpTip HelpTip.lua
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

    C_CVar.SetCVar("showNPETutorials",'0')

    --Blizzard_TutorialPointerFrame.lua 隐藏, 新手教程
    hooksecurefunc(TutorialPointerFrame, 'Show',function(self, content, direction, anchorFrame, ofsX, ofsY, relativePoint, backupDirection, showMovieName, loopMovie, resolution)
        if not anchorFrame or not self.DirectionData[direction] then
            return
        end
        local ID=self.NextID
        if ID then
            C_Timer.After(2, function()
                TutorialPointerFrame:Hide(ID-1)
                print(e.Icon.icon2..WoWTools_TextureMixin.addName, '|cffff00ff'..content)
            end)
        end
    end)

    hooksecurefunc(ReportFrame, 'UpdateThankYouMessage', function(self, showThankYouMessage)
        if showThankYouMessage then
            C_Timer.After(1, function()
                if self:IsShown() then
                    self:Hide()
                    print(e.Icon.icon2..WoWTools_TextureMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '感谢您的举报！' or ERR_REPORT_SUBMITTED_SUCCESSFULLY)..'|r', e.onlyChinese and '关闭' or CLOSE)
                end
            end)
        end
    end)

    C_Timer.After(2, function()
        if SplashFrame and SplashFrame:IsShown() then
            SplashFrame:Close();
            print(e.Icon.icon2..WoWTools_TextureMixin.addName, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '隐藏' or HIDE)..'|r|n|cff00ff00', SplashFrame.Label and SplashFrame.Label:GetText() or '')
        end

        if not Save().disabledHelpTip then--错误，提示
            if ScriptErrorsFrame then
                if ScriptErrorsFrame:IsShown() then
                    print(e.Icon.icon2..WoWTools_TextureMixin.addName)
                    print(ScriptErrorsFrame.ScrollFrame.Text:GetText())
                    ScriptErrorsFrame.Close:Click()
                end
                ScriptErrorsFrame:HookScript('OnShow', function(self)
                    print(WoWTools_TextureMixin.addName, WoWTools_TextureMixin.addName)
                    print(self.ScrollFrame.Text:GetText())
                    ScriptErrorsFrame.Close:Click()
                end)
            end
        end
    end)
end






function WoWTools_TextureMixin:Init_HelpTip()--隐藏教程
    Init()
end