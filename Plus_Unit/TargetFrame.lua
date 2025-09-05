




--####
--目标
--####
local function Init()
    --目标，生命条，颜色，材质
    WoWTools_DataMixin:Hook(TargetFrame, 'CheckClassification', function(frame)--外框，颜色
        local r,g,b= select(2, WoWTools_UnitMixin:GetColor(frame.unit))
        frame.TargetFrameContainer.FrameTexture:SetVertexColor(r, g, b)
        frame.TargetFrameContainer.BossPortraitFrameTexture:SetVertexColor(r, g, b)
        frame.healthbar:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')--生命条，材质
        frame.healthbar:SetStatusBarColor(r,g,b)--生命条，颜色
    end)

    WoWTools_DataMixin:Hook(TargetFrame,'CheckLevel', function(self)--目标, 等级, 颜色
        local levelText = self.TargetFrameContent.TargetFrameContentMain.LevelText
        if levelText then
            local r,g,b= select(2, WoWTools_UnitMixin:GetColor(self.unit))
            levelText:SetTextColor(r,g,b)
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

    Init=function()end
end

    --[[TargetFrame.rangeText= WoWTools_LabelMixin:Create(TargetFrame, {justifyH='RIGHT'})
    TargetFrame.rangeText:SetPoint('RIGHT', TargetFrame, 'LEFT', 22, 6)
    TargetFrame.speedText= WoWTools_LabelMixin:Create(TargetFrame, {justifyH='RIGHT', color={r=1,g=1,b=1}})
    TargetFrame.speedText:SetPoint('TOPRIGHT', TargetFrame.rangeText, 'BOTTOMRIGHT', 0, -2)

    TargetFrame:HookScript('OnHide', function(self)
        self.elapsed= nil
    end)
    WoWTools_DataMixin:Hook(TargetFrame, 'OnUpdate', function(self, elapsed)--距离
        self.elapsed= (self.elapsed or 0.3) + elapsed
        if self.elapsed<0.3 then
            return
        end

        self.elapsed=0
        local text, speed

        if not UnitIsUnit('player', 'target') then
            local mi, ma= WoWTools_UnitMixin:GetRange('target')
            if mi and ma then
                text=mi..'|n'..ma
                if mi>40 then
                    text='|cFFFF0000'..text--红色

                elseif mi>35 then
                    text='|cFFFFD000'..text
                elseif mi>30 then
                    text='|cFFFF00FF'..text
                elseif mi >8 then
                    text ='|cFFFFFF00'..text
                elseif mi>5 then
                    text='|cFFAF00FF'..text
                elseif mi>2 then
                    text='|cFF00FF00'..text
                else
                    text='|cFFFFFFFF'..text----白色
                end
            end

            local value= GetUnitSpeed('target') or 0
            if value==0 then
                speed= '|cff8282820%'
            else
                speed= format( '%.0f%%', (value)*100/BASE_MOVEMENT_SPEED)
            end

        end
        self.rangeText:SetText(text or '')
        self.speedText:SetText(speed or '')
    end)]]













function WoWTools_UnitMixin:Init_TargetFrame()--目标
    Init()
end