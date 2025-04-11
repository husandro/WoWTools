--地下城查找器








local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(LFDMicroButton,  {size=WoWToolsSave['Plus_MainMenu'].size, color=true})
    frame.Text:SetPoint('TOP', LFDMicroButton, 0,  -3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local lv= C_MythicPlus.GetOwnedKeystoneLevel() or 0
        self.Text:SetText(lv>0 and lv or '')
    end
    frame:RegisterEvent('LOADING_SCREEN_DISABLED')
    frame:RegisterEvent('BAG_UPDATE_DELAYED')
    frame:SetScript('OnEvent', frame.settings)

    LFDMicroButton.setTextFrame= frame
    LFDMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        self.setTextFrame:settings()
        GameTooltip:AddLine(' ')

        local find= WoWTools_ChallengeMixin:ActivitiesTooltip()--周奖励，提示
        local link= WoWTools_WoWDate[WoWTools_DataMixin.Player.GUID].Keystone.link
        if link then
            GameTooltip:AddLine('|T4352494:0|t'..link)
        end

        if find or link then
            GameTooltip:AddLine(' ')
        end

        local bat= InCombatLockdown()

        GameTooltip:AddLine(
            (bat and '|cff828282' or '|cffffffff')..(WoWTools_DataMixin.onlyChinese and '地下城和团队副本' or GROUP_FINDER)
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        GameTooltip:AddLine(
            (bat and '|cff828282' or '|cffffffffPvP')
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddLine(
            (
                (bat or PlayerGetTimerunningSeasonID() or not WoWTools_DataMixin.Player.IsMaxLevel)
                and '|cff828282' or '|cffffffff'
            )
            ..(WoWTools_DataMixin.onlyChinese and '史诗地下城' or MYTHIC_DUNGEONS)
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        GameTooltip:Show()
    end)


    LFDMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            PVEFrame_ToggleFrame("PVPUIFrame", LFGListPVPStub)
        end
    end)

    LFDMicroButton:EnableMouseWheel(true)
    LFDMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if d==1 then
            if not LFGListPVEStub:IsVisible() then
                PVEFrame_ToggleFrame("GroupFinderFrame", LFGListPVEStub)--, RaidFinderFrame)
            end
        elseif d==-1 then
            if not ChallengesFrame or not ChallengesFrame:IsVisible() then
                PVEFrame_ToggleFrame("ChallengesFrame", nil)
            end
            --[[if not DelvesDashboardFrame or not DelvesDashboardFrame:IsShown() then
                PVEFrame_ToggleFrame("DelvesDashboardFrame", nil)
            end]]
        end
    end)


    Init=function()end
end





function WoWTools_MainMenuMixin:Init_LFD()--地下城查找器
    Init()
end