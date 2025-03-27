local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end
local P_PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES





local AttributesCategory={}

local function Init_AttributesCategory()
    AttributesCategory={
        {stat='STRENGTH', index=1, name=WoWTools_DataMixin.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH, primary=LE_UNIT_STAT_STRENGTH},--AttributesCategory
        {stat='AGILITY', index=1, name=WoWTools_DataMixin.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY, rimary=LE_UNIT_STAT_AGILITY},
        {stat='INTELLECT', index=1, name=WoWTools_DataMixin.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT, primary=LE_UNIT_STAT_INTELLECT},
        {stat='-'},
        {stat='STAMINA', index=1, name= WoWTools_DataMixin.onlyChinese and '耐力' or STA_LCD},
        {stat='ARMOR', index=1},
        {stat='STAGGER', index=1},
        {stat='MANAREGEN', index=1, name=WoWTools_DataMixin.onlyChinese and '法力回复' or MANA_REGEN},
        {stat='SPELLPOWER', index=1, name=WoWTools_DataMixin.onlyChinese and '法术强度' or STAT_SPELLPOWER},

        {stat='HEALTH', index=1},
        {stat='POWER', index=1, name=WoWTools_DataMixin.onlyChinese and '能量' or POWER_TYPE_POWER},
        {stat='ALTERNATEMANA', index=1, name=WoWTools_DataMixin.onlyChinese and '法力值' or  MANA},

        {stat='-'},
    --}
    --local EnhancementsCategory={
        {stat='CRITCHANCE', index=2, name=WoWTools_DataMixin.onlyChinese and '爆击' or STAT_CRITICAL_STRIKE},
        {stat='HASTE', index=2},
        {stat='MASTERY', index=2},
        {stat='VERSATILITY', index=2},
        {stat='LIFESTEAL', index=2},
        {stat='AVOIDANCE', index=2},
        {stat='SPEED', index=2},
        {stat='DODGE', index=2},
        {stat='PARRY', index=2},
        {stat='BLOCK', index=2},

        {stat='ENERGY_REGEN', index=2},
        {stat='RUNE_REGEN', index=2},
        {stat='FOCUS_REGEN', index=2},

        {stat='MOVESPEED', index=2, name=WoWTools_DataMixin.onlyChinese and '移动' or NPE_MOVE},
        {stat='ATTACK_DAMAGE', index=2, name=WoWTools_DataMixin.onlyChinese and '伤害' or DAMAGE, },
        {stat='ATTACK_AP', index=2,  name=WoWTools_DataMixin.onlyChinese and '攻击强度' or STAT_ATTACK_POWER, },
        {stat='ATTACK_ATTACKSPEED', index=2, name=WoWTools_DataMixin.onlyChinese and '攻击速度' or ATTACK_SPEED},
    }
end





local function Data_Save()
    WoWTools_Mixin:Call(PaperDollFrame_UpdateStats)
    Save().PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES
end




local function Find_Stats(stat, index, P)--查找
    local tabs
    if P then
        tabs=P_PAPERDOLL_STATCATEGORIES[index]
    else
       tabs= PAPERDOLL_STATCATEGORIES[index]
    end
    if tabs then
        for _, tab in pairs(tabs.stats or {}) do
            if tab.stat==stat then
                return tab
            end
        end
    end
    return false
end

local function Find_Roles(roles)
    local tank, n, dps= false, false, false
    for _, num in pairs(roles or {}) do
        if num== Enum.LFGRole.Tank then--0
            tank=true
        elseif num== Enum.LFGRole.Healer then--1
            n=true
        elseif num== Enum.LFGRole.Damage then--2
            dps=true
        end
    end
    return tank, n, dps
end

local function Add_Stat(tab)--添加
    local index= tab.index
    local stat=tab.stat
    if not PAPERDOLL_STATCATEGORIES[index] then
        local categoryFrame= index==1 and 'AttributesCategory'
                    or (index==2 and 'EnhancementsCategory')
                    or (index==3 and 'GeneralCategory')
                    or (index==4 and 'AttackCategory')
                    or 'OtherCategory'
        PAPERDOLL_STATCATEGORIES[index]= {
            categoryFrame= categoryFrame,
            stats={},
        }
        if not CharacterStatsPane[categoryFrame] then
            local frame= CreateFrame("Frame", nil, CharacterStatsPane, 'CharacterStatFrameCategoryTemplate')
            local title= index==3 and (WoWTools_DataMixin.onlyChinese and '综合' or GENERAL)
                    or index==4 and (WoWTools_DataMixin.onlyChinese and '攻击' or ATTACK)
                    or (WoWTools_DataMixin.onlyChinese and '其它' or OTHER)
            frame.titleText=title
            frame.Title:SetText(title)
            CharacterStatsPane[categoryFrame]= frame
        end
    end
    local P_tab= Find_Stats(stat, index, true)--查找
    if not PAPERDOLL_STATCATEGORIES[index] then
        PAPERDOLL_STATCATEGORIES[index]= {categoryFrame= index}
    end
    if P_tab then
        table.insert(PAPERDOLL_STATCATEGORIES[index].stats, P_tab)
    else
        table.insert(PAPERDOLL_STATCATEGORIES[index].stats, {
            stat=stat,
            hideAt=-1,
            --roles= tab.roles,
            --primary= tab.primary,
            --showFunc= tab.showFunc,
        })
    end
    --print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stat), WoWTools_DataMixin.onlyChinese and '添加' or ADD)
end

local function Remove_Stat(tab)--移除        
    local index= tab.index
    local stat= tab.stat
    --local name= tab.name
    if PAPERDOLL_STATCATEGORIES[index] then
        for i, info in pairs(PAPERDOLL_STATCATEGORIES[index].stats or {}) do
            if info.stat==stat then
                table.remove(PAPERDOLL_STATCATEGORIES[index].stats, i)
                --print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r', WoWTools_DataMixin.onlyChinese and '移除' or REMOVE), stat, name)
                return
            end
        end
    end
    --print(WoWTools_DataMixin.Icon.icon2..WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r', WoWTools_DataMixin.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), stat, name)
end

local function Get_Primary_Text(primary)--主属性, 文本
    if primary then
        if primary==LE_UNIT_STAT_STRENGTH then
            return format('|cffc69b6d%s|r', WoWTools_DataMixin.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH)
        elseif primary==LE_UNIT_STAT_AGILITY then
            return format('|cff16c663%s|r', WoWTools_DataMixin.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY)
        elseif primary==LE_UNIT_STAT_INTELLECT then
            return format('|cff00ccff%s|r', WoWTools_DataMixin.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT)
        end
    end
end


local function Get_Role_Text(roleIndex)--职责
    return
        roleIndex== Enum.LFGRole.Tank and format('%s%s', WoWTools_DataMixin.Icon.TANK, WoWTools_DataMixin.onlyChinese and '坦克' or TANK)
        or (roleIndex==Enum.LFGRole.Healer and format('%s%s', WoWTools_DataMixin.Icon.TANK, WoWTools_DataMixin.onlyChinese and '治疗' or HEALER))
        or (roleIndex==Enum.LFGRole.Damage and format('%s%s', WoWTools_DataMixin.Icon.DAMAGER, WoWTools_DataMixin.onlyChinese and '伤害' or DAMAGER))
        or (WoWTools_DataMixin.onlyChinese and '无' or NONE)
    
end

















local function Init_Sub_Menu(_, root, stat, index, name)
    local stats= Find_Stats(stat, index, false)

    if not stats then
        return
    end

    local p_stats= Find_Stats(stat, index, true) or {}

    local sub
    root:CreateTitle(name..' '..stat..' '..index)

--自动隐藏 -1 0
    root:CreateDivider()
    for va=-1, 0, 1 do
        sub=root:CreateCheckbox(
            format('%s |cnGREEN_FONT_COLOR:'..va..'|r',
                WoWTools_DataMixin.onlyChinese and '自动隐藏'
                or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE))
            ..(p_stats.hideAt==va and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            local tab= Find_Stats(data.stat, data.index, false)
            return tab and tab.hideAt== data.value
        end, function(data)
            local tab=Find_Stats(data.stat, data.index, false)
            if tab then
                if not tab.hideAt or tab.hideAt~=data.value then
                    tab.hideAt= data.value
                else
                    tab.hideAt= nil
                end
                Data_Save()
            end
        end, {stat=stat, index=index, value=va, hideAt=stats.hideAt, p_hideAt=p_stats.hideAt})

        sub:SetTooltip(function(tooltip, description)
            tooltip:AddLine(
                (WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)
                ..': '
                ..(description.data.p_hideAt or (WoWTools_DataMixin.onlyChinese and '无' or NONE))
            )
            tooltip:AddLine(' ')
            tooltip:AddLine(format('<='..description.data.value..' %s', WoWTools_DataMixin.onlyChinese and '隐藏' or HIDE))
        end)
    end

--职责，设置
    root:CreateDivider()
    for i= Enum.LFGRole.Tank, Enum.LFGRole.Damage, 1 do
        sub=root:CreateCheckbox(
            Get_Role_Text(i)--职责
            ..(p_stats.roles and (p_stats.roles[1]==i or p_stats.roles[2]==i or p_stats.roles[3]==i) and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            local tank, n, dps= Find_Roles(stats.roles)
            if data.value==Enum.LFGRole.Tank then
                return tank
            elseif data.value==Enum.LFGRole.Healer then
                return n
            elseif data.value== Enum.LFGRole.Damage then
                return dps
            end
        end, function(data)
            local tab= Find_Stats(data.stat, data.index, false)
            if tab then
                if tab.stat==data.stat then
                    local findTank, findN, findDps
                    if not tab.roles then
                        tab.roles={data.value}
                    else
                        findTank, findN, findDps= Find_Roles(stats.roles)--职责，设置                                    
                        if data.value==Enum.LFGRole.Tank then
                            findTank = not findTank and true or false
                        elseif data.value==Enum.LFGRole.Healer then
                            findN = not findN and true or false
                        elseif data.value==Enum.LFGRole.Damage then
                            findDps = not findDps and true or false
                        end
                        if findTank or findN or findDps then
                            local roles={}
                            if findTank then table.insert(roles, Enum.LFGRole.Tank) end
                            if findN then table.insert(roles, Enum.LFGRole.Healer) end
                            if findDps then table.insert(roles, Enum.LFGRole.Damage) end
                            tab.roles= roles
                        else
                            tab.roles=nil
                        end
                    end
                    Data_Save()
                end
            end
        end, {stat=stat, index=index, value=i, roles=stats.roles, p_roles=p_stats.roles})

        sub:SetTooltip(function(tooltip, description)
            local find
            if description.data.p_roles then
                for _, roleIndex in pairs(description.data.p_roles) do
                    tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)..': '..Get_Role_Text(roleIndex))
                    find= true
                end
            end
            if not find then
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '无' or NONE)
            end
        end)
    end

--主属性，条件
    root:CreateDivider()
    for _, primary in pairs({LE_UNIT_STAT_STRENGTH, LE_UNIT_STAT_AGILITY , LE_UNIT_STAT_INTELLECT}) do
        sub=root:CreateCheckbox(
            format(WoWTools_DataMixin.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, Get_Primary_Text(primary))
            ..(p_stats.primary==primary and '|A:auctionhouse-icon-favorite:0:0|a' or ''),
        function(data)
            local tab= Find_Stats(data.stat, data.index, false) or {}
            return tab and tab.primary==data.value
        end, function(data)
            local tab= Find_Stats(data.stat, data.index, false)
            if tab then
                if not tab.primary or tab.primary~=data.value then
                    tab.primary=data.value
                else
                    tab.primary=nil
                end
                Data_Save()
            end
        end, {stat=stat, index=index, value=primary})
        sub:SetTooltip(function(tooltip, description)
            local tab= Find_Stats(description.data.stat, description.data.index, true)
            tooltip:AddLine(
                (WoWTools_DataMixin.onlyChinese and '默认' or DEFAULT)
                ..': '..
                (Get_Primary_Text(tab and tab.primary) or (WoWTools_DataMixin.onlyChinese and '无' or NONE))
            )
        end)
    end


    if stats.showFunc then
        root:CreateDivider()
        root:CreateTitle('|cnGREEN_FONT_COLOR:showFunc|r')
    end
end








local function Init_Status_Menu(self, root)
    local sub
    for _, tab in pairs(AttributesCategory) do
        if tab.stat=='-' then
            root:CreateDivider()
        else
            local index= tab.index
            local stat= tab.stat
            local name= tab.name or WoWTools_TextMixin:CN(_G[stat] or _G['STAT_'..stat]) or stat
            --tab.name= tab.name or name
            local stats= Find_Stats(stat, index, false)
            local role, autoHide ='', ''
            if stats then
                local tank, n, dps= Find_Roles(stats.roles)--职责
                role= format('%s%s%s', tank and WoWTools_DataMixin.Icon.TANK or '', n and WoWTools_DataMixin.Icon.TANK or '', dps and WoWTools_DataMixin.Icon.DAMAGER or '')
                autoHide= format('|cnGREEN_FONT_COLOR:%s|r', stats.hideAt or '')--隐藏 0， -1
            end
            local primary
            if stats and stats.primary and tab.primary and stats.primary~=tab.primary then
                primary=Get_Primary_Text(stats and stats.primary)--主属性
            end
            sub=root:CreateCheckbox(
                name..autoHide..role..(primary or ''),
            function(data)
                return Find_Stats(data.stat, data.index, false)
            end, function(data)
                if not Find_Stats(data.stat, data.index) then
                    Add_Stat(data.tab)
                else
                    Remove_Stat(data.tab)
                end
                Data_Save()
            end, {stat=stat, index=index, tab=tab})

            Init_Sub_Menu(self, sub, stat, index, name)
        end
    end
end



















local function Init_Menu(self, root)
    local sub, sub2
--启用    
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
    function()
        return not Save().notStatusPlus
    end, function ()
        self:set_enabel_disable()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--全部清除
    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        PAPERDOLL_STATCATEGORIES= {}
        Data_Save()
        return MenuResponse.CloseAll
    end)

--还原
    sub:CreateButton(
        (Save().PAPERDOLL_STATCATEGORIES and '' or '|cff9e9e9e')
        ..'|A:uitools-icon-refresh:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT),
    function()
        PAPERDOLL_STATCATEGORIES= P_PAPERDOLL_STATCATEGORIES
        Save().PAPERDOLL_STATCATEGORIES=nil
        WoWTools_Mixin:Call(PaperDollFrame_UpdateStats)
        return MenuResponse.CloseAll
    end)

--Plus
    sub:CreateDivider()
    sub2=sub:CreateCheckbox(
        'Plus|A:communities-icon-addchannelplus:0:0|a',
    function()
        return not Save().notStatusPlusFunc
    end, function()
        Save().notStatusPlusFunc= not Save().notStatusPlusFunc and true or nil
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine((WoWTools_DataMixin.onlyChinese and '急速' or SPELL_HASTE)..': |cffffffff9037|r|cnGREEN_FONT_COLOR:[+13%]|r  13|cffff00ff.69|r%')
        tooltip:AddLine(' ')
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--小数点
    for i=-1, 4 do
        sub2:CreateRadio(
            i==-1 and (WoWTools_DataMixin.onlyChinese and '无' or NONE)
             or ((WoWTools_DataMixin.onlyChinese and '小数点 ' or 'bit ')..i),
        function(data)
            return Save().itemLevelBit==data.bit
        end, function(data)
            Save().itemLevelBit= data.bit
            WoWTools_Mixin:Call(PaperDollFrame_UpdateStats)
            return MenuResponse.Refresh
        end, {bit=i})
    end

    sub:CreateDivider()
    --sub:CreateTitle(self.addName)
--打开选项界面
    WoWTools_MenuMixin:OpenOptions(sub, {name=WoWTools_PaperDollMixin.addName, name2=self.addName})

--reload
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub)

--属性，选项
    root:CreateDivider()
    Init_Status_Menu(self, root)
end






function WoWTools_PaperDollMixin:Init_Status_Menu(btn)
    btn:SetupMenu(Init_Menu)
end

function WoWTools_PaperDollMixin:Init_AttributesCategory_Menu()
    Init_AttributesCategory()
end