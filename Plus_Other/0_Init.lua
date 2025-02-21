local id, e= ...

WoWTools_OtherMixin={
    Save={},
    Category=nil,
    Layout=nil,
}

EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(owner, arg1)
    if arg1~=id then
        return
    end

    e.AddPanel_Header(nil, e.onlyChinese and '其它' or OTHER)

    WoWTools_OtherMixin.addName= '|A:QuestNormal:0:0|a'..(e.onlyChinese and '其它' or OTHER)

    local Category, Layout= e.AddPanel_Sub_Category({name= WoWTools_OtherMixin.addName})

    WoWTools_OtherMixin.Category= Category
    WoWTools_OtherMixin.Layout= Layout

    EventRegistry:UnregisterCallback('ADDON_LOADED', owner)
end)
