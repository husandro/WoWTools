local id, e = ...
local addName= HUD_EDIT_MODE_MINIMAP_LABEL
local Save={}


--####
--初始
--####
local function Init()
    
    local frame=MinimapCluster
    if Save.scale and Save.scale~=1 then
        frame:SetScale(Save.scale)
    end
    frame.ScaleIn=e.Cbtn(Minimap, nil, nil, nil, nil, true, {20,20})
    frame.ScaleIn:SetPoint('TOP',-2, 13)
    --frame.ScaleIn:SetPoint('TOP')
    frame.ScaleIn:SetScript('OnMouseDown', function(self, d)
        local scale = Save.scale or 1
        scale= scale+0.1
        scale= scale>2 and 2 or scale<0.4 and 0.4 or scale
        frame:SetScale(scale)
        Save.scale=scale
        print(id, addName, UI_SCALE, scale)
    end)

    frame.ScaleOut=e.Cbtn(Minimap, nil, nil, nil, nil, true, {20,20})
    frame.ScaleOut:SetPoint('BOTTOM', -1, -13)
    frame.ScaleOut:SetScript('OnMouseDown', function(self, d)
        local scale = Save.scale or 1
        scale= scale-0.1
        scale= scale>2 and 2 or scale<0.4 and 0.4 or scale
        frame:SetScale(scale)
        Save.scale=scale
        print(id, addName, UI_SCALE, scale)
    end)

end

--###########
--加载保存数据
--###########
local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

             --添加控制面板        
             local sel=e.CPanel(addName, not Save.disabled)
             sel:SetScript('OnClick', function()
                 if Save.disabled then
                     Save.disabled=nil
                 else
                     Save.disabled=true
                 end
                 print(id, addName, e.GetEnabeleDisable(not Save.disabled), 	REQUIRES_RELOAD)
             end)

            if not Save.disabled then
                Init()
            end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)