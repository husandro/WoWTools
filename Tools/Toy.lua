local id, e = ...
local addName= SLASH_RANDOM3:gsub('/','').. TOY
local Save={}


--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('PLAYER_REGEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
            end)
            if not Save.disabled then
                Init()--初始
            else
                e.toolsFrame.disabled=true
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
        hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    elseif event=='TOYS_UPDATED' or event=='NEW_TOY_ADDED' then
        getToy()--生成, 有效表格
        setAtt()--设置属性

    elseif event=='BAG_UPDATE_COOLDOWN' then
        setCooldown()--主图标冷却
        setBagHearthstone()--设置Shift, Ctrl, Alt 提示

    elseif event=='BAG_UPDATE_DELAYED' then
        if IsResting()  then
            setBagHearthstone()--设置Shift, Ctrl, Alt 提示
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
        e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
    end
end)