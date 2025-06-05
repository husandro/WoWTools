--GossipFrame
function WoWTools_TextureMixin.Frames:GossipFrame()
    self:SetButton(GossipFrameCloseButton, {all=true})
    self:SetNineSlice(GossipFrame, true)
    self:SetAlphaColor(GossipFrameBg)

    self:HideTexture(GossipFrameInset.Bg)
    self:SetNineSlice(GossipFrameInset, nil, true)

    self:SetScrollBar(GossipFrame.GreetingPanel)
    self:Init_BGMenu_Frame(GossipFrame, GossipFrame.Background, {
        alpha=1,
    })
end

--任务
function WoWTools_TextureMixin.Frames:QuestFrame()
    self:SetButton(QuestFrameCloseButton, {all=true})
    self:SetNineSlice(QuestFrame, true)
    self:SetAlphaColor(QuestFrameBg)
    self:HideTexture(QuestFrameInset.Bg)
    self:SetScrollBar(QuestFrame)
    self:SetScrollBar(QuestProgressScrollFrame)
    self:SetScrollBar(QuestDetailScrollFrame)

    self:SetNineSlice(QuestLogPopupDetailFrame, true)
    self:SetAlphaColor(QuestLogPopupDetailFrameBg)
    self:HideFrame(QuestLogPopupDetailFrameInset)
    self:SetScrollBar(QuestLogPopupDetailFrameScrollFrame)
    self:SetNineSlice(QuestLogPopupDetailFrameInset, nil, true)

    self:SetFrame(QuestModelScene)
    self:SetAlphaColor(QuestNPCModelTextFrameBg, nil, nil, 0.3)
    self:SetScrollBar(QuestNPCModelTextScrollChildFrame)
end










--信箱
function WoWTools_TextureMixin.Frames:MailFrame()
    self:SetNineSlice(MailFrame, true)
    self:SetAlphaColor(MailFrameBg)
    self:SetAlphaColor(SendMailMoneyBgRight, nil, nil, 0.3)
    self:SetAlphaColor(SendMailMoneyBgLeft, nil, nil, 0.3)
    self:SetAlphaColor(SendMailMoneyBgMiddle, nil, nil, 0.3)
    self:SetAlphaColor(MailFrameInset.Bg)
    self:SetNineSlice(OpenMailFrame, true)
    self:SetAlphaColor(OpenMailFrameBg)
    self:SetAlphaColor(OpenMailFrameInset.Bg)
    self:SetTabButton(MailFrameTab1)
    self:SetTabButton(MailFrameTab2)
    self:HideTexture(SendMailMoneyInset.Bg)
    self:SetNineSlice(MailFrameInset, true)
    self:SetScrollBar(SendMailScrollFrame)
    self:SetScrollBar(OpenMailScrollFrame)
end









--拾取, 历史
function WoWTools_TextureMixin.Frames:GroupLootHistoryFrame()
    self:SetNineSlice(GroupLootHistoryFrame, true)
    self:SetAlphaColor(GroupLootHistoryFrameBg)
    self:SetScrollBar(GroupLootHistoryFrame)
    self:SetAlphaColor(GroupLootHistoryFrameMiddle)
    self:SetAlphaColor(GroupLootHistoryFrameLeft)
    self:SetAlphaColor(GroupLootHistoryFrameRight)
    self:SetFrame(GroupLootHistoryFrame.ResizeButton, {alpha=0.3})
end






--频道, 设置
function WoWTools_TextureMixin.Frames:ChatConfigFrame()

    self:SetNineSlice(ChatConfigCategoryFrame, nil, true, nil, true)
    ChatConfigCategoryFrame.NineSlice:SetCenterColor(0,0,0, 0.3)


    self:SetNineSlice(ChatConfigBackgroundFrame,nil, true, nil, true)
    ChatConfigBackgroundFrame.NineSlice:SetCenterColor(0,0,0, 0.3)
    
    self:SetNineSlice(ChatConfigChatSettingsLeft, nil, true)

    self:SetNineSlice(ChatConfigCombatSettingsFilters,nil, true, nil, true)
    ChatConfigCombatSettingsFilters.NineSlice:SetCenterColor(0,0,0, 0.3)
    self:SetScrollBar(ChatConfigCombatSettingsFilters)

    for _, f in pairs({
        ChatConfigCombatSettingsFilters,
        ChatConfigBackgroundFrame,
        CombatConfigMessageSourcesDoneBy,
        CombatConfigMessageSourcesDoneTo,
        ChatConfigOtherSettingsCombat,
        ChatConfigOtherSettingsSystem,
        ChatConfigOtherSettingsPVP,
        ChatConfigOtherSettingsCreature,
    }) do
        if f and f.NineSlice then
            self:SetNineSlice(f, nil, true, nil, true)
            f.NineSlice:SetCenterColor(0,0,0, 0.3)
        end
    end

    self:SetAlphaColor(ChatConfigFrame.Border, nil, nil, 0.3)
    self:HideFrame(ChatConfigFrame.Header)
    ChatConfigFrame.Header.Text:ClearAllPoints()
    ChatConfigFrame.Header.Text:SetPoint('CENTER', 0, -10)
    --self:SetAlphaColor(ChatConfigFrame.Header.RightBG, true)
    --self:SetAlphaColor(ChatConfigFrame.Header.LeftBG, true)
    --self:SetAlphaColor(ChatConfigFrame.Header.CenterBG, true)


    for i= 1, 5 do
        self:SetTabButton(_G['CombatConfigTab'..i])
    end

    local function set_NinelSlice(checkBox, r, g, b)
        if not checkBox or not checkBox.NineSlice then
            return
        end
        if not checkBox.NineSlice.is_Clear then
            self:HideTexture(checkBox.NineSlice.TopEdge)
            self:HideTexture(checkBox.NineSlice.RightEdge)
            self:HideTexture(checkBox.NineSlice.LeftEdge)
            self:HideTexture(checkBox.NineSlice.TopRightCorner)
            self:HideTexture(checkBox.NineSlice.TopLeftCorner)
            self:HideTexture(checkBox.NineSlice.BottomRightCorner)
            self:HideTexture(checkBox.NineSlice.BottomLeftCorner)
            checkBox.NineSlice.is_Clear= true
        end
        if r and g and b then
            checkBox.NineSlice.BottomEdge:SetVertexColor(r,g,b)
        end
    end

    hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame)--ChatConfigFrame.lua
        self:SetNineSlice(frame, nil, true)
        local checkBoxNameString = frame:GetName().."Checkbox"
        for index in pairs(frame.checkBoxTable or {}) do
            set_NinelSlice(_G[checkBoxNameString..index])
        end
    end)
    hooksecurefunc('ChatConfig_UpdateCheckboxes', function(frame)--频道颜色设置 ChatConfigFrame.lua
        if not FCF_GetCurrentChatFrame() then return end

        local checkBoxNameString = frame:GetName().."Checkbox"
        local baseName, colorSwatch
        for index, value in pairs(frame.checkBoxTable or {}) do
            local r,g,b
            baseName = checkBoxNameString..index
            colorSwatch = _G[baseName.."ColorSwatch"]
            if  colorSwatch and not value.isBlank then
                r, g, b = GetMessageTypeColor(value.type)
            end
            r,g,b= r or 1, g or 1, b or 1
            if _G[checkBoxNameString..index.."CheckText"] then
                _G[checkBoxNameString..index.."CheckText"]:SetTextColor(r,g,b)
            end
            set_NinelSlice(_G[checkBoxNameString..index], r, g, b)
        end
    end)


    hooksecurefunc('ChatConfig_CreateColorSwatches', function(frame)
        local checkBoxNameString = frame:GetName().."Swatch"
        for index in pairs(frame.swatchTable or {}) do
            set_NinelSlice(checkBoxNameString..index)
        end
    end)
    hooksecurefunc('ChatConfig_UpdateSwatches', function(frame)
        if not FCF_GetCurrentChatFrame() then
            return
        end
        local nameString = frame:GetName().."Swatch"
        local baseName, colorSwatch, r,g,b
        for index, value in ipairs(frame.swatchTable or {}) do
            baseName = nameString..index
            colorSwatch = _G[baseName.."ColorSwatch"]
            if ( colorSwatch ) then
                r,g,b= GetChatUnitColor(value.type)
            end
            r,g,b= r or 1, g or 1, b or 1
            _G[baseName.."Text"]:SetTextColor(r, g, b)
            _G[baseName].NineSlice.BottomEdge:SetVertexColor(r, g, b)
        end
    end)

    self:SetNineSlice(CombatConfigColorsUnitColors, nil, true)
    self:SetNineSlice(CombatConfigColorsHighlighting, nil, true)
    self:SetNineSlice(CombatConfigColorsColorizeUnitName, nil, true)
    self:SetNineSlice(CombatConfigColorsColorizeSpellNames, nil, true)
    self:SetNineSlice(CombatConfigColorsColorizeDamageNumber, nil, true)
    self:SetNineSlice(CombatConfigColorsColorizeDamageSchool, nil, true)
    self:SetNineSlice(CombatConfigColorsColorizeEntireLine, nil, true)









--社交，按钮
     self:SetAlphaColor(QuickJoinToastButton.FriendsButton, nil, nil, 0.5)
     self:SetFrame(ChatFrameChannelButton, {alpha= 0.5})
     self:SetFrame(ChatFrameMenuButton, {alpha= 0.5})
     self:SetFrame(TextToSpeechButton, {alpha= 0.5})


    for i=1, NUM_CHAT_WINDOWS do
    local frame= _G["ChatFrame"..i]
    if frame then
        self:SetAlphaColor(_G['ChatFrame'..i..'EditBoxMid'], nil, nil, 0.3)
        self:SetAlphaColor(_G['ChatFrame'..i..'EditBoxLeft'], nil, nil, 0.3)
        self:SetAlphaColor(_G['ChatFrame'..i..'EditBoxRight'], nil, nil, 0.3)
        self:SetScrollBar(frame)
        self:SetFrame(frame.ScrollToBottomButton, {notAlpha=true})
    end
    end
    self:SetEditBox(ChatFrame1EditBox)
end







--试衣间
function WoWTools_TextureMixin.Frames:DressUpFrame()
    self:SetNineSlice(DressUpFrame, true)
    self:SetAlphaColor(DressUpFrameBg)
    self:HideTexture(DressUpFrameInset.Bg)
    self:SetFrame(DressUpFrameInset)
    self:SetAlphaColor(DressUpFrame.ModelBackground, nil, nil, 0.3)
    self:SetFrame(DressUpFrame.OutfitDetailsPanel, {alpha=0.3})
    self:SetAlphaColor(DressUpFrame.OutfitDetailsPanel.BlackBackground)
end




function WoWTools_TextureMixin.Frames:ItemTextFrame()
    self:SetNineSlice(ItemTextFrame, true)
    self:HideTexture(ItemTextFrameBg)
    self:HideFrame(ItemTextFrameInset)
    self:SetAlphaColor(ItemTextMaterialTopLeft, nil, nil, 0.3)
    self:SetAlphaColor(ItemTextMaterialTopRight, nil, nil, 0.3)
    self:SetAlphaColor(ItemTextMaterialBotLeft, nil, nil, 0.3)
    self:SetAlphaColor(ItemTextMaterialBotRight, nil, nil, 0.3)
    self:SetScrollBar(ItemTextScrollFrame)
    self:SetNineSlice(ItemTextFrameInset, true)
end




--背包 Bg FlatPanelBackgroundTemplate
function WoWTools_TextureMixin.Frames:ContainerFrame1()
    self:SetButton(ContainerFrameCombinedBags.CloseButton, {all=true})
    self:SetNineSlice(ContainerFrameCombinedBags, true)

    --ContainerFrameCombinedBags.Bg.BottomLeft:SetTexture(0)
    --ContainerFrameCombinedBags.Bg.BottomRight:SetTexture(0)
    self:HideFrame(ContainerFrameCombinedBags.Bg)

    self:SetFrame(ContainerFrameCombinedBags.MoneyFrame.Border, {alpha=0.3})
    self:SetFrame(BackpackTokenFrame.Border, {alpha=0.3})
    self:SetEditBox(BagItemSearchBox)

     for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
         local frame= _G['ContainerFrame'..i]
         if frame then
            self:SetColorTexture(frame.Bg.BottomLeft)
            self:SetColorTexture(frame.Bg.BottomRight)
            frame.Bg:SetFrameStrata('LOW')
            self:SetNineSlice(frame, true)
            self:SetFrame(frame.Bg)
         end
    end



    local function set_BagTexture(frame)
        if not frame:IsVisible() then
            return
        end
        for _, btn in frame:EnumerateValidItems() do
            if not btn.hasItem then
                --self:HideTexture(btn.icon)
                self:HideTexture(btn.ItemSlotBackground)
                self:SetAlphaColor(btn.Background,nil, nil, 0.2)
                --self:HideTexture(btn.Background)

                btn.icon:SetAlpha(0)
                btn.NormalTexture:SetVertexColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
                btn.NormalTexture:SetAlpha(0.2)
            else
                btn.icon:SetAlpha(1)
                btn.NormalTexture:SetAlpha(0)
            end
        end
    end

    hooksecurefunc('ContainerFrame_GenerateFrame',function()--ContainerFrame.lua 背包里，颜色
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            if not frame.SetBagAlpha then
                set_BagTexture(frame)
                hooksecurefunc(frame, 'UpdateItems', set_BagTexture)
                frame:SetTitle('')--名称
                hooksecurefunc(frame, 'UpdateName', function(self2) self2:SetTitle('') end)
                frame.SetBagAlpha=true
            end
        end
    end)


    for _, text in pairs({
        'CharacterBag0Slot',
        'CharacterBag1Slot',
        'CharacterBag2Slot',
        'CharacterBag3Slot',
        'CharacterReagentBag0Slot',
    }) do
        if _G[text] then
            self:SetAlphaColor(_G[text]:GetNormalTexture(), true)
        end
    end

    ContainerFrameCombinedBagsPortraitButton:RegisterForMouse("RightButtonDown", 'LeftButtonDown', "LeftButtonUp", 'RightButtonUp')
    self:Init_BGMenu_Frame(ContainerFrameCombinedBags)
end








--考古学 ArchaeologyProgressBar.xml
function WoWTools_TextureMixin.Frames:ArcheologyDigsiteProgressBar()
     self:SetAlphaColor(ArcheologyDigsiteProgressBar.BarBorderAndOverlay, true)
    self:HideTexture(ArcheologyDigsiteProgressBar.Shadow)
    ArcheologyDigsiteProgressBar.BarTitle:SetShadowOffset(1, -1)
    self:HideTexture(ArcheologyDigsiteProgressBar.BarBackground)
end






--商人
function WoWTools_TextureMixin.Frames:MerchantFrame()
    self:SetScrollBar(MerchantFrame)
    self:SetNineSlice(MerchantFrame)
    self:HideFrame(MerchantFrame)

    self:SetTabButton(MerchantFrameTab1)
    self:SetTabButton(MerchantFrameTab2)

    self:SetNineSlice(MerchantFrameInset, nil, true)
    self:HideTexture(MerchantFrameInset.Bg)

    self:SetMenu(MerchantFrame.FilterDropdown)

    self:SetAlphaColor(MerchantMoneyInset.Bg)
    self:HideTexture(MerchantMoneyBgMiddle)
    self:HideTexture(MerchantMoneyBgLeft)
    self:HideTexture(MerchantMoneyBgRight)

    self:SetAlphaColor(MerchantExtraCurrencyBg)
    self:SetAlphaColor(MerchantExtraCurrencyInset)
    self:HideTexture(MerchantFrameBottomLeftBorder)
    self:SetButton(MerchantFrameCloseButton, {all=true})

    for i=1, math.max(MERCHANT_ITEMS_PER_PAGE, BUYBACK_ITEMS_PER_PAGE) do --MERCHANT_ITEMS_PER_PAGE = 10 BUYBACK_ITEMS_PER_PAGE = 12
        self:SetAlphaColor(_G['MerchantItem'..i..'SlotTexture'])
    end
    self:HideTexture(MerchantBuyBackItemSlotTexture)

    self:SetAlphaColor(StackSplitFrame.SingleItemSplitBackground, true)
    self:SetAlphaColor(StackSplitFrame.MultiItemSplitBackground, true)
    self:HideFrame(MerchantRepairItemButton, {index=1})
    self:HideFrame(MerchantRepairAllButton, {index=1})
    self:HideFrame(MerchantGuildBankRepairButton, {index=1})
    self:HideFrame(MerchantSellAllJunkButton, {index=1})

    self:Init_BGMenu_Frame(MerchantFrame)
end









--就绪
function WoWTools_TextureMixin.Frames:ReadyCheckListenerFrame()
    self:SetNineSlice(ReadyCheckListenerFrame, true)
    self:SetAlphaColor(ReadyCheckListenerFrame.Bg, true)
end












