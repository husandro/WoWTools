local id, e = ...
local addName= CHARACTER
local Save={
    --EquipmentH=true, --装备管理, true横, false坚
    equipment= e.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1--装备管理, 缩放
    --hide=true,--隐藏CreateTexture
}



local panel= CreateFrame("Frame", nil, PaperDollFrame)
local TrackButton








local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr= ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"
local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local ITEM_CREATED_BY_Str= ITEM_CREATED_BY:gsub('%%s','(.+)')--"|cff00ff00<由%s制造>|r";

local function is_Left_Slot(slot)--左边插曹
    return slot==1 or slot==2 or slot==3 or slot==15 or slot==5 or slot==4 or slot==19 or slot==9 or slot==17 or slot==18
end

local InventSlot_To_ContainerSlot={}--背包数
for i=1, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
    local bag=C_Container.ContainerIDToInventoryID(i)
    if bag then
        InventSlot_To_ContainerSlot[bag]=i
    end
end

local function LvTo()--总装等
    if not PaperDollSidebarTab1 then
        return
    end
    local avgItemLevel,_, avgItemLevelPvp
    if not Save.hide then
        avgItemLevel,_, avgItemLevelPvp= GetAverageItemLevel()
        if not PaperDollSidebarTab1.itemLevelText then--PVE
            PaperDollSidebarTab1.itemLevelText=e.Cstr(PaperDollSidebarTab1, {justifyH='CENTER', mouse=true})
            PaperDollSidebarTab1.itemLevelText:SetPoint('BOTTOM')
            PaperDollSidebarTab1.itemLevelText:EnableMouse(true)
            PaperDollSidebarTab1.itemLevelText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            PaperDollSidebarTab1.itemLevelText:SetScript('OnMouseDown', function()
                e.call('PaperDollFrame_SetSidebar', PaperDollSidebarTab1, 1)--PaperDollFrame.lua
            end)
            PaperDollSidebarTab1.itemLevelText:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
                e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
                e.tips:AddLine(' ')
                e.tips:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '物品等级：%d' or CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, self.avgItemLevel or ''))
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
        end
        PaperDollSidebarTab1.itemLevelText.avgItemLevel= avgItemLevel

        if avgItemLevel~= avgItemLevelPvp and avgItemLevelPvp and not PaperDollSidebarTab1.itemLevelPvPText then--PVP
            PaperDollSidebarTab1.itemLevelPvPText=e.Cstr(PaperDollSidebarTab1, {justifyH='CENTER', mouse=true})
            PaperDollSidebarTab1.itemLevelPvPText:SetPoint('TOP')
            PaperDollSidebarTab1.itemLevelPvPText:SetScript('OnMouseDown', function(self)
                e.call(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)--PaperDollFrame.lua
            end)
            PaperDollSidebarTab1.itemLevelPvPText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            PaperDollSidebarTab1.itemLevelPvPText:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
                e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
                e.tips:AddLine(' ')
                e.tips:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and 'PvP物品等级 %d' or ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT, self.avgItemLevel or '0'))
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
                self:SetAlpha(0.3)
            end)
        end
    end
    if PaperDollSidebarTab1.itemLevelText then
        PaperDollSidebarTab1.itemLevelText:SetText(avgItemLevel and avgItemLevel>0 and format('%i', avgItemLevel) or '')
    end

    if PaperDollSidebarTab1.itemLevelPvPText then
        PaperDollSidebarTab1.itemLevelPvPText:SetText(avgItemLevelPvp and avgItemLevelPvp>0 and format('%i', avgItemLevelPvp) or '')
    end
end

local function recipeLearned(recipeSpellID)--是否已学配方
    local info= C_TradeSkillUI.GetRecipeInfo(recipeSpellID)
    return info and info.learned
end













local function set_Engineering(self, slot, link, use, isPaperDollItemSlot)--增加 [潘达利亚工程学: 地精滑翔器][诺森德工程学: 氮气推进器]
    if not ((slot==15 and recipeLearned(126392)) or (slot==6 and recipeLearned(55016))) or use or Save.hide or not link or not isPaperDollItemSlot then
        if self.engineering  then
            self.engineering:SetShown(false)
        end
        return
    end

    if not self.engineering then
        local h=self:GetHeight()/3
        self.engineering=e.Cbtn(self, {icon='hide',size={h,h}})
        self.engineering:SetNormalTexture(136243)
        if is_Left_Slot(slot) then
            self.engineering:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)
        else
            self.engineering:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
        end
        self.engineering.spell= slot==15 and 126392 or 55016
        self.engineering:SetScript('OnMouseDown' ,function(self2,d)
            if d=='LeftButton' then
                C_TradeSkillUI.OpenTradeSkill(202)
                C_TradeSkillUI.CraftRecipe(self2.spell)
                C_TradeSkillUI.CloseTradeSkill()
                ToggleCharacter("PaperDollFrame", true)
            elseif d=='RightButton' then
                C_TradeSkillUI.OpenTradeSkill(202)
            end
        end)
        self.engineering:SetScript('OnEnter' ,function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self2.spell)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '商业技能' or TRADESKILLS), e.Icon.right)
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需求' or NEED), (e.onlyChinese and '打开一次' or CHALLENGES_LASTRUN_TIME)..'('..(e.onlyChinese and '打开' or UNWRAP)..')')
                e.tips:Show()
        end)
        self.engineering:SetScript("OnMouseUp", function()
            local n=GetItemCount(90146, true)
                if n==0 then
                    print(select(2, GetItemInfo(90146)) or (e.onlyChinese and '附加材料' or OPTIONAL_REAGENT_TUTORIAL_TOOLTIP_TITLE), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
                end
        end)
        self.engineering:SetScript('OnLeave',GameTooltip_Hide)
    end
    self.engineering:SetShown(true)
end

local subClassToSlot={
    [1]= 0,--头	
    [2]= 1,--脖子	
    [3]= 2,--肩膀	
    [15]= 3,--披风	
    [5]= 4,--胸部	
    [9]= 5,--手腕	
    [10]= 6,--手
    [6]= 7,--腰部	
    [7]= 8,--腿	
    [8]= 9,--脚	
    [11]= 10,--手指	
    [12]= 10,--手指	
    [16]= 11,--武器	单手武器
    --[16]= 12,--	双手武器	
    [17]= 13,--盾牌/副手	
}
local function get_no_Enchant_Bag(slot)--取得，物品，bag, slot    
    for bagIndex= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do--Constants.InventoryConstants.NumBagSlots
        for slotIndex=1, C_Container.GetContainerNumSlots(bagIndex) do
            local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
            if info and info.itemID then
                local classID, subClassID= select(6, GetItemInfoInstant(info.itemID))
                if classID==8 and (slot==16 and subClassID==12 or subClassID==subClassToSlot[slot]) then
                    return {bag= bagIndex, slot= slotIndex}
                end
            end
        end
    end
end
local function set_no_Enchant(self, slot, find, isPaperDollItemSlot)--附魔，按钮
    if not subClassToSlot[slot] or UnitAffectingCombat('player') then
        return
    end
    local tab
    if not find and not Save.hide and isPaperDollItemSlot then
        tab=get_no_Enchant_Bag(slot)--取得，物品，bag, slot
        if tab and not self.noEnchant then
            local h=self:GetHeight()/3
            self.noEnchant= e.Cbtn(self, {size={h, h}, type=true, icon='hide'})
            self.noEnchant:SetAttribute("type", "item")
            self.noEnchant.slot= slot
            if is_Left_Slot(slot) then
                self.noEnchant:SetPoint('LEFT', self, 'RIGHT', 8, 0)
            else
                self.noEnchant:SetPoint('RIGHT', self, 'LEFT', -8, 0)
            end
            self.noEnchant:SetScript('OnMouseDown', function()
                if MerchantFrame:IsVisible() then
                    MerchantFrame:SetShown(false)
                end
                if SendMailFrame:IsShown() then
                    MailFrame:SetShown(false)
                end
            end)
            self.noEnchant:SetScript('OnLeave',function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            self.noEnchant:SetScript('OnEnter' ,function(self2)
                if self2.tab then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetBagItem(self2.tab.bag, self2.tab.slot)
                    if UnitAffectingCombat('player') then
                        e.tips:AddLine(' ')
                        e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
                    end
                    e.tips:Show()
                    self2:SetAlpha(0.3)
                end
            end)

            self.noEnchant:SetScript('OnShow', function(self2)
                self2:RegisterEvent('BAG_UPDATE_DELAYED')
            end)
            self.noEnchant:SetScript('OnHide', function(self2)
                self2:UnregisterEvent('BAG_UPDATE_DELAYED')
            end)
            self.noEnchant:RegisterEvent('BAG_UPDATE_DELAYED')
            self.noEnchant:SetScript('OnEvent', function(self2)
                if not UnitAffectingCombat('player') then
                    local tab2=get_no_Enchant_Bag(self2.slot)--取得，物品，bag, slot
                    if tab2 then
                        self2:SetAttribute("item", tab2.bag..' '..tab2.slot)
                    end
                    self2.tab= tab2
                end
            end)

            local texture= self.noEnchant:CreateTexture(nil, 'OVERLAY')
            texture:SetAllPoints(self.noEnchant)
            texture:SetAtlas('bags-icon-addslots')

        end
    end
    if self.noEnchant then
        self.noEnchant.tab=tab
        self.noEnchant:SetShown(tab and true or false)
        if tab then
            self.noEnchant:SetAttribute("item", tab.bag..' '..tab.slot)
        end
    end
end

local function set_Item_Tips(self, slot, link, isPaperDollItemSlot)--附魔, 使用, 属性
    local enchant, use, pvpItem, upgradeItem, createItem
    local unit = (not isPaperDollItemSlot and InspectFrame) and InspectFrame.unit or 'player'
    local isLeftSlot= is_Left_Slot(slot)

    if link and not Save.hide and not IsCorruptedItem(link) then
        local dateInfo= e.GetTooltipData({hyperLink=link, text={enchantStr, pvpItemStr, upgradeStr,ITEM_CREATED_BY_Str}, onlyText=true})--物品提示，信息
        enchant, use, pvpItem, upgradeItem, createItem= dateInfo.text[enchantStr], dateInfo.red, dateInfo.text[pvpItemStr], dateInfo.text[upgradeStr], dateInfo.text[ITEM_CREATED_BY_Str]
    end

    if enchant and not self.enchant then--附魔
        local h=self:GetHeight()/3
        self.enchant= self:CreateTexture()
        self.enchant:SetSize(h,h)
        if isLeftSlot then
            self.enchant:SetPoint('LEFT', self, 'RIGHT', 8, 0)
        else
            self.enchant:SetPoint('RIGHT', self, 'LEFT', -8, 0)
        end
        self.enchant:SetTexture(463531)
        self.enchant:EnableMouse(true)
        self.enchant:SetScript('OnLeave',function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        self.enchant:SetScript('OnEnter' ,function(self2)
            if self2.tips then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(self2.tips)
                e.tips:Show()
                self2:SetAlpha(0.3)
            end
        end)
    end
    if self.enchant then
        self.enchant.tips= enchant
        self.enchant:SetShown(enchant and true or false)
    end

    set_no_Enchant(self, slot, enchant and true or false, isPaperDollItemSlot)--附魔，按钮

    use=  link and select(2, GetItemSpell(link))--物品是否可使用
    if use and not self.use then
        local h=self:GetHeight()/3
        self.use= self:CreateTexture()
        self.use:SetSize(h,h)
        if isLeftSlot then
            self.use:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)
        else
            self.use:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
        end
        self.use:SetAtlas('soulbinds_tree_conduit_icon_utility')
        self.use:EnableMouse(true)
        self.use:SetScript('OnLeave',function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        self.use:SetScript('OnEnter' ,function(self2)
            if self2.spellID then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(self2.spellID)
                e.tips:Show()
                self2:SetAlpha(0.3)
            end
        end)
    end
    if self.use then
        self.use.spellID= use
        self.use:SetShown(use and true or false)
    end
    set_Engineering(self, slot, link, use, isPaperDollItemSlot)--地精滑翔,氮气推进器

    if pvpItem and not self.pvpItem then--提示PvP装备
        local h=self:GetHeight()/3
        self.pvpItem=self:CreateTexture(nil,'OVERLAY',nil,7)
        self.pvpItem:SetSize(h,h)
        if isLeftSlot then
            self.pvpItem:SetPoint('LEFT', self, 'RIGHT', -2.5,0)
        else
            self.pvpItem:SetPoint('RIGHT', self, 'LEFT', 2.5,0)
        end
        self.pvpItem:SetAtlas('pvptalents-warmode-swords')
        self.pvpItem:EnableMouse(true)
        self.pvpItem:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        self.pvpItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine((e.onlyChinese and "装备：在竞技场和战场中将物品等级提高至%d。" or PVP_ITEM_LEVEL_TOOLTIP):format(self2.tips))
                e.tips:Show()
                self2:SetAlpha(0.3)
            end
        end)
    end
    if self.pvpItem then
        self.pvpItem.tips= pvpItem
        self.pvpItem:SetShown(pvpItem and true or false)
    end

    if upgradeItem and not self.upgradeItem then--"升级：%s/%s"
        if isLeftSlot then
            self.upgradeItem= e.Cstr(self, {color={r=0,g=1,b=0}, mouse=true})
            self.upgradeItem:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT',1,0)
        else
            self.upgradeItem= e.Cstr(self, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
            self.upgradeItem:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT',2,0)
        end
        self.upgradeItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine((e.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                e.tips:Show()
                self2:SetAlpha(0.3)
            end
        end)
        self.upgradeItem:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    end
    if self.upgradeItem then
        self.upgradeItem.tips=upgradeItem
        local upText
        if upgradeItem then
            local min, max= upgradeItem:match('(%d+)/(%d+)')
            if min and max then
                if min==max then
                    upText= "|A:VignetteKill:0:0|a"
                else
                    min, max= tonumber(min), tonumber(max)
                    upText= max-min
                end
            end
        end
        self.upgradeItem:SetText(upText or '')
    end

    local upgradeItemText
    local upText= upgradeItem and upgradeItem:match('(.-)%d+/%d+')--"升级：%s %s/%s"
    if upText then
        upgradeItemText= strlower(e.WA_Utf8Sub(upText,1,3, true))
        if not self.upgradeItemText then
            local h= self:GetHeight()/3
            if isLeftSlot then
                self.upgradeItemText= e.Cstr(self, {color={r=0,g=1,b=0}, mouse=true})
                self.upgradeItemText:SetPoint('LEFT', self, 'RIGHT',h+8,0)
            else
                self.upgradeItemText= e.Cstr(self, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
                self.upgradeItemText:SetPoint('RIGHT', self, 'LEFT',-h-8,0)
            end
            self.upgradeItemText:SetScript('OnEnter', function(self2)
                if self2.tips then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine((e.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                    e.tips:Show()
                    self2:SetAlpha(0.3)
                end
            end)
            self.upgradeItemText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        end
        self.upgradeItemText.tips= upgradeItem
        local quality = GetInventoryItemQuality(unit, slot)--颜色
        local hex = quality and select(4, GetItemQualityColor(quality))
        if hex then
            upgradeItemText= '|c'..hex..upgradeItemText..'|r'
        end
    end
    if  self.upgradeItemText then--"升级：%s %s/%s"
        self.upgradeItemText:SetText(upgradeItemText or '')
    end




    if createItem and not self.createItem then--"|cff00ff00<由%s制造>|r" ITEM_CREATED_BY 
        if isLeftSlot then
            self.createItem= e.Cstr(self, {color={r=0,g=1,b=0}, mouse=true})
            self.createItem:SetPoint('LEFT', self, 'RIGHT',1,0)
        else
            self.createItem= e.Cstr(self, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
            self.createItem:SetPoint('RIGHT', self, 'LEFT',2,0)
        end
        self.createItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(format(e.onlyChinese and '|cff00ff00<由%s制造>|r' or ITEM_CREATED_BY, self2.tips))
                e.tips:Show()
                self2:SetAlpha(0.3)
            end
        end)
        self.createItem:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    end
    if self.createItem then
        self.createItem.tips=createItem
        self.createItem:SetText(createItem and '|A:communities-icon-notification:10:10|a' or '')
    end




    if not Save.hide then--宝石
        local x= isLeftSlot and 8 or -8--左边插曹
        for n=1, MAX_NUM_SOCKETS do
            local gemLink= link and select(2, GetItemGem(link, n))
            if gemLink then
                e.LoadDate({id=gemLink, type='item'})
                if not self['gem'..n] then
                    self['gem'..n]=self:CreateTexture()
                    self['gem'..n]:SetSize(12.3, 12.3)--local h=self:GetHeight()/3 37 12.3
                    self['gem'..n]:EnableMouse(true)
                    self['gem'..n]:SetScript('OnEnter' ,function(self2)
                        if self2.gemLink then
                            e.tips:SetOwner(self2, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetHyperlink(self2.gemLink)
                            e.tips:Show()
                            self2:SetAlpha(0.3)
                        end
                    end)
                    self['gem'..n]:SetScript('OnLeave',function(self2) e.tips:Hide() self2:SetAlpha(1) end)
                else
                    self['gem'..n]:ClearAllPoints()
                end
                if isLeftSlot then--左边插曹
                    self['gem'..n]:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', x, 0)
                else
                    self['gem'..n]:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', x, 0)
                end
            end
            if self['gem'..n] then
                self['gem'..n].gemLink= gemLink
                self['gem'..n]:SetTexture(gemLink and C_Item.GetItemIconByID(gemLink) or 0)
                self['gem'..n]:SetShown(not gemLink and false or true)
            end

            x= isLeftSlot and x+ 12.3 or x- 12.3--左边插曹
        end
    else
        for n=1, MAX_NUM_SOCKETS do
            if self['gem'..n] then
                self['gem'..n]:SetShown(false)
            end
        end
    end

    local du, min, max
    if link and not Save.hide then
        min, max=GetInventoryItemDurability(slot)
        if min and max and max>0 then
            du=min/max*100
        end
    end
    if not self.du and du and isPaperDollItemSlot then
        self.du= CreateFrame('StatusBar', nil, self)
        local wq= slot==16 or slot==17 or slot==18--武器
        if wq then
            self.du:SetPoint('TOP', self, 'BOTTOM')
        elseif isLeftSlot then
            self.du:SetPoint('RIGHT', self, 'LEFT', -2.5,0)
        else
            self.du:SetPoint('LEFT', self, 'RIGHT', 2.5,0)
        end
        if wq then
            self.du:SetOrientation('HORIZONTAL')
            self.du:SetSize(self:GetHeight(),4)--h37
        else
            self.du:SetOrientation("VERTICAL")
            self.du:SetSize(4, self:GetHeight())--h37
        end
        self.du:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        self.du:EnableMouse(true)
        self.du:SetMinMaxValues(0, 100)
        self.du:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(self2. du and 1 or 0) end)
        self.du:SetScript('OnEnter', function(self2)
            if self2.du then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(format(e.onlyChinese and '耐久度 %d / %d' or DURABILITY_TEMPLATE, min,  max), format('%i%%', self2.du))
                e.tips:Show()
                self2:SetAlpha(0.3)
            end
        end)
        self.du.texture= self.du:CreateTexture(nil, "BACKGROUND")
        self.du.texture:SetAllPoints(self.du)
        self.du.texture:SetColorTexture(1,0,0)
        self.du.texture:SetAlpha(0.3)
    end
    if self.du then
        if du then
            if du and du >70 then
                self.du:SetStatusBarColor(0,1,0)
            elseif du and du >30 then
                self.du:SetStatusBarColor(1,1,0)
            else
                self.du:SetStatusBarColor(1,0,0)
            end
        end
        self.du:SetValue(du or 0)
        self.du.du=du
        self.du.min= min
        self.du.max= max
        self.du:SetAlpha(du and 1 or 0)
    end
end

local function set_Slot_Num_Label(self, slot, isEquipped)--栏位
    if not self.slotText and not Save.hide and not isEquipped then
        self.slotText=e.Cstr(self, {color=true, justifyH='CENTER', mouse=true})
        self.slotText:EnableMouse(true)
        self.slotText:SetAlpha(0.3)
        self.slotText:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine((e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS)..' '..(self2.name and _G[strupper(strsub(self2.name, 10))] or self2.name or ''), self2.slot)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(1)
        end)
        self.slotText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.3) end)
        self.slotText:SetPoint('CENTER')
    end
    if self.slotText then
        self.slotText.slot= slot
        self.slotText.name= self:GetName()
        self.slotText:SetText(slot)
        self.slotText:SetShown(not Save.hide and not isEquipped)
    end
end

local function set_item_Set(self, link)--套装
    local set
    if link and not Save.hide then
        set=select(16 , GetItemInfo(link))
        if set then
            if set and not self.set then
                self.set=self:CreateTexture()
                self.set:SetAllPoints(self)
                self.set:SetAtlas('UI-HUD-MicroMenu-Highlightalert')
            end
        end
    end
    if self.set then
        self.set:SetShown(set and true or false)
    end
end










local function Title()--头衔数量
    if not PaperDollSidebarTab2 or not PAPERDOLL_SIDEBARS[2].IsActive() then
        return
    end
    local nu
    if not Save.hide then
        local to=GetKnownTitles() or {}
        nu= #to-1
        nu= nu>0 and nu or nil
        if not PaperDollSidebarTab2.titleNumeri then
            PaperDollSidebarTab2.titleNumeri= e.Cstr(PaperDollSidebarTab2, {justifyH='CENTER', mouse=true})
            PaperDollSidebarTab2.titleNumeri:SetPoint('BOTTOM')
            PaperDollSidebarTab2.titleNumeri:EnableMouse(true)
            PaperDollSidebarTab2.titleNumeri:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            PaperDollSidebarTab2.titleNumeri:SetScript('OnMouseDown', function(self)
                e.call(PaperDollFrame_SetSidebar, PaperDollSidebarTab2, 2)--PaperDollFrame.lua
            end)
            PaperDollSidebarTab2.titleNumeri:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(format(e.onlyChinese and '头衔：%s' or RENOWN_REWARD_TITLE_NAME_FORMAT, self2.num or ''), e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL, 0,1,0, 0,1,0)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
                self2:SetAlpha(0.3)
            end)
        end
    end
    if PaperDollSidebarTab2.titleNumeri then
        PaperDollSidebarTab2.titleNumeri.num= nu
        PaperDollSidebarTab2.titleNumeri:SetText(nu or '')
    end
end





















--####################
--装备, 标签, 内容,提示
--####################
local function set_set_PaperDollSidebarTab3_Text_Tips(self)
    self:EnableMouse(true)
    self:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
    self:SetScript('OnMouseDown', function()
        e.call(PaperDollFrame_SetSidebar, PaperDollSidebarTab3, 3)--PaperDollFrame.lua
    end)
    self:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        if self2.setID then
            e.tips:SetEquipmentSet(self.setID)
            e.tips:AddLine(' ')
        end
        e.tips:AddDoubleLine(self2.tooltip, self2.tooltip2, 0,1,0,0,1,0)
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        self2:SetAlpha(0.3)
    end)
end
local function set_PaperDollSidebarTab3_Text()--标签, 内容,提示
    local self= PaperDollSidebarTab3
    if not self then
        return
    end
    local name, icon, specIcon,nu
    local specName, setID
    if not Save.hide then
        local setIDs=C_EquipmentSet.GetEquipmentSetIDs()
        for _, v in pairs(setIDs) do
            local name2, icon2, _, isEquipped, numItems= C_EquipmentSet.GetEquipmentSetInfo(v)
            if isEquipped then
                name=name2
                name=e.WA_Utf8Sub(name, 2, 5)
                if icon2 and icon2~=134400 then
                    icon=icon2
                end
                local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(v)
                if specIndex then
                    local _, specName2, _, icon3 = GetSpecializationInfo(specIndex)
                    specName= specName2
                    if icon3 then
                        specIcon=icon3
                    end
                end
                nu=numItems
                setID= v
                break
            end
        end
    end

    if not self.set and name then--名称
        self.set=e.Cstr(self, {justifyH='CENTER'})
        self.set:SetPoint('BOTTOM', 2, 0)
        set_set_PaperDollSidebarTab3_Text_Tips(self.set)
        self.set.tooltip= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '名称' or NAME)..'|r'
    end
    if self.set then
        self.set:SetText(name or '')
        self.set:SetShown(name and true or false)
        self.set.tooltip2= name
        self.set.setID= setID
    end

    if not self.tex and icon then--套装图标图标
        self.tex=self:CreateTexture(nil, 'OVERLAY')
        self.tex:SetPoint('CENTER',1,-2)
        local w, h=self:GetSize()
        self.tex:SetSize(w-4, h-4)
    end
    if self.tex then
        self.tex:SetTexture(icon or 0)
        self.tex:SetShown(icon and true or false)
    end

    if not self.spec and specIcon then--天赋图标
        self.spec=self:CreateTexture(nil, 'OVERLAY')
        self.spec:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT')
        local h, w= self:GetSize()
        self.spec:SetSize(h/3+2, w/3+2)
        set_set_PaperDollSidebarTab3_Text_Tips(self.spec)
        self.spec.tooltip= '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '%s专精' or PROFESSIONS_SPECIALIZATIONS_PAGE_NAME, e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER)..'|r'
    end
    if self.spec then
        self.spec:SetTexture(specIcon or 0)
        self.spec:SetShown(specIcon and true or false)
        self.spec.tooltip2= (specIcon and "|T"..specIcon..':0|t' or '')..(specName or '' )
        self.spec.setID= setID
    end

    if not self.nu and nu then--套装数量
        self.nu=e.Cstr(self, {justifyH='RIGHT'})
        self.nu:SetPoint('LEFT', self, 'RIGHT',0, 4)
        self.nu.tooltip= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '装备' or EQUIPSET_EQUIP)
        set_set_PaperDollSidebarTab3_Text_Tips(self.nu)
    end
    if self.nu then
        self.nu:SetText(nu or '')
        self.nu:SetShown(nu and true or false)
        self.nu.tooltip2= (e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..(nu or '')
        self.nu.setID= setID
    end
end


















--#######
--装备管理
--#######
local function Init_TrackButton()--添加装备管理框
    if not Save.equipment or not PAPERDOLL_SIDEBARS[3].IsActive() or Save.hide or TrackButton then
        if TrackButton then
            TrackButton:set_shown()
            TrackButton:init_buttons()
        end
        return
    end


    TrackButton=e.Cbtn(UIParent, {icon='hide'})--添加移动按钮
    TrackButton.buttons={}--添加装备管理按钮

    TrackButton:SetSize(20,20)
    TrackButton:RegisterForDrag("RightButton")
    TrackButton:SetClampedToScreen(true)
    TrackButton:SetMovable(true)
    TrackButton.text= e.Cstr(TrackButton, {color=true, alpha=0.5})
    TrackButton.text:SetPoint('BOTTOM')

    TrackButton:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then
            self:StartMoving()
        end
    end)
    TrackButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        Save.Equipment={self:GetPoint(1)}
        Save.Equipment[2]=nil
        self:Raise()
    end)
    TrackButton:SetScript('OnMouseDown', function(_, d)
        if d=='RightButton' and IsAltKeyDown() then--移动图标
            SetCursor('UI_MOVE_CURSOR')
        end
    end)
    TrackButton:SetScript("OnMouseUp", ResetCursor)
    TrackButton:SetScript("OnClick", function(self, d)
        if d=='RightButton' and IsControlKeyDown() then--图标横,或 竖
            Save.EquipmentH= not Save.EquipmentH and true or nil
            for index, btn in pairs(self.buttons) do
                btn:ClearAllPoints()
                self:set_button_point(btn, index)--设置位置
            end

        elseif d=='LeftButton' and not IsModifierKeyDown() then--打开/关闭角色界面
            ToggleCharacter("PaperDollFrame")
            if PaperDollFrame:IsShown() then
                PaperDollFrame_SetSidebar(PaperDollFrame, 3)
            end
        end
    end)
    TrackButton:SetScript('OnMouseWheel',function(self, d)--放大
        if IsAltKeyDown() then
            local n=Save.equipmentFrameScale or 1
            if d==1 then
                n=n+0.05
            elseif d==-1 then
                n=n-0.05
            end
            n= n>4 and 4 or n
            n= n<0.4 and 0.4 or n
            Save.equipmentFrameScale=n
            self:set_scale()--缩放
            print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, GREEN_FONT_COLOR_CODE..n)
        end
    end)
    TrackButton:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.equipmentFrameScale or 1),'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(not Save.EquipmentH and e.Icon.toRight2..(e.onlyChinese and '向右' or BINDING_NAME_STRAFERIGHT) or (e.Icon.down2..(e.onlyChinese and '向下' or BINDING_NAME_PITCHDOWN)),
                'Ctrl+'..e.Icon.right)

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.onlyChinese and '装备管理'or EQUIPMENT_MANAGER)
        e.tips:Show()
        if panel.equipmentButton:IsVisible() then
            panel.equipmentButton:SetButtonState('PUSHED')
            panel.equipmentButton:SetAlpha(1)
        end
    end)
    TrackButton:SetScript("OnLeave", function()
        ResetCursor()
        e.tips:Hide()
        panel.equipmentButton:SetButtonState('NORMAL')
        panel.equipmentButton:SetAlpha(0.5)
    end)


    --装等
    function TrackButton:set_player_itemLevel()
        self.text:SetFormattedText('%i', select(2, GetAverageItemLevel()) or 0)
    end


    --位置保存
    function TrackButton:set_point()
        if Save.Equipment then
            self:SetPoint(Save.Equipment[1], UIParent, Save.Equipment[3], Save.Equipment[4], Save.Equipment[5])
        elseif e.Player.husandro then
            self:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.FrameTexture, 'TOPRIGHT',-4,-3)
        else
            self:SetPoint('BOTTOMRIGHT', PaperDollItemsFrame, 'TOPRIGHT')
        end
    end

    --缩放
    function TrackButton:set_scale()
        self:SetScale(Save.equipmentFrameScale or 1)
    end


    --设置，显示
    function TrackButton:set_shown()
        self:SetShown(not Save.hide and Save.equipment)
    end

    --设置，列表位置
    function TrackButton:set_button_point(button, index)
        local btn= index==1 and TrackButton or TrackButton.buttons[index-1]
        if Save.EquipmentH then
            button:SetPoint('LEFT', btn, 'RIGHT')
        else
            button:SetPoint('TOP', btn, 'BOTTOM')
        end
    end

    --提示，没有装上
    function TrackButton:tips_not_equipment()
        if not IsInInstance() or not self:IsShown() or not IsInGroup() then
            return
        end
        local equipped
        local num=0
        for _, setID in pairs(C_EquipmentSet.GetEquipmentSetIDs() or {}) do
            local isEquipped, numItems= select(4, C_EquipmentSet.GetEquipmentSetInfo(setID))
            if numItems>0 then
                num= num+1
                if isEquipped then
                    equipped=true
                    break
                end
            end
        end
        e.Set_HelpTips({frame=self, point='left', size={40,40}, color={r=1,g=0,b=0,a=1}, show= not equipped and num>0})
    end

    --建立，按钮
    function TrackButton:create_button(index)
        local btn=e.Cbtn(self, {icon='hide',size={20,20}})
        btn.texture= btn:CreateTexture(nil, 'OVERLAY')
        btn.texture:SetSize(26,26)
        btn.texture:SetPoint('CENTER')
        btn.texture:SetAtlas('AlliedRace-UnlockingFrame-GenderMouseOverGlow')
        btn.text= e.Cstr(btn, {color={r=1,g=0,b=0}})
        btn.text:SetPoint('BOTTOMRIGHT')
        self:set_button_point(btn, index)--设置位置
        btn:SetScript("OnClick",function(frame)
            if not UnitAffectingCombat('player') then
                C_EquipmentSet.UseEquipmentSet(frame.setID)
                if TrackButton.HelpTips then
                    TrackButton.HelpTips:SetShown(false)
                end
                C_Timer.After(1.5, function()
                    LvTo()--修改总装等
                end)
            else
                print(id, addName, RED_FONT_COLOR_CODE, e.onlyChinese and '你无法在战斗中实施那个动作' or ERR_NOT_IN_COMBAT)
            end
        end)
        btn:SetScript("OnEnter", function(frame)
            if ( frame.setID ) then
                e.tips:SetOwner(frame, "ANCHOR_LEFT")
                e.tips:SetEquipmentSet(frame.setID)
                if UnitAffectingCombat('player') then
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine(' ', '|cnRED_FONT_COLOR:'..(e.onlyChinese and '你无法在战斗中实施那个动作' or ERR_NOT_IN_COMBAT))
                end
                local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(frame.setID)
                if specIndex then
                    local _, specName2, _, icon3 = GetSpecializationInfo(specIndex)
                    if icon3 and specName2 then
                        e.tips:AddLine(' ')
                        e.tips:AddLine(format(e.onlyChinese and '%s专精' or PROFESSIONS_SPECIALIZATIONS_PAGE_NAME, '|T'..icon3..':0|t|cffff00ff'..specName2..'|r'))
                    end
                end
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id,addName)
                e.tips:Show()
                --local name, iconFileID, _, isEquipped2, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
                if panel.equipmentButton:IsVisible() then
                    panel.equipmentButton:SetButtonState('PUSHED')
                    panel.equipmentButton:SetAlpha(1)
                end
            end
            frame:GetParent():SetButtonState('PUSHED')
            frame:SetAlpha(1)
        end)

        btn:SetScript("OnLeave",function(frame)
            frame:GetParent():SetButtonState('NORMAL')
            e.tips:Hide()
            panel.equipmentButton:SetButtonState('NORMAL')
            panel.equipmentButton:SetAlpha(0.5)
            frame:set_alpha()
        end)
        btn:RegisterEvent('PLAYER_REGEN_DISABLED')
        btn:RegisterEvent('PLAYER_REGEN_ENABLED')
        function btn:set_shown()
            self:SetShown(self.setID and (self.isEquipped or not UnitAffectingCombat('player')))
        end
        function btn:set_alpha()
            self:SetAlpha((self.numItems==0 and not self.isEquipped) and 0.3 or 1)
        end
        btn:SetScript('OnEvent', btn.set_shown)
        self.buttons[index]=btn
        return btn
    end
    --设置，初始，按钮
    function TrackButton:init_buttons()
        if not self:IsShown() then
            return
        end
        local setIDs= SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs() or {})--PaperDollFrame.lua
        local numIndex=0
        for index, setID in pairs(setIDs) do
            local texture, _, isEquipped, numItems, _, _, numLost= select(2, C_EquipmentSet.GetEquipmentSetInfo(setID))

            local btn=self.buttons[index] or self:create_button(index)
            if numItems==0 then
                btn:SetNormalAtlas('groupfinder-eye-highlight')
            else
                if texture==134400 then--?图标
                    local specIndex = C_EquipmentSet.GetEquipmentSetAssignedSpec(setID)
                    if specIndex then
                        texture= select(4, GetSpecializationInfo(specIndex))
                    end
                end
                btn:SetNormalTexture(texture or 0)
            end
            btn.text:SetText(numLost>0 and numLost or '')
            btn.texture:SetShown(isEquipped)
            btn.setID=setID
            btn.isEquipped= isEquipped
            btn.numItems=numItems
            numIndex=index
            btn:set_shown()
            btn:set_alpha()
        end
        for index= numIndex+1, #self.buttons, 1 do
            self.buttons[index].setID=nil
            self.buttons[index].isEquipped=nil
            self.buttons[index].numItems=0
            self.buttons[index]:set_shown()
        end
    end

    TrackButton:set_point()
    TrackButton:set_scale()
    TrackButton:set_shown()
    TrackButton:init_buttons()
    TrackButton:tips_not_equipment()
    TrackButton:set_player_itemLevel()

    --更新
    hooksecurefunc('PaperDollEquipmentManagerPane_Update',  TrackButton.init_buttons)

    TrackButton:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
    TrackButton:RegisterEvent('EQUIPMENT_SETS_CHANGED')
    TrackButton:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
    TrackButton:RegisterEvent('BAG_UPDATE_DELAYED')
    TrackButton:RegisterEvent('PLAYER_ENTERING_WORLD')
    TrackButton:RegisterEvent('READY_CHECK')

    --TrackButton:RegisterEvent('BAG_UPDATE')
    TrackButton:SetScript('OnEvent', function(self, event)
        if event=='PLAYER_ENTERING_WORLD' or event=='READY_CHECK' then
            self:tips_not_equipment()
        elseif not self.time or self.time:IsCancelled() then
            self.time= C_Timer.NewTimer(0.6, function()
                self:init_buttons()
                self:set_player_itemLevel()
                self.time:Cancel()
            end)
        end
    end)
end















--############
--装备,总耐久度
--############
local function GetDurationTotale()
    if Save.hide then
        if panel.durabilityText then
            panel.durabilityText:SetText('')
        end
    end
    if not panel.durabilityText then
        panel.durabilityText= e.Cstr(panel, {copyFont=CharacterLevelText, mouse=true})
        panel.durabilityText:SetPoint('LEFT', panel.serverText, 'RIGHT')
        panel.durabilityText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        panel.durabilityText:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '耐久度' or DURABILITY, self2.value)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(0.3)
        end)
    end
    local du= e.GetDurabiliy()--耐久度
    panel.durabilityText.value=du
    panel.durabilityText:SetText(du or '')
end


















--#######
--装备弹出
--EquipmentFlyout.lua
local function setFlyout(button, itemLink, slot)
    local text, level, dateInfo
    if not Save.hide then
        if not button.level then
            button.level= e.Cstr(button)
            button.level:SetPoint('BOTTOM')
        end
        dateInfo= e.GetTooltipData({hyperLink=itemLink, itemID=itemLink and GetItemInfoInstant(itemLink) , text={upgradeStr, pvpItemStr, itemLevelStr}, onlyText=true})--物品提示，信息

        if dateInfo and dateInfo.text[itemLevelStr] then
            level= tonumber(dateInfo.text[itemLevelStr])
        end
        level= level or itemLink and GetDetailedItemLevelInfo(itemLink)
        text= level
        if text then
            local itemQuality = C_Item.GetItemQualityByID(itemLink)
            if itemQuality then
                local hex = select(4, GetItemQualityColor(itemQuality))
                if hex then
                    text= '|c'..hex..text..'|r'
                end
            end
        end
    end
    if button.level then
        button.level:SetText(text or '')
    end

    local upgrade, pvpItem
    local updown--UpgradeFrame等级，比较
    if dateInfo then
        upgrade, pvpItem=dateInfo.text[upgradeStr], dateInfo.text[pvpItemStr]
        upgrade= upgrade and upgrade:match('(%d+/%d+)')
        if upgrade and not button.upgrade then
            button.upgrade= e.Cstr(button, {color={r=0,g=1,b=0}})
            button.upgrade:SetPoint('LEFT')
        end
        if button.upgrade then
            button.upgrade:SetText(upgrade or '')
        end
        if level then
            if not slot or slot==0 then
                local itemEquipLoc= itemLink and select(4, GetItemInfoInstant(itemLink))
                slot= itemEquipLoc and e.itemSlotTable[itemEquipLoc]
            end
            if slot then
                local itemLink2 = GetInventoryItemLink('player', slot)
                if itemLink2 then
                    updown = GetDetailedItemLevelInfo(itemLink2)
                    if updown then
                        updown=level-updown
                        if updown>0 then
                            updown= '|cnGREEN_FONT_COLOR:+'..updown..'|r'
                        elseif updown<0 then
                            updown= '|cnRED_FONT_COLOR:'..updown..'|r'
                        elseif updown==0 then
                            updown= nil
                        end
                    else
                        updown= e.Icon.up2
                    end
                else
                    updown= e.Icon.up2
                end
            end
        end
    end
    if updown and not button.updown then
        button.updown=e.Cstr(button)
        button.updown:SetPoint('TOP')
    end
    if button.updown then
        button.updown:SetText(updown or '')
    end

    set_item_Set(button, itemLink)--套装

    if pvpItem and not button.pvpItem and not Save.hide then--提示PvP装备
        local h=button:GetHeight()/3
        button.pvpItem=button:CreateTexture(nil,'OVERLAY',nil,7)
        button.pvpItem:SetSize(h,h)
        button.pvpItem:SetPoint('RIGHT')
        button.pvpItem:SetAtlas('Warfronts-BaseMapIcons-Horde-Barracks-Minimap')
    end
    if button.pvpItem then
        button.pvpItem:SetShown(pvpItem and true or false)
    end
end




















--#########
--目标, 装备
--#########
local function Init_Target_InspectUI()
    local self= InspectPaperDollFrame
    panel.Init_Show_Hide_Button(InspectFrame, _G['MoveZoomInButtonPerInspectFrame'])

    if not self.initButton and not Save.hide then
        if self.ViewButton then
            e.Cstr(nil, {changeFont= InspectLevelText, size=20})
            self.ViewButton:ClearAllPoints()
            self.ViewButton:SetPoint('LEFT', InspectLevelText, 'RIGHT',20,0)
            self.ViewButton:SetSize(25,25)
            self.ViewButton:SetText(e.onlyChinese and '试' or e.WA_Utf8Sub(VIEW,1))
        end
        if InspectPaperDollItemsFrame.InspectTalents then
            InspectPaperDollItemsFrame.InspectTalents:SetSize(25,25)
            InspectPaperDollItemsFrame.InspectTalents:SetText(e.onlyChinese and '赋' or e.WA_Utf8Sub(TALENT,1))
        end
        self.initButton=true
    end
end

local function set_InspectPaperDollItemSlotButton_Update(self)
    local slot= self:GetID()
	local link= not Save.hide and GetInventoryItemLink(InspectFrame.unit, slot) or nil
	e.LoadDate({id=link, type='item'})--加载 item quest spell
    --set_Gem(self, slot, link)
    set_Item_Tips(self, slot, link, false)
    set_Slot_Num_Label(self, slot, link and true or false)--栏位, 帐号最到物品等级
    e.Set_Item_Stats(self, link, {point=self.icon})
    if not self.OnEnter and not Save.hide then
        self:SetScript('OnEnter', function(self2)
            if self2.link then
                e.tips:ClearLines()
                e.tips:SetOwner(InspectFrame, "ANCHOR_RIGHT")
                e.tips:SetHyperlink(self2.link)
                e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.left)
                e.tips:Show()
            end
        end)
        self:SetScript('OnLeave', GameTooltip_Hide)
        self:SetScript('OnMouseDown', function(self2)
            e.Chat(self2.link, nil, true)
            --local chat=SELECTED_DOCK_FRAME
            --ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)

        end)
    end
    self.link= link

    if link and not self.itemLinkText then
        self.itemLinkText= e.Cstr(self)
        local h=self:GetHeight()/3
        if slot==16 then
            self.itemLinkText:SetPoint('BOTTOMRIGHT', InspectPaperDollFrame, 'BOTTOMLEFT', 6,15)
        elseif slot==17 then
            self.itemLinkText:SetPoint('BOTTOMLEFT', InspectPaperDollFrame, 'BOTTOMRIGHT', -5,15)
        elseif is_Left_Slot(slot) then
            self.itemLinkText:SetPoint('RIGHT', self, 'LEFT', -2,0)
        else
            self.itemLinkText:SetPoint('LEFT', self, 'RIGHT', 5,0)
        end
    end
    if self.itemLinkText then
        self.itemLinkText:SetText(link or '')
    end
end

local function set_InspectPaperDollFrame_SetLevel()--目标,天赋 装等
    if Save.hide then
        return
    end
    local unit= InspectFrame.unit
    local guid= unit and UnitGUID(unit)
    local info= guid and e.UnitItemLevel[guid]
    if info and info.itemLevel and info.specID  then
        local level= UnitLevel(unit)
        local effectiveLevel= UnitEffectiveLevel(unit)
        local sex = UnitSex(unit)

        local text= e.GetPlayerInfo({unit=unit, guid=guid})
        local icon, role = select(4, GetSpecializationInfoByID(info.specID, sex))
        if icon and role then
            text=text..' |T'..icon..':0|t '..e.Icon[role]
        end
        if level and level>0 then
            text= text..' '..level
            if effectiveLevel~=level then
                text= text..'(|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r)'
            end
        end
        text= text..(sex== 2 and ' |A:charactercreate-gendericon-male-selected:0:0|a' or sex==3 and ' |A:charactercreate-gendericon-female-selected:0:0|a' or ' |A:charactercreate-icon-customize-body-selected:0:0|a')
        text= text.. info.itemLevel
        if info.col then
            text= info.col..text..'|r'
        end
        InspectLevelText:SetText(text)
    end
end



















--########################
--显示服务器名称，装备管理框
--########################
local function Init_Server_equipmentButton_Lable()
   if not panel.serverText then
        panel.serverText= e.Cstr(PaperDollItemsFrame,{color= GameLimitedMode_IsActive() and {r=0,g=1,b=0} or true, mouse=true})--显示服务器名称
        panel.serverText:SetPoint('RIGHT', CharacterLevelText, 'LEFT',-30,0)
        panel.serverText:SetScript("OnLeave",function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        panel.serverText:SetScript("OnEnter",function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local server= e.Get_Region(e.Player.realm, nil, nil)--服务器，EU， US {col=, text=, realm=}
            e.tips:AddDoubleLine(e.onlyChinese and '服务器:' or FRIENDS_LIST_REALM, server and server.col..' '..server.realm)
            local ok2
            for k, v in pairs(GetAutoCompleteRealms()) do
                if v==e.Player.realm then
                    e.tips:AddDoubleLine(v..e.Icon.star2, k, 0,1,0)
                else
                    e.tips:AddDoubleLine(v, k)
                end
                ok2=true
            end
            if not ok2 then
                e.tips:AddDoubleLine(e.onlyChinese and '唯一' or ITEM_UNIQUE, e.Player.realm)
            end

            e.tips:AddLine(' ')
            e.tips:AddDoubleLine('realmID', GetRealmID())
            e.tips:AddDoubleLine('regionID: '..e.Player.region,  GetCurrentRegionName())

            e.tips:AddLine(' ')
            if GameLimitedMode_IsActive() then
                local rLevel, rMoney, profCap = GetRestrictedAccountData()
                e.tips:AddLine(e.onlyChinese and '受限制' or CHAT_MSG_RESTRICTED, 1,0,0)
                e.tips:AddDoubleLine(e.onlyChinese and '等级' or LEVEL, rLevel, 1,0,0, 1,0,0)
                e.tips:AddDoubleLine(e.onlyChinese and '钱' or MONEY, GetMoneyString(rMoney), 1,0,0, 1,0,0)
                e.tips:AddDoubleLine(e.onlyChinese and '专业技能' or PROFESSIONS_TRACKER_HEADER_PROFESSION, profCap, 1,0,0, 1,0,0)
                e.tips:AddLine(' ')
            end
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self:SetAlpha(0.3)
        end)
    end
    local text
    if not Save.hide then
        local ser=GetAutoCompleteRealms() or {}
        local server= e.Get_Region(e.Player.realm, nil, nil)
        text= (#ser>1 and '|cnGREEN_FONT_COLOR:'..#ser..' ' or '')..e.Player.col..e.Player.realm..'|r'..(server and ' '..server.col or '')
    end
    if panel.serverText then
        panel.serverText:SetText(text or '')
    end
    if not panel.equipmentButton then
        panel.equipmentButton = e.Cbtn(PaperDollItemsFrame, {size={18,18}, atlas= Save.equipment and 'auctionhouse-icon-favorite' or e.Icon.disabled})--显示/隐藏装备管理框选项
        panel.equipmentButton:SetPoint('TOPRIGHT',-2,-40)
        panel.equipmentButton:SetAlpha(0.5)
        panel.equipmentButton:SetScript("OnClick", function(self2, d)
            if d=='LeftButton' and not IsModifierKeyDown() then
                Save.equipment= not Save.equipment and true or nil
                self2:SetNormalAtlas(Save.equipment and 'auctionhouse-icon-favorite' or e.Icon.disabled)
                Init_TrackButton()--添加装备管理框
                print(id, addName, e.GetShowHide(Save.equipment))
            elseif d=='RightButton' and IsControlKeyDown() then
                Save.Equipment=nil
                if TrackButton then
                    TrackButton:ClearAllPoints()
                    TrackButton:set_point()
                end
                print(id, addName, e.onlyChinese and '重置位置' or RESET_POSITION)
            end
        end)
        panel.equipmentButton:SetScript("OnEnter", function (self2)
            e.tips:SetOwner(self2, "ANCHOR_TOPLEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER, e.Icon.left..e.GetShowHide(Save.equipment))
            local col= not (self2.btn and Save.Equipment) and '|cff606060' or ''
            e.tips:AddDoubleLine(col..(e.onlyChinese and '重置位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(1)
            if self2.btn and self2.btn:IsShown() then
                self2.btn:SetButtonState('PUSHED')
            end
        end)
        panel.equipmentButton:SetScript("OnLeave",function(self2)
            e.tips:Hide()
            if self2.btn then
                self2.btn:SetButtonState("NORMAL")
            end
            self2:SetAlpha(0.5)
        end)
    end
    panel.equipmentButton:SetShown(not Save.hide and true or false)

end

















--################
--时空漫游战役, 提示
--################
local function set_ChromieTime()--时空漫游战役, 提示
    local canEnter = C_PlayerInfo.CanPlayerEnterChromieTime()
    if canEnter and not Save.hide and not panel.ChromieTime then
        panel.ChromieTime= e.Cbtn(PaperDollItemsFrame, {size={18,18}, atlas='ChromieTime-32x32'})
        panel.ChromieTime:SetAlpha(0.5)
        if _G['MoveZoomInButtonPerCharacterFrame'] or PaperDollItemsFrame.ShowHideButton then
            panel.ChromieTime:SetPoint('LEFT', _G['MoveZoomInButtonPerCharacterFrame'] or PaperDollItemsFrame.ShowHideButton, 'RIGHT')
            panel.ChromieTime:SetFrameLevel(CharacterFrame.TitleContainer:GetFrameLevel()+1)
        else
            panel.ChromieTime:SetPoint('BOTTOMLEFT', PaperDollItemsFrame, 5, 10)
        end
        panel.ChromieTime:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
        panel.ChromieTime:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local expansionID = UnitChromieTimeID('player')--时空漫游战役 PartyUtil.lua
            local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID);
            local expansion = option and option.name or (e.onlyChinese and '无' or NONE)
            if option and option.previewAtlas then
                expansion= '|A:'..option.previewAtlas..':0:0|a'..expansion
            end
            local text= format(e.onlyChinese and '你目前处于|cffffffff时空漫游战役：%s|r' or PARTY_PLAYER_CHROMIE_TIME_SELF_LOCATION, expansion)
            e.tips:AddDoubleLine((e.onlyChinese and '选择时空漫游战役' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHROMIE_TIME_SELECT_EXAPANSION_BUTTON, CHROMIE_TIME_PREVIEW_CARD_DEFAULT_TITLE))..': '..e.GetEnabeleDisable(C_PlayerInfo.CanPlayerEnterChromieTime()),
                                    text
                                )
            e.tips:AddLine(' ')
            for _, info in pairs(C_ChromieTime.GetChromieTimeExpansionOptions() or {}) do
                local col= info.alreadyOn and '|cffff00ff' or ''-- option and option.id==info.id
                e.tips:AddDoubleLine((info.alreadyOn and e.Icon.toRight2 or '')..col..(info.previewAtlas and '|A:'..info.previewAtlas..':0:0|a' or '')..info.name..(info.alreadyOn and e.Icon.toLeft2 or '')..col..' ID '.. info.id, col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info.completed))
                --e.tips:AddDoubleLine(' ', col..(info.mapAtlas and '|A:'..info.mapAtlas..':0:0|a'.. info.mapAtlas))
                --e.tips:AddDoubleLine(' ', col..(info.previewAtlas and '|A:'..info.previewAtlas..':0:0|a'.. info.previewAtlas))
                --e.tips:AddDoubleLine(' ', col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info.completed))
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
            self2:SetAlpha(1)
        end)
    end
    if panel.ChromieTime then
        panel.ChromieTime:SetShown(canEnter and not Save.hide)
    end
end


















--###############
--显示，隐藏，按钮
--###############
panel.Init_Show_Hide_Button= function(self, frame)
    if not self or self.ShowHideButton then
        return
    end

    local title= self==PaperDollItemsFrame and CharacterFrame.TitleContainer or self.TitleContainer

    local btn= e.Cbtn(self, {size={20,20}, atlas= not Save.hide and e.Icon.icon or e.Icon.disabled})
    if frame then
        btn:SetPoint('RIGHT', frame, 'LEFT')
    else
        btn:SetPoint('LEFT', title)
    end
    btn:SetFrameLevel(title:GetFrameLevel()+1)

    btn:SetAlpha(0.5)
    btn:SetScript('OnClick', function()
        Save.hide= not Save.hide and true or nil
        if InspectFrame and InspectFrame.ShowHideButton then
            InspectFrame.ShowHideButton:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)
        end
        PaperDollItemsFrame.ShowHideButton:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)

        --print(id, addName, e.GetShowHide(not Save.hide), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要刷新' or (NEED..REFRESH)))

        Title()--头衔数量
        GetDurationTotale()--装备,总耐久度
        LvTo()--总装等
        set_PaperDollSidebarTab3_Text()--标签, 内容,提示
        Init_Server_equipmentButton_Lable()--显示服务器名称，装备管理框
        set_ChromieTime()--时空漫游战役, 提示
        Init_TrackButton()--添加装备管理框
        e.call('PaperDollFrame_SetLevel')
        e.call('PaperDollFrame_UpdateStats')

        if InspectFrame then
            if InspectFrame:IsShown() then
                e.call('InspectPaperDollFrame_UpdateButtons')--InspectPaperDollFrame.lua
                e.call('InspectPaperDollFrame_SetLevel')--目标,天赋 装等
                Init_Target_InspectUI()
            end
            if InspectLevelText then
                e.Cstr(nil, {changeFont= InspectLevelText, size= not Save.hide and 20 or 12})
            end
        end
    end)
    btn:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
    btn:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(not e.onlyChinese and SHOW..'/'..HIDE or '显示/隐藏', e.GetShowHide(not Save.hide))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        self2:SetAlpha(1)
    end)
    self.ShowHideButton= btn
end


















--#####
--初始化
--#####
local function Init()
    panel.Init_Show_Hide_Button(PaperDollItemsFrame, _G['MoveZoomInButtonPerCharacterFrame'])--初始，显示/隐藏，按钮
    Init_Server_equipmentButton_Lable()--显示服务器名称，装备管理框
    set_ChromieTime()--时空漫游战役, 提示

    GetDurationTotale()--装备,总耐久度

    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
        Title()--总装等
        set_PaperDollSidebarTab3_Text()
    end)

    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function()--装备管理
        set_PaperDollSidebarTab3_Text()
        LvTo()--总装等
    end)
    hooksecurefunc('GearSetButton_SetSpecInfo', function()--装备管理,修该专精
        set_PaperDollSidebarTab3_Text()
        LvTo()--总装等
    end)
    hooksecurefunc('GearSetButton_UpdateSpecInfo', function(self)--套装已装备数量
        local setID=self.setID
        local nu
        if setID and not Save.hide then
            if not self.nu then
                self.nu=e.Cstr(self)
                self.nu:SetJustifyH('RIGHT')
                self.nu:SetPoint('BOTTOMLEFT', self.text, 'BOTTOMLEFT')
            end
            local  numItems, numEquipped= select(5, C_EquipmentSet.GetEquipmentSetInfo(setID))
            if numItems and numEquipped then
                nu=numEquipped..'/'..numItems
            end
        end
        if self.nu then
            self.nu:SetText(nu or '')
        end
    end)


    --#######
    --装备属性
    --#######
    hooksecurefunc('PaperDollItemSlotButton_Update',  function(self)--PaperDollFrame.lua
        local slot= self:GetID()
        if not slot  then
            return
        end
        if PaperDoll_IsEquippedSlot(slot) then
            local textureName = GetInventoryItemTexture("player", slot)
            local hasItem = textureName ~= nil
            local link=hasItem and GetInventoryItemLink('player', slot) or nil--装等                
            if slot~=4 and slot~=19 then
                set_Item_Tips(self, slot, link, true)
                e.Set_Item_Stats(self, not Save.hide and link or nil, {point=self.icon})
                set_PaperDollSidebarTab3_Text()
                LvTo()--总装等
            end
            set_Slot_Num_Label(self, slot, link and true or nil)--栏位
        elseif InventSlot_To_ContainerSlot[slot] then
            local numFreeSlots
            local isbagEquipped= self:HasBagEquipped()
            if isbagEquipped then--背包数
                numFreeSlots= C_Container.GetContainerNumFreeSlots(InventSlot_To_ContainerSlot[slot])
                if numFreeSlots==0 then
                    numFreeSlots= '|cnRED_FONT_COLOR:'..numFreeSlots..'|r'
                end
                if not self.numFreeSlots then
                    self.numFreeSlots=e.Cstr(self, {color=true, justifyH='CENTER'})
                    self.numFreeSlots:SetPoint('BOTTOM',0 ,6)
                end
            end
            if self.numFreeSlots then
                self.numFreeSlots:SetText(numFreeSlots or '')
            end
            set_Slot_Num_Label(self, InventSlot_To_ContainerSlot[slot], isbagEquipped)--栏位
        end
    end)


    --#######
    --装备弹出
    --EquipmentFlyout.lua
   hooksecurefunc('EquipmentFlyout_Show', function(itemButton)
        for _, button in ipairs(EquipmentFlyoutFrame.buttons) do
            if button and button:IsShown() then
                local itemLink, slot
                if button.location and type(button.location)=='number' then--角色, 界面
                    local location = button.location;
                    slot= itemButton:GetID()
                    if location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
                        local player, bank, bags, voidStorage, slot2, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location);
                        if ( voidStorage and voidSlot ) then
                            itemLink = GetVoidItemHyperlinkString(voidSlot)
                        elseif ( not bags and slot2) then
                            itemLink =GetInventoryItemLink("player",slot2);
                        elseif bag and slot2 then
                            itemLink = C_Container.GetContainerItemLink(bag, slot2);
                        end
                    end
                else--其它
                    local location = button:GetItemLocation()
                    if location and type(location)=='table' then
                        itemLink= C_Item.GetItemLink(location)
                        slot=C_Item.GetItemInventoryType(location)
                    end
                end
                setFlyout(button, itemLink, slot)
            end
        end
    end)











    --############
    --更改,等级文本
    --############
    hooksecurefunc('PaperDollFrame_SetLevel', function()--PaperDollFrame.lua
        set_ChromieTime()--时空漫游战役, 提示
        if Save.hide then
            return
        end
        local race= e.GetUnitRaceInfo({unit='player', guid=nil , race=nil , sex=nil , reAtlas=true})
        local class= e.Class('player', nil, true)
        local level = UnitLevel("player");
        local effectiveLevel = UnitEffectiveLevel("player");

        if ( effectiveLevel ~= level ) then
            level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level);
        end
        local faction= e.Player.faction=='Alliance' and '|A:charcreatetest-logo-alliance:26:26|a' or e.Player.faction=='Horde' and '|A:charcreatetest-logo-horde:26:26|a' or ''
        CharacterLevelText:SetText('  '..faction..(race and '|A:'..race..':26:26|a' or '')..(class and '|A:'..class..':26:26|a  ' or '')..level)
        if not CharacterLevelText.set then
            e.Set_Label_Texture_Color(CharacterLevelText, {type='FontString'})
            --CharacterLevelText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
            CharacterLevelText:SetJustifyH('LEFT')
            CharacterLevelText:EnableMouse(true)
            CharacterLevelText:HookScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            CharacterLevelText:HookScript('OnEnter', function(self2)
                local info = C_PlayerInfo.GetPlayerCharacterData()
                if Save.hide or not info then
                    return
                end
                C_PlayerInfo.GetDisplayID()
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine('name', info.name)
                e.tips:AddDoubleLine('fileName', info.fileName)
                e.tips:AddDoubleLine('createScreenIconAtlas', (info.createScreenIconAtlas and '|A:'..info.createScreenIconAtlas..':0:0|a' or '')..(info.createScreenIconAtlas or ''))
                e.tips:AddDoubleLine('sex', info.sex)
                if info.alternateFormRaceData then
                    e.tips:AddLine(' ')
                    --e.tips:AddLine('alternateFormRaceData')
                    e.tips:AddDoubleLine('raceID', info.alternateFormRaceData.raceID)
                    e.tips:AddDoubleLine('name', info.alternateFormRaceData.name)
                    e.tips:AddDoubleLine('fileName', info.alternateFormRaceData.fileName)
                    e.tips:AddDoubleLine('createScreenIconAtlas', info.alternateFormRaceData.createScreenIconAtlas)
                    e.tips:AddLine(' ')
                end
                e.tips:AddDoubleLine('displayID', C_PlayerInfo.GetDisplayID())
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, addName)
                e.tips:Show()
                self2:SetAlpha(0.3)
            end)

            CharacterLevelText.set=true
        end
    end)

    --添加，空装，按钮
    --PaperDollFrame.lua
    hooksecurefunc('PaperDollEquipmentManagerPane_InitButton', function(btn)
        if Save.hide then
            if btn.createButton then
                btn.createButton:SetShown(false)
            end
            return
        end
        if not btn.setID and not btn.createButton  then
            btn.createButton= e.Cbtn(btn, {size={30,30}, atlas='groupfinder-eye-highlight'})
            btn.createButton.str= e.onlyChinese and '空' or EMPTY
            btn.createButton:SetPoint('RIGHT', 0,-4)
            btn.createButton:SetScript('OnLeave', GameTooltip_Hide)
            btn.createButton:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, addName)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(self.str,
                    C_EquipmentSet.GetEquipmentSetID(self.str)
                    and ('|cffff00ff'..(e.onlyChinese and '修改' or EQUIPMENT_SET_EDIT)..'|r')
                    or ('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '新建' or NEW)..'|r')
                )
                e.tips:Show()
            end)

            btn.createButton:SetScript('OnClick', function(self)
                local setID= C_EquipmentSet.GetEquipmentSetID(self.str)
                if setID then
                    C_EquipmentSet.DeleteEquipmentSet(setID)
                end
                for i=1, 18 do
                    C_EquipmentSet.IgnoreSlotForSave(i)
                end
                C_EquipmentSet.CreateEquipmentSet(self.str)
                if setID then
                    print(id,addName, '|cffff00ff'..(e.onlyChinese and '修改' or EQUIPMENT_SET_EDIT)..'|r', self.str)
                else
                    print(id,addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '新建' or NEW)..'|r', self.str)
                end
            end)
        end
        if btn.createButton then
            btn.createButton:SetShown(not btn.setID and true or false)
        end
        if not btn.setScripOK then
            btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
            btn:HookScript('OnClick', function(self, d)
                if UnitAffectingCombat('player') or not self.setID or Save.hide or d~='RightButton' then
                    return
                end
                C_EquipmentSet.UseEquipmentSet(self.setID)
                local name, iconFileID = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
                print(id, addName, iconFileID and '|T'..iconFileID..':0|t|cnGREEN_FONT_COLOR:' or '', name)
            end)
            btn.setScripOK=true
        end
    end)

    C_Timer.After(2, Init_TrackButton)--装备管理框
    --set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框
end
















--####################
--添加一个按钮, 打开选项
--####################
local function add_Button_OpenOption(frame)
    if not frame then
        return
    end
    local btn= e.Cbtn(frame, {atlas='charactercreate-icon-customize-body-selected', size={40,40}})
    btn:SetPoint('TOPRIGHT',-5,-25)
    btn:SetScript('OnClick', function()
        ToggleCharacter("PaperDollFrame")
    end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    if frame==ItemUpgradeFrameCloseButton then--装备升级, 界面
        --物品，货币提示
        e.ItemCurrencyLabel({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
        btn:SetScript("OnEvent", function()
            --物品，货币提示
            e.ItemCurrencyLabel({frame=ItemUpgradeFrame, point={'TOPLEFT', nil, 'TOPLEFT', 2, -55}})
        end)
        btn:SetScript('OnShow', function(self)
            self:RegisterEvent('BAG_UPDATE_DELAYED')
            self:RegisterEvent('CURRENCY_DISPLAY_UPDATE')
        end)
        btn:SetScript('OnHide', function(self)
            self:UnregisterAllEvents()
        end)
    end
end














--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            e.AddPanel_Header(nil, 'WoW')
            e.AddPanel_Check({
                name= (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName),
                tooltip= addName,
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            })

            --[[添加控制面板
            local sel=e.AddPanel_Check((e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)]]

            if not Save.disabled then
                Init()
                panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
            else
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级, 界面
            add_Button_OpenOption(ItemUpgradeFrameCloseButton)--添加一个按钮, 打开选项

        elseif arg1=='Blizzard_ItemInteractionUI' then--套装转换, 界面
            add_Button_OpenOption(ItemInteractionFrameCloseButton)--添加一个按钮, 打开选项

        elseif arg1=='Blizzard_InspectUI' then--目标, 装备
            Init_Target_InspectUI()
            hooksecurefunc('InspectPaperDollItemSlotButton_Update', set_InspectPaperDollItemSlotButton_Update)--目标, 装备
            hooksecurefunc('InspectPaperDollFrame_SetLevel', set_InspectPaperDollFrame_SetLevel)--目标,天赋 装等
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        GetDurationTotale()--装备,总耐久度
    end
end)
