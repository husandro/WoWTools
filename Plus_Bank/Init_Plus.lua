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
--清理战团银行
    BankPanel.AutoSortButton:HookScript('OnEnter', function()
        GameTooltip:AddLine(
            (WoWTools_DataMixin.onlyChinese and '确认' or OKAY)..': '
            ..WoWTools_TextMixin:GetEnabeleDisable(GetCVarBool("bankConfirmTabCleanUp"))
            ..WoWTools_DataMixin.Icon.right
        )
        GameTooltip:Show()

    end)
    BankPanel.AutoSortButton:HookScript('OnMouseDown', function(self, d)
        if d~='RightButton' then
            return
        end
        MenuUtil.CreateContextMenu(self, function(_, root)
            local sub=root:CreateCheckbox(
                '|A:bags-button-autosort-up:0:0|a'
                ..(WoWTools_DataMixin.onlyChinese and '确认' or OKAY)
                ..WoWTools_DataMixin.Icon.icon2,
            function()
                return C_CVar.GetCVarBool("bankConfirmTabCleanUp") and true or false
            end, function()
                if not InCombatLockdown() then
                    C_CVar.SetCVar('bankConfirmTabCleanUp', C_CVar.GetCVarBool("bankConfirmTabCleanUp") and 0 or 1)
                end
            end)
            sub:SetTooltip(function(tooltip)
                tooltip:AddLine(WoWTools_BankMixin.addName..WoWTools_DataMixin.Icon.icon2..' bankConfirmTabCleanUp')
                tooltip:AddLine(' ')
                tooltip:AddLine(
                    '|cffff8000'
                    ..(WoWTools_DataMixin.onlyChinese and '你确定要自动整理你的物品吗？|n该操作会影响所有的标签。' or BANK_CONFIRM_CLEANUP_PROMPT)
                )
                tooltip:AddLine(' ')
                tooltip:AddLine(
                    '|cff00ccff'
                    ..(WoWTools_DataMixin.onlyChinese and '你确定要自动整理你的物品吗？|n该操作会影响所有的战团标签。' or ACCOUNT_BANK_CONFIRM_CLEANUP_PROMPT))
            end)
            sub:SetEnabled(not InCombatLockdown())
        end)
    end)



--下面, Tab，加颜色
    for _, btn in pairs(BankFrame.TabSystem.tabs) do--TabSystemMixin
        local ID= btn:GetTabID()
        if ID==BankFrame.accountBankTabID then
            btn.Text:SetTextColor(0, 0.8, 1)
            btn.Text:SetText(WoWTools_DataMixin.onlyChinese and '战团' or ACCOUNT_QUEST_LABEL)

            BankPanel.MoneyFrame.Text2= WoWTools_LabelMixin:Create(btn, {color={r=0,g=0.8,b=1}})
            BankPanel.MoneyFrame.Text2:SetPoint('TOP', btn.Text, 'BOTTOM')
            --BankPanel.MoneyFrame.Text2:SetPoint('BOTTOMRIGHT')
            WoWTools_DataMixin:Hook(BankPanel.MoneyFrame, 'Refresh', function(self)
                local text
                local money=C_Bank.FetchDepositedMoney(Enum.BankType.Account)
                if money and money>10000 then
                    text= WoWTools_DataMixin:MK(math.modf(money/10000), 3)
                end
                self.Text2:SetText(text or '')
            end)

        elseif ID==BankFrame.characterBankTabID then
            btn.Text:SetTextColor(1,0.5,0)
            btn.Text:SetText(WoWTools_DataMixin.onlyChinese and '银行' or BANK)
        end
    end

--BankFrame，标题，加颜色
--替换，原生
    function BankPanel:RequestTitleRefresh()
        local name, freeAll, numAll
        if self:GetActiveBankType() == Enum.BankType.Account then
            BankFrameTitleText:SetTextColor(0, 0.8, 1)
            name= WoWTools_DataMixin.onlyChinese and '战团银行' or ACCOUNT_BANK_PANEL_TITLE
        else
            BankFrameTitleText:SetTextColor(1,0.5,0)
            name= WoWTools_DataMixin.onlyChinese and '银行' or BANK
        end
        for _, tabData in ipairs(self.purchasedBankTabData or {}) do
            if tabData.ID then
                local free= C_Container.GetContainerNumFreeSlots(tabData.ID)
                local num= C_Container.GetContainerNumSlots(tabData.ID)
                if free then
                    freeAll= (freeAll or 0)+ free
                    numAll= (numAll or 0)+ num
                end
            end
        end
        BankFrameTitleText:SetText(
            name
            ..(numAll and numAll>0 and
                ' |cnGREEN_FONT_COLOR:'..freeAll..'|r/'..numAll..' |cnGREEN_FONT_COLOR:'
                ..math.modf(freeAll/numAll*100)..'%'
                or ''
            )
        )
    end
    BankPanel:HookScript('OnEvent', function(self, event, containerID)
        if event== 'BAG_UPDATE' and self:GetTabData(containerID) then
            BankPanel:RequestTitleRefresh()
        end
    end)

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
    WoWTools_DataMixin:Hook(BankPanel.TabSettingsMenu.DepositSettingsMenu.ExpansionFilterDropdown, 'SetFilterValue', function(self, filterType)
        local atlas= C_BAG_FILTER_LABELS[filterType]
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

--购买标签，按钮, 不好点击
    --BankPanel.PurchasePrompt.TabCostFrame.PurchaseButton:SetFrameStrata('HIGH')
    BankFrame.NineSlice:SetFrameLevel(BankPanel:GetFrameLevel()+1)

    Init=function()end
end
















--替换，原生 右边Tab OnEnter
local function AddBankTabSettingsToTooltip(self, tabData)
    if not tabData or not tabData.depositFlags or not tabData.ID or tabData.ID==-1 then
        return
    end

    local depositFlags= tabData.depositFlags

    local isAccount= BankPanel:GetActiveBankType() == Enum.BankType.Account
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip,
        (isAccount and '|cff00ccff' or '|cffff8000')
        ..'|T'..(tabData.icon or 0)..':0|t'
        ..(tabData.name or ''),
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
    --GameTooltip:AddLine(' ')
    local free= C_Container.GetContainerNumFreeSlots(tabData.ID) or 0
    local num= C_Container.GetContainerNumSlots(tabData.ID) or 0
    if num >0 then
        GameTooltip_AddNormalLine(GameTooltip,
            (WoWTools_DataMixin.onlyChinese and '空置' or DELVES_CURIO_SLOT_EMPTY)..': '
            ..free..'/'..num..' '..math.modf(free/num*100)..'%'
        )
    end
    GameTooltip_AddNormalLine(GameTooltip,
        WoWTools_DataMixin.Icon.right
        ..'|cnGREEN_FONT_COLOR:'
        ..(WoWTools_DataMixin.onlyChinese and '<设置>' or ('<'..SETTINGS..'>'))
    )
    GameTooltip:Show()
end


local function GetFlagsText(flags, isNewLine)
    if not flags then
        return
    end
    local tab={}
    for _, filter in ContainerFrameUtil_EnumerateBagGearFilters() do
        if FlagsUtil.IsSet(flags, filter) then
            table.insert(tab, C_BAG_FILTER_LABELS[filter])
        end
    end
--内容更新:仅限当前内容)
    if FlagsUtil.IsSet(flags, Enum.BagSlotFlags.ExpansionCurrent) then
        table.insert(tab, C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ExpansionCurrent])

--内容更新:仅限旧版内容
    elseif FlagsUtil.IsSet(flags, Enum.BagSlotFlags.ExpansionLegacy) then
        table.insert(tab, C_BAG_FILTER_LABELS[Enum.BagSlotFlags.ExpansionLegacy])
    end

--忽略此标签 1
    if FlagsUtil.IsSet(flags, Enum.BagSlotFlags.DisableAutoSort) then
        table.insert(tab, C_BAG_FILTER_LABELS[Enum.BagSlotFlags.DisableAutoSort])
    end

    local num=#tab
    if num==0 then
        return
    end

    local text=''
    if isNewLine then
        local meta= math.modf(num/2)+ 1
        for index, icon in pairs(tab) do
            if icon then
                text= text
                    ..(index==meta and '|n' or '')
                    ..'|A:'..icon..':0:0|a'
            end
        end
        text= text..' '
    else
            for _, icon in pairs(tab) do
            if icon then
                text= text..'|A:'..icon..':0:0|a'
            end
        end
    end
    return text
end












local function Init_TabSystem()
    if not Save().plusTab then
        return
    end

--右边 Tab 添加，提示
    WoWTools_DataMixin:Hook(BankPanelTabMixin, 'Init', function(btn, tabData)--bankType name ID depositFlags icon tabNameEditBoxHeader tabCleanupConfirmation
        if not tabData or btn:IsPurchaseTab() then
            return
        end
        if not btn.FlagsText then
            btn.Name= WoWTools_LabelMixin:Create(btn)
            btn.Name:SetPoint('BOTTOM', 0, -6)

            btn.FlagsText= WoWTools_LabelMixin:Create(btn)--, {color=true})--, layer='BACKGROUND'})
            btn.FlagsText:SetPoint('LEFT', btn, 'RIGHT')

            btn.FreeText= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}})
            btn.FreeText:SetPoint('LEFT', btn.FlagsText, 'RIGHT')

            function btn:set_flags_text(data)
                local flag, free
                if data then
                    flag= GetFlagsText(data.depositFlags, true)
                    free= data.ID and C_Container.GetContainerNumFreeSlots(data.ID)
                end
                self.FlagsText:SetText(flag or '')
                self.FreeText:SetText(free or '')
            end
        end
        local r,g,b
        if btn:GetActiveBankType() == Enum.BankType.Account then
            r,g,b= 0,0.8,1
        else
            r,g,b= 1,0.5,0
        end
        btn.Name:SetTextColor(r,g,b)
        btn.FlagsText:SetTextColor(r,g,b)
        btn.Name:SetText(WoWTools_TextMixin:sub(tabData.name, 2, 5) or '')
        btn:set_flags_text(tabData)
    end)


    --[[BankPanel:HookScript('OnShow', function(self)
        for btn in self.bankTabPool:EnumerateActive() do
            if btn.set_flags_text then
                btn:set_flags_text(btn.tabData)
            end
        end
    end)]]

    BankPanel:HookScript('OnEvent', function(self, event, containerID)
        if event~= 'BAG_UPDATE' or not self:GetTabData(containerID) then
            return
        end
        for btn in self.bankTabPool:EnumerateActive() do
            if btn.tabData and btn.tabData.ID==containerID then
                if btn.set_flags_text then
                    btn:set_flags_text(btn.tabData)
                end
                break
            end
        end
    end)

    WoWTools_DataMixin:Hook(BankPanelTabMixin, 'OnLoad', function(btn)
        btn:SetScript('OnEnter', function(self)
            AddBankTabSettingsToTooltip(self, self.tabData)
            --BankPanelTabMixin.OnEnter(self)
        end)
    end)



--当选项面板显示，清队EditBox焦点
    --[[BankPanel.TabSettingsMenu:HookScript('OnShow', function(self)
        self.BorderBox.IconSelectorEditBox:ClearFocus()
    end)]]

--修该长度，中文会被截断
    BankPanel.TabSettingsMenu.DepositSettingsMenu.AssignProfessionGoodsCheckbox.Text:SetPoint('RIGHT', BankPanel.TabSettingsMenu.DepositSettingsMenu)

    Init_TabSystem=function()end
end










--ItemButton 索引
local function Init_IndexText()
    if not Save().plusIndex then
        return
    end

    WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'Init', function(btn, bankType, bankTabID, containerSlotID)
        if not btn.indexText then
            btn.indexText=WoWTools_LabelMixin:Create(btn, {justifyH='CENTER', layer='BACKGROUND', })
            btn.indexText:SetPoint('CENTER')
        end
        local index= containerSlotID
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

    Init_IndexText=function()end
end




local function Init_ItemInfo()
    if not Save().plusItem then
        return
    end

    local function Settings(self)
        if C_Bank.AreAnyBankTypesViewable() then
            local bag= self:GetBankTabID() or -1
            local slot= self:GetContainerSlotID() or -1
            local hasItem= C_Container.HasContainerItem(bag, slot)
            WoWTools_ItemMixin:SetupInfo(self, hasItem and {bag={bag=bag, slot=slot}} or nil)
        end
    end

    WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'InitItemLocation', Settings)
    WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'Init', Settings)
    WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'Refresh', Settings)
    WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'RefreshItemInfo', Settings)
    --WoWTools_DataMixin:Hook(BankPanelItemButtonMixin, 'OnEnter', Settings)

    Init_ItemInfo=function()end
end



function WoWTools_BankMixin:Init_BankPlus()
    Init()
    Init_TabSystem()
    Init_IndexText()
    Init_ItemInfo()
end










function WoWTools_BankMixin:AddBankTabSettingsToTooltip(frame, tabData)
    AddBankTabSettingsToTooltip(frame, tabData)
end

function WoWTools_BankMixin:GetFlagsText(flags, isNewLine)
    return GetFlagsText(flags, isNewLine)
end



















