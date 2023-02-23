local id, e= ...
local Save= {}
local addName= COLOR_PICKER--"颜色选择器";
local panel= CreateFrame("Frame")--ColorPickerFrame.xml



--####
--初始
--####
local function Init()
    if not ColorPickerFrame then
        return
    end
    ColorPickerFrame.rgbText= e.Cstr(ColorPickerFrame)
    ColorPickerFrame.rgbText:SetPoint('TOPLEFT')
    hooksecurefunc('ColorPickerFrame.opacityFunc', function(self, r, g, b)
        print(r,g,b)
    end)
end

panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --[[添加控制面板        
            local sel=e.CPanel( e.onlyChinse and '隐藏NPC发言' or addName, not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                setRegister()--设置事件
                print(id, addName, e.GetEnabeleDisable(not Save.disabled))
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinse and '声音' or SOUND, e.GetEnabeleDisable(e.setPlayerSound))
                e.tips:AddDoubleLine('ChatButton, '..(e.onlyChinse and '超链接图标' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK..EMBLEM_SYMBOL), e.onlyChinse and '事件声音' or EVENTS_LABEL..SOUND)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)]]

            if not Save.disabled then
                C_Timer.After(2, Init)
                panel:UnregisterEvent('ADDON_LOADED')
            else
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent('PLAYER_LOGOUT')
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)

