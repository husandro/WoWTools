local e= select(2, ...)




function WoWTools_MinimapMixin:ExpansionLanding_Menu(_, root)
    root:CreateCheckbox(
        (ExpansionLandingPageMinimapButton and '' or '|cff9e9e9e')
        ..'|A:dragonflight-landingbutton-up:0:0|a'..(e.onlyChinese and '隐藏要塞图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HIDE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GARRISON_LOCATION_TOOLTIP, EMBLEM_SYMBOL))),
    function()
        return self.Save.hideExpansionLandingPageMinimapButton
    end, function()
        self.Save.hideExpansionLandingPageMinimapButton= not self.Save.hideExpansionLandingPageMinimapButton and true or nil
        self.Save.moveExpansionLandingPageMinimapButton=nil
        print(e.Icon.icon2..WoWTools_MinimapMixin.addName, '|cnGREEN_FONT_COLOR:' , e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

    root:CreateCheckbox(
        '|A:dragonflight-landingbutton-up:0:0|a'..(e.onlyChinese and '移动要塞图标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NPE_MOVE, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GARRISON_LOCATION_TOOLTIP, EMBLEM_SYMBOL))),
    function()
        return self.Save.moveExpansionLandingPageMinimapButton
    end, function()
        self.Save.moveExpansionLandingPageMinimapButton= not self.Save.moveExpansionLandingPageMinimapButton and true or nil
        self.Save.hideExpansionLandingPageMinimapButton=nil
        print(e.Icon.icon2..WoWTools_MinimapMixin.addName, '|cnGREEN_FONT_COLOR:' , e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)
end




function WoWTools_MinimapMixin:Init_ExpansionLanding()
    --要塞，图标
    if not ExpansionLandingPageMinimapButton then
        return
    end
    if self.Save.hideExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:SetShown(false)
        ExpansionLandingPageMinimapButton:HookScript('OnShow', function(frame)
            frame:SetShown(false)
        end)
    elseif self.Save.moveExpansionLandingPageMinimapButton then
        ExpansionLandingPageMinimapButton:SetFrameStrata('TOOLTIP')
        C_Timer.After(2, function()
            WoWTools_MoveMixin:Setup(ExpansionLandingPageMinimapButton, {
                --needMove=true,
                hideButton=true, click='RightButton',
            setResizeButtonPoint={
                nil, nil, nil, -2, 2
            }})
            C_Timer.After(8, function()--盟约图标停止闪烁
                ExpansionLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
            end)
        end)
    end
end