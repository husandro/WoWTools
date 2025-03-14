--公会和社区
local function Save()
    return WoWTools_MoveMixin.Save
end


local function set_size(frame)
    local self= frame:GetParent()
        if not self.ResizeButton then
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
        self.ResizeButton.minWidth= 814
        self.ResizeButton.minHeight= 426
    end
    if size then
        self:SetSize(size[1], size[2])
    end
    if scale then
        self:SetScale(scale)
    end
end





local function Init_Update(frame)
    if not frame:GetView() then
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





local function Init()






    hooksecurefunc(CommunitiesFrame.MaxMinButtonFrame, 'Minimize', set_size)--maximizedCallback
    hooksecurefunc(CommunitiesFrame.MaxMinButtonFrame, 'Maximize', set_size)
    hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox, 'Update', Init_Update)


    WoWTools_MoveMixin:Setup(CommunitiesFrame, {
        setSize=true,
        scaleStoppedFunc= function(btn)
            local self= btn.target
            local displayMode = self:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().scale['CommunitiesFrameMINIMIZED']= self:GetScale()
            else
                Save().scale['CommunitiesFrameNormal']= self:GetScale()
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
            local self= btn.target
            local displayMode = self:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().size['CommunitiesFrameMINIMIZED']= {self:GetSize()}
            else
                Save().size['CommunitiesFrameNormal']= {self:GetSize()}
            end
        end,
        sizeRestFunc=function(btn)
            local self= btn.target
            local displayMode = self:GetDisplayMode()
            if displayMode==COMMUNITIES_FRAME_DISPLAY_MODES.MINIMIZED then
                Save().size['CommunitiesFrameMINIMIZED']=nil
                self:SetSize(322, 406)
            elseif Save().size['CommunitiesFrameNormal'] then
                Save().size['CommunitiesFrameNormal']= nil
                self:SetSize(814, 426)
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

    WoWTools_MoveMixin:Setup(CommunitiesFrame.RecruitmentDialog)
    WoWTools_MoveMixin:Setup(CommunitiesFrame.NotificationSettingsDialog)
    WoWTools_MoveMixin:Setup(CommunitiesFrame.NotificationSettingsDialog.Selector, {frame=CommunitiesFrame.NotificationSettingsDialog})
    WoWTools_MoveMixin:Setup(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame, {frame=CommunitiesFrame.NotificationSettingsDialog})
    WoWTools_MoveMixin:Setup(CommunitiesGuildNewsFiltersFrame)

--信息，查看记录
    WoWTools_MoveMixin:Setup(CommunitiesGuildLogFrame, {setSize=true, sizeRestFunc=function(btn)
        btn.target:SetSize(384, 432)
    end})

--公会信息， 点击以编辑
    WoWTools_MoveMixin:Setup(CommunitiesGuildTextEditFrame, {setSize=true, onShowFunc=true,
    initFunc=function()

        CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('RIGHT')
        CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox:SetPoint('BOTTOM')
        
        WoWTools_EditBoxMixn:Setup(CommunitiesGuildTextEditFrame.Container.ScrollFrame.EditBox, {isMaxLetter=true})

        hooksecurefunc('CommunitiesGuildTextEditFrame_SetType', function(frame)
            WoWTools_MoveMixin:Set_SizeScale(frame)
            frame.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", nil)
            --self.Container.ScrollFrame.EditBox:SetScript("OnEnterPressed", CommunitiesGuildTextEditFrame_OnAccept);
        end)
    end, sizeRestFunc=function(btn)
        btn.target:SetSize(295, 295)
    end})

--新建，公会, 签名
    WoWTools_MoveMixin:Setup(PetitionFrame, {setSize=true, initFunc=function(btn)
        PetitionFrame.Bg:SetPoint('BOTTOMRIGHT',-32,30)
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 424)
    end})
--公会，可以使用的服务
    WoWTools_MoveMixin:Setup(GuildRegistrarFrame)




    
--设计，公会战袍
    WoWTools_MoveMixin:Setup(TabardFrame, {setSize=true, initFunc=function()
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

        TabardModel:HookScript('OnMouseWheel', function(self, d)--ModelFrameMixin.lua
            local rotationsPerSecond = ROTATIONS_PER_SECOND;
            local elapsedTime= 0.05
            if d==-1 then
                self.rotation = self.rotation + (elapsedTime * 2 * PI * rotationsPerSecond);
                if ( self.rotation > (2 * PI) ) then
                    self.rotation = self.rotation - (2 * PI);
                end
                self:SetRotation(self.rotation);

            else
                self.rotation = self.rotation - (elapsedTime * 2 * PI * rotationsPerSecond);
                if ( self.rotation < 0 ) then
                    self.rotation = self.rotation + (2 * PI);
                end
                self:SetRotation(self.rotation);
            end
        end)
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 424)
    end})

--公会设置
    WoWTools_MoveMixin:Setup(GuildControlUI, {setSize=true, notFuori=true, initFunc=function()
        GuildControlUIRankBankFrameInset:SetPoint('LEFT', 2, 0)
        GuildControlUIRankBankFrameInset:SetPoint('BOTTOMRIGHT', -2, 2)
    end, sizeRestFunc=function(btn)
        btn.targetFrame:SetSize(338, 444)
    end})
end




function WoWTools_MoveMixin:Init_Communities()--公会和社区
    Init()
end