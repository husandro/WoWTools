local e= select(2, ...)

local function get_Find(ID, spell)
    if spell then
        if IsSpellKnownOrOverridesKnown(ID) then
            return true
        end
    else
        if C_Item.GetItemCount(ID)>0 or (PlayerHasToy(ID) and C_ToyBox.IsToyUsable(ID)) then
            return true
        end
    end
end

local function set_button_Event(self, isShown)--事件
    local tab={}
    if self.spellID then
        tab= {
            'SPELL_UPDATE_USABLE',
            'SPELL_UPDATE_COOLDOWN',
        }
    elseif self.itemID then
        tab={
            'BAG_UPDATE_DELAYED',
            'BAG_UPDATE_COOLDOWN'
        }
    end
    if isShown then
        FrameUtil.RegisterFrameForEvents(self, tab)
    else
        FrameUtil.UnregisterFrameForEvents(self, tab)
    end
end











--####
--物品
--####
local function set_Equip_Slot(self)--装备
    if UnitAffectingCombat('player') then
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    local slotItemID=GetInventoryItemID('player', self.slot)
    local slotItemLink=GetInventoryItemLink('player', self.slot)
    local name= slotItemLink and C_Item.GetItemInfo(slotItemLink) or slotItemID and C_Item.GetItemNameByID(slotItemID)
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

local function set_Item_Count(self)--数量
    local num = C_Item.GetItemCount(self.itemID, false, true, true)
    if not PlayerHasToy(self.itemID) then
        if num~=1 and not self.count then
            self.count=WoWTools_LabelMixin:Create(self, {size=10, color=true})--10,nil,nil,true)
            self.count:SetPoint('BOTTOMRIGHT',-2, 9)
        end
        if self.count then
            self.count:SetText(num~=1 and num or '')
        end
    end
    self.texture:SetDesaturated(num==0 and not PlayerHasToy(self.itemID))
end

local function set_Bling_Quest(self)--布林顿任务
    local complete=C_QuestLog.IsQuestFlaggedCompleted(56042)
    if not self.quest then
        self.quest=WoWTools_LabelMixin:Create(self, {size=8})
        self.quest:SetPoint('BOTTOM',0,8)
    end
    self.quest:SetText(complete and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '完成' or COMPLETE)..'|r' or '|A:questlegendary:0:0|a')
end











local function init_Item_Button(self, equip)--设置按钮
    self:SetScript('OnEnter', function()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetItemByID(self.itemID)
        e.tips:Show()
        WoWTools_BagMixin:Find(true, {itemID= self.itemID})--查询，背包里物品
    end)
    self:SetScript('OnLeave', function() WoWTools_BagMixin:Find(false) GameTooltip_Hide() end)
    self:SetScript("OnEvent", function(self2, event, arg1)
        if event=='BAG_UPDATE_DELAYED' then
            set_Item_Count(self2)
        elseif event=='BAG_UPDATE_COOLDOWN' then
            e.SetItemSpellCool(self2, {item=self2.itemID})
        elseif event=='QUEST_COMPLETE' then
            set_Bling_Quest(self2)
        elseif event=='PLAYER_EQUIPMENT_CHANGED' or 'PLAYER_REGEN_ENABLED' then
            set_Equip_Slot(self2)
        end
    end)
    self:SetScript('OnShow', function(self2)
        set_button_Event(self2, true)--事件
        e.SetItemSpellCool(self, {item=self.itemID})
        set_Item_Count(self)
    end)
    self:SetScript('OnHide', function(self2)
        set_button_Event(self2)--事件
    end)

    if equip then
        self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        self:SetScript('OnMouseUp',function()
            local frame=PaperDollFrame
            if frame and not frame:IsVisible() then
                ToggleCharacter("PaperDollFrame");
            end
        end)
        set_Equip_Slot(self)
    end
    if self.itemID==168667 or self.itemID==87214 or self==111821 then--布林顿任务
        self:RegisterEvent('QUEST_COMPLETE')
        set_Bling_Quest(self)
    end
end













--法术
local function set_Spell_Count(self)--次数
    local data= self.spellID and C_Spell.GetSpellCharges(self.spellID) or {}
    local num, max= data.currentCharges, data.maxCharges
    if max and max>1 and not self.count then
        self.count=WoWTools_LabelMixin:Create(self, {color=true})--nil,nil,nil,true)
        self.count:SetPoint('BOTTOMRIGHT',-2, 9)
    end
    if self.count then
        self.count:SetText((max and max>1) and num or '')
    end
    self.texture:SetDesaturated(num and num>0)
end

local function init_Spell_Button(self)--设置按钮
    self:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:SetSpellByID(self2.spellID)
        e.tips:Show()
    end)
    self:SetScript('OnLeave', GameTooltip_Hide)
    self:SetScript("OnEvent", function(self2, event)
        if event=='SPELL_UPDATE_USABLE' then
            set_Spell_Count(self2)
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            e.SetItemSpellCool(self2, {spell=self2.spellID})
        end
    end)
    self:SetScript('OnShow', function(self2)
        set_button_Event(self2, true)
        e.SetItemSpellCool(self2, {spell=self2.spellID})
        set_Spell_Count(self2)
    end)
    self:SetScript('OnHide', function(self2)
        set_button_Event(self2)
    end)
end















local function Init()
    WoWTools_ToolsButtonMixin:AddOptions(function(_, layout)
        e.AddPanel_Header(layout, WoWTools_UseItemsMixin.addName)
    end)

    for _, itemID in pairs(WoWTools_UseItemsMixin.Save.item) do
        local name ,icon
        if get_Find(itemID) then
            name = C_Item.GetItemNameByID(itemID)
            icon = C_Item.GetItemIconByID(itemID)
            if name and icon then
                local btn= WoWTools_ToolsButtonMixin:CreateButton({
                    name='UsaItems_ItemID_'..itemID,
                    tooltip='|T'..icon..':0|t'..e.cn(name, {itemID=itemID, isName=true}),
                })
                if btn then
                    btn.itemID=itemID
                    init_Item_Button(btn)

                    btn:SetAttribute('type', 'item')
                    btn:SetAttribute('item', name)
                    btn.texture:SetTexture(icon)
                end
            end
        end
   end

    for _, itemID in pairs(WoWTools_UseItemsMixin.Save.equip) do
        local name ,icon
        if C_Item.GetItemCount(itemID)>0 then
            name = C_Item.GetItemNameByID(itemID)
            local itemEquipLoc, icon2 = select(4, C_Item.GetItemInfoInstant(itemID))
            icon =icon2 or C_Item.GetItemIconByID(itemID)
            local slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)

            if name and icon and slot then
                local btn= WoWTools_ToolsButtonMixin:CreateButton({
                    name='UsaItems_Equip_ItemID_'..itemID,
                    tooltip='|T'..icon..':0|t'..e.cn(name, {itemID=itemID, isName=true}),
                })
                if btn then
                    btn.itemID=itemID
                    btn.slot=slot
                    init_Item_Button(btn, true)
                    btn:SetAttribute('type', 'item')
                    btn:SetAttribute('item', name)
                    btn:SetAttribute('type2', 'item')
                    btn.texture:SetTexture(icon)
                end
            end
        end
    end

    for _, spellID in pairs(WoWTools_UseItemsMixin.Save.spell) do
        if IsSpellKnownOrOverridesKnown(spellID) then
            local name= C_Spell.GetSpellName(spellID)
            local icon= C_Spell.GetSpellTexture(spellID)
            if name and icon then
                local btn= WoWTools_ToolsButtonMixin:CreateButton({
                    name='UsaItems_SpellID_'..spellID,
                    tooltip='|T'..icon..':0|t'..e.cn(name, {spellID=spellID, isName=true}),
                })
                if btn then
                    btn.spellID=spellID
                    init_Spell_Button(btn)
                    btn:SetAttribute('type', 'spell')
                    btn:SetAttribute('spell', name)
                    btn.texture:SetTexture(icon)
                end
            end
        end
    end
end

















function WoWTools_UseItemsMixin:Init_All_Buttons()
    Init()
end