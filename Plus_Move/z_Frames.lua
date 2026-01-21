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
    WoWTools_DataMixin:Hook(GossipGreetingTextMixin, 'Setup', function(b)
        b.GreetingText:SetWidth(b:GetWidth()-22)
    end)
    GossipFrame.GreetingPanel:SetPoint('BOTTOMRIGHT')
    GossipFrame.GreetingPanel.ScrollBox:SetPoint('BOTTOMRIGHT', -28,28)
    GossipFrame.Background:SetPoint('BOTTOMRIGHT', -28,28)

    self:Setup(GossipFrame, {
        minW=220,
        minH=220,
        sizeRestFunc=function(f)
            f:SetSize(384, 512)
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

    WoWTools_DataMixin:Hook(DressUpFrame, 'ConfigureSize', function(frame, isMinimized)
        if not frame.ResizeButton then
            return
        end
        local name= frame:GetName()

        frame:SetMovable(isMinimized)
        frame.ResizeButton:SetShown(isMinimized)
        frame:SetScale(isMinimized and self:Save().scale[name] or 1)

        if isMinimized then
            local size= self:Save().size[name]
            if size then
                frame:SetSize(size[1], size[2])
            end
        else
            Set_Max(frame)
        end

        frame:Raise()
    end)

    self:Setup(DressUpFrame, {
        minH=320, minW=310,
    sizeRestFunc=function(f)
        --self:Save().size[f:GetName()]= nil
        f:ConfigureSize(true)--GetCVarBool("miniDressUpFrame"))
        f:Raise()
    end})

    if DressUpFrame.OutfitDetailsPanel then
        self:Setup(DressUpFrame.OutfitDetailsPanel, {frame=DressUpFrame})
    end

    DressUpFrame.SetSelectionPanel:SetPoint('TOPLEFT', DressUpFrame, 'TOPRIGHT', 7, 23)--<Anchor point="TOPLEFT" relativePoint="TOPRIGHT" x="-7" y="-30"/>
    DressUpFrame.SetSelectionPanel:SetPoint('BOTTOMLEFT', DressUpFrame, 'BOTTOMRIGHT', -7, 0)
    self:Setup(DressUpFrame.SetSelectionPanel, {frame=DressUpFrame})
end






--任务
function WoWTools_MoveMixin.Frames:QuestFrame()
    --QuestFrame <Size x="338" y="496"/>
    QuestDetailScrollFrame:HookScript('OnSizeChanged', function(_, w)
        QUEST_TEMPLATE_DETAIL.contentWidth=w-25--275
        QUEST_TEMPLATE_LOG.contentWidth= w-15--285
        QUEST_TEMPLATE_REWARD.contentWidth= w-15--285
    end)

    self:Setup(QuestLogPopupDetailFrame)

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
        sizeRestFunc=function(f)
            f:SetSize(338, 496)
        end
    })
end

--新内容
function WoWTools_MoveMixin.Frames:SplashFrame()
    self:Setup(SplashFrame)
end




--就绪
function WoWTools_MoveMixin.Frames:ReadyCheckFrame()
    WoWTools_DataMixin:Hook('ShowReadyCheck', function(initiator)
        if initiator==UnitName('player') then
            ReadyCheckFrame:SetShown(false)
        end
    end)
    self:Setup(ReadyCheckFrame)
    --self:Setup(ReadyCheckListenerFrame, {frame=ReadyCheckFrame})
end

--颜色选择器
function WoWTools_MoveMixin.Frames:ColorPickerFrame()
    self:Setup(ColorPickerFrame, {click='RightButton'})
    self:Setup(ColorPickerFrame.Header, {frame=ColorPickerFrame})
    self:Setup(ColorPickerFrame.Content, {frame=ColorPickerFrame})
end

--物品拾取
function WoWTools_MoveMixin.Frames:LootFrame()

    LootFrame.ScrollBox:SetPoint('RIGHT', -12, 0)

    WoWTools_DataMixin:Hook(LootFrameItemElementMixin, 'OnLoad', function(btn)
        btn.Text:SetPoint('RIGHT', -8, 0)
    end)
    --WoWTools_DataMixin:Hook(LootFrameElementMixin, 'Init', function(btn)

    WoWTools_DataMixin:Hook(LootFrame, 'Open', function(frame)
        if WoWTools_FrameMixin:IsLocked(frame) then
            return
        end

        local s= self:Save().size['LootFrame']
        local p

        if not GetCVarBool("lootUnderMouse") then
            p= self:Save().point['LootFrame']
        end

        if p and p[1] then
            frame:ClearAllPoints()
            frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        end
        if s and s[1] then
            frame:SetWidth(s[1])
            if s[2] then
                frame:SetHeight(s[2])
            end
        end
    end)


    self:Setup(LootFrame, {
        isShow=true,
    sizeRestFunc=function()
	    ScrollingFlatPanelMixin.Open(LootFrame, true)
    end})
end

function WoWTools_MoveMixin.Frames:ItemTextFrame()
    self:Setup(ItemTextFrame)
end


function WoWTools_MoveMixin.Frames:UIWidgetBelowMinimapContainerFrame()
    self:Setup(UIWidgetBelowMinimapContainerFrame, {frame=UIParentRightManagedFrameContainer, notSave=true})--UIParentRightManagedFrameContainer
end






--职责选取框
function WoWTools_MoveMixin.Frames:RolePollPopup()
    self:Setup(RolePollPopup)
end


function WoWTools_MoveMixin.Frames:CatalogShopFrame()--Blizzard_CatalogShop
    CatalogShopFrame.ProductContainerFrame:SetClampedToScreen(false)

    self:Setup(CatalogShopFrame)
    --self:Setup(CatalogShopFrame.ForegroundContainer, {frame= CatalogShopFrame})
    self:Setup(CatalogShopFrame.CatalogShopDetailsFrame, {frame= CatalogShopFrame})
    self:Setup(CatalogShopFrame.ModelSceneContainerFrame, {frame= CatalogShopFrame})

    self:Setup(CatalogShopFrame.ProductContainerFrame, {frame= CatalogShopFrame})
    self:Setup(CatalogShopFrame.ProductContainerFrame.ProductsHeader, {frame= CatalogShopFrame})

    self:Setup(CatalogShopFrame.ProductDetailsContainerFrame.DetailsProductContainerFrame, {frame= CatalogShopFrame})
    self:Setup(CatalogShopFrame.ProductDetailsContainerFrame.DetailsProductContainerFrame.ProductsHeader, {frame= CatalogShopFrame})
end