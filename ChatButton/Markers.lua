local id, e = ...
local addName= BINDING_HEADER_RAID_TARGET
local Save={ autoSet=true, tank=2, tank2=6, healer=1,}

local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)
WoWToolsChatButtonFrame.last=panel

local color={
    [1]={r=1, g=1, b=0},--星星, 黄色
    [2]={r=1, g=0.45, b=0.04},--圆形, 金色
    [3]={r=1, g=0, b=1},--菱形,紫色
    [4]={r=0, g=1, b=0},--三角,绿色

    [5]={r=0.6, g=0.6, b=0.6},--月亮,灰色
    [6]={r=0.1, g=0.2, b=1},--方块, 蓝色
    [7]={r=1, g=0, b=0},--十字, 红色
    [8]={r=1, g=1, b=1},--骷髅,白色
}
local function getTexture(index)--取得图片
    if not index or index<1 or index>NUM_WORLD_RAID_MARKERS then
        return ''
    else
        return '|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..index..':0|t'
    end
end

local function getIsLeader()--队长， 或助理
    return UnitIsGroupAssistant('player') or UnitIsGroupLeader('player')
end

local function setTaget(unit, index)--设置,目标,标记
    if CanBeRaidTarget(unit) and GetRaidTargetIndex(unit)~=index then
        SetRaidTarget(unit, index)
    end
end

local function getAllSet()--是不有权限
    local raid =IsInRaid()
    return (raid and getIsLeader()) or not raid
end

local function setRaidTarget()--设置团队标记
    local tab={}
    for index=1,GetNumGroupMembers() do-- MAX_RAID_MEMBERS do
        local online, _, role, _, combatRole = select(8, GetRaidRosterInfo(index))
        if (role=='TANK' or  combatRole=='TANK') and online then
            table.insert(tab, {
                unit='raid'..index,
                hp=UnitHealthMax('raid'..index)
            })
        end
    end
    if #tab>0 then
        table.sort(tab, function(a,b) return a.hp<b.hp end)
        setTaget(tab[1].unit, Save.tank)--设置,目标,标记
        if tab[2] and Save.tank2~=0 then
            setTaget(tab[2].unit, Save.tank)--设置,目标,标记
        end
    end
end

local function setPartyTarget()--设置队伍标记
    local tank, healer
    local num=GetNumGroupMembers()--MAX_PARTY_MEMBERS + 1
    for index=1, num do
        local unit = index==num and 'player' or 'party'..index
        local role = UnitGroupRolesAssigned(unit)
        if role=='TANK' then
            if not tank then
                setTaget(unit, Save.tank)--设置,目标,标记
                tank=true
            end
        elseif role=='HEALER' then
            if not healer then
                setTaget(unit, Save.healer)--设置,目标,标记
                healer=true
            end
        end
    end
end

local function setTankHealer(autoSet)--设置队伍标记
    if autoSet and not Save.autoSet then
        return
    end
    local num=GetNumGroupMembers()
    if Save.tank==0 or num<2 then
        if num<2 and not autoSet then
            print(id, addName, SETTINGS, TANK..getTexture(Save.tank), HEALER..getTexture(Save.healer), '|cnRED_FONT_COLOR:'..SPELL_TARGET_TYPE4_DESC..'<2|r') 
        end
        return
    end
    if IsInRaid() then
        if not getIsLeader() and not autoSet then--没有权限
            print(id, addName, SETTINGS, TANK..getTexture(Save.tank), HEALER..getTexture(Save.healer), '|cnRED_FONT_COLOR:'..ERR_ARENA_TEAM_PERMISSIONS..'|r')
        else
            setRaidTarget()--设置团队标记
        end
    else
        setPartyTarget()--设置队伍标记
    end
end

--#############
--设置,按钮,图片
--#############
local function setTexture()--图标, 自动标记
    if Save.tank==0 then
        panel.texture:SetTexture(0)
    else
        panel.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save.tank)
    end
    if Save.autoSet then
        panel.border:SetAtlas('bag-border')
    else
        panel.border:SetAtlas('bag-reagent-border')
    end 
end
local function setAllTextrue()--主图标,是否有权限
    panel.texture:SetDesaturated(GetNumGroupMembers() <2  or not getAllSet())
end

--#############
--设置标记, 框架
--#############
local function C(unit, index)
    local t=GetRaidTargetIndex(unit)
    if t and t>0 and (index==t or not index) then
        setTaget(unit, 0)--设置,目标,标记
    end
end
local function Clear(index)--取消标记标    
    local u;--取消怪物标记
    for _, v in pairs(C_NamePlate.GetNamePlates()) do
        u = v.namePlateUnitToken or (v.UnitFrame and v.UnitFrame.unit)
        C(u, index);
    end
    if R then u='raid' else u='party' end--取消队友标记
    for i=1, GetNumGroupMembers() do
        C(u..i, index)
        C(u..i..'target', index)
        C(u..'pet'..i, index)
    end
    u={
        'player', 'target','pet','focus',
        'boss1', 'boss2', 'boss3', 'boss4', 'boss5'
    }
    for _, v in pairs(u) do
        C(v, index)
    end
end

local frame, frame2

local function setMarkersFrame()--设置标记, 框架
    if not Save.markersFrame or not getAllSet() then
        if frame then
            frame:SetShown(false)
        end
        return
    end
    if not frame then
        frame=CreateFrame("Frame",nil, UIParent)-- e.Cbtn(UIParent, nil, nil, nil, nil, true, {30,30})
        frame:SetFrameStrata('HIGH')
        if Save.markersFramePoint then
            frame:SetPoint(Save.markersFramePoint[1], UIParent, Save.markersFramePoint[3], Save.markersFramePoint[4], Save.markersFramePoint[5])
        else
            frame:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton12, 'TOPRIGHT')
        end
        frame:SetSize(1, 25)
        frame:SetMovable(true)
        frame:SetClampedToScreen(true)
        if Save.markersScale and Save.markersScale~=1 then--缩放
            frame:SetScale(Save.markersScale)
        end
        local last
        for index = 0, NUM_RAID_ICONS do
            local button=e.Cbtn(frame, nil, nil, nil, nil, true, {25,25})
            if Save.H then
                button:SetPoint('BOTTOMLEFT', last or frame, 'TOPLEFT')
            else
                button:SetPoint('BOTTOMRIGHT', last or frame, 'BOTTOMLEFT')
            end
            --button:SetPoint('BOTTOMRIGHT', last or frame, 'BOTTOMLEFT')
            if index==0 then
                button:SetNormalTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-mark.tga')
                button:RegisterForDrag("RightButton")
                button:SetScript("OnDragStart", function(self,d )
                    if d=='RightButton' and not IsModifierKeyDown() then
                        frame:StartMoving()
                    end
                end)
                button:SetScript("OnDragStop", function(self)
                    ResetCursor()
                    frame:StopMovingOrSizing()
                    Save.markersFramePoint={frame:GetPoint(1)}
                    Save.markersFramePoint[2]=nil
                    print(id, addName, 	RESET_POSITION, 'Alt+'..e.Icon.right)
                end)
                button:SetScript('OnMouseDown', function(self, d)
                    local key=IsModifierKeyDown()
                    if d=='LeftButton' and not key then
                        Clear()--取消标记标
                    elseif d=='RightButton' and not key then
                        SetCursor('UI_MOVE_CURSOR')
                    elseif d=='RightButton' and IsAltKeyDown() then
                        frame:ClearAllPoints()
                        frame:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton12, 'TOPRIGHT')
                    elseif d=='RightButton' and IsControlKeyDown() then
                        Save.H = not Save.H and true or nil
                        print(id,addName,HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION..(Save.H and e.Icon.up2 or e.Icon.toLeft2), REQUIRES_RELOAD,'/reload')
                    end
                end)
                button:SetScript('OnMouseUp', function()
                    ResetCursor()
                end)
                button:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:AddDoubleLine(e.Icon.O2..CLEAR_ALL, e.Icon.left)
                    e.tips:AddDoubleLine(NPE_MOVE,e.Icon.right)
                    e.tips:AddDoubleLine(UI_SCALE, (Save.markersScale or 1)..' Alt+'..e.Icon.mid)
                    e.tips:AddDoubleLine(HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION..(Save.H and e.Icon.toLeft2 or e.Icon.up2), 'Ctrl+'..e.Icon.right)
                    e.tips:Show()
                end)
                button:EnableMouseWheel(true)
                button:SetScript('OnMouseWheel', function(self, d)--缩放
                    if IsAltKeyDown() then
                        local sacle=Save.markersScale or 1
                        if d==1 then
                            sacle=sacle+0.1
                        elseif d==-1 then
                            sacle=sacle-0.1
                        end
                        if sacle>3 then
                            sacle=3
                        elseif sacle<0.6 then
                            sacle=0.6
                        end
                        print(id, addName, UI_SCALE, sacle)
                        frame:SetScale(sacle)
                        Save.markersScale=sacle
                    end
                end)
            else
                button:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
                button:SetScript('OnMouseDown', function(self, d)
                    if d=='LeftButton' then
                        setTaget('target', index)--设置,目标, 标记
                    elseif d=='RightButton' then
                        Clear(index)--取消标记标    
                    end
                end)
                button:SetScript('OnEnter', function(self)
                    e.tips:SetOwner(frame, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    e.tips:AddDoubleLine(id, addName)
                    e.tips:AddDoubleLine(getTexture(index)..SETTINGS, e.Icon.left, color[index].r, color[index].g, color[index].b)
                    e.tips:AddDoubleLine(getTexture(index)..(CLEAR or KEY_NUMLOCK_MAC), e.Icon.right, color[index].r, color[index].g, color[index].b)
                    
                    e.tips:Show()
                end)
            end
            button:SetScript('OnLeave', function()
                e.tips:Hide()
            end)
            last=button
        end
    end
    frame:SetShown(true)

    local combat=UnitAffectingCombat('player')--世界标记
    local isInGroup=IsInGroup()
    if combat then
       if not isInGroup or not frame2 or not fram2:IsShown() then
            panel:RegisterEvent('PLAYER_REGEN_ENABLED')
            panel.combat=true
            return
       end
    elseif not isInGroup then
        if frame2 then
            frame2:SetShown(false)
        end
        return
    end
    if not frame2 then
        frame2=CreateFrame("Frame", nil, frame)
        if Save.H then
            frame2:SetPoint('TOPRIGHT', frame, 'TOPLEFT')
        else
            frame2:SetPoint('TOPLEFT', frame, 'TOPRIGHT',-1,0)
        end
        frame2:SetSize(1, 1)
        local last
        local tab={5,6,3,2,7,1,4,8}
        for index=0,  NUM_WORLD_RAID_MARKERS do
            local button=e.Cbtn(frame2, nil, nil, true, nil, true, {25,25})
            if Save.H then
                button:SetPoint('BOTTOMRIGHT', last or frame2, 'TOPRIGHT')
            else
                button:SetPoint('BOTTOMRIGHT', last or frame2, 'BOTTOMLEFT')
            end
            button:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)

            button:SetAttribute('type1', 'worldmarker')
            button:SetAttribute('marker1', index==0 and 0 or tab[index])
            button:SetAttribute("action1", index==0 and 'clear' or "set")

            button:SetAttribute("type2", "worldmarker")
            button:SetAttribute("marker2", index==0 and 0 or tab[index])
            button:SetAttribute("action2", "clear")
            if index==0 then
                button:SetNormalTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\cancel-mark.tga')
            else
                button:SetNormalTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index)
            end
            button:SetScript('OnLeave', function()
                e.tips:Hide()
            end)
            button:SetScript('OnEnter', function(self)
                e.tips:SetOwner(frame, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                if index==0 then
                    e.tips:AddDoubleLine(e.Icon.O2..CLEAR_ALL, e.Icon.left)
                else
                    e.tips:AddDoubleLine(getTexture(index)..SETTINGS, e.Icon.left, color[index].r, color[index].g, color[index].b)
                    e.tips:AddDoubleLine(getTexture(index)..(CLEAR or KEY_NUMLOCK_MAC), e.Icon.right, color[index].r, color[index].g, color[index].b)
                end
                e.tips:Show()
            end)
            last=button
            if index~=0 then--背景
                button.texture=button:CreateTexture(nil,'BACKGROUND')
                button.texture:SetAllPoints(button)
                button.texture:SetColorTexture(color[index].r, color[index].g, color[index].b)
                button.texture:SetAlpha(0.3)
            end
        end
    end
    frame2:SetShown(true)
end

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local colorCode={
        [1]='|cffffff00',
        [2]='|cffE29114',
        [3]='|cffff00ff',
        [4]='|cff00ff00',
        [6]='|cff03BBFA',
        [7]='|cffff0000',
    }
    local info
    if type then
        local num= NUM_RAID_ICONS+1
        for index=1, num do
            if index==num then
                UIDropDownMenu_AddSeparator(level)
            end
            info={
                text= index==num and NONE or _G['RAID_TARGET_'..index],
                icon= index==num and nil or 'Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..index,
                checked= Save[type]==index,
                colorCode=colorCode[index],
                func=function()
                    Save[type]=index
                    CloseDropDownMenus()
                    if type=='tank' then
                        setTexture()--图标, 自动标记
                    end
                end
            }
            if index~=0 then
                if type=='tank' then
                    info.disabled= Save.healer==index or Save.tank2==index
                elseif type=='tank2' then
                    info.disabled= Save.tank==index or Save.tank==0
                elseif type=='healer' then
                    info.disabled= Save.tank==index
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
        info={
            text=LFG_LIST_CROSS_FACTION:format(type=='tank2' and RAID or type=='healer' and GROUP or (HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS)),
            notCheckable=true,
            isTitle=true,
        }
        UIDropDownMenu_AddButton(info, level)
    else
        info={
            text=AUTO_JOIN:gsub(JOIN,'')..EVENTTRACE_MARKER..e.Icon.TANK..e.Icon.HEALER,
            checked= Save.autoSet,
            disabled= Save.tank==0 and Save.healer==0,
            func=function()
                if Save.autoSet then
                    Save.autoSet=nil
                else
                    Save.autoSet=true
                    setTankHealer(true)
                end
                setTexture()--设置,按钮图片
            end
        }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator()

        local tab={
                {text= e.Icon.TANK..TANK, type='tank'},
                {text= e.Icon.HEALER..HEALER, type='healer'},
                {text= e.Icon.TANK..TANK..'2', type='tank2'},
            }
        for _, tab2 in pairs(tab) do
            info={
                text=tab2.text,
                checked=Save[tab2.type]~=0,
                menuList=tab2.type,
                hasArrow=true,
            }
            if Save[tab2.type]~=0 then
                info.text=info.text..'|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_'..Save[tab2.type]..':0|t'
            end
            info.colorCode=colorCode[Save[tab2.type]]
            if tab2.type2 and Save.tank==0 then
                info.disabled=true
            end
            UIDropDownMenu_AddButton(info, level)
            if tab2.type=='healer' then
                UIDropDownMenu_AddSeparator()
            end
        end

        UIDropDownMenu_AddSeparator()
        info={
            text=PROFESSION_TOOL_TOOLTIP_LINE:format(BINDING_HEADER_RAID_TARGET),
            checked=Save.markersFrame,
            func=function()
                if UnitAffectingCombat('player') then
                    print(id, addName, '|cnRED_FONT_COLOR:'..COMBAT..'|r')
                    return
                end
                Save.markersFrame= not Save.markersFrame and true or nil
                setMarkersFrame()--设置标记, 框架
            end,
            disabled=not getAllSet(),--是不有权限
        }
        UIDropDownMenu_AddButton(info, level)
    end
end

--####
--初始
--####
local function Init()
    setTexture()--设置,按钮图片
    setAllTextrue()--主图标,是否有权限
    setMarkersFrame()--设置标记, 框架

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetPoint('LEFT',WoWToolsChatButtonFrame, 'RIGHT')
    panel:SetScript("OnMouseDown", function(self,d)
        local key=IsModifierKeyDown()
        if d=='RightButton' and not key then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)

        elseif d=='LeftButton' and not key then
            setTankHealer()--设置队伍标记
        end
      end)
    --[[
  panel:SetScript("OnMouseUp", function(self, d)
      end)
      panel:SetScript('OnEnter', function (self)
      end)
      panel:SetScript("OnLeave",function(self)
      end)

]]

end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('GROUP_ROSTER_UPDATE')--'PLAYER_ROLES_ASSIGNED')--GROUP_ROSTER_UPDATE
panel:RegisterEvent('GROUP_LEFT')

--panel:RegisterEvent('GROUP_LEFT')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then--禁用Chat Button
            panel:UnregisterAllEvents()
            return
        end
        Save= WoWToolsSave and WoWToolsSave[addName] or Save
        Init()

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event=='GROUP_ROSTER_UPDATE' or event=='GROUP_LEFT' then
        setTankHealer(true)--设置队伍标记
        setAllTextrue()--主图标,是否有权限
        setMarkersFrame()--设置标记, 框架

    elseif event=='PLAYER_REGEN_ENABLED' then
        if self.combat then
            setMarkersFrame()--设置标记, 框架
            self.combat=nil
            self.UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
end)
--Blizzard_CompactRaidFrameManager.lua