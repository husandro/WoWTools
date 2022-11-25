local id, e = ...
local addName=	CALENDAR_FILTER_HOLIDAYS
local Save={}
local panel= e.Cbtn(UIParent, nil, true, nil, nil, nil, {25,25})



local function set_Text()

end

--####
--初始
--####
local function Init()
    if not IsAddOnLoaded("Blizzard_Calendar") then--加载
        LoadAddOn("Blizzard_Calendar")
        Calendar_Toggle()
        CalendarFrame:Hide()
    end
end

panel:RegisterEvent('ADDON_LOADED')

panel:RegisterEvent('CALENDAR_UPDATE_EVENT_LIST')
panel:RegisterEvent('QUEST_FINISHED')
panel:RegisterEvent('QUEST_COMPLETE')
panel:RegisterEvent('QUEST_ACCEPTED')
panel:RegisterEvent('CALENDAR_UPDATE_EVENT')
panel:RegisterEvent('CALENDAR_CLOSE_EVENT')
panel:RegisterEvent('CALENDAR_NEW_EVENT')
panel:RegisterEvent('BAG_UPDATE_DELAYED')
panel:RegisterEvent('CALENDAR_OPEN_EVENT')
panel:RegisterEvent('LFG_COMPLETION_REWARD')
panel:RegisterEvent('LFG_UPDATE_RANDOM_INFO')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(Save.disabled), REQUIRES_RELOAD)
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Calendar' then
            set_Text()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    else
        set_Text()
    end
end)
