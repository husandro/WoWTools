--地下城查找器
local e= select(2, ...)







local function Init()
    local frame= CreateFrame('Frame')

    frame.Text= WoWTools_LabelMixin:Create(LFDMicroButton,  {size=WoWTools_PlusMainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', LFDMicroButton, 0,  -3)

    table.insert(WoWTools_PlusMainMenuMixin.Labels, frame.Text)

    function frame:settings()
        local lv= C_MythicPlus.GetOwnedKeystoneLevel() or 0
        self.Text:SetText(lv>0 and lv or '')
    end
    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
    frame:RegisterEvent('BAG_UPDATE_DELAYED')
    frame:SetScript('OnEvent', frame.settings)

    LFDMicroButton.setTextFrame= frame
    LFDMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        self.setTextFrame:settings()
        e.tips:AddLine(' ')

        local find= WoWTools_WeekMixin:Activities({showTooltip=true})--周奖励，提示
        local link= e.WoWDate[e.Player.guid].Keystone.link
        if link then
            e.tips:AddLine('|T4352494:0|t'..link)
        end

        if find or link then
            e.tips:AddLine(' ')
        end

        local bat= UnitAffectingCombat('player')

        e.tips:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(e.onlyChinese and '地下城和团队副本' or GROUP_FINDER)..'|r'
            ..e.Icon.mid
            ..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        e.tips:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(e.onlyChinese and 'PvP' or PVP)..'|r'
            ..e.Icon.right
        )
        e.tips:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(e.onlyChinese and '地下堡' or DELVES_LABEL)..'|r'
            ..e.Icon.mid
            ..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        e.tips:Show()
    end)


    LFDMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            PVEFrame_ToggleFrame("PVPUIFrame", nil)
        end
    end)

    LFDMicroButton:EnableMouseWheel(true)
    LFDMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if d==1 then
            if not GroupFinderFrame:IsShown() then
                PVEFrame_ToggleFrame("GroupFinderFrame", nil)--, RaidFinderFrame)
            end
        elseif d==-1 then
            if not DelvesDashboardFrame or not DelvesDashboardFrame:IsShown() then
                PVEFrame_ToggleFrame("DelvesDashboardFrame", nil)
            end
        end
    end)
end





function WoWTools_PlusMainMenuMixin:Init_LFD()--地下城查找器
    Init()
end