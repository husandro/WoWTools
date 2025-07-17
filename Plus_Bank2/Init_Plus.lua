if BankFrameTab2 then
    return
end


local function Save()
    return WoWToolsSave['Plus_Bank2']
end


local C_BAG_FILTER_LABELS = {
	[Enum.BagSlotFlags.ClassEquipment]= 'Warfronts-BaseMapIcons-Alliance-Armory-Minimap',--装备 BAG_FILTER_EQUIPMENT 2
	[Enum.BagSlotFlags.ClassConsumables]= 'Food',--消耗品 BAG_FILTER_CONSUMABLES 4
	[Enum.BagSlotFlags.ClassProfessionGoods]= 'Profession', --专业技能货物 BAG_FILTER_PROFESSION_GOODS 8
	[Enum.BagSlotFlags.ClassJunk]= 'Coin-Silver',--垃圾 BAG_FILTER_JUNK 16
	[Enum.BagSlotFlags.ClassQuestItems]= 'AdventureMapIcon-SandboxQuest',--任务物品 BAG_FILTER_QUEST_ITEMS 32
	[Enum.BagSlotFlags.ClassReagents]= 'Professions_Tracking_Fish',--材料 BAG_FILTER_REAGENTS 128

    [Enum.BagSlotFlags.ExpansionCurrent]= 'QuestLegendary',--内容更新:仅限当前内容 256
    [Enum.BagSlotFlags.ExpansionLegacy]= 'QuestDaily',--内容更新:仅限旧版内容 512
    [Enum.BagSlotFlags.DisableAutoSort]= 'bags-button-autosort-up',--忽略此标签 1
}


--[[
BankPanelTabMixin.tabData= {bankType name ID depositFlags icon tabNameEditBoxHeader tabCleanupConfirmation}
]]













local function Init()
    if not Save().plus then
        return
    end






--清理战团银行
    BankPanel.AutoSortButton:HookScript('OnEnter', function()
        if Save().plus then
            GameTooltip:AddLine(
                (WoWTools_DataMixin.onlyChinese and '确认' or OKAY)..': '
                ..WoWTools_TextMixin:GetEnabeleDisable(GetCVarBool("bankConfirmTabCleanUp"))
                ..WoWTools_DataMixin.Icon.right
            )
            GameTooltip:Show()
        end
    end)
    BankPanel.AutoSortButton:HookScript('OnMouseDown', function(self, d)
        if d~='RightButton' or not Save().plus then
            return
        end
        MenuUtil.CreateContextMenu(self, function(_, root)
            local sub=root:CreateCheckbox(
                '|A:bags-button-autosort-up:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '确认' or OKAY),
            function()
                return C_CVar.GetCVarBool("bankConfirmTabCleanUp") and true or false
            end, function()
                if not InCombatLockdown() then
                    C_CVar.SetCVar('bankConfirmTabCleanUp', C_CVar.GetCVarBool("bankConfirmTabCleanUp") and 0 or 1)
                end
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_BankMixin.addName..WoWTools_DataMixin.Icon.icon2)
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '你确定要自动整理你的物品吗？|n该操作会影响所有的标签。' or BANK_CONFIRM_CLEANUP_PROMPT)
                tooltip:AddLine(' ')
                tooltip:AddLine(WoWTools_DataMixin.onlyChinese and '你确定要自动整理你的物品吗？|n该操作会影响所有的战团标签。' or ACCOUNT_BANK_CONFIRM_CLEANUP_PROMPT)
            end)
            sub:SetEnabled(not InCombatLockdown())
        end)
    end)













--Tab,显示 名称
    BankPanel.Header.Text:SetShadowOffset(1, -1)
    hooksecurefunc(BankPanel, 'RefreshHeaderText', function(self)
        if Save().plus and self:GetActiveBankType() == Enum.BankType.Account then
            self.Header.Text:SetTextColor(0, 0.8, 1)
        else
            self.Header.Text:SetTextColor(1,1,1)
        end
    end)








--[[BankFrame标题 测试不了
    hooksecurefunc(BankFrame, 'OnTitleUpdateRequested', function(self)
        if self:GetActiveBankType() == Enum.BankType.Account then
            BankFrameTitleText:SetTextColor(0, 0.8, 1)
        else
            BankFrameTitleText:SetTextColor(1, 0.823, 0)
        end
    end)]]

--右边Tab, 右击，选项面板，图标提示
    for _, check in ipairs(BankPanel.TabSettingsMenu.DepositSettingsMenu.DepositSettingsCheckboxes) do
        local atlas= C_BAG_FILTER_LABELS[check.settingFlag]
        if atlas then
            check.Icon=check:CreateTexture()
            check.Icon:SetPoint('RIGHT', -18, 0)
            check.Icon:SetSize(20, 20)
            check.Icon:SetAtlas(atlas)
        end
	end
    hooksecurefunc(BankPanel.TabSettingsMenu.DepositSettingsMenu.ExpansionFilterDropdown, 'SetFilterValue', function(self, filterType)
        local atlas= Save().plus and C_BAG_FILTER_LABELS[filterType]
        if not self.Icon then
            self.Icon= self:CreateTexture()
            self.Icon:SetPoint('RIGHT', self, 'LEFT', 10, 0)
            self.Icon:SetSize(23, 23)
        end
        if atlas then
            self.Icon:SetAtlas(atlas)
        else
            self.Icon:SetTexture(0)
        end
    end)















--替换，原生 右边Tab OnEnter
    local function AddBankTabSettingsToTooltip(self)
        local depositFlags= not self:IsPurchaseTab() and self.tabData and self.tabData.depositFlags
        if not depositFlags then
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip,
            '|T'..(self.tabData.icon or 0)..':0|t'
            ..self.tabData.name,
            NORMAL_FONT_COLOR
        )
        if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
            local icon= '|A:'..C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ExpansionCurrent]..':0:0|a'
            GameTooltip_AddNormalLine(GameTooltip,
                WoWTools_DataMixin.onlyChinese and '内容更新：'..icon..'|cnHIGHLIGHT_FONT_COLOR:仅限当前内容|r'
                or BANK_TAB_EXPANSION_ASSIGNMENT:format(icon..BANK_TAB_EXPANSION_FILTER_CURRENT)
            )
        elseif FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
            local icon= '|A:'..C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ExpansionLegacy]..':0:0|a'
            GameTooltip_AddNormalLine(GameTooltip,
                WoWTools_DataMixin.onlyChinese and '内容更新：'..icon..'|cff626262仅限旧版内容|r'
                or BANK_TAB_EXPANSION_ASSIGNMENT:format(icon..'|cff626262'..BANK_TAB_EXPANSION_FILTER_LEGACY)
            )
        end
        local text
        for _, filter in ContainerFrameUtil_EnumerateBagGearFilters() do
            if FlagsUtil.IsSet(depositFlags, filter) then
                text= (text or '')
                    ..'|n    '
                    ..'|cnHIGHLIGHT_FONT_COLOR:'
                    ..(C_BAG_FILTER_LABELS[filter] and '|A:'..C_BAG_FILTER_LABELS[filter]..':0:0|a' or '')
                    ..(WoWTools_TextMixin:CN(BAG_FILTER_LABELS[filter]) or '')
            end
        end
        if text then
            GameTooltip_AddNormalLine(GameTooltip,
                format(WoWTools_DataMixin and '指定到：|cnHIGHLIGHT_FONT_COLOR:%s|r' or BANK_TAB_DEPOSIT_ASSIGNMENTS, text)
            )
        end
        if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.DisableAutoSort) then
            GameTooltip_AddNormalLine(GameTooltip,
                (WoWTools_DataMixin.onlyChinese and '清理：' or BANK_TAB_CLEANUP_SETTINGS_HEADER)
                ..'|A:'..C_BAG_FILTER_LABELS[Enum.BagSlotFlags.DisableAutoSort]..':0:0|a'
                ..'|cnHIGHLIGHT_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '忽略此标签' or BANK_TAB_IGNORE_IN_CLEANUP_CHECKBOX)
            )
        end
        GameTooltip_AddInstructionLine(GameTooltip, WoWTools_DataMixin.onlyChinese and '<右键点击进行设置>' or BANK_TAB_TOOLTIP_CLICK_INSTRUCTION)
        GameTooltip:Show()
    end
    hooksecurefunc(BankPanelTabMixin, 'OnLoad', function(btn)
        btn:SetScript('OnEnter', function(self)
            if Save().plus then
                AddBankTabSettingsToTooltip(self)
            else
                BankPanelTabMixin.OnEnter(self)
            end
        end)
    end)

    hooksecurefunc(BankPanelTabMixin, 'Init', function()

    end)











--右边 Tab 添加，提示
    local function C_ContainerFrameUtil_ConvertFilterFlagsToList(filterFlags)
        if not filterFlags then
            return
        end
        local tab={}
        for _, filter in ContainerFrameUtil_EnumerateBagGearFilters() do
            if FlagsUtil.IsSet(filterFlags, filter) then
                table.insert(tab, C_BAG_FILTER_LABELS[filter])
            end
        end
    --内容更新:仅限当前内容)
        if FlagsUtil.IsSet(filterFlags, Enum.BagSlotFlags.ExpansionCurrent) then
            table.insert(tab, C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ExpansionCurrent])
    --内容更新:仅限旧版内容
        elseif FlagsUtil.IsSet(filterFlags, Enum.BagSlotFlags.ExpansionLegacy) then
            table.insert(tab, C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ExpansionLegacy])
        end
    --忽略此标签 1
        if FlagsUtil.IsSet(filterFlags, Enum.BagSlotFlags.DisableAutoSort) then
            table.insert(tab, C_BAG_FILTER_LABELS[Enum.BagSlotFlags.DisableAutoSort])
        end
        local num=#tab
        if num>0 then
            local meta= math.modf(num/2)+ 1
            local text=''
            for index, icon in pairs(tab) do
                if icon then
                    text= text
                        ..(index==meta and '|n' or '')
                        ..'|A:'..icon..':0:0|a'
                end
            end
            return text..' '
        end
    end
--空位，数量，百份比
    local function Set_Tab_Free(containerID)
        if not containerID then
            return
        end
        local free= C_Container.GetContainerNumFreeSlots(containerID) or 0
        local num= C_Container.GetContainerNumSlots(containerID) or 0
        local percent
        if num>0 then
            percent= math.modf(free/num*100)..'%'
        end
        return percent
    end

    hooksecurefunc(BankPanelTabMixin, 'Init', function(btn, tabData)--bankType name ID depositFlags icon tabNameEditBoxHeader tabCleanupConfirmation
        if btn:IsPurchaseTab() or not tabData then
            return
        end
        if not btn.Name then
            btn.Name= WoWTools_LabelMixin:Create(btn)
            btn.Name:SetPoint('BOTTOM')

            btn.FlagsText= WoWTools_LabelMixin:Create(btn)--, {color=true})--, layer='BACKGROUND'})
            btn.FlagsText:SetPoint('LEFT', btn, 'RIGHT')

            btn.freeText= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}})
            btn.freeText:SetPoint('TOP', btn.Name, 'BOTTOM')
        end

        local flag, name, free
        if Save().plus then
            name= WoWTools_TextMixin:sub(tabData.name, 2, 5)
            flag= C_ContainerFrameUtil_ConvertFilterFlagsToList(tabData.depositFlags)
            free= C_Container.GetContainerNumFreeSlots(tabData.ID)
            local r,g,b
            if btn:GetActiveBankType() == Enum.BankType.Account then
                r,g,b= 0,0.8,1
            else
                r,g,b= 1,0.5,0
            end
            btn.Name:SetTextColor(r,g,b)
            btn.FlagsText:SetTextColor(r,g,b)
        end
        btn.Name:SetText(name or '')
        btn.FlagsText:SetText(flag or '')
        btn.freeText:SetText(free or '')
    end)

    BankPanel:HookScript('OnEvent', function(self, event, containerID)
        if not Save().plus or event~= 'BAG_UPDATE' or not self:GetTabData(containerID) then
            return
        end
        for btn in self.bankTabPool:EnumerateActive() do
            if btn.tabData and btn.tabData.ID==containerID then
                if btn.FlagsText then
                    btn.FlagsText:SetText(C_Container.GetContainerNumFreeSlots(containerID) or '')
                end
                break
            end
        end
    end)





--当选项面板显示，清队EditBox焦点
    BankPanel.TabSettingsMenu:HookScript('OnShow', function(self)
        if Save().plus then
            self.BorderBox.IconSelectorEditBox:ClearFocus()
        end
    end)








--修该长度，中文会被截断
    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignProfessionGoodsCheckbox.Text:SetPoint('RIGHT', BankPanel.TabSettingsMenu.DepositSettingsMenu)



--ItemButton 索引
    hooksecurefunc(BankPanelItemButtonMixin, 'Init', function(btn, bankType, bankTabID, containerSlotID)
        if not btn.indexText then
            btn.indexText=WoWTools_LabelMixin:Create(btn, {justifyH='CENTER'})
            btn.indexText:SetPoint('CENTER')
        end
        local index= Save().plusIndex and Save().plus and containerSlotID
        if index then
            local r,g,b
            if select(2, math.modf(bankTabID/2))==0 then
                if bankType==Enum.BankType.Account then
                    r,g,b= 0,0.8,1
                else
                    r,g,b= 1,0.5,0
                end
            else
                r,g,b=1,1,1
            end
            btn.indexText:SetTextColor(r,g,b, 0.3)
        end
        btn.indexText:SetText(index or '')
    end)




    Init=function()
        BankPanel:Reset()
        for _, check in ipairs(BankPanel.TabSettingsMenu.DepositSettingsMenu.DepositSettingsCheckboxes) do
            if check then
                check.Icon:SetShown(Save().plus)
            end
        end
    end
end











function WoWTools_BankMixin:Init_BankPlus()
    Init()
end





























