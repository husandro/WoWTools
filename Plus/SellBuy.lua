local id, e = ...
local Save={
    noSell={
        [144341]=true,--[可充电的里弗斯电池]
        [49040]=true,--[基维斯]
        [114943]=true,--[终极版侏儒军刀]
        [103678]=true,--迷时神器
        [142469]=true,--魔导大师的紫罗兰印戒
        [139590]=true,--[传送卷轴：拉文霍德]
        [144391]=true,--拳手的重击指环
        [144392]=true,--拳手的重击指环
        [37863]=true,--[烈酒的遥控器]
    },
    Sell={
        [34498]=true,--[纸飞艇工具包]
    },
    --notAutoLootPlus= e.Player.husandro,--打开拾取窗口时，下次禁用，自动拾取
    --sellJunkMago=true,--出售，可幻化，垃圾物品
    --notPlus=true,--商人 Plus,加宽

    --notSellBoss=true,--出售，BOSS，掉落
    --bossSave={},
    saveBossLootList= e.Player.husandro,--保存，BOSS，列表

    --notAutoRepairAll=true,--自动修理

    MERCHANT_ITEMS_PER_PAGE= 24,--页，物品数量
    numLine=6,--行数
}

local addName= MERCHANT
local panel= CreateFrame("Frame")
local RepairSave={date=date('%x'), player=0, guild=0, num=0}
local Initializer

--MerchantFrame.lua
local bossSave={}
local buySave={}--购买物品



local AutoRepairCheck--自动修理
local AutoSellJunkCheck--自动出售

local BuyItemButton
local BuybackButton--回购物品




















--####################
--检测是否是出售物品
--为 ItemInfo.lua, 用
function e.CheckItemSell(itemID, itemLink, quality, isBound)
    if not itemID or Save.noSell[itemID] then
        return
    end
    if Save.Sell[itemID] and not Save.notSellCustom then
        return e.onlyChinese and '自定义' or CUSTOM
    end
    local level= bossSave[itemID]
    if level and not Save.notSellBoss and itemLink  then
        local itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or select(4, C_Item.GetItemInfo(itemLink))
        if level== itemLevel  then
            return e.onlyChinese and '首领' or BOSS
        end
    end
    if quality==0 then
        if e.GetPet9Item(itemID, true) then--宠物兑换, wow9.0
            return e.onlyChinese and '宠物' or PET

        elseif not Save.notSellJunk then--垃圾
            if Save.sellJunkMago or isBound==true then
                return e.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            else
                local classID, subclassID = select(6, C_Item.GetItemInfoInstant(itemID))
                if (classID==2 or classID==4) and subclassID~=0 then
                    local isCollected = select(2, e.GetItemCollected(itemID, nil, nil))--物品是否收集
                    if isCollected==false then
                        return
                    end
                end
                return e.onlyChinese and '垃圾' or BAG_FILTER_JUNK
            end
        end
    end
end























--商人Plus. 设置, 提示, 信息
--#########################
local function Set_Merchant_Info()--设置, 提示, 信息
    if not MerchantFrame:IsVisible() or Save.notPlus then
        return
    end
    local selectedTab= MerchantFrame.selectedTab
    local isMerce= selectedTab == 1
    local page= isMerce and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE
    local numItem= isMerce and GetMerchantNumItems() or GetNumBuybackItems()
    for i=1, page do
        local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i)
        local btn= _G["MerchantItem"..i]
        local text, spellID, num, itemID, itemLink

        if btn and index<= numItem then
            if isMerce then
                itemID= GetMerchantItemID(index)
                itemLink=  GetMerchantItemLink(index)
            else
                itemID= C_MerchantFrame.GetBuybackItemID(index)
                itemLink= GetBuybackItemLink(index)
            end

            num=(not Save.notAutoBuy and itemID) and buySave[itemID]--自动购买， 数量
            num= num and num..'|T236994:0|t'
            --包里，银行，总数
            local bag=itemID and C_Item.GetItemCount(itemID, true, false, true)
            if bag and bag>0 then
                num=(num and num..'|n' or '')..bag..'|A:Banker:0:0|a'
            end
            if num and not btn.buyItemNum then
                btn.buyItemNum=e.Cstr(btn)
                btn.buyItemNum:SetPoint('RIGHT')
                btn.buyItemNum:EnableMouse(true)
                btn.buyItemNum:SetScript('OnLeave', GameTooltip_Hide)
                btn.buyItemNum:SetScript('OnEnter', function(self)
                    if not self.itemID then return end
                    e.tips:SetOwner(self, "ANCHOR_LEFT")
					e.tips:ClearLines()
                    e.tips:AddDoubleLine(id, Initializer:GetName())
                    e.tips:AddLine(' ')
                    e.tips:AddDoubleLine('|T236994:0|t'..(e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), not Save.notAutoBuy and buySave[self.itemID] or (e.onlyChinese and '无' or NONE))
                    local all= C_Item.GetItemCount(self.itemID, true, false, true)
                    local bag2= C_Item.GetItemCount(self.itemID)
                    e.tips:AddDoubleLine('|A:Banker:0:0|a'..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL), all..'= '.. '|A:bag-main:0:0|a'.. bag2..'+ '..'|A:Banker:0:0|a'..(all-bag))
					e.tips:Show()
                end)
            end
            --物品，属性
            local classID= itemLink and select(6, C_Item.GetItemInfoInstant(itemLink))
            if classID==2 or classID==4 then--装备
                local stat= e.Get_Item_Stats(itemLink)--物品，属性，表
                table.sort(stat, function(a,b) return a.value>b.value and a.index== b.index end)
                for _, tab in pairs(stat) do
                    text= text and text..' ' or ''
                    text= (text and text..' ' or '')..tab.text
                end
                spellID= select(2, C_Item.GetItemSpell(itemLink))
                if spellID then
                    text= (text or '').. '|A:soulbinds_tree_conduit_icon_utility:10:10|a'
                end
                if text and not btn.stats then
                    btn.stats=e.Cstr(btn, {size=10, mouse=true})
                    btn.stats:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT',0,6)
                    btn.stats:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
                    btn.stats:SetScript('OnEnter', function(self)
                        if self.spellID then
                            e.tips:SetOwner(self, "ANCHOR_LEFT")
                            e.tips:ClearLines()
                            e.tips:SetSpellByID(self.spellID)
                            e.tips:AddLine(' ')
                            e.tips:AddDoubleLine(id, Initializer:GetName())
                            e.tips:Show()
                        end
                        self:SetAlpha(0.5)
                    end)
                end
            end
        end
        if btn then
            if btn.buyItemNum then
                btn.buyItemNum:SetText(num or '')
                btn.buyItemNum.itemID= itemID
            end
            if btn.stats then
                btn.stats:SetText(text or '')
                btn.stats.spellID= spellID
            end
        end
    end
end





























--商人 Plus, 加宽，物品，信息
local function Create_ItemButton()
    for i= 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do--建立，索引，文本
        local btn= _G['MerchantItem'..i] or CreateFrame('Frame', 'MerchantItem'..i, MerchantFrame, 'MerchantItemTemplate', i)
        if not btn.IndexLable then
            btn.IndexLable= e.Cstr(btn)
            btn.IndexLable:SetPoint('TOPRIGHT', btn, -1, 4)
            btn.IndexLable:SetAlpha(0.3)
            btn.IndexLable:SetText(i)
            --建立，物品，背景
            btn.itemBG= btn:CreateTexture(nil, 'BACKGROUND')
            btn.itemBG:SetAtlas('ChallengeMode-guild-background')
            btn.itemBG:SetSize(100,43)
            btn.itemBG:SetPoint('TOPRIGHT',-7,-2)
            btn.itemBG:Hide()
            btn.ItemButton:HookScript('OnEnter', function(self)
                if MerchantFrame.selectedTab == 1 then
                    if self.hasItem then
                        e.FindBagItem(true, {itemName=self.name})
                    end
                elseif MerchantFrame.selectedTab == 2 then
                    e.FindBagItem(true, {BuybackIndex=self:GetID()})
                end
            end)
            btn.ItemButton:HookScript('OnLeave', function(self)
                if MerchantFrame.selectedTab == 1 then
                    if self.hasItem then
                        e.FindBagItem(false)
                    end
                elseif MerchantFrame.selectedTab == 2 then
                    local name= GetBuybackItemInfo(self:GetID())
                    if name then
                        e.FindBagItem(false)
                    end
                end
            end)
        end
    end
    local index= MERCHANT_ITEMS_PER_PAGE+1
    while _G['MerchantItem'..index] do--隐藏，多余
        _G['MerchantItem'..index]:SetShown(false)
        local itemButton = _G["MerchantItem"..index.."ItemButton"]
        itemButton.price = nil
        itemButton.hasItem = nil
        itemButton.name = nil
        itemButton.extendedCost = nil
        itemButton.link = nil
        itemButton.texture = nil
        _G["MerchantItem"..index.."Name"]:SetText("")
        index= index+1
    end
end





local function Init_WidthX2()
    if C_AddOns.IsAddOnLoaded("CompactVendor") then
        print(id, Initializer:GetName(), format(e.onlyChinese and "|cffff0000与%s发生冲突！|r" or ALREADY_BOUND, 'CompactVendor'), e.onlyChinese and '插件' or ADDONS)
    end

    MERCHANT_ITEMS_PER_PAGE= Save.MERCHANT_ITEMS_PER_PAGE or MERCHANT_ITEMS_PER_PAGE or 24
    Create_ItemButton()

    --物品数量
    MerchantFrameTab1.numLable= e.Cstr(MerchantFrameTab1)
    MerchantFrameTab1.numLable:SetPoint('TOPRIGHT')
    MerchantFrame:HookScript('OnShow', function()
        local num= GetMerchantNumItems()
        print(num)
        MerchantFrameTab1.numLable:SetText(num and num>0 and num or '')
    end)

    --回购，数量，提示
    MerchantFrameTab2.numLable= e.Cstr(MerchantFrameTab2)
    MerchantFrameTab2.numLable:SetPoint('TOPRIGHT')
    function MerchantFrameTab2:set_buyback_num()
        local num
        num= GetNumBuybackItems() or 0
        if num>0 then
            num= num==BUYBACK_ITEMS_PER_PAGE and '|cnRED_FONT_COLOR:'..num or num
        else
            num= ''
        end
        self.numLable:SetText(num)
    end

    --卖
    hooksecurefunc('MerchantFrame_UpdateMerchantInfo', function()
        if not MerchantFrame:IsShown() then
            return
        end
        local w, h= 172, 146+(Save.numLine*52)--<Size x="336" y="444"/> <Size x="153" y="44"/>
        for i = 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
            local btn= _G['MerchantItem'..i]
            if i<=MERCHANT_ITEMS_PER_PAGE then

                btn:SetShown(true)
                btn.itemBG:SetShown(btn.ItemButton.hasItem)--Texture.lua
                if i>1 then
                    btn:ClearAllPoints()
                    btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
                end
            else
                btn:Hide()
            end
        end
        local line= MerchantFrame.ResizeButton and Save.numLine or 6
        for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do
            local btn= _G['MerchantItem'..i]
            btn:ClearAllPoints()
            btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            w= w+161
        end
        MerchantFrame:SetSize(max(w, 336), max(h, 440))
        Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示
        if MerchantFrame.ResizeButton then
            MerchantFrame.ResizeButton.setSize=true
        end
    end)

    --回购
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', function()
        local numBuybackItems = GetNumBuybackItems() or 0
        for i = 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
            local btn= _G['MerchantItem'..i]
            if i<= BUYBACK_ITEMS_PER_PAGE then
                btn:SetShown(true)
                if i>1 then
                    btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
                end
                btn.itemBG:SetShown(numBuybackItems>=i)
            else
                btn:SetShown(false)
            end
        end
        _G['MerchantItem7']:SetPoint('TOPLEFT', _G['MerchantItem1'], 'TOPRIGHT', 8, 0)

        MerchantFrame:SetSize(336, 440)
        Set_Merchant_Info()--设置, 提示, 信息
        MerchantFrameTab2:set_buyback_num()--回购，数量，提示
        if MerchantFrame.ResizeButton then
            MerchantFrame.ResizeButton.setSize=nil
        end
    end)

    --重新设置，按钮
    hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
        MerchantRepairItemButton:ClearAllPoints()--单个，修理
        MerchantRepairItemButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -289, 33)
        MerchantRepairAllButton:ClearAllPoints()--全部，修理
        MerchantRepairAllButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -241, 33)
        MerchantGuildBankRepairButton:ClearAllPoints()--公会，修理
        MerchantGuildBankRepairButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -193, 33)
        MerchantSellAllJunkButton:ClearAllPoints()--出售垃圾，修理
        MerchantSellAllJunkButton:SetPoint('BOTTOMRIGHT', MerchantFrame, -145, 33)--36
    end)
    MerchantBuyBackItem:ClearAllPoints()--回购
    MerchantBuyBackItem:SetPoint('BOTTOMRIGHT', MerchantFrame, -16, 33)--115
    MerchantNextPageButton:ClearAllPoints()--下一页
    MerchantNextPageButton:SetPoint('RIGHT', MerchantFrameLootFilter, 'LEFT', 20, 2)
    MerchantNextPageButton:SetFrameStrata('HIGH')
    local label, texture= MerchantNextPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end
    MerchantPrevPageButton:ClearAllPoints()--上一页
    MerchantPrevPageButton:SetPoint('RIGHT', MerchantNextPageButton, 'LEFT', 8,0)
    label, texture= MerchantPrevPageButton:GetRegions()
    if texture and texture:GetObjectType()=='Texture' then texture:Hide() texture:SetTexture(0) end
    if label and label:GetObjectType()=='FontString' then label:Hide() label:SetText('') end
    MerchantPageText:ClearAllPoints()--上页数
    MerchantPageText:SetPoint('RIGHT', MerchantPrevPageButton, 'LEFT', 0, 0)
    MerchantPageText:SetJustifyH('RIGHT')
    MerchantFrameBottomLeftBorder:ClearAllPoints()--外框
    MerchantFrameBottomLeftBorder:SetPoint('BOTTOMRIGHT', 0, 26)

    e.Set_Move_Frame(MerchantFrame, {setSize=true, needSize=true, needMove=true, minW=329, minH=402, sizeUpdateFunc= function()
            local w, h= MerchantFrame:GetSize()
            Save.numLine= max(5, math.floor((h-144)/52))
            MERCHANT_ITEMS_PER_PAGE= max(10, max(2, math.floor(((w-8)/161)))* Save.numLine)
            do
                Create_ItemButton()
            end
            for i = 1, max(BUYBACK_ITEMS_PER_PAGE, MERCHANT_ITEMS_PER_PAGE) do
                local btn= _G['MerchantItem'..i]
                if i<=MERCHANT_ITEMS_PER_PAGE then
                    btn:SetShown(true)
                    if i>1 then
                        btn:ClearAllPoints()
                        btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-1)], 'BOTTOMLEFT', 0, -8)
                    end
                    if not btn.ItemButton.hasItem then
                        local name, texture= GetMerchantItemInfo(i)
                        _G["MerchantItem"..i.."Name"]:SetText(name or '')
                        SetItemButtonTexture(btn.ItemButton, texture or 0)
                    end
                else
                    btn:Hide()
                end
            end
            local line= Save.numLine
            for i= line+1, MERCHANT_ITEMS_PER_PAGE, line do
                local btn= _G['MerchantItem'..i]
                btn:ClearAllPoints()
                btn:SetPoint('TOPLEFT', _G['MerchantItem'..(i-line)], 'TOPRIGHT', 8, 0)
            end

            local numMerchantItems = GetMerchantNumItems()
            MerchantPageText:SetFormattedText(e.onlyChinese and '页数 %s/%s' or MERCHANT_PAGE_NUMBER, MerchantFrame.page, math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE))
            -- Handle paging buttons
            if ( numMerchantItems > MERCHANT_ITEMS_PER_PAGE ) then
                MerchantPageText:SetShown(true)
                MerchantPrevPageButton:SetShown(true)
                MerchantNextPageButton:SetShown(true)
            else
                MerchantPageText:SetShown(false)
                MerchantPrevPageButton:SetShown(false)
                MerchantNextPageButton:SetShown(false)
            end

        end, sizeRestFunc= function()
            MERCHANT_ITEMS_PER_PAGE= 10
            Save.numLine= 5
            Create_ItemButton()
            e.call('MerchantFrame_UpdateMerchantInfo')
        end, sizeStopFunc= function()
            Save.MERCHANT_ITEMS_PER_PAGE= MERCHANT_ITEMS_PER_PAGE
            e.call('MerchantFrame_UpdateMerchantInfo')
        end
    })
end
























--堆叠,数量,框架 StackSplitFrame.lua
local function Init_StackSplitFrame()
    local frame= StackSplitFrame
    frame.restButton=e.Cbtn(frame, {size={22,22}})--重置
    frame.restButton:SetPoint('TOP')
    frame.restButton:SetNormalAtlas('characterundelete-RestoreButton')
    frame.restButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split= f.minSplit
        f.LeftButton:SetEnabled(false)
        f.RightButton:SetEnabled(true)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    frame.restButton:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, 'ANCHOR_LEFT')
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine(e.onlyChinese and '重置' or RESET)
        e.tips:Show()
    end)
    frame.restButton:SetScript('OnLeave', GameTooltip_Hide)

    frame.MaxButton=e.Cbtn(frame, {icon='hide', size={40,20}})
    frame.MaxButton:SetNormalFontObject('NumberFontNormalYellow')
    frame.MaxButton:SetPoint('LEFT', frame.restButton, 'RIGHT')
    frame.MaxButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=f.maxStack
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    frame.MetaButton=e.Cbtn(frame, {icon='hide', size={40,20}})
    frame.MetaButton:SetNormalFontObject('NumberFontNormalYellow')
    frame.MetaButton:SetPoint('RIGHT', frame.restButton, 'LEFT')
    frame.MetaButton:SetScript('OnMouseDown', function(self)
        local f= self:GetParent()
        f.split=floor(f.maxStack/2)
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)

    frame.editBox=CreateFrame('EditBox', nil, frame)--输入框
    frame.editBox:SetSize(100, 23)
    frame.editBox:SetPoint('TOPLEFT', 38, -18)
    frame.editBox:SetTextColor(0,1,0)
    frame.editBox:SetAutoFocus(false)
    frame.editBox:ClearFocus()
    frame.editBox:SetFontObject("ChatFontNormal")
    frame.editBox:SetMultiLine(false)
    frame.editBox:SetNumeric(true)
    frame.editBox:SetScript('OnEditFocusLost', function(self) self:SetText('') end)
    frame.editBox:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    frame.editBox:SetScript('OnEnterPressed', function(self) self:ClearFocus() end)
    frame.editBox:SetScript('OnTextChanged',function(self, userInput)
        if not userInput then
            return
        end
        local f= self:GetParent()
        local num=self:GetNumber()
        if f.isMultiStack then
            num= floor(num/f.minSplit) * f.minSplit
        end
        num= num<f.minSplit and f.minSplit or num
        num= num>f.maxStack and f.maxStack or num
        f.RightButton:SetEnabled(num<f.maxStack)
        f.LeftButton:SetEnabled(num==f.minSplit)
        f.split=num
        f:UpdateStackText()
        f:UpdateStackSplitFrame(f.maxStack)
    end)
    frame:HookScript('OnMouseWheel', function(self, d)
        local minSplit= self.minSplit or 1
        local maxStack= self.maxStack or 1
        local num= self.split or 1
        num= d==1 and num+ minSplit or num
        num= d==-1 and num- minSplit or num
        num= num< minSplit and minSplit or num
        num= num> maxStack and maxStack or num
        self.split= num
        self:UpdateStackText()
        self:UpdateStackSplitFrame(self.maxStack)
    end)

    hooksecurefunc(StackSplitFrame, 'OpenStackSplitFrame', function(self)
        self.MaxButton:SetText(self.maxStack)
        self.MetaButton:SetText(floor(self.maxStack/2))
    end)
end










--商人 Plus
local function Init_Plus()
    if Save.notPlus then
        return
    end
    Init_StackSplitFrame()-- 堆叠,数量,框架
    C_Timer.After(2, Init_WidthX2)--加宽，框架x2
    hooksecurefunc('MerchantFrame_UpdateCurrencies', function()
        MerchantExtraCurrencyInset:SetShown(false)
        MerchantExtraCurrencyBg:SetShown(false)
        MerchantMoneyInset:SetShown(false)
    end)
end















--自动修理
local function Init_Auto_Repair()
    AutoRepairCheck= CreateFrame("CheckButton", nil, MerchantRepairAllButton, "InterfaceOptionsCheckButtonTemplate")
    AutoRepairCheck:SetSize(18,18)
    AutoRepairCheck:SetChecked(not Save.notAutoRepairAll)
    AutoRepairCheck:SetPoint('BOTTOMLEFT', -4,-5)

    function AutoRepairCheck:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddDoubleLine(e.onlyChinese and '自动修理所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REPAIR_ALL_ITEMS), e.GetEnabeleDisable(not Save.notAutoRepairAll))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine('|cffff00ff'..(e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER), RepairSave.date)
        e.tips:AddDoubleLine(e.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR, (RepairSave.num or 0)..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1))
        local guild= RepairSave.guild or 0
        local player= RepairSave.player or 0
        e.tips:AddDoubleLine(e.onlyChinese and '公会' or GUILD, C_CurrencyInfo.GetCoinTextureString(guild))
        e.tips:AddDoubleLine(e.onlyChinese and '玩家' or PLAYER, C_CurrencyInfo.GetCoinTextureString(player))
        if guild>0 and player>0 then
            e.tips:AddDoubleLine(e.onlyChinese and '合计' or TOTAL, C_CurrencyInfo.GetCoinTextureString(guild+player))
        end
        e.tips:AddLine(' ')
        if CanGuildBankRepair() then
            local m= GetGuildBankMoney() or 0
            local col= m==0 and '|cff606060' or '|cnGREEN_FONT_COLOR:'
            e.tips:AddDoubleLine(col..(e.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP), col..C_CurrencyInfo.GetCoinTextureString(m))
        else
            e.tips:AddDoubleLine('|cff606060'..(e.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP), '|cff606060'..(e.onlyChinese and '禁用' or DISABLE))
        end
        e.tips:Show()
    end
    AutoRepairCheck:SetScript('OnClick', function(self)
        Save.notAutoRepairAll= not Save.notAutoRepairAll and true or nil
        self:set_repair_all()
        self:set_tooltip()
    end)
    AutoRepairCheck:SetScript('OnLeave', GameTooltip_Hide)
    AutoRepairCheck:SetScript('OnEnter', AutoRepairCheck.set_tooltip)








    --修理
    function AutoRepairCheck:set_repair_all()
        if Save.notAutoRepairAll or not CanMerchantRepair() or IsModifierKeyDown() then
            return
        end
        local Co, Can= GetRepairAllCost()
        if Can and Co and Co>0 then
            if CanGuildBankRepair() and GetGuildBankMoney()>=Co  then
                RepairAllItems(true)
                RepairSave.guild=RepairSave.guild+Co
                RepairSave.num=RepairSave.num+1
                print(id, Initializer:GetName(), '|cffff00ff'..(e.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP)..'|r', C_CurrencyInfo.GetCoinTextureString(Co))
                e.call('MerchantFrame_Update')
            else
                if GetMoney()>=Co then
                    RepairAllItems()
                    RepairSave.player=RepairSave.player+Co
                    RepairSave.num=RepairSave.num+1
                    print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '修理花费：' or REPAIR_COST)..'|r', C_CurrencyInfo.GetCoinTextureString(Co))
                    e.call('MerchantFrame_Update')
                else
                    print(id, Initializer:GetName(), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '失败' or FAILED)..'|r', e.onlyChinese and '修理花费：' or REPAIR_COST, C_CurrencyInfo.GetCoinTextureString(Co))
                end
            end
        end
        
    end
    AutoRepairCheck:RegisterEvent('MERCHANT_SHOW')
    AutoRepairCheck.events={
        'EQUIPMENT_SWAP_FINISHED',
        'PLAYER_EQUIPMENT_CHANGED',
        'UPDATE_INVENTORY_DURABILITY',
    }
    MerchantFrame:HookScript('OnShow', function()
        FrameUtil.RegisterFrameForEvents(AutoRepairCheck, AutoRepairCheck.events)
    end)
    MerchantFrame:HookScript('OnHide', function()
        FrameUtil.UnregisterFrameForEvents(AutoRepairCheck, AutoRepairCheck.events)
    end)
    AutoRepairCheck:SetScript('OnEvent', function(self, event)
        if event=='MERCHANT_SHOW' then
            self:set_repair_all()
        end
    end)

    --显示，公会修理，信息
    MerchantGuildBankRepairButton.Text= e.Cstr(MerchantGuildBankRepairButton, {justifyH='RIGHT'})
    MerchantGuildBankRepairButton.Text:SetPoint('TOPLEFT', 1, -1)
    hooksecurefunc('MerchantFrame_UpdateGuildBankRepair', function()
        local repairAllCost = GetRepairAllCost()
        if not CanGuildBankRepair() then
            MerchantGuildBankRepairButton.Text:SetFormattedText('|A:%s:0:0|a', e.Icon.disabled)
        else
            local co = GetGuildBankMoney() or 0
            local col= co==0 and '|cff606060' or (repairAllCost> co and '|cnRED_FONT_COLOR:') or '|cnGREEN_FONT_COLOR:'
            MerchantGuildBankRepairButton.Text:SetText(col..(e.MK(co/10000, 0)))
        end
    end)

    --提示，可修理，件数
    MerchantRepairItemButton.Text=e.Cstr(MerchantRepairItemButton)
    MerchantRepairItemButton.Text:SetPoint('TOPLEFT', 1, -1)
    MerchantRepairItemButton:SetScript('OnEnter', function(self)--替换，源FUNC
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText(e.onlyChinese and '修理一件物品' or REPAIR_AN_ITEM)
        GameTooltip:AddLine(' ')
        e.GetDurabiliy_OnEnter()
        GameTooltip:Show()
    end)
    MerchantRepairItemButton:HookScript('OnClick', function()
        if not PaperDollFrame:IsVisible() then
            ToggleCharacter("PaperDollFrame")
        end
    end)

    --显示耐久度
    AutoRepairCheck.Text:ClearAllPoints()
    AutoRepairCheck.Text:SetPoint('BOTTOM', MerchantRepairAllButton, 'TOP', 0, 0)
    AutoRepairCheck.Text:SetShadowOffset(1, -1)

    --显示，修理，金钱
    MerchantRepairAllButton.Text2=e.Cstr(MerchantRepairAllButton)
    MerchantRepairAllButton.Text2:SetPoint('TOPLEFT', MerchantRepairAllButton, 1, -1)
    hooksecurefunc('MerchantFrame_UpdateRepairButtons', function()
        if MerchantRepairAllButton:IsShown() then
            local co = GetRepairAllCost()--显示，修理所有，金钱
            local col= co==0 and '|cff606060' or (co<= GetMoney() and '|cnGREEN_FONT_COLOR:') or '|cnRED_FONT_COLOR:'
            MerchantRepairAllButton.Text2:SetText(col..e.MK(co/10000, 0))

            local num=0--提示，可修理，件数
            for i= 1, 18 do
                local cur2, max2 = GetInventoryItemDurability(i)
                if cur2 and max2 and max2>cur2 and max2>0 then
                    num= num+1
                end
            end
            MerchantRepairItemButton.Text:SetText((num==0 and '|cff606060' or '|cnGREEN_FONT_COLOR:')..num)

            AutoRepairCheck.Text:SetText(e.GetDurabiliy(true))--显示耐久度
        end
    end)

    MerchantRepairAllButton:SetScript('OnEnter', function(self)--替换，源FUNC
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        local repairAllCost, canRepair = GetRepairAllCost()
        if ( canRepair and (repairAllCost > 0) ) then
            GameTooltip:SetText(e.onlyChinese and '修理所有物品' or REPAIR_ALL_ITEMS)
            SetTooltipMoney(GameTooltip, repairAllCost)
            local personalMoney = GetMoney()
            if(repairAllCost > personalMoney) then
                GameTooltip:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '没有足够的资金来修理所有物品' or GUILDBANK_REPAIR_INSUFFICIENT_FUNDS))
            end
        end
        GameTooltip:AddLine(' ')
        e.GetDurabiliy_OnEnter()
        GameTooltip:Show()
    end)
end





























--自动出售
local function Init_Auto_Sell_Junk()
    AutoSellJunkCheck=CreateFrame("CheckButton", nil, MerchantSellAllJunkButton, "InterfaceOptionsCheckButtonTemplate")
    AutoSellJunkCheck:SetSize(18,18)
    AutoSellJunkCheck:SetPoint('BOTTOMLEFT', MerchantSellAllJunkButton, -4,-5)

    AutoSellJunkCheck.Texture= MerchantSellAllJunkButton:CreateTexture(nil, 'OVERLAY')
    AutoSellJunkCheck.Texture:SetSize(14,14)
    AutoSellJunkCheck.Texture:SetTexture(132288)
    AutoSellJunkCheck.Texture:SetPoint('TOPLEFT', -2, 2)

    function AutoSellJunkCheck:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine('|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '自动出售垃圾' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SELL_ALL_JUNK_ITEMS_EXCLUDE_HEADER), e.GetEnabeleDisable(not Save.notSellJunk))
        if not Save.notSellJunk then
            e.tips:AddLine(format(e.onlyChinese and '品质：%s' or PROFESSIONS_CRAFTING_QUALITY, '|cff606060'..(e.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC)..'|r'))
            e.tips:AddDoubleLine(e.onlyChinese and '未收集幻化' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NOT_COLLECTED, TRANSMOGRIFICATION), Save.sellJunkMago and '|cnRED_FONT_COLOR:'..(e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB) or (e.onlyChinese and '不出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, DISABLE, AUCTION_HOUSE_SELL_TAB)))
        end
        e.tips:Show()
    end
    function AutoSellJunkCheck:settings()
        self.Texture:SetShown(Save.sellJunkMago and not Save.notSellJunk)
        self:SetChecked(not Save.notSellJunk)
        self:set_sell_junk()--出售物品
    end
    AutoSellJunkCheck:SetScript('OnClick', function(self)
        Save.notSellJunk= not Save.notSellJunk and true or nil
        self:settings()
        self:set_tooltip()
    end)
    AutoSellJunkCheck:SetScript('OnLeave', GameTooltip_Hide)--self:SetAlpha(0.3)
    AutoSellJunkCheck:SetScript('OnEnter', AutoSellJunkCheck.set_tooltip)


    function AutoSellJunkCheck:set_sell_junk()--出售物品
        if IsModifierKeyDown() or not C_MerchantFrame.IsSellAllJunkEnabled() or UnitAffectingCombat('player') then
            return
        end
        local num, gruop, preceTotale= 0, 0, 0
        for bag= Enum.BagIndex.Backpack, NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES do
            for slot=1, C_Container.GetContainerNumSlots(bag) do--背包数量
                local info = C_Container.GetContainerItemInfo(bag,slot)
                if info
                    and info.hyperlink
                    and info.itemID
                    and info.quality
                    and (info.quality<5 or Save.Sell[info.itemID]and not Save.notSellCustom)
                then
                    local checkText= e.CheckItemSell(info.itemID, info.hyperlink, info.quality, info.isBound)--检察 ,boss掉落, 指定 或 出售灰色,宠物
                    if not info.isLocked and checkText then
                        C_Container.UseContainerItem(bag, slot)--买出

                        local prece =0
                        if not info.hasNoValue then--卖出钱
                            prece = (select(11, C_Item.GetItemInfo(info.hyperlink)) or 0) * (C_Container.stackCount or 1)--价格
                            preceTotale = preceTotale + prece
                        end
                        gruop= gruop+ 1
                        num= num+ (C_Container.stackCount or 1)--数量

                        print('|cnRED_FONT_COLOR:'..gruop..')|r', checkText or '', info.hyperlink, C_CurrencyInfo.GetCoinTextureString(prece))

                        if gruop>= 11 then
                            break
                        end
                    end
                    if gruop>= 11 then
                        break
                    end
                end
            end
        end
        if num > 0 then
            print(
                id, Initializer:GetName(),
                (e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)..' |cnGREEN_FONT_COLOR:'..gruop..'|r'..(e.onlyChinese and '组' or AUCTION_PRICE_PER_STACK),
                '|cnGREEN_FONT_COLOR:'..num..'|r'..(e.onlyChinese and '件' or AUCTION_HOUSE_QUANTITY_LABEL),
                C_CurrencyInfo.GetCoinTextureString(preceTotale)
            )
        end
    end
    AutoSellJunkCheck:RegisterEvent('MERCHANT_SHOW')
    AutoSellJunkCheck:SetScript('OnEvent', AutoSellJunkCheck.set_sell_junk)

    AutoSellJunkCheck.Texture:SetShown(Save.sellJunkMago and not Save.notSellJunk)
    AutoSellJunkCheck:SetChecked(not Save.notSellJunk)

    --提示，垃圾，数量
    MerchantSellAllJunkButton:HookScript('OnEnter', function()
        e.tips:AddDoubleLine(e.onlyChinese and '垃圾' or BAG_FILTER_JUNK , '|cnGREEN_FONT_COLOR:'..(C_MerchantFrame.GetNumJunkItems() or 0))
        e.tips:Show()
    end)
    MerchantSellAllJunkButton.Text= e.Cstr(MerchantSellAllJunkButton, {justifyH='RIGHT'})
    MerchantSellAllJunkButton.Text:SetPoint('TOPRIGHT',-2, -2)
    hooksecurefunc('MerchantFrame_Update', function()
        if not MerchantSellAllJunkButton:IsVisible() then
            return
        end
        local num= C_MerchantFrame.GetNumJunkItems() or 0
        MerchantSellAllJunkButton.Text:SetText((num==0 and '|cff606060' or '|cnGREEN_FONT_COLOR:')..num)
    end)
end























--自动拾取 Plus
local function Init_Loot_Plus()
    if Save.notAutoLootPlus then
        return
    end
    local check=CreateFrame("CheckButton", nil, LootFrame.TitleContainer, "InterfaceOptionsCheckButtonTemplate")
    check:SetPoint('TOPLEFT',-27,2)

    check:SetScript('OnClick', function()
        if UnitAffectingCombat('player') then
            return
        end
        C_CVar.SetCVar("autoLootDefault", not C_CVar.GetCVarBool("autoLootDefault") and '1' or '0')
        local value= C_CVar.GetCVarBool("autoLootDefault")
        print(id, Initializer:GetName(), '|cffff00ff|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus|r|n', not e.onlyChinese and AUTO_LOOT_DEFAULT_TEXT or "自动拾取", e.GetEnabeleDisable(value))
        if value and not IsModifierKeyDown() then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
        end
    end)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        e.tips:AddLine('|cffff00ff|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus|r')
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '自动拾取' or AUTO_LOOT_DEFAULT_TEXT, (e.onlyChinese and '当前' or REFORGE_CURRENT)..': '..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
        local col= UnitAffectingCombat('player') and '|cff606060'
        e.tips:AddDoubleLine((col or '')..(e.onlyChinese and '拾取时' or PROC_EVENT512_DESC:format(ITEM_LOOT)),
            (col or '|cnGREEN_FONT_COLOR:')..'Shift|r '..(e.onlyChinese and '禁用' or DISABLE))
        e.tips:Show()
    end)
    check:SetScript('OnShow', function(self)
        self:SetEnabled(not UnitAffectingCombat('player'))
        self:SetChecked(C_CVar.GetCVarBool("autoLootDefault"))
    end)

    check:RegisterEvent('LOOT_READY')
    check:SetScript('OnEvent', function()
        if IsShiftKeyDown() and not UnitAffectingCombat('player') then
            C_CVar.SetCVar("autoLootDefault", '0')
            print(id, Initializer:GetName(),'|cffff00ff|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus|r','|cnGREEN_FONT_COLOR:Shift|r', e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT, e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")))
        elseif C_CVar.GetCVarBool("autoLootDefault") then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
        end
    end)
end























--#######
--设置菜单
--#######
local function Init_Menu(_, level, type)
    local info
    if type=='SELLJUNK' then--出售垃圾
        info= {
            text= e.onlyChinese and '幻化' or TRANSMOGRIFICATION,
            checked= Save.sellJunkMago,
            tooltipOnButton=true,
            tooltipTitle= '|cff9d9d9d'..(e.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC),
            keepShownOnClick=true,
            func= function()
                Save.sellJunkMago= not Save.sellJunkMago and true or nil
                AutoSellJunkCheck:settings()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='CUSTOM' then--二级菜单, 自定义出售
        for itemID, _ in pairs(Save.Sell) do
            if itemID  then
                e.LoadDate({id=itemID, type='item'})
                local itemLink= select(2, C_Item.GetItemInfo(itemID))
                itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
                info= {
                    text= itemLink,
                    icon= C_Item.GetItemIconByID(itemID),
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=e.onlyChinese and '移除' or REMOVE,
                    arg1= itemID,
                    arg2= itemLink,
                    func=function(_, arg1, arg2)
                        Save.Sell[arg1]= nil
                        print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r'..(e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB)..'|r', arg2, arg1)
                    end
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                Save.Sell={}
                e.LibDD:CloseDropDownMenus()
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='BOSS' then--二级菜单, BOSS
        for itemID, itemLevel in pairs(bossSave) do
            e.LoadDate({itemID=itemID, type='item'})
            local itemLink= select(2, C_Item.GetItemInfo(itemID)) or itemID
            info= {
                text= itemLink..'('..itemLevel..')',
                notCheckable=true,
                icon= C_Item.GetItemIconByID(itemID),
                tooltipOnButton=true,
                tooltipTitle=e.onlyChinese and '移除' or REMOVE,
                arg1= itemID,
                arg2= itemLink,
                func=function(_, arg1, arg2)
                    Save.bossSave[arg1]=nil
                    print(id, Initializer:GetName(), arg2, arg1)
                end,
            }
            e.LibDD:UIDropDownMenu_AddButton(info, level)
        end

        info= {
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                bossSave={}
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=e.onlyChinese and '保存' or SAVE,
            checked= Save.saveBossLootList,
            keepShownOnClick=true,
            func=function ()
                Save.saveBossLootList = not Save.saveBossLootList and true or nil
            end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='BUY' then--二级菜单, 购买物品
        for itemID, num in pairs(buySave) do
            if itemID and num then
                e.LoadDate({id=itemID, type='item'})
                local bag=C_Item.GetItemCount(itemID)
                local bank=C_Item.GetItemCount(itemID, true, false, true)-bag
                local itemLink= select(2, C_Item.GetItemInfo(itemID))
                itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
                info= {
                    text='|cnGREEN_FONT_COLOR:'..num..'|r '..itemLink..' '..'|cnYELLOW_FONT_COLOR:'..bag..'|A:bag-main:0:0|a'..bank..'|A:Banker:0:0|a'..'|r',
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=e.onlyChinese and '移除' or REMOVE,
                    icon= C_Item.GetItemIconByID(itemID),
                    arg1= itemID,
                    arg2= itemLink,
                    func=function(_, arg1, arg2)
                        buySave[arg1]=nil
                        Set_Merchant_Info()--设置, 提示, 信息
                        print(id, Initializer:GetName(), arg2, arg1)
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end

        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info= {
            text=e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                buySave={}
                Set_Merchant_Info()--设置, 提示, 信息
                e.LibDD:CloseDropDownMenus()
           end
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return

    elseif type=='BUYBACK' then--二级菜单, 购回物品
        for itemID, _ in pairs(Save.noSell) do
            if itemID then
                e.LoadDate({id=itemID, type='item'})
                local bag=C_Item.GetItemCount(itemID)
                local bank=C_Item.GetItemCount(itemID, true, false, true)-bag
                local itemLink= select(2, C_Item.GetItemInfo(itemID))
                itemLink= itemLink or C_Item.GetItemNameByID(itemID) or ('itemID: ' .. itemID)
                info= {
                    text=itemLink..' '..'|cnYELLOW_FONT_COLOR:'..bag..'|A:bag-main:0:0|a'..bank..'|A:Banker:0:0|a'..'|r',
                    notCheckable=true,
                    tooltipOnButton=true,
                    tooltipTitle=e.onlyChinese and '移除' or REMOVE,
                    icon= C_Item.GetItemIconByID(itemID),
                    arg1= itemID,
                    arg2= itemLink,
                    func=function(_, arg1, arg2)
                        Save.noSell[arg1]=nil
                        print(id, Initializer:GetName(), arg2, arg1)
                        BuybackButton:set_text()--回购，数量，提示
                    end,
                }
                e.LibDD:UIDropDownMenu_AddButton(info, level)
            end
        end
        e.LibDD:UIDropDownMenu_AddSeparator(level)
        info ={
            text= e.onlyChinese and '清除全部' or CLEAR_ALL,
            notCheckable=true,
            func=function ()
                Save.noSell={}
                BuybackButton:set_text()--回购，数量，提示
            end,
        }
        e.LibDD:UIDropDownMenu_AddButton(info, level)
        return
    end

    local num
    info ={--出售垃圾
        text= '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '自动出售垃圾' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, SELL_ALL_JUNK_ITEMS_EXCLUDE_HEADER))..(Save.sellJunkMago and '|T132288:0|t' or ''),
        checked= not Save.notSellJunk,
        menuList= 'SELLJUNK',
        hasArrow= true,
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle=format(e.onlyChinese and '品质：%s' or PROFESSIONS_CRAFTING_QUALITY, '|cff606060'..(e.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC)..'|r')
            ..'|n|cffff00ff'..(e.onlyChinese and '在战斗中无法出售物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)),
        func= function()
            Save.notSellJunk= not Save.notSellJunk and true or nil
            AutoSellJunkCheck:settings()
        end,

    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    num=0
    for _, boolean in pairs(Save.Sell) do
        if boolean then
            num=num+1
        end
    end
    info = {
        text= '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '出售自定义' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB, CUSTOM))..'|cnRED_FONT_COLOR: #'..num..'|r',
        checked= not Save.notSellCustom,
        tooltipOnButton=true,
        tooltipTitle='|cffff00ff'..(e.onlyChinese and '在战斗中无法出售物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)),
        menuList='CUSTOM',
        hasArrow=true,
        func=function ()
            Save.notSellCustom= not Save.notSellCustom and true or nil
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    num=0
    for itemID, _ in pairs(bossSave) do
        if itemID then
            num=num+1
        end
    end
    local avgItemLevel= GetAverageItemLevel() or 30
    avgItemLevel= avgItemLevel<30 and 30 or avgItemLevel
    info = {--出售BOSS掉落
        text= '|A:bags-button-autosort-up:0:0|a'..(e.onlyChinese and '出售首领掉落' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, AUCTION_HOUSE_SELL_TAB,TRANSMOG_SOURCE_1))..'|cnRED_FONT_COLOR: #'..num..'|r',
        tooltipOnButton=true,
        tooltipTitle= (e.onlyChinese and '物品等级' or STAT_AVERAGE_ITEM_LEVEL)..' < ' ..math.ceil(avgItemLevel),
        tooltipText= '|cffff00ff'..(e.onlyChinese and '在战斗中无法出售物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT, ITEM_UNSELLABLE)),
        checked= not Save.notSellBoss,
        keepShownOnClick=true,
        menuList='BOSS',
        hasArrow=true,
        func=function ()
            Save.notSellBoss= not Save.notSellBoss and true or nil
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    num= BuybackButton:set_text()--回购，数量，提示
    info ={--购回
        text= '    |A:common-icon-undo:0:0|a'..(e.onlyChinese and '回购' or BUYBACK)..'|cnGREEN_FONT_COLOR: #'..num..'|r',
        notCheckable=true,
        menuList='BUYBACK',
        keepShownOnClick=true,
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    num= BuyItemButton:set_text()--回购，数量，提示
    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--购买物品
        text= '|T236994:0|t'..(e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..'|cnGREEN_FONT_COLOR: #'..num..'|r',
        checked=not Save.notAutoBuy,
        keepShownOnClick=true,
        func=function ()
            if Save.notAutoBuy then
                Save.notAutoBuy=nil
            else
                Save.notAutoBuy=true
            end
            Set_Merchant_Info()--设置, 提示, 信息
            BuyItemButton:set_text()--回购，数量，提示
        end,
        menuList='BUY',
        hasArrow=true,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    local text=	(e.onlyChinese and '修理' or MINIMAP_TRACKING_REPAIR)..': '..RepairSave.num..' '..(e.onlyChinese and '次' or VOICEMACRO_LABEL_CHARGE1)
                ..'|n'..(e.onlyChinese and '公会' or GUILD)..': '..C_CurrencyInfo.GetCoinTextureString(RepairSave.guild)
                ..'|n'..(e.onlyChinese and '玩家' or PLAYER)..': '..C_CurrencyInfo.GetCoinTextureString(RepairSave.player)
    if RepairSave.guild>0 and RepairSave.player>0 then
        text=text..'|n|n'..(e.onlyChinese and '合计' or TOTAL)..': '..C_CurrencyInfo.GetCoinTextureString(RepairSave.guild+RepairSave.player)
    end
    text=text..'|n|n'..(e.onlyChinese and '使用公会资金修理' or GUILDCONTROL_OPTION15_TOOLTIP)..'|n'..C_CurrencyInfo.GetCoinTextureString(CanGuildBankRepair() and GetGuildBankMoney() or 0)

    info={--自动修理
        text= '|A:SpellIcon-256x256-RepairAll:0:0|a'..(e.onlyChinese and '自动修理所有物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, REPAIR_ALL_ITEMS)),
        checked=not Save.notAutoRepairAll,
        keepShownOnClick=true,
        func=function()
            Save.notAutoRepairAll= not Save.notAutoRepairAll and true or nil
            AutoRepairCheck:set_repair_all()
            AutoRepairCheck:SetChecked(not Save.notAutoRepairAll)
        end,
        tooltipOnButton=true,
        tooltipTitle= '|cffff00ff'..(e.onlyChinese and '记录' or EVENTTRACE_LOG_HEADER).. '|r '..RepairSave.date,
        tooltipText=text,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    info= {--商人 Plus
        text= '|A:communities-icon-addgroupplus:0:0|a'..(e.onlyChinese and '商人 Plus' or  format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, MERCHANT, 'Plus')),
        checked= not Save.notPlus,
        keepShownOnClick=true,
        func=function ()
            Save.notPlus = not Save.notPlus and true or nil
            print(id, Initializer:GetName(), '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    e.LibDD:UIDropDownMenu_AddSeparator(level)
    info={--删除字符
        text= '|A:common-icon-redx:0:0|a'..(e.onlyChinese and '自动输入DELETE' or (RUNECARVER_SCRAPPING_CONFIRMATION_TEXT..': '..DELETE_ITEM_CONFIRM_STRING)),
        checked= not Save.notDELETE,
        keepShownOnClick=true,
        func=function ()
            Save.notDELETE= not Save.notDELETE and true or nil
        end,
        tooltipOnButton=true,
        tooltipTitle= e.onlyChinese and '你真的要摧毁%s吗？|n|n请在输入框中输入 DELETE 以确认。' or DELETE_GOOD_ITEM,
    }
    e.LibDD:UIDropDownMenu_AddButton(info)

    info={
        text= '|A:Cursor_lootall_128:0:0|a'..(e.onlyChinese and "自动拾取" or AUTO_LOOT_DEFAULT_TEXT)..' Plus',
        checked= not Save.notAutoLootPlus,
        keepShownOnClick=true,
        tooltipOnButton=true,
        tooltipTitle=(not e.onlyChinese and AUTO_LOOT_DEFAULT_TEXT..', '..REFORGE_CURRENT or '自动拾取, 当前: ')..e.GetEnabeleDisable(C_CVar.GetCVarBool("autoLootDefault")),
        tooltipText= (not e.onlyChinese and HUD_EDIT_MODE_LOOT_FRAME_LABEL..'Shift: '..DISABLE or '拾取窗口 Shift: 禁用')..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '不在战斗中' or 'not in combat'),
        func= function()
            Save.notAutoLootPlus= not Save.notAutoLootPlus and true or nil
            print(id, Initializer:GetName(), '|cnRED_FONT_COLOR:',e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
        end

    }
    e.LibDD:UIDropDownMenu_AddButton(info)
    info={
        text= '    |A:SpellIcon-256x256-SellJunk:0:0|a'..(e.onlyChinese and '选项' or OPTIONS),
        notCheckable=true,
        func= function()
            e.OpenPanelOpting(Initializer:GetName())
        end
    }
    e.LibDD:UIDropDownMenu_AddButton(info)
end





















--购买物品
local function Init_Buy_Items_Button()
    BuyItemButton=e.Cbtn(MerchantBuyBackItem, {size={22,22}, icon='hide'})
    BuyItemButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,-4)
    function BuyItemButton:set_texture()
        self:SetNormalTexture(236994)
    end
    BuyItemButton:set_texture()
    function BuyItemButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())

        local num= self:set_text()--回购，数量，提示

        e.tips:AddDoubleLine('|T236994:0|t|cffff00ff'..(e.onlyChinese and '自动购买物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE)), '|cnGREEN_FONT_COLOR: #'..num..'|r')

        e.tips:AddLine(' ')
        local infoType, itemIDorIndex, itemLink = GetCursorInfo()
        if infoType=='item' and itemIDorIndex and itemLink then
            local icon= C_Item.GetItemIconByID(itemLink)
            local name= '|T'..(icon or 0)..':0|t'..itemLink
            if Save.Sell[itemIDorIndex] then
                e.tips:AddDoubleLine(name, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, REMOVE, AUCTION_HOUSE_SELL_TAB)))
                self:SetNormalAtlas('bags-button-autosort-up')
            else
                e.tips:AddDoubleLine(name, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加出售' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADD, AUCTION_HOUSE_SELL_TAB)))
                if icon then
                    self:SetNormalTexture(icon)
                end
            end
        elseif infoType=='merchant' and itemIDorIndex then--购买物品
            local itemID= GetMerchantItemID(itemIDorIndex)
            local icon= select(2, GetMerchantItemInfo(itemIDorIndex))
            itemLink= GetMerchantItemLink(itemIDorIndex)
            if itemID and itemLink then
                local name = '|T'..(icon or 0)..':0|t'..itemLink
                if buySave[itemID] then
                    e.tips:AddDoubleLine(name..' x|cnGREEN_FONT_COLOR:'..buySave[itemID], '|cffff00ff'..(e.onlyChinese and '修改' or EDIT)..e.Icon.left)
                else
                    e.tips:AddDoubleLine(name, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '购买' or PURCHASE)..e.Icon.left)
                end
                if icon then
                    self:SetNormalTexture(icon)
                end
            end
        else
            e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '出售/购买' or (AUCTION_HOUSE_SELL_TAB..'/'..PURCHASE))
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        end
        e.tips:Show()
    end

    BuyItemButton:SetScript('OnLeave', function(self) GameTooltip_Hide() self:set_texture() end)
    BuyItemButton:SetScript('OnEnter', BuyItemButton.set_tooltip)
    BuyItemButton:SetScript('OnMouseUp', BuyItemButton.set_texture)
    BuyItemButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='item' and itemID then
            if Save.Sell[itemID] then
                Save.Sell[itemID]=nil
                print(id, Initializer:GetName(), '|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..'|r', e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB, itemLink)
            else
                Save.Sell[itemID]=true
                Save.noSell[itemID]=nil
                buySave[itemID]=nil
                print(id,Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r'..(e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB), itemLink )
                AutoSellJunkCheck:set_sell_junk()--出售物品
            end
            ClearCursor()
            BuyItemButton:set_text()--回购，数量，提示
        elseif infoType=='merchant' and itemID then--购买物品
            local index=itemID
            itemID= GetMerchantItemID(index)
            itemLink=GetMerchantItemLink(index)
            if itemID and itemLink then
                local icon
                icon= C_Item.GetItemIconByID(itemLink)
                icon= icon and '|T'..icon..':0|t' or ''
                StaticPopupDialogs[id..addName..'Buy']= {
                    text =id..' '..addName
                    ..'|n|n'.. (e.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..icon ..itemLink
                    ..'|n|n'..e.Icon.player..e.Player.name_realm..': ' ..(e.onlyChinese and '数量' or AUCTION_HOUSE_QUANTITY_LABEL)
                    ..'|n|n0: '..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)
                    ..(Save.notAutoBuy and '|n|n'..(e.onlyChinese and '自动购买' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SELF_CAST_AUTO, PURCHASE))..': '..e.GetEnabeleDisable(false) or ''),
                    button1 = e.onlyChinese and '购买' or PURCHASE,
                    button2 = e.onlyChinese and '取消' or CANCEL,
                    whileDead=true, hideOnEscape=true, exclusive=true, hasEditBox=true,
                    OnAccept=function(s)
                        local num= s.editBox:GetNumber()
                        if num==0 then
                            buySave[itemID]=nil
                            print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2)..'|r', itemLink)
                        else
                            buySave[itemID]=num
                            Save.Sell[itemID]=nil
                            print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '购买' or PURCHASE)..'|rx|cffff00ff'..num..'|r', itemLink)
                            BuyItemButton:set_buy_item()--购买物品
                        end
                        BuyItemButton:set_text()--回购，数量，提示
                        Set_Merchant_Info()--设置, 提示, 信息
                    end,
                    OnShow=function(s)
                        s.editBox:SetNumeric(true)

                        if buySave[itemID] then
                            s.editBox:SetText(buySave[itemID])
                        end
                    end,
                    OnHide= function(self3)
                        self3.editBox:SetText("")
                        e.call('ChatEdit_FocusActiveWindow')
                    end,
                    EditBoxOnEscapePressed = function(s)
                        s:SetAutoFocus(false)
                        s:ClearFocus()
                        s:GetParent():Hide()
                    end,
                }
                StaticPopup_Show(id..addName..'Buy')
                ClearCursor()
            end
        else
            if not self.Menu then
                self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(self.Menu, Init_Menu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
        end
    end)

    function BuyItemButton:set_buy_item()--购买物品
        local numAllItems= GetMerchantNumItems() or 0
        if IsModifierKeyDown() or Save.notAutoBuy or numAllItems==0 then
            return
        end
        local Tab={}
        for index=1, numAllItems do
            local itemID=GetMerchantItemID(index)
            local num= itemID and buySave[itemID]
            if itemID and num then
                local buyNum=num-C_Item.GetItemCount(itemID, true, false, true)
                if buyNum>0 then
                    local maxStack = GetMerchantItemMaxStack(index)
                    local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(index)
                    local canAfford
                    if (price and price > 0) then
                        canAfford = floor(GetMoney() / (price / stackCount))
                    end
                    if (extendedCost) then
                        for i = 1, MAX_ITEM_COST do
                            local _, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i)
                            if itemLink and itemValue and itemValue>0 then
                                if not currencyName then
                                    local myCount = C_Item.GetItemCount(itemLink, false, false, true)
                                    local value= floor(myCount / (itemValue / stackCount))
                                    canAfford=not canAfford and value or min(canAfford, value)
                                elseif currencyName then
                                   local info= C_CurrencyInfo.GetCurrencyInfoFromLink(itemLink)
                                   if info and info.quantity then
                                        local value=floor(info.quantity / (itemValue / stackCount))
                                        canAfford= not canAfford and value or min(canAfford, value)
                                    else
                                        canAfford=0
                                   end
                                end
                            end
                        end
                    end
                    if canAfford and canAfford>=buyNum and floor(buyNum/stackCount)>0 then
                        while buyNum>0 do
                            local stack=floor(buyNum/stackCount)
                            if IsModifierKeyDown() or stack<1 then
                                break
                            end
                            local buy=buyNum
                            if stackCount>1 then
                                if buy>=maxStack then
                                    buy=maxStack
                                else
                                    buy=stack*stackCount
                                end
                            else
                                buy=buy>maxStack and maxStack or buy
                            end
                            BuyMerchantItem(index, buy)
                            buyNum=buyNum-buy
                        end
                        local itemLink=GetMerchantItemLink(index)
                        if itemLink then
                            Tab[itemLink]=num
                        end
                    end
                end
            end
        end
        C_Timer.After(1.5, function()
            for itemLink2, num2 in pairs(Tab) do
                print(Initializer:GetName(), e.onlyChinese and '正在购买' or TUTORIAL_TITLE20, '|cnGREEN_FONT_COLOR:'..num2..'|r', itemLink2)
            end
        end)
    end
    BuyItemButton:RegisterEvent('MERCHANT_SHOW')
    BuyItemButton:SetScript('OnEvent', BuyItemButton.set_buy_item)--购买物品

    BuyItemButton.Text= e.Cstr(BuyItemButton, {justifyH='CENTER'})
    BuyItemButton.Text:SetPoint('CENTER', 2, 0)
    function BuyItemButton:set_text()--回购，数量，提示
        local num= 0
        for _ in pairs(buySave) do
            num= num +1
        end
        self.Text:SetText(not Save.notAutoBuy and num or '')
        return num
    end
    BuyItemButton:set_text()--回购，数量，提示
end



























--回购物品
local function Init_Buyback_Button()
    BuybackButton= e.Cbtn(MerchantBuyBackItem, {size={22,22}, icon='hide'})--nil, false)--购回
    function BuybackButton:set_texture()
        self:SetNormalAtlas('common-icon-undo')
    end
    BuybackButton:SetPoint('BOTTOMRIGHT', MerchantBuyBackItem, 6,18)

    function BuybackButton:set_tooltip()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, Initializer:GetName())
        local num= self:set_text()
        e.tips:AddDoubleLine('|cffff00ff'..(e.onlyChinese and '回购' or BUYBACK), '|cnGREEN_FONT_COLOR: #'..num)
        e.tips:AddLine(' ')
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='merchant' and itemID then
            itemLink= GetMerchantItemLink(itemID)
            itemID= GetMerchantItemID(itemID)
        end
        if (infoType=='item' or infoType=='merchant') and itemID and itemLink then
            local icon= '|T'..(C_Item.GetItemIconByID(itemLink) or 0)..':0|t'..itemLink
            if Save.noSell[itemID] then
                e.tips:AddDoubleLine(icon, '|A:bags-button-autosort-up:0:0|a|cnRED_FONT_COLOR:'..(e.onlyChinese and '移除' or REMOVE)..e.Icon.left)
                self:SetNormalAtlas('bags-button-autosort-up')
            else
                e.tips:AddDoubleLine(icon, '|A:common-icon-undo:0:0|a|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.left)
                local icon= C_Item.GetItemIconByID(itemLink)
                if icon then
                    self:SetNormalTexture(icon)
                end
            end
        else
            local num= GetNumBuybackItems()
	        local buybackName, buybackTexture= GetBuybackItemInfo(num)
            if buybackName then
                local itemID = C_MerchantFrame.GetBuybackItemID(num)
                if itemID then
                    e.tips:AddDoubleLine(
                        '|T'..(buybackTexture or 0)..':0|t'..(GetMerchantItemLink(num) or buybackName),
                        '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..e.Icon.left
                    )
                    e.tips:AddLine(' ')
                    if buybackTexture then
                        self:SetNormalTexture(buybackTexture)
                    end
                end
            end
            e.tips:AddDoubleLine((e.onlyChinese and '拖曳' or DRAG_MODEL)..e.Icon.left..(e.onlyChinese and '物品' or ITEMS), e.onlyChinese and '回购' or BUYBACK)
            e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.right)
        end
        e.tips:Show()
    end
    BuybackButton:SetScript('OnMouseDown', function(self, d)
        local infoType, itemID, itemLink = GetCursorInfo()
        if infoType=='merchant' and itemID then--购买物品
            itemLink= GetMerchantItemLink(itemID)
            itemID= GetMerchantItemID(itemID)
        end
        if (infoType=='item' or infoType=='merchant') and itemID then
            if Save.noSell[itemID] then
                Save.noSell[itemID]=nil
                print(id, Initializer:GetName(),'|cnRED_FONT_COLOR:', e.onlyChinese and '移除' or REMOVE, e.onlyChinese and '回购' or BUYBACK, itemLink)
            else
                Save.noSell[itemID]=true
                Save.Sell[itemID]=nil
                print(id,Initializer:GetName(), '|cnGREEN_FONT_COLOR:', e.onlyChinese and '添加' or ADD, e.onlyChinese and '回购' or BUYBACK, itemLink )
                self:set_buyback_item()--购回物品
            end
            ClearCursor()
            self:set_tooltip()

        elseif d=='RightButton' then
            if not BuyItemButton.Menu then
                BuyItemButton.Menu=CreateFrame("Frame", nil, BuyItemButton, "UIDropDownMenuTemplate")
                e.LibDD:UIDropDownMenu_Initialize(BuyItemButton.Menu, Init_Menu, 'MENU')
            end
            e.LibDD:ToggleDropDownMenu(1, nil, BuyItemButton.Menu, self, 15, 0)

        elseif d=='LeftButton' then
            local num= GetNumBuybackItems()
	        local buybackName= GetBuybackItemInfo(num)
            if buybackName then
                local itemID = C_MerchantFrame.GetBuybackItemID(num)
                if itemID then
                    Save.noSell[itemID]= true
                    Save.Sell[itemID]= nil
                    print(id,Initializer:GetName(), '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '添加' or ADD)..'|r', e.onlyChinese and '回购' or BUYBACK, GetMerchantItemLink(num) or buybackName)
                    self:set_buyback_item()--购回物品
                end
            end
            self:set_tooltip()
        end

    end)
    BuybackButton:SetScript('OnMouseUp', function(self) self:set_texture() self:set_tooltip() end)
    BuybackButton:SetScript('OnLeave', function(self) self:set_texture() GameTooltip_Hide() end)
    BuybackButton:SetScript('OnEnter', BuybackButton.set_tooltip)

    BuybackButton.Text= e.Cstr(BuybackButton, {justifyH='CENTER'})
    BuybackButton.Text:SetPoint('CENTER', 2, 0)
    function BuybackButton:set_text()--回购，数量，提示
        local num= 0
        for _ in pairs(Save.noSell) do
            num= num +1
        end
        self.Text:SetText(num>0 and num or '')
        return num
    end


    function BuybackButton:set_buyback_item()--购回物品
        local num= GetNumBuybackItems() or 0
        if IsModifierKeyDown() or num==0 then
            return
        end
        local tab={}
        local no={}
        for index=1, num do
            local itemID = C_MerchantFrame.GetBuybackItemID(index)
            if itemID and Save.noSell[itemID] then
                local itemLink= GetBuybackItemLink(index) or itemID
                local co= select(3, GetBuybackItemInfo(index)) or 0
                if co<=GetMoney() then
                    table.insert(tab, itemLink)
                    BuybackItem(index)
                else
                    table.insert(no, {itemLink, co or 0})
                end
            end
        end
        C_Timer.After(0.3, function()
            for index, itemLink in pairs(tab) do
                print(id, Initializer:GetName(), index..')|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '购回' or BUYBACK), itemLink)
            end
            for index, info in pairs(no) do
                print(id, Initializer:GetName(), index..')|cnRED_FONT_COLOR:'..(e.onlyChinese and '购回失败' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, BUYBACK, INCOMPLETE)), info[1], C_CurrencyInfo.GetCoinTextureString(info[2]))
            end
        end)
    end
    BuybackButton:RegisterEvent('MERCHANT_UPDATE')
    BuybackButton:RegisterEvent('MERCHANT_SHOW')
    BuybackButton:SetScript('OnEvent', BuybackButton.set_buyback_item)

    BuybackButton:set_texture()
    BuybackButton:set_text()--回购，数量，提示


    --清除，回购买，图标
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:ClearAllPoints()
    MerchantBuyBackItemItemButton.UndoFrame.Arrow:SetTexture(0)
end

























--####
--初始
--####
local DELETE_ITEM_CONFIRM_STRING= DELETE_ITEM_CONFIRM_STRING
local COMMUNITIES_DELETE_CONFIRM_STRING= COMMUNITIES_DELETE_CONFIRM_STRING
local function Init()
    Init_Loot_Plus()--自动拾取 Plus
    Init_Auto_Repair()--自动修理
    Init_Auto_Sell_Junk()--自动出售
    Init_Plus()--商人 Plus
    Init_Buy_Items_Button()--购买物品
    Init_Buyback_Button()--回购物品
    --######
    --DELETE
    --######
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"],"OnShow",function(self)
        if not Save.notDELETE then
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
        end
    end)
    hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"], "OnShow",function(self)
        if not Save.notDELETE and self.editBox then
            self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
        end
    end)
    hooksecurefunc(StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"],"OnShow",function(self)
        if not Save.notDELETE and self.editBox then
            self.editBox:SetText(COMMUNITIES_DELETE_CONFIRM_STRING)
        end
    end)





end































--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('ENCOUNTER_LOOT_RECEIVED')
panel:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, _, arg5)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            Save.numLine= Save.numLine or 6
            bossSave= Save.bossSave or {}

            --添加控制面板
            Initializer= e.AddPanel_Check({
                name= '|A:SpellIcon-256x256-SellJunk:0:0|a'..(e.onlyChinese and '商人' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, Initializer:GetName(), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '重新加载UI' or RELOADUI)
                end
            })



            if Save.disabled then
                e.CheckItemSell=nil
                panel:UnregisterAllEvents()
            else
                if WoWToolsSave then
                    buySave=WoWToolsSave.BuyItems and WoWToolsSave.BuyItems[e.Player.name_realm] or buySave--购买物品
                    RepairSave=WoWToolsSave.Repair and WoWToolsSave.Repair[e.Player.name_realm] or RepairSave--修理
                end

                Init()
                panel:UnregisterEvent('ADDON_LOADED')
            end
            panel:RegisterEvent("PLAYER_LOGOUT")
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if Save.saveBossLootList then
                Save.bossSave= bossSave
            else
                Save.bossSave=nil
            end
            WoWToolsSave[addName]=Save
            WoWToolsSave.BuyItems=WoWToolsSave.BuyItems or {}--购买物品
            WoWToolsSave.BuyItems[e.Player.name_realm]=buySave
            WoWToolsSave.Repair=WoWToolsSave.Repair or {}--修理
            WoWToolsSave.Repair[e.Player.name_realm] = RepairSave

        end



    elseif event=='ENCOUNTER_LOOT_RECEIVED' then--买出BOOS装备
        if IsInInstance() and arg5 and arg5:find(e.Player.name) then
            local itemID, itemLink= arg2, arg3
            local avgItemLevel= GetAverageItemLevel() or 30
            local _, _, itemQuality, itemLevel, _, _, _, _, itemEquipLoc, _, _, classID, subclassID, bindType = C_Item.GetItemInfo(itemLink)
            itemLevel= C_Item.GetDetailedItemLevelInfo(itemLink) or itemLevel
            local other= classID==15 and subclassID==0
            if itemEquipLoc--绑定
            and itemQuality and itemQuality==4--最高史诗
            and (classID==2 or classID==3 or classID==4 or other)--2武器 3宝石 4盔甲
            and bindType == LE_ITEM_BIND_ON_ACQUIRE--1     LE_ITEM_BIND_ON_ACQUIRE    拾取绑定
            and itemLevel and itemLevel>1 and avgItemLevel-itemLevel>=15
            and not Save.noSell[itemID]
            then
                if other then
                    local dateInfo= e.GetTooltipData({hyperLink=itemLink, red=true, onlyRed=true})--物品提示，信息
                    if not dateInfo.red then
                        return
                    end
                end
                bossSave[itemID]= itemLevel
                if not Save.notSellBoss then
                    print(id, Initializer:GetName(), '|cnGREEN_FONT_COLOR:'.. (e.onlyChinese and '出售' or AUCTION_HOUSE_SELL_TAB) , itemLink)
                end
            end
        end
    end
end)
