local id, e= ...
local addName= TARGET..COMBAT_ALLY_START_MISSION
local Save= {}

local panel= CreateFrame("Frame")


local function set_Register_Event()
    if Save.disabled then
        panel:UnregisterEvent('PLAYER_TARGET_CHANGED')--提示
        panel:UnregisterEvent('PLAYER_ENTERING_WORLD')

        panel:UnregisterEvent('PLAYER_REGEN_DISABLED')--颜色
        panel:UnregisterEvent('PLAYER_REGEN_ENABLED')
        if panel.Texture then
            panel.Texture:SetShwon(false)
        end
    else
        if not panel.Texture then
            panel.Texture= panel:CreateTexture()
            panel.Texture:SetAtlas('common-icon-rotateright')
            panel.Texture:SetSize(40, 20)
        end

        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
        panel:RegisterEvent('PLAYER_ENTERING_WORLD')

        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')
    end
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(e.onlyChinse and '目标指示' or addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                Save.disabled= not Save.disabled and true or nil
                set_Register_Event()
                print(id, addName, e.GetEnabeleDisable(not Save.disabled))
            end)

            set_Register_Event()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_TARGET_CHANGED' or event=='PLAYER_ENTERING_WORLD' then
        C_Timer.After(0.15, function()
            local plate = C_NamePlate.GetNamePlateForUnit("target")
            if plate then
                local frame
                if plate.UnitFrame then
                    if plate.UnitFrame.ClassificationFrame and plate.UnitFrame.ClassificationFrame.classificationIndicator:IsShown() then
                        frame= plate.UnitFrame.ClassificationFrame.classificationIndicator
                    elseif plate.UnitFrame.healthBar then
                        frame= plate.UnitFrame.healthBar
                    end
                end

                panel.Texture:ClearAllPoints()
                panel.Texture:SetPoint('RIGHT', frame or plate, 'LEFT')
            end
            panel.Texture:SetShown(plate and true or false)
        end)

    elseif event=='PLAYER_REGEN_DISABLED' then--颜色
        panel.Texture:SetVertexColor(1,0,0)

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel.Texture:SetVertexColor(1,1,1)
    end
end)