--世界地图
local function Save()
    return WoWToolsSave['Plus_Move']
end

local minimizedWidth= WorldMapFrame.minimizedWidth or 702
local minimizedHeight= WorldMapFrame.minimizedHeight or 534


local function set_min_max_value(size)
    local self= WorldMapFrame
    local isMax= self:IsMaximized()
    if isMax then
        self.minimizedWidth= minimizedWidth
        self.minimizedHeight= minimizedHeight
        self.BorderFrame.MaximizeMinimizeFrame:Maximize()
    elseif size then
        local w= size[1]-(self.questLogWidth or 0)
        self.minimizedWidth= w
        self.minimizedHeight= size[2]
        self.BorderFrame.MaximizeMinimizeFrame:Minimize()
    end
end





local function Init()
    hooksecurefunc(WorldMapFrame, 'Minimize', function(self)
        if not self.ResizeButton then
            return
        end
        local name= self:GetName()
        local size= Save().size[name]
        if size then
            self:SetSize(size[1], size[2])
            set_min_max_value(size)
        end
        local scale= Save().scale[name]
        if scale then
            self:SetScale(scale)
        end
        self.ResizeButton:SetShown(true)
    end)
    hooksecurefunc(WorldMapFrame, 'Maximize', function(self)
        if not self.ResizeButton then
            return
        end
        set_min_max_value()
        if Save().scale[self:GetName()] then
            self:SetScale(1)
        end
        if self.ResizeButton then
            self.ResizeButton:SetShown(false)
        end
    end)

    WoWTools_MoveMixin:Setup(WorldMapFrame, {
        minW=(WorldMapFrame.questLogWidth or 290)*2+37,
        minH=WorldMapFrame.questLogWidth,
        setSize=true,
        onShowFunc=true,
        --notMoveAlpha=true,
        sizeUpdateFunc= function()--WorldMapMixin:UpdateMaximizedSize()
            set_min_max_value({WorldMapFrame:GetSize()})
        end,
        sizeRestFunc= function()
            WorldMapFrame.minimizedWidth= minimizedWidth
            WorldMapFrame.minimizedHeight= minimizedHeight
            WorldMapFrame:SetSize(minimizedWidth+ (WorldMapFrame.questLogWidth or 290), minimizedHeight)
            WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Minimize()
        end, sizeTooltip='|cnRED_FONT_COLOR:BUG|r'
    })


    QuestMapFrame.DetailsFrame:SetPoint('BOTTOM')
    --QuestMapDetailsScrollFrame:SetPoint('BOTTOM', QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame, 'TOP')
    --QuestMapDetailsScrollFrame:SetPoint('BOTTOM', 0, 123)
    --QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame:ClearAllPoints()
    QuestMapDetailsScrollFrame.Contents:SetPoint('BOTTOMLEFT')


    --QuestMapFrame.DetailsFrame.Bg:SetPoint('BOTTOM')
    QuestMapFrame.DetailsFrame.Bg:SetPoint('BOTTOM', 0, 23)
    QuestMapFrame.DetailsFrame.SealMaterialBG:SetPoint('BOTTOM', 0, 23)

    WorldMapFrame.ScrollContainer.Child.TiledBackground:ClearAllPoints()
    WorldMapFrame.ScrollContainer.Child.TiledBackground:SetAllPoints()
    

    QuestScrollFrame.Background:SetPoint('BOTTOM', 0, 123)
    QuestScrollFrame.Background:SetAllPoints()

    WoWTools_MoveMixin:Setup(QuestScrollFrame, {frame=WorldMapFrame})
    WoWTools_MoveMixin:Setup(MapQuestInfoRewardsFrame, {frame=WorldMapFrame})
    WoWTools_MoveMixin:Setup(QuestMapFrame, {frame=WorldMapFrame})
    WoWTools_MoveMixin:Setup(QuestMapFrame.DetailsFrame, {frame=WorldMapFrame})
    WoWTools_MoveMixin:Setup(QuestMapDetailsScrollFrame, {frame=WorldMapFrame})
end







function WoWTools_MoveMixin:Init_WorldMapFrame()--世界地图
    Init()
end