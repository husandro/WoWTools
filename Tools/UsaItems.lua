local id, e = ...
local addName=USE_ITEM
local panel=e.Cbtn(e.toolsFrame, nil, true, nil, nil, nil, {20,20})
panel:SetPoint('BOTTOMLEFT', e.toolsFrame, 'TOPRIGHT',-2,5)
panel:SetAlpha(0.1)
local Save= {
        item={
            40768,--[移动邮箱]
            --156833,--[凯蒂的印哨]
            194885,--[欧胡纳栖枝]收信
            114943,--[终极版侏儒军刀]
            168667,--[布林顿7000]

            49040,--[基维斯]
            144341,--[可充电的里弗斯电池]

            128353,--[海军上将的罗盘]
            167075,--[超级安全传送器：麦卡贡]
            168222,--[加密的黑市电台]
            184504,184501, 184503, 184502, 184500, 64457,--[侍神者的袖珍传送门：奥利波斯]
            172924,--[虫洞发生器：暗影界]
            168807,--[虫洞发生器：库尔提拉斯]
            168808,--[虫洞发生器：赞达拉]
            151652,--[虫洞发生器：阿古斯]
            112059,--[虫洞离心机]
            87215,--[虫洞发生器：潘达利亚]
            48933,--[虫洞发生器：诺森德]
            30542,--[空间撕裂器 - 52区]
            151016,--[开裂的死亡之颅]
            136849, 52251,--[自然道标]
            139590,--[传送卷轴：拉文霍德]
            87216,--[热流铁砧]
            85500,--[垂钓翁钓鱼筏]
            37863,--[烈酒的遥控器]
            --141605,--[飞行管理员的哨子]
        },
        spell={
            83958,--移动银行
            69046,--[呼叫大胖],种族特性
            50977,--[黑锋之门]
            193753,--[传送：月光林地]
            556,--[星界传送]
            18960,--[梦境行者]
            126892,--[禅宗朝圣]
        },
        equip={
            65274,65360, 63206, 63207, 63352, 63353,--协同披风
            103678,--迷时神器
            142469,--魔导大师的紫罗兰印戒
            144391, 144392,--拳手的重击指环
        }
}

local function findType(type, ID)
    for index, ID2 in pairs(Save[type]) do
        if ID2==ID then
            return index
        end
    end
end

local function getFind(ID, spell)
    if spell then
        if IsSpellKnown(ID) then
            return true
        end
    else
        if GetItemCount(ID)>0 or (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID)) then
            return true
        end
    end
end


--###########
--添加, 对话框
--###########
StaticPopupDialogs[id..addName..'REMOVE']={
    text=id..' '..addName..'\n\n%s',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    button1='|cnRED_FONT_COLOR:'..REMOVE..'|r',
    button2=CANCEL,
    OnAccept = function(self, data)
        if data.clearAll then
            Save[data.type]={}
            C_UI.Reload()
        else
            if Save[data.type][data.index] and Save[data.type][data.index]==data.ID then
                table.remove(Save[data.type], data.index)
                print(id, addName, '|cnGREEN_FONT_COLOR:'..REMOVE..'|r'..COMPLETE, data.name, '|cnRED_FONT_COLOR:'..REQUIRES_RELOAD..'|r')
            else
                print(id, addName,'|cnGREEN_FONT_COLOR:'..ERROR_CAPS..'|r',	BROWSE_NO_RESULTS, data.name)
            end
        end
    end,
}

StaticPopupDialogs[id..addName..'RESETALL']={--重置所有
    text=id..' '..addName..'\n\n'..RESET_ALL_BUTTON_TEXT..'\n\n'..RELOADUI,
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    button1=RESET,
    button2=CANCEL,
    OnAccept = function(self, data)
        Save=nil
        C_UI.Reload()
    end,
}

StaticPopupDialogs[id..addName..'ADD']={--添加, 移除
    text=id..' '..addName..'\n\n%s: %s',
    whileDead=1,
    hideOnEscape=1,
    exclusive=1,
    timeout = 60,
    button1=ADD,
    button2=CANCEL,
    button3=REMOVE,
    OnShow = function(self, data)
        local find=findType(data.type, data.ID)
        data.index=find
        self.button3:SetEnabled(find)
        self.button1:SetEnabled(not find)
    end,
    OnAccept = function(self, data)
        table.insert(Save[data.type], data.ID)
        print(id, addName, '|cnGREEN_FONT_COLOR:'..ADD..'|r', COMPLETE, data.name, REQUIRES_RELOAD)
    end,
    OnAlt = function(self, data)
        table.remove(Save[data.type], data.index)
        print(id, addName, '|cnRED_FONT_COLOR:'..REMOVE..'|r', COMPLETE, data.name, REQUIRES_RELOAD)
    end,
}

--#####
--主菜单
--#####
local function InitMenu(self, level, type)--主菜单
    local info
    if type then
        local cleraAllText='|cnRED_FONT_COLOR:'..(e.onlyChinse and '全部清除' or CLEAR_ALL)..'|r '..(type=='spell' and (e.onlyChinse and '法术' or SPELLS) or type=='item' and (e.onlyChinse and '物品' or ITEMS) or (e.onlyChinse and '装备' or EQUIPSET_EQUIP))..' #'..'|cnGREEN_FONT_COLOR:'..#Save[type]..'|r'
        info={--清除全部
            text=cleraAllText,
            notCheckable=true,
            func=function()
                StaticPopup_Show(id..addName..'REMOVE', cleraAllText ,nil, {type=type, clearAll=true})
            end,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '重新加载UI' or RELOADUI
            }
        UIDropDownMenu_AddButton(info, level)
        UIDropDownMenu_AddSeparator(level)

        for index, ID in pairs(Save[type]) do
            local name, icon, _
            if type=='spell' then
                name, _, icon =GetSpellInfo(ID)
            else
                name= C_Item.GetItemNameByID(ID..'')
                icon=C_Item.GetItemIconByID(ID..'')
            end
            name=name or (type..'ID '..ID)
            local text=(icon and '|T'..icon..':0|t' or '') ..name
            info={
                text= name,
                notCheckable=true,
                icon=icon,
                func=function()
                    StaticPopup_Show(id..addName..'REMOVE',text ,nil, {type=type, index=index, name=text, ID=ID})
                end,
                tooltipOnButton=true,
                tooltipTitle='|cnRED_FONT_COLOR:'..REMOVE..'|r',
            }
            if (type=='spell' and not IsSpellKnown(ID)) or ((type=='item' or type=='equip') and GetItemCount(ID)==0 and not PlayerHasToy(ID)) then
                info.text= e.Icon.O2..info.text
                info.colorCode='|cff606060'
            end
            UIDropDownMenu_AddButton(info, level)

        end
    else
        local tab={
            [e.onlyChinse and '物品' or ITEMS]='item',
            [e.onlyChinse and '法术' or SPELLS]='spell',
            [e.onlyChinse and '装备' or EQUIPSET_EQUIP]='equip'
        }
        for text, type2 in pairs(tab) do
            info={
                text=text..' |cnGREEN_FONT_COLOR:'..#Save[type2]..'|r',
                notCheckable=true,
                hasArrow=true,
                menuList=type2,
            }
            UIDropDownMenu_AddButton(info, level);
        end
        UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinse and '重新加载UI' or RELOADUI,
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle='/reload',
            func=function()
                C_UI.Reload()
            end
        }
        UIDropDownMenu_AddButton(info, level);
        UIDropDownMenu_AddSeparator(level)
        info={
            text= e.onlyChinse and '重置' or RESET,
            colorCode='|cffff0000',
            notCheckable=true,
            tooltipOnButton=true,
            tooltipTitle= e.onlyChinse and '全部重置' or RESET_ALL_BUTTON_TEXT,
            tooltipText= e.onlyChinse and '重新加载UI' or RELOADUI,
            func=function()
                StaticPopup_Show(id..addName..'RESETALL')
            end
        }
        UIDropDownMenu_AddButton(info, level);
        UIDropDownMenu_AddButton({text=addName, isTitle=true, notCheckable=true}, level);
        UIDropDownMenu_AddButton({text= e.onlyChinse and '拖曳: 物品, 法术, 装备' or (DRAG_MODEL..', '..SPELLS..', '..ITEMS), isTitle=true, notCheckable=true}, level);
    end
end


--####
--物品
--####
local function setEquipSlot(self)--装备
    if UnitAffectingCombat('player') then
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    local slotItemID=GetInventoryItemID('player', self.slot)
    local slotItemLink=GetInventoryItemLink('player', self.slot)
    local name= slotItemLink and GetItemInfo(slotItemLink) or slotItemID and C_Item.GetItemNameByID(slotItemID..'')
    if name and slotItemID~=self.itemID and self:GetAttribute('item2')~=name then
        self:SetAttribute('item2', name)
        self.slotEquipName=name
        local icon = C_Item.GetItemIconByID(slotItemID..'')
        if icon and not self.slotTexture then--装备前的物品,提示
            self.slotequipedTexture=self:CreateTexture(nil, 'OVERLAY')
            self.slotequipedTexture:SetPoint('BOTTOMRIGHT',-7,9)
            self.slotequipedTexture:SetSize(8,8)
            self.slotequipedTexture:SetTexture(icon)
            self.slotequipedTexture:SetDrawLayer('OVERLAY', 2)
        end
    elseif not name then
        self:SetAttribute('item2', nil)
    end
    if slotItemID==self.itemID and not self.equipedTexture then--自身已装备提示
        self.equipedTexture=self:CreateTexture(nil, 'OVERLAY')
        self.equipedTexture:SetPoint('BOTTOMLEFT',2,5)
        self.equipedTexture:SetSize(15,15)
        self.equipedTexture:SetAtlas('charactercreate-icon-customize-body-selected')
        self.equipedTexture:SetDrawLayer('OVERLAY', 2)
    end

    if self.equipedTexture then
        self.equipedTexture:SetShown(slotItemID==self.itemID)
    end
    if  self.slotequipedTexture then
        self.slotequipedTexture:SetShown(slotItemID==self.itemID)
    end
    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

local function setItemCount(self)--数量
    if not PlayerHasToy(self.itemID) then
        local num = GetItemCount(self.itemID,nil,true,true)
        if num~=1 and not self.count then
            self.count=e.Cstr(self,10,nil,nil,true)
            self.count:SetPoint('BOTTOMRIGHT',-2, 9)
        end
        if self.count then
            self.count:SetText(num~=1 and num or '')
        end
    end
    self.texture:SetDesaturated(num==0 and not PlayerHasToy(self.itemID))
end

local function setItemCooldown(self)--冷却
    local startTime, duration = GetItemCooldown(self.itemID)
    e.Ccool(self,startTime, duration,nil, true)
end
local function setBlingtron(self)--布林顿任务
    local complete=C_QuestLog.IsQuestFlaggedCompleted(56042)
    if not self.quest then
        self.quest=e.Cstr(self, 8)
        self.quest:SetPoint('BOTTOM',0,8)
    end
    self.quest:SetText(complete and '|cnGREEN_FONT_COLOR:'..COMPLETE..'|r' or e.Icon.info2)
end
local function setItemButton(self, equip)--设置按钮
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:SetScript('OnEnter', function()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(self.itemID)
        e.tips:Show()
    end)
    self:SetScript('OnLeave', function() e.tips:Hide() end)
    self:SetScript("OnEvent", function(self2, event, arg1)
        if event=='BAG_UPDATE_DELAYED' then
            setItemCount(self2)
        elseif event=='BAG_UPDATE_COOLDOWN' then
            setItemCooldown(self2)
        elseif event=='QUEST_COMPLETE' then
            setBlingtron(self2)
        elseif event=='PLAYER_EQUIPMENT_CHANGED' or 'PLAYER_REGEN_ENABLED' then
            setEquipSlot(self2)
        end
    end)
    setItemCooldown(self)
    setItemCount(self)
    if equip then
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        self:SetScript('OnMouseUp',function()
            local frame=PaperDollFrame
            if frame and not frame:IsVisible() then
                ToggleCharacter("PaperDollFrame");
            end
        end)
        setEquipSlot(self)
    end
    if self.itemID==168667 or self.itemID==87214 or self==111821 then--布林顿任务
        self:RegisterEvent('QUEST_COMPLETE')
        setBlingtron(self)
    end
end

--###
--法术
--###
local function setSpellCount(self)--次数
    local num, max= GetSpellCharges(self.spellID)
    if max and max>1 and not self.count then
        self.count=e.Cstr(self,nil,nil,nil,true)
        self.count:SetPoint('BOTTOMRIGHT',-2, 9)
    end
    if self.count then
        self.count:SetText((max and max>1) and num or '')
    end
    self.texture:SetDesaturated(num and num>0)
end
local function setSpellCooldown(self)--冷却
    local start, duration, _, modRate = GetSpellCooldown(self.spellID)
    e.Ccool(self, start, duration, modRate, true)
end
local function setSpellButton(self)--设置按钮
    self:RegisterEvent("SPELL_UPDATE_USABLE")
    self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    self:SetScript('OnEnter', function()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetSpellByID(self.spellID)
        e.tips:Show()
    end)
    self:SetScript('OnLeave', function() e.tips:Hide() end)
    self:SetScript("OnEvent", function(self2, event, arg1)
        if event=='SPELL_UPDATE_USABLE' then
            setSpellCount(self2)
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            setSpellCooldown(self2)
        end
    end)
    setSpellCooldown(self)
    setSpellCount(self)
end
--###
--初始
--###
local Button={}
local function Init()
   local index=1
   for _, itemID in pairs(Save.item) do
        local name ,icon
        if getFind(itemID) then
            name = C_Item.GetItemNameByID(itemID..'')
            icon = C_Item.GetItemIconByID(itemID..'')
            if name and icon then
                Button[index]=e.Cbtn2(nil, e.toolsFrame, true, true)
                Button[index].itemID=itemID
                setItemButton(Button[index])
                e.ToolsSetButtonPoint(Button[index])--设置位置
                Button[index]:SetAttribute('type', 'item')
                Button[index]:SetAttribute('item', name)
                Button[index].texture:SetTexture(icon)
                index=index+1
            end
        end
   end
   for _, spellID in pairs(Save.spell) do
        if IsSpellKnown(spellID) then
            local name, _, icon = GetSpellInfo(spellID)
            if name and icon then
                if name and icon then
                    Button[index]=e.Cbtn2(nil, e.toolsFrame, true, true)
                    Button[index].spellID=spellID
                    setSpellButton(Button[index])
                    e.ToolsSetButtonPoint(Button[index])--设置位置
                    Button[index]:SetAttribute('type', 'spell')
                    Button[index]:SetAttribute('spell', name)
                    Button[index].texture:SetTexture(icon)
                    index=index+1
                end
            end
        end
   end
   for _, itemID in pairs(Save.equip) do
        local name ,icon
        if GetItemCount(itemID)>0 then
            name = C_Item.GetItemNameByID(itemID..'')
            local itemEquipLoc, icon2 = select(4, GetItemInfoInstant(itemID))
            icon =icon2 or C_Item.GetItemIconByID(itemID..'')
            local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]
            if name and icon and slot then
                Button[index]=e.Cbtn2(nil, e.toolsFrame, true, true)
                Button[index].itemID=itemID
                Button[index].slot=slot
                setItemButton(Button[index], true)
                e.ToolsSetButtonPoint(Button[index])--设置位置
                Button[index]:SetAttribute('type', 'item')
                Button[index]:SetAttribute('item', name)
                Button[index]:SetAttribute('type2', 'item')
                Button[index].texture:SetTexture(icon)
                index=index+1
            end
        end
    end

    panel.Menu=CreateFrame("Frame",nil, panel, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(panel.Menu, InitMenu, 'MENU')

    panel:SetScript('OnMouseDown',function(self, d)--添加, 移除
        local infoType, itemID, itemLink ,spellID= GetCursorInfo()
        if infoType == "item" and itemID and itemLink then
            local itemEquipLoc= select(4, GetItemInfoInstant(itemLink))
            local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]
            local type = slot and 'equip' or 'item'
            local text = slot and EQUIPSET_EQUIP or ITEMS
            local icon = C_Item.GetItemIconByID(itemLink)
            StaticPopup_Show(id..addName..'ADD', text , (icon and '|T'..icon..':0|t' or '')..itemLink, {type=type, name=itemLink, ID=itemID})
            ClearCursor()

        elseif infoType =='spell' and spellID then
            local spellLink=GetSpellLink(spellID) or (SPELLS..' ID: '..spellID)
            local icon=GetSpellTexture(spellID)
            StaticPopup_Show(id..addName..'ADD', SPELLS , (icon and '|T'..icon..':0|t' or '')..spellLink, {type='spell', name=spellLink, ID=spellID})
            ClearCursor()

        elseif d=='LeftButton' then
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddDoubleLine(DRAG_MODEL, ADD)
            e.tips:AddDoubleLine(SPELLS, ITEMS, 0,1,0, 0,1,0)
            e.tips:AddDoubleLine(MAINMENU or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
            e.tips:Show()
        elseif d=='RightButton' then
            ToggleDropDownMenu(1,nil,self.Menu, self, 15,0)
        end
    end)
    panel:SetScript('OnEnter',function (self)
        self:SetAlpha(1.0)
    end)
    panel:SetScript('OnLeave', function (self)
        self:SetAlpha(0.1)
        e.tips:Hide()
    end)
    panel:SetScript('OnMouseUp',function ()
        panel:SetAlpha(0.1)
    end)
end


--#############
--玩具界面, 菜单
--#############
local function setToyBox_ShowToyDropdown(itemID, anchorTo, offsetX, offsetY)
    if e.toolsFrame.disabled or not itemID then
        return
    end
    local find = findType('item', itemID)
    local info={
            text='|A:'..e.Icon.icon..':0:0|a'..addName,
            checked=find and true or nil,
            tooltipOnButton=true,
            tooltipTitle=addName,
            tooltipText=id..'\n\n|cnRED_FONT_COLOR:'..REQUIRES_RELOAD..'|r',
            func=function()
                if find then
                    table.remove(Save.item, find)
                else
                    table.insert(Save.item, itemID)
                end
                local name= select(2, GetItemInfo(itemID)) or (ITEMS..' ID: '..itemID)
                print(id, addName, find and '|cnRED_FONT_COLOR:'..REMOVE..'|r' or '|cnGREEN_FONT_COLOR:'..ADD..'|r', name, 	REQUIRES_RELOAD)
                ToySpellButton_UpdateButton(anchorTo)
            end,
        }
    UIDropDownMenu_AddButton(info, 1)

    UIDropDownMenu_AddSeparator()
    UIDropDownMenu_AddButton({
        text=ITEMS..'ID: '..itemID,
        isTitle=true,
        notCheckable=true,
    }, 1)
end
local function setToySpellButton_UpdateButton(self)--标记, 是否已选取
    if e.toolsFrame.disabled or not self.itemID then
        return
    end
    local find = findType('item', self.itemID)
    if find and not self.useitem then
        self.useitem=self:CreateTexture(nil, 'ARTWORK')
        self.useitem:SetPoint('TOPLEFT',self.name,'BOTTOMLEFT',24,0)
        self.useitem:SetAtlas(e.Icon.icon)
        self.useitem:SetSize(12, 12)
    end
    if self.useitem then
        self.useitem:SetShown(find)
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:RegisterEvent("PLAYER_REGEN_ENABLED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        if WoWToolsSave and not WoWToolsSave[addName..'Tools'] then
            panel:SetAlpha(1)
        end

        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then

            for _, ID in pairs(Save.item) do
                e.LoadSpellItemData(ID)--加载法术, 物品数据
            end
            for _, ID in pairs(Save.spell) do
                e.LoadSpellItemData(ID, true)--加载法术, 物品数据
            end
            for _, ID in pairs(Save.equip) do
                e.LoadSpellItemData(ID)--加载法术, 物品数据
            end

            C_Timer.After(1.6, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                end
            end)
        else
            panel:UnregisterAllEvents()
            panel:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName..'Tools']=Save
        end

    elseif event=='PLAYER_REGEN_ENABLED' then
        if panel.combat then
            panel.combat=nil
            Init()--初始
        end
        panel:UnregisterEvent("PLAYER_REGEN_ENABLED")

    elseif event=='ADDON_LOADED' and arg1=='Blizzard_Collections' then
        hooksecurefunc('ToyBox_ShowToyDropdown', setToyBox_ShowToyDropdown)
        hooksecurefunc('ToySpellButton_UpdateButton', setToySpellButton_UpdateButton)
    end
end)
