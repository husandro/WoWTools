local id, e = ...
local addName= CHARACTER
local Save={
    --EquipmentH=true, --装备管理, true横, false坚
    equipment= e.Player.husandro,--装备管理, 开关,
    --Equipment=nil--装备管理, 位置保存
    equipmentFrameScale=1.1--装备管理, 缩放
}
local panel = CreateFrame("Frame", nil, PaperDollFrame)

local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr= ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','.-(%%d%+/%%d%+)')-- "升级：%s/%s"
local itemLevelStr= ITEM_LEVEL:gsub('%%d', '%(%%d%+%)')--"物品等级：%d"
local function Slot(slot)--左边插曹
    return slot==1 or slot==2 or slot==3 or slot==15 or slot==5 or slot==4 or slot==19 or slot==9 or slot==17 or slot==18
end

local InventSlot_To_ContainerSlot={}--背包数
for i=1, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
    local bag=C_Container.ContainerIDToInventoryID(i)
    if bag then
        InventSlot_To_ContainerSlot[bag]=i
    end
end

local function Du(self, slot, link) --耐久度    
    local du
    if link then
        local min, max=GetInventoryItemDurability(slot)
        if min and max and max>0 then
            du=min/max*100
        end
    end
    if not self.du then
        self.du= CreateFrame('StatusBar', nil, self)
        local wq= slot==16 or slot==17 or slot==18--武器
        if wq then
            self.du:SetPoint('TOP', self, 'BOTTOM')
        elseif Slot(slot) then
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
        self.du:SetStatusBarTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_Smooth_Border')
        self.du:EnableMouse(true)
        self.du:SetMinMaxValues(0, 100)
        self.du:SetScript('OnEnter', function(self2)
            if self2.du then
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine((e.onlyChinese and '耐久度' or DURABILITY),format('%.1f%%', self2.du))
                e.tips:Show()
            end
        end)
        self.du:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    if du and du >70 then
        self.du:SetStatusBarColor(0,1,0)
    elseif du and du >30 then
        self.du:SetStatusBarColor(1,1,0)
    else
        self.du:SetStatusBarColor(1,0,0)
    end
    self.du:SetValue(du or 0)
    self.du.du=du

    if not self.slotText then
        self.slotText=e.Cstr(self.du, {size=8})
        self.slotText:SetAlpha(0.5)
        self.slotText:EnableMouse(true)
        self.slotText:SetScript('OnEnter', function(self2)
            e.tips:SetOwner(self2, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine((e.onlyChinese and '栏位' or TRADESKILL_FILTER_SLOTS), self2.slot)
            e.tips:Show()
        end)
        self.slotText:SetScript('OnLeave', function() e.tips:Hide() end)
        if self.du then
            self.slotText:SetPoint('CENTER', self.du)
        else
            local wq= slot==16 or slot==17 or slot==18--武器
            if wq then
                self.slotText:SetPoint('TOP', self.du or self, 'BOTTOM')
            elseif Slot(slot) then
                self.slotText:SetPoint('RIGHT', self.du or self, 'LEFT')
            else
                self.slotText:SetPoint('LEFT', self.du or self, 'RIGHT')
            end
        end
    end
    self.slotText.slot= slot
    self.slotText:SetText(slot or '')
end

local function LvTo()--总装等
    if not PaperDollSidebarTab1 then
        return
    end
    local avgItemLevel,_, avgItemLevelPvp = GetAverageItemLevel()
    if not PaperDollSidebarTab1.itemLevelText then--PVE
        PaperDollSidebarTab1.itemLevelText=e.Cstr(PaperDollSidebarTab1, {justifyH='CENTER'})
        PaperDollSidebarTab1.itemLevelText:SetPoint('BOTTOM')
        PaperDollSidebarTab1.itemLevelText:EnableMouse(true)
        PaperDollSidebarTab1.itemLevelText:SetScript('OnLeave', function() e.tips:Hide() end)
        PaperDollSidebarTab1.itemLevelText:SetScript('OnMouseDown', function(self)
            securecallfunction(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)--PaperDollFrame.lua
        end)
        PaperDollSidebarTab1.itemLevelText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
            e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
            e.tips:AddLine(' ')
            e.tips:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '物品等级：%d' or CHARACTER_LINK_ITEM_LEVEL_TOOLTIP, self.avgItemLevel or '0'))
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
    end
    if avgItemLevel and avgItemLevel>0 then
        PaperDollSidebarTab1.itemLevelText:SetFormattedText('%i', avgItemLevel)
    else
        PaperDollSidebarTab1.itemLevelText:SetText('')
    end
    PaperDollSidebarTab1.itemLevelText.avgItemLevel= avgItemLevel


    if avgItemLevel~= avgItemLevelPvp and avgItemLevelPvp and not PaperDollSidebarTab1.itemLevelPvPText then--PVP
        PaperDollSidebarTab1.itemLevelPvPText=e.Cstr(PaperDollSidebarTab1, {justifyH='CENTER'})
        PaperDollSidebarTab1.itemLevelPvPText:SetPoint('TOP')
        PaperDollSidebarTab1.itemLevelPvPText:SetScript('OnMouseDown', function(self)
            securecallfunction(PaperDollFrame_SetSidebar, PaperDollSidebarTab1, 1)--PaperDollFrame.lua
        end)
        PaperDollSidebarTab1.itemLevelPvPText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip)
            e.tips:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
            e.tips:AddLine(' ')
            e.tips:AddLine('|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and 'PvP物品等级 %d' or ITEM_UPGRADE_PVP_ITEM_LEVEL_STAT_FORMAT, self.avgItemLevel or '0'))
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
    end

    if PaperDollSidebarTab1.itemLevelPvPText then
        if avgItemLevel~= avgItemLevelPvp and avgItemLevelPvp then
            PaperDollSidebarTab1.itemLevelPvPText:SetFormattedText('%i', avgItemLevelPvp)
            PaperDollSidebarTab1.itemLevelPvPText:SetShown(true)
        else
            PaperDollSidebarTab1.itemLevelText:SetShown(false)
        end
    end
end

local function Gem(self, slot, link)--宝石
    if not slot or slot>17 or slot<1 or slot==4 then
        return
    end

    local leftSlot= Slot(slot)--左边插曹
    local x= leftSlot and 8 or -8
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
                    end
                end)
                self['gem'..n]:SetScript('OnLeave',function() e.tips:Hide() end)
            else
                self['gem'..n]:ClearAllPoints()
            end
            if leftSlot then--左边插曹
                self['gem'..n]:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', x, 0)
            else
                self['gem'..n]:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', x, 0)
            end
        end
        if self['gem'..n] then
            self['gem'..n].gemLink= gemLink
            self['gem'..n]:SetTexture(gemLink and C_Item.GetItemIconByID(gemLink) or 0)
            self['gem'..n]:SetShown(gemLink and true or false)
        end

        x= leftSlot and x+ 12.3 or x- 12.3--左边插曹
    end
end

local function recipeLearned(recipeSpellID)--是否已学配方
    local info= C_TradeSkillUI.GetRecipeInfo(recipeSpellID)
    return info and info.learned
end
local function Engineering(self, slot, use)--增加 [潘达利亚工程学: 地精滑翔器][诺森德工程学: 氮气推进器]
    if not ((slot==15 and recipeLearned(126392)) or (slot==6 and recipeLearned(55016))) or use then
        if self.engineering  then
            self.engineering:SetShown(false)
        end
        return
    end

    if not self.engineering then
        local h=self:GetHeight()/3
        self.engineering=e.Cbtn(self, {icon='hide',size={h,h}})
        self.engineering:SetNormalTexture(136243)
        if Slot(slot) then
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
                e.tips:AddDoubleLine('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需求' or NEED), e.onlyChinese and '打开一次' or CHALLENGES_LASTRUN_TIME..'('..UNWRAP..')')
                e.tips:Show()
        end)
        self.engineering:SetScript("OnMouseUp", function()
            local n=GetItemCount(90146, true)
                if n==0 then
                    local item=select(2, GetItemInfo(90146)) or SPELL_REAGENTS_OPTIONAL
                    print(item..' '..RED_FONT_COLOR_CODE..NONE..'|r')
                end
        end)
        self.engineering:SetScript('OnLeave',function() e.tips:Hide() end)
    end
    self.engineering:SetShown(true)
end

local function Enchant(self, slot, link)--附魔, 使用, 属性
    local enchant, use, pvpItem, upgradeItem
    if link then
        local dateInfo= e.GetTooltipData({hyperLink=link, text={enchantStr, pvpItemStr, upgradeStr}, onlyText=true})--物品提示，信息
        enchant, use, pvpItem, upgradeItem= dateInfo.text[enchantStr], dateInfo.red, dateInfo.text[pvpItemStr],  dateInfo.text[upgradeStr]
        if enchant and not self.enchant then--附魔
            local h=self:GetHeight()/3
            self.enchant=self:CreateTexture()
            self.enchant:SetSize(h,h)
            if Slot(slot) then
                self.enchant:SetPoint('LEFT', self, 'RIGHT', 8, 0)
            else
                self.enchant:SetPoint('RIGHT', self, 'LEFT', -8, 0)
            end
            self.enchant:SetTexture(463531)
            self.enchant:EnableMouse(true)
            self.enchant:SetScript('OnEnter' ,function(self2)
                if self2.tips then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine(self2.tips)
                    e.tips:Show()
                end
            end)
            self.enchant:SetScript('OnLeave',function() e.tips:Hide() end)
        end

        use= select(2, GetItemSpell(link))--物品是否可使用
        if use and not self.use then
            local h=self:GetHeight()/3
            self.use=self:CreateTexture()
            self.use:SetSize(h,h)
            if Slot(slot) then
                self.use:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)
            else
                self.use:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
            end
            self.use:SetAtlas('soulbinds_tree_conduit_icon_utility')
            self.use:EnableMouse(true)
            self.use:SetScript('OnEnter' ,function(self2)
                if self2.spellID then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:SetSpellByID(self2.spellID)
                    e.tips:Show()
                end
            end)
            self.use:SetScript('OnLeave',function() e.tips:Hide() end)
        end

        Engineering(self, slot, use)--地精滑翔,氮气推进器

        if pvpItem and not self.pvpItem then--提示PvP装备
            local h=self:GetHeight()/3
            self.pvpItem=self:CreateTexture(nil,'OVERLAY',nil,7)
            self.pvpItem:SetSize(h,h)
            if Slot(slot) then
                self.pvpItem:SetPoint('LEFT', self, 'RIGHT', -2.5,0)
            else
                self.pvpItem:SetPoint('RIGHT', self, 'LEFT', 2.5,0)
            end
            self.pvpItem:SetAtlas('pvptalents-warmode-swords')
            self.pvpItem:EnableMouse(true)
            self.pvpItem:SetScript('OnEnter', function(self2)
                if self2.tips then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine((e.onlyChinese and "装备：在竞技场和战场中将物品等级提高至%d。" or PVP_ITEM_LEVEL_TOOLTIP):format(self2.tips))
                    e.tips:Show()
                end
            end)
            self.pvpItem:SetScript('OnLeave', function() e.tips:Hide() end)
        end

        if upgradeItem and not self.upgradeItem then--"升级：%s/%s"
            if Slot(slot) then
                self.upgradeItem= e.Cstr(self, {color={r=0,g=1,b=0}})
                self.upgradeItem:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT',1,0)
            else
                self.upgradeItem= e.Cstr(self, {color={r=0,g=1,b=0}, justifyH='RIGHT'})
                self.upgradeItem:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT',2,0)
            end
            self.upgradeItem:EnableMouse(true)
            self.upgradeItem:SetScript('OnEnter', function(self2)
                if self2.tips then
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
                    e.tips:AddLine((e.onlyChinese and "升级：" or ITEM_UPGRADE_NEXT_UPGRADE)..self2.tips)
                    e.tips:Show()
                end
            end)
            self.upgradeItem:SetScript('OnLeave', function() e.tips:Hide() end)
        end
    end

    if self.enchant then
        self.enchant.tips= enchant
        self.enchant:SetShown(enchant and true or false)
    end
    if self.use then
        self.use.spellID= use
        self.use:SetShown(use and true or false)
    end
    if self.pvpItem then
        self.pvpItem.tips= pvpItem
        self.pvpItem:SetShown(pvpItem and true or false)
    end
    if self.upgradeItem then--文字
        self.upgradeItem.tips=upgradeItem
        if upgradeItem then
            local min, max= upgradeItem:match('(%d+)/(%d+)')
            if min and max then
                if min==max then
                    upgradeItem= "|A:VignetteKill:0:0|a"
                else
                    min, max= tonumber(min), tonumber(max)
                    upgradeItem= max-min
                end
            end
        end
        self.upgradeItem:SetText(upgradeItem or '')
    end
end

local function Set(self, link)--套装
    local set
    if link then
        set=select(16 , GetItemInfo(link))
        if set then
            if set and not self.set then
                self.set=self:CreateTexture()
                self.set:SetAllPoints(self)
                self.set:SetAtlas(e.Icon.pushed)
            end
        end
    end
    if self.set then self.set:SetShown(set) end
end

local function Title()--头衔数量
    if not PaperDollSidebarTab2 or not PAPERDOLL_SIDEBARS[2].IsActive() then
        return
    end
    local nu
    local to=GetKnownTitles() or {}
    nu= #to-1
    nu= nu>0 and nu or nil
    if not PaperDollSidebarTab2.titleNumeri then
        PaperDollSidebarTab2.titleNumeri=e.Cstr(PaperDollSidebarTab2, {justifyH='CENTER'})
        PaperDollSidebarTab2.titleNumeri:SetPoint('BOTTOM')
        PaperDollSidebarTab2.titleNumeri:EnableMouse(true)
        PaperDollSidebarTab2.titleNumeri:SetScript('OnLeave', function() e.tips:Hide() end)
        PaperDollSidebarTab2.titleNumeri:SetScript('OnMouseDown', function(self)
            securecallfunction(PaperDollFrame_SetSidebar, PaperDollSidebarTab2, 2)--PaperDollFrame.lua
        end)
        PaperDollSidebarTab2.titleNumeri:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(format(e.onlyChinese and '头衔：%s' or RENOWN_REWARD_TITLE_NAME_FORMAT, self.num or ''), e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL, 0,1,0, 0,1,0)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
    end
    PaperDollSidebarTab2.titleNumeri.num= nu
    PaperDollSidebarTab2.titleNumeri:SetText(nu or '')
end


--####################
--装备, 标签, 内容,提示
--####################
local function set_set_PaperDollSidebarTab3_Text_Tips(self)
    self:EnableMouse(true)
    self:SetScript('OnLeave', function() e.tips:Hide() end)
    self:SetScript('OnMouseDown', function(self2)
        securecallfunction(PaperDollFrame_SetSidebar, PaperDollSidebarTab3, 3)--PaperDollFrame.lua
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
    end)
end
local function set_PaperDollSidebarTab3_Text()--标签, 内容,提示
    if not PaperDollSidebarTab3 then
        return
    end
    local name, icon, specIcon,nu
    local setIDs=C_EquipmentSet.GetEquipmentSetIDs()
    local specName, setID
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

    if not PaperDollSidebarTab3.set and name then--名称
        PaperDollSidebarTab3.set=e.Cstr(PaperDollSidebarTab3, {justifyH='CENTER'})
        PaperDollSidebarTab3.set:SetPoint('BOTTOM', 2, 0)
        set_set_PaperDollSidebarTab3_Text_Tips(PaperDollSidebarTab3.set)
        PaperDollSidebarTab3.set.tooltip= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '名称' or NAME)..'|r'
    end
    if PaperDollSidebarTab3.set then
        PaperDollSidebarTab3.set:SetText(name or '')
        PaperDollSidebarTab3.set:SetShown(name and true or false)
        PaperDollSidebarTab3.set.tooltip2= name
        PaperDollSidebarTab3.set.setID= setID
    end

    if not PaperDollSidebarTab3.tex and icon then--套装图标图标
        PaperDollSidebarTab3.tex=PaperDollSidebarTab3:CreateTexture(nil, 'OVERLAY')
        PaperDollSidebarTab3.tex:SetPoint('CENTER',1,-2)
        local w, h=PaperDollSidebarTab3:GetSize()
        PaperDollSidebarTab3.tex:SetSize(w-4, h-4)
    end
    if PaperDollSidebarTab3.tex then
        PaperDollSidebarTab3.tex:SetTexture(icon or 0)
        PaperDollSidebarTab3.tex:SetShown(icon and true or false)
    end

    if not PaperDollSidebarTab3.spec and specIcon then--天赋图标
        PaperDollSidebarTab3.spec=PaperDollSidebarTab3:CreateTexture(nil, 'OVERLAY')
        PaperDollSidebarTab3.spec:SetPoint('BOTTOMLEFT', PaperDollSidebarTab3, 'BOTTOMRIGHT')
        local h, w= PaperDollSidebarTab3:GetSize()
        PaperDollSidebarTab3.spec:SetSize(h/3+2, w/3+2)
        set_set_PaperDollSidebarTab3_Text_Tips(PaperDollSidebarTab3.spec)
        PaperDollSidebarTab3.spec.tooltip= '|cnGREEN_FONT_COLOR:'..format(e.onlyChinese and '%s专精' or PROFESSIONS_SPECIALIZATIONS_PAGE_NAME, e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER)..'|r'
    end
    if PaperDollSidebarTab3.spec then
        PaperDollSidebarTab3.spec:SetTexture(specIcon or 0)
        PaperDollSidebarTab3.spec:SetShown(specIcon and true or false)
        PaperDollSidebarTab3.spec.tooltip2= (specIcon and "|T"..specIcon..':0|t' or '')..(specName or '' )
        PaperDollSidebarTab3.spec.setID= setID
    end

    if not PaperDollSidebarTab3.nu and nu then--套装数量
        PaperDollSidebarTab3.nu=e.Cstr(PaperDollSidebarTab3, {justifyH='RIGHT'})
        PaperDollSidebarTab3.nu:SetPoint('LEFT', PaperDollSidebarTab3, 'RIGHT',0, 4)
        PaperDollSidebarTab3.nu.tooltip= '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '装备' or EQUIPSET_EQUIP)
        set_set_PaperDollSidebarTab3_Text_Tips(PaperDollSidebarTab3.nu)
    end
    if PaperDollSidebarTab3.nu then
        PaperDollSidebarTab3.nu:SetText(nu or '')
        PaperDollSidebarTab3.nu:SetShown(nu and true or false)
        PaperDollSidebarTab3.nu.tooltip2= (e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)..' '..(nu or '')
        PaperDollSidebarTab3.nu.setID= setID
    end
end

--#######
--装备管理
--#######
local function set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框
    panel.equipmentButton:SetNormalAtlas(Save.equipment and 'auctionhouse-icon-favorite' or e.Icon.icon)
    panel.equipmentButton:SetAlpha(Save.equipment and 0.2 or 1)
end
local function EquipmentStr(self)--套装已装备数量
    local setID=self.setID
    local nu
    if setID then
        if not self.nu then
            self.nu=e.Cstr(self)
            self.nu:SetJustifyH('RIGHT')
            self.nu:SetPoint('BOTTOMLEFT', self.text, 'BOTTOMLEFT')
        end
        local  numItems, numEquipped= select(5, C_EquipmentSet.GetEquipmentSetInfo(setID))
        if numItems and numEquipped then
            nu=numEquipped..'/'..numItems
        end
        self.nu:SetText(nu)
    end

    if self.nu then self.nu:SetShown(nu) end
end

local function set_equipmentButton_Size()--设置大小
    if not Save.EquipmentH then
        panel.equipmentButton.btn:SetSize(20,10)
    else
        panel.equipmentButton.btn:SetSize(10,20)
    end
end

local function set_equipmentButton_bnt_button_Point(self, index)--添加装备管理框,设置位置
    local btn= index==1 and panel.equipmentButton.btn or panel.equipmentButton.btn.buttons[index-1]
    if Save.EquipmentH then
        self:SetPoint('LEFT', btn, 'RIGHT')
    else
        self:SetPoint('TOP', btn, 'BOTTOM')
    end
end
local function set_equipmentFrame_Scale()--缩放
    panel.equipmentButton.btn:SetScale(Save.equipmentFrameScale or 1)
end
local function set_inti_Equipment_Frame()--添加装备管理框
    if not Save.equipment or not PAPERDOLL_SIDEBARS[3].IsActive() then
        if panel.equipmentButton.btn then
            panel.equipmentButton.btn:SetShown(false)
        end
        return
    end

    if not panel.equipmentButton.btn then
        panel.equipmentButton.btn=e.Cbtn(UIParent, {icon='hide'})--添加移动按钮
        set_equipmentButton_Size()--设置大小
        if Save.Equipment then
            panel.equipmentButton.btn:SetPoint(Save.Equipment[1], UIParent, Save.Equipment[3], Save.Equipment[4], Save.Equipment[5])
        elseif PlayerFrame.PlayerFrameContainer.FrameTexture:IsShown() then
            panel.equipmentButton.btn:SetPoint('TOPLEFT', PlayerFrame.PlayerFrameContainer.FrameTexture, 'TOPRIGHT',-4,-3)
        else
            panel.equipmentButton.btn:SetPoint('BOTTOMRIGHT', PaperDollItemsFrame, 'TOPRIGHT')
        end
        panel.equipmentButton.btn:RegisterForDrag("RightButton")
        panel.equipmentButton.btn:SetClampedToScreen(true)
        panel.equipmentButton.btn:SetMovable(true)
        panel.equipmentButton.btn:SetScript("OnDragStart", function(self)
            if not IsModifierKeyDown() then
                self:StartMoving()
            end
        end)
        panel.equipmentButton.btn:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.Equipment={self:GetPoint(1)}
                Save.Equipment[2]=nil
        end)
        panel.equipmentButton.btn:SetScript("OnMouseUp", function() ResetCursor() end)
        panel.equipmentButton.btn:SetScript("OnMouseDown", function(self,d)
            local key=IsModifierKeyDown()
            local alt=IsAltKeyDown()
            if d=='RightButton' and not key then--移动图标
                SetCursor('UI_MOVE_CURSOR')

            elseif d=='LeftButton' and alt then--图标横,或 竖
                Save.EquipmentH= not Save.EquipmentH and true or nil
                for index, btn in pairs(self.buttons) do
                    btn:ClearAllPoints()
                    set_equipmentButton_Size()--设置大小
                    set_equipmentButton_bnt_button_Point(btn, index)--设置位置
                end

            elseif d=='LeftButton' and not key then--打开/关闭角色界面
                ToggleCharacter("PaperDollFrame")
            end
        end)
        panel.equipmentButton.btn:SetScript('OnMouseWheel',function(self, d)--放大
                local n=Save.equipmentFrameScale or 1
                if d==1 then
                    n=n+0.1
                elseif d==-1 then
                    n=n-0.1
                end
                n= n<0.8 and 0.8 or n>3 and 3 or n
                Save.equipmentFrameScale=n
                set_equipmentFrame_Scale()--缩放
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, GREEN_FONT_COLOR_CODE..n)
        end)
        panel.equipmentButton.btn:SetScript("OnEnter", function (self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, e.onlyChinese and '装备管理'or EQUIPMENT_MANAGER)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine( Save.EquipmentH and (e.onlyChinese and '向右' or BINDING_NAME_STRAFERIGHT) or (e.onlyChinese and '向下' or BINDING_NAME_PITCHDOWN), 'Alt + '..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE), (Save.equipmentFrameScale or 1)..e.Icon.mid)
            e.tips:Show()
        end)
        panel.equipmentButton.btn:SetScript("OnLeave", function(self)
            ResetCursor()
            e.tips:Hide()
        end)
        panel.equipmentButton.btn.buttons={}--添加装备管理按钮
        set_equipmentFrame_Scale()--缩放
    end
    panel.equipmentButton.btn:SetShown(true)

    local setIDs= C_EquipmentSet.GetEquipmentSetIDs() or {}
    securecallfunction(SortEquipmentSetIDs, setIDs)--PaperDollFrame.lua

    local numIndex=0
    for index, setID in pairs(setIDs) do
        local texture, _, isEquipped= select(2, C_EquipmentSet.GetEquipmentSetInfo(setID))
        local btn=panel.equipmentButton.btn.buttons[index]
        if not btn then
            btn=e.Cbtn(panel.equipmentButton.btn, {icon='hide',size={20,20}})
            set_equipmentButton_bnt_button_Point(btn, index)--设置位置

            btn:SetScript("OnMouseDown",function(self)
                if not UnitAffectingCombat('player') then
                    C_EquipmentSet.UseEquipmentSet(self.setID)
                    C_Timer.After(0.5, function() LvTo() end)--修改总装等
                else
                        print(addName..': '..RED_FONT_COLOR_CODE..ERR_NOT_IN_COMBAT..'|r')
                end
            end)
            btn:SetScript("OnEnter", function(self)
                if ( self.setID ) then
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
                    e.tips:SetEquipmentSet(self.setID)
                    local specIndex=C_EquipmentSet.GetEquipmentSetAssignedSpec(self.setID)
                    if specIndex then
                        local _, specName2, _, icon3 = GetSpecializationInfo(specIndex)
                        if icon3 and specName2 then
                            e.tips:AddLine(format(e.onlyChinese and '%s专精' or PROFESSIONS_SPECIALIZATIONS_PAGE_NAME, '|T'..icon3..':0|t'..specName2))
                            e.tips:Show()
                        end
                    end
                    --local name, iconFileID, _, isEquipped2, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(self.setID)
                end
                self:GetParent():SetButtonState('PUSHED')
            end)
            btn:SetScript("OnLeave",function(self)
                self:GetParent():SetButtonState('NORMAL')
                e.tips:Hide()
            end)
        end
        btn.setID=setID
        btn:SetNormalTexture(texture)
        btn:SetShown(true)
        if isEquipped then
            btn:LockHighlight()
        else
            btn:UnlockHighlight()
        end
        numIndex=index
        panel.equipmentButton.btn.buttons[index]=btn
    end
    for index= numIndex+1, #panel.equipmentButton.btn.buttons, 1 do
        panel.equipmentButton.btn.buttons[index]:SetShown(false)
    end
end


--############
--装备,总耐久度
--############
local function GetDurationTotale()
    if not panel.durabilityText then
        panel.durabilityText= e.Cstr(panel)
        panel.durabilityText:SetPoint('LEFT', panel.serverText, 'RIGHT')
        panel.durabilityText:EnableMouse(true)
        panel.durabilityText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinese and '耐久度' or DURABILITY, self.value)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        panel.durabilityText:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    local cu, max=0,0
    for slot=1, 17 do
        local cu2, max2= GetInventoryItemDurability(slot)
        if cu2 and max2 and max2>0 then
            cu = cu+ cu2
            max= max + max2
        end
    end
    local du
    if max>0 then
        local to=cu/max*100
        du=('%i%%'):format(to)
        if to<30 then
            du= '|cnRED_FONT_COLOR:'..du..'|r'
        end
    end
    panel.durabilityText.value=du or '100%'
    panel.durabilityText:SetText(du or '')
end

--#######
--装备弹出
--EquipmentFlyout.lua
local function setFlyout(button, itemLink, slot)

    if not button.level then
        button.level= e.Cstr(button)
        button.level:SetPoint('BOTTOM')
    end
    local dateInfo= e.GetTooltipData({hyperLink=itemLink, itemID=itemLink and GetItemInfoInstant(itemLink) , text={upgradeStr, pvpItemStr, itemLevelStr}, onlyText=true})--物品提示，信息

    local level
    if dateInfo and dateInfo.text[itemLevelStr] then
        level= tonumber(dateInfo.text[itemLevelStr])
    end
    level= level or itemLink and GetDetailedItemLevelInfo(itemLink)
    local text= level
    if text then
        local itemQuality = C_Item.GetItemQualityByID(itemLink)
        if itemQuality then
            local hex = select(4, GetItemQualityColor(itemQuality))
            if hex then
                text= '|c'..hex..text..'|r'
            end
        end
    end
    button.level:SetText(text or '')

    local upgrade, pvpItem= dateInfo.text[upgradeStr], dateInfo.text[pvpItemStr]
    upgrade= upgrade and upgrade:match('(%d+/%d+)')
    if upgrade and not button.upgrade then
        button.upgrade= e.Cstr(button, {color={r=0,g=1,b=0}})
        button.upgrade:SetPoint('LEFT')
    end
    if button.upgrade then
        button.upgrade:SetText(upgrade or '')
    end

    local updown--UpgradeFrame等级，比较
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
    if updown and not button.updown then
        button.updown=e.Cstr(button)
        button.updown:SetPoint('TOP')
    end
    if button.updown then
        button.updown:SetText(updown or '')
    end

    Set(button, itemLink)--套装

    if pvpItem and not button.pvpItem then--提示PvP装备
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
local function set_InspectPaperDollItemSlotButton_Update(self)
    local slot= self:GetID()
	local link = GetInventoryItemLink(InspectFrame.unit, slot);
	e.LoadDate({id=link, type='item'})--加载 item quest spell
    Gem(self, slot, link)
    Enchant(self, slot, link)
    e.Set_Item_Stats(self, link, {point=self.icon})
    if not self.OnEnter then
        self:SetScript('OnEnter', function(self2)
            if self2.link then
                e.tips:ClearLines()
                e.tips:SetOwner(InspectFrame, "ANCHOR_RIGHT")
                e.tips:SetHyperlink(self2.link)
                e.tips:AddDoubleLine(e.onlyChinese and '链接至聊天栏' or COMMUNITIES_INVITE_MANAGER_LINK_TO_CHAT, e.Icon.left)
                e.tips:Show()
            end
        end)
        self:SetScript('OnLeave', function() e.tips:Hide() end)
        self:SetScript('OnMouseDown', function(self2)
            if self2.link then
                local chat=SELECTED_DOCK_FRAME
                ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)
            end
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
        elseif Slot(slot) then
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
    local unit=InspectFrame.unit
    local guid= UnitGUID(unit)
    local info= guid and e.UnitItemLevel[guid]
    if info and info.itemLevel and info.specID then
        local level, effectiveLevel, sex = UnitLevel(InspectFrame.unit), UnitEffectiveLevel(InspectFrame.unit), UnitSex(InspectFrame.unit);
        local text= e.GetPlayerInfo({unit=unit, guid=guid, name=nil,  reName=false, reRealm=false, reLink=false})
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
        InspectFrameTitleText:SetTextColor(info.r or 1, info.g or 1, info.b or 1)
    end
end


--#####
--初始化
--#####
local function Init()
    --#############
    --显示服务器名称
    --#############
    panel.serverText= e.Cstr(PaperDollItemsFrame,{color= GameLimitedMode_IsActive() and {r=0,g=1,b=0} or true})--显示服务器名称
    panel.serverText:SetPoint('RIGHT', CharacterLevelText, 'LEFT',-30,0)
    panel.serverText:EnableMouse(true)
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
            e.tips:AddDoubleLine('regionID: '..GetCurrentRegion(),  GetCurrentRegionName())

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
    end)
    panel.serverText:SetScript("OnLeave",function() e.tips:Hide() end)
    local ser=GetAutoCompleteRealms() or {}
    local server= e.Get_Region(e.Player.realm, nil, nil)
    panel.serverText:SetText((#ser>1 and '|cnGREEN_FONT_COLOR:'..#ser..' ' or '')..e.Player.col..e.Player.realm..'|r'..(server and ' '..server.col or ''))

    --#########
    --装备管理框
    --#########
    panel.equipmentButton = e.Cbtn(PaperDollItemsFrame, {size={18,18}})--显示/隐藏装备管理框选项
    panel.equipmentButton:SetPoint('TOPRIGHT',-2,-40)
    panel.equipmentButton:SetScript("OnClick", function(self)
        Save.equipment= not Save.equipment and true or nil
        set_inti_Equipment_Frame()--装备管理框
        set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框
    end)
    panel.equipmentButton:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine((e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER)..e.GetShowHide(Save.equipment), e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
        if self.btn and self.btn:IsShown() then
			self.btn:SetButtonState('PUSHED')
		end
    end)
    panel.equipmentButton:SetScript("OnLeave",function(self)
        e.tips:Hide()
        if self.btn then
			self.btn:SetButtonState("NORMAL")
		end
    end)
    set_inti_Equipment_Frame()--装备管理框
    set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框

    GetDurationTotale()--装备,总耐久度

    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
            Title()--总装等
            set_PaperDollSidebarTab3_Text()
    end)

    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function(slef, equipmentSetsDirty)--装备管理
            set_PaperDollSidebarTab3_Text()
            LvTo()--总装等
    end)
    hooksecurefunc('GearSetButton_SetSpecInfo', function()--装备管理,修该专精
            set_PaperDollSidebarTab3_Text()
            LvTo()--总装等
    end)
    hooksecurefunc('GearSetButton_UpdateSpecInfo', EquipmentStr)--套装已装备数量
    hooksecurefunc('PaperDollEquipmentManagerPane_Update',set_inti_Equipment_Frame)----添加装备管理框  

    --#######
    --装备属性
    --#######
    hooksecurefunc('PaperDollItemSlotButton_Update',  function(self)--PaperDollFrame.lua
        local slot= self:GetID()
        if slot then
            if slot<20 and slot~=4 and slot~=19 and slot~=0 then
                local textureName = GetInventoryItemTexture("player", slot)
                local hasItem = textureName ~= nil
                local link=hasItem and GetInventoryItemLink('player', slot) or nil--装等                
                --Lv(self, slot, link)
                Du(self, slot, link)
                Gem(self, slot, link)
                Enchant(self, slot, link)
                --Set(self, slot, link)
                e.Set_Item_Stats(self, link, {point=self.icon})
                set_PaperDollSidebarTab3_Text()
                LvTo()--总装等
            elseif InventSlot_To_ContainerSlot[slot] then
                local numFreeSlots
                if self:HasBagEquipped() then--背包数
                    numFreeSlots = C_Container.GetContainerNumFreeSlots(InventSlot_To_ContainerSlot[slot])
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
            end
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
    CharacterLevelText:SetTextColor(e.Player.r, e.Player.g, e.Player.b)
    CharacterLevelText:SetJustifyH('LEFT')
    hooksecurefunc('PaperDollFrame_SetLevel', function()--PaperDollFrame.lua
        local race= e.GetUnitRaceInfo({unit='player', guid=nil , race=nil , sex=nil , reAtlas=true})
        local class= e.Class('player', nil, true)
        local level = UnitLevel("player");
        local effectiveLevel = UnitEffectiveLevel("player");

        if ( effectiveLevel ~= level ) then
            level = EFFECTIVE_LEVEL_FORMAT:format('|cnGREEN_FONT_COLOR:'..effectiveLevel..'|r', level);
        end
        local faction= e.Player.faction=='Alliance' and '|A:charcreatetest-logo-alliance:26:26|a' or e.Player.faction=='Horde' and '|A:charcreatetest-logo-horde:26:26|a' or ''
        CharacterLevelText:SetText('  '..faction..(race and '|A:'..race..':26:26|a' or '')..(class and '|A:'..class..':26:26|a  ' or '')..level)
    end)
end



--####################
--添加一个按钮, 打开选项
--####################
local function add_Button_OpenOption(self, notToggleCharacter)
    local btn2= e.Cbtn(self, {atlas='charactercreate-icon-customize-body-selected', size={40,40}})
    btn2:SetPoint('TOPRIGHT',-5,-25)
    btn2:SetScript('OnClick', function()
        ToggleCharacter("PaperDollFrame")
    end)
    btn2:SetScript('OnEnter', function(self2)
        e.tips:SetOwner(self2, "ANCHOR_Left")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, addName)
        e.tips:Show()
    end)
    btn2:SetScript('OnLeave', function() e.tips:Hide() end)

    if not (PaperDollFrame:IsVisible() or PaperDollFrame:IsShown()) and self:IsShown() then
        ToggleCharacter("PaperDollFrame")
    end
end
--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            Save= WoWToolsSave[addName] or Save

            --添加控制面板
            local sel=e.CPanel((e.Player.sex==2 and '|A:charactercreate-gendericon-male-selected:0:0|a' or '|A:charactercreate-gendericon-female-selected:0:0|a')..(e.onlyChinese and '角色' or addName), not Save.disabled)
            sel:SetScript('OnMouseDown', function()
                Save.disabled = not Save.disabled and true or nil
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需求重新加载' or REQUIRES_RELOAD)
            end)

            if not Save.disabled then
                panel:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
                panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
                Init()
            else
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_WeeklyRewards' then--周奖励, 物品提示，信息
            hooksecurefunc(WeeklyRewardsFrame, 'Refresh', function(self2)--Blizzard_WeeklyRewards.lua
                local activities = C_WeeklyRewards.GetActivities();
                for _, activityInfo in ipairs(activities) do
                    local frame = self2:GetActivityFrame(activityInfo.type, activityInfo.index);
                    local itemFrame= frame and frame.ItemFrame
                    if itemFrame then
                        e.Set_Item_Stats(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), {point=itemFrame.Icon})
                    end
                end
            end)

        elseif arg1=='Blizzard_ItemUpgradeUI' then--装备升级, 界面
            add_Button_OpenOption(ItemUpgradeFrameCloseButton)--添加一个按钮, 打开选项

        elseif arg1=='Blizzard_ItemInteractionUI' then--套装转换, 界面
            add_Button_OpenOption(ItemInteractionFrameCloseButton)--添加一个按钮, 打开选项

        elseif arg1=='Blizzard_InspectUI' then
            if InspectPaperDollFrame.ViewButton then
                InspectPaperDollFrame.ViewButton:ClearAllPoints()
                InspectPaperDollFrame.ViewButton:SetPoint('LEFT', InspectLevelText, 'RIGHT',4,0)
                InspectPaperDollFrame.ViewButton:SetSize(25,25)
                InspectPaperDollFrame.ViewButton:SetText(e.onlyChinese and '试' or e.WA_Utf8Sub(VIEW,1))
            end
            if InspectPaperDollItemsFrame.InspectTalents then
                InspectPaperDollItemsFrame.InspectTalents:SetSize(25,25)
                InspectPaperDollItemsFrame.InspectTalents:SetText(e.onlyChinese and '赋' or e.WA_Utf8Sub(TALENT,1))
            end

            hooksecurefunc('InspectPaperDollItemSlotButton_Update', set_InspectPaperDollItemSlotButton_Update)--目标, 装备
            hooksecurefunc('InspectPaperDollFrame_SetLevel', set_InspectPaperDollFrame_SetLevel)--目标,天赋 装等
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    elseif event == 'EQUIPMENT_SWAP_FINISHED' then
        C_Timer.After(0.6, set_inti_Equipment_Frame)

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        GetDurationTotale()--装备,总耐久度
    end
end)
