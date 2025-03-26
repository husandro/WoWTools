--[[##############
副本，难度，指示
MinimapCluster.InstanceDifficulty.Default
MinimapCluster.InstanceDifficulty.ChallengeMode.Text
MinimapCluster.InstanceDifficulty.Guild.Border
]]








--InstanceDifficulty.lua
local function InstanceDifficulty_Update(self)
    local isChallengeMode= self.ChallengeMode:IsShown()
    local tooltip, color, name
    local frame

    if self.Guild:IsShown() then
        frame = self.Guild
    elseif isChallengeMode then
        frame = self.ChallengeMode
    elseif self.Default:IsShown() then
        frame = self.Default
    end

    local difficultyID
    if isChallengeMode then--挑战
        tooltip, color, name= WoWTools_MapMixin:GetDifficultyColor(nil, DifficultyUtil.ID.DungeonChallenge)

    elseif IsInInstance() then
        difficultyID = select(3, GetInstanceInfo())
        tooltip, color, name= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID)
    end

    if frame and color then
        frame.Background:SetVertexColor(color.r, color.g, color.b)
    end

    if not self.labelType then
        self.labelType= WoWTools_LabelMixin:Create(self, {color=true, level=22, alpha=0.5})
        self.labelType:SetPoint('TOP', self, 'BOTTOM', 0, 4)
    end

    self.labelType:SetText(name and WoWTools_TextMixin:sub(name, 3, 7) or '')
    self.tooltip= tooltip
end




local function InstanceDifficulty_Tooltip(tooltip, difficultyID)
    difficultyID = difficultyID or select(3,  GetInstanceInfo())
    local tab={
        DifficultyUtil.ID.Raid40,
        DifficultyUtil.ID.RaidLFR,
        DifficultyUtil.ID.DungeonNormal,
        DifficultyUtil.ID.DungeonHeroic,
        DifficultyUtil.ID.DungeonMythic,
        DifficultyUtil.ID.DungeonChallenge,
        DifficultyUtil.ID.RaidTimewalker,
        25,
        205,--Seguace (5)LFG_TYPE_FOLLOWER_DUNGEON = "追随者地下城"
        208,
        220,
    }
    for _, ID in pairs(tab) do
        local text, color= WoWTools_MapMixin:GetDifficultyColor(nil, ID)
        tooltip:AddDoubleLine(
            (ID==difficultyID and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight) or '')
            ..text
            ..(ID==difficultyID and format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft) or ''),

            (color and color.hex or '')..ID
        )
    end
end




local function InstanceDifficulty_OnEnter(self)
    if not IsInInstance() then
        return
    end

    GameTooltip:SetOwner(MinimapCluster, "ANCHOR_LEFT")
    GameTooltip:ClearLines()
    --name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID
    local instanceName, _, difficultyID, difficultyName, maxPlayers= GetInstanceInfo()
    difficultyName= WoWTools_TextMixin:CN(difficultyName)
    if difficultyName and maxPlayers then
        difficultyName= difficultyName..(maxPlayers and ' ('..maxPlayers..')' or '')..' '..(difficultyID or '')
    end

    GameTooltip:AddDoubleLine(WoWTools_TextMixin:CN(instanceName), difficultyName)
    GameTooltip:AddLine(self.tooltip)
    GameTooltip:AddLine(' ')
   
    InstanceDifficulty_Tooltip(GameTooltip, difficultyID)

    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_MinimapMixin.addName)
    GameTooltip:Show()
    if self.labelType then
        self.labelType:SetAlpha(1)
    end
end






local function Init()
    local btn= MinimapCluster.InstanceDifficulty
    if not btn or WoWToolsSave['Minimap_Plus'].disabledInstanceDifficulty then
        return
    end

    WoWTools_ColorMixin:Setup(btn.Default.Border, {type='Texture'})
    WoWTools_ColorMixin:Setup(btn.Guild.Border, {type='Texture'})
    WoWTools_ColorMixin:Setup(btn.ChallengeMode.Border, {type='Texture'})

    WoWTools_LabelMixin:Create(nil,{size=14, copyFont=btn.Text, changeFont= btn.Default.Text})--字体，大小
    btn.Default.Text:SetShadowOffset(1,-1)

    hooksecurefunc(btn, 'Update', InstanceDifficulty_Update)

    btn:HookScript('OnEnter', InstanceDifficulty_OnEnter)
    btn:HookScript('OnLeave', function(self)
        if self.labelType then
            self.labelType:SetAlpha(0.5)
        end
        GameTooltip:Hide()
    end)

    Init=function()end
end








function WoWTools_MinimapMixin:InstanceDifficulty_Tooltip(_, tooltip)
    InstanceDifficulty_Tooltip(tooltip, nil)
end


function WoWTools_MinimapMixin:Init_InstanceDifficulty()
    Init()
end