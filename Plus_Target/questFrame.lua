local questFrame
local THREAT_TOOLTIP= WoWTools_TextMixin:Magic(THREAT_TOOLTIP)--:gsub('%%d', '%%d+')--"%d%% 威胁"

local function Save()
    return WoWToolsSave['Plus_Target']
end


















local function Find_Text(text)
    if text and not text:find(THREAT_TOOLTIP) then
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
local function Get_Unit_Text(self, unit)
    if not UnitIsPlayer(unit) then
        local type = UnitClassification(unit)
        if type=='rareelite' or type=='rare' or type=='worldboss' then--or type=='elite'
            return '|A:VignetteEvent:18:18|a'
        end
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
    elseif not (UnitInParty(unit) or UnitIsUnit('player', unit)) then
        local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, UnitGUID(unit), nil)--检测, 是否好友
        local faction= WoWTools_UnitMixin:GetFaction(unit, nil, Save().questShowAllFaction)--检查, 是否同一阵营
        local text
        if Save().questShowPlayerClass then
            text= WoWTools_UnitMixin:GetClassIcon(nil, unit)
        end
        if wow or faction then
            text= (text or '')..(wow or '')..(faction or '')
        end
        return text
    end
end


--设置，内容
local function Set_Quest_Text(self, plate, unit)
    plate= unit and C_NamePlate.GetNamePlateForUnit(unit, issecure()) or plate
    local frame= plate and plate.UnitFrame
    if not frame then
        return
    end
    local text= Get_Unit_Text(self, frame.unit or unit)
    if text and not frame.questProgress then
        frame.questProgress= WoWTools_LabelMixin:Create(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
        frame.questProgress:SetPoint('LEFT', frame.healthBar or frame, 'RIGHT', 2,0)
    end
    if frame.questProgress then
        frame.questProgress:SetText(text or '')
    end
end















--#########
--任务，数量
--#########
local function Init()
    questFrame= CreateFrame('Frame')
    WoWTools_TargetMixin.questFrame= questFrame

    function questFrame:hide_plate(plate)--移除，内容
        if plate and plate.UnitFrame and plate.UnitFrame.questProgress then--任务
            plate.UnitFrame.questProgress:SetText('')
        end
    end
    function questFrame:rest_all()--移除，所有内容
        for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
            self:hide_plate(plate)
        end
    end
    function questFrame:check_all()--检查，所有
        for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
            Set_Quest_Text(self, plate, nil)
        end
    end

    function questFrame:Settings()--注册，事件
        self:UnregisterAllEvents()

        if not Save().quest then
            self:rest_all()
            return
        end

        self:RegisterEvent('LOADING_SCREEN_DISABLED')

        local isPvPArena= WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
        local isIns= isPvPArena
                or (not Save().questShowInstance and IsInInstance()
                    and (GetNumGroupMembers()>3 or C_ChallengeMode.IsChallengeModeActive())
                )
        if not isIns then
            local eventTab= {
                'UNIT_QUEST_LOG_CHANGED',
                'SCENARIO_UPDATE',
                'SCENARIO_CRITERIA_UPDATE',
                'SCENARIO_COMPLETED',
                'QUEST_POI_UPDATE',
                'NAME_PLATE_UNIT_ADDED',
                --'NAME_PLATE_UNIT_REMOVED',
            }
            FrameUtil.RegisterFrameForEvents(self, eventTab)
            self:check_all()
        else
            self:rest_all()
        end
    end

    questFrame:SetScript("OnEvent", function(self, event, arg1)
        if event=='LOADING_SCREEN_DISABLED' then
            self:Settings()--注册，事件

        elseif event=='NAME_PLATE_UNIT_ADDED'  then
            Set_Quest_Text(self, nil, arg1)--任务

        else--event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
            C_Timer.After(2, function() self:check_all() end)
        end
    end)

    return true
end














function WoWTools_TargetMixin:Init_questFrame()
    if Save().quest and Init() then
        Init=function()end
    end

    if questFrame then
        questFrame:Settings()
    end
end