 --任务

local function Init()
    local tab={
        'Detail',
        'Greeting',
        'Progress',
        'Reward',
    }
    for _, name in pairs(tab) do
        local frame= _G['QuestFrame'..name..'Panel']
        if frame then
            frame:SetPoint('BOTTOMRIGHT')
            if frame.Bg then
                frame.Bg:SetPoint('BOTTOMRIGHT', -28,28)
            end
            if frame.SealMaterialBG then
                frame.SealMaterialBG:SetPoint('BOTTOMRIGHT', -28,28)
            end
        end
        frame= _G['Quest'..name..'ScrollFrame']
        if frame then
            frame:SetPoint('BOTTOMRIGHT', -28,28)
        end
    end

    WoWTools_MoveMixin:Setup(QuestFrame, {
        minW=164,
        minH=128,
        setSize=true,
        sizeRestFunc=function(self)
            self.target:SetSize(338, 496)
        end
    })
end






function WoWTools_MoveMixin:Init_QuestFrame()--任务
    Init()
end