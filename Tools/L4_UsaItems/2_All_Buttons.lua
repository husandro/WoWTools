

local function Save()
    return WoWToolsPlayerDate['Tools_UseItems']
end

local function Set_Button_Event(self, isShown)--事件
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
local function Set_Equip_Slot(btn)--装备
    --if btn and btn.CanChangeTalents and not btn:CanChangeTalents() or InCombatLockdown() then
    if not btn:CanChangeAttribute() then
        btn:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    local slotItemID=GetInventoryItemID('player', btn.slot)
    local slotItemLink=GetInventoryItemLink('player', btn.slot)
    local name= slotItemLink and C_Item.GetItemInfo(slotItemLink) or (slotItemID and C_Item.GetItemNameByID(slotItemID))
    if name and slotItemID~=btn.itemID and btn:GetAttribute('item2')~=name then
        btn:SetAttribute('item2', name)
        btn.slotEquipName=name
        local icon = select(5, C_Item.GetItemInfoInstant(slotItemID))
        if icon and not btn.slotTexture then--装备前的物品,提示
            btn.slotequipedTexture=btn:CreateTexture(nil, 'OVERLAY')
            btn.slotequipedTexture:SetPoint('BOTTOMRIGHT',-7,9)
            btn.slotequipedTexture:SetSize(8,8)
            btn.slotequipedTexture:SetTexture(icon)
            btn.slotequipedTexture:SetDrawLayer('OVERLAY', 2)
        end
    elseif not name then
        btn:SetAttribute('item2', nil)
    end
    if slotItemID==btn.itemID and not btn.equipedTexture then--自身已装备提示
        btn.equipedTexture=btn:CreateTexture(nil, 'OVERLAY')
        btn.equipedTexture:SetPoint('BOTTOMLEFT',2,5)
        btn.equipedTexture:SetSize(15,15)
        btn.equipedTexture:SetAtlas('charactercreate-icon-customize-body-selected')
        btn.equipedTexture:SetDrawLayer('OVERLAY', 2)
    end

    if btn.equipedTexture then
        btn.equipedTexture:SetShown(slotItemID==btn.itemID)
    end
    if  btn.slotequipedTexture then
        btn.slotequipedTexture:SetShown(slotItemID==btn.itemID)
    end
    btn:UnregisterEvent('PLAYER_REGEN_ENABLED')
end


--数量
local function Set_Item_Count(btn)
    local num = C_Item.GetItemCount(btn.itemID, false, true, true) or 0
    local hasToy= PlayerHasToy(btn.itemID)
    if not PlayerHasToy(btn.itemID) then
        if num>1 and not btn.count then
            btn.count=WoWTools_LabelMixin:Create(btn, {size=10, {r=1,g=1,b=1}})--10,nil,nil,true)
            btn.count:SetPoint('BOTTOMRIGHT',-2, 9)
        end
    end
    if btn.count then
        if not hasToy and num>1 then
            btn.count:SetText(num)
        else
            btn.count:SetText('')
        end
    end
    btn.texture:SetDesaturated(num<1 and not hasToy)
end


--布林顿任务
local function Set_Bling_Quest(btn)
    local complete=C_QuestLog.IsQuestFlaggedCompleted(56042)
    if not btn.quest then
        btn.quest=WoWTools_LabelMixin:Create(btn, {size=8})
        btn.quest:SetPoint('BOTTOM',0,8)
    end
    btn.quest:SetText(complete and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '完成' or COMPLETE)..'|r' or '|A:questlegendary:0:0|a')
end










--设置按钮
local function Set_Item_Button(btn, itemID, equipSlotID)
    btn.itemID= itemID
    btn.slot= equipSlotID

    local hasToy
    if equipSlotID then
        btn:SetAttribute('type', 'item')
        btn:SetAttribute('type2', 'item')

        btn:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        btn:SetScript('OnMouseUp',function()
            local frame=PaperDollFrame
            if frame and not frame:IsVisible() then
                ToggleCharacter("PaperDollFrame");
            end
        end)
        Set_Equip_Slot(btn)

    else
        hasToy= PlayerHasToy(itemID)
        if hasToy then
            btn:SetAttribute('type', 'toy')
            btn:SetAttribute('toy', itemID)
        else
            btn:SetAttribute('type', 'item')
        end
    end

    if C_Item.IsItemDataCachedByID(itemID) then
        btn.texture:SetTexture(C_Item.GetItemIconByID(itemID or 134400))
        if not hasToy then
            btn:SetAttribute('item', C_Item.GetItemNameByID(itemID))
        end
    else
        ItemEventListener:AddCancelableCallback(itemID, function()
            btn.texture:SetTexture(C_Item.GetItemIconByID(itemID or 134400))
            if not hasToy then
                if not btn:CanChangeAttribute() then
                    EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", function(owner)
                        btn:SetAttribute('item', C_Item.GetItemNameByID(itemID))
                        EventRegistry:UnregisterCallback('PLAYER_REGEN_ENABLED', owner)
                    end)
                else
                    btn:SetAttribute('item', C_Item.GetItemNameByID(itemID))
                end
            end
        end)
    end

    if itemID==168667 or itemID==87214 or itemID==111821 then--布林顿任务
        btn:RegisterEvent('QUEST_COMPLETE')
        Set_Bling_Quest(btn)
    end

    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        if PlayerHasToy(self.itemID) then
            GameTooltip:SetToyByItemID(self.itemID)
        else
            GameTooltip:SetItemByID(self.itemID)
        end
        GameTooltip:Show()
        WoWTools_BagMixin:Find(true, {itemID=self.itemID})--查询，背包里物品
    end)

    btn:SetScript('OnLeave', function()
        WoWTools_BagMixin:Find(false)
        GameTooltip_Hide()
    end)

    btn:SetScript("OnEvent", function(self, event)
        if event=='BAG_UPDATE_DELAYED' then
            Set_Item_Count(self)
        elseif event=='BAG_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID})
        elseif event=='QUEST_COMPLETE' then
            Set_Bling_Quest(self)
        elseif event=='PLAYER_EQUIPMENT_CHANGED' or 'PLAYER_REGEN_ENABLED' then
            Set_Equip_Slot(self)
        end
    end)

    btn:SetScript('OnShow', function(self)
        Set_Button_Event(self, true)--事件
        WoWTools_CooldownMixin:SetFrame(self, {itemID=self.itemID})
        Set_Item_Count(self)
    end)

    btn:SetScript('OnHide', function(self)
        Set_Button_Event(self, false)--事件
    end)

    WoWTools_CooldownMixin:SetFrame(btn, {itemID=btn.itemID})

    Set_Item_Count(btn)

    Set_Button_Event(btn, btn:IsVisible())--事件
end














--法术
local function Set_Spell_Count(btn)--次数
    local data= btn.spellID and C_Spell.GetSpellCharges(btn.spellID) or {}
    local num, max= data.currentCharges, data.maxCharges
    if max and max>1 and not btn.count then
        btn.count=WoWTools_LabelMixin:Create(btn, {color=true})--nil,nil,nil,true)
        btn.count:SetPoint('BOTTOMRIGHT',-2, 9)
    end
    if btn.count then
        btn.count:SetText((max and max>1) and num or '')
    end
    btn.texture:SetDesaturated(num and num>0)
end





--法术，设置按钮
local function Set_Spell_Button(btn, spellID)
    btn.spellID= spellID

    btn:SetAttribute('type', 'spell')
    btn:SetAttribute('spell', spellID)
    if C_Spell.IsSpellDataCached(spellID) then
        btn.texture:SetTexture(C_Spell.GetSpellTexture(spellID) or 134400)
    else
        SpellEventListener:AddCancelableCallback(spellID, function()
            btn.texture:SetTexture(C_Spell.GetSpellTexture(spellID) or 134400)
        end)
    end

    btn:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:SetSpellByID(self.spellID)
        GameTooltip:Show()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript("OnEvent", function(self, event)
        if event=='SPELL_UPDATE_USABLE' then
            Set_Spell_Count(self)
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
        end
    end)
    btn:SetScript('OnShow', function(self)
        Set_Button_Event(self, true)
        WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
        Set_Spell_Count(self)
    end)
    btn:SetScript('OnHide', function(self)
        Set_Button_Event(self, false)
    end)

    Set_Button_Event(btn, btn:IsVisible())
    WoWTools_CooldownMixin:SetFrame(btn, {spellID=btn.spellID})
    Set_Spell_Count(btn)
end















local function Init()
    WoWTools_ToolsMixin:Set_AddList(function(_, layout)
        WoWTools_PanelMixin:Header(layout, WoWTools_UseItemsMixin.addName)
    end)

    for _, itemID in pairs(Save().item) do
        if C_Item.GetItemCount(itemID)>0 or (PlayerHasToy(itemID) and C_ToyBox.IsToyUsable(itemID)) or WoWTools_DataMixin.Player.husandro then
            WoWTools_DataMixin:Load(itemID, 'item')
            local name = C_Item.GetItemNameByID(itemID) or itemID
            local icon= select(5, C_Item.GetItemInfoInstant(itemID)) or 134400
            local btn= WoWTools_ToolsMixin:CreateButton({
                name='UsaItems_ItemID_'..itemID,
                tooltip='|T'..icon..':0|t'..WoWTools_TextMixin:CN(name, {itemID=itemID, isName=true}),
            })
            if btn then
                Set_Item_Button(btn, itemID, nil)
            end
        end
   end

    for _, itemID in pairs(Save().equip) do
        if C_Item.GetItemCount(itemID)>0 or WoWTools_DataMixin.Player.husandro then
            WoWTools_DataMixin:Load(itemID, 'item')
            local itemEquipLoc, icon = select(4, C_Item.GetItemInfoInstant(itemID))
            local slot= WoWTools_ItemMixin:GetEquipSlotID(itemEquipLoc)
            if slot then
                local name = C_Item.GetItemNameByID(itemID) or itemID
                icon= icon or 134400
                local btn= WoWTools_ToolsMixin:CreateButton({
                    name='UsaItems_Equip_ItemID_'..itemID,
                    tooltip='|T'..icon..':0|t'..WoWTools_TextMixin:CN(name, {itemID=itemID, isName=true}),
                })
                if btn then
                    Set_Item_Button(btn, itemID, slot)
                end
            end
        end
    end

    for _, spellID in pairs(Save().spell) do
        if C_SpellBook.IsSpellInSpellBook(spellID) or WoWTools_DataMixin.Player.husandro then
            WoWTools_DataMixin:Load(spellID, 'spell')
            local btn= WoWTools_ToolsMixin:CreateButton({
                name='UsaItems_SpellID_'..spellID,
                tooltip='|T'..(C_Spell.GetSpellTexture(spellID) or 134400)..':0|t'
                    ..(WoWTools_TextMixin:CN(C_Spell.GetSpellName(spellID), {spellID=spellID, isName=true}) or spellID),
            })
            if btn then
                Set_Spell_Button(btn, spellID)
            end
        end
    end

    Init=function()end
end

















function WoWTools_UseItemsMixin:Init_All_Buttons()
    Init()
end