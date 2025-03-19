local id, e = ...
WoWTools_BagMixin.Save={}

local function Save()
    return WoWTools_BagMixin.Save
end


local function Init()
    WoWTools_BagMixin:Init_Container_Menu()--背包，菜单，增强
   -- WoWTools_BagMixin:Init_PortraitButton()
end



local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then

            WoWTools_BagMixin.Save= WoWToolsSave['Plus_Container'] or Save()

            local addName= '|A:bag-main:0:0|a'..(e.onlyChinese and '容器' or ITEM_CONTAINER)
            WoWTools_BagMixin.addName= addName

            --添加控制面板
            e.AddPanel_Check({
                name= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.Icon.icon2.. addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })

            if Save().disabled then
                self:UnregisterEvent(event)
            else
                Init()
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Container']=Save()
        end
    end
end)