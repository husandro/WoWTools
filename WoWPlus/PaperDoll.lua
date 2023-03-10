local id, e = ...
local addName= CHARACTER
local Save={EquipmentH=true}
local panel = CreateFrame("Frame", nil, PaperDollFrame)
panel.serverText= e.Cstr(PaperDollItemsFrame)--显示服务器名称

local pvpItemStr= PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr= ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local upgradeStr= ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT:gsub('%%s/%%s','(%%d%+/%%d%+)')-- "升级：%s/%s"

local function Slot(slot)--左边插曹
    return slot==1 or slot==2 or slot==3 or slot==15 or slot==5 or slot==4 or slot==19 or slot==9 or slot==17 or slot==18
end

local function Du(self, slot, link) --耐久度    
    local du
    if link then
        local min, max=GetInventoryItemDurability(slot)
        if min and max and max>0 then
            du=min/max*100
        end
    end
    if du then
        if not self.du then
            self.du=CreateFrame('StatusBar', nil, self)
            if Slot(slot) then
               self.du:SetPoint('RIGHT', self, 'LEFT', -2.5,0)
            else
                self.du:SetPoint('LEFT', self, 'RIGHT', 2.5,0)
            end
            self.du:SetSize(4, self:GetHeight())--h37
            self.du:SetMinMaxValues(0, 100)
            self.du:SetOrientation("VERTICAL")
            self.du:SetStatusBarTexture('Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_Smooth_Border')
        end
        if du >70 then
            self.du:SetStatusBarColor(0,1,0)
        elseif du >30 then
            self.du:SetStatusBarColor(1,1,0)
        else
            self.du:SetStatusBarColor(1,0,0)
        end
        self.du:SetValue(du)
    end
    if self.du then
        self.du:SetShown(du and true or false)
    end
end

local function LvTo()--总装等
    if not PaperDollSidebarTab1 then
        return
    end
    local avgItemLevel,_, avgItemLevelPvp = GetAverageItemLevel()
    if avgItemLevel and not PaperDollSidebarTab1.itemLevelText then--PVE
        PaperDollSidebarTab1.itemLevelText=e.Cstr(PaperDollSidebarTab1, {justifyH='CENTER'})
        PaperDollSidebarTab1.itemLevelText:SetPoint('BOTTOM')
    end
    if PaperDollSidebarTab1.itemLevelText then
        if avgItemLevel then
            PaperDollSidebarTab1.itemLevelText:SetFormattedText('%i', avgItemLevel)
        end
        PaperDollSidebarTab1.itemLevelText:SetShown(avgItemLevel and true or false)
    end

    if avgItemLevel~= avgItemLevelPvp and avgItemLevelPvp and not PaperDollSidebarTab1.itemLevelPvPText then--PVP
        PaperDollSidebarTab1.itemLevelPvPText=e.Cstr(PaperDollSidebarTab1, {justifyH='CENTER'})
        PaperDollSidebarTab1.itemLevelPvPText:SetPoint('TOP')
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

    local gems={}
    if link then
        for i=1, MAX_NUM_SOCKETS do
            local gemlink=select(2, GetItemGem(link, i))
            gems[i]=gemlink and C_Item.GetItemIconByID(gemlink) or false
        end
    end
    local n= 1
    for _, v in pairs(gems) do
        if v then
            if not self['gem'..n] then
                local h=self:GetHeight()/3
                self['gem'..n]=self:CreateTexture()
                self['gem'..n]:SetSize(h,h)
            else
                self['gem'..n]:ClearAllPoints()
            end
            if Slot(slot) then--左边插曹
                if n==1 then
                    self['gem'..n]:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 8, 0)
                else
                    self['gem'..n]:SetPoint('BOTTOMLEFT', self['gem'..(n-1)], 'BOTTOMRIGHT')
                end
            else
                if n==1 then
                    self['gem'..n]:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', -8, 0)
                else
                    self['gem'..n]:SetPoint('BOTTOMRIGHT', self['gem'..(n-1)], 'BOTTOMLEFT')
                end
            end
        end
        if self['gem'..n] then
            self['gem'..n]:SetTexture(v or 0)
            self['gem'..n]:SetShown(v and true or false)
        end
        if v then
            n=n+1
        end
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
    local enchant, use, pvpItem, upgradeItem, _
    if link then
        _, enchant, _ , pvpItem, upgradeItem=  e.GetTooltipData(nil, enchantStr, link, nil, nil, nil, nil, slot, pvpItemStr, upgradeStr)--物品提示，信息
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
        end

        use=GetItemSpell(link)--物品是否可使用
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
        end

        if upgradeItem and not self.upgradeItem then--"升级：%s/%s"
            if Slot(slot) then
                self.upgradeItem= e.Cstr(self, {color={r=0,g=1,b=0}})--12, nil, nil, {0,1,0}, nil,'LEFT')
                self.upgradeItem:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT')
            else
                self.upgradeItem= e.Cstr(self, {color={r=0,g=1,b=0}, justifyH='RIGHT'})--12, nil, nil, {0,1,0}, nil,'RIGHT')
                self.upgradeItem:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT')
            end
        end
    end

    if self.enchant then
        self.enchant:SetShown(enchant and true or false)
    end
    if self.use then
        self.use:SetShown(use and true or false)
    end
    if self.pvpItem then
        self.pvpItem:SetShown(pvpItem and true or false)
    end
    if self.upgradeItem then--文字
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
    nu= nu>1 and nu or nil
    if nu and not PaperDollSidebarTab2.titleNumeri then
        PaperDollSidebarTab2.titleNumeri=e.Cstr(PaperDollSidebarTab2, {justifyH='CENTER'})
        PaperDollSidebarTab2.titleNumeri:SetPoint('BOTTOM')
    end
    if PaperDollSidebarTab2.titleNumeri then
        PaperDollSidebarTab2.titleNumeri:SetText(nu or '')
        PaperDollSidebarTab2.titleNumeri:SetShown(nu and true or false)
    end
end

--#######
--装备管理
--#######
local function set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框
    panel.HideShowEquipmentFrame:SetNormalAtlas(Save.equipment and e.Icon.icon or e.Icon.disabled)
    panel.HideShowEquipmentFrame:SetAlpha(Save.equipment and 0.1 or 1)
end

local function Equipment()--装备管理
    if not PaperDollSidebarTab3 then
        return
    end
    local name, icon, specIcon,nu
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
                local icon3=select(4, GetSpecializationInfo(specIndex))
                if icon3 then
                    specIcon=icon3
                end
            end
            nu=numItems
            break
        end
    end

    if not PaperDollSidebarTab3.set and name then--名称
        PaperDollSidebarTab3.set=e.Cstr(PaperDollSidebarTab3, {justifyH='CENTER'})
        PaperDollSidebarTab3.set:SetPoint('BOTTOM', 2, 0)
    end
    if PaperDollSidebarTab3.set then
        PaperDollSidebarTab3.set:SetText(name or '')
        PaperDollSidebarTab3.set:SetShown(name and true or false)
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
    end
    if PaperDollSidebarTab3.spec then
        PaperDollSidebarTab3.spec:SetTexture(specIcon or 0)
        PaperDollSidebarTab3.spec:SetShown(specIcon and true or false)
    end

    if not PaperDollSidebarTab3.nu and nu then--套装数量
        PaperDollSidebarTab3.nu=e.Cstr(PaperDollSidebarTab3, {justifyH='RIGHT'})
        PaperDollSidebarTab3.nu:SetPoint('LEFT', PaperDollSidebarTab3, 'RIGHT',0, 4)
    end
    if PaperDollSidebarTab3.nu then
        PaperDollSidebarTab3.nu:SetText(nu or '')
        PaperDollSidebarTab3.nu:SetShown(nu and true or false)
    end
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


local function EPoint(self, f, b2)--添加装备管理框,设置位置
    if not Save.EquipmentH then
        if b2 then
            self:SetPoint('TOP', b2, 'BOTTOM')
        else
            self:SetPoint('TOP', f, 'BOTTOM')
        end
    else
        if b2 then
            self:SetPoint('LEFT', b2, 'RIGHT')
        else
            self:SetPoint('LEFT', f, 'RIGHT')
        end
    end
end
local function setEquipmentSize(self, index)--装备管理框,设置大小,隐然多除的
    if not self.B then
        return
    end
    for i=1, #self.B do
        if index==i then
            self.B[i]:SetShown(false)
        end
        self.B[i]:SetSize(Save.equipmentSize or 18, Save.equipmentSize or 18)
    end
end
local function add_Equipment_Frame(equipmentSetsDirty)--添加装备管理框
    if not Save.equipment or not PAPERDOLL_SIDEBARS[3].IsActive() then
        if panel.equipmentFrame then
            panel.equipmentFrame:SetShown(false)
            for _, button in pairs(panel.equipmentFrame.B) do
                if button then
                    button:SetShown(false)
                end
            end
        end
        return
    end

    if not panel.equipmentFrame then
        panel.equipmentFrame=e.Cbtn(nil, {icon=true, size={14,14}})--添加移动按钮
        if Save.Equipment then
            panel.equipmentFrame:SetPoint(Save.Equipment[1], UIParent, Save.Equipment[3], Save.Equipment[4], Save.Equipment[5])
        else
            panel.equipmentFrame:SetPoint('BOTTOMRIGHT', PaperDollItemsFrame, 'TOPRIGHT')
        end
        panel.equipmentFrame:RegisterForDrag("RightButton")
        panel.equipmentFrame:SetClampedToScreen(true)
        panel.equipmentFrame:SetMovable(true)
        panel.equipmentFrame:EnableMouseWheel(true)
        panel.equipmentFrame:SetScript("OnDragStart", function(self)
            if not IsModifierKeyDown() then
                self:StartMoving()
            end
        end)
        panel.equipmentFrame:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.Equipment={self:GetPoint(1)}
                Save.Equipment[2]=nil
        end)
        panel.equipmentFrame:SetScript("OnMouseUp", function() ResetCursor() end)
        panel.equipmentFrame:SetScript("OnMouseDown", function(self,d)
            local key=IsModifierKeyDown()
            local alt=IsAltKeyDown()
            if d=='RightButton' and not key then--移动图标
                SetCursor('UI_MOVE_CURSOR')

            elseif d=='LeftButton' and alt then--图标横,或 竖
                Save.EquipmentH= not Save.EquipmentH and true or nil
                if self.B then
                    local b3
                    for _, v in pairs(self.B) do
                        v:ClearAllPoints()
                        EPoint(v, self, b3)--设置位置
                        b3=v
                    end
                end
            elseif d=='LeftButton' and not key then--打开/关闭角色界面
                ToggleCharacter("PaperDollFrame")
            end
        end)
        panel.equipmentFrame:SetScript('OnMouseWheel',function(self, d)--放大
                local n=Save.equipmentSize or 18
                if d==1 then
                    n=n+1
                elseif d==-1 then
                    n=n-1
                end
                if n>50 then
                    n=50
                elseif n<6 then
                    n=6
                end
                Save.equipmentSize=n
                setEquipmentSize(self)
                print(id, addName, e.onlyChinese and '缩放' or UI_SCALE, GREEN_FONT_COLOR_CODE..n)
        end)
        panel.equipmentFrame:SetScript("OnEnter", function (self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, e.onlyChinese and '装备管理'or EQUIPMENT_MANAGER)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine( Save.EquipmentH and (e.onlyChinese and '向右' or BINDING_NAME_STRAFERIGHT) or (e.onlyChinese and '向下' or BINDING_NAME_PITCHDOWN), 'Alt + '..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinese and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..': '..(Save.equipmentSize and Save.equipmentSize or 18), e.Icon.mid)
            e.tips:Show()
            self:SetAlpha(1)
        end)
        panel.equipmentFrame:SetScript("OnLeave", function(self)
            ResetCursor()
            e.tips:Hide()
            self:SetAlpha(0)
        end)
        if Save.Equipment then
            panel.equipmentFrame:SetAlpha(0)
        end
        panel.equipmentFrame.B={}--添加装备管理按钮
    end
    panel.equipmentFrame:SetShown(true)

    local b2, index=nil, 1
    local setIDs=SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs())--PaperDollFrame.lua
    for k, id2 in pairs(setIDs) do
        local texture, setID, isEquipped= select(2, C_EquipmentSet.GetEquipmentSetInfo(id2))
        local b=panel.equipmentFrame.B[k]
        if not b then
            b=e.Cbtn(nil, {icon='hide'})
            b.tex=b:CreateTexture(nil, 'OVERLAY')
            b.tex:SetAtlas(e.Icon.select)
            b.tex:SetAllPoints(b)
           -- b:SetSize(20, 20)
            EPoint(b, panel.equipmentFrame ,b2)--设置位置

            b:SetScript("OnMouseDown",function(self)
                    if not UnitAffectingCombat('player') then
                        C_EquipmentSet.UseEquipmentSet(self.setID)
                        C_Timer.After(0.5, function() LvTo() end)--修改总装等
                    else
                        print(addName..': '..RED_FONT_COLOR_CODE..ERR_NOT_IN_COMBAT..'|r')
                    end
            end)
            b:SetScript("OnEnter", function(self)
                    if ( self.setID ) then
                        e.tips:SetOwner(self, "ANCHOR_LEFT")
                        e.tips:SetEquipmentSet(self.setID)
                    end
            end)
            b:SetScript("OnLeave",function() e.tips:Hide() end)
        end
        b.setID=setID
        b.tex:SetShown(isEquipped and true or false)
        b:SetNormalTexture(texture)
        b:SetShown(true)--显示        
        panel.equipmentFrame.B[k]=b
        index=k+1
        b2=b
    end
    setEquipmentSize(panel.equipmentFrame, index)--隐然多除的, 设置大小
    LvTo()--总装等
end


local InventSlot_To_ContainerSlot={}--背包数
for i=1, NUM_TOTAL_EQUIPPED_BAG_SLOTS  do
    local bag=C_Container.ContainerIDToInventoryID(i)
    if bag then
        InventSlot_To_ContainerSlot[bag]=i
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
    --[[for slot, _ in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
        local cu2, max2= GetInventoryItemDurability(slot)
        if cu2 and max2 and max2>0 then
            cu = cu+ cu2
            max= max + max2
        end
    end]]
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
    local level= itemLink and GetDetailedItemLevelInfo(itemLink)
    if not button.level then
        button.level= e.Cstr(button)
        button.level:SetPoint('BOTTOM')
    end
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

    local upgrade, pvpItem, _
    if itemLink then
        _, upgrade, _, pvpItem= e.GetTooltipData(nil, upgradeStr, itemLink, nil, nil, nil, nil, nil, pvpItemStr)--物品提示，信息
        --e.GetTooltipData= function(colorRed, text, hyperLink, bag, guidBank, merchant, buyBack, inventory, text2, text3)
    end

    if upgrade and not button.upgrade then
        button.upgrade= e.Cstr(button, {color={r=0,g=1,b=0}})
        button.upgrade:SetPoint('LEFT')
    end
    if button.upgrade then
        button.upgrade:SetText(upgrade or '')
    end

    local updown--升级等级，比较
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

--#####
--初始化
--#####
local function Init()
    --#############
    --显示服务器名称
    --#############
    panel.serverText:SetPoint('RIGHT', CharacterLevelText, 'LEFT',-30,0)
    panel.serverText:EnableMouse(true)
    panel.serverText:SetScript("OnEnter",function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '服务器:' or FRIENDS_LIST_REALM)
            local ok2
            for k, v in pairs(GetAutoCompleteRealms()) do
                if v==e.Player.server then
                    e.tips:AddDoubleLine(v, k, 0,1,0)
                else
                    e.tips:AddDoubleLine(v, k)
                end
                ok2=true
            end
            if not ok2 then
                e.tips:AddDoubleLine(e.onlyChinese and '唯一' or ITEM_UNIQUE, e.Player.server)
            end
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
    end)
    panel.serverText:SetScript("OnLeave",function() e.tips:Hide() end)
    local ser=GetAutoCompleteRealms() or {}
    panel.serverText:SetText((#ser>1 and #ser..' ' or '')..e.Player.col..e.Player.server..'|r')

    --#########
    --装备管理框
    --#########
    panel.HideShowEquipmentFrame = e.Cbtn(PaperDollItemsFrame, {icon=Save.equipment, size={20,20}})--显示/隐藏装备管理框选项
    panel.HideShowEquipmentFrame:SetPoint('TOPRIGHT',-2,-40)
    panel.HideShowEquipmentFrame:SetScript("OnMouseDown", function(self)
        Save.equipment= not Save.equipment and true or nil
        add_Equipment_Frame()--装备管理框
        set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框
    end)
    panel.HideShowEquipmentFrame:SetScript("OnEnter", function (self)
            e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, addName)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '装备管理' or EQUIPMENT_MANAGER, e.GetShowHide(Save.equipment))
            e.tips:Show()
    end)
    panel.HideShowEquipmentFrame:SetScript("OnLeave",function(self)
            e.tips:Hide()
    end)
    add_Equipment_Frame()--装备管理框
    set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框

    GetDurationTotale()--装备,总耐久度

    hooksecurefunc('PaperDollFrame_UpdateSidebarTabs', function()--头衔数量
            Title()--总装等
            Equipment()
    end)

    hooksecurefunc('PaperDollEquipmentManagerPane_Update', function(slef, equipmentSetsDirty)--装备管理
            Equipment()
            LvTo()--总装等
    end)
    hooksecurefunc('GearSetButton_SetSpecInfo', function()----装备管理,修该专精
            Equipment()
            LvTo()--总装等
    end)
    hooksecurefunc('GearSetButton_UpdateSpecInfo', EquipmentStr)--套装已装备数量
    hooksecurefunc('PaperDollEquipmentManagerPane_Update',add_Equipment_Frame)----添加装备管理框  

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
                e.Set_Item_Stats(self, link, self.icon)
                Equipment()
                LvTo()--总装等
            elseif InventSlot_To_ContainerSlot[slot] and self:HasBagEquipped() then--背包数
                local numFreeSlots
                numFreeSlots = C_Container.GetContainerNumFreeSlots(InventSlot_To_ContainerSlot[slot])
                if numFreeSlots==0 then
                    numFreeSlots= nil
                end
                if numFreeSlots and not self.numFreeSlots then
                    self.numFreeSlots=e.Cstr(self, {color=true, justifyH='CENTER'})
                    self.numFreeSlots:SetPoint('BOTTOM',0 ,6)
                end
                if self.numFreeSlots then
                    self.numFreeSlots:SetText(numFreeSlots or '')
                end
            end
        end
    end)

    --#########
    --背包, 数量
    --MainMenuBarBagButtons.lua
    if MainMenuBarBackpackButton then
        if MainMenuBarBackpackButtonCount then
            MainMenuBarBackpackButtonCount:SetShadowOffset(1, -1)
        end
        if e.Player.useColor and MainMenuBarBackpackButtonCount then
            MainMenuBarBackpackButtonCount:SetTextColor(e.Player.useColor.r, e.Player.useColor.g, e.Player.useColor.b, e.Player.useColor.a)
        end
        hooksecurefunc(MainMenuBarBackpackButton, 'UpdateFreeSlots', function(self)
            local totalFree
            totalFree= 0
            for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS-1 do
                local freeSlots, bagFamily= C_Container.GetContainerNumFreeSlots(i)
                if ( bagFamily == 0 ) then
                    totalFree = totalFree + freeSlots;
                end
            end
            self.freeSlots= totalFree
            if totalFree==0 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(1,0,0,1)
                totalFree= '|cnRED_FONT_COLOR:'..totalFree..'|r'
            elseif totalFree<=5 then
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,1,0,1)
                totalFree= '|cnGREEN_FONT_COLOR:'..totalFree..'|r'
            else
                MainMenuBarBackpackButtonIconTexture:SetColorTexture(0,0,0,0)
            end
            self.Count:SetText(totalFree)
        end)
    end
    MainMenuBarBackpackButton:HookScript('OnClick', function(self, d)
        if d=='RightButton' then
            ToggleAllBags()
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
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

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
                        e.Set_Item_Stats(itemFrame, itemFrame.displayedItemDBID and C_WeeklyRewards.GetItemHyperlink(itemFrame.displayedItemDBID), itemFrame.Icon)
                    end
                end
            end)
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event == 'EQUIPMENT_SWAP_FINISHED' then
        C_Timer.After(0.6, add_Equipment_Frame)

    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        GetDurationTotale()--装备,总耐久度

    
    end
end)
