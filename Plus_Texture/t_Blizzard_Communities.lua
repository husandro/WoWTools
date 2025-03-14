
 --公会和社区 Blizzard_Communities
 function WoWTools_TextureMixin.Events:Blizzard_Communities(mixin)--成就
    mixin:SetNineSlice(CommunitiesFrame, true)
    mixin:SetScrollBar(CommunitiesFrameCommunitiesList)
    mixin:SetScrollBar(CommunitiesFrame.Chat)
    mixin:SetScrollBar(CommunitiesFrame.MemberList)
    mixin:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards)
    mixin:SetScrollBar(CommunitiesFrameGuildDetailsFrameNews)
    mixin:SetScrollBar(ClubFinderCommunityAndGuildFinderFrame.CommunityCards)

    mixin:SetAlphaColor(CommunitiesFrameBg)
    mixin:SetAlphaColor(CommunitiesFrame.MemberList.ColumnDisplay.Background)
    mixin:SetAlphaColor(CommunitiesFrameCommunitiesList.Bg)
    mixin:SetAlphaColor(CommunitiesFrameInset.Bg, nil, nil, 0.3)
    mixin:SetNineSlice(CommunitiesFrameInset, nil, true)
    mixin:SetNineSlice(CommunitiesFrameCommunitiesList.InsetFrame, true)
    CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
    
    CommunitiesFrameGuildDetailsFrameNews:DisableDrawLayer('BACKGROUND')

    mixin:SetSearchBox(CommunitiesFrame.ChatEditBox)
    mixin:SetNineSlice(CommunitiesFrame.Chat.InsetFrame, true)
    mixin:SetNineSlice(CommunitiesFrame.MemberList.InsetFrame, true)
    mixin:SetAlphaColor(CommunitiesFrameMiddle)

    mixin:SetNineSlice(ClubFinderCommunityAndGuildFinderFrame.InsetFrame, nil, true)
    mixin:SetMenu(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SortByDropdown)
    mixin:HideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)

    hooksecurefunc(CommunitiesFrameCommunitiesList,'UpdateCommunitiesList',function()
        C_Timer.After(0.3, function()
             local frame= CommunitiesFrameCommunitiesList.ScrollBox
            if not frame or not frame:GetView() then
                return
            end
            for _, button in pairs(frame:GetFrames() or {}) do
                mixin:SetAlphaColor(button.Background)
            end
        end)
    end)

    mixin:SetAlphaColor(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.Bg)

    mixin:HideFrame(CommunitiesFrame.ChatTab, {index=1})
    mixin:HideFrame(CommunitiesFrame.RosterTab, {index=1})
    mixin:HideFrame(CommunitiesFrame.GuildBenefitsTab, {index=1})
    mixin:HideFrame(CommunitiesFrame.GuildInfoTab, {index=1})

    mixin:SetFrame(CommunitiesFrame.AddToChatButton, {notAlpha=true})

    mixin:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, {index=1})
    mixin:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, {index=1})

    mixin:SetAlphaColor(ClubFinderGuildFinderFrame.InsetFrame.Bg)

    mixin:SetFrame(CommunitiesFrame.NotificationSettingsDialog.Selector)
    mixin:SetScrollBar(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame)
    mixin:SetAlphaColor(CommunitiesFrame.NotificationSettingsDialog.BG, {notAlpha=true})

--公会设置
    mixin:SetFrame(GuildControlUI)
    mixin:SetFrame(GuildControlUIHbar)
    mixin:SetMenu(GuildControlUINavigationDropdown)
    mixin:SetMenu(GuildControlUIRankBankFrameRankDropdown)
    mixin:SetInset(GuildControlUIRankBankFrameInset)
    mixin:SetScrollBar(GuildControlUIRankBankFrameInsetScrollFrame)
    mixin:SetMenu(GuildControlUIRankSettingsFrameRankDropdown)



    mixin:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubFilterDropdown)
    mixin:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubSizeDropdown)


--霸业风暴商店
    if AccountStoreFrame then
        mixin:HideTexture(AccountStoreFrame.LeftInset.Bg)
        mixin:HideTexture(AccountStoreFrame.RightInset.Bg)
        mixin:SetFrame(AccountStoreFrame.LeftDisplay, {alpha=0.3})
        mixin:HideTexture(AccountStoreFrameBg)

        mixin:SetNineSlice(AccountStoreFrame)
        mixin:SetScrollBar(AccountStoreFrame.CategoryList)
        mixin:SetInset(AccountStoreFrame.RightInset)
        mixin:SetInset(AccountStoreFrame.LeftInset)
    end

--新建，公会, 签名
    mixin:SetAlphaColor(PetitionFrame.Bg, nil, true, true)
    mixin:SetNineSlice(PetitionFrame)
    mixin:SetAlphaColor(PetitionFrameBg, nil, nil,true)
    mixin:HideTexture(PetitionFrameInset.Bg)
    mixin:SetInset(PetitionFrameInset)
    mixin:SetNineSlice(PetitionFrameInset)
    mixin:SetScrollBar(PetitionFrame)

--公会，可以使用的服务
    mixin:SetNineSlice(GuildRegistrarFrame)
    mixin:SetAlphaColor(GuildRegistrarFrameBg, nil, nil,true)
    mixin:HideTexture(GuildRegistrarFrameInset.Bg)
    mixin:SetInset(GuildRegistrarFrameInset)
    mixin:SetNineSlice(GuildRegistrarFrameInset)
    mixin:SetScrollBar(GuildRegistrarFrame)
    
--设计，公会战袍
    --mixin:SetNineSlice(TabardFrameInset)
    TabardFrameInset:Hide()
    mixin:SetNineSlice(TabardFrame)
    TabardFrameBg:SetAtlas('UI-Frame-DialogBox-BackgroundTile')

    mixin:SetAlphaColor(TabardFrameBg, nil, nil, true)

    mixin:HideTexture(TabardFrameMoneyBgMiddle)
    mixin:HideTexture(TabardFrameMoneyBgLeft)
    mixin:HideTexture(TabardFrameMoneyBgRight)
    mixin:HideTexture(TabardFrameMoneyInset.Bg)

    TabardFrameMoneyInset.NineSlice:Hide()
    TabardFrameCostFrame.NineSlice:Hide()
    TabardFrameOuterFrameTopLeft:Hide()
    TabardFrameOuterFrameTopRight:Hide()
    TabardFrameOuterFrameBottomLeft:Hide()
    TabardFrameOuterFrameBottomRight:Hide()
    TabardFrameOuterFrameLeftTop:Hide()
    TabardFrameOuterFrameLeftBottom:Hide()
    TabardFrameOuterFrameRightTop:Hide()
    TabardFrameOuterFrameRightBottom:Hide()
    TabardFrameOuterFrameBottom:Hide()
    TabardFrameOuterFrameTop:Hide()

    TabardFrameCustomization1Middle:Hide()
    TabardFrameCustomization1Left:Hide()
    TabardFrameCustomization1Right:Hide()

    TabardFrameCustomization2Middle:Hide()
    TabardFrameCustomization2Left:Hide()
    TabardFrameCustomization2Right:Hide()

    TabardFrameCustomization3Middle:Hide()
    TabardFrameCustomization3Left:Hide()
    TabardFrameCustomization3Right:Hide()

    TabardFrameCustomization4Middle:Hide()
    TabardFrameCustomization4Left:Hide()
    TabardFrameCustomization4Right:Hide()

    TabardFrameCustomization5Middle:Hide()
    TabardFrameCustomization5Left:Hide()
    TabardFrameCustomization5Right:Hide()


    mixin:SetButton(TabardCharacterModelRotateLeftButton, {alpha=0.5})
    mixin:SetButton(TabardCharacterModelRotateRightButton, {alpha=0.5})

--信息
    mixin:SetFrame(CommunitiesFrameGuildDetailsFrameInfo, {isMinAlpha=true})
    CommunitiesFrameGuildDetailsFrameInfo:DisableDrawLayer('BACKGROUND')
    mixin:SetFrame(CommunitiesFrameGuildDetailsFrame, {isMinAlpha=true})
    mixin:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame)
    mixin:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame)

--公会信息， 点击以编辑
    --CommunitiesGuildTextEditFrame
    mixin:SetFrame(CommunitiesGuildTextEditFrame, {isMinAlpha=true})
    mixin:SetNineSlice(CommunitiesGuildTextEditFrame.Container, nil, nil, nil, true)
    mixin:SetScrollBar(CommunitiesGuildTextEditFrame.Container.ScrollFrame)

--查看日志，记录
    mixin:SetFrame(CommunitiesGuildLogFrame)
    mixin:SetNineSlice(CommunitiesGuildLogFrame.Container, nil, nil, nil, true)
    mixin:SetScrollBar(CommunitiesGuildLogFrame.Container.ScrollFrame)
end