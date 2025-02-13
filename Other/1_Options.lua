
local e= select(2, ...)

local function Save()
    return WoWTools_OtherMixin.Save
end

local Category, Layout







local function Init_Options()
    
end











local function Init()
    Category, Layout= e.AddPanel_Sub_Category({name=WoWTools_OtherMixin.addName})

    e.AddPanel_Check({
        name= e.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_OtherMixin.addName,
        category= Category,
        GetValue= function() return not Save().disabled end,
        SetValue= function()
            Save().disabled= not Save().disabled and true or nil
            print(WoWTools_Mixin.addName, WoWTools_OtherMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end
    })
end








function WoWTools_OtherMixin:Init_Options()
    Init()
end



function WoWTools_OtherMixin:Blizzard_Settings()
    Init_Options()
end