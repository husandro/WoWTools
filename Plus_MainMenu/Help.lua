--帮助
local e= select(2, ...)














local function Init()
    local frame= CreateFrame("Frame")

    frame:SetPoint('TOP')
    frame:SetSize(1,1)

    frame.Text= WoWTools_LabelMixin:Create(MainMenuMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
    frame.Text:SetPoint('TOP', MainMenuMicroButton, 0,  -3)

    frame.Text2= WoWTools_LabelMixin:Create(MainMenuMicroButton,  {size=WoWTools_MainMenuMixin.Save.size, color=true})
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
            self.Text2:SetText(ms>400 and '|cnRED_FONT_COLOR:'..ms..'|r' or ms>120 and ('|cnYELLOW_FONT_COLOR:'..ms..'|r') or ms)
        end
    end)



    --添加版本号 MainMenuBar.lua
    hooksecurefunc('MainMenuBarPerformanceBarFrame_OnEnter', function()
        if not MainMenuMicroButton.hover or KeybindFrames_InQuickKeybindMode() then
            return
        end
        e.tips:AddLine(' ')
        local version, build, date, tocversion, localizedVersion, buildType = GetBuildInfo()
        e.tips:AddLine(version..' '..build.. ' '..date.. ' '..tocversion..(buildType and ' '..buildType or ''), 1,0,1)
        if localizedVersion and localizedVersion~='' then
            e.tips:AddLine((e.onlyChinese and '本地' or REFORGE_CURRENT)..localizedVersion, 1,0,0)
        end
        e.tips:AddLine('realmID '..(GetRealmID() or '')..' '..(GetNormalizedRealmName() or ''), 1,0.82,0)
        e.tips:AddLine('regionID '..e.Player.region..' '..GetCurrentRegionName(), 1,0.82,0)

        local info=C_BattleNet.GetGameAccountInfoByGUID(e.Player.guid)
        if info and info.wowProjectID then
            local region=''
            if info.regionID and info.regionID~=e.Player.region then
                region=' regionID'..(e.onlyChinese and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:')..info.regionID..'|r'
            end
            e.tips:AddLine('isInCurrentRegion '..e.GetYesNo(info.isInCurrentRegion)..region, 1,1,1)
        end

        e.tips:AddLine(' ')

        local bat= UnitAffectingCombat('player')

        e.tips:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(e.onlyChinese and '设置选项' or GAMEMENU_OPTIONS)..'|r'
            ..e.Icon.mid
            ..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        e.tips:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(e.onlyChinese and '插件' or ADDONS)..'|r'
            ..e.Icon.right
        )
        e.tips:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(e.onlyChinese and '宏命令设置' or MACROS)..'|r'
            ..e.Icon.mid
            ..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        e.tips:Show()
    end)

    --Blizzard_GameMenu/Standard/GameMenuFrame.lua
    MainMenuMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
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
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        if d==1 then
            local func= GenerateFlatClosure(SettingsPanel.Open, SettingsPanel)
            if func then
                func()
            else
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
            e.call(ShowMacroFrame)
        end
    end)
end






function WoWTools_MainMenuMixin:Init_Help()--帮助
    Init()
end