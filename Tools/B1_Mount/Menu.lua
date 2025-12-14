local function Save()
    return WoWToolsSave['Tools_Mounts']
end
local function SaveLog()
    return WoWToolsPlayerDate['Tools_Mounts']
end










local function Set_Menu_Index(root)
    root:AddInitializer(function(btn, desc)
        local index= desc.data.index
        if index then
            local font = btn:AttachFontString()
            local offset = desc:HasElements() and -20 or 0
            font:SetPoint("RIGHT", offset, 0)
            font:SetJustifyH("RIGHT")
            font:SetTextToFit(index)

            local disabled= index==0
                or (desc.data.spellID and not C_Spell.DoesSpellExist(desc.data.spellID))
                or (desc.data.itemID and C_Item.GetItemCount(desc.data.itemID, false, false, false, false)==0)
        
            if disabled then
                font:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
            else
                font:SetTextColor(WHITE_FONT_COLOR:GetRGB())
            end
        end
    end)
end




local function Set_Menu_Tooltip(tooltip, desc)
    local mountType= desc.data.type
    local mountID= desc.data.mountID
    local spellID= desc.data.spellID
    local itemID= desc.data.itemID

    if mountID then
        local isUsable, useError = C_MountJournal.GetMountUsabilityByID(mountID, true)
        if useError then
            GameTooltip_AddErrorLine(tooltip, WoWTools_TextMixin:CN(useError))
        elseif isUsable then
            GameTooltip_AddNormalLine(tooltip, WoWTools_DataMixin.Icon.left..(WoWTools_DataMixin.onlyChinese and '召唤' or SUMMON))
        end
    elseif spellID then
        tooltip:SetSpellByID(spellID)
    elseif itemID then
        tooltip:SetItemByID(itemID)
    end

    if mountType=='Floor' then
        for uiMapID in pairs(SaveLog().Floor[spellID] or {}) do
            local mapInfo = C_Map.GetMapInfo(uiMapID)
            tooltip:AddDoubleLine(uiMapID, mapInfo and WoWTools_TextMixin:CN(mapInfo.name))
        end
    end
end







local function ClearAll_Menu(root, mountType)

    root:CreateDivider()

    local name= WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL

    root:CreateButton(
        name,
    function(data)
        StaticPopup_Show('WoWTools_OK',
        name..'\n\n'..WoWTools_MountMixin.TypeName[mountType],
        nil,
        {SetValue=function()
           WoWToolsPlayerDate['Tools_Mounts'][mountType]={}

            WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
            print(
                WoWTools_MountMixin.addName..WoWTools_DataMixin.Icon.icon2,
                name,
                WoWTools_MountMixin.TypeName[mountType]
            )
        end})
        return MenuResponse.Open
    end)

    WoWTools_MenuMixin:SetScrollMode(root)
end















local function Set_Mount_Sub_Options(root, data)--icon,col,mountID,spellID,itemID
    local icon= data.icon or ''
    local col= data.col or ''
    local id= data.itemID or data.spellID
    local mountID= data.mountID
    local mountType= data.type
    local sub

    if mountID then
        root:CreateButton(
            icon..col..(WoWTools_DataMixin.onlyChinese and '召唤' or SUMMON),
        function()
            C_MountJournal.SummonByID(mountID)
            return MenuResponse.Refresh
        end)
        root:CreateDivider()
    end


    root:CreateButton(
        (mountID and '|A:QuestLegendary:0:0|a' or icon)
        ..(WoWTools_DataMixin.onlyChinese and '修改' or EDIT)
        ..(mountID and '' or WoWTools_DataMixin.Icon.left),
    function()
        WoWTools_MountMixin:Set_Item_Spell_Edit(data)
        return MenuResponse.Open
    end)

    if mountID then
        WoWTools_MenuMixin:OpenJournal(root, {--战团藏品
            name=WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS,
            index=1,
            moutID=mountID,
        })
    else
        WoWTools_MenuMixin:OpenSpellBook(root, {--天赋和法术书
            name='|A:common-icon-zoomin:0:0|a'..(WoWTools_DataMixin.onlyChinese and '查看' or VIEW),
            index=PlayerSpellsUtil.FrameTabs.SpellBook or 3,
            --spellID=data.spellID,--bug
        })
    end

    root:CreateDivider()
    sub= root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS,
    function()
        return SaveLog()[mountType][id]
    end, function()
        SaveLog()[mountType][id]= not SaveLog()[mountType][id] and true or nil
        WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '添加/移除' or format('%s/%s', ADD, REMOVE))
    end)
end








local function Set_Mount_Menu(root, mountType, spellID, num, index)
    local mountID= spellID and C_MountJournal.GetMountFromSpell(spellID)

    local sub, icon, isUsable, _, isCollected, col, name, mountName
    if mountID then
        mountName, _, icon, _, isUsable, _, _, _, _, _, isCollected =C_MountJournal.GetMountInfoByID(mountID)
        if not isCollected then--没收集
            col= '|cff626262'
        elseif not isUsable then--不可用
            col= '|cnWARNING_FONT_COLOR:'
        end
    end
    col= col or ''

    icon= '|T'..(icon or (spellID and C_Spell.GetSpellTexture(spellID)) or 0)..':0|t'

    if index then
        if mountName then
            name= icon..WoWTools_TextMixin:CN(mountName)
        elseif spellID then
            name= WoWTools_SpellMixin:GetName(spellID)
        end
    end

    name= name or (icon..WoWTools_MountMixin.TypeName[mountType])

    sub=root:CreateButton(
        col..name,
        function(d)
            C_MountJournal.SummonByID(d.mountID or 0)
            return MenuResponse.Refresh
        end,
        {spellID=spellID, mountID=mountID, type=mountType, index=num or index}
    )

    sub:SetTooltip(Set_Menu_Tooltip)
    Set_Menu_Index(sub)

    if index then
        Set_Mount_Sub_Options(sub, {
            icon=icon,
            col=col,
            mountID=mountID,
            spellID=spellID,
            type=mountType,
        })
    end

    return sub
end
















local function Init_Menu_Mount(root, mountType)
    local tab2= WoWTools_MountMixin:Get_MountTab(mountType)

    WoWTools_DataMixin:Load(tab2[1], 'spell')

    local sub= Set_Mount_Menu(
        root,
        mountType,
        tab2[1],
        WoWTools_MountMixin:Get_Table_Num(mountType),--检测,表里的数量
        nil
    )


    local index=0
    for spellID in pairs(SaveLog()[mountType] or {}) do

        WoWTools_DataMixin:Load(spellID, 'spell')

        index= index +1
        Set_Mount_Menu(
            sub,
            mountType,
            spellID,
            nil,
            index
        )
    end

    ClearAll_Menu(sub, mountType)
end









local function Init_Menu_ShiftAltCtrl(root, mountType)
    local tab2=WoWTools_MountMixin:Get_MountTab(mountType) or {}
    WoWTools_DataMixin:Load(tab2[1], 'spell')

    local sub= Set_Mount_Menu(
        root,
        mountType,
        tab2[1],
        WoWTools_MountMixin:Get_Table_Num(mountType),--检测,表里的数量,
        nil
    )

    sub:CreateTitle(
        WoWTools_DataMixin.onlyChinese and '仅限 1 个' or
        format(LFG_LIST_CROSS_FACTION, '|cffffffff1"r '..SPELLS)
    )

    local index=0
    for spellID in pairs(SaveLog()[mountType] or {}) do
       WoWTools_DataMixin:Load(spellID, 'spell')
        index= index +1
        Set_Mount_Menu(sub, mountType, spellID, nil, index)
    end

    ClearAll_Menu(sub, mountType)
    return sub, index
end















local function Init_Menu_Spell(_, sub)
    local sub2, icon, col
    local index=0
    for spellID in pairs(SaveLog().Spell or {}) do
        WoWTools_DataMixin:Load(spellID, 'spell')
        index= index+1

        icon='|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'

        sub2=sub:CreateButton(
            WoWTools_SpellMixin:GetName(spellID),
        function(data)
            WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            return MenuResponse.Open
        end, {spellID=spellID, type='Spell', index=index})

        sub2:SetTooltip(Set_Menu_Tooltip)
        Set_Menu_Index(sub2)

        Set_Mount_Sub_Options(sub2, {
            icon=icon,
            col=col,
            type='Spell',
            mountID=nil,
            spellID=spellID,
            itemID=nil,
        })

    end

    ClearAll_Menu(sub, 'Spell')

    sub2=sub:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
    function()
        StaticPopup_Show('WoWTools_OK',
            (WoWTools_DataMixin.onlyChinese and '法术' or SPELLS)
            ..'|n|n'
            ..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
        nil,
        {SetValue=function()
            SaveLog().Spell= WoWTools_MountMixin:P_Mouts_Tab().Spell or {}
            WoWTools_ToolsMixin:Get_ButtonForName('Mount'):settings()
        end})
        return MenuResponse.Open
    end)
end













local function Init_Menu_Item(_, sub)
    local sub2, icon
    local index= 0
    for itemID in pairs(SaveLog().Item or {}) do
       WoWTools_DataMixin:Load(itemID, 'item')

        index= index+1

        icon='|T'..(select(5, C_Item.GetItemInfoInstant(itemID)) or 0)..':0|t'

        local name= WoWTools_ItemMixin:GetName(itemID)

        sub2=sub:CreateButton(
            name,
        function(data)
            WoWTools_MountMixin:Set_Item_Spell_Edit(data)
            return MenuResponse.Open
        end,{itemID=itemID, name=name, type='Item', index=index})

        sub2:SetTooltip(Set_Menu_Tooltip)
        Set_Menu_Index(sub2)

        Set_Mount_Sub_Options(sub2, {
            icon=icon,
            col=nil,
            type='Item',
            mountID=nil,
            spellID=nil,
            itemID=itemID,
        })
    end

    ClearAll_Menu(sub, 'Item')

    sub2=sub:CreateTitle(
        WoWTools_DataMixin.onlyChinese and '拖曳物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, ITEMS)
    )
    sub2:SetTooltip(function (tooltip)
        tooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '添加' or ADD)
    end)
end









--#####
--主菜单
--#####
local function Init_Menu(self, root)
    local sub, sub2, sub3, num

    for _, mountType in pairs({
        'Ground',
        'Aquatic',
        'Flying',
        'Dragonriding',
        '-',
        'Alt',
        'Ctrl',
        'Shift',
        '-',
        'Floor',
        --'-',
        'Spell',
        'Item',
    }) do

        num= nil
        if mountType=='-' then
            root:CreateDivider()

        elseif mountType=='Spell' or mountType=='Item' then

            local icon
            local itemID, spellID
            if mountType=='Spell' then
                if self.spellID then
                    spellID= self.spellID
                    WoWTools_DataMixin:Load(spellID, 'spell')

                    icon= C_Spell.GetSpellTexture(spellID)
                end
            elseif mountType=='Item' then
                if self.itemID then
                    WoWTools_DataMixin:Load(self.itemID, 'item')
                    itemID=self.itemID
                    icon=select(5, C_Item.GetItemInfoInstant(self.itemID))
                end
            end

            icon= icon or 0
            num= WoWTools_MountMixin:Get_Table_Num(mountType)--检测,表里的数量

            local name= WoWTools_MountMixin.TypeName[mountType] or mountType

            if itemID then
                name= WoWTools_ItemMixin:GetColor(nil, {itemID=itemID, text=name})
            elseif spellID then
                name= '|cff3fc7eb'..name..'|r'
            else
                name= HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(name)
            end

            sub=root:CreateButton(
                '|T'..icon..':0|t'
                ..name,
            function()
                return MenuResponse.Open
            end, {itemID=itemID, spellID=spellID, type=mountType, index=num})

            sub:SetTooltip(Set_Menu_Tooltip)
            Set_Menu_Index(sub)

            if mountType=='Spell' then
                Init_Menu_Spell(self, sub)
            else
                Init_Menu_Item(self, sub)
            end

            Set_Menu_Index(sub)


        elseif mountType=='Shift' or mountType=='Alt' or mountType=='Ctrl' then
            Init_Menu_ShiftAltCtrl(root, mountType)

        else
            Init_Menu_Mount(root, mountType)
        end
--列表总数
    end

--选项
    root:CreateDivider()
    sub=root:CreateButton(
        '|T413588:0|t'
        ..(Save().KEY or (WoWTools_DataMixin.onlyChinese and '坐骑' or MOUNT)),
    function()
        C_MountJournal.SummonByID(0)
        return MenuResponse.Refresh
    end)
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '随机召唤偏好坐骑' or MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT:gsub('\n', ' '), nil,nil,nil)
    end)
--坐骑秀
    sub2=sub:CreateButton(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '坐骑秀' or 'Mount show'),
    function()
        _G['WoWToolsToolsMountFrame']:initMountShow()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(EMOTE171_CMD2)
        tooltip:AddLine(' ')
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '召唤坐骑:' or MOUNT,
            '|cffffffff'..(Save().mountShowTime or 3)..' '
            ..(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        )
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP,
            WoWTools_DataMixin.Icon.mid
        )
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

    sub2=sub:CreateButton(
        '|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '坐骑特效' or EMOTE171_CMD2),
    function()
        _G['WoWToolsToolsMountFrame']:initSpecial()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '坐骑特效:' or EMOTE171_CMD2,
            (Save().mountShowTime or 3)..' '..(WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS)
        )
        tooltip:AddDoubleLine(
            WoWTools_DataMixin.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN,
            WoWTools_DataMixin.Icon.mid
        )
    end)

    sub2=sub:CreateButton(
        '|T'..FRIENDS_TEXTURE_AFK..':0|t'
        ..(UnitIsAFK('player') and '|cff626262' or '')
        ..(WoWTools_DataMixin.onlyChinese and '暂离' or 'AFK'),
    function()
        WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(SLASH_CHAT_AFK1)
    end)

--坐骑秀，间隔
    sub:CreateSpacer()
    WoWTools_MenuMixin:CreateSlider(sub, {
        getValue=function()
            return Save().mountShowTime or 3
        end, setValue=function(value)
            Save().mountShowTime=value
        end,
        name=WoWTools_DataMixin.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS ,
        minValue=1,
        maxValue=10,
        step=1,
        tooltip=function(tooltip)
            tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '间隔' or CAA_SAY_PLAYER_HEALTH_THROTTLE_LABEL or 'Interval')
        end
    })

--设置捷键
    sub:CreateSpacer()
    WoWTools_KeyMixin:SetMenu(self, sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name= WoWTools_MountMixin.addName,
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
        WoWTools_MountMixin.addName..'|n|cnGREEN_FONT_COLOR:'
        ..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        function()
            WoWToolsSave['Tools_Mounts']= nil
            WoWToolsPlayerDate['Tools_Mounts']= nil
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