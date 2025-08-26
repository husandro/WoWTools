
function WoWTools_TooltipMixin.Events:Blizzard_Communities()
    hooksecurefunc(CommunitiesAvatarButtonMixin, 'Init', function(btn)
        if not btn.Name then
            btn.Name= WoWTools_LabelMixin:Create(btn, {mouse=true})
            btn.Name:SetPoint('BOTTOM')
            btn.Name:SetScript('OnLeave', function(b)
                b:SetAlpha(1)
                GameTooltip:Hide()
            end)
            btn.Name:SetScript('OnEnter', function(b)
                GameTooltip:SetOwner(b, 'ANCHOR_LEFT')
                GameTooltip:SetText(WoWTools_DataMixin.Icon.icon2..'avatarId')
                GameTooltip:Show()
                b:SetAlpha(0.5)
            end)
        end
        btn.Name:SetText(btn.avatarId or '')
    end)
end




function WoWTools_TextureMixin.Events:Blizzard_GuildRename()--11.1.5
    self:SetNineSlice(GuildRenameFrame)
    self:SetAlphaColor(GuildRenameFrameBg, nil, nil, true)
    self:HideTexture(GuildRenameFrameInset.Bg)
    --self:SetInset(GuildRenameFrameInset)
    self:SetNineSlice(GuildRenameFrameInset)
end





 --公会和社区 Blizzard_Communities
 function WoWTools_TextureMixin.Events:Blizzard_Communities()
    self:SetButton(CommunitiesFrameCloseButton)
    self:SetButton(CommunitiesFrame.MaximizeMinimizeFrame.MinimizeButton)
    self:SetButton(CommunitiesFrame.MaximizeMinimizeFrame.MaximizeButton)

    --self:SetNineSlice(CommunitiesFrame, true)

    self:SetScrollBar(CommunitiesFrame.Chat, true)
    self:SetNineSlice(CommunitiesFrame.Chat.InsetFrame)
    self:CreateBG(CommunitiesFrame.Chat, {isAllPoint=true, isColor=true})
--新闻过滤
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameNews, true)
    self:SetBG(CommunitiesFrameGuildDetailsFrameNews)

    self:SetNineSlice(CommunitiesFrameInset)

    self:SetEditBox(CommunitiesFrame.ChatEditBox)
    self:SetAlphaColor(CommunitiesFrameMiddle)

--公会和社区，列表
    self:HideTexture(CommunitiesFrameCommunitiesList.Bg)
    self:SetNineSlice(CommunitiesFrameCommunitiesList.InsetFrame, nil, true)
    self:SetScrollBar(CommunitiesFrameCommunitiesList, true)
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
    self:SetScrollBar(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame, true)
    self:SetAlphaColor(CommunitiesFrame.NotificationSettingsDialog.BG, {notAlpha=true})

--成员，列表
    self:SetNineSlice(CommunitiesFrame.MemberList.InsetFrame)
    self:HideFrame(CommunitiesFrame.MemberList.ColumnDisplay)
    self:SetScrollBar(CommunitiesFrame.MemberList, true)
    self:CreateBG(CommunitiesFrame.MemberList, {isAllPoint=true})


--成员,叙述 CommunitiesGuildMemberDetailMixin
    self:SetFrame(CommunitiesFrame.GuildMemberDetailFrame.Border, {alpha=1})
    self:SetButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)
    self:SetNineSlice(CommunitiesFrame.GuildMemberDetailFrame.NoteBackground, 0.5)
    self:SetMenu(CommunitiesFrame.GuildMemberDetailFrame.RankDropdown)
    self:SetNineSlice(CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground, 0.5)


--公会奖励，列表, 物品，GuildRewards.lua
    self:HideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)
    self:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards, true)
    CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
    self:HideFrame(CommunitiesFrame.GuildBenefitsFrame)
    self:HideTexture(CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.BG)
    self:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBar, true)

    hooksecurefunc(CommunitiesGuildRewardsButtonMixin, 'Init', function(f)
        self:SetBG(f)
    end)
    

--角色名称邀请你加入
    self:SetNineSlice(CommunitiesFrame.ClubFinderInvitationFrame.InsetFrame)


--公会设置
    self:SetFrame(GuildControlUI)
    self:SetFrame(GuildControlUIHbar)
    self:SetMenu(GuildControlUINavigationDropdown)
    self:SetMenu(GuildControlUIRankBankFrameRankDropdown)
    self:SetInset(GuildControlUIRankBankFrameInset)
    self:SetScrollBar(GuildControlUIRankBankFrameInsetScrollFrame, true)
    self:SetMenu(GuildControlUIRankSettingsFrameRankDropdown)


--新建，公会, 签名
    self:SetAlphaColor(PetitionFrame.Bg, nil, true, true)
    self:SetNineSlice(PetitionFrame)
    self:SetAlphaColor(PetitionFrameBg, nil, nil,true)
    self:HideTexture(PetitionFrameInset.Bg)
    self:SetInset(PetitionFrameInset)
    self:SetNineSlice(PetitionFrameInset)
    self:SetScrollBar(PetitionFrame, true)



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
    self:SetFrame(CommunitiesFrameGuildDetailsFrameInfo)
    CommunitiesFrameGuildDetailsFrameInfo:DisableDrawLayer('BACKGROUND')
    self:SetFrame(CommunitiesFrameGuildDetailsFrame)
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame, true)
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, true)
    --CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('BOTTOMRIGHT')

--公会信息， 点击以编辑
    --CommunitiesGuildTextEditFrame
    self:SetFrame(CommunitiesGuildTextEditFrame)
    self:SetNineSlice(CommunitiesGuildTextEditFrame.Container, nil, true)
    self:SetScrollBar(CommunitiesGuildTextEditFrame.Container.ScrollFrame, true)

--查看日志，记录
    self:SetFrame(CommunitiesGuildLogFrame)
    self:SetFrame(CommunitiesGuildLogFrameCloseButton)
    self:SetNineSlice(CommunitiesGuildLogFrame.Container, nil, true)
    self:SetScrollBar(CommunitiesGuildLogFrame.Container.ScrollFrame, true)


--新闻过滤
    self:SetFrame(CommunitiesGuildNewsFiltersFrame)
    self:SetButton(CommunitiesGuildNewsFiltersFrame.CloseButton)

--寻找社区
    self:SetScrollBar(ClubFinderCommunityAndGuildFinderFrame.CommunityCards, true)
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

--这个会，弹出菜单
    CommunitiesFrame.CommunitiesListDropdown:SetFrameStrata('HIGH')

--BG
    self:Init_BGMenu_Frame(CommunitiesFrame)
end











































--公会和社区
function WoWTools_MoveMixin.Events:Blizzard_Communities()--公会和社区


    local function set_size(frame)
        frame= frame:GetParent()
        if WoWTools_FrameMixin:IsLocked(frame) then
            return
        end

        local size, scale
        local displayMode = frame:GetDisplayMode();
        if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
            frame.ResizeButton.minWidth= 290
            frame.ResizeButton.minHeight= 115
            size= self:Save().size['CommunitiesFrameMINIMIZED']
            scale= self:Save().scale['CommunitiesFrameMINIMIZED']
        else
            size= self:Save().size['CommunitiesFrameNormal']
            scale= self:Save().scale['CommunitiesFrameNormal']
            frame.ResizeButton.minWidth= 562--814
            frame.ResizeButton.minHeight= 228--426
        end

        if size then
            frame:SetSize(size[1], size[2])
        end
        if scale then
            frame:SetScale(scale)
        end
    end




    --hooksecurefunc(ClubFinderCommunitiesCardMixin, 'Init', function(b)
    local function Init_Update(frame)
        if not frame:GetView() or WoWTools_FrameMixin:IsLocked(frame) then
            return
        end
        for _, btn in pairs(frame:GetFrames() or {}) do
            btn.Name:ClearAllPoints()
            btn.Name:SetPoint('TOPLEFT', btn.LogoBorder, 'TOPRIGHT', 12,0)
            btn.Description:ClearAllPoints()
            btn.Description:SetPoint('LEFT', btn.LogoBorder, 'RIGHT', 12,0)
            btn.Description:SetPoint('RIGHT', btn.RequestJoin, 'LEFT', -26,0)
            btn.Background:SetPoint('RIGHT', -12,0)--移动背景
            local cardInfo= btn.cardInfo-- or {}-- clubFinderGUID, isCrossFaction, clubId, 

            if not btn.corssFactionTexture and cardInfo.isCrossFaction then--跨阵营
                btn.corssFactionTexture= btn:CreateTexture(nil, 'OVERLAY')
                btn.corssFactionTexture:SetSize(18,18)
                btn.corssFactionTexture:SetAtlas('CrossedFlags')
                btn.corssFactionTexture:SetPoint('LEFT', btn.MemberIcon, 'RIGHT', 4, 0)
            end
            if btn.corssFactionTexture then
                btn.corssFactionTexture:SetShown(true)--not cardInfo.isCrossFaction)
            end
            local autoAccept--自动，批准, 无效
            local clubStatus= cardInfo.clubFinderGUID and C_ClubFinder.GetPlayerClubApplicationStatus(cardInfo.clubFinderGUID)
            btn:SetAlpha(btn.RequestJoin:IsShown() and 1 or 0.3)
            if clubStatus then
                autoAccept= clubStatus== Enum.PlayerClubRequestStatus.AutoApproved--2
            end
            if not btn.autoAcceptTexture and autoAccept then
                btn.autoAcceptTexture= btn:CreateTexture(nil, 'OVERLAY')
                btn.autoAcceptTexture:SetSize(18,18)
                btn.autoAcceptTexture:SetAtlas('common-icon-checkmark')
                btn.autoAcceptTexture:SetPoint('LEFT', btn.MemberIcon, 'RIGHT', 24, 0)
            end
            if btn.autoAcceptTexture then
                btn.autoAcceptTexture:SetShown(autoAccept)
            end
        end
    end






    local sub


    hooksecurefunc(CommunitiesFrame.MaxMinButtonFrame, 'Minimize', set_size)--maximizedCallback
    hooksecurefunc(CommunitiesFrame.MaxMinButtonFrame, 'Maximize', set_size)

--公会奖励
    CommunitiesFrame.GuildBenefitsFrame.Perks:SetPoint('TOPRIGHT', CommunitiesFrame.GuildBenefitsFrame, 'TOP', -17, 0)
    CommunitiesFrame.GuildBenefitsFrame.Rewards:SetPoint('LEFT', CommunitiesFrame.GuildBenefitsFrame.Perks, 'RIGHT', 15, 0)
    CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar:SetPoint('TOPRIGHT', CommunitiesFrame.GuildBenefitsFrame.Perks, 'BOTTOMRIGHT')

    CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetPoint('BOTTOMRIGHT', 14, 0)--bg
    CommunitiesFrame.GuildBenefitsFrame.Rewards:GetRegions():SetPoint('BOTTOMRIGHT', 14, 0)

--寻找社区
    hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, 'Update', Init_Update)






--公会信息
    CommunitiesFrameGuildDetailsFrameInfo:SetWidth(272)



    CommunitiesFrameGuildDetailsFrameInfo.Header1:SetPoint('RIGHT', 14,0)
    CommunitiesFrameGuildDetailsFrameInfoChallenge1:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfoChallenge2:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfoChallenge3:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfoChallenge4:SetPoint('RIGHT')
    CommunitiesFrameGuildDetailsFrameInfo.BG:SetPoint('RIGHT', 14, 0)

    CommunitiesFrameGuildDetailsFrameInfo.Header2:SetPoint('RIGHT', 14,0)

    CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('BOTTOMLEFT', CommunitiesFrameGuildDetailsFrameInfoBar2Left, 'TOPLEFT', 14, 0)
    CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('RIGHT')

    CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame:SetPoint('RIGHT')
    sub= CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame:GetChildren()
    if sub and sub.Details then
        sub:SetPoint('RIGHT', CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame)
        sub.Details:SetPoint('RIGHT', CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame, 0, 4)
    end

--公会新闻
    CommunitiesFrameGuildDetailsFrameNews:SetPoint('LEFT', CommunitiesFrameGuildDetailsFrameInfo, 'RIGHT', 15, 0)
    CommunitiesFrameGuildDetailsFrameNews.ScrollBox:SetPoint('BOTTOMRIGHT')
    CommunitiesFrameGuildDetailsFrameNews.Header:SetPoint('RIGHT', -14, 0)
    --CommunitiesFrameGuildDetailsFrameNews.SetFiltersButton:SetPoint('RIGHT', CommunitiesFrameGuildDetailsFrameNews.Header, -2, 0)




    CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('RIGHT')
    CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('BOTTOM')
    WoWTools_EditBoxMixin:Setup(CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox, {isMaxLetter=true})
    hooksecurefunc('CommunitiesGuildTextEditFrame_SetType', function(frame)
        self:Set_SizeScale(frame)
        frame.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", nil)
    end)






    local function CommunitiesMode_IsMini()
        return CommunitiesFrame:GetDisplayMode()==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED
    end
    local function CommunitiesMode_GetName()
        return CommunitiesMode_IsMini() and 'CommunitiesFrameMINIMIZED' or 'CommunitiesFrameNormal'
    end

    self:Setup(CommunitiesFrame, {
        setSize=true,
        scaleStoppedFunc= function()
            self:Save().scale[CommunitiesMode_GetName()]= CommunitiesFrame:GetScale()

        end,
        scaleRestFunc=function()
            self:Save().scale['CommunitiesFrameMINIMIZED']= nil
            self:Save().scale['CommunitiesFrameNormal']= nil
        end,
        sizeStopFunc=function()
            self:Save().size[CommunitiesMode_GetName()]=  {CommunitiesFrame:GetSize()}
        end,
        sizeRestFunc=function()
            if CommunitiesMode_IsMini() then
                CommunitiesFrame:SetSize(322, 406)
            else
                CommunitiesFrame:SetSize(814, 426)
            end
            self:Save().size['CommunitiesFrameMINIMIZED']=nil
            self:Save().size['CommunitiesFrameNormal']= nil
        end,
        sizeRestTooltipColorFunc=function()
            if self:Save().size[CommunitiesMode_GetName()] then
                return ''
            else
                return '|cff9e9e9e'
            end
        end,
    })


    --[[没有GetName()
    self:Setup(CommunitiesFrame.RecruitmentDialog)
    self:Setup(CommunitiesFrame.NotificationSettingsDialog)
    self:Setup(CommunitiesFrame.NotificationSettingsDialog.Selector, {frame=CommunitiesFrame.NotificationSettingsDialog})
    self:Setup(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame, {frame=CommunitiesFrame.NotificationSettingsDialog})]]
    self:Setup(CommunitiesTicketManagerDialog)

--新闻过滤
    self:Setup(CommunitiesGuildNewsFiltersFrame, {notFuori=true})


--成员,叙述 CommunitiesGuildMemberDetailMixin
    self:Setup(CommunitiesFrame.GuildMemberDetailFrame, {frame=CommunitiesFrame})
    hooksecurefunc(CommunitiesFrame.GuildMemberDetailFrame, 'DisplayMember', function(frame)
        frame:SetHeight(frame:GetHeight()+15)
    end)
    CommunitiesFrame.GuildMemberDetailFrame.NoteBackground.PersonalNoteText:SetNonSpaceWrap(true)

--信息，查看记录
    self:Setup(CommunitiesGuildLogFrame, {
        setSize=true, notFuori=true,
    sizeRestFunc=function(btn)
        CommunitiesGuildLogFrame:SetSize(384, 432)
    end})

--公会信息， 点击以编辑
    self:Setup(CommunitiesGuildTextEditFrame, {
        setSize=true, notFuori=true,
    sizeRestFunc=function()
        CommunitiesGuildTextEditFrame:SetSize(295, 295)
    end})





















--新建，公会, 签名
    self:Setup(PetitionFrame, {
        setSize=true,
    sizeRestFunc=function()
        PetitionFrame:SetSize(338, 424)
    end})
    PetitionFrame.Bg:SetPoint('BOTTOMRIGHT',-32,30)


--公会和社区，列表
    CommunitiesFrameCommunitiesList:SetPoint('BOTTOMRIGHT', CommunitiesFrame, 'BOTTOMLEFT', 170, 3)


--设计，公会战袍
    self:Setup(TabardFrame, {
        setSize=true,
    sizeRestFunc=function()
        TabardFrame:SetSize(338, 424)
    end})

    TabardFrameCancelButton:ClearAllPoints()
    TabardFrameCancelButton:SetPoint('BOTTOMRIGHT', -20, 8)
    TabardFrameAcceptButton:ClearAllPoints()
    TabardFrameAcceptButton:SetPoint('RIGHT', TabardFrameCancelButton, 'LEFT')
    TabardFrameNameText:ClearAllPoints()
    TabardFrameNameText:SetParent(TabardFrame.TitleContainer)
    TabardFrameNameText:SetPoint('CENTER',TabardFrame.TitleContainer)
    TabardFrameNameText:SetDrawLayer('BORDER', 7)

    TabardFrameCostFrame:ClearAllPoints()
    TabardFrameCostFrame:SetPoint('TOPRIGHT', -8, -60)

    TabardFrameEmblemTopRight:ClearAllPoints()
    TabardFrameEmblemTopRight:SetPoint('BOTTOMRIGHT', 0, 240)

    TabardModel:SetPoint('TOPLEFT', 2, 0)
    TabardModel:SetPoint('TOPRIGHT', -2, 0)
    TabardModel:SetPoint('BOTTOM', TabardFrame, 'BOTTOM', 0, 2)

    TabardModel:HookScript('OnMouseWheel', function(frame, d)--ModelFrameMixin.lua
        local rotationsPerSecond = ROTATIONS_PER_SECOND;
        local elapsedTime= 0.05
        if d==-1 then
            frame.rotation = frame.rotation + (elapsedTime * 2 * PI * rotationsPerSecond);
            if ( frame.rotation > (2 * PI) ) then
                frame.rotation = frame.rotation - (2 * PI);
            end
            frame:SetRotation(frame.rotation);

        else
            frame.rotation = frame.rotation - (elapsedTime * 2 * PI * rotationsPerSecond);
            if ( frame.rotation < 0 ) then
                frame.rotation = frame.rotation + (2 * PI);
            end
            frame:SetRotation(frame.rotation);
        end
    end)


--公会设置
    self:Setup(GuildControlUI, {
        setSize=true, notFuori=true,
    sizeRestFunc=function()
        GuildControlUI:SetSize(338, 444)
    end})
    GuildControlUIRankBankFrameInset:SetPoint('LEFT', 2, 0)
    GuildControlUIRankBankFrameInset:SetPoint('BOTTOMRIGHT', -2, 2)

--社区设置
--修改，图标, 可能会有BUG
    --宏列表，按钮宽，数量
    --[[CommunitiesAvatarPickerDialog:HookScript('OnSizeChanged', function(frame)--Blizzard_ScrollBoxSelector.lua
        local value= math.max(2, math.modf(frame:GetWidth()/64))
        if frame:GetStride()~= value then
            frame:SetCustomStride(value)
            frame:Init()
        end
    end)

    self:Setup(CommunitiesAvatarPickerDialog, {
        setSize=true, notFuori=true, minW=207, minH=260,
    sizeRestFunc=function()
        CommunitiesAvatarPickerDialog:SetSize(510, 480)
    end})]]
end














--公会，可以使用的服务
function WoWTools_TextureMixin.Frames:GuildRegistrarFrame()
    GuildRegistrarFrameNpcNameText:SetParent(GuildRegistrarFrame.TitleContainer)
    self:SetButton(GuildRegistrarFrameCloseButton)
    self:SetNineSlice(GuildRegistrarFrame)
    self:SetAlphaColor(GuildRegistrarFrameBg, nil, nil,true)
    self:HideTexture(GuildRegistrarFrameInset.Bg)
    self:SetInset(GuildRegistrarFrameInset)
    self:SetNineSlice(GuildRegistrarFrameInset)
    self:SetScrollBar(GuildRegistrarFrame, true)
    self:SetEditBox(GuildRegistrarFrameEditBox)
end

--公会，可以使用的服务
function WoWTools_MoveMixin.Frames:GuildRegistrarFrame()
    self:Setup(GuildRegistrarFrame)

--注册公会
    WoWTools_EditBoxMixin:Setup(GuildRegistrarFrameEditBox,  {isMaxLetter=true, maxLetterPoint=function(edit, label)
        label:SetPoint('BOTTOMRIGHT', edit, 'TOPRIGHT')
    end})
--公会更名
    WoWTools_EditBoxMixin:Setup(GuildRenameFrame.RenameFlow.NameBox,  {isMaxLetter=true, maxLetterPoint=function(edit, label)
        label:SetPoint('BOTTOMRIGHT', edit, 'TOPRIGHT')
    end})
    local label= WoWTools_LabelMixin:Create(GuildRenameFrame.RenameFlow.NameBox, {color=true, name='WoWToolsGuildRenameFrameRenameMaxLabel'})
    label:SetPoint('LEFT', GuildRenameFrame.RenameFlow.NameBox, 'RIGHT')
    label:SetText(24)
end