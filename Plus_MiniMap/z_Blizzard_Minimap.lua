--小地图
function WoWTools_TextureMixin.Events:Blizzard_Minimap()
    self:SetAlphaColor(MinimapCompassTexture)
    self:SetButton(GameTimeFrame)

    if MinimapCluster and MinimapCluster.TrackingFrame then
       self:SetButton(MinimapCluster.TrackingFrame.Button, {alpha= 0.3, all=false})
       self:SetFrame(MinimapCluster.BorderTop)
    end


    local libDBIcon = LibStub("LibDBIcon-1.0", true)
    if libDBIcon then
        local function set_icon(name)
            local btn= libDBIcon:GetMinimapButton(name)
            if not btn then
                return
            end
            local icon= btn.icon
            for _, region in pairs ({btn:GetRegions()}) do
                if region:GetObjectType()=='Texture' and region~=icon then
                    local text= region:GetTexture()
                    if text==136430 then--OVERLAY
                        region:SetTexture(0)
                    elseif text==136467 then--BACKGROUND
                        region:SetAlpha(0.75)
                    end
                end
            end
        end

        do
            for _, name in pairs(libDBIcon:GetButtonList() or {}) do
                set_icon(name)
            end
        end

        hooksecurefunc(libDBIcon, 'Register', function(_, name)
            set_icon(name)
        end)
    end
end

