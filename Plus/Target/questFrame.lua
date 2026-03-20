
local THREAT_TOOLTIP= WoWTools_TextMixin:Magic(THREAT_TOOLTIP)--:gsub('%%d', '%%d+')--"%d%% 威胁"

local function Save()
    return WoWToolsSave['Plus_Target']
end

--任务，数量
















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
            return '|A:VignetteEvent:0:0|a'
        end

    else--if not UnitInParty(unit) and not UnitInRaid(unit) then

        local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, UnitGUID(unit), nil)--检测, 是否好友
        local faction= WoWTools_UnitMixin:GetFaction(unit, nil, Save().questShowAllFaction)--检查, 是否同一阵营
        local text
        if Save().questShowPlayerClass then
            text= WoWTools_UnitMixin:GetClassIcon(unit, nil, nil)
        end
        if wow or faction then
            text= (text or '')..(wow or '')..(faction or '')
        end
        return text
    end
end






local function Create_Label(self)
    self.questProgress= self:CreateFontString(nil, 'ARTWORK', 'WoWToolsFonts')
    self.questProgress:SetTextColor(GREEN_FONT_COLOR:GetRGB())
    self.questProgress:SetJustifyH('LEFT')
    self.questProgress:SetPoint('LEFT', self.healthBar or self, 'RIGHT', 2, 0)
    --self.questProgress:SetPoint('LEFT', self.AurasFrame or self, 'RIGHT', 2, 0)
end






local function Init()
    if not Save().quest then
        return
    end
 
    WoWTools_DataMixin:Hook(NamePlateHealthBarMixin, 'UpdateSelectionBorder', function(self)
        if IsInInstance() then
            return
        end
        local unitFrame= self:GetParent()
        local questProgress= unitFrame and unitFrame.questProgress
        if questProgress and questProgress.isQuest then
            self.selectedBorder:SetVertexColor(1,0,1)
            self.selectedBorder:SetShown(true)
        end
    end)

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'OnLoad', function(self)
        self.questProgress= self:CreateFontString(nil, 'ARTWORK', 'WoWToolsFonts')
        self.questProgress:SetTextColor(GREEN_FONT_COLOR:GetRGB())
        self.questProgress:SetJustifyH('LEFT')
        self.questProgress:SetPoint('LEFT', self.healthBar or self, 'RIGHT', 2, 0)
    end)

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'OnUnitSet', function(self)
        if IsInInstance() then
            return
        end
        local text, isQuest= Get_Unit_Text(self)
        if self.questProgress.SetText then
            self.questProgress:SetText(text)
        end
        self.questProgress.isQuest= isQuest
        if isQuest then
            self.questProgress:SetFontHeight(canaccessvalue(self.isSimplified) and self.isSimplified and 44 or 22)
            self.HealthBarsContainer.healthBar.selectedBorder:SetVertexColor(1,0,0)
            self.HealthBarsContainer.healthBar.selectedBorder:SetShown(true)
        end
    end)

    --[[WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'OnUnitCleared', function(self)
        self.questProgress:SetText('')
        self.questProgress.isQuest= nil
    end)]]

    Init=function()
    end
end


        --self.questProgress:SetPoint('LEFT', self.AurasFrame or self, 'RIGHT', 2, 0)












function WoWTools_TargetMixin:Init_questFrame()
    Init()
end
--[[
self:GetScaleData()
vertical 0.8
aura 0.75
horizontal 0.75
aggroHighlight 1
classification 0.8

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'UpdateScale', function(self)
	    local scaleData = self:GetScaleData();
        info=scaleData
        for k, v in pairs(info or {}) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR|r') for k2,v2 in pairs(v) do print('|cffffff00',k2,v2, '|r') end print('|cffff0000---',k, '---END|r') else print(k,v) end end print('|cffff00ff——————————|r')
    end)



[hooksecurefunc(NamePlateUnitFrameMixin, 'ShouldBeSimplified', function()

    WoWTools_DataMixin:Hook(NamePlateUnitFrameMixin, 'UpdateIsSimplified', function(self)
        local questProgress= self:GetParent():GetParent().questProgress
        if questProgress and canaccessvalue(self.isSimplified) then--and questProgress.isQuest then
            self.questProgress:SetFontHeight(self.isSimplified and 44 or 22)
           -- if self.isSimplified then
                self.isSimplified= false
                C_NamePlateManager.SetNamePlateSimplified(self.unit, false);
            --end
        end
    end)
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