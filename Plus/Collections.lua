local id, e = ...
local addName= COLLECTIONS
local Save={

    --hideSets= true,--套装, 幻化, 界面
    --hideHeirloom= true,--传家宝
    --hideItems= true,--物品, 幻化, 界面
    --hideToyBox= true,--玩具

    --Heirlooms_Class_Scale=1,
    --Wardrober_Items_Labels_Scale=1,
}


local SetsDataProvider
local function Init_SetsDataProvider()
    if not SetsDataProvider and WardrobeSetsDataProviderMixin then
        SetsDataProvider= CreateFromMixins(WardrobeSetsDataProviderMixin)
    end
end

local SlotsIcon = {
    "|A:transmog-nav-slot-head:0:0|a",--1
    "|A:transmog-nav-slot-shoulder:0:0|a",--2
    "|A:transmog-nav-slot-back:0:0|a",--3
    "|A:transmog-nav-slot-chest:0:0|a",--4
    "|A:transmog-nav-slot-shirt:0:0|a",--5
    "|A:transmog-nav-slot-tabard:0:0|a",--6
    "|A:transmog-nav-slot-wrist:0:0|a",--7
    "|A:transmog-nav-slot-hands:0:0|a",--8
    "|A:transmog-nav-slot-waist:0:0|a",--9
    "|A:transmog-nav-slot-legs:0:0|a",--10
    "|A:transmog-nav-slot-feet:0:0|a",--11
    "|T135139:0|t",--12魔杖
    '|T132392:0|t',--13单手斧
    '|A:transmog-nav-slot-mainhand:0:0|a',--14单手剑
    '|T133476:0|t',--15单手锤
    '|T132324:0|t',--16匕首
    '|T132965:0|t',--17拳套
    '|A:transmog-nav-slot-secondaryhand:0:0|a',--18副手
    '|T652302:0|t',--19副手物品    
    '|T132400:0|t',--20双手斧
    '|T135327:0|t',--21双手剑
    '|T133044:0|t',--22双手锤
    '|T135145:0|t',--23法杖
    '|T135129:0|t',--24长柄武器
    '|T135490:0|t',--25弓
    '|T135610:0|t',--26枪械
    '|T135530:0|t',--27弩
    '|A:transmog-nav-slot-enchant:0:0|a',--28 e.onlyChinese and '武器附魔' or WEAPON_ENCHANTMENT,
    '|A:ElementalStorm-Lesser-Earth:0:0|a',--29'军团再临"神器
}



--保存，套装，数据
--wowSaveSets= {[1]={class=str,numCollected=number, numTotal=number}


--info=  C_TransmogSets
--for k, v in pairs(info) do if v and type(v)=='table' then print('|cff00ff00---',k, '---STAR') for k2,v2 in pairs(v) do print(k2,v2) end print('|cffff0000---',k, '---END') else print(k,v) end end print('|cffff00ff——————————')


local function GetSetsCollectedNum(setID)--套装 , 收集数量, 返回: 图标, 数量, 最大数, 文本
    local info= setID and C_TransmogSets.GetSetPrimaryAppearances(setID) or {}
    local numCollected, numAll=0,0
    for _,v in pairs(info) do
        numAll=numAll+1
        if v.collected then
            numCollected=numCollected + 1
        end
    end
    if numAll>0 then
        if numCollected==numAll then
            return '|A:AlliedRace-UnlockingFrame-Checkmark:12:12|a', numCollected, numAll--, '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r'
        elseif numCollected==0 then
            return '|cff9e9e9e'..numAll-numCollected..'|r ', numCollected, numAll,  '|cff9e9e9e'..numCollected..'|r/'..numAll--, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        else
            return numAll-numCollected, numCollected, numAll, '|cffffffff'..numCollected..'|r/'..numAll--, '|cnYELLOW_FONT_COLOR:'..numCollected..'/'..numAll..' '..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
        end
    end
end































--套装物品 Link
local function Init_Wardrobe_DetailsFrame(_, itemFrame)
    if Save.hideSets then
        if itemFrame.indexbtn then
            for i = 1, itemFrame.indexbtn do
                local btn=itemFrame['btn'..i]
                if btn then
                    btn:SetShown(false)
                end
            end
            itemFrame.indexbtn=nil
        end
        return
    end
    local sourceInfo = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID)
    local slot = C_Transmog.GetSlotForInventoryType(sourceInfo.invType)
    local sources = C_TransmogSets.GetSourcesForSlot(itemFrame:GetParent():GetParent():GetSelectedSetID(), slot)
    if ( #sources == 0 ) then
        tinsert(sources, sourceInfo)
    end
    CollectionWardrobeUtil.SortSources(sources, sourceInfo.visualID, itemFrame.sourceID)
    local numItems=#sources
    for i=1, numItems do
        local index = CollectionWardrobeUtil.GetValidIndexForNumSources(i, numItems)
        local link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sources[index].sourceID))
        local btn=itemFrame['btn'..i]
        if not btn then
            btn=e.Cbtn(itemFrame, {icon=true, size={26,10}})
            btn:SetNormalAtlas('adventure-missionend-line')
            itemFrame['btn'..i]=btn
            if i==1 then
                btn:SetPoint('BOTTOM', itemFrame, 'TOP', 0 ,1)
            else
                btn:SetPoint('TOP', itemFrame, 'BOTTOM', 0 , -(i-2)*10)
            end
            btn:SetAlpha(0.2)
            btn:SetScript("OnEnter",function(self2)
                    if not self2.link then
                         return
                    end
                    self2:SetAlpha(1)
                    e.tips:ClearLines()
                    e.tips:SetOwner(self2, "ANCHOR_RIGHT")
                    e.tips:SetHyperlink(self2.link)
                    e.tips:Show()
            end)
            btn:SetScript("OnMouseDown", function(self2)
                e.Chat(self2.link, nil, true)
                --local chat=SELECTED_DOCK_FRAME
                --ChatFrame_OpenChat((chat.editBox:GetText() or '')..self2.link, chat)

            end)
            btn:SetScript("OnLeave",function(self2)
                    self2:SetAlpha(0.2)
                    e.tips:Hide()
            end)
        end
        btn.link=link
        btn:SetShown(true)
    end
    if itemFrame.indexbtn and itemFrame.indexbtn > numItems then
        for i = numItems+1, itemFrame.indexbtn do
            local btn=itemFrame['btn'..i]
            if btn then
                btn:SetShown(false)
            end
        end
    end
    itemFrame.indexbtn=numItems
end




































--幻化，套装，索引 WardrobeCollectionFrame.SetsTransmogFrame
local function set_Sets_Tooltips(self)--UpdateSets
    local idexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE
    for i= 1, self.PAGE_SIZE do
        local model = self.Models[i]
        if model and model:IsShown() then
            local idex--索引
            if not Save.hideItems then
                idex= i + idexOffset
                if not model.Text then
                    model.Text= e.Cstr(model)
                    model.Text:SetPoint('TOPRIGHT',1,0)
                    model.Text:SetAlpha(0.5)
                end
            end
            if model.Text then
                model.Text:SetText(idex or '')
            end
        end
    end
end




















--物品
local function Init_Wardrober_Items()--物品, 幻化, 界面
    --部位，已收集， 提示
    hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame, 'UpdateSlotButtons', function(self)
        for _, btn in pairs(self.SlotsFrame.Buttons) do
            local collected= 0
            local category
            if not Save.hideItems then
                local transmogLocation= btn.transmogLocation
                local slotID= transmogLocation:GetSlotID()
                if ( transmogLocation:IsIllusion() ) then--武器，附魔
                    if slotID~=17 then
                        for _, illusion in ipairs(C_TransmogCollection.GetIllusions() or {}) do
                            if ( illusion.isCollected ) then
                                collected = collected + 1
                            end
                        end
                    end
                elseif slotID==16 or slotID==17 then--武器, 副手
                    local tab= slotID==16 and {12, 13, 14, 15, 16, 17, 20, 21, 22, 23, 24, 25, 26, 27, 29} or {18, 19}
                    for _, category2 in pairs(tab) do
                        collected= collected+ (C_TransmogCollection.GetCategoryCollectedCount(category2) or 0)
                    end
                elseif ( transmogLocation:IsAppearance() ) then
                    local useLastWeaponCategory = self.transmogLocation:IsEitherHand() and
                                                    self.lastWeaponCategory and
                                                    self:IsValidWeaponCategoryForSlot(self.lastWeaponCategory);
                    if ( useLastWeaponCategory ) then
                        category = self.lastWeaponCategory;
                    else
                        local appliedSourceID, appliedVisualID, selectedSourceID, selectedVisualID = self:GetActiveSlotInfo();
                        if ( selectedSourceID ~= Constants.Transmog.NoTransmogID ) then
                            category = C_TransmogCollection.GetAppearanceSourceInfo(selectedSourceID);
                            if category and not self:IsValidWeaponCategoryForSlot(category) then
                                category = nil;
                            end
                        end
                    end
                    if ( not category ) then
                        if ( transmogLocation:IsEitherHand() ) then
                            -- find the first valid weapon category
                            for categoryID = FIRST_TRANSMOG_COLLECTION_WEAPON_TYPE, LAST_TRANSMOG_COLLECTION_WEAPON_TYPE do
                                if ( self:IsValidWeaponCategoryForSlot(categoryID) ) then
                                    category = categoryID;
                                    break;
                                end
                            end
                        else
                            category = transmogLocation:GetArmorCategoryID();
                        end
                    end
                    if category then
                        collected= C_TransmogCollection.GetCategoryCollectedCount(category) or 0
                    end
                end
            end
            if collected>0 and not btn.Text then
                btn.Text= e.Cstr(btn, {justifyH='CENTER', mouse=true})
                btn.Text:SetPoint('BOTTOMRIGHT')
                btn.Text.category= category
            end
            if btn.Text then
                btn.Text:SetText(collected>0 and e.MK(collected, 3) or '')
            end
        end
    end)

    for _, btn in pairs(WardrobeCollectionFrame.ItemsCollectionFrame.SlotsFrame.Buttons) do
        btn:HookScript('OnEnter', function(self)
            if Save.hideItems then
                return
            end
            local slotID= self.transmogLocation:GetSlotID()
            e.tips:AddLine('slotID '..slotID..' '..self.slot)
            if self.transmogLocation:IsIllusion() then--武器，附魔            
                local collected, all= 0, 0
                for _, illusion in ipairs(C_TransmogCollection.GetIllusions() or {}) do
                    if ( illusion.isCollected ) then
                        collected = collected + 1
                    end
                    all= all+ 1
                end
                if all>0 then
                    e.tips:AddLine(
                        (collected==all and '|cnGREEN_FONT_COLOR:' or '')
                        ..format('|A:transmog-nav-slot-enchant:0:0|a%i%%  %d/%d', collected/all*100, collected, all)
                    )
                end

            elseif slotID==16 or slotID==17 then--武器, 副手
                local tab= slotID==16 and {12, 13, 14, 15, 16, 17, 20, 21, 22, 23, 24, 25, 26, 27, 29} or {18, 19}
                local n=1
                for _, category in pairs(tab) do
                local collected= C_TransmogCollection.GetCategoryCollectedCount(category) or 0
                    local all= C_TransmogCollection.GetCategoryTotal(category) or 0
                    if all>0 then
                        local col= collected==all and '|cnGREEN_FONT_COLOR:' or (select(2, math.modf(n/2))==0 and '|cffff7f00' or '|cffffffff')
                        local icon= SlotsIcon[category] or ''
                        local name= e.cn(C_TransmogCollection.GetCategoryInfo(category)) or ''
                        e.tips:AddLine(format('%s%s%s %i%%  %s/%s', col, icon, name, collected/all*100, e.MK(collected, 3), e.MK(all, 3)))
                        n=n+1
                    end
                end
            elseif self.Text and self.Text.category then
                e.tips:AddLine('category '..self.Text.category)
                local collected= C_TransmogCollection.GetCategoryCollectedCount(self.Text.category) or 0
                local all= C_TransmogCollection.GetCategoryTotal(self.Text.category) or 0
                local icon= SlotsIcon[self.Text.category] or ''
                e.tips:AddLine(format('%s%i%%  %s/%s', icon, collected/all*100, e.MK(collected, 3), e.MK(all, 3)))
            end
            e.tips:Show()
        end)
    end
end


























--外观，物品，提示，索引 WardrobeCollectionFrame.ItemsCollectionFrame
local function get_Link_Item_Type_Source(sourceID, type)
    if sourceID then
        if type=='item' then
            return WardrobeCollectionFrame:GetAppearanceItemHyperlink(sourceID)
        else
            return select(2, C_TransmogCollection.GetIllusionStrings(sourceID))
        end
    end
end
local function set_Items_Tooltips(self)--UpdateItems    
    local idexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE
    for i= 1, self.PAGE_SIZE do
        local model = self.Models[i]
        if model and model:IsShown() then
            model.itemButton=model.itemButton or {}
            local itemLinks={}
            if not Save.hideItems and self.transmogLocation then
                local findLinks={}
                if self.transmogLocation:IsIllusion() then--WardrobeItemsModelMixin:OnMouseDown(button)
                    local link= get_Link_Item_Type_Source(model.visualInfo.sourceID, 'illusion')--select(2, C_TransmogCollection.GetIllusionStrings(model.visualInfo.sourceID))
                    if link then
                        e.LoadDate({id=link, type='item'})--加载 item quest spell
                        table.insert(itemLinks, {link= link, sourceID= model.visualInfo.sourceID, type='illusion'})
                    end
                else
                    local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(model.visualInfo.visualID, self:GetActiveCategory(), self.transmogLocation) or {}
                    for index= 1, #sources do
                        local link= get_Link_Item_Type_Source(sources[index],'item')--WardrobeCollectionFrame:GetAppearanceItemHyperlink(sources[index])
                        if link and not findLinks[link] then
                            e.LoadDate({id=link, type='item'})--加载 item quest spell
                            table.insert(itemLinks, {link=link, sourceID=sources[index], type='item'})
                            findLinks[link]=true
                        end
                    end
                end
                findLinks=nil

                local y, x, h =0,0, 11
                for index, tab in pairs(itemLinks) do
                    local btn= model.itemButton[index]
                    if not btn then
                        btn=e.Cbtn(model, {icon='hide', size=index==1 and {14.4, 14.4} or {h,h}})
                        if index==1 then
                            btn:SetPoint('BOTTOMLEFT', -4, -4)
                        else
                            btn:SetPoint('BOTTOMLEFT', x, y)
                        end
                        btn:SetAlpha(0.5)

                        btn:SetScript("OnEnter",function(self2)
                            local link2= get_Link_Item_Type_Source(self2.sourceID, self2.type) or self2.link
                            if link2 then
                                self2:SetAlpha(1)
                                e.tips:ClearLines()
                                e.tips:SetOwner(self2:GetParent():GetParent(), "ANCHOR_RIGHT",8,-300)
                                if self2.illusionID then
                                    local name, _, sourceText = C_TransmogCollection.GetIllusionStrings(self2.illusionID)
                                    e.tips:AddLine(name)
                                    e.tips:AddLine(' ')
                                    e.tips:AddLine(sourceText, 1,1,1, true)
                                    e.tips:AddLine(' ')
                                    local info = C_TransmogCollection.GetIllusionInfo(self2.illusionID)
                                    if info then
                                        e.tips:AddDoubleLine('visualID '..(info.visualID or ''), 'sourceID '..(info.sourceID or ''))
                                        e.tips:AddDoubleLine(info.icon and '|T'..info.icon..':0|t'..info.icon or '', 'isHideVisual '..(info.isHideVisual and 'true' or 'false'))
                                        e.tips:AddDoubleLine(info.isCollected and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '已收集' or COLLECTED)..'|r' or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'),
                                                            info.isUsable and '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '可用' or AVAILABLE)..'|r' or ('|cnRED_FONT_COLOR:'..(e.onlyChinese and '不可用' or UNAVAILABLE)..'|r'))
                                        e.tips:AddLine(' '
                                    )
                                    end
                                else
                                    e.tips:SetHyperlink(link2)
                                end
                                e.tips:AddLine(' ')
                                e.tips:AddDoubleLine(e.onlyChinese and '发送' or SEND_LABEL, e.Icon.left)
                                e.tips:Show()
                               e.tips:AddDoubleLine(id, e.cn(addName))
                             end
                             self2:SetAlpha(1)
                        end)
                        btn:SetScript("OnClick", function(self2)
                            local link2= get_Link_Item_Type_Source(self2.sourceID, self2.type) or self2.link
                            e.Chat(link2, nil, true)
                        end)
                        btn:SetScript("OnLeave",function(self2)
                            self2:SetAlpha(0.5)
                            e.tips:Hide()
                        end)
                        model.itemButton[index]=btn
                    end
                    if index~=1 and select(2, math.modf(index / 10))==0 then
                        x= x+ h
                        y=0
                    else
                        y=y+ h
                    end
                    local illusionID= tab.link:match('Htransmogillusion:(%d+)') or tab.type=='illusion'
                    if index==1 then
                        local icon
                        if illusionID and illusionID~=true then
                            local info = C_TransmogCollection.GetIllusionInfo(illusionID)
                            icon= info and info.icon
                        end
                        icon= icon or C_Item.GetItemIconByID(tab.link)
                        if icon then
                            btn:SetNormalTexture(icon)
                        else
                            btn:SetNormalAtlas('adventure-missionend-line')
                        end
                    elseif index<=10 then
                        btn:SetNormalAtlas('services-number-'..(index-1))
                    else
                        btn:SetNormalAtlas('adventure-missionend-line')
                    end
                    btn.link=tab.link
                    btn.sourceID= tab.sourceID
                    btn.type= tab.type
                    btn.illusionID= illusionID
                    btn.index=index
                    btn:SetShown(true)
                end
            end
            for index= #itemLinks+1, #model.itemButton do
                model.itemButton[index]:SetShown(false)
            end

            local idex--索引
            if not Save.hideItems then
                idex= i + idexOffset
                if not model.Text then
                    model.Text= e.Cstr(model)
                    model.Text:SetPoint('TOPRIGHT', 3, 2)
                    model.Text:SetAlpha(0.5)
                end
            end
            if model.Text then
                model.Text:SetText(idex or '')
            end
        end
    end
end




























--套装，列表
local function Init_Wardrober_ListContainer()
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'Init', function(btn, displayData)
        local setID= displayData.setID or btn.setID
        if Save.hideSets or not setID then
            if btn.set_Rest then btn:set_Rest() end
            return
        end


        if not btn.set_Rest then
            btn:SetScript("OnEnter",function(self)
                if not Save.hideSets then
                    e.tips:SetOwner(self.Icon or self, "ANCHOR_LEFT")--,8,-300)
                    e.tips:ClearLines()
                    --e.tips:AddDoubleLine('setID', self.setID)
                    e.tips:AddLine(self.tooltip)
                    e.tips:Show()
                end
            end)
            btn:SetScript("OnLeave",function()
                e.tips:Hide()
            end)

            btn.version=e.Cstr(btn)--版本
            btn.version:SetPoint('BOTTOMRIGHT',-5, 5)

            btn.limited=btn:CreateTexture(nil, 'OVERLAY')--限时
            btn.limited:SetSize(12, 12)
            btn.limited:SetAtlas('socialqueuing-icon-clock')
            btn.limited:SetPoint('TOPRIGHT', btn.Icon)
            btn.limited:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.limited:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '限时套装' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, TRANSMOG_SET_LIMITED_TIME_SET, WARDROBE_SETS))
                e.tips:Show()
                self:SetAlpha(0.3)
            end)

            btn.numSetsLabel=e.Cstr(btn, {size=16, mouse=true})
            btn.numSetsLabel:SetPoint('BOTTOMLEFT', btn.Icon)
            btn.numSetsLabel:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
            btn.numSetsLabel:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '套装数量' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WARDROBE_SETS, AUCTION_HOUSE_QUANTITY_LABEL))
                e.tips:Show()
                self:SetAlpha(0.3)
            end)

            function btn:set_Rest()
                self.limited:SetShown(false)
                self.numSetsLabel:SetText('')
                self.tooltip=nil
            end
        end


        local tipsText= e.cn(displayData.name or btn.Name:GetText() or '')..(displayData.label and displayData.name~= displayData.label and '|n'..e.cn(displayData.label) or '')
        tipsText= tipsText and tipsText..'|n' or ''

        local variantSets = SetsDataProvider:GetVariantSets(setID) or {}
        if #variantSets==0 then
            table.insert(variantSets, C_TransmogSets.GetSetInfo(setID))
        end
        SetsDataProvider:ClearSets()

        local text, isLimited, patch, version--版本
        for _, info in pairs(variantSets) do
            if info and info.setID then
                local meno, collect, numAll = GetSetsCollectedNum(info.setID)
                if meno and numAll then

                    text= (text or '').. meno..' '--未收集，数量
                    --version= version or _G['EXPANSION_NAME'..(info.expansionID or '')]--版本
                    isLimited= isLimited or info.limitedTimeSet--限时套装

                    local name= info.description or info.name or ''
                    name= e.cn(name)
                    name= numAll==collect and '|cnGREEN_FONT_COLOR:'..name..'|r' or name--已收集

                    local isCollected= collect== numAll--是否已收

                    local tip= (collect==0 and '|cff9e9e9e'..collect..'|r' or collect)
                                ..'/'..numAll--收集数量
                                ..' '..meno..(not isCollected and ' ' or '')
                                ..name--名称
                                ..(info.limitedTimeSet and '|A:socialqueuing-icon-clock:0:0|a' or '')--限时套装
                                ..' '..info.setID
                                --..(info.setID==btn.setID and ' '..format('|A:%s:0:0|a', e.Icon.toLeft) or '')
                    tipsText= tipsText..'|n'..(isCollected and '|cnGREEN_FONT_COLOR:'..tip..'|r' or tip)
                end
                patch= patch or (info.patchID and info.patchID>0 and 'v'..(info.patchID/10000))
                version= version or (info.expansionID and e.cn(_G['EXPANSION_NAME'..info.expansionID]))
            end
        end

        btn.tooltip= tipsText
            ..((patch or version) and '|n' or '')

            ..(version and '|n'..version or '')..(patch and ' '..patch or '')

        local r, g, b= btn.Name:GetTextColor()

        btn.Label:SetText(text)
        btn.Label:SetTextColor(r, g, b)

        --[[local maxNum=#variantSets
        btn.maxNum:SetText(maxNum~=0 and maxNum or '')--套装最大数量
        btn.maxNum:SetTextColor(r, g, b)]]

        btn.limited:SetShown(isLimited and true or false)--限时

        btn.version:SetText(version or '')--版本
        btn.version:SetTextColor(r, g, b)

        local numStes= #variantSets
        btn.numSetsLabel:SetText(numStes>1 and numStes or '')
        btn.numSetsLabel:SetTextColor(r, g, b)
    end)

    WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.tipsLabel= e.Cstr(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, {size=14})--点击，按钮信息
    WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.tipsLabel:SetPoint('BOTTOMLEFT', WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, 'BOTTOMRIGHT', 8, 8)
    hooksecurefunc(WardrobeSetsScrollFrameButtonMixin, 'OnClick', function(btn, buttonName)--点击，显示套装情况Blizzard_Wardrobe.lua
        if buttonName == "LeftButton" or not Save.hideSets then
            WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.tipsLabel:SetText(btn.tooltip or '')--点击，按钮信息
        else
            WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.tipsLabel:SetText("")
        end
    end)
end










--幻化
local function Init_Wardrober()
    --物品, 幻化, 界面
    Init_Wardrober_Items()

    --外观，物品，提示, 索引
    hooksecurefunc(WardrobeCollectionFrame.ItemsCollectionFrame, 'UpdateItems', set_Items_Tooltips)

    

    --幻化，套装，索引
    hooksecurefunc(WardrobeCollectionFrame.SetsTransmogFrame, 'UpdateSets', set_Sets_Tooltips)

    --套装,物品, Link
    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', Init_Wardrobe_DetailsFrame)

    --套装，列表
    Init_Wardrober_ListContainer()

end






























--#####
--传家宝, 按钮，提示
--Blizzard_HeirloomCollection.lua
local function Init_Heirloom()
    if e.Is_Timerunning then--10.2.7
        return
    end
    hooksecurefunc(HeirloomsJournal, 'UpdateButton', function(_, button)
        if Save.hideHeirloom then
            if button.isPvP then
                button.isPvP:SetShown(false)
            end
            if button.upLevel then
                button.upLevel:SetShown(false)
            end
            if button.itemLevel then
                button.itemLevel:SetText('')
            end
            for index=1 ,4 do
                local text=button['statText'..index]
                if text then
                    text:SetText('')
                end
            end
            return
        end
        local _, _, isPvP, _, upgradeLevel = C_Heirloom.GetHeirloomInfo(button.itemID)
        --local _, _, isPvP, _, upgradeLevel, _, _, _, _, maxLevel = C_Heirloom.GetHeirloomInfo(button.itemID)
        local maxUp=C_Heirloom.GetHeirloomMaxUpgradeLevel(button.itemID) or 0
        local level= maxUp-(upgradeLevel or 0)
        local has = C_Heirloom.PlayerHasHeirloom(button.itemID)
        if has then--需要升级数
            if not button.upLevel then
                button.upLevel = button:CreateTexture(nil, 'OVERLAY')
                button.upLevel:SetPoint('TOPLEFT', -4, 4)
                button.upLevel:SetSize(26,26)
                button.upLevel:SetVertexColor(1,0,0)
                button.upLevel:EnableMouse(true)
                button.upLevel:SetScript('OnLeave', GameTooltip_Hide)
                button.upLevel:SetScript('OnEnter', function(self2)
                    if self2.maxUp and self2.upgradeLevel then
                        e.tips:SetOwner(self2, "ANCHOR_LEFT")
                        e.tips:ClearLines()
                        e.tips:AddLine(format(e.onlyChinese and '传家宝升级等级：%d/%d' or HEIRLOOM_UPGRADE_TOOLTIP_FORMAT, self2.upgradeLevel, self2.maxUp))
                        e.tips:AddDoubleLine(id, e.cn(addName))
                        e.tips:Show()
                    end
                end)
                button.upLevel:SetScript('OnMouseDown', function(self2)
                    local itemID= self2:GetParent().itemID
                    if itemID and C_Heirloom.PlayerHasHeirloom(itemID) then
                        C_Heirloom.CreateHeirloom(itemID)
                    end
                end)
            end
        end
        if button.upLevel then
            button.upLevel.maxUp= maxUp
            button.upLevel.upgradeLevel= upgradeLevel
            button.upLevel:SetShown(has and level>0)
            if level>0 then
                button.upLevel:SetAtlas('services-number-%d'..level)
            else
                button.upLevel:SetTexture(0)
            end
        end

        if isPvP and not button.isPvP then
            button.isPvP=button:CreateTexture(nil, 'OVERLAY')
            button.isPvP:SetPoint('TOP')
            button.isPvP:SetSize(14, 14)
            button.isPvP:SetAtlas('honorsystem-icon-prestige-6')
            button.isPvP:EnableMouse(true)
            button.isPvP:SetScript('OnLeave', GameTooltip_Hide)
            button.isPvP:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddLine(e.onlyChinese and '竞技装备' or ITEM_TOURNAMENT_GEAR)
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
            end)
            button.isPvP:SetScript('OnMouseDown', function(self2)
                local itemID= self2:GetParent().itemID
                if itemID and C_Heirloom.PlayerHasHeirloom(itemID) then
                    C_Heirloom.CreateHeirloom(itemID)
                end
            end)
        end
        if button.isPvP then
            button.isPvP:SetShown(isPvP)
        end
        if not button.moved and button.level then--设置，等级数字，位置
            button.level:ClearAllPoints()
            button.level:SetPoint('TOPRIGHT', button, 'TOPRIGHT')

            button.levelBackground:ClearAllPoints()
            button.levelBackground:SetPoint('TOPRIGHT', button, 'TOPRIGHT',-2,-2)
            button.levelBackground:SetAlpha(0.5)

            button.slotFrameCollected:SetTexture(0)--外框架
            button.slotFrameCollected:SetShown(false)
            button.slotFrameCollected:SetAlpha(0)
            button.moved= true
        end
        if level==0 then
            button.level:SetText('')
        end
        button.levelBackground:SetShown(level>0 and has)

        e.Set_Item_Stats(button, C_Heirloom.GetHeirloomLink(button.itemID), {point=button.iconTexture, itemID=button.itemID, hideSet=true, hideLevel=not has, hideStats=not has})--设置，物品，4个次属性，套装，装等，
    end)









    local check= e.Cbtn(HeirloomsJournal, {size={22,22}, icon='hide'})
    function check:set_alpha()
        self:SetAlpha(Save.hideHeirloom and 0.3 or 1)
    end
    function check:set_texture()
        self:SetNormalAtlas(Save.hideHeirloom and e.Icon.disabled or e.Icon.icon)
    end
    function check:set_filter_shown()
        self.frame:SetShown(not Save.hideHeirloom)
    end
    function check:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_RIGHT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        if UnitAffectingCombat('player') then
            e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
        end
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '传家宝' or HEIRLOOMS).. ' '..e.GetEnabeleDisable(not Save.hideHeirloom), e.Icon.right)
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.Heirlooms_Class_Scale or 0), e.Icon.mid)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(e.onlyChinese and '全职业' or ALL_CLASSES, e.Icon.left)
        e.tips:Show()
    end
    check:SetScript('OnClick',function (self, d)
        if d=='RightButton' then
            Save.hideHeirloom= not Save.hideHeirloom and true or nil
            self:set_tooltips()
            self:set_alpha()
            self:set_texture()
            self:set_filter_shown()
            HeirloomsJournal:FullRefreshIfVisible()
        else
            HeirloomsJournal:SetClassAndSpecFilters(0, 0)
        end
    end)
    check:SetScript("OnMouseWheel", function(self, d)
        local n
        n= Save.Heirlooms_Class_Scale or 1
        n= d==1 and n-0.1 or n
        n= d==-1 and n+0.1 or n
        n= n<0.4 and 0.4 or n
        n= n>4 and 4 or n
        if n==1 then
            n=nil
        end
        Save.Heirlooms_Class_Scale=n
        self:set_frame_scale()
        self:set_tooltips()
    end)

    check:SetPoint('TOPLEFT', HeirloomsJournal.iconsFrame, 'TOPRIGHT', 8, 0)
    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', check.set_tooltips)


    --过滤，按钮
    check.frame= CreateFrame('Frame', nil, check)
    check.frame:SetPoint('TOPLEFT', check, 'BOTTOMLEFT',0 -80)
    check.frame:SetSize(26, 1)
    function check:set_frame_scale()
        self.frame:SetScale(Save.Heirlooms_Class_Scale or 1)
    end

    check.classButton={}
    check.specButton={}

    function check:cereate_button(classID, specID, texture, atlas)
        local btn= e.Cbtn2({parent=self.frame, notSecureActionButton=true, size=26, showTexture=true, click=true})
        function btn:set_select(class, spec)
            if class==self.classID and spec==self.specID then
                self:LockHighlight()
            else
                self:UnlockHighlight()
            end
        end
        btn:SetScript('OnClick', function(f)
            HeirloomsJournal:SetClassAndSpecFilters(f.classID, f.specID)
        end)
        btn:SetScript('OnLeave', GameTooltip_Hide)
        btn:SetScript('OnEnter', function(f)
            if UnitAffectingCombat('player') then
                e.tips:SetOwner(f, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:AddLine(' ')
                e.tips:AddLine('|cnRED_FONT_COLOR:'..(e.onlyChinese and '请不要在战斗中使用' or 'Please do not use in combat'))
                e.tips:Show()
            end
        end)
        if texture then
            btn.texture:SetTexture(texture)
        else
            btn.texture:SetAtlas(atlas)
        end
        btn.classID= classID
        btn.specID= specID
        return btn
    end

    function check:init_spce(classID, spec)
        classID= classID or 0
        spec= spec or 0
        local num= classID>0 and GetNumSpecializationsForClassID(classID) or 0
        for i = 1, num, 1 do
            local specID, _, _, icon, role = GetSpecializationInfoForClassID(classID, i, e.Player.sex)
            local btn= self.specButton[i]
            if not btn then
                btn= self:cereate_button(classID, specID, icon, nil)
                btn.roleTexture= btn:CreateTexture(nil, 'OVERLAY', nil, 7)
                btn.roleTexture:SetSize(15,15)
                btn.roleTexture:SetPoint('LEFT', btn, 'RIGHT', -4, 0)
                if i==1 then
                    local texture= btn:CreateTexture()
                    texture:SetPoint('RIGHT', btn, 'LEFT')
                    texture:SetSize(10, 10)
                    texture:SetAtlas('common-icon-rotateleft')
                end
                self.specButton[i]= btn
            else
                btn.classID= classID
                btn.specID= specID
                btn.texture:SetTexture(icon)
            end
            role= role=='DAMAGER' and 'DPS' or role
            btn.roleTexture:SetAtlas('UI-LFG-RoleIcon-'..role..'-Micro')

            btn:ClearAllPoints()
            if i==1 then
                btn:SetPoint('TOPLEFT', self.classButton[classID], 'TOPRIGHT', 7 ,0)
            else
                btn:SetPoint('TOP', self.specButton[i-1], 'BOTTOM')
            end
            btn:SetShown(true)
            btn:set_select(classID, spec)
        end
        for i=num+1, #self.specButton, 1 do
            self.specButton[i]:SetShown(false)
        end
    end


    for i = 1, GetNumClasses() do--设置，职业
        local classFile, classID= select(2, GetClassInfo(i))
        local atlas
        if classFile==e.Player.class then
            atlas= 'auctionhouse-icon-favorite'
        else
            atlas= e.Class(nil, classFile, true)
        end
        if atlas then
            local btn= check:cereate_button(classID, 0, nil, atlas)
            check.classButton[i]=btn
            btn:SetPoint('TOPLEFT', check.classButton[i-1] or check.frame, 'BOTTOMLEFT')
        end
    end

    C_Timer.After(2, function()
        check:init_spce(select(2, UnitClassBase('player')), PlayerUtil.GetCurrentSpecID() or 0)
    end)

    function check:chek_select(Class, Spec)
        for _, btn in pairs(self.classButton) do
            btn:set_select(Class, Spec)
        end
        self:init_spce(Class, Spec)
    end


    hooksecurefunc(HeirloomsJournal, 'SetClassAndSpecFilters', function(_, Class, Spec)
        check:chek_select(Class, Spec)
    end)

    check:set_alpha()
    check:set_texture()
    check:set_filter_shown()
    check:set_frame_scale()
end



























































--#########
--坐骑, 界面
--#########
local function Init_Mount()
    hooksecurefunc('MountJournal_UpdateMountDisplay', function()--坐骑
        if not MountJournal.MountDisplay.tipButton then
            MountJournal.MountDisplay.tipButton= e.Cbtn(MountJournal.MountDisplay, {size={22,22}, atlas='QuestNormal'})
            MountJournal.MountDisplay.tipButton:SetPoint('BOTTOMRIGHT', MountJournal.MountDisplay.ModelScene.TogglePlayer, 'TOPRIGHT',0, 2)
            MountJournal.MountDisplay.tipButton.text= e.Cstr(MountJournal.MountDisplay, {copyFont= MountJournal.MountCount.Label, color=false, justifyH='LEFT'})
            MountJournal.MountDisplay.tipButton.text:SetPoint('BOTTOMLEFT', 2, 2)

            function MountJournal.MountDisplay.tipButton:set_Alpha()
                self:SetAlpha(Save.ShowMountDisplayInfo and 0.2 or 1)
            end
            function MountJournal.MountDisplay.tipButton:set_Tooltips()
                e.tips:SetOwner(self, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '显示信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, SHOW, INFO), e.GetShowHide(not Save.ShowMountDisplayInfo))
                e.tips:AddLine(' ')
                e.tips:AddDoubleLine(id, e.cn(addName))
                e.tips:Show()
            end
            function MountJournal.MountDisplay.tipButton:set_Text()
                local text
                if Save.ShowMountDisplayInfo then
                    local creatureDisplayInfoID, _, _, isSelfMount, mountTypeID, uiModelSceneID, animID, spellVisualKitID, disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(MountJournal.selectedMountID)
                    text= 'mountID '..MountJournal.selectedMountID
                        ..'|nanimID '..(animID or '')
                        ..'|nisSelfMount '.. (isSelfMount and 'true' or 'false')
                        ..'|nmountTypeID '..(mountTypeID or '')
                        ..'|nspellVisualKitID '..(spellVisualKitID or '')
                        ..'|nuiModelSceneID '..(uiModelSceneID or '')
                        ..'|ncreatureDisplayInfoID '..(creatureDisplayInfoID or '')

                        local _, spellID, icon, _, _, sourceType= C_MountJournal.GetMountInfoByID(MountJournal.selectedMountID)
                        text= text..'|nspellID '..(spellID or '')
                                    ..'|nicon '..(icon and '|T'..icon..':0:0|t'..icon or '')
                                    ..'|nsourceType '..(e.cn(sourceType) or '').. (sourceType and e.cn(_G['BATTLE_PET_SOURCE_'..sourceType]) and ' ('..e.cn(_G['BATTLE_PET_SOURCE_'..sourceType])..')' or '')
                end
                self.text:SetText(text or '')
            end
            MountJournal.MountDisplay.tipButton:SetScript('OnClick', function(self)
                Save.ShowMountDisplayInfo= not Save.ShowMountDisplayInfo and true or nil
                self:set_Text()
                self:set_Alpha()
                self:set_Tooltips()
            end)
            MountJournal.MountDisplay.tipButton:SetScript('OnLeave', GameTooltip_Hide)
            MountJournal.MountDisplay.tipButton:SetScript('OnEnter', MountJournal.MountDisplay.tipButton.set_Tooltips)
            MountJournal.MountDisplay.tipButton:set_Alpha()
        end
        MountJournal.MountDisplay.tipButton:set_Text()
    end)

    --总数
    --MountJournal.MountCount.Count:ClearAllPoints()
    MountJournal.MountCount.Count:SetPoint('RIGHT', -4,0)
    hooksecurefunc('MountJournal_UpdateMountList', function()
        local numMounts = C_MountJournal.GetNumMounts() or 0
        if numMounts>1 then
            local mountIDs = C_MountJournal.GetMountIDs() or {}
            MountJournal.MountCount.Count:SetText(MountJournal.numOwned..'/'..#mountIDs)
        end
    end)
end















--宠物
--Blizzard_PetCollection.lua
local function Init_Pet()
    --增加，总数
    PetJournal.PetCount.Label:ClearAllPoints()--太长了，
    PetJournal.PetCount.Label:SetPoint('RIGHT', PetJournal.PetCount.Count, 'LEFT', -2, 0)
    PetJournal.PetCount.Label:SetJustifyH('RIGHT')
    hooksecurefunc('PetJournal_UpdatePetList', function()
	    PetJournal.PetCount.Count:SetFormattedText('%d/%d', C_PetJournal.GetNumPets())

    end)
end






















    --试衣间, 外观列表
    --DressUpFrames.lua
local function Init_DressUpFrames()
    hooksecurefunc(DressUpOutfitDetailsSlotMixin, 'SetDetails', function(frame)
        if frame.setEnter then
            return
        end
        frame.setEnter=true
        frame.Icon:EnableMouse(true)
        function frame:get_item_link()
            local link
            if self.transmogID then
                if self.item then
                    link = select(6, C_TransmogCollection.GetAppearanceSourceInfo(self.transmogID))
                else
                    link = select(2, C_TransmogCollection.GetIllusionStrings(self.transmogID))
                end
            end
            return link
        end
        frame.Icon:SetScript("OnMouseUp", function(self) self:SetAlpha(0.5) end)
        frame.Icon:SetScript("OnMouseDown", function(self, d)
            local p= self:GetParent()
            local link= p:get_item_link()
            if d=='LeftButton' then
                e.Chat(link, nil, true)
            elseif d=='RightButton' then
                WoWTools_ToolsButtonMixin:LoadedCollectionsJournal(5)
                
                local wcFrame= WardrobeCollectionFrame
                --[[if not CollectionsJournal:IsVisible() or not wcFrame:IsVisible() then
                    ToggleCollectionsJournal(5)
                end]]
                if wcFrame.activeFrame ~= wcFrame.ItemsCollectionFrame then
                    wcFrame:ClickTab(wcFrame.ItemsTab)
                end
                if p.transmogLocation then
                    WardrobeCollectionFrame.ItemsCollectionFrame:SetActiveSlot(p.transmogLocation)
                end
                WardrobeCollectionFrameSearchBox:SetText(p.name or '')
            end
            self:SetAlpha(0.3)
        end)
        frame.Icon:SetScript("OnLeave", function(self) GameTooltip_Hide() self:SetAlpha(1) end)
        frame.Icon:SetScript("OnEnter", function(self)
            local p= self:GetParent()
            local link= p:get_item_link()
            if not link then
                return
            end
            e.tips:SetOwner(self, "ANCHOR_RIGHT")
            e.tips:ClearLines()
            e.tips:SetHyperlink(link)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(e.onlyChinese and '链接' or COMMUNITIES_INVITE_MANAGER_COLUMN_TITLE_LINK, e.Icon.left)
            if p.name then
                e.tips:AddDoubleLine(e.onlyChinese and '搜索' or SEARCH, e.Icon.right)
            end
            e.tips:Show()
            self:SetAlpha(0.5)
        end)
    end)
end















local function Init_ToyBox()
    hooksecurefunc('ToySpellButton_UpdateButton', function(self)
        if not self.itemID and self.itemID>0 then
            return
        end
        if ToyBox.fanfareToys[self.itemID] then
            self.name:SetTextColor(0,1,0)
        else
            if not PlayerHasToy(self.itemID) then
                self.name:SetTextColor(1,1,1)
            end
        end
    end)
end


















local function Init()
    Init_SetsDataProvider()
    
    Init_Heirloom()--传家宝
    Init_Wardrober()--幻化
    Init_Mount()--坐骑, 界面
    Init_Pet()
    Init_ToyBox()--玩具
end




















local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            WoWToolsSave['WoW-CollectionWardrobeSets']=nil
            WoWToolsSave['WoW-CollectionWardrobeItems']=nil

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(e.onlyChinese and '收藏' or addName),
                tooltip= e.cn(addName),
                GetValue= function() return not Save.disabled end,
                SetValue= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })


            if not Save.disabled then
                if C_AddOns.IsAddOnLoaded('Blizzard_Collections') then
                    Init()
                    self:UnregisterEvent('ADDON_LOADED')
                end
                Init_DressUpFrames()--试衣间, 外观列表
            else
                self:UnregisterEvent('ADDON_LOADED')
            end


        elseif arg1=='Blizzard_Collections' then
            Init()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
        end

    end
end)
