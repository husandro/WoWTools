
local THREAT_TOOLTIP= WoWTools_TextMixin:Magic(THREAT_TOOLTIP)--:gsub('%%d', '%%d+')--"%d%% 威胁"
local questFrame
local function Save()
    return WoWToolsSave['Plus_Target']
end


















local function Find_Text(text)
    if canaccessvalue(text) and text and not text:find(THREAT_TOOLTIP) then
        if text:find('(%d+/%d+)') then
            local min, max= text:match('(%d+)/(%d+)')
            min, max= tonumber(min), tonumber(max)
            if min and max and max> min then
                return max- min
            end
        elseif text:find('[%d%.]+%%') then
            local value= text:match('([%d%.]+%%)')
            if value and value~='100%' then
                return value
            end
        end
    end
end


--[[
	self.isPlayer = nil;
	self.isFriend = nil;
	self.isDead = nil;
	self.isSimplified = nil;
	self.isFocus = nil;
	self.isTarget = nil;
	self.widgetsOnlyMode = nil;
	self.showOnlyName = nil;

	self.aggroHighlightShown = nil;
	self.isBehindCamera = nil;

	self.AurasFrame:SetUnit(nil);
	self.ClassificationFrame:SetUnit(nil);
	self.HealthBarsContainer.healthBar:SetUnit(nil);
]]
---取得，内容 GameTooltip.lua --local questID= line and line.id
local function Get_Unit_Text(self)
    local unit= self.unit
    local isAI= UnitInPartyIsAI(unit)

    if not canaccessvalue(isAI) or IsInRaid() or not Save().quest then
        return

    elseif isAI then
        local role = UnitGroupRolesAssigned(unit)
        if role and role~='NONE' then
            return WoWTools_DataMixin.Icon[role]
        end--if role=='TANK' or role=='HEALER' then

    elseif not UnitIsPlayer(unit) then
        local data = C_TooltipInfo.GetUnit(unit)
        if canaccesstable(data) and data and data.lines then
            for i = 4, #data.lines do
                local line = data.lines[i]
                local text= Find_Text(line.leftText)
                if text then
                    return text, true
                end
            end
        end

        if C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
            if UnitIsQuestBoss(unit) then
                return '|A:Crosshair_Attack_128:0:0|a', true
            else
                return '|A:QuestLegendary:0:0|a', true
            end
        end

        local type = UnitClassification(unit)
        if type=='rareelite' or type=='rare' or type=='worldboss' then--or type=='elite'
            return '|A:VignetteEvent:18:18|a'
        end

    else--if not UnitInParty(unit) and not UnitInRaid(unit) then

        local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, UnitGUID(unit), nil)--检测, 是否好友
        local faction= WoWTools_UnitMixin:GetFaction(unit, nil, Save().questShowAllFaction)--检查, 是否同一阵营
        local text
        if Save().questShowPlayerClass then
            text= WoWTools_UnitMixin:GetClassIcon(unit)
        end
        if wow or faction then
            text= (text or '')..(wow or '')..(faction or '')
        end
        return text
    end
end








--[[

--设置，内容
local function Set_Quest_Text(plate)
    local frame= plate and plate.UnitFrame

    if not frame then
        return
    end


    local text, isQuest= Get_Unit_Text(frame.unit)


    if not frame.questProgress then
        frame.questProgress= frame:CreateFontString(nil, 'ARTWORK', 'WoWToolsFonts') -- WoWTools_LabelMixin:Create(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
        frame.questProgress:SetTextColor(GREEN_FONT_COLOR:GetRGB())
        frame.questProgress:SetJustifyH('LEFT')
        --frame.questProgress:SetFontHeight(22)
        frame.questProgress:SetPoint('LEFT', frame.healthBar or frame, 'RIGHT', 2,0)

    end

    frame.questProgress:SetText(text or '')
    
    frame.questProgress:SetFontHeight(frame.isSimplified and 44 or 22)
    frame.questProgress.isQuest= isQuest
    if isQuest then
        frame.HealthBarsContainer.healthBar.selectedBorder:SetVertexColor(1,0,0)
        frame.HealthBarsContainer.healthBar.selectedBorder:SetShown(true)
        frame.HealthBarsContainer.healthBar.isTarget=true
        frame.isSimplified=nil
    end

end









--检查，所有
local function Check_AllPlate()
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        --Set_Quest_Text(plate)
    end
end


--移除，内容
local function RestPlate(plate)
    if plate and plate.UnitFrame and plate.UnitFrame.questProgress then--任务
        plate.UnitFrame.questProgress:SetText('')
    end
end
--移除，所有内容
local function RestAllPlate()
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        RestPlate(plate)
    end
end]]


















--#########
--任务，数量
--#########
local function Init()
    if not Save().quest then
        return
    end
 --[[
    questFrame= CreateFrame('Frame')


   function questFrame:settings()--注册，事件
        self:UnregisterAllEvents()

        if not Save().quest then
            RestAllPlate()
            return
        end

        self:RegisterEvent('PLAYER_ENTERING_WORLD')

        --if IsInRaid()
            --or (IsInInstance() and IsInGroup(LE_PARTY_CATEGORY_HOME) and not WoWTools_MapMixin:IsInDelve())
            --or WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
            --or C_ChallengeMode.IsChallengeModeActive()
        --then
          --  RestAllPlate()
            return
        --end

        FrameUtil.RegisterFrameForEvents(self, {
            'UNIT_QUEST_LOG_CHANGED',
            'SCENARIO_UPDATE',
            'SCENARIO_CRITERIA_UPDATE',
            'SCENARIO_COMPLETED',
            'QUEST_POI_UPDATE',
            'NAME_PLATE_UNIT_ADDED',
            'GROUP_ROSTER_UPDATE',
            --'NAME_PLATE_UNIT_REMOVED',
        })


       -- Check_AllPlate()
    end]]








    --[[questFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' then
            self:settings()--注册，事件

        elseif event=='NAME_PLATE_UNIT_ADDED' then
            if arg1 then
                --Set_Quest_Text(C_NamePlate.GetNamePlateForUnit(arg1, issecure()))--任务
            end

        elseif event=='GROUP_ROSTER_UPDATE' then
            Check_AllPlate()

        else--event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
            C_Timer.After(2, Check_AllPlate)
        end
    end)


    --questFrame:settings()


    WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'ClearUnit', function(plate)--移除所有
        RestPlate(plate)
    end)
]]
    WoWTools_DataMixin:Hook(NamePlateHealthBarMixin, 'UpdateSelectionBorder', function(self)
        local questProgress= self:GetParent():GetParent().questProgress
        if questProgress and questProgress.isQuest then
            self.selectedBorder:SetVertexColor(1,0,1)
            self.selectedBorder:SetShown(true)
        end
    end)

    --hooksecurefunc(NamePlateUnitFrameMixin, 'ShouldBeSimplified', function()

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'UpdateIsSimplified', function(self)
        local questProgress= self:GetParent():GetParent().questProgress
        if questProgress and questProgress.isQuest then
            --self.isSimplified= nil
        end
    end)
    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'OnLoad', function(self)
        self.questProgress= self:CreateFontString(nil, 'ARTWORK', 'WoWToolsFonts')
        self.questProgress:SetTextColor(GREEN_FONT_COLOR:GetRGB())
        self.questProgress:SetJustifyH('LEFT')
        --frame.questProgress:SetFontHeight(22)
        self.questProgress:SetPoint('LEFT', self.healthBar or self, 'RIGHT', 2, 0)
    end)

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'OnUnitSet', function(self)
        local text, isQuest= Get_Unit_Text(self)
        
        self.questProgress:SetText(text or '')
        self.questProgress.isQuest= isQuest
        
        if isQuest then
            self.questProgress:SetFontHeight(canaccessvalue(self.isSimplified) and self.isSimplified and 44 or 22)
            self.HealthBarsContainer.healthBar.selectedBorder:SetVertexColor(1,0,0)
            self.HealthBarsContainer.healthBar.selectedBorder:SetShown(true)
            --self.HealthBarsContainer.healthBar.isTarget=true
            --self.isSimplified=nil
            --self:UpdateIsSimplified()
        end
    end)

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'OnUnitCleared', function(self)
        self.questProgress:SetText('')
        self.questProgress.isQuest= nil
    end)
    

    Init=function()
        --questFrame:settings()
    end
end














function WoWTools_TargetMixin:Init_questFrame()
    Init()
end
--[[


NamePlateUnitFrameMixin
SetExplicitValues = function: 000001AA52AE67E8
IsMinusMob = function: 000001AA52AE6270
UpdateIsDead = function: 000001AA52AE6200
ShouldBeSimplified = function: 000001AA52AE62A8
ShouldBeTarget = function: 000001AA52AE6350
IsFocus = function: 000001AA52AE6430
IsTarget = function: 000001AA52AE6388
UpdateShowOnlyName = function: 000001AA52AE66D0
ApplyFrameOptions = function: 000001AA52AF19C0
IsPlayer = function: 000001AA52AE6120
IsSimplified = function: 000001AA52AE62E0
UpdateIsSimplified = function: 000001A9FB849390
IsMinion = function: 000001AA52AE6238
UpdateRaidTarget = function: 000001AA52AE64D8
UpdateNameClassColor = function: 000001AA52AE6708
OnUnitCleared = function: 000001AA52AE6040
IsFriend = function: 000001AA52AE6158
UpdateScale = function: 000001AA52AE65F0
IsDead = function: 000001AA52AE61C8
IsShowOnlyName = function: 000001AA52AE6698
OnUnitSet = function: 000001A9FB849490
UpdateIsPlayer = function: 000001AA52AE60E8
UpdateIsTarget = function: 000001AA52AE63C0
UpdateThreatDisplay = function: 000001AA52AE6740
UpdateWidgetsOnlyMode = function: 000001AA52AE6660
UpdateAggroHighlight = function: 000001AA52AE6548
OnLoad = function: 000001A9FB849410
UpdateAnchors = function: 000001AA52AE67B0
ShouldBeFocus = function: 000001AA52AE63F8
ShouldShowName = function: 000001AA52AE6778
OnEvent = function: 000001AA52AE6008
UpdateBehindCamera = function: 000001AA52AE6628
GetScaleData = function: 000001AA52AE65B8
UpdateCastBarDisplay = function: 000001AA52AE6580
UpdateIsFocus = function: 000001AA52AE6468
ShouldAggroHighlightBeShown = function: 000001AA52AE6510
GetRaidTargetIndex = function: 000001AA52AE64A0
OnUnitFactionChanged = function: 000001AA52AE60B0
UpdateIsFriend = function: 000001AA52AE6190
——————————
]]