
 --公会和社区 Blizzard_Communities
 function WoWTools_TextureMixin.Events:Blizzard_Communities()
    self:SetButton(CommunitiesFrameCloseButton, {all=true})
    self:SetButton(CommunitiesFrame.MaximizeMinimizeFrame.MinimizeButton, {all=true})
    self:SetButton(CommunitiesFrame.MaximizeMinimizeFrame.MaximizeButton, {all=true})

    self:SetNineSlice(CommunitiesFrame, true)

    self:SetScrollBar(CommunitiesFrame.Chat)


    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameNews)





    self:SetNineSlice(CommunitiesFrameInset, nil, true)



    CommunitiesFrameGuildDetailsFrameNews:DisableDrawLayer('BACKGROUND')

    self:SetEditBox(CommunitiesFrame.ChatEditBox)
    self:SetNineSlice(CommunitiesFrame.Chat.InsetFrame, nil, true)
    self:SetAlphaColor(CommunitiesFrameMiddle)



--公会和社区，列表
    self:HideTexture(CommunitiesFrameCommunitiesList.Bg)
    self:SetNineSlice(CommunitiesFrameCommunitiesList.InsetFrame, nil, true)
    self:SetScrollBar(CommunitiesFrameCommunitiesList)
    self:HideFrame(CommunitiesFrameCommunitiesList.FilligreeOverlay)
    self:HideTexture(CommunitiesFrameCommunitiesList.TopFiligree)
    self:HideTexture(CommunitiesFrameCommunitiesList.BottomFiligree)

    hooksecurefunc(CommunitiesListEntryMixin, 'Init', function(frame, data)
        self:SetAlphaColor(frame.Background, nil, nil, true)
    end)


    self:HideFrame(CommunitiesFrame.ChatTab, {index=1})
    self:HideFrame(CommunitiesFrame.RosterTab, {index=1})
    self:HideFrame(CommunitiesFrame.GuildBenefitsTab, {index=1})
    self:HideFrame(CommunitiesFrame.GuildInfoTab, {index=1})

    self:SetFrame(CommunitiesFrame.AddToChatButton, {notAlpha=true})



    self:SetFrame(CommunitiesFrame.NotificationSettingsDialog.Selector)
    self:SetScrollBar(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame)
    self:SetAlphaColor(CommunitiesFrame.NotificationSettingsDialog.BG, {notAlpha=true})


--成员，列表
    self:SetNineSlice(CommunitiesFrame.MemberList.InsetFrame, nil, true)
    self:HideFrame(CommunitiesFrame.MemberList.ColumnDisplay)
    self:SetScrollBar(CommunitiesFrame.MemberList)


--公会奖励，列表
    self:HideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)
    self:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards)
    CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
    self:HideFrame(CommunitiesFrame.GuildBenefitsFrame)



--公会设置
    self:SetFrame(GuildControlUI)
    self:SetFrame(GuildControlUIHbar)
    self:SetMenu(GuildControlUINavigationDropdown)
    self:SetMenu(GuildControlUIRankBankFrameRankDropdown)
    self:SetInset(GuildControlUIRankBankFrameInset)
    self:SetScrollBar(GuildControlUIRankBankFrameInsetScrollFrame)
    self:SetMenu(GuildControlUIRankSettingsFrameRankDropdown)


--新建，公会, 签名
    self:SetAlphaColor(PetitionFrame.Bg, nil, true, true)
    self:SetNineSlice(PetitionFrame)
    self:SetAlphaColor(PetitionFrameBg, nil, nil,true)
    self:HideTexture(PetitionFrameInset.Bg)
    self:SetInset(PetitionFrameInset)
    self:SetNineSlice(PetitionFrameInset)
    self:SetScrollBar(PetitionFrame)

--公会，可以使用的服务
    self:SetNineSlice(GuildRegistrarFrame)
    self:SetAlphaColor(GuildRegistrarFrameBg, nil, nil,true)
    self:HideTexture(GuildRegistrarFrameInset.Bg)
    self:SetInset(GuildRegistrarFrameInset)
    self:SetNineSlice(GuildRegistrarFrameInset)
    self:SetScrollBar(GuildRegistrarFrame)

--设计，公会战袍
    --self:SetNineSlice(TabardFrameInset)
    TabardFrameInset:Hide()
    self:SetNineSlice(TabardFrame)
    TabardFrameBg:SetAtlas('ChallengeMode-guild-background')

    self:SetAlphaColor(TabardFrameBg, nil, nil, true)

    self:HideTexture(TabardFrameMoneyBgMiddle)
    self:HideTexture(TabardFrameMoneyBgLeft)
    self:HideTexture(TabardFrameMoneyBgRight)
    self:HideTexture(TabardFrameMoneyInset.Bg)

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


    self:SetButton(TabardCharacterModelRotateLeftButton, {alpha=0.5})
    self:SetButton(TabardCharacterModelRotateRightButton, {alpha=0.5})

--信息
    self:SetFrame(CommunitiesFrameGuildDetailsFrameInfo, {isMinAlpha=true})
    CommunitiesFrameGuildDetailsFrameInfo:DisableDrawLayer('BACKGROUND')
    self:SetFrame(CommunitiesFrameGuildDetailsFrame, {isMinAlpha=true})
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame)
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame)
    --CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('BOTTOMRIGHT')

--公会信息， 点击以编辑
    --CommunitiesGuildTextEditFrame
    self:SetFrame(CommunitiesGuildTextEditFrame, {isMinAlpha=true})
    self:SetNineSlice(CommunitiesGuildTextEditFrame.Container, nil, nil, nil, true)
    self:SetScrollBar(CommunitiesGuildTextEditFrame.Container.ScrollFrame)

--查看日志，记录
    self:SetFrame(CommunitiesGuildLogFrame)
    self:SetNineSlice(CommunitiesGuildLogFrame.Container, nil, nil, nil, true)
    self:SetScrollBar(CommunitiesGuildLogFrame.Container.ScrollFrame)


--新闻过滤
    self:SetFrame(CommunitiesGuildNewsFiltersFrame, {isMinAlpha=true})

--寻找社区
    self:SetScrollBar(ClubFinderCommunityAndGuildFinderFrame.CommunityCards)
    self:SetEditBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)
    self:SetNineSlice(ClubFinderCommunityAndGuildFinderFrame.InsetFrame, nil, true)
    self:SetMenu(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SortByDropdown)
    self:SetAlphaColor(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.Bg)
    self:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, {index=1})
    self:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, {index=1})

--公会查找器
    self:HideTexture(ClubFinderGuildFinderFrame.InsetFrame.Bg)
    self:SetNineSlice(ClubFinderGuildFinderFrame.InsetFrame, nil, true)
    self:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubFilterDropdown)
    self:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubSizeDropdown)
    self:SetEditBox(ClubFinderGuildFinderFrame.OptionsList.SearchBox)


    self:HideTexture(CommunitiesFrame.TopTileStreaks)

    self:HideTexture(CommunitiesFrameInset.Bg)

   self:SetAlphaColor(CommunitiesFrameBg, nil, nil, 0.3)

--BG
    WoWTools_TextureMixin:Init_BGMenu_Frame(
    CommunitiesFrame,--框架, frame.PortraitContainer
    'CommunitiesFrame',--名称
    nil,--CommunitiesFrameInset.Bg,--Texture
    {
    isAddBg=true,--是否添加背景
    }
)
end