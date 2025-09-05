--GossipFrame
function WoWTools_TextureMixin.Frames:GossipFrame()
    self:SetButton(GossipFrameCloseButton)
    --self:SetNineSlice(GossipFrame, true)
    self:HideTexture(GossipFrameBg)
    self:HideTexture(GossipFrame.TopTileStreaks)

    self:HideTexture(GossipFrameInset.Bg)
    self:SetNineSlice(GossipFrameInset)

    self:SetScrollBar(GossipFrame.GreetingPanel)

    self:Init_BGMenu_Frame(GossipFrame, {
        enabled=true,
        alpha=1,
        --settings=function(_, texture, alpha)
          --  GossipFrame.Background:SetAlpha(texture and 0 or alpha or 1)
        --end
    })
end

--任务
function WoWTools_TextureMixin.Frames:QuestFrame()
    self:HideFrame(QuestFrame)
    --self:SetNineSlice(QuestFrame)
    self:SetScrollBar(QuestFrame)

    self:SetButton(QuestFrameCloseButton)

    self:HideTexture(QuestFrameInset.Bg)
    self:SetNineSlice(QuestFrameInset)
    self:SetScrollBar(QuestRewardScrollFrame)

    self:SetScrollBar(QuestProgressScrollFrame)
    self:SetScrollBar(QuestDetailScrollFrame)

    self:SetNineSlice(QuestLogPopupDetailFrame)
    self:SetAlphaColor(QuestLogPopupDetailFrameBg)
    self:HideFrame(QuestLogPopupDetailFrameInset)
    self:SetScrollBar(QuestLogPopupDetailFrameScrollFrame)
    self:SetNineSlice(QuestLogPopupDetailFrameInset)

    self:SetFrame(QuestModelScene)
    self:SetAlphaColor(QuestNPCModelTextFrameBg, nil, nil, 0.3)
    self:SetScrollBar(QuestNPCModelTextScrollChildFrame)

    self:Init_BGMenu_Frame(QuestFrame, {
        enabled=true,
        alpha=1,
        settings=function(_, texture, alpha)
            alpha= texture and 0 or alpha or 1
            QuestFrameRewardPanelBg:SetAlpha(alpha)
            QuestFrameDetailPanelBg:SetAlpha(alpha)
            QuestFrameProgressPanelBg:SetAlpha(alpha)
        end
    })
end
















--拾取, 历史
function WoWTools_TextureMixin.Frames:GroupLootHistoryFrame()
    self:SetNineSlice(GroupLootHistoryFrame, self.min, true)
    self:SetAlphaColor(GroupLootHistoryFrameBg)
    self:SetScrollBar(GroupLootHistoryFrame)
    self:SetAlphaColor(GroupLootHistoryFrameMiddle)
    self:SetAlphaColor(GroupLootHistoryFrameLeft)
    self:SetAlphaColor(GroupLootHistoryFrameRight)
    self:SetFrame(GroupLootHistoryFrame.ResizeButton, {alpha=0.3})
end






--频道, 设置
function WoWTools_TextureMixin.Frames:ChatConfigFrame()


    self:SetNineSlice(ChatConfigChatSettingsLeft)

    self:SetScrollBar(ChatConfigCombatSettingsFilters)

    for _, f in pairs({
        ChatConfigCategoryFrame,
        ChatConfigCombatSettingsFilters,
        ChatConfigBackgroundFrame,
        CombatConfigMessageSourcesDoneBy,
        CombatConfigMessageSourcesDoneTo,
        ChatConfigOtherSettingsCombat,
        ChatConfigOtherSettingsSystem,
        ChatConfigOtherSettingsPVP,
        ChatConfigOtherSettingsCreature,
        CombatConfigColorsUnitColors,
        CombatConfigColorsHighlighting,
        CombatConfigColorsColorizeUnitName,
        CombatConfigColorsColorizeSpellNames,
        CombatConfigColorsColorizeDamageNumber,
        CombatConfigColorsColorizeDamageSchool,
        CombatConfigColorsColorizeEntireLine,
        ChatConfigChannelSettingsLeft,

    }) do
        self:SetNineSlice(f)
    end

    self:HideFrame(ChatConfigFrame.Border)
    self:HideFrame(ChatConfigFrame.Header)
    ChatConfigFrame.Header.Text:ClearAllPoints()
    ChatConfigFrame.Header.Text:SetPoint('CENTER', 0, -10)

    for i= 1, 5 do
        self:SetTabButton(_G['CombatConfigTab'..i])
    end




    local function hook_texture(colorTexture, nineSlice, font)
        if not colorTexture or colorTexture.isset_hook then
            return
        end

        colorTexture.BottomEdge= nineSlice and nineSlice.BottomEdge or nil
        colorTexture.font= font

        WoWTools_DataMixin:Hook(colorTexture, 'SetVertexColor', function(f, r2, g2, b2, a2)
            if r2 and r2 and b2 then
                if f.BottomEdge then
                    f.BottomEdge:SetVertexColor(r2, g2, b2, a2 or 1)
                end
                if f.font then
                    f.font:SetTextColor(r2, g2, b2)
                end
            end
        end)
        colorTexture.isset_hook= true
    end

    hook_texture(
        CombatConfigColorsColorizeSpellNamesColorSwatchNormalTexture,
        CombatConfigColorsColorizeSpellNames.NineSlice,
        CombatConfigColorsColorizeSpellNamesCheckText
    )
    hook_texture(
        CombatConfigColorsColorizeDamageNumberColorSwatchNormalTexture,
        CombatConfigColorsColorizeDamageNumber.NineSlice,
        CombatConfigColorsColorizeDamageNumberCheckText
    )

    local function set_NinelSlice(name, index, value)
        local check = _G[name..'Checkbox'..index]--ChatConfigChatSettingsLeft Checkbox 1 CheckText
        local swatch = _G[name..'Swatch'..index]--CombatConfigColorsUnit ColorsSwatch 2 Text
        local colorTexture, nineSlice, font, r, g, b

        if check then
            nineSlice= check.NineSlice
            font= _G[name..'Checkbox'..index.."CheckText"]
            if value and value.type and CHATCONFIG_SELECTED_FILTER then
                r, g, b = GetMessageTypeColor(value.type)
            end

            local t= _G[name..'Checkbox'..index.."ColorSwatch"]
            colorTexture= t and t.Color

            if not r and colorTexture then
                r,g,b= colorTexture:GetVertexColor()
            end

        elseif swatch then
            nineSlice= swatch.NineSlice
            font= _G[name..'Swatch'..index.."Text"]
            if value and value.type and CHATCONFIG_SELECTED_FILTER then
                r, g, b = GetChatUnitColor(value.type)
            end
            colorTexture=_G[name..'Swatch'..index.."ColorSwatchNormalTexture"]
        end



        if nineSlice then
            nineSlice:SetVertexColor(0,0,0,0)
            nineSlice.BottomEdge:SetVertexColor(r or 1, g or 1, b or 1, 1)
        end
        if font then
            font:SetTextColor(r or 1, g or 1, b or 1)
        end

        hook_texture(colorTexture, nineSlice, font)
    end

    local function settings(frame)
        if not frame:IsVisible() or not FCF_GetCurrentChatFrame() then
            return
        end
        if frame.NineSlice then
            frame.NineSlice:SetBorderColor(0,0,0,0,0)
            frame.NineSlice:SetCenterColor(0,0,0,0.15)
        end

        local name = frame:GetName()
        for index, value in pairs(frame.checkBoxTable or frame.swatchTable or {}) do
            set_NinelSlice(name, index, value)
        end
    end
    WoWTools_DataMixin:Hook('ChatConfig_CreateCheckboxes', function(frame)--ChatConfigFrame.lua
        settings(frame)
    end)
    WoWTools_DataMixin:Hook('ChatConfig_UpdateCheckboxes', function(frame)--频道颜色设置 ChatConfigFrame.lua
        settings(frame)
    end)
    WoWTools_DataMixin:Hook('ChatConfig_CreateColorSwatches', function(frame)--ChatConfigFrame.lua
        settings(frame)
    end)
    WoWTools_DataMixin:Hook('ChatConfig_UpdateSwatches', function(frame)
        settings(frame)
    end)

    self:Init_BGMenu_Frame(ChatConfigFrame, {
        isNewButton=true,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT', ChatConfigFrame.Border)
        end
    })







--社交，按钮
    self:SetAlphaColor(QuickJoinToastButton.FriendsButton, nil, nil, 0.5)
    self:SetFrame(ChatFrameChannelButton, {alpha= 0.5})
    self:SetFrame(ChatFrameMenuButton, {alpha= 0.5})
    self:SetFrame(TextToSpeechButton, {alpha= 0.5})

--聊天框 FloatingChatFrame.lua
    --最小化聊天框
    WoWTools_DataMixin:Hook('FCF_CreateMinimizedFrame', function(chatFrame)
        local name= chatFrame:GetName()
        self:SetFrame(_G[name..'MinimizedMaximizeButton'])
        self:SetFrame(_G[name..'Minimized'])
    end)

    --WoWTools_DataMixin:Hook('FCF_OpenTemporaryWindow', function(chatType, chatTarget, sourceChatFrame, selectWindow)
--提示, 使其不可交互
    local function Set_SetUninteractable(chatFrame)
        local name= chatFrame:GetName()
        local isLocked= chatFrame.isUninteractable
        if isLocked then
            chatFrame.lockedTexture= chatFrame:CreateTexture('WoWToolsIsLocked'..name, 'BORDER')
            chatFrame.lockedTexture:SetPoint('RIGHT', _G[name..'Tab'].Text, 'LEFT', 2,-2)
            chatFrame.lockedTexture:SetSize(10,14)
            chatFrame.lockedTexture:SetAtlas('Garr_LockedBuilding')
            --chatFrame.lockedTexture:SetAlpha(0.5)
        end
        if chatFrame.lockedTexture then
            chatFrame.lockedTexture:SetShown(isLocked)
        end
    end
    WoWTools_DataMixin:Hook('FCF_SetUninteractable', function(chatFrame)--使其不可交互
        Set_SetUninteractable(chatFrame)
    end)
    --[[WoWTools_DataMixin:Hook('FCF_SetExpandedUninteractable', function(chatFrame)--使其不可交互
        if ( chatFrame.isDocked ) then
            for _, frame in pairs(GENERAL_CHAT_DOCK.DOCKED_CHAT_FRAMES) do
                FCF_SetUninteractable(frame)
            end
        else
            FCF_SetUninteractable(chatFrame)
        end
    end)]]
    
    --[[WoWTools_DataMixin:Hook('FCF_MaximizeFrame', function(chatFrame)
        local name= chatFrame:GetName()
        self:SetFrame(_G[name..'ButtonFrameMinimizeButton'])
        self:SetFrame(_G[name..'ResizeButton'])

    end)]]
    for i=1, NUM_CHAT_WINDOWS do
        local frame= _G["ChatFrame"..i]
        if frame then
            self:SetAlphaColor(_G['ChatFrame'..i..'EditBoxMid'], nil, nil, 0.3)
            self:SetAlphaColor(_G['ChatFrame'..i..'EditBoxLeft'], nil, nil, 0.3)
            self:SetAlphaColor(_G['ChatFrame'..i..'EditBoxRight'], nil, nil, 0.3)

            self:SetFrame(_G['ChatFrame'..i..'ResizeButton'])
            self:SetFrame(_G['ChatFrame'..i..'ButtonFrameMinimizeButton'])

            self:SetScrollBar(frame)
            self:SetFrame(frame.ScrollToBottomButton, {notAlpha=true})

            Set_SetUninteractable(frame)
        end
    end

    self:SetEditBox(ChatFrame1EditBox)
    self:HideFrame(ChatFrame1ButtonFrame)
    self:HideTexture(ChatFrame1LeftTexture)
    self:HideTexture(ChatFrame1TopTexture)
    self:HideTexture(ChatFrame1BottomTexture)
    self:HideTexture(ChatFrame1RightTexture)

    self:HideTexture(ChatFrame1TopRightTexture)
    self:HideTexture(ChatFrame1TopLeftTexture)
    self:HideTexture(ChatFrame1BottomRightTexture)
    self:HideTexture(ChatFrame1BottomLeftTexture)

    self:Init_BGMenu_Frame(GeneralDockManager, {
        menuTag= 'MENU_FCF_TAB',
        enabled=true,
        alpha=0,
        bgPoint=function(icon)
            icon:SetAllPoints(ChatFrame1Background)
        end
    })
end







--试衣间
function WoWTools_TextureMixin.Frames:DressUpFrame()
    self:HideFrame(DressUpFrame)
    --self:SetNineSlice(DressUpFrame)
    self:SetMenu(DressUpFrameOutfitDropdown)
    self:SetButton(DressUpFrame.ToggleOutfitDetailsButton)

    self:SetNineSlice(DressUpFrameInset)
    self:HideFrame(DressUpFrameInset)

    self:SetFrame(DressUpFrame.OutfitDetailsPanel, {alpha=0.3})
    self:SetButton(DressUpFrame.MaxMinButtonFrame.MinimizeButton, {all=true,})
    self:SetButton(DressUpFrame.MaxMinButtonFrame.MaximizeButton, {all=true,})
    self:SetButton(DressUpFrameCloseButton)

    self:SetButton(DressUpFrameCancelButton)
    self:SetButton(DressUpFrame.LinkButton)
    self:SetButton(DressUpFrameResetButton)

    self:Init_BGMenu_Frame(DressUpFrame, {
        settings=function(_, texture, alpha)
            DressUpFrame.ModelBackground:SetAlpha(texture and 0 or alpha or 1)
        end
    })
end



function WoWTools_TextureMixin.Frames:ItemTextFrame()
    self:HideTexture(ItemTextFrame.TopTileStreaks)
    self:HideTexture(ItemTextFrameBg)
    self:SetButton(ItemTextFrameCloseButton)

    self:SetScrollBar(ItemTextScrollFrame)

    self:HideFrame(ItemTextFrameInset)
    self:SetNineSlice(ItemTextFrameInset)

    self:SetAlphaColor(ItemTextMaterialTopLeft, nil, nil, 0.3)
    self:SetAlphaColor(ItemTextMaterialTopRight, nil, nil, 0.3)
    self:SetAlphaColor(ItemTextMaterialBotLeft, nil, nil, 0.3)
    self:SetAlphaColor(ItemTextMaterialBotRight, nil, nil, 0.3)

    self:Init_BGMenu_Frame(ItemTextFrame, {
        enabled=true,
        alpha=1,
        settings=function(_, texture, alpha)
            ItemTextFramePageBg:SetAlpha(texture and 0 or alpha or 1)
        end
    })



    ItemTextPrevPageButton:SetNormalAtlas('common-icon-backarrow')
    ItemTextPrevPageButton:SetAlpha(0.3)
    ItemTextNextPageButton:SetNormalAtlas('common-icon-forwardarrow')
    ItemTextNextPageButton:SetAlpha(0.3)
    ItemTextScrollFrame:HookScript('OnMouseWheel', function(_, d)
        if d==1 then
            if ItemTextGetPage()>1 then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                ItemTextPrevPage()
            end
        else
            if ItemTextHasNextPage() then
                PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                ItemTextNextPage()
            end
        end
    end)
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
    --self:SetNineSlice(MerchantFrame)
    self:HideFrame(MerchantFrame)

    self:SetTabButton(MerchantFrameTab1)
    self:SetTabButton(MerchantFrameTab2)

    self:SetNineSlice(MerchantFrameInset)
    self:HideTexture(MerchantFrameInset.Bg)

    self:SetMenu(MerchantFrame.FilterDropdown)

    self:SetAlphaColor(MerchantMoneyInset.Bg)
    self:HideTexture(MerchantMoneyBgMiddle)
    self:HideTexture(MerchantMoneyBgLeft)
    self:HideTexture(MerchantMoneyBgRight)

    self:SetAlphaColor(MerchantExtraCurrencyBg)
    self:SetAlphaColor(MerchantExtraCurrencyInset)
    self:HideTexture(MerchantFrameBottomLeftBorder)
    self:SetButton(MerchantFrameCloseButton)

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
    self:SetNineSlice(ReadyCheckListenerFrame, self.min, true)
    self:SetAlphaColor(ReadyCheckListenerFrame.Bg, true)
end










function WoWTools_TextureMixin.Frames:LootFrame()
    self:SetNineSlice(LootFrame)
    self:HideFrame(LootFrameBg)
    self:SetButton(LootFrame.ClosePanelButton)
    self:SetScrollBar(LootFrame)


    WoWTools_DataMixin:Hook(LootFrameElementMixin, 'Init', function(btn)
        btn.BorderFrame:Hide()
    end)

    self:Init_BGMenu_Frame(LootFrame, {isNewButton=true})
end




--function WoWTools_TextureMixin.Frames:UIWidgetBelowMinimapContainerFrame()