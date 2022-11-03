local pet=2780

local id, e = ...
local Save={}
local addName='DaisyTools'
local panel=e.Cbtn2(nil, e.toolsFrame, true, false)

--####
--初始
--####
local function Init()
    e.ToolsSetButtonPoint(panel)--设置位置
    panel:RegisterForClicks('LeftButtonDown')--, 'RightButtonDown')
    panel:SetAttribute('')
end

--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGOUT')

panel:RegisterEvent("PLAYER_REGEN_ENABLED")
panel:RegisterEvent('UNIT_AURA')
panel:RegisterEvent('PLAYER_TARGET_CHANGED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(1.71, function()
                local num = C_PetJournal.GetNumCollectedInfo(pet)--没宠物,不加载
                if not num or num==0 then
                    panel:UnregisterAllEvents()
                    return
                end
                if UnitAffectingCombat('player')  then
                    panel.combat= true
                else
                    Init()--初始
                end
            end)
        else
            panel:UnregisterAllEvents()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
        if panel.combat then
            Init()
            panel.combat=nil
        end
    elseif event=='PLAYER_REGEN_DISABLED' then
        panel:UnregisterEvent('PLAYER_TARGET_CHANGED')

    elseif event=='UNIT_AURA' then

    elseif event=='PLAYER_TARGET_CHANGED' then

    end
end)