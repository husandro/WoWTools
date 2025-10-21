--帮助















local function Init()
    local frame= CreateFrame('Frame', MainMenuMicroButton)

    frame:SetPoint('TOP')
    frame:SetSize(1,1)

    frame.Text= WoWTools_LabelMixin:Create(MainMenuMicroButton,  {size=WoWToolsSave['Plus_MainMenu'].size, color=true})
    frame.Text:SetPoint('TOP', MainMenuMicroButton, 0,  -3)

    frame.Text2= WoWTools_LabelMixin:Create(MainMenuMicroButton,  {size=WoWToolsSave['Plus_MainMenu'].size, color=true})
    frame.Text2:SetPoint('BOTTOM', MainMenuMicroButton, 0, 3)

    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text)
    table.insert(WoWTools_MainMenuMixin.Labels, frame.Text2)

    frame.elapsed= 1
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > 0.4 then
            self.elapsed = 0
            local latencyHome, latencyWorld= select(3, GetNetStats())--ms
            local ms= math.max(latencyHome, latencyWorld) or 0
            local fps= math.modf(GetFramerate() or 0)
            self.Text:SetText(fps<10 and '|cnGREEN_FONT_COLOR:'..fps..'|r' or fps<20 and '|cnYELLOW_FONT_COLOR:'..fps..'|r' or fps)
            self.Text2:SetText(ms>400 and '|cnWARNING_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)
        end
    end)



    --添加版本号 MainMenuBar.lua
    WoWTools_DataMixin:Hook('MainMenuBarPerformanceBarFrame_OnEnter', function()
        if not MainMenuMicroButton.hover or KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end
        GameTooltip:AddLine(' ')
        local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
        GameTooltip:AddLine(version..' '..build.. ' '..date.. ' '..tocversion..(buildType and ' '..buildType or ''), 1,0,1)
        if localizedVersion and localizedVersion~='' then
            GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '本地' or REFORGE_CURRENT)..localizedVersion, 1,0,0)
        end
        GameTooltip:AddLine('realmID '..(GetRealmID() or '')..' '..(GetNormalizedRealmName() or ''), 1,0.82,0)
        GameTooltip:AddLine('regionID '..WoWTools_DataMixin.Player.Region..' '..GetCurrentRegionName(), 1,0.82,0)

        local info=C_BattleNet.GetGameAccountInfoByGUID(WoWTools_DataMixin.Player.GUID)
        if info and info.wowProjectID then
            local region=''
            if info.regionID and info.regionID~=WoWTools_DataMixin.Player.Region then
                region=' regionID'..(WoWTools_DataMixin.onlyChinese and '|cnGREEN_FONT_COLOR:' or '|cnWARNING_FONT_COLOR:')..info.regionID..'|r'
            end
            GameTooltip:AddLine('isInCurrentRegion '..WoWTools_TextMixin:GetYesNo(info.isInCurrentRegion)..region, 1,1,1)
        end

        GameTooltip:AddLine(' ')

        local bat= InCombatLockdown()

        GameTooltip:AddLine(
            (GenerateFlatClosure(SettingsPanel.Open, SettingsPanel) and '|cffffffff' or'|cff828282')
            ..(WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        GameTooltip:AddLine(
            (GenerateFlatClosure(ShowUIPanel, AddonList, nil, G_GameMenuFrameContextKey) and C_AddOns.GetNumAddOns()> 0 and '|cffffffff' or '|cff828282')
            ..(WoWTools_DataMixin.onlyChinese and '插件' or ADDONS)
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddLine(
            (bat and '|cff828282' or '|cffffffff')
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_DataMixin.onlyChinese and '宏命令设置' or MACROS)
            ..(WoWTools_DataMixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        GameTooltip:Show()
    end)

--Blizzard_GameMenu/Standard/GameMenuFrame.lua
    MainMenuMicroButton:HookScript('OnClick', function(_, d)
         if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() and not Kiosk.IsEnabled() then
            if C_AddOns.GetNumAddOns() > 0 then
                local func= GenerateFlatClosure(ShowUIPanel, AddonList, nil, G_GameMenuFrameContextKey)
                if func then
                    func()
                end
            end
        end
    end)


    MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
    MainMenuMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() or Kiosk.IsEnabled() then
            return
        end

        if d==1 then
            local func= GenerateFlatClosure(SettingsPanel.Open, SettingsPanel)
            if func then
                func()
            elseif not WoWTools_FrameMixin:IsLocked(SettingsPanel) then
                Settings.OpenToCategory()
            end
        else
            do
                if SettingsPanel:IsShown() then
                    HideUIPanel(SettingsPanel)
                end
                if AddonList:IsShown() then
                    HideUIPanel(AddonList)
                end
                if GameMenuFrame:IsShown() then
                    HideUIPanel(GameMenuFrame)
                end
            end
            WoWTools_DataMixin:Call(ShowMacroFrame)
        end
    end)

--self.NotificationOverlay:SetShown(C_SocialRestrictions.CanReceiveChat() and (self:HasUnseenInvitations() or CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages()));
    if MainMenuMicroButton.NotificationOverlay then
        MainMenuMicroButton.NotificationOverlay:ClearAllPoints()
        MainMenuMicroButton.NotificationOverlay:SetSize(1,1)
        MainMenuMicroButton.NotificationOverlay:SetPoint('CENTER', MainMenuMicroButton, 0,4)
        MainMenuMicroButton.NotificationOverlay:SetAlpha(0.7)
    end

    Init=function()end
end






function WoWTools_MainMenuMixin:Init_Help()--帮助
    Init()
end