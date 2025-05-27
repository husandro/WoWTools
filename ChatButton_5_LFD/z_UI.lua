


--地下城和团队副本
local function Save()
    return WoWToolsSave['Plus_Move']
end



--GroupFinderFrame
function WoWTools_MoveMixin.Events:Blizzard_GroupFinder()
   LFGListPVEStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.CategorySelection.Inset.CustomBG:SetPoint('BOTTOMRIGHT')

    hooksecurefunc('GroupFinderFrame_SelectGroupButton', function(index)
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or not PVEFrame:IsProtected() then
            return
        end
        if index==3 then
            btn.setSize= true
            local size= Save().size['PVEFrame_PVE']
            if size then
                PVEFrame:SetSize(size[1], size[2])
                return
            end
        else
            btn.setSize= false
        end
        PVEFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
        LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -20, 0)
    end)


    self:Setup(PVEFrame, {
        setSize=true,
        minW=563,
        minH=428,
        sizeUpdateFunc=function()
            if PVEFrame.activeTabIndex==3 then
                WoWTools_Mixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end, sizeStopFunc=function(btn)
            if PVEFrame.activeTabIndex==1 then
                Save().size['PVEFrame_PVE']= {btn.targetFrame:GetSize()}
            elseif PVEFrame.activeTabIndex==2 then
                if PVPQueueFrame.selection==LFGListPVPStub then
                    Save().size['PVEFrame_PVP']= {btn.targetFrame:GetSize()}
                end
            elseif PVEFrame.activeTabIndex==3 then
                Save().size['PVEFrame_KEY']= {btn.targetFrame:GetSize()}
            end
        end, sizeRestFunc=function(btn)
            if PVEFrame.activeTabIndex==1 then
                Save().size['PVEFrame_PVE']=nil
                btn.targetFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            elseif PVEFrame.activeTabIndex==2 then--Blizzard_PVPUI.lua
                Save().size['PVEFrame_PVP']=nil
                local width = PVE_FRAME_BASE_WIDTH;
                width = width + PVPQueueFrame.HonorInset:Update();
                btn.targetFrame:SetSize(width, 428)
            elseif PVEFrame.activeTabIndex==3 then
                Save().size['PVEFrame_KEY']=nil
                btn.targetFrame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
                WoWTools_Mixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end
    })

    --自定义，副本，创建，更多...
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:ClearAllPoints()
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('TOPLEFT',0, -30)
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('BOTTOMRIGHT')
end












--PVEFrame
function WoWTools_TextureMixin.Events:Blizzard_GroupFinder()
    self:SetTabButton(PVEFrameTab1)
    self:SetTabButton(PVEFrameTab2)
    self:SetTabButton(PVEFrameTab3)
    self:SetTabButton(PVEFrameTab4)

    --地下城和团队副本
    self:SetButton(PVEFrameCloseButton, {all=true})
    self:HideTexture(PVEFrame.TopTileStreaks)--最上面
    self:SetNineSlice(PVEFrame, true)
    self:SetEditBox(LFGListFrame.SearchPanel.SearchBox)
    self:SetScrollBar(LFGListFrame.SearchPanel)
    self:SetNineSlice(LFGListFrame.SearchPanel.ResultsInset, nil, true)

    self:SetFrame(LFGListFrame.CategorySelection.Inset, {alpha= 0.3})
    self:SetNineSlice(LFGListFrame.CategorySelection.Inset, nil, true)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.Bg)
    self:HideTexture(LFGListFrame.CategorySelection.Inset.CustomBG)

    self:SetFrame(LFGDungeonReadyDialog.Border, {alpha= 0.3})
    self:SetFrame(LFDRoleCheckPopup.Border, {alpha= 0.3})
    self:SetFrame(LFGDungeonReadyStatus.Border, {alpha= 0.3})

    self:SetScrollBar(LFDQueueFrameSpecific)


    self:SetNineSlice(LFGListFrame.EntryCreation.Inset, nil, true)
    self:HideTexture(LFGListFrame.EntryCreation.Inset.CustomBG)
    self:HideTexture(LFGListFrame.EntryCreation.Inset.Bg)

    self:SetMenu(LFGListEntryCreationGroupDropdown)
    self:SetMenu(LFGListEntryCreationActivityDropdown)
    self:SetEdit(LFGListFrame.EntryCreation.Name)
    self:SetEdit(LFGListCreationDescription.EditBox)

    self:SetAlphaColor(LFGListFrameMiddleMiddle)
    self:SetAlphaColor(LFGListFrameMiddleLeft)
    self:SetAlphaColor(LFGListFrameMiddleRight)
    self:SetAlphaColor(LFGListFrameBottomMiddle)
    self:SetAlphaColor(LFGListFrameTopMiddle)
    self:SetAlphaColor(LFGListFrameTopLeft)
    self:SetAlphaColor(LFGListFrameBottomLeft)
    self:SetAlphaColor(LFGListFrameTopRight)
    self:SetAlphaColor(LFGListFrameBottomRight)

    self:SetScrollBar(LFGListFrame.ApplicationViewer)
    self:SetNineSlice(LFGListFrame.ApplicationViewer.Inset)

    self:SetAlphaColor(RaidFinderQueueFrameBackground)

    self:HideTexture(RaidFinderFrameRoleBackground)


    --右边
    self:HideTexture(PVEFrameLLVert)
    self:HideTexture(PVEFrameRLVert)
    self:HideTexture(PVEFrameBLCorner)
    self:HideTexture(PVEFrameBottomLine)
    self:HideTexture(PVEFrameBRCorner)
    self:HideTexture(PVEFrameTLCorner)
    self:HideTexture(PVEFrameTopLine)
    self:HideTexture(PVEFrameTRCorner)


    self:SetAlphaColor(PVEFrameBg)--左边


    self:HideTexture(PVEFrameBlueBg)
    self:HideTexture(PVEFrameLeftInset.Bg)
    self:SetNineSlice(PVEFrameLeftInset, nil, true)
    self:HideFrame(PVEFrame.shadows)

    self:SetAlphaColor(LFDQueueFrameBackground)
    self:SetMenu(LFDQueueFrameTypeDropdown)
    self:SetMenu(LFGListFrame.SearchPanel.FilterButton)

    self:SetNineSlice(LFDParentFrameInset, nil, true)
    self:HideTexture(LFDParentFrameInset.Bg)
    self:SetNineSlice(RaidFinderFrameBottomInset, nil, true)
    self:SetAlphaColor(RaidFinderFrameBottomInset.Bg)

    self:SetAlphaColor(LFDParentFrameRoleBackground)

    self:HideTexture(LFDParentFrameRoleBackground)
    self:SetNineSlice(RaidFinderFrameRoleInset, nil, true)
    self:HideTexture(RaidFinderFrameRoleInset.Bg)
end























--地下城和团队副本, PVP
function WoWTools_MoveMixin.Events:Blizzard_PVPUI()
    PVPUIFrame:SetPoint('BOTTOMRIGHT')
    LFGListPVPStub:SetPoint('BOTTOMRIGHT')
    LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)

    hooksecurefunc('PVPQueueFrame_ShowFrame', function()
        local btn= PVEFrame.ResizeButton
        if not btn or btn.disabledSize or WoWTools_FrameMixin:IsLocked(PVEFrame) then
            return
        end
        if PVPQueueFrame.selection==LFGListPVPStub then
            btn.setSize= true
            local size= Save().size['PVEFrame_PVP']
            if size then
                PVEFrame:SetSize(size[1], size[2])
                return
            end
        else
            btn.setSize= false
        end
        PVEFrame:SetHeight(428)
    end)
end



--地下城和团队副本, PVP
function WoWTools_TextureMixin.Events:Blizzard_PVPUI()
    self:HideTexture(HonorFrame.Inset.Bg)

    self:SetNineSlice(HonorFrame.Inset, nil, true)
    HonorFrame.BonusFrame.WorldBattlesTexture:SetAlpha(0)
    HonorFrame.BonusFrame.ShadowOverlay:SetAlpha(0)

    self:HideTexture(HonorFrame.ConquestBar.Background)
    self:SetNineSlice(PVPQueueFrame.HonorInset, nil, true)--最右边

    self:SetNineSlice(ConquestFrame.Inset, nil, true)--中间
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

end


























--挑战, 钥匙插件, 界面

function WoWTools_MoveMixin.Events:Blizzard_ChallengesUI()
    self:Setup(ChallengesKeystoneFrame)

    --if not Save().disabledZoom then
        ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
        ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
        ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
        for _, region in pairs({ChallengesFrame:GetRegions()}) do
            if region:GetObjectType()=='Texture' then
                region:SetPoint('BOTTOMRIGHT')
            end
        end
        ChallengesFrame:HookScript('OnShow', function()
            local frame= PVEFrame
            if not frame.ResizeButton or frame.ResizeButton.disabledSize or not frame:CanChangeAttribute() then
                return
            end
            local size= WoWToolsSave['Plus_Move'].size['PVEFrame_KEY']
            frame.ResizeButton.setSize= true
            if size then
                frame:SetSize(size[1], size[2])
            else
                frame:SetSize(PVE_FRAME_BASE_WIDTH, 428)
            end
        end)
    --end
end







--挑战, 钥匙插入， 界面
function WoWTools_TextureMixin.Events:Blizzard_ChallengesUI()
    self:SetButton(ChallengesKeystoneFrame.CloseButton, {all=true})
    self:SetAlphaColor(ChallengesFrameInset.Bg)

    self:SetNineSlice(ChallengesFrameInset)
    self:SetFrame(ChallengesKeystoneFrame, {index=1})
    self:HideTexture(ChallengesKeystoneFrame.InstructionBackground)

    hooksecurefunc(ChallengesKeystoneFrame, 'Reset', function(frame)--钥匙插入， 界面
        self:SetFrame(frame, {index=1})
        self:HideTexture(frame.InstructionBackground)
    end)
end






















--地下堡
function WoWTools_TextureMixin.Events:Blizzard_DelvesDashboardUI()
    self:SetAlphaColor(DelvesDashboardFrame.DashboardBackground, nil, nil, 0.3)
end

--地下堡
function WoWTools_MoveMixin.Events:Blizzard_DelvesDashboardUI()
    self:Setup(DelvesDashboardFrame, {frame=PVEFrame})
    self:Setup(DelvesDashboardFrame.ButtonPanelLayoutFrame, {frame=PVEFrame})
    self:Setup(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel, {frame=PVEFrame})
end