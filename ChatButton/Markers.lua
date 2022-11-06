local id, e = ...
local addName= BINDING_HEADER_RAID_TARGET
local Save={
    tank=2,
    tank2=6,
    healer=1,
}
local panel=e.Cbtn2(nil, WoWToolsChatButtonFrame, true, false)

local function getTexture(index)--取得图片
    if index==0 or index>NUM_WORLD_RAID_MARKERS then
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
local function setRaidTarget()--设置团队标记
    local tab={}
    for index=1,GetNumGroupMembers() do-- MAX_RAID_MEMBERS do
        local online, _, role= select(8, GetRaidRosterInfo(index))
        if role=='TANK' and online then
            table.insert({
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
local function setTankHealer(auto)--设置队伍标记
    local num=GetNumGroupMembers()
    if Save.tank==0 or num<2 then
        if num<2 then
            print(id, addName, SETTINGS, TANK..getTexture(Save.tank), HEALER..getTexture(Save.healer), '|cnRED_FONT_COLOR:'..SPELL_TARGET_TYPE4_DESC..'<2|r') 
        end
        return
    end
    local group=IsInGroup()
    local raid=IsInRaid()
    local leader=getIsLeader()
    if auto then
        if group then
            if raid then
                if leader then
                    setRaidTarget()--设置团队标记
                end
            else
                setPartyTarget()--设置队伍标记
            end
        end
    else
        if raid then
            if not leader then--没有权限
                print(id, addName, SETTINGS, TANK..getTexture(Save.tank), HEALER..getTexture(Save.healer), '|cnRED_FONT_COLOR:'..ERR_ARENA_TEAM_PERMISSIONS..'|r')
            else
                setRaidTarget()--设置团队标记
            end
        else
            setPartyTarget()--设置队伍标记
        end
    end
end

--########
--设置,按钮
--########
local function setTexture()--设置,按钮主图片
    panel.texture:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_'..(Save.tank~=0 and Save.tank or Save.healer))
end

--####
--初始
--####
local function Init()
    setTexture()--设置图片
    panel:SetPoint('LEFT',WoWToolsChatButtonFrame, 'RIGHT')
    panel:SetScript("OnMouseDown", function(self,d)
        if d=='RightButton' then
        elseif d=='LeftButton' then
            setTankHealer()--设置队伍标记
        end
      end)
      panel:SetScript("OnMouseUp", function(self, d)
      end)
      panel:SetScript('OnEnter', function (self)
      end)
      panel:SetScript("OnLeave",function(self)
      end)
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
        if WoWToolsChatButtonFrame.disabled then
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
    end
end)
--[[
TANK='|A:groupfinder-icon-role-large-tank:0:0|a',
HEALER='|A:groupfinder-icon-role-large-heal:0:0|a',
DAMAGER='|A:groupfinder-icon-role-large-dps:0:0|a',
NONE='|A:groupfinder-icon-emptyslot:0:0|a',
leader='

NUM_WORLD_RAID_MARKERS = 8;
NUM_RAID_ICONS = 8;

WORLD_RAID_MARKER_ORDER = {};
WORLD_RAID_MARKER_ORDER[1] = 8;
WORLD_RAID_MARKER_ORDER[2] = 4;
WORLD_RAID_MARKER_ORDER[3] = 1;
WORLD_RAID_MARKER_ORDER[4] = 7;
WORLD_RAID_MARKER_ORDER[5] = 2;
WORLD_RAID_MARKER_ORDER[6] = 3;
WORLD_RAID_MARKER_ORDER[7] = 6;
WORLD_RAID_MARKER_ORDER[8] = 5;

MAX_RAID_MEMBERS = 40;
NUM_RAID_GROUPS = 8;
MEMBERS_PER_RAID_GROUP = 5;
MAX_RAID_INFOS = 20;

MAX_PARTY_MEMBERS = 4;
]]
    
--Blizzard_CompactRaidFrameManager.lua