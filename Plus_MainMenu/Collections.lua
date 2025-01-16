--战团藏品
local e= select(2, ...)












local function Init()
    CollectionsMicroButton:HookScript('OnEnter', function(self)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end

        e.tips:AddLine(' ')

        e.tips:AddLine(
            '|cffffffff'..(e.onlyChinese and '坐骑' or MOUNTS)..'|r'
            ..e.Icon.mid
            ..(e.onlyChinese and '上' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_UP)
        )
        e.tips:AddLine(
            '|cffffffff'..(e.onlyChinese and '宠物手册' or PET_JOURNAL)..'|r'
            ..e.Icon.right
        )
        e.tips:AddLine(
            '|cffffffff'..(e.onlyChinese and '玩具箱' or TOY_BOX)..'|r'
            ..e.Icon.mid
            ..(e.onlyChinese and '下' or HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_DOWN)
        )

        e.tips:Show()
    end)

    CollectionsMicroButton:HookScript('OnClick', function(_, d)
        if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() then
            ToggleCollectionsJournal(2)
        end
    end)

    CollectionsMicroButton:EnableMouseWheel(true)
    CollectionsMicroButton:HookScript('OnMouseWheel', function(_, d)
        if KeybindFrames_InQuickKeybindMode() then
            return
        end
        if d==1 then
            if not MountJournal or not MountJournal:IsShown() then
                ToggleCollectionsJournal(1)
            end
        elseif d==-1 then
            if not ToyBox or not ToyBox:IsShown() then
                ToggleCollectionsJournal(3)
            end
        end
    end)
end






function WoWTools_PlusMainMenuMixin:Init_Collections()--收藏
    Init()
end