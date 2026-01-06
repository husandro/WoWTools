
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
            --return true
        elseif text:find('[%d%.]+%%') then
            local value= text:match('([%d%.]+%%)')
            if value and value~='100%' then
                return value
            end
            --return true
        end
    end
end



---取得，内容 GameTooltip.lua --local questID= line and line.id
local function Get_Unit_Text( unit)
    if UnitInPartyIsAI(unit) then
        local role = UnitGroupRolesAssigned(unit)
        if role and role~='NONE' then
            return WoWTools_DataMixin.Icon[role]
        end--if role=='TANK' or role=='HEALER' then

    elseif not UnitIsPlayer(unit) then
        local tooltipData = C_TooltipInfo.GetUnit(unit)
        if tooltipData and tooltipData.lines then
            for i = 4, #tooltipData.lines do
                local line = tooltipData.lines[i]
                local text= Find_Text(line.leftText)
                if text then
                    return text
                end
            end
        end

        if C_QuestLog.UnitIsRelatedToActiveQuest(unit) then
            if UnitIsQuestBoss(unit) then
                return '|A:Crosshair_Attack_128:0:0|a'
            end

            return '|A:QuestLegendary:0:0|a'
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










--设置，内容
local function Set_Quest_Text(plate)
    local frame= plate and plate.UnitFrame

    if not frame then
        return
    end

    local unit = frame.unit
    local text
    if canaccessvalue(unit) and unit and not UnitIsPlayer(unit) then
        text= Get_Unit_Text(unit)
    end

    if text and not frame.questProgress then
        frame.questProgress= frame:CreateFontString(nil, 'ARTWORK', 'ChatFontNormal') -- WoWTools_LabelMixin:Create(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
        frame.questProgress:SetFontHeight(14)
        frame.questProgress:SetTextColor(GREEN_FONT_COLOR:GetRGB())
        frame.questProgress:SetPoint('LEFT', frame.healthBar or frame, 'RIGHT', 2,0)
    end
    if frame.questProgress then
        frame.questProgress:SetText(text or '')
    end
end









--检查，所有
local function Check_AllPlate()
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
        Set_Quest_Text(plate)
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
end


















--#########
--任务，数量
--#########
local function Init()
    if not Save().quest then
        return
    end

    questFrame= CreateFrame('Frame')


    function questFrame:settings()--注册，事件
        self:UnregisterAllEvents()

        if not Save().quest then
            RestAllPlate()
            return
        end

        self:RegisterEvent('PLAYER_ENTERING_WORLD')

        if IsInRaid()
                or WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
                or C_ChallengeMode.IsChallengeModeActive()
                or (
                    IsInInstance()
                    and not UnitInPartyIsAI('party1')
                    and not Save().questShowInstance
                )
        then
            RestAllPlate()
            return
        end

        FrameUtil.RegisterFrameForEvents(self, {
            'UNIT_QUEST_LOG_CHANGED',
            'SCENARIO_UPDATE',
            'SCENARIO_CRITERIA_UPDATE',
            'SCENARIO_COMPLETED',
            'QUEST_POI_UPDATE',
            'NAME_PLATE_UNIT_ADDED',
            --'NAME_PLATE_UNIT_REMOVED',
        })

        if UnitInPartyIsAI('party1') then
            self:RegisterEvent('GROUP_ROSTER_UPDATE')
        end

        Check_AllPlate()
    end








    questFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='PLAYER_ENTERING_WORLD' then
            self:settings()--注册，事件

        elseif event=='NAME_PLATE_UNIT_ADDED' then
            if arg1 then
                Set_Quest_Text(C_NamePlate.GetNamePlateForUnit(arg1, issecure()))--任务
            end

        elseif event=='GROUP_ROSTER_UPDATE' then
            Check_AllPlate()

        else--event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
            C_Timer.After(2, Check_AllPlate)
        end
    end)









    questFrame:settings()






    if NamePlateBaseMixin.OnRemoved then--12.0没有了
        WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'OnRemoved', function(plate)--移除所有
           RestPlate(plate)
        end)
    else
        WoWTools_DataMixin:Hook(NamePlateBaseMixin, 'ClearUnit', function(plate)--移除所有
            RestPlate(plate)
        end)
    end


    Init=function()
        questFrame:settings()
    end
end














function WoWTools_TargetMixin:Init_questFrame()
    Init()
end