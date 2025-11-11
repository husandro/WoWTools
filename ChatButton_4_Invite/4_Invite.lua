

WoWTools_InviteMixin={
    InvPlateGuid={},
    --SummonThxText='谢谢, 拉我'
}
local P_Save={
    InvNoFriend={},
    --LFGListAceInvite=true,--接受,LFD, 邀请
    FriendAceInvite=true,--接受, 好友, 邀请
    InvNoFriendNum=0,--拒绝, 次数
    restingTips=true,--休息区提示
    ChannelText=WoWTools_DataMixin.Player.IsCN and '1' or 'inv',--频道, 邀请, 事件,内容

    Summon= true,--接受, 召唤
    notSummonChat=nil,--不说
    SummonThxText=nil,--自定义THX内容
    SummonThxInRaid=nil,--在团里也说谢谢

    setFrameFun= WoWTools_DataMixin.Player.husandro,--跟随，密语

    setFucus= WoWTools_DataMixin.Player.husandro,--焦点
    overSetFocus= WoWTools_DataMixin.Player.husandro,--移过是，
    focusKey= 'Shift',

}


local function Save()
    return WoWToolsSave['ChatButton_Invite'] or {}
end


function WoWTools_InviteMixin:Get_Leader()--取得权限
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player') or not IsInGroup()
end



























--####
--初始
--####
local function Init(btn)
    btn.texture:SetAtlas('communities-icon-addgroupplus')

    btn.summonTips= btn:CreateTexture(nil,'OVERLAY')--召唤，提示
    btn.summonTips:SetPoint('BOTTOMLEFT', 0, 3)
    btn.summonTips:SetSize(16,16)
    btn.summonTips:SetAtlas('Raid-Icon-SummonPending')

    btn.invTips= btn:CreateTexture(nil,'OVERLAY')--召唤，提示
    btn.invTips:SetPoint('BOTTOMRIGHT', -2, 0)
    btn.invTips:SetSize(16,16)
    btn.invTips:SetAtlas('poi-traveldirections-arrow2')

    function btn:settings()
        self.summonTips:SetShown(Save().Summon)--召唤，提示
        self.invTips:SetShown(Save().Channel and Save().ChannelText or Save().InvTar)
    end

    function btn:set_tooltip()
        self:set_owner()
        GameTooltip:AddDoubleLine(WoWTools_InviteMixin.addName, WoWTools_DataMixin.Icon.left)
        if Save().InvTar then
            GameTooltip:AddLine(WoWTools_DataMixin.onlyChinese and '邀请目标' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, INVITE, TARGET))
        end
        if Save().Channel and Save().ChannelText then
            GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and '频道' or CHANNEL)..'|cnGREEN_FONT_COLOR: '..Save().ChannelText)
        end
        GameTooltip:Show()
    end

    WoWTools_InviteMixin:Setup_Menu(btn)

    function btn:set_OnMouseDown()
        WoWTools_InviteMixin:Inv_All_Unit()--邀请，周围玩家
    end

    btn:settings()





    if (WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3) then
        WoWTools_InviteMixin.SummonThxText = '{rt1}thx{rt1}, sum me'
    elseif WoWTools_DataMixin.Player.Region==5 then
        WoWTools_InviteMixin.SummonThxText= '{rt1}谢谢{rt1}, 拉我'
    else
        WoWTools_InviteMixin.SummonThxText= '{rt1}'..SUMMON..'{rt1} '..VOICEMACRO_16_Dw_1
    end




    Init=function()end
end















local panel= CreateFrame('Frame')
panel:RegisterEvent('ADDON_LOADED')

panel:SetScript('OnEvent', function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['ChatButton_Invite']= WoWToolsSave['ChatButton_Invite'] or P_Save
            P_Save=nil

            WoWTools_InviteMixin.addName= '|A:communities-icon-addgroupplus:0:0|a'..(WoWTools_DataMixin.onlyChinese and '邀请' or INVITE)

            if WoWTools_ChatMixin:CreateButton('Invite', WoWTools_InviteMixin.addName) then
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
                Init(WoWTools_ChatMixin:GetButtonForName('Invite'))
            else
                self:SetScript('OnEvent', nil)
            end

            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_ENTERING_WORLD' then
        WoWTools_InviteMixin:Init_Chanell()--设置,内容,频道, 邀请,事件
        WoWTools_InviteMixin:Init_Focus()--Shift+点击设置焦点
        WoWTools_InviteMixin:Init_Summon()
        WoWTools_InviteMixin:Init_Resting()--设置, 休息区提示事件
        WoWTools_InviteMixin:Init_Target()--设置, 邀请目标
        WoWTools_InviteMixin:Init_StaticPopup()

        self:UnregisterEvent(event)
    end
end)