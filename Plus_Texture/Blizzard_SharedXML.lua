function WoWTools_TextureMixin.Events:Blizzard_SharedXML()
    hooksecurefunc(ScrollBarMixin, 'OnLoad', function(bar)
        self:SetScrollBar(bar)
    end)
end
