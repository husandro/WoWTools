local id, e= ...

WoWTools_OtherMixin={
    Save={},
}

local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWTools_OtherMixin.addName= '|A:QuestNormal:0:0|a'..(WoWTools_Mixin.onlyChinese and '其它' or OTHER)

            local Category, Layout= WoWTools_PanelMixin:AddSubCategory({name= WoWTools_OtherMixin.addName})

            WoWTools_OtherMixin.Category= Category
            WoWTools_OtherMixin.Layout= Layout

            self:UnregisterEvent(event)
        end
    end
end)