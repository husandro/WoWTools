--物品
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end








local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr= ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(.-%%d%+/%%d%+)')-- "升级：%s/%s"

local ITEM_CREATED_BY_Str= ITEM_CREATED_BY:gsub('%%s','(.+)')--"|cff00ff00<由%s制造>|r"



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
        self.engineering=WoWTools_ButtonMixin:Cbtn(self, {size=h, texture='136243'})
        if WoWTools_PaperDollMixin:Is_Left_Slot(slot) then
            self.engineering:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)
        else
            self.engineering:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
        end
        self.engineering.spell= slot==15 and 126392 or 55016

        self.engineering:SetScript('OnMouseDown' ,function(frame, d)
            if d=='LeftButton' then
                local n=C_Item.GetItemCount(90146, true, false, true, false)
                if n==0 then
                    print(WoWTools_ItemMixin:GetLink(90146) or (WoWTools_DataMixin.onlyChinese and '附加材料' or OPTIONAL_REAGENT_TUTORIAL_TOOLTIP_TITLE), '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '无' or NONE))
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
                GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(frame.spell)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '商业技能' or TRADESKILLS), WoWTools_DataMixin.Icon.right)
                GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需求' or NEED), (WoWTools_DataMixin.onlyChinese and '打开一次' or CHALLENGES_LASTRUN_TIME)..'('..(WoWTools_DataMixin.onlyChinese and '打开' or UNWRAP)..')')
                GameTooltip:Show()
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
    if not subClassToSlot[slot] then
        return
    end
    local tab
    if not find and not Save().hide and isPaperDollItemSlot then
        tab=get_no_Enchant_Bag(slot)--取得，物品，bag, slot
        if tab and not self.noEnchant then
            local h=self:GetHeight()/3
            self.noEnchant= WoWTools_ButtonMixin:Cbtn(self, {size=h, isSecure=true})
            self.noEnchant:SetAttribute("type", "item")
            self.noEnchant.slot= slot
            if WoWTools_PaperDollMixin:Is_Left_Slot(slot) then
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
            self.noEnchant:SetScript('OnLeave',function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
            self.noEnchant:SetScript('OnEnter' ,function(self2)
                if self2.tab then
                    GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetBagItem(self2.tab.bag, self2.tab.slot)
                    if not self:CanChangeAttribute() then
                        GameTooltip:AddLine(' ')
                        GameTooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
                    end
                    GameTooltip:Show()
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
                if self2:CanChangeAttribute() then
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
        if tab and self.noEnchant:CanChangeAttribute() then
            self.noEnchant:SetAttribute("item", tab.bag..' '..tab.slot)
        end
        if not WoWTools_FrameMixin:IsLocked(self.noEnchant) then
            self.noEnchant:SetShown(tab and true or false)
        end
    end
end














local function set_Item_Tips(self, slot, link, isPaperDollItemSlot)--附魔, 使用, 属性
    if Save().hide then
        link= nil
    end
    local enchant, use, pvpItem, upgradeItem, createItem
    local unit = (not isPaperDollItemSlot and InspectFrame) and InspectFrame.unit or 'player'
    local isLeftSlot= WoWTools_PaperDollMixin:Is_Left_Slot(slot)

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
        self.enchant:SetScript('OnLeave',function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        self.enchant:SetScript('OnEnter' ,function(self2)
            if self2.tips then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self2.tips)
                GameTooltip:Show()
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
        self.use:SetScript('OnLeave',function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        self.use:SetScript('OnEnter' ,function(self2)
            if self2.spellID then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(self2.spellID)
                GameTooltip:Show()
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
        self.pvpItem:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        self.pvpItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and "装备：在竞技场和战场中将物品等级提高至%d。" or PVP_ITEM_LEVEL_TOOLTIP):format(self2.tips))
                GameTooltip:Show()
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
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
        self.upgradeItem:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
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
                    GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                    GameTooltip:Show()
                    self2:SetAlpha(0.3)
                end
            end)
            self.upgradeItemText:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
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
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '|cff00ff00<由%s制造>|r' or ITEM_CREATED_BY, self2.tips))
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
        self.createItem:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    end
    if self.createItem then
        self.createItem.tips=createItem
        self.createItem:SetText(createItem and '|A:communities-icon-notification:10:10|a' or '')
    end



if not PlayerIsTimerunning() then
    if not Save().hide and link then--宝石
        local numSockets= C_Item.GetItemNumSockets(link) or 0--MAX_NUM_SOCKETS
        for n=1, numSockets do
            local gemLink= select(2, C_Item.GetItemGem(link, n))
           WoWTools_DataMixin:Load(gemLink, 'item')

            local gem= self['gem'..n]
            if not gem then
                gem=self:CreateTexture()
                gem.index= n
                gem:SetSize(12.3, 12.3)--local h=self:GetHeight()/3 37 12.3
                gem:EnableMouse(true)
                gem:SetScript('OnLeave',function(frame) GameTooltip:Hide() frame:SetAlpha(1) end)
                gem:SetScript('OnEnter' ,function(frame)
                    if frame.gemLink then
                        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:SetHyperlink(frame.gemLink)
                        GameTooltip:Show()
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
                frame:SetScript('OnLeave', function(f) GameTooltip:Hide() f:SetScale(1) end)
                frame:SetScript('OnEnter', function(f)
                    if f.gemID then
                        GameTooltip:SetOwner(f, "ANCHOR_LEFT")
                        GameTooltip:ClearLines()
                        GameTooltip:SetItemByID(f.gemID)
                        GameTooltip:Show()
                    end
                    f:SetScale(1.3)
                end)
                self.SocketDisplay:ClearAllPoints()
                if isLeftSlot then
                    self.SocketDisplay:SetPoint('LEFT', self, 'RIGHT', 8, 0)
                else
                    self.SocketDisplay:SetPoint('RIGHT', self, 'LEFT', -8, 0)
                end
                frame:SetSize(14, 14)
                frame:SetFrameStrata('HIGH')
                frame.Slot:ClearAllPoints()
                frame.Slot:SetPoint('CENTER')
                frame.Slot:SetSize(13, 13)
            end
            local atlas
            if gemID then
                local quality= C_Item.GetItemQualityByID(gemID)--C_Item.GetItemQualityColor(quality)
                atlas= WoWTools_DataMixin.Icon[quality]
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
            self.du:SetPoint('RIGHT', self, 'LEFT', -1.5,0)
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
        self.du:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(self2. du and 1 or 0) end)
        self.du:SetScript('OnEnter', function(self2)
            if self2.du then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '耐久度 %d / %d' or DURABILITY_TEMPLATE, min,  max), format('%i%%', self2.du))
                GameTooltip:Show()
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
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_PaperDollMixin.addName)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS, self.slot)
            local name= self:GetParent():GetName()
            if name then
                GameTooltip:AddDoubleLine(_G[strupper(strsub(name, 10))], name)
            end
            GameTooltip:Show()
            self:SetAlpha(1)
        end)
        frame.slotText:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(0.3) end)
        frame.slotText:SetPoint('CENTER')
    end
    if frame.slotText then
        frame.slotText.slot= slot
        frame.slotText.name= frame:GetName()
        frame.slotText:SetText(slot)
        frame.slotText:SetShown(not Save().hide and not isEquipped)
    end
end










local function Init()
--装备属性
    WoWTools_DataMixin:Hook('PaperDollItemSlotButton_Update',  function(self)--PaperDollFrame.lua
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
                WoWTools_ItemMixin:SetItemStats(self, not Save().hide and link or nil, {point=self.icon})
                WoWTools_PaperDollMixin:Settings_Tab3()
                WoWTools_PaperDollMixin:Settings_Tab1()
            end
            set_Slot_Num_Label(self, slot, link and true or nil)--栏位
            self.icon:SetAlpha((hasItem or Save().hide) and 1 or 0.3)--图标透明度

        elseif InventSlot_To_ContainerSlot[slot] then
            local numFreeSlots, numAllSlots, slot2
            local isbagEquipped= self:HasBagEquipped()
            if isbagEquipped then--背包数
                slot2= InventSlot_To_ContainerSlot[slot]
                numFreeSlots= C_Container.GetContainerNumFreeSlots(slot2)
                numAllSlots= C_Container.GetContainerNumSlots(slot2)
                if numFreeSlots==0 then
                    numFreeSlots= '|cnWARNING_FONT_COLOR:'..numFreeSlots..'|r'
                end
                if not self.numFreeSlots then
                    self.numFreeSlots=WoWTools_LabelMixin:Create(self, {color=true, justifyH='CENTER', size=10})
                    self.numFreeSlots:SetPoint('TOP')

                    self.numAllSlots= WoWTools_LabelMixin:Create(self, {color={r=0.65,g=0.65,b=0.65}, justifyH='CENTER', size=10})
                    self.numAllSlots:SetPoint('BOTTOM',0 ,4)
                    self.numAllSlots:SetAlpha(0.5)
                end
            end

            if self.numFreeSlots then
                self.numFreeSlots:SetText(numFreeSlots or '')
                self.numAllSlots:SetText((numAllSlots and numAllSlots>0) and numAllSlots or '')
            end

            set_Slot_Num_Label(self, InventSlot_To_ContainerSlot[slot], isbagEquipped)--栏位
        end
    end)

    Init=function()end
end














function WoWTools_PaperDollMixin:Init_Item_PoaperDll()
    Init()
end



function WoWTools_PaperDollMixin:Set_Item_Tips(...)
    set_Item_Tips(...)
end
function WoWTools_PaperDollMixin:Set_Slot_Num_Label(...)
    set_Slot_Num_Label(...)
end