local id, e= ...
local addName= CREATURE
local Save={}
local panel= CreateFrame("Frame")

local function set_VIGNETTE_MINIMAP_UPDATED(vignetteGUID)
    local info= C_VignetteInfo.GetVignetteInfo(vignetteGUID)
   for k, v in pairs(info) do if v and type(v)=='table' then print('---------',k..'STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('---------',k..'END') end print(k,v) end
end

--####
--初始
--####
local function Init()

end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('VIGNETTE_MINIMAP_UPDATED')

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1==id then
        Save= WoWToolsSave and WoWToolsSave[addName] or Save

        --添加控制面板        
        local sel=e.CPanel(e.onlyChinse and '怪物' or addName, not Save.disabled, true)
        sel:SetScript('OnMouseDown', function()
            Save.disabled= not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
        end)

        if Save.disabled then
            panel:UnregisterAllEvents()
        else
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event == 'VIGNETTE_MINIMAP_UPDATED' and arg1 and arg2 then--vignetteGUID, onMinimap
        set_VIGNETTE_MINIMAP_UPDATED(arg1)

    end
end)