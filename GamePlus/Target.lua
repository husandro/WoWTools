local id, e= ...
local addName= TARGET
local Save= {
    target= true,
    targetTextureNewTab={},
    targetTextureName='common-icon-rotateright',

    targetColor= {r=1,g=1,b=1,a=1},--颜色
    targetInCombat=true,--战斗中，提示
    targetInCombatColor={r=1, g=0, b=0, a=1},--战斗中，颜色
    w=40,
    h=20,
    x=0,
    y=0,
    scale=1.5,
    elapsed=0.5,
    TargetFramePoint='LEFT',--'TOP', 'HEALTHBAR','LEFT'
    --top=true,--位于，目标血条，上方

    creature= true,--怪物数量
    creatureFontSize=10,
    --questShowInstance=true,
    --creatureToUIParet=true,--放在UIPrent

    unitIsMe=true,--提示， 目标是你
    unitIsMeTextrue= 'auctionhouse-icon-favorite',
    unitIsMeSize=12,
    unitIsMePoint='TOPLEFT',
    unitIsMeX=0,
    unitIsMeY=-2,
    unitIsMeColor={r=1,g=1,b=1,a=1},

    quest= true,
    --questShowAllFaction=nil,--显示， 所有玩家派系
    questShowPlayerClass=true,--显示，玩家职业
    --questShowInstance=true,--在副本显示
}











local panel= CreateFrame("Frame")

local TargetFrame
local QuestFrame
local IsMeFrame
local NumFrame

local CreatureLabel

local isPvPArena, isIns--, isPvPZone
--local isAddOnPlater--C_AddOns.IsAddOnLoaded("Plater")
--[[
local function get_isAddOnPlater(unit)
    if isAddOnPlater and unit then
        local num= unit:match('%d+')
        if num then
            return _G['NamePlate'..num..'PlaterUnitFrameHealthBar']
        end
    end
end]]










local function get_texture_tab()
    local tab={
        ['auctionhouse-icon-favorite']='a',
        ['common-icon-rotateright']='a',
        ['Adventures-Target-Indicator']='a',
        ['Adventures-Target-Indicator-desat']='a',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Hunters_Mark.tga']='t',
        ['NPE_ArrowDown']='a',
        ['UI-HUD-MicroMenu-StreamDLYellow-Up']='a',
        ['Interface\\AddOns\\WeakAuras\\Media\\Textures\\targeting-mark.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Reticule.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\RedArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NeonReticule.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NeonRedArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\RedChevronArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\PaleRedChevronArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\arrow_tip_green.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\arrow_tip_red.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\skull.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\circles_target.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\red_star.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\greenarrowtarget.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\BlueArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\bluearrow1.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\gearsofwar.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\malthael.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NewRedArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NewSkull.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\PurpleArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Shield.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\NeonGreenArrow.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_FelFlamingSkull.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_RedFlamingSkull.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_ShadowFlamingSkull.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_GreenGPS.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_RedGPS.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_WhiteGPS.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_GreenTarget.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_RedTarget.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Q_WhiteTarget.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_Towards.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_Away.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_SelfTowards.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_SelfAway.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FriendTowards.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FriendAway.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FocusTowards.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\Arrows_FocusAway.tga']='t',
        ['Interface\\AddOns\\WoWTools\\Sesource\\Mouse\\green_arrow_down_11384.tga']='t',
    }
    for name, _ in pairs(Save.targetTextureNewTab) do
        if tab[name] then
            Save.targetTextureNewTab[name]=nil
        else
            tab[name]= 'use'
        end
    end
    return tab
end


local function get_plate_unit(plate)
    if plate then
        return  plate.UnitFrame and plate.UnitFrame.unit or plate.namePlateUnitToken
    end
end








local function set_Target_Color(self, isInCombat)--设置，颜色
    if self then
        if isInCombat then
            self:SetVertexColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
        else
            self:SetVertexColor(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a)
        end
    end
end
local function set_Target_Size(self)--设置，大小
    if self then
        self:SetSize(Save.w, Save.h)
    end
end


local function set_Scale_Frame()--缩放
    if not TargetFrame then
        return
    end
    if TargetFrame.Texture and Save.scale~=1 then
        TargetFrame:SetScript('OnUpdate', function(self, elapsed)
            self.elapsed= (self.elapsed or Save.elapsed) + elapsed
            if self.elapsed> Save.elapsed then
                self.elapsed=0
                self:SetScale(self:GetScale()==1 and Save.scale or 1)
            end
        end)
    else
        TargetFrame:SetScript('OnUpdate', nil)
    end
    TargetFrame:SetScale(1)
end



















--########################
--怪物目标, 队员目标, 总怪物
--########################
local function set_Creature_Num()--local distanceSquared, checkedDistance = UnitDistanceSquared(u) inRange = CheckInteractDistance(unit, distIndex)
    local k,T,F=0,0,0
    for _, nameplat in pairs(C_NamePlate.GetNamePlates() or {}) do
        local u = get_plate_unit(nameplat)
        local t= u and u..'target'
        --local range= Save.creatureRange>0 and e.CheckRange(u, Save.creatureRange, '<=') or Save.creatureRange==0
        if UnitExists(t) and UnitExists(u)
            and not UnitIsDeadOrGhost(u)
            and not UnitInParty(u)
            and not UnitIsUnit(u,'player')
            and (not isPvPArena or (isPvPArena and UnitIsPlayer(u)))
            and e.CheckRange(u, 40, true)
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
            if UnitExists(u) and not UnitIsDeadOrGhost(u) and UnitIsUnit(t, 'player') and not UnitIsUnit(u, 'player') then
                F=F+1
            end
        end
    end
    CreatureLabel:SetText(e.Player.col..(T==0 and '-' or  T)..'|r |cff00ff00'..(F==0 and '-' or F)..'|r '..(k==0 and '-' or k))
end

local function Init_Creature_Num()
    if Save.creature then
        --怪物数量
        if not CreatureLabel then
            CreatureLabel= e.Cstr(TargetFrame, {size=Save.creatureFontSize, color={r=1,g=1,b=1}, layer='BORDER'})--10, nil, nil, {1,1,1}, 'BORDER', 'RIGHT')
            function CreatureLabel:set_point()
                self:ClearAllPoints()
                if Save.TargetFramePoint=='LEFT' then
                    self:SetPoint('CENTER')
                    self:SetJustifyH('RIGHT')
                else
                    self:SetPoint('BOTTOM', 0, 8)
                    self:SetJustifyH('CENTER')
                end
            end
            CreatureLabel:SetTextColor(1,1,1)
        elseif CreatureLabel then
            e.Cstr(nil, {changeFont=CreatureLabel, size= Save.creatureFontSize})
            CreatureLabel:set_point()
        end
        set_Creature_Num()
    else
        if CreatureLabel then
            CreatureLabel:SetText('')
        end
    end
end




























--#########
--任务，数量
--#########
local function Init_Quest()
    if not Save.quest then
        if QuestFrame then
            QuestFrame:UnregisterAllEvents()
            QuestFrame:rest_all()
        end
        return
    end



    if not QuestFrame then
        QuestFrame= CreateFrame('Frame')
        QuestFrame.THREAT_TOOLTIP= e.Magic(THREAT_TOOLTIP)--:gsub('%%d', '%%d+')--"%d%% 威胁"
        function QuestFrame:find_text(text)
            if text and not text:find(self.THREAT_TOOLTIP) then
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

        --GameTooltip.lua --local questID= line and line.id
        function QuestFrame:get_unit_text(unit)--取得，内容
            if not UnitIsPlayer(unit) then
                local type = UnitClassification(unit)
                if type=='rareelite' or type=='rare' or type=='worldboss' then--or type=='elite'
                    return '|A:VignetteEvent:18:18|a'
                end
                local tooltipData = C_TooltipInfo.GetUnit(unit)
                if tooltipData and tooltipData.lines then
                    for i = 4, #tooltipData.lines do
                        local line = tooltipData.lines[i]
                        TooltipUtil.SurfaceArgs(line)
                        local text= self:find_text(line.leftText)
                        if text then
                            return text~=true and text
                        end
                    end
                end

            elseif not (UnitInParty(unit) or UnitIsUnit('player', unit)) then--if not isIns and isPvPZone and not UnitInParty(unit) then
                local wow= e.GetFriend(nil, UnitGUID(unit), nil)--检测, 是否好友
                local faction= e.GetUnitFaction(unit, nil, Save.questShowAllFaction)--检查, 是否同一阵营
                local text
                if Save.questShowPlayerClass then
                    text= e.Class(unit)
                end
                if wow or faction then
                    text= (text or '')..(wow or '')..(faction or '')
                end
                return text
            end
        end

        function QuestFrame:set_quest_text(plate, unit)--设置，内容
            local plate= unit and C_NamePlate.GetNamePlateForUnit(unit) or plate
            local frame= plate and plate.UnitFrame
            if not frame then
                return
            end
            local text= self:get_unit_text(frame.unit or unit)
            if text and not frame.questProgress then
                frame.questProgress= e.Cstr(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
                frame.questProgress:SetPoint('LEFT', frame.healthBar or frame, 'RIGHT', 2,0)
            end
            if frame.questProgress then
                frame.questProgress:SetText(text or '')
            end
        end
        function QuestFrame:hide_plate(plate, unit)--移除，内容
            plate= unit and C_NamePlate.GetNamePlateForUnit(unit) or plate
            if plate and plate.UnitFrame then
                if plate.UnitFrame.questProgress then--任务
                    plate.UnitFrame.questProgress:SetText('')
                end
            end
        end
        function QuestFrame:rest_all()--移除，所有内容
            for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
                QuestFrame:hide_plate(plate, nil)
            end
        end
        function QuestFrame:check_all()--检查，所有
            for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
                self:set_quest_text(plate, nil)
            end
        end

        function QuestFrame:set_event()--注册，事件
            QuestFrame:UnregisterAllEvents()
            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            local isPvPArena= C_PvP.IsBattleground() or C_PvP.IsArena()--在PVP副中
            local isIns= isPvPArena
                    or (not Save.questShowInstance and IsInInstance()
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

        QuestFrame:SetScript("OnEvent", function(self, event, arg1)
            if event=='PLAYER_ENTERING_WORLD' then
                self:set_event()--注册，事件

            elseif event=='NAME_PLATE_UNIT_ADDED'  then
                self:set_quest_text(nil, arg1)--任务

            else--event=='UNIT_QUEST_LOG_CHANGED' or event=='QUEST_POI_UPDATE' or event=='SCENARIO_COMPLETED' or event=='SCENARIO_UPDATE' or event=='SCENARIO_CRITERIA_UPDATE' then
                C_Timer.After(2, function() self:check_all() end)
            end
        end)
    end

    QuestFrame:set_event()--注册，事件
end































--#############
--提示，目标是我
--#############
local function Init_Unit_Is_Me()
    if IsMeFrame then
        IsMeFrame:UnregisterAllEvents()
    end
    if not Save.unitIsMe then
        if IsMeFrame then
            for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
                IsMeFrame:hide_plate(plate)
            end
        end
        return
    end
    if not IsMeFrame then
        IsMeFrame= CreateFrame('Frame')
        function IsMeFrame:set_texture(plate)--设置，参数
            local self= plate.UnitFrame
            self.UnitIsMe= self:CreateTexture(nil, 'OVERLAY')
            if Save.unitIsMePoint=='TOP' then
                self.UnitIsMe:SetPoint("BOTTOM", self.healthBar, 'TOP', Save.unitIsMeX,Save.unitIsMeY)
            elseif Save.unitIsMePoint=='TOPRIGHT' then
                self.UnitIsMe:SetPoint("BOTTOMRIGHT", self.healthBar, 'TOPRIGHT', Save.unitIsMeX,Save.unitIsMeY)
            else--TOPLEFT
                self.UnitIsMe:SetPoint("BOTTOMLEFT", self.healthBar, 'TOPLEFT', Save.unitIsMeX,Save.unitIsMeY)
            end
            local isAtlas, texture= e.IsAtlas(Save.unitIsMeTextrue)
            if isAtlas or not texture then
                self.UnitIsMe:SetAtlas(texture or 'auctionhouse-icon-favorite')
            else
                self.UnitIsMe:SetTexture(texture)
            end
            self.UnitIsMe:SetVertexColor(Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a)
            self.UnitIsMe:SetSize(Save.unitIsMeSize, Save.unitIsMeSize)
        end
        function IsMeFrame:set_plate(plate, unit)--设置, Plate
            plate= unit and C_NamePlate.GetNamePlateForUnit(unit) or plate
            if plate and plate.UnitFrame then
                local isMe= plate.UnitFrame.unit and UnitIsUnit((plate.UnitFrame.unit or '')..'target', 'player')
                if isMe and not plate.UnitFrame.UnitIsMe then
                    self:set_texture(plate)--设置，参数
                end
                if plate.UnitFrame.UnitIsMe then
                    plate.UnitFrame.UnitIsMe:SetShown(isMe)
                end
            end
        end
        function IsMeFrame:hide_plate(plate, unit)--隐藏，Plate
            local plate= unit and C_NamePlate.GetNamePlateForUnit(unit) or plate
            if plate and plate.UnitFrame and plate.UnitFrame.UnitIsMe then
                plate.UnitFrame.UnitIsMe:SetShown(false)
            end
        end
        function IsMeFrame:init_all()--检查，所有
            for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
                self:set_plate(plate, nil)--设置
            end
        end
        hooksecurefunc(NamePlateBaseMixin, 'OnAdded', function(plate)
            IsMeFrame:set_plate(plate, nil)
        end)
        hooksecurefunc(NamePlateBaseMixin, 'OnOptionsUpdated', function(plate)
            IsMeFrame:set_plate(plate, nil)
        end)
        IsMeFrame:SetScript('OnEvent', function(self, event, arg1)
            if event=='PLAYER_REGEN_DISABLED' then--颜色
               self:init_all()

            elseif arg1 then
                if arg1=='player' or arg1=='pet' then
                    self:init_all()
                else--if UnitIsEnemy(arg1, 'player') then
                    self:set_plate(nil, arg1)
                end
            end
        end)
    end
    local eventTab= {
        'PLAYER_REGEN_DISABLED',
        'UNIT_TARGET',
        'UNIT_SPELLCAST_CHANNEL_START',
        --'PLAYER_REGEN_ENABLED',
        --'NAME_PLATE_UNIT_ADDED',
        --'NAME_PLATE_UNIT_REMOVED',
        --'FORBIDDEN_NAME_PLATE_UNIT_ADDED',
        --'FORBIDDEN_NAME_PLATE_UNIT_REMOVED',
       -- 'CVAR_UPDATE',
    }
    FrameUtil.RegisterFrameForEvents(IsMeFrame, eventTab)
    for _, plate in pairs(C_NamePlate.GetNamePlates() or {}) do
        if plate.UnitFrame then
            if plate.UnitFrame.UnitIsMe then--修改
                plate.UnitFrame.UnitIsMe:ClearAllPoints()
                self:set_texture(plate)--设置，参数
            end
            self:set_plate(plate)--设置
        end
    end
end























































--##########################
--设置,指示目标,位置,显示,隐藏
--##########################
local function set_Target()
    local plate= C_NamePlate.GetNamePlateForUnit("target")
    if plate then
        local self = plate.UnitFrame
        local frame--= get_isAddOnPlater(plate.UnitFrame.unit)--C_AddOns.IsAddOnLoaded("Plater")
        TargetFrame:ClearAllPoints()
        if Save.TargetFramePoint=='TOP' then
            if self.SoftTargetFrame.Icon:IsShown() then
                frame= self.SoftTargetFrame
            else
                frame= self.name or self.healthBar
            end
            TargetFrame:SetPoint('BOTTOM', frame or self, 'TOP', Save.x, Save.y)

        elseif Save.TargetFramePoint=='HEALTHBAR' then
            frame= self.healthBar or self.name or self
            local w, h= frame:GetSize()
            w= w+ Save.w
            h= h+ Save.h
            local n, p
            if self.RaidTargetFrame.RaidTargetIcon:IsVisible() then
                n= self.RaidTargetFrame.RaidTargetIcon:GetWidth()+ self.ClassificationFrame.classificationIndicator:GetWidth()
            elseif self.ClassificationFrame.classificationIndicator:IsVisible() then
                n= self.ClassificationFrame.classificationIndicator:GetWidth()
            end
            if self.questProgress then
                p= self.questProgress:GetWidth()
            end
            n, p= n or 0, p or 0
            TargetFrame:SetSize(w+ n+ p, h)
            TargetFrame:SetPoint('CENTER', self, Save.x+ (-n+p)/2, Save.y)
        else
            if self.RaidTargetFrame.RaidTargetIcon:IsVisible() then
                frame= self.RaidTargetFrame
            elseif self.ClassificationFrame.classificationIndicator:IsVisible() then
                frame= self.ClassificationFrame.classificationIndicator
            else
                frame= self.healthBar or self.name
            end
            TargetFrame:SetPoint('RIGHT', frame or self, 'LEFT',Save.x, Save.y)
        end
    end
    TargetFrame:SetShown(plate and true or false)
end






























































local function set_All_Init()
    TargetFrame:UnregisterAllEvents()
    TargetFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

    if Save.target or Save.creature then
        TargetFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
        TargetFrame:RegisterEvent('RAID_TARGET_UPDATE')
        TargetFrame:RegisterUnitEvent('UNIT_FLAGS', 'target')
        TargetFrame:RegisterEvent('CVAR_UPDATE')
    end

    if (Save.target and Save.targetInCombat) then
        TargetFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
        TargetFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
    end

    if Save.creature then
        TargetFrame:RegisterEvent('UNIT_TARGET')
    end



    if  Save.TargetFramePoint~='HEALTHBAR' then
        set_Target_Size(TargetFrame)--设置，大小
    end
    if not TargetFrame.Texture and Save.target then
        TargetFrame.Texture= TargetFrame:CreateTexture(nil, 'BACKGROUND')
        TargetFrame.Texture:SetAllPoints(TargetFrame)
    end

    if TargetFrame.Texture then
        local isAtlas, texture= e.IsAtlas(Save.targetTextureName)--设置，图片
        if isAtlas then
            TargetFrame.Texture:SetAtlas(texture)
        else
            TargetFrame.Texture:SetTexture(texture or 0)
        end
        set_Scale_Frame()--缩放
        set_Target_Color(TargetFrame.Texture, Save.targetInCombat and UnitAffectingCombat('player'))
        TargetFrame.Texture:SetShown(Save.target)
    end


   set_Target()
   Init_Creature_Num()
   Init_Quest()
   Init_Unit_Is_Me()
end

































--####
--初始
--####
local function Init()
    hooksecurefunc(NamePlateBaseMixin, 'OnRemoved', function(plate)--移除所有
        if IsMeFrame then
            IsMeFrame:hide_plate(plate, nil)
        end
        if QuestFrame then
            QuestFrame:hide_plate(plate, nil)
        end
    end)

    TargetFrame= CreateFrame("Frame")
    set_All_Init()

    hooksecurefunc(NamePlateDriverFrame, 'OnSoftTargetUpdate', function()
        if Save.TargetFramePoint=='TOP' then
            set_Target()
        end
    end)

    TargetFrame:SetScript("OnEvent", function(_, event, arg1)
        if event=='PLAYER_TARGET_CHANGED'
            or event=='RAID_TARGET_UPDATE'
            or event=='UNIT_FLAGS'
        then
            C_Timer.After(0.15, set_Target)

        elseif event=='CVAR_UPDATE' then
            if arg1=='nameplateShowAll' or arg1=='nameplateShowEnemies' or arg1=='nameplateShowFriends' then
                C_Timer.After(0.15, set_Target)
            end

        elseif event=='PLAYER_ENTERING_WORLD' then
            set_All_Init()

        elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then--颜色
            set_Target_Color(TargetFrame.Texture, event=='PLAYER_REGEN_DISABLED')



        else
            if Save.creature then
                set_Creature_Num()
            end
        end
    end)
end


























--#################
--选项, 添加控制面板      
--#################
local function set_Option()
    if panel.tipTargetTexture or Save.disabled then
        return
    end

    local sel=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel:SetPoint('TOPLEFT', 0, -40)
    sel:SetChecked(Save.target)
    sel:SetScript('OnClick', function()
        Save.target= not Save.target and true or nil
        set_All_Init()
    end)
    sel.Text:SetText(e.Icon.toRight2..(e.onlyChinese and '目标' or addName))
    sel.Text:SetTextColor( Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a)
    sel.Text:EnableMouse(true)
    sel.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a
            local function func()
                Save.targetColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(panel.tipTargetTexture, false)
                set_All_Init()
            end
            e.ShowColorPicker(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a, function()
                    setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save.targetColor={r=1, g=1, b=1, a=1}
            self2:SetTextColor(1, 1, 1, 1)
            set_Target_Color(panel.tipTargetTexture, false)
            set_All_Init()
        end
    end)
    sel.Text:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    sel.Text:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.onlyChinese and '显示敌方姓名板' or BINDING_NAME_NAMEPLATES, e.GetEnabeleDisable(C_CVar.GetCVarBool("nameplateShowEnemies")))
        e.tips:AddLine(' ')
        local r,g,b,a= Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a
        e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), (e.onlyChinese and '默认' or DEFAULT)..e.Icon.right, r,g,b, 1,1,1)
        e.tips:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        e.tips:AddLine(' ')
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)

    panel.tipTargetTexture= panel:CreateTexture()--目标，图片，提示
    panel.tipTargetTexture:SetPoint("TOP")
    --set_Target_Texture(panel.tipTargetTexture)--设置，图片
    set_Target_Size(panel.tipTargetTexture)--设置，大小
    set_Target_Color(panel.tipTargetTexture, false)--设置，颜色

    local combatCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    combatCheck:SetPoint('LEFT', sel.Text, 'RIGHT', 15,0)
    combatCheck:SetChecked(Save.targetInCombat)
    combatCheck:SetScript('OnClick', function()
        Save.targetInCombat= not Save.targetInCombat and true or nil
        set_All_Init()
    end)
    combatCheck.Text:EnableMouse(true)
    combatCheck.Text:SetText(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
    combatCheck.Text:SetTextColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
    combatCheck.Text:SetScript('OnMouseDown', function(self2, d)
        if d=='LeftButton' then
            local setR, setG, setB, setA
            local R,G,B,A= Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a
            local function func()
                Save.targetInCombatColor={r=setR, g=setG, b=setB, a=setA}
                self2:SetTextColor(setR, setG, setB, setA)
                set_Target_Color(panel.tipTargetTexture, true)
                set_All_Init()
            end
            e.ShowColorPicker(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a, function()
                    setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                    func()
                end, function()
                    setR, setG, setB, setA= R,G,B,A
                    func()
                end
            )
        elseif d=='RightButton' then
            Save.targetInCombatColor={r=1, g=0, b=0, a=1}
            self2:SetTextColor(1, 0, 0, 1)
            set_Target_Color(panel.tipTargetTexture, false)
            set_All_Init()
        end
    end)
    combatCheck.Text:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    combatCheck.Text:SetScript('OnEnter', function(self2)
        local r,g,b,a= Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS, COLOR)), (e.onlyChinese and '默认' or DEFAULT)..e.Icon.right, r,g,b, 1,1,1)
        e.tips:AddDoubleLine('r='..r..' g='..g..' b='..b, 'a='..a, r,g,b, r,g,b)
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)

    --[[local topCheck=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    topCheck:SetPoint('LEFT', combatCheck.Text, 'RIGHT', 15,0)
    topCheck:SetChecked(Save.top)
    topCheck.Text:SetText('TOP')
    topCheck:SetScript('OnClick', function()
        Save.top= not Save.top and true or nil
        set_All_Init()
    end)]]
    local menuPoint = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    menuPoint:SetPoint("LEFT", combatCheck.Text, 'RIGHT', 15, 0)
    e.LibDD:UIDropDownMenu_SetWidth(menuPoint, 100)
    e.LibDD:UIDropDownMenu_Initialize(menuPoint, function(self, level)
        local tab={
            'TOP',
            'HEALTHBAR',
            'LEFT'
        }
        for _, name in pairs(tab) do
            local info={
                text= name,
                checked= Save.TargetFramePoint==name,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '位置' or CHOOSE_LOCATION,
                arg1= name,
                func= function(_, arg1)
                    Save.TargetFramePoint= arg1
                    e.LibDD:UIDropDownMenu_SetText(self, arg1)
                    set_All_Init()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end)
    e.LibDD:UIDropDownMenu_SetText(menuPoint, Save.TargetFramePoint)
    menuPoint.Button:SetScript('OnClick', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    local sliderX = e.CSlider(panel, {min=-250, max=250, value=Save.x, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.x= value
        set_All_Init()
    end})
    sliderX:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT',0, -12)
    local sliderY = e.CSlider(panel, {min=-250, max=250, value=Save.y, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.y= value
        set_All_Init()
    end})
    sliderY:SetPoint("LEFT", sliderX, 'RIGHT',15,0)
    local sliderW = e.CSlider(panel, {min=10, max=100, value=Save.w, setp=1, w= 100,
    text= 'W',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.w= value
        set_Target_Size(panel.tipTargetTexture)--设置，大小
        set_All_Init()
    end})
    sliderW:SetPoint("LEFT", sliderY, 'RIGHT',15,0)
    local sliderH = e.CSlider(panel, {min=10, max=100, value=Save.h, setp=1, w= 100, color=true,
    text= 'H',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.h= value
        set_Target_Size(panel.tipTargetTexture)--设置，大小
        set_All_Init()
    end})
    sliderH:SetPoint("LEFT", sliderW, 'RIGHT',15,0)



    local sliderScale = e.CSlider(panel, {min=0.4, max=2, value=Save.scale or 1, setp=0.1, w= 100,
    text= e.onlyChinese and '缩放' or UI_SCALE,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.scale= value
        if value==1 then
            print(id,e.cn(addName),'|cnRED_FONT_COLOR:', e.onlyChinese and '禁用' or DISABLE)
        else
            print(id,e.cn(addName), '|cnGREEN_FONT_COLOR:', value)
        end
        set_Scale_Frame()--缩放
    end})
    sliderScale:SetPoint("TOPLEFT", sliderX, 'BOTTOMLEFT', 0,-16)

    local sliderElapsed = e.CSlider(panel, {min=0.3, max=1.5, value=Save.elapsed or 0.5, setp=0.1, w= 100, color=true,
    text= e.onlyChinese and '速度' or SPEED,
    func=function(self2, value)
        value= tonumber(format('%.1f', value))
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.elapsed= value
    end})
    sliderElapsed:SetPoint("LEFT", sliderScale, 'RIGHT',15, 0)


    local menu = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    menu:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT', -16,-82)
    e.LibDD:UIDropDownMenu_SetWidth(menu, 410)
    e.LibDD:UIDropDownMenu_Initialize(menu, function(self, level)
        for name, use in pairs(get_texture_tab()) do
            local isAtlas, texture= e.IsAtlas(name)
            if texture then
                local info={
                    text= name:match('.+\\(.+)%.') or name,
                    icon= name,
                    colorCode= use=='use' and '|cff00ff00' or (isAtlas and '|cffff00ff') or nil,
                    tooltipOnButton=true,
                    tooltipTitle= isAtlas and 'Atls' or 'Texture',
                    tooltipText= use=='use' and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自定义' or CUSTOM) or nil,
                    arg1= name,
                    arg2= isAtlas,
                    checked= Save.targetTextureName==name,
                    func= function(_, arg1)
                        Save.targetTextureName= arg1
                        e.LibDD:UIDropDownMenu_SetText(self, arg1)
                        self.edit:SetText(arg1)
                        set_All_Init()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    e.LibDD:UIDropDownMenu_SetText(menu, Save.targetTextureName)
    menu.Button:SetScript('OnClick', function(self)
        e.HideMenu(self:GetParent())
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    menu.edit= CreateFrame("EditBox", nil, menu, 'InputBoxTemplate')--EditBox
    menu.edit:SetPoint("TOPLEFT", menu, 'BOTTOMLEFT',22,-2)
	menu.edit:SetSize(420,22)
	menu.edit:SetAutoFocus(false)
    menu.edit:ClearFocus()
    menu.edit.Label= e.Cstr(menu.edit)
    menu.edit.Label:SetPoint('RIGHT', menu.edit, 'LEFT', -4, 0)
    menu.edit:SetScript('OnShow', function(self)
        self:SetText(Save.targetTextureName)
    end)
    menu.edit:SetScript('OnTextChanged', function(self)
        local name, isAtlas
        name= self:GetText() or ''
        name= name:gsub(' ', '')
        name= name=='' and false or name
        if name then
            isAtlas, name= e.IsAtlas(name)
            if name then
                if isAtlas then
                    panel.tipTargetTexture:SetAtlas(name)
                else
                    panel.tipTargetTexture:SetTexture(name)
                end
                self.Label:SetText(isAtlas and 'Atls' or 'Texture')
            else
                panel.tipTargetTexture:SetTexture(0)
            end
        end
        self.del:SetShown(name and Save.targetTextureNewTab[name])
        self.add:SetShown(name and not Save.targetTextureNewTab[name])
    end)

    --删除，图片
    menu.edit.del= e.Cbtn(menu.edit, {atlas='xmarksthespot', size={20,20}})
    menu.edit.del:SetPoint('LEFT', menu, 'RIGHT',-10,0)
    menu.edit.del:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtals, name= e.IsAtlas(parent:GetText())
        if name and Save.targetTextureNewTab[name] then
            Save.targetTextureNewTab[name]= nil
            print(id, e.cn(addName),
                '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r',
                (isAtals and '|A:'..name..':0:0|a' or ('|T'..name..':0|t'))..name
            )
            e.LibDD:UIDropDownMenu_SetText(menu, '')
            parent:SetText("")
            parent:SetText(name)
        end
    end)

    --添加按钮
    menu.edit.add= e.Cbtn(menu.edit, {atlas=e.Icon.select, size={20,20}})--添加, 按钮
    menu.edit.add:SetPoint('LEFT', menu.edit, 'RIGHT', 5,0)
    menu.edit.add:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtlas, icon= e.IsAtlas(parent:GetText())
        if icon and not Save.targetTextureNewTab[icon] then
            Save.targetTextureNewTab[icon]= isAtlas and 'a' or 't'
            parent:SetText('')
            print(id,
                e.cn(addName),
                '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r',
                (isAtlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'))..icon
            )
        end
    end)
    menu.edit.add:SetScript('OnLeave', GameTooltip_Hide)
    menu.edit.add:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        local atlas, icon= e.IsAtlas(menu.edit:GetText())
        if icon then
            e.tips:AddDoubleLine(atlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'), e.onlyChinese and '添加' or ADD)
            e.tips:AddDoubleLine(atlas and 'Atlas' or 'Texture', icon)
        else
            e.tips:AddLine(e.onlyChinese and '无' or NONE)
        end
        e.tips:Show()
    end)





    local sel2=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel2.Text:SetText(e.onlyChinese and e.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r'
                or (e.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
            )
    sel2:SetPoint('TOPLEFT', menu.edit, 'BOTTOMLEFT', -32, -32)
    sel2:SetChecked(Save.creature)
    sel2:SetScript('OnClick', function()
        Save.creature= not Save.creature and true or nil
        set_All_Init()
    end)

    local sliderCreatureFontSize = e.CSlider(panel, {min=8, max=32, value=Save.creatureFontSize, setp=1, w=100, color=true,
    text= e.Player.L.size,
    func=function(self2, value)--字体大小
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.creatureFontSize= value
        set_All_Init()
    end})
    sliderCreatureFontSize:SetPoint("LEFT", sel2.Text, 'RIGHT',15,0)





    local unitIsMeCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    unitIsMeCheck.Text:SetText(e.onlyChinese and '目标是'..e.Player.col..'你|r' or 'Target is '..e.Player.col..'You|r')
    unitIsMeCheck:SetPoint('TOP', sel2, 'BOTTOM', 0, -24)
    unitIsMeCheck:SetChecked(Save.unitIsMe)
    unitIsMeCheck:SetScript('OnClick', function()
        Save.unitIsMe= not Save.unitIsMe and true or false
        print(id, e.cn(addName), e.GetEnabeleDisable(Save.unitIsMe), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        set_All_Init()
    end)

    local menuUnitIsMePoint = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    menuUnitIsMePoint:SetPoint("LEFT", unitIsMeCheck.Text, 'RIGHT', 15, 0)
    e.LibDD:UIDropDownMenu_SetWidth(menuUnitIsMePoint, 100)
    e.LibDD:UIDropDownMenu_Initialize(menuUnitIsMePoint, function(self, level)
        local info
        local tab={
            'TOPLEFT',
            'TOP',
            'TOPRIGHT'
        }
        for _, name in pairs(tab) do
            info={
                text= name,
                checked= Save.unitIsMePoint==name,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '位置' or CHOOSE_LOCATION,
                arg1= name,
                func= function(_, arg1)
                    Save.unitIsMePoint= arg1
                    e.LibDD:UIDropDownMenu_SetText(self, arg1)
                    set_All_Init()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        --[[e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text=e.onlyChinese and '颜色' or COLOR,
            notCheckable=true,
            icon= Save.unitIsMeTextrue,
            r= Save.unitIsMeColor.r or 1,
            g= Save.unitIsMeColor.g or 1,
            b= Save.unitIsMeColor.b or 1,
            a= Save.unitIsMeColor.a or 1,
            hasColorSwatch=true,
            swatchFunc= function(...)
                print(ColorPickerFrame:GetColorRGB())
            end,
            cancelFunc= function(s)
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)]]
    end)
    e.LibDD:UIDropDownMenu_SetText(menuUnitIsMePoint, Save.unitIsMePoint)
    menuUnitIsMePoint.Button:SetScript('OnClick', function(self)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    local menuUnitIsMe = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    menuUnitIsMe:SetPoint("LEFT", menuUnitIsMePoint, 'RIGHT', 2,0)
    function menuUnitIsMe:get_icon()
        local isAtlas, texture= e.IsAtlas(Save.unitIsMeTextrue)
        if isAtlas or not texture then
            e.LibDD:UIDropDownMenu_SetText(self, '|A:'..(texture or 'auctionhouse-icon-favorite')..':0:0|a')
        else
            e.LibDD:UIDropDownMenu_SetText(self, '|T'.. texture..':0|t')
        end
    end
    e.LibDD:UIDropDownMenu_SetWidth(menuUnitIsMe, 100)
    e.LibDD:UIDropDownMenu_Initialize(menuUnitIsMe, function(self, level)
        for name, use in pairs(get_texture_tab()) do
            local isAtlas, texture= e.IsAtlas(name)
            if texture then
                local info={
                    text= isAtlas and '|cffff00ffAtlas|r' or '',
                    icon= name,
                    colorCode= use=='use' and '|cff00ff00' or (isAtlas and '|cffff00ff') or nil,
                    tooltipOnButton=true,
                    tooltipTitle= isAtlas and 'Atls' or 'Texture',
                    tooltipText= (name:match('.+\\(.+)%.') or name)..(use=='use' and '|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '自定义' or CUSTOM)..'|r' or ''),
                    arg1= name,
                    checked= Save.unitIsMeTextrue==name,
                    func= function(_, arg1)
                        Save.unitIsMeTextrue= arg1
                        self:get_icon()
                        set_All_Init()
                        self.color:set_texture()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    menuUnitIsMe:get_icon()
    menuUnitIsMe.Button:SetScript('OnClick', function(self)
        e.HideMenu(self:GetParent())
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)

    menuUnitIsMe.color= e.Cbtn(panel, {size={32,32}, type='ColorSwatchTemplate', icon='hide'})--CreateFrame('Button', nil, panel, 'ColorSwatchTemplate')
    menuUnitIsMe.color.InnerBorder:ClearAllPoints()
    menuUnitIsMe.color.InnerBorder:SetAllPoints(menuUnitIsMe.color)
    menuUnitIsMe.color.Color:ClearAllPoints()
    menuUnitIsMe.color.Color:SetAllPoints(menuUnitIsMe.color)
    menuUnitIsMe.color:SetPoint('LEFT', menuUnitIsMe, 'RIGHT', 2,0)
    --menuUnitIsMe.color:SetSize(32,32)
    function menuUnitIsMe.color:set_texture()
        local isAtlas, texture= e.IsAtlas(Save.unitIsMeTextrue)
        if isAtlas then
            self.Color:SetAtlas(texture)
        else
            self.Color:SetTexture(texture)
        end
    end
    function menuUnitIsMe.color:set_color()
        self.Color:SetVertexColor(Save.unitIsMeColor.r or 1, Save.unitIsMeColor.g or 1, Save.unitIsMeColor.b or 1, Save.unitIsMeColor.a or 1)
    end
    menuUnitIsMe.color:set_texture()
    menuUnitIsMe.color:set_color()
    menuUnitIsMe.color:SetScript('OnClick', function(self)
        local r,g,b,a= Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a
        local info={
            r= r,
            g= g,
            b= b,
            a= a,
            swatchFunc = function()
                Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a= ColorPickerFrame:GetColorRGB()
                self:set_color()
                set_All_Init()
            end,
            cancelFunc = function()
                Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a= r, g, b, a
                self:set_color()
                set_All_Init()
            end
        }
        --info.extraInfo = nil;
        ColorPickerFrame:SetupColorPickerAndShow(info);
    end)


    local unitIsMeX = e.CSlider(panel, {min=-250, max=250, value=Save.unitIsMeX, setp=1, w= 100,
    text= 'X',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.unitIsMeX= value
        set_All_Init()
    end})
    unitIsMeX:SetPoint("TOPLEFT", unitIsMeCheck, 'BOTTOMRIGHT',0, -12)
    local unitIsMeY = e.CSlider(panel, {min=-250, max=250, value=Save.unitIsMeY, setp=1, w= 100, color=true,
    text= 'Y',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.unitIsMeY= value
        set_All_Init()
    end})
    unitIsMeY:SetPoint("LEFT", unitIsMeX, 'RIGHT',15,0)

    local unitIsMeSize = e.CSlider(panel, {min=2, max=64, value=Save.unitIsMeSize, setp=1, w= 100, color=false,
    text= e.onlyChinese and '大小' or 'size',
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.unitIsMeSize= value
        set_All_Init()
    end})
    unitIsMeSize:SetPoint("LEFT", unitIsMeY, 'RIGHT',15,0)










    local questCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questCheck.Text:SetText(e.onlyChinese and '任务进度' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, PVP_PROGRESS_REWARDS_HEADER)))
    questCheck:SetPoint('TOPLEFT', unitIsMeCheck, 'BOTTOMLEFT',0,-64)
    questCheck:SetChecked(Save.quest)
    questCheck:SetScript('OnClick', function()
        Save.quest= not Save.quest and true or nil
        set_All_Init()
    end)

    local questAllFactionCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questAllFactionCheck.Text:SetText((e.onlyChinese and '提示所有阵营' or (SHOW..'('..ALL..')'..FACTION))..e.Icon.horde2..e.Icon.alliance2)
    questAllFactionCheck:SetPoint('LEFT', questCheck.Text, 'RIGHT',2,0)
    questAllFactionCheck:SetChecked(Save.questShowAllFaction)
    questAllFactionCheck:SetScript('OnClick', function()
        Save.questShowAllFaction= not Save.questShowAllFaction and true or nil
        set_All_Init()
    end)

    local classCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    classCheck.Text:SetText(e.onlyChinese and '职业' or CLASS)
    classCheck:SetPoint('LEFT', questAllFactionCheck.Text, 'RIGHT',2,0)
    classCheck:SetChecked(Save.questShowPlayerClass)
    classCheck:SetScript('OnClick', function()
        Save.questShowPlayerClass= not Save.questShowPlayerClass and true or nil
        set_All_Init()
    end)

    local instanceCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    instanceCheck.Text:SetText(e.onlyChinese and '在副本里显示' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, INSTANCE))
    instanceCheck:SetPoint('TOPLEFT', questCheck, 'BOTTOMRIGHT')
    instanceCheck:SetChecked(Save.questShowInstance)
    instanceCheck:SetScript('OnClick', function()
        Save.questShowInstance= not Save.questShowInstance and true or nil
        set_All_Init()
    end)
end



































panel:RegisterEvent('PLAYER_LOGOUT')
panel:RegisterEvent('ADDON_LOADED')
panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            Save.targetTextureTab= nil
            Save.targetTextureNewTab= Save.targetTextureNewTab or {}

            Save.targetTextureName= Save.targetTextureName or 'common-icon-rotateright'
            Save.targetColor= Save.targetColor or {r=1,g=1,b=1,a=1}
            Save.targetInCombatColor= Save.targetInCombatColor or {r=1, g=0, b=0, a=1}

            Save.unitIsMe= Save.unitIsMe==nil and true or Save.unitIsMe
            Save.unitIsMeTextrue= Save.unitIsMeTextrue or 'auctionhouse-icon-favorite'
            Save.unitIsMeSize= Save.unitIsMeSize or 12
            Save.unitIsMePoint= Save.unitIsMePoint or 'TOPLEFT'
            Save.unitIsMeX= Save.unitIsMeX or 0
            Save.unitIsMeY= Save.unitIsMeY or -2
            Save.unitIsMeColor= Save.unitIsMeColor or {r=1,g=1,b=1,a=1}

            Save.scale= Save.scale or 1.5
            Save.elapsed= Save.elapsed or 0.5

            Save.TargetFramePoint= Save.TargetFramePoint or 'LEFT'

            --添加控制面板
            e.AddPanel_Sub_Category({name=e.Icon.toRight2..(e.onlyChinese and '目标指示' or addName)..'|r', frame=panel})

            e.ReloadPanel({panel=panel, addName= e.cn(addName), restTips=nil, checked=not Save.disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
                disabledfunc=function()
                    Save.disabled= not Save.disabled and true or nil
                    if not TargetFrame and not Save.disabled  then
                        set_Option()
                        Init()
                    end
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), Save.disabled and (e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')
                end,
                clearfunc= function() Save=nil e.Reload() end}
            )

            if not Save.disabled then
                Init()
            end
        elseif arg1=='Blizzard_Settings' then
            set_Option()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)
--NamePlate2PlaterUnitFrameHealthBar