


--菜单
function WoWTools_TextureMixin.Events:Blizzard_Menu()
--bar
    WoWTools_DataMixin:Hook(MenuProxyMixin, 'OnLoad', function(frame)
        self:SetScrollBar(frame)
    end)

--外框
    WoWTools_DataMixin:Hook(MenuStyle1Mixin, 'Generate', function(frame)
        local icon= frame:GetRegions()
        if icon and icon:IsObjectType('Texture')then
            self:SetAlphaColor(icon, true)
        end
    end)


--横线
    WoWTools_DataMixin:Hook(MenuVariants, 'CreateDivider', function(frame)--MenuVariants.lua
        self:SetFrame(frame, {alpha=1})
    end)

    WoWTools_DataMixin:Hook(MenuVariants, 'CreateCheckbox', function(_, frame)
        self:SetAlphaColor(frame.leftTexture1, true)
    end)

    WoWTools_DataMixin:Hook(MenuVariants, 'CreateRadio', function(_, frame)
        self:SetAlphaColor(frame.leftTexture1, true)
    end)

    --UISliderTemplat

--DropdownButton.lua
    WoWTools_DataMixin:Hook(DropdownButtonMixin, 'OnLoad', function(frame)
        self:SetMenu(frame)
    end)

--MenuTemplates.lua    
    WoWTools_DataMixin:Hook(WowStyle1FilterDropdownMixin, 'OnLoad', function(frame)
        self:SetMenu(frame)
    end)
    WoWTools_DataMixin:Hook(WowStyle1DropdownMixin, 'OnLoad', function(frame)
        self:SetMenu(frame)
    end)
    --样式：选项面板，菜单
    WoWTools_DataMixin:Hook(WowStyle2DropdownMixin, 'OnLoad', function(frame)
        self:SetMenu(frame)
        local p= frame:GetParent()
        if p.IncrementButton then
            self:SetButton(p.IncrementButton, 1)
            self:SetButton(p.DecrementButton, 1)
        end
    end)
    WoWTools_DataMixin:Hook(WowStyle1ArrowDropdownMixin, 'OnLoad', function(frame)
        self:SetMenu(frame)
    end)

    --WoWTools_DataMixin:Hook(DropdownTextMixin, 'OnLoad', function(frame)
end





function WoWTools_TextureMixin.Events:Blizzard_SharedXML()
--TabSystem/TabSystemTemplates.lua
    WoWTools_DataMixin:Hook(TabSystemButtonMixin, 'Init', function(btn)
        self:SetTabButton(btn)
    end)

--SharedUIPanelTemplates.lua
    WoWTools_DataMixin:Hook(PanelTabButtonMixin, 'OnLoad', function(btn)
        self:SetTabButton(btn)
    end)
    WoWTools_DataMixin:Hook(PanelTopTabButtonMixin, 'OnLoad', function(btn)
        self:SetTabButton(btn, 0.5)
    end)

--将一个图标拖曳至此处来显示
    WoWTools_DataMixin:Hook(IconSelectorPopupFrameTemplateMixin, 'OnLoad', function(frame)
        self:SetIconSelectFrame(frame)
    end)

--图标，修改，列表 Blizzard_SelectorUI.lua
    WoWTools_DataMixin:Hook(SelectorButtonMixin, 'Init', function(btn)
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
    WoWTools_DataMixin:Hook(ScrollBarMixin, 'Update', function(bar)
        if not bar.hideIfUnscrollable then--SetHideIfUnscrollable
            bar:SetAlpha(bar:HasScrollableExtent() and 1 or 0)
        end
    end)

--NavBar
    WoWTools_DataMixin:Hook('NavBar_Initialize', function(bar)
        WoWTools_TextureMixin:SetNavBar(bar:GetParent())
        --[[self:HideFrame(bar)
        self:HideFrame(bar.overlay)
        self:HideFrame(bar.Inset)]]
    end)

--选项面板，Slider
    WoWTools_DataMixin:Hook(MinimalSliderWithSteppersMixin, 'OnLoad', function(frame)
        self:SetSlider(frame)
    end)

    WoWTools_DataMixin:Hook(MinimalSliderWithSteppersMixin, 'SetEnabled', function(frame, enabled)
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

--InputBoxTemplates.lua
    WoWTools_DataMixin:Hook('SearchBoxTemplate_OnLoad', function(edit)
        self:SetEditBox(edit)
    end)
    WoWTools_DataMixin:Hook(ClearButtonMixin, 'OnEnter', function(btn)
        self:SetButton(btn, 1)
    end)


    WoWTools_DataMixin:Hook('ScrollingEdit_OnLoad', function(frame)
        self:SetEditBox(frame)
    end)
    WoWTools_DataMixin:Hook('ScrollFrame_OnLoad', function(frame)
        self:SetScrollBar(frame.ScrollBar)
    end)
    WoWTools_DataMixin:Hook('UIPanelScrollFrame_OnLoad', function(frame)
        self:SetScrollBar(frame.ScrollBar or _G[frame:GetName().."ScrollBar"])
    end)
    WoWTools_DataMixin:Hook('HybridScrollFrame_OnLoad', function(frame)
        self:SetScrollBar(frame)
    end)
    WoWTools_DataMixin:Hook('UIPanelButton_OnLoad', function(btn)
        self:SetUIButton(btn)
    end)

    --WoWTools_DataMixin:Hook(UIMenuButtonStretchMixin, 'OnShow', function(btn)
--导航条
    WoWTools_DataMixin:Hook('NavBar_AddButton', function(frame)
        local navButton= frame.navList[#frame.navList]
        if navButton then
            local icon = navButton:GetNormalTexture()
            if icon then
                self:SetAlphaColor(icon, true)
            end
            self:SetAlphaColor(navButton.arrowUp, true)
        end
    end)
    --WoWTools_DataMixin:Hook('NavBar_Initialize', function(frame)
    WoWTools_DataMixin:Hook(UIButtonMixin, 'InitButton', function(btn)
        self:SetUIButton(btn)
    end)
    WoWTools_DataMixin:Hook(ThreeSliceButtonMixin, 'InitButton', function(btn)
        self:SetUIButton(btn)
    end)
    WoWTools_DataMixin:Hook('MagicButton_OnLoad', function(btn)
        self:SetUIButton(btn)
    end)

    WoWTools_DataMixin:Hook('DynamicResizeButton_Resize', function(btn)
        self:SetButton(btn, 1)
    end)

    --WoWTools_DataMixin:Hook(UIButtonFitToTextBehaviorMixin, 'SetTextToFit', function(btn, text)

--钱

WoWTools_DataMixin:Hook(LargeMoneyInputFrameMixin, 'OnLoad', function(frame)
        self:SetEditBox(frame.CopperBox)
        self:SetEditBox(frame.SilverBox)
        self:SetEditBox(frame.GoldBox)
    end)
    WoWTools_DataMixin:Hook(LargeMoneyInputBoxMixin, 'OnLoad', function(edit)
        self:SetEditBox(edit)
    end)
end


--上一页，下一页
function WoWTools_TextureMixin.Events:Blizzard_PagedContent()
    WoWTools_DataMixin:Hook(PagingControlsMixin, 'OnLoad', function(frame)
        self:SetButton(frame.PrevPageButton, 1)
        self:SetButton(frame.NextPageButton, 1)
    end)
end

