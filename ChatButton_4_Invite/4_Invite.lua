local id, e = ...


WoWTools_InviteMixin={
Save={
    InvNoFriend={},
    --LFGListAceInvite=true,--接受,LFD, 邀请
    FriendAceInvite=true,--接受, 好友, 邀请
    InvNoFriendNum=0,--拒绝, 次数
    restingTips=true,--休息区提示
    ChannelText=e.Player.cn and '1' or 'inv',--频道, 邀请, 事件,内容

    Summon= true,--接受, 召唤
    notSummonChat=nil,--不说
    SummonThxText=nil,--自定义THX内容
    SummonThxInRaid=nil,--在团里也说谢谢

    setFrameFun= e.Player.husandro,--跟随，密语

    setFucus= e.Player.husandro,--焦点
    overSetFocus= e.Player.husandro,--移过是，
    focusKey= 'Shift',

},
InviteButton=nil,
RestingFrame=nil,
InvTargetFrame=nil,
InvChanellFrame=nil,

InvPlateGuid={},
SummonThxText='谢谢, 拉我'
}


local function Save()
    return WoWTools_InviteMixin.Save
end


function WoWTools_InviteMixin:Get_Leader()--取得权限
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end



























--####
--初始
--####
local function Init()
    local InviteButton= WoWTools_InviteMixin.InviteButton
    if not InviteButton then
        return
    end

    InviteButton.texture:SetAtlas('communities-icon-addgroupplus')

    InviteButton.summonTips= InviteButton:CreateTexture(nil,'OVERLAY')--召唤，提示
    InviteButton.summonTips:SetPoint('BOTTOMLEFT', 0, 3)
    InviteButton.summonTips:SetSize(16,16)
    InviteButton.summonTips:SetAtlas('Raid-Icon-SummonPending')

    InviteButton.invTips= InviteButton:CreateTexture(nil,'OVERLAY')--召唤，提示
    InviteButton.invTips:SetPoint('BOTTOMRIGHT', -2, 0)
    InviteButton.invTips:SetSize(16,16)
    InviteButton.invTips:SetAtlas('poi-traveldirections-arrow2')

    function InviteButton:settings()
        self.summonTips:SetShown(Save().Summon)--召唤，提示
        self.invTips:SetShown(Save().Channel and Save().ChannelText or Save().InvTar)
    end

    function InviteButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(WoWTools_InviteMixin.addName, e.Icon.left)
        if Save().InvTar then
            e.tips:AddLine(e.onlyChinese and '邀请目标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, TARGET))
        end
        if Save().Channel and Save().ChannelText then
            e.tips:AddLine((e.onlyChinese and '频道' or CHANNEL)..'|cnGREEN_FONT_COLOR: '..Save().ChannelText)
        end
        e.tips:Show()
    end

    InviteButton:SetupMenu(function(...)
        WoWTools_InviteMixin:Init_Menu(...)
    end)

    function InviteButton:set_OnMouseDown()
        WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
    end
    --[[InviteButton:SetScript('OnMouseDown',function(self, d)
        if d=='LeftButton' then
            WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
            self:CloseMenu()
            self:set_tooltip()
        end
    end)

    
    InviteButton:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
        else
            WoWTools_InviteMixin:Init_Menu(self)
        end
    end)

    InviteButton:SetScript('OnLeave', function(self)
        e.tips:Hide()
        self:state_leave()
    end)
    InviteButton:SetScript('OnEnter', function(self)
        self:set_tooltip()
        self:state_enter()
    end)]]

    InviteButton:settings()



    WoWTools_InviteMixin:Init_Chanell()--设置,内容,频道, 邀请,事件
    WoWTools_InviteMixin:Init_Target()--设置, 邀请目标
    WoWTools_InviteMixin:Init_Focus()--Shift+点击设置焦点
    WoWTools_InviteMixin:Init_Summon()
    WoWTools_InviteMixin:Init_Resting()--设置, 休息区提示事件

    --hooksecurefunc(StaticPopupDialogs["CONFIRM_SUMMON"], "OnUpdate", Init_CONFIRM_SUMMON)




    if (e.Player.region==1 or e.Player.region==3) then
        WoWTools_InviteMixin.SummonThxText = '{rt1}thx{rt1}, sum me'
    elseif e.Player.region==5 then
        WoWTools_InviteMixin.SummonThxText= '{rt1}谢谢{rt1}, 拉我'
    else
        WoWTools_InviteMixin.SummonThxText= '{rt1}'..SUMMON..'{rt1} '..VOICEMACRO_16_Dw_1
    end
end



















EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", function(_, arg1)
    if arg1~=id then
        return
    end

    WoWTools_InviteMixin.Save= WoWToolsSave['ChatButton_Invite'] or WoWTools_InviteMixin.Save

    WoWTools_InviteMixin.addName= '|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '邀请' or INVITE)

    local btn= WoWTools_ChatButtonMixin:CreateButton('Invite', WoWTools_InviteMixin.addName)
    WoWTools_InviteMixin.InviteButton= btn

    if WoWTools_InviteMixin.InviteButton then
        Init()
    end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
    if not e.ClearAllSave then
        WoWToolsSave['ChatButton_Invite']= WoWTools_InviteMixin.Save
    end
end)
