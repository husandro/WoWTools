

--PVEFrame
function WoWTools_TextureMixin.Events:Blizzard_GroupFinder()
    self:SetTabButton(PVEFrameTab1)
    self:SetTabButton(PVEFrameTab2)
    self:SetTabButton(PVEFrameTab3)
    self:SetTabButton(PVEFrameTab4)

    --地下城和团队副本
    self:SetButton(PVEFrameCloseButton)
    self:HideTexture(PVEFrame.TopTileStreaks)--最上面

    --self:SetNineSlice(PVEFrame)
    self:SetEditBox(LFGListFrame.SearchPanel.SearchBox)
    self:SetScrollBar(LFGListFrame.SearchPanel)
    self:SetNineSlice(LFGListFrame.SearchPanel.ResultsInset)

    self:SetFrame(LFGListFrame.CategorySelection.Inset, {alpha= 0.3})
    self:SetNineSlice(LFGListFrame.CategorySelection.Inset)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.Bg)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.CustomBG)
    self:SetUIButton(LFGListFrame.CategorySelection.FindGroupButton)
    self:SetUIButton(LFGListFrame.CategorySelection.StartGroupButton)

    self:SetFrame(LFGDungeonReadyDialog.Border, {alpha= 0.3})
    self:SetButton(LFGDungeonReadyDialogCloseButton)

    self:SetFrame(LFDRoleCheckPopup.Border, {alpha= 0.3})
    self:SetFrame(LFGDungeonReadyStatus.Border, {alpha= 0.3})
    self:SetButton(LFGDungeonReadyStatusCloseButton)

    self:SetScrollBar(LFDQueueFrameSpecific)
    self:SetCheckBox(LFDQueueFrameRoleButtonTank.checkButton)
    self:SetCheckBox(LFDQueueFrameRoleButtonLeader.checkButton)
    self:SetCheckBox(LFDQueueFrameRoleButtonHealer.checkButton)
    self:SetCheckBox(LFDQueueFrameRoleButtonDPS.checkButton)
    self:SetUIButton(LFDQueueFrameFindGroupButton)
    self:SetUIButton(RaidFinderFrameFindRaidButton)

    self:SetCheckBox(RaidFinderQueueFrameRoleButtonTank.checkButton)
    self:SetCheckBox(RaidFinderQueueFrameRoleButtonLeader.checkButton)
    self:SetCheckBox(RaidFinderQueueFrameRoleButtonHealer.checkButton)
    self:SetCheckBox(RaidFinderQueueFrameRoleButtonDPS.checkButton)


    self:SetNineSlice(LFGListFrame.EntryCreation.Inset)
    self:HideTexture(LFGListFrame.EntryCreation.Inset.CustomBG)
    self:HideTexture(LFGListFrame.EntryCreation.Inset.Bg)
    self:SetUIButton(LFGListFrame.EntryCreation.ListGroupButton)
    self:SetUIButton(LFGListFrame.EntryCreation.CancelButton)
    self:SetEditBox(LFGListFrame.EntryCreation.ItemLevel.EditBox)
    self:SetEditBox(LFGListFrame.EntryCreation.VoiceChat.EditBox)
    self:SetMenu(LFGListEntryCreationGroupDropdown)
    self:SetMenu(LFGListEntryCreationActivityDropdown)
    self:SetMenu(LFGListEntryCreationPlayStyleDropdown)
    self:SetEditBox(LFGListFrame.EntryCreation.Name)
    self:SetFrame(LFGListCreationDescription, {alpha=1})
    self:SetCheckBox(LFGListFrame.EntryCreation.ItemLevel.CheckButton)
    self:SetCheckBox(LFGListFrame.EntryCreation.VoiceChat.CheckButton)
    self:SetCheckBox(LFGListFrame.EntryCreation.PrivateGroup.CheckButton)
    self:SetCheckBox(LFGListFrame.EntryCreation.CrossFactionGroup.CheckButton)

    self:SetCheckBox(LFGListFrame.EntryCreation.PvpItemLevel.CheckButton)
    self:SetEditBox(LFGListFrame.EntryCreation.PvpItemLevel.EditBox)
    self:SetCheckBox(LFGListFrame.EntryCreation.PVPRating.CheckButton)
    self:SetEditBox(LFGListFrame.EntryCreation.PVPRating.EditBox)






    --[[self:SetAlphaColor(LFGListFrameMiddleMiddle)
    self:SetAlphaColor(LFGListFrameMiddleLeft)
    self:SetAlphaColor(LFGListFrameMiddleRight)
    self:SetAlphaColor(LFGListFrameBottomMiddle)
    self:SetAlphaColor(LFGListFrameTopMiddle)
    self:SetAlphaColor(LFGListFrameTopLeft)
    self:SetAlphaColor(LFGListFrameBottomLeft)
    self:SetAlphaColor(LFGListFrameTopRight)
    self:SetAlphaColor(LFGListFrameBottomRight)]]

    self:SetScrollBar(LFGListFrame.ApplicationViewer)
    self:SetNineSlice(LFGListFrame.ApplicationViewer.Inset)
    self:SetAlphaColor(LFGListFrame.ApplicationViewer.InfoBackground)
    self:SetUIButton(LFGListFrame.ApplicationViewer.BrowseGroupsButton)
    self:SetUIButton(LFGListFrame.ApplicationViewer.RemoveEntryButton)
    self:SetButton(LFGListFrame.ApplicationViewer.RefreshButton, {alpha=1})
    self:SetUIButton(LFGListFrame.ApplicationViewer.EditButton)


    self:SetUIButton(LFGListFrame.SearchPanel.ScrollBox.StartGroupButton)
    self:SetUIButton(LFGListFrame.SearchPanel.BackToGroupButton)
    self:SetUIButton(LFGListFrame.SearchPanel.BackButton)
    self:SetUIButton(LFGListFrame.SearchPanel.SignUpButton)
    self:SetButton(LFGListFrame.SearchPanel.RefreshButton, {alpha=1})



    self:SetAlphaColor(RaidFinderQueueFrameBackground)
    self:SetMenu(RaidFinderQueueFrameSelectionDropdown)

    self:HideTexture(RaidFinderFrameRoleBackground)

    self:SetNineSlice(LFGListFrame.NothingAvailable.Inset)

    --右边
    self:HideFrame(PVEFrame)
    --self:HideTexture(PVEFrameBg)--左边


    self:HideTexture(PVEFrameBlueBg)
    self:HideTexture(PVEFrameLeftInset.Bg)
    self:SetNineSlice(PVEFrameLeftInset)
    self:HideFrame(PVEFrame.shadows)

    self:SetAlphaColor(LFDQueueFrameBackground, nil, nil, 0.3)

    self:SetMenu(LFDQueueFrameTypeDropdown)
    LFDQueueFrameTypeDropdownName:ClearAllPoints()
    LFDQueueFrameTypeDropdownName:SetPoint('BOTTOMLEFT', LFDQueueFrameRandomScrollFrame, 'TOPLEFT', 0, 15)
    LFDQueueFrameTypeDropdownName:SetWidth(LFDQueueFrameTypeDropdownName:GetStringWidth()+4)



    self:SetMenu(LFGListFrame.SearchPanel.FilterButton)

    self:SetNineSlice(LFDParentFrameInset)
    self:HideTexture(LFDParentFrameInset.Bg)
    self:SetNineSlice(RaidFinderFrameBottomInset)
    self:HideTexture(RaidFinderFrameBottomInset.Bg)

    self:SetAlphaColor(LFDParentFrameRoleBackground)

    self:HideTexture(LFDParentFrameRoleBackground)
    self:SetNineSlice(RaidFinderFrameRoleInset)
    self:HideTexture(RaidFinderFrameRoleInset.Bg)

    for i=1, 5 do
        local b= _G['GroupFinderFrameGroupButton'..i]
        if b then
            self:SetAlphaColor(b.bg, nil, nil, 0.5)
        end
    end

    WoWTools_DataMixin:Hook('LFGListCategorySelection_AddButton', function(frame, btnIndex)
        local btn = frame.CategoryButtons[btnIndex]
        if btn then
            self:SetAlphaColor(btn.Icon, nil, nil, 0.5)
            self:HideTexture(btn.Cover)
        end
    end)

    self:SetFrame(LFGListFrame.EntryCreation.ActivityFinder.Dialog.Border, {alpha=0})
    --self:SetAlphaColor(LFGListFrame.EntryCreation.ActivityFinder.Dialog.Bg, nil, true)
    LFGListFrame.EntryCreation.ActivityFinder.Dialog.Bg:SetColorTexture(0,0,0,0.75)
    self:SetEditBox(LFGListFrame.EntryCreation.ActivityFinder.Dialog.EntryBox)
    self:SetScrollBar(LFGListFrame.EntryCreation.ActivityFinder.Dialog)
    self:SetNineSlice(LFGListFrame.EntryCreation.ActivityFinder.Dialog.BorderFrame, 1)

    self:Init_BGMenu_Frame(PVEFrame)
end













--地下城和团队副本, PVP
function WoWTools_TextureMixin.Events:Blizzard_PVPUI()

    self:HideTexture(HonorFrame.Inset.Bg)
    self:SetNineSlice(HonorFrame.Inset)
    HonorFrame.BonusFrame.WorldBattlesTexture:SetAlpha(0)
    HonorFrame.BonusFrame.ShadowOverlay:SetAlpha(0)



    self:HideTexture(HonorFrame.ConquestBar.Background)
    self:SetNineSlice(PVPQueueFrame.HonorInset)--最右边

    self:SetNineSlice(ConquestFrame.Inset)--中间
    self:HideTexture(ConquestFrame.Inset.Bg)
    self:HideTexture(ConquestFrameLeft)
    self:HideTexture(ConquestFrameRight)
    self:HideTexture(ConquestFrameTopRight)
    self:HideTexture(ConquestFrameTop)
    self:HideTexture(ConquestFrameTopLeft)
    self:HideTexture(ConquestFrameBottomLeft)
    self:HideTexture(ConquestFrameBottom)
    self:HideTexture(ConquestFrameBottomRight)
    self:SetAlphaColor(ConquestFrame.RatedBGTexture)
    PVPQueueFrame.HonorInset:DisableDrawLayer('BACKGROUND')
    self:SetAlphaColor(PVPQueueFrame.HonorInset.CasualPanel.HonorLevelDisplay.Background)
    self:HideTexture(ConquestFrame.RatedBGTexture)

    for i=1, 4 do
        local b=PVPQueueFrame['CategoryButton'..i]--12.0才有
        if b then
            self:SetAlphaColor(b.Background, nil, nil, 0.5)
        end
    end

--12.0才有
    self:SetNineSlice(TrainingGroundsFrame.Inset)
    self:HideTexture(TrainingGroundsFrame.BonusTrainingGroundList.WorldBattlesTexture)
    self:HideFrame(TrainingGroundsFrame.BonusTrainingGroundList.ShadowOverlay)
    self:SetUIButton(TrainingGroundsFrame.QueueButton)
    self:HideTexture(TrainingGroundsFrame.Inset.Bg)

--职责，CheckBox
    for _, name in pairs({
        'HonorFrame',
        'TrainingGroundsFrame',
        'ConquestFrame',
    }) do
        if _G[name] and _G[name].RoleList then
            self:SetCheckBox(_G[name].RoleList.TankIcon.checkButton)
            self:SetCheckBox(_G[name].RoleList.HealerIcon.checkButton)
            self:SetCheckBox(_G[name].RoleList.DPSIcon.checkButton)
        end
    end
end
















--挑战, 钥匙插入，界面
function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI()
    self:HideFrame(ChallengesFrame)
    self:HideTexture(ChallengesFrame.Background)
    ChallengesFrame.Background:ClearAllPoints()
    self:HideTexture(ChallengesFrameInset.Bg)
    self:SetNineSlice(ChallengesFrameInset)
    self:HideTexture(ChallengesFrame.WeeklyInfo.Child.RuneBG)

--钥匙插入，界面
    self:SetAlphaColor(ChallengesKeystoneFrame.Divider, true)
    self:SetUIButton(ChallengesKeystoneFrame.StartButton)
    self:SetButton(ChallengesKeystoneFrame.CloseButton)
    self:HideFrame(ChallengesKeystoneFrame, {index=1})
    self:HideTexture(ChallengesKeystoneFrame.InstructionBackground)
    WoWTools_DataMixin:Hook(ChallengesKeystoneFrame, 'Reset', function(frame)
        self:HideTexture(frame, {index=1})
        self:HideTexture(frame.InstructionBackground)
    end)


    self:Init_BGMenu_Frame(ChallengesKeystoneFrame, {
        isNewButton=ChallengesKeystoneFrame.CloseButton,
        newButtonPoint=function(btn)
            btn:SetPoint('RIGHT', ChallengesKeystoneFrame.CloseButton, 'LEFT', -23, 0)
        end
    })
end



















function WoWTools_TextureMixin.Events:Blizzard_WeeklyRewards()--周奖励提示
    self:HideFrame(WeeklyRewardsFrame)
    self:SetButton(WeeklyRewardsFrame.CloseButton)

    WoWTools_DataMixin:Hook(WeeklyRewardsFrame, 'UpdateOverlay', function(f)
        f= f.Overlay
        if not f or not f:IsShown() then
            return
        end
        self:SetNineSlice(f)
        self:SetFrame(f)
    end)

    WoWTools_DataMixin:Hook(WeeklyRewardsFrame,'UpdateSelection', function(frame)
        for _, f in ipairs(frame.Activities) do
            self:SetAlphaColor(f.Background)
        end
    end)

    self:Init_BGMenu_Frame(WeeklyRewardsFrame, {
        isNewButton=true,
        newButtonAlpha=1,
        newButtonPoint=function(btn)
            btn:SetPoint('TOPLEFT', 10, -10)
        end,
        bgPoint=function(icon)
            icon:SetPoint('TOPLEFT', 10, -10)
            icon:SetPoint('BOTTOMRIGHT', -10, 10)
        end
    })
end
