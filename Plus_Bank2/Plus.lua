if BankFrameTab2 then
    return
end
local function Save()
    return WoWToolsSave['Plus_Bank2']
end





--[[
	if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
		GameTooltip_AddNormalLine(tooltip, 内容更新:format(仅限当前内容));
	elseif FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
		GameTooltip_AddNormalLine(tooltip, 内容更新:format(仅限旧版内容));
	end
    BankPanel.selectedTabID
};
]]

local C_BAG_FILTER_LABELS = {
	[Enum.BagSlotFlags.ClassEquipment]= '|A:Warfronts-BaseMapIcons-Alliance-Armory-Minimap:0:0|a',--装备 BAG_FILTER_EQUIPMENT 2
	[Enum.BagSlotFlags.ClassConsumables]= '|A:Food:0:0|a',--消耗品 BAG_FILTER_CONSUMABLES 4
	[Enum.BagSlotFlags.ClassProfessionGoods]= '|A:Profession:0:0|a', --专业技能货物 BAG_FILTER_PROFESSION_GOODS 8
	[Enum.BagSlotFlags.ClassJunk]= '|A:auctionhouse-icon-coin-copper:0:0|a',--垃圾 BAG_FILTER_JUNK 16
	[Enum.BagSlotFlags.ClassQuestItems]= '|A:AdventureMapIcon-SandboxQuest:0:0|a',--任务物品 BAG_FILTER_QUEST_ITEMS 32
	[Enum.BagSlotFlags.ClassReagents]= '|A:Professions_Tracking_Fish:0:0|a',--材料 BAG_FILTER_REAGENTS 128
}


local C_ContainerFrameUtil_ConvertFilterFlagsToList = function(filterFlags)
    if not filterFlags then
        return;
    end

    local filterList
    local index=0
    for _, filter in ContainerFrameUtil_EnumerateBagGearFilters() do
        if FlagsUtil.IsSet(filterFlags, filter) then
            index= index+ 1
            if not filterList then
                filterList = C_BAG_FILTER_LABELS[filter]
            else
                filterList = filterList
                    ..(select(2, math.modf(index/3))==0 and '|n' or '')
                    .. C_BAG_FILTER_LABELS[filter]
            end
        end
    end

    if FlagsUtil.IsSet(filterFlags, Enum.BagSlotFlags.ExpansionCurrent) then--内容更新:仅限当前内容)
        index= index+1
        filterList = (filterList or '')
                    ..(select(2, math.modf(index/3))==0 and '|n' or '')
                    ..'|A:SmallQuestBang:0:0|a'

	elseif FlagsUtil.IsSet(filterFlags, Enum.BagSlotFlags.ExpansionLegacy) then--内容更新:仅限旧版内容;
        index= index+1
         filterList = (filterList or '')
                    ..(select(2, math.modf(index/3))==0 and '|n' or '')
                    ..'|A:Islands-QuestBangDisable:0:0|a'
	end
    --[[if FlagsUtil.IsSet(filterFlags, Enum.BagSlotFlags.DisableAutoSort) then--忽略此标签 1
        index= index+1
         filterList = (filterList or '')
                    ..(select(2, math.modf(index/3))==0 and '|n' or '')
                    ..'|A:bags-button-autosort-down:0:0|a'
    end]]

    return filterList
end

local function Init()



    --[[BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignEquipmentCheckbox.Text:SetText(
        C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ClassEquipment]
        ..(WoWTools_DataMixin.onlyChinese and '装备' or BAG_FILTER_EQUIPMENT)
    )

    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignConsumablesCheckbox.Text:SetText(
        C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ClassConsumables]
        ..(WoWTools_DataMixin.onlyChinese and '消耗品' or BAG_FILTER_CONSUMABLES)
    )
 

    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignProfessionGoodsCheckbox.Text:SetText(
        C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ClassProfessionGoods]
        ..(WoWTools_DataMixin.onlyChinese and '专业技能货物' or BAG_FILTER_PROFESSION_GOODS)
    )

    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignReagentsCheckbox.Text:SetText(
        C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ClassReagents]
        ..(WoWTools_DataMixin.onlyChinese and '材料' or BAG_FILTER_REAGENTS)        
    )

    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignJunkCheckbox.Text:SetText(
        C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ClassJunk]
        ..(WoWTools_DataMixin.onlyChinese and '垃圾' or BAG_FILTER_JUNK)        
    )]]


    hooksecurefunc(BankPanelTabMixin, 'Init', function(btn)
        local data= btn.tabData--bankType name ID depositFlags icon tabNameEditBoxHeader tabCleanupConfirmation
        if not data or btn:IsPurchaseTab() then
            return
        end
        if not btn.Name then
            btn.Name= WoWTools_LabelMixin:Create(btn, {color=true})
            btn.Name:SetPoint('BOTTOM')
            btn.FlagsText= WoWTools_LabelMixin:Create(btn, {color=true})
            btn.FlagsText:SetPoint('LEFT', btn, 'RIGHT')
            WoWTools_TextureMixin:CreateBG(btn, {point=function(bg)
                bg:SetAllPoints(btn.FlagsText)
            end})
        end
        btn.Name:SetText(WoWTools_TextMixin:sub(Save().plus and data.name, 2, 5) or '')

        btn.FlagsText:SetText(C_ContainerFrameUtil_ConvertFilterFlagsToList(data.depositFlags) or '')

    end)




    BankPanel.TabSettingsMenu:HookScript('OnShow', function(self)
        self.BorderBox.IconSelectorEditBox:ClearFocus()
    end)
    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignProfessionGoodsCheckbox.Text:SetPoint('RIGHT', BankPanel.TabSettingsMenu.DepositSettingsMenu)

    Init=function()
    end
end


function WoWTools_BankMixin:Init_Plus()
    Init()
end