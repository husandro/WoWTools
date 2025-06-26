

function WoWTools_MoveMixin.Events:Blizzard_FriendsFrame()--好友列表
    FriendsListFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -24, 30)

    hooksecurefunc(FriendsListButtonMixin, 'OnLoad', function(btn)
        btn.name:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
        btn.info:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
    end)

    RecruitAFriendFrame.RecruitList.ScrollBox:SetPoint('BOTTOMRIGHT', -20,0)
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('LEFT')
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('RIGHT')









--好友的好友，列表
    local function Set_RaidFrame_Button_size()
        local w= FriendsFrame:GetWidth()/2-8
        for i=1, 8 do
            local frame= _G['RaidGroup'..i]
            if frame and frame:CanChangeAttribute() then
                frame:SetWidth(w)
                for _, r in pairs({frame:GetRegions()}) do
                    if r:GetObjectType()=='Texture' then
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

    WoWTools_MoveMixin:Setup(FriendsFrame, {
        setSize=true,
        minW=385,
        minH=424,
        sizeUpdateFunc=function()
            if RaidFrame:IsShown() and RaidFrame:CanChangeAttribute() then
                Set_RaidFrame_Button_size()
                if RaidGroupFrame_Update then
                    WoWTools_Mixin:Call(RaidGroupFrame_Update)
                end
            end
        end,
        sizeRestFunc=function()
            FriendsFrame:SetSize(385, 424)
            if RaidFrame:IsShown() and RaidFrame:CanChangeAttribute() then
                Set_RaidFrame_Button_size()
                if RaidGroupFrame_Update then
                    WoWTools_Mixin:Call(RaidGroupFrame_Update)
                end
            end
        end
    })

    WoWTools_MoveMixin:Setup(RecruitAFriendRewardsFrame)
    WoWTools_MoveMixin:Setup(RecruitAFriendFrame.RewardClaiming.Inset, {frame=FriendsFrame})






--好友的好友，列表
    FriendsFriendsFrame.ScrollFrameBorder:SetPoint('BOTTOMRIGHT', -25, 55)
    hooksecurefunc('FriendsFriends_InitButton', function(btn)
        if not btn:GetScript('OnDoubleClick') then
            btn.name:SetPoint('RIGHT', -6, 0)
            btn:SetScript('OnDoubleClick', function()
                WoWTools_Mixin:Call(FriendsFriendsFrame.SendRequest, FriendsFriendsFrame)
            end)
        end
    end)
    WoWTools_MoveMixin:Setup(FriendsFriendsFrame, {
        minW=295,
        minH=157,
        setSize=true,
        sizeRestFunc=function()
            FriendsFriendsFrame:SetSize(314, 345)
        end

    })










--团队
    if RaidFrameRaidDescription then--11.2没有了
        RaidFrameRaidDescription:SetPoint('BOTTOMRIGHT', -15, 35)
    end

    RaidFrame:HookScript('OnShow', function(...) Set_RaidFrame_Button_size(...) end)

--团队，信息
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
        setSize=true,
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























--好友列表
function WoWTools_TextureMixin.Events:Blizzard_FriendsFrame()

    --self:SetNineSlice(FriendsFrame, true)
    self:HideFrame(FriendsFrame)
    self:SetNineSlice(FriendsFrameInset)
    self:HideTexture(FriendsFrameInset.Bg)
    self:SetScrollBar(FriendsListFrame)
    self:CreateBG(FriendsListFrame.ScrollBox, {isAllPoint=true, isColor=true, alpha=0.5})
    self:SetFrame(FriendsFrameBattlenetFrame.BroadcastButton, {notAlpha=true})
    self:SetButton(FriendsFrameCloseButton)
    self:SetMenu(FriendsFrameStatusDropdown, {alpha=1})
    self:HideTexture(FriendsFrameStatusDropdown.Background)

    self:SetScrollBar(IgnoreListFrame)

--好友列表，召募
    self:SetScrollBar(RecruitAFriendFrame.RecruitList)
    self:SetAlphaColor(RecruitAFriendFrame.RecruitList.ScrollFrameInset.Bg)
    self:SetNineSlice(RecruitAFriendFrame.RewardClaiming.Inset)
    self:SetNineSlice(RecruitAFriendFrame.RecruitList.ScrollFrameInset)
    self:HideTexture(RecruitAFriendFrame.RecruitList.Header.Background)
    self:HideTexture(RecruitAFriendFrame.RewardClaiming.Inset.Bg)
    self:SetFrame(RecruitAFriendFrame.RewardClaiming, {alpha=0.3})
    self:SetButton(RecruitAFriendFrame.RewardClaiming.NextRewardInfoButton, {alpha=0.5})

--团队信息
    self:HideTexture(RaidInfoDetailHeader)
    self:SetAlphaColor(RaidInfoFrame.Header.LeftBG)
    self:SetAlphaColor(RaidInfoFrame.Header.CenterBG)
    self:SetAlphaColor(RaidInfoFrame.Header.RightBG)
    self:SetAlphaColor(RaidInfoDetailFooter)
    self:SetFrame(RaidInfoFrame.Border.LeftEdge, {alpha=0.3})
    self:HideTexture(RaidInfoFrame.Border.Bg)
    self:SetScrollBar(RaidInfoFrame)

    self:SetNineSlice(WhoFrameListInset)

    self:HideTexture(WhoFrameListInset.Bg)
    self:SetScrollBar(WhoFrame)
    self:SetMenu(WhoFrameDropdown)

    if WhoFrameEditBoxInset then--11.2 没有了
        self:HideTexture(WhoFrameEditBoxInset.Bg)
        self:SetNineSlice(WhoFrameEditBoxInset, 0.3)
    else
        self:HideTexture(WhoFrameEditBox.Bg)
        self:SetEditBox(WhoFrameEditBox)
    end

    self:CreateBG(WhoFrame.ScrollBox, {isAllPoint=true, isColor=true, alpha=0.5})

    self:SetScrollBar(QuickJoinFrame)

    for i=1, 4 do
        self:SetTabButton(_G['FriendsFrameTab'..i])
        self:SetTabButton(_G['FriendsTabHeaderTab'..i])
        --self:SetFrame(_G['WhoFrameColumnHeader'..i], {notAlpha=true})
    end

    self:SetFrame(BattleTagInviteFrame.Border, {notAlpha=true})



--好友的好友，列表
    self:SetFrame(FriendsFriendsFrame.Border, {show={[FriendsFriendsFrame.Border.Bg]=true}})
    self:SetNineSlice(FriendsFriendsFrame.ScrollFrameBorder, 0, true)
    self:SetScrollBar(FriendsFriendsFrame)
    self:SetMenu(FriendsFriendsFrameDropdown)


    self:Init_BGMenu_Frame(FriendsFrame)
end









function WoWTools_TextureMixin.Events:Blizzard_BNet()
    BNToastFrame:ClearAllPoints()
    BNToastFrame:SetPoint('BOTTOMLEFT', QuickJoinToastButton, 'TOPLEFT')
    self:SetFrame(BNToastFrame, {alpha=0.3})
end