local e= select(2, ...)
--确定，进入副本


local function Show_LFGDungeonReadyPopup()
    if GetLFGProposal() and not LFGDungeonReadyPopup:IsShown() then
        StaticPopupSpecial_Show(LFGDungeonReadyPopup)
        WoWTools_Mixin:Call(LFGDungeonReadyPopup_Update)
    end
end




local function Init()
    if LFGDungeonReadyDialog.bossTipsLabel then
        Show_LFGDungeonReadyPopup()
        return

    end

    LFGInvitePopup:HookScript("OnShow", function(self)--自动进入FB
        WoWTools_Mixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self, nil, self.timeOut and STATICPOPUP_TIMEOUT, nil, true, true)
    end)

    LFGDungeonReadyDialog:HookScript("OnShow", function(self)--自动进入FB
        WoWTools_Mixin:PlaySound()--播放, 声音
        WoWTools_CooldownMixin:Setup(self, nil, LFGInvitePopup.timeOut and LFGInvitePopup.timeOut or 38, nil, true, true)
    end)

--禁用
    if WoWTools_LFDMixin.Save.disabledLFGDungeonReadyDialog then
        return
    end

--确定，进入副本
    WoWTools_MoveMixin:Setup(LFGDungeonReadyPopup, {
        notFuori=true,
        setResizeButtonPoint={'BOTTOMRIGHT', LFGDungeonReadyPopup, 6, -6},
    restPointFunc=function(btn)
        btn.targetFrame:ClearAllPoints()
        btn.targetFrame:SetPoint('TOP', UIParent, 'TOP', 0, -135)
    end})
    WoWTools_MoveMixin:Setup(LFGDungeonReadyDialog, {frame=LFGDungeonReadyPopup, notFuori=true})
    WoWTools_MoveMixin:Setup(LFGDungeonReadyStatus, {frame=LFGDungeonReadyPopup, notFuori=true})

    LFGDungeonReadyDialog.bossTipsLabel= WoWTools_LabelMixin:Create(LFGDungeonReadyDialog)
    LFGDungeonReadyDialog.bossTipsLabel:SetPoint('LEFT', LFGDungeonReadyDialog, 'RIGHT', 4, 0)

    LFGDungeonReadyDialog:HookScript('OnHide', function(self)
        self.bossTipsLabel:SetText('')
    end)

    LFGDungeonReadyDialog:HookScript('OnShow', function(self)
        local numBosses = select(9, GetLFGProposal()) or 0
        local isHoliday = select(13, GetLFGProposal())
        if numBosses == 0 or isHoliday or WoWTools_LFDMixin.Save.disabledLFGDungeonReadyDialog then
            self.bossTipsLabel:SetText('')
            return
        end

        local text
        local dead=0
        for i=1, numBosses do
            local bossName, _, isKilled = GetLFGProposalEncounter(i)
            if bossName then
                text= (text and text..'|n' or '')..i..') '

                if isKilled then
                    text= text
                        ..'|A:common-icon-checkmark:0:0|a|cnRED_FONT_COLOR:'..e.cn(bossName)
                        ..'|r |cffffffff'..(WoWTools_Mixin.onlyChinese and '已消灭' or BOSS_DEAD)..'|r'
                    dead= dead+1
                else
                    text= text
                        ..'|A:QuestLegendary:0:0|a|cnGREEN_FONT_COLOR:'..e.cn(bossName)
                        ..'|r |cffffffff'..(WoWTools_Mixin.onlyChinese and '可消灭' or BOSS_ALIVE)..'|r'
                end
            end
        end

        if text then
            text= (numBosses==dead and '|cff9e9e9e' or '|cffffffff')
                ..(WoWTools_Mixin.onlyChinese and '首领：' or BOSSES)
                ..format(WoWTools_Mixin.onlyChinese and '已消灭%d/%d个首领' or BOSSES_KILLED, dead, numBosses)
                ..'|r|n|n'
                ..text
                ..'|n|n'..WoWTools_ChatMixin.addName..' '..WoWTools_LFDMixin.addName
        end
        self.bossTipsLabel:SetText(text or '')
    end)


    LFGDungeonReadyDialogCloseButton:HookScript('OnLeave', GameTooltip_Hide)
    LFGDungeonReadyDialogCloseButton:HookScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(WoWTools_Mixin.onlyChinese and '隐藏' or HIDE)
        GameTooltip:Show()
    end)

    Menu.ModifyMenu("MENU_QUEUE_STATUS_FRAME", function(_, root)
        WoWTools_LFDMixin:ShowMenu_LFGDungeonReadyDialog(root)--显示 LFGDungeonReadyDialog
    end)


    Show_LFGDungeonReadyPopup()
end








function WoWTools_LFDMixin:Init_LFGDungeonReadyDialog()
    Init()
end
