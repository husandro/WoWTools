local id, e = ...
local addName= 'Emoji'
local Save={disabled= not e.Player.zh, }
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

--####
--初始
--####
local function Init()
    
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        local sel2=CreateFrame("CheckButton", nil, WoWToolsChatButtonFrame.sel, "InterfaceOptionsCheckButtonTemplate")
        sel2.Text:SetText('emoji')
        sel2:SetPoint('LEFT', WoWToolsChatButtonFrame.sel.Text, 'RIGHT')
        sel2:SetChecked(not Save.disabled)
        sel2:SetScript('OnClick', function()
            Save.disabled= not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.GetEnabeleDisable(not WoWToolsChatButtonFrame.disabled), REQUIRES_RELOAD)
        end)

        if WoWToolsChatButtonFrame.disabled or Save.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
        else
            Init()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)