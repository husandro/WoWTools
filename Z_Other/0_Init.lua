

WoWTools_OtherMixin={
    Save={},
    OpenOption=function()end
}

local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if arg1~= 'WoWTools' then
        return
    end

    WoWTools_OtherMixin.addName= '|A:QuestNormal:0:0|a'..(WoWTools_DataMixin.onlyChinese and '其它' or OTHER)

    WoWTools_OtherMixin.Category, WoWTools_OtherMixin.Layout= WoWTools_PanelMixin:AddSubCategory({name= WoWTools_OtherMixin.addName})

    function WoWTools_OtherMixin:OpenOption(root, name, name2)
        return WoWTools_MenuMixin:OpenOptions(root, {
            category=WoWTools_OtherMixin.Category,
            name=name or WoWTools_OtherMixin.addName,
            name2=name2
        })
    end

    self:UnregisterEvent(event)
end)