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
    --creatureNotParentTarget=true,--自定义位置
    --creatureUIParent=true,--放在UIPrent
    --creaturePoint={},--位置

    unitIsMe=true,--提示， 目标是你
    unitIsMeTextrue= 'auctionhouse-icon-favorite',
    unitIsMeSize=12,
    unitIsMePoint='TOPLEFT',
    unitIsMeParent='healthBar',--name
    unitIsMeX=0,
    unitIsMeY=-2,
    unitIsMeColor={r=1,g=1,b=1,a=1},

    quest= true,
    --questShowAllFaction=nil,--显示， 所有玩家派系
    questShowPlayerClass=true,--显示，玩家职业
    questShowInstance=e.Player.husandro,--在副本显示
}











local panel= CreateFrame("Frame")

local TargetFrame
local QuestFrame
local IsMeFrame
local NumFrame

--local CreatureLabel

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





local function set_Target_Color(self, isInCombat)--设置，颜色
    if self then
        if isInCombat then
            self:SetVertexColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
        else
            self:SetVertexColor(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a)
        end
    end
end











--指示目标 Blizzard_NamePlates.xml
--HealthBarsContainer castBar WidgetContainer
function Init_Target()
    if TargetFrame then
        TargetFrame:UnregisterAllEvents()
    end
    if not Save.target then
        if TargetFrame then
            TargetFrame:SetShown(false)
        end
    end

    if not TargetFrame then
        TargetFrame= CreateFrame("Frame")
        TargetFrame.Texture= TargetFrame:CreateTexture(nil, 'BACKGROUND')
        TargetFrame.Texture:SetAllPoints(TargetFrame)

        function TargetFrame:set_color(isInCombat)
            if isInCombat then
                self.Texture:SetVertexColor(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a)
            else
                self.Texture:SetVertexColor(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a)
            end
        end
        function TargetFrame:set_texture()
            self:SetSize(Save.w, Save.h)--设置大小
            local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save.targetTextureName)--设置，图片
            if isAtlas then
                self.Texture:SetAtlas(texture)
            else
                self.Texture:SetTexture(texture or 0)
            end

            if Save.scale~=1 then
                self:SetScript('OnUpdate', function(frame, elapsed)
                    frame.elapsed= (frame.elapsed or Save.elapsed) + elapsed
                    if frame.elapsed> Save.elapsed then
                        frame.elapsed=0
                        frame:SetScale(frame:GetScale()==1 and Save.scale or 1)
                    end
                end)
            else
                self:SetScript('OnUpdate', nil)
            end
            self:SetScale(1)--缩放
            self:set_color(Save.targetInCombat and UnitAffectingCombat('player') or false)
            self:set_target()
        end

        function TargetFrame:set_target()
            local plate= C_NamePlate.GetNamePlateForUnit("target", issecure())
            if not plate or not plate.UnitFrame then
                self:SetShown(false)
                return
            end

            local UnitFrame = plate.UnitFrame
            local frame--= get_isAddOnPlater(plate.UnitFrame.unit)--C_AddOns.IsAddOnLoaded("Plater")
            self:ClearAllPoints()
            if Save.TargetFramePoint=='TOP' then
                if UnitFrame.SoftTargetFrame.Icon:IsShown() then
                    frame= UnitFrame.SoftTargetFrame
                else
                    frame= UnitFrame.name or UnitFrame.healthBar
                end
                self:SetPoint('BOTTOM', frame or UnitFrame, 'TOP', Save.x, Save.y)

            elseif Save.TargetFramePoint=='HEALTHBAR' then
                frame= UnitFrame.healthBar or UnitFrame.name or UnitFrame
                local w, h= frame:GetSize()
                w= w+ Save.w
                h= h+ Save.h
                local n, p
                if UnitFrame.RaidTargetFrame.RaidTargetIcon:IsVisible() then
                    n= UnitFrame.RaidTargetFrame.RaidTargetIcon:GetWidth()+ UnitFrame.ClassificationFrame.classificationIndicator:GetWidth()

                --[[elseif UnitFrame.WidgetContainer:IsVisible() then
                    n= UnitFrame.WidgetContainer:GetWidth()]]

                elseif UnitFrame.ClassificationFrame.classificationIndicator:IsVisible() then
                    n= UnitFrame.ClassificationFrame.classificationIndicator:GetWidth()
                end

                if UnitFrame.questProgress then
                    p= UnitFrame.questProgress:GetWidth()
                end
                n, p= n or 0, p or 0
                self:SetSize(w+ n+ p, h)
                self:SetPoint('CENTER', UnitFrame, Save.x+ (-n+p)/2, Save.y)
            else

                if UnitFrame.RaidTargetFrame.RaidTargetIcon:IsVisible() then
                    frame= UnitFrame.RaidTargetFrame

                elseif UnitFrame.ClassificationFrame.classificationIndicator:IsVisible() then
                    frame= UnitFrame.ClassificationFrame.classificationIndicator

                elseif UnitFrame.WidgetContainer:IsVisible() then
                    frame= UnitFrame.WidgetContainer
                else
                    frame= UnitFrame.healthBar or UnitFrame.name
                end
                self:SetPoint('RIGHT', frame or UnitFrame, 'LEFT',Save.x, Save.y)
            end
            self:SetShown(true)
        end

        hooksecurefunc(NamePlateDriverFrame, 'OnSoftTargetUpdate', function()
            if Save.TargetFramePoint=='TOP' then
                TargetFrame:set_target()
            end
        end)

        TargetFrame:SetScript("OnEvent", function(self, event, arg1)
            if event=='PLAYER_TARGET_CHANGED'
                or event=='RAID_TARGET_UPDATE'
                or event=='UNIT_FLAGS'
                or event=='PLAYER_ENTERING_WORLD'
                or (event=='CVAR_UPDATE'
                    and (arg1=='nameplateShowAll' or arg1=='nameplateShowEnemies' or arg1=='nameplateShowFriends')
                )
            then
                C_Timer.After(0.15, function() self:set_target() end)

            elseif event=='PLAYER_REGEN_DISABLED' or event=='PLAYER_REGEN_ENABLED' then--颜色
                self:set_color(event=='PLAYER_REGEN_DISABLED')

            end
        end)
    end
    TargetFrame:SetShown(false)

    TargetFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    TargetFrame:RegisterEvent('CVAR_UPDATE')
    TargetFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    TargetFrame:RegisterEvent('RAID_TARGET_UPDATE')
    TargetFrame:RegisterUnitEvent('UNIT_FLAGS', 'target')
    if Save.targetInCombat then
        TargetFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
        TargetFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
    end
    TargetFrame:set_texture()
end
























--########################
--怪物目标, 队员目标, 总怪物
--########################
local function Init_Num()
    if NumFrame then
        NumFrame:UnregisterAllEvents()
    end
    if not Save.creature then
        if NumFrame then
            NumFrame.Text:SetText("")
        end
        return
    end
    --怪物数量
    if not NumFrame then
        if Save.creatureUIParent or not TargetFrame then
            NumFrame= WoWTools_ButtonMixin:Cbtn(nil, {size={18, 18}, icon='hide'})

            NumFrame.Text= WoWTools_LabelMixin:Create(NumFrame, {size=Save.creatureFontSize, color={r=1,g=1,b=1}})
            NumFrame.Text:SetScript('OnLeave', function(self) self:GetParent():SetButtonState('NORMAL') end)
            NumFrame.Text:SetScript('OnEnter', function(self) self:GetParent():SetButtonState('PUSHED') end)
            NumFrame.Text:SetPoint('LEFT', NumFrame, 'RIGHT')

            function NumFrame:set_point()
                self:ClearAllPoints()
                if Save.creaturePoint then
                    self:SetPoint(Save.creaturePoint[1], UIParent, Save.creaturePoint[3], Save.creaturePoint[4], Save.creaturePoint[5])
                elseif e.Player.husandro then
                    self:SetPoint('BOTTOM', _G['PlayerFrame'], 'TOP', 0,24)
                else
                    self:SetPoint('CENTER', -50, 20)
                end
            end
            NumFrame:set_point()

            NumFrame:RegisterForDrag("RightButton")
            NumFrame:SetMovable(true)
            NumFrame:SetClampedToScreen(true)

            NumFrame:SetScript("OnMouseUp", ResetCursor)
            NumFrame:SetScript("OnMouseDown", function(_, d)
                if IsAltKeyDown() and d=='RightButton' then--移动光标
                    SetCursor('UI_MOVE_CURSOR')
                end
            end)
            NumFrame:SetScript("OnDragStart", function(self)
                if IsAltKeyDown() then
                    self:StartMoving()
                end
            end)
            NumFrame:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.creaturePoint={self:GetPoint(1)}
                Save.creaturePoint[2]=nil
            end)
            NumFrame:SetScript("OnClick", function(self, d)
                if d=='RightButton' and IsControlKeyDown() then--还原
                    Save.creaturePoint=nil
                    self:set_point()
                    print(e.addName , e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                elseif d=='RightButton' and IsAltKeyDown() then
                    SetCursor('UI_MOVE_CURSOR')
                end
            end)
            NumFrame:SetScript('OnMouseWheel', function(self, d)--缩放
                if not IsAltKeyDown() then
                    return
                end
                local n=Save.creatureFontSize or 10
                if d==1 then
                    n=n+1
                elseif d==-1 then
                    n=n-1
                end
                n= n>72 and 72 or n
                n= n<8 and 8 or n
                Save.creatureFontSize=n
                WoWTools_LabelMixin:Create(nil, {changeFont=self.Text, size=n})
                self:set_tooltip()
                print(e.addName, e.cn(addName), (e.onlyChinese and '字体大小' or FONT_SIZE), '|cnGREEN_FONT_COLOR:'..Save.creatureFontSize)
            end)

            function NumFrame:set_tooltip()
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, e.cn(addName))
                e.tips:AddLine(' ')
                if e.onlyChinese then
                    e.tips:AddLine(e.onlyChinese and e.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r')
                else
                    e.tips:AddLine(e.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
                end
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
                e.tips:AddDoubleLine(e.onlyChinese and '重置位置' or RESET_POSITION, 'Ctrl+'..e.Icon.right)
                e.tips:AddDoubleLine((e.onlyChinese and '字体大小' or FONT_SIZE)..'|cnGREEN_FONT_COLOR:'..Save.creatureFontSize, 'Alt+'..e.Icon.mid)
                e.tips:Show()
            end
            NumFrame:SetScript('OnLeave', GameTooltip_Hide)
            NumFrame:SetScript("OnEnter", NumFrame.set_tooltip)
        else
            NumFrame= CreateFrame('Frame')
            NumFrame.Text= WoWTools_LabelMixin:Create(TargetFrame, {size=Save.creatureFontSize, color={r=1,g=1,b=1}})--10, nil, nil, {1,1,1}, 'BORDER', 'RIGHT')
            function NumFrame:set_text_point()
                self.Text:ClearAllPoints()
                if Save.TargetFramePoint=='LEFT' then
                    self.Text:SetPoint('CENTER')
                    self.Text:SetJustifyH('RIGHT')
                else
                    self.Text:SetPoint('BOTTOM', 0, 8)
                    self.Text:SetJustifyH('CENTER')
                end
            end
        end
        function NumFrame:set_pvp()
            self.isPvPArena= WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
        end
        function NumFrame:set_text()--local distanceSquared, checkedDistance = UnitDistanceSquared(u) inRange = CheckInteractDistance(unit, distIndex)
            local k,T,F=0,0,0
            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
                local unit = plate.UnitFrame and plate.UnitFrame.unit
                if UnitCanAttack('player', unit)
                    and (self.isPvPArena and UnitIsPlayer(unit) or not self.isPvPArena)
                    and e.CheckRange(unit, 40, true)
                then
                    k=k+1
                    if UnitIsUnit(unit..'target','player') then
                        T=T+1
                    end
                end
            end
            if IsInRaid() then
                for i=1, MAX_RAID_MEMBERS do
                    local unit='raid'..i..'target'
                    if UnitIsUnit(unit, 'player') and not UnitIsUnit(unit, 'player') then
                        F=F+1
                    end
                end
            elseif IsInGroup() then
                for i=1, MAX_PARTY_MEMBERS do
                    if UnitIsUnit('party'..i..'target', 'player') then
                        F=F+1
                    end
                end
            end
            NumFrame.Text:SetText(e.Player.col..(T==0 and '-' or  T)..'|r |cff00ff00'..(F==0 and '-' or F)..'|r '..(k==0 and '-' or k))
        end
        NumFrame:SetScript('OnEvent', function(self, event)
            if event=='PLAYER_ENTERING_WORLD' then
                self:set_pvp()
            end
            self:set_text()
        end)
        NumFrame:set_pvp()

    elseif NumFrame then
        WoWTools_LabelMixin:Create(nil, {changeFont=NumFrame.Text, size= Save.creatureFontSize})
    end

    local eventTab= {
        'NAME_PLATE_UNIT_ADDED',
        'NAME_PLATE_UNIT_REMOVED',
        'UNIT_TARGET',
        'PLAYER_ENTERING_WORLD'
        --'FORBIDDEN_NAME_PLATE_UNIT_ADDED',
        --'FORBIDDEN_NAME_PLATE_UNIT_REMOVED',
    }
    FrameUtil.RegisterFrameForEvents(NumFrame, eventTab)
    if NumFrame.set_text_point then
        NumFrame:set_text_point()
    end
    NumFrame:set_text()
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
        QuestFrame.THREAT_TOOLTIP= WoWTools_TextMixin:Magic(THREAT_TOOLTIP)--:gsub('%%d', '%%d+')--"%d%% 威胁"
        function QuestFrame:find_text(text)
            if text and not text:find(self.THREAT_TOOLTIP) then
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
        function QuestFrame:get_unit_text(unit)--取得，内容 GameTooltip.lua --local questID= line and line.id
            if not UnitIsPlayer(unit) then
                local type = UnitClassification(unit)
                if type=='rareelite' or type=='rare' or type=='worldboss' then--or type=='elite'
                    return '|A:VignetteEvent:18:18|a'
                end
                local tooltipData = C_TooltipInfo.GetUnit(unit)
                if tooltipData and tooltipData.lines then
                    for i = 4, #tooltipData.lines do
                        local line = tooltipData.lines[i]
                        --TooltipUtil.SurfaceArgs(line) 10.2.7没有FUNC
                        local text= self:find_text(line.leftText)
                        if text then
                            return text
                        end
                    end
                end
            elseif not (UnitInParty(unit) or UnitIsUnit('player', unit)) then
                local wow= WoWTools_UnitMixin:GetIsFriendIcon(nil, UnitGUID(unit), nil)--检测, 是否好友
                local faction= WoWTools_UnitMixin:GetFaction(unit, nil, Save.questShowAllFaction)--检查, 是否同一阵营
                local text
                if Save.questShowPlayerClass then
                    text= WoWTools_UnitMixin:GetClassIcon(unit)
                end
                if wow or faction then
                    text= (text or '')..(wow or '')..(faction or '')
                end
                return text
            end
        end
        function QuestFrame:set_quest_text(plate, unit)--设置，内容
            local plate= unit and C_NamePlate.GetNamePlateForUnit(unit, issecure()) or plate
            local frame= plate and plate.UnitFrame
            if not frame then
                return
            end
            local text= self:get_unit_text(frame.unit or unit)
            if text and not frame.questProgress then
                frame.questProgress= WoWTools_LabelMixin:Create(frame, {size=14, color={r=0,g=1,b=0}})--14, nil, nil, {0,1,0}, nil,'LEFT')
                frame.questProgress:SetPoint('LEFT', frame.healthBar or frame, 'RIGHT', 2,0)
            end
            if frame.questProgress then
                frame.questProgress:SetText(text or '')
            end
        end
        function QuestFrame:hide_plate(plate)--移除，内容
            if plate and plate.UnitFrame and plate.UnitFrame.questProgress then--任务
                plate.UnitFrame.questProgress:SetText('')
            end
        end
        function QuestFrame:rest_all()--移除，所有内容
            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
                QuestFrame:hide_plate(plate)
            end
        end
        function QuestFrame:check_all()--检查，所有
            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
                self:set_quest_text(plate, nil)
            end
        end
        function QuestFrame:set_event()--注册，事件
            self:UnregisterAllEvents()
            self:RegisterEvent('PLAYER_ENTERING_WORLD')

            local isPvPArena= WoWTools_MapMixin:IsInPvPArea()--是否在，PVP区域中
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
            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
                IsMeFrame:hide_plate(plate)
            end
        end
        return
    end
    if not IsMeFrame then
        IsMeFrame= CreateFrame('Frame')
        function IsMeFrame:set_texture(plate)--设置，参数
            local frame= plate and plate.UnitFrame
            if not frame.UnitIsMe then
                frame.UnitIsMe= frame:CreateTexture(nil, 'OVERLAY')
            end
            local parent= Save.unitIsMeParent=='name' and frame.name or frame.healthBar
            if Save.unitIsMePoint=='TOP' then
                frame.UnitIsMe:SetPoint("BOTTOM", parent, 'TOP', Save.unitIsMeX,Save.unitIsMeY)
            elseif Save.unitIsMePoint=='TOPRIGHT' then
                frame.UnitIsMe:SetPoint("BOTTOMRIGHT", parent, 'TOPRIGHT', Save.unitIsMeX,Save.unitIsMeY)
            elseif Save.unitIsMePoint=='LEFT' then
                frame.UnitIsMe:SetPoint("RIGHT", parent, 'LEFT', Save.unitIsMeX,Save.unitIsMeY)
            elseif Save.unitIsMePoint=='RIGHT' then
                frame.UnitIsMe:SetPoint("LEFT", parent, 'RIGHT', Save.unitIsMeX,Save.unitIsMeY)
            else--TOPLEFT
                frame.UnitIsMe:SetPoint("BOTTOMLEFT", parent, 'TOPLEFT', Save.unitIsMeX,Save.unitIsMeY)
            end
            local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save.unitIsMeTextrue)
            if isAtlas or not texture then
                frame.UnitIsMe:SetAtlas(texture or 'auctionhouse-icon-favorite')
            else
                frame.UnitIsMe:SetTexture(texture)
            end
            frame.UnitIsMe:SetVertexColor(Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a)
            frame.UnitIsMe:SetSize(Save.unitIsMeSize, Save.unitIsMeSize)
        end
        function IsMeFrame:set_plate(plate, unit)--设置, Plate
            plate= UnitExists(unit) and C_NamePlate.GetNamePlateForUnit(unit, issecure()) or plate
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
        function IsMeFrame:hide_plate(plate)--隐藏，Plate
            if plate and plate.UnitFrame and plate.UnitFrame.UnitIsMe then
                plate.UnitFrame.UnitIsMe:SetShown(false)
            end
        end
        function IsMeFrame:init_all()--检查，所有
            for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do
                self:set_plate(plate, nil)--设置
            end
        end
        hooksecurefunc(NamePlateBaseMixin, 'OnAdded', function(_, unit)
            IsMeFrame:set_plate(nil, unit)
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
    for _, plate in pairs(C_NamePlate.GetNamePlates(issecure()) or {}) do--初始，数据
        if plate.UnitFrame then
            if plate.UnitFrame.UnitIsMe then--修改
                plate.UnitFrame.UnitIsMe:ClearAllPoints()
                IsMeFrame:set_texture(plate)--设置，参数
            end
            IsMeFrame:set_plate(plate)--设置
        end
    end
end








































--####
--初始
--####
local function set_All_Init()
    Init_Target()
    Init_Num()
    Init_Quest()
    Init_Unit_Is_Me()
end

local function Init()
    hooksecurefunc(NamePlateBaseMixin, 'OnRemoved', function(plate)--移除所有
        if IsMeFrame then
            IsMeFrame:hide_plate(plate)
        end
        if QuestFrame then
            QuestFrame:hide_plate(plate)
        end
    end)
    set_All_Init()
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
    sel.Text:SetText('1) '..format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '目标' or addName))
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
            WoWTools_ColorMixin:ShowColorFrame(Save.targetColor.r, Save.targetColor.g, Save.targetColor.b, Save.targetColor.a, function()
                    setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
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
    panel.tipTargetTexture:SetSize(Save.w, Save.h)--设置，大小
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
            WoWTools_ColorMixin:ShowColorFrame(Save.targetInCombatColor.r, Save.targetInCombatColor.g, Save.targetInCombatColor.b, Save.targetInCombatColor.a, function()
                    setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
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


    --local menuPoint = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local menuPoint= CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")--下拉，菜单
    menuPoint:SetPoint("LEFT", combatCheck.Text, 'RIGHT', 15, 0)
    menuPoint:SetWidth(195)
    menuPoint.Text:ClearAllPoints()
    menuPoint.Text:SetPoint('CENTER')
    --e.LibDD:UIDropDownMenu_SetWidth(menuPoint, 100)
    menuPoint:SetDefaultText(Save.TargetFramePoint)
    menuPoint:SetupMenu(function(self, root)
        for _, name in pairs({
            'TOP',
            'HEALTHBAR',
            'LEFT'
        }) do
            root:CreateCheckbox(
                name,
            function(data)
                return Save.TargetFramePoint==data.name
            end, function(data)
                Save.TargetFramePoint= data.name
                self:SetDefaultText(data.name)
                set_All_Init()
            end, {name=name})
        end
    end)
    --[[e.LibDD:UIDropDownMenu_Initialize(menuPoint, function(self, level)
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

    --e.LibDD:UIDropDownMenu_SetText(menuPoint, Save.TargetFramePoint)
    -menuPoint.Button:SetScript('OnMouseDown', function(self)
        e.LibDD:CloseDropDownMenus(1)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)]]

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
        panel.tipTargetTexture:SetSize(Save.w, Save.h)--设置，大小
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
        panel.tipTargetTexture:SetSize(Save.w, Save.h)--设置，大小
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
            print(e.addName,e.cn(addName),'|cnRED_FONT_COLOR:', e.onlyChinese and '禁用' or DISABLE)
        else
            print(e.addName,e.cn(addName), '|cnGREEN_FONT_COLOR:', value)
        end
        set_All_Init()
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


    --local menu = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local menu= CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")--下拉，菜单
    menu:SetPoint("TOPLEFT", sel, 'BOTTOMRIGHT', -16,-82)
    menu:SetWidth(445)
    menu:SetDefaultText(Save.targetTextureName)
    menu.Text:ClearAllPoints()
    menu.Text:SetPoint('CENTER')
    menu:SetupMenu(function(self, root)
        local num, icon, sub= 0, nil, nil
        for name in pairs(get_texture_tab()) do
            icon= select(3, WoWTools_TextureMixin:IsAtlas(name))
            if icon then
                sub=root:CreateRadio(
                    icon,
                function(data)
                    return Save.targetTextureName== data.name
                end, function(data)
                    Save.targetTextureName= data.name
                    self:SetDefaultText(data.icon)
                    self.edit:SetText(data.name)
                    set_All_Init()
                end, {name=name, icon=icon})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(description.data.icon:gsub(':0', ':64'))
                    tooltip:AddLine(description.data.name)
                end)
                sub:AddInitializer(function(btn)
                    btn.fontString:ClearAllPoints()
                    btn.fontString:SetPoint('CENTER')
                end)
                num= num+1
            end
        end
        --SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(root, nil)
    end)
    --[[e.LibDD:UIDropDownMenu_SetWidth(menu, 410)
    e.LibDD:UIDropDownMenu_Initialize(menu, function(self, level)
        for name, use in pairs(get_texture_tab()) do
            local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(name)
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
    menu.Button:SetScript('OnMouseDown', function(self)
        e.LibDD:CloseDropDownMenus(1)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)]]

    menu.edit= CreateFrame("EditBox", nil, menu, 'InputBoxTemplate')--EditBox
    menu.edit:SetPoint("TOPLEFT", menu, 'BOTTOMLEFT',22,-2)
	menu.edit:SetSize(420,22)
	menu.edit:SetAutoFocus(false)
    menu.edit:ClearFocus()
    menu.edit.Label= WoWTools_LabelMixin:Create(menu.edit)
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
            isAtlas, name= WoWTools_TextureMixin:IsAtlas(name)
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
    menu.edit.del= WoWTools_ButtonMixin:Cbtn(menu.edit, {atlas='xmarksthespot', size=23})
    menu.edit.del:SetPoint('LEFT', menu, 'RIGHT',2,0)
    menu.edit.del:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtals, name= WoWTools_TextureMixin:IsAtlas(parent:GetText())
        if name and Save.targetTextureNewTab[name] then
            Save.targetTextureNewTab[name]= nil
            print(e.addName, e.cn(addName),
                '|cnRED_FONT_COLOR:'..(e.onlyChinese and '删除' or DELETE)..'|r',
                (isAtals and '|A:'..name..':0:0|a' or ('|T'..name..':0|t'))..name
            )
            e.LibDD:UIDropDownMenu_SetText(menu, '')
            parent:SetText("")
            parent:SetText(name)
        end
    end)

    --添加按钮
    menu.edit.add= WoWTools_ButtonMixin:Cbtn(menu.edit, {atlas=e.Icon.select, size=23})--添加, 按钮
    menu.edit.add:SetPoint('LEFT', menu.edit, 'RIGHT', 5,0)
    menu.edit.add:SetScript('OnClick', function(self)
        local parent= self:GetParent()
        local isAtlas, icon= WoWTools_TextureMixin:IsAtlas(parent:GetText())
        if icon and not Save.targetTextureNewTab[icon] then
            Save.targetTextureNewTab[icon]= isAtlas and 'a' or 't'
            parent:SetText('')
            print(e.addName,
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
        local atlas, icon= WoWTools_TextureMixin:IsAtlas(menu.edit:GetText())
        if icon then
            e.tips:AddDoubleLine(atlas and '|A:'..icon..':0:0|a' or ('|T'..icon..':0|t'), e.onlyChinese and '添加' or ADD)
            e.tips:AddDoubleLine(atlas and 'Atlas' or 'Texture', icon)
        else
            e.tips:AddLine(e.onlyChinese and '无' or NONE)
        end
        e.tips:Show()
    end)






















    local sel2= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    sel2.Text:SetText('2) '..(e.onlyChinese and '怪物数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)))
    sel2:SetPoint('TOPLEFT', menu.edit, 'BOTTOMLEFT', -32, -32)
    sel2:SetChecked(Save.creature)
    sel2:SetScript('OnLeave', GameTooltip_Hide)
    sel2:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if e.onlyChinese then
            e.tips:AddLine(e.onlyChinese and e.Player.col..'怪物目标(你)|r |cnGREEN_FONT_COLOR:队友目标(你)|r |cffffffff怪物数量|r')
        else
            e.tips:AddLine(e.Player.col..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, TARGET)..'('..YOU..')|r |cnGREEN_FONT_COLOR:'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, PLAYERS_IN_GROUP, TARGET)..'('..YOU..')|r |cffffffff'..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CREATURE, AUCTION_HOUSE_QUANTITY_LABEL)..'|r')
        end
        e.tips:Show()
    end)
    sel2:SetScript('OnClick', function()
        Save.creature= not Save.creature and true or nil
        set_All_Init()
    end)

    local numSize = e.CSlider(panel, {min=8, max=72, value=Save.creatureFontSize, setp=1, w=100, color=true,
    text= e.onlyChinese and '字体大小' or FONT_SIZE,
    func=function(self2, value)--字体大小
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.creatureFontSize= value
        set_All_Init()
    end})
    numSize:SetPoint("LEFT", sel2.Text, 'RIGHT',15,0)

    local numPostionCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    numPostionCheck.Text:SetText(e.onlyChinese and '自定义位置' or SPELL_TARGET_CENTER_LOC)
    numPostionCheck:SetPoint('LEFT', numSize, 'RIGHT', 10,0)
    numPostionCheck:SetChecked(Save.creatureUIParent)
    numPostionCheck:SetScript('OnClick', function()
        Save.creatureUIParent= not Save.creatureUIParent and true or nil
        set_All_Init()
        if not Save.creatureUIParent and not Save.target then
            print('|cnRED_FONT_COLOR:'..(e.onlyChinese and '需要启用‘1) '..format('|A:%s:0:0|a', e.Icon.toRight)..'目标’' or 'Need to enable the \"1) '..format('|A:%s:0:0|a', e.Icon.toRight)..addName..'\"'))
        end
        print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.creatureUIParent), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)























    local unitIsMeCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    unitIsMeCheck.Text:SetText('3) '..(e.onlyChinese and '目标是'..e.Player.col..'你|r' or 'Target is '..e.Player.col..'You|r'))
    unitIsMeCheck:SetPoint('TOP', sel2, 'BOTTOM', 0, -24)
    unitIsMeCheck:SetChecked(Save.unitIsMe)
    unitIsMeCheck:SetScript('OnClick', function()
        Save.unitIsMe= not Save.unitIsMe and true or false
        print(e.addName, e.cn(addName), e.GetEnabeleDisable(Save.unitIsMe), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        set_All_Init()
    end)

    --local menuUnitIsMePoint = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local menuUnitIsMePoint= CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")--下拉，菜单
    menuUnitIsMePoint:SetPoint("LEFT", unitIsMeCheck.Text, 'RIGHT', 15, 0)
    menuUnitIsMePoint:SetWidth(230)
    menuUnitIsMePoint:SetDefaultText(Save.unitIsMePoint)
    menuUnitIsMePoint.Text:ClearAllPoints()
    menuUnitIsMePoint.Text:SetPoint('CENTER')
    menuUnitIsMePoint:SetupMenu(function(self, root)
        for _, name in pairs({
            'TOPLEFT',
            'TOP',
            'TOPRIGHT',
            'LEFT',
            'RIGHT',
        }) do
            root:CreateRadio(
                name,
            function(data)
                return Save.unitIsMePoint==data.name
            end, function(data)
                Save.unitIsMePoint= data.name
                --self:SetDefaultText(data.name)
                set_All_Init()
            end, {name=name})
        end
        root:CreateDivider()
        for _, tab2 in pairs({
            {'healthBar', e.onlyChinese and '生命条' or 'HealthBar'},
            {'name', e.onlyChinese and '名称' or NAME},
        }) do
            root:CreateCheckbox(
                tab2[2],
            function(data)
                return  Save.unitIsMeParent== data.name
            end, function(data)
                Save.unitIsMeParent= data.name
                set_All_Init()
            end, {name= tab2[1]})
        end
    end)
    --[[e.LibDD:UIDropDownMenu_SetWidth(menuUnitIsMePoint, 100)
    
    e.LibDD:UIDropDownMenu_Initialize(menuUnitIsMePoint, function(self, level)
        local info
        local tab={
            'TOPLEFT',
            'TOP',
            'TOPRIGHT',
            'LEFT',
            'RIGHT',
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
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        tab={
            {'healthBar', e.onlyChinese and '生命条' or 'HealthBar'},
            {'name', e.onlyChinese and '名称' or NAME},
        }
        for _, tab2 in pairs(tab) do
            local info={
                text= tab2[2],
                checked= Save.unitIsMeParent==tab2[1],
                arg1= tab2[1],
                func= function(_, arg1)
                    Save.unitIsMeParent= arg1
                    set_All_Init()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
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
        e.LibDD:UIDropDownMenu_AddButton(info, level)
    end)
    e.LibDD:UIDropDownMenu_SetText(menuUnitIsMePoint, Save.unitIsMePoint)
    menuUnitIsMePoint.Button:SetScript('OnMouseDown', function(self)
        e.LibDD:CloseDropDownMenus(1)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)]]

    --local menuUnitIsMe = CreateFrame("FRAME", nil, panel, "UIDropDownMenuTemplate")--下拉，菜单
    local menuUnitIsMe= CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")--下拉，菜单
    menuUnitIsMe:SetPoint("LEFT", menuUnitIsMePoint, 'RIGHT', 2,0)
    menuUnitIsMe:SetWidth(150)
    menuUnitIsMe.Text:ClearAllPoints()
    menuUnitIsMe.Text:SetPoint('CENTER')
    menuUnitIsMe:SetupMenu(function(self, root)
        local num, icon, sub= 0, nil, nil
        for name in pairs(get_texture_tab()) do
            icon= select(3, WoWTools_TextureMixin:IsAtlas(name))
            if icon then
                sub=root:CreateRadio(
                    icon,
                function(data)
                    return Save.unitIsMeTextrue== data.name
                end, function(data)
                    Save.unitIsMeTextrue= data.name
                    self:set_icon()
                    set_All_Init()
                end, {name=name, icon=icon})
                sub:SetTooltip(function(tooltip, description)
                    tooltip:AddLine(description.data.icon:gsub(':0', ':64'))
                    tooltip:AddLine(description.data.name)
                end)
                sub:AddInitializer(function(btn)
                    btn.fontString:ClearAllPoints()
                    btn.fontString:SetPoint('CENTER')
                end)
                num= num+1
            end
        end

        --SetScrollMod
        WoWTools_MenuMixin:SetScrollMode(root, nil)
    end)
    --[[e.LibDD:UIDropDownMenu_SetWidth(menuUnitIsMe, 100)
    e.LibDD:UIDropDownMenu_Initialize(menuUnitIsMe, function(self, level)
        for name, use in pairs(get_texture_tab()) do
            local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(name)
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
                        self:set_icon()
                        set_All_Init()
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
    end)

    menuUnitIsMe.Button:SetScript('OnMouseDown', function(self)
        e.LibDD:CloseDropDownMenus(1)
        e.LibDD:ToggleDropDownMenu(1, nil, self:GetParent(), self, 15, 0)
    end)]]

    function menuUnitIsMe:set_icon()
        local isAtlas, texture= WoWTools_TextureMixin:IsAtlas(Save.unitIsMeTextrue)
        if isAtlas or not texture then
            e.LibDD:UIDropDownMenu_SetText(self, texture or 'auctionhouse-icon-favorite')
            self.Icon:SetAtlas(texture or 'auctionhouse-icon-favorite')
        else
            self.Icon:SetTexture(texture)
            e.LibDD:UIDropDownMenu_SetText(self, texture:match('.+\\(.+)%.') or texture)
        end
        self.Icon:SetVertexColor(Save.unitIsMeColor.r or 1, Save.unitIsMeColor.g or 1, Save.unitIsMeColor.b or 1, Save.unitIsMeColor.a or 1)
    end

    menuUnitIsMe.Icon= menuUnitIsMe:CreateTexture()
    menuUnitIsMe.Icon:SetSize(32,32)
    --menuUnitIsMe.Icon:ClearAllPoints()
    menuUnitIsMe.Icon:SetPoint('LEFT', menuUnitIsMe, 'RIGHT', 2)
    menuUnitIsMe.Icon:Show()
    menuUnitIsMe.Icon:EnableMouse(true)
    menuUnitIsMe.Icon:SetScript("OnLeave", function(self) self:SetAlpha(1) GameTooltip_Hide() end)
    menuUnitIsMe.Icon:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.Icon.left..(e.onlyChinese and '设置颜色' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SETTINGS ,COLOR)),
                            'r'..Save.unitIsMeColor.r..' g'..Save.unitIsMeColor.g..' b'..Save.unitIsMeColor.b..' a'..Save.unitIsMeColor.a)
        e.tips:AddDoubleLine(e.Icon.right..(e.onlyChinese and '默认' or DEFAULT), 'r1 g1 b1 a1' )
        e.tips:Show()
        self:SetAlpha(0.7)
    end)
    menuUnitIsMe.Icon:SetScript('OnMouseDown', function(self, d)
        if d=='RightButton' then
            Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a= 1,1,1,1
            self:GetParent():set_icon()
            set_All_Init()
            print(e.addName, e.cn(addName), e.onlyChinese and '默认' or DEFAULT)
        else
            local r,g,b,a= Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a
            WoWTools_ColorMixin:ShowColorFrame(r,g,b,a,
                function()
                    Save.unitIsMeColor=  select(5, WoWTools_ColorMixin:Get_ColorFrameRGBA())--取得, ColorFrame, 颜色
                    self:GetParent():set_icon()
                    set_All_Init()
                end, function()
                    Save.unitIsMeColor.r, Save.unitIsMeColor.g, Save.unitIsMeColor.b, Save.unitIsMeColor.a= r, g, b, a
                    self:GetParent():set_icon()
                    set_All_Init()
                end
            )
            self:SetAlpha(1)
        end
    end)

    menuUnitIsMe:set_icon()

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
    text= e.onlyChinese and '大小' or HUD_EDIT_MODE_SETTING_ARCHAEOLOGY_BAR_SIZE,
    func=function(self2, value)
        value= math.floor(value)
        self2:SetValue(value)
        self2.Text:SetText(value)
        Save.unitIsMeSize= value
        set_All_Init()
    end})
    unitIsMeSize:SetPoint("LEFT", unitIsMeY, 'RIGHT',15,0)




















    local questCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questCheck.Text:SetText('4) '..(e.onlyChinese and '任务进度' or (format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, QUESTS_LABEL, PVP_PROGRESS_REWARDS_HEADER))))
    questCheck:SetPoint('TOPLEFT', unitIsMeCheck, 'BOTTOMLEFT',0,-64)
    questCheck:SetChecked(Save.quest)
    questCheck:SetScript('OnClick', function()
        Save.quest= not Save.quest and true or nil
        set_All_Init()
    end)

    local questAllFactionCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    questAllFactionCheck.Text:SetFormattedText(
        '%s|A:%s:0:0|a|A:%s:0:0|a',
---@diagnostic disable-next-line: undefined-global
        e.onlyChinese and '所有阵营' or TRANSMOG_SHOW_ALL_FACTIONS or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ALL, FACTION),
        e.Icon.Horde, e.Icon.Alliance)
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
            e.AddPanel_Sub_Category({name=format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '目标' or addName)..'|r', frame=panel})

            e.ReloadPanel({panel=panel, addName= e.cn(addName), restTips=nil, checked=not Save.disabled, clearTips=nil, reload=false,--重新加载UI, 重置, 按钮
                disabledfunc=function()
                    Save.disabled= not Save.disabled and true or nil
                    if not TargetFrame and not Save.disabled  then
                        set_Option()
                        Init()
                    end
                    print(e.addName, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), Save.disabled and (e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD) or '')
                end,
                clearfunc= function() Save=nil WoWTools_Mixin:Reload() end}
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