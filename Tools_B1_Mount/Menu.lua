local function Save()
    return WoWToolsSave['Tools_Mounts']
end

















local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data.mountID then
        local isUsable, useError = C_MountJournal.GetMountUsabilityByID(desc.data.mountID, true)
        if useError then
            GameTooltip_AddErrorLine(tooltip, WoWTools_TextMixin:CN(useError))
        elseif isUsable then
            GameTooltip_AddNormalLine(tooltip, WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '召唤' or SUMMON))
        end
    elseif desc.data.spellID then
        tooltip:SetSpellByID(desc.data.spellID)
    elseif desc.data.itemID then
        tooltip:SetItemByID(desc.data.itemID)
    end
    if desc.data.type==FLOOR then
        for uiMapID, _ in pairs(Save().Mounts[FLOOR][desc.data.spellID] or {}) do
            local mapInfo = C_Map.GetMapInfo(uiMapID)
            tooltip:AddDoubleLine(uiMapID, mapInfo and WoWTools_TextMixin:CN(mapInfo.name))
        end
    end
end







local function ClearAll_Menu(root, type, index)
    if index>1 then
        root:CreateDivider()
        local name= WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL
        root:CreateButton(
            name,
        function(data)
            StaticPopup_Show('WoWTools_OK',
            data.name..'\n\n'..WoWTools_TextMixin:CN(data.type),
            nil,
            {SetValue=function()
                Save().Mounts[data.type]={}
                print(
                    WoWTools_MountMixin.addName..WoWTools_DataMixin.Icon.icon2,
                    data.name,
                    WoWTools_TextMixin:CN(data.type)
                )
                 WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
            end})
            return MenuResponse.Open
        end, {type=type, name=name})
    end
    WoWTools_MenuMixin:SetScrollMode(root)
end















local function Set_Mount_Sub_Options(root, data)--icon,col,mountID,spellID,itemID
    local icon= data.icon or ''
    local col= data.col or ''

    if data.mountID then
        root:CreateButton(
            icon..col..(WoWTools_DataMixin.onlyChinese and '召唤' or SUMMON),
        function(d)
            C_MountJournal.SummonByID(d.mountID or 0)
            return MenuResponse.Refresh
        end, data)
        root:CreateDivider()
    end


    root:CreateButton(
        (data.mountID and '|A:QuestLegendary:0:0|a' or icon)..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)..(data.mountID and '' or WoWTools_DataMixin.Icon.left),
    function()
        WoWTools_MountMixin:Set_Item_Spell_Edit(data)
        return MenuResponse.Open
    end)

    if data.mountID then
        WoWTools_MenuMixin:OpenJournal(root, {--战团藏品
            name=WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS,
            index=1,
            moutID=data.mountID,
        })
    else
        WoWTools_MenuMixin:OpenSpellBook(root, {--天赋和法术书
            name='|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS),
            index=PlayerSpellsUtil.FrameTabs.SpellBook,
            --spellID=data.spellID,--bug
        })
    end


    root:CreateDivider()
    root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '移除' or REMOVE,
    function()
        return Save().Mounts[data.type][data.itemID or data.spellID]
    end, function()
        Save().Mounts[data.type][data.itemID or data.spellID]= not Save().Mounts[data.type][data.itemID or data.spellID] and true or nil

         WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
    end)


end








local function Set_Mount_Menu(root, type, spellID, name, index)
    local mountID= spellID and C_MountJournal.GetMountFromSpell(spellID)

    local sub, icon, creatureName, isUsable, _, isCollected, col
    if mountID then
        creatureName, _, _, _, isUsable, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
        if not isCollected then--没收集
            col= '|cff626262'
        elseif not isUsable then--不可用
            col= '|cnWARNING_FONT_COLOR:'
        end
    end
    col= col or ''

    if index then
        name= WoWTools_TextMixin:CN(creatureName or C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID '..spellID)
    end

    icon= '|T'..(spellID and C_Spell.GetSpellTexture(spellID) or 0)..':0|t'

    sub=root:CreateButton(
        (index and index..') ' or '')
        ..icon
        ..col
        ..name,
        function(d)
            C_MountJournal.SummonByID(d.mountID or 0)
            return MenuResponse.Refresh
        end,
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
   WoWTools_DataMixin:Load(tab2[1], 'spell')
    local num= WoWTools_MountMixin:Get_Table_Num(type)--检测,表里的数量
    local col= num==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], (WoWTools_DataMixin.onlyChinese and name or WoWTools_TextMixin:CN(type))..' '..col..num, nil)


    local index=0
    for spellID, _ in pairs(Save().Mounts[type] or {}) do
       WoWTools_DataMixin:Load(spellID, 'spell')
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end









local function Init_Menu_ShiftAltCtrl(root, type)
    local tab2=WoWTools_MountMixin:Get_MountTab(type)
   WoWTools_DataMixin:Load(tab2[1], 'spell')
    local num= WoWTools_MountMixin:Get_Table_Num(type)--检测,表里的数量
    local col= num==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], type..' '..col..num, nil)

    if num>1 then
        sub:CreateTitle(
            WoWTools_DataMixin.onlyChinese and '仅限第1个' or
            format(LFG_LIST_CROSS_FACTION, format(JAILERS_TOWER_SCENARIO_FLOOR, 1))
        )
    end

    local index=0
    for spellID, _ in pairs(Save().Mounts[type] or {}) do
       WoWTools_DataMixin:Load(spellID, 'spell')
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end















local function Init_Menu_Spell(_, sub)
    local sub2, icon, col
    local index=0
    for spellID, _ in pairs(Save().Mounts[SPELLS]) do
       WoWTools_DataMixin:Load(spellID, 'spell')
        index= index+1

        icon='|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
        col= (C_SpellBook.IsSpellInSpellBook(spellID) and '' or '|cff626262')

        sub2=sub:CreateButton(
            index..') '
            ..col
            ..icon
            ..(WoWTools_TextMixin:CN(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID: '..spellID)),
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

    sub2=sub:CreateButton(WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT, function()
        if IsControlKeyDown() then
            Save().Mounts[SPELLS]= WoWTools_MountMixin:P_Mouts_Tab()
            print(WoWTools_MountMixin.addName..WoWTools_DataMixin.Icon.icon2, '|cnGREEN_FONT_COLOR:', WoWTools_DataMixin.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
             WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..WoWTools_DataMixin.Icon.left)
    end)

end













local function Init_Menu_Item(_, sub)
    local sub2, num, icon
    local index= 0
    for itemID, _ in pairs(Save().Mounts[ITEMS]) do
       WoWTools_DataMixin:Load(itemID, 'item')
        index= index+1

        icon='|T'..(select(5, C_Item.GetItemInfoInstant(itemID)) or 0)..':0|t'
        num= C_Item.GetItemCount(itemID, false, true, true) or 0

        local name= icon
                    ..(WoWTools_TextMixin:CN(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID: '..itemID))
                    ..(num==0 and '|cff626262' or '|cffffffff')..' x'..num..'|r'

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

    sub2=sub:CreateTitle(WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS))
    sub2:SetTooltip(function (tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
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
                    icon=select(5, C_Item.GetItemInfoInstant(self.itemID))
                end
            end
            icon= icon or 0
            num= WoWTools_MountMixin:Get_Table_Num(indexType)--检测,表里的数量
            col= num==0 and '|cff626262' or '|cnGREEN_FONT_COLOR:'

            sub=root:CreateButton('|T'..icon..':0|t'..(WoWTools_DataMixin.onlyChinese and tab.name or indexType).. col..' '.. num..'|r', function()
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
    sub=root:CreateButton('|T413588:0|t'..(Save().KEY or (WoWTools_DataMixin.onlyChinese and '坐骑' or MOUNT)),
    function()
        C_MountJournal.SummonByID(0)
        return MenuResponse.Refresh
    end, {spellID=150544})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '随机召唤偏好坐骑' or MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT:gsub('\n', ' '), nil,nil,nil)
    end)
        --Set_Menu_Tooltip)

    sub2=sub:CreateButton('|A:bags-greenarrow:0:0|a'..(WoWTools_DataMixin.onlyChinese and '坐骑秀' or 'Mount show'), function()
        _G['WoWToolsToolsMountFrame']:initMountShow()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '召唤坐骑:' or MOUNT..': ', Save().mountShowTime..' '..(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS))
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP, WoWTools_DataMixin.Icon.mid)
    end)

    sub3=sub2:CreateCheckbox('<AFK>'..(WoWTools_DataMixin.onlyChinese and '自动' or SELF_CAST_AUTO), function()
        return Save().AFKRandom
    end, function()
        Save().AFKRandom= not Save().AFKRandom and true or nil
        _G['WoWToolsToolsMountFrame']:set_evnet()
        if Save().AFKRandom then
            WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        end
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(SLASH_CHAT_AFK1)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '注意: 掉落' or (LABEL_NOTE..': '..STRING_ENVIRONMENTAL_DAMAGE_FALLING))
    end)

    sub2=sub:CreateButton('|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '坐骑特效' or EMOTE171_CMD2), function()
        _G['WoWToolsToolsMountFrame']:initSpecial()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '坐骑特效:' or EMOTE171_CMD2..': ', Save().mountShowTime..' '..(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS))
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN, WoWTools_DataMixin.Icon.mid)
    end)

    sub2=sub:CreateButton('|T'..FRIENDS_TEXTURE_AFK..':0|t'..(UnitIsAFK('player') and '|cff626262' or '')..(WoWTools_DataMixin.onlyChinese and '暂离' or 'AFK'), function()
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
        name=WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=1,
        maxValue=10,
        step=1,
        bit=nil,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '间隔' or 'Interval')
        end
    })

--设置捷键
    sub:CreateSpacer()
    --local text2, num2= WoWTools_MenuMixin:GetDragonriding()--驭空术 11.2.7 没有了
    WoWTools_KeyMixin:SetMenu(self, sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=WoWTools_MountMixin.addName,--..(num2 and num2>0 and text2 or ''),
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
        WoWTools_MountMixin.addName..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        function()
            WoWTools_MountMixin.Save=nil
            WoWTools_DataMixin:Reload()
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
    WoWTools_ToolsMixin:OpenMenu(sub, WoWTools_MountMixin.addName)
end























function WoWTools_MountMixin:Init_Menu(frame)
    MenuUtil.CreateContextMenu(frame, function(...) Init_Menu(...) end)
end

function WoWTools_MountMixin:Init_Menu_Spell(frame)
    MenuUtil.CreateContextMenu(frame, function(...) Init_Menu_Spell(...) end)
end

function WoWTools_MountMixin:Init_Menu_Item(frame)
    MenuUtil.CreateContextMenu(frame, function(...) Init_Menu_Item(...) end)
end

function WoWTools_MountMixin:Set_Mount_Sub_Options(...)
    Set_Mount_Sub_Options(...)
end