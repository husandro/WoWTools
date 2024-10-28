local e= select(2, ...)

local function Save()
    return WoWTools_MountMixin.Save
end

local function Set_Mount_Summon(data)
    C_MountJournal.SummonByID(data.mountID or 0)
    return MenuResponse.Open
end

















local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data.mountID then
        local isUsable, useError = C_MountJournal.GetMountUsabilityByID(desc.data.mountID, true)
        if useError then
            GameTooltip_AddErrorLine(tooltip, e.cn(useError))
        elseif isUsable then
            GameTooltip_AddNormalLine(tooltip, e.Icon.left..(e.onlyChinese and '召唤' or SUMMON))
        end
    elseif desc.data.spellID then
        tooltip:SetSpellByID(desc.data.spellID)
    elseif desc.data.itemID then
        tooltip:SetItemByID(desc.data.itemID)
    end
    if desc.data.type==FLOOR then
        for uiMapID, _ in pairs(Save().Mounts[FLOOR][desc.data.spellID] or {}) do
            local mapInfo = C_Map.GetMapInfo(uiMapID)
            tooltip:AddDoubleLine(uiMapID, mapInfo and e.cn(mapInfo.name))
        end
    end
end







local function ClearAll_Menu(root, type, index)
    if index>1 then
        root:CreateDivider()
        local sub=root:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function(data)
            if IsControlKeyDown() then
                Save().Mounts[data]={}
                print(e.addName, WoWTools_MountMixin.addName, e.onlyChinese and '全部清除' or CLEAR_ALL, e.cn(type))
                WoWTools_MountMixin.MountButton:settings()

            else
                return MenuResponse.Open
            end
        end, type)
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(e.cn(desc.data))
            tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
        end)
    end
    WoWTools_MenuMixin:SetGridMode(root, index)
end















local function Set_Mount_Sub_Options(root, data)--icon,col,mountID,spellID,itemID
    local icon= data.icon or ''
    local col= data.col or ''
    if data.mountID then
        root:CreateButton(
            icon..col..(e.onlyChinese and '召唤' or SUMMON),
            Set_Mount_Summon,
            data
        )
        root:CreateDivider()
    end

    root:CreateButton(
        (data.mountID and '|A:QuestLegendary:0:0|a' or icon)..(e.onlyChinese and '修改' or EDIT)..(data.mountID and '' or e.Icon.left),
    function()
        WoWTools_MountMixin:Set_Item_Spell_Edit(data)
        return MenuResponse.Open
    end)

    if data.mountID then
        WoWTools_MenuMixin:OpenJournal(root, {--战团藏品
            name=e.onlyChinese and '设置' or SETTINGS,
            index=1,
            moutID=data.mountID,
        })
    else
        WoWTools_MenuMixin:OpenSpellBook(root, {--天赋和法术书
            name='|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '设置' or SETTINGS),
            index=PlayerSpellsUtil.FrameTabs.SpellBook,
            spellID=data.spellID,
        })
    end


    root:CreateButton(
        '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE),
        function(info)
            Save().Mounts[info.type][info.itemID or info.spellID]=nil

            print(e.addName, WoWTools_MountMixin.addName, e.onlyChinese and '移除' or REMOVE,
                    WoWTools_ItemMixin:GetLink(info.itemID)
                    or (info.spellID and C_Spell.GetSpellLink(info.spellID)
                    or info.itemID or info.spellID
            ))
            WoWTools_MountMixin.MountButton:settings()
            return MenuResponse.Open
        end,
        data
    )
end








local function Set_Mount_Menu(root, type, spellID, name, index)
    local mountID= spellID and C_MountJournal.GetMountFromSpell(spellID)

    local sub, icon, creatureName, isUsable, _, isCollected, col
    if mountID then
        creatureName, _, _, _, isUsable, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
        if not isCollected then--没收集
            col= '|cff9e9e9e'
        elseif not isUsable then--不可用
            col= '|cnRED_FONT_COLOR:'
        end
    end
    col= col or ''

    if index then
        name= e.cn(creatureName or C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID '..spellID)
    end

    icon= '|T'..(spellID and C_Spell.GetSpellTexture(spellID) or 0)..':0|t'

    sub=root:CreateButton(
        (index and index..') ' or '')
        ..icon
        ..col
        ..name,
        Set_Mount_Summon,
        {spellID=spellID, mountID=mountID, type=type}
    )
    sub:SetTooltip(Set_Menu_Tooltip)

    if index and mountID then
        Set_Mount_Sub_Options(sub, {
            icon=icon,
            col=col,
            mountID=mountID,
            spellID=spellID,
            --itemID=itemID,
            type=type,
        })
    end
    return sub
end
















local function Init_Menu_Mount(root, type, name)
    local tab2=WoWTools_MountMixin:Get_MountTab(type)
    e.LoadData({id=tab2[1], type='spell'})
    local num= WoWTools_MountMixin:Get_Table_Num(type)--检测,表里的数量
    local col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], (e.onlyChinese and name or e.cn(type))..' '..col..num, nil)


    local index=0
    for spellID, _ in pairs(Save().Mounts[type] or {}) do
        e.LoadData({id=spellID, type='spell'})
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end









local function Init_Menu_ShiftAltCtrl(root, type)
    local tab2=WoWTools_MountMixin:Get_MountTab(type)
    e.LoadData({id=tab2[1], type='spell'})
    local num= WoWTools_MountMixin:Get_Table_Num(type)--检测,表里的数量
    local col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], type..' '..col..num, nil)

    if num>1 then
        sub:CreateTitle(
            e.onlyChinese and '仅限第1个' or
            format(LFG_LIST_CROSS_FACTION, format(JAILERS_TOWER_SCENARIO_FLOOR, 1))
        )
    end

    local index=0
    for spellID, _ in pairs(Save().Mounts[type] or {}) do
        e.LoadData({id=spellID, type='spell'})
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end















local function Init_Menu_Spell(_, sub)
    local sub2, icon, col
    local index=0
    for spellID, _ in pairs(Save().Mounts[SPELLS]) do
        e.LoadData({id=spellID, type='spell'})
        index= index+1

        icon='|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
        col= (IsSpellKnownOrOverridesKnown(spellID) and '' or '|cff9e9e9e')

        sub2=sub:CreateButton(
            index..') '
            ..col
            ..icon
            ..(e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID: '..spellID)),
        function(data)
            WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            return MenuResponse.Open
        end, {spellID=spellID, type=SPELLS})
        sub2:SetTooltip(Set_Menu_Tooltip)

        Set_Mount_Sub_Options(sub2, {
            icon=icon,
            col=col,
            type=SPELLS,
            mountID=nil,
            spellID=spellID,
            itemID=nil,
        })

    end

    ClearAll_Menu(sub, SPELLS, index)

    sub2=sub:CreateButton(e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT, function()
        if IsControlKeyDown() then
            Save().Mounts[SPELLS]= WoWTools_MountMixin:P_Mouts_Tab()
            print(e.addName, WoWTools_MountMixin.addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
            WoWTools_MountMixin.MountButton:settings()
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
    end)

end













local function Init_Menu_Item(_, sub)
    local sub2, num, icon
    local index= 0
    for itemID, _ in pairs(Save().Mounts[ITEMS]) do
        e.LoadData({id=itemID, type='item'})
        index= index+1

        icon='|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
        num= C_Item.GetItemCount(itemID, false, true, true) or 0

        local name= '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
                    ..(e.cn(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID: '..itemID))
                    ..(num==0 and '|cff9e9e9e' or '|cffffffff')..' x'..num..'|r'

        sub2=sub:CreateButton(
            index..') '..name,
        function(data)
            WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            return MenuResponse.Open
        end,{itemID=itemID, name=name, type=ITEMS})
        sub2:SetTooltip(Set_Menu_Tooltip)

        Set_Mount_Sub_Options(sub2, {
            icon=icon,
            col=nil,
            type=ITEMS,
            mountID=nil,
            spellID=nil,
            itemID=itemID,
        })
    end

    ClearAll_Menu(sub, ITEMS, index)

    sub2=sub:CreateTitle(e.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
    sub2:SetTooltip(function (tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '添加' or ADD)
    end)
end










local MainMenuTable={
    {type=MOUNT_JOURNAL_FILTER_GROUND, name='地面'},
    {type=MOUNT_JOURNAL_FILTER_AQUATIC, name='水栖'},
    {type=MOUNT_JOURNAL_FILTER_FLYING, name='飞行'},
    {type=MOUNT_JOURNAL_FILTER_DRAGONRIDING, name='驭空术'},
    {type='-'},
    {type='Shift'},
    {type='Alt'},
    {type='Ctrl'},
    {type='-'},
    {type=FLOOR, name='区域'},
    {type='-'},
    {type=SPELLS, name='法术'},
    {type=ITEMS, name='物品'},

}





--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2, sub3, num, col
    for _, tab in pairs(MainMenuTable) do
        local indexType= tab.type
        if indexType=='-' then
            root:CreateDivider()

        elseif indexType==SPELLS or indexType==ITEMS then
            --local data={}
            local icon
            local itemID, spellID
            if indexType==SPELLS then
                if self.spellID then
                    spellID= self.spellID
                    icon= C_Spell.GetSpellTexture(self.spellID)
                end
            elseif indexType==ITEMS then
                if self.itemID then
                    itemID=self.itemID
                    icon=C_Item.GetItemIconByID(self.itemID)
                end
            end
            icon= icon or 0
            num= WoWTools_MountMixin:Get_Table_Num(indexType)--检测,表里的数量
            col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

            sub=root:CreateButton('|T'..icon..':0|t'..(e.onlyChinese and tab.name or indexType).. col..' '.. num..'|r', function()
                return MenuResponse.Open
            end, {itemID=itemID, spellID=spellID, type=indexType})
            sub:SetTooltip(Set_Menu_Tooltip)

            if indexType==SPELLS then
                Init_Menu_Spell(self, sub)
            else
                Init_Menu_Item(self, sub)
            end

        elseif indexType=='Shift' or indexType=='Alt' or indexType=='Ctrl' then
            Init_Menu_ShiftAltCtrl(root, indexType)

        else
            Init_Menu_Mount(root, indexType, tab.name)
        end
    end

--选项
    root:CreateDivider()
    sub=root:CreateButton('|T413588:0|t'..(Save().KEY or (e.onlyChinese and '坐骑' or MOUNT)),
    function()
        C_MountJournal.SummonByID(0)
    end, {spellID=150544})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '随机召唤偏好坐骑' or MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT:gsub('\n', ' '), nil,nil,nil)
    end)
        --Set_Menu_Tooltip)

    sub2=sub:CreateButton('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '坐骑秀' or 'Mount show'), function()
        self.ShowFrame:initMountShow()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '召唤坐骑:' or MOUNT..': ', Save().mountShowTime..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS))
        tooltip:AddDoubleLine(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP, e.Icon.mid)
    end)

    sub3=sub2:CreateCheckbox('<AFK>'..(e.onlyChinese and '自动' or SELF_CAST_AUTO), function()
        return Save().AFKRandom
    end, function()
        Save().AFKRandom= not Save().AFKRandom and true or nil
        self.ShowFrame:set_evnet()
        if Save().AFKRandom then
            WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        end
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(SLASH_CHAT_AFK1)
        tooltip:AddLine(e.onlyChinese and '注意: 掉落' or (LABEL_NOTE..': '..STRING_ENVIRONMENTAL_DAMAGE_FALLING))
    end)

    sub2=sub:CreateButton('|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a'..(e.onlyChinese and '坐骑特效' or EMOTE171_CMD2:gsub('/','')), function()
        self.ShowFrame:initSpecial()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '坐骑特效:' or EMOTE171_CMD2:gsub('/','')..': ', Save().mountShowTime..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS))
        tooltip:AddDoubleLine(e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN, e.Icon.mid)
    end)

    sub2=sub:CreateButton('|T'..FRIENDS_TEXTURE_AFK..':0|t'..(UnitIsAFK('player') and '|cff9e9e9e' or '')..(e.onlyChinese and '暂离' or 'AFK'), function()
        WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(SLASH_CHAT_AFK1)
    end)

--间隔
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().mountShowTime
        end, setValue=function(value)
            Save().mountShowTime=value
        end,
        name=e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=1,
        maxValue=10,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddLine(e.onlyChinese and '间隔' or 'Interval')
        end
    })

--设置捷键
    sub:CreateSpacer()
    local text2, num2= WoWTools_MenuMixin:GetDragonriding()--驭空术
    WoWTools_KeyMixin:SetMenu(sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=WoWTools_MountMixin.addName..(num2 and num2>0 and text2 or ''),
        key=Save().KEY,
        GetKey=function(key)
            Save().KEY=key
            WoWTools_KeyMixin:Setup(self)--设置捷键
        end,
        OnAlt=function()
            Save().KEY=nil
            WoWTools_KeyMixin:Setup(self)--设置捷键
        end,
    })

--全部重置
    WoWTools_MenuMixin:RestData(sub,
        WoWTools_MountMixin.addName..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        function()
            WoWTools_MountMixin.Save=nil
            WoWTools_Mixin:Reload()
        end
    )

--驭空术
    sub:CreateDivider()
    WoWTools_MenuMixin:OpenDragonriding(sub)

--战团藏品
    WoWTools_MenuMixin:OpenJournal(sub, {
        index=1,
        icon='|A:hud-microbutton-Mounts-Up:0:0|a'}
    )

--选项
    sub2=WoWTools_ToolsButtonMixin:OpenMenu(sub, WoWTools_MountMixin.addName)
end























function WoWTools_MountMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu)
end

function WoWTools_MountMixin:Init_Menu_Spell(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu_Spell)
end

function WoWTools_MountMixin:Init_Menu_Item(frame)
    MenuUtil.CreateContextMenu(frame, Init_Menu_Item)
end

function WoWTools_MountMixin:Set_Mount_Sub_Options(...)
    Set_Mount_Sub_Options(...)
end