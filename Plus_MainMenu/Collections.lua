--战团藏品













local function Init()
    CollectionsMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        local bat= UnitAffectingCombat('player')
        GameTooltip:AddLine(' ')

        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '坐骑' or MOUNTS)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_Mixin.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '宠物手册' or PET_JOURNAL)..'|r'
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:AddLine(
            (bat and '|cnRED_FONT_COLOR:' or '|cffffffff')..(WoWTools_Mixin.onlyChinese and '玩具箱' or TOY_BOX)..'|r'
            ..WoWTools_DataMixin.Icon.mid
            ..(WoWTools_Mixin.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        GameTooltip:Show()
    end)

    CollectionsMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            WoWTools_Mixin:Call(ToggleCollectionsJournal, 2)
        end
    end)

    CollectionsMicroButton:EnableMouseWheel(true)
    CollectionsMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if d==1 then
            if not MountJournal or not MountJournal:IsShown() then
                WoWTools_Mixin:Call(ToggleCollectionsJournal, 1)
            end
        elseif d==-1 then
            if not ToyBox or not ToyBox:IsShown() then
                WoWTools_Mixin:Call(ToggleCollectionsJournal, 3)
            end
        end
    end)
end






function WoWTools_MainMenuMixin:Init_Collections()--收藏
    Init()
end