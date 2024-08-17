local id, e = ...
local addName= CHARACTER
local Save={
    --EquipmentH=true, --装备管理, true横, false坚
    equipment= e.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1,--装备管理, 缩放
    --hide=true,--隐藏CreateTexture

    --notStatusPlus=true,--禁用，属性 PLUS
    StatusPlus_OnEnter_show_menu=true,--移过图标时，显示菜单

    --notStatusPlusFunc=true, --属性 PLUS Func
    itemLevelBit= 1,--物品等级，位数

}



local panel= CreateFrame("Frame", nil, PaperDollFrame)
local TrackButton
local StatusPlusButton
local Initializer

--[[local function Is_Load_ElvUI(btn)
    if C_AddOns.IsAddOnLoaded('ElvUI') and not btn.icon then
        btn.icon= btn:CreateTexture()
    end
end]]





local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr= ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"
local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local ITEM_CREATED_BY_Str= ITEM_CREATED_BY:gsub('%%s','(.+)')--"|cff00ff00<由%s制造>|r"

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
                e.tips:AddDoubleLine(id, Initializer:GetName())
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
                e.tips:AddDoubleLine(id, Initializer:GetName())
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
   -- print(recipeLearned(126392), recipeLearned(55016))
   --local tradeSkillID, skillLineName, parentTradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID);
   --print(C_TradeSkillUI.GetTradeSkillLineForRecipe(126392))
   --Professions.InspectRecipe(recipeID)
    if not ((slot==15 and recipeLearned(126392)) or (slot==6 and recipeLearned(55016))) or use or Save.hide or not link or not isPaperDollItemSlot then
    --if not (slot==15 or slot==6 ) or use or Save.hide or not link or not isPaperDollItemSlot then
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
        self.engineering:SetScript('OnMouseDown' ,function(frame,d)
            local parentTradeSkillID= select(3, C_TradeSkillUI.GetTradeSkillLineForRecipe(frame.spell)) or 202

            if d=='LeftButton' then
                local n=C_Item.GetItemCount(90146, true)
                if n==0 then
                    print(select(2, C_Item.GetItemInfo(90146)) or (e.onlyChinese and '附加材料' or OPTIONAL_REAGENT_TUTORIAL_TOOLTIP_TITLE), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
                    return
                end
                --OpenProfessionUIToSkillLine(202)
                OpenProfessionUIToSkillLine(parentTradeSkillID)
                --C_TradeSkillUI.OpenTradeSkill(202)
                C_TradeSkillUI.CraftRecipe(frame.spell)
                C_TradeSkillUI.CloseTradeSkill()
                ToggleCharacter("PaperDollFrame", true)
            elseif d=='RightButton' then
                OpenProfessionUIToSkillLine(parentTradeSkillID)
                --C_TradeSkillUI.OpenTradeSkill(202)
            end
        end)
        self.engineering:SetScript('OnEnter' ,function(frame)
                e.tips:SetOwner(frame, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:SetSpellByID(frame.spell)
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '商业技能' or TRADESKILLS), e.Icon.right)
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需求' or NEED), (e.onlyChinese and '打开一次' or CHALLENGES_LASTRUN_TIME)..'('..(e.onlyChinese and '打开' or UNWRAP)..')')
                e.tips:Show()
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
                local classID, subClassID= select(6, C_Item.GetItemInfoInstant(info.itemID))
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
    if Save.hide then
        link= nil
    end
    local enchant, use, pvpItem, upgradeItem, createItem
    local unit = (not isPaperDollItemSlot and InspectFrame) and InspectFrame.unit or 'player'
    local isLeftSlot= is_Left_Slot(slot)

    if link and not C_Item.IsCorruptedItem(link) then
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

    use=  link and select(2, C_Item.GetItemSpell(link))--物品是否可使用
    if use and not self.use  then
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
        local hex = quality and select(4, C_Item.GetItemQualityColor(quality))
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



if not e.Is_Timerunning then
    if not Save.hide and link then--宝石
        local numSockets= C_Item.GetItemNumSockets(link) or 0--MAX_NUM_SOCKETS
        for n=1, numSockets do
            local gemLink= select(2, C_Item.GetItemGem(link, n))
            e.LoadDate({id=gemLink, type='item'})

            local gem= self['gem'..n]
            if not gem then
                gem=self:CreateTexture()
                gem.index= n
                gem:SetSize(12.3, 12.3)--local h=self:GetHeight()/3 37 12.3
                gem:EnableMouse(true)
                gem:SetScript('OnLeave',function(frame) e.tips:Hide() frame:SetAlpha(1) end)
                gem:SetScript('OnEnter' ,function(frame)
                    if frame.gemLink then
                        e.tips:SetOwner(frame, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:SetHyperlink(frame.gemLink)
                        e.tips:Show()
                        frame:SetAlpha(0.3)
                    end
                end)

                if isLeftSlot then--左边插曹
                    if n==1 then
                        gem:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 8, 0)
                    else
                        gem:SetPoint('LEFT',  self['gem'..n-1], 'RIGHT')
                    end
                else
                    if n==1 then
                        gem:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', -8, 0)
                    else
                        gem:SetPoint('RIGHT',  self['gem'..n-1], 'LEFT')
                    end
                end
                self['gem'..n]= gem
            end
            gem.gemLink= gemLink
            local icon
            if gemLink then
                icon = C_Item.GetItemIconByID(gemLink) or select(5, C_Item.GetItemInfoInstant(gemLink))
            end
            if icon then
                gem:SetTexture(icon)
            else
                gem:SetAtlas(gemLink and 'Islands-QuestDisable' or 'FlightPath')--'socket-hydraulic-background')
            end
            gem:SetShown(true)
            --local x= isLeftSlot and 8 or -8--左边插曹
            --x= isLeftSlot and x+ 12.3 or x- 12.3--左边插曹
        end
        for n=numSockets+1, MAX_NUM_SOCKETS do
            local gem= self['gem'..n]
            if gem then
                gem:SetShown(false)
            end
        end
    else
        for n=1, MAX_NUM_SOCKETS do
            local gem= self['gem'..n]
            if gem then
                gem:SetShown(false)
            end
        end
    end

elseif not Save.hide and self.SocketDisplay:IsShown() and link then
    for index, frame in pairs(self.SocketDisplay.Slots) do
        if frame and frame:IsShown() then
            local gemID = C_Item.GetItemGemID(link, index)
            frame.gemID= gemID
            if not frame:IsMouseEnabled() then
                frame:EnableMouse(true)
                frame:SetScript('OnLeave', function(f) e.tips:Hide() f:SetScale(1) end)
                frame:SetScript('OnEnter', function(f)
                    if f.gemID then
                        e.tips:SetOwner(f, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:SetItemByID(f.gemID)
                        e.tips:Show()
                    end
                    f:SetScale(1.3)
                end)
                self.SocketDisplay:ClearAllPoints()
                if isLeftSlot then
                    self.SocketDisplay:SetPoint('LEFT', self, 'RIGHT', 8, 0)
                else
                    self.SocketDisplay:SetPoint('RIGHT', self, 'LEFT', -8, 0)
                end
                --[[if isLeftSlot then
                    self.SocketDisplay:SetPoint('RIGHT', self, 'LEFT')
                else
                    self.SocketDisplay:SetPoint('LEFT', self, 'RIGHT')
                end]]
                frame:SetSize(14, 14)
                frame:SetFrameStrata('HIGH')
                frame.Slot:ClearAllPoints()
                frame.Slot:SetPoint('CENTER')
                frame.Slot:SetSize(13, 13)
            end
            local atlas
            if gemID then
                local quality= C_Item.GetItemQualityByID(gemID)--C_Item.GetItemQualityColor(quality)
                atlas= e.Icon[quality]
            end
            frame.Slot:SetAtlas(atlas or 'character-emptysocket')
        end
    end

end


    local du, min, max
    if link then
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

local function set_Slot_Num_Label(frame, slot, isEquipped)--栏位
    if not frame.slotText and not Save.hide and not isEquipped then
        frame.slotText=e.Cstr(frame, {color=true, justifyH='CENTER', mouse=true})
        frame.slotText:EnableMouse(true)
        frame.slotText:SetAlpha(0.3)
        frame.slotText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, self.slot)
            local name= self:GetParent():GetName()
            if name then
                e.tips:AddDoubleLine(_G[strupper(strsub(name, 10))], name)
            end
            e.tips:Show()
            self:SetAlpha(1)
        end)
        frame.slotText:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(0.3) end)
        frame.slotText:SetPoint('CENTER')
    end
    if frame.slotText then
        frame.slotText.slot= slot
        frame.slotText.name= frame:GetName()
        frame.slotText:SetText(slot)
        frame.slotText:SetShown(not Save.hide and not isEquipped)
    end
end

local function set_item_Set(self, link)--套装
    local set
    if link and not Save.hide then
        set=select(16 , C_Item.GetItemInfo(link))
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




























local function Init_Title()--头衔数量
    local btn= PaperDollFrame.TitleManagerPane.tipsButton
    if not PAPERDOLL_SIDEBARS[2].IsActive() or Save.hide then
        if btn then
            btn.titleNumeri:SetText("")
            btn:SetShown(false)
        end
        return
    end

    if not btn then
        btn= e.Cbtn(PaperDollFrame.TitleManagerPane, {size={28, 28}, icon='hide'})--, atlas=e.Icon.icon})
        btn.Text= e.Cstr(btn)
        btn.Text:SetPoint('CENTER')
        btn:SetFrameLevel(PaperDollFrame.TitleManagerPane.ScrollBox:GetFrameLevel()+1)
        btn:SetPoint('TOPRIGHT', -6,8)
        function btn:get_tab()
            local tab={}
            for i = 1, GetNumTitles() do
                if not IsTitleKnown(i) then
                    local name, playerTitle = GetTitleName(i)
                    if name and playerTitle then
                        if not IsTitleKnown(i) then
                            table.insert(tab, {index=i, name=name, cnName=e.cn(name, {titleID=i})})
                        end
                    end
                end
            end
            return tab
        end
        btn:SetScript('OnMouseDown', function(self)
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")--菜单框架
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(frame, level, menuList)--主菜单
                    local info
                    local tab= frame:GetParent():get_tab()
                    local n=30
                    if menuList then
                        for i= menuList, menuList+n-1 do
                            if tab[i] then
                                local index= tab[i].index
                                
                                local name= tab[i].name
                                local cnName=tab[i].cnName
                                info= {
                                    text= (index<10 and ' ' or '').. index..')'..(cnName and format(cnName, '') or name),
                                    tooltipOnButton=true,
                                    tooltipTitle= name..' ',
                                    tooltipText= (cnName and format(cnName, UnitName('player')..'|n') or '')..'titleID '..index..'|n'..e.Icon.left..'wowhead',
                                    notCheckable=true,
                                    arg1=i,
                                    func= function(_, arg1)
                                        e.Show_WoWHead_URL(true, 'title', arg1, nil)
                                    end
                                }
                                e.LibDD:UIDropDownMenu_AddButton(info, level)
                            else
                                break
                            end
                        end
                        return
                    end

                    for i=1, #tab, n do
                        info= {
                            text= i,
                            notCheckable=true,
                            menuList=i,
                            hasArrow=true
                        }
                        e.LibDD:UIDropDownMenu_AddButton(info, level)
                    end
                    e.LibDD:UIDropDownMenu_AddSeparator(level)

                    info= {
                        text= #tab==0 and (e.onlyChinese and '全部已收集' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC,  ALL, COLLECTED))
                            or (#tab.. ' '..(e.onlyChinese and '未收集' or  NOT_COLLECTED)),
                        isTitle=true,
                        notCheckable=true,
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                    info= {
                        text= id..' '..Initializer:GetName(),
                        isTitle=true,
                        notCheckable=true,
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end)
        PaperDollFrame.TitleManagerPane.tipsButton= btn
    end
    btn.Text:SetText(#btn:get_tab())
    btn:SetShown(true)

    if not btn.titleNumeri then
        btn.titleNumeri= e.Cstr(PaperDollSidebarTab2, {justifyH='CENTER', mouse=true})
        btn.titleNumeri:SetPoint('BOTTOM')
        btn.titleNumeri:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        btn.titleNumeri:SetScript('OnMouseDown', function()
            e.call('PaperDollFrame_SetSidebar', _G['PaperDollSidebarTab2'], 2)--PaperDollFrame.lua
        end)
        btn.titleNumeri:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(format(e.onlyChinese and '头衔：%s' or RENOWN_REWARD_TITLE_NAME_FORMAT,  '|cnGREEN_FONT_COLOR:'..(#GetKnownTitles()-1)..'|r'), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '未收集' or  NOT_COLLECTED))
            e.tips:AddDoubleLine(#PaperDollFrame.TitleManagerPane.tipsButton:get_tab(), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or  NOT_COLLECTED))
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
            self:SetAlpha(0.3)
        end)
    end
    btn.titleNumeri:SetText(#GetKnownTitles()-1)


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
        e.tips:AddDoubleLine(id, Initializer:GetName())
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
            print(id, Initializer:GetName(), e.onlyChinese and '缩放' or UI_SCALE, GREEN_FONT_COLOR_CODE..n)
        end
    end)
    TrackButton:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()

        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, 'Alt+'..e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' '..(Save.equipmentFrameScale or 1),'Alt+'..e.Icon.mid)
        e.tips:AddDoubleLine(not Save.EquipmentH and format('|A:%s:0:0|a', e.Icon.toRight)..(e.onlyChinese and '向右' or BINDING_NAME_STRAFERIGHT) or ('|A:UI-HUD-MicroMenu-StreamDLRed-Up:0:0|a'..(e.onlyChinese and '向下' or BINDING_NAME_PITCHDOWN)),
                'Ctrl+'..e.Icon.right)

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, e.onlyChinese and '装备管理'or EQUIPMENT_MANAGER)
        e.tips:Show()
        if panel.equipmentButton and panel.equipmentButton:IsVisible() then
            panel.equipmentButton:SetButtonState('PUSHED')
            panel.equipmentButton:SetAlpha(1)
        end
    end)
    TrackButton:SetScript("OnLeave", function()
        ResetCursor()
        e.tips:Hide()
        if panel.equipmentButton then
            panel.equipmentButton:SetButtonState('NORMAL')
            panel.equipmentButton:SetAlpha(0.5)
        end
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
        btn.text= e.Cstr(btn, {color=true, size=10, alpha=0.5})
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
                print(id, Initializer:GetName(), RED_FONT_COLOR_CODE, e.onlyChinese and '你无法在战斗中实施那个动作' or ERR_NOT_IN_COMBAT)
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
                e.tips:AddDoubleLine(id, Initializer:GetName())
                e.tips:Show()
                --local name, iconFileID, _, isEquipped2, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
                if panel.equipmentButton and panel.equipmentButton:IsVisible() then
                    panel.equipmentButton:SetButtonState('PUSHED')
                    panel.equipmentButton:SetAlpha(1)
                end
            end
            frame:SetAlpha(1)
        end)

        btn:SetScript("OnLeave",function(frame)
            e.tips:Hide()
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
            if numItems==0 then
                btn.text:SetText('')
            else
                btn.text:SetText(numLost>0 and '|cnRED_FONT_COLOR:'..numLost or numItems)
            end
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
    hooksecurefunc('PaperDollEquipmentManagerPane_Update',  function()
        TrackButton:init_buttons()
    end)

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






--装备管理, 总开关
function Init_TrackButton_ShowHide_Button()
    if Save.hide or not PAPERDOLL_SIDEBARS[3].IsActive() then
        if panel.equipmentButton then
            panel.equipmentButton:SetShown(false)
        end
        return
    elseif panel.equipmentButton then
        panel.equipmentButton:SetShown(true)
        return
    end
    panel.equipmentButton = e.Cbtn(PaperDollFrame.EquipmentManagerPane, {size={20,20}, atlas= Save.equipment and 'auctionhouse-icon-favorite' or e.Icon.disabled})--显示/隐藏装备管理框选项
    panel.equipmentButton:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT')
    panel.equipmentButton:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    panel.equipmentButton:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    panel.equipmentButton:SetAlpha(0.3)
    panel.equipmentButton:SetScript("OnClick", function(self, d)
        if d=='LeftButton' and not IsModifierKeyDown() then
            Save.equipment= not Save.equipment and true or nil
            self:SetNormalAtlas(Save.equipment and 'auctionhouse-icon-favorite' or e.Icon.disabled)
            Init_TrackButton()--添加装备管理框
            print(id, Initializer:GetName(), e.GetShowHide(Save.equipment))
        elseif d=='RightButton' and IsControlKeyDown() then
            Save.Equipment=nil
            if TrackButton then
                TrackButton:ClearAllPoints()
                TrackButton:set_point()
            end
            print(id, Initializer:GetName(), e.onlyChinese and '重置位置' or RESET_POSITION)
        end
    end)
    panel.equipmentButton:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER, e.Icon.left..e.GetShowHide(Save.equipment))
        local col= not (self.btn and Save.Equipment) and '|cff9e9e9e' or ''
        e.tips:AddDoubleLine(col..(e.onlyChinese and '重置位置' or RESET_POSITION), col..'Ctrl+'..e.Icon.right)
        e.tips:Show()
        self:SetAlpha(1)
        if TrackButton then
            TrackButton:SetButtonState('PUSHED')
        end
    end)
    panel.equipmentButton:SetScript("OnLeave",function(self)
        GameTooltip_Hide()
        if TrackButton then
            TrackButton:SetButtonState("NORMAL")
        end
        self:SetAlpha(0.3)
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
        return
    end
    if not panel.durabilityText then
        panel.durabilityText= e.Cstr(PaperDollItemsFrame, {copyFont=CharacterLevelText, mouse=true})
        panel.durabilityText:SetPoint('RIGHT', CharacterLevelText, 'LEFT', -2,0)
        panel.durabilityText:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
        panel.durabilityText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:AddLine(' ')
            e.GetDurabiliy_OnEnter()
            e.tips:Show()
            self:SetAlpha(0.3)
        end)
    end
    panel.durabilityText:SetText(e.GetDurabiliy(true))
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
        dateInfo= e.GetTooltipData({hyperLink=itemLink, itemID=itemLink and C_Item.GetItemInfoInstant(itemLink) , text={upgradeStr, pvpItemStr, itemLevelStr}, onlyText=true})--物品提示，信息

        if dateInfo and dateInfo.text[itemLevelStr] then
            level= tonumber(dateInfo.text[itemLevelStr])
        end
        level= level or itemLink and C_Item.GetDetailedItemLevelInfo(itemLink)
        text= level
        if text then
            local itemQuality = C_Item.GetItemQualityByID(itemLink)
            if itemQuality then
                local hex = select(4, C_Item.GetItemQualityColor(itemQuality))
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
                local itemEquipLoc= itemLink and select(4, C_Item.GetItemInfoInstant(itemLink))
                slot= e.GetItemSlotID(itemEquipLoc)
            end
            if slot then
                local itemLink2 = GetInventoryItemLink('player', slot)
                if itemLink2 then
                    updown = C_Item.GetDetailedItemLevelInfo(itemLink2)
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
                        updown= '|A:bags-greenarrow:0:0|a'
                    end
                else
                    updown= '|A:bags-greenarrow:0:0|a'
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

    if not button.isEquippedTexture then--提示，已装备
        button.isEquippedTexture= button:CreateTexture(nil, 'OVERLAY')
        button.isEquippedTexture:SetPoint('CENTER')
        local w,h= button:GetSize()
        button.isEquippedTexture:SetSize(w+12, h+12)
        button.isEquippedTexture:SetAtlas('Forge-ColorSwatchHighlight')--'Forge-ColorSwatchSelection')
        --button.isEquippedTexture:SetVertexColor(0,1,0)

        button:HookScript('OnEnter', function(self)--查询
            if self.itemLink then
                e.FindBagItem(true, {itemLink=self.itemLink})
            end
        end)
        button:HookScript('OnLeave', function()
           e.FindBagItem(false)
        end)
    end
    local show=false
    if not Save.hide and button.itemLink then
        show= C_Item.IsEquippedItem(button.itemLink)
       --[[ local itemLocation = button:GetItemLocation();
        if itemLocation then
            if itemLocation:IsEquipmentSlot() and itemLocation:GetEquipmentSlot() then
                show=true
            end
        elseif type(button.location)=='number' then
            local player, bank, bags, voidStorage, slot= EquipmentManager_UnpackLocation(button.location)--EquipmentManager.lua
            if slot and player and not voidStorage and not bags and not bank then
                show=GetInventoryItemLink('player', slot)==button.itemLink
            end
        end]]
    end
    button.isEquippedTexture:SetShown(show)
end



local function set_equipment_flyout_buttons(itemButton)
    for _, button in ipairs(EquipmentFlyoutFrame.buttons) do
        if button and button:IsShown()  then
            local itemLink, slot
            if button.location and type(button.location)=='number' then--角色, 界面
                local location = button.location
                slot= itemButton:GetID()
                if location < EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
                    local player, bank, bags, voidStorage, slot2, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location)
                    if ( voidStorage and voidSlot ) then
                        itemLink = GetVoidItemHyperlinkString(voidSlot)
                    elseif ( not bags and slot2) then
                        itemLink =GetInventoryItemLink("player",slot2)
                    elseif bag and slot2 then
                        itemLink = C_Container.GetContainerItemLink(bag, slot2)
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
            button.itemLink= itemLink
        end
    end
end





















--###############
--显示，隐藏，按钮
--###############
local function Init_Show_Hide_Button(frame)
    if not frame or frame.ShowHideButton then
        return
    end

    local title= frame==PaperDollItemsFrame and CharacterFrame.TitleContainer or frame.TitleContainer

    local btn= e.Cbtn(frame, {size={20,20}, atlas= not Save.hide and e.Icon.icon or e.Icon.disabled})
    btn:SetFrameStrata(title:GetFrameStrata())
    btn:SetPoint('LEFT', title)
    btn:SetFrameLevel(title:GetFrameLevel()+1)

    btn:SetScript('OnClick', function(_, d)
        if d=='RightButton' then
            if not Initializer then
                e.OpenPanelOpting()    
            end
            e.OpenPanelOpting(Initializer)
            return
        end
        Save.hide= not Save.hide and true or nil

        GetDurationTotale()--装备,总耐久度
        panel:Init_Server_equipmentButton_Lable()--显示服务器名称

        Init_Title()--头衔数量
        LvTo()--总装等
        set_PaperDollSidebarTab3_Text()--标签, 内容,提示
        --Init_ChromieTime()--时空漫游战役, 提示

        Init_TrackButton_ShowHide_Button()--装备管理, 总开关
        Init_TrackButton()--添加装备管理框

        panel:Init_Status_Plus()

        e.call('PaperDollFrame_SetLevel')
        e.call('PaperDollFrame_UpdateStats')

        local Slot = {
            [1]	 = "CharacterHeadSlot",
            [2]	 = "CharacterNeckSlot",
            [3]	 = "CharacterShoulderSlot",
            [4]	 = "CharacterShirtSlot",
            [5]	 = "CharacterChestSlot",
            [6]	 = "CharacterWaistSlot",
            [7]	 = "CharacterLegsSlot",
            [8]	 = "CharacterFeetSlot",
            [9]	 = "CharacterWristSlot",
            [10] = "CharacterHandsSlot",
            [11] = "CharacterFinger0Slot",
            [12] = "CharacterFinger1Slot",
            [13] = "CharacterTrinket0Slot",
            [14] = "CharacterTrinket1Slot",
            [15] = "CharacterBackSlot",
            [16] = "CharacterMainHandSlot",
            [17] = "CharacterSecondaryHandSlot",
        }
        for _, slot in pairs(Slot) do
            local btn2= _G[slot]
            if btn2 then
                e.call('PaperDollItemSlotButton_Update', btn2)
            end
        end

        if InspectFrame then
            if InspectFrame:IsShown() then
                e.call('InspectPaperDollFrame_UpdateButtons')--InspectPaperDollFrame.lua
                e.call('InspectPaperDollFrame_SetLevel')--目标,天赋 装等
                panel:Init_Target_InspectUI()
            end
            if InspectLevelText then
                e.Cstr(nil, {changeFont= InspectLevelText, size= not Save.hide and 18 or 12})
            end
            if InspectFrame.ShowHideButton then
                InspectFrame.ShowHideButton:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)
            end
            if InspectFrame.statusLabel then--目标，属性
                InspectFrame.statusLabel:settings()
            end
        end
        PaperDollItemsFrame.ShowHideButton:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)

    end)
    function btn:set_alpha(isEnter)
        if isEnter then
            self:SetAlpha(1)
        else
            self:SetAlpha(0.5)
        end
    end
    btn:set_alpha(false)
    
    btn:SetScript('OnLeave', function(self) GameTooltip_Hide() self:set_alpha(false) end)
    btn:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save.hide), e.Icon.left)

        e.tips:AddDoubleLine(e.onlyChinese and '选项' or SETTINGS_TITLE, e.Icon.right)


        e.tips:Show()
        self:set_alpha(true)
    end)
    frame.ShowHideButton= btn
end
















--#########
--目标, 装备
--#########
function panel:Init_Target_InspectUI()
    local frame= InspectPaperDollFrame
    Init_Show_Hide_Button(InspectFrame)

    if not frame.initButton and not Save.hide then
        if frame.ViewButton then
            e.Cstr(nil, {changeFont= InspectLevelText, size=18})
            frame.ViewButton:ClearAllPoints()
            frame.ViewButton:SetPoint('LEFT', InspectLevelText, 'RIGHT',20,0)
            frame.ViewButton:SetSize(25,25)
            frame.ViewButton:SetText(e.onlyChinese and '试' or e.WA_Utf8Sub(VIEW,1))
        end
        if InspectPaperDollItemsFrame.InspectTalents then
            InspectPaperDollItemsFrame.InspectTalents:SetSize(25,25)
            InspectPaperDollItemsFrame.InspectTalents:SetText(e.onlyChinese and '赋' or e.WA_Utf8Sub(TALENT,1))
        end
        frame.initButton=true
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
        if link then
            local itemID= GetInventoryItemID(InspectFrame.unit, slot)
            local cnName= e.cn(nil, {itemID=itemID, isName=true})
            if cnName then
                cnName= cnName:match('|cff......(.+)|r') or cnName
                local atlas= link:match('%[(.-) |A') or link:match('%[(.-)]')
                if atlas then
                    link= link:gsub(atlas, cnName)
                end
            end
        end
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





--目标，属性
local function Set_Target_Status(frame)--InspectFrame
    if frame.statusLabel then
        frame.statusLabel:settings()
        return
    end
    frame.statusLabel= e.Cstr(InspectPaperDollFrame)
    frame.statusLabel:SetPoint('TOPLEFT', InspectFrameTab1, 'BOTTOMLEFT',0,-2)
    function frame.statusLabel:settings()
        local unit=InspectFrame.unit
        local text
        if not Save.hide and UnitExists(unit) then
            local tab={ 1,2,3,15,5,9, 10,6,7,8,11,12,13,14, 16,17}
            local sta, newSta={}, {}
            for _, slotID in pairs(tab) do
                local itemLink= GetInventoryItemLink(unit, slotID)
                for a,b in pairs(itemLink and C_Item.GetItemStats(itemLink) or {}) do
                    sta[a]= (sta[a] or 0) +b
                end
            end
            for a, b in pairs(sta) do
                table.insert(newSta, {text=e.cn(_G[a] or a), value=b})
            end
            table.sort(newSta, function(a,b) return a.value> b.value end)
            for index, info in pairs(newSta) do
                text= text and text..'|n' or ''
                local col= select(2, math.modf(index/2))==0 and '|cffffffff' or '|cffff7f00'
                text= text..col..info.text..': '..e.MK(info.value, 3)..'|r'
            end
        end
        self:SetText(text or '')
    end
    frame.statusLabel:settings()
end



















--#############
--显示服务器名称
--#############
function panel:Init_Server_equipmentButton_Lable()
    if Save.hide then
        if  panel.serverText then
            panel.serverText:SetText('')
        end
        return
    end
   if not panel.serverText then
        panel.serverText= e.Cstr(PaperDollItemsFrame.ShowHideButton, {color= GameLimitedMode_IsActive() and {r=0,g=1,b=0} or true, mouse=true, justifyH='RIGHT'})--显示服务器名称
        panel.serverText:SetPoint('LEFT', PaperDollItemsFrame.ShowHideButton, 'RIGHT',2,0)
        panel.serverText:SetScript("OnLeave",function(frame) e.tips:Hide() frame:GetParent():set_alpha(false) end)
        panel.serverText:SetScript("OnEnter",function(frame)
            e.tips:SetOwner(frame, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local server= e.Get_Region(e.Player.realm, nil, nil)--服务器，EU， US {col=, text=, realm=}
            e.tips:AddDoubleLine(e.onlyChinese and '服务器:' or FRIENDS_LIST_REALM, server and server.col..' '..server.realm)
            local ok2
            for k, v in pairs(GetAutoCompleteRealms()) do
                if v==e.Player.realm then
                    e.tips:AddDoubleLine(v..'|A:auctionhouse-icon-favorite:0:0|a', k, 0,1,0)
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
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
            frame:GetParent():set_alpha(true)
        end)
    end
    local ser=GetAutoCompleteRealms() or {}
    local server= e.Get_Region(e.Player.realm, nil, nil)
    local text= (#ser>1 and '|cnGREEN_FONT_COLOR:'..#ser..' ' or '')..e.Player.col..e.Player.realm..'|r'..(server and ' '..server.col or '')
    panel.serverText:SetText(text or '')
end

















--################
--时空漫游战役, 提示
--[[################
local function Init_ChromieTime()--时空漫游战役, 提示
    local canEnter = C_PlayerInfo.CanPlayerEnterChromieTime()
    if canEnter and not Save.hide and not panel.ChromieTime then
        panel.ChromieTime= e.Cbtn(PaperDollItemsFrame, {size={18,18}, atlas='ChromieTime-32x32'})
        panel.ChromieTime:SetAlpha(0.5)
        if PaperDollItemsFrame.ShowHideButton then
            panel.ChromieTime:SetPoint('LEFT', PaperDollItemsFrame.ShowHideButton, 'RIGHT')
            panel.ChromieTime:SetFrameLevel(CharacterFrame.TitleContainer:GetFrameLevel()+1)
        else
            panel.ChromieTime:SetPoint('BOTTOMLEFT', PaperDollItemsFrame, 5, 10)
        end
        panel.ChromieTime:SetScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(0.5) end)
        panel.ChromieTime:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            local expansionID = UnitChromieTimeID('player')--时空漫游战役 PartyUtil.lua
            local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID)
            local expansion = option and e.cn(option.name) or (e.onlyChinese and '无' or NONE)
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
                e.tips:AddDoubleLine((info.alreadyOn and format('|A:%s:0:0|a', e.Icon.toRight) or '')..col..(info.previewAtlas and '|A:'..info.previewAtlas..':0:0|a' or '')..info.name..(info.alreadyOn and format('|A:%s:0:0|a', e.Icon.toLeft) or '')..col..' ID '.. info.id, col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info.completed))
                --e.tips:AddDoubleLine(' ', col..(info.mapAtlas and '|A:'..info.mapAtlas..':0:0|a'.. info.mapAtlas))
                --e.tips:AddDoubleLine(' ', col..(info.previewAtlas and '|A:'..info.previewAtlas..':0:0|a'.. info.previewAtlas))
                --e.tips:AddDoubleLine(' ', col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info.completed))
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, Initializer:GetName())
            e.tips:Show()
            self2:SetAlpha(1)
        end)
    end
    if panel.ChromieTime then
        panel.ChromieTime:SetShown(canEnter and not Save.hide)
    end
end]]











































--属性 PLUS Func
local function Init_Status_Func()
    --功击速度，放在前前，原生出错
    function PaperDollFrame_SetAttackSpeed(statFrame, unit)
        local meleeHaste = GetMeleeHaste()
        local speed, offhandSpeed = UnitAttackSpeed(unit)
        local displaySpeed
        speed= speed or 0
        if offhandSpeed  then
            displaySpeed = format("%.2f/%.2f", speed, offhandSpeed)
        else
            displaySpeed = format("%.2f", speed)
        end
        PaperDollFrame_SetLabelAndText(statFrame, e.onlyChinese and '攻击速度' or WEAPON_SPEED, displaySpeed, false, speed)
        statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, e.onlyChinese and '攻击速度' or ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE
        statFrame.tooltip2 = format(e.onlyChinese and '攻击速度+%s%%' or STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHaste))
        statFrame:Show()
        if statFrame.numLabel then
            statFrame.numLabel:SetText('')
        end
    end

    if Save.notStatusPlusFunc then
        return
    end




    hooksecurefunc('PaperDollFrame_SetItemLevel', function(statFrame)--物品等级，小数点
        if statFrame:IsShown() and not Save.hide and Save.itemLevelBit>0 then
            local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel()
	        local minItemLevel = C_PaperDollInfo.GetMinItemLevel()
	        local displayItemLevel = math.max(minItemLevel or 0, avgItemLevelEquipped)
            local pvp=''
            if ( avgItemLevel ~= avgItemLevelPvP ) then
                pvp= format('/|cffff7f00%i|r', avgItemLevelPvP)
            end
            if statFrame.numericValue ~= displayItemLevel then
                statFrame.Value:SetFormattedText('%.0'..Save.itemLevelBit..'f%s', displayItemLevel, pvp)
            end
        end
    end)
    CharacterStatsPane.ItemLevelFrame.Value:EnableMouse(true)
    function CharacterStatsPane.ItemLevelFrame.Value:set_tooltips()
        if Save.hide then
            return
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(format('|A:communities-icon-addchannelplus:0:0|a%s Plus', e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '小数点 ' or 'bit ')..(Save.itemLevelBit==0 and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE)..'|r' or ('|cnGREEN_FONT_COLOR:'..Save.itemLevelBit)), '-1'..e.Icon.left)
        e.tips:AddDoubleLine('0 '..(e.onlyChinese and '禁用' or DISABLE), '+1'..e.Icon.right)
        e.tips:Show()
    end
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnLeave', function(self)
        self:SetAlpha(1)
        GameTooltip_Hide()
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnEnter', function(self)
        self:set_tooltips()
        self:SetAlpha(0.7)
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnMouseUp', function(self)
        self:SetAlpha(0.7)
    end)
    CharacterStatsPane.ItemLevelFrame.Value:SetScript('OnMouseDown', function(self, d)
        local n= Save.itemLevelBit or 3
        n= d=='LeftButton' and n-1 or n
        n= d=='RightButton' and n+1 or n
        n= n>4 and 4 or n
        n= n<0 and 0 or n
        Save.itemLevelBit=n
        e.call('PaperDollFrame_UpdateStats')
        self:set_tooltips()
        self:SetAlpha(0.3)
    end)





    --自定，数据
    function StatusPlusButton:status_set_rating(frame, rating)
        local num= GetCombatRating(rating)
        if num == 0 then
            frame.numLabel:SetText('')
        else
            local extraChance = GetCombatRatingBonus(rating) or 0
            local extra=''
            if extraChance>0 then
                extra= format('|cnGREEN_FONT_COLOR:+%i%%|r', extraChance)
            elseif extraChance<0 then
                extra= format('|cnRED_FONT_COLOR:%i%%|r', extraChance)
            end
            frame.numLabel:SetFormattedText('%s%s', BreakUpLargeNumbers(num), extra)
        end
    end
    function StatusPlusButton:create_status_label(frame, rating)
        if not Save.hide and Save.itemLevelBit>0 and frame:IsShown() then
            if not frame.numLabel then
                frame.numLabel=e.Cstr(frame, {color={r=1,g=1,b=1}})
                frame.numLabel:SetPoint('LEFT', frame.Label, 'RIGHT',2,0)
            end
            if rating then
                self:status_set_rating(frame, rating)
            end
            return true
        elseif frame.numLabel then
            frame.numLabel:SetText("")
        end
    end

-- General
    hooksecurefunc('PaperDollFrame_SetHealth', function(frame)--生命
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetAlternateMana', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    function MovementSpeed_OnUpdate(statFrame)--原生，替换，增强 PaperDollFrame_SetMovementSpeed
        local unit = statFrame.unit
        local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit)
        local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
        if isGliding and forwardSpeed then
            flightSpeed= forwardSpeed/BASE_MOVEMENT_SPEED*100
        else
            flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100
        end
        runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100
        swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100
        if (unit == "pet") then
            swimSpeed = runSpeed
        end
        local speed = runSpeed
        local swimming = IsSwimming(unit)
        if (swimming) then
            speed = swimSpeed
        elseif (IsFlying(unit)) then
            speed = flightSpeed
        end
        if (IsFalling(unit)) then
            if (statFrame.wasSwimming) then
                speed = swimSpeed
            end
        else
            statFrame.wasSwimming = swimming
        end
        local valueText = format("%i%%", speed)
        PaperDollFrame_SetLabelAndText(statFrame, e.onlyChinese and '移动' or (NPE_MOVE), valueText, false, speed)
        statFrame.speed = speed
        statFrame.runSpeed = runSpeed
        statFrame.flightSpeed = flightSpeed
        statFrame.swimSpeed = swimSpeed
        StatusPlusButton:create_status_label(statFrame, CR_SPEED)
    end
    function MovementSpeed_OnEnter(statFrame)
        GameTooltip:SetOwner(statFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, e.onlyChinese and '移动速度' or STAT_MOVEMENT_SPEED).." "..format("%d%%", statFrame.speed+0.5)..FONT_COLOR_CODE_CLOSE)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(e.onlyChinese and '奔跑速度：%d%%' or STAT_MOVEMENT_GROUND_TOOLTIP, statFrame.runSpeed+0.5))
        GameTooltip:AddLine(format(e.onlyChinese and '游泳速度：%d%%' or STAT_MOVEMENT_SWIM_TOOLTIP, statFrame.swimSpeed+0.5))
        if (statFrame.unit ~= "pet") then
            GameTooltip:AddLine(format(e.onlyChinese and '飞行速度：%d%%' or STAT_MOVEMENT_FLIGHT_TOOLTIP, statFrame.flightSpeed+0.5))
            GameTooltip:AddLine(format('%s: %i%%', e.onlyChinese and '驭空术' or LANDING_DRAGONRIDING_PANEL_TITLE, 100*100/BASE_MOVEMENT_SPEED))
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(e.onlyChinese and '提升移动速度。|n|n速度：%s [+%.2f%%]' or CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)))
        GameTooltip:Show()
        statFrame.UpdateTooltip = MovementSpeed_OnEnter
    end

-- Base stats
    hooksecurefunc('PaperDollFrame_SetStat', function(frame, unit, statIndex)--主属性
        if StatusPlusButton:create_status_label(frame) then
            local tooltipText
            local _, _, posBuff, negBuff = UnitStat(unit, statIndex)
            if posBuff ~= 0 or negBuff ~= 0 then
                if ( posBuff > 0 ) then
                    tooltipText = GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE
                end
                if ( negBuff < 0 ) then
                    tooltipText = (tooltipText or '')..RED_FONT_COLOR_CODE.." -"..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE
                end
            end
            frame.numLabel:SetText(tooltipText or '')
        end
    end)

--Enhancements
    hooksecurefunc('PaperDollFrame_SetCritChance', function(frame)--爆击
        if StatusPlusButton:create_status_label(frame) then
            local rating, spellCrit, rangedCrit, meleeCrit
            local holySchool = 2
            local minCrit = GetSpellCritChance(holySchool)
            for i=(holySchool+1), MAX_SPELL_SCHOOLS do
                spellCrit = GetSpellCritChance(i)
                minCrit = min(minCrit, spellCrit)
            end
            spellCrit = minCrit
            rangedCrit = GetRangedCritChance()
            meleeCrit = GetCritChance()
            if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
                rating = CR_CRIT_SPELL
            elseif (rangedCrit >= meleeCrit) then
                rating = CR_CRIT_RANGED
            else
                rating = CR_CRIT_MELEE
            end
            StatusPlusButton:status_set_rating(frame, rating)
        end
    end)
    hooksecurefunc('PaperDollFrame_SetHaste', function(frame)--急速
        StatusPlusButton:create_status_label(frame, CR_HASTE_MELEE)
    end)
    hooksecurefunc('PaperDollFrame_SetMastery', function(frame)--精通
        StatusPlusButton:create_status_label(frame, CR_MASTERY)
    end)
    hooksecurefunc('PaperDollFrame_SetVersatility', function(frame)--全能
        if StatusPlusButton:create_status_label(frame) then
            local text
            local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0
            if versatility>1 then
                text= BreakUpLargeNumbers(versatility)
                local versatilityDamageTakenReduction= GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)
                if versatilityDamageTakenReduction>1 then
                    text= format('%s/|cffc69b6d%i%%|r', text, versatilityDamageTakenReduction)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetLifesteal', function(frame)--吸
        StatusPlusButton:create_status_label(frame, CR_LIFESTEAL)
    end)
    hooksecurefunc('PaperDollFrame_SetAvoidance', function(frame)--闪避
        StatusPlusButton:create_status_label(frame, CR_AVOIDANCE)
    end)
    hooksecurefunc('PaperDollFrame_SetSpeed', function(frame)--速度
        StatusPlusButton:create_status_label(frame, CR_SPEED)
    end)

-- Attack
    hooksecurefunc('PaperDollFrame_SetDamage', function(frame)--伤害
        if StatusPlusButton:create_status_label(frame) then
            frame.numLabel:SetText(frame.damage and frame.damage:match('(|c.-|r)') or '')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetAttackPower', function(frame)--功击强度
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)

    hooksecurefunc('PaperDollFrame_SetEnergyRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetRuneRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetFocusRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)

-- Spell
    hooksecurefunc('PaperDollFrame_SetSpellPower', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetManaRegen', function(frame)
        if frame.numLabel then
            frame.numLabel:SetText('')
        end
    end)

-- Defense
    hooksecurefunc('PaperDollFrame_SetArmor', function(frame, unit)--护甲
        if StatusPlusButton:create_status_label(frame) then
            local effectiveArmor = select(2, UnitArmor(unit))
            local text
            local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit)) or 0
            if armorReduction>1 then
                text = format('%i%%', armorReduction)
                local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor)
                if armorReductionAgainstTarget and armorReduction~=armorReductionAgainstTarget and armorReductionAgainstTarget>1 then
                    text = format('%s/%i%%', text, armorReductionAgainstTarget)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetDodge', function(frame)--躲闪
        StatusPlusButton:create_status_label(frame, CR_DODGE)
    end)
    hooksecurefunc('PaperDollFrame_SetParry', function(frame)--招架
        StatusPlusButton:create_status_label(frame, CR_PARRY)
    end)
    hooksecurefunc('PaperDollFrame_SetBlock', function(frame, unit)--格挡
        if StatusPlusButton:create_status_label(frame) then--, CR_BLOCK)
            local text
            local shieldBlockArmor = GetShieldBlock()
            local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel(unit)) or 0
            if blockArmorReduction>1 then
                local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor)
                text= format('%i%%', blockArmorReduction)
                if blockArmorReductionAgainstTarget and blockArmorReduction~= blockArmorReductionAgainstTarget and blockArmorReductionAgainstTarget>1 then
                    text=format('%s/%i%%', text, blockArmorReductionAgainstTarget)
                end
            end
            frame.numLabel:SetText(text or '')
        end
    end)
    hooksecurefunc('PaperDollFrame_SetResilience', function(frame)--韧性
        StatusPlusButton:create_status_label(frame, COMBAT_RATING_RESILIENCE_PLAYER_DAMAGE_TAKEN)
    end)

    hooksecurefunc('PaperDollFrame_SetLabelAndText', function(statFrame, _, text, isPercentage, numericValue)
        if not Save.hide and Save.itemLevelBit>0 and (isPercentage or (type(text)=='string' and text:find('%%'))) then--and select(2, math.modf(numericValue))>0 then
            statFrame.Value:SetFormattedText('%.0'..Save.itemLevelBit..'f%%', numericValue)
        end
    end)
end








local P_PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES
local function Init_Status_Menu()

    function StatusPlusButton.Menu:save()
        e.call('PaperDollFrame_UpdateStats')
        Save.PAPERDOLL_STATCATEGORIES= PAPERDOLL_STATCATEGORIES
    end

    function StatusPlusButton.Menu:find_stats(stat, index, P)--查找
        local tabs
        if P then
            tabs=P_PAPERDOLL_STATCATEGORIES[index]
        else
           tabs= PAPERDOLL_STATCATEGORIES[index]
        end
        if tabs then
            for _, tab in pairs(tabs.stats or {}) do
                if tab.stat==stat then
                    return tab
                end
            end
        end
        return false
    end

    function StatusPlusButton.Menu:find_roles(roles)
        local tank, n, dps= false, false, false
        for _, num in pairs(roles or {}) do
            if num== Enum.LFGRole.Tank then--0
                tank=true
            elseif num== Enum.LFGRole.Healer then--1
                n=true
            elseif num== Enum.LFGRole.Damage then--2
                dps=true
            end
        end
        return tank, n, dps
    end

    function StatusPlusButton.Menu:add_stat(tab)--添加
        local index= tab.index
        local stat=tab.stat
        if not PAPERDOLL_STATCATEGORIES[index] then
            local categoryFrame= index==1 and 'AttributesCategory'
                        or (index==2 and 'EnhancementsCategory')
                        or (index==3 and 'GeneralCategory')
                        or (index==4 and 'AttackCategory')
                        or 'OtherCategory'
            PAPERDOLL_STATCATEGORIES[index]= {
                categoryFrame= categoryFrame,
                stats={},
            }
            if not CharacterStatsPane[categoryFrame] then
                local frame= CreateFrame("Frame", nil, CharacterStatsPane, 'CharacterStatFrameCategoryTemplate')
                local title= index==3 and (e.onlyChinese and '综合' or GENERAL)
                        or index==4 and (e.onlyChinese and '攻击' or ATTACK)
                        or (e.onlyChinese and '其它' or OTHER)
                frame.titleText=title
                frame.Title:SetText(title)
                CharacterStatsPane[categoryFrame]= frame
            end
        end
        local P_tab=self:find_stats(stat, index, true)--查找
        if not PAPERDOLL_STATCATEGORIES[index] then
            PAPERDOLL_STATCATEGORIES[index]= {categoryFrame= index}
        end
        if P_tab then
            table.insert(PAPERDOLL_STATCATEGORIES[index].stats, P_tab)
        else
            table.insert(PAPERDOLL_STATCATEGORIES[index].stats, {
                stat=stat,
                hideAt=-1,
                --roles= tab.roles,
                --primary= tab.primary,
                --showFunc= tab.showFunc,
            })
        end
        print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r', stat), e.onlyChinese and '添加' or ADD)
    end

    function StatusPlusButton.Menu:remove_stat(tab)--移除        
        local index= tab.index
        local stat= tab.stat
        local name= tab.name
        if PAPERDOLL_STATCATEGORIES[index] then
            for i, info in pairs(PAPERDOLL_STATCATEGORIES[index].stats or {}) do
                if info.stat==stat then
                    table.remove(PAPERDOLL_STATCATEGORIES[index].stats, i)
                    print(id, Initializer:GetName(), format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '移除' or REMOVE), stat, name)
                    return
                end
            end
        end
        print(id, Initializer:GetName(), format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), stat, name)
    end

    function StatusPlusButton.Menu:get_primary_text(primary)--主属性, 文本
        if primary then
            if primary==LE_UNIT_STAT_STRENGTH then
                return format('|cffc69b6d%s|r', e.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH)
            elseif primary==LE_UNIT_STAT_AGILITY then
                return format('|cff16c663%s|r', e.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY)
            elseif primary==LE_UNIT_STAT_INTELLECT then
                return format('|cff00ccff%s|r', e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT)
            end
        end
    end
    e.LibDD:UIDropDownMenu_Initialize(StatusPlusButton.Menu, function(self, level, menuList)
        local info
        if menuList=='STATUS_Func_itemLevelBit' then
            for i=0, 4 do
                info={
                    text= format('%s %d', e.onlyChinese and '小数点' or 'bit', i),
                    checked= Save.itemLevelBit==i,
                    arg1=i,
                    func= function(_, arg1)
                        Save.itemLevelBit= arg1
                        e.call('PaperDollFrame_UpdateStats')
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        elseif menuList=='ENABLE_DISABLE' then
            info= {
                text=e.onlyChinese and '全部清除' or CLEAR_ALL,
                notCheckable=true,
                icon='bags-button-autosort-up',
                func= function()
                    PAPERDOLL_STATCATEGORIES= {}
                    e.LibDD:CloseDropDownMenus(1)
                    self:save()
                    print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r', e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT), e.onlyChinese and '完成' or DONE)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            info= {
                text=e.onlyChinese and '还原' or TRANSMOGRIFY_TOOLTIP_REVERT,
                notCheckable=true,
                icon='uitools-icon-refresh',
                colorCode= Save.PAPERDOLL_STATCATEGORIES and '' or '|cff9e9e9e',
                func= function()
                    PAPERDOLL_STATCATEGORIES= P_PAPERDOLL_STATCATEGORIES
                    Save.PAPERDOLL_STATCATEGORIES=nil
                    e.call('PaperDollFrame_UpdateStats')
                    e.LibDD:CloseDropDownMenus(1)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)

            e.LibDD:UIDropDownMenu_AddSeparator(level)
            info={
                text=e.onlyChinese and '显示菜单' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, HUD_EDIT_MODE_MICRO_MENU_LABEL),
                checked= Save.StatusPlus_OnEnter_show_menu,
                icon= 'newplayertutorial-drag-cursor',
                keepShownOnClick=true,
                tooltipOnButton=true,
                tooltipTitle= e.onlyChinese and '移过图标时，显示菜单' or 'Show menu when moving over icon',
                func= function()
                    Save.StatusPlus_OnEnter_show_menu= not Save.StatusPlus_OnEnter_show_menu and true or nil
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
            info={
                text= format('%s Plus|A:communities-icon-addchannelplus:0:0|a', e.onlyChinese and '属性' or STAT_CATEGORY_ATTRIBUTES),
                checked= not Save.notStatusPlusFunc,
                keepShownOnClick=true,
                tooltipOnButton=true,
                menuList='STATUS_Func_itemLevelBit',
                hasArrow=true,
                func= function()
                    Save.notStatusPlusFunc= not Save.notStatusPlusFunc and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.notStatusPlusFunc), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)


        elseif menuList then
            local stat, index, name= menuList:match('(.+)(%d)(.+)')
            index= tonumber(index)
            local stats= self:find_stats(stat, index, false)
            if stats then
                --自动隐藏 -1 0
                for i=-1, 0, 1 do
                    info={
                        text=format('%s |cnGREEN_FONT_COLOR:'..i..'|r', e.onlyChinese and '自动隐藏' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, HIDE)),
                        keepShownOnClick=true,
                        checked=stats.hideAt==i,
                        arg1={stat=stat, index=index, value=i},
                        tooltipOnButton=true,
                        tooltipTitle=format('<='..i..' %s', e.onlyChinese and '隐藏' or HIDE),
                        func= function(_, arg1)
                            for i, tab in pairs(PAPERDOLL_STATCATEGORIES[arg1.index] and PAPERDOLL_STATCATEGORIES[arg1.index].stats or {}) do
                                if tab.stat== arg1.stat then
                                    local value
                                    value= PAPERDOLL_STATCATEGORIES[arg1.index].stats[i].hideAt
                                    if not value or value~=arg1.value then
                                        value=arg1.value
                                    else
                                        value=nil
                                    end
                                    PAPERDOLL_STATCATEGORIES[arg1.index].stats[i].hideAt= value
                                    self:save()
                                    print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r', arg1.stat), value)
                                    return
                                end
                            end
                            print(id, Initializer:GetName(), format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE), arg1.stat)
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end

                --职责，设置
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                local tank, n, dps= self:find_roles(stats.roles)
                for i= Enum.LFGRole.Tank, Enum.LFGRole.Damage, 1 do
                    info={
                        text= i== Enum.LFGRole.Tank and format('%s%s', e.Icon.TANK, e.onlyChinese and '坦克' or TANK)
                            or i==Enum.LFGRole.Healer and format('%s%s', e.Icon.HEALER, e.onlyChinese and '治疗' or HEALER)
                            or i==Enum.LFGRole.Damage and format('%s%s', e.Icon.DAMAGER, e.onlyChinese and '伤害' or DAMAGER),
                        keepShownOnClick=true,
                        arg1={stat=stat, index=index, value=i},
                        func= function(_, arg1)
                            for _, tab in pairs (PAPERDOLL_STATCATEGORIES[arg1.index] and PAPERDOLL_STATCATEGORIES[arg1.index].stats or {}) do
                                if tab.stat==arg1.stat then
                                    local findTank, findN, findDps
                                    if not tab.roles then
                                        tab.roles={arg1.value}
                                    else
                                        findTank, findN, findDps=  self:find_roles(stats.roles)--职责，设置                                    
                                        if arg1.value==Enum.LFGRole.Tank then
                                            findTank = not findTank and true or false
                                        elseif arg1.value==Enum.LFGRole.Healer then
                                            findN = not findN and true or false
                                        elseif arg1.value==Enum.LFGRole.Damage then
                                            findDps = not findDps and true or false
                                        end
                                        if findTank or findN or findDps then
                                            local roles={}
                                            if findTank then table.insert(roles, Enum.LFGRole.Tank) end
                                            if findN then table.insert(roles, Enum.LFGRole.Healer) end
                                            if findDps then table.insert(roles, Enum.LFGRole.Damage) end
                                            tab.roles= roles
                                        else
                                            tab.roles=nil
                                        end
                                    end
                                    self:save()
                                    print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r', stats.stat) , findTank and e.Icon.TANK or '', findN and e.Icon.HEALER or '', findDps and e.Icon.DAMAGER or '')
                                    return
                                end
                            end
                            print(id, Initializer:GetName(), format('|cnRED_FONT_COLOR:%s|r %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, arg1.stat))
                        end
                    }
                    if i==Enum.LFGRole.Tank then
                        info.checked= tank
                    elseif i==Enum.LFGRole.Healer then
                        info.checked= n
                    elseif i== Enum.LFGRole.Damage then
                        info.checked= dps
                    end
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end

                --主属性，条件
                e.LibDD:UIDropDownMenu_AddSeparator(level)
                for _, primary in pairs({LE_UNIT_STAT_STRENGTH, LE_UNIT_STAT_AGILITY , LE_UNIT_STAT_INTELLECT}) do
                    info={
                        text= format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, self:get_primary_text(primary)),
                        keepShownOnClick=true,
                        checked= stats.primary==primary,
                        arg1={stat=stat, index=index, value=primary},
                        func= function(_, arg1)
                            for _, tab in pairs (PAPERDOLL_STATCATEGORIES[arg1.index] and PAPERDOLL_STATCATEGORIES[arg1.index].stats or {}) do
                                if tab.stat==arg1.stat then
                                    if not tab.primary or tab.primary~=arg1.value then
                                        tab.primary=arg1.value
                                    else
                                        tab.primary=nil
                                    end
                                    self:save()
                                    print(id, Initializer:GetName(), format('|cnGREEN_FONT_COLOR:%s|r', stats.stat) , format(e.onlyChinese and '仅限%s' or LFG_LIST_CROSS_FACTION, self:get_primary_text(tab.primary) or format('|cnRED_FONT_COLOR:%s|r', e.onlyChinese and '无' or NONE)))
                                    return
                                end
                            end
                            print(id, Initializer:GetName(), format('|cnRED_FONT_COLOR:%s|r %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, arg1.stat))
                        end
                    }
                    e.LibDD:UIDropDownMenu_AddButton(info, level)
                end

                e.LibDD:UIDropDownMenu_AddSeparator(level)
                if stats.showFunc then
                    e.LibDD:UIDropDownMenu_AddButton({
                        text='|cnGREEN_FONT_COLOR:showFunc|r',
                        checked=true,
                        isTitle=true,
                    }, level)
                end
                info={
                    text=name..' '..stat..' '..index,
                    notCheckable=true,
                    isTitle=true,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            else
                info={
                    text=format('|cnRED_FONT_COLOR:%s|r %s %s %s', e.onlyChinese and '尚未发现' or TAXI_PATH_UNREACHABLE, name, stat, index),
                    notCheckable=true,
                    isTitle=true,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end

        end
        if menuList then
            return
        end



        local AttributesCategory={
            {stat='STRENGTH', index=1, name=e.onlyChinese and '力量' or SPEC_FRAME_PRIMARY_STAT_STRENGTH, primary=LE_UNIT_STAT_STRENGTH},--AttributesCategory
            {stat='AGILITY', index=1, name=e.onlyChinese and '敏捷' or SPEC_FRAME_PRIMARY_STAT_AGILITY, rimary=LE_UNIT_STAT_AGILITY},
            {stat='INTELLECT', index=1, name=e.onlyChinese and '智力' or SPEC_FRAME_PRIMARY_STAT_INTELLECT, primary=LE_UNIT_STAT_INTELLECT},
            {stat='-'},
            {stat='STAMINA', index=1, name= e.onlyChinese and '耐力' or STA_LCD},
            {stat='ARMOR', index=1},
            {stat='STAGGER', index=1},
            {stat='MANAREGEN', index=1, name=e.onlyChinese and '法力回复' or MANA_REGEN},
            {stat='SPELLPOWER', index=1, name=e.onlyChinese and '法术强度' or STAT_SPELLPOWER},

            {stat='HEALTH', index=1},
            {stat='POWER', index=1, name=e.onlyChinese and '能量' or POWER_TYPE_POWER},
            {stat='ALTERNATEMANA', index=1, name=e.onlyChinese and '法力值' or  MANA},

            {stat='-'},
        --}
        --local EnhancementsCategory={
            {stat='CRITCHANCE', index=2, name=e.onlyChinese and '爆击' or STAT_CRITICAL_STRIKE},
            {stat='HASTE', index=2},
            {stat='MASTERY', index=2},
            {stat='VERSATILITY', index=2},
            {stat='LIFESTEAL', index=2},
            {stat='AVOIDANCE', index=2},
            {stat='SPEED', index=2},
            {stat='DODGE', index=2},
            {stat='PARRY', index=2},
            {stat='BLOCK', index=2},

            {stat='ENERGY_REGEN', index=2},
            {stat='RUNE_REGEN', index=2},
            {stat='FOCUS_REGEN', index=2},

            {stat='MOVESPEED', index=2, name=e.onlyChinese and '移动' or NPE_MOVE},
            {stat='ATTACK_DAMAGE', index=2, name=e.onlyChinese and '伤害' or DAMAGE, },
            {stat='ATTACK_AP', index=2,  name=e.onlyChinese and '攻击强度' or STAT_ATTACK_POWER, },
            {stat='ATTACK_ATTACKSPEED', index=2, name=e.onlyChinese and '攻击速度' or ATTACK_SPEED},

        }
        for _, tab in pairs(AttributesCategory) do
            if tab.stat=='-' then
                e.LibDD:UIDropDownMenu_AddSeparator(level)
            else
                local index= tab.index
                local stat= tab.stat
                local name= tab.name or e.cn(_G[stat] or _G['STAT_'..stat]) or stat
                tab.name= tab.name or name
                local stats= self:find_stats(stat, index, false)
                local role, autoHide ='', ''
                if stats then
                    local tank, n, dps= self:find_roles(stats.roles)--职责
                    role= format('%s%s%s', tank and e.Icon.TANK or '', n and e.Icon.HEALER or '', dps and e.Icon.DAMAGER or '')
                    autoHide= format('|cnGREEN_FONT_COLOR:%s|r', stats.hideAt or '')--隐藏 0， -1
                end
                local primary=  self:get_primary_text(stats and stats.primary) or ''--主属性
                info={
                    text=name..autoHide..role..primary,
                    tooltipOnButton=true,
                    tooltipTitle=format('%s |cnGREEN_FONT_COLOR:%s|r', tab.stat, index),
                    keepShownOnClick=true,
                    checked= stats and true or false,
                    menuList=stat..index..name,
                    hasArrow=true,
                    arg1=tab,
                    arg2=index,
                    func= function(_, arg1)
                        local find= self:find_stats(arg1.stat, arg1.index)
                        if not find then
                            self:add_stat(arg1)
                        else
                            self:remove_stat(arg1)
                        end
                        self:save()
                        e.LibDD:CloseDropDownMenus(2)
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)

        info= {
            text=e.GetEnabeleDisable(true)..(Save.StatusPlus_OnEnter_show_menu and '|A:newplayertutorial-drag-cursor:0:0|a' or '')..(Save.notStatusPlusFunc and '' or '|A:communities-icon-addchannelplus:0:0|a'),
            checked= not Save.notStatusPlus,
            hasArrow=true,
            menuList='ENABLE_DISABLE',
            func= function()
                StatusPlusButton:set_enabel_disable()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

    end, 'MENU')
end









--属性，增强 PaperDollFrame.lua
function panel:Init_Status_Plus()
    if StatusPlusButton or Save.hide then
        if StatusPlusButton then
            StatusPlusButton:SetShown(not Save.hide)
        end
        return
    end
    StatusPlusButton= e.Cbtn(CharacterStatsPane, {size={20,20}, icon='hide'})--显示/隐藏装备管理框选项
    StatusPlusButton:SetPoint('RIGHT', CharacterFrameCloseButton, 'LEFT')
    StatusPlusButton:SetFrameStrata(CharacterFrameCloseButton:GetFrameStrata())
    StatusPlusButton:SetFrameLevel(CharacterFrameCloseButton:GetFrameLevel()+1)
    function StatusPlusButton:set_alpha(min)
        self:SetAlpha(min and 0.3 or 1)
    end
    function StatusPlusButton:set_texture()
        self:SetNormalAtlas(Save.notStatusPlus and e.Icon.disabled or format('charactercreate-gendericon-%s-selected', e.Player.sex==3 and 'Female' or 'male'))
    end
    function StatusPlusButton:set_enabel_disable()
        Save.notStatusPlus= not Save.notStatusPlus and true or nil
        self:set_texture()
        print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.notStatusPlus), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end
    function StatusPlusButton:show_menu()
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 40, 0)--主菜单
    end
    function StatusPlusButton:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.left)
        e.tips:Show()
        self:set_alpha(false)
    end
    StatusPlusButton:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        self:set_alpha(true)
    end)
    StatusPlusButton:SetScript('OnEnter', StatusPlusButton.set_tooltips)

    StatusPlusButton.Menu= CreateFrame("Frame", nil, StatusPlusButton, "UIDropDownMenuTemplate")

    StatusPlusButton:SetScript("OnClick", StatusPlusButton.show_menu)

    StatusPlusButton:set_texture()
    StatusPlusButton:set_alpha(true)

    if Save.notStatusPlus then
        e.LibDD:UIDropDownMenu_Initialize(StatusPlusButton.Menu, function(_, level)
            e.LibDD:UIDropDownMenu_AddButton({
                text=e.onlyChinese and '启用' or ENABLE,
                checked= not Save.notStatusPlus,
                func= function()
                    StatusPlusButton:set_enabel_disable()
                end,
            }, level)
        end)
        return
    end

    if Save.PAPERDOLL_STATCATEGORIES then--加载，数据
        PAPERDOLL_STATCATEGORIES= Save.PAPERDOLL_STATCATEGORIES
    end

    StatusPlusButton:SetScript('OnEnter', function(self)--重新,设置
        self:set_tooltips()
        if Save.StatusPlus_OnEnter_show_menu then--移过图标时，显示菜单
            e.LibDD:CloseDropDownMenus(1)
            self:show_menu()
        end
    end)

    Init_Status_Menu()
    Init_Status_Func()
end










































--#####
--初始化
--#####
local function Init()
    Init_Show_Hide_Button(PaperDollItemsFrame)--初始，显示/隐藏，按钮

    GetDurationTotale()--装备,总耐久度

    panel:Init_Server_equipmentButton_Lable()--显示服务器名称，装备管理框


    --Init_ChromieTime()--时空漫游战役, 提示

    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
        Init_Title()--总装等
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
    hooksecurefunc('EquipmentFlyout_UpdateItems', function()
        local itemButton = EquipmentFlyoutFrame.button;
        set_equipment_flyout_buttons(itemButton)
    end)
   hooksecurefunc('EquipmentFlyout_Show', set_equipment_flyout_buttons)











    --############
    --更改,等级文本
    --############
    hooksecurefunc('PaperDollFrame_SetLevel', function()--PaperDollFrame.lua
        --Init_ChromieTime()--时空漫游战役, 提示
        if Save.hide then
            return
        end
        local race= e.GetUnitRaceInfo({unit='player', guid=nil , race=nil , sex=nil , reAtlas=true})
        local class= e.Class('player', nil, true)
        local level
        level= UnitLevel("player")
        local effectiveLevel = UnitEffectiveLevel("player")

        if ( effectiveLevel ~= level ) then
            level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level)
        end
        local faction= format('|A:%s:26:26|a', e.Icon[e.Player.faction] or '')
        CharacterLevelText:SetText('  '..faction..(race and '|A:'..race..':26:26|a' or '')..(class and '|A:'..class..':26:26|a  ' or '')..level)
        if not CharacterLevelText.set then
            e.Set_Label_Texture_Color(CharacterLevelText, {type='FontString'})
            CharacterLevelText:SetJustifyH('LEFT')
            CharacterLevelText:EnableMouse(true)
            CharacterLevelText:HookScript('OnLeave', function(self2) e.tips:Hide() self2:SetAlpha(1) end)
            CharacterLevelText:HookScript('OnEnter', function(self2)
                local info = C_PlayerInfo.GetPlayerCharacterData()
                if Save.hide or not info then
                    return
                end
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, Initializer:GetName())
                e.tips:AddLine(' ')
                e.tips:AddLine('name |cnGREEN_FONT_COLOR:'..info.name)
                e.tips:AddLine('fileName |cnGREEN_FONT_COLOR:'..info.fileName)
                e.tips:AddLine('sex |cnGREEN_FONT_COLOR:'..info.sex)
                e.tips:AddLine('displayID |cnGREEN_FONT_COLOR:'..C_PlayerInfo.GetDisplayID())
                e.tips:AddDoubleLine((info.createScreenIconAtlas and '|A:'..info.createScreenIconAtlas..':0:0|a' or '')..'createScreenIconAtlas', info.createScreenIconAtlas)
                e.tips:AddDoubleLine('GUID', UnitGUID('player'))
                e.tips:AddLine(' ')

                local expansionID = UnitChromieTimeID('player')--时空漫游战役 PartyUtil.lua
                local option = C_ChromieTime.GetChromieTimeExpansionOption(expansionID)
                local expansion = option and e.cn(option.name) or (e.onlyChinese and '无' or NONE)
                if option and option.previewAtlas then
                    expansion= '|A:'..option.previewAtlas..':0:0|a'..expansion
                end
                local text= format(e.onlyChinese and '你目前处于|cffffffff时空漫游战役：%s|r' or PARTY_PLAYER_CHROMIE_TIME_SELF_LOCATION, expansion)
                e.tips:AddDoubleLine((e.onlyChinese and '选择时空漫游战役' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, CHROMIE_TIME_SELECT_EXAPANSION_BUTTON, CHROMIE_TIME_PREVIEW_CARD_DEFAULT_TITLE))..': '..e.GetEnabeleDisable(C_PlayerInfo.CanPlayerEnterChromieTime()),
                                        text
                                    )
                e.tips:AddLine(' ')
                for _, info2 in pairs(C_ChromieTime.GetChromieTimeExpansionOptions() or {}) do
                    local col= info2.alreadyOn and '|cffff00ff' or ''-- option and option.id==info.id
                    e.tips:AddDoubleLine((info2.alreadyOn and format('|A:%s:0:0|a', e.Icon.toRight) or '')..col..(info2.previewAtlas and '|A:'..info2.previewAtlas..':0:0|a' or '')..info2.name..(info2.alreadyOn and format('|A:%s:0:0|a', e.Icon.toLeft) or '')..col..' ID '.. info2.id, col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info2.completed))
                    --e.tips:AddDoubleLine(' ', col..(info.mapAtlas and '|A:'..info.mapAtlas..':0:0|a'.. info.mapAtlas))
                    --e.tips:AddDoubleLine(' ', col..(info.previewAtlas and '|A:'..info.previewAtlas..':0:0|a'.. info.previewAtlas))
                    --e.tips:AddDoubleLine(' ', col..(e.onlyChinese and '完成' or COMPLETE)..': '..e.GetYesNo(info.completed))
                end

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
                e.tips:AddDoubleLine(id, Initializer:GetName())
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(self.str,
                    C_EquipmentSet.GetEquipmentSetID(self.str)
                    and ('|cffff00ff'..(e.onlyChinese and '修改' or EDIT)..'|r')
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
                    print(id,Initializer:GetName(), '|cffff00ff'..(e.onlyChinese and '修改' or EDIT)..'|r', self.str)
                else
                    print(id,Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '新建' or NEW)..'|r', self.str)
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
                print(id, Initializer:GetName(), iconFileID and '|T'..iconFileID..':0|t|cnGREEN_FONT_COLOR:' or '', name)
            end)
            btn.setScripOK=true
        end
    end)




    panel:Init_Status_Plus()--属性，增强


    C_Timer.After(2, function()
        Init_TrackButton_ShowHide_Button()--装备管理, 总开关
        Init_TrackButton()
    end)--装备管理框
end



























--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            Save= WoWToolsSave[addName] or Save
            Save.itemLevelBit= Save.itemLevelBit or 1

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= (e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName),
                --tooltip= Initializer:GetName(),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            })

            --[[添加控制面板
            local sel=e.AddPanel_Check((e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)]]


            if not Save.disabled then
                Init()
                self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
                self:RegisterEvent('SOCKET_INFO_UPDATE')--宝石，更新

                --[[ProfessionsFrame_LoadUI()
                OpenProfessionUIToSkillLine(202)
                C_TradeSkillUI.CloseTradeSkill()]]

            else
                self:UnregisterEvent('ADDON_LOADED')
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_InspectUI' then--目标, 装备
            self:Init_Target_InspectUI()
            InspectFrame:HookScript('OnShow', Set_Target_Status)
            --hooksecurefunc('InspectFrame_UnitChanged', Set_Target_Status)
            hooksecurefunc('InspectPaperDollItemSlotButton_Update', set_InspectPaperDollItemSlotButton_Update)--目标, 装备
            hooksecurefunc('InspectPaperDollFrame_SetLevel', set_InspectPaperDollFrame_SetLevel)--目标,天赋 装等
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        GetDurationTotale()--装备,总耐久度

    elseif event=='SOCKET_INFO_UPDATE' then--宝石，更新
        if PaperDollItemsFrame:IsShown() then
            e.call('PaperDollFrame_UpdateStats')
        end
    end
end)
