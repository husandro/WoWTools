WoWTools_MainMenuMixin={
    Labels={}
}

function WoWTools_MainMenuMixin:SetNotificationOverlay(button)
    if button.NotificationOverlay then
        button.NotificationOverlay:SetAlpha(0.4)
    end
end
    --[[button.NotificationOverlay:ClearAllPoints()
    button.NotificationOverlay:SetSize(12,12)
    button.NotificationOverlay:SetPoint('CENTER')--, button, 0,3)
    button.NotificationOverlay:SetAlpha(0.4)]]
