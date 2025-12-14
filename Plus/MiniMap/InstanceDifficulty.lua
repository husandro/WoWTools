--[[##############
副本，难度，指示
MinimapCluster.InstanceDifficulty.Default
MinimapCluster.InstanceDifficulty.ChallengeMode.Text
MinimapCluster.InstanceDifficulty.Guild.Border
]]










local function InstanceDifficulty_Tooltip(tooltip, difficultyID)
    difficultyID = difficultyID or select(3,  GetInstanceInfo())
    local difficultyIDName= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID)
    for _, ID in pairs({
        DifficultyUtil.ID.Raid40,
        DifficultyUtil.ID.RaidLFR,
        DifficultyUtil.ID.DungeonNormal,--1
        DifficultyUtil.ID.DungeonHeroic,
        DifficultyUtil.ID.DungeonMythic,--23
        DifficultyUtil.ID.DungeonChallenge,
        DifficultyUtil.ID.RaidTimewalker,
        25,
        205,--Seguace (5)LFG_TYPE_FOLLOWER_DUNGEON = "追随者地下城"
        208,
        220,
    }) do
        local text= WoWTools_MapMixin:GetDifficultyColor(nil, ID)
        if text then
            if ID==difficultyID or difficultyIDName==text then
                tooltip:AddLine(text..'|A:common-icon-rotateleft:0:0|a |cffffffff'..difficultyID)
            else
                tooltip:AddLine(text)
            end
        end
    end
end









local function Init()
    local btn= MinimapCluster.InstanceDifficulty
    if not btn or WoWToolsSave['Minimap_Plus'].disabledInstanceDifficulty then
        return
    end

    btn.labelType= WoWTools_LabelMixin:Create(btn, {color=true, level=22, alpha=0.5})
    btn.labelType:SetPoint('TOP', btn, 'BOTTOM', 0, 4)

    WoWTools_ColorMixin:Setup(btn.Default.Border, {type='Texture'})
    WoWTools_ColorMixin:Setup(btn.Guild.Border, {type='Texture'})
    WoWTools_ColorMixin:Setup(btn.ChallengeMode.Border, {type='Texture'})

    WoWTools_LabelMixin:Create(nil,{size=14, copyFont=btn.Text, changeFont= btn.Default.Text})--字体，大小
    btn.Default.Text:SetShadowOffset(1,-1)

--InstanceDifficulty.lua
    WoWTools_DataMixin:Hook(btn, 'Update', function(self)
        local isChallengeMode= self.ChallengeMode:IsShown()
        local difficultyName, color, name, tip

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
            difficultyName, color= WoWTools_MapMixin:GetDifficultyColor(nil, DifficultyUtil.ID.DungeonChallenge)

        elseif IsInInstance() then
            difficultyID = select(3, GetInstanceInfo())
            difficultyName, color= WoWTools_MapMixin:GetDifficultyColor(nil, difficultyID)
        end

        if difficultyName then
            name= difficultyName:match('|cff......(.-)|r') or difficultyName
            name= WoWTools_TextMixin:sub(name, 3, 7)
            tip= difficultyName..WoWTools_DataMixin.Icon.icon2..'difficultyID|cffffffff'..difficultyID
        end

        if frame and frame.Background and color then
            frame.Background:SetVertexColor(color.r, color.g, color.b)
        end
        self.labelType:SetText(name or '')
    end)



    btn:HookScript('OnEnter', function(self)
        local instanceName, _, difficultyID, difficultyName, maxPlayers= GetInstanceInfo()
        if not instanceName then
            return
        end
        if not GameTooltip:IsShown() then
            GameTooltip:SetOwner(MinimapCluster, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            difficultyName= WoWTools_TextMixin:CN(difficultyName)
            if difficultyName and maxPlayers then
                difficultyName= difficultyName..(maxPlayers and ' ('..maxPlayers..')' or '')..' '..(difficultyID or '')
            end

            GameTooltip:AddDoubleLine(WoWTools_DataMixin.Icon.icon2..WoWTools_TextMixin:CN(instanceName), difficultyName)
        end
        GameTooltip:AddLine(' ')
        InstanceDifficulty_Tooltip(GameTooltip, difficultyID)
        GameTooltip:Show()
        self.labelType:SetAlpha(1)
    end)
    btn:HookScript('OnLeave', function(self)
        self.labelType:SetAlpha(0.5)
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