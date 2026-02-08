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
















--增加 [潘达利亚工程学: 地精滑翔器] recipeID 126392
--[诺森德工程学: 氮气推进器] ricipeID 55016
local function set_Engineering(btn, slot, link, use, isPaperDollItemSlot)
    if not (
            (slot==15 and C_TradeSkillUI.IsRecipeProfessionLearned(126392))
            or (slot==6 and C_TradeSkillUI.IsRecipeProfessionLearned(55016))
        )
        or use
        or not link
        or not isPaperDollItemSlot
    then
        if btn.engineering  then
            btn.engineering:SetShown(false)
        end
        return
    end

    if not btn.engineering then
        local h=btn:GetHeight()/3
        btn.engineering=CreateFrame('Button', nil, btn, 'WoWToolsButtonTemplate') --WoWTools_ButtonMixin:Cbtn(btn, {size=h, texture=136243})
        btn.engineering:SetSize(h, h)
        btn.engineering:SetNormalTexture(136243)
        if WoWTools_PaperDollMixin:Is_Left_Slot(slot) then
            btn.engineering:SetPoint('TOPLEFT', btn, 'TOPRIGHT', 8, 0)
        else
            btn.engineering:SetPoint('TOPRIGHT', btn, 'TOPLEFT', -8, 0)
        end
        btn.engineering.spell= slot==15 and 126392 or 55016

        btn.engineering:SetScript('OnMouseDown' ,function(frame, d)
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
        btn.engineering:SetScript('OnEnter' ,function(frame)
                GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(frame.spell)
                GameTooltip:AddLine(' ')
                GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '商业技能' or TRADESKILLS), WoWTools_DataMixin.Icon.right)
                --GameTooltip:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需求' or NEED), (WoWTools_DataMixin.onlyChinese and '打开一次' or CHALLENGES_LASTRUN_TIME)..'('..(WoWTools_DataMixin.onlyChinese and '打开' or UNWRAP)..')')
                GameTooltip:Show()
        end)
        btn.engineering:SetScript('OnLeave',GameTooltip_Hide)
    end
    btn.engineering:SetShown(true)
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

local function set_no_Enchant(btn, slot, find, isPaperDollItemSlot)--附魔，按钮
    if not subClassToSlot[slot] then
        return
    end

    local tab
    if find and isPaperDollItemSlot then
        tab=get_no_Enchant_Bag(slot)--取得，物品，bag, slot
        if tab and not btn.noEnchant then
            local h=btn:GetHeight()/3
            btn.noEnchant= WoWTools_ButtonMixin:Cbtn(btn, {size=h, isSecure=true})
            btn.noEnchant:SetAttribute("type", "item")
            btn.noEnchant.slot= slot
            if WoWTools_PaperDollMixin:Is_Left_Slot(slot) then
                btn.noEnchant:SetPoint('LEFT', btn, 'RIGHT', 8, 0)
            else
                btn.noEnchant:SetPoint('RIGHT', btn, 'LEFT', -8, 0)
            end
            btn.noEnchant:SetScript('OnMouseDown', function()
                if MerchantFrame:IsVisible() then
                    MerchantFrame:SetShown(false)
                end
                if SendMailFrame:IsShown() then
                    MailFrame:SetShown(false)
                end
            end)
            btn.noEnchant:SetScript('OnLeave',function(self)
                GameTooltip:Hide()
                self:SetAlpha(1)
                WoWTools_BagMixin:Find()
            end)
            btn.noEnchant:SetScript('OnEnter' ,function(self)
                if self.tab then
                    local bagID= self.tab.bag
                    local slotID= self.tab.slot
                    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:SetBagItem(bagID, slotID)
                    if not self:CanChangeAttribute() then
                        GameTooltip:AddLine(' ')
                        GameTooltip:AddLine('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '战斗中' or HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT))
                    end
                    GameTooltip:Show()
                    WoWTools_BagMixin:Find(true, {bag={bag=bagID, slot=slotID}})
                end
                self:SetAlpha(0.3)
            end)

            btn.noEnchant:SetScript('OnShow', function(self)
                self:RegisterEvent('BAG_UPDATE_DELAYED')
            end)
            btn.noEnchant:SetScript('OnHide', function(self)
                self:UnregisterEvent('BAG_UPDATE_DELAYED')
            end)
            btn.noEnchant:RegisterEvent('BAG_UPDATE_DELAYED')
            btn.noEnchant:SetScript('OnEvent', function(self)
                if self:CanChangeAttribute() then
                    local tab2=get_no_Enchant_Bag(self.slot)--取得，物品，bag, slot
                    if tab2 then
                        self:SetAttribute("item", tab2.bag..' '..tab2.slot)
                    end
                    self.tab= tab2
                end
            end)

            local texture= btn.noEnchant:CreateTexture(nil, 'OVERLAY')
            texture:SetAllPoints()
            texture:SetAtlas('bags-icon-addslots')
        end
    end

    if btn.noEnchant then
        btn.noEnchant.tab=tab
        if not InCombatLockdown() then
            btn.noEnchant:SetAttribute("item", tab and tab.bag..' '..tab.slot or nil)
            btn.noEnchant:SetShown(tab and true or false)
        end
    end
end




















--宝石信息
local function Set_Item_Gem(self, link, isLeftSlot)

    if not PlayerIsTimerunning() then
        if link then--宝石
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
                    icon = select(5, C_Item.GetItemInfoInstant(gemLink))
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

    elseif self.SocketDisplay:IsShown() and link then
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
                    local quality= C_Item.GetItemQualityByID(gemID)
                    atlas= WoWTools_DataMixin.Icon[quality]
                end
                frame.Slot:SetAtlas(atlas or 'character-emptysocket')
            end
        end
    end
end
















--耐久度
local function Set_Item_Durability(btn, link, slot, isPaperDollItemSlot, isLeftSlot)
    local du, min, max
    if link then
        min, max=GetInventoryItemDurability(slot)
        if min and max and max>0 then
            du=min/max*100
        end
    end
    if not btn.du and du and isPaperDollItemSlot then
        btn.du= CreateFrame('StatusBar', nil, btn)
        local wq= slot==16 or slot==17 or slot==18--武器
        if wq then
            btn.du:SetPoint('TOP', btn, 'BOTTOM')
        elseif isLeftSlot then
            btn.du:SetPoint('RIGHT', btn, 'LEFT', -1.5,0)
        else
            btn.du:SetPoint('LEFT', btn, 'RIGHT', 2.5,0)
        end
        if wq then
            btn.du:SetOrientation('HORIZONTAL')
            btn.du:SetSize(btn:GetHeight(),4)--h37
        else
            btn.du:SetOrientation("VERTICAL")
            btn.du:SetSize(4, btn:GetHeight())--h37
        end
        btn.du:SetStatusBarTexture('UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health-Status')
        btn.du:EnableMouse(true)
        btn.du:SetMinMaxValues(0, 100)
        btn.du:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(self2. du and 1 or 0) end)
        btn.du:SetScript('OnEnter', function(self2)
            if self2.du then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddDoubleLine(format(WoWTools_DataMixin.onlyChinese and '耐久度 %d / %d' or DURABILITY_TEMPLATE, min,  max), format('%i%%', self2.du))
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
        btn.du.texture= btn.du:CreateTexture(nil, "BACKGROUND")
        btn.du.texture:SetAllPoints()
        btn.du.texture:SetColorTexture(1,0,0)
        btn.du.texture:SetAlpha(0.3)
    end
    if btn.du then
        if du then
            if du and du >70 then
                btn.du:SetStatusBarColor(0,1,0)
            elseif du and du >30 then
                btn.du:SetStatusBarColor(1,1,0)
            else
                btn.du:SetStatusBarColor(1,0,0)
            end
        end
        btn.du:SetValue(du or 0)
        btn.du.du=du
        btn.du.min= min
        btn.du.max= max
        btn.du:SetAlpha(du and 1 or 0)
    end
end





















local function set_Item_Tips(btn, slot, link, isPaperDollItemSlot)--附魔, 使用, 属性
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

    if enchant and not btn.enchant then--附魔
        local h=btn:GetHeight()/3
        btn.enchant= btn:CreateTexture()
        btn.enchant:SetSize(h,h)
        if isLeftSlot then
            btn.enchant:SetPoint('LEFT', btn, 'RIGHT', 8, 0)
        else
            btn.enchant:SetPoint('RIGHT', btn, 'LEFT', -8, 0)
        end
        btn.enchant:SetTexture(463531)
        btn.enchant:EnableMouse(true)
        btn.enchant:SetScript('OnLeave',function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        btn.enchant:SetScript('OnEnter' ,function(self2)
            if self2.tips then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self2.tips)
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
    end
    if btn.enchant then
        btn.enchant.tips= enchant
        btn.enchant:SetShown(enchant and true or false)
    end

    set_no_Enchant(btn, slot, not enchant and link, isPaperDollItemSlot)--附魔，按钮

    use=  link and select(2, C_Item.GetItemSpell(link))--物品是否可使用
    if use and not btn.use  then
        local h=btn:GetHeight()/3
        btn.use= btn:CreateTexture()
        btn.use:SetSize(h,h)
        if isLeftSlot then
            btn.use:SetPoint('TOPLEFT', btn, 'TOPRIGHT', 8, 0)
        else
            btn.use:SetPoint('TOPRIGHT', btn, 'TOPLEFT', -8, 0)
        end
        btn.use:SetAtlas('soulbinds_tree_conduit_icon_utility')
        btn.use:EnableMouse(true)

        btn.use:SetScript('OnLeave',function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        btn.use:SetScript('OnEnter' ,function(self2)
            if self2.spellID then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:SetSpellByID(self2.spellID)
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
    end
    if btn.use then
        btn.use.spellID= use
        btn.use:SetShown(use and true or false)
    end
    set_Engineering(btn, slot, link, use, isPaperDollItemSlot)--地精滑翔,氮气推进器

    if pvpItem and not btn.pvpItem then--提示PvP装备
        local h=btn:GetHeight()/3
        btn.pvpItem=btn:CreateTexture(nil,'OVERLAY',nil,7)
        btn.pvpItem:SetSize(h,h)
        if isLeftSlot then
            btn.pvpItem:SetPoint('LEFT', btn, 'RIGHT', -2.5,0)
        else
            btn.pvpItem:SetPoint('RIGHT', btn, 'LEFT', 2.5,0)
        end
        btn.pvpItem:SetAtlas('pvptalents-warmode-swords')
        btn.pvpItem:EnableMouse(true)
        btn.pvpItem:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        btn.pvpItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and "装备：在竞技场和战场中将物品等级提高至%d。" or PVP_ITEM_LEVEL_TOOLTIP):format(self2.tips))
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
    end
    if btn.pvpItem then
        btn.pvpItem.tips= pvpItem
        btn.pvpItem:SetShown(pvpItem and true or false)
    end

    if upgradeItem and not btn.upgradeItem then--"升级：%s/%s"
        if isLeftSlot then
            btn.upgradeItem= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}, mouse=true})
            btn.upgradeItem:SetPoint('BOTTOMLEFT', btn, 'BOTTOMRIGHT',1,0)
        else
            btn.upgradeItem= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
            btn.upgradeItem:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMLEFT',2,0)
        end
        btn.upgradeItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
        btn.upgradeItem:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    end
    if btn.upgradeItem then
        btn.upgradeItem.tips=upgradeItem
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
        btn.upgradeItem:SetText(upText or '')
    end

    local upgradeItemText
    local upText= upgradeItem and upgradeItem:match('(.-)%d+/%d+')--"升级：%s %s/%s"
    if upText then
        upgradeItemText= strlower(WoWTools_TextMixin:sub(upText,1,3, true))
        if not btn.upgradeItemText then
            local h= btn:GetHeight()/3
            if isLeftSlot then
                btn.upgradeItemText= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}, mouse=true})
                btn.upgradeItemText:SetPoint('LEFT', btn, 'RIGHT',h+8,0)
            else
                btn.upgradeItemText= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
                btn.upgradeItemText:SetPoint('RIGHT', btn, 'LEFT',-h-8,0)
            end
            btn.upgradeItemText:SetScript('OnEnter', function(self2)
                if self2.tips then
                    GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine((WoWTools_DataMixin.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                    GameTooltip:Show()
                    self2:SetAlpha(0.3)
                end
            end)
            btn.upgradeItemText:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
        end
        btn.upgradeItemText.tips= upgradeItem
        local quality = GetInventoryItemQuality(unit, slot)--颜色
        upgradeItemText= WoWTools_ItemMixin:GetColor(quality, {text=upgradeItemText})
    end
    if  btn.upgradeItemText then--"升级：%s %s/%s"
        btn.upgradeItemText:SetText(upgradeItemText or '')
    end




    if createItem and not btn.createItem then--"|cff00ff00<由%s制造>|r" ITEM_CREATED_BY 
        if isLeftSlot then
            btn.createItem= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}, mouse=true})
            btn.createItem:SetPoint('LEFT', btn, 'RIGHT',1,0)
        else
            btn.createItem= WoWTools_LabelMixin:Create(btn, {color={r=0,g=1,b=0}, justifyH='RIGHT', mouse=true})
            btn.createItem:SetPoint('RIGHT', btn, 'LEFT',2,0)
        end
        btn.createItem:SetScript('OnEnter', function(self2)
            if self2.tips then
                GameTooltip:SetOwner(self2, "ANCHOR_LEFT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(format(WoWTools_DataMixin.onlyChinese and '|cff00ff00<由%s制造>|r' or ITEM_CREATED_BY, self2.tips))
                GameTooltip:Show()
                self2:SetAlpha(0.3)
            end
        end)
        btn.createItem:SetScript('OnLeave', function(self2) GameTooltip:Hide() self2:SetAlpha(1) end)
    end
    if btn.createItem then
        btn.createItem.tips=createItem
        btn.createItem:SetText(createItem and '|A:communities-icon-notification:10:10|a' or '')
    end

--宝石信息
    Set_Item_Gem(btn, link, isLeftSlot)
--耐久度
    Set_Item_Durability(btn, link, slot, isPaperDollItemSlot, isLeftSlot)
end













local function set_Slot_Num_Label(frame, slot, isEquipped)--栏位
    local show= not Save().hide
    if not frame.slotText and show and not isEquipped then
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
        frame.slotText:SetShown(show and not isEquipped)
    end
end










local function Init()
--装备属性
    WoWTools_DataMixin:Hook('PaperDollItemSlotButton_Update',  function(self)--PaperDollFrame.lua
        local slot= self:GetID()

        if PaperDoll_IsEquippedSlot(slot) then
            local show= not Save().hide
            local textureName = GetInventoryItemTexture("player", slot)
            local hasItem = textureName ~= nil and show
            local link= hasItem and GetInventoryItemLink('player', slot) or nil--装等                
            if slot~=4 and slot~=19 then
                set_Item_Tips(self, slot, link, true)
                WoWTools_ItemMixin:SetItemStats(self, link, {point=self.icon})
                --[[WoWTools_PaperDollMixin:Settings_Tab3()
                WoWTools_PaperDollMixin:Settings_Tab1()]]
            end
            set_Slot_Num_Label(self, slot, link and true or nil)--栏位
            self.icon:SetAlpha((hasItem or not show) and 1 or 0.3)--图标透明度

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