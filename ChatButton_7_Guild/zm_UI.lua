--公会和社区
local function Save()
    return WoWToolsSave['Plus_Move']
end


local function set_size(frame)
    local self= frame:GetParent()
    if not self.ResizeButton or WoWTools_FrameMixin:IsLocked(frame) then
        return
    end
    local size, scale
    local displayMode = self:GetDisplayMode();
    if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
        self.ResizeButton.minWidth= 290
        self.ResizeButton.minHeight= 115
        size= Save().size['CommunitiesFrameMINIMIZED']
        scale= Save().scale['CommunitiesFrameMINIMIZED']
    else
        size= Save().size['CommunitiesFrameNormal']
        scale= Save().scale['CommunitiesFrameNormal']
        self.ResizeButton.minWidth= 200--814
        self.ResizeButton.minHeight= 200--426
    end
    if size then
        self:SetSize(size[1], size[2])
    end
    if scale then
        self:SetScale(scale)
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






























--今日信息


function WoWTools_MoveMixin.Events:Blizzard_Communities()--公会和社区
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

    CommunitiesFrameGuildDetailsFrameNews:SetPoint('LEFT', CommunitiesFrameGuildDetailsFrameInfo, 'RIGHT', 15, 0)
    CommunitiesFrameGuildDetailsFrameNews.ScrollBox:SetPoint('BOTTOMRIGHT')




    CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('RIGHT')
    CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('BOTTOM')
    WoWTools_EditBoxMixin:Setup(CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox, {isMaxLetter=true})
    hooksecurefunc('CommunitiesGuildTextEditFrame_SetType', function(frame)
        self:Set_SizeScale(frame)
        frame.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", nil)
    end)








    self:Setup(CommunitiesFrame, {
        setSize=true,
        scaleStoppedFunc= function(btn)
            local frame= btn.targetFrame
            local displayMode = frame:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().scale['CommunitiesFrameMINIMIZED']= frame:GetScale()
            else
                Save().scale['CommunitiesFrameNormal']= frame:GetScale()
            end
        end,
        scaleRestFunc=function(btn)
            local displayMode = btn.targetFrame:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().scale['CommunitiesFrameMINIMIZED']= nil
            else
                Save().scale['CommunitiesFrameNormal']= nil
            end
        end,
        sizeStopFunc=function(btn)
            local frame= btn.targetFrame
            local displayMode = frame:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().size['CommunitiesFrameMINIMIZED']= {frame:GetSize()}
            else
                Save().size['CommunitiesFrameNormal']= {frame:GetSize()}
            end
        end,
        sizeRestFunc=function(btn)
            local frame= btn.targetFrame
            local displayMode = frame:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().size['CommunitiesFrameMINIMIZED']=nil
                frame:SetSize(322, 406)
            elseif Save().size['CommunitiesFrameNormal'] then
                Save().size['CommunitiesFrameNormal']= nil
                frame:SetSize(814, 426)
            end
        end,
        sizeRestTooltipColorFunc=function(btn)
            local displayMode = btn.targetFrame:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                if Save().size['CommunitiesFrameMINIMIZED'] then
                    return ''
                end
            elseif Save().size['CommunitiesFrameNormal'] then
                return ''
            end
            return '|cff9e9e9e'
        end,
    })

    self:Setup(CommunitiesFrame.RecruitmentDialog)
    self:Setup(CommunitiesFrame.NotificationSettingsDialog)
    self:Setup(CommunitiesFrame.NotificationSettingsDialog.Selector, {frame=CommunitiesFrame.NotificationSettingsDialog})
    self:Setup(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame, {frame=CommunitiesFrame.NotificationSettingsDialog})
    self:Setup(CommunitiesTicketManagerDialog)

--新闻过滤
    self:Setup(CommunitiesGuildNewsFiltersFrame, {notFuori=true})



--信息，查看记录
    self:Setup(CommunitiesGuildLogFrame, {
        setSize=true, notFuori=true,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(384, 432)
    end})

--[[公会信息， 点击以编辑
    self:Setup(CommunitiesGuildTextEditFrame, {
        setSize=true, notFuori=true,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(295, 295)
    end})
    ]]




















--新建，公会, 签名
    WoWTools_MoveMixin:Setup(PetitionFrame, {
        setSize=true,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 424)
    end})
    PetitionFrame.Bg:SetPoint('BOTTOMRIGHT',-32,30)

--公会，可以使用的服务
    WoWTools_MoveMixin:Setup(GuildRegistrarFrame)

--公会和社区，列表
    CommunitiesFrameCommunitiesList:SetPoint('BOTTOMRIGHT', CommunitiesFrame, 'BOTTOMLEFT', 170, 3)


--设计，公会战袍
    WoWTools_MoveMixin:Setup(TabardFrame, {
        setSize=true,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 424)
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
    WoWTools_MoveMixin:Setup(GuildControlUI, {
        setSize=true, notFuori=true,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 444)
    end})
    GuildControlUIRankBankFrameInset:SetPoint('LEFT', 2, 0)
    GuildControlUIRankBankFrameInset:SetPoint('BOTTOMRIGHT', -2, 2)

--社区设置
--[[修改，图标
    WoWTools_MoveMixin:Setup(CommunitiesAvatarPickerDialog, {
        setSize=true, notFuori=true,
    sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(510, 480)
    end})]]
end