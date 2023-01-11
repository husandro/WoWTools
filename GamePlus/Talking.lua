local id, e = ...
local Save={}
local addName= HIDE..'NPC'..VOICE_TALKING
local panel=CreateFrame('Frame')

local function setRegister()--设置事件
    if not Save.disabled then
        --panel:RegisterEvent('TALKINGHEAD_CLOSE')
        panel:RegisterEvent('TALKINGHEAD_REQUESTED')
    else
        --panel:UnregisterEvent('TALKINGHEAD_CLOSE')
        panel:UnregisterEvent('TALKINGHEAD_REQUESTED')
    end
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel( e.onlyChinse and '隐藏NPC发言' or addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                Save.disabled= not Save.disabled and true or nil
                setRegister()--设置事件
                print(id, addName, e.GetEnabeleDisable(not Save.disabled))
            end)
            setRegister()--设置事件

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='TALKINGHEAD_REQUESTED' then
        local _, _, vo, _, _, _, name, text, isNewTalkingHead = C_TalkingHead.GetCurrentLineInfo();
        if vo and vo>0 and self.soundKitID~=vo then
            PlaySound(vo, "Dialog");
            print(id, addName, 'soundKitID', vo)
            print('|cff00ff00'..name..'|r','|cffff00ff'..text..'|r')
            self.soundKitID=vo
        end
        TalkingHeadFrame:CloseImmediately()
    end
end)
