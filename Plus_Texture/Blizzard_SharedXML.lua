--[[function WoWTools_TextureMixin.Events:Blizzard_SharedXML()
    hooksecurefunc(ScrollBarMixin, 'OnLoad', function(bar)
        self:SetScrollBar(bar)
    end)
end]]

function WoWTools_TextureMixin.Events:Blizzard_Menu()
    hooksecurefunc(MenuProxyMixin, 'OnLoad', function(menu)
        self:SetScrollBar(menu)
        self:SetFrame(menu, {notAlpha=true})
    end)
end