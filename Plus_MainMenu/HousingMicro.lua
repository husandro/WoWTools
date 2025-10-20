
local function Init()
    if HousingMicroButton then
        HousingMicroButton:HookScript('OnClick', function(_, d)
            if d=='RightButton' and not KeybindFrames_InQuickKeybindMode() and not Kiosk.IsEnabled() then
                

            end
        end)

    end
    Init=function() end
end
function WoWTools_MainMenuMixin:HousingMicro()--住宅信息板
    Init()
end