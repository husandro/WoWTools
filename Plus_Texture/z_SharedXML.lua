function WoWTools_TextureMixin.Events:Blizzard_SharedXML()
--TabSystem/TabSystemTemplates.lua
    hooksecurefunc(TabSystemButtonMixin, 'Init', function(btn)
        self:SetTabButton(btn)
    end)

--SharedUIPanelTemplates.lua
    hooksecurefunc(PanelTabButtonMixin, 'OnLoad', function(btn)
        self:SetTabButton(btn)
    end)
    hooksecurefunc(PanelTopTabButtonMixin, 'OnLoad', function(btn)
        self:SetTabButton(btn, 0.5)
    end)

--将一个图标拖曳至此处来显示
    hooksecurefunc(IconSelectorPopupFrameTemplateMixin, 'OnLoad', function(frame)
        self:SetIconSelectFrame(frame)
    end)

--图标，修改，列表 Blizzard_SelectorUI.lua
    hooksecurefunc(SelectorButtonMixin, 'Init', function(btn)
        if btn.IconMask then
            return
        end
        do
            self:HideFrame(btn, {index=1})
        end
        WoWTools_ButtonMixin:AddMask(btn, nil, btn.Icon)

        btn.SelectedTexture:ClearAllPoints()
        btn.SelectedTexture:SetPoint('TOPLEFT',-3,3)
        btn.SelectedTexture:SetPoint('BOTTOMRIGHT',3,-3)
        btn.SelectedTexture:SetVertexColor(0,1,0)
    end)

--ScrollBarMixin
    hooksecurefunc(ScrollBarMixin, 'Update', function(bar)
        if not bar.hideIfUnscrollable then--SetHideIfUnscrollable
            bar:SetAlpha(bar:HasScrollableExtent() and 1 or 0)
        end
    end)

--NavBar
    hooksecurefunc('NavBar_Initialize', function(bar)
        self:HideFrame(bar)
        self:HideFrame(bar.overlay)
        self:HideFrame(bar.Inset)
    end)

--选项面板，Slider
    hooksecurefunc(MinimalSliderWithSteppersMixin, 'OnLoad', function(frame)
        self:SetSlider(frame)
    end)
    hooksecurefunc(MinimalSliderWithSteppersMixin, 'SetEnabled', function(frame, enabled)
        local alpha= enabled and 1 or 0.3
        if frame.Back then
            frame.Back:SetAlpha(alpha)
        end
        if frame.Forward then
            frame.Forward:SetAlpha(alpha)
        end
        if frame.Slider then
            frame.Slider:SetAlpha(alpha)
        end
    end)


    --[[hooksecurefunc(ScrollBarMixin, 'OnLoad', function(bar)
        self:SetScrollBar(bar)
    end)]]
end

