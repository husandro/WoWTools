--角色
local e= select(2, ...)
local function Save()
    return WoWTools_MoveMixin.Save
end






local function Init()
    PaperDollFrame.TitleManagerPane:ClearAllPoints()
    PaperDollFrame.TitleManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
    PaperDollFrame.TitleManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)
    PaperDollFrame.TitleManagerPane.ScrollBox:ClearAllPoints()
    PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('TOPLEFT',CharacterFrameInsetRight,4,-4)
    PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22,0)

    PaperDollFrame.EquipmentManagerPane:ClearAllPoints()
    PaperDollFrame.EquipmentManagerPane:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -4)
    PaperDollFrame.EquipmentManagerPane:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -4, 4)
    PaperDollFrame.EquipmentManagerPane.ScrollBox:ClearAllPoints()
    PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('TOPLEFT', CharacterFrameInsetRight, 4, -28)
    PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint('BOTTOMRIGHT', CharacterFrameInsetRight, -22,0)

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

    CharacterMainHandSlot:ClearAllPoints()
    CharacterMainHandSlot:SetPoint('BOTTOMRIGHT', CharacterFrameInset, 'BOTTOM', -2.5, 16)

    CharacterFrame.InsetRight:ClearAllPoints()
    CharacterFrame.InsetRight:SetPoint('TOPRIGHT', 0, -58)
    CharacterFrame.InsetRight:SetPoint('BOTTOMRIGHT')
    CharacterFrame.InsetRight:SetWidth(203)

    CharacterFrame.Inset:ClearAllPoints()
    CharacterFrame.Inset:SetPoint('BOTTOMLEFT')
    CharacterFrame.Inset:SetPoint('TOPRIGHT', CharacterFrame.InsetRight, 'TOPLEFT')
    CharacterFrame.Inset.NineSlice:Hide()

    CharacterFrame.Background:SetPoint('RIGHT')

    ReputationFrame.ScrollBox:ClearAllPoints()
    ReputationFrame.ScrollBox:SetPoint('TOPLEFT', 4, -58)
    ReputationFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -22, 2)

    TokenFrame.ScrollBox:ClearAllPoints()
    TokenFrame.ScrollBox:SetPoint('TOPLEFT', TokenFrame, 4, -58)
    TokenFrame.ScrollBox:SetPoint('BOTTOMRIGHT', TokenFrame , -22, 2)

    hooksecurefunc(CharacterFrame, 'UpdateSize', function(self)
        if not self.ResizeButton then
            return
        end
        local size
        if self.Expanded then
            self.ResizeButton.minWidth=450
            size= Save().size['CharacterFrameExpanded']
        else
            size= Save().size['CharacterFrameCollapse']
            self.ResizeButton.minWidth=320
        end
        if size then
            self:SetSize(size[1], size[2])
        end
    end)


    WoWTools_MoveMixin:Setup(CharacterFrame, {
        minW=450,
        minH=424,
        setSize=true,
        sizeUpdateFunc=function()
            if PaperDollFrame.EquipmentManagerPane:IsVisible() then
                e.call(PaperDollEquipmentManagerPane_Update)
            end
            if PaperDollFrame.TitleManagerPane:IsVisible() then
                e.call(PaperDollTitlesPane_Update)
            end
        end,
        sizeStopFunc=function(btn)
            local self= btn.target
            if CharacterFrame.Expanded then
                Save().size['CharacterFrameExpanded']={self:GetSize()}
            else
                Save().size['CharacterFrameCollapse']={self:GetSize()}
            end
        end,
        sizeRestFunc=function()
            local find= (Save().size['CharacterFrameExpanded'] or Save().size['CharacterFrameCollapse']) and true or false
            Save().size['CharacterFrameExpanded']=nil
            Save().size['CharacterFrameCollapse']=nil
            if find then
                CharacterFrame:SetHeight(424)
            end
            CharacterFrame:UpdateSize()
        end,
        sizeRestTooltipColorFunc=function(self)
            return ((self.target.Expanded and Save().size['CharacterFrameExpanded']) or (not self.target.Expanded and Save().size['CharacterFrameCollapse'])) and '' or '|cff9e9e9e'
        end
    })

    WoWTools_MoveMixin:Setup(TokenFrame, {frame=CharacterFrame})
    WoWTools_MoveMixin:Setup(TokenFramePopup, {frame=CharacterFrame})
    WoWTools_MoveMixin:Setup(ReputationFrame, {frame=CharacterFrame})
    WoWTools_MoveMixin:Setup(ReputationFrame.ReputationDetailFrame, {frame=CharacterFrame})
    WoWTools_MoveMixin:Setup(CurrencyTransferMenu)
    WoWTools_MoveMixin:Setup(CurrencyTransferMenu.TitleContainer, {frame=CurrencyTransferMenu})






    WoWTools_MoveMixin:Setup(CurrencyTransferLog, {
        setSize=true,
        sizeRestFunc=function(btn)
            btn.target:ClearAllPoints()
            btn.target:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 5,0)
            btn.target:SetSize(340, 370)
        end, scaleRestFunc= function(btn)
            btn.target:ClearAllPoints()
            btn.target:SetPoint('TOPLEFT', CharacterFrame, 'TOPRIGHT', 5,0)
        end,
    })
end







function WoWTools_MoveMixin:Init_CharacterFrame()--角色
    Init()
end