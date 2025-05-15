--[[function WoWTools_TextureMixin.Events:Blizzard_SharedXML()
    hooksecurefunc(ScrollBarMixin, 'OnLoad', function(bar)
        self:SetScrollBar(bar)
    end)
end]]

function WoWTools_TextureMixin.Events:Blizzard_Menu()
    hooksecurefunc(MenuProxyMixin, 'OnLoad', function(menu)
        self:SetScrollBar(menu)
    end)
    hooksecurefunc(MenuStyle1Mixin, 'Generate', function(frame)
        local icon= frame:GetRegions()
        if icon:GetObjectType()=="Texture" then
           icon:SetVertexColor(0, 0, 0, 0.925)
        end
    end)
end
