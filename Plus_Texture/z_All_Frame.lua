













local function Init(mixin)

    mixin:HideTexture(GameMenuFrame.Header.RightBG)
    mixin:HideTexture(GameMenuFrame.Header.CenterBG)
    mixin:HideTexture(GameMenuFrame.Header.LeftBG)
    GameMenuFrame.Header.Text:ClearAllPoints()
    GameMenuFrame.Header.Text:SetPoint('TOP', 0 ,-24)
    mixin:SetFrame(GameMenuFrame.Border, {alpha= 0.3})

    for i=1, MAX_BOSS_FRAMES do
        local frame= _G['Boss'..i..'TargetFrame']
        if frame then
            mixin:HideTexture(frame.TargetFrameContainer.FrameTexture)
        end
    end

    hooksecurefunc('PlayerFrame_UpdateArt', function()--隐藏材质, 载具
        if OverrideActionBarEndCapL then
            mixin:HideTexture(OverrideActionBarEndCapL)
            mixin:HideTexture(OverrideActionBarEndCapR)
            mixin:HideTexture(OverrideActionBarBorder)
            mixin:HideTexture(OverrideActionBarBG)
            mixin:HideTexture(OverrideActionBarButtonBGMid)
            mixin:HideTexture(OverrideActionBarButtonBGR)
            mixin:HideTexture(OverrideActionBarButtonBGL)
        end
        if OverrideActionBarMicroBGMid then
            mixin:HideTexture(OverrideActionBarMicroBGMid)
            mixin:HideTexture(OverrideActionBarMicroBGR)
            mixin:HideTexture(OverrideActionBarMicroBGL)
            mixin:HideTexture(OverrideActionBarLeaveFrameExitBG)

            mixin:HideTexture(OverrideActionBarDivider2)
            mixin:HideTexture(OverrideActionBarLeaveFrameDivider3)
        end
        if OverrideActionBarExpBar then
            mixin:HideTexture(OverrideActionBarExpBarXpMid)
            mixin:HideTexture(OverrideActionBarExpBarXpR)
            mixin:HideTexture(OverrideActionBarExpBarXpL)
            for i=1, 19 do
                mixin:SetAlphaColor(_G['OverrideActionBarXpDiv'..i], nil, nil, 0.3)
            end
        end
    end)
    if ExtraActionButton1 then mixin:HideTexture(ExtraActionButton1.style) end--额外技能
    if ZoneAbilityFrame then mixin:HideTexture(ZoneAbilityFrame.Style) end--区域技能








    if MultiBarBottomLeftButton10 then
        mixin:HideTexture(MultiBarBottomLeftButton10.SlotBackground)
    end

    if CompactRaidFrameManager then--隐藏, 团队, 材质 Blizzard_CompactRaidFrameManager.lua
        mixin:SetAlphaColor(_G['CompactRaidFrameManagerBG-regulars'], nil, nil, 0)
        mixin:SetAlphaColor(_G['CompactRaidFrameManagerBG-party-leads'], nil, nil, 0)
        mixin:SetAlphaColor(_G['CompactRaidFrameManagerBG-leads'], nil, nil, 0)
        mixin:SetAlphaColor(_G['CompactRaidFrameManagerBG-party-regulars'], nil,nil,0)

        CompactRaidFrameManagerToggleButtonForward:SetAlpha(0.3)
        CompactRaidFrameManagerToggleButtonBack:SetAlpha(0.3)
        mixin:SetMenu(CompactRaidFrameManagerDisplayFrameRestrictPingsDropdown)
        mixin:SetMenu(CompactRaidFrameManagerDisplayFrameModeControlDropdown, {alpha=1})
        mixin:HideTexture(_G['CompactRaidFrameManagerBG-assists'])
    end

    --施法条 CastingBarFrameTemplate
    for _, frame in pairs({
        PlayerCastingBarFrame,
        PetCastingBarFrame,
        OverlayPlayerCastingBarFrame,
    }) do
        if frame then
            mixin:SetAlphaColor(frame.Border)
            mixin:SetAlphaColor(frame.Background)
            mixin:SetAlphaColor(frame.TextBorder)
            mixin:SetAlphaColor(frame.Shine)
        end
    end



    --世界地图
    mixin:SetButton(WorldMapFrameCloseButton, {all=true})
    mixin:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MaximizeButton, {all=true})
    mixin:SetButton(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame.MinimizeButton, {all=true})

    mixin:SetNineSlice(WorldMapFrame.BorderFrame, true)
    mixin:SetAlphaColor(WorldMapFrameBg)
    mixin:SetAlphaColor(QuestMapFrame.Background)
    mixin:HideTexture(WorldMapFrame.NavBar.overlay)
    mixin:HideTexture(WorldMapFrame.NavBar.InsetBorderBottom)
    mixin:HideTexture(WorldMapFrame.NavBar.InsetBorderRight)
    mixin:HideTexture(WorldMapFrame.NavBar.InsetBorderLeft)
    mixin:HideTexture(WorldMapFrame.NavBar.InsetBorderBottomRight)
    mixin:HideTexture(WorldMapFrame.NavBar.InsetBorderBottomLeft)
    mixin:HideTexture(WorldMapFrame.BorderFrame.InsetBorderTop)
    WorldMapFrame.NavBar:DisableDrawLayer('BACKGROUND')
    mixin:SetScrollBar(QuestMapDetailsScrollFrame)
    hooksecurefunc(WorldMapFrame, 'SynchronizeDisplayState', function(self)--最大化时，隐藏背景
        if self:IsMaximized() then
            self.BlackoutFrame:Hide()
        end
    end)
    mixin:HideTexture(QuestScrollFrame.Background, true)
    mixin:SetScrollBar(QuestScrollFrame)

    mixin:SetScrollBar(MapLegendScrollFrame)
    mixin:HideTexture(MapLegendScrollFrame.Background, true)
    mixin:SetAlphaColor(QuestMapFrame.MapLegend.BorderFrame.Border, nil, nil, true)
    mixin:SetAlphaColor(QuestScrollFrame.SettingsDropdown.Icon, true, nil, nil)
    mixin:SetAlphaColor(QuestMapFrame.QuestsFrame.DetailsFrame.BorderFrame, true, nil, nil)

    mixin:SetAlphaColor(QuestScrollFrame.BorderFrame.Border, true, nil, nil)
    mixin:SetEditBox(QuestScrollFrame.SearchBox)

--任务，列表 QuestLogHeaderCodeTemplate
    hooksecurefunc(QuestLogHeaderCodeMixin, 'OnLoad', function(btn)
        mixin:SetFrame(btn, {index=2, isMinAlpha=true})
    end)

    mixin:HideTexture(QuestMapFrame.MapLegendTab.Background)
    mixin:HideTexture(QuestMapFrame.QuestsTab.Background)



--PVEFrame
    mixin:SetTabButton(PVEFrameTab1)
    mixin:SetTabButton(PVEFrameTab2)
    mixin:SetTabButton(PVEFrameTab3)
    mixin:SetTabButton(PVEFrameTab4)

    --地下城和团队副本
    mixin:SetButton(PVEFrameCloseButton, {all=true})
    mixin:HideTexture(PVEFrame.TopTileStreaks)--最上面
    mixin:SetNineSlice(PVEFrame, true)
    mixin:SetEditBox(LFGListFrame.SearchPanel.SearchBox)
    mixin:SetScrollBar(LFGListFrame.SearchPanel)
    mixin:SetFrame(LFGListFrame.CategorySelection.Inset, {alpha= 0.3})
    mixin:SetFrame(LFGDungeonReadyDialog.Border, {alpha= 0.3})
    mixin:SetFrame(LFDRoleCheckPopup.Border, {alpha= 0.3})
    mixin:SetFrame(LFGDungeonReadyStatus.Border, {alpha= 0.3})



    mixin:SetNineSlice(LFGListFrame.CategorySelection.Inset, nil, true)
    mixin:SetNineSlice(LFGListFrame.EntryCreation.Inset, nil, true)
    mixin:HideTexture(LFGListFrame.EntryCreation.Inset.CustomBG)
    mixin:HideTexture(LFGListFrame.EntryCreation.Inset.Bg)

    mixin:SetAlphaColor(LFGListFrameMiddleMiddle)
    mixin:SetAlphaColor(LFGListFrameMiddleLeft)
    mixin:SetAlphaColor(LFGListFrameMiddleRight)
    mixin:SetAlphaColor(LFGListFrameBottomMiddle)
    mixin:SetAlphaColor(LFGListFrameTopMiddle)
    mixin:SetAlphaColor(LFGListFrameTopLeft)
    mixin:SetAlphaColor(LFGListFrameBottomLeft)
    mixin:SetAlphaColor(LFGListFrameTopRight)
    mixin:SetAlphaColor(LFGListFrameBottomRight)

    mixin:SetScrollBar(LFGListFrame.ApplicationViewer)
    mixin:SetNineSlice(LFGListFrame.ApplicationViewer.Inset)

    mixin:SetAlphaColor(RaidFinderQueueFrameBackground)

    mixin:HideTexture(RaidFinderFrameRoleBackground)


    --右边
    mixin:HideTexture(PVEFrameLLVert)
    mixin:HideTexture(PVEFrameRLVert)
    mixin:HideTexture(PVEFrameBLCorner)
    mixin:HideTexture(PVEFrameBottomLine)
    mixin:HideTexture(PVEFrameBRCorner)
    mixin:HideTexture(PVEFrameTLCorner)
    mixin:HideTexture(PVEFrameTopLine)
    mixin:HideTexture(PVEFrameTRCorner)


    mixin:SetAlphaColor(PVEFrameBg)--左边


    mixin:HideTexture(PVEFrameBlueBg)
    mixin:HideTexture(PVEFrameLeftInset.Bg)
    mixin:SetNineSlice(PVEFrameLeftInset, nil, true)
    mixin:HideFrame(PVEFrame.shadows)

    mixin:SetAlphaColor(LFDQueueFrameBackground)
    mixin:SetMenu(LFDQueueFrameTypeDropdown)
    mixin:SetMenu(LFGListFrame.SearchPanel.FilterButton)

    mixin:SetNineSlice(LFDParentFrameInset, nil, true)
    mixin:SetAlphaColor(LFDParentFrameInset.Bg)
    mixin:SetNineSlice(RaidFinderFrameBottomInset, nil, true)
    mixin:SetAlphaColor(RaidFinderFrameBottomInset.Bg)

    mixin:SetAlphaColor(LFDParentFrameRoleBackground)

    mixin:HideTexture(LFDParentFrameRoleBackground)
    mixin:SetNineSlice(RaidFinderFrameRoleInset, nil, true)
    mixin:HideTexture(RaidFinderFrameRoleInset.Bg)


    --GossipFrame
    mixin:SetButton(GossipFrameCloseButton, {all=true})
    mixin:SetNineSlice(GossipFrame, true)
    mixin:SetAlphaColor(GossipFrameBg)
    mixin:HideTexture(GossipFrameInset.Bg)
    mixin:SetScrollBar(GossipFrame.GreetingPanel)







--背包 Bg FlatPanelBackgroundTemplate
    mixin:SetButton(ContainerFrameCombinedBags.CloseButton, {all=true})
    mixin:SetNineSlice(ContainerFrameCombinedBags, true)

    ContainerFrameCombinedBags.Bg.BottomLeft:SetTexture(0)
    ContainerFrameCombinedBags.Bg.BottomRight:SetTexture(0)
    mixin:SetFrame(ContainerFrameCombinedBags.Bg)

    mixin:SetFrame(ContainerFrameCombinedBags.MoneyFrame.Border, {alpha=0.3})
    mixin:SetFrame(BackpackTokenFrame.Border, {alpha=0.3})
    mixin:SetEditBox(BagItemSearchBox)

     for i=1 ,NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS+1 do
         local frame= _G['ContainerFrame'..i]
         if frame then
            mixin:SetColorTexture(frame.Bg.BottomLeft)
            mixin:SetColorTexture(frame.Bg.BottomRight)
            frame.Bg:SetFrameStrata('LOW')
            mixin:SetNineSlice(frame, true)
            mixin:SetFrame(frame.Bg)
         end
    end



    local function set_BagTexture(frame)
        if not frame:IsVisible() then
            return
        end
        for _, btn in frame:EnumerateValidItems() do
            if not btn.hasItem then
                --WoWTools_TextureMixin:HideTexture(btn.icon)
                WoWTools_TextureMixin:HideTexture(btn.ItemSlotBackground)
                WoWTools_TextureMixin:SetAlphaColor(btn.Background,nil, nil, 0.2)
                --WoWTools_TextureMixin:HideTexture(btn.Background)

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
            mixin:SetAlphaColor(_G[text]:GetNormalTexture(), true)
        end
    end





     --好友列表
     mixin:SetNineSlice(FriendsFrame, true)
     mixin:SetAlphaColor(FriendsFrameBg)
     mixin:SetNineSlice(FriendsFrameInset, true)
     mixin:SetAlphaColor(FriendsFrameInset.Bg, nil, nil, 0.3)
     mixin:SetScrollBar(FriendsListFrame)
     mixin:SetScrollBar(IgnoreListFrame)

     mixin:SetFrame(FriendsFrameBattlenetFrame.BroadcastButton, {notAlpha=true})
     mixin:SetButton(FriendsFrameCloseButton, {all=true})

     --好友列表，召募
     if RecruitAFriendFrame and RecruitAFriendFrame.RecruitList then
        mixin:SetScrollBar(RecruitAFriendFrame.RecruitList)
        mixin:SetAlphaColor(RecruitAFriendFrame.RecruitList.ScrollFrameInset.Bg)
        mixin:SetNineSlice(RecruitAFriendFrame.RewardClaiming.Inset)
        mixin:SetNineSlice(RecruitAFriendFrame.RecruitList.ScrollFrameInset)
        mixin:HideTexture(RecruitAFriendFrame.RecruitList.Header.Background)
        mixin:SetAlphaColor(RecruitAFriendFrame.RewardClaiming.Inset.Bg)

     end
     if RaidInfoFrame then--团队信息
        mixin:HideTexture(RaidInfoDetailHeader)
        mixin:SetAlphaColor(RaidInfoFrame.Header.LeftBG)
        mixin:SetAlphaColor(RaidInfoFrame.Header.CenterBG)
        mixin:SetAlphaColor(RaidInfoFrame.Header.RightBG)
        mixin:SetAlphaColor(RaidInfoDetailFooter)
        mixin:SetAlphaColor(RaidInfoFrame.Border.LeftEdge, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.RightEdge, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.TopEdge, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.BottomEdge, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.TopLeftCorner, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.BottomLeftCorner, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.BottomRightCorner, nil, nil, 0.3)
        mixin:SetAlphaColor(RaidInfoFrame.Border.TopRightCorner, nil, nil, 0.3)
        mixin:SetScrollBar(RaidInfoFrame)
        mixin:SetAlphaColor(RaidInfoFrame.Border.Bg, nil, nil, 0.3)
     end

     mixin:SetNineSlice(WhoFrameListInset, true)
     mixin:SetNineSlice(WhoFrameEditBoxInset, true)
     mixin:HideTexture(WhoFrameListInset.Bg)
     mixin:SetScrollBar(WhoFrame)
     mixin:SetMenu(WhoFrameDropdown)
     mixin:SetMenu(FriendsFrameStatusDropdown, {alpha=1})


     mixin:HideTexture(WhoFrameEditBoxInset.Bg)
     mixin:SetScrollBar(QuickJoinFrame)

     for i=1, 4 do
        mixin:SetFrame(_G['FriendsFrameTab'..i], {notAlpha=true})
        mixin:SetFrame(_G['FriendsTabHeaderTab'..i], {notAlpha=true})
        mixin:SetFrame(_G['WhoFrameColumnHeader'..i], {notAlpha=true})
     end


     --聊天设置     
     mixin:SetAlphaColor(ChannelFrameBg)

     mixin:HideTexture(ChannelFrameInset.Bg)
     mixin:HideTexture(ChannelFrame.RightInset.Bg)
     mixin:HideTexture(ChannelFrame.LeftInset.Bg)

     mixin:SetScrollBar(ChannelFrame.ChannelRoster)
     mixin:SetScrollBar(ChannelFrame.ChannelList)

     mixin:SetNineSlice(ChannelFrame)
     mixin:SetNineSlice(ChannelFrameInset)
     mixin:SetNineSlice(ChannelFrame.RightInset)
     mixin:SetNineSlice(ChannelFrame.LeftInset)


     --任务
     mixin:SetButton(QuestFrameCloseButton, {all=true})
     mixin:SetNineSlice(QuestFrame, true)
     mixin:SetAlphaColor(QuestFrameBg)
     mixin:HideTexture(QuestFrameInset.Bg)
     mixin:SetScrollBar(QuestFrame)
     mixin:SetScrollBar(QuestProgressScrollFrame)
     mixin:SetScrollBar(QuestDetailScrollFrame)

     mixin:SetNineSlice(QuestLogPopupDetailFrame, true)
     mixin:SetAlphaColor(QuestLogPopupDetailFrameBg)
     mixin:HideFrame(QuestLogPopupDetailFrameInset)
     mixin:SetScrollBar(QuestLogPopupDetailFrameScrollFrame)
     mixin:SetNineSlice(QuestLogPopupDetailFrameInset, nil, true)

     mixin:SetFrame(QuestModelScene)
     mixin:SetAlphaColor(QuestNPCModelTextFrameBg, nil, nil, 0.3)
     mixin:SetScrollBar(QuestNPCModelTextScrollChildFrame)


     --信箱
     mixin:SetNineSlice(MailFrame, true)
     mixin:SetAlphaColor(MailFrameBg)
     mixin:SetAlphaColor(SendMailMoneyBgRight, nil, nil, 0.3)
     mixin:SetAlphaColor(SendMailMoneyBgLeft, nil, nil, 0.3)
     mixin:SetAlphaColor(SendMailMoneyBgMiddle, nil, nil, 0.3)
     mixin:SetAlphaColor(MailFrameInset.Bg)
     mixin:SetNineSlice(OpenMailFrame, true)
     mixin:SetAlphaColor(OpenMailFrameBg)
     mixin:SetAlphaColor(OpenMailFrameInset.Bg)
     mixin:SetTabButton(MailFrameTab1)
     mixin:SetTabButton(MailFrameTab2)
     mixin:HideTexture(SendMailMoneyInset.Bg)
     mixin:SetNineSlice(MailFrameInset, true)
     mixin:SetScrollBar(SendMailScrollFrame)
     mixin:SetScrollBar(OpenMailScrollFrame)

     --拾取, 历史
     mixin:SetNineSlice(GroupLootHistoryFrame, true)
     mixin:SetAlphaColor(GroupLootHistoryFrameBg)
     mixin:SetScrollBar(GroupLootHistoryFrame)
     mixin:SetAlphaColor(GroupLootHistoryFrameMiddle)
     mixin:SetAlphaColor(GroupLootHistoryFrameLeft)
     mixin:SetAlphaColor(GroupLootHistoryFrameRight)

     mixin:SetFrame(GroupLootHistoryFrame.ResizeButton, {alpha=0.3})




     --频道, 设置
     mixin:SetNineSlice(ChatConfigCategoryFrame,true)
     mixin:SetNineSlice(ChatConfigBackgroundFrame,true)
     mixin:SetNineSlice(ChatConfigChatSettingsLeft, true)
     mixin:HideTexture(ChatConfigBackgroundFrame.NineSlice.Center)
     mixin:HideTexture(ChatConfigCategoryFrame.NineSlice.Center)
     mixin:HideTexture(ChatConfigChatSettingsLeft.NineSlice.Center)

     mixin:SetScrollBar(ChatConfigCombatSettingsFilters)

     mixin:SetAlphaColor(ChatConfigFrame.Border, nil, nil, 0.3)
     mixin:SetAlphaColor(ChatConfigFrame.Header.RightBG, true)
     mixin:SetAlphaColor(ChatConfigFrame.Header.LeftBG, true)
     mixin:SetAlphaColor(ChatConfigFrame.Header.CenterBG, true)


     for i= 1, 5 do
        mixin:SetFrame(_G['CombatConfigTab'..i], {notAlpha=true})
     end

     hooksecurefunc('ChatConfig_CreateCheckboxes', function(frame)--ChatConfigFrame.lua
        mixin:SetNineSlice(frame, nil, true)
        local checkBoxNameString = frame:GetName().."Checkbox"
        local checkBoxName, checkBox
        for index in pairs(frame.checkBoxTable or {}) do
            checkBoxName = checkBoxNameString..index
            checkBox = _G[checkBoxName]
            if checkBox and checkBox.NineSlice then
                mixin:HideTexture(checkBox.NineSlice.TopEdge)
                mixin:HideTexture(checkBox.NineSlice.RightEdge)
                mixin:HideTexture(checkBox.NineSlice.LeftEdge)
                mixin:HideTexture(checkBox.NineSlice.TopRightCorner)
                mixin:HideTexture(checkBox.NineSlice.TopLeftCorner)
                mixin:HideTexture(checkBox.NineSlice.BottomRightCorner)
                mixin:HideTexture(checkBox.NineSlice.BottomLeftCorner)
            end
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

            local checkBox = _G[checkBoxNameString..index]
            if checkBox and checkBox.NineSlice and checkBox.NineSlice.BottomEdge then
                checkBox.NineSlice.BottomEdge:SetVertexColor(r,g,b)
            end
        end
    end)


    hooksecurefunc('ChatConfig_CreateColorSwatches', function(frame)
        local checkBoxNameString = frame:GetName().."Swatch"
        local checkBoxName, checkBox
        for index in pairs(frame.swatchTable or {}) do
            checkBoxName = checkBoxNameString..index
            checkBox = _G[checkBoxName]
            if checkBox and checkBox.NineSlice then
                mixin:HideTexture(checkBox.NineSlice.TopEdge)
                mixin:HideTexture(checkBox.NineSlice.RightEdge)
                mixin:HideTexture(checkBox.NineSlice.LeftEdge)
                mixin:HideTexture(checkBox.NineSlice.TopRightCorner)
                mixin:HideTexture(checkBox.NineSlice.TopLeftCorner)
                mixin:HideTexture(checkBox.NineSlice.BottomRightCorner)
                mixin:HideTexture(checkBox.NineSlice.BottomLeftCorner)
            end
        end
    end)
    hooksecurefunc('ChatConfig_UpdateSwatches', function(frame)
        if ( not FCF_GetCurrentChatFrame() ) then
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

    mixin:SetNineSlice(CombatConfigColorsUnitColors, nil, true)
    mixin:SetNineSlice(CombatConfigColorsHighlighting, nil, true)
    mixin:SetNineSlice(CombatConfigColorsColorizeUnitName, nil, true)
    mixin:SetNineSlice(CombatConfigColorsColorizeSpellNames, nil, true)
    mixin:SetNineSlice(CombatConfigColorsColorizeDamageNumber, nil, true)
    mixin:SetNineSlice(CombatConfigColorsColorizeDamageSchool, nil, true)
    mixin:SetNineSlice(CombatConfigColorsColorizeEntireLine, nil, true)



     --插件，管理
    mixin:SetNineSlice(AddonList,true)
    mixin:SetScrollBar(AddonList)
    mixin:SetAlphaColor(AddonListBg)
    mixin:SetNineSlice(AddonListInset, true)
    mixin:SetAlphaColor(AddonListInset.Bg, nil, nil, 0.3)
    mixin:SetMenu(AddonList.Dropdown)
    mixin:SetEditBox(AddonList.SearchBox)
    mixin:SetButton(AddonListCloseButton, {all=true})

     if MainStatusTrackingBarContainer then--货币，XP，追踪，最下面BAR
         mixin:HideTexture(MainStatusTrackingBarContainer.BarFrameTexture)
     end

     --插件，菜单
     mixin:HideFrame(AddonCompartmentFrame, {alpha= 0.3})
     mixin:SetAlphaColor(AddonCompartmentFrame.Text, nil, nil, 0.3)


     mixin:HideTexture(PlayerFrameAlternateManaBarBorder)
     mixin:HideTexture(PlayerFrameAlternateManaBarLeftBorder)
     mixin:HideTexture(PlayerFrameAlternateManaBarRightBorder)



     --小队，背景
    mixin:SetFrame(PartyFrame.Background, {alpha= 0.3})

     --任务，追踪柆
     mixin:SetAlphaColor(ScenarioObjectiveTracker.StageBlock.NormalBG, nil, nil, 0.3)

     --社交，按钮
     mixin:SetAlphaColor(QuickJoinToastButton.FriendsButton, nil, nil, 0.5)
     mixin:SetFrame(ChatFrameChannelButton, {alpha= 0.5})
     mixin:SetFrame(ChatFrameMenuButton, {alpha= 0.5})
     mixin:SetFrame(TextToSpeechButton, {alpha= 0.5})


    for i=1, NUM_CHAT_WINDOWS do
    local frame= _G["ChatFrame"..i]
    if frame then
        mixin:SetAlphaColor(_G['ChatFrame'..i..'EditBoxMid'], nil, nil, 0.3)
        mixin:SetAlphaColor(_G['ChatFrame'..i..'EditBoxLeft'], nil, nil, 0.3)
        mixin:SetAlphaColor(_G['ChatFrame'..i..'EditBoxRight'], nil, nil, 0.3)
        mixin:SetScrollBar(frame)
        mixin:SetFrame(frame.ScrollToBottomButton, {notAlpha=true})
    end
    end
    mixin:SetEditBox(ChatFrame1EditBox)





     C_Timer.After(2, function()

        WoWTools_TextureMixin:HideTexture(SpellFlyout.Background.Start)
        WoWTools_TextureMixin:HideTexture(SpellFlyout.Background.End)
        WoWTools_TextureMixin:HideTexture(SpellFlyout.Background.HorizontalMiddle)
        WoWTools_TextureMixin:HideTexture(SpellFlyout.Background.VerticalMiddle)


--商人, SellBuy.lua
         for i=1, math.max(MERCHANT_ITEMS_PER_PAGE, BUYBACK_ITEMS_PER_PAGE) do --MERCHANT_ITEMS_PER_PAGE = 10 BUYBACK_ITEMS_PER_PAGE = 12
             mixin:SetAlphaColor(_G['MerchantItem'..i..'SlotTexture'])
         end
         mixin:HideTexture(MerchantBuyBackItemSlotTexture)
     end)

     mixin:SetAlphaColor(StackSplitFrame.SingleItemSplitBackground, true)
     mixin:SetAlphaColor(StackSplitFrame.MultiItemSplitBackground, true)
     mixin:HideFrame(MerchantRepairItemButton, {index=1})
     mixin:HideFrame(MerchantRepairAllButton, {index=1})
     mixin:HideFrame(MerchantGuildBankRepairButton, {index=1})
     mixin:HideFrame(MerchantSellAllJunkButton, {index=1})


    --考古学 ArchaeologyProgressBar.xml
    if ArcheologyDigsiteProgressBar then
        mixin:SetAlphaColor(ArcheologyDigsiteProgressBar.BarBorderAndOverlay, true)
        mixin:HideTexture(ArcheologyDigsiteProgressBar.Shadow)
        --ArcheologyDigsiteProgressBar.BarTitle:SetTextColor(WoWTools_DataMixin.Player.r, WoWTools_DataMixin.Player.g, WoWTools_DataMixin.Player.b)
        ArcheologyDigsiteProgressBar.BarTitle:SetShadowOffset(1, -1)
        mixin:HideTexture(ArcheologyDigsiteProgressBar.BarBackground)
    end







    --颜色
    --mixin:SetFrame(ColorPickerFrame.Header, {alpha= 0.3})
    --mixin:SetFrame(ColorPickerFrame.Border, {alpha= 0.3})

    --编辑模式
    mixin:SetButton(EditModeManagerFrame.CloseButton, {all=true})
    mixin:SetScrollBar(EditModeManagerFrame.AccountSettings.SettingsContainer)
    mixin:SetFrame(EditModeManagerFrame.Border, {alpha=0.3})
    mixin:SetFrame(EditModeManagerFrame.AccountSettings.SettingsContainer.BorderArt, {alpha=0.3})
    mixin:SetSlider(EditModeManagerFrame.GridSpacingSlider)

    mixin:SetFrame(BNToastFrame, {alpha=0.3})



    --ReportFrame
    mixin:SetFrame(ReportFrame)
    mixin:SetFrame(ReportFrame.Border)
    mixin:HideTexture(ReportFrame.BottomInset)
    mixin:HideTexture(ReportFrame.TopInset)
    mixin:SetFrame(ReportFrame.CloseButton, {notAlpha=true})

    mixin:SetScrollBar(ReportFrame.Comment)

    mixin:SetFrame(BattleTagInviteFrame.Border, {notAlpha=true})

    --就绪
    mixin:SetNineSlice(ReadyCheckListenerFrame, true)
    mixin:SetAlphaColor(ReadyCheckListenerFrame.Bg, true)

    --团队 RolePoll.lua
    mixin:SetFrame(RolePollPopup.Border, {notAlpha=true})

    --对话框
    mixin:SetFrame(StaticPopup1.Border, {notAlpha=true})
    mixin:SetAlphaColor(StaticPopup1.Border.Bg, true)

    --ItemTextFrame
    mixin:SetNineSlice(ItemTextFrame, true)
    mixin:HideTexture(ItemTextFrameBg)
    mixin:HideFrame(ItemTextFrameInset)
    mixin:SetAlphaColor(ItemTextMaterialTopLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(ItemTextMaterialTopRight, nil, nil, 0.3)
    mixin:SetAlphaColor(ItemTextMaterialBotLeft, nil, nil, 0.3)
    mixin:SetAlphaColor(ItemTextMaterialBotRight, nil, nil, 0.3)
    mixin:SetScrollBar(ItemTextScrollFrame)
    mixin:SetNineSlice(ItemTextFrameInset, true)

    --试衣间
    mixin:SetNineSlice(DressUpFrame, true)
    mixin:SetAlphaColor(DressUpFrameBg)
    mixin:HideTexture(DressUpFrameInset.Bg)
    mixin:SetFrame(DressUpFrameInset)
    mixin:SetAlphaColor(DressUpFrame.ModelBackground, nil, nil, 0.3)
    mixin:SetFrame(DressUpFrame.OutfitDetailsPanel, {alpha=0.3})
    mixin:SetAlphaColor(DressUpFrame.OutfitDetailsPanel.BlackBackground)

    Init=function()end
end



















function WoWTools_TextureMixin:Init_All_Frame()
    Init(self)
end