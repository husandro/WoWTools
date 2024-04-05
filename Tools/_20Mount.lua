local id, e = ...
local addName= MOUNT

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

local Save={
    --disabled= not e.Player.husandro,
    Mounts={
        [ITEMS]={[174464]=true, [168035]=true},--幽魂缰绳 噬渊鼠缰绳
        [SPELLS]={
            [2645]=true,
            [111400]=true,
            [343016]=true,
            [195072]=true,
            [2983]=true,
            [190784]=true,
            [48265]=true,
            [186257]=true,
            [6544]=true,
            [358267]= true,--悬空
            [212653]= true,
        },
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
        Shift={
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
        Alt={[264058]=true,--雄壮商队雷龙
            [122708]=true,--雄壮远足牦牛
            [61425]=true,--旅行者的苔原猛犸象
        },
        Ctrl={
            --[118089]=true,--天蓝水黾
            --[127271]=true,--猩红水黾
            [107203]=true,--泰瑞尔的天使战马
         },
    },
    XD= true,
    KEY= e.Player.husandro and 'BUTTON5', --为我自定义, 按键
    --AFKRandom=e.Player.husandro,--离开时, 随机坐骑
}

local panel= CreateFrame("Frame")
local button
local Faction =  e.Player.faction=='Horde' and 0 or e.Player.faction=='Alliance' and 1
local ShiJI= e.Player.faction==0 and 179244 or e.Player.faction=='Alliance' and 179245
local OkMount--是否已学, 骑术
local XD

e.LoadDate({id=179244, type= 'spell'})
e.LoadDate({id=179245, type= 'spell'})
e.LoadDate({id=90265, type= 'spell'})
e.LoadDate({id=33391, type= 'spell'})
e.LoadDate({id=34090, type= 'spell'})
e.LoadDate({id=34090, type= 'spell'})


local MountType={
    MOUNT_JOURNAL_FILTER_GROUND,
    MOUNT_JOURNAL_FILTER_AQUATIC,
    MOUNT_JOURNAL_FILTER_FLYING,
    MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    'Shift', 'Alt', 'Ctrl',
    FLOOR,
}



















local function set_Button_Postion()--设置按钮位置
    if not button then
        return
    end
    button:ClearAllPoints()
    if Save.Point and Save.Point[1] and Save.Point[3] and Save.Point[4] and Save.Point[5] then
        button:SetPoint(Save.Point[1], UIParent, Save.Point[3], Save.Point[4], Save.Point[5])
    elseif e.Player.husandro then
        button:SetPoint('RIGHT', QueueStatusButton, 'LEFT')
    else
        button:SetPoint('CENTER', 300, 100)
    end
end

local function setKEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(button, true, Save.KEY)
        if #Save.KEY==1 then
            if not button.KEY then
                button.KEYstring=e.Cstr(button,{size=10, color=true})--10, nil, nil, true, 'OVERLAY')
                button.KEYstring:SetPoint('BOTTOMRIGHT', button.border, 'BOTTOMRIGHT',-4,4)
            end
            button.KEYstring:SetText(Save.KEY)
            if button.KEYtexture then
                button.KEYtexture:SetShown(false)
            end
        else
            if not button.KEYtexture then
                button.KEYtexture=button:CreateTexture(nil,'OVERLAY')
                button.KEYtexture:SetPoint('BOTTOM', button.border,'BOTTOM',-1,-5)
                button.KEYtexture:SetAtlas('NPE_ArrowDown')
                button.KEYtexture:SetDesaturated(true)
                button.KEYtexture:SetSize(20,15)
            end
            button.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(button)
        if button.KEYstring then
            button.KEYstring:SetText('')
        end
        if button.KEYtexture then
            button.KEYtexture:SetShown(false)
        end
    end
end
local function XDInt()--德鲁伊设置
    XD=nil
    if Save.XD and e.Player.class=='DRUID' then
        local ground=IsSpellKnown(768) and 768
        local flying=IsSpellKnown(783) and 783
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
    button.spellID=nil
    if XD and XD[MOUNT_JOURNAL_FILTER_GROUND] then
        button.spellID=XD[MOUNT_JOURNAL_FILTER_GROUND]
    else
        for spellID, _ in pairs(Save.Mounts[SPELLS]) do
            if IsSpellKnown(spellID) then
                button.spellID=spellID
                break
            end
        end
    end
end
local function checkItem()--检测物品
    button.itemID=nil
    for itemID, _ in pairs(Save.Mounts[ITEMS]) do
        if C_Item.GetItemCount(itemID , false, true, true)>0 then
            button.itemID=itemID
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
        if IsUsableSpell(tab[index]) and not select(2, C_MountJournal.GetMountUsabilityByID(tab[index], true)) then
            return tab[index]
        end
    end
end
local function setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
    if UnitAffectingCombat('player') then
        button.Combat=true
        return
    end
    local tab={'Shift', 'Alt', 'Ctrl'}

    for _, type in pairs(tab) do
        button.textureModifier[type]=nil
        if MountTab[type] and MountTab[type][1] then
            local name, _, icon=GetSpellInfo(MountTab[type][1])
            --if name and icon then
                button:SetAttribute(type.."-spell1", name or MountTab[type][1])
                button.textureModifier[type]=icon
                button.typeSpell=true--提示用
                button.typeID=MountTab[type][1]
            --end
        end
    end
    button.Combat=nil
end


local function setTextrue()--设置图标
    local icon= button.iconAtt
    if IsMounted() then
        icon=136116
    elseif icon then
        local spellID= button.spellAtt or button.itemID and select(2, C_Item.GetItemSpell(button.itemID))
        local aura = spellID and C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        if aura and aura.spellId then
            icon=136116
        end
    end
    if icon then
        button.texture:SetTexture(icon)
    end
    button.texture:SetShown(icon and true or false)
    e.SetItemSpellCool({frame=button, item=button.itemID, spell=button.spellAtt})--设置冷却
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
    --if inCombat or UnitIsDeadOrGhost('player') or not button:CanChangeAttribute() then
    if not button:CanChangeAttribute() then
        button.Combat=true
        return
    end
    local isFlyableArea= IsFlyableArea()
    local spellID= (IsIndoors() or IsPlayerMoving()) and button.spellID--进入战斗, 室内
                    or getRandomRoll(FLOOR)--区域
                    or ((IsAdvancedFlyableArea() and isFlyableArea)and getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING))
                    or ((XD and IsUsableSpell(783)) and 783)
                    or (IsSubmerged() and getRandomRoll(MOUNT_JOURNAL_FILTER_AQUATIC))--水平中
                    or (isFlyableArea and getRandomRoll(MOUNT_JOURNAL_FILTER_FLYING))--飞行区域
                    or (IsOutdoors() and getRandomRoll(MOUNT_JOURNAL_FILTER_GROUND))--室外
                    or button.spellID
                    --or IsUsableSpell(368896) and C_MountJournal.GetMountUsabilityByID(1589, true) and getRandomRoll(MOUNT_JOURNAL_FILTER_DRAGONRIDING)

    if not spellID then
        button.Combat=true
        return
    end
    local name, _, icon
    if spellID then
        name, _, icon=GetSpellInfo(spellID)
        if name and icon then
            button:SetAttribute("type1", "spell")
            button:SetAttribute("spell1", name)
            button:SetAttribute('target1', 'mouseover')
            button.typeSpell=true--提示用
            button.typeID=spellID
        end
    elseif button.itemID then
        button:SetAttribute("type1", "item")
        button:SetAttribute("item1", C_Item.GetItemNameByID(button.itemID)  or button.itemID)
        button.typeID= MountTab[type][1]
        button.typeSpell=nil--提示用
        button.typeID=spellID
    else
        button:SetAttribute("item1", nil)
        button:SetAttribute("spell1", nil)
        button.typeSpell=nil--提示用
        button.typeID=nil
    end
    button.spellAtt=spellID
    button.iconAtt=icon
    setTextrue()--设置图标

    button.Combat=nil
end


















--#######
--坐骑展示
--#######
local function getMountShow()
    C_MountJournal.SetDefaultFilters()
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,false)
    --C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
    --C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED,false)
    --C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE,false)
    local num=C_MountJournal.GetNumDisplayedMounts()
    local n=1
    while n<num and button.showFrame:IsShown() and IsOutdoors() and not UnitIsDeadOrGhost('player') and not UnitAffectingCombat('player') and not IsPlayerMoving() do
        local _, _, _, isActive, isUsable, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(math.random(1, num));
        if not isActive and isUsable and mountID then
            C_MountJournal.SummonByID(mountID)
            return
        end
        n=n+1
    end
    button.showFrame:SetShown(false)
end

local specialEffects
local function setMountShow()--坐骑展示
    if UnitAffectingCombat('player') then
        specialEffects=nil
        print(id, e.cn(addName), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or COMBAT)..'|r')
        return
    elseif specialEffects and not IsMounted() then
        print(id, e.cn(addName), e.onlyChinese and '/坐骑特效' or EMOTE171_CMD2,
        '|cnRED_FONT_COLOR:'..(e.onlyChinese and '需要要坐骑' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, MOUNT)))
        specialEffects=nil
        return
    end


    print(id, e.cn(addName), specialEffects and (e.onlyChinese and '/坐骑特效' or EMOTE171_CMD2) or (e.onlyChinese and '坐骑' or MOUNT), '3 '..(e.onlyChinese and '秒' or SECONDS))
    if not button.showFrame then
        button.showFrame=CreateFrame('Frame')
        button.showFrame:HookScript('OnUpdate',function(self, elapsed)
            self.elapsed= (self.elapsed or 3) + elapsed
            if UnitAffectingCombat('player') or IsPlayerMoving() or UnitIsDeadOrGhost('player') then
                button.showFrame:SetShown(false)
                specialEffects=nil
                return
            elseif self.elapsed>3 then
                self.elapsed=0
                if specialEffects then
                    DEFAULT_CHAT_FRAME.editBox:SetText(EMOTE171_CMD2)
                    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox,0)
                else
                    getMountShow()
                end
            end
        end)
    end
    button.showFrame:SetShown(true)
end


















--#############
--初始化，对话框
--#############
local function Init_Dialogs()
    StaticPopupDialogs[id..addName..'ITEMS']={--物品, 设置对话框
        text=id..' '..addName..' '..(e.onlyChinese and '物品' or ITEMS)..'|n|n%s|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            self.button3:SetEnabled(Save.Mounts[ITEMS][data.itemID] and true or false)
            self.button1:SetEnabled(not Save.Mounts[ITEMS][data.itemID] and true or false)
        end,
        OnAccept = function(self, data)
            Save.Mounts[ITEMS][data.itemID]=true
            checkItem()--检测物品
            setClickAtt()--设置 Click属性
        end,
        OnAlt = function(self, data)
            Save.Mounts[ITEMS][data.itemID]=nil
            checkItem()--检测物品
            setClickAtt()--设置 Click属性
        end,
        EditBoxOnEscapePressed = function(s)
            s:SetAutoFocus(false)
            s:ClearFocus()
            s:GetParent():Hide()
        end,
    }

    StaticPopupDialogs[id..addName..'SPELLS']={--法术, 设置对话框
        text=id..' '..addName..' '..(e.onlyChinese and '法术' or SPELLS)..'|n|n%s|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        button1= e.onlyChinese and '添加' or ADD,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self, data)
            self.button3:SetEnabled(Save.Mounts[SPELLS][data.spellID] and true or false)
            self.button1:SetEnabled(not Save.Mounts[SPELLS][data.spellID] and true or false)
        end,
        OnAccept = function(self, data)
            Save.Mounts[SPELLS][data.spellID]=true
            checkItem()--检测物品
            setClickAtt()--设置 Click属性
        end,
        OnAlt = function(self, data)
            Save.Mounts[SPELLS][data.spellID]=nil
            checkSpell()--检测法术
            setClickAtt()--设置 Click属性
        end,
        EditBoxOnEscapePressed = function(s)
            s:SetAutoFocus(false)
            s:ClearFocus()
            s:GetParent():Hide()
        end,
    }

    StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
        text=id..' '..addName..'|n'..(e.onlyChinese and '快捷键"' or SETTINGS_KEYBINDINGS_LABEL)..'|n|nQ, BUTTON5',
        whileDead=true, hideOnEscape=true, exclusive=true,
        hasEditBox=true,
        button1= e.onlyChinese and '设置' or SETTINGS,
        button2= e.onlyChinese and '取消' or CANCEL,
        button3= e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self2, data)
            self2.editBox:SetText(Save.KEY or 'BUTTON5')
            if Save.KEY then
                self2.button1:SetText(SLASH_CHAT_MODERATE2:gsub('/', ''))--修该
            end
            self2.button3:SetEnabled(Save.KEY)
        end,
        OnHide= function(self2)
            self2.editBox:SetText("")
            e.call('ChatEdit_FocusActiveWindow')
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
            s:SetAutoFocus(false)
            s:ClearFocus()
            s:GetParent():Hide()
        end,
    }

    local function get_UIMapIDs(text)--从text取得uiMapID表
        local tab, reText={}, nil
        text:gsub('%d+', function(self)
            local uiMapID= tonumber(self)
            local info= uiMapID and C_Map.GetMapInfo(uiMapID)
            if uiMapID and info and info.name then--uiMapID<2147483647
                tab[uiMapID]=true
                reText= reText and reText..'|n' or ''
                reText= reText..uiMapID..info.name
            end
        end)
        return tab, reText
    end

    StaticPopupDialogs[id..addName..'FLOOR'] = {--区域,设置对话框
        text=id..' '..addName..' '..(e.onlyChinese and '区域' or FLOOR)..'|n|n%s|n%s',
        whileDead=true, hideOnEscape=true, exclusive=true,
        timeout= 0,
        hasEditBox= true,
        button1=e.onlyChinese and '区域' or FLOOR,
        button2=e.onlyChinese and '取消' or CANCEL,
        button3=e.onlyChinese and '移除' or REMOVE,
        OnShow = function(self4, data)
            self4.editBox:SetAutoFocus(false)
            self4.editBox:ClearFocus()
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
            self4.editBox:SetText(text)
            self4.button3:SetEnabled(Save.Mounts[FLOOR][data.spellID] and true or false)
        end,
        OnAccept = function(self4, data)
            local tab, text= get_UIMapIDs(self4.editBox:GetText())
            print('|cnGREEN_FONT_COLOR:', data.name, data.spellID, data.mountID, ':|r|n|cffff00ff', text, '|n|r'..id, e.cn(addName), 'Tools','...')

            Save.Mounts[FLOOR][data.spellID]= tab
            checkMount()--检测坐骑
            setClickAtt()--设置 Click属性
            if MountJournal_UpdateMountList then e.call('MountJournal_UpdateMountList') end
        end,
        OnHide= function(self2)
            self2.editBox:SetText("")
            e.call('ChatEdit_FocusActiveWindow')
        end,
        OnAlt = function(self4, data)
            Save.Mounts[FLOOR][data.spellID]=nil
            checkMount()--检测坐骑
            setClickAtt()--设置 Click属性
            if MountJournal_UpdateMountList then e.call('MountJournal_UpdateMountList') end
        end,
        EditBoxOnTextChanged=function(self4, data)
            local _, text= get_UIMapIDs(self4:GetText())
            local btn=self4:GetParent().button1
            btn:SetEnabled(text and true or false)
            btn:SetText(text or (e.onlyChinese and '无' or NONE))
        end,
        EditBoxOnEscapePressed = function(self2)
            self2:SetAutoFocus(false)
            self2:ClearFocus()
            self2:GetParent():Hide()
        end,
    }
end















--##################
--打开界面, 收藏, 坐骑
--##################
local function set_ToggleCollectionsJournal(mountID, type, showNotCollected)
    --CollectionsJournal_LoadUI()
    --[[if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
        C_AddOns.LoadAddOn('Blizzard_Collections')
    end]]
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

























--#####
--主菜单
--#####
local function InitMenu(_, level, type)--主菜单
    local info
    if type=='RANDOM' then--三级, 离开时, 随机坐骑
        info={
            text= '<AFK>'..(e.onlyChinese and '自动' or SELF_CAST_AUTO),
            checked= Save.AFKRandom,
            tooltipOnButton=true,
            tooltipTitle=e.onlyChinese and '注意: 掉落' or ('note: '..STRING_ENVIRONMENTAL_DAMAGE_FALLING),
            keepShownOnClick=true,
            func= function()
                Save.AFKRandom= not Save.AFKRandom and true or nil
                if Save.AFKRandom then
                    panel:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')--AFK
                else
                    panel:UnregisterEvent('PLAYER_FLAGS_CHANGED')
                end
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type==SETTINGS then--设置菜单
        info={--快捷键,设置对话框
            text= e.onlyChinese and '快捷键' or SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
            icon= 'NPE_ArrowDown',
            checked=Save.KEY and true or nil,
            keepShownOnClick=true,
            func=function()
                StaticPopup_Show(id..addName..'KEY')
            end,
        }
        info.disabled=UnitAffectingCombat('player')
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        if e.Player.class=='DRUID' then--德鲁伊
            info={
                text= e.onlyChinese and '德鲁伊' or  UnitClass('player'),
                icon= 'classicon-druid',
                checked=Save.XD,
                keepShownOnClick=true,
                func=function()
                    Save.XD= not Save.XD and true or nil
                    XDInt()--德鲁伊设置
                    checkSpell()--检测法术
                    checkMount()--检测坐骑
                    setClickAtt()--设置属性
                    e.LibDD:CloseDropDownMenus()
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info,level)
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={--坐骑展示,每3秒
            text= e.Icon.mid..(e.onlyChinese and '坐骑展示' or ('Random'..SHOW)),
            notCheckable=true,
            tooltipOnButton=true,
            hasArrow=true,
            menuList='RANDOM',
            keepShownOnClick=true,
            tooltipTitle= e.onlyChinese and '每隔 3 秒, 召唤' or ('3 '..SECONDS..MOUNT),
            tooltipText= (e.onlyChinese and '鼠标滚轮向上滚动' or KEY_MOUSEWHEELUP)..e.Icon.mid,
            func=function()
                specialEffects=nil
                setMountShow()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={--坐骑特效
            text= e.Icon.mid..(e.onlyChinese and '坐骑特效' or (EMOTE171_CMD2:gsub('/','')..SHOW)),
            notCheckable=true,
            keepShownOnClick=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinese and '每隔 3 秒' or ('3 '..SECONDS..EMOTE171_CMD2:gsub('/','')),
            tooltipText= (e.onlyChinese and '鼠标滚轮向下滚动' or KEY_MOUSEWHEELDOWN)..e.Icon.mid,
            func=function()
                specialEffects=true
                setMountShow()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinese and '重置位置' or RESET_POSITION,
            disabled=UnitAffectingCombat('player'),
            colorCode=not Save.Point and '|cff606060',
            keepShownOnClick=true,
            func=function()
                Save.Point=nil
                set_Button_Postion()--设置按钮位置
                print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                e.LibDD:CloseDropDownMenus()
            end,
            tooltipOnButton=true,
            tooltipTitle=e.Icon.right..(e.onlyChinese and '移动' or NPE_MOVE),
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        info={
            text=id..' Tools',
            isTitle=true,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info,level)
        return

    elseif type==ITEMS then--物品, 二级菜单
        for itemID, _ in pairs(Save.Mounts[ITEMS]) do
            local text= e.cn(C_Item.GetItemNameByID(itemID)) or ('itemID: '..itemID)
            local icon= C_Item.GetItemIconByID(itemID)
            if icon then
                text= '|T'..icon..':0|t'..text
            end
            local num=C_Item.GetItemCount(itemID , false, true, true)
            text= text..(num==0 and ' #|cnRED_FONT_COLOR:' or  ' #|cnGREEN_FONT_COLOR:')..num..'|r'
            local col= '|cffff8200'
            local itemQuality= select(3, GetItemInfo(itemID))
            if itemQuality then
                local hex = select(4,C_Item.GetItemQualityColor(itemQuality))
                col= hex and '|c'..hex
            end
            text= col.. text..'|r'
            info={
                text= text,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '修改' or HUD_EDIT_MODE_RENAME_LAYOUT)..e.Icon.left,
                notCheckable=true,
                keepShownOnClick=true,
                arg1= itemID,
                arg2= text,
                func=function(_, arg1, arg2)
                    StaticPopup_Show(id..addName..'ITEMS',
                                    arg2,
                                    Save.Mounts[ITEMS][arg1] and (e.onlyChinese and '物品已存在' or ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS)) or (e.onlyChinese and '新建' or NEW),
                                    {itemID=itemID})
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info,level)
        end
        return

    elseif type==SPELLS then--法术, 二级菜单
        for spellID, _ in pairs(Save.Mounts[SPELLS]) do
            local name, _, icon = GetSpellInfo(spellID)
            local text= (icon and '|T'..icon..':0|t' or '').. (e.cn(name) or ('spellID: '..spellID))
            local known= spellID and IsSpellKnown(spellID)
            text= text..(known and e.Icon.select2 or e.Icon.O2)
            info={
                text= text,
                tooltipOnButton=true,
                tooltipTitle= (e.onlyChinese and '修改' or HUD_EDIT_MODE_RENAME_LAYOUT)..e.Icon.left,
                colorCode= not known and '|cff606060',
                notCheckable=true,
                keepShownOnClick=true,
                arg1= spellID,
                arg2= text,
                func=function(_, arg1, arg2)
                    StaticPopup_Show(id..addName..'SPELLS',
                            arg2,
                            Save.Mounts[SPELLS][arg1] and (e.onlyChinese and '法术已存在' or ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS)) or (e.onlyChinese and '新建' or NEW),
                            {spellID=arg1}
                    )
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level);
        end
        return

    elseif type=='Shift' or type=='Alt' or type=='Ctrl' then--二级菜单
        info={
            text= format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, format(e.onlyChinese and '第%d个' or JAILERS_TOWER_SCENARIO_FLOOR, 1)),
            isTitle=true,
            notCheckable=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level);
        for spellID, _ in pairs(Save.Mounts[type]) do
            local name, _, icon
            local mountID = C_MountJournal.GetMountFromSpell(spellID)
            if mountID then
                name, _, icon = C_MountJournal.GetMountInfoByID(mountID)
            end
            info={
                text=name or ('spellID '..spellID),
                icon=icon,
                colorCode= spellID~=MountTab[type][1] and '|cff606060' or '|cnGREEN_FONT_COLOR:',
                notCheckable=true,
                tooltipOnButton= true,
                keepShownOnClick=true,
                tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                tooltipText= (e.onlyChinese and '藏品->坐骑' or (COLLECTIONS..'->'..MOUNTS))..e.Icon.left,
                arg1= mountID,
                arg2= type,
                func=function(_, arg1, arg2)
                    set_ToggleCollectionsJournal(arg1, arg2, true)--打开界面, 收藏, 坐骑
                end
            }
            if mountID then
                local useError = select(2, C_MountJournal.GetMountUsabilityByID(mountID, true))
                if useError then
                    info.tooltipText= info.tooltipText..'|n|cnRED_FONT_COLOR:'..useError
                end
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level);
        end
        return

    elseif type and MountTab[type] then--二级菜单
        for _, spellID in pairs(MountTab[type]) do
            local name, _, icon, mountID
            local isXDSpell= XD and XD[type]
            if isXDSpell then
                icon=GetSpellTexture(spellID)
                name, _, icon = GetSpellInfo(spellID)
            else
                mountID = C_MountJournal.GetMountFromSpell(spellID)
                if mountID then
                    name, _, icon = C_MountJournal.GetMountInfoByID(mountID)
                end
            end

            info={
                text=e.cn(name) or ('spellID '..spellID),
                icon=icon,
                notCheckable=true,
                keepShownOnClick=true,
                tooltipOnButton= not isXDSpell,
                tooltipTitle= e.onlyChinese and '添加/移除' or (ADD..'/'..REMOVE),
                tooltipText= (e.onlyChinese and '藏品->坐骑' or (COLLECTIONS..'->'..MOUNTS))..e.Icon.left,
                arg1= mountID,
                arg2= type,
            }

            if type==FLOOR and Save.Mounts[FLOOR][spellID] then
                local text
                for uiMapID, _ in pairs(Save.Mounts[FLOOR][spellID]) do
                    local mapInfo = C_Map.GetMapInfo(uiMapID)
                    text= text and text..'|n' or ''
                    text= text..uiMapID..' '..(mapInfo and e.cn(mapInfo.name) or (e.onlyChinese and '无' or NONE))
                end
                info.tooltipText= text
            end
            if not isXDSpell then
                info.func=function(_, arg1, arg2)
                    set_ToggleCollectionsJournal(arg1, arg2)--打开界面, 收藏, 坐骑, 不过滤类型
                end
                if mountID then
                    local useError = select(2, C_MountJournal.GetMountUsabilityByID(mountID, true))
                    if useError then
                        info.tooltipText= info.tooltipText..'|n|cnRED_FONT_COLOR:'..useError

                    end
                end
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level);
        end
        return
    end

    local mainMenuTable={
        {type=MOUNT_JOURNAL_FILTER_GROUND, name='地面'},
        {type=MOUNT_JOURNAL_FILTER_AQUATIC, name='水栖'},
        {type=MOUNT_JOURNAL_FILTER_FLYING, name='飞行'},
        {type=MOUNT_JOURNAL_FILTER_DRAGONRIDING, name='驭龙术'},
        {type='-', name=''},
        {type='Shift', name=''}, {type='Alt', name=''}, {type='Ctrl', name=''},
        {type='-', name=''},
        {type=SPELLS, name='法术'},
        {type=ITEMS, name='物品'},
        {type=FLOOR, name='区域'},
    }
    for _, tab in pairs(mainMenuTable) do
        local indexType= tab.type
        if indexType=='-' then
            e.LibDD:UIDropDownMenu_AddSeparator(level)

        elseif indexType==SPELLS or indexType==ITEMS then
            local num=getTableNum(indexType)--检测,表里的数量
            local icon= (indexType==SPELLS and button.spellID) and GetSpellTexture(button.spellID) or button.itemID and C_Item.GetItemIconByID(button.itemID)
            info={
                text=(num>0 and '|cnGREEN_FONT_COLOR:'..num..'|r' or '')..(icon and '|T'..icon..':0|t' or '')..(e.onlyChinese and tab.name or indexType),
                menuList=indexType,
                hasArrow=num>0,
                keepShownOnClick=true,
                notCheckable=true,
                colorCode=num==0 and '|cff606060',
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level);

        elseif indexType=='Shift' or indexType=='Alt' or indexType=='Ctrl' then
            local tab2=MountTab[indexType] or {}
            local spellID=tab2[1]
            local icon =spellID and GetSpellTexture(spellID)
            local mountID= spellID and C_MountJournal.GetMountFromSpell(spellID)
            local useError = mountID and select(2, C_MountJournal.GetMountUsabilityByID(mountID, true))
            info={
                text= (icon and '|T'..icon..':0|t' or '').. indexType,
                notCheckable= true,
                keepShownOnClick=true,
                tooltipOnButton=true,
                hasArrow=true,
                menuList=indexType,
                tooltipTitle= (spellID and (e.onlyChinese and '召唤' or SUMMON) or (e.onlyChinese and '设置' or SETTINGS))..e.Icon.left,
                tooltipText= useError and '|cnRED_FONT_COLOR:'..useError,
                arg1= mountID,
                func= function(_, arg1)
                    if arg1 then
                        C_MountJournal.SummonByID(arg1)
                    else
                        set_ToggleCollectionsJournal(nil, nil, true)--打开界面, 收藏, 坐骑
                    end
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level);
        else
            local tab2=MountTab[indexType] or {}
            local spellID= tab2[1]
            local icon= spellID and GetSpellTexture(spellID)
            local isXDSpell= XD and XD[indexType]
            local mountID= not isXDSpell and spellID and C_MountJournal.GetMountFromSpell(spellID)
            info={
                text= (icon and '|T'..icon..':0|t' or '').. (e.onlyChinese and tab.name or indexType),
                menuList=indexType,
                hasArrow= #tab2>0 and true or false,
                notCheckable= true,
                keepShownOnClick=true,
                tooltipOnButton=not isXDSpell,
                tooltipTitle= (mountID and (e.onlyChinese and '召唤' or SUMMON) or (e.onlyChinese and '设置' or SETTINGS))..e.Icon.left,
                arg1= mountID,
                arg2= indexType,
                func= function(_, arg1, arg2)
                    if arg1 then
                        C_MountJournal.SummonByID(arg1)
                    else
                        set_ToggleCollectionsJournal(nil, arg2)--打开界面, 收藏, 坐骑
                    end
                end
            }
            if mountID then
                local useError = select(2, C_MountJournal.GetMountUsabilityByID(mountID, true))
                if useError then
                    info.tooltipText= '|cnRED_FONT_COLOR:'..useError
                end
            end
            e.LibDD:UIDropDownMenu_AddButton(info, level);
        end
    end

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=Save.KEY or (e.onlyChinese and '设置' or SETTINGS),
        notCheckable=true,
        menuList=SETTINGS,
        hasArrow=true,
        keepShownOnClick=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)
end
















--#############################
--坐骑界面, 添加菜单, 设置提示内容
--#############################
local function Init_Menu_Set_UI(self, level)--坐骑界面, 菜单
    local info
    if UnitAffectingCombat('player') then
        info={
            text= e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT,
            notCheckable=true,
            isTitle=true,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    local frame= self:GetParent()
    local spellID= frame.spellID
    local mountID = frame.mountID
    if not mountID then
        return
    end
    local name, _, icon, _, _, _, _, isFactionSpecific, faction, shouldHideOnChar, isCollected, _, isForDragonriding = C_MountJournal.GetMountInfoByID(mountID)    
    for _, type in pairs(MountType) do
        if type=='Shift' or type==FLOOR then
            e.LibDD:UIDropDownMenu_AddSeparator(level)
        end
        info={
            text= (e.onlyChinese and '设置' or SETTINGS)..' '..e.cn(type)..' #'..getTableNum(type),
            checked= Save.Mounts[type][spellID] and true or nil,
            arg1={type= type, spellID= spellID, name= name, mountID= mountID},
            colorCode= (
                    (type==MOUNT_JOURNAL_FILTER_DRAGONRIDING and not isForDragonriding)
                    or (type~=MOUNT_JOURNAL_FILTER_DRAGONRIDING and isForDragonriding)
                    or not isCollected
                    or shouldHideOnChar
                    or (isFactionSpecific and faction~=Faction)
                ) and '|cff606060'
        }
        if type==FLOOR then
            info.func= function(_, tab)
                StaticPopup_Show(
                    id..addName..'FLOOR',
                    (tab.icon and '|T'..tab.icon..':0|t' or '').. (e.cn(tab.name) or ('spellID: '..tab.spellID)),
                    (Save.Mounts[FLOOR][tab.spellID] and (e.onlyChinese and '已存在' or format(ERR_ZONE_EXPLORED, PROFESSIONS_CURRENT_LISTINGS)) or (e.onlyChinese and '新建' or NEW))..'|n|n uiMapID: '..(C_Map.GetBestMapForUnit("player") or ''),
                    tab
                )
            end
            if info.checked then
                local text
                for uiMapID,_ in pairs(Save.Mounts[type][spellID]) do
                    local mapInfo= uiMapID and C_Map.GetMapInfo(uiMapID)
                    text= text and text..'|n' or ''
                    text= text..'uiMapID '..uiMapID..' '..(mapInfo and e.cn(mapInfo.name) or (e.onlyChinese and '无' or NONE))
                end
                if text then
                    info.tooltipOnButton=true
                    info.tooltipTitle= text
                end
            end
        else
            info.func= function(_, tab)
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
        e.LibDD:UIDropDownMenu_AddButton(info, level);
    end

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={
        text=e.cn(name),
        icon=icon,
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level);

    info={
        text=id..' '..e.cn(addName),
        isTitle=true,
        notCheckable=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info, level);
end













--初始，坐骑界面
local function Init_MountJournal()
    hooksecurefunc('MountJournal_InitMountButton',function(self)--Blizzard_MountCollection.lua
        if not self or not self.spellID then
            if self and self.btn then
                self.btn:SetShown(false)
            end
            return
        end
        local text
        for _, type in pairs(MountType) do
            local ID=Save.Mounts[type][self.spellID]
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
        if text and not self.text then--提示， 文本
            self.text=e.Cstr(self, {justifyH='RIGHT'})--nil, self.name, nil,nil,nil,'RIGHT')
            self.text:SetPoint('RIGHT')
            self.text:SetFontObject('GameFontNormal')
            self.text:SetAlpha(0.3)
        end
        if self.text then
            self.text:SetText(text or '')
        end
        if not self.btn then--建立，图标，菜单
            self.btn=e.Cbtn(self, {icon=true, size={18,18}})
            self.btn:SetPoint('BOTTOMRIGHT')
            self.btn:SetAlpha(0.3)
            self.btn:SetScript('OnEnter', function(self2)
                self2:SetAlpha(1)
            end)
            self.btn:SetScript('OnLeave', function(self2) self2:SetAlpha(0.3) end)
            self.btn:SetScript('OnMouseDown', function(self2)
                if not self2.Menu then
                    self2.Menu=CreateFrame("Frame", nil, self2, "UIDropDownMenuTemplate")
                    e.LibDD:UIDropDownMenu_Initialize(self2.Menu, Init_Menu_Set_UI, 'MENU')
                end
                e.LibDD:ToggleDropDownMenu(1, nil, self2.Menu, self2, 10, 0)
            end)
        end
        self.btn.mountID= self.mountID
        self.btn.spellID= self.spellID
        self.btn:SetShown(true)

        if not MountJournal.MountDisplay.tipsMenu then
            MountJournal.MountDisplay.tipsMenu= e.Cbtn(MountJournal.MountDisplay, {icon=true, size={22,22}})
            MountJournal.MountDisplay.tipsMenu:SetPoint('LEFT')
            MountJournal.MountDisplay.tipsMenu:SetAlpha(0.3)
            MountJournal.MountDisplay.tipsMenu:SetScript('OnEnter', function(self2)
                e.LibDD:ToggleDropDownMenu(1, nil, button.Menu, self2, 15, 0)
                self2:SetAlpha(1)
            end)
            MountJournal.MountDisplay.tipsMenu:SetScript('OnLeave', function(self2) self2:SetAlpha(0.3) end)
        end
    end)


    local btn= CreateFrame('DropDownToggleButton', 'MountJournalFilterButtonWoWTools', MountJournal, 'UIResettableDropdownButtonTemplate')--SharedUIPanelTemplates.lua
    btn:SetPoint('BOTTOM', MountJournalFilterButton, 'TOP')
    btn.MountJournal_FullUpdate= MountJournal_FullUpdate
    function btn.resetFunction()
        MountJournal_FullUpdate= _G['MountJournalFilterButtonWoWTools'].MountJournal_FullUpdate
        _G['MountJournalFilterButtonWoWTools']:SetText("")
        e.call('MountJournalFilterDropdown_ResetFilters')
        --e.call('MountJournal_FullUpdate', MountJournal)
    end

    btn:SetScript('OnMouseDown', function(frame)
        if not frame.Menu then
            frame.Menu= CreateFrame('Frame', nil, frame, 'UIDropDownMenuTemplate')
            e.LibDD:UIDropDownMenu_Initialize(frame.Menu, function(self, level)
                local parent= self:GetParent()
                for _, t in pairs(MountType) do
                    local name= e.cn(t)
                    local info={
                        text= name,
                        checked= parent:GetText()==name,
                        tooltipOnButton=true,
                        tooltipTitle=id..' Tools',
                        arg1= t,
                        func= function(_, arg1)
                            MountJournal_FullUpdate= function()
                                if (MountJournal:IsVisible()) then
                                    local newDataProvider = CreateDataProvider();
                                    for index = 1, C_MountJournal.GetNumDisplayedMounts()  do
                                        local _, spellID, _, _, _, _, _, _, _, _, _, mountID   = C_MountJournal.GetDisplayedMountInfo(index)
                                        if mountID and spellID and Save.Mounts[arg1][spellID] then
                                            newDataProvider:Insert({index = index, mountID = mountID})
                                        end
                                    end
                                    MountJournal.ScrollBox:SetDataProvider(newDataProvider, ScrollBoxConstants.RetainScrollPosition);
                                    if (not MountJournal.selectedSpellID) then
                                        MountJournal_Select(self.dragonridingHelpTipMountIndex or 1);
                                    end
                                    MountJournal_UpdateMountDisplay()
                                end
                            end
                            e.call('MountJournalFilterDropdown_ResetFilters')
                            e.call('MountJournal_SetUnusableFilter',true)
                            --e.call('MountJournal_FullUpdate')

                            parent.ResetButton:SetShown(true)
                            parent:SetText(e.cn(arg1))
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                e.LibDD:UIDropDownMenu_AddButton({
                    text= 'Tools '..e.cn(addName),
                    notCheckable=true,
                    isTitle=true,
                }, level)
            end, 'MENU')
        end
        e.LibDD:CloseDropDownMenus()
        e.LibDD:ToggleDropDownMenu(1, nil, frame.Menu, frame, 74, 15)
    end)

    MountJournal.MountCount:ClearAllPoints()
    MountJournal.MountCount:SetPoint('BOTTOMLEFT', MountJournalSearchBox, 'TOPLEFT',-3, 0)
    MountJournal.MountCount:SetPoint('RIGHT', MountJournalFilterButton, 'LEFT', -2, 0)
    MountJournalFilterButton.ResetButton:HookScript('OnClick', function()
        if _G['MountJournalFilterButtonWoWTools'].ResetButton:IsShown() then
            _G['MountJournalFilterButtonWoWTools'].ResetButton:Click()
        end
    end)
end






















--######
--初始化
--######
local function Init()
    button.Menu= CreateFrame("Frame", nil, button, "UIDropDownMenuTemplate")
    e.LibDD:UIDropDownMenu_Initialize(button.Menu, InitMenu, 'MENU')

    Init_Dialogs()--初始化，对话框

    OkMount= IsSpellKnownOrOverridesKnown(90265)--是否已学, 骑术
                or IsSpellKnownOrOverridesKnown(33391)
                or IsSpellKnownOrOverridesKnown(34090)
                or IsSpellKnownOrOverridesKnown(33388)

    for type, tab in pairs(Save.Mounts) do
        for ID, _ in pairs(tab) do
            e.LoadDate({id=ID, type= type==ITEMS and 'item' or 'spell'})
        end
    end
    set_Button_Postion()--设置按钮位置

    --setButtonSize()--设置按钮大小
    XDInt()--德鲁伊设置
    checkSpell()--检测法术
    checkItem()--检测物品
    checkMount()--检测坐骑
    setClickAtt()--设置
    setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
    e.SetItemSpellCool({frame=button, item=button.itemID, spell=button.spellAtt})--设置冷却

    if Save.KEY then
        setKEY()--设置捷键
    end



    button:RegisterForDrag("RightButton")
    button:SetMovable(true)
    button:SetClampedToScreen(true)

    button:SetScript("OnDragStart", function(self,d)
        if d=='RightButton' and IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    button:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
        e.LibDD:CloseDropDownMenus()
    end)

    button:SetScript("OnMouseDown", function(self,d)
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID then
            local exits=Save.Mounts[ITEMS][itemID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
            local icon = C_Item.GetItemIconByID(itemID)
            local text= (icon and '|T'..icon..':0|t' or '').. (itemLink or ('itemID: '..itemID))
            StaticPopup_Show(id..addName..'ITEMS',text, exits , {itemID=itemID})
            ClearCursor()

        elseif infoType =='spell' and spellID then
            local exits=Save.Mounts[SPELLS][spellID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
            local icon = GetSpellTexture(spellID)
            local text= (icon and '|T'..icon..':0|t' or '').. (GetSpellLink(spellID) or ('spellID: '..spellID))
            StaticPopup_Show(id..addName..'SPELLS',text, exits , {spellID=spellID})
            ClearCursor()

        elseif d=='RightButton' and IsAltKeyDown() then
            SetCursor('UI_MOVE_CURSOR')

        elseif d=='RightButton' and not IsModifierKeyDown() then
           e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)

        elseif d=='LeftButton' then
            if IsMounted() then
                C_MountJournal.Dismiss()
            elseif IsSpellKnown(111400) and not UnitAffectingCombat('player') then--SS爆燃冲刺
                for i = 1, 40 do
                    local spell = select(10, UnitBuff('player', i, 'PLAYER'))
                    if not spell then
                        break
                    elseif spell == 111400 then
                        CancelUnitBuff('player', i, 'HELPFUL')
                        break
                    end
                end
            end
        end
        self.border:SetAtlas('bag-border')
    end)

    button:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' then
            self.border:SetAtlas('bag-reagent-border')
        end
        ResetCursor()
    end)

    button:SetScript('OnMouseWheel',function(self,d)
        if IsAltKeyDown() then
            local n= Save.scale or 1
            if d==1 then
                n= n+0.05
            else
                n= n-0.05
            end
            n= n>3 and 3 or n
            n= n<0.5 and 0.5 or n
            self:SetScale(n)
            print(id, e.cn(addName), e.onlyChinese and '缩放' or UI_SCALE, n)
            Save.scale= n
        else
            if d==1 then--坐骑展示
                specialEffects=nil
                setMountShow()
            elseif d==-1 then--坐骑特效
                specialEffects=true
                setMountShow()
            end
        end
    end)

    function button:set_tooltips()
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
            local icon = GetSpellTexture(spellID)
            local text= (icon and '|T'..icon..':0|t' or '').. (GetSpellLink(spellID) or ('spellID: '..spellID))
            e.tips:AddDoubleLine(text, exits..e.Icon.left, 0,1,0, 0,1,0)
            e.tips:AddLine(' ')
        end

        e.tips:AddLine('')
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE), '|cnGREEN_FONT_COLOR:'..(Save.scale or 1)..'|r Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE or SLASH_TEXTTOSPEECH_MENU, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        e.tips:Show()
    end

    button:SetScript("OnLeave",function(self)
        e.tips:Hide()
        setClickAtt()--设置属性
        ResetCursor()
        self.border:SetAtlas('bag-reagent-border')
        self:SetScript('OnUpdate',nil)
        self.elapsed=nil
    end)
    
    button:SetScript('OnEnter', function(self)
        if not UnitAffectingCombat('player') then
            e.toolsFrame:SetShown(true)--设置, TOOLS 框架, 显示
        end
        self:set_tooltips()
        self:SetScript('OnUpdate', function (self, elapsed)
            self.elapsed = (self.elapsed or 0.3) + elapsed
            if self.elapsed > 0.3 and self.typeID then
                self.elapsed = 0
                if GameTooltip:IsOwned(self) then
                    local typeID= self.typeSpell and select(2, GameTooltip:GetSpell()) or select(3, GameTooltip:GetItem())
                    if typeID and typeID~=self.typeID then
                        self:set_tooltips()
                    end
                end
            end
        end)
    end)


    if Save.scale and Save.scale~=1 then
        button:SetScale(Save.scale)
    end

    C_Timer.After(2, function()
        setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
        setClickAtt()--设置
    end)
end






















--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Header(nil, 'Tools')
            e.AddPanel_Check_Button({
                checkName= '|A:bag-border-empty:0:0|aTools',
                checkValue= not Save.disabled,
                checkFunc= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, 'Tools', e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
                buttonText= e.onlyChinese and '重置位置' or RESET_POSITION,
                buttonFunc= function()
                    Save.Point=nil
                    set_Button_Postion()--设置按钮位置
                    print(id, e.cn(addName), e.onlyChinese and '重置位置' or RESET_POSITION)
                end,
                tooltip= e.cn(addName),
                layout= nil,
                category= nil,
            })

            if not Save.disabled then
                for spellID, tab in pairs(Save.Mounts[FLOOR]) do
                    if type(tab)~='table' then
                        Save.Mounts[FLOOR][spellID]=nil
                    end
                end

                --[[if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
                    C_AddOns.LoadAddOn('Blizzard_Collections')
                end]]
                CollectionsJournal_LoadUI()
                

                button= e.Cbtn2({
                    name= 'WoWToolsMountButton',
                    parent=nil,
                    click=true,-- right left
                    notSecureActionButton=nil,
                    notTexture=nil,
                    showTexture=true,
                    sizi=nil,
                })
                button:SetAttribute("type1", "spell")
                button:SetAttribute("target-spell", "cursor")
                button:SetAttribute("alt-type1", "spell")
                button:SetAttribute("shift-type1", "spell")
                button:SetAttribute("ctrl-type1", "spell")

                button.textureModifier=button:CreateTexture(nil,'OVERLAY')--提示 Shift, Ctrl, Alt
                button.textureModifier:SetAllPoints(button.texture)
                button.textureModifier:AddMaskTexture(button.mask)

                button.textureModifier:SetShown(false)

                e.toolsFrame:SetParent(button)--设置, TOOLS 位置
                e.toolsFrame:SetPoint('BOTTOMRIGHT', button, 'TOPRIGHT',-1,0)
                button.Up=button:CreateTexture(nil,'OVERLAY')
                button.Up:SetPoint('TOP',-1, 9)
                button.Up:SetAtlas('NPE_ArrowUp')
                button.Up:SetSize(20,20)

                Init()--初始

                panel:RegisterEvent('PLAYER_REGEN_DISABLED')
                panel:RegisterEvent('PLAYER_REGEN_ENABLED')
                panel:RegisterEvent('SPELLS_CHANGED')
                panel:RegisterEvent('SPELL_DATA_LOAD_RESULT')
                panel:RegisterEvent('BAG_UPDATE_DELAYED')
                panel:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')
                panel:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
                --panel:RegisterEvent('AREA_POIS_UPDATED')
                panel:RegisterEvent('NEW_MOUNT_ADDED')
                panel:RegisterEvent('MODIFIER_STATE_CHANGED')
                panel:RegisterEvent('ZONE_CHANGED')
                panel:RegisterEvent('ZONE_CHANGED_INDOORS')
                panel:RegisterEvent('ZONE_CHANGED_NEW_AREA')
                panel:RegisterEvent('SPELL_UPDATE_COOLDOWN')
                panel:RegisterEvent('SPELL_UPDATE_USABLE')
                panel:RegisterEvent('PET_BATTLE_CLOSE')
                panel:RegisterUnitEvent('UNIT_EXITED_VEHICLE', "player")

                panel:RegisterEvent('PLAYER_STOPPED_MOVING')
                panel:RegisterEvent('PLAYER_STARTED_MOVING')--设置, TOOLS 框架,隐藏

                panel:RegisterEvent('NEUTRAL_FACTION_SELECT_RESULT')--ShiJI
                panel:RegisterEvent('LEARNED_SPELL_IN_TAB')--OkMount

                if Save.AFKRandom then
                    panel:RegisterUnitEvent('PLAYER_FLAGS_CHANGED', 'player')--AFK
                    if not UnitAffectingCombat('player') and UnitIsAFK('player') and IsOutdoors() then
                        setMountShow()--坐骑展示
                    end
                end

            else
                e.toolsFrame.disabled=true
                panel:UnregisterAllEvents()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Collections' then
            Init_MountJournal()

            --hooksecurefunc('MountJournal_ShowMountDropdown',setMountJournal_ShowMountDropdown)
        end

    elseif event=='PLAYER_REGEN_DISABLED' then
            setClickAtt()--设置属性
            if e.toolsFrame:IsShown() then
                e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
            end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if button.Combat then
            C_Timer.After(0.3, function()
                setClickAtt()--设置属性
                setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
                button.Combat=nil
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
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
    then-- or event=='AREA_POIS_UPDATED' then
        setClickAtt()--设置属性

    elseif event=='MODIFIER_STATE_CHANGED' then
        local icon
        if arg2==1 then
            icon = arg1:find('SHIFT') and button.textureModifier.Shift
                or arg1:find('CTRL') and button.textureModifier.Ctrl
                or arg1:find('ALT') and button.textureModifier.Alt
        end
        if icon then
            button.textureModifier:SetTexture(icon)
        end
        button.textureModifier:SetShown(icon)

    elseif event=='SPELL_UPDATE_COOLDOWN' then
        e.SetItemSpellCool({frame=button, item=button.itemID, spell=button.spellAtt})--设置冷却

    elseif event=='SPELL_UPDATE_USABLE' then
        setTextrue()--设置图标

    elseif event=='PLAYER_FLAGS_CHANGED' then
        if not UnitAffectingCombat('player') and UnitIsAFK('player') and IsOutdoors() then
            setMountShow()--坐骑展示
        end

    elseif event=='PLAYER_STARTED_MOVING' then
        setClickAtt()--设置属性
        if not UnitAffectingCombat('player') and e.toolsFrame:IsShown() then
            e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
        end
        
    elseif event=='NEUTRAL_FACTION_SELECT_RESULT' then
        ShiJI= Faction==0 and 179244 or Faction==1 and 179245
        checkMount()--检测坐骑
        setClickAtt()--设置属性

    elseif event=='LEARNED_SPELL_IN_TAB' then
        OkMount= IsSpellKnownOrOverridesKnown(90265)--是否已学, 骑术
                or IsSpellKnownOrOverridesKnown(33391)
                or IsSpellKnownOrOverridesKnown(34090)
                or IsSpellKnownOrOverridesKnown(33388)

    end
end)