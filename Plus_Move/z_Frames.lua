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

    self:Setup(GossipFrame, {minW=220, minH=220, setSize=true,
    sizeRestFunc=function()
        GossipFrame:SetSize(384, 512)
    end
    })
end















--试衣间
function WoWTools_MoveMixin.Frames:DressUpFrame()
    local function Set_Max(frame)
        local w, h= UIParent:GetSize()
        local s= (math.min(w, h)- 40)
        s= math.max(s, 50)
        frame:ClearAllPoints()
        frame:SetPoint('CENTER')
        frame:SetSize(s, s)
    end
    hooksecurefunc(DressUpFrame, 'SetShownOutfitDetailsPanel', function(frame)
        if frame.ResizeButton and not GetCVarBool("miniDressUpFrame") then
            Set_Max(frame)
        end
        frame:Raise()
    end)
    hooksecurefunc(DressUpFrame, 'ConfigureSize', function(frame, isMinimized)
        if not frame.ResizeButton then
            return
        end
        local name= frame:GetName()

        frame:SetMovable(isMinimized)
        frame.ResizeButton:SetShown(isMinimized)
        frame:SetScale(isMinimized and Save().scale[name] or 1)

        if isMinimized then
            local size= Save().size[name]
            if size then
                frame:SetSize(size[1], size[2])
            end
        else
            Set_Max(frame)
        end

        frame:Raise()
    end)

    self:Setup(DressUpFrame, {setSize=true, minH=320, minW=310,
    sizeRestFunc=function()
        Save().size[DressUpFrame:GetName()]= nil
        DressUpFrame:ConfigureSize(GetCVarBool("miniDressUpFrame"))
        DressUpFrame:Raise()
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
        sizeRestFunc=function()
            QuestFrame:SetSize(338, 496)
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

    LootFrame.ScrollBox:SetPoint('RIGHT')

    hooksecurefunc(LootFrameElementMixin, 'Init', function(btn)
        btn.Text:SetPoint('RIGHT', -8, 0)
    end)

    hooksecurefunc(LootFrame, 'Open', function(frame)
        if WoWTools_FrameMixin:IsLocked(frame) then
            return
        end

        local s= Save().size['LootFrame']
        local p

        if not GetCVarBool("lootUnderMouse") then
            p= Save().point['LootFrame']
        end

        if p and p[1] then
            frame:ClearAllPoints()
            frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        end
        if s and s[1] then
            frame:SetWidth(s[1])
        end
    end)


    self:Setup(LootFrame, {
        setSize=true, isShow=true,
    sizeStopFunc=function()
        ScrollingFlatPanelMixin.Open(LootFrame, true)
    end, sizeRestFunc=function()
        Save().size['LootFrame']= nil
        LootFrame:SetWidth(220)
	    ScrollingFlatPanelMixin.Open(LootFrame, true)
    end})
end