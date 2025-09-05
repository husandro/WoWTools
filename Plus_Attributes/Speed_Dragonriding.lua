
local BuffTabs={
    447959,--一起骑乘 - 开启
    404183,--掠地滑翔
    447982,--奔雷疾冲
}

local function Create_Buff(frame)--AuraButtonArtTemplate

end












local function Create_Bar(frame)
    frame.speedBar:SetStatusBarTexture('UI-HUD-CoolDownManager-Bar')--UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Status')

    frame.speedBar:SetPoint('BOTTOM', frame, 'TOP')
    frame.speedBar:SetMinMaxValues(0, 100)
    frame.speedBar:SetSize(240,10)

    local texture= frame.speedBar:CreateTexture(nil,'BACKGROUND')
    texture:SetAllPoints(frame.speedBar)
    texture:SetAtlas('UI-HUD-CoolDownManager-Bar-BG')--UI-HUD-UnitFrame-Player-PortraitOn-Bar-Mana-Mask')
    texture:SetVertexColor(1, 0.5, 0.25, 0.5)

    texture= frame.speedBar:CreateTexture(nil,'OVERLAY')--90
    texture:SetAtlas('worldstate-capturebar-divider-safedangerous-embercourt')
    texture:SetSize(3, 5)
    texture:SetPoint('LEFT', 180, 1)
    texture:SetVertexColor(1, 0.5, 0.25)

    texture= frame.speedBar:CreateTexture(nil,'OVERLAY')--60
    texture:SetAtlas('worldstate-capturebar-divider-safedangerous-embercourt')
    texture:SetSize(3, 5)
    texture:SetPoint('LEFT', 120, 1)
    texture:SetVertexColor(0, 1, 0)


    texture= frame.speedBar:CreateTexture(nil,'OVERLAY')--30
    texture:SetAtlas('worldstate-capturebar-divider-safedangerous-embercourt')
    texture:SetSize(3, 5)
    texture:SetPoint('LEFT', 60, 01)
    texture:SetVertexColor(1, 1, 1)
end




local function Set_Dragonriding_Speed(frame)
    if not frame or frame.speedBar then
        return
    end

    frame.speedBar= CreateFrame('StatusBar', 'WoWToolsAttributesSpeedDragonriding', frame)
    
    Create_Bar(frame)


    frame.speedBar.Text= WoWTools_LabelMixin:Create(frame.speedBar, {size=16, color= true})
    frame.speedBar.Text:SetPoint('BOTTOM', frame.speedBar, 'TOP', 0,1)

    frame.speedBar.Text2= WoWTools_LabelMixin:Create(frame.speedBar, {color= true})
    frame.speedBar.Text2:SetPoint('BOTTOMRIGHT', frame.speedBar, 'TOPRIGHT')

    Create_Buff(frame)

    frame.speedBar:SetScript('OnUpdate', function(self, elapsed)
        self.elapsed= (self.elapsed or 0.3)+ elapsed
        if self.elapsed>0.3 then
            self.elapsed=0
            local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
            local base = isGliding and forwardSpeed or GetUnitSpeed("player") or 0
            if base>0 then
                self.Text:SetText(math.modf(base / BASE_MOVEMENT_SPEED * 100))
                local r,g,b=1,1,1-- WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b
                if isGliding and forwardSpeed>=30 then
                    if forwardSpeed>95 then
                        r,g,b=1,0,0
                    elseif forwardSpeed>=60 then
                        r,g,b= 1, 0.5, 0.25
                    else
                        r,g,b=0,1,0
                    end
                end
                self:SetStatusBarColor(r,g,b)
            else
                self.Text:SetText('')
            end
            self.Text2:SetFormattedText('%i', forwardSpeed)
            self:SetValue(base)
        end
    end)

    frame:HookScript('OnShow', function(self)
        self.speedBar:SetShown(self:IsShown())
    end)
    frame:HookScript('OnShow', function(self)
        self.elapsed=nil
    end)
    frame.speedBar:SetShown(frame:IsShown())
end













--驭空术UI，速度
local function Init()

    if UIWidgetPowerBarContainerFrame.WoWToolsMoveButton then
        UIWidgetPowerBarContainerFrame.WoWToolsMoveButton:ClearAllPoints()
        UIWidgetPowerBarContainerFrame.WoWToolsMoveButton:SetPoint('BOTTOM', UIWidgetPowerBarContainerFrame, 'TOP', -25, 10)
    end

    Set_Dragonriding_Speed(UIWidgetPowerBarContainerFrame.widgetFrames[4460])

    WoWTools_DataMixin:Hook(UIWidgetPowerBarContainerFrame, 'CreateWidget', function(_, widgetID)--RemoveWidget Blizzard_UIWidgetManager.lua
        if widgetID~=4460 then
            return
        end
        Set_Dragonriding_Speed(UIWidgetPowerBarContainerFrame.widgetFrames[4460])
    end)
end


function WoWTools_AttributesMixin:Init_Dragonriding_Speed()
    if WoWToolsSave['Plus_Attributes'].disabledDragonridingSpeed then
        return
    end

    do
        Init()
    end
    Init=function()end
end