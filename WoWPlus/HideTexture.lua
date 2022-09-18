local id, e= ...
local addName=HIDE..TEXTURES_SUBHEADER
local Save={}
local function Set()
    if Save.disabled then
        return
    end
    ExtraActionButton1.style:Hide()--额外技能
    ZoneAbilityFrame.Style:Hide()--区域技能

    MainMenuBar.EndCaps.LeftEndCap:Hide()
    MainMenuBar.EndCaps.RightEndCap:Hide()
end

--加载保存数据
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                    Set()
                    print(addName, e.GetEnabeleDisable(not Save.disabled))
                else
                    Save.disabled=true
                    print(addName, e.GetEnabeleDisable(not Save.disabled), NEED..' /reload')
                end
            end)
            Set()

    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save
    end
end)