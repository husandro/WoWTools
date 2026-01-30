local function Save()
    return WoWToolsSave['Plus_MainMenu']
end

local Category, Layout






























local function Init()
    Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name= WoWTools_MainMenuMixin.addName,
        disabled= Save().disabled and not Save().frameratePlus,
    })

    if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
        Init_Options()
    else
        EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
            if arg1=='Blizzard_Settings' then
                Init_Options()
                EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
            end
        end)
    end

    Init=function()end
end







function WoWTools_MainMenuMixin:Init_Options()
    Init()
end

