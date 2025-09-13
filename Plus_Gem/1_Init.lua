
local P_Save={
    --hide=true,--显示，隐藏 Frame
    --scale=1,--缩放
    favorites={},--{itemID=true},
    gemLeft={},--右边，按钮
    gemTop={},
    gemRight={},
    disableSpell=true,--禁用，法术按钮
    gemLoc= {}--{class={['INVSLOT_LEGS']={1=gemID, 2=gemID, 3=gemID}}
}


local addName
local Frame
local Set_Gem

local SpellsTab={
    433397,--取出宝石
    --405805,--拔出始源之石
}

local function Save()
    return WoWToolsSave['Plus_Gem']
end





for _, spellID in pairs(SpellsTab) do
    WoWTools_DataMixin:Load({id=spellID, type='spell'})
end



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



--保存，slot, 数据
local function set_save_gem(itemEquipLoc, gemLink, index)
    if not itemEquipLoc then
        return
    end
    Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc]= Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc] or {}
    local gemID
    if gemLink then
        gemID= C_Item.GetItemInfoInstant(gemLink)
        if gemID then
            Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc][index]= gemID
        end
    end

    gemID= gemID or Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc][index]
    Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc][index]= gemID
    return gemID
end






local function Init_Button_Menu(self, root)
    root:CreateCheckbox(
        '|A:auctionhouse-icon-favorite:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '标记' or EVENTTRACE_BUTTON_MARKER),
    function()
        return Save().favorites[self.itemID]
    end, function()
        Save().favorites[self.itemID]= not Save().favorites[self.itemID] and true or nil
        self:set_favorite()
        print(WoWTools_DataMixin.Icon.icon2..addName, Save().favorites[self.itemID] and self.itemID or '', WoWTools_DataMixin.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
        Set_Gem()
    end)
    root:CreateDivider()

    root:CreateCheckbox(
        '|A:common-icon-rotateright:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '左边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT),
    function ()
        return Save().gemLeft[self.itemID]
    end, function ()
        Save().gemLeft[self.itemID]= not Save().gemLeft[self.itemID] and true or nil
        Set_Gem()
    end)

    root:CreateCheckbox(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '上面' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP),
    function ()
        return Save().gemTop[self.itemID]
    end, function ()
        Save().gemTop[self.itemID]= not Save().gemTop[self.itemID] and true or nil
        Set_Gem()
    end)

    root:CreateCheckbox(
        '|A:common-icon-rotateleft:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT),
    function ()
        return Save().gemRight[self.itemID]
    end, function ()
        Save().gemRight[self.itemID]= not Save().gemRight[self.itemID] and true or nil
        Set_Gem()
    end)
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
    local btn= WoWTools_ButtonMixin:Cbtn(parent or Frame, {frameType='ItemButton'})

    btn.level=WoWTools_LabelMixin:Create(btn)
    btn.level:SetPoint('TOPRIGHT')
    btn.type= WoWTools_LabelMixin:Create(btn)
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
    btn:SetScript('OnHide', function(self) self:set_event() end)
    btn:SetScript('OnShow', function(self) self:set_event() end)

    function btn:set_favorite()
        self.favorite:SetShown(Save().favorites[self.itemID])
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
            GameTooltip:SetOwner(ItemSocketingFrame, 'ANCHOR_BOTTOMRIGHT')
            GameTooltip:ClearLines()
            GameTooltip:SetBagItem(self.bagID, self.slotID)
            GameTooltip:AddLine(' ')
            GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '左边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toRight), 'Alt+'..WoWTools_DataMixin.Icon.left)
            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '上面' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP)..'|A:bags-greenarrow:0:0|a', 'Alt+'..WoWTools_DataMixin.Icon.mid)
            GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '右边' or HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT)..format('|A:%s:0:0|a', WoWTools_DataMixin.Icon.toLeft), 'Alt+'..WoWTools_DataMixin.Icon.right)
            GameTooltip:Show()
        end
    end
    btn:SetScript('OnClick', function(self, d)
        if not self.bagID or not self.itemID then
            return
        end
        ClearCursor()
        if IsAltKeyDown() then
            if d=='LeftButton' then
                Save().gemLeft[self.itemID]= not Save().gemLeft[self.itemID] and true or nil
                Set_Gem()
            elseif d=='RightButton' then
                Save().gemRight[self.itemID]= not Save().gemRight[self.itemID] and true or nil
                Set_Gem()
            end
        elseif d=='LeftButton' then
            C_Container.PickupContainerItem(self.bagID, self.slotID)
        elseif d=='RightButton' then
            MenuUtil.CreateContextMenu(self, Init_Button_Menu)
        end
        self:set_tooltips()
    end)
    btn:SetScript("OnMouseWheel", function(self)
        if IsAltKeyDown() then
            Save().gemTop[self.itemID]= not Save().gemTop[self.itemID] and true or nil
            Set_Gem()
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
    WoWTools_ItemMixin:SetGemStats(btn, itemLink)
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

function Set_Gem()--Blizzard_ItemSocketingUI.lua MAX_NUM_SOCKETS
    local items, gemLeft, gemTop, gemRight= {}, {}, {}, {}
    local scale= Save().scale or 1

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
                    and (WoWTools_DataMixin.Is_Timerunning or (WoWTools_DataMixin.Player.IsMaxLevel and WoWTools_DataMixin.ExpansionLevel== expacID or not WoWTools_DataMixin.Player.IsMaxLevel))--最高等级
                then
                    local tab={
                        info= info,
                        bag=bag,
                        slot=slot,
                        level= level or 0,
                        expacID= expacID or 0,
                        favorite= Save().favorites[info.itemID]
                    }
                    if Save().gemLeft[info.itemID] then
                        table.insert(gemLeft, tab)

                    elseif Save().gemTop[info.itemID] then
                        table.insert(gemTop, tab)

                    elseif Save().gemRight[info.itemID] then
                        table.insert(gemRight, tab)
                    else
                        local type
                        if WoWTools_DataMixin.Is_Timerunning then
                            local date= WoWTools_ItemMixin:GetTooltip({hyperLink=info.hyperlink, index=2})
                            type= date.indexText and date.indexText:match('|c........(.-)|r') or date.indexText
                        else
                            type= subclassID and WoWTools_TextMixin:CN(C_Item.GetItemSubClassInfo(classID, subclassID))
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
    if Save().disableSpell then
        return
    end

    local SpellButton=WoWTools_ButtonMixin:Cbtn(Frame, {
        size=32,
        isSecure=true,
        name='WoWToolsGemSpellButton'
    })

    SpellButton:Hide()

    SpellButton:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 4, 4)
    SpellButton.texture= SpellButton:CreateTexture(nil, 'OVERLAY')
    SpellButton.texture:SetAllPoints()
    SpellButton.count=WoWTools_LabelMixin:Create(SpellButton, {color={r=1,g=1,b=1}})
    SpellButton.count:SetPoint('BOTTOMRIGHT',-2, 9)

    function SpellButton:set_count()
        local data= self.spellID and C_Spell.GetSpellCharges(self.spellID) or {}
        local num, max= data.currentCharges, data.maxCharges
        self.count:SetText((max and max>1) and num or '')
        self.texture:SetDesaturated(num and num>0)
    end
    SpellButton:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        if self.spellID then
            GameTooltip:SetSpellByID(self.spellID)
        elseif self.action then
            GameTooltip:SetAction(self.action)
        end
        GameTooltip:Show()
    end)
    SpellButton:SetScript('OnLeave', GameTooltip_Hide)
    SpellButton:SetScript("OnEvent", function(self, event)
        if event=='SPELL_UPDATE_USABLE' then
            self:set_count()
        elseif event=='SPELL_UPDATE_COOLDOWN' then
            WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
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
        WoWTools_CooldownMixin:SetFrame(self, {spellID=self.spellID})
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
            if C_SpellBook.IsSpellInSpellBook(spell) then
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
    ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)--调整，宽度

    local numSockets = GetNumSockets() or 0
    CurTypeGemTab={}
    local itemEquipLoc
    if WoWTools_DataMixin.Is_Timerunning then
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
            if not Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc] then
                Save().gemLoc[WoWTools_DataMixin.Player.Class][itemEquipLoc]={}
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
                btn.type=WoWTools_LabelMixin:Create(btn)
                btn.type:SetPoint('BOTTOM', btn, 'TOP', 0, 2)
                btn.qualityTexture= btn:CreateTexture(nil, 'OVERLAY')
                if WoWTools_DataMixin.Is_Timerunning then
                    btn.qualityTexture:SetPoint('CENTER')
                    btn.qualityTexture:SetSize(46,46)--40
                else
                    btn.qualityTexture:SetPoint('RIGHT', btn, 'LEFT',15,-8)
                    btn.qualityTexture:SetSize(30,30)
                end
                btn.levelText=WoWTools_LabelMixin:Create(btn)
                btn.levelText:SetPoint('CENTER')
                btn.leftText=WoWTools_LabelMixin:Create(btn)
                btn.leftText:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT')
                btn.rightText=WoWTools_LabelMixin:Create(btn)
                btn.rightText:SetPoint('TOPRIGHT', btn, 'BOTTOMRIGHT')

                btn.gemButton=WoWTools_ButtonMixin:Cbtn(btn, {frameType='ItemButton'})--使用过宝石，提示
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
                btn.gemButton:SetScript('OnEvent', function(self) self:settings() end)
                btn.gemButton:SetScript('OnShow',  function(self) self:set_event() end)
                btn.gemButton:SetScript('OnHide',  function(self) self:set_event() end)
                btn.gemButton:SetScript('OnLeave', function()
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
            local left, right= WoWTools_ItemMixin:SetGemStats(nil, gemLink)
            local atlas
            if gemLink then
                if WoWTools_DataMixin.Is_Timerunning then
                    local quality= C_Item.GetItemQualityByID(gemLink)--C_Item.GetItemQualityColor(quality)
                    atlas= WoWTools_DataMixin.Icon[quality]
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

    Set_Gem()
end
























local function Init_Menu(self, root)
    local sub, num
    sub=root:CreateCheckbox(
        WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
    function()
        return not Save().hide
    end, function()
        Save().hide= not Save().hide and true or nil
        self:set_shown()
    end)
    sub:SetEnabled(Frame:CanChangeAttribute())

    root:CreateCheckbox(
        format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '法术' or SPELLS, 'Button'),
    function()
        return not Save().disableSpell
    end, function()
        Save().disableSpell= not Save().disableSpell and true or false
        print(WoWTools_DataMixin.Icon.icon2..addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disableSpell), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
    end, {})

    root:CreateDivider()
    num=0
    for _ in pairs(Save().favorites) do
        num= num+1
    end

    root:CreateButton(
        '|A:auctionhouse-icon-favorite:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '清除标记' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_BUTTON_MARKER))
        ..' |cnGREEN_FONT_COLOR:#'..num,
    function()
        Save().favorites={}
        for _, frame in pairs(Frame.buttons) do
            frame:set_favorite()
        end
        return MenuResponse.Refresh
    end)

--清除左边
    num= 0
    for _ in pairs(Save().gemLeft) do
        num= num+1

    end
    root:CreateButton(
         '|A:common-icon-rotateright:0:0|a'
         ..(WoWTools_DataMixin.onlyChinese and '清除左边' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_LEFT))
         ..' |cnGREEN_FONT_COLOR:#'
         ..num,
    function()
        Save().gemLeft={}
        Set_Gem()
        return MenuResponse.Refresh
    end)

--清除上面
    num= 0
    for _ in pairs(Save().gemTop) do
        num= num+1
    end
    root:CreateButton(
        '|A:bags-greenarrow:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '清除上面' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_UP))
        ..' |cnGREEN_FONT_COLOR:#'
        ..num,
    function()
        Save().gemTop={}
        Set_Gem()
        return MenuResponse.Refresh
    end)

--清除右边
    num= 0
    for _ in pairs(Save().gemRight) do
        num= num+1
    end
    root:CreateButton(
         '|A:common-icon-rotateleft:0:0|a'
         ..(WoWTools_DataMixin.onlyChinese and '清除右边' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, HUD_EDIT_MODE_SETTING_BAGS_DIRECTION_RIGHT))
         ..' |cnGREEN_FONT_COLOR:#'
         ..num,
    function()
        Save().gemRight={}
        Set_Gem()
        return MenuResponse.Refresh
    end)

    root:CreateButton(
        '|A:bags-button-autosort-up:0:0|a'
        ..(WoWTools_DataMixin.onlyChinese and '清除记录' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SLASH_STOPWATCH_PARAM_STOP2, EVENTTRACE_LOG_HEADER)),
    function()
        Save().gemLoc={
            [WoWTools_DataMixin.Player.Class]={}
        }
        WoWTools_DataMixin:Call(ItemSocketingFrame_Update)
        return MenuResponse.Refresh
    end)

    root:CreateDivider()
    WoWTools_MenuMixin:OpenOptions(root, {name=addName})
end











--总开关
local function Init_Button_All()
    local btn= WoWTools_ButtonMixin:Cbtn(ItemSocketingFrame.TitleContainer, {
            size=22,
            icon='hide',
        })
    btn:SetPoint('LEFT', 26)
    function btn:set_texture()
        if Save().hide then
            btn:SetNormalAtlas('talents-button-reset')
        else
            btn:SetNormalTexture('Interface\\AddOns\\WoWTools\\Source\\Texture\\WoWtools')
        end
    end
    function btn:set_shown()
        if Frame:CanChangeAttribute() then
            Frame:SetShown(not Save().hide)
            self:set_texture()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    function btn:set_scale()
        if Frame:CanChangeAttribute() then
            Frame:SetScale(Save().scale or 1)
            Set_Gem()
        else
            self:RegisterEvent('PLAYER_REGEN_ENABLED')
        end
    end
    function btn:set_tooltips()
        if not Frame:CanChangeAttribute() then
            GameTooltip:Hide()
            return
        end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, addName)
        GameTooltip:AddLine(' ')
        GameTooltip:AddDoubleLine(WoWTools_TextMixin:GetShowHide(not Save().hide), WoWTools_DataMixin.Icon.left)
        GameTooltip:AddDoubleLine((WoWTools_DataMixin.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save().scale or 1), WoWTools_DataMixin.Icon.mid)
        GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '菜单' or HUD_EDIT_MODE_MICRO_MENU_LABEL, WoWTools_DataMixin.Icon.right)
        GameTooltip:Show()
    end
    btn:SetAlpha(0.5)
    btn:SetScript('OnLeave', function(self) self:SetAlpha(0.5) GameTooltip:Hide() end)
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
            Save().hide= not Save().hide and true or nil
            self:set_shown()
            self:set_texture()
            self:set_tooltips()
        else
            MenuUtil.CreateContextMenu(self, function(...)
                Init_Menu(...)
            end)
        end
    end)
    btn:SetScript('OnMouseWheel', function(self, d)
        if not self:CanChangeAttribute() then
            return
        end
        local n= Save().scale or 1
        n= d==1 and n+0.05 or n
        n= d==-1 and n-0.05 or n
        n= n>4 and 4 or n
        n= n<0.4 and 0.4 or n
        Save().scale= n
        self:set_scale()
        self:set_tooltips()
    end)

    btn:set_texture()
    btn:set_shown()
    btn:set_scale()
end






























local function Set_Move(self)
    if Save().disabled then
         self:Setup(ItemSocketingFrame)

    else
        ItemSocketingScrollFrame:SetPoint('BOTTOMRIGHT', -22, 90)

        ItemSocketingScrollChild:ClearAllPoints()
        ItemSocketingScrollChild:SetPoint('TOPLEFT')
        ItemSocketingScrollChild:SetPoint('TOPRIGHT', -18, -254)

        ItemSocketingDescription:ClearAllPoints()
        ItemSocketingDescription:SetAllPoints()
        ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)--调整，宽度

        self:Setup(ItemSocketingFrame, {
        setSize=true,
        minW=338,
        minH=424,
        sizeRestFunc=function()
            ItemSocketingFrame:SetSize(338, 424)
            Set_Gem()
            ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)--调整，宽度
        end, sizeUpdateFunc=function()
            Set_Gem()
            ItemSocketingDescription:SetMinimumWidth(ItemSocketingScrollFrame:GetWidth()-36, true)--调整，宽度
        end})
    end

    self:Setup(ItemSocketingScrollChild, {frame=ItemSocketingFrame})
    self:Setup(ItemSocketingFrameInset, {frame=ItemSocketingFrame})
    self:Setup(ItemSocketingScrollFrame, {frame=ItemSocketingFrame})

    Set_Move= function()end
end

--镶嵌宝石，界面
function WoWTools_MoveMixin.Events:Blizzard_ItemSocketingUI()
    Set_Move(self)
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
    Frame:SetScript('OnHide', function(self) self:set_event() end)
    Frame:SetScript('OnShow', function(self) self:set_event() end)
    Frame:SetScript('OnEvent', function() Set_Gem() end)
    Frame:set_event()

    ItemSocketingSocket3Left:ClearAllPoints()
    ItemSocketingSocket2Left:ClearAllPoints()
    ItemSocketingSocket1Left:ClearAllPoints()
    ItemSocketingSocket1Right:ClearAllPoints()
    ItemSocketingSocket2Right:ClearAllPoints()
    ItemSocketingSocket3Right:ClearAllPoints()
    ItemSocketingFrame['SocketFrame-Left']:SetPoint('TOPRIGHT', ItemSocketingFrame, 'BOTTOM',0, 77)
    ItemSocketingFrame['SocketFrame-Right']:SetPoint('BOTTOMLEFT', ItemSocketingFrame, 'BOTTOM', 0, 26)

    WoWTools_DataMixin:Hook('ItemSocketingFrame_Update', function(...)--宝石，数据
        Init_ItemSocketingFrame_Update(...)
    end)

    Init_Button_All()
    Init_Spell_Button()

    local region= select(3, ItemSocketingFrame:GetRegions())
    if region:GetObjectType()=='FontString' then
        region:SetParent(ItemSocketingFrame.TitleContainer)
    end

    Set_Move(WoWTools_MoveMixin)


--Plus_Tooltip 加上的
    C_Timer.After(0.3, function()
        if not ItemSocketingDescription.textLeft then
            return
        end

        ItemSocketingDescription.backgroundColor:SetAlpha(0)

        ItemSocketingDescription.textLeft:SetParent(ItemSocketingScrollFrame)
        ItemSocketingDescription.textLeft:ClearAllPoints()
        ItemSocketingDescription.textLeft:SetPoint('BOTTOMLEFT', ItemSocketingScrollFrame, 'TOPLEFT')

        ItemSocketingDescription.text2Left:SetParent(ItemSocketingScrollFrame)

        ItemSocketingDescription.textRight:SetParent(ItemSocketingScrollFrame)
        ItemSocketingDescription.textRight:ClearAllPoints()
        ItemSocketingDescription.textRight:SetPoint('BOTTOMRIGHT', ItemSocketingScrollFrame, 'TOPRIGHT')

        ItemSocketingDescription.text2Right:SetParent(ItemSocketingScrollFrame)

        if ItemSocketingDescription.playerModel then
            ItemSocketingDescription.playerModel:SetParent(ItemSocketingScrollFrame)
        end
    end)


    Init=function()end
end










local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_Gem']= WoWToolsSave['Plus_Gem'] or P_Save
            P_Save=nil

            addName= '|T4555592:0|t'..(WoWTools_DataMixin.onlyChinese and '镶嵌宝石' or SOCKET_GEMS)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled = not Save().disabled and true or nil

                    Init()

                    if Save().disabled then
                        print(
                            WoWTools_DataMixin.Icon.icon2..addName,
                            WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)
                    end
                end
            })

            if Save().disabled then
                self:UnregisterEvent(event)

            elseif C_AddOns.IsAddOnLoaded('Blizzard_ItemSocketingUI') then
                Init()
                self:UnregisterEvent(event)
            end

        elseif arg1=='Blizzard_ItemSocketingUI' and WoWToolsSave then
            Init()
            self:UnregisterEvent(event)
        end
    end
end)