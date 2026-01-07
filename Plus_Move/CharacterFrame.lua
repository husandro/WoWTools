function WoWTools_MoveMixin.Frames:GearManagerPopupFrame()
    self:Setup(GearManagerPopupFrame, {frame=CharacterFrame})
end










function WoWTools_MoveMixin.Frames:CharacterFrame()--:Init_CharacterFrame()--角色
    PaperDollFrame.TitleManagerPane:ClearAllPoints()
    PaperDollFrame.TitleManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
    PaperDollFrame.TitleManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)

    PaperDollFrame.TitleManagerPane.ScrollBox:ClearAllPoints()
    PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('TOPLEFT',CharacterFrameInsetRight,4,-4)
    PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22,4)

    PaperDollFrame.EquipmentManagerPane:ClearAllPoints()
    PaperDollFrame.EquipmentManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
    PaperDollFrame.EquipmentManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)
    PaperDollFrame.EquipmentManagerPane.ScrollBox:ClearAllPoints()
    PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -28)
    PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22, 4)

    CharacterModelScene:ClearAllPoints()
    CharacterModelScene:SetPoint('TOPLEFT', 52, -66)
    CharacterModelScene:SetPoint('BOTTOMRIGHT', CharacterFrameInset, -50, 34)

    CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    CharacterModelFrameBackgroundOverlay:SetAllPoints(CharacterModelScene)

    CharacterModelFrameBackgroundTopLeft:ClearAllPoints()
    CharacterModelFrameBackgroundTopLeft:SetPoint('TOPLEFT')
    CharacterModelFrameBackgroundTopLeft:SetPoint('BOTTOMRIGHT',-19, 128)

    CharacterModelFrameBackgroundTopRight:ClearAllPoints()
    CharacterModelFrameBackgroundTopRight:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'TOPRIGHT')
    CharacterModelFrameBackgroundTopRight:SetPoint('BOTTOMRIGHT', 0, 128)

    CharacterModelFrameBackgroundBotLeft:ClearAllPoints()
    CharacterModelFrameBackgroundBotLeft:SetPoint('TOPLEFT', CharacterModelFrameBackgroundTopLeft, 'BOTTOMLEFT')
    CharacterModelFrameBackgroundBotLeft:SetPoint('BOTTOMRIGHT', -19, 0)

    CharacterModelFrameBackgroundBotRight:ClearAllPoints()
    CharacterModelFrameBackgroundBotRight:SetPoint('TOPLEFT', CharacterModelFrameBackgroundBotLeft, 'TOPRIGHT')
    CharacterModelFrameBackgroundBotRight:SetPoint('BOTTOMRIGHT')

    CharacterStatsPane.ClassBackground:ClearAllPoints()
    CharacterStatsPane.ClassBackground:SetAllPoints(CharacterStatsPane)


    CharacterFrame.InsetRight:ClearAllPoints()
    CharacterFrame.InsetRight:SetPoint('TOPRIGHT', 0, -58)
    CharacterFrame.InsetRight:SetPoint('BOTTOMRIGHT')
    CharacterFrame.InsetRight:SetWidth(203)

    CharacterFrame.Inset:ClearAllPoints()
    CharacterFrame.Inset:SetPoint('TOPRIGHT', CharacterFrame.InsetRight, 'TOPLEFT')
    CharacterFrame.Inset:SetPoint('BOTTOMLEFT')
    CharacterFrame.Inset.NineSlice:Hide()



    ReputationFrame.ScrollBox:ClearAllPoints()
    ReputationFrame.ScrollBox:SetPoint('TOPLEFT', 4, -58)
    ReputationFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -22, 2)

    TokenFrame.ScrollBox:ClearAllPoints()
    TokenFrame.ScrollBox:SetPoint('TOPLEFT', TokenFrame, 4, -58)
    TokenFrame.ScrollBox:SetPoint('BOTTOMRIGHT', TokenFrame , -22, 2)


    local function Set_Button_Point()
        if not CharacterFrame:IsVisible() or WoWTools_FrameMixin:IsLocked(CharacterFrame) then
            return
        end

        local w, h= CharacterFrame:GetSize()--366 * 337   (40+4)*8
        local scale= self:Save().CharacterSlotScale or 1
        local line= math.max(0, (h-60-32-37*8*scale)/8)

        --CharacterHeadSlot
        CharacterNeckSlot:SetPoint('TOPLEFT', CharacterHeadSlot, 'BOTTOMLEFT', 0, -line)
        CharacterShoulderSlot:SetPoint('TOPLEFT', CharacterNeckSlot, 'BOTTOMLEFT', 0, -line)
        CharacterBackSlot:SetPoint('TOPLEFT', CharacterShoulderSlot, 'BOTTOMLEFT', 0, -line)
        CharacterChestSlot:SetPoint('TOPLEFT', CharacterBackSlot, 'BOTTOMLEFT', 0, -line)
        CharacterShirtSlot:SetPoint('TOPLEFT', CharacterChestSlot, 'BOTTOMLEFT', 0, -line)
        CharacterTabardSlot:SetPoint('TOPLEFT', CharacterShirtSlot, 'BOTTOMLEFT', 0, -line)
        CharacterWristSlot:SetPoint('TOPLEFT', CharacterTabardSlot, 'BOTTOMLEFT', 0, -line)

        --CharacterHandsSlot
        CharacterWaistSlot:SetPoint('TOPLEFT', CharacterHandsSlot, 'BOTTOMLEFT', 0, -line)
        CharacterLegsSlot:SetPoint('TOPLEFT', CharacterWaistSlot, 'BOTTOMLEFT', 0, -line)
        CharacterFeetSlot:SetPoint('TOPLEFT', CharacterLegsSlot, 'BOTTOMLEFT', 0, -line)
        CharacterFinger0Slot:SetPoint('TOPLEFT', CharacterFeetSlot, 'BOTTOMLEFT', 0, -line)
        CharacterFinger1Slot:SetPoint('TOPLEFT', CharacterFinger0Slot, 'BOTTOMLEFT', 0, -line)
        CharacterTrinket0Slot:SetPoint('TOPLEFT', CharacterFinger1Slot, 'BOTTOMLEFT', 0, -line)
        CharacterTrinket1Slot:SetPoint('TOPLEFT', CharacterTrinket0Slot, 'BOTTOMLEFT', 0, -line)

        line= (w-40*2-200-203)/3
        CharacterMainHandSlot:SetPoint('BOTTOM', 100+line, 16)
        CharacterSecondaryHandSlot:SetPoint('LEFT', CharacterMainHandSlot,'RIGHT', math.max(5, line), 0)
    end

    CharacterFrame:HookScript('OnSizeChanged', function(frame)
        Set_Button_Point()
    end)



    CharacterMainHandSlot:ClearAllPoints()
    CharacterMainHandSlot:SetPoint('BOTTOMRIGHT', CharacterModelScene, 'BOTTOM', 0, -6)


    WoWTools_DataMixin:Hook(CharacterFrame, 'UpdateSize', function(f)
        if not f.ResizeButton then
            return
        end
        local size
        if f.Expanded then
            f.ResizeButton.minWidth=450
            size= self:Save().size['CharacterFrameExpanded']
        else
            size= self:Save().size['CharacterFrameCollapse']
            f.ResizeButton.minWidth=320
        end
        if size then
            f:SetSize(size[1], size[2])
        end
    end)


    local function settings()
        local scale= self:Save().CharacterSlotScale or 1
        for _, slot in pairs(WoWTools_PaperDollMixin.ItemButtons) do
            local btn= _G[slot]
            if btn and not WoWTools_FrameMixin:IsLocked(btn) then
                btn:SetScale(scale)
            end
        end
    end

    if self:Save().CharacterSlotScale and self:Save().CharacterSlotScale~=1 then
        settings()
    end

    self:Setup(CharacterFrame, {
        minW=450,
        minH=424,
    sizeUpdateFunc=function()
        if PaperDollFrame.EquipmentManagerPane:IsVisible() then
            WoWTools_DataMixin:Call('PaperDollEquipmentManagerPane_Update')
        end
        if PaperDollFrame.TitleManagerPane:IsVisible() then
            WoWTools_DataMixin:Call('PaperDollTitlesPane_Update')
        end
    end,
    sizeStopFunc=function(frame)
        if frame.Expanded then
            self:Save().size['CharacterFrameExpanded']={frame:GetSize()}
        else
            self:Save().size['CharacterFrameCollapse']={frame:GetSize()}
        end
    end,
    sizeRestFunc=function(f)
        if not WoWTools_FrameMixin:IsLocked(f) then
            if (self:Save().size['CharacterFrameExpanded'] or self:Save().size['CharacterFrameCollapse']) then
                f:SetHeight(424)
            end
            self:Save().size['CharacterFrameExpanded']=nil
            self:Save().size['CharacterFrameCollapse']=nil
            WoWTools_DataMixin:Call(f.UpdateSize, f)
        end
    end,
    sizeRestTooltipColorFunc=function(f)
        return ((f.target.Expanded and self:Save().size['CharacterFrameExpanded']) or (not f.target.Expanded and self:Save().size['CharacterFrameCollapse'])) and '' or '|cff626262'
    end,
    addMenu= function(frame, root)
        root:CreateDivider()
        local sub= root:CreateButton(
            (WoWTools_DataMixin.onlyChinese and '装备栏位' or ORDER_HALL_EQUIPMENT_SLOTS)
            ..' '
            ..(self:Save().CharacterSlotScale or 1),
        function()
            return MenuResponse.Open
        end)

        WoWTools_MenuMixin:ScaleRoot(frame, sub,
        function()
            return self:Save().CharacterSlotScale or 1
        end, function(value)
            self:Save().CharacterSlotScale= value
            settings()
            Set_Button_Point()

        end, function()
            self:Save().CharacterSlotScale= nil
            settings()
            Set_Button_Point()
        end)
    end})

    CharacterFrame.Background:SetPoint('TOPLEFT', 3, -3)
    CharacterFrame.Background:SetPoint('BOTTOMRIGHT',-3, 3)

    self:Setup(TokenFrame, {frame=CharacterFrame})
    self:Setup(TokenFramePopup, {frame=CharacterFrame})
    self:Setup(ReputationFrame, {frame=CharacterFrame})
    self:Setup(ReputationFrame.ReputationDetailFrame, {frame=CharacterFrame})

    self:Setup(CurrencyTransferMenu)
    self:Setup(CurrencyTransferLog, {
        sizeRestFunc=function(frame)
            frame:ClearAllPoints()
            frame:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 5,0)
            frame:SetSize(340, 370)
        end, scaleRestFunc= function(frame)
            frame:ClearAllPoints()
            frame:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 5,0)
        end,
    })

end