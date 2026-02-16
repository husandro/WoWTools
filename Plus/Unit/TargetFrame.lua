




--####
--目标
--####
local function Init()
    --目标，生命条，颜色，材质
    WoWTools_DataMixin:Hook(TargetFrame, 'CheckClassification', function(frame)--外框，颜色
        local color= WoWTools_UnitMixin:GetColor(frame.unit)
        local r,g,b= color:GetRGB()
        frame.TargetFrameContainer.FrameTexture:SetVertexColor(r, g, b)
        frame.TargetFrameContainer.BossPortraitFrameTexture:SetVertexColor(r, g, b)
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，材质
        frame.healthbar:SetStatusBarColor(r,g,b)--生命条，颜色
    end)

    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetPoint('RIGHT')
    --TargetFrame.TargetFrameContent.TargetFrameContentMain.Name:SetShadowOffset(2, -2)
    --<Anchor point="TOPLEFT" relativeKey="$parent.ReputationColor" relativePoint="TOPRIGHT" x="-106" y="-1"/>

    WoWTools_DataMixin:Hook(TargetFrame,'CheckLevel', function(self)--目标, 等级, 颜色
        local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText
        if levelText then
            local color= WoWTools_UnitMixin:GetColor(self.unit)
            levelText:SetTextColor(color:GetRGB())
        end
    end)

    local rangeFrame= CreateFrame('Frame', nil, TargetFrame)
    rangeFrame:SetSize(1,1)
    rangeFrame:SetPoint('RIGHT', TargetFrame, 'LEFT', 22, 6)
    rangeFrame.unit= 'target'
    WoWTools_UnitMixin:SetRangeFrame(rangeFrame)
    rangeFrame:SetScript('OnHide', function(self)
        self.elapsed=nil
        self.Text:SetText('')
        self.Text2:SetText('')
        self.Text3:SetText('')
    end)

--目标的目标
    WoWTools_TextureMixin:SetFrame(TargetFrame.TargetFrameContent.TargetFrameContentContextual.NumericalThreat, {index=1})

    Init=function()end
end













function WoWTools_UnitMixin:Init_TargetFrame()--目标
    Init()
end