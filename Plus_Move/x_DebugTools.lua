--FSTACK

function WoWTools_MoveMixin.Events:Blizzard_DebugTools()
    TableAttributeDisplay.LinesScrollFrame:ClearAllPoints()
    TableAttributeDisplay.LinesScrollFrame:SetPoint('TOPLEFT', 6, -62)
    TableAttributeDisplay.LinesScrollFrame:SetPoint('BOTTOMRIGHT', -36, 22)
    TableAttributeDisplay.FilterBox:SetPoint('RIGHT', -26,0)
    TableAttributeDisplay.TitleButton.Text:SetPoint('RIGHT')
    hooksecurefunc(TableAttributeLineReferenceMixin, 'Initialize', function(self, _, _, attributeData)
        local frame= self:GetParent():GetParent():GetParent()
        local btn= frame.ResizeButton
        if btn and btn.setSize then
            local w= frame:GetWidth()-200
            self.ValueButton:SetWidth(w)
            self.ValueButton.Text:SetWidth(w)
        end
    end)
    hooksecurefunc(TableAttributeDisplay, 'UpdateLines', function(self)
        if self.dataProviders then
            for _, line in ipairs(self.lines) do
                if line.ValueButton then
                    local w= self:GetWidth()-200
                    line.ValueButton:SetWidth(w)
                    line.ValueButton.Text:SetWidth(w)
                end
            end
        end
    end)

    WoWTools_MoveMixin:Setup(TableAttributeDisplay, {
        minW=476,
        minH=150,
        setSize=true,
        sizeUpdateFunc=function(btn)
            btn.targetFrame:UpdateLines()--RefreshAllData()
        end,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(500, 400)
        end,
    })
end