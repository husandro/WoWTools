
 --公会和社区 Blizzard_Communities
 function WoWTools_TextureMixin.Events:Blizzard_Communities()
    self:SetButton(CommunitiesFrameCloseButton)
    self:SetButton(CommunitiesFrame.MaximizeMinimizeFrame.MinimizeButton)
    self:SetButton(CommunitiesFrame.MaximizeMinimizeFrame.MaximizeButton)

    --self:SetNineSlice(CommunitiesFrame, true)

    self:SetScrollBar(CommunitiesFrame.Chat)
    self:SetNineSlice(CommunitiesFrame.Chat.InsetFrame)
    self:CreateBG(CommunitiesFrame.Chat, {isAllPoint=true, isColor=true})
--新闻过滤
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameNews)
    self:SetBG(CommunitiesFrameGuildDetailsFrameNews)

    self:SetNineSlice(CommunitiesFrameInset)

    self:SetEditBox(CommunitiesFrame.ChatEditBox)
    self:SetAlphaColor(CommunitiesFrameMiddle)

--公会和社区，列表
    self:HideTexture(CommunitiesFrameCommunitiesList.Bg)
    self:SetNineSlice(CommunitiesFrameCommunitiesList.InsetFrame, nil, true)
    self:SetScrollBar(CommunitiesFrameCommunitiesList)
    self:HideFrame(CommunitiesFrameCommunitiesList.FilligreeOverlay)
    self:HideTexture(CommunitiesFrameCommunitiesList.TopFiligree)
    self:HideTexture(CommunitiesFrameCommunitiesList.BottomFiligree)

    hooksecurefunc(CommunitiesListEntryMixin, 'Init', function(frame, data)
        self:SetAlphaColor(frame.Background, 1, true)
    end)

    self:HideFrame(CommunitiesFrame.ChatTab, {index=1})
    self:HideFrame(CommunitiesFrame.RosterTab, {index=1})
    self:HideFrame(CommunitiesFrame.GuildBenefitsTab, {index=1})
    self:HideFrame(CommunitiesFrame.GuildInfoTab, {index=1})
    WoWTools_ButtonMixin:AddMask(CommunitiesFrame.ChatTab, true)
    WoWTools_ButtonMixin:AddMask(CommunitiesFrame.RosterTab, true)
    WoWTools_ButtonMixin:AddMask(CommunitiesFrame.GuildBenefitsTab, true)
    WoWTools_ButtonMixin:AddMask(CommunitiesFrame.GuildInfoTab, true)

    self:SetFrame(CommunitiesFrame.AddToChatButton, {notAlpha=true})

    self:SetFrame(CommunitiesFrame.NotificationSettingsDialog.Selector)
    self:SetScrollBar(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame)
    self:SetAlphaColor(CommunitiesFrame.NotificationSettingsDialog.BG, {notAlpha=true})

--成员，列表
    self:SetNineSlice(CommunitiesFrame.MemberList.InsetFrame)
    self:HideFrame(CommunitiesFrame.MemberList.ColumnDisplay)
    self:SetScrollBar(CommunitiesFrame.MemberList)
    self:CreateBG(CommunitiesFrame.MemberList, {isAllPoint=true})


--成员,叙述
    self:SetNineSlice(CommunitiesFrame.GuildMemberDetailFrame.Border, 1)
    self:SetButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)


--公会奖励，列表, 物品，GuildRewards.lua
    self:HideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)
    self:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards)
    CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
    self:HideFrame(CommunitiesFrame.GuildBenefitsFrame)
    self:HideTexture(CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.BG)

    hooksecurefunc(CommunitiesGuildRewardsButtonMixin, 'Init', function(f)
        self:SetBG(f)
    end)
    --hooksecurefunc(CommunitiesGuildRewardsButtonMixin, 'Init', function(btn)
    --CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetPoint('BOTTOM')
    --CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAtlas('ChallengeMode-guild-background')
    --CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAlpha(0.3)


    --


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
    self:SetAllFrames(TabardFrame, {
        frames={TabardFrameCustomizationFrame},
        bg=true,
    })
    for i=1, 5 do
        self:HideTexture(_G['TabardFrameCustomization'..i..'Middle'])
        self:HideTexture(_G['TabardFrameCustomization'..i..'Left'])
        self:HideTexture(_G['TabardFrameCustomization'..i..'Right'])
        self:SetButton(_G['TabardFrameCustomization'..i..'LeftButton'], {alpha=0.75})
        self:SetButton(_G['TabardFrameCustomization'..i..'RightButton'], {alpha=0.75})
    end
    self:SetButton(TabardCharacterModelRotateLeftButton)
    self:SetButton(TabardCharacterModelRotateRightButton)

    
    --self:SetButton(TabardFrameCloseButton)
    

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
    self:SetNineSlice(CommunitiesGuildTextEditFrame.Container, nil, true)
    self:SetScrollBar(CommunitiesGuildTextEditFrame.Container.ScrollFrame)

--查看日志，记录
    self:SetFrame(CommunitiesGuildLogFrame)
    self:SetNineSlice(CommunitiesGuildLogFrame.Container, nil, true)
    self:SetScrollBar(CommunitiesGuildLogFrame.Container.ScrollFrame)


--新闻过滤
    self:SetFrame(CommunitiesGuildNewsFiltersFrame, {isMinAlpha=true})

--寻找社区
    self:SetScrollBar(ClubFinderCommunityAndGuildFinderFrame.CommunityCards)
    self:SetEditBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)
    self:SetNineSlice(ClubFinderCommunityAndGuildFinderFrame.InsetFrame)
    self:SetMenu(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SortByDropdown)
    self:SetAlphaColor(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.Bg)
    self:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, {index=1})
    self:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, {index=1})

--公会查找器
    self:HideTexture(ClubFinderGuildFinderFrame.InsetFrame.Bg)
    self:SetNineSlice(ClubFinderGuildFinderFrame.InsetFrame)
    self:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubFilterDropdown)
    self:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubSizeDropdown)
    self:SetEditBox(ClubFinderGuildFinderFrame.OptionsList.SearchBox)


    self:HideTexture(CommunitiesFrame.TopTileStreaks)

    self:HideTexture(CommunitiesFrameInset.Bg)

   self:HideTexture(CommunitiesFrameBg)

--BG
    self:Init_BGMenu_Frame(CommunitiesFrame)
end