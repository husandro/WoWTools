local e= select(2, ...)
local function Save()
    return WoWTools_PaperDollMixin.Save
end
local P_PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES







local AttributesCategory={
    {stat='STRENGTH', index=1, name=e.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH, primary=LE_UNIT_STAT_STRENGTH},--AttributesCategory
    {stat='AGILITY', index=1, name=e.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY, rimary=LE_UNIT_STAT_AGILITY},
    {stat='INTELLECT', index=1, name=e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT, primary=LE_UNIT_STAT_INTELLECT},
    {stat='-'},
    {stat='STAMINA', index=1, name= e.onlyChinese and '耐力' or STA_LCD},
    {stat='ARMOR', index=1},
    {stat='STAGGER', index=1},
    {stat='MANAREGEN', index=1, name=e.onlyChinese and '法力回复' or MANA_REGEN},
    {stat='SPELLPOWER', index=1, name=e.onlyChinese and '法术强度' or STAT_SPELLPOWER},

    {stat='HEALTH', index=1},
    {stat='POWER', index=1, name=e.onlyChinese and '能量' or POWER_TYPE_POWER},
    {stat='ALTERNATEMANA', index=1, name=e.onlyChinese and '法力值' or  MANA},

    {stat='-'},
--}
--local EnhancementsCategory={
    {stat='CRITCHANCE', index=2, name=e.onlyChinese and '爆击' or STAT_CRITICAL_STRIKE},
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

    {stat='MOVESPEED', index=2, name=e.onlyChinese and '移动' or NPE_MOVE},
    {stat='ATTACK_DAMAGE', index=2, name=e.onlyChinese and '伤害' or DAMAGE, },
    {stat='ATTACK_AP', index=2,  name=e.onlyChinese and '攻击强度' or STAT_ATTACK_POWER, },
    {stat='ATTACK_ATTACKSPEED', index=2, name=e.onlyChinese and '攻击速度' or ATTACK_SPEED},

}






local function Data_Save()
    e.call(PaperDollFrame_UpdateStats)
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
            local title= index==3 and (e.onlyChinese and '综合' or GENERAL)
                    or index==4 and (e.onlyChinese and '攻击' or ATTACK)
                    or (e.onlyChinese and '其它' or OTHER)
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
    print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stat), e.onlyChinese and '添加' or ADD)
end

local function Remove_Stat(tab)--移除        
    local index= tab.index
    local stat= tab.stat
    local name= tab.name
    if PAPERDOLL_STATCATEGORIES[index] then
        for i, info in pairs(PAPERDOLL_STATCATEGORIES[index].stats or {}) do
            if info.stat==stat then
                table.remove(PAPERDOLL_STATCATEGORIES[index].stats, i)
                print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '移除' or REMOVE), stat, name)
                return
            end
        end
    end
    print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), stat, name)
end

local function Get_Primary_Text(primary)--主属性, 文本
    if primary then
        if primary==LE_UNIT_STAT_STRENGTH then
            return format('|cffc69b6d%s|r', e.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH)
        elseif primary==LE_UNIT_STAT_AGILITY then
            return format('|cff16c663%s|r', e.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY)
        elseif primary==LE_UNIT_STAT_INTELLECT then
            return format('|cff00ccff%s|r', e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT)
        end
    end
end














local function Init_Sub_Menu(self, root, stat, index, name)
    local sub
    local stats= Find_Stats(stat, index, false)
    if stats then
--自动隐藏 -1 0
        for va=-1, 0, 1 do
            sub=root:CreateCheckbox(
                format('%s |cnGREEN_FONT_COLOR:'..i..'|r', e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE)),
            function(data)
                return Find_Stats(data.stat, data.index, false).hideAt== data.value
            end, function(data)
                for i, tab in pairs(PAPERDOLL_STATCATEGORIES[data.index] and PAPERDOLL_STATCATEGORIES[data.index].stats or {}) do
                    if tab.stat== data.stat then
                        local value
                        value= PAPERDOLL_STATCATEGORIES[data.index].stats[i].hideAt
                        if not value or value~=data.value then
                            value=data.value
                        else
                            value=nil
                        end
                        PAPERDOLL_STATCATEGORIES[data.index].stats[i].hideAt= value
                        Data_Save()
                        print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', data.stat), value)
                        return
                    end
                end
                print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), data.stat)
            end, {stat=stat, index=index, value=va, hideAt=stats.hideAt})

            sub:SetTooltip(function(tooltip, description)
                tooltip:AddLine(format('<='..description.data.value..' %s', e.onlyChinese and '隐藏' or HIDE))
            end)
        end

--职责，设置
        root:CreateDivider()
       
        for i= Enum.LFGRole.Tank, Enum.LFGRole.Damage, 1 do
            root:CreateCheckbox(
                i== Enum.LFGRole.Tank and format('%s%s', e.Icon.TANK, e.onlyChinese and '坦克' or TANK)
                or i==Enum.LFGRole.Healer and format('%s%s', e.Icon.HEALER, e.onlyChinese and '治疗' or HEALER)
                or i==Enum.LFGRole.Damage and format('%s%s', e.Icon.DAMAGER, e.onlyChinese and '伤害' or DAMAGER),
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
                for _, tab in pairs (PAPERDOLL_STATCATEGORIES[data.index] and PAPERDOLL_STATCATEGORIES[data.index].stats or {}) do
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
                        print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stats.stat) , findTank and e.Icon.TANK or '', findN and e.Icon.HEALER or '', findDps and e.Icon.DAMAGER or '')
                        return
                    end
                end
                print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, data.stat))
            end, {stat=stat, index=index, value=i, roles=stats.roles})
        end

--主属性，条件
        root:CreateDivider()
        for _, primary in pairs({LE_UNIT_STAT_STRENGTH, LE_UNIT_STAT_AGILITY , LE_UNIT_STAT_INTELLECT}) do
            root:CreateCheckbox(
                format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, Get_Primary_Text(primary)),
            function(data)
                local stats2= Find_Stats(data.stat, data.index, false) or {}
                return stats2.primary==data.primary
            end, function(data)
                for _, tab in pairs (PAPERDOLL_STATCATEGORIES[data.index] and PAPERDOLL_STATCATEGORIES[data.index].stats or {}) do
                    if tab.stat==data.stat then
                        if not tab.primary or tab.primary~=data.value then
                            tab.primary=data.value
                        else
                            tab.primary=nil
                        end
                        Data_Save()
                        print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stats.stat) , format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, Get_Primary_Text(tab.primary) or format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '无' or NONE)))
                        return
                    end
                end
                print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, data.stat))
            end, {stat=stat, index=index, value=primary})
        end

        if stats.showFunc then
            root:CreateTitle('|cnGREEN_FONT_COLOR:showFunc|r')
        end
        root:CreateTitle(name..' '..stat..' '..index)
    else

        root:CreateTitle(format(
            '|cnRED_FONT_COLOR:%s|r %s %s %s',
            e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, name, stat, index)
        )
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
            local name= tab.name or e.cn(_G[stat] or _G['STAT_'..stat]) or stat
            tab.name= tab.name or name
            local stats= Find_Stats(stat, index, false)
            local role, autoHide ='', ''
            if stats then
                local tank, n, dps= Find_Roles(stats.roles)--职责
                role= format('%s%s%s', tank and e.Icon.TANK or '', n and e.Icon.HEALER or '', dps and e.Icon.DAMAGER or '')
                autoHide= format('|cnGREEN_FONT_COLOR:%s|r', stats.hideAt or '')--隐藏 0， -1
            end
            local primary= Get_Primary_Text(stats and stats.primary) or ''--主属性

            sub=root:CreateCheckbox(
                name..autoHide..role..primary,
            function(data)
                return Find_Stats(data.stat, data.index, false)
            end, function(data)
                if not Find_Stats(data.stat, data.index) then
                    Add_Stat(data.tab)
                else
                    Remove_Stat(data.tab)
                end
                Data_Save()
                --return MenuResponse.Close
            end, {stat=stat, index=index, tab=tab})

            Init_Sub_Menu(self, sub, stat, index, name)
        end
    end
end



















local function Init_Menu(self, root)
    local sub, sub2
--启用    
    sub= root:CreateCheckbox(
        e.onlyChinese and '启用' or ENABLE,
    function()
        return Save().notStatusPlus
    end, function ()
        self:set_enabel_disable()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--全部清除
    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '全部清除' or CLEAR_ALL),
    function()
        PAPERDOLL_STATCATEGORIES= {}
        e.LibDD:CloseDropDownMenus(1)
        Data_Save()
        print(
            WoWTools_PaperDollMixin.addName,
            self.addName,
            format('|cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT),
            e.onlyChinese and '完成' or DONE
        )        
    end)

--还原
    sub:CreateButton(
        (Save().PAPERDOLL_STATCATEGORIES and '' or '|cff9e9e9e')
        ..'|A:uitools-icon-refresh:0:0|a'
        ..(e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT),
    function()
        PAPERDOLL_STATCATEGORIES= P_PAPERDOLL_STATCATEGORIES
        Save().PAPERDOLL_STATCATEGORIES=nil
        e.call(PaperDollFrame_UpdateStats)
    end)

--属性
    sub2=sub:CreateCheckbox(
        format('%s Plus|A:communities-icon-addchannelplus:0:0|a', e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES),
    function()
        return not Save().notStatusPlusFunc
    end, function()
        Save().notStatusPlusFunc= not Save().notStatusPlusFunc and true or nil
        print(e.addName, WoWTools_PaperDollMixin.addName, e.GetEnabeleDisable(not Save().notStatusPlusFunc), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end)

--小数点
    for i=0, 4 do
        sub:CreateRadio(
            format('%s %d', e.onlyChinese and '小数点' or 'bit', i),
        function(data)
            return Save().itemLevelBit==data.bit
        end, function(data)
            Save().itemLevelBit= data.bit
            e.call(PaperDollFrame_UpdateStats)
        end, {bit=i})
    end


--reload
    sub:CreateDivider()
    WoWTools_MenuMixin:Reload(sub)
    
    root:CreateDivider()
    Init_Status_Menu(self, root)
end






function WoWTools_PaperDollMixin:Init_Status_Menu(btn)
    btn:SetupMenu(Init_Menu)
end







--[[
local function Init_Status_Menu()

   

    e.LibDD:UIDropDownMenu_Initialize(StatusPlusButton.Menu, function(self, level, menuList)

      

        local info



        elseif menuList then
            local stat, index, name= menuList:match('(.+)(%d)(.+)')
            index= tonumber(index)

            local stats= Find_Stats(stat, index, false)
            if stats then
                --自动隐藏 -1 0
                for i=-1, 0, 1 do
                    info={
                        text=format('%s |cnGREEN_FONT_COLOR:'..i..'|r', e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE)),
                        keepShownOnClick=true,
                        checked=stats.hideAt==i,
                        arg1={stat=stat, index=index, value=i},
                        tooltipOnButton=true,
                        tooltipTitle=format('<='..i..' %s', e.onlyChinese and '隐藏' or HIDE),
                        func= function(_, arg1)
                            for i, tab in pairs(PAPERDOLL_STATCATEGORIES[arg1.index] and PAPERDOLL_STATCATEGORIES[arg1.index].stats or {}) do
                                if tab.stat== arg1.stat then
                                    local value
                                    value= PAPERDOLL_STATCATEGORIES[arg1.index].stats[i].hideAt
                                    if not value or value~=arg1.value then
                                        value=arg1.value
                                    else
                                        value=nil
                                    end
                                    PAPERDOLL_STATCATEGORIES[arg1.index].stats[i].hideAt= value
                                    Data_Save()
                                    print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', arg1.stat), value)
                                    return
                                end
                            end
                            print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), arg1.stat)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end

                --职责，设置
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                local tank, n, dps= Find_Roles(stats.roles)
                for i= Enum.LFGRole.Tank, Enum.LFGRole.Damage, 1 do
                    info={
                        text= i== Enum.LFGRole.Tank and format('%s%s', e.Icon.TANK, e.onlyChinese and '坦克' or TANK)
                            or i==Enum.LFGRole.Healer and format('%s%s', e.Icon.HEALER, e.onlyChinese and '治疗' or HEALER)
                            or i==Enum.LFGRole.Damage and format('%s%s', e.Icon.DAMAGER, e.onlyChinese and '伤害' or DAMAGER),
                        keepShownOnClick=true,
                        arg1={stat=stat, index=index, value=i},
                        func= function(_, arg1)
                            for _, tab in pairs (PAPERDOLL_STATCATEGORIES[arg1.index] and PAPERDOLL_STATCATEGORIES[arg1.index].stats or {}) do
                                if tab.stat==arg1.stat then
                                    local findTank, findN, findDps
                                    if not tab.roles then
                                        tab.roles={arg1.value}
                                    else
                                        findTank, findN, findDps= Find_Roles(stats.roles)--职责，设置                                    
                                        if arg1.value==Enum.LFGRole.Tank then
                                            findTank = not findTank and true or false
                                        elseif arg1.value==Enum.LFGRole.Healer then
                                            findN = not findN and true or false
                                        elseif arg1.value==Enum.LFGRole.Damage then
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
                                    print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stats.stat) , findTank and e.Icon.TANK or '', findN and e.Icon.HEALER or '', findDps and e.Icon.DAMAGER or '')
                                    return
                                end
                            end
                            print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, arg1.stat))
                        end
                    }
                    if i==Enum.LFGRole.Tank then
                        info.checked= tank
                    elseif i==Enum.LFGRole.Healer then
                        info.checked= n
                    elseif i== Enum.LFGRole.Damage then
                        info.checked= dps
                    end
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end

                --主属性，条件
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                for _, primary in pairs({LE_UNIT_STAT_STRENGTH, LE_UNIT_STAT_AGILITY , LE_UNIT_STAT_INTELLECT}) do
                    info={
                        text= format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, Get_Primary_Text(primary)),
                        keepShownOnClick=true,
                        checked= stats.primary==primary,
                        arg1={stat=stat, index=index, value=primary},
                        func= function(_, arg1)
                            for _, tab in pairs (PAPERDOLL_STATCATEGORIES[arg1.index] and PAPERDOLL_STATCATEGORIES[arg1.index].stats or {}) do
                                if tab.stat==arg1.stat then
                                    if not tab.primary or tab.primary~=arg1.value then
                                        tab.primary=arg1.value
                                    else
                                        tab.primary=nil
                                    end
                                    Data_Save()
                                    print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnGREEN_FONT_COLOR:%s|r', stats.stat) , format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, Get_Primary_Text(tab.primary) or format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '无' or NONE)))
                                    return
                                end
                            end
                            print(e.addName, WoWTools_PaperDollMixin.addName, format('|cnRED_FONT_COLOR:%s|r %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, arg1.stat))
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end

                e.LibDD:UIDropDownMenu_AddSeparator(level)
                if stats.showFunc then
                    e.LibDD:UIDropDownMenu_AddButton({
                        text='|cnGREEN_FONT_COLOR:showFunc|r',
                        checked=true,
                        isTitle=true,
                    }, level)
                end
                info={
                    text=name..' '..stat..' '..index,
                    notCheckable=true,
                    isTitle=true,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            else
                info={
                    text=format('|cnRED_FONT_COLOR:%s|r %s %s %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, name, stat, index),
                    notCheckable=true,
                    isTitle=true,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end

        end
        if menuList then
            return
        end



        for _, tab in pairs(AttributesCategory) do
            if tab.stat=='-' then
                e.LibDD:UIDropDownMenu_AddSeparator(level)
            else
                local index= tab.index
                local stat= tab.stat
                local name= tab.name or e.cn(_G[stat] or _G['STAT_'..stat]) or stat
                tab.name= tab.name or name
                local stats= Find_Stats(stat, index, false)
                local role, autoHide ='', ''
                if stats then
                    local tank, n, dps= Find_Roles(stats.roles)--职责
                    role= format('%s%s%s', tank and e.Icon.TANK or '', n and e.Icon.HEALER or '', dps and e.Icon.DAMAGER or '')
                    autoHide= format('|cnGREEN_FONT_COLOR:%s|r', stats.hideAt or '')--隐藏 0， -1
                end
                local primary= Get_Primary_Text(stats and stats.primary) or ''--主属性
                info={
                    text=name..autoHide..role..primary,
                    tooltipOnButton=true,
                    tooltipTitle=format('%s |cnGREEN_FONT_COLOR:%s|r', tab.stat, index),
                    keepShownOnClick=true,
                    checked= stats and true or false,
                    menuList=stat..index..name,
                    hasArrow=true,
                    arg1=tab,
                    arg2=index,
                    func= function(_, arg1)
                        local find= Find_Stats(arg1.stat, arg1.index)
                        if not find then
                            Add_Stat(arg1)
                        else
                            Remove_Stat(arg1)
                        end
                        Data_Save()
                        e.LibDD:CloseDropDownMenus(2)
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)

        info= {
            text=e.GetEnabeleDisable(true)..(Save().notStatusPlusFunc and '' or '|A:communities-icon-addchannelplus:0:0|a'),
            checked= not Save().notStatusPlus,
            hasArrow=true,
            menuList='ENABLE_DISABLE',
            func= function()
                self:set_enabel_disable()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    end, 'MENU')
end







]]