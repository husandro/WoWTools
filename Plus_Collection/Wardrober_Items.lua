

local function Save()
    return WoWToolsSave['Plus_Collection'] or {}
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
    '|A:transmog-nav-slot-enchant:0:0|a',--28 WoWTools_DataMixin.onlyChinese and '武器附魔' or WEAPON_ENCHANTMENT,
    '|A:ElementalStorm-Lesser-Earth:0:0|a',--29'军团再临"神器
}









local function UpdateSlotButtons(self)
    if not self:IsVisible() then
        return
    end

    for _, btn in pairs(self.SlotsFrame.Buttons) do
        local collected= 0
        local category
        if not Save().hideItems then
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
                category= btn.category
                if not category then
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
                end
                if category then
                    collected= C_TransmogCollection.GetFilteredCategoryCollectedCount(category)

                    if collected==0 then-- and self.activeCategory== category then
                        if TableIsEmpty(self.visualsList) then--第一次打开时，会是0
                            collected= C_TransmogCollection.GetCategoryCollectedCount(category)

                        else
                            for _, illusion in ipairs(self.visualsList or {}) do
                                if ( illusion.isCollected ) then
                                    collected = collected + 1;
                                end
                            end
                        end
                    end
                end
            end

        end
        if collected and collected>0 and not btn.Text then
            btn.Text= WoWTools_LabelMixin:Create(btn, {justifyH='CENTER'})
            btn.Text:SetPoint('BOTTOMRIGHT')
            btn.Text.category= category
        end
        if btn.Text then
            btn.Text:SetText(
                collected and collected>0 and
                WoWTools_DataMixin:MK(collected, 3)
                or ''
            )
        end
    end
end







--物品
local function Init_Wardrober_Items()--物品, 幻化, 界面
    --部位，已收集， 提示
    WoWTools_DataMixin:Hook(WardrobeCollectionFrame.ClassDropdown, 'SetClassFilter', function(self)
        C_Timer.After(0.3, function()
            UpdateSlotButtons(WardrobeCollectionFrame.ItemsCollectionFrame)
        end)
    end)

    WoWTools_DataMixin:Hook(WardrobeCollectionFrame.ItemsCollectionFrame, 'UpdateSlotButtons', UpdateSlotButtons)

    for _, btn in pairs(WardrobeCollectionFrame.ItemsCollectionFrame.SlotsFrame.Buttons) do
        btn:HookScript('OnEnter', function(self)
            if Save().hideItems then
                return
            end
            GameTooltip:AddLine(' ')
            local slotID= self.transmogLocation:GetSlotID()
            GameTooltip:AddLine('slotID '..slotID..' '..self.slot)
            if self.transmogLocation:IsIllusion() then--武器，附魔            
                local collected, all= 0, 0
                for _, illusion in ipairs(C_TransmogCollection.GetIllusions() or {}) do
                    if ( illusion.isCollected ) then
                        collected = collected + 1
                    end
                    all= all+ 1
                end
                if all>0 then
                    GameTooltip:AddLine(
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
                        local name= WoWTools_TextMixin:CN(C_TransmogCollection.GetCategoryInfo(category)) or ''
                        GameTooltip:AddLine(
                            format('%s%s%s %i%%  %s/%s%s', col, icon, name, collected/all*100, WoWTools_DataMixin:MK(collected, 3), WoWTools_DataMixin:MK(all, 3), WoWTools_DataMixin.Icon.Player)
                        )
                        n=n+1
                    end
                end
            elseif self.Text and self.Text.category then
                GameTooltip:AddLine('category '..self.Text.category)
                local collected= C_TransmogCollection.GetCategoryCollectedCount(self.Text.category) or 0
                local all= C_TransmogCollection.GetCategoryTotal(self.Text.category) or 0
                local icon= SlotsIcon[self.Text.category] or ''
                GameTooltip:AddLine(
                    format('%s%i%%  %s/%s', icon, collected/all*100, WoWTools_DataMixin:MK(collected, 3), (WoWTools_DataMixin:MK(all, 3) ) or '')..WoWTools_DataMixin.Icon.Player)
            end
            GameTooltip:Show()
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

local function btn_alphacolor(btn)
    local icon= btn:GetNormalTexture()
    if not icon then
        return
    end
    if btn:IsMouseOver() then
        if btn.index==1 then
            icon:SetDesaturated(false)
        end
        icon:SetAlpha(1)
    else
        if btn.index==1 then
            icon:SetDesaturated(not btn.isCollected and true or false)
            icon:SetAlpha(btn.isCollected and 1 or 0.5)
        else
            if btn.isCollected then
                icon:SetVertexColor(0, 1, 0, 0.5)
            else
                icon:SetVertexColor(1, 0, 0, 0.5)
            end
        end
    end
end

local function btn_enter(self)
    local link2= self.link
    if not link2 then
        return
    end

    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self:GetParent():GetParent(), "ANCHOR_RIGHT",8,-300)

    if self.illusionID then
        local name, _, sourceText = C_TransmogCollection.GetIllusionStrings(self.illusionID)
        GameTooltip:AddLine(name)
        GameTooltip:AddLine(' ')
        GameTooltip:AddLine(sourceText, 1,1,1, true)
        GameTooltip:AddLine(' ')

        local info = C_TransmogCollection.GetIllusionInfo(self.illusionID)
        if info then
            GameTooltip:AddDoubleLine('visualID '..(info.visualID or ''), 'sourceID '..(info.sourceID or ''))
            GameTooltip:AddDoubleLine(
                info.icon and '|T'..info.icon..':0|t'..info.icon or '', 'isHideVisual '..(info.isHideVisual and 'true' or 'false'))
            GameTooltip:AddDoubleLine(
                info.isCollected
                and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '已收集' or COLLECTED)
                or ('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '未收集' or NOT_COLLECTED)),

                info.isUsable
                and '|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '可用' or AVAILABLE)
                or ('|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '不可用' or UNAVAILABLE))
            )
        end
    else
        GameTooltip:SetHyperlink(link2)
    end
    GameTooltip:AddDoubleLine(WoWTools_DataMixin.onlyChinese and '发送' or SEND_LABEL, WoWTools_DataMixin.Icon.left)

    GameTooltip:AddDoubleLine(WoWTools_DataMixin.addName, WoWTools_CollectionMixin.addName)
    GameTooltip:Show()
end


local function Create_Items_ListButton(model, index, x, y, h )
    local btn=WoWTools_ButtonMixin:Cbtn(model, {
        size= index==1 and {14.4, 14.4} or h,
    })

    if index==1 then
        btn:SetPoint('BOTTOMLEFT', -4, -4)
    else
        btn:SetPoint('BOTTOMLEFT', x, y)
    end

    btn:SetScript("OnLeave",function(self)
        btn_alphacolor(self)
        GameTooltip:Hide()
    end)

    btn:SetScript("OnEnter",function(self)
        btn_enter(self)
        btn_alphacolor(self)
    end)

    btn:SetScript("OnClick", function(self)
        local link2= get_Link_Item_Type_Source(self.sourceID, self.type) or self.link
        WoWTools_ChatMixin:Chat(link2, nil, true)
    end)

    model.itemButton[index]= btn
    return btn
end


local function set_Items_Tooltips(self)--UpdateItems
    if not self:IsVisible() or WoWTools_FrameMixin:IsLocked(self) then
        return
    end

    local idexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE
    for i= 1, self.PAGE_SIZE do
        local model = self.Models[i]
        if model and model:IsShown() then
            model.itemButton=model.itemButton or {}

            local itemLinks={}

            if not Save().hideItems and self.transmogLocation then
                local findLinks={}
                if self.transmogLocation:IsIllusion() then--WardrobeItemsModelMixin:OnMouseDown(button)
                    local link= get_Link_Item_Type_Source(model.visualInfo.sourceID, 'illusion')--select(2, C_TransmogCollection.GetIllusionStrings(model.visualInfo.sourceID))
                    if link then
                       WoWTools_DataMixin:Load(link, 'item')--加载 item quest spell
                        --visualInfo={isHideVisual=, visualID=, isCollected=, sourceID=, icon=, isUsable=}
                        table.insert(itemLinks, {
                            link= link,
                            sourceID= model.visualInfo.sourceID,
                            type='illusion',
                            isCollected= model.visualInfo.isCollected
                        })
                    end
                else
                    local sources = CollectionWardrobeUtil.GetSortedAppearanceSources(model.visualInfo.visualID, self:GetActiveCategory(), self.transmogLocation) or {}
                    for index= 1, #sources do
                        local link= get_Link_Item_Type_Source(sources[index],'item')--WardrobeCollectionFrame:GetAppearanceItemHyperlink(sources[index])
                        if link and not findLinks[link] then
                            --sources[index]= {sourceType=3, visualID=1, isCollected=, isValidSourceForPlayer, categoryID, isHideVisual, quality, invType, sourceID, playerCanCollect, inventorySlot, itemID, itemModID, name, canDisplayerOnPlayer}
                           WoWTools_DataMixin:Load(link, 'item')--加载 item quest spell
                            table.insert(itemLinks, {
                                link=link,
                                sourceID=sources[index],
                                type='item',
                                isCollected= sources[index].isCollected
                            })
                            findLinks[link]=true
                        end
                    end
                end
                findLinks=nil

                local y, x, h =0,0, 11
                for index, tab in pairs(itemLinks) do
                    local btn= model.itemButton[index] or Create_Items_ListButton(model, index, x, y, h )

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
                    btn.isCollected= tab.isCollected

                    btn_alphacolor(btn)

                    btn:SetShown(true)
                end
            end

            for index= #itemLinks+1, #model.itemButton do
                model.itemButton[index]:SetShown(false)
            end

            local idex--索引
            if not Save().hideItems then
                idex= i + idexOffset
                if not model.Text then
                    model.Text= WoWTools_LabelMixin:Create(model, {color={r=1,g=1,b=1}})
                    model.Text:SetPoint('BOTTOMRIGHT', -3, 2)
                    model.Text:SetAlpha(0.5)
                end
            end
            if model.Text then
                model.Text:SetText(idex or '')
            end
        end
    end
end








 --幻化，套装，索引 WardrobeCollectionFrame.SetsTransmogFrame
 local function set_Sets_Tooltips(self)--UpdateSets
    if not self:IsVisible() or WoWTools_FrameMixin:IsLocked(self) then
        return
    end
    local idexOffset = (self.PagingFrame:GetCurrentPage() - 1) * self.PAGE_SIZE
    for i= 1, self.PAGE_SIZE do
        local model = self.Models[i]
        if model and model:IsShown() then
            local idex--索引
            if not Save().hideItems then
                idex= i + idexOffset
                if not model.Text then
                    model.Text= WoWTools_LabelMixin:Create(model)
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






















local function Init()
    if Save().hideItems then
        return
    end
    --外观，物品，提示, 索引
    WoWTools_DataMixin:Hook(WardrobeCollectionFrame.ItemsCollectionFrame, 'UpdateItems', function(self)
        set_Items_Tooltips(self)
    end)

    --物品, 幻化, 界面
    Init_Wardrober_Items()

    --幻化，套装，索引
    WoWTools_DataMixin:Hook(WardrobeCollectionFrame.SetsTransmogFrame, 'UpdateSets', function(self)
        set_Sets_Tooltips(self)
    end)

    WardrobeCollectionFrameSearchBox:ClearAllPoints()
    WardrobeCollectionFrameSearchBox:SetPoint('LEFT',WardrobeCollectionFrame.progressBar ,'RIGHT', 12, 0)
    WardrobeCollectionFrameSearchBox:SetPoint('LEFT', WardrobeCollectionFrame.progressBar, 'RIGHT')

    Init=function()end
end







function WoWTools_CollectionMixin:Init_Wardrober_Items()--幻化 5
    Init()
end

