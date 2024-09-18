local id, e = ...
local addName

--IsAdvancedFlyableArea()
--IsFlyableArea()
--IsOutdoors()

local ITEMS= ITEMS
local SPELLS= SPELLS
local FLOOR= FLOOR
local MOUNT_JOURNAL_FILTER_GROUND= MOUNT_JOURNAL_FILTER_GROUND
local MOUNT_JOURNAL_FILTER_FLYING= MOUNT_JOURNAL_FILTER_FLYING
local MOUNT_JOURNAL_FILTER_AQUATIC= MOUNT_JOURNAL_FILTER_AQUATIC
local MOUNT_JOURNAL_FILTER_DRAGONRIDING= MOUNT_JOURNAL_FILTER_DRAGONRIDING

local P_Spells_Tab={
    [2645]=true,--幽魂之狼
    [111400]=true,--爆燃冲刺
    [2983]=true,--疾跑
    [190784]=true,--神圣马驹
    [48265]=true,--死亡脚步
    [186257]=true,--猎豹守护
    [6544]=true,--英勇飞跃
    [358267]= true,--悬空
    --[212653]= true,--闪光术
    [1953]=true,--闪现术

    [109132]=true,--滚地翻
    --[115008]=true,--真气突

    [121536]=true,--天堂之羽
    [189110]=true,--地狱火撞击
    [195072]=true,--邪能冲撞
}

local Save={
    --disabled= not e.Player.husandro,
    Mounts={
        [ITEMS]={[174464]=true, [168035]=true},--幽魂缰绳 噬渊鼠缰绳
        [SPELLS]=P_Spells_Tab,
        [FLOOR]={},--{[spellID]=uiMapID}
        [MOUNT_JOURNAL_FILTER_GROUND]={
            --[339588]=true,--[罪奔者布兰契]
            --[163024]=true,--战火梦魇兽
            --[366962]=true,--[艾什阿达，晨曦使者]
            [256123]=true,--[斯克维里加全地形载具]
        },
        [MOUNT_JOURNAL_FILTER_FLYING]={
            --[339588]=true,--[罪奔者布兰契]
            [163024]=true,--战火梦魇兽
            --[366962]=true,--[艾什阿达，晨曦使者]
            --[107203]=true,--泰瑞尔的天使战马
            --[419345]=true,--伊芙的森怖骑行扫帚
        },
        [MOUNT_JOURNAL_FILTER_AQUATIC]={
            --[359379]=true,--闪光元水母
            --[376912]=true,--[热忱的载人奥獭]
            --[342680]=true,--[深星元水母]
            --[30174]=true,--[乌龟坐骑]
            [98718]=true,
            --[64731]=true,--[海龟]
        },
        [MOUNT_JOURNAL_FILTER_DRAGONRIDING]={
            [368896]=true,--[复苏始祖幼龙]
            --[368901]=true,--[崖际荒狂幼龙]
            --[368899]=true,--[载风迅疾幼龙]
            --[360954]=true,--[高地幼龙]
            --[339588]=true,--[罪奔者布兰契]
            --[134359]=true,--飞天魔像
        },
        ['Shift']={
            --[[[75973]=true,--X-53型观光火箭
            [93326]=true,--沙石幼龙
            [121820]=true,--黑耀夜之翼]]

            [359379]=true,--闪光元水母
            [376912]=true,--[热忱的载人奥獭]
            [342680]=true,--[深星元水母]
            [30174]=true,--[乌龟坐骑]
            [98718]=true,
            [64731]=true,--[海龟]
        },
        ['Alt']={[264058]=true,--雄壮商队雷龙
            [122708]=true,--雄壮远足牦牛
            [61425]=true,--旅行者的苔原猛犸象
        },
        ['Ctrl']={
            [256123]=true,--斯克维里加全地形载具
            --[118089]=true,--天蓝水黾
            --[127271]=true,--猩红水黾
            --[107203]=true,--泰瑞尔的天使战马
         },
    },
    --XD= true,
    KEY= e.Player.husandro and 'BUTTON5', --为我自定义, 按键
    AFKRandom=e.Player.husandro,--离开时, 随机坐骑
    mountShowTime=3,--坐骑秀，时间
    showFlightModeButton=true, --切换飞行模式
    toFrame=nil,
}


local panel= CreateFrame("Frame")
local MountButton
local MountShowFrame--坐骑秀

local Faction =  e.Player.faction=='Horde' and 0 or e.Player.faction=='Alliance' and 1
local ShiJI
local OkMount--是否已学, 骑术
local XD


local MountType={
    MOUNT_JOURNAL_FILTER_GROUND,
    MOUNT_JOURNAL_FILTER_AQUATIC,
    MOUNT_JOURNAL_FILTER_FLYING,
    MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    'Shift', 'Alt', 'Ctrl',
    FLOOR,
}


local function set_ShiJI()--召唤司机 代驾型机械路霸
    ShiJI= e.Player.faction=='Horde' and 179244 or (e.Player.faction=='Alliance' and 179245) or nil--"Alliance", "Horde", "Neutral"
end


local function set_OkMout()--是否已学, 骑术
    OkMount= IsSpellKnownOrOverridesKnown(90265)
            or IsSpellKnownOrOverridesKnown(33391)
            or IsSpellKnownOrOverridesKnown(34090)
            or IsSpellKnownOrOverridesKnown(33388)
end












local function XDInt()--德鲁伊设置
    XD=nil
    if e.Player.class=='DRUID' then
        local ground=IsSpellKnownOrOverridesKnown(768) and 768
        local flying=IsSpellKnownOrOverridesKnown(783) and 783
        if ground then
            XD={
                [MOUNT_JOURNAL_FILTER_GROUND]= ground,
                [MOUNT_JOURNAL_FILTER_AQUATIC]= flying,
                [MOUNT_JOURNAL_FILTER_FLYING]= flying,
            }
        end
    end
end

local function getTableNum(type)--检测,表里的数量
    local num= 0
    for _ in pairs(Save.Mounts[type]) do
        num=num+1
    end
    return num
end
local function removeTable(type, ID)--移除, 表里, 其他同样的项目
    for type2, _ in pairs(Save.Mounts) do
        if type2~=type and type2~=FLOOR then
            Save.Mounts[type2][ID]=nil
        end
    end
end
local function checkSpell()--检测法术
    MountButton.spellID=nil
    if XD and XD[MOUNT_JOURNAL_FILTER_GROUND] then
        MountButton.spellID=XD[MOUNT_JOURNAL_FILTER_GROUND]
    else
        for spellID, _ in pairs(Save.Mounts[SPELLS]) do
            if IsSpellKnownOrOverridesKnown(spellID) then
                MountButton.spellID=spellID
                --MountButton.spellTarget= target~=true and target or nil
                break
            end
        end
    end
end
local function checkItem()--检测物品
    MountButton.itemID=nil
    for itemID, _ in pairs(Save.Mounts[ITEMS]) do
        if C_Item.GetItemCount(itemID , false, true, true, false)>0 then
            MountButton.itemID=itemID
            break
        end
    end
end


MountTab={}--MountTab[MountType]={}

local function checkMount()--检测坐骑
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图
    for index, type in pairs(MountType) do
        if XD and XD[type] then
            MountTab[type]={XD[type]}


        elseif index<=3 and not OkMount and ShiJI then--33388初级骑术 33391中级骑术 3409高级骑术 34091专家级骑术 90265大师级骑术 783旅行形态
            MountTab[type]={ShiJI}

        else
            MountTab[type]={}
            if not Save.Mounts[type] then
                Save.Mounts[type]= {}
            end
            for spellID, tab in pairs(Save.Mounts[type]) do
                spellID= (spellID==179244 or spellID==179245) and ShiJI or spellID
                local mountID = C_MountJournal.GetMountFromSpell(spellID)
                if mountID then
                    local isFactionSpecific, faction, shouldHideOnChar, isCollected= select(8, C_MountJournal.GetMountInfoByID(mountID))
                    if not shouldHideOnChar and isCollected and (not isFactionSpecific or faction==Faction) then
                        if type==FLOOR then
                            if uiMapID and tab[uiMapID] and not XD then
                                table.insert(MountTab[type], spellID)
                            end
                        else
                            table.insert(MountTab[type], spellID)
                        end
                    end
                end
            end
        end
    end
end








local function getRandomRoll(type)--随机坐骑
    local tab=MountTab[type] or {}
    if #tab>0 then
        local index=math.random(1,#tab)
        if C_Spell.IsSpellUsable(tab[index]) and not select(2, C_MountJournal.GetMountUsabilityByID(tab[index], true)) then
            return tab[index]
        end
    end
end














local function setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
    if not MountButton:CanChangeAttribute() then
        MountButton.Combat=true
        return
    end
    local tab={'Shift', 'Alt', 'Ctrl'}

    for _, type in pairs(tab) do
        MountButton.textureModifier[type]=nil
        local spellID= MountTab[type] and MountTab[type][1]
        if spellID then
            local name= C_Spell.GetSpellName(spellID)
            local icon= C_Spell.GetSpellTexture(spellID)
            MountButton:SetAttribute(type.."-spell1", name or spellID)
            MountButton.textureModifier[type]=icon
            MountButton.typeSpell=true--提示用
            MountButton.typeID=MountTab[type][1]
            --end
        end
    end
    MountButton.Combat=nil
end


local function setTextrue()--设置图标
    local icon= MountButton.iconAtt
    if IsMounted() then
        icon=136116
    elseif icon then
        local spellID= MountButton.spellAtt or MountButton.itemID and select(2, C_Item.GetItemSpell(MountButton.itemID))
        local aura = spellID and C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        if aura and aura.spellId then
            icon=136116
        end
    end
    if icon then
        MountButton.texture:SetTexture(icon)
    end
    MountButton.texture:SetShown(icon and true or false)
    e.SetItemSpellCool(MountButton, {item=MountButton.itemID, spell=MountButton.spellAtt})--设置冷却
end

--[[
local mapIDs={
    [1978]=true,
    [2022]=true,
    [2023]=true,
    [2024]=true,
    [2025]=true,
    [2112]=true,
    [2093]=true
}
]]

















local function setClickAtt()--设置 Click属性
    --local inCombat=UnitAffectingCombat('player')
    --if inCombat or UnitIsDeadOrGhost('player') or not MountButton:CanChangeAttribute() then
    if not MountButton:CanChangeAttribute() then
        MountButton.Combat=true
        return
    end
    local isFlyableArea= IsFlyableArea()
    local isMoving= IsPlayerMoving()
    local isBat= UnitAffectingCombat('player')
    local spellID
    local isAdvancedFlyableArea = IsAdvancedFlyableArea()
    if XD then
        if IsSubmerged() then
            spellID= 783
        elseif isMoving or isBat then
            spellID= IsIndoors() and 768 or 783
        elseif isAdvancedFlyableArea then
            spellID= getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)
        end
        spellID= spellID or (IsIndoors() and 768 or 783)
    else
        
        spellID= (IsIndoors() or isMoving or isBat) and MountButton.spellID--进入战斗, 室内
            or getRandomRoll(FLOOR)--区域
            or ((isAdvancedFlyableArea or C_Spell.IsSpellUsable(368896)) and-- [368896]=true,--[复苏始祖幼龙] 
                C_UnitAuras.GetAuraDataBySpellName('player', C_Spell.GetSpellName(404468), 'HELPFUL')--404468/飞行模式：稳定
                    and getRandomRoll(MOUNT_JOURNAL_FILTER_FLYING)
                    or getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)
                )
            or (IsSubmerged() and getRandomRoll(MOUNT_JOURNAL_FILTER_AQUATIC))--水平中
            or (isFlyableArea and getRandomRoll(MOUNT_JOURNAL_FILTER_FLYING))--飞行区域
            or (IsOutdoors() and getRandomRoll(MOUNT_JOURNAL_FILTER_GROUND))--室内
            or MountButton.spellID
    end
    spellID= spellID or ShiJI

    if spellID== MountButton.typeID then
        return
    end

    local name, icon
    if spellID then
        name= C_Spell.GetSpellName(spellID)
        icon= C_Spell.GetSpellTexture(spellID)
        if name and icon then
            if spellID==6544 or spellID==189110 then--6544英勇飞跃 189110地狱火撞击
                MountButton:SetAttribute("type1", "macro")
                MountButton:SetAttribute("macrotext1", format('/cast [@cursor]%s', name))
                MountButton:SetAttribute('unit', nil)
                --[[MountButton:SetAttribute('type1', 'spell')
                MountButton:SetAttribute('spell1', name)
                MountButton:SetAttribute('unit', 'cursor')]]
            else
                MountButton:SetAttribute("type1", "spell")
                MountButton:SetAttribute("spell1", name)
                if spellID==121536 then--天堂之羽 
                    MountButton:SetAttribute('unit', "player")--mouseover player
                else
                    MountButton:SetAttribute('unit', nil)
                end
                MountButton.typeSpell=true--提示用
                MountButton.typeID=spellID
            end
        else
            e.LoadData({id=spellID, type='spell'})
            MountButton.Combat=true
        end
    elseif MountButton.itemID then
        MountButton:SetAttribute("type1", "item")
        MountButton:SetAttribute("item1", C_Item.GetItemNameByID(MountButton.itemID))
        MountButton:SetAttribute('unit', nil)
        MountButton.typeID= MountTab[type][1]
        MountButton.typeSpell=nil--提示用
        MountButton.typeID=spellID
    else
        MountButton:SetAttribute("item1", nil)
        MountButton:SetAttribute("spell1", nil)
        MountButton:SetAttribute('unit', nil)
        MountButton.typeSpell=nil--提示用
        MountButton.typeID=nil
    end
    MountButton.spellAtt=spellID
    MountButton.iconAtt=icon
    setTextrue()--设置图标

    MountButton.Combat=nil
end































--坐骑秀
function Init_Mount_Show()
    MountShowFrame=CreateFrame('Frame', nil, MountButton)
    MountShowFrame:SetAllPoints()
    MountShowFrame:Hide()

    function MountShowFrame:get_mounts()--得到，有效坐骑，表
        WoWTools_LoadUIMixin:Journal()
        self.tabs={}
        C_MountJournal.SetDefaultFilters()
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false)
        for index=1, C_MountJournal.GetNumDisplayedMounts() do
            local _, _, _, isActive, isUsable, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(index)
            if not isActive and isUsable and mountID then
                table.insert(self.tabs, mountID)
            end
        end
        local num= #self.tabs
        if num==0 then
            self:Hide()
        end
        return num
    end

    function MountShowFrame:initSpecial()--启用，坐骑特效
        self:rest()
        self.specialEffects= true
        self:set_shown()
    end

    function MountShowFrame:set_shown()--设置，是否显示
        local show= true
        if UnitAffectingCombat('player') or IsIndoors() then
            show=false

        elseif self.specialEffects and not IsMounted() then
            C_MountJournal.SummonByID(0)
        end
        self:SetShown(show)
    end

    function MountShowFrame:initMountShow()--启用，坐骑秀
        self:rest()
        self:set_shown()
    end

    function MountShowFrame:rest()--重置
        self.elapsed=Save.mountShowTime
        self.specialEffects=nil
        self.tabs={}
        e.Ccool(self)
        self:SetShown(false)
    end

    function MountShowFrame:set_evnet()--AFK, 事件
        self:UnregisterAllEvents()
        if Save.AFKRandom then
            self:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            self:RegisterEvent('PLAYER_REGEN_DISABLED')
        end
    end

    MountShowFrame:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_FLAGS_CHANGED' then
            if UnitIsAFK('player') then
                self:set_shown()
            end

        elseif event=='PLAYER_REGEN_ENABLED' then
            self:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')

        elseif event=='PLAYER_REGEN_DISABLED' then
            self:UnregisterEvent('PLAYER_FLAGS_CHANGED')
        end
    end)


    MountShowFrame:SetScript('OnUpdate', function(self, elapsed)--启用
        self.elapsed= self.elapsed  + elapsed

        if IsIndoors() or UnitAffectingCombat('player') or IsPlayerMoving() or UnitIsDeadOrGhost('player') then
            self:Hide()
            self.specialEffects=nil
            return

        elseif self.elapsed> Save.mountShowTime then
            self.elapsed=0

            e.Ccool(self, nil, Save.mountShowTime, 0, true,false, true )--冷却条
            if self.specialEffects then
                DEFAULT_CHAT_FRAME.editBox:SetText(EMOTE171_CMD2)
                ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)

            else
                do
                    if #self.tabs==0 then
                        if self:get_mounts()==0 then
                            self:Hide()
                            return
                        end
                    end
                end
                local index= math.random(1, #self.tabs)
                C_MountJournal.SummonByID(self.tabs[index] or 0)
                table.remove(self.tabs, index)
            end
        end
    end)
    MountShowFrame:SetScript('OnHide', MountShowFrame.rest)

    MountShowFrame:set_evnet()
    MountShowFrame:rest()
end
































--C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
--C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,false)
--C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE,false)


--##################
--打开界面, 收藏, 坐骑
--[[##################
local function set_ToggleCollectionsJournal(mountID, type, showNotCollected)
    WoWTools_LoadUIMixin:Journal(1)

    C_MountJournal.SetDefaultFilters()
    if not showNotCollected then
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, false)
    end
    if mountID then
        local name= C_MountJournal.GetMountInfoByID(mountID)
        if name then
            MountJournalSearchBox:SetText(name)
            --C_MountJournal.SetSearch(name)
            return --不, 过滤, 类型
        end
    end
    local tab={--过滤, 类型, Blizzard_MountCollection.lua
        [MOUNT_JOURNAL_FILTER_GROUND]= Enum.MountType.Ground,
        [MOUNT_JOURNAL_FILTER_AQUATIC]= Enum.MountType.Aquatic,
        [MOUNT_JOURNAL_FILTER_FLYING]=Enum.MountType.Flying,
        [MOUNT_JOURNAL_FILTER_DRAGONRIDING]= Enum.MountType.Dragonriding,
    }
    MountJournalSearchBox:SetText('')
    if type and tab[type] then
        for i=0, Enum.MountTypeMeta.NumValues do
            C_MountJournal.SetTypeFilter(i, i==tab[type]+1)
        end
    end
    return MenuResponse.Open
end]]




























local function Set_Mount_Summon(data)
    C_MountJournal.SummonByID(data.mountID or 0)
    return MenuResponse.Open
end







local function Set_Item_Spell_Edit(info)
    if info.type==FLOOR then
        StaticPopup_Show('WoWTools_GetMapID', addName, nil, {
            type=info.type,
            spellID=info.spellID,
            OnShow=function(self, data)
                local text= ''
                local tab= Save.Mounts[FLOOR][data.spellID] or {}
                for uiMapID, _ in pairs(tab) do
                    text= text..uiMapID..', '
                end
                if text=='' then
                    local mapID= C_Map.GetBestMapForUnit("player")
                    text= (mapID and text..mapID or text)..', '
                end
                self.editBox:SetText(text)
                self.data.text= text
                self.button3:SetEnabled(Save.Mounts[FLOOR][data.spellID] and true or false)
            end,
            SetValue = function(_, data, tab, text)
                Save.Mounts[FLOOR][data.spellID]= tab
                MountButton:settings()
                if MountJournal_UpdateMountList then e.call(MountJournal_UpdateMountList) end
                print(e.addName, addName, C_Spell.GetSpellLink(data.spellID), '|n', text)

            end,
            OnAlt = function(_, data)
                Save.Mounts[FLOOR][data.spellID]=nil
                checkMount()--检测坐骑
                setClickAtt()--设置 Click属性
                if MountJournal_UpdateMountList then e.call(MountJournal_UpdateMountList) end
                print(e.addName, addName, e.onlyChinese and '移除' or REMOVE, data.link)
            end
        })
        return MenuResponse.Open
    end


    local name, link, texture, itemRarity, color, type, count, _
    if info.itemID or info.itemLink then
        name, link, itemRarity, _, _, _, _, _, _, texture = C_Item.GetItemInfo(info.itemLink or info.itemID)
        color= {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()}
        type=info.type
        count=C_Item.GetItemCount(info.itemID, true, false, true,true)
    elseif info.spellID then
        name= C_Spell.GetSpellName(info.spellID)
        texture= C_Spell.GetSpellTexture(info.spellID)
        link=C_Spell.GetSpellLink(info.spellID)
        type=info.type
    end

    StaticPopup_Show('WoWTools_Item', addName, nil, {
        link= info.itemLink or link,
        ID= info.itemID or info.spellID,
        name= name,
        type= type,
        color= color,
        texture= texture,
        count=count,
        OnShow=function(self, data)
            self.button3:SetEnabled(Save.Mounts[data.type][data.ID] and true or false)
            self.button1:SetEnabled(not Save.Mounts[data.type][data.ID] and true or false)
        end,
        SetValue = function(_, data)
            Save.Mounts[data.type][data.ID]=true
            MountButton:settings()
            print(e.addName, addName, e.onlyChinese and '添加' or ADD, data.link)
        end,
        OnAlt = function(_, data)
            Save.Mounts[data.type][data.ID]=nil
            MountButton:settings()
            print(e.addName, addName, e.onlyChinese and '移除' or REMOVE, data.link)
        end,
    })

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
        for uiMapID, _ in pairs(Save.Mounts[FLOOR][desc.data.spellID] or {}) do
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
                Save.Mounts[data]={}
                print(e.addName, addName, e.onlyChinese and '全部清除' or CLEAR_ALL, e.cn(type))
                MountButton:settings()

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
        Set_Item_Spell_Edit,
        data
    )

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


    --[[if data.spellID or data.mountID then
        local sub=root:CreateButton(
            '|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '设置' or SETTINGS),
            function(info)
                if info.mountID then
                   
                    --set_ToggleCollectionsJournal(info.mountID, info.type)--打开界面, 收藏, 坐骑, 不过滤类型
                elseif info.spellID then
                    PlayerSpellsUtil.OpenToSpellBookTabAtSpell(info.spellID)--查询，法术书，法术
                end
                return MenuResponse.Open
            end,
            data
        )
        sub:SetTooltip(function(tooltip, info)
            if info.mountID then
                tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
            elseif info.spellID then
                tooltip:AddLine(MicroButtonTooltipText('天赋和法术书', "TOGGLETALENTS"))
            end
        end)
    end]]

    root:CreateButton(
        '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE),
        function(info)
            Save.Mounts[info.type][info.itemID or info.spellID]=nil

            print(e.addName, addName, e.onlyChinese and '移除' or REMOVE,
                    WoWTools_ItemMixin:GetLink(info.itemID)
                    or (info.spellID and C_Spell.GetSpellLink(info.spellID)
                    or info.itemID or info.spellID
            ))
            MountButton:settings()
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
















function Init_Menu_Mount(root, type, name)
    local tab2=MountTab[type] or {}
    e.LoadData({id=tab2[1], type='spell'})
    local num=getTableNum(type)--检测,表里的数量
    local col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], (e.onlyChinese and name or e.cn(type))..' '..col..num, nil)


    local index=0
    for spellID, _ in pairs(Save.Mounts[type] or {}) do
        e.LoadData({id=spellID, type='spell'})
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end









local function Init_Menu_ShiftAltCtrl(root, type)
    local tab2=MountTab[type] or {}
    e.LoadData({id=tab2[1], type='spell'})
    local num=getTableNum(type)--检测,表里的数量
    local col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], type..' '..col..num, nil)

    if num>1 then
        sub:CreateTitle(
            e.onlyChinese and '仅限第1个' or
            format(LFG_LIST_CROSS_FACTION, format(JAILERS_TOWER_SCENARIO_FLOOR, 1))
        )
    end

    local index=0
    for spellID, _ in pairs(Save.Mounts[type] or {}) do
        e.LoadData({id=spellID, type='spell'})
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end















local function Init_Menu_Spell(sub)
    local sub2, icon, col
    local index=0
    for spellID, _ in pairs(Save.Mounts[SPELLS]) do
        e.LoadData({id=spellID, type='spell'})
        index= index+1

        icon='|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
        col= (IsSpellKnownOrOverridesKnown(spellID) and '' or '|cff9e9e9e')

        sub2=sub:CreateButton(
            index..') '
            ..col
            ..icon
            ..(e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID: '..spellID)),
        Set_Item_Spell_Edit, {spellID=spellID, type=SPELLS})
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
            Save.Mounts[SPELLS]=P_Spells_Tab
            print(e.addName, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
            MountButton:settings()
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
    end)

    --[[sub2=sub:CreateTitle(e.onlyChinese and '拖曳法术' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, SPELLS))
    sub2:SetTooltip(function (tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '添加' or ADD)
    end)]]
end













local function Init_Menu_Item(sub)
    local sub2, num, icon
    local index= 0
    for itemID, _ in pairs(Save.Mounts[ITEMS]) do
        e.LoadData({id=itemID, type='item'})
        index= index+1

        icon='|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
        num= C_Item.GetItemCount(itemID, false, true, true) or 0

        local name= '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
                    ..(e.cn(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID: '..itemID))
                    ..(num==0 and '|cff9e9e9e' or '|cffffffff')..' x'..num..'|r'

        sub2=sub:CreateButton(
            index..') '..name,
            Set_Item_Spell_Edit,
            {itemID=itemID, name=name, type=ITEMS}
        )
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
--[[
    if index==1 then
        sub:CreateDivider()
    end

    sub2=sub:CreateButton(e.onlyChinese and '添加' or ADD, function()
        return MenuResponse.Open
    end)]]

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
local function Init_Menu(_, root)
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
                if MountButton.spellID then
                    spellID= MountButton.spellID
                    --data.spellID=MountButton.spellID
                    icon= C_Spell.GetSpellTexture(MountButton.spellID)
                end
            elseif indexType==ITEMS then
                if MountButton.itemID then
                    itemID=MountButton.itemID
                    --data.itemID=MountButton.itemID
                    icon=C_Item.GetItemIconByID(MountButton.itemID)
                end
            end
            icon= icon or 0
            num=getTableNum(indexType)--检测,表里的数量
            col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

            sub=root:CreateButton('|T'..icon..':0|t'..(e.onlyChinese and tab.name or indexType).. col..' '.. num..'|r', function()
                return MenuResponse.Open
            end, {itemID=itemID, spellID=spellID, type=indexType})
            sub:SetTooltip(Set_Menu_Tooltip)

            if indexType==SPELLS then
                Init_Menu_Spell(sub)
            else
                Init_Menu_Item(sub)
            end

        elseif indexType=='Shift' or indexType=='Alt' or indexType=='Ctrl' then
            Init_Menu_ShiftAltCtrl(root, indexType)

        else
            Init_Menu_Mount(root, indexType, tab.name)
        end
    end

--选项
    root:CreateDivider()
    sub=root:CreateButton('|T413588:0|t'..(Save.KEY or (e.onlyChinese and '坐骑' or MOUNT)),
    function()
        C_MountJournal.SummonByID(0)
    end, {spellID=150544})
    sub:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '随机召唤偏好坐骑' or MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT:gsub('\n', ' '), nil,nil,nil)
    end)
        --Set_Menu_Tooltip)

    sub2=sub:CreateButton('|A:bags-greenarrow:0:0|a'..(e.onlyChinese and '坐骑秀' or 'Mount show'), function()
        MountShowFrame:initMountShow()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '召唤坐骑:' or MOUNT..': ', Save.mountShowTime..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS))
        tooltip:AddDoubleLine(e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP, e.Icon.mid)
    end)

    sub3=sub2:CreateCheckbox('<AFK>'..(e.onlyChinese and '自动' or SELF_CAST_AUTO), function()
        return Save.AFKRandom
    end, function()
        Save.AFKRandom= not Save.AFKRandom and true or nil
        MountShowFrame:set_evnet()
        if Save.AFKRandom then
            WoWTools_ChatMixin:SendText(SLASH_CHAT_AFK1)
        end
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddLine(SLASH_CHAT_AFK1)
        tooltip:AddLine(e.onlyChinese and '注意: 掉落' or (LABEL_NOTE..': '..STRING_ENVIRONMENTAL_DAMAGE_FALLING))
    end)

    sub2=sub:CreateButton('|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a'..(e.onlyChinese and '坐骑特效' or EMOTE171_CMD2:gsub('/','')), function()
        MountShowFrame:initSpecial()
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '坐骑特效:' or EMOTE171_CMD2:gsub('/','')..': ', Save.mountShowTime..' '..(e.onlyChinese and '秒' or LOSS_OF_CONTROL_SECONDS))
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
            return Save.mountShowTime
        end, setValue=function(value)
            Save.mountShowTime=value
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
    WoWTools_Key_Button:SetMenu(sub, {
        icon='|A:NPE_ArrowDown:0:0|a',
        name=addName..(num2 and num2>0 and text2 or ''),
        key=Save.KEY,
        GetKey=function(key)
            Save.KEY=key
            WoWTools_Key_Button:Setup(MountButton)--设置捷键
        end,
        OnAlt=function()
            Save.KEY=nil
            WoWTools_Key_Button:Setup(MountButton)--设置捷键
        end,
    })

--[[位于上方
    WoWTools_MenuMixin:ToTop(sub, {
        name=nil,
        GetValue=function()
            return Save.toFrame
        end,
        SetValue=function()
            Save.toFrame = not Save.toFrame and true or nil
            WoWTools_ToolsButtonMixin:RestAllPoint()--重置所有按钮位置
        end,
        tooltip=nil,
        isReload=false,--重新加载UI
    })
    ]]
--全部重置
    WoWTools_MenuMixin:RestData(sub,
        addName..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        function()
            Save=nil
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
    sub2=WoWTools_ToolsButtonMixin:OpenMenu(sub, addName)
end









































--界面，菜单
local function Init_UI_Menu(self, root)
    local frame= self:GetParent()
    local mountID = frame.mountID

    if not mountID then
        root:CreateTitle((e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..' mountID')
        return
    end

    local name, spellID, icon, _, _, _, _, isFactionSpecific, faction, shouldHideOnChar, isCollected, _, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)
    spellID= spellID or self.spellID

    if not name then
        return
    end

    local col, sub
    for _, type in pairs(MountType) do
        if type=='Shift' or type==FLOOR then
            root:CreateDivider()
        end

        col= (
            (type==MOUNT_JOURNAL_FILTER_DRAGONRIDING and not isForDragonriding)
            or (type~=MOUNT_JOURNAL_FILTER_DRAGONRIDING and isForDragonriding)
            or not isCollected
            or shouldHideOnChar
            or (isFactionSpecific and faction~=Faction)
        ) and '|cff9e9e9e' or ''

        function GetValue(data)
            return Save.Mounts[data.type][data.spellID]
        end

        local setData= {type=type, spellID=spellID, mountID=mountID, name=name, icon='|T'..(icon or 0)..':0|t'}
        sub=root:CreateCheckbox(col..(e.onlyChinese and '设置' or SETTINGS)..' '..e.cn(type)..' #|cnGREEN_FONT_COLOR:'..getTableNum(type),
            function(data)
                return Save.Mounts[data.type][data.spellID]

            end, function(data)
                if Save.Mounts[data.type][data.spellID] then
                    Save.Mounts[data.type][data.spellID]=nil

                elseif data.type==FLOOR then
                    Set_Item_Spell_Edit(data)
                else
                    if data.type=='Shift' or data.type=='Alt' or data.type=='Ctrl' then--唯一
                        Save.Mounts[data.type]={[data.spellID]=true}
                    else
                        Save.Mounts[data.type][data.spellID]=true
                    end
                    removeTable(data.type, data.spellID)--移除, 表里, 其他同样的项目
                end
                MountButton:settings()
                e.call(MountJournal_UpdateMountList)
            end, setData
        )
        Set_Mount_Sub_Options(sub, setData)
    end

    root:CreateDivider()
    WoWTools_ToolsButtonMixin:OpenMenu(root, WoWTools_SpellMixin:GetName(spellID) or ('|T'..(icon or 0)..':0|t'..name))
end


















--过滤，列表，Func
local function New_MountJournal_FullUpdate()
    if not MountJournal:IsVisible() then
        return
    end

    local btn= _G['MountJournalFilterButtonWoWTools']
    local spellIDs={}
    for type in pairs(btn.Type or {}) do
        for spellID in pairs(Save.Mounts[type]) do
            spellIDs[spellID]=true
        end
    end
    local newDataProvider = CreateDataProvider();
    for index = 1, C_MountJournal.GetNumDisplayedMounts()  do
        local _, spellID, _, _, _, _, _, _, _, _, _, mountID   = C_MountJournal.GetDisplayedMountInfo(index)
        if mountID and spellID and spellIDs[spellID] then
            newDataProvider:Insert({index = index, mountID = mountID})
        end
    end
    MountJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);
    if (not MountJournal.selectedSpellID) then
        MountJournal_Select(1);
    end
    MountJournal_UpdateMountDisplay()
end





local function Updata_MountJournal_FullUpdate(self)
    MountJournal_FullUpdate=New_MountJournal_FullUpdate--过滤，列表，Func

    MountJournal.FilterDropdown:Reset()
    e.call(MountJournal_SetUnusableFilter,true)
    e.call(MountJournal_FullUpdate, MountJournal)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE or 3, true);

    self.ResetButton:SetShown(true)
    self:set_text()
end







--过滤，列表，菜单
local function Init_UI_List_Menu(self, root)
    for _, type in pairs(MountType) do
        root:CreateCheckbox(e.cn(type)..' #|cnGREEN_FONT_COLOR:'..getTableNum(type), function(data)
            return self.Type[data]
        end, function(data)
            self.Type[data]= not self.Type[data] and true or nil
            Updata_MountJournal_FullUpdate(self)
        end, type)
    end

    root:CreateDivider()
    root:CreateButton('     '..(e.onlyChinese and '勾选所有' or CHECK_ALL), function()
        self.Type={
            [MOUNT_JOURNAL_FILTER_GROUND]=true,
            [MOUNT_JOURNAL_FILTER_AQUATIC]=true,
            [MOUNT_JOURNAL_FILTER_FLYING]=true,
            [MOUNT_JOURNAL_FILTER_DRAGONRIDING]=true,
            ['Shift']=true, ['Alt']=true, ['Ctrl']=true,
            [FLOOR]=true,
        }
        Updata_MountJournal_FullUpdate(self)

        return MenuResponse.Refresh
    end)

    root:CreateButton('     '..(e.onlyChinese and '撤选所有' or UNCHECK_ALL), function()
        self:rest_type()
        self.ResetButton:Click()
        return MenuResponse.Refresh
    end)

    root:CreateDivider()
    WoWTools_ToolsButtonMixin:OpenMenu(root, addName)
end































--初始，坐骑界面
local function Init_MountJournal()
    hooksecurefunc('MountJournal_InitMountButton',function(frame)--Blizzard_MountCollection.lua
        if not frame or not frame.spellID then
            if frame and frame.btn then
                frame.btn:SetShown(false)
            end
            return
        end
        local text
        for _, type in pairs(MountType) do
            local ID=Save.Mounts[type][frame.spellID]
            if ID then
                text= text and text..'|n' or ''
                if type==FLOOR then
                    local num=0
                    for _, _ in pairs(ID) do
                        num=num+1
                    end
                    text=text..'|cnGREEN_FONT_COLOR:'..num..'|r'
                end
                text= text..e.cn(type)
            end
        end
         if not frame.WoWToolsButton then--建立，图标，菜单
            frame.WoWToolsButton=WoWTools_ButtonMixin:Cbtn(frame, {icon=true, size={22,22}})
            frame.WoWToolsButton:SetPoint('BOTTOMRIGHT')
            frame.WoWToolsButton:SetAlpha(0)
            frame.WoWToolsButton:SetScript('OnEnter', function(self)
                self:SetAlpha(1)
            end)
            frame.WoWToolsButton:SetScript('OnLeave', function(self) self:SetAlpha(0) end)
            frame.WoWToolsButton:SetScript('OnClick', function(self)
                MenuUtil.CreateContextMenu(self, Init_UI_Menu)--界面，菜单
            end)
            frame:HookScript('OnLeave', function(self) self.WoWToolsButton:SetAlpha(0) end)
            frame:HookScript('OnEnter', function(self) self.WoWToolsButton:SetAlpha(1) end)
            frame.WoWToolsText=WoWTools_LabelMixin:CreateLabel(frame, {justifyH='RIGHT'})--nil, frame.name, nil,nil,nil,'RIGHT')
            frame.WoWToolsText:SetPoint('TOPRIGHT',0,-2)
            frame.WoWToolsText:SetFontObject('GameFontNormal')
            frame.WoWToolsText:SetAlpha(0.5)
        end
        frame.WoWToolsButton.mountID= frame.mountID
        frame.WoWToolsButton.spellID= frame.spellID
        frame.WoWToolsButton:SetShown(true)
        frame.WoWToolsText:SetText(text or '')--提示， 文本
    end)

    if not MountJournal.MountDisplay.tipsMenu then
        MountJournal.MountDisplay.tipsMenu= WoWTools_ButtonMixin:Cbtn(MountJournal.MountDisplay, {icon=true, size={22,22}})
        MountJournal.MountDisplay.tipsMenu:SetPoint('LEFT')
        MountJournal.MountDisplay.tipsMenu:SetAlpha(0.3)
        MountJournal.MountDisplay.tipsMenu:SetScript('OnMouseDown', function(self)
            MenuUtil.CreateContextMenu(self, Init_Menu)
            self:SetAlpha(1)
        end)
        MountJournal.MountDisplay.tipsMenu:SetScript('OnLeave', function(self) self:SetAlpha(0.3) end)
    end

    --local btn= CreateFrame('DropDownToggleButton', 'MountJournalFilterButtonWoWTools', MountJournal, 'UIResettableDropdownButtonTemplate')--SharedUIPanelTemplates.lua
    local btn= CreateFrame('DropdownButton', 'MountJournalFilterButtonWoWTools', MountJournal, 'WowStyle1FilterDropdownTemplate')
    btn:SetPoint('BOTTOM', MountJournal.FilterDropdown, 'TOP', 0, 6)


    MountJournal.FilterDropdown.ResetButton:HookScript('OnClick', function()
        local btn2= _G['MountJournalFilterButtonWoWTools']
        if btn2.ResetButton:IsShown() then
            btn2.ResetButton:Click()
        end
    end)

    btn.MountJournal_FullUpdate= MountJournal_FullUpdate

    function btn:rest_type()
        self.Type={}
    end
    function btn:set_text()
        for type in pairs(self.Type or {}) do
            self:SetText(e.cn(type))
            return
        end
        self:SetText('Tools')
    end

    --重置
    btn.ResetButton:SetScript('OnClick', function(self)
        local frame= self:GetParent()
        MountJournal_FullUpdate= frame.MountJournal_FullUpdate
        frame:set_text()
        MountJournal.FilterDropdown:Reset()
        C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE or 3, true);
        e.call(MountJournal_SetUnusableFilter,true)
        e.call(MountJournal_FullUpdate, MountJournal)
        self:Hide()
        self:GetParent():rest_type()
    end)

    MountJournal.MountCount:ClearAllPoints()
    MountJournal.MountCount:SetPoint('BOTTOMRIGHT', MountJournalSearchBox, 'TOPRIGHT', 0, 4)


    btn:rest_type()
    btn:set_text()
    btn:SetupMenu(Init_UI_List_Menu)--过滤，列表，菜单    
end
















local function set_Use_Spell_Button(btn, spellID)
    if not btn.mountSpell then
        btn.mountSpell= WoWTools_ButtonMixin:Cbtn(btn, {size={16,16}, atlas='hud-microbutton-Mounts-Down'})
        btn.mountSpell:SetPoint('TOP', btn, 'BOTTOM', -8, 0)
        function btn.mountSpell:set_alpha()
            if self.spellID then
                self:SetAlpha(Save.Mounts[SPELLS][self.spellID] and 1 or 0.2)
            end
        end
        function btn.mountSpell:set_tooltips()
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.addName)
            e.tips:AddDoubleLine(WoWTools_ToolsButtonMixin:GetName(), addName)
            e.tips:AddLine(' ')
            if self.spellID then
                e.tips:AddDoubleLine(
                    '|T'..(C_Spell.GetSpellTexture(self.spellID) or 0)..':0|t'
                    ..(C_Spell.GetSpellLink(self.spellID) or self.spellID)
                    ..' '..e.GetEnabeleDisable(Save.Mounts[SPELLS][self.spellID]),

                    e.Icon.left
                )
            end
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
            self:SetAlpha(1)
        end
        btn.mountSpell:SetScript('OnLeave', function(self) e.tips:Hide() self:set_alpha()  end)
        btn.mountSpell:SetScript('OnEnter', btn.mountSpell.set_tooltips)
        btn.mountSpell:SetScript('OnMouseDown', function(self, d)
            if d=='LeftButton' then
                if self.spellID then
                    Save.Mounts[SPELLS][self.spellID]= not Save.Mounts[SPELLS][self.spellID] and true or nil
                    self:set_tooltips()
                    self:set_alpha()
                    MountButton:settings()
                    print(e.addName, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD, C_Spell.GetSpellLink(self.spellID))
                end
            else
                MenuUtil.CreateContextMenu(self, function(_, root)
                    Init_Menu_Spell(root)
                end)
            end
        end)
    end

    btn.mountSpell.spellID= spellID
    btn.mountSpell:set_alpha()
    btn.mountSpell:SetShown(spellID and true or false)
end
















--436854 C_MountJournal.GetDynamicFlightModeSpellID() 切换飞行模式
--######
--初始化
--######
local function Init()

    WoWTools_Key_Button:Init(MountButton, function() return Save.KEY end)


    for type, tab in pairs(Save.Mounts) do
        for ID, _ in pairs(tab) do
            e.LoadData({id=ID, type= type==ITEMS and 'item' or 'spell'})
        end
    end

    MountButton:SetAttribute("type1", "spell")
    MountButton:SetAttribute("alt-type1", "spell")
    MountButton:SetAttribute("shift-type1", "spell")
    MountButton:SetAttribute("ctrl-type1", "spell")
    --MountButton:SetFrameStrata('HIGH')

    MountButton.textureModifier=MountButton:CreateTexture(nil,'OVERLAY')--提示 Shift, Ctrl, Alt
    MountButton.textureModifier:SetAllPoints(MountButton.texture)
    MountButton.textureModifier:AddMaskTexture(MountButton.mask)

    MountButton.textureModifier:SetShown(false)

    MountButton.Up=MountButton:CreateTexture(nil,'OVERLAY')
    MountButton.Up:SetPoint('TOP',-1, 9)
    MountButton.Up:SetAtlas('NPE_ArrowUp')
    MountButton.Up:SetSize(20,20)










    MountButton:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID then
            Set_Item_Spell_Edit({itemID=itemID, itemLink=itemLink, type=ITEMS})
            ClearCursor()
            return
        elseif infoType =='spell' and spellID then
            Set_Item_Spell_Edit({spellID=spellID, type=SPELLS})
            ClearCursor()
            return

        elseif d=='RightButton' and not IsModifierKeyDown() then
            MenuUtil.CreateContextMenu(self, Init_Menu)

        elseif d=='LeftButton' then
            if IsMounted() then
               C_MountJournal.Dismiss()

            --战斗中，可用，驭空术
            elseif UnitAffectingCombat('player') and not IsPlayerMoving() and  C_Spell.IsSpellUsable(368896) then
                local spellID2= getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)
                local mountID= spellID2 and C_MountJournal.GetMountFromSpell(spellID2) or 368896
                if mountID then
                    C_MountJournal.SummonByID(mountID)
                end
            end
        end
        self.border:SetAtlas('bag-border')
    end)

    MountButton:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' then
            self.border:SetAtlas('bag-reagent-border')
        end
    end)

    MountButton:SetScript('OnMouseWheel',function(_, d)
        if d==1 then--坐骑秀
            MountShowFrame:initMountShow()
        elseif d==-1 then--坐骑特效
            MountShowFrame:initSpecial()
        end
    end)

    function MountButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local infoType, itemID, _, spellID= GetCursorInfo()
        local name, col, exits
        if infoType == "item" and itemID then
            name, col= WoWTools_ItemMixin:GetName(itemID)
            exits= Save.Mounts[ITEMS][itemID] and true or false

        elseif infoType =='spell' and spellID then
            name, col= WoWTools_SpellMixin:GetName(spellID)
            exits=Save.Mounts[SPELLS][spellID] and true or false
        end

        if name and exits~=nil then
            e.tips:AddDoubleLine(name,
                (col or '')
                ..(exits and
                    (e.onlyChinese and '修改' or EDIT)
                    or ('|A:bags-icon-addslots:0:0|a'..(e.onlyChinese and '添加' or ADD))
                ))
        else
            if self.typeID then
                local key= WoWTools_Key_Button:IsKeyValid(self)
                e.tips:AddDoubleLine(
                    self.typeSpell and WoWTools_SpellMixin:GetName(self.typeID) or WoWTools_ItemMixin:GetName(self.typeID),
                    (key and '|cnGREEN_FONT_COLOR:'..key or '')..e.Icon.left
                )
                e.tips:AddLine(' ')
            end
            e.tips:AddDoubleLine(e.onlyChinese and '坐骑秀' or 'Mount show', '|A:bags-greenarrow:0:0|a')
            e.tips:AddDoubleLine(e.onlyChinese and '坐骑特效' or EMOTE171_CMD2:gsub('/',''), '|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a')

            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
        end
        e.tips:Show()
    end

    MountButton:SetScript("OnLeave",function(self)
        e.tips:Hide()
        setClickAtt()--设置属性
        ResetCursor()
        self.border:SetAtlas('bag-reagent-border')
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)

    MountButton:SetScript('OnEnter', function(self)
        WoWTools_ToolsButtonMixin:EnterShowFrame(self)
        self:set_tooltips()
        self:SetScript('OnUpdate', function (s, elapsed)
            s.elapsed = (s.elapsed or 0.3) + elapsed
            if s.elapsed > 0.3 and s.typeID then
                s.elapsed = 0
                if GameTooltip:IsOwned(s) then
                    local typeID= s.typeSpell and select(2, GameTooltip:GetSpell()) or select(3, GameTooltip:GetItem())
                    if typeID and typeID~=s.typeID then
                        s:set_tooltips()
                    end
                end
            end
        end)
    end)




    function MountButton:settings()
        set_ShiJI()--召唤司机
        set_OkMout()--是否已学, 骑术
        XDInt()--德鲁伊设置
        checkSpell()--检测法术
        checkItem()--检测物品
        checkMount()--检测坐骑
        setClickAtt()--设置
        setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
    end

    MountButton:settings()
   -- Init_Dialogs()--初始化，对话框
    Init_Mount_Show()--坐骑秀

    C_Timer.After(4, function()
        if not UnitAffectingCombat('player') then
            setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
            setClickAtt()--设置
            e.SetItemSpellCool(MountButton, {item=MountButton.itemID, spell=MountButton.spellAtt})--设置冷却
        end
    end)

    hooksecurefunc('SpellFlyoutButton_UpdateGlyphState', function(self)--法术书，界面, Flyout, 菜单
        local frame= self:GetParent():GetParent()
        if not frame or not frame.mountSpell or not self.spellID or C_Spell.IsSpellPassive(self.spellID) then
            if self.mountSpell then
                self.mountSpell:SetShown(false)
            end
        else
            set_Use_Spell_Button(self, self.spellID)
        end
    end)
end













--[[

local KeybindingSpacer = {};
local function GetBindingCategoryName(cat)
	local loc = _G[cat];
	if type(loc) == "string" then
		return loc;
	end

	return cat;
end


local function CreateSearchableSettings(redirectCategory)
	local fakeCategory, layout = Settings.RegisterVerticalLayoutCategory("NoDisplayKB");

	local bindingsCategories = {
		[BINDING_HEADER_OTHER] = {},
	};

	for bindingIndex = 1, GetNumBindings() do
		local action, cat, binding1, binding2 = GetBinding(bindingIndex);
		
		if not cat then
			tinsert(bindingsCategories[BINDING_HEADER_OTHER], {bindingIndex, action});
		else
			if not bindingsCategories[cat] then
				bindingsCategories[cat] = {};
			end

			if strsub(action, 1, 6) ~= "HEADER" then
				tinsert(bindingsCategories[cat], {bindingIndex, action});
			end
		end
	end

	for categoryName, bindingCategory in pairs(bindingsCategories) do
		for _, bindingData in ipairs(bindingCategory) do
			local bindingIndex, action = unpack(bindingData);
			local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
			local bindingName = securecallfunction(GetBindingName, action);
			initializer:AddSearchTags(bindingName);
			layout:AddInitializer(initializer);
		end
	end

	fakeCategory.redirectCategory = redirectCategory;
	Settings.RegisterCategory(fakeCategory, SETTING_GROUP_GAMEPLAY);
end
local function CreateKeybindingInitializers(category, layout)
	-- Keybinding sections
	local bindingsCategories = {};
	local nextOrder = 1;
	local function AddBindingCategory(key, requiredSettingName, expanded)
		if not bindingsCategories[key] then
			bindingsCategories[key] = {order = nextOrder, bindings = {}, requiredSettingName = requiredSettingName, expanded = expanded};
			nextOrder = nextOrder + 1;
		end
	end

	KeybindingsOverrides.AddBindingCategories(AddBindingCategory);

	for bindingIndex = 1, GetNumBindings() do
		local action, cat, binding1, binding2 = GetBinding(bindingIndex);
		if not cat then
			tinsert(bindingsCategories[BINDING_HEADER_OTHER].bindings, {bindingIndex, action});
		else
			cat = securecallfunction(GetBindingCategoryName, cat);
			AddBindingCategory(cat);

			if strsub(action, 1, 6) == "HEADER" then
				tinsert(bindingsCategories[cat].bindings, KeybindingSpacer);
			else
				tinsert(bindingsCategories[cat].bindings, {bindingIndex, action});
			end
		end
	end

	local sortedCategories = {};

	for cat, bindingCategory in pairs(bindingsCategories) do
		sortedCategories[bindingCategory.order] = {cat = cat, bindings = bindingCategory.bindings, requiredSettingName = bindingCategory.requiredSettingName, expanded = bindingCategory.expanded};
	end

	for _, categoryInfo in ipairs(sortedCategories) do
		if #(categoryInfo.bindings) > 0 then
			layout:AddInitializer(CreateKeybindingSectionInitializer(categoryInfo.cat, categoryInfo.bindings, categoryInfo.requiredSettingName, categoryInfo.expanded));
            
		end
	end
    
    --layout:AddInitializer(CreateKeybindingSectionInitializer('bbb', {{ GetNumBindings()+1, 'WOWTOOLS'}}, 'wowtoolMount', false));
	
	-- Keybindings (search + redirectCategory)
	CreateSearchableSettings(category);
end
]]








--[[

]]

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            addName= '|A:hud-microbutton-Mounts-Down:0:0|a'..(e.onlyChinese and '坐骑' or MOUNT)
            --旧数据
            if WoWToolsSave[MOUNT] then
                Save= WoWToolsSave[MOUNT]
                Save.Point=nil
                WoWToolsSave[MOUNT]=nil
                for spellID, tab in pairs(Save.Mounts[FLOOR]) do
                    if type(tab)~='table' then
                        Save.Mounts[FLOOR][spellID]=nil
                    end
                end
                Save.mountShowTime= 3
                WoWToolsSave['Tools_Mount']=nil
            else
                Save= WoWToolsSave['Tools_Mounts'] or Save
            end


            if not Save.Mounts[SPELLS] then--为不同语言，
                Save.Mounts={
                    [ITEMS]={[174464]=true, [168035]=true},--幽魂缰绳 噬渊鼠缰绳
                    [SPELLS]=P_Spells_Tab,
                    [FLOOR]={},--{[spellID]=uiMapID}
                    [MOUNT_JOURNAL_FILTER_GROUND]={[256123]=true,},
                    [MOUNT_JOURNAL_FILTER_FLYING]={[419345]=true},
                    [MOUNT_JOURNAL_FILTER_AQUATIC]={[98718]=true},
                    [MOUNT_JOURNAL_FILTER_DRAGONRIDING]={[368896]=true},
                    ['Shift']={[64731]=true},
                    ['Alt']={[264058]=true,},
                    ['Ctrl']={[107203]=true,},
                }
            end

            MountButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='Mount',
                tooltip=addName,
            })



            if MountButton then

                Init()--初始

                self:RegisterEvent('PLAYER_REGEN_DISABLED')
                self:RegisterEvent('PLAYER_REGEN_ENABLED')
                self:RegisterEvent('SPELLS_CHANGED')
                self:RegisterEvent('SPELL_DATA_LOAD_RESULT')
                self:RegisterEvent('BAG_UPDATE_DELAYED')
                self:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')
                self:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
                self:RegisterEvent('NEW_MOUNT_ADDED')
                self:RegisterEvent('MODIFIER_STATE_CHANGED')
                self:RegisterEvent('ZONE_CHANGED')
                self:RegisterEvent('ZONE_CHANGED_INDOORS')
                self:RegisterEvent('ZONE_CHANGED_NEW_AREA')
                self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                self:RegisterEvent('SPELL_UPDATE_USABLE')
                self:RegisterEvent('PET_BATTLE_CLOSE')
                self:RegisterUnitEvent('UNIT_EXITED_VEHICLE', "player")

                self:RegisterEvent('PLAYER_STOPPED_MOVING')
                self:RegisterEvent('PLAYER_STARTED_MOVING')--设置, TOOLS 框架,隐藏

                self:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')--ShiJI
                self:RegisterEvent('LEARNED_SPELL_IN_TAB')--OkMount


            else
                self:UnregisterEvent('ADDON_LOADED')
            end

        elseif arg1=='Blizzard_Collections' then
            Init_MountJournal()

        elseif arg1=='Blizzard_PlayerSpells' then--法术书
            hooksecurefunc(SpellBookItemMixin, 'UpdateVisuals', function(frame)
                set_Use_Spell_Button(frame.Button, frame.spellBookItemInfo.spellID)
            end)

        end

    elseif event=='PLAYER_REGEN_DISABLED' then
            setClickAtt()--设置属性

    elseif event=='PLAYER_REGEN_ENABLED' then
        if MountButton.Combat then
            C_Timer.After(0.3, function()
                setClickAtt()--设置属性
                setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
                MountButton.Combat=nil
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Tools_Mounts']= Save
        end

    elseif event=='SPELLS_CHANGED' or event=='SPELL_DATA_LOAD_RESULT' then
        checkSpell()--检测法术
        XDInt()--德鲁伊设置
        checkMount()--检测坐骑
        setClickAtt()--设置属性   

    elseif event=='BAG_UPDATE_DELAYED' then
        checkItem()--检测物品

    elseif event=='NEW_MOUNT_ADDED' then
        checkMount()--检测坐骑

    elseif event=='ZONE_CHANGED' or event=='ZONE_CHANGED_INDOORS' or event=='ZONE_CHANGED_NEW_AREA' then
        if not XD then
            checkMount()--检测坐骑
        end
    elseif event=='MOUNT_JOURNAL_USABILITY_CHANGED'
        or event=='PLAYER_MOUNT_DISPLAY_CHANGED'
        or event=='PET_BATTLE_CLOSE'
        or event=='UNIT_EXITED_VEHICLE'
        or event=='PLAYER_STOPPED_MOVING'
        or event=='PLAYER_STARTED_MOVING'
    then-- or event=='AREA_POIS_UPDATED' then
        setClickAtt()--设置属性

    elseif event=='MODIFIER_STATE_CHANGED' then
        local icon
        if arg2==1 then
            icon = arg1:find('SHIFT') and MountButton.textureModifier.Shift
                or arg1:find('CTRL') and MountButton.textureModifier.Ctrl
                or arg1:find('ALT') and MountButton.textureModifier.Alt
        end
        if icon then
            MountButton.textureModifier:SetTexture(icon)
        end
        MountButton.textureModifier:SetShown(icon)

    elseif event=='SPELL_UPDATE_COOLDOWN' then
        e.SetItemSpellCool(MountButton, {item=MountButton.itemID, spell=MountButton.spellAtt})--设置冷却

    elseif event=='SPELL_UPDATE_USABLE' then
        setTextrue()--设置图标




    elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
        MountButton:settings()

    elseif event=='LEARNED_SPELL_IN_TAB' then
        set_OkMout()
    end
end)