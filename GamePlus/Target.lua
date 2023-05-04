local id, e= ...
local addName= TARGET..COMBAT_ALLY_START_MISSION
local Save= {
    creatureNum= true,
    range=35,
}

local panel= CreateFrame("Frame")
local isPvPArena, isIns--, isPvPZone

--########################
--怪物目标, 队员目标, 总怪物
--########################
--local distanceSquared, checkedDistance = UnitDistanceSquared(u)
local function set_CreatureNum()
    local k,T,F=0,0,0

    local nameplates= C_NamePlate.GetNamePlates() or {}
    for _, nameplat in pairs(nameplates) do
        local u = nameplat.namePlateUnitToken or nameplat.UnitFrame and nameplat.UnitFrame.unit
        local t= u and u..'target'
        local range= Save.range>0 and e.CheckRange(u, Save.range, '<=') or Save.range==0
        if t and UnitExists(u)
            and not UnitIsDeadOrGhost(u)
            and not UnitInParty(u)
            and not UnitIsUnit(u,'player')
            and (not isPvPArena or (isPvPArena and UnitIsPlayer(u)))
            and range
            then
            if UnitCanAttack('player',u) then
                k=k+1
                if UnitIsUnit(t,'player') then
                    T=T+1
                end
            elseif UnitIsUnit(t,'player') then
                F=F+1
            end
        end
    end
    if IsInGroup() then
        local raid=IsInRaid()
        for i=1, GetNumGroupMembers() do
            local u
            if raid then--团                         
                u='raid'..i
            else--队里
                u='party'..i
            end
            local t=u..'-target'
            if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsUnit(t, 'player') and not UnitIsUnit(u,'player') then
                F=F+1
            end
        end
    end

    panel.Text:SetText((T==0 and '-' or T)..' |cff00ff00'..(F==0 and '-' or F)..'|r '..(k==0 and '-' or k))
end

--#########
--任务，数量
--#########
local THREAT_TOOLTIP_str= THREAT_TOOLTIP:gsub('%%d', '%%d+')--"%d%% 威胁"
local function find_Text(text)
    if text and not text:find(THREAT_TOOLTIP_str) then
        if text:find('(%d+/%d+)') then
            local min, max= text:match('(%d+)/(%d+)')
            min, max= tonumber(min), tonumber(max)
            if min and max and max> min then
                return max- min
            end
            return true
        elseif text:find('[%d%.]+%%') then
            local value= text:match('([%d%.]+%%)')
            if value and value~='100%' then
                return value
            end
            return true
        end
    end
end


local function Get_Quest_Progress(unit)--GameTooltip.lua --local questID= line and line.id
    if not UnitIsPlayer(unit) then
        local type = UnitClassification(unit)
        if type=='rareelite' or type=='rare' or type=='worldboss' then--or type=='elite'
            return '|A:VignetteEvent:18:18|a'
        end
        local tooltipData = C_TooltipInfo.GetUnit(unit)
        for i = 4, #tooltipData.lines do
            local line = tooltipData.lines[i]
            TooltipUtil.SurfaceArgs(line)
            local text= find_Text(line.leftText)
            if text then
                return text~=true and text
            end
        end
    elseif not (isIns and UnitInParty(unit)) then--if not isIns and isPvPZone and not UnitInParty(unit) then
        local wow= e.GetFriend(nil, UnitGUID(unit), nil)--检测, 是否好友
        local faction= e.GetUnitFaction(unit)--检查, 是否同一阵营
        if wow or faction then
            return (wow or '')..(faction or '')
        end
    end
end

local function set_questProgress_Text(plate, unit)
    if UnitExists(unit) and plate then
        local text= Get_Quest_Progress(unit)
        if text and not plate.questProgress then
            local frame= plate.UnitFrame and plate.UnitFrame.healthBar or plate
            plate.questProgress= e.Cstr(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
            plate.questProgress:SetPoint('LEFT', frame, 'RIGHT', 2,0)
        end
        if plate.questProgress then
            plate.questProgress:SetText(text or '')
        end
    end
end

local questChanging
local function set_check_All_Plates()
    if not questChanging then
        questChanging=true
        local plates= C_NamePlate.GetNamePlates() or {}
        for _, plate in pairs(plates) do
            set_questProgress_Text(plate, plate.namePlateUnitToken or plate.UnitFrame and plate.UnitFrame.unit)
        end
        questChanging=nil
    end
end


--####
--事件
--####
local function set_Register_Event()
    panel:UnregisterAllEvents()
    if Save.disabled then
        if panel.Texture then
            panel.Texture:SetShown(false)
        end
        if panel.Text then
            panel.Text:SetText('')
        end
    else
        panel:RegisterEvent('PLAYER_TARGET_CHANGED')
        panel:RegisterEvent('PLAYER_ENTERING_WORLD')
        panel:RegisterEvent('RAID_TARGET_UPDATE')
        panel:RegisterUnitEvent('UNIT_FLAGS', 'target')

        panel:RegisterEvent('PLAYER_REGEN_DISABLED')
        panel:RegisterEvent('PLAYER_REGEN_ENABLED')

        if Save.creatureNum then
            panel:RegisterEvent('UNIT_TARGET')

            panel:RegisterEvent('NAME_PLATE_UNIT_ADDED')
            panel:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
            if not isIns  then
                panel:RegisterEvent('UNIT_QUEST_LOG_CHANGED')
                panel:RegisterEvent('SCENARIO_UPDATE')
                panel:RegisterEvent('SCENARIO_CRITERIA_UPDATE')
                panel:RegisterEvent('SCENARIO_COMPLETED')
                panel:RegisterEvent('QUEST_POI_UPDATE')

                --[[panel:RegisterEvent('ZONE_CHANGED')
                panel:RegisterEvent('ZONE_CHANGED_INDOORS')
                panel:RegisterEvent('ZONE_CHANGED_NEW_AREA')
                panel:RegisterEvent('FRIENDLIST_UPDATE')
                panel:RegisterEvent('BN_FRIEND_INFO_CHANGED')]]
            end

        elseif panel.Text then
            panel.Text:SetText('')
        end
    end

    panel:RegisterEvent('PLAYER_LOGOUT')
end


--####
--初始
--####
local function Init()
    panel:SetSize(40, 20)

    panel.Texture= panel:CreateTexture(nil, 'BACKGROUND')
    panel.Texture:SetAtlas('common-icon-rotateright')
    panel.Texture:SetAllPoints(panel)

    panel.Text= e.Cstr(panel, {size=10, color={r=1,g=1,b=1}, layer='BORDER', justifyH='RIGHT'})--10, nil, nil, {1,1,1}, 'BORDER', 'RIGHT')
    panel.Text:SetPoint('RIGHT', -8, 0)
    --panel.Text:SetShadowOffset(2, -2)
end

panel:RegisterEvent('ADDON_LOADED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.range= Save.range or 35

            --添加控制面板        
            local sel=e.CPanel(e.Icon.toRight2..(e.onlyChinese and '目标指示' or addName), not Save.disabled, true)
            sel:SetScript('OnMouseDown', function()
                Save.disabled= not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:AddDoubleLine(e.onlyChinese and '显示敌方姓名板' or BINDING_NAME_NAMEPLATES, e.GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            local sel2=CreateFrame("CheckButton", nil, sel, "InterfaceOptionsCheckButtonTemplate")
            sel2.text:SetText(e.onlyChinese and '怪物数量' or CREATURE..AUCTION_HOUSE_QUANTITY_LABEL)
            sel2:SetPoint('LEFT', sel.text, 'RIGHT')
            sel2:SetChecked(Save.creatureNum)
            sel2:SetScript('OnMouseDown', function()
                Save.creatureNum= not Save.creatureNum and true or nil
                if panel.Text then
                    set_Register_Event()
                    if Save.creatureNum then
                        set_CreatureNum()
                    end
                end
            end)
            sel2:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('|cffffffff'..(e.onlyChinese and '怪物目标' or CREATURE..TARGET), e.onlyChinese and '你' or YOU)
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '队友目标' or PLAYERS_IN_GROUP ..TARGET), e.onlyChinese and '你' or YOU)
                e.tips:AddDoubleLine('|cffffffff'..(e.onlyChinese and '怪物' or CREATURE), e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '任务' or QUESTS_LABEL, e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '显示敌方姓名板' or BINDING_NAME_NAMEPLATES, (e.onlyChinese and '当前' or REFORGE_CURRENT)..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
                e.tips:Show()
            end)
            sel2:SetScript('OnLeave', function() e.tips:Hide() end)

            local sliderRange = e.Create_Slider(sel, {min=0, max=60, value=Save.range, setp=1, w= e.onlyChinese and 150 or 100,
            text=e.onlyChinese and '码' or IN_GAME_NAVIGATION_RANGE:gsub('%%s',''),
            func=function(self2, value)
                value= math.floor(value)
                self2:SetValue(value)
                self2.Text:SetText(value)
                Save.range= value
            end})
            sliderRange:SetPoint("LEFT", sel2.text, 'RIGHT', 2, 0)

            set_Register_Event()
            if not Save.disabled then
                --PlaterADD= IsAddOnLoaded("Plater")
                Init()
            end
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='PLAYER_TARGET_CHANGED' or event=='PLAYER_ENTERING_WORLD' or event=='RAID_TARGET_UPDATE' or (event=='UNIT_FLAGS' and arg1=='target') then
        C_Timer.After(0.15, function()
            local plate = C_NamePlate.GetNamePlateForUnit("target")
            if plate then
                local frame
                if plate.UnitFrame then
                    if plate.UnitFrame.RaidTargetFrame and plate.UnitFrame.RaidTargetFrame.RaidTargetIcon:IsShown() then
                        frame= plate.UnitFrame.RaidTargetFrame
                    elseif plate.UnitFrame.ClassificationFrame and plate.UnitFrame.ClassificationFrame.classificationIndicator:IsShown() then
                        frame= plate.UnitFrame.ClassificationFrame.classificationIndicator
                    elseif plate.UnitFrame.healthBar then
                        frame= plate.UnitFrame.healthBar
                    end
                end

                panel:ClearAllPoints()
                panel:SetPoint('RIGHT', frame or plate, 'LEFT')

                if Save.creatureNum then
                    set_CreatureNum()
                end
            end
            panel:SetShown(plate and true or false)
        end)

        if event=='PLAYER_ENTERING_WORLD' then
            isPvPArena= C_PvP.IsBattleground() or C_PvP.IsArena()
            isIns= IsInInstance() and GetNumGroupMembers()>2

            if Save.creatureNum then
                set_Register_Event()
            end
        end

    --elseif event=='ZONE_CHANGED' or event=='ZONE_CHANGED_INDOORS' or event=='ZONE_CHANGED_NEW_AREA' then
        --local pvpType, isFFA = GetZonePVPInfo()
        --isPvPZone= pvpType=='arena' and  isFFA

    elseif event=='PLAYER_REGEN_DISABLED' then--颜色
        panel.Texture:SetVertexColor(1,0,0)

    elseif event=='PLAYER_REGEN_ENABLED' then
        panel.Texture:SetVertexColor(1,1,1)

    elseif event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
        C_Timer.After(2, set_check_All_Plates)

    else
        if not isIns and arg1 then
            if event=='NAME_PLATE_UNIT_ADDED' then
                set_questProgress_Text(C_NamePlate.GetNamePlateForUnit(arg1), arg1)

            elseif event=='NAME_PLATE_UNIT_REMOVED' then
                local plate = C_NamePlate.GetNamePlateForUnit(arg1)
                if plate and plate.questProgress then
                    plate.questProgress:SetText('')
                end
            end
        end
        if self:IsShown() then
            set_CreatureNum()
        end
    end
end)