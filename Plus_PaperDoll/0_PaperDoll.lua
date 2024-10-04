local id, e = ...
local addName= CHARACTER
WoWTools_PaperDollMixin={
Save={
    --hide=true,--隐藏CreateTexture

    --EquipmentH=true, --装备管理, true横, false坚
    equipment= e.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1,--装备管理, 缩放
    trackButtonShowItemLeve= e.Player.husandro,--装等
    trackButtonStrata='HIGH',

    --notStatusPlus=true,--禁用，属性 PLUS
    StatusPlus_OnEnter_show_menu=true,--移过图标时，显示菜单

    --notStatusPlusFunc=true, --属性 PLUS Func
    itemLevelBit= 1,--物品等级，位数

},

}

local function Save()
    return WoWTools_PaperDollMixin.Save
end


local panel= CreateFrame("Frame", nil, PaperDollFrame)



--[[local function Is_Load_ElvUI(btn)
    if C_AddOns.IsAddOnLoaded('ElvUI') and not btn.icon then
        btn.icon= btn:CreateTexture()
    end
end]]





local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr= ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"

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









local function recipeLearned(recipeSpellID)--是否已学配方
    return C_TradeSkillUI.IsRecipeProfessionLearned(recipeSpellID)
    --local info= C_TradeSkillUI.GetRecipeInfo(recipeSpellID)
    --return info and info.learned
end












--增加 [潘达利亚工程学: 地精滑翔器] recipeID 126392
--[诺森德工程学: 氮气推进器] ricipeID 109099
local function set_Engineering(self, slot, link, use, isPaperDollItemSlot)
    if not ((slot==15 and recipeLearned(126392)) or (slot==6 and recipeLearned(55016))) or use or Save().hide or not link or not isPaperDollItemSlot then


        if self.engineering  then
            self.engineering:SetShown(false)
        end
        return
    end

    if not self.engineering then
        local h=self:GetHeight()/3
        self.engineering=WoWTools_ButtonMixin:Cbtn(self, {icon='hide',size={h,h}})
        self.engineering:SetNormalTexture(136243)
        if is_Left_Slot(slot) then
            self.engineering:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)
        else
            self.engineering:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
        end
        self.engineering.spell= slot==15 and 126392 or 55016

        self.engineering:SetScript('OnMouseDown' ,function(frame, d)
            if d=='LeftButton' then
                local n=C_Item.GetItemCount(90146, true, false, true, false)
                if n==0 then
                    print(WoWTools_ItemMixin:GetLink(90146) or (e.onlyChinese and '附加材料' or OPTIONAL_REAGENT_TUTORIAL_TOOLTIP_TITLE), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '无' or NONE))
                    return
                end
                local isShow= ProfessionsFrame and ProfessionsFrame:IsShown()
                do
                    WoWTools_LoadUIMixin:Professions(frame.spell)
                end
                do
                    C_TradeSkillUI.CraftRecipe(frame.spell)
                    if not isShow then
                        C_TradeSkillUI.CloseTradeSkill()
                    end
                end
                ToggleCharacter("PaperDollFrame", true)

            elseif d=='RightButton' then
                WoWTools_LoadUIMixin:Professions(frame.spell)
                --OpenProfessionUIToSkillLine(parentTradeSkillID)
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
    if not find and not Save().hide and isPaperDollItemSlot then
        tab=get_no_Enchant_Bag(slot)--取得，物品，bag, slot
        if tab and not self.noEnchant then
            local h=self:GetHeight()/3
            self.noEnchant= WoWTools_ButtonMixin:Cbtn(self, {size={h, h}, type=true, icon='hide'})
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
            texture:SetAllPoints()
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
    if Save().hide then
        link= nil
    end
    local enchant, use, pvpItem, upgradeItem, createItem
    local unit = (not isPaperDollItemSlot and InspectFrame) and InspectFrame.unit or 'player'
    local isLeftSlot= is_Left_Slot(slot)

    if link and not C_Item.IsCorruptedItem(link) then
        local dateInfo= WoWTools_ItemMixin:GetTooltip({hyperLink=link, text={enchantStr, pvpItemStr, upgradeStr,ITEM_CREATED_BY_Str}, onlyText=true})--物品提示，信息
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
        --[[self.use:SetScript('OnMouseDown', function(f)
            local info=C_TradeSkillUI.GetRecipeInfo(f.spellID)
            if info and info.recipeID then
                WoWTools_LoadUIMixin:Professions(info.recipeID)
            end
        end)]]
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
            self.upgradeItem= WoWTools_LabelMixin:Create(self, {color={r=0,g=1,b=0}, mouse=true})
            self.upgradeItem:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT',1,0)
        else
            self.upgradeItem= WoWTools_LabelMixin:Create(self, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
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
        upgradeItemText= strlower(WoWTools_TextMixin:sub(upText,1,3, true))
        if not self.upgradeItemText then
            local h= self:GetHeight()/3
            if isLeftSlot then
                self.upgradeItemText= WoWTools_LabelMixin:Create(self, {color={r=0,g=1,b=0}, mouse=true})
                self.upgradeItemText:SetPoint('LEFT', self, 'RIGHT',h+8,0)
            else
                self.upgradeItemText= WoWTools_LabelMixin:Create(self, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
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
            self.createItem= WoWTools_LabelMixin:Create(self, {color={r=0,g=1,b=0}, mouse=true})
            self.createItem:SetPoint('LEFT', self, 'RIGHT',1,0)
        else
            self.createItem= WoWTools_LabelMixin:Create(self, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
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



if not PlayerGetTimerunningSeasonID() then
    if not Save().hide and link then--宝石
        local numSockets= C_Item.GetItemNumSockets(link) or 0--MAX_NUM_SOCKETS
        for n=1, numSockets do
            local gemLink= select(2, C_Item.GetItemGem(link, n))
            e.LoadData({id=gemLink, type='item'})

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

elseif not Save().hide and self.SocketDisplay:IsShown() and link then
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
    if not frame.slotText and not Save().hide and not isEquipped then
        frame.slotText=WoWTools_LabelMixin:Create(frame, {color=true, justifyH='CENTER', mouse=true})
        frame.slotText:EnableMouse(true)
        frame.slotText:SetAlpha(0.3)
        frame.slotText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
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
        frame.slotText:SetShown(not Save().hide and not isEquipped)
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

    local btn= WoWTools_ButtonMixin:Cbtn(frame, {size={20,20}, atlas= not Save().hide and e.Icon.icon or e.Icon.disabled})
    btn:SetFrameStrata(title:GetFrameStrata())
    btn:SetPoint('LEFT', title)
    btn:SetFrameLevel(title:GetFrameLevel()+1)

    btn:SetScript('OnClick', function(_, d)
        if d=='RightButton' then
            e.OpenPanelOpting(nil, WoWTools_PaperDollMixin.addName)
            return
        end
        Save().hide= not Save().hide and true or nil

        WoWTools_PaperDollMixin:Set_Duration()--装备, 总耐久度
        WoWTools_PaperDollMixin:Settings_ServerInfo()--显示服务器名称
        WoWTools_PaperDollMixin:Settings_Tab2()--头衔数量
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
        WoWTools_PaperDollMixin:Settings_Tab3()--标签, 内容,提示
        --Init_ChromieTime()--时空漫游战役, 提示

        WoWTools_PaperDollMixin:TrackButton_Settings()--添加装备管理框

        WoWTools_PaperDollMixin:Init_Status_Plus()--属性，增强

        e.call(PaperDollFrame_SetLevel)
        e.call(PaperDollFrame_UpdateStats)

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
                e.call(PaperDollItemSlotButton_Update, btn2)
            end
        end

        if InspectFrame then
            if InspectFrame:IsShown() then
                e.call(InspectPaperDollFrame_UpdateButtons)--InspectPaperDollFrame.lua
                e.call(InspectPaperDollFrame_SetLevel)--目标,天赋 装等
                panel:Init_Target_InspectUI()
            end
            if InspectLevelText then
                WoWTools_LabelMixin:Create(nil, {changeFont= InspectLevelText, size= not Save().hide and 18 or 12})
            end
            if InspectFrame.ShowHideButton then
                InspectFrame.ShowHideButton:SetNormalAtlas(Save().hide and e.Icon.disabled or e.Icon.icon)
            end
            if InspectFrame.statusLabel then--目标，属性
                InspectFrame.statusLabel:settings()
            end
        end
        PaperDollItemsFrame.ShowHideButton:SetNormalAtlas(Save().hide and e.Icon.disabled or e.Icon.icon)

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
        e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
        e.tips:AddLine(' ')

        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save().hide), e.Icon.left)

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

    if not frame.initButton and not Save().hide then
        if frame.ViewButton then
            WoWTools_LabelMixin:Create(nil, {changeFont= InspectLevelText, size=18})
            frame.ViewButton:ClearAllPoints()
            frame.ViewButton:SetPoint('LEFT', InspectLevelText, 'RIGHT',20,0)
            frame.ViewButton:SetSize(25,25)
            frame.ViewButton:SetText(e.onlyChinese and '试' or WoWTools_TextMixin:sub(VIEW,1))
        end
        if InspectPaperDollItemsFrame.InspectTalents then
            InspectPaperDollItemsFrame.InspectTalents:SetSize(25,25)
            InspectPaperDollItemsFrame.InspectTalents:SetText(e.onlyChinese and '赋' or WoWTools_TextMixin:sub(TALENT,1))
        end
        frame.initButton=true
    end
end

local function set_InspectPaperDollItemSlotButton_Update(self)
    local slot= self:GetID()
	local link= not Save().hide and GetInventoryItemLink(InspectFrame.unit, slot) or nil
	e.LoadData({id=link, type='item'})--加载 item quest spell
    --set_Gem(self, slot, link)
    set_Item_Tips(self, slot, link, false)
    set_Slot_Num_Label(self, slot, link and true or false)--栏位, 帐号最到物品等级
    WoWTools_ItemStatsMixin:SetItem(self, link, {point=self.icon})
    if not self.OnEnter and not Save().hide then
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
            WoWTools_ChatMixin:Chat(self2.link, nil, true)
            --local chat=SELECTED_DOCK_FRAME
            --ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)

        end)
    end
    self.link= link

    if link and not self.itemLinkText then
        self.itemLinkText= WoWTools_LabelMixin:Create(self)
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
    if Save().hide then
        return
    end
    local unit= InspectFrame.unit
    local guid= unit and UnitGUID(unit)
    local info= guid and e.UnitItemLevel[guid]
    if info and info.itemLevel and info.specID  then
        local level= UnitLevel(unit)
        local effectiveLevel= UnitEffectiveLevel(unit)
        local sex = UnitSex(unit)

        local text= WoWTools_UnitMixin:GetPlayerInfo({unit=unit, guid=guid})
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
    frame.statusLabel= WoWTools_LabelMixin:Create(InspectPaperDollFrame)
    frame.statusLabel:SetPoint('TOPLEFT', InspectFrameTab1, 'BOTTOMLEFT',0,-2)
    function frame.statusLabel:settings()
        local unit=InspectFrame.unit
        local text
        if not Save().hide and UnitExists(unit) then
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
                text= text..col..info.text..': '..WoWTools_Mixin:MK(info.value, 3)..'|r'
            end
        end
        self:SetText(text or '')
    end
    frame.statusLabel:settings()
end



































































--#####
--初始化
--#####
local function Init()
    WoWTools_PaperDollMixin:Init_EquipmentFlyout()--装备弹出
    WoWTools_PaperDollMixin:Init_SetLevel()--更改,等级文本
    WoWTools_PaperDollMixin:Init_ServerInfo()--显示服务器名称--显示服务器名称，装备管理框
    WoWTools_PaperDollMixin:Init_Status_Plus()--属性，增强
    WoWTools_PaperDollMixin:Init_Duration()--总耐久度
    WoWTools_PaperDollMixin:Init_Tab1()--总装等
    WoWTools_PaperDollMixin:Init_Tab2()--头衔数量    
    WoWTools_PaperDollMixin:Init_Tab3()

    Init_Show_Hide_Button(PaperDollItemsFrame)--初始，显示/隐藏，按钮



    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
        WoWTools_PaperDollMixin:Settings_Tab2()--总装等
        WoWTools_PaperDollMixin:Settings_Tab3()
    end)

    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function()--装备管理
        WoWTools_PaperDollMixin:Settings_Tab3()
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    end)
    hooksecurefunc('GearSetButton_SetSpecInfo', function()--装备管理,修该专精
        WoWTools_PaperDollMixin:Settings_Tab3()
        WoWTools_PaperDollMixin:Settings_Tab1()--总装等
    end)
    hooksecurefunc('GearSetButton_UpdateSpecInfo', function(self)--套装已装备数量
        local setID=self.setID
        local nu
        if setID and not Save().hide then
            if not self.nu then
                self.nu=WoWTools_LabelMixin:Create(self)
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
                WoWTools_ItemStatsMixin:SetItem(self, not Save().hide and link or nil, {point=self.icon})
                WoWTools_PaperDollMixin:Settings_Tab3()
                WoWTools_PaperDollMixin:Settings_Tab1()
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
                    self.numFreeSlots=WoWTools_LabelMixin:Create(self, {color=true, justifyH='CENTER'})
                    self.numFreeSlots:SetPoint('BOTTOM',0 ,6)
                end
            end
            if self.numFreeSlots then
                self.numFreeSlots:SetText(numFreeSlots or '')
            end
            set_Slot_Num_Label(self, InventSlot_To_ContainerSlot[slot], isbagEquipped)--栏位
        end
    end)









    --添加，空装，按钮
    --PaperDollFrame.lua
    hooksecurefunc('PaperDollEquipmentManagerPane_InitButton', function(btn)
        if Save().hide then
            if btn.createButton then
                btn.createButton:SetShown(false)
            end
            return
        end
        if not btn.setID and not btn.createButton  then
            btn.createButton= WoWTools_ButtonMixin:Cbtn(btn, {size={30,30}, atlas='groupfinder-eye-highlight'})
            btn.createButton.str= e.onlyChinese and '空' or EMPTY
            btn.createButton:SetPoint('RIGHT', 0,-4)
            btn.createButton:SetScript('OnLeave', GameTooltip_Hide)
            btn.createButton:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.addName, WoWTools_PaperDollMixin.addName)
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
                    print(e.addName,WoWTools_PaperDollMixin.addName, '|cffff00ff'..(e.onlyChinese and '修改' or EDIT)..'|r', self.str)
                else
                    print(e.addName,WoWTools_PaperDollMixin.addName, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '新建' or NEW)..'|r', self.str)
                end
            end)
        end
        if btn.createButton then
            btn.createButton:SetShown(not btn.setID and true or false)
        end
        if not btn.setScripOK then
            btn:RegisterForClicks(e.LeftButtonDown, e.RightButtonDown)
            btn:HookScript('OnClick', function(self, d)
                if UnitAffectingCombat('player') or not self.setID or Save().hide or d~='RightButton' then
                    return
                end
                C_EquipmentSet.UseEquipmentSet(self.setID)
                local name, iconFileID = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
                print(e.addName, WoWTools_PaperDollMixin.addName, iconFileID and '|T'..iconFileID..':0|t|cnGREEN_FONT_COLOR:' or '', name)
            end)
            btn.setScripOK=true
        end
    end)



    




    C_Timer.After(2, function()
        WoWTools_PaperDollMixin:Init_TrackButton()--装备管理框
    end)
end



























--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            if WoWToolsSave[CHARACTER] then
                WoWTools_PaperDollMixin.Save= WoWToolsSave[CHARACTER]
                WoWToolsSave[CHARACTER]=nil
                
            else
                WoWTools_PaperDollMixin.Save= WoWToolsSave['Plus_PaperDoll'] or WoWTools_PaperDollMixin.Save
            end

            WoWTools_PaperDollMixin.addName= (
                e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a'
                or '|A:charactercreate-gendericon-female-selected:0:0|a'
            )..(e.onlyChinese and '角色' or addName)
            
            --添加控制面板
            e.AddPanel_Check({
                name= WoWTools_PaperDollMixin.addName,
                --tooltip= WoWTools_PaperDollMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_PaperDollMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end,
            })



            if not WoWTools_PaperDollMixin.disabled then
                Init()
                self:RegisterEvent('SOCKET_INFO_UPDATE')--宝石，更新    

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
            WoWToolsSave['Plus_PaperDoll']= Save()
        end

    elseif event=='SOCKET_INFO_UPDATE' then--宝石，更新
        if PaperDollItemsFrame:IsShown() then
            e.call(PaperDollFrame_UpdateStats)
        end
    end
end)
