local id, e = ...
local addName=MOUNT
local Faction =  UnitFactionGroup('player')=='Horde' and 0 or UnitFactionGroup('player')=='Alliance' and 1
local ClassID = select(2, UnitClassBase('player'))
local ShiJI= Faction==0 and IsSpellKnown(179244) and 179244 or Faction==1 and IsSpellKnown(179245) and 179245--[召唤司机]

local Save={
    Mounts={
        [ITEMS]={[174464]=true, [168035]=true},--幽魂缰绳 噬渊鼠缰绳
        [SPELLS]={[2645]=true, [111400]=true, [343016]=true, [195072]=true, [2983]=true, [190784]=true, [48265]=true, [186257]=true, [6544]=true},
        [FLOOR]={},
        [MOUNT_JOURNAL_FILTER_GROUND]={
            [339588]=true,--[罪奔者布兰契]
            [163024]=ture,--战火梦魇兽
        },
        [MOUNT_JOURNAL_FILTER_FLYING]={
            [339588]=true,--[罪奔者布兰契]
            [163024]=ture,--战火梦魇兽
        },
        [MOUNT_JOURNAL_FILTER_AQUATIC]={
            [359379]=true,--闪光元水母
            [376912]=true,--[热忱的载人奥獭]
            [342680]=true,--[深星元水母]
            [30174]=true,--[乌龟坐骑]
            [64731]=true,--[海龟]
        },
        [MOUNT_JOURNAL_FILTER_DRAGONRIDING]={
            [368896]=true,--[复苏始祖幼龙]
            [368901]=true,--[崖际荒狂幼龙]
            [368899]=true,--[载风迅疾幼龙]
            [360954]=true,--[高地幼龙]
        },
        Shift={
            [75973]=true,--X-53型观光火箭
            [93326]=true,--沙石幼龙
            [121820]=true,--黑耀夜之翼
        },
        Alt={[264058]=true,--雄壮商队雷龙
            [122708]=true,--雄壮远足牦牛
            [61425]=true,--旅行者的苔原猛犸象
        },
        Ctrl={
            [118089]=true,--天蓝水黾
            [127271]=true,--猩红水黾
         },
    },
    XD=true
}
local XD

local panel=e.Cbtn2('WoWToolsMountButton')
panel:SetAttribute("type1", "spell")
panel:SetAttribute("target-spell", "cursor")
panel:SetAttribute("alt-type1", "spell")
panel:SetAttribute("shift-type1", "spell")
panel:SetAttribute("ctrl-type1", "spell")

panel.textureModifier=panel:CreateTexture(nil,'OVERLAY')--提示 Shift, Ctrl, Alt
panel.textureModifier:SetAllPoints(panel.texture)
panel.textureModifier:AddMaskTexture(panel.mask)

panel.textureModifier:SetShown(false)

e.toolsFrame:SetParent(panel)--设置, TOOLS 位置
e.toolsFrame:SetPoint('BOTTOMRIGHT', panel, 'TOPRIGHT',-1,0)
panel.Up=panel:CreateTexture(nil,'OVERLAY')
panel.Up:SetPoint('TOP',-1, 9)
panel.Up:SetAtlas('NPE_ArrowUp')
panel.Up:SetSize(20,20)

local function setPanelPostion()--设置按钮位置
    local p=Save.Point
    panel:ClearAllPoints()
    if p and p[1] and p[3] and p[4] and p[5] then
        panel:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        panel:SetParent(UIParent)
    else
        panel:SetPoint('RIGHT', CharacterReagentBag0Slot, 'LEFT', -60 ,0)
       -- panel:SetParent(CharacterReagentBag0Slot)
        
        --panel:SetPoint('RIGHT', _G['HearthstoneToolsFrame'], 'LEFT',0,0)
    end
end

local function setButtonSize()--设置按钮大小
    if e.toolsFrame.size then
        panel:SetSize(e.toolsFrame.size, e.toolsFrame.size)
    end
end

local function setKEY()--设置捷键
    if Save.KEY then
        e.SetButtonKey(panel, true, Save.KEY)
        if #Save.KEY==1 then
            if not panel.KEY then
                panel.KEYstring=e.Cstr(panel,10, nil, nil, true, 'OVERLAY')
                panel.KEYstring:SetPoint('BOTTOMRIGHT', panel.border, 'BOTTOMRIGHT',-4,4)
            end
            panel.KEYstring:SetText(Save.KEY)
            if panel.KEYtexture then
                panel.KEYtexture:SetShown(false)
            end
        else
            if not panel.KEYtexture then
                panel.KEYtexture=panel:CreateTexture(nil,'OVERLAY')
                panel.KEYtexture:SetPoint('BOTTOM', panel.border,'BOTTOM',-1,-5)
                panel.KEYtexture:SetAtlas('NPE_ArrowDown')
                panel.KEYtexture:SetDesaturated(true)
                panel.KEYtexture:SetSize(20,15)
            end
            panel.KEYtexture:SetShown(true)
        end
    else
        e.SetButtonKey(panel)
        if panel.KEYstring then
            panel.KEYstring:SetText('')
        end
        if panel.KEYtexture then
            panel.KEYtexture:SetShown(false)
        end
    end
end
local function XDInt()--德鲁伊设置
    XD=nil
    if Save.XD and ClassID==11 then
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
        if type2~=type then
            Save.Mounts[type2][ID]=nil
        end
    end
end
local function checkSpell()--检测法术
    panel.spellID=nil
    if XD and XD[MOUNT_JOURNAL_FILTER_GROUND] then
        panel.spellID=XD[MOUNT_JOURNAL_FILTER_GROUND]
    else
        for spellID, _ in pairs(Save.Mounts[SPELLS]) do
            if IsSpellKnown(spellID) then
                panel.spellID=spellID
                break
            end
        end
    end
end
local function checkItem()--检测物品
    panel.itemID=nil
    for itemID, _ in pairs(Save.Mounts[ITEMS]) do
        if GetItemCount(itemID , nil, true, true)>0 then
            panel.itemID=itemID
            break
        end
    end
end

local function checkMount()--检测坐骑
    local tab={
        MOUNT_JOURNAL_FILTER_GROUND,
        MOUNT_JOURNAL_FILTER_AQUATIC,
        MOUNT_JOURNAL_FILTER_FLYING,
        MOUNT_JOURNAL_FILTER_DRAGONRIDING,
        'Shift', 'Alt', 'Ctrl',
        FLOOR,
    }
    local prima=IsSpellKnown(33388)
    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图
    for index, type in pairs(tab) do
        if XD and XD[type] then
            panel[type]={XD[type]}

        elseif index<=3 and not prima and ShiJI then--33388初级骑术 33391中级骑术 3409高级骑术 34091专家级骑术 90265大师级骑术 783旅行形态
            panel[type]={ShiJI}

        else
            panel[type]={}
            for spellID, mapID in pairs(Save.Mounts[type]) do
                local mountID = C_MountJournal.GetMountFromSpell(spellID)
                if mountID then
                    mountID = mountID==678 and Faction==1 and 679 or mountID==679 and Faction==0 and 678 or mountID--[召唤司机]
                    local name, _, icon, isActive, isUsable, sourceType, isFavorite, isFactionSpecific, faction, shouldHideOnChar, isCollected =C_MountJournal.GetMountInfoByID(mountID)
                    if not shouldHideOnChar and isCollected and (not isFactionSpecific or faction==Faction) then
                        if type==FLOOR then
                            if uiMapID and mapID==uiMapID and not XD then
                                table.insert(panel[type], spellID)
                            end
                        else
                            table.insert(panel[type], spellID)
                        end
                    end
                end
            end
        end
    end
end

local function getRandomRoll(type)--随机坐骑
    local tab=panel[type]
    if #tab>0 then
        local index=math.random(1,#tab)
        return tab[index]
    end
end
local function setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
    if UnitAffectingCombat('player') then
        panel.Combat=true
        return
    end
    local tab={'Shift', 'Alt', 'Ctrl'}

    local name, _, icon
    for _, type in pairs(tab) do
        panel.textureModifier[type]=nil
        if panel[type] and panel[type][1] then
            name, _, icon=GetSpellInfo(panel[type][1])
            if name and icon then
                panel:SetAttribute(type.."-spell1", name)
                panel.textureModifier[type]=icon
            end
        end
    end
    panel.Combat=nil
end
local function setCooldown(aura)--设置冷却
    if panel.spellAtt then
        local start, duration, _, modRate = GetSpellCooldown(panel.spellAtt)
        e.Ccool(panel, start, duration, modRate, true, nil, true)--冷却条
    elseif panel.itemID then
        local start, duration = GetItemCooldown(itemID)
        e.Ccool(panel, start, duration, nil, true,nil, true)--冷却条
    elseif panel.cooldown then
        panel.cooldown:Clear()
    end
end
local function setTextrue()--设置图标
    local icon= panel.iconAtt
    if IsMounted() then
        icon=136116
    elseif icon then
        local spellID= panel.spellAtt or panel.itemID and select(2, GetItemSpell(panel.itemID))
        if spellID  then --and e.WA_GetUnitBuff('player', spellID, 'PLAYER') then
            local spellName=GetSpellInfo(spellID)
            for i = 1, 40 do
                local name, _, _, _, _, _, _, _, _, spell=UnitBuff('player', spellID, 'PLAYER')
                if not name then
                    break
                elseif spell == spellID  or spellName == name then
                    icon=136116
                    break
                end
              end
        end
    end
    if icon then
        panel.texture:SetTexture(icon)
    end
    panel.texture:SetShown(icon and true or false)
    setCooldown()--设置冷却
end
local function setClickAtt(inCombat)--设置 Click属性
    if UnitAffectingCombat('player') and not inCombat then
        return
    end
    local spellID= (inCombat or IsIndoors()) and panel.spellID--进入战斗, 室内
                    or #panel[FLOOR]>0 and getRandomRoll(FLOOR)--区域
                    or IsSubmerged() and getRandomRoll(MOUNT_JOURNAL_FILTER_AQUATIC)--水平中
                    or IsFlyableArea() and getRandomRoll(MOUNT_JOURNAL_FILTER_FLYING)--飞行区域
                    or IsOutdoors() and getRandomRoll(MOUNT_JOURNAL_FILTER_GROUND)--室外

    local name, _, icon
    if spellID then
        name, _, icon=GetSpellInfo(spellID)
        if name and icon then
            panel:SetAttribute("type1", "spell")
            panel:SetAttribute("spell1", name)
        end
    elseif panel.itemID then
        panel:SetAttribute("type1", "item")
        panel:SetAttribute("item1", C_Item.GetItemNameByID(panel.itemID)  or panel.itemID)
    else
        panel:SetAttribute("item1", nil)
        panel:SetAttribute("spell1", nil)
    end
    panel.spellAtt=spellID
    panel.iconAtt=icon
    setTextrue()--设置图标
end

--#######
--坐骑展示
--#######
local function getMountShow()
    C_MountJournal.SetCollectedFilterSetting(2,false)
    C_MountJournal.SetCollectedFilterSetting(3,false)
    local num=C_MountJournal.GetNumDisplayedMounts()
    while not find and panel.showFrame:IsShown() do
        if UnitAffectingCombat('player') or IsPlayerMoving() then
            panel.showFrame:SetShown(false)
        end
        local _, _, _, isActive, isUsable, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(math.random(1, num));
        if not isActive and isUsable and mountID then
            C_MountJournal.SummonByID(mountID)
            return
        end
    end
    panel.showFrame:SetShown(false)
end

local specialEffects
local timeElapsed=3.1
local function setMountShow()--坐骑展示
    if UnitAffectingCombat('player') then
        specialEffects=nil
        print(id, addName, '|cnRED_FONT_COLOR:'..COMBAT..'|r')
        return
    elseif specialEffects and not IsMounted() then
        print(id, addName, EMOTE171_CMD2, '|cnRED_FONT_COLOR:'..NEED..MOUNT..'|r')
        specialEffects=nil
        return
    end
    timeElapsed=3.1
    print(id, addName, specialEffects and EMOTE171_CMD2:gsub('/','') or MOUNT, '3 '..SECONDS)
    if not panel.showFrame then
        panel.showFrame=CreateFrame('Frame')
        panel.showFrame:HookScript('OnUpdate',function(self, elapsed)
            timeElapsed= timeElapsed+ elapsed
            if UnitAffectingCombat('player') or IsPlayerMoving() or UnitIsDeadOrGhost('player') then
                panel.showFrame:SetShown(false)
                specialEffects=nil
                return
            elseif timeElapsed>3 then
                if specialEffects then
                    DEFAULT_CHAT_FRAME.editBox:SetText(	EMOTE171_CMD2)
                    ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox,0)
                else
                    getMountShow()
                    timeElapsed=0
                end
            end
        end)
    end
    panel.showFrame:SetShown(true)
end

--#####
--对话框
--#####
StaticPopupDialogs[id..addName..'FLOOR']={--区域,设置对话框
    text=id..' '..addName..' '..FLOOR..'\n\n%s\n%s',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
	timeout = 60,
    hasEditBox=1,
    button1=FLOOR,
    button2=CANCEL,
    button3=REMOVE,
    OnShow = function(self, data)
        self.editBox:SetNumeric(true)
        local num= Save.Mounts[FLOOR][data.spellID] or C_Map.GetBestMapForUnit("player")
        if num and num>1 then
            self.editBox:SetNumber(num)
        end
        self.button3:SetEnabled(Save.Mounts[FLOOR][data.spellID] and true or false)
	end,
    OnAccept = function(self, data)
		local num= self.editBox:GetNumber()
        num = num<1 and 1 or num
        Save.Mounts[FLOOR][data.spellID]=num
        checkMount()--检测坐骑
        setClickAtt()--设置 Click属性
        if MountJournal_UpdateMountList then MountJournal_UpdateMountList() end
	end,
    OnAlt = function(self, data)
        Save.Mounts[FLOOR][data.spellID]=nil
        checkMount()--检测坐骑
        setClickAtt()--设置 Click属性
        if MountJournal_UpdateMountList then MountJournal_UpdateMountList() end
    end,
    EditBoxOnTextChanged=function(self, data)
       local num= self:GetNumber()
       local mapInfo = num>0 and num<2147483647 and C_Map.GetMapInfo(num)
       if mapInfo and mapInfo.name then
        self:GetParent().button1:SetText('|cnGREEN_FONT_COLOR:'..mapInfo.name..'|r')
       else
        self:GetParent().button1:SetText(NONE)
       end
       self:GetParent().button1:SetEnabled(num>0 and num<2147483647) 
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}
StaticPopupDialogs[id..addName..'ITEMS']={--物品, 设置对话框
    text=id..' '..addName..' '..ITEMS..'\n\n%s\n%s',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
	timeout = 60,
    button1=ADD,
    button2=CANCEL,
    button3=REMOVE,
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
        s:GetParent():Hide()
    end,
}
StaticPopupDialogs[id..addName..'SPELLS']={--法术, 设置对话框
    text=id..' '..addName..' '..SPELLS..'\n\n%s\n%s',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
	timeout = 60,
    button1=ADD,
    button2=CANCEL,
    button3=REMOVE,
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
        s:GetParent():Hide()
    end,
}
StaticPopupDialogs[id..addName..'KEY']={--快捷键,设置对话框
    text=id..' '..addName..'\n'..SETTINGS_KEYBINDINGS_LABEL..'\n\nQ, BUTTON5',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    hasEditBox=1,
    button1=SETTINGS,
    button2=CANCEL,
    button3=REMOVE,
    OnShow = function(self, data)
        self.editBox:SetText(Save.KEY or 'BUTTON5')
        if Save.KEY then
            self.button1:SetText(SLASH_CHAT_MODERATE2:gsub('/', ''))--修该
        end
        self.button3:SetEnabled(Save.KEY)
    end,
    OnAccept = function(self, data)
        local text= self.editBox:GetText()
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
    EditBoxOnTextChanged=function(self, data)
        local text= self:GetText()
        text=text:gsub(' ','')
        self:GetParent().button1:SetEnabled(text~='')
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}

StaticPopupDialogs[id..addName..'TEXTURESIZE']={--设置按钮大小
    text=id..' Tools\n'..EMBLEM_SYMBOL..HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_HEIGHT..'\n\n'..DEFAULT..': 30 |cnGREEN_FONT_COLOR:'..	STATUS_TEXT_VALUE..': 8 - 200|r',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    hasEditBox=1,
    button1=SETTINGS,
    button2=CANCEL,
    OnShow = function(self, data)
        self.editBox:SetNumeric(true)
        self.editBox:SetText(e.toolsFrame.size or 30)
    end,
    OnAccept = function(self, data)
        local num= self.editBox:GetNumber()
        e.toolsFrame.size=num
        Save.size=num
        setButtonSize()--设置按钮大小
        print(id, addName, EMBLEM_SYMBOL..HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_HEIGHT, e.toolsFrame.size, '|cnRED_FONT_COLOR:'..RELOADUI..'|r')
    end,

    EditBoxOnTextChanged=function(self, data)
        local num= self:GetNumber()
        self:GetParent().button1:SetEnabled(num>=8 and num<=200)
    end,
    EditBoxOnEscapePressed = function(s)
        s:GetParent():Hide()
    end,
}
--#####
--#####
--主菜单
--#####
local mainMenuTable={
    MOUNT_JOURNAL_FILTER_GROUND,
    MOUNT_JOURNAL_FILTER_AQUATIC,
    MOUNT_JOURNAL_FILTER_FLYING,
    --MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    '-',
    'Shift', 'Alt', 'Ctrl',
    '-',
    SPELLS,
    FLOOR,
    ITEMS,
}

local function InitMenu(self, level, menuList)--主菜单
    local info
    if menuList then
        if menuList==SETTINGS then--设置菜单
            info={--快捷键,设置对话框
                text=SETTINGS_KEYBINDINGS_LABEL,--..(Save.KEY and ' |cnGREEN_FONT_COLOR:'..Save.KEY..'|r' or ''),
                checked=Save.KEY and true or niil,
                func=function ()
                    StaticPopup_Show(id..addName..'KEY')
                end,
            }
            info.disabled=UnitAffectingCombat('player')
            UIDropDownMenu_AddButton(info, level)

            info={
                text=HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,--HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_HEIGHT,--设置按钮大小
                tooltipOnButton=true,
                tooltipTitle=e.toolsFrame.size or 30,
                notCheckable=true,
                func=function()
                    StaticPopup_Show(id..addName..'TEXTURESIZE')
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            if ClassID==11 then--德鲁伊
                info={
                    text= UnitClass('player'),
                    checked=Save.XD,
                    func=function()
                        if Save.XD then
                            Save.XD=nil
                        else
                            Save.XD=true
                        end
                        XDInt()--德鲁伊设置
                        checkSpell()--检测法术
                        checkMount()--检测坐骑
                        setClickAtt()--设置属性
                        CloseDropDownMenus()
                    end
                }
                UIDropDownMenu_AddButton(info,level)
            end

            UIDropDownMenu_AddSeparator(level)
            info={--坐骑展示,每3秒
                text=SLASH_RANDOM3:gsub('/','')..SHOW,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='3 '..SECONDS..MOUNT,
                tooltipText=KEY_MOUSEWHEELUP..e.Icon.mid,
                func=function()
                    specialEffects=nil
                    setMountShow()
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            info={--坐骑特效
                text=	EMOTE171_CMD2:gsub('/','')..SHOW,
                notCheckable=true,
                tooltipOnButton=true,
                tooltipTitle='3 '..SECONDS..EMOTE171_CMD2:gsub('/',''),
                tooltipText=KEY_MOUSEWHEELDOWN..e.Icon.mid,
                func=function()
                    specialEffects=true
                    setMountShow()
                end,
            }
            UIDropDownMenu_AddButton(info, level)

            UIDropDownMenu_AddSeparator(level)
            info={
                text=RESET_POSITION,--还原位置
                func=function()
                    Save.Point=nil
                    setPanelPostion()--设置按钮位置
                    CloseDropDownMenus()
                end,
                tooltipOnButton=true,
                tooltipTitle='Alt +'..e.Icon.right..' '..NPE_MOVE,
                notCheckable=true,
            }
            if not Save.Point then
                info.colorCode='|cff606060'
            end
            UIDropDownMenu_AddButton(info, level)

            info={
                text=id..' Tools',
                isTitle=true,
                notCheckable=true,
            }
            UIDropDownMenu_AddButton(info,level)

        elseif menuList==ITEMS or menuList==SPELLS then
            for ID, _ in pairs(Save.Mounts[menuList]) do
                if menuList==ITEMS then--物品, 二级菜单
                    if not C_Item.IsItemDataCachedByID(ID) then C_Item.RequestLoadItemDataByID(ID) end
                    local name = C_Item.GetItemNameByID(ID)
                    name=name or ('itemID: '..ID)
                    local icon= C_Item.GetItemIconByID(ID)
                    local num=GetItemCount(ID , nil, true, true)
                    num = num>0 and ' |cnGREEN_FONT_COLOR:x'..num..'|r' or ' x'..num
                    local hex
                    local itemQuality= select(3, GetItemInfo(ID))
                    if itemQuality then
                        hex = select(4,GetItemQualityColor(itemQuality))
                        hex= hex and '|c'..hex
                    end
                    info={
                        text= name..num,
                        notCheckable=true,
                        func=function()
                            local text= (icon and '|T'..icon..':0|t' or '').. name.. num
                            text= hex and hex..text..'|r' or text
                            local exits=Save.Mounts[ITEMS][ID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
                            StaticPopup_Show(id..addName..'ITEMS',text,exits , {itemID=ID})
                        end,
                        colorCode= hex,
                        icon=icon
                    }

                else--法术, 二级菜单
                    if not C_Spell.IsSpellDataCached(ID) then C_Spell.RequestLoadSpellData(ID) end
                    local name, _, icon = GetSpellInfo(ID)
                    name=name or ('spellID: '..ID)
                    local known= IsSpellKnown(ID)
                    name= not known and e.Icon.O2.. name or name
                    info={
                        text= name,
                        notCheckable=true,
                        func=function()
                            local text= (icon and '|T'..icon..':0|t' or '').. name
                            local exits=Save.Mounts[SPELLS][ID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
                            StaticPopup_Show(id..addName..'SPELLS',text,exits , {spellID=ID})
                            
                        end,
                        icon=icon,
                        colorCode= not known and '|cff606060',
                    }
                end
                UIDropDownMenu_AddButton(info, level);
            end

        elseif panel[menuList] then--二级菜单
            for _, spellID in pairs(panel[menuList]) do
                local name, _, icon, mountID
                if menuList==ITEMS then
                    name=C_Item.GetItemNameByID(spellID)
                    icon=C_Item.GetItemIconByID(spellID)

                elseif menuList==SPELLS or XD and XD[menuList] then
                    icon=GetSpellTexture(spellID)
                    name, _, icon = GetSpellInfo(spellID)
                else
                    mountID = C_MountJournal.GetMountFromSpell(spellID)
                    if mountID then
                        name, _, icon = C_MountJournal.GetMountInfoByID(mountID)
                    end
                end
                info={
                    text=name or ('ID '..spellID),
                    icon=icon,
                    notCheckable=true,
                }
                if menuList~=ITEMS and menuList~=SPELLS then
                    info.func=function()
                        if mountID then
                            C_MountJournal.SummonByID(mountID)
                        end
                    end
                end
                if menuList==ITEMS then
                    info.text=info.text..' |cff00ff00x|r'..GetItemCount(spellID , nil, true, true)
                elseif menuList==FLOOR and type(boolean)=='number' then
                    local mapInfo = C_Map.GetMapInfo(boolean)
                    if mapInfo and mapInfo.name then
                        info.tooltipText=mapInfo.name
                    else
                        info.tooltipText='MapID: '..boolean
                    end
                end
                UIDropDownMenu_AddButton(info, level);
            end
        end
    else
        for _, type in pairs(mainMenuTable) do
            if type=='-' then
                UIDropDownMenu_AddSeparator()

            elseif type==SPELLS or type==ITEMS then
                local num=getTableNum(type)--检测,表里的数量
                local icon= (type==SPELLS and panel.spellID) and GetSpellTexture(panel.spellID) or panel.itemID and C_Item.GetItemIconByID(panel.itemID)
                info={
                    text=(num>0 and '|cnGREEN_FONT_COLOR:'..num..'|r' or '')..(icon and '|T'..icon..':0|t' or '')..type,
                    menuList=type,
                    hasArrow=num>0,
                    notCheckable=true,
                    colorCode=num==0 and '|cff606060',
                }
                UIDropDownMenu_AddButton(info, level);

            elseif panel[type] then
                local tab=panel[type]
                local num, spellID = #tab, tab[1]
                local icon
                icon =spellID and GetSpellTexture(spellID)
                icon = icon and '|T'..icon..':0|t' or ''
                info={text=(num>1 and '|cnGREEN_FONT_COLOR:'..num..'|r' or num and num>1 and num..' ' or '')..icon..type}
                info.notCheckable=true
                if type~='Shift' and type~='Ctrl' and type~='Alt' then
                    info.menuList=type
                    info.hasArrow= num>0 and true or nil
                end
                info.func=function()
                    local mountID = spellID and C_MountJournal.GetMountFromSpell(spellID)
                    if mountID then
                        C_MountJournal.SummonByID(mountID)
                    end
                end
                if num==0 then
                    info.colorCode='|cff606060'
                elseif type==FLOOR then
                    info.colorCode='|cffff00ff'
                end
                if type==FLOOR then
                    local uiMapID= C_Map.GetBestMapForUnit("player")--当前地图
                    if uiMapID then
                        info.tooltipOnButton=true
                        info.tooltipTitle= REFORGE_CURRENT..' MapID: '..uiMapID
                    end
                end
                UIDropDownMenu_AddButton(info, level);
            end
        end

        UIDropDownMenu_AddSeparator()
        info={
            text=Save.KEY or SETTINGS,
            notCheckable=true,
            menuList=SETTINGS,
            hasArrow=true,
        }
        UIDropDownMenu_AddButton(info)
        
        info={--提示移动
            text='Alt+'..e.Icon.right..NPE_MOVE,
            isTitle=true,
            notCheckable=true
        }
        UIDropDownMenu_AddButton(info)
    end
end

--#############################
--坐骑界面, 添加菜单, 设置提示内容
--#############################
local tabMenuList={
    MOUNT_JOURNAL_FILTER_GROUND,
    MOUNT_JOURNAL_FILTER_AQUATIC,
    MOUNT_JOURNAL_FILTER_FLYING,
    --MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    'Shift', 'Alt', 'Ctrl',
    FLOOR,
}
local function setMountJournal_InitMountButton(button, elementData)--Blizzard_MountCollection.lua
    --local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(elementData.index)
    if not button or not button.spellID or Save.disabled then
        return
    end
    local text
    for _, type in pairs(tabMenuList) do
        local ID=Save.Mounts[type][button.spellID]
        if ID then
            text= text and text..'\n' or ''
            if type==FLOOR then
                local mapInfo = ID<2147483647 and C_Map.GetMapInfo(ID)
                if mapInfo and mapInfo.name then
                    text= text..mapInfo.name
                else
                    text= text..type
                end
            else
                text= text..type
            end
        end
    end
    if text and not button.text then
        button.text=e.Cstr(button, nil, button.name, nil,nil,nil,'RIGHT')--self, size, fontType, ChangeFont, color, layer, justifyH)
        button.text:SetPoint('RIGHT')
        button.text:SetFontObject('GameFontNormal')
        button.text:SetAlpha(0.3)
    end
    if button.text then
        button.text:SetText(text or '')
    end
end

local function setMountJournal_ShowMountDropdown(index)
    if not index and Save.disabled then
        return
    end
    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, isFiltered, isCollected, mountID, isForDragonriding = C_MountJournal.GetDisplayedMountInfo(index)
    if not spellID then
        return
    end
    UIDropDownMenu_AddSeparator()
    local info
    for _, type in pairs(tabMenuList) do
        if (type==MOUNT_JOURNAL_FILTER_DRAGONRIDING and isForDragonriding) or (type~=MOUNT_JOURNAL_FILTER_DRAGONRIDING and not isForDragonriding) then
            if type=='Shift'  or type==FLOOR then
                UIDropDownMenu_AddSeparator()
            end
            info={text=SETTINGS..' '..type..' #'..getTableNum(type)}
            info.checked=Save.Mounts[type][spellID] and true or nil
            if type==FLOOR then
                info.func=function ()
                    local exits=Save.Mounts[FLOOR][spellID] and ERR_ZONE_EXPLORED:format(PROFESSIONS_CURRENT_LISTINGS) or NEW
                    exits= exits.. '\n\n'..WORLD_MAP..' uiMapID: '..(C_Map.GetBestMapForUnit("player") or '')
                    local text= (icon and '|T'..icon..':0|t' or '').. (creatureName or ('spellID: '..spellID))
                    StaticPopup_Show(id..addName..'FLOOR',text,exits , {spellID=spellID})
                end
            else
                info.func=function()
                    if Save.Mounts[type][spellID] then
                        Save.Mounts[type][spellID]=nil
                    else
                        if type=='Shift' or type=='Alt' or type=='Ctrl' then--唯一
                            Save.Mounts[type]={[spellID]=true}
                        else
                            Save.Mounts[type][spellID]=true
                        end
                        removeTable(type, spellID)--移除, 表里, 其他同样的项目
                    end
                    checkMount()--检测坐骑
                    setClickAtt()--设置属性
                    setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
                    local spellLink=GetSpellLink(spellID)
                    print(id, addName, 'Shift + '..e.Icon.left, find and '|cnRED_FONT_COLOR:'..REMOVE..'|r' or '|cnGREEN_FONT_COLOR:'..ADD..'|r', spellLink)
                    MountJournal_UpdateMountList()
                end
            end
            info.tooltipOnButton=true
            info.tooltipTitle=id
            info.tooltipText=addName
            UIDropDownMenu_AddButton(info, level);
        end
    end
end


--######
--初始化
--######
local function Init()
    setPanelPostion()--设置按钮位置
    
    setButtonSize()--设置按钮大小
    
    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')
    XDInt()--德鲁伊设置
    checkSpell()--检测法术
    checkItem()--检测物品
    checkMount()--检测坐骑
    setClickAtt()--设置
    setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
    setCooldown()--设置冷却
    if Save.KEY then
        setKEY()--设置捷键
    end

    --panel:EnableMouseWheel(true)
    panel:RegisterForDrag("RightButton")
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)

    panel:SetScript("OnDragStart", function(self,d )
        if IsAltKeyDown() and d=='RightButton' then
            self:StartMoving()
        end
    end)
    panel:SetScript("OnDragStop", function(self)
        ResetCursor()
        self:StopMovingOrSizing()
        Save.Point={self:GetPoint(1)}
        Save.Point[2]=nil
    end)
    panel:SetScript("OnMouseDown", function(self,d)
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
           -- if not Save.showMenuOnEnter then--即时显示菜单
                ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
            --(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button, autoHideDelay)
        elseif d=='LeftButton' then
            if IsSpellKnown(111400) and not UnitAffectingCombat('player') then--SS爆燃冲刺
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

    panel:SetScript("OnMouseUp", function(self, d)
        if d=='LeftButton' then
            self.border:SetAtlas('bag-reagent-border')
        end
        ResetCursor()
    end)

    panel:SetScript('OnMouseWheel',function(self,d)
        if d==1 then--坐骑展示
            specialEffects=nil
            setMountShow()
        elseif d==-1 then--坐骑特效
            specialEffects=true
            setMountShow()
        end
    end)

    panel:SetScript('OnEnter', function (self)
       --[[
 if Save.showMenuOnEnter then--即时显示菜单
            ToggleDropDownMenu(1,nil,self.Menu, self,15,0 )
        end

]]

        if not UnitAffectingCombat('player') then
            e.toolsFrame:SetShown(true)--设置, TOOLS 框架, 显示
        end
    end)
    panel:SetScript("OnLeave",function(self)
        e.tips:Hide()
        ResetCursor()
        self.border:SetAtlas('bag-reagent-border')
    end)
end
--###########
--加载保存数据
--###########

panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent('PLAYER_REGEN_DISABLED')
panel:RegisterEvent('PLAYER_REGEN_ENABLED')

panel:RegisterEvent('SPELLS_CHANGED')
panel:RegisterEvent('SPELL_DATA_LOAD_RESULT')

panel:RegisterEvent('BAG_UPDATE_DELAYED')

panel:RegisterEvent('MOUNT_JOURNAL_USABILITY_CHANGED')
panel:RegisterEvent('PLAYER_MOUNT_DISPLAY_CHANGED')
panel:RegisterEvent('AREA_POIS_UPDATED')

panel:RegisterEvent('NEW_MOUNT_ADDED')

panel:RegisterEvent('MODIFIER_STATE_CHANGED')

panel:RegisterEvent('ZONE_CHANGED')
panel:RegisterEvent('ZONE_CHANGED_INDOORS')
panel:RegisterEvent('ZONE_CHANGED_NEW_AREA')

panel:RegisterEvent('SPELL_UPDATE_COOLDOWN')
panel:RegisterEvent('SPELL_UPDATE_USABLE')

panel:RegisterEvent('CHAT_MSG_AFK')

panel:RegisterEvent('PLAYER_STARTED_MOVING')

panel:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            local check=e.CPanel('Tools', not Save.disabled, true)
            check:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, 'Tools', e.GetEnabeleDisable(not Save.disabled), NEED..RELOADUI)
            end)

            if not Save.disabled then
                if Save.size then
                    e.toolsFrame.size=Save.size
                end
                Init()--初始
            else
                e.toolsFrame.disabled=true
                panel:UnregisterAllEvents()
                panel:SetShown(false)
            end

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('MountJournal_InitMountButton',setMountJournal_InitMountButton)
        hooksecurefunc('MountJournal_ShowMountDropdown',setMountJournal_ShowMountDropdown)

    elseif event=='PLAYER_REGEN_DISABLED' then
        setClickAtt(true)--设置属性
        if e.toolsFrame:IsShown() then
            e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        setClickAtt()--设置属性
        if panel.Combat then
            setShiftCtrlAltAtt()--设置Shift Ctrl Alt 属性
        end
    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
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
    elseif event=='MOUNT_JOURNAL_USABILITY_CHANGED' or event=='PLAYER_MOUNT_DISPLAY_CHANGED' or event=='AREA_POIS_UPDATED' then
        setClickAtt()--设置属性

    elseif event=='MODIFIER_STATE_CHANGED' then
        local icon
        if arg2==1 then
            icon = arg1:find('SHIFT') and panel.textureModifier.Shift
                or arg1:find('CTRL') and panel.textureModifier.Ctrl
                or arg1:find('ALT') and panel.textureModifier.Alt
        end
        if icon then
            panel.textureModifier:SetTexture(icon)
        end
        panel.textureModifier:SetShown(icon)

    elseif event=='SPELL_UPDATE_COOLDOWN' then
        setCooldown()--设置冷却

    elseif event=='SPELL_UPDATE_USABLE' then
        setTextrue()--设置图标

    elseif event=='CHAT_MSG_AFK' then
        if not UnitAffectingCombat('player') then
            setMountShow()--坐骑展示
        end

    elseif event=='PLAYER_STARTED_MOVING' then
        if not UnitAffectingCombat('player') and e.toolsFrame:IsShown() then
            e.toolsFrame:SetShown(false)--设置, TOOLS 框架,隐藏
        end
    end
end)