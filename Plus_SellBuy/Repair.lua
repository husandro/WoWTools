local e= select(2, ...)

local function Save()
    return WoWTools_SellBuyMixin.Save
end

local function RepairSave()
    return WoWTools_SellBuyMixin.Save.repairItems
end



--自动修理
local function Init()
    local AutoRepairCheck= CreateFrame("CheckButton", 'WoWTools_AutoRepairCheck', MerchantRepairAllButton, "InterfaceOptionsCheckButtonTemplate")
    AutoRepairCheck:SetSize(18,18)
    AutoRepairCheck:SetChecked(not Save().notAutoRepairAll)
    AutoRepairCheck:SetPoint('BOTTOMLEFT', -4,-5)

    function AutoRepairCheck:set_tooltip()
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_SellBuyMixin.addName)
        
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine('|cffff00ff'..(WoWTools_Mixin.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER), RepairSave().date)
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR, (RepairSave().num or 0)..' '..(WoWTools_Mixin.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
        local guild= RepairSave().guild or 0
        local player= RepairSave().player or 0
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '公会' or GUILD, C_CurrencyInfo.GetCoinTextureString(guild))
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '玩家' or PLAYER, C_CurrencyInfo.GetCoinTextureString(player))
        if guild>0 and player>0 then
            GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '合计' or TOTAL, C_CurrencyInfo.GetCoinTextureString(guild+player))
        end
        
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_Mixin.onlyChinese and '自动修理所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REPAIR_ALL_ITEMS), WoWTools_TextMixin:GetEnabeleDisable(not Save().notAutoRepairAll))
        if CanGuildBankRepair() then
            local m= GetGuildBankMoney() or 0
            local col= m==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:'
            GameTooltip:AddDoubleLine(col..(WoWTools_Mixin.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP), col..C_CurrencyInfo.GetCoinTextureString(m))
        else
            GameTooltip:AddDoubleLine('|cff9e9e9e'..(WoWTools_Mixin.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP), '|cff9e9e9e'..(WoWTools_Mixin.onlyChinese and '禁用' or DISABLE))
        end
        GameTooltip:Show()
    end
    AutoRepairCheck:SetScript('OnClick', function(self)
        Save().notAutoRepairAll= not Save().notAutoRepairAll and true or nil
        self:set_repair_all()
        self:set_tooltip()
    end)
    AutoRepairCheck:SetScript('OnLeave', GameTooltip_Hide)
    AutoRepairCheck:SetScript('OnEnter', AutoRepairCheck.set_tooltip)








    --修理
    function AutoRepairCheck:set_repair_all()
        if Save().notAutoRepairAll or not CanMerchantRepair() or IsModifierKeyDown() then
            return
        end
        local Co, Can= GetRepairAllCost()
        if Can and Co and Co>0 then
            if CanGuildBankRepair() and GetGuildBankMoney()>=Co  then
                do
                    RepairAllItems(true)
                end
                RepairSave().guild=RepairSave().guild+Co
                RepairSave().num=RepairSave().num+1
                print(WoWTools_DataMixin.Icon.icon2..WoWTools_SellBuyMixin.addName, '|cffff00ff'..(WoWTools_Mixin.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP)..'|r', C_CurrencyInfo.GetCoinTextureString(Co))
                WoWTools_Mixin:Call(MerchantFrame_Update)
            else
                if GetMoney()>=Co then
                    do
                        RepairAllItems()
                    end
                    RepairSave().player=RepairSave().player+Co
                    RepairSave().num=RepairSave().num+1
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_SellBuyMixin.addName, '|cnGREEN_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '修理花费：' or REPAIR_COST)..'|r', C_CurrencyInfo.GetCoinTextureString(Co))
                    WoWTools_Mixin:Call(MerchantFrame_Update)
                else
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_SellBuyMixin.addName, '|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '失败' or FAILED)..'|r', WoWTools_Mixin.onlyChinese and '修理花费：' or REPAIR_COST, C_CurrencyInfo.GetCoinTextureString(Co))
                end
            end
        end

    end
    AutoRepairCheck:RegisterEvent('MERCHANT_SHOW')
    AutoRepairCheck.events={
        'EQUIPMENT_SWAP_FINISHED',
        'PLAYER_EQUIPMENT_CHANGED',
        'UPDATE_INVENTORY_DURABILITY',
    }
    MerchantFrame:HookScript('OnShow', function()
        FrameUtil.RegisterFrameForEvents(AutoRepairCheck, AutoRepairCheck.events)
    end)
    MerchantFrame:HookScript('OnHide', function()
        FrameUtil.UnregisterFrameForEvents(AutoRepairCheck, AutoRepairCheck.events)
    end)
    AutoRepairCheck:SetScript('OnEvent', function(self, event)
        if event=='MERCHANT_SHOW' then
            self:set_repair_all()
        end
    end)

    --显示，公会修理，信息
    MerchantGuildBankRepairButton.Text= WoWTools_LabelMixin:Create(MerchantGuildBankRepairButton, {justifyH='RIGHT'})
    MerchantGuildBankRepairButton.Text:SetPoint('TOPLEFT', 1, -1)
    hooksecurefunc('MerchantFrame_UpdateGuildBankRepair', function()
        local repairAllCost = GetRepairAllCost()
        if not CanGuildBankRepair() then
            MerchantGuildBankRepairButton.Text:SetFormattedText('|A:%s:0:0|a', 'talents-button-reset')
        else
            local co = GetGuildBankMoney() or 0
            local col= co==0 and '|cff9e9e9e' or (repairAllCost> co and '|cnRED_FONT_COLOR:') or '|cnGREEN_FONT_COLOR:'
            MerchantGuildBankRepairButton.Text:SetText(col..(WoWTools_Mixin:MK(co/10000, 0)))
        end
    end)

    --提示，可修理，件数
    MerchantRepairItemButton.Text=WoWTools_LabelMixin:Create(MerchantRepairItemButton)
    MerchantRepairItemButton.Text:SetPoint('TOPLEFT', 1, -1)
    MerchantRepairItemButton:SetScript('OnEnter', function(self)--替换，源FUNC
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(WoWTools_Mixin.onlyChinese and '修理一件物品' or REPAIR_AN_ITEM)
        GameTooltip:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()
        GameTooltip:Show()
    end)
    MerchantRepairItemButton:HookScript('OnClick', function()
        if not PaperDollFrame:IsVisible() then
            ToggleCharacter("PaperDollFrame")
        end
    end)

    --显示耐久度
    AutoRepairCheck.Text:ClearAllPoints()
    AutoRepairCheck.Text:SetPoint('BOTTOM', MerchantRepairAllButton, 'TOP', 0, 0)
    AutoRepairCheck.Text:SetShadowOffset(1, -1)

    --显示，修理，金钱
    MerchantRepairAllButton.Text2=WoWTools_LabelMixin:Create(MerchantRepairAllButton)
    MerchantRepairAllButton.Text2:SetPoint('TOPLEFT', MerchantRepairAllButton, 1, -1)
    hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
        if MerchantRepairAllButton:IsShown() then
            local co = GetRepairAllCost()--显示，修理所有，金钱
            local col= co==0 and '|cff9e9e9e' or (co<= GetMoney() and '|cnGREEN_FONT_COLOR:') or '|cnRED_FONT_COLOR:'
            MerchantRepairAllButton.Text2:SetText(col..WoWTools_Mixin:MK(co/10000, 0))

            local num=0--提示，可修理，件数
            for i= 1, 18 do
                local cur2, max2 = GetInventoryItemDurability(i)
                if cur2 and max2 and max2>cur2 and max2>0 then
                    num= num+1
                end
            end
            MerchantRepairItemButton.Text:SetText((num==0 and '|cff9e9e9e' or '|cnGREEN_FONT_COLOR:')..num)

            AutoRepairCheck.Text:SetText(WoWTools_DurabiliyMixin:Get(true))--显示耐久度
        end
    end)

    MerchantRepairAllButton:SetScript('OnEnter', function(self)--替换，源FUNC
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        local repairAllCost, canRepair = GetRepairAllCost()
        if ( canRepair and (repairAllCost > 0) ) then
            GameTooltip:SetText(WoWTools_Mixin.onlyChinese and '修理所有物品' or REPAIR_ALL_ITEMS)
            SetTooltipMoney(GameTooltip, repairAllCost)
            local personalMoney = GetMoney()
            if(repairAllCost > personalMoney) then
                GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(WoWTools_Mixin.onlyChinese and '没有足够的资金来修理所有物品' or GUILDBANK_REPAIR_INSUFFICIENT_FUNDS))
            end
        end
        GameTooltip:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()
        GameTooltip:Show()
    end)
end









--自动修理
function WoWTools_SellBuyMixin:Init_Auto_Repair()
    Init()
end