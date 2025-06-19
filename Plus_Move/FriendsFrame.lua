--好友列表





local function RaidInfoFrame_Set_point()
    RaidInfoFrame:ClearAllPoints()
    RaidInfoFrame:SetPoint("TOPLEFT", RaidFrame, "TOPRIGHT", 0 ,-28)
end



local function Init_RaidInfoFrame()
    RaidInfoFrame.ScrollBox:SetPoint('BOTTOMRIGHT',-35, 38)
    RaidInfoDetailFooter:SetPoint('RIGHT', -12, 0)
    RaidInfoInstanceLabel:SetWidth(200)
    RaidInfoIDLabel:ClearAllPoints()
    RaidInfoIDLabel:SetPoint('TOPRIGHT', -13, -31)
    RaidInfoInstanceLabel:ClearAllPoints()
    RaidInfoInstanceLabel:SetPoint('TOPLEFT', 13, -31)
    RaidInfoInstanceLabel:SetPoint('BOTTOMRIGHT', RaidInfoIDLabel, 'BOTTOMLEFT', 1,0)

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




local function Init()
    FriendsListFrame.ScrollBox:SetPoint('BOTTOMRIGHT', -24, 30)

    --FriendsFrameBattlenetFrame:ClearAllPoints()
    --FriendsFrameBattlenetFrame:SetPoint('LEFT', FriendsFrameStatusDropdown, 'RIGHT')

    --FriendsFrameBattlenetFrame.BroadcastButton:ClearAllPoints()
    --FriendsFrameBattlenetFrame.BroadcastButton:SetPoint('LEFT', FriendsFrameBattlenetFrame, 'RIGHT')

    hooksecurefunc(FriendsListButtonMixin, 'OnLoad', function(btn)
        btn.name:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
        btn.info:SetPoint('RIGHT', btn.gameIcon, 'LEFT', -2, 0)
    end)

    RecruitAFriendFrame.RecruitList.ScrollBox:SetPoint('BOTTOMRIGHT', -20,0)
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('LEFT')
    RecruitAFriendFrame.RewardClaiming.Background:SetPoint('RIGHT')

    if RaidFrameRaidDescription then--11.2没有了
        RaidFrameRaidDescription:SetPoint('BOTTOMRIGHT', -15, 35)
    end


    RaidFrame:HookScript('OnShow', function(...) Set_RaidFrame_Button_size(...) end)


    WoWTools_MoveMixin:Setup(FriendsFrame, {
        setSize=true,
        minW=338,
        minH=424,
        sizeUpdateFunc=function()
            if RaidFrame:IsShown() and RaidFrame:CanChangeAttribute() then
                Set_RaidFrame_Button_size()
                if RaidGroupFrame_Update then
                    WoWTools_Mixin:Call(RaidGroupFrame_Update)
                end
            end
        end,
        sizeRestFunc=function(btn)
            FriendsFrame:SetSize(338, 424)
            if RaidFrame:IsShown() and RaidFrame:CanChangeAttribute() then
                Set_RaidFrame_Button_size()
                if RaidGroupFrame_Update then
                    WoWTools_Mixin:Call(RaidGroupFrame_Update)
                end
            end
        end
    })


    WoWTools_MoveMixin:Setup(FriendsFriendsFrame)
    WoWTools_MoveMixin:Setup(RecruitAFriendRewardsFrame)
    WoWTools_MoveMixin:Setup(RecruitAFriendFrame.RewardClaiming.Inset, {frame=FriendsFrame})


    Init_RaidInfoFrame()
end







function WoWTools_MoveMixin:Init_FriendsFrame()--好友列表
    Init()
end