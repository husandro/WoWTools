local function Save()
    return WoWToolsSave['Plus_Move']
end









local function Init()
--对话
    WoWTools_MoveMixin:Setup(GossipFrame, {minW=220, minH=220, setSize=true, initFunc=function(self)
        self.target.GreetingPanel:SetPoint('BOTTOMRIGHT')
        self.target.GreetingPanel.ScrollBox:SetPoint('BOTTOMRIGHT', -28,28)
        self.target.Background:SetPoint('BOTTOMRIGHT', -28,28)
        --GreetingText:SetWidth(GreetingText:GetParent():GetWidth()-56)
        hooksecurefunc(GossipGreetingTextMixin, 'Setup', function(self)
            self.GreetingText:SetWidth(self:GetWidth()-22)
        end)
        --hooksecurefunc(GossipOptionButtonMixin, 'Setup', function(self, optionInfo)
    end, sizeRestFunc=function(self)
        self.targetFrame:SetSize(384, 512)
    end})

--聊天设置
    WoWTools_MoveMixin:Setup(ChannelFrame, {minW=402, minH=200, maxW=402, setSize=true,  sizeRestFunc=function(self)
        self.targetFrame:SetSize(402, 423)
    end})

--选项
    WoWTools_MoveMixin:Setup(SettingsPanel, {setSize=true, minW=800, minH=200, initFunc=function(btn)
        for _, region in pairs({btn.targetFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT', -12, 38)
            end
        end
    end, sizeRestFunc=function(self)
        self.targetFrame:SetSize(920, 724)
    end})

--试衣间
    WoWTools_MoveMixin:Setup(DressUpFrame, {setSize=true, minH=330, minW=330, initFunc=function(btn)
        btn.targetFrame:HookScript('OnShow', function(self)--DressUpFrame_Show
            local size= Save().size[self:GetName()]
            if size then
                self:SetSize(size[1], size[2])
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
                WoWTools_MoveMixin:Setup(frame, {save=true})
            else
                WoWTools_MoveMixin:Setup(frame)
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
                        WoWTools_MoveMixin:SetPoint(frame, name)--设置, 移动, 位置
                    end
                end
            end
        end)
    --end

    WoWTools_MoveMixin:Setup(LootFrame, {save=false})--物品拾取
    WoWTools_MoveMixin:Setup(ChatConfigFrame)
    WoWTools_MoveMixin:Setup(ChatConfigFrame.Header, {frame=ChatConfigFrame})
    WoWTools_MoveMixin:Setup(ChatConfigFrame.Border, {frame=ChatConfigFrame})
    ObjectiveTrackerFrame:SetClampedToScreen(false)

    WoWTools_MoveMixin:Setup(GameMenuFrame)--菜单
    WoWTools_MoveMixin:Setup(ExtraActionButton1, {click='RightButton', notSave=true, notMoveAlpha=true, notFuori=true})--额外技能
    WoWTools_MoveMixin:Setup(ContainerFrameCombinedBags)
    --WoWTools_MoveMixin:Setup(ContainerFrameCombinedBags.TitleContainer, {frame=ContainerFrameCombinedBags})

    WoWTools_MoveMixin:Setup(ColorPickerFrame, {click='RightButton'})--颜色选择器
    WoWTools_MoveMixin:Setup(ColorPickerFrame.Header, {frame=ColorPickerFrame})
    WoWTools_MoveMixin:Setup(ColorPickerFrame.Content, {frame=ColorPickerFrame})

    WoWTools_MoveMixin:Setup(PartyFrame.Background, {frame=PartyFrame, notZoom=true, notSave=true})
    WoWTools_MoveMixin:Setup(OpacityFrame)
    WoWTools_MoveMixin:Setup(ArcheologyDigsiteProgressBar, {notZoom=true})
    WoWTools_MoveMixin:Setup(VehicleSeatIndicator, {notZoom=true, notSave=true})
    WoWTools_MoveMixin:Setup(ExpansionLandingPage)
    WoWTools_MoveMixin:Setup(PlayerPowerBarAlt, {notMoveAlpha=true})
    WoWTools_MoveMixin:Setup(CreateChannelPopup)
    WoWTools_MoveMixin:Setup(BattleTagInviteFrame)
    WoWTools_MoveMixin:Setup(OverrideActionBarExpBar, {notZoom=true})
    WoWTools_MoveMixin:Setup(ReportFrame)

--背包
    WoWTools_MoveMixin:MoveAlpha(BagsBar)

--商店
    WoWTools_MoveMixin:Setup(AccountStoreFrame, {setSize=true, minH=537, minW=800,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(800, 537)
    end})

--就绪
    WoWTools_MoveMixin:Setup(ReadyCheckFrame, {notFuori=true})

    WoWTools_MoveMixin:Setup(GuildRenameFrame)


    C_Timer.After(0.3, function()


        if WoWTools_DataMixin.Player.Class=='HUNTER' and WoWToolsSave['Plus_StableFrame'] and WoWToolsSave['Plus_StableFrame'].disabled then--StableFrame
            WoWTools_MoveMixin:Setup(StableFrame)
        end

        if WoWToolsSave['Plus_SellBuy'] and WoWToolsSave['Plus_SellBuy'].disabled then
            WoWTools_MoveMixin:Setup(MerchantFrame)
        end
    --插件
        if WoWToolsSave['Plus_AddOns'] and WoWToolsSave['Plus_AddOns'].disabled then
            WoWTools_MoveMixin:Setup(AddonList)
        end
    --银行
        if WoWToolsSave['Plus_Bank'] and WoWToolsSave['Plus_Bank'].disabled then
            WoWTools_MoveMixin:Setup(BankFrame)
            WoWTools_MoveMixin:Setup(AccountBankPanel, {frame=BankFrame})
        end
    end)
end



function WoWTools_MoveMixin:Init_Other()
    Init()
end