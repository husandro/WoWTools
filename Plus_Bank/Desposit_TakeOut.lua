local e= select(2, ...)

local function Save()
    return WoWTools_BankFrame.Save
end









--存放，取出，所有
local function Init()
    local btn= WoWTools_ButtonMixin:Cbtn(BankSlotsFrame, {size=23, icon='hide'})
    btn:SetNormalAtlas('poi-traveldirections-arrow')
    btn:GetNormalTexture():SetTexCoord(1,0,1,0)
    if Save().allBank then
        btn:SetPoint('RIGHT', BankItemAutoSortButton, 'LEFT', -2, 0)
    else
        btn:SetPoint('RIGHT', BankItemSearchBox, 'LEFT', -6, 0)
    end
    btn:SetScript('OnClick', function(self)
        local free= WoWTools_BagMixin:GetFree()--背包，空位
        if free==0 then
            return
        end
        for bag=(NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, -1 do
            for slot=1, C_Container.GetContainerNumSlots(bag) or 0, 1 do
                if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end

        for i=NUM_BANKGENERIC_SLOTS, 1, -1 do--28
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                self:show_tooltips()
                return
            end
            local bag, slot= WoWTools_BankMixin:GetBagAndSlot(BankSlotsFrame["Item"..i])
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= WoWTools_BagMixin:GetFree()--背包，空位
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有物品' or 'Take out all items',
            format('|A:bag-main:0:0|a%s #%s%d',
                e.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btn:show_tooltips()
        C_Timer.After(1.5, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btn:HookScript('OnLeave', GameTooltip_Hide)
    btn:HookScript('OnEnter', btn.set_tooltips)
    ReagentBankFrame.TakeOutAllItemButton= btn

    --存放，所有，物品
    local btnOut= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.TakeOutAllItemButton, {size=23, icon='hide'})
    btnOut:SetNormalAtlas('poi-traveldirections-arrow')
    btnOut:GetNormalTexture():SetTexCoord(0,1,1,0)
    btnOut:SetPoint('RIGHT', ReagentBankFrame.TakeOutAllItemButton, 'LEFT', -2, 0)
    btnOut:SetScript('OnClick', function(self)
        local free= WoWTools_BankMixin:GetFree()--银行，空位
        if free==0 then
            return
        end
        for bag= NUM_BAG_FRAMES,  BACKPACK_CONTAINER, -1 do
            for slot= C_Container.GetContainerNumSlots(bag), 1, -1 do
                if not self:IsVisible() or IsModifierKeyDown() or free==0 then
                    self:show_tooltips()
                    return
                end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.hyperlink and not select(17, C_Item.GetItemInfo(info.hyperlink)) then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
    end)
    function btnOut:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free=WoWTools_BankMixin:GetFree()--银行，空位
        e.tips:AddDoubleLine(e.onlyChinese and '存放所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, GUILDCONTROL_DEPOSIT_ITEMS, ' ('..ALL..')'),
            format('|A:Banker:0:0|a%s #%s%d',
                e.onlyChinese and '银行' or BANK,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnOut:show_tooltips()
        C_Timer.After(1.5, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnOut:HookScript('OnLeave', GameTooltip_Hide)
    btnOut:HookScript('OnEnter', btnOut.set_tooltips)
    ReagentBankFrame.DespositAllItemButton= btnOut


    --取出，所有，材料
    local btnR= WoWTools_ButtonMixin:Cbtn(ReagentBankFrame.DespositButton, {size=23, icon='hide'})
    btnR:SetNormalAtlas('poi-traveldirections-arrow')
    btnR:GetNormalTexture():SetTexCoord(1,0,1,0)
    btnR:SetPoint('LEFT', ReagentBankFrame.DespositButton, 'RIGHT', 2, 0)
    function btnR:get_bag_slot(frame)
        return frame.isBag and Enum.BagIndex.Bankbag or frame:GetParent():GetID(), frame:GetID()
    end
    --[[function btnR:get_free()
        return C_Container.GetContainerNumFreeSlots(NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES) or 0
    end]]
    btnR:SetScript('OnClick', function(self)
        local free= WoWTools_BagMixin:GetFree(true)--self:get_free()
        if free==0 or not IsReagentBankUnlocked() then
            return
        end
        local tabs={}
        for _, frame in ReagentBankFrame:EnumerateItems() do
            table.insert(tabs, 1, frame)
        end
        for _, frame in pairs(tabs) do
            if not self:IsVisible() or IsModifierKeyDown() or free<=0 then
                self:show_tooltips()
                return
            end
            local bag, slot= WoWTools_BankMixin:GetBagAndSlot(frame)
            if bag and slot then
                local info= C_Container.GetContainerItemInfo(bag, slot) or {}
                if info.itemID then
                    C_Container.UseContainerItem(bag, slot)
                    free= free-1
                end
            end
        end
        self:show_tooltips()
    end)
    function btnR:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        local free= WoWTools_BagMixin:GetFree(true)--self:get_free()
        e.tips:AddDoubleLine(e.onlyChinese and '取出所有材料' or 'Take out all reagents',
            format('|A:4549254:0:0|a%s #%s%d',
                e.onlyChinese and '材料' or AUCTION_CATEGORY_TRADE_GOODS,
                free==0 and '|cnRED_FONT_COLOR:' or '|cnGREEN_FONT_COLOR:',
                free)
        )
        e.tips:Show()
    end
    function btnR:show_tooltips()
        C_Timer.After(1, function() if GameTooltip:IsOwned(self) then self:set_tooltips() end end)
    end
    btnR:HookScript('OnLeave', GameTooltip_Hide)
    btnR:HookScript('OnEnter', btnR.set_tooltips)
    ReagentBankFrame.TakeOutAllReagentsButton= btnR
end







function WoWTools_BankFrame:Init_Desposit_TakeOut()--原生, 增强
    Init()
end