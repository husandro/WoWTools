function WoWToolsButton_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForClicks(WoWTools_DataMixin.LeftButtonDown, WoWTools_DataMixin.RightButtonDown)
end
function WoWToolsMenu_OnLoad(self)
    self:EnableMouseWheel(true)
    self:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
end

function WoWToolsButton_OnLeave(self)
    ResetCursor()
    GameTooltip_Hide()
    if self.set_alpha then
        self:set_alpha()
    elseif self.alpha then
        self:SetAlpha(self:IsMouseOver() and 1 or self.alpha)
    end
end

function WoWToolsButton_OnEnter(self)
    if self.tooltip then
        GameTooltip:SetOwner(self, self.owner or 'ANCHOR_LEFT')
        GameTooltip:ClearLines()
        if type(self.tooltip)=='function' then
            self:tooltip(GameTooltip)
        else
            GameTooltip:AddLine(self.tooltip, nil, nil, nil, true)
        end
        GameTooltip:Show()
    end
    if self.set_alpha then
        self:set_alpha()
    elseif self.alpha then
        self:SetAlpha(self:IsMouseOver() and 1 or self.alpha)
    end
end

--[[


    <Button name="WoWToolsMenu2Template" virtual="true">
        <Size x="23" y="23"/>
        <HighlightTexture atlas="bag-border" setAllPoints="true"/>
        <PushedTexture atlas="bag-border-highlight" setAllPoints="true"/>>
        <Layers>
            <Layer level="BORDER">
                <Texture parentKey="texture" setAllPoints="true"/>>
            </Layer>
            <Layer level="ARTWORK">
                <Texture parentKey="border" atlas='bag-reagent-border' setAllPoints="true"/>
            </Layer>
            <Layer level="OVERLAY">
                <MaskTexture parentKey="IconMask" atlas="CircleMaskScalable" hWrapMode="CLAMPTOBLACKADDITIVE" vWrapMode="CLAMPTOBLACKADDITIVE">
                <Anchors>
                    <Anchor point="TOPLEFT" x="0" y="0"/>
                    <Anchor point="BOTTOMRIGHT" x="-5" y="5"/>
                </Anchors>
                <MaskedTextures>
                    <MaskedTexture childKey="texture"/>
                </MaskedTextures>
				</MaskTexture>
            </Layer>
        </Layers>
        <Scripts>
            <OnLoad>
                WoWTools_TextureMixin:SetAlphaColor(self.border, nil, nil, 0)
                WoWToolsButton_OnLoad(self)
            </OnLoad>
            <OnLeave function="WoWToolsButton_OnLeave"/>
            <OnEnter function="WoWToolsButton_OnEnter"/>
        </Scripts>
    </Button>

]]