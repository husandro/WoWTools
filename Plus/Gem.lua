local id, e = ...
local addName= SOCKET_GEMS
local Save={
    --hide=true,--显示，隐藏 Frame
    --scale=1,--缩放
    favorites={},--{itemID=true},
    gemLeft={},--右边，按钮
    gemTop={},
    gemRight={},
    disableSpell=true,--禁用，法术按钮
    gemLoc= {}--{class={['INVSLOT_LEGS']={1=gemID, 2=gemID, 3=gemID}}
}








local panel=CreateFrame("Frame")
local Frame
local SpellButton
local Initializer
local SpellsTab={
    433397,--取出宝石
    --405805,--拔出始源之石
}


for _, spellID in pairs(SpellsTab) do
    e.LoadData({id=spellID, type='spell'})
end
local AUCTION_CATEGORY_GEMS= AUCTION_CATEGORY_GEMS
local CurTypeGemTab={}--当前，宝石，类型
local function Get_Item_Color(itemLink)
    local r,g,b
    if itemLink then
        local itemQuality= select(3, C_Item.GetItemInfo(itemLink))
        if itemQuality then
            r,g,b = C_Item.GetItemQualityColor(itemQuality)
        end
    end
    return r or 1, g or 1, b or 1
end
local function set_point()
    ItemSocketingScrollFrame:SetPoint('BOTTOMRIGHT', -22, 90)
    ItemSocketingScrollChild:ClearAllPoints()
    ItemSocketingScrollChild:SetPoint('TOPLEFT')
    ItemSocketingScrollChild:SetPoint('TOPRIGHT', -18, -254)
    ItemSocketingDescription:SetPoint('LEFT')
    ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollChild:GetWidth()-18, true)--调整，宽度
    ItemSocketingDescription:SetSocketedItem()
end

--保存，slot, 数据
local function set_save_gem(itemEquipLoc, gemLink, index)
    if not itemEquipLoc then
        return
    end
    Save.gemLoc[e.Player.class][itemEquipLoc]= Save.gemLoc[e.Player.class][itemEquipLoc] or {}
    local gemID
    if gemLink then
        gemID= C_Item.GetItemInfoInstant(gemLink)
        if gemID then
            Save.gemLoc[e.Player.class][itemEquipLoc][index]= gemID
        end
    end

    gemID= gemID or Save.gemLoc[e.Player.class][itemEquipLoc][index]
    Save.gemLoc[e.Player.class][itemEquipLoc][index]= gemID
    return gemID
end












--[[local GEM_TYPE_INFO =	{
    Yellow = EMPTY_SOCKET_YELLOW,--黄色插槽',
    Red = EMPTY_SOCKET_RED,--红色插槽',
    Blue = EMPTY_SOCKET_BLUE,--蓝色插槽',
    Hydraulic = EMPTY_SOCKET_HYDRAULIC,--染煞',
    Cogwheel = EMPTY_SOCKET_COGWHEEL,--齿轮插槽',
    Meta = EMPTY_SOCKET_META,--多彩插槽',
    Prismatic =EMPTY_SOCKET_PRISMATIC,--棱彩插槽',
    PunchcardRed = EMPTY_SOCKET_PUNCHCARDRED,--红色打孔卡插槽',
    PunchcardYellow = EMPTY_SOCKET_PUNCHCARDYELLOW,--黄色打孔卡插槽',
    PunchcardBlue = EMPTY_SOCKET_PUNCHCARDBLUE,--蓝色打孔卡插槽',
    Domination = EMPTY_SOCKET_DOMINATION,--统御插槽',
    Cypher = EMPTY_SOCKET_CYPHER,--晶态插槽',
    Tinker = EMPTY_SOCKET_TINKER,--匠械插槽',
    Primordial = EMPTY_SOCKET_PRIMORDIAL,--始源镶孔',
}--EMPTY_SOCKET_NO_COLOR,--棱彩插槽]]


local function creatd_button(index, parent)
    local btn= WoWTools_ButtonMixin:Cbtn(parent or Frame, {button='ItemButton', icon='hide'})--34, 34

    btn.level=WoWTools_LabelMixin:CreateLabel(btn)
    btn.level:SetPoint('TOPRIGHT')
    btn.type= WoWTools_LabelMixin:CreateLabel(btn)
    btn.type:SetPoint('LEFT', btn, 'RIGHT')
    btn.favorite= btn:CreateTexture(nil, 'OVERLAY', nil, 2)
    btn.favorite:SetSize(17,17)
    btn.favorite:SetAtlas('auctionhouse-icon-favorite')
    btn.favorite:SetPoint('TOPRIGHT',4,4)
    btn.favorite:SetVertexColor(0,1,0)

    btn:Hide()
    function btn:set_event()
        if self:IsShown() then
            self:RegisterEvent('ITEM_LOCKED')
            self:RegisterEvent('ITEM_UNLOCKED')
            self:RegisterEvent('SOCKET_INFO_UPDATE')
        else
            self:UnregisterAllEvents()
        end
    end
    btn:SetScript('OnHide', btn.set_event)
    btn:SetScript('OnShow', btn.set_event)

    function btn:set_favorite()
        self.favorite:SetShown(Save.favorites[self.itemID])
    end
    function btn:set_alpha()
        local alpha= 1
        local info
        if self.bagID then
            info = C_Container.GetContainerItemInfo(self.bagID, self.slotID)
        end
        if not info then
            alpha=0
        elseif info.isLocked then
            alpha=0.3
        end
        self:SetAlpha(alpha)
    end
    function btn:rest()
        self:SetShown(false)
        self:Reset()
        self.bagID=nil
        self.slotID=nil
        self.itemID=nil
        self.type:SetText('')
        self.level:SetText('')
    end
    btn:SetScript('OnEvent', btn.set_alpha)
    function btn:set_tooltips()
        if self.bagID then
            e.tips:SetOwner(ItemSocketingFrame, 'ANCHOR_BOTTOMRIGHT')
            e.tips:ClearLines()
            e.tips:SetBagItem(self.bagID, self.slotID)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
            e.tips:AddDoubleLine((e.onlyChinese and '左边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT)..format('|A:%s:0:0|a', e.Icon.toRight), 'Alt+'..e.Icon.left)
            e.tips:AddDoubleLine((e.onlyChinese and '上面' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP)..'|A:bags-greenarrow:0:0|a', 'Alt+'..e.Icon.mid)
            e.tips:AddDoubleLine((e.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT)..format('|A:%s:0:0|a', e.Icon.toLeft), 'Alt+'..e.Icon.right)
            e.tips:Show()
        end
    end
    btn:SetScript('OnClick', function(self, d)
        if not self.bagID or not self.itemID then
            return
        end
        ClearCursor()
        if IsAltKeyDown() then
            if d=='LeftButton' then
                Save.gemLeft[self.itemID]= not Save.gemLeft[self.itemID] and true or nil
                panel:set_Gem()
            elseif d=='RightButton' then
                Save.gemRight[self.itemID]= not Save.gemRight[self.itemID] and true or nil
                panel:set_Gem()
            end
        elseif d=='LeftButton' then
            C_Container.PickupContainerItem(self.bagID, self.slotID)
        elseif d=='RightButton' then
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '标记' or EVENTTRACE_BUTTON_MARKER,
                        icon='auctionhouse-icon-favorite',
                        checked= Save.favorites[self.itemID],
                        func= function()
                            Save.favorites[self.itemID]= not Save.favorites[self.itemID] and true or nil
                            self:set_favorite()
                            print(e.addName, Initializer:GetName(), Save.favorites[self.itemID] and self.itemID or '', e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
                            panel:set_Gem()
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '左边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT,
                        icon= e.Icon.toRight,
                        checked=Save.gemLeft[self.itemID],
                        func= function()
                            Save.gemLeft[self.itemID]= not Save.gemLeft[self.itemID] and true or nil
                            panel:set_Gem()
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '上面' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP,
                        icon= 'bags-greenarrow',
                        checked=Save.gemTop[self.itemID],
                        func= function()
                            Save.gemTop[self.itemID]= not Save.gemTop[self.itemID] and true or nil
                            panel:set_Gem()
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT,
                        icon= e.Icon.toLeft,
                        checked=Save.gemRight[self.itemID],
                        func= function()
                            Save.gemRight[self.itemID]= not Save.gemRight[self.itemID] and true or nil
                            panel:set_Gem()
                        end
                    }, level)
                end, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
        self:set_tooltips()
    end)
    btn:SetScript("OnMouseWheel", function(self)
        if IsAltKeyDown() then
            Save.gemTop[self.itemID]= not Save.gemTop[self.itemID] and true or nil
            panel:set_Gem()
        end
    end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltips()
        if self.bagID then
            WoWTools_BagMixin:Find(true, {bag={bag=self.bagID, slot=self.slotID}})
        end
    end)
    btn:SetScript('OnLeave', function(self)
        GameTooltip_Hide()
        WoWTools_BagMixin:Find()
    end)
    if index then
        Frame.buttons[index]= btn
    end
    return btn
end

























local function Set_Button_Att(btn, info)
    info= info or {}
    local itemLink= info.info.hyperlink
    local itemID= info.info.itemID
    btn.bagID= info.bag
    btn.slotID= info.slot
    btn.itemID= itemID
    btn.level:SetText(info.level and info.level>1 and info.level or '')
    btn.level:SetTextColor(Get_Item_Color(itemLink))
    btn:set_favorite()
    btn:SetItem(itemLink)
    btn:SetItemButtonCount(info.info.stackCount)
    WoWTools_ItemStatsMixin:Gem(btn, itemLink)
    btn:SetShown(true)
end



local function Set_Sort_Button(tab)
    table.sort(tab, function(a, b)
        if a.favorite and not b.favorite then
            return true
        elseif a.expacID> b.expacID then
            return true
        elseif a.info.quality== b.info.quality then
            if a.level== b.level then
                return a.info.itemID> b.info.itemID
            else
                return a.level>b.level
            end
        else
            return a.info.quality>b.info.quality
        end
    end)
end

function panel:set_Gem()--Blizzard_ItemSocketingUI.lua MAX_NUM_SOCKETS
    local items, gemLeft, gemTop, gemRight= {}, {}, {}, {}
    local scale= Save.scale or 1

    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do-- + NUM_REAGENTBAG_FRAMES do
        for slot=1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info
                and info.hyperlink
                and info.itemID
                and info.quality
            then
                local level= C_Item.GetDetailedItemLevelInfo(info.hyperlink) or 0
                local classID, subclassID, _, expacID= select(12, C_Item.GetItemInfo(info.hyperlink))
                if classID==3
                    and (e.Is_Timerunning or (e.Player.levelMax and e.ExpansionLevel== expacID or not e.Player.levelMax))--最高等级
                then
                    local tab={
                        info= info,
                        bag=bag,
                        slot=slot,
                        level= level or 0,
                        expacID= expacID or 0,
                        favorite= Save.favorites[info.itemID]
                    }
                    if Save.gemLeft[info.itemID] then
                        table.insert(gemLeft, tab)

                    elseif Save.gemTop[info.itemID] then
                        table.insert(gemTop, tab)

                    elseif Save.gemRight[info.itemID] then
                        table.insert(gemRight, tab)
                    else
                        local type
                        if e.Is_Timerunning then
                            local date= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, index=2})
                            type= date.indexText and date.indexText:match('|c........(.-)|r') or date.indexText
                        else
                            type=e.cn(C_Item.GetItemSubClassInfo(classID, subclassID))
                        end
                        type=type or ' '
                        items[type]= items[type] or {}
                        table.insert(items[type], tab)
                    end
                end
            end
        end
    end
    for _, tab in pairs(items) do
        Set_Sort_Button(tab)
    end
    local x, y, index= 0, 0, 1
    for type, tab in pairs(items) do
        for i, info in pairs(tab) do
            local btn= Frame.buttons[index] or creatd_button(index)
            btn:ClearAllPoints()
            btn:SetPoint('TOPRIGHT', x, y)
            if i==1 then
                local findGem
                local gemName= type:gsub(AUCTION_CATEGORY_GEMS, '')
                for name in pairs(CurTypeGemTab or {}) do
                    if name:find(gemName) then
                        type= format('|cnGREEN_FONT_COLOR:%s|r', type or '')
                        findGem=true
                        break
                    end
                end
                btn.type:SetText(type or '')
                btn.type:SetScale(findGem and 1.35 or 1)
            else
                btn.type:SetText('')
            end
            Set_Button_Att(btn, info)
            x=x-40
            index= index+1
        end
        x=0
        y=y-40
    end

    x, y= -10, 0--左边
    local w, h= ItemSocketingFrame:GetSize()
    Set_Sort_Button(gemLeft)
    for _, info in pairs(gemLeft) do
        local btn= Frame.buttons[index] or creatd_button(index)
        btn:ClearAllPoints()
        btn:SetPoint('TOPRIGHT', ItemSocketingFrame, 'TOPLEFT', x, y)
        btn.type:SetText('')
        Set_Button_Att(btn, info)
        y=y-40
        if h<=(-y*scale+40) then
            y=0
            x=x-40
        end
        index= index+1
    end

    x, y= 0, 10--TOP
    Set_Sort_Button(gemTop)
    for _, info in pairs(gemTop) do
        local btn= Frame.buttons[index] or creatd_button(index)
        btn:ClearAllPoints()
        btn:SetPoint('BOTTOMRIGHT', ItemSocketingFrame, 'TOPRIGHT', x, y)
        btn.type:SetText('')
        Set_Button_Att(btn, info)
        x=x-40
        if w<= (-x*scale+40) then
            x=0
            y=y+40
        end
        index= index+1
    end


    x, y= 10, 0--右边
    Set_Sort_Button(gemRight)
    for _, info in pairs(gemRight) do
        local btn= Frame.buttons[index] or creatd_button(index)
        btn:ClearAllPoints()
        btn:SetPoint('TOPLEFT', ItemSocketingFrame, 'TOPRIGHT', x, y)
        btn.type:SetText('')
        Set_Button_Att(btn, info)
        y=y-40
        if h<= (-y*scale+40) then
            y=0
            x=x+40
        end
        index= index+1
    end

    for i= index, #Frame.buttons, 1 do
        local btn= Frame.buttons[i]
        if btn then btn:rest() end
    end
end




















--433397/取出宝石
local function Init_Spell_Button()
    if Save.disableSpell then
        return
    end
    SpellButton= WoWTools_ButtonMixin:Cbtn(Frame, {size={32,32}, icon='hide', type=true})
    SpellButton:Hide()
    --SpellButton:SetPoint('LEFT', ItemSocketingSocket3, 'RIGHT', 4,0)
    --SpellButton:SetPoint('BOTTOMRIGHT', -4, 42)--, ItemSocketingSocketButton, 'TOPRIGHT', 20, 10)
    SpellButton:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 4, 4)
    SpellButton.texture= SpellButton:CreateTexture(nil, 'OVERLAY')
    SpellButton.texture:SetAllPoints(SpellButton)
    SpellButton.count=WoWTools_LabelMixin:CreateLabel(SpellButton, {color={r=1,g=1,b=1}})--nil,nil,nil,true)
    SpellButton.count:SetPoint('BOTTOMRIGHT',-2, 9)

    function SpellButton:set_count()
        local data= self.spellID and C_Spell.GetSpellCharges(self.spellID) or {}
        local num, max= data.currentCharges, data.maxCharges
        self.count:SetText((max and max>1) and num or '')
        self.texture:SetDesaturated(num and num>0)
    end
    SpellButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        if self.spellID then
            e.tips:SetSpellByID(self.spellID)
        elseif self.action then
            e.tips:SetAction(self.action)
        end
        e.tips:Show()
    end)
    SpellButton:SetScript('OnLeave', GameTooltip_Hide)
    SpellButton:SetScript("OnEvent", function(self, event)
        if event=='SPELL_UPDATE_USABLE' then
            self:set_count()
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            e.SetItemSpellCool(self, {spell=self.spellID})
        elseif event=='ACTIONBAR_UPDATE_STATE' then
            self:set()
        elseif event=='PLAYER_REGEN_ENABLED' then
            self:set()
            self:UnregisterEvent('PLAYER_REGEN_ENABLED')
        end
    end)

    SpellButton:SetScript('OnShow', function(self)
        self:RegisterEvent('SPELL_UPDATE_USABLE')
        self:RegisterEvent('SPELL_UPDATE_COOLDOWN')
        e.SetItemSpellCool(self, {spell=self.spellID})
        self:set_count()
    end)
    SpellButton:SetScript('OnHide', SpellButton.UnregisterAllEvents)



    function SpellButton:set()
        if not self:CanChangeAttribute() then
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
            return
        end

        local spellID, action
        for _, spell in pairs(SpellsTab) do
            if IsSpellKnownOrOverridesKnown(spell) then                
                local name= C_Spell.GetSpellName(spell)
                local icon= C_Spell.GetSpellTexture(spell)
                self:SetAttribute("type", "spell")
                self:SetAttribute("spell", name or spell)
                self:SetAttribute("action", nil)
                self.texture:SetTexture(icon or 0)
                spellID=spell
                break
            end
        end
        if not spellID and HasExtraActionBar() then
            local i = 1
            local slot = i + ((GetExtraBarIndex() or 19) - 1) * (NUM_ACTIONBAR_BUTTONS or 12)
            local actionType, spell = GetActionInfo(slot)
            if actionType== "spell" and spell then--and ActionTab[spell] then
                self:SetAttribute("type", "action")
                self:SetAttribute("action", slot)
                self:SetAttribute("spell", nil)
                self.texture:SetTexture(GetActionTexture(slot) or 0)
                action= slot
                spellID= spell
            end
        end

        self:SetShown((spellID or action) and true or false)
        self.spellID= spellID
        self.action= action
    end

    SpellButton:set()
    ItemSocketingFrame:HookScript('OnShow', function()
        SpellButton:RegisterEvent('ACTIONBAR_UPDATE_STATE')
        SpellButton:set()
    end)
    ItemSocketingFrame:HookScript('OnHide', function()
        SpellButton:UnregisterAllEvents()
    end)
end
















































--宝石，数据
local function Init_ItemSocketingFrame_Update()
    local numSockets = GetNumSockets() or 0
    CurTypeGemTab={}
    local itemEquipLoc
    if e.Is_Timerunning then
        local link, itemID= select(2, ItemSocketingDescription:GetItem())
        itemEquipLoc= itemID and select(4, C_Item.GetItemInfoInstant(itemID))
        if itemEquipLoc then
            if itemEquipLoc=='INVTYPE_TRINKET' then--13, 14
                itemEquipLoc= itemEquipLoc..(GetInventoryItemLink('player', 13)==link and 13 or 14)
            elseif itemEquipLoc=='INVTYPE_FINGER' then--11, 12
                itemEquipLoc= itemEquipLoc..(GetInventoryItemLink('player', 11)==link and 11 or 12)
            elseif itemEquipLoc=='INVTYPE_WEAPON' then--16, 17
                itemEquipLoc= itemEquipLoc..(GetInventoryItemLink('player', 16)==link and 16 or 17)
            end
            if not Save.gemLoc[e.Player.class][itemEquipLoc] then
                Save.gemLoc[e.Player.class][itemEquipLoc]={}
            end
        end
    end

    for i, btn in ipairs(ItemSocketingFrame.Sockets) do--插槽，名称
        if ( i <= numSockets ) then
            local name= GetSocketTypes(i)
            name= name and _G['EMPTY_SOCKET_'..string.upper(name)]
            if name then
                local text= EMPTY_SOCKET_BLUE:gsub(BLUE_GEM, '')
                if text and text~='' then
                    name= name:gsub(text, '')
                end
                CurTypeGemTab[name]=true
            end
            if not btn.type then
                btn.type=WoWTools_LabelMixin:CreateLabel(btn)
                btn.type:SetPoint('BOTTOM', btn, 'TOP', 0, 2)
                btn.qualityTexture= btn:CreateTexture(nil, 'OVERLAY')
                if e.Is_Timerunning then
                    btn.qualityTexture:SetPoint('CENTER')
                    btn.qualityTexture:SetSize(46,46)--40
                else
                    btn.qualityTexture:SetPoint('RIGHT', btn, 'LEFT',15,-8)
                    btn.qualityTexture:SetSize(30,30)
                end
                btn.levelText=WoWTools_LabelMixin:CreateLabel(btn)
                btn.levelText:SetPoint('CENTER')
                btn.leftText=WoWTools_LabelMixin:CreateLabel(btn)
                btn.leftText:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')
                btn.rightText=WoWTools_LabelMixin:CreateLabel(btn)
                btn.rightText:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT')

                btn.gemButton=WoWTools_ButtonMixin:Cbtn(btn, {button='ItemButton', icon='hide'})--使用过宝石，提示
                btn.gemButton:SetPoint('BOTTOMLEFT', btn, 'BOTTOMRIGHT', 6, 0)
                btn.gemButton:Hide()
                function btn.gemButton:set_event()
                    if self:IsShown() then
                        self:RegisterEvent('BAG_UPDATE_DELAYED')
                    else
                        self:UnregisterAllEvents()
                    end
                end
                function btn.gemButton:settings()
                    local count= self.gemID and C_Item.GetItemCount(self.gemID, false, false, false) or 0
                    self:SetItemButtonCount(count)
                    self:SetEnabled(count>0)
                    self:SetAlpha(count>0 and 1 or 0.3)
                end
                btn.gemButton:SetScript('OnEvent', btn.gemButton.settings)
                btn.gemButton:SetScript('OnShow',  btn.gemButton.set_event)
                btn.gemButton:SetScript('OnHide',  btn.gemButton.set_event)
                btn.gemButton:SetScript('OnLeave', function(self)
                    WoWTools_BagMixin:Find(false)
                end)
                btn.gemButton:SetScript('OnEnter', function(self)
                    WoWTools_BagMixin:Find(true, {itemID=self.gemID})
                end)
                btn.gemButton:SetScript('OnClick', function(self)
                    for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES do
                        for slot=1, C_Container.GetContainerNumSlots(bag) do
                            local info = C_Container.GetContainerItemInfo(bag, slot)
                            if info and info.itemID==self.gemID then
                                ClearCursor()
                                C_Container.PickupContainerItem(bag, slot)
                                break
                            end
                        end
                    end
                end)
            end

            local gemLinkExist= GetExistingSocketLink(i)
            local gemLink= GetNewSocketLink(i) or gemLinkExist
            local left, right= WoWTools_ItemStatsMixin:Gem(nil, gemLink)
            local atlas
            if gemLink then
                if e.Is_Timerunning then
                    local quality= C_Item.GetItemQualityByID(gemLink)--C_Item.GetItemQualityColor(quality)
                    atlas= e.Icon[quality]
                else
                    local quality= C_TradeSkillUI.GetItemReagentQualityByItemInfo(gemLink) or C_TradeSkillUI.GetItemCraftedQualityByItemInfo(gemLink)
                    if quality then
                        atlas = ("Professions-Icon-Quality-Tier%d-Inv"):format(quality)
                    end
                end
            end

            btn.type:SetText(name or '')
            btn.leftText:SetText(left or '')
            btn.rightText:SetText(right or '')
            local itemLevel= gemLink and C_Item.GetDetailedItemLevelInfo(gemLink) or 1
            btn.levelText:SetText(itemLevel>10 and itemLevel or '')
            btn.levelText:SetTextColor(Get_Item_Color(gemLink))
            if atlas then
                btn.qualityTexture:SetAtlas(atlas)
            else
                btn.qualityTexture:SetTexture(0)
            end

            local gemID--使用过宝石，提示
            if itemEquipLoc then
                gemID= set_save_gem(itemEquipLoc, gemLinkExist, i)--保存，slot, 数据
            end
            btn.gemButton.gemID= gemID
            btn.gemButton:settings()
            btn.gemButton:SetItem(gemID)
            btn.gemButton:SetShown(gemID and true or false )
        end
    end

    if numSockets==1 then--宝石，位置
        ItemSocketingSocket1:ClearAllPoints()
        ItemSocketingSocket1:SetPoint('BOTTOM', 0, 33)
    elseif numSockets==2 then
        ItemSocketingSocket1:ClearAllPoints()
        ItemSocketingSocket1:SetPoint('BOTTOM', -60, 33)
        ItemSocketingSocket2:ClearAllPoints()
        ItemSocketingSocket2:SetPoint('BOTTOM', 60, 33)
    elseif numSockets==3 then
        ItemSocketingSocket1:ClearAllPoints()
        ItemSocketingSocket1:SetPoint('BOTTOMLEFT', 50, 33)
        ItemSocketingSocket2:ClearAllPoints()
        ItemSocketingSocket2:SetPoint('BOTTOM', 0, 33)
        ItemSocketingSocket3:ClearAllPoints()
        ItemSocketingSocket3:SetPoint('BOTTOMRIGHT', -50, 33)
    end
    set_point()
    panel:set_Gem()
end





























--总开关
local function Init_Button_All()
    local btn= WoWTools_ButtonMixin:Cbtn(ItemSocketingFrame.TitleContainer, {size=22, icon='hide'})
    btn:SetPoint('LEFT', 26)
    function btn:set_texture()
        btn:SetNormalAtlas(Save.hide and e.Icon.disabled or e.Icon.icon)
    end
    function btn:set_shown()
        if Frame:CanChangeAttribute() then
            Frame:SetShown(not Save.hide)
            self:set_texture()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    function btn:set_scale()
        if Frame:CanChangeAttribute() then
            Frame:SetScale(Save.scale or 1)
            panel:set_Gem()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    function btn:set_tooltips()
        if not Frame:CanChangeAttribute() then
            e.tips:Hide()
            return
        end
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.addName, Initializer:GetName())
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.GetShowHide(not Save.hide), e.Icon.left)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.scale or 1), e.Icon.mid)
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, e.Icon.right)
        e.tips:Show()
    end
    btn:SetAlpha(0.5)
    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.5) e.tips:Hide() end)
    btn:SetScript('OnEnter', function(self)
        self:set_tooltips()
        self:SetAlpha(1)
    end)
    btn:SetScript('OnEvent', function(self)
        self:set_scale()
        self:set_shown()
        self:UnregisterAllEvents()
    end)
    btn:SetScript('OnClick', function(self, d)
        if d=='LeftButton' then
            Save.hide= not Save.hide and true or nil
            self:set_shown()
            self:set_texture()
            self:set_tooltips()
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=e.onlyChinese and '显示' or SHOW,
                        checked=not Save.hide,
                        keepShownOnClick=true,
                        disabled=not Frame:CanChangeAttribute(),
                        func=function()
                            Save.hide= not Save.hide and true or nil
                            self:set_shown()
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddButton({
                        text= format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, e.onlyChinese and '法术' or SPELLS, 'Button'),
                        checked=not Save.disableSpell,
                        keepShownOnClick=true,
                        func= function()
                            Save.disableSpell= not Save.disableSpell and true or nil
                            print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disableSpell), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    local num= 0
                    for _ in pairs(Save.favorites) do
                        num= num+1
                    end
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=(e.onlyChinese and '清除标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_BUTTON_MARKER))..' |cnGREEN_FONT_COLOR:#'..num,
                        icon='auctionhouse-icon-favorite',
                        colorCode= num==0 and '|cff9e9e9e',
                        notCheckable=true,
                        func=function()
                            Save.favorites={}
                            for _, frame in pairs(Frame.buttons) do
                                frame:set_favorite()
                            end
                            print(e.addName, Initializer:GetName(), e.onlyChinese and '完成' or COMPLETE)
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    num= 0
                    for _ in pairs(Save.gemLeft) do
                        num= num+1
                    end
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=(e.onlyChinese and '清除左边' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT))..' |cnGREEN_FONT_COLOR:#'..num,
                        icon=e.Icon.toRight,
                        colorCode= num==0 and '|cff9e9e9e',
                        notCheckable=true,
                        func=function()
                            Save.gemLeft={}
                            panel:set_Gem()
                        end
                    }, level)

                    num= 0
                    for _ in pairs(Save.gemTop) do
                        num= num+1
                    end
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=(e.onlyChinese and '清除上面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP))..' |cnGREEN_FONT_COLOR:#'..num,
                        icon='bags-greenarrow',
                        colorCode= num==0 and '|cff9e9e9e',
                        notCheckable=true,
                        func=function()
                            Save.gemTop={}
                            panel:set_Gem()
                        end
                    }, level)

                    num= 0
                    for _ in pairs(Save.gemRight) do
                        num= num+1
                    end
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=(e.onlyChinese and '清除右边' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT))..' |cnGREEN_FONT_COLOR:#'..num,
                        icon=e.Icon.toLeft,
                        colorCode= num==0 and '|cff9e9e9e',
                        notCheckable=true,
                        func=function()
                            Save.gemRight={}
                            panel:set_Gem()
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text=e.onlyChinese and '清除记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_LOG_HEADER),
                        icon='bags-button-autosort-up',
                        notCheckable=true,
                        func=function()
                            Save.gemLoc={
                                [e.Player.class]={}
                            }
                            e.call(ItemSocketingFrame_Update)
                            print(e.addName, Initializer:GetName(), '|cnGREEN_FONT_COLOR:', e.onlyChinese and '完成' or COMPLETE)
                        end
                    }, level)

                    e.LibDD:UIDropDownMenu_AddSeparator(level)
                    e.LibDD:UIDropDownMenu_AddButton({
                        text= e.onlyChinese and '选项' or OPTIONS,
                        icon='mechagon-projects',
                        keepShownOnClick=true,
                        notCheckable=true,
                        func=function()
                            if not Initializer then
                                e.OpenPanelOpting()
                            end
                            e.OpenPanelOpting(Initializer)
                        end
                    }, level)
                end, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15,0)
        end
    end)
    btn:SetScript('OnMouseWheel', function(self, d)
        if not self:CanChangeAttribute() then
            return
        end
        local n= Save.scale or 1
        n= d==1 and n+0.05 or n
        n= d==-1 and n-0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save.scale= n
        self:set_scale()
        self:set_tooltips()
    end)

    btn:set_texture()
    btn:set_shown()
    btn:set_scale()
end












local function Init()
    Frame= CreateFrame("Frame", nil, ItemSocketingFrame)
    Frame.buttons={}
    Frame:SetPoint('BOTTOMRIGHT', 0, -10)
    Frame:SetSize(1,1)
    Frame:SetScript('OnHide', function() CurTypeGemTab={} end)

    function Frame:set_event()
        if self:IsShown() then
            self:RegisterEvent('BAG_UPDATE_DELAYED')
        else
            self:UnregisterAllEvents()
        end
    end
    Frame:SetScript('OnHide', Frame.set_event)
    Frame:SetScript('OnShow', Frame.set_event)
    Frame:SetScript('OnEvent', panel.set_Gem)
    Frame:set_event()

    ItemSocketingSocket3Left:ClearAllPoints()
    ItemSocketingSocket2Left:ClearAllPoints()
    ItemSocketingSocket1Left:ClearAllPoints()
    ItemSocketingSocket1Right:ClearAllPoints()
    ItemSocketingSocket2Right:ClearAllPoints()
    ItemSocketingSocket3Right:ClearAllPoints()
    ItemSocketingFrame['SocketFrame-Left']:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOM',0, 77)
    ItemSocketingFrame['SocketFrame-Right']:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOM', 0, 26)


    e.Set_Move_Frame(ItemSocketingFrame, {needSize=true, needMove=true, setSize=true, minW=338, minH=424, sizeRestFunc=function(btn)
        btn.target:SetSize(338, 424)
        set_point()
        panel:set_Gem()
    end, sizeUpdateFunc=function()
        set_point()
        panel:set_Gem()
    end})
    e.Set_Move_Frame(ItemSocketingScrollChild, {frame=ItemSocketingFrame})

    hooksecurefunc('ItemSocketingFrame_Update', Init_ItemSocketingFrame_Update)--宝石，数据


    Init_Button_All()
    Init_Spell_Button()
end













panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent('PLAYER_LOGOUT')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            if not WoWToolsSave[addName] and e.Is_Timerunning then
                C_Timer.After(2, function()
                    local slots={
                        ['INVTYPE_HEAD']= 1,
                        ['INVTYPE_NECK']= 2,
                        ['INVTYPE_SHOULDER']= 3,
                        --['INVTYPE_CLOAK']= 15,
                        ['INVTYPE_CHEST']= 5,
                        ['INVTYPE_WRIST']= 9,

                        ['INVTYPE_HAND']= 10,
                        ['INVTYPE_WAIST']= 6,
                        ['INVTYPE_LEGS']= 7,
                        ['INVTYPE_FEET']= 8,
                        ['INVTYPE_FINGER11']= 11,
                        ['INVTYPE_FINGER12']= 12,
                        ['INVTYPE_TRINKET13']= 13,
                        ['INVTYPE_TRINKET14']=14,
                        --['INVTYPE_WEAPON']=16,
                        --['INVTYPE_SHIELD']=17,
                    }
                    for itemEquipLoc, slotID in pairs(slots) do
                        local itemLink= GetInventoryItemLink('player', slotID)
                        if itemLink then
                            for index=1, MAX_NUM_SOCKETS do
                                local gemLink = select(2, C_Item.GetItemGem(itemLink, index))
                                if gemLink then
                                    set_save_gem(itemEquipLoc, gemLink, index)
                                end
                            end
                        end
                    end
                end)
            end

            Save= WoWToolsSave[addName] or Save
            Save.favorites= Save.favorites or {}
            Save.gemLeft= Save.gemLeft or {}
            Save.gemTop= Save.gemTop or {}
            Save.gemRight= Save.gemRight or {}

            Save.gemLoc= Save.gemLoc or {}
            Save.gemLoc[e.Player.class]= Save.gemLoc[e.Player.class] or {}


            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|T4555592:0|t'..(e.onlyChinese and '镶嵌宝石' or addName),
                tooltip= e.cn(addName),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled = not Save.disabled and true or nil
                    print(e.addName, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })

            if Save.disabled then
                self:UnregisterEvent('ADDON_LOADED')
            elseif ItemSocketingFrame then
                Init()
                self:UnregisterEvent('ADDON_LOADED')
            end
        elseif arg1=='Blizzard_ItemSocketingUI' then
            if Initializer then
                Init()
                self:UnregisterEvent('ADDON_LOADED')
            end
        end

    elseif event=='PLAYER_LOGOUT' then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end
    end
end)