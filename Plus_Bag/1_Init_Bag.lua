
local P_Save={}

local function Save()
    return WoWToolsSave['Plus_Container'] or {}
end






local function Init()
    if Save().disabled then
        return
    end

    WoWTools_BagMixin:Init_Container_Menu()--背包，菜单，增强

    Init=function()end
end






local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_ENTERING_WORLD")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_Container']= WoWToolsSave['Plus_Container'] or P_Save

            WoWTools_BagMixin.addName= '|A:bag-main:0:0|a'..(WoWTools_DataMixin.onlyChinese and '容器' or ITEM_CONTAINER)

--添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_BagMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init()
                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..WoWTools_BagMixin.addName,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                            WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                        )
                    end
                end,
                layout= WoWTools_OtherMixin.Layout,
                category= WoWTools_OtherMixin.Category,
            })
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)
    end
end)