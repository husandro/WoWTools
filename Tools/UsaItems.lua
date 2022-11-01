local id, e = ...
local addName=USE..ITEMS
local panel=e.Cbtn(e.toolsFrame, nil, true, nil, nil, nil, {16,16})
panel:SetPoint('TOPRIGHT', e.toolsFrame, 'BOTTOMRIGHT',-30,0)
--panel:SetAlpha(0.1)
local Save= {
        item={
            49040,--[基维斯]
            144341,--[可充电的里弗斯电池]
            40768,--[移动邮箱]
            156833,--[凯蒂的印哨]
            168667,--[布林顿7000]
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
            136849, 139590, 52251,--[自然道标]
            114943,--[终极版侏儒军刀]
            87216,--[热流铁砧]
            85500,--[垂钓翁钓鱼筏]
            37863,--[烈酒的遥控器]
            141605,--[飞行管理员的哨子]
        },
        spell={
            83958,--移动银行
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

local function getFind(ID, spell)
    if spell then
        if IsSpellKnown(ID) then
            if not C_Spell.IsSpellDataCached(ID) then C_Spell.RequestLoadSpellData(ID) end
            return true
        end
    else
        if GetItemCount(ID)>0 or (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID)) then
            if not C_Item.IsItemDataCachedByID(ID) then C_Item.RequestLoadItemDataByID(ID) end
            return true
        end
    end
end

for _, itemID in pairs(Save.item) do
    getFind(itemID)
end
for _, itemID in pairs(Save.spell) do
    getFind(itemID, true)
end
for _, itemID in pairs(Save.equip) do
    getFind(itemID)
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
    local name= slotItemID and C_Item.GetItemNameByID(slotItemID)

    if name and slotItemID~=self.itemID and self:GetAttribute('item2')~=name then
        self:SetAttribute('item2', name)
        self.slotEquipName=name
        local icon = C_Item.GetItemIconByID(slotItemID)
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
            self.count=e.Cstr(self,nil,nil,nil,true)
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
    if complete and not self.quest then
        self.quest=e.Cstr(self, 8)
        self.quest:SetPoint('BOTTOM',0,8)
    end
    if self.quest then
        self.quest:SetText(complete and '|cnGREEN_FONT_COLOR:'..COMPLETE..'|r' or '')
    end
end
local function setItemButton(self, equip)--设置按钮
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("BAG_UPDATE_COOLDOWN")
    self:SetScript('OnEnter', function()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(self.itemID)
        local cd=e.GetItemCooldown(self.itemID)--物品冷却
        if cd then
            e.tips:AddDoubleLine(ON_COOLDOWN, cd, 1,0,0)
        end
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
        self:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
        self:SetScript('OnMouseDown',function()
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
            name = C_Item.GetItemNameByID(itemID)
            icon = C_Item.GetItemIconByID(itemID)
            if name and icon then
                Button[index]=e.Cbtn2(nil, panel)
                Button[index].texture:SetShown(true)
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
                    Button[index]=e.Cbtn2(nil, panel)
                    Button[index].texture:SetShown(true)
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
            name = C_Item.GetItemNameByID(itemID)
            local itemEquipLoc, icon2 = select(4, GetItemInfoInstant(itemID))
            icon =icon2 or C_Item.GetItemIconByID(itemID)
            local slot=itemEquipLoc and e.itemSlotTable[itemEquipLoc]
            if name and icon and slot then
                Button[index]=e.Cbtn2(nil, panel)
                Button[index].texture:SetShown(true)
                Button[index].itemID=itemID
                Button[index].slot=slot
                
                
                setItemButton(Button[index], true)
                e.ToolsSetButtonPoint(Button[index])--设置位置
                Button[index]:SetAttribute('type', 'item')
                
                Button[index]:SetAttribute('item', name)
                --Button[index]:SetAttribute('target-slot', slot)
                
                Button[index]:SetAttribute('type2', 'item')
                --Button[index]:SetAttribute('target-slot2', slot)

                Button[index].texture:SetTexture(icon)
                index=index+1
            end
        end
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_REGEN_ENABLED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1== id then
        Save= WoWToolsSave and WoWToolsSave[addName..'Tools'] or Save
        if not e.toolsFrame.disabled then
            C_Timer.After(2, function()
                if UnitAffectingCombat('player') then
                    panel.combat= true
                else
                    Init()--初始
                end
            end)
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

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
    end
end)