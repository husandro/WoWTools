local function Is_Locked()
    return WoWTools_FrameMixin:IsLocked(PVEFrame)
end
local function Get_Index()
    return PVEFrame.activeTabIndex or 1
end
local function Set_Width(w)
    PVE_FRAME_BASE_WIDTH= w or 563
end

--地下城和团队副本 GroupFinderFrame
function WoWTools_MoveMixin.Events:Blizzard_GroupFinder()
    LFGListPVEStub:SetPoint('BOTTOMRIGHT')
    LFDParentFrame:SetPoint('BOTTOMRIGHT')

    LFDQueueFrameRandomScrollFrame:SetPoint('TOPLEFT', 5, -146)
    LFDQueueFrameRandomScrollFrameChildFrame:SetPoint('RIGHT', -12, 0)
    LFDQueueFrameRandomScrollFrameChildFrameDescription:SetPoint('RIGHT', -12, 0)
    LFDQueueFrameTypeDropdown:ClearAllPoints()
    LFDQueueFrameTypeDropdown:SetPoint('TOPRIGHT', -8, -115)
    LFDQueueFrameTypeDropdown:SetPoint('LEFT', LFDQueueFrameTypeDropdownName:GetStringWidth()+12, 0)
    LFDQueueFrameTypeDropdownName:ClearAllPoints()--<Anchor point="TOPLEFT" x="5" y="-146"/>
    LFDQueueFrameTypeDropdownName:SetPoint('RIGHT', LFDQueueFrameTypeDropdown, 'LEFT')

    LFDQueueFrameBackground:ClearAllPoints()

    LFDQueueFrameRoleButtonTank:ClearAllPoints()
    LFDQueueFrameRoleButtonTank:SetPoint('TOPLEFT', 35, -35)
    LFDParentFrameRoleBackground:ClearAllPoints()
    LFDParentFrameRoleBackground:SetPoint('TOPLEFT', LFDQueueFrameRoleButtonTank, -30, 10)
    PVEFrameBlueBg:SetPoint('BOTTOM')
    PVEFrame.shadows:SetPoint('BOTTOM')
    for _, icon in pairs({PVEFrame.shadows:GetRegions()}) do
        if icon:IsObjectType('Texture') then
            icon:SetPoint('BOTTOM')
        end
    end

    LFDParentFrameInset:ClearAllPoints()
    --LFDParentFrameInset:SetAllPoints(LFDQueueFrameRandomScrollFrame)
    LFDParentFrameInset:SetPoint('TOPLEFT', LFDQueueFrameRandomScrollFrame)
    LFDParentFrameInset:SetPoint('BOTTOMRIGHT', LFDQueueFrameRandomScrollFrame, 16, 0)



    RaidFinderFrame:SetPoint('BOTTOMRIGHT', -12, 12)
    RaidFinderQueueFrame:SetPoint('BOTTOMRIGHT')
    RaidFinderQueueFrameScrollFrame:SetPoint('TOPLEFT', 5, -146)
    RaidFinderQueueFrameSelectionDropdown:ClearAllPoints()
    RaidFinderQueueFrameSelectionDropdown:SetPoint('TOPRIGHT', -8, -115)
    RaidFinderQueueFrameSelectionDropdown:SetPoint('LEFT', RaidFinderQueueFrameSelectionDropdownName:GetStringWidth()+12, 0)
    RaidFinderQueueFrameScrollFrameChildFrame:SetPoint('RIGHT', -12, 0)
    RaidFinderQueueFrameScrollFrameChildFrameDescription:SetPoint('RIGHT', -24, 0)
    RaidFinderQueueFrameBackground:ClearAllPoints()
    RaidFinderQueueFrameRoleButtonTank:ClearAllPoints()
    RaidFinderQueueFrameRoleButtonTank:SetPoint('TOPLEFT', 35, -35)

    --自定义，副本，创建，更多...
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:ClearAllPoints()
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('TOPLEFT',0, -30)
    LFGListFrame.EntryCreation.ActivityFinder.Dialog:SetPoint('BOTTOMRIGHT')

    LFGListFrame.CategorySelection.Inset.CustomBG:SetPoint('BOTTOMRIGHT')
    LFGListFrame.EntryCreation.Inset.CustomBG:SetPoint('BOTTOMRIGHT')
    LFGListFrame.ApplicationViewer.InfoBackground:SetPoint('RIGHT', -2,0)

--免费试玩账号无法使用该功能
    LFGListFrame.NothingAvailable.Inset.CustomBG:SetPoint('BOTTOMRIGHT', -15, 0)

    WoWTools_DataMixin:Hook('PVEFrame_ShowFrame', function()
        if Is_Locked() then
            return
        end
        local index= Get_Index()
        local s= self:Save().size['PVEFrame'..index]
        if s and s[1] and s[2] then
            PVEFrame:SetSize(s[1], s[2])
            PVE_FRAME_BASE_WIDTH = s[1]
            if index==3 then
                WoWTools_DataMixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end
    end)
    self:Setup(PVEFrame, {
        minW=563,
        minH=428,
        initFunc=function()
            local s= self:Save().size['PVEFrame'..Get_Index()]
            Set_Width(s and s[1])
        end,
        sizeUpdateFunc=function()
            if Is_Locked() then
                return
            end
            if PVEFrame.activeTabIndex==3 then
                WoWTools_DataMixin:Call(ChallengesFrame.Update, ChallengesFrame)
            end
        end, sizeStopFunc=function()
            local w, h= PVEFrame:GetSize()
            self:Save().size['PVEFrame'..Get_Index()]= {w, h}
            Set_Width(w)
        end, sizeRestFunc=function()
            for index=1,5 do
                self:Save().size['PVEFrame'..index]=nil
            end
            Set_Width()

            if Is_Locked() then
                return
            end

            local index= Get_Index()
            if index==3 then
                PVEFrame:SetSize(950, 717)
                if ChallengesFrame then
                    WoWTools_DataMixin:Call(ChallengesFrame.Update, ChallengesFrame)
                end
            else
                PVEFrame:SetSize(563, 428)
            end
        end
    })

--预创建队伍，更多副本，列表
    self:Setup(LFGListFrame.EntryCreation.ActivityFinder.Dialog, {frame=PVEFrame})


--确定，进入副本
    self:Setup(LFGDungeonReadyPopup, {
        setResizeButtonPoint={'BOTTOMRIGHT', LFGDungeonReadyPopup, 6, -6},
    restPointFunc=function()
        LFGDungeonReadyPopup:ClearAllPoints()
        LFGDungeonReadyPopup:SetPoint('TOP', UIParent, 'TOP', 0, -135)
    end})
    self:Setup(LFGDungeonReadyDialog, {frame=LFGDungeonReadyPopup})
    self:Setup(LFGDungeonReadyStatus, {frame=LFGDungeonReadyPopup})
end









--地下城和团队副本, PVP
function WoWTools_MoveMixin.Events:Blizzard_PVPUI()
    PVPUIFrame:SetPoint('BOTTOMRIGHT')
    LFGListPVPStub:SetPoint('BOTTOMRIGHT')

    HonorFrame:SetPoint('BOTTOMRIGHT', PVPQueueFrame.HonorInset, 'BOTTOMLEFT')
    HonorFrame.BonusFrame.WorldBattlesTexture:ClearAllPoints()
    HonorFrame.BonusFrame.WorldBattlesTexture:SetAllPoints()

    ConquestFrame:SetPoint('BOTTOMRIGHT', PVPQueueFrame.HonorInset, 'BOTTOMLEFT')
    ConquestFrame.RatedBGTexture:ClearAllPoints()
    ConquestFrame.RatedBGTexture:SetAllPoints(ConquestFrame)
    PVPQueueFrame.NewSeasonPopup:ClearAllPoints()
    PVPQueueFrame.NewSeasonPopup:SetAllPoints(ConquestFrame)

    PVEFrameBlueBg:SetPoint('BOTTOM')
    PVPQueueFrame.HonorInset.Background:SetPoint('BOTTOM')
end







--挑战, 钥匙插件, 界面
function WoWTools_MoveMixin.Events:Blizzard_ChallengesUI()
    self:Setup(ChallengesKeystoneFrame)

    ChallengesFrame.WeeklyInfo:SetPoint('BOTTOMRIGHT')
    ChallengesFrame.WeeklyInfo.Child:SetPoint('BOTTOMRIGHT')
    ChallengesFrame.WeeklyInfo.Child.RuneBG:SetPoint('BOTTOMRIGHT')
    for _, region in pairs({ChallengesFrame:GetRegions()}) do
        if region:IsObjectType('Texture') then
            region:SetPoint('BOTTOMRIGHT')
        end
    end
end











--地下堡
function WoWTools_MoveMixin.Events:Blizzard_DelvesDashboardUI()
    DelvesDashboardFrame.ButtonPanelLayoutFrame:ClearAllPoints()
    DelvesDashboardFrame.ButtonPanelLayoutFrame:SetPoint('CENTER', 0, -62)--, 0, -130)
    --DelvesDashboardFrame.ButtonPanelLayoutFrame:SetPoint('TOP', 0, -130)
    self:Setup(DelvesDashboardFrame, {frame=PVEFrame})
    self:Setup(DelvesDashboardFrame.ButtonPanelLayoutFrame, {frame=PVEFrame})
    self:Setup(DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel, {frame=PVEFrame})
end

function WoWTools_MoveMixin.Events:Blizzard_DelvesDifficultyPicker()
    self:Setup(DelvesDifficultyPickerFrame)
end