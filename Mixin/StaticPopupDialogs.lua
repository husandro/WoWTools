local id, e= ...

--[[
https://warcraft.wiki.gg/wiki/Creating_simple_pop-up_dialog_boxes
e.onlyChinese and '重新加载UI' or RELOADUI
e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT
]]

local function Init()
StaticPopupDialogs['WoWTools_RestData']= {
    text=e.addName..'|n|n%s|n|n'
        ..(e.onlyChinese and "你想要将所有选项重置为默认状态吗？|n将会立即对所有设置生效。" or CONFIRM_RESET_SETTINGS)..'|n|n',
    whileDead=true, hideOnEscape=true, exclusive=true, showAlert=true,
    button1= e.onlyChinese and '重置' or RESET,
    button2= e.onlyChinese and '取消' or CANCEL,
    OnAccept=function(_, SetValue)
        SetValue()
    end
}
--StaticPopup_Show('WoWTools_RestData','aa', nil, function() print('c') end)


end

















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== id then
            Init()

        end
        self:UnregisterEvent('ADDON_LOADED')
    end
end)