local e= select(2, ...)








local function Set_Dragonriding_Speed(frame)
    if not frame or frame.speedBar then
        return
    end
    frame.speedBar= CreateFrame('StatusBar', nil, frame)
    frame.speedBar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status')
    frame.speedBar:SetStatusBarColor(e.Player.r, e.Player.g, e.Player.b)
    frame.speedBar:SetPoint('BOTTOM', frame, 'TOP')
    frame.speedBar:SetMinMaxValues(0, 100)
    frame.speedBar:SetSize(240,10)

    local texture= frame.speedBar:CreateTexture(nil,'BACKGROUND')
    texture:SetAllPoints(frame.speedBar)
    texture:SetAtlas('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask')
    texture:SetAlpha(0.3)

    texture= frame.speedBar:CreateTexture(nil,'OVERLAY')
    texture:SetAtlas('worldstate-capturebar-divider-safedangerous-embercourt')
    texture:SetSize(3, 6)
    texture:SetPoint('LEFT', 180, 0)
    texture:SetVertexColor(1, 0, 1)

    texture= frame.speedBar:CreateTexture(nil,'OVERLAY')
    texture:SetAtlas('worldstate-capturebar-divider-safedangerous-embercourt')
    texture:SetSize(3, 6)
    texture:SetPoint('LEFT', 120, 0)
    texture:SetVertexColor(0, 1, 0)

    texture= frame.speedBar:CreateTexture(nil,'OVERLAY')
    texture:SetAtlas('worldstate-capturebar-divider-safedangerous-embercourt')
    texture:SetSize(3, 6)
    texture:SetPoint('LEFT', 60, 0)
    texture:SetVertexColor(0.93, 0.82, 0.00)


    frame.speedBar.Text= WoWTools_LabelMixin:Create(frame.speedBar, {size=16, color= true})
    frame.speedBar.Text:SetPoint('BOTTOM', frame.speedBar, 'TOP', 0,1)

    frame.speedBar:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3)+ elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
            local base = isGliding and forwardSpeed or GetUnitSpeed("player") or 0
            if base>0 then
                self.Text:SetText(math.modf(base / BASE_MOVEMENT_SPEED * 100))
                local r,g,b=1,1,1-- e.Player.r, e.Player.g, e.Player.b
                if isGliding then
                    if forwardSpeed==100 then
                        r,g,b= 0.64, 0.21, 0.93
                    elseif forwardSpeed>90 then
                        r,g,b= 1, 0, 1
                    elseif forwardSpeed>60 then
                        r,g,b= 0, 1, 0
                    elseif forwardSpeed >30 then
                        r,g,b= 0.93, 0.82, 0.00
                    else
                        r,g,b= 1, 0, 0
                    end
                end
                self:SetStatusBarColor(r,g,b)
            else
                self.Text:SetText('')
            end
            self:SetValue(base)
            --[[if not canGlide then
                self:Hide()
            end]]
        end
    end)

    frame:HookScript('OnShow', function(self)
        self.speedBar:SetShown(self:IsShown())
    end)
    frame.speedBar:SetShown(frame:IsShown())
end













--驭空术UI，速度
local function Init()

    if UIWidgetPowerBarContainerFrame.moveButton then
        UIWidgetPowerBarContainerFrame.moveButton:ClearAllPoints()
        UIWidgetPowerBarContainerFrame.moveButton:SetPoint('BOTTOM', UIWidgetPowerBarContainerFrame, 'TOP', -25, 10)
    end

    Set_Dragonriding_Speed(UIWidgetPowerBarContainerFrame.widgetFrames[4460])

    hooksecurefunc(UIWidgetPowerBarContainerFrame, 'CreateWidget', function(_, widgetID)--RemoveWidget Blizzard_UIWidgetManager.lua
        if widgetID~=4460 then
            return
        end
        Set_Dragonriding_Speed(UIWidgetPowerBarContainerFrame.widgetFrames[4460])
    end)
end


function WoWTools_AttributesMixin:Init_Dragonriding_Speed()
    if not self.Save.disabledDragonridingSpeed then
        Init()
    end
end