--地下城和团队副本

local function Save()
    return WoWToolsSave['Plus_Move']
end



--GroupFinderFrame
local function Init()
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


    WoWTools_MoveMixin:Setup(PVEFrame, {
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






function WoWTools_MoveMixin:Init_PVEFrame()--地下城和团队副本
    Init()
end