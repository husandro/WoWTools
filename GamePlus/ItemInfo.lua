local id, e = ...
local addName= e.onlyChinse and '物品信息' or ITEMS..INFO
local Save={}
local panel=CreateFrame("Frame")

local itemUseString =ITEM_SPELL_CHARGES:gsub('%%d', '%(%%d%+%)')--(%d+)次
local KeyStone=CHALLENGE_MODE_KEYSTONE_NAME:gsub('%%s','(.+) ')--钥石
local text_EQUIPMENT_SETS= 	EQUIPMENT_SETS:gsub('%%s','(.+)')
local size= 10--字体大小

local function set_Item_Info(self, itemLink, itemID, bag, merchantIndex, guildBank, buyBack)
    local topLeftText, bottomRightText, leftText, bottomLeftText, topRightText, r, g ,b, setIDItem, isWoWItem--setIDItem套装
    if itemLink then
        local _, _, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, _, _, classID, subclassID, bindType, expacID, setID, isCraftingReagent = GetItemInfo(itemLink)

        setIDItem= setID and true or nil--套装
        itemLevel=GetDetailedItemLevelInfo(itemLink) or itemLevel

        if itemQuality then
            r,g,b = GetItemQualityColor(itemQuality)
        end

        if bag and bag.hasLoot then--宝箱
            local noUse= e.GetTooltipData(true, nil, itemLink, bag and {bag=bag.bagID, slot=bag.slotID}, guildBank and {tab= guildBank[1], slot=guildBank[2]}, merchantIndex, buyBack)--物品提示，信息
            topRightText= noUse and '|A:Monuments-Lock:0:0|a' or '|A:talents-button-undo:0:0|a'

        elseif C_Item.IsItemKeystoneByID(itemID) then--挑战
            local name=itemLink:match('%[(.-)]') or itemLink
            if name then
                topLeftText=name:match('%((%d+)%)') or C_MythicPlus.GetOwnedKeystoneLevel() --等级
                name=name:gsub('%((%d+)%)','')
                name=name:match('（(.-)）') or name:match('%((.-)%)') or name:match('%- (.+)') or name:match(KeyStone)--名称
                if name then
                    bottomLeftText=e.WA_Utf8Sub(name, 2,5)
                end
                local activities=C_WeeklyRewards.GetActivities(1)--本周完成
                if activities then
                    local t=0
                    for _,v in pairs(activities) do
                        if v and v.level then
                            if v.level >t then t=v.level end
                        end
                    end
                    if t>0 then
                        leftText='|cnGREEN_FONT_COLOR:'..t..'|r'
                    end
                end
            end
        elseif e.itemPetID[itemID] then
            topRightText='|A:WildBattlePetCapturable:0:0|a'

        elseif itemQuality and itemQuality==0 then
            topRightText='|A:Coin-Silver:0:0|a'

        elseif classID==1 then--背包
            bottomLeftText= e.WA_Utf8Sub(itemSubType, 2,5)
            if bag and not bag.isBound then--没有锁定
                topRightText='|A:'..e.Icon.unlocked..':0:0|a'
            end

        elseif isCraftingReagent or classID==8 or classID==3 or classID==9 or (classID==0 and (subclassID==1 or subclassID==3 or subclassID==5)) or classID==19 or classID==7 then--附魔, 宝石,19专业装备 ,7商业技能
            local noUse,findText, wow= e.GetTooltipData(true, ITEM_SPELL_KNOWN , itemLink, bag and {bag=bag.bagID, slot=bag.slotID}, guildBank and {tab= guildBank[1], slot=guildBank[2]}, merchantIndex, buyBack)--物品提示，信息
            if not (classID==15 and (subclassID== 0 or subclassID==4)) then
                if classID==0 and subclassID==5 then
                    topRightText= e.WA_Utf8Sub(POWER_TYPE_FOOD, 2,5)--食物
                else
                    topRightText= e.WA_Utf8Sub(itemSubType, 2,5)
                end
                if expacID and expacID< e.ExpansionLevel and itemID~='5512' and itemID~='113509' then--低版本，5512糖 食物,113509[魔法汉堡]
                    topRightText= '|cff606060'..topRightText..'|r'
                end
            end
            if findText then
                bottomRightText= e.Icon.X2
            elseif noUse then
                bottomRightText= e.Icon.O2
            elseif wow then
                bottomRightText= e.Icon.wow2
            end
        elseif classID==2 and subclassID==20 then-- 鱼竿
                topRightText='|A:worldquest-icon-fishing:0:0|a'

        elseif classID==2 or classID==4 then--装备
            if itemQuality and itemQuality>1 then
                local noUse, text, wow= e.GetTooltipData(true, text_EQUIPMENT_SETS, itemLink, bag and {bag=bag.bagID, slot=bag.slotID}, guildBank and {tab= guildBank[1], slot=guildBank[2]}, merchantIndex, buyBack)--物品提示，信息
                if text then--套装名称，
                    text= text:match('(.+),') or text:match('(.+)，') or text
                    bottomLeftText=e.WA_Utf8Sub(text,3,5)
                elseif itemMinLevel>e.Player.level then--低装等
                    bottomLeftText='|cnRED_FONT_COLOR:'..itemMinLevel..'|r'
                elseif wow then--战网
                    bottomLeftText= e.Icon.wow2
                end

                local invSlot = e.itemSlotTable[itemEquipLoc]
                if invSlot and itemLevel and itemLevel>1 then
                    if not noUse then--装等
                        local itemLinkPlayer =  GetInventoryItemLink('player', invSlot)
                        local upLevel, downLevel
                        if itemLinkPlayer then
                            local lv=GetDetailedItemLevelInfo(itemLinkPlayer)
                            if lv then
                                if itemLevel-lv>0 then
                                    upLevel=true
                                elseif itemLevel-lv< 0 and itemLevel>29 then
                                    downLevel=true
                                end
                            end
                        else
                            upLevel=true
                        end
                        if upLevel and (itemMinLevel and itemMinLevel<=e.Player.level or not itemMinLevel) then
                            topLeftText=e.Icon.up2
                        elseif downLevel then
                            topLeftText= e.Icon.down2
                        end
                        if itemQuality>2 or (not e.Player.levelMax and itemQuality==2) or upLevel then
                            topLeftText=itemLevel ..(topLeftText or '')
                        end
                    elseif itemMinLevel and itemMinLevel<=e.Player.level then--不可使用
                        topLeftText=e.Icon.X2
                    end
                end

                if bag and not bag.isBound or not bag then
                    bottomRightText = e.GetItemCollected(itemLink, nil, true)--幻化
                end
                if itemQuality and itemQuality>1 and bag and not bag.isBound then--没有锁定
                    topRightText=itemSubType and e.WA_Utf8Sub(itemSubType,3,5) or '|A:'..e.Icon.unlocked..':0:0|a'
                end
            end

        elseif classID==17 or (classID==15 and subclassID==2) or itemLink:find('Hbattlepet:(%d+)') then--宠物
            local speciesID = itemLink:match('Hbattlepet:(%d+)') or select(13, C_PetJournal.GetPetInfoByItemID(itemID))--宠物
            if speciesID then
                topLeftText= e.GetPetCollected(speciesID, nil, true) or topLeftText--宠物, 收集数量
                local petType= select(3, C_PetJournal.GetPetInfoBySpeciesID(speciesID))
                if petType then
                    topRightText='|TInterface\\TargetingFrame\\PetBadge-'..PET_TYPE_SUFFIX[petType]..':0|t'
                end
            end

        elseif classID==15 and subclassID==5 then--坐骑
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            if mountID then
                bottomRightText= select(11, C_MountJournal.GetMountInfoByID(mountID)) and e.Icon.X2 or e.Icon.star2
            end


        elseif classID==12 and itemQuality and itemQuality>0 then--任务
            topRightText= e.onlyChinse and '任务' or e.WA_Utf8Sub(itemSubType, 2,5)

        elseif itemQuality==7 or itemQuality==8 then
            topRightText=e.Icon.wow2

        elseif C_ToyBox.GetToyInfo(itemID) then--玩具
            bottomRightText= PlayerHasToy(itemID) and e.Icon.X2 or e.Icon.star2

        elseif itemStackCount==1 then
            local noUse, text, wow= e.GetTooltipData(true, itemUseString, itemLink, bag and {bag=bag.bagID, slot=bag.slotID}, guildBank and {tab= guildBank[1], slot=guildBank[2]}, merchantIndex, buyBack)--物品提示，信息
            bottomLeftText=text
            topRightText= wow and e.Icon.wow2 or noUse and e.Icon.X2
        end

        local num=GetItemCount(itemLink, true)-GetItemCount(itemLink)--银行数量
        if num>0 then
            leftText= '+'..e.MK(num, 0)
        end
    end

    if topRightText and not self.topRightText then
        self.topRightText=e.Cstr(self, size, nil, nil, nil, 'OVERLAY')
        self.topRightText:SetPoint('TOPRIGHT',2,0)
    end
    if self.topRightText then
        self.topRightText:SetText(topRightText or '')
        if r and g and b and topRightText then
            self.topRightText:SetTextColor(r,g,b)
        end
    end
    if topLeftText and not self.topLeftText then
        self.topLeftText=e.Cstr(self, size, nil, nil, nil, 'OVERLAY')
        self.topLeftText:SetPoint('TOPLEFT')
    end
    if self.topLeftText then
        self.topLeftText:SetText(topLeftText or '')
        if r and g and b and topLeftText then
            self.topLeftText:SetTextColor(r,g,b)
        end
    end
    if bottomRightText then
        if not self.bottomRightText then
            self.bottomRightText=e.Cstr(self, size, nil, nil, nil, 'OVERLAY')
            self.bottomRightText:SetPoint('BOTTOMRIGHT')
        end
    end
    if self.bottomRightText then
        self.bottomRightText:SetText(bottomRightText or '')
        if r and g and b and bottomRightText then
            self.bottomRightText:SetTextColor(r,g,b)
        end
    end

    if leftText and not self.leftText then
        self.leftText=e.Cstr(self, size, nil, nil, nil, 'OVERLAY')
        self.leftText:SetPoint('LEFT')
    end
    if self.leftText then
        self.leftText:SetText(leftText or '')
        if r and g and b and leftText then
            self.leftText:SetTextColor(r,g,b)
        end
    end
    if bottomLeftText and not self.bottomLeftText then
        self.bottomLeftText=e.Cstr(self, size)
        self.bottomLeftText:SetPoint('BOTTOMLEFT')
    end
    if self.bottomLeftText then
        self.bottomLeftText:SetText(bottomLeftText or '')
        if r and g and b and bottomLeftText then
            self.bottomLeftText:SetTextColor(r,g,b)
        end
    end

    if setIDItem and not self.setIDItem then
        self.setIDItem=self:CreateTexture()
        self.setIDItem:SetAllPoints(self)
        self.setIDItem:SetAtlas(e.Icon.pushed)
    end
    if self.setIDItem then
        self.setIDItem:SetShown(setIDItem)
    end
end

local function setBags(self)--背包设置
    for i, itemButton in self:EnumerateValidItems() do
        local itemLink, itemID, isBound--, equipmentName
        local slotID, bagID= itemButton:GetSlotAndBagID()--:GetID() GetBagID()
        local info
        if itemButton.hasItem then
            info=C_Container.GetContainerItemInfo(bagID, slotID)
            if info and info.hyperlink and info.itemID then
                itemLink= info.hyperlink
                itemID= info.itemID

                info.bagID=bagID
                info.slotID=slotID
            end
        end

        set_Item_Info(itemButton, itemLink, itemID, info)
    end
end


local function setMerchantInfo()--商人设置
    local selectedTab= MerchantFrame.selectedTab
    local page= selectedTab == 1 and MERCHANT_ITEMS_PER_PAGE or BUYBACK_ITEMS_PER_PAGE

    for i=1, page do
        local index = selectedTab==1 and (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i) or i
        local itemButton= _G["MerchantItem"..i..'ItemButton']
        if itemButton then
            local itemLink,itemID

            if itemButton:IsShown() then
                if selectedTab==1 then
                    itemLink= GetMerchantItemLink(index)
                    itemID= GetMerchantItemID(index)
                else
                    itemLink= GetBuybackItemInfo(index)
                    itemID= C_MerchantFrame.GetBuybackItemID(index)
                end

            end
            set_Item_Info(itemButton, itemLink, itemID, nil, selectedTab == 1 and index, nil, selectedTab ~= 1 and index)
        end
    end
end


local MAX_GUILDBANK_SLOTS_PER_TAB = 98;
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14;
local function setGuildBank()--公会银行,设置
    if GuildBankFrame and GuildBankFrame:IsVisible() then
        local tab = GetCurrentGuildBankTab() or 1;--Blizzard_GuildBankUI.lua
        for i=1, MAX_GUILDBANK_SLOTS_PER_TAB do
            local index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP);
            if ( index == 0 ) then
                index = NUM_SLOTS_PER_GUILDBANK_GROUP;
            end
            local column = ceil((i-0.5)/NUM_SLOTS_PER_GUILDBANK_GROUP);
            local button = (GuildBankFrame.Columns[column] and GuildBankFrame.Columns[column].Buttons) and GuildBankFrame.Columns[column].Buttons[index];
            if button then
                local itemLink= GetGuildBankItemLink(tab, i)
                local itemID= itemLink and GetItemInfoInstant(itemLink)
                set_Item_Info(button, itemLink, itemID, nil, nil, {tab, i})
            end
        end
    end
end

local function set_BankFrameItemButton_Update(button)--银行, BankFrame.lua
    local container = button:GetParent():GetID();
    if not button.isBag then
        local buttonID = button:GetID();
        local itemInfo = C_Container.GetContainerItemInfo(container, buttonID) or {};
        local info={
            bagID=container,
            slotID=buttonID,
        }
        set_Item_Info(button, itemInfo.hyperlink, itemInfo.itemID, info)
    end
end
--####
--初始
--####
local function Init()
--[[    if Bagnon then
        local item = Bagnon.ItemSlot  or Bagnon.Item
        if (item) and (item.Update)  then
            hooksecurefunc(item, 'Update', Update)
        end
    elseif Baggins then
        hooksecurefunc(Baggins, 'UpdateItemButton',
            function (self, bag, button, bagID, slotID)
                Update(button,bagID, slotID)
        end)

    elseif Combuctor then
        local item = Combuctor.ItemSlot or Combuctor.Item
        if (item) and (item.Update)  then
            hooksecurefunc(item, 'Update', Update)
        end
    els]]
  --[[
  if IsAddOnLoaded('Inventorian') then
        C_Timer.After(3, function()
            local frame=InventorianBagFrame
            if frame then
                
            end
        end)
    else

]]

    hooksecurefunc(ContainerFrameCombinedBags,'Update', function(self)
        setBags(self)
    end)
    ContainerFrameCombinedBags.SetBagInfo=true
    hooksecurefunc('ContainerFrame_GenerateFrame',function (self, size, id2)
        for _, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
            if not frame.SetBagInfo then
                setBags(frame)
                hooksecurefunc(frame, 'UpdateItems', setBags)
                frame.SetBagInfo=true
            end
        end
    end)

    hooksecurefunc('MerchantFrame_UpdateMerchantInfo',setMerchantInfo)--MerchantFrame.lua
    hooksecurefunc('MerchantFrame_UpdateBuybackInfo', setMerchantInfo)
    hooksecurefunc('BankFrameItemButton_Update',set_BankFrameItemButton_Update)--银行

    --############
    --排序:从右到左
    --############
    local function set_Sort_Rigth_To_Left()
        C_Container.SetSortBagsRightToLeft(Save.sortRightToLeft)
    end
    ContainerFrameCombinedBagsPortraitButton:HookScript('OnMouseDown',function ()
        UIDropDownMenu_AddSeparator()

        local info={--排序:从右到左
            text= e.onlyChinse and '排序: 从右到左' or CLUB_FINDER_SORT_BY..': '..	INT_SPELL_POINTS_SPREAD_TEMPLATE:format(HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_RIGHT,HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_LEFT),
            checked= C_Container.GetSortBagsRightToLeft(),
            tooltipOnButton=true,
            tooltipTitle=id,
            tooltipText=addName,
            func= function()
                Save.sortRightToLeft= not C_Container.GetSortBagsRightToLeft() and true or false
                set_Sort_Rigth_To_Left()--排序:从右到左
            end,
        }
        UIDropDownMenu_AddButton(info, 1)
    end)
    if Save.sortRightToLeft~=nil then
        set_Sort_Rigth_To_Left()--排序:从右到左
    end
    --###############
    --收起，背包小按钮
    --###############
    if C_CVar.GetCVarBool("expandBagBar") and C_CVar.GetCVarBool("combinedBags") then--MainMenuBarBagButtons.lua
        C_CVar.SetCVar("expandBagBar", '0')
    end
end

--###########
--加载保存数据
--###########
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED");
panel:RegisterEvent("GUILDBANK_ITEM_LOCK_CHANGED");
panel:RegisterEvent('BANKFRAME_OPENED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save

            --添加控制面板        
            local sel=e.CPanel(addName, not Save.disabled, true)
            sel:SetScript('OnClick', function()
                if Save.disabled then
                    Save.disabled=nil
                else
                    Save.disabled=true
                end
                print(id, addName, e.GetEnabeleDisable(not Save.disabled), e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)

            sel:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(BAGSLOT..' '..MERCHANT, EMBLEM_SYMBOL..INFO)
                e.tips:Show()
            end)
            sel:SetScript('OnLeave', function() e.tips:Hide() end)

            if Save.disabled then
                panel:UnregisterAllEvents()
            else
                Init()
            end
            panel:RegisterEvent("PLAYER_LOGOUT")

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end

    elseif event == "GUILDBANKBAGSLOTS_CHANGED" or event =="GUILDBANK_ITEM_LOCK_CHANGED" then
        setGuildBank()--公会银行,设置

    elseif event=='BANKFRAME_OPENED' then--打开所有银行，背包
        for i=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
            ToggleBag(i);
        end
    end
end)

--[[
if MainMenuBarBackpackButton then--背包，数量
        hooksecurefunc(MainMenuBarBackpackButton, 'UpdateFreeSlots', function(self)
            local totalFree=0
            for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
                local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i);
                print(bagFamily, i)
                if ( bagFamily == 0 ) then
                    totalFree = totalFree + freeSlots;
                end
            end
            self.Count:SetText(totalFree)
        end)
    end
]]