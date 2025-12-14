function WoWTools_TextureMixin.Events:Blizzard_BNet()
    BNToastFrame:ClearAllPoints()
    BNToastFrame:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT')
    self:SetFrame(BNToastFrame, {alpha=0.3})
end

--[[function WoWTools_MoveMixin.Events:Blizzard_BNet()
    self:Setup(BNToastFrame)
end]]







--好友召募
function WoWTools_MoveMixin.Events:Blizzard_RecruitAFriend()
    RecruitAFriendFrame.RecruitList.ScrollBox:SetPoint('BOTTOMRIGHT', -20,0)
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('LEFT')
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('RIGHT')
    --RecruitAFriendFrame.RewardClaiming.NextRewardName:SetPoint('RIGHT', -13, 0)
    --RecruitAFriendFrame.RewardClaiming.NextRewardName.Text:SetPoint('RIGHT')
    WoWTools_MoveMixin:Setup(RecruitAFriendRewardsFrame)
    WoWTools_MoveMixin:Setup(RecruitAFriendFrame.RewardClaiming.Inset, {frame=FriendsFrame})
end

function WoWTools_TextureMixin.Events:Blizzard_RecruitAFriend()
    self:SetScrollBar(RecruitAFriendFrame.RecruitList)
    self:HideTexture(RecruitAFriendFrame.RecruitList.ScrollFrameInset.Bg)
    self:SetNineSlice(RecruitAFriendFrame.RewardClaiming.Inset)
    self:SetNineSlice(RecruitAFriendFrame.RecruitList.ScrollFrameInset)
    self:HideTexture(RecruitAFriendFrame.RecruitList.Header.Background)
    self:HideTexture(RecruitAFriendFrame.RewardClaiming.Inset.Bg)
    self:SetFrame(RecruitAFriendFrame.RewardClaiming, {alpha=0.3})
    self:SetButton(RecruitAFriendFrame.RewardClaiming.NextRewardInfoButton, 0.5)

--好友召募奖励
    self:HideFrame(RecruitAFriendRewardsFrame.Border)
    self:SetButton(RecruitAFriendRewardsFrame.CloseButton)
end
--function WoWTools_MoveMixin.Events:Blizzard_RaidFrame()













--团队信息， 副本击杀信息
function WoWTools_MoveMixin.Events:Blizzard_RaidFrame()
    RaidInfoFrame.ScrollBox:SetPoint('BOTTOMRIGHT',-35, 38)
    RaidInfoDetailFooter:SetPoint('RIGHT', -12, 0)
    RaidInfoInstanceLabel:SetWidth(200)
    RaidInfoIDLabel:ClearAllPoints()
    RaidInfoIDLabel:SetPoint('TOPRIGHT', -13, -31)
    RaidInfoInstanceLabel:ClearAllPoints()
    RaidInfoInstanceLabel:SetPoint('TOPLEFT', 13, -31)
    RaidInfoInstanceLabel:SetPoint('BOTTOMRIGHT', RaidInfoIDLabel, 'BOTTOMLEFT', 1,0)

    local function RaidInfoFrame_Set_point()
        RaidInfoFrame:ClearAllPoints()
        RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 0 ,-28)
    end
    WoWTools_MoveMixin:Setup(RaidInfoFrame, {
        minW=345,
        minH=128,
        notMoveAlpha=true,
        sizeRestFunc=function()
            RaidInfoFrame:SetSize(345, 250)
            RaidInfoFrame_Set_point()
        end, restPointFunc=function()
            RaidInfoFrame_Set_point()
        end
    })
end


function WoWTools_TextureMixin.Events:Blizzard_RaidFrame()
    self:SetUIButton(RaidFrameConvertToRaidButton)
    self:SetUIButton(RaidFrameRaidInfoButton)

    self:HideTexture(RaidInfoDetailHeader)
    self:SetButton(RaidInfoCloseButton)
    self:SetFrame(RaidInfoFrame.Border, {show={[RaidInfoFrame.Border.Bg]=true}})
    self:SetFrame(RaidInfoFrame.Header)
    self:SetAlphaColor(RaidInfoDetailFooter)
    self:SetScrollBar(RaidInfoFrame)
    self:SetUIButton(RaidInfoExtendButton)
    self:SetUIButton(RaidInfoCancelButton)
end














function WoWTools_MoveMixin.Events:Blizzard_FriendsFrame()--好友列表
    local function Set_RaidFrame_Button_size()
        local w= FriendsFrame:GetWidth()/2-8
        for i=1, 8 do
            local frame= _G['RaidGroup'..i]
            if frame and frame:CanChangeAttribute() then
                frame:SetWidth(w)
                for _, r in pairs({frame:GetRegions()}) do
                    if r:IsObjectType('Texture') then
                        r:SetWidth(w+4)
                    end
                end
            end
            for b=1, 5 do
                local btn2= _G['RaidGroup'..i..'Slot'..b]
                if btn2 and btn2:CanChangeAttribute()  then
                    btn2:SetWidth(w)
                end
            end
        end
        for i=1, 40 do
            local btn2= _G['RaidGroupButton'..i]
            if btn2 and btn2:CanChangeAttribute()  then
                btn2:SetWidth(w)
            end
            local name= _G['RaidGroupButton'..i..'Name']
            if name then--11+23+50 
                name:SetWidth(w-114)
            end
        end
    end

    FriendsListFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -24, 30)

--团队
    RaidFrame:HookScript('OnShow', function(...) Set_RaidFrame_Button_size(...) end)

    WoWTools_DataMixin:Hook(FriendsListButtonMixin, 'OnLoad', function(btn)
        btn.name:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
        btn.info:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
    end)


    WoWTools_MoveMixin:Setup(FriendsFrame, {
        sizeUpdateFunc=function()
            if RaidFrame:IsVisible() and not WoWTools_FrameMixin:IsLocked(RaidFrame) then
                Set_RaidFrame_Button_size()
                WoWTools_DataMixin:Call('RaidGroupFrame_Update')
            end
        end,
        sizeRestFunc=function()
            FriendsFrame:SetSize(385, 424)
            if RaidFrame:IsVisible() and RaidFrame:CanChangeAttribute() then
                Set_RaidFrame_Button_size()
                WoWTools_DataMixin:Call('RaidGroupFrame_Update')
            end
        end
    })





--好友的好友，列表

    FriendsFriendsFrame.ScrollFrameBorder:SetPoint('BOTTOMRIGHT', -25, 55)
    WoWTools_DataMixin:Hook('FriendsFriends_InitButton', function(btn)
        if not btn:GetScript('OnDoubleClick') then
            btn.name:SetPoint('RIGHT', -6, 0)
            btn:SetScript('OnDoubleClick', function()
                WoWTools_DataMixin:Call(FriendsFriendsFrame.SendRequest, FriendsFriendsFrame)
            end)
        end
    end)


    WoWTools_MoveMixin:Setup(FriendsFriendsFrame, {
        minW=295,
        minH=157,
        sizeRestFunc=function()
            FriendsFriendsFrame:SetSize(314, 345)
        end

    })

--好友 屏蔽列表
    --FriendsFrame.IgnoreListWindow.CloseButton:SetFrameStrata(FriendsFrame.IgnoreListWindow.TitleContainer:GetFrameStrata())
    --FriendsFrame.IgnoreListWindow.CloseButton:SetFrameLevel(FriendsFrame.IgnoreListWindow.TitleContainer:GetFrameLevel()+1)
    FriendsFrame.IgnoreListWindow:ClearAllPoints()
    FriendsFrame.IgnoreListWindow:SetPoint('TOPLEFT', FriendsFrame, 'TOPRIGHT')
    FriendsFrame.IgnoreListWindow:SetPoint('BOTTOMLEFT', FriendsFrame, 'BOTTOMRIGHT')
    self:Setup(FriendsFrame.IgnoreListWindow, {frame=FriendsFrame})

    --WoWTools_TextureMixin:SetButton(FriendsFrame.IgnoreListWindow.ResizeButton)
--通告
    self:Setup(FriendsFrameBattlenetFrame.BroadcastFrame, {frame=FriendsFrame})
end









--好友列表
function WoWTools_TextureMixin.Events:Blizzard_FriendsFrame()
    self:HideFrame(FriendsFrame)
    self:SetNineSlice(FriendsFrameInset)
    self:HideTexture(FriendsFrameInset.Bg)
    self:SetScrollBar(FriendsListFrame)
    self:CreateBG(FriendsListFrame.ScrollBox, {isAllPoint=true, isColor=true, alpha=0.5})
    self:SetButton(FriendsFrameCloseButton)
    self:SetMenu(FriendsFrameStatusDropdown, {alpha=1})
    self:HideTexture(FriendsFrameStatusDropdown.Background)
    self:SetScrollBar(IgnoreListFrame)
    self:SetNineSlice(WhoFrameListInset)
    self:HideTexture(WhoFrameListInset.Bg)
    self:SetScrollBar(WhoFrame)
    self:SetMenu(WhoFrameDropdown)


    self:HideTexture(WhoFrameEditBox.Bg)
    self:SetEditBox(WhoFrameEditBox)

    self:CreateBG(WhoFrame.ScrollBox, {isAllPoint=true, isColor=true, alpha=0.5})
    self:SetScrollBar(QuickJoinFrame)


    self:SetTabButton(FriendsTabHeader)

    for i=1, 4 do
        self:SetTabButton(_G['FriendsFrameTab'..i])
        self:SetFrame(_G['WhoFrameColumnHeader'..i], {notAlpha=true})
    end

    self:SetFrame(BattleTagInviteFrame.Border, {notAlpha=true})



--好友的好友，列表
    self:SetUIButton(FriendsFrameAddFriendButton)
    self:SetUIButton(FriendsFrameSendMessageButton)
    self:HideFrame(FriendsFriendsFrame.Border, {show={[FriendsFriendsFrame.Border.Bg]=true}})
    self:SetNineSlice(FriendsFriendsFrame.ScrollFrameBorder, 0, true)
    self:SetScrollBar(FriendsFriendsFrame)
    self:SetMenu(FriendsFriendsFrameDropdown)


--近期往来
    self:SetScrollBar(RecentAlliesFrame.List)

--好友 屏蔽列表
    self:SetNineSlice(FriendsFrame.IgnoreListWindow)
    self:SetButton(FriendsFrame.IgnoreListWindow.CloseButton)
    self:SetScrollBar(FriendsFrame.IgnoreListWindow)
    self:HideTexture(FriendsFrame.IgnoreListWindow.Bg)
    self:SetNineSlice(FriendsFrame.IgnoreListWindow.Inset)
    self:SetUIButton(FriendsFrame.IgnoreListWindow.UnignorePlayerButton)

--通告
    self:SetFrame(FriendsFrameBattlenetFrame.BroadcastButton, {notAlpha=true})
    self:SetFrame(FriendsFrameBattlenetFrame.BroadcastFrame.Border, {alpha=0.7})
    self:SetEditBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
    self:SetButton(FriendsFrameBattlenetFrame.ContactsMenuButton, {alpha=1})
    self:SetUIButton(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton)
    self:SetUIButton(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton)


--查询
    self:SetUIButton(WhoFrameWhoButton)
    self:SetUIButton(WhoFrameAddFriendButton)
    self:SetUIButton(WhoFrameGroupInviteButton)
--快速加入
    self:SetUIButton(QuickJoinFrame.JoinQueueButton)
    self:Init_BGMenu_Frame(FriendsFrame, {
    settings=function(_, _, _, _, portraitAlpha)
        FriendsFrameIcon:SetAlpha(portraitAlpha or 1)
    end})
end









