--地下城和团队副本, PVP
local function Save()
    return WoWTools_MoveMixin.Save
end




function WoWTools_MoveMixin.Events:Blizzard_PVPUI()
    --if Save().disabledZoom then
    PVPUIFrame:SetPoint('BOTTOMRIGHT')
    LFGListPVPStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)
    hooksecurefunc('PVPQueueFrame_ShowFrame', function()
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or not PVEFrame:CanChangeAttribute() then
            return
        end
        if PVPQueueFrame.selection==LFGListPVPStub then
            btn.setSize= true
            local size= Save().size['PVEFrame_PVP']
            if size then
                PVEFrame:SetSize(size[1], size[2])
                return
            end
        else
            btn.setSize= false
        end
        PVEFrame:SetHeight(428)
    end)
end




