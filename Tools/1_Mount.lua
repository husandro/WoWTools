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
            --[163024]=true,--战火梦魇兽
            --[366962]=true,--[艾什阿达，晨曦使者]
            --[107203]=true,--泰瑞尔的天使战马
            [419345]=true,--伊芙的森怖骑行扫帚
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
            --[118089]=true,--天蓝水黾
            --[127271]=true,--猩红水黾
            [107203]=true,--泰瑞尔的天使战马
         },
    },
    --XD= true,
    KEY= e.Player.husandro and 'BUTTON5', --为我自定义, 按键
    AFKRandom=e.Player.husandro,--离开时, 随机坐骑
    mountShowTime=3,--坐骑秀，时间
    showFlightModeButton=true, --切换飞行模式
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












local function setKEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(MountButton, true, Save.KEY)
        if #Save.KEY==1 then
            if not MountButton.KEY then
                MountButton.KEYstring=e.Cstr(MountButton,{size=10, color=true})--10, nil, nil, true, 'OVERLAY')
                MountButton.KEYstring:SetPoint('BOTTOMRIGHT', MountButton.border, 'BOTTOMRIGHT',-4,4)
            end
            MountButton.KEYstring:SetText(Save.KEY)
            if MountButton.KEYtexture then
                MountButton.KEYtexture:SetShown(false)
            end
        else
            if not MountButton.KEYtexture then
                MountButton.KEYtexture=MountButton:CreateTexture(nil,'OVERLAY')
                MountButton.KEYtexture:SetPoint('BOTTOM', MountButton.border,'BOTTOM',-1,-5)
                MountButton.KEYtexture:SetAtlas('NPE_ArrowDown')
                MountButton.KEYtexture:SetDesaturated(true)
                MountButton.KEYtexture:SetSize(20,15)
            end
            MountButton.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(MountButton)
        if MountButton.KEYstring then
            MountButton.KEYstring:SetText('')
        end
        if MountButton.KEYtexture then
            MountButton.KEYtexture:SetShown(false)
        end
    end
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
            or ((isAdvancedFlyableArea or C_Spell.IsSpellUsable(368896)) and getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING))-- [368896]=true,--[复苏始祖幼龙]
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
        --name, _, icon=GetSpellInfo(spellID)
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
            e.LoadDate({id=spellID, type='spell'})
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


































--#############
--初始化，对话框
--#############
local function Init_Dialogs()
    StaticPopupDialogs['WoWTools_Tools_Mount_ITEMS']={--物品, 设置对话框
        text=id..' '..addName..' '..(e.onlyChinese and '物品' or ITEMS)..'|n|n%s|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, itemID)
            self.button3:SetEnabled(Save.Mounts[ITEMS][itemID] and true or false)
            self.button1:SetEnabled(not Save.Mounts[ITEMS][itemID] and true or false)
        end,
        OnAccept = function(self, itemID)
            Save.Mounts[ITEMS][itemID]=true
            checkItem()--检测物品
            setClickAtt()--设置 Click属性
        end,
        OnAlt = function(self, itemID)
            Save.Mounts[ITEMS][itemID]=nil
            checkItem()--检测物品
            setClickAtt()--设置 Click属性
        end,
    }

    StaticPopupDialogs['WoWTools_Tools_Mount_SPELLS']={--法术, 设置对话框
        text=id..' '..addName..' '..(e.onlyChinese and '法术' or SPELLS)..'|n|n%s|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        OnShow = function(self, data)
            self.button3:SetEnabled(Save.Mounts[SPELLS][data.spellID] and true or false)
            self.button1:SetEnabled(not Save.Mounts[SPELLS][data.spellID] and true or false)
        end,
        OnAccept = function(_, data)
            Save.Mounts[SPELLS][data.spellID]=true
            checkItem()--检测物品
            setClickAtt()--设置 Click属性
        end,
    }

    StaticPopupDialogs['WoWTools_Tools_Mount_Key']={--快捷键,设置对话框
        text=id..' '..addName..'|n'..(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)..'|n|nQ, BUTTON5',
        whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
        button1= e.onlyChinese and '设置' or SETTINGS,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self2)
            self2.editBox:SetText(Save.KEY or 'BUTTON5')
            if Save.KEY then
                self2.button1:SetText(e.onlyChinese and '修改' or EDIT)
            end
            self2.button3:SetEnabled(Save.KEY)
        end,
        OnHide= function(s)
            s.editBox:ClearFocus()
        end,
        OnAccept = function(self2)
            local text= self2.editBox:GetText()
            text=text:gsub(' ','')
            text=text:gsub('%[','')
            text=text:gsub(']','')
            text=text:upper()
            Save.KEY=text
            setKEY()--设置捷键
        end,
        OnAlt = function()
            Save.KEY=nil
            setKEY()--设置捷键
        end,
        EditBoxOnTextChanged=function(self2)
            local text= self2:GetText()
            text=text:gsub(' ','')
            self2:GetParent().button1:SetEnabled(text~='')
        end,
        EditBoxOnEscapePressed = function(s)
           s:ClearFocus()
        end,
    }

    local function Get_UIMapIDs_Name(text)--从text取得uiMapID表
        local tab, reText={}, nil
        text:gsub('%d+', function(self)
            local uiMapID= tonumber(self)
            local info= uiMapID and C_Map.GetMapInfo(uiMapID)
            if uiMapID and info and info.name and not tab[uiMapID] then--uiMapID<2147483647
                tab[uiMapID]=true
                reText= reText and reText..'|n' or ''
                reText= reText..uiMapID..' '..e.cn(info.name)
            end
        end)
        return tab, reText
    end

    StaticPopupDialogs['WoWTools_Tools_Mount_FLOOR'] = {--区域,设置对话框
        text=id..' '..addName..' '..(e.onlyChinese and '区域' or FLOOR)..'|n|n%s|n|n|cnGREEN_FONT_COLOR:%s|r',
        whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox= true,
        button1=e.onlyChinese and '区域' or FLOOR,
        button2=e.onlyChinese and '取消' or CANCEL,
        button3=e.onlyChinese and '移除' or REMOVE,
        OnShow = function(s, data)
            s.editBox:SetAutoFocus(false)
            s.editBox:ClearFocus()
            local text
            text= ''
            local tab= Save.Mounts[FLOOR][data.spellID] or {}
            for uiMapID, _ in pairs(tab) do
                text= text..uiMapID..', '
            end
            if text=='' then
                text= C_Map.GetBestMapForUnit("player") or text
                text= text..', '
            end
            s.editBox:SetText(text)
            s.button3:SetEnabled(Save.Mounts[FLOOR][data.spellID] and true or false)
        end,
        OnAccept = function(s, data)
            local tab, text= Get_UIMapIDs_Name(s.editBox:GetText())
            print(
                '|cnGREEN_FONT_COLOR:', e.cn(data.name, {spellID=data.spellID, isName=true}), 'spellID:', data.spellID, 'mountID:', data.mountID,
                ':|r|n|cffff00ff', text, '|r|n',
                id, WoWTools_ToolsButtonMixin:GetName(), addName
            )

            Save.Mounts[FLOOR][data.spellID]= tab
            checkMount()--检测坐骑
            setClickAtt()--设置 Click属性
            if MountJournal_UpdateMountList then e.call('MountJournal_UpdateMountList') end
        end,
        OnHide= function(s)
            s.editBox:ClearFocus()
        end,
        OnAlt = function(_, data)
            Save.Mounts[FLOOR][data.spellID]=nil
            checkMount()--检测坐骑
            setClickAtt()--设置 Click属性
            if MountJournal_UpdateMountList then e.call('MountJournal_UpdateMountList') end
        end,
        EditBoxOnTextChanged=function(s)
            local _, text= Get_UIMapIDs_Name(s:GetText())
            local btn=s:GetParent().button1
            btn:SetEnabled(text and true or false)
            btn:SetText(text or (e.onlyChinese and '无' or NONE))
        end,
        EditBoxOnEscapePressed = function(s)
            s:ClearFocus()
        end,
    }
end






















--C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
--C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,false)
--C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE,false)


--坐骑秀
function Init_Mount_Show()
    MountShowFrame=CreateFrame('Frame', nil, MountButton)
    MountShowFrame:SetAllPoints()
    MountShowFrame:Hide()

    function MountShowFrame:get_mounts()--得到，有效坐骑，表
        WoWTools_ToolsButtonMixin:LoadedCollectionsJournal()
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

            e.Ccool(self, nil, Save.mountShowTime)--冷却条
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
































--##################
--打开界面, 收藏, 坐骑
--##################
local function set_ToggleCollectionsJournal(mountID, type, showNotCollected)
    WoWTools_ToolsButtonMixin:LoadedCollectionsJournal()

    if MountJournal and not MountJournal:IsVisible() then
        ToggleCollectionsJournal(1)
    end
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
end






































local function Set_Item_Edit(data)
    StaticPopup_Show(
        'WoWTools_Tools_Mount_ITEMS',
        data.name,
        Save.Mounts[ITEMS][data.itemID] and (e.onlyChinese and '物品已存在' or ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS)) or (e.onlyChinese and '新建' or NEW),
        data.itemID
    )
end










local function Set_Menu_Tooltip(tooltip, desc)
    if desc.data.mountID then
        local isUsable2, useError = C_MountJournal.GetMountUsabilityByID(desc.data.mountID, true)
        if useError then
            GameTooltip_AddErrorLine(tooltip, e.cn(useError))
        elseif isUsable2 then
            GameTooltip_AddNormalLine(tooltip, e.onlyChinese and '召唤' or SUMMON)
        end
    elseif desc.data.spellID then
        tooltip:SetSpellByID(desc.data.spellID)
    elseif desc.data.itemID then
        tooltip:SetItemByID(desc.data.itemID)
    end
    if desc.data.type==FLOOR then
        for uiMapID, _ in pairs(Save.Mounts[FLOOR][desc.data.spellID] or {}) do
            local mapInfo = C_Map.GetMapInfo(uiMapID)
            tooltip:AddDoubleLine('uiMapID '..uiMapID, mapInfo and e.cn(mapInfo.name))
        end
    end
end







local function ClearAll_Menu(root, type, index)
    if index>1 then
        root:CreateDivider()
        local sub=root:CreateButton(e.onlyChinese and '全部清除' or CLEAR_ALL, function(data)
            if IsControlKeyDown() then
                Save.Mounts[data]={}
                print(id, addName, e.onlyChinese and '全部清除' or CLEAR_ALL, e.cn(type))
                if not UnitAffectingCombat('player') then
                    MountButton:settings()
                end
            else
                return MenuResponse.Open
            end
        end, type)
        sub:SetTooltip(function(tooltip, desc)
            tooltip:AddLine(e.cn(desc.data))
            tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
        end)
    end
    if index>35 then
        root:SetGridMode(MenuConstants.VerticalGridDirection, math.ceil(index/35))
    end
end






local function Set_Mount_Menu(root, type, spellID, name, index)
    local mountID= spellID and C_MountJournal.GetMountFromSpell(spellID)

    local creatureName, isUsable, _, isCollected, col
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

    local icon= '|T'..(spellID and C_Spell.GetSpellTexture(spellID) or 0)..':0|t'

    local sub=root:CreateButton(
        (index and index..') ' or '')
        ..icon
        ..col
        ..name,
    function(data)
        if data.mountID then
            C_MountJournal.SummonByID(data.mountID)
        end

        return MenuResponse.Open
    end, {spellID=spellID, mountID=mountID, type=type})

    sub:SetTooltip(Set_Menu_Tooltip)

    if index and mountID then
        local sub2=sub:CreateButton('|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE), function(data)
            Save.Mounts[data.type][data.spellID]=nil
            print(id, addName, e.onlyChinese and '移除' or REMOVE, C_Spell.GetSpellLink(data.spellID) or data.spellID)

            if not UnitAffectingCombat('player') then
                MountButton:settings()
            end

            return MenuResponse.Refresh
        end, {type=type, spellID=spellID})
        sub2:SetTooltip(Set_Menu_Tooltip)

        sub:CreateDivider()
        if type==FLOOR then
            sub2=sub:CreateButton(icon..(e.onlyChinese and '修改' or EDIT), function(data)
                StaticPopup_Show('WoWTools_Tools_Mount_FLOOR',
                    '|T'..(data.icon or 0)..':0|t'.. (e.cn(data.name, {spellID=data.spellID, isName=true}) or ('spellID: '..data.spellID)),

                    (Save.Mounts[FLOOR][data.spellID] and
                        (e.onlyChinese and '已存在' or format(ERR_ZONE_EXPLORED, PROFESSIONS_CURRENT_LISTINGS))
                        or (e.onlyChinese and '新建' or NEW)
                    )..'|n|n uiMapID: '..(C_Map.GetBestMapForUnit("player") or ''),

                    data
                )
            end, {spellID=spellID, icon=icon, name=name})
            sub2:SetTooltip(Set_Menu_Tooltip)
        end

        sub2=sub:CreateButton('|A:common-icon-zoomin:0:0|a'..(e.onlyChinese and '设置' or SETTINGS), function(data)
            set_ToggleCollectionsJournal(data.mountID, data.type)--打开界面, 收藏, 坐骑, 不过滤类型
            return MenuResponse.Open
        end, {mountID=mountID, type=type})
        sub2:SetTooltip(function(tooltip)
            tooltip:AddLine(MicroButtonTooltipText(e.onlyChinese and '战团藏品' or COLLECTIONS, "TOGGLECOLLECTIONS"))
        end)
    end
    return sub
end
















function Init_Menu_Mount(root, type, name)
    local tab2=MountTab[type] or {}
    e.LoadDate({id=tab2[1], type='spell'})
    local num=getTableNum(type)--检测,表里的数量
    local col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

    local sub= Set_Mount_Menu(root, type, tab2[1], (e.onlyChinese and name or e.cn(type))..' '..col..num, nil)


    local index=0
    for spellID, _ in pairs(Save.Mounts[type] or {}) do
        e.LoadDate({id=spellID, type='spell'})
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end









local function Init_Menu_ShiftAltCtrl(root, type)
    local tab2=MountTab[type] or {}
    e.LoadDate({id=tab2[1], type='spell'})
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
        e.LoadDate({id=spellID, type='spell'})
        index= index +1
        Set_Mount_Menu(sub, type, spellID, nil, index)
    end

    ClearAll_Menu(sub, type, index)
end















local function Init_Menu_Spell(sub)
    local sub2, sub3, icon, col
    local index=0
    for spellID, _ in pairs(Save.Mounts[SPELLS]) do
        e.LoadDate({id=spellID, type='spell'})
        index= index+1


        icon='|T'..(C_Spell.GetSpellTexture(spellID) or 0)..':0|t'
        col= (IsSpellKnownOrOverridesKnown(spellID) and '' or '|cff9e9e9e')

        sub2=sub:CreateButton(
            index..') '
            ..col
            ..icon
            ..(e.cn(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or ('spellID: '..spellID)),
        function()
            return MenuResponse.Open
        end, {spellID=spellID})
        sub2:SetTooltip(Set_Menu_Tooltip)

        sub3=sub2:CreateButton('|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE), function(data)
            Save.Mounts[SPELLS][data.spellID]=nil
            print(id, addName, e.onlyChinese and '移除' or REMOVE, C_Spell.GetSpellLink(data.spellID) or data.spellID)
            return MenuResponse.Close
        end, {spellID=spellID})
        sub3:SetTooltip(Set_Menu_Tooltip)
    end

    ClearAll_Menu(sub, SPELLS, index)

    sub2=sub:CreateButton(e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT, function()
        if IsControlKeyDown() then
            Save.Mounts[SPELLS]=P_Spells_Tab
            print(id, addName, '|cnGREEN_FONT_COLOR:', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT)
            checkSpell()--检测法术
            setClickAtt()--设置
        else
            return MenuResponse.Open
        end
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine('|cnGREEN_FONT_COLOR:Ctrl+'..e.Icon.left)
    end)

    sub2=sub:CreateTitle(e.onlyChinese and '拖曳法术' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DRAG_MODEL, SPELLS))
    sub2:SetTooltip(function (tooltip)
        tooltip:AddDoubleLine(e.onlyChinese and '添加' or ADD)
    end)
end













local function Init_Menu_Item(sub)
    local sub2, sub3, num, icon, col
    local index= 0
    for itemID, _ in pairs(Save.Mounts[ITEMS]) do
        e.LoadDate({id=itemID, type='item'})
        index= index+1

        icon='|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
        num= C_Item.GetItemCount(itemID, false, true, true) or 0

        local name= '|T'..(C_Item.GetItemIconByID(itemID) or 0)..':0|t'
                    ..(e.cn(C_Item.GetItemNameByID(itemID), {itemID=itemID, isName=true}) or ('itemID: '..itemID))
                    ..(num==0 and '|cff9e9e9e' or '|cffffffff')..' x'..num..'|r'

        sub2=sub:CreateButton(
            index..') '..name,
            Set_Item_Edit,
            {itemID=itemID, name=name}
        )
        sub2:SetTooltip(Set_Menu_Tooltip)

        sub3=sub2:CreateButton(icon..(e.onlyChinese and '修改' or EDIT), Set_Item_Edit, {itemID=itemID, name=name})
        sub3:SetTooltip(Set_Menu_Tooltip)

        sub2:CreateDivider()
        sub3=sub2:CreateButton('|A:common-icon-redx:0:0|a'..(e.onlyChinese and '移除' or REMOVE), function(data)
            Save.Mounts[ITEMS][data.itemID]=nil
            print(id, addName, select(2, C_Item.GetItemInfo(data.itemID)) or data.itemID, e.onlyChinese and '移除' or REMOVE)
            return MenuResponse.Close
        end, {itemID=itemID})
        sub3:SetTooltip(Set_Menu_Tooltip)
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
            local data={}
            local icon
            if indexType==SPELLS then
                if MountButton.spellID then
                    data.spellID=MountButton.spellID
                    icon= C_Spell.GetSpellTexture(MountButton.spellID)
                end
            elseif indexType==ITEMS then
                if MountButton.itemID then
                    data.itemID=MountButton.itemID
                    icon=C_Item.GetItemIconByID(MountButton.itemID)
                end
            end
            icon= icon or 0
            num=getTableNum(indexType)--检测,表里的数量
            col= num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'

            sub=root:CreateButton('|T'..icon..':0|t'..(e.onlyChinese and tab.name or indexType).. col..' '.. num..'|r', function()
                return MenuResponse.Open
            end, data)
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
    sub=WoWTools_ToolsButtonMixin:OpenMenu(root, addName, Save.KEY)

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
            e.SendText(SLASH_CHAT_AFK1)
        end
    end)
    sub3:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(SLASH_CHAT_AFK1)
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
        e.SendText(SLASH_CHAT_AFK1)
        return MenuResponse.Open
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddDoubleLine(SLASH_CHAT_AFK1)
    end)

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

    sub:CreateSpacer()
    --sub:CreateDivider()
    sub2=sub:CreateCheckbox('|A:NPE_ArrowDown:0:0|a'..(Save.KEY or (e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL)), function()
        return Save.KEY
    end, function()
        StaticPopup_Show('WoWTools_Tools_Mount_Key')
    end)
    sub2:SetTooltip(function(tooltip)
        tooltip:AddLine(e.onlyChinese and '设置' or SETTINGS)
        tooltip:AddDoubleLine(e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL, Save.KEY)
    end)

    WoWTools_MenuMixin:RestDataMenu(sub,
        addName..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
        function()
            Save=nil
            e.Reload()
        end
    )
end









































--界面，菜单
local function Init_UI_Menu(self, root)
    if UnitAffectingCombat('player') then
        root:CreateTitle(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT)
        return
    end

    local frame= self:GetParent()
    local mountID = frame.mountID

    if not mountID then
        root:CreateTitle((e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE)..' mountID')
        return
    end

    local name, spellID, icon, _, _, _, _, isFactionSpecific, faction, shouldHideOnChar, isCollected, _, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)
    spellID= spellID or self.spellID

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

        local SetValue
        if type==FLOOR then
            function SetValue(data)
                StaticPopup_Show('WoWTools_Tools_Mount_FLOOR',
                    '|T'..(data.icon or 0)..':0|t'.. (e.cn(data.name, {spellID=data.spellID, isName=true}) or ('spellID: '..data.spellID)),

                    (Save.Mounts[FLOOR][data.spellID] and
                        (e.onlyChinese and '已存在' or format(ERR_ZONE_EXPLORED, PROFESSIONS_CURRENT_LISTINGS))
                        or (e.onlyChinese and '新建' or NEW)
                    )..'|n|n uiMapID: '..(C_Map.GetBestMapForUnit("player") or ''),

                    data
                )
            end
        else
            function SetValue(tab)
                if Save.Mounts[tab.type][tab.spellID] then
                    Save.Mounts[tab.type][tab.spellID]=nil
                else
                    if tab.type=='Shift' or tab.type=='Alt' or tab.type=='Ctrl' then--唯一
                        Save.Mounts[tab.type]={[tab.spellID]=true}
                    else
                        Save.Mounts[tab.type][tab.spellID]=true
                    end
                    removeTable(tab.type, tab.spellID)--移除, 表里, 其他同样的项目
                end
                checkMount()--检测坐骑
                setClickAtt()--设置属性
                setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
                e.call('MountJournal_UpdateMountList')
            end
        end

        sub=root:CreateCheckbox(col..(e.onlyChinese and '设置' or SETTINGS)..' '..e.cn(type)..' #|cnGREEN_FONT_COLOR:'..getTableNum(type),
            GetValue,
            SetValue,
            {type=type, spellID=spellID, mountID=mountID, name=name, icon=icon, GetValue=GetValue}
        )

        if type==FLOOR then
            sub:SetTooltip(function(tooltip, description)
                for uiMapID,_ in pairs(Save.Mounts[FLOOR][description.data.spellID] or {}) do
                    local mapInfo= C_Map.GetMapInfo(uiMapID)
                    tooltip:AddDoubleLine('uiMapID '..uiMapID, mapInfo and e.cn(mapInfo.name))
                end
            end)
        end
    end

    root:CreateDivider()
    root:CreateTitle('|T'..(icon or 0)..':0|t'..e.cn(name, {spellID=spellID, isName=true}))
    WoWTools_ToolsButtonMixin:OpenMenu(root, addName)
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
    e.call('MountJournal_SetUnusableFilter',true)
    e.call('MountJournal_FullUpdate', MountJournal)
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
            frame.WoWToolsButton=e.Cbtn(frame, {icon=true, size={22,22}})
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
            frame.WoWToolsText=e.Cstr(frame, {justifyH='RIGHT'})--nil, frame.name, nil,nil,nil,'RIGHT')
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
        MountJournal.MountDisplay.tipsMenu= e.Cbtn(MountJournal.MountDisplay, {icon=true, size={22,22}})
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
        e.call('MountJournal_SetUnusableFilter',true)
        e.call('MountJournal_FullUpdate', MountJournal)
        self:Hide()
        self:GetParent():rest_type()
    end)

    MountJournal.MountCount:ClearAllPoints()
    MountJournal.MountCount:SetPoint('BOTTOMRIGHT', MountJournalSearchBox, 'TOPRIGHT', 0, 4)


    btn:rest_type()
    btn:set_text()
    btn:SetupMenu(Init_UI_List_Menu)--过滤，列表，菜单    
end














--436854 C_MountJournal.GetDynamicFlightModeSpellID() 切换飞行模式











--######
--初始化
--######
local function Init()


    for type, tab in pairs(Save.Mounts) do
        for ID, _ in pairs(tab) do
            e.LoadDate({id=ID, type= type==ITEMS and 'item' or 'spell'})
        end
    end

    MountButton:SetAttribute("type1", "spell")
    MountButton:SetAttribute("alt-type1", "spell")
    MountButton:SetAttribute("shift-type1", "spell")
    MountButton:SetAttribute("ctrl-type1", "spell")
    MountButton:SetFrameStrata('HIGH')

    MountButton.textureModifier=MountButton:CreateTexture(nil,'OVERLAY')--提示 Shift, Ctrl, Alt
    MountButton.textureModifier:SetAllPoints(MountButton.texture)
    MountButton.textureModifier:AddMaskTexture(MountButton.mask)

    MountButton.textureModifier:SetShown(false)

    MountButton.Up=MountButton:CreateTexture(nil,'OVERLAY')
    MountButton.Up:SetPoint('TOP',-1, 9)
    MountButton.Up:SetAtlas('NPE_ArrowUp')
    MountButton.Up:SetSize(20,20)





    if Save.KEY then
        setKEY()--设置捷键
    end







    MountButton:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID then
            local exits=Save.Mounts[ITEMS][itemID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
            local icon = C_Item.GetItemIconByID(itemID)
            local text= (icon and '|T'..icon..':0|t' or '').. (itemLink or ('itemID: '..itemID))
            StaticPopup_Show('WoWTools_Tools_Mount_ITEMS',text, exits, itemID)
            ClearCursor()
            return
        elseif infoType =='spell' and spellID then
            local exits=Save.Mounts[SPELLS][spellID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
            local icon = C_Spell.GetSpellTexture(spellID)
            local text= (icon and '|T'..icon..':0|t' or '').. (C_Spell.GetSpellLink(spellID) or ('spellID: '..spellID))
            StaticPopup_Show('WoWTools_Tools_Mount_SPELLS',text, exits , {spellID=spellID})
            ClearCursor()
            return

        elseif d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

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
        ResetCursor()
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

        if self.typeID then
            if self.typeSpell then
                e.tips:SetSpellByID(self.typeID)
            else
                e.tips:SetItemByID(self.typeID)
            end
            e.tips:AddLine(' ')
        end

        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID then
            local exits=Save.Mounts[ITEMS][itemID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
            local icon = C_Item.GetItemIconByID(itemID)
            local text= (icon and '|T'..icon..':0|t' or '').. (itemLink or ('itemID: '..itemID))
            e.tips:AddDoubleLine(text, exits..e.Icon.left, 0,1,0, 0,1,0)
            e.tips:AddLine(' ')
        elseif infoType =='spell' and spellID then
            local exits=Save.Mounts[SPELLS][spellID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
            local icon = C_Spell.GetSpellTexture(spellID)
            local text= (icon and '|T'..icon..':0|t' or '').. (C_Spell.GetSpellLink(spellID) or ('spellID: '..spellID))
            e.tips:AddDoubleLine(text, exits..e.Icon.left, 0,1,0, 0,1,0)
            e.tips:AddLine(' ')
        end

        e.tips:AddLine('')
        e.tips:AddDoubleLine(e.onlyChinese and '坐骑秀' or 'Mount show', '|A:bags-greenarrow:0:0|a')
        e.tips:AddDoubleLine(e.onlyChinese and '坐骑特效' or EMOTE171_CMD2:gsub('/',''), '|A:UI-HUD-MicroMenu-StreamDLYellow-Up:0:0|a')

        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)

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
        WoWTools_ToolsButtonMixin:EnterShowFrame()

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
    Init_Dialogs()--初始化，对话框
    Init_Mount_Show()--坐骑秀

    C_Timer.After(4, function()
        if not UnitAffectingCombat('player') then
            setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
            setClickAtt()--设置
            e.SetItemSpellCool(MountButton, {item=MountButton.itemID, spell=MountButton.spellAtt})--设置冷却
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


            MountButton= WoWTools_ToolsButtonMixin:CreateButton({
                name='Mount',
                tooltip=addName,
                setParent=false,
                point='LEFT',
                --option=function(category, layout)--initializer
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