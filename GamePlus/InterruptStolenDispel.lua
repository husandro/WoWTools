local id, e = ...
local addName= INTERRUPT..DISPELS
local Save={}
local panel=CreateFrame("Frame")

local de='->'--分隔符
if e.Player.Lo== "zhCN" or e.Player.Lo == "zhTW" or e.Player.Lo=='koKR' then
    de='→'
end
local playerGUID = UnitGUID("player")

local UMark={--'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..t..':0|t'
    [1]='{rt1}',
    [2]='{rt2}',
    [4]='{rt3}',
    [8]='{rt4}',
    [16]='{rt5}',
    [32]='{rt6}',
    [64]='{rt7}',
    [128]='{rt8}',
}


--######
--初始化
--######
--[[
local function Init()
    
end

]]

local function setEvent()--注册事件
    if Save.disabled then
        panel:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    else
        panel:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    end
end


panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                setEvent()--注册事件
                print(id, addName, e.GetEnabeleDisable(Save.disabled))
            end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                setEvent()--注册事件
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='COMBAT_LOG_EVENT_UNFILTERED' then
        local eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
   
        if eventType=="SPELL_INTERRUPT" or eventType=="SPELL_DISPEL" or eventType=="SPELL_STOLEN"   then
    
            local petGUID = UnitGUID("pet")
            local m=''
            local spellId, _,_, extraSpellId= select(12, ...)
    
            if sourceGUID ~=playerGUID and sourceGUID~=petGUID then--源名称
                m=sourceName
            end
    
            m=m..(UMark(sourceRaidFlags) or '')
            m=m..GetSpellLink(spellId)
    
            m=m..de
    
            m=m..GetSpellLink(extraSpellId)--法术
            m=m..(UMark(destRaidFlags) or '')
    
            if e.config.DN then--目标名称
                m=m..destName
            end
    
            e.Chat(m)
        end
    end
end)
