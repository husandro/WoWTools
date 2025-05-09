--[[function WoWTools_TextureMixin.Events:Blizzard_SharedXML()
    hooksecurefunc(ScrollBarMixin, 'OnLoad', function(bar)
        self:SetScrollBar(bar)
    end)
end]]

function WoWTools_TextureMixin.Events:Blizzard_Menu()
    hooksecurefunc(MenuProxyMixin, 'OnLoad', function(menu)
        self:SetScrollBar(menu)
        --self:SetFrame(menu, {notAlpha=true})
        --print(menu.Background)
    end)
    hooksecurefunc(MenuStyle1Mixin, 'Generate', function(frame)
        --self:SetFrame(menu, {notAlpha=true})
        for index, icon in pairs({frame:GetRegions()}) do
            if icon:GetObjectType()=="Texture" and index==1 then
                icon:SetVertexColor(0,0,0, 0.925)
            end     
        end
    end)
end
