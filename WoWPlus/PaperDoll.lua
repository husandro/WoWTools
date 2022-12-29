local id, e = ...
local addName= CHARACTER
local Save={EquipmentH=true}
local panel = CreateFrame("Frame", nil, PaperDollFrame)
panel.serverText= e.Cstr(PaperDollItemsFrame, nil, nil, nil,{1,0.82,0},nil, 'LEFT')--显示服务器名称

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
               -- self.du:SetPoint('LEFT', self, 'RIGHT', 2.5,0)
               self.du:SetPoint('RIGHT', self, 'LEFT', -2.5,0)
            else
                self.du:SetPoint('LEFT', self, 'RIGHT', 2.5,0)
                --self.du:SetPoint('RIGHT', self, 'LEFT', -2.5,0)
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
        PaperDollSidebarTab1.itemLevelText=e.Cstr(PaperDollSidebarTab1, nil, nil, nil,{1,0.82,0},nil, 'CENTER')
        PaperDollSidebarTab1.itemLevelText:SetPoint('BOTTOM')
    end
    if PaperDollSidebarTab1.itemLevelText then
        if avgItemLevel then
            PaperDollSidebarTab1.itemLevelText:SetFormattedText('%i', avgItemLevel)
        end
        PaperDollSidebarTab1.itemLevelText:SetShown(avgItemLevel and true or false)
    end

    if avgItemLevel~= avgItemLevelPvp and avgItemLevelPvp and not PaperDollSidebarTab1.itemLevelPvPText then--PVP
        PaperDollSidebarTab1.itemLevelPvPText=e.Cstr(PaperDollSidebarTab1, nil, nil, nil,{1,0.82,0},nil, 'CENTER')
        PaperDollSidebarTab1.itemLevelPvPText:SetPoint('TOP',0,-2)
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

local function Lv(self, slot, link)--装等    
    local lv--, pvp
    local to=GetAverageItemLevel()
    if link then
        local quality = GetInventoryItemQuality("player", slot)--颜色
        lv=GetDetailedItemLevelInfo(link)
        if lv and to then
            local val=lv-to
            if val>3 then
                lv= GREEN_FONT_COLOR_CODE..lv..'|r'
            elseif quality and quality< 5 then
                if val < -9  then
                    lv =RED_FONT_COLOR_CODE..lv..'|r'
                elseif val < -3 then
                    lv =YELLOW_FONT_COLOR_CODE..lv..'|r'
                else
                    local hex=quality and select(4, GetItemQualityColor(quality))
                    if hex then
                        lv='|c'..hex..lv..'|r'
                    end
                end
            end
        end

       -- pvp= slot and select(2, e.GetTooltipData(nil, PvPItemLevel, link, nil, nil, nil, nil, slot))--"装备：在竞技场和战场中将物品等级提高至%d。"
        --[[if PvPLevel and hex then
            PvPLevel= '|c'..hex..PvPLevel..'|r'
        end]]
    end
    if not self.lv and lv then
        self.lv= e.Cstr(self, 10, nil, nil,nil,nil, 'CENTER')
        self.lv:SetPoint('BOTTOM', 0, 0)
    end
    if self.lv then
        self.lv:SetText(lv or '')
    end

    --[[if not self.PvPLevel and PvPLevel then
        self.PvPLevel= e.Cstr(self, 10, nil, nil,nil,nil, 'RIGHT')
        self.PvPLevel:SetPoint('RIGHT', 0, 0)
    end
    if self.PvPLevel then
        self.PvPLevel:SetText(PvPLevel or '')
        self.PvPLevel:SetShown(PvPLevel and true or false)
    end]]

--[[
    if pvp and not self.pvpItem then
        self.pvpItem=self:CreateTexture()
        self.pvpItem:SetPoint('RIGHT')
        local size= self:GetSize()
        size= size/3
        self.pvpItem:SetSize(size, size)
        self.pvpItem:SetAtlas('pvptalents-warmode-swords')
    end
    if self.pvpItem then
        self.pvpItem:SetShown(pvp and true or false)
    end

]]

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
        self.engineering=e.Cbtn(self)
        self.engineering:SetSize(self.use:GetSize())
        self.engineering:SetNormalTexture(136243)
        --self.engineering:SetPoint('CENTER', self.use, 'CENTER')
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

local PvPItemLevelStr=PVP_ITEM_LEVEL_TOOLTIP:gsub('%%d', '%(%%d%+%)')--"装备：在竞技场和战场中将物品等级提高至%d。"
local enchantStr=ENCHANTED_TOOLTIP_LINE:gsub('%%s','(.+)')--附魔
local function Enchant(self, slot, link)--附魔, 使用, 属性
    local enchant, use, pvpItem, _
    if link then
        _, enchant, _ , pvpItem= e.GetTooltipData(nil, enchantStr, link, nil, nil, nil, nil, slot, PvPItemLevelStr)--物品提示，信息
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
            self.pvpItem=self:CreateTexture()
            self.pvpItem:SetSize(h,h)
            if Slot(slot) then
                self.pvpItem:SetPoint('LEFT', self, 'RIGHT', -2.5,0)
            else
                self.pvpItem:SetPoint('RIGHT', self, 'LEFT', 2.5,0)
            end
            self.pvpItem:SetAtlas('pvptalents-warmode-swords')
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
end

local function Set(self, slot, link)--套装
    local set
    if link then
        set=select(16 , GetItemInfo(link))
        if set then
            if set and not self.set then
                self.set=self:CreateTexture()
                if Slot(slot) then
                    self.set:SetPoint('TOPRIGHT',self)
                else
                    self.set:SetPoint('TOPLEFT',self)
                end
                self.set:SetAllPoints(self)
                self.set:SetAtlas(e.Icon.pushed)
            end
        end
    end
    if self.set then self.set:SetShown(set) end
end

local function SetP(self, n)
    if n==1 then
        self:SetPoint('BOTTOMLEFT', -3, 0)
    elseif n==2 then
        self:SetPoint('BOTTOMRIGHT', 3, 0)
    elseif n==3 then
        self:SetPoint('TOPLEFT', -3, 0)
    else
        self:SetPoint('TOPRIGHT', 3, 0)
    end
end
local function Sta(self, slot, link)--显示属性
    local s,h,m,v
    local n=0
    if link then
        local info=GetItemStats(link) or {}
        s=info['ITEM_MOD_CRIT_RATING_SHORT']
        h=info['ITEM_MOD_HASTE_RATING_SHORT']
        m=info['ITEM_MOD_MASTERY_RATING_SHORT']
        v=info['ITEM_MOD_VERSATILITY']

        if s then
            if not self.s then
                self.s=e.Cstr(self, 10)
                self.s:SetText(e.WA_Utf8Sub(STAT_CRITICAL_STRIKE, 1):upper())
            else
                self.s:ClearAllPoints()
            end
            n=n+1
            SetP(self.s, n)
        end

        if h then
            if not self.h then
                self.h=e.Cstr(self, 10)
                self.h:SetText(e.WA_Utf8Sub(STAT_HASTE, 1):upper())
            else
                self.h:ClearAllPoints()
            end
            n=n+1
            SetP(self.h, n)
        end
        if m  then
            if not self.m then
                self.m=e.Cstr(self, 10)
                self.m:SetText(e.WA_Utf8Sub(STAT_MASTERY, 1):upper())
            else
                self.m:ClearAllPoints()
            end
            n=n+1
            SetP(self.m, n)
        end
        if v then
            if not self.v then
                self.v=e.Cstr(self, 10)
                self.v:SetText(e.WA_Utf8Sub(STAT_VERSATILITY, 1):upper())
            else
                self.v:ClearAllPoints()
            end
            n=n+1
            SetP(self.v, n)
        end
    end
    if self.s then self.s:SetShown(s) end
    if self.h then self.h:SetShown(h) end
    if self.m then self.m:SetShown(m) end
    if self.v then self.v:SetShown(v) end
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
        PaperDollSidebarTab2.titleNumeri=e.Cstr(PaperDollSidebarTab2,nil,nil,nil,{1,0.82,0},nil,'CENTER')
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
        PaperDollSidebarTab3.set=e.Cstr(PaperDollSidebarTab3, nil, nil, nil,{1,0.82,0},nil, 'CENTER')
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
        PaperDollSidebarTab3.nu=e.Cstr(PaperDollSidebarTab3, nil, nil, nil,{1,0.82,0},nil, 'RIGHT')
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
        panel.equipmentFrame=e.Cbtn(UIParent)--添加移动按钮
        panel.equipmentFrame:SetSize(12, 12)
        panel.equipmentFrame:SetNormalAtlas(e.Icon.icon)
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
                print(id, addName, e.onlyChinse and '缩放' or UI_SCALE, GREEN_FONT_COLOR_CODE..n)
        end)
        panel.equipmentFrame:SetScript("OnEnter", function (self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, e.onlyChinse and '装备管理'or EQUIPMENT_MANAGER)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinse and '打开/关闭角色界面' or BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine( Save.EquipmentH and (e.onlyChinse and '向右' or BINDING_NAME_STRAFERIGHT) or (e.onlyChinse and '向下' or BINDING_NAME_PITCHDOWN), 'Alt + '..e.Icon.left)
            e.tips:AddDoubleLine(e.onlyChinse and '移动' or NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinse and '缩放' or UI_SCALE)..': '..(Save.equipmentSize and Save.equipmentSize or 18), e.Icon.mid)
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
    local setIDs=SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs())
    for k, id2 in pairs(setIDs) do
        local texture, setID, isEquipped= select(2, C_EquipmentSet.GetEquipmentSetInfo(id2))
        local b=panel.equipmentFrame.B[k]
        if not b then
            b=e.Cbtn(UIParent)
            b.tex=b:CreateTexture(nil, 'OVERLAY')
            b.tex:SetAtlas(e.Icon.select)
            b.tex:SetAllPoints(b)
           -- b:SetSize(20, 20)
            EPoint(b, panel.equipmentFrame ,b2)--设置位置

            b:SetScript("OnClick",function(self)
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

--#######
--装备弹出
--#######
local function setFlyoutLevel(button, level, paperDollItemSlot)
    if level and not button.level then
        button.level=e.Cstr(button, 10)
        button.level:SetPoint('BOTTOM')
    end
    if button.level then
        button.level:SetText(level or '')
    end

    local slotLevel--升级等级，比较
    if paperDollItemSlot and level then
        local slot=paperDollItemSlot:GetID()
        if slot then
            local itemLink = GetInventoryItemLink('player', slot)
            if itemLink then
                slotLevel = GetDetailedItemLevelInfo(itemLink)
                if slotLevel then
                    slotLevel=level-slotLevel
                end
            end
        end
    end
    if slotLevel and not button.upLevel then
        button.upLevel=e.Cstr(button, 10)
        button.upLevel:SetPoint('TOP',0 ,5)
    end
    if button.upLevel then
        if slotLevel then
            if slotLevel>0 then
                button.upLevel:SetText('|cnGREEN_FONT_COLOR:+'..slotLevel..'|r')
            elseif slotLevel<0 then
                button.upLevel:SetText('|cnRED_FONT_COLOR:'..slotLevel..'|r')
            else
                button.upLevel:SetText(slotLevel)
            end
        else
            button.upLevel:SetText('')
        end
    end
end


--############
--装备,总耐久度
--############
local function GetDurationTotale()
    if not panel.durabilityText then
        panel.durabilityText= e.Cstr(panel, nil, nil,nil,{1,0.8,0})
        panel.durabilityText:SetPoint('LEFT', panel.serverText, 'RIGHT')
        panel.durabilityText:EnableMouse(true)
        panel.durabilityText:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(e.onlyChinse and '耐久度' or DURABILITY, self.value)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, addName)
            e.tips:Show()
        end)
        panel.durabilityText:SetScript('OnLeave', function() e.tips:Hide() end)
    end
    local cu, max=0,0
    for slot, _ in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
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
            du= RED_FONT_COLOR_CODE..du..'|r'
        end
    end
    panel.durabilityText.value=du or '100%'
    panel.durabilityText:SetText(du or '')
end


--#####
--初始化
--#####
local function Init()
    --#############
    --显示服务器名称
    --#############
    panel.serverText:SetPoint('RIGHT', CharacterLevelText, 'LEFT')
    panel.serverText:EnableMouse(true)
    panel.serverText:SetScript("OnEnter",function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(FRIENDS_LIST_REALM)
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
                if e.onlyChinse then
                    e.tips:AddDoubleLine('唯一', '服务器')
                else
                    e.tips:AddDoubleLine(ITEM_UNIQUE, SERVER_MESSAGE_PREFIX)
                end
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
    panel.HideShowEquipmentFrame = e.Cbtn(PaperDollItemsFrame, nil, Save.equipment)--显示/隐藏装备管理框选项
    panel.HideShowEquipmentFrame:SetPoint('TOPRIGHT',-2,-40)
    panel.HideShowEquipmentFrame:SetSize(20, 20)
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
            e.tips:AddDoubleLine(e.onlyChinse and '装备管理' or EQUIPMENT_MANAGER, e.GetShowHide(Save.equipment))
            e.tips:Show()
    end)
    panel.HideShowEquipmentFrame:SetScript("OnLeave",function(self)
            e.tips:Hide()
    end)
    add_Equipment_Frame()--装备管理框
    set_HideShowEquipmentFrame_Texture()--设置，总开关，装备管理框

    GetDurationTotale()--装备,总耐久度

    hooksecurefunc('EquipmentFlyout_DisplayButton', function(button, paperDollItemSlot)--EquipmentFlyout.lua
        local location = button.location;
        if not location or location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
            setFlyoutLevel(button)
            return;
        end
        local player, bank, bags, voidStorage, slot, bag, tab, voidSlot = EquipmentManager_UnpackLocation(location);
        if ( not player and not bank and not bags and not voidStorage ) then--EquipmentManager.lua
            setFlyoutLevel(button)
            return;
        end
        local itemLink
        if ( voidStorage ) then
            itemLink = GetVoidItemHyperlinkString(voidSlot)
        elseif ( not bags ) then -- and (player or bank)
            itemLink =GetInventoryItemLink("player",slot);
        else -- bags
            itemLink = C_Container.GetContainerItemLink(bag, slot);
        end
        local level= itemLink and GetDetailedItemLevelInfo(itemLink)
        setFlyoutLevel(button, level, paperDollItemSlot)
    end)

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
                Lv(self, slot, link)
                Du(self, slot, link)
                Gem(self, slot, link)
                Enchant(self, slot, link)
                Set(self, slot, link)
                Sta(self, slot, link)
                Equipment()
                LvTo()--总装等
            elseif InventSlot_To_ContainerSlot[slot] then--背包数
                local numFreeSlots = C_Container.GetContainerNumFreeSlots(InventSlot_To_ContainerSlot[slot])
                if numFreeSlots and not self.numFreeSlots then
                    self.numFreeSlots=e.Cstr(self,nil, nil, nil, true,nil, 'CENTER')
                    self.numFreeSlots:SetPoint('BOTTOM',0 ,6)
                end
                if self.numFreeSlots then
                    self.numFreeSlots:SetText(numFreeSlots or '')
                end
            end
        end
    end)
end
--加载保存数据
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
panel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
       Save= WoWToolsSave and WoWToolsSave[addName] or Save

        --添加控制面板        
        local sel=e.CPanel(addName, not Save.disabled)
        sel:SetScript('OnClick', function()
            Save.disabled = not Save.disabled and true or nil
            print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需求重新加载' or REQUIRES_RELOAD)
        end)

        if not Save.disabled then
            Init()
        else
            panel:UnregisterAllEvents()
        end
        panel:RegisterEvent("PLAYER_LOGOUT")

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
