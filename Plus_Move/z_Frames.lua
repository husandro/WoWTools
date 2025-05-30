local function Save()
    return WoWToolsSave['Plus_Move']
end



--商人
function WoWTools_MoveMixin.Frames:MerchantFrame()
    if WoWToolsSave['Plus_SellBuy'] then
        if WoWToolsSave['Plus_SellBuy'].notPlus or WoWToolsSave['Plus_SellBuy'].disabled then
            self:Setup(MerchantFrame)
        end
    end
end




--对话
function WoWTools_MoveMixin.Frames:GossipFrame()
    hooksecurefunc(GossipGreetingTextMixin, 'Setup', function(b)
        b.GreetingText:SetWidth(b:GetWidth()-22)
    end)
    GossipFrame.GreetingPanel:SetPoint('BOTTOMRIGHT')
    GossipFrame.GreetingPanel.ScrollBox:SetPoint('BOTTOMRIGHT', -28,28)
    GossipFrame.Background:SetPoint('BOTTOMRIGHT', -28,28)

    self:Setup(GossipFrame, {minW=220, minH=220, setSize=true, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(384, 512)
    end})
end



--试衣间
function WoWTools_MoveMixin.Frames:DressUpFrame()
    DressUpFrame:HookScript('OnShow', function(b)--DressUpFrame_Show
        local size= Save().size[b:GetName()]
        if size then
            b:SetSize(size[1], size[2])
        end
    end)
    self:Setup(DressUpFrame, {setSize=true, minH=330, minW=330, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(450, 545)
    end})
end

--小，背包
function WoWTools_MoveMixin.Frames:ContainerFrame1()
    for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
        local frame= _G['ContainerFrame'..i]
        if frame then
            if i==1 then
                self:Setup(frame, {save=true})
            else
                self:Setup(frame)
            end
        end
    end
    hooksecurefunc('UpdateContainerFrameAnchors', function()--ContainerFrame.lua
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            local name= frame:GetName()
            if name then
                --if not Save().disabledZoom and Save().scale[name] and Save().scale[name]~=1 then--缩放
                if Save().scale[name] and Save().scale[name]~=1 then--缩放
                    frame:SetScale(Save().scale[name])
                end
                if (frame==ContainerFrameCombinedBags or frame==ContainerFrame1) then--位置
                    self:SetPoint(frame, name)--设置, 移动, 位置
                end
            end
        end
    end)

--背包
    self:MoveAlpha(BagsBar)

    self:Setup(ContainerFrameCombinedBags)
end






--任务
function WoWTools_MoveMixin.Frames:QuestFrame()
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

    self:Setup(QuestFrame, {
        minW=164,
        minH=128,
        setSize=true,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(338, 496)
        end
    })

end

--新内容
function WoWTools_MoveMixin.Frames:SplashFrame()
    self:Setup(SplashFrame)
end


--银行
function WoWTools_MoveMixin.Frames:BankFrame()
    if WoWToolsSave['Plus_Bank'] and WoWToolsSave['Plus_Bank'].disabled then
        self:Setup(BankFrame)
        self:Setup(AccountBankPanel, {frame=BankFrame})
    end
end

--就绪
function WoWTools_MoveMixin.Frames:ReadyCheckFrame()
    self:Setup(ReadyCheckFrame, {notFuori=true})
end

--颜色选择器
function WoWTools_MoveMixin.Frames:ColorPickerFrame()
    self:Setup(ColorPickerFrame, {click='RightButton'})
    self:Setup(ColorPickerFrame.Header, {frame=ColorPickerFrame})
    self:Setup(ColorPickerFrame.Content, {frame=ColorPickerFrame})
end


--物品拾取
function WoWTools_MoveMixin.Frames:LootFrame()
    self:Setup(LootFrame, {save=false})
end