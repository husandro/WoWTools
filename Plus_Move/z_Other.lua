local function Save()
    return WoWToolsSave['Plus_Move']
end









local function Init(mxin)
--对话
    mxin:Setup(GossipFrame, {minW=220, minH=220, setSize=true, initFunc=function(btn)
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
    mxin:Setup(ChannelFrame, {minW=402, minH=200, maxW=402, setSize=true,  sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(402, 423)
    end})

--选项
    mxin:Setup(SettingsPanel, {setSize=true, minW=800, minH=200, initFunc=function(btn)
        for _, region in pairs({btn.targetFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT', -12, 38)
            end
        end
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(920, 724)
    end})

--试衣间
    mxin:Setup(DressUpFrame, {setSize=true, minH=330, minW=330, initFunc=function(btn)
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
                mxin:Setup(frame, {save=true})
            else
                mxin:Setup(frame)
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
                        mxin:SetPoint(frame, name)--设置, 移动, 位置
                    end
                end
            end
        end)
    --end

    mxin:Setup(LootFrame, {save=false})--物品拾取
    mxin:Setup(ChatConfigFrame)
    mxin:Setup(ChatConfigFrame.Header, {frame=ChatConfigFrame})
    mxin:Setup(ChatConfigFrame.Border, {frame=ChatConfigFrame})
    ObjectiveTrackerFrame:SetClampedToScreen(false)

    mxin:Setup(GameMenuFrame)--菜单
    mxin:Setup(ExtraActionButton1, {click='RightButton', notSave=true, notMoveAlpha=true, notFuori=true})--额外技能
    mxin:Setup(ContainerFrameCombinedBags)
    --mxin:Setup(ContainerFrameCombinedBags.TitleContainer, {frame=ContainerFrameCombinedBags})

    mxin:Setup(ColorPickerFrame, {click='RightButton'})--颜色选择器
    mxin:Setup(ColorPickerFrame.Header, {frame=ColorPickerFrame})
    mxin:Setup(ColorPickerFrame.Content, {frame=ColorPickerFrame})

    mxin:Setup(PartyFrame.Background, {frame=PartyFrame, notZoom=true, notSave=true})
    mxin:Setup(OpacityFrame)
    mxin:Setup(ArcheologyDigsiteProgressBar, {notZoom=true})
    mxin:Setup(VehicleSeatIndicator, {notZoom=true, notSave=true})
    mxin:Setup(ExpansionLandingPage)
    mxin:Setup(PlayerPowerBarAlt, {notMoveAlpha=true})
    mxin:Setup(CreateChannelPopup)
    mxin:Setup(BattleTagInviteFrame)
    mxin:Setup(OverrideActionBarExpBar, {notZoom=true})
    mxin:Setup(ReportFrame)

--背包
    mxin:MoveAlpha(BagsBar)



--就绪
    mxin:Setup(ReadyCheckFrame, {notFuori=true})

    mxin:Setup(GuildRenameFrame)


    C_Timer.After(0.3, function()


        if WoWTools_DataMixin.Player.Class=='HUNTER' and WoWToolsSave['Plus_StableFrame'] and WoWToolsSave['Plus_StableFrame'].disabled then--StableFrame
            mxin:Setup(StableFrame)
        end

        if WoWToolsSave['Plus_SellBuy'] and WoWToolsSave['Plus_SellBuy'].disabled then
            mxin:Setup(MerchantFrame)
        end
    --插件
        if WoWToolsSave['Plus_AddOns'] and WoWToolsSave['Plus_AddOns'].disabled then
            mxin:Setup(AddonList)
        end
    --银行
        if WoWToolsSave['Plus_Bank'] and WoWToolsSave['Plus_Bank'].disabled then
            mxin:Setup(BankFrame)
            mxin:Setup(AccountBankPanel, {frame=BankFrame})
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

    mxin:Setup(QuestFrame, {
        minW=164,
        minH=128,
        setSize=true,
        sizeRestFunc=function(btn)
            btn.targetFrame:SetSize(338, 496)
        end
    })





    Init=function()end
end



function WoWTools_MoveMixin:Init_Other()
    Init(self)
end