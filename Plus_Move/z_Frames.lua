local function Save()
    return WoWToolsSave['Plus_Move']
end









local function Init(self)
--对话
    self:Setup(GossipFrame, {minW=220, minH=220, setSize=true, initFunc=function(btn)
        btn.targetFrame.GreetingPanel:SetPoint('BOTTOMRIGHT')
        btn.targetFrame.GreetingPanel.ScrollBox:SetPoint('BOTTOMRIGHT', -28,28)
        btn.targetFrame.Background:SetPoint('BOTTOMRIGHT', -28,28)
        --GreetingText:SetWidth(GreetingText:GetParent():GetWidth()-56)
        hooksecurefunc(GossipGreetingTextMixin, 'Setup', function(btn)
            btn.GreetingText:SetWidth(btn:GetWidth()-22)
        end)
        --hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(btn, optionInfo)
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(384, 512)
    end})

--聊天设置
    self:Setup(ChannelFrame, {minW=402, minH=200, maxW=402, setSize=true,  sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(402, 423)
    end})

--选项
    self:Setup(SettingsPanel, {setSize=true, minW=800, minH=200, initFunc=function(btn)
        for _, region in pairs({btn.targetFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT', -12, 38)
            end
        end
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(920, 724)
    end})

--试衣间
    self:Setup(DressUpFrame, {setSize=true, minH=330, minW=330, initFunc=function(btn)
        btn.targetFrame:HookScript('OnShow', function(b)--DressUpFrame_Show
            local size= Save().size[b:GetName()]
            if size then
                b:SetSize(size[1], size[2])
            end
        end)
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(450, 545)
    end})

--小，背包
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
    --if not Save().disabledZoom and not Save().disabledMove then
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
    --end

    self:Setup(LootFrame, {save=false})--物品拾取
    self:Setup(ChatConfigFrame)
    self:Setup(ChatConfigFrame.Header, {frame=ChatConfigFrame})
    self:Setup(ChatConfigFrame.Border, {frame=ChatConfigFrame})
    ObjectiveTrackerFrame:SetClampedToScreen(false)

    self:Setup(GameMenuFrame)--菜单
    self:Setup(ExtraActionButton1, {click='RightButton', notSave=true, notMoveAlpha=true, notFuori=true})--额外技能
    self:Setup(ContainerFrameCombinedBags)
    --self:Setup(ContainerFrameCombinedBags.TitleContainer, {frame=ContainerFrameCombinedBags})

    self:Setup(ColorPickerFrame, {click='RightButton'})--颜色选择器
    self:Setup(ColorPickerFrame.Header, {frame=ColorPickerFrame})
    self:Setup(ColorPickerFrame.Content, {frame=ColorPickerFrame})

    self:Setup(PartyFrame.Background, {frame=PartyFrame, notZoom=true, notSave=true})
    self:Setup(OpacityFrame)
    self:Setup(ArcheologyDigsiteProgressBar, {notZoom=true})
    self:Setup(VehicleSeatIndicator, {notZoom=true, notSave=true})
    self:Setup(ExpansionLandingPage)
    self:Setup(PlayerPowerBarAlt, {notMoveAlpha=true})
    self:Setup(CreateChannelPopup)
    self:Setup(BattleTagInviteFrame)
    self:Setup(OverrideActionBarExpBar, {notZoom=true})
    self:Setup(ReportFrame)

--背包
    self:MoveAlpha(BagsBar)



--就绪
    self:Setup(ReadyCheckFrame, {notFuori=true})



    C_Timer.After(0.3, function()


        if WoWTools_DataMixin.Player.Class=='HUNTER' and WoWToolsSave['Plus_StableFrame'] and WoWToolsSave['Plus_StableFrame'].disabled then--StableFrame
            self:Setup(StableFrame)
        end

        if WoWToolsSave['Plus_SellBuy'] and WoWToolsSave['Plus_SellBuy'].disabled then
            self:Setup(MerchantFrame)
        end
    --插件
        if WoWToolsSave['Plus_AddOns'] and WoWToolsSave['Plus_AddOns'].disabled then
            self:Setup(AddonList)
        end
    --银行
        if WoWToolsSave['Plus_Bank'] and WoWToolsSave['Plus_Bank'].disabled then
            self:Setup(BankFrame)
            self:Setup(AccountBankPanel, {frame=BankFrame})
        end
    end)











--任务
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

--任务
    self:Setup(QuestFrame, {
        minW=164,
        minH=128,
        setSize=true,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(338, 496)
        end
    })


--新内容
    self:Setup(SplashFrame)


    Init=function()end
end



function WoWTools_MoveMixin:Init_Other()
    Init(self)
end