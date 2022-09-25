local id, e = ...

local addName=CHARACTER
local Frame=PaperDollItemsFrame
local Save={}

local Icon={
    enchant=463531,--附魔图标
    use='soulbinds_tree_conduit_icon_utility',--物品 '使用' 图标
}

local function Sever()--显示服务名称
    local s=Frame.server
    if not Save.disabled and not s then
            s=e.Cstr(Frame)
            s:SetPoint('RIGHT', CharacterLevelText, 'LEFT')
            s:SetJustifyH('RIGHT')
            s:EnableMouse(true)
            s:SetScript("OnEnter",function(self)
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
                        e.tips:AddLine(ITEM_UNIQUE, SERVER_MESSAGE_PREFIX)
                    end
                    e.tips:Show()
            end)
            s:SetScript("OnLeave",function() e.tips:Hide() end)
            Frame.server=s
            s:SetText(e.Player.col..e.Player.server..'|r')
    end
    if s then
        s:SetShown(not Save.disabled)
    end
end

local function Slot(slot)--左边插曹
    return slot==1 or slot==2 or slot==3 or slot==15 or slot==5 or slot==4 or slot==19 or slot==9 or slot==17 or slot==18
end

local function Du(self, slot, link) --耐久度    
    local du
    if link and not Save.disabled then
        local min, max=GetInventoryItemDurability(slot)
        if min and max and max>0 then
            du=min/max*100
        end
    end
    if du then
        if not self.du then
            self.du=CreateFrame('StatusBar', nil, self)
            if Slot(slot) then
                self.du:SetPoint('LEFT', self, 'RIGHT', 2.5,0)
            else
                self.du:SetPoint('RIGHT', self, 'LEFT', -2.5,0)
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
        --[[if du and du<=50 then
            Lib.AutoCastGlow_Start(self.du, {0,1,0},  1, 0.10, 0.5)
        else
            Lib.AutoCastGlow_Stop(self.du)
        end]]
        self.du:SetShown(du and true or false)
    end
end

local function LvTo()--总装等
    local f=PaperDollSidebarTab1
    if not f then 
        return
    end
    local lv
    if not Save.disabled then
        local to, cu=GetAverageItemLevel()
        if to and cu then
            lv=to-cu
            if not f.lv then
                f.lv=e.Cstr(f)
                f.lv:SetPoint('BOTTOM')
            end
            f.lv:SetFormattedText('%i', to)
        end
    end
    if f.lv then f.lv:SetShown(lv) end
end

local function Lv(self, slot, link)--装等    
    local lv
    if not Save.disabled  then
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
                        local hex=select(4, GetItemQualityColor(quality))
                        if hex then
                            lv='|c'..hex..lv..'|r'
                        end
                    end
                end
            end
        end
    end
    if lv then
        if not self.lv then
            self.lv=e.Cstr(self)
            self.lv:SetPoint('BOTTOM', 0, 0)            
            self.lv:SetJustifyH('CENTER')
        end
        self.lv:SetText(lv)
    end     
    if self.lv then self.lv:SetShown(lv) end    
end

local function Gem(self, slot, link)--宝石
    local gems={}
    if link then
        for i=1,3 do
            local gemlink=select(2, GetItemGem(link, i))
            gems[i]=gemlink and C_Item.GetItemIconByID(gemlink) or nil
        end
    end
    local n=1
    for _, v in pairs(gems) do        
        local b=self['gem'..n]
        if v and not Save.disabled then
            if not b then
                local h=self:GetHeight()/3
                b=self:CreateTexture()
                b:SetSize(h,h)
                self['gem'..n]=b
            else
                b:ClearAllPoints()
            end
            if Slot(slot) then
                if n==1 then
                    b:SetPoint('BOTTOMLEFT', self, 'BOTTOMRIGHT', 8, (n-1)*9)
                else
                    b:SetPoint('BOTTOMLEFT', self['gem'..(n-1)], 'BOTTOMRIGHT', 0, 0)
                end
            else
                if n==1 then
                    b:SetPoint('BOTTOMRIGHT', self, 'BOTTOMLEFT', -8, (n-1)*9)
                else
                    b:SetPoint('BOTTOMRIGHT', self['gem'..(n-1)], 'BOTTOMLEFT', 0, 0)
                end
            end
            b:SetTexture(v)
            n=n+1
        end
        if b then b:SetShown(v and not Save.disabled) end
    end
end

local function recipeLearned(recipeSpellID)--是否已学配方
    local info= C_TradeSkillUI.GetRecipeInfo(recipeSpellID)
    return info and info.learned
end
local function Engineering(self, slot, use)--增加 [潘达利亚工程学: 地精滑翔器][诺森德工程学: 氮气推进器]    
    if not ((slot==15 and recipeLearned(126392)) or (slot==6 and recipeLearned(55016))) or use or self.engineering then
        return
    end
    self.engineering=e.Cbtn(self)
    local h=self:GetHeight()/3
    self.engineering:SetSize(h,h)
    self.engineering:SetNormalTexture(136243)
    if Slot(slot) then
        self.engineering:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)                                
    else
        self.engineering:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
    end
    self.engineering.spell= slot==15 and 126392 or 55016
    self.engineering:RegisterForClicks("LeftButtonDown","RightButtonDown")
    self.engineering:SetScript('OnClick' ,function(self2,d)
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
local enchantStr=ENCHANTED_TOOLTIP_LINE:gsub('%%s','')--附魔
local function Enchant(self, slot, link)--附魔, 使用, 属性
    local enchant, use
    if link and not Save.disabled then
        local tip = _G['ScannerTooltip'] or CreateFrame('GameTooltip', 'ScannerTooltip', self, 'GameTooltipTemplate')
        tip:SetOwner(self, "ANCHOR_NONE")
        tip:ClearLines()
        tip:SetHyperlink(link)

        for i=1, tip:NumLines() do
            local  line = _G['ScannerTooltipTextLeft'..i]
            if line then
                local msg = line:GetText()
                if msg then
                    if not enchant and msg:find(enchantStr) then--附魔
                        enchant=true
                    elseif not use and msg:find(ITEM_SPELL_TRIGGER_ONUSE) then--使用:
                        use=true
                    end
                end
            end
            if enchant and use then
                break
            end
        end
        if enchant and not self.enchant then
            local h=self:GetHeight()/3
            self.enchant=self:CreateTexture()
            self.enchant:SetSize(h,h)
            if Slot(slot) then
                self.enchant:SetPoint('LEFT', self, 'RIGHT', 8, 0)
            else
                self.enchant:SetPoint('RIGHT', self, 'LEFT', -8, 0)
            end
            self.enchant:SetTexture(Icon.enchant)
        end
        if use and not self.use then
            local h=self:GetHeight()/3
            self.use=self:CreateTexture()
            self.use:SetSize(h,h)
            if Slot(slot) then
                self.use:SetPoint('TOPLEFT', self, 'TOPRIGHT', 8, 0)
            else
                self.use:SetPoint('TOPRIGHT', self, 'TOPLEFT', -8, 0)
            end
            self.use:SetAtlas(Icon.use)
        end
        Engineering(self, slot, use)--地精滑翔,氮气推进器
    end
    if self.enchant then self.enchant:SetShown(enchant) end
    if self.use then self.use:SetShown(use) end
    if self.engineering then self.engineering:SetShown(not use and link) end
end

local function Set(self, slot, link)--套装
    local set
    if link and not Save.disabled then
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
    if link and not Save.disabled then
        local info=GetItemStats(link) or {}
        s=info['ITEM_MOD_CRIT_RATING_SHORT']
        h=info['ITEM_MOD_HASTE_RATING_SHORT']
        m=info['ITEM_MOD_MASTERY_RATING_SHORT']
        v=info['ITEM_MOD_VERSATILITY']

        if s then
            if not self.s then
                self.s=e.Cstr(self)
                self.s:SetText(e.WA_Utf8Sub(STAT_CRITICAL_STRIKE, 1):upper())
            else
                self.s:ClearAllPoints()
            end
            n=n+1
            SetP(self.s, n)
        end

        if h then
            if not self.h then
                self.h=e.Cstr(self)
                self.h:SetText(e.WA_Utf8Sub(STAT_HASTE, 1):upper())
            else
                self.h:ClearAllPoints()
            end
            n=n+1
            SetP(self.h, n)
        end
        if m  then
            if not self.m then
                self.m=e.Cstr(self)
                self.m:SetText(e.WA_Utf8Sub(STAT_MASTERY, 1):upper())
            else
                self.m:ClearAllPoints()
            end
            n=n+1
            SetP(self.m, n)
        end
        if v then
            if not self.v then
                self.v=e.Cstr(self)
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
    local f=PaperDollSidebarTab2
    local nu
    if f and PAPERDOLL_SIDEBARS[2].IsActive() and not Save.disabled then
        local to=GetKnownTitles() or {}
        nu= #to-1
        if nu>1 then
            if not f.nu then
                f.nu=e.Cstr(f)
                f.nu:SetPoint('BOTTOM')
            end
            f.nu:SetText(nu)
        else
            nu=nil
        end
    end
    if f and f.nu then f.nu:SetShown(nu) end
end

local function Equipment()--装备管理
    local f=PaperDollSidebarTab3
    if not f then
        return
    end
    local name, icon, specIcon,nu
    if not Save.disabled then
        local setIDs=C_EquipmentSet.GetEquipmentSetIDs()
        for _, v in pairs(setIDs) do 
            local name2, icon2, _, isEquipped, numItems= C_EquipmentSet.GetEquipmentSetInfo(v)            
            if isEquipped then                            
                name=name2
                if name:find('%w')  then
                    name=e.WA_Utf8Sub(name, 5)
                else
                    name=e.WA_Utf8Sub(name, 2)
                end
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
    end
    if name then
        if not f.set then
            f.set=e.Cstr(f)
            f.set:SetPoint('BOTTOM', 2, 0)
            f.set:SetJustifyH('CENTER')
        end
        f.set:SetText(name)
    end
    if f.set then f.set:SetShown(name) end

    if icon then--套装图标图标
        if not f.tex then
            f.tex=f:CreateTexture(nil, 'OVERLAY')
            f.tex:SetPoint('CENTER',1,-2)
            local w, h=f:GetSize()
            f.tex:SetSize(w-4, h-4)
        end
        f.tex:SetTexture(icon)
    end    
    if f.tex then f.tex:SetShown(icon) end

    if specIcon then--天赋图标
        if not f.spec then
            f.spec=f:CreateTexture(nil, 'OVERLAY')
            f.spec:SetPoint('BOTTOMLEFT', f, 'BOTTOMRIGHT')
            local h, w=f:GetSize()
            f.spec:SetSize(h/3+2, w/3+2)
        end
        f.spec:SetTexture(specIcon)
    end
    if f.spec then f.spec:SetShown(specIcon) end

    if nu then--套装数量
        if not f.nu then
            f.nu=e.Cstr(f)
            f.nu:SetPoint('LEFT', f, 'RIGHT',0, 4)
            f.nu:SetJustifyH('RIGHT')
        end
        f.nu:SetText(nu)
    end    
    if f.nu then f.nu:SetShown(nu) end
end


local function EquipmentStr(self)--套装已装备数量
    local setID=self.setID    
    local nu
    if setID and not Save.disabled then
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
local Equipmentframe
local function ADDEquipment(equipmentSetsDirty)--添加装备管理框
    local f=Equipmentframe
    if f then f:SetShown(Save.equipment) end
    if not Save.equipment or not PAPERDOLL_SIDEBARS[3].IsActive() then
        return
    end

    if not f then
        f=e.Cbtn(UIParent)--添加移动按钮
        f:SetSize(14, 14)
        f:SetNormalAtlas(e.Icon.icon)
        local p=Save.Equipment
        if p then
            f:SetPoint(p[1], UIParent, p[3], p[4], p[5])
        else
            f:SetPoint('BOTTOMRIGHT', Frame, 'TOPRIGHT')
        end
        f:RegisterForDrag("RightButton")
        f:SetClampedToScreen(true)
        f:SetMovable(true)
        f:EnableMouseWheel(true)
        f:SetScript("OnDragStart", function(self) if not IsModifierKeyDown() then  self:StartMoving() end end)
        f:SetScript("OnDragStop", function(self)
                ResetCursor()
                self:StopMovingOrSizing()
                Save.Equipment={self:GetPoint(1)}
                print(addName..'\n'..    GEARSETS_TITLE..': .|cFF00FF00Alt+'..e.Icon.right..KEY_BUTTON2..'|r='.. TRANSMOGRIFY_TOOLTIP_REVERT)
        end)
        f:SetScript("OnMouseUp", function() ResetCursor() end)
        f:SetScript("OnMouseDown", function(self,d)
                local key=IsModifierKeyDown()
                local alt=IsAltKeyDown()
                if d=='RightButton' and alt then--还原位置
                    Save.Equipment=nil
                    self:ClearAllPoints()
                    self:SetPoint('TOPLEFT', Frame, 'TOPRIGHT')

                elseif d=='RightButton' and not key then--移动图标
                    SetCursor('UI_MOVE_CURSOR')

                elseif d=='LeftButton' and alt then--图标横,或 竖
                    if Save.EquipmentH then
                        Save.EquipmentH=nil
                    else
                        Save.EquipmentH=true
                    end
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
        f:SetScript('OnMouseWheel',function(self, d)--放大
                local n=Save.equipmentSize or 20
                if d==1 then
                    n=n+2
                elseif d==-1 then
                    n=n-2
                end
                if n>60 then
                    n=60
                elseif n<6 then
                    n=6
                end
                Save.equipmentSize=n
                setEquipmentSize(self)
                print(addName..ZOOM_IN..': '..GREEN_FONT_COLOR_CODE..n..'|r')
        end)
        f:SetScript("OnEnter", function (self)
            if UnitAffectingCombat('player') then
                return
            end
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddDoubleLine(id, EQUIPMENT_MANAGER)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(BINDING_NAME_TOGGLECHARACTER0, e.Icon.left)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(Save.EquipmentH and BINDING_NAME_STRAFERIGHT or BINDING_NAME_PITCHDOWN, 'Alt + '..e.Icon.left)
            e.tips:AddDoubleLine(NPE_MOVE, e.Icon.right)
            e.tips:AddDoubleLine(ZOOM_IN..'/'..ZOOM_OUT..': '..(Save.equipmentSize and Save.equipmentSize or 1), e.Icon.mid)
            e.tips:Show()
        end)
        f:SetScript("OnLeave", function()
                ResetCursor()
                e.tips:Hide()
        end)
        Equipmentframe=f
    end
    --if Save.equipmentSize and Save.equipmentSize<=1 then f:SetScale(Save.equipmentSize) end--放大

    f.B=f.B or {}--添加装备管理按钮
    local b2, index=nil, 1
    f.setIDs= (not f.setIDs or equipmentSetsDirty) and SortEquipmentSetIDs(C_EquipmentSet.GetEquipmentSetIDs()) or f.setIDs
    for k, id2 in pairs(f.setIDs) do
        local texture, setID, isEquipped= select(2, C_EquipmentSet.GetEquipmentSetInfo(id2))
        local b=f.B[k]
        if not b then
            b=e.Cbtn(f)
            b.tex=b:CreateTexture(nil, 'OVERLAY')
            b.tex:SetAtlas(e.Icon.select)
            b.tex:SetAllPoints(b)
           -- b:SetSize(20, 20)
            EPoint(b, f ,b2)--设置位置

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
        f.B[k]=b
        index=k+1
        b2=b
    end
    setEquipmentSize(f, index)--隐然多除的, 设置大小
    LvTo()--总装等
end

hooksecurefunc('PaperDollItemSlotButton_Update',  function(self)--PaperDollFrame.lua
            local slot= self:GetID()
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
            end
end)

local function setFlyoutLevel(button, level, paperDollItemSlot)--装备弹出 
    if level and not button.level then
        button.level=e.Cstr(button)
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
        button.upLevel=e.Cstr(button, 16)
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
		itemLink = GetVoidItemHyperlinkString(tab, voidSlot);

	elseif ( not bags ) then -- and (player or bank)
		itemLink =GetInventoryItemLink("player",slot);
	else -- bags
		itemLink = GetContainerItemLink(bag, slot);
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
hooksecurefunc('PaperDollEquipmentManagerPane_Update',ADDEquipment)----添加装备管理框        

Frame.sel = e.Cbtn(Frame, nil, not Save.disabled)--总开关
Frame.sel:SetSize(20, 20)
Frame.sel.Text=e.Cstr(Frame)
Frame.sel.Text:SetPoint('LEFT', Frame.sel, 'RIGHT')
Frame.sel2 = e.Cbtn(Frame, nil, Save.equipment)--显示/隐藏装备管理框选项

local function GetDurationTotale()--装备总耐久度
    local cu, max=0,0
    if not Save.disabled then
        for slot, _ in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
            local cu2, max2= GetInventoryItemDurability(slot)
            if cu2 and max2 and max2>0 then
                cu = cu+ cu2
                max= max + max2
            end
        end
    end
    local du=''
    if max>0 then
        local to=cu/max*100
        du=('%i'):format(to)
        if to<30 then
            du=RED_FONT_COLOR_CODE..du..'|r'
        elseif to<60 then
            du=YELLOW_FONT_COLOR_CODE..du..'|r'
        end
        Frame.sel.DuVal=math.modf(to)
    else
        Frame.sel.DuVal=nil
    end
    Frame.sel.Text:SetText(du)
end


local function SetIni()
    ADDEquipment()--装备管理框
    GetDurationTotale()--装备总耐久度        
    Frame.sel:SetNormalAtlas(Save.disabled and e.Icon.disabled or e.Icon.icon)
    Frame.sel:SetAlpha(Save.disabled and 0.3 or 1)
    Frame.sel2:SetNormalAtlas(Save.equipment and e.Icon.icon or e.Icon.disabled)
    Frame.sel2:SetAlpha(Save.equipment and 0.3 or 1)
    Sever()--服务器名称
end
Frame.sel:SetPoint('BOTTOMLEFT',5,7)
Frame.sel:SetScript("OnClick", function ()
        local m
        if Save.disabled then
            Save.disabled=nil
            m=addName..': '..GREEN_FONT_COLOR_CODE..SHOW..'|r '
        else
            Save.disabled=true
            m=addName..': '..RED_FONT_COLOR_CODE..HIDE..'|r '
        end
        m=m..'('..YELLOW_FONT_COLOR_CODE..NEED..REFRESH..'|r)'
        print(m)
        SetIni()
end)
Frame.sel:SetScript("OnEnter", function (self)
    GetDurationTotale()
        e.tips:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        if self.DuVal and self.DuVal~='' then
            e.tips:AddDoubleLine(DURABILITY, self.DuVal..'%')
        end
        e.tips:AddDoubleLine(SHOW..'/'..HIDE, Save.disabled and HIDE or SHOW, nil,nil,nil, 0,1,0)
        e.tips:Show()
end)
Frame.sel:SetScript("OnLeave",function(self)
        e.tips:Hide()
end)

Frame.sel2:SetPoint('TOPRIGHT',-2,-40)
Frame.sel2:SetSize(20, 20)

Frame.sel2:SetScript("OnClick", function(self)
        if Save.equipment then
            Save.equipment=nil
        else
            Save.equipment=true
        end
        SetIni()
end)
Frame.sel2:SetScript("OnEnter", function (self)
        e.tips:SetOwner(self, "ANCHOR_TOPLEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, addName)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(ADD, EQUIPMENT_MANAGER)
        e.tips:AddDoubleLine(SHOW..'/'..HIDE, Save.equipment and SHOW or HIDE, nil,nil,nil, 0,1,0)
        e.tips:Show()
end)
Frame.sel2:SetScript("OnLeave",function(self)
        e.tips:Hide()
end)

--加载保存数据
Frame.sel:RegisterEvent("ADDON_LOADED")
Frame.sel:RegisterEvent("PLAYER_LOGOUT")
Frame.sel:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
Frame.sel:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

Frame.sel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == id then
       Save= (WoWToolsSave and WoWToolsSave[addName]) and WoWToolsSave[addName] or Save
       SetIni()
    elseif event == "PLAYER_LOGOUT" then
        if not WoWToolsSave then WoWToolsSave={} end
		WoWToolsSave[addName]=Save
    elseif event == 'EQUIPMENT_SWAP_FINISHED' then
        C_Timer.After(0.6, ADDEquipment)
    elseif event=='UPDATE_INVENTORY_DURABILITY' then
        GetDurationTotale()--装备总耐久度
    end
end)