local id, e = ...
local addName= 	TASKS_COLON..TRACK_QUEST_PROXIMITY_SORTING
local Save={}

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled)
            sel:SetScript('OnClick', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD)
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_TOPLEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine('|A:Navigation-Tracked-Icon:0:0|a', IN_GAME_NAVIGATION_RANGE)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if not Save.disabled then
                hooksecurefunc(SuperTrackedFrame,'UpdateDistanceText', function(self)
                    if not self.isClamped then
                        local distance = C_Navigation.GetDistance();
                        distance= e.MK(distance,2)
                        self.DistanceText:SetText(IN_GAME_NAVIGATION_RANGE:format(distance));
                    end
                end)
            end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)