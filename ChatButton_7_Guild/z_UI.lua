
function WoWTools_TooltipMixin.Events:Blizzard_Communities()
    WoWTools_DataMixin:Hook(CommunitiesAvatarButtonMixin, 'Init', function(btn)
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
    self:SetMenu(CommunitiesFrame.StreamDropdown)

    self:SetScrollBar(CommunitiesFrame.Chat)
    self:SetNineSlice(CommunitiesFrame.Chat.InsetFrame)
    self:CreateBG(CommunitiesFrame.Chat, {isAllPoint=true, isColor=true})

--公会，页面
    self:SetUIButton(CommunitiesFrame.InviteButton)
    self:SetUIButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
    self:SetUIButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
    self:SetMenu(CommunitiesFrame.GuildMemberListDropdown)
    self:SetCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
    self:SetStatusBar(CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar, CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar.Progress)
    self:SetUIButton(CommunitiesFrame.GuildLogButton)
    self:SetUIButton(CommunitiesGuildLogFrameCloseButton)

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

    WoWTools_DataMixin:Hook(CommunitiesListEntryMixin, 'Init', function(frame, data)
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

    self:SetMenu(CommunitiesFrame.NotificationSettingsDialog.CommunitiesListDropdown)
    self:SetFrame(CommunitiesFrame.NotificationSettingsDialog.Selector)
    self:SetScrollBar(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame)
    self:SetAlphaColor(CommunitiesFrame.NotificationSettingsDialog.BG, {notAlpha=true})

--成员，列表
    self:SetNineSlice(CommunitiesFrame.MemberList.InsetFrame)
    self:HideFrame(CommunitiesFrame.MemberList.ColumnDisplay)
    self:SetScrollBar(CommunitiesFrame.MemberList)
    self:CreateBG(CommunitiesFrame.MemberList, {isAllPoint=true})


--成员,叙述 CommunitiesGuildMemberDetailMixin
    self:SetFrame(CommunitiesFrame.GuildMemberDetailFrame.Border, {alpha=1})
    self:SetButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)
    self:SetNineSlice(CommunitiesFrame.GuildMemberDetailFrame.NoteBackground, 0.5)
    self:SetMenu(CommunitiesFrame.GuildMemberDetailFrame.RankDropdown)
    self:SetNineSlice(CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground, 0.5)
    self:SetUIButton(CommunitiesFrame.GuildMemberDetailFrame.RemoveButton)
    self:SetUIButton(CommunitiesFrame.GuildMemberDetailFrame.GroupInviteButton)


--公会奖励，列表, 物品，GuildRewards.lua
    self:HideTexture(CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg)
    self:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards)
    CommunitiesFrame.GuildBenefitsFrame.Perks:DisableDrawLayer('BACKGROUND')
    self:HideFrame(CommunitiesFrame.GuildBenefitsFrame)
    self:SetScrollBar(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBar)

    WoWTools_DataMixin:Hook(CommunitiesGuildRewardsButtonMixin, 'Init', function(f)
        self:SetBG(f)
    end)
    

--角色名称邀请你加入
    self:SetNineSlice(CommunitiesFrame.ClubFinderInvitationFrame.InsetFrame)
    self:SetUIButton(CommunitiesFrame.ClubFinderInvitationFrame.AcceptButton)
    self:SetUIButton(CommunitiesFrame.ClubFinderInvitationFrame.DeclineButton)


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



--设计，公会战袍
    self:SetAllFrames(TabardFrame, {
        frames={TabardFrameCustomizationFrame},
        bg=true,
    })
    for i=1, 5 do
        self:HideTexture(_G['TabardFrameCustomization'..i..'Middle'])
        self:HideTexture(_G['TabardFrameCustomization'..i..'Left'])
        self:HideTexture(_G['TabardFrameCustomization'..i..'Right'])
        self:SetButton(_G['TabardFrameCustomization'..i..'LeftButton'], 0.75)
        self:SetButton(_G['TabardFrameCustomization'..i..'RightButton'], 0.75)
    end
    self:SetButton(TabardCharacterModelRotateLeftButton)
    self:SetButton(TabardCharacterModelRotateRightButton)


    --self:SetButton(TabardFrameCloseButton)


--信息
    self:SetFrame(CommunitiesFrameGuildDetailsFrameInfo)
    CommunitiesFrameGuildDetailsFrameInfo:DisableDrawLayer('BACKGROUND')
    self:SetFrame(CommunitiesFrameGuildDetailsFrame)
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame)
    self:SetScrollBar(CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame)
    --CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:SetPoint('BOTTOMRIGHT')

--公会信息， 点击以编辑
    --CommunitiesGuildTextEditFrame
    self:SetFrame(CommunitiesGuildTextEditFrame)
    self:SetNineSlice(CommunitiesGuildTextEditFrame.Container, nil, true)
    self:SetScrollBar(CommunitiesGuildTextEditFrame.Container.ScrollFrame)

--查看日志，记录
    self:SetFrame(CommunitiesGuildLogFrame)
    self:SetFrame(CommunitiesGuildLogFrameCloseButton)
    self:SetNineSlice(CommunitiesGuildLogFrame.Container, nil, true)
    self:SetScrollBar(CommunitiesGuildLogFrame.Container.ScrollFrame)


--新闻过滤
    self:SetFrame(CommunitiesGuildNewsFiltersFrame)
    self:SetButton(CommunitiesGuildNewsFiltersFrame.CloseButton)

--寻找社区
    self:SetScrollBar(ClubFinderCommunityAndGuildFinderFrame.CommunityCards)
    self:SetScrollBar(ClubFinderCommunityAndGuildFinderFrame.PendingCommunityCards)

    if ClubFinderCommunityAndGuildFinderFrame.OptionsList then
        self:SetMenu(ClubFinderCommunityAndGuildFinderFrame.OptionsList.ClubFilterDropdown)
        self:SetCheckBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.TankRoleFrame.Checkbox)
        self:SetCheckBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.HealerRoleFrame.Checkbox)
        self:SetCheckBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.DpsRoleFrame.Checkbox)
        self:SetEditBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)
        self:SetUIButton(ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search)
        self:SetMenu(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SortByDropdown)
    end

    self:SetNineSlice(ClubFinderCommunityAndGuildFinderFrame.InsetFrame)
    self:SetAlphaColor(ClubFinderCommunityAndGuildFinderFrame.InsetFrame.Bg)
    self:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, {index=1})
    WoWTools_ButtonMixin:AddMask(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab, true)
    self:HideFrame(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, {index=1})
    WoWTools_ButtonMixin:AddMask(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab, true)

--公会查找器
    self:HideTexture(ClubFinderGuildFinderFrame.InsetFrame.Bg)
    self:SetNineSlice(ClubFinderGuildFinderFrame.InsetFrame)
    self:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubFilterDropdown)
    self:SetMenu(ClubFinderGuildFinderFrame.OptionsList.ClubSizeDropdown)
    self:SetEditBox(ClubFinderGuildFinderFrame.OptionsList.SearchBox)
    self:SetUIButton(ClubFinderGuildFinderFrame.OptionsList.Search)
    self:SetCheckBox(ClubFinderGuildFinderFrame.OptionsList.TankRoleFrame.Checkbox)
    self:SetCheckBox(ClubFinderGuildFinderFrame.OptionsList.HealerRoleFrame.Checkbox)
    self:SetCheckBox(ClubFinderGuildFinderFrame.OptionsList.DpsRoleFrame.Checkbox)
    self:SetUIButton(ClubFinderGuildFinderFrame.GuildCards.FirstCard.RequestJoin)
    self:SetUIButton(ClubFinderGuildFinderFrame.GuildCards.SecondCard.RequestJoin)
    self:SetUIButton(ClubFinderGuildFinderFrame.GuildCards.ThirdCard.RequestJoin)
    self:SetButton(ClubFinderGuildFinderFrame.GuildCards.PreviousPage, 1)
    self:SetButton(ClubFinderGuildFinderFrame.GuildCards.NextPage, 1)
    self:HideFrame(ClubFinderGuildFinderFrame.ClubFinderSearchTab, {index=1})
    WoWTools_ButtonMixin:AddMask(ClubFinderGuildFinderFrame.ClubFinderSearchTab, true)
    self:HideFrame(ClubFinderGuildFinderFrame.ClubFinderPendingTab, {index=1})
    WoWTools_ButtonMixin:AddMask(ClubFinderGuildFinderFrame.ClubFinderPendingTab, true)


    self:HideTexture(CommunitiesFrame.TopTileStreaks)

    self:HideTexture(CommunitiesFrameInset.Bg)

    self:HideTexture(CommunitiesFrameBg)

--这个会，弹出菜单
    CommunitiesFrame.CommunitiesListDropdown:SetFrameStrata('HIGH')
    self:SetMenu(CommunitiesFrame.CommunitiesListDropdown)

--邀请别人加入
    self:SetFrame(CommunitiesTicketManagerDialog, {show={CommunitiesTicketManagerDialog.Background}, alpha=1})
    self:SetUIButton(CommunitiesTicketManagerDialog.LinkToChat)
    self:SetUIButton(CommunitiesTicketManagerDialog.Copy)
    self:SetUIButton(CommunitiesTicketManagerDialog.Close)

--BG
    self:Init_BGMenu_Frame(CommunitiesFrame)
end











































--公会和社区
function WoWTools_MoveMixin.Events:Blizzard_Communities()--公会和社区


    local function set_size(frame)
        frame= frame:GetParent()
        if WoWTools_FrameMixin:IsLocked(frame) or not frame.ResizeButton then
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




    --WoWTools_DataMixin:Hook(ClubFinderCommunitiesCardMixin, 'Init', function(b)
    local function Init_Update(frame)
        if not frame:HasView() or WoWTools_FrameMixin:IsLocked(frame) then
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


    WoWTools_DataMixin:Hook(CommunitiesFrame.MaxMinButtonFrame, 'Minimize', set_size)--maximizedCallback
    WoWTools_DataMixin:Hook(CommunitiesFrame.MaxMinButtonFrame, 'Maximize', set_size)

--公会奖励
    CommunitiesFrame.GuildBenefitsFrame.Perks:SetPoint('TOPRIGHT', CommunitiesFrame.GuildBenefitsFrame, 'TOP', -17, 0)
    CommunitiesFrame.GuildBenefitsFrame.Rewards:SetPoint('LEFT', CommunitiesFrame.GuildBenefitsFrame.Perks, 'RIGHT', 15, 0)
    CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar:SetPoint('TOPRIGHT', CommunitiesFrame.GuildBenefitsFrame.Perks, 'BOTTOMRIGHT')

    CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetPoint('BOTTOMRIGHT', 14, 0)--bg
    CommunitiesFrame.GuildBenefitsFrame.Rewards:GetRegions():SetPoint('BOTTOMRIGHT', 14, 0)

--寻找社区
    WoWTools_DataMixin:Hook(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, 'Update', Init_Update)
    






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
    WoWTools_DataMixin:Hook('CommunitiesGuildTextEditFrame_SetType', function(frame)
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
                return '|cff626262'
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
    self:Setup(CommunitiesGuildNewsFiltersFrame)


--成员,叙述 CommunitiesGuildMemberDetailMixin
    self:Setup(CommunitiesFrame.GuildMemberDetailFrame, {frame=CommunitiesFrame})
    WoWTools_DataMixin:Hook(CommunitiesFrame.GuildMemberDetailFrame, 'DisplayMember', function(frame)
        frame:SetHeight(frame:GetHeight()+15)
    end)
    CommunitiesFrame.GuildMemberDetailFrame.NoteBackground.PersonalNoteText:SetNonSpaceWrap(true)

--信息，查看记录
    self:Setup(CommunitiesGuildLogFrame, {
    sizeRestFunc=function()
        CommunitiesGuildLogFrame:SetSize(384, 432)
    end})

--公会信息， 点击以编辑
    self:Setup(CommunitiesGuildTextEditFrame, {
    sizeRestFunc=function()
        CommunitiesGuildTextEditFrame:SetSize(295, 295)
    end})





















--新建，公会, 签名
    self:Setup(PetitionFrame, {
    sizeRestFunc=function()
        PetitionFrame:SetSize(338, 424)
    end})
    PetitionFrame.Bg:SetPoint('BOTTOMRIGHT',-32,30)


--公会和社区，列表
    CommunitiesFrameCommunitiesList:SetPoint('BOTTOMRIGHT', CommunitiesFrame, 'BOTTOMLEFT', 170, 3)


--设计，公会战袍
    self:Setup(TabardFrame, {
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
        minW=207, minH=260,
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
    self:SetScrollBar(GuildRegistrarFrame)
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