--[[##############
副本，难度，指示
MinimapCluster.InstanceDifficulty.Default
MinimapCluster.InstanceDifficulty.ChallengeMode.Text
MinimapCluster.InstanceDifficulty.Guild.Border
]]
local e= select(2, ...)







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
        tooltip, color, name= e.GetDifficultyColor(nil, DifficultyUtil.ID.DungeonChallenge)

    elseif IsInInstance() then
        difficultyID = select(3, GetInstanceInfo())
        tooltip, color, name= e.GetDifficultyColor(nil, difficultyID)
    end

    if frame and color then
        frame.Background:SetVertexColor(color.r, color.g, color.b)
    end

    if not self.labelType then
        self.labelType= e.Cstr(self, {color=true, level=22, alpha=0.5})
        self.labelType:SetPoint('TOP', self, 'BOTTOM', 0, 4)
    end

    self.labelType:SetText(name and e.WA_Utf8Sub(name, 3, 7) or '')
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
    }
    for _, ID in pairs(tab) do
        local text, color= e.GetDifficultyColor(nil, ID)
        tooltip:AddDoubleLine(
            (ID==difficultyID and format('|A:%s:0:0|a', e.Icon.toRight) or '')
            ..text
            ..(ID==difficultyID and format('|A:%s:0:0|a', e.Icon.toLeft) or ''),

            (color and color.hex or '')..ID
        )
    end
end




local function InstanceDifficulty_OnEnter(self)
    if not IsInInstance() then
        return
    end

    e.tips:SetOwner(MinimapCluster, "ANCHOR_LEFT")
    e.tips:ClearLines()
    --name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID
    local instanceName, _, difficultyID, difficultyName, maxPlayers= GetInstanceInfo()
    difficultyName= e.cn(difficultyName)
    if difficultyName and maxPlayers then
        difficultyName= difficultyName..(maxPlayers and ' ('..maxPlayers..')' or '')..' '..(difficultyID or '')
    end

    e.tips:AddDoubleLine(e.cn(instanceName), difficultyName)
    e.tips:AddLine(self.tooltip)
    e.tips:AddLine(' ')
   
    InstanceDifficulty_Tooltip(e.tips, difficultyID)

    e.tips:AddLine(' ')
    e.tips:AddDoubleLine(e.addName, WoWTools_MinimapMixin.addName)
    e.tips:Show()
    if self.labelType then
        self.labelType:SetAlpha(1)
    end
end






local function Init()
    local btn= MinimapCluster.InstanceDifficulty
    if not btn then
        return
    end

    e.Set_Label_Texture_Color(btn.Default.Border, {type='Texture'})
    e.Set_Label_Texture_Color(btn.Guild.Border, {type='Texture'})
    e.Set_Label_Texture_Color(btn.ChallengeMode.Border, {type='Texture'})

    e.Cstr(nil,{size=14, copyFont=btn.Text, changeFont= btn.Default.Text})--字体，大小
    btn.Default.Text:SetShadowOffset(1,-1)

    --e.Cstr(nil,{size=14, copyFont=btn.Guild.Text, changeFont= btn.Default.Text})--字体，大小
    --btn.Guild.Text:SetShadowOffset(1,-1)

    --e.Cstr(nil,{size=14, copyFont=btn.ChallengeMode.Text, changeFont= btn.Default.Text})--字体，大小
    --btn.ChallengeMode.Default.Text:SetShadowOffset(1,-1)

    --MinimapCluster:HookScript('OnEvent', function(self)--Minimap.luab
    hooksecurefunc(btn, 'Update', InstanceDifficulty_Update)

    btn:HookScript('OnEnter', InstanceDifficulty_OnEnter)
    btn:HookScript('OnLeave', function(self)
        if self.labelType then
            self.labelType:SetAlpha(0.5)
        end
        e.tips:Hide()
    end)
end








function WoWTools_MinimapMixin:InstanceDifficulty_Tooltip(_, tooltip)
    InstanceDifficulty_Tooltip(tooltip, nil)
end


function WoWTools_MinimapMixin:Init_InstanceDifficulty()
    if not self.Save.disabledInstanceDifficulty then
        Init()
    end
end