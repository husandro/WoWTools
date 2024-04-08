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

--保存，物品，数据
local wowSaveItems={}
function Save_Items_Date()
    local List={}
    for i=1, 29 do
        if i==28 then
            local visualsList=C_TransmogCollection.GetIllusions() or {}
            local totale = #visualsList
            if totale>0 then
                local collected = 0
                for _, illusion in ipairs(visualsList) do
                    if ( illusion.isCollected ) then
                        collected = collected + 1
                    end
                end
                table.insert(List, {
                    index=i,
                    Collected=collected,
                    All=totale,
                })
            end
        else
            local all= C_TransmogCollection.GetCategoryTotal(i) or 0
            if  all>0 then--C_TransmogCollection.GetCategoryInfo(i) and
                table.insert(List, {
                    index=i,
                    Collected=C_TransmogCollection.GetCategoryCollectedCount(i),
                    All=all,
                })
            end
        end
    end
    wowSaveItems[e.Player.class]=List
end

--保存，套装，数据
--wowSaveSets= {[1]={class=str,numCollected=number, numTotal=number}
local wowSaveSets = {
    ['1']={['class']='WARRIOR'},
    ['2']={['class']='PALADIN'},
    ['4']={['class']='HUNTER'},
    ['8']={['class']='ROGUE'},
    ['16']={['class']='PRIEST'},
    ['32']={['class']='DEATHKNIGHT'},
    ['64']={['class']='SHAMAN'},
    ['128']={['class']='MAGE'},
    ['256']={['class']='WARLOCK'},
    ['512']={['class']='MONK'},
    ['1024']={['class']='DRUID'},
    ['2048']={['class']='DEMONHUNTER'},
    ['4096']={['class']='EVOKER'},
}
local function Save_Sets_Colleced()
    if not SetsDataProvider then
        return
    end

    local numCollected, numTotal = C_TransmogSets.GetBaseSetsCounts()
    local coll, all= 0, 0

    for _, set in pairs(C_TransmogSets.GetBaseSets() or {}) do
        local variantSets = SetsDataProvider:GetVariantSets(set.setID) or {}
        if #variantSets==0 then
            table.insert(variantSets, C_TransmogSets.GetSetInfo(set.setID))
        end
        for _, tab in pairs(variantSets) do
            coll=  tab.collected and coll+1  or coll
            all= all+1
        end
        SetsDataProvider:ClearSets()
    end

    for index, info in pairs(wowSaveSets) do
        if info.class==e.Player.class then
            wowSaveSets[index]={
                class= info.class,
                numCollected= numCollected,
                numTotal= numTotal,
                coll= coll,
                all= all,
            }
            break
        end
    end
end

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
            return '|cff606060'..numAll-numCollected..'|r ', numCollected, numAll,  '|cff606060'..numCollected..'|r/'..numAll--, '|cnRED_FONT_COLOR:'..(e.onlyChinese and '未收集' or NOT_COLLECTED)..'|r'
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





























--套装 Blizzard_Wardrobe.lua
local function Init_Wardrober_Sets()
    local btn= e.Cbtn(WardrobeCollectionFrame.SetsCollectionFrame, {size={20,20}, icon=not Save.hideSets})
    btn:SetPoint('TOPLEFT', WardrobeCollectionFrame.ItemsCollectionFrame, 'TOPRIGHT', 4, 40)

    --所有套装，数量
    btn.allSetsLabel= e.Cstr(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, {size=14, justifyH='RIGHT'})--所有套装，数量
    btn.allSetsLabel:SetPoint('BOTTOMRIGHT', -6, 8)

    function btn:set_all_sets_text()
        if Save.hideSets then
            self.allSetsLabel:SetText('')
            return
        end

        local sets = C_TransmogSets.GetAllSets() or {}
        local a, h, o= 0, 0, 0--联盟, 部落, 其它
        for _, info in pairs(sets) do
            if info and info.classMask and info.setID then
                if info.requiredFaction=='Alliance' then
                    a=a+1
                elseif info.requiredFaction=='Horde' then
                    h=h+1
                else
                    o=o+1
                end
            end
        end
        local m=''
        if a > 0 or h>0 or o>0 then
            m=m..h..  ' |A:communities-create-button-wow-horde:0:0|a'
            m=m..'|n'..a..' |A:communities-create-button-wow-alliance:0:0|a'
            m=m..'|n'..o..' |A:communities-guildbanner-background:0:0|a'
            m=m..'|n'..#sets..' '..(e.onlyChinese and '总计' or TOTAL)
        end

        self.allSetsLabel:SetText(m)--所有套装，数量
    end

    --所有玩家，收集情况
    btn.allPlayerLabel= e.Cstr(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, {size=14})--所有玩家，收集情况
    btn.allPlayerLabel:SetPoint('TOPLEFT', btn, 'BOTTOMLEFT', 4, -2)
    function btn:set_all_player_text()
        if Save.hideSets then
            self.allPlayerLabel:SetText('')
            return
        end

        local coll, all, numClass= 0, 0, 0
        local m=''
        for _, info in pairs(wowSaveSets) do
            if info.numCollected and info.numTotal and info.numTotal > 0 then
                local t='|A:classicon-'..info.class..':0:0|a'
                if info.coll and info.all and info.all>0 then
                    coll= coll+ info.coll
                    all= all+ info.all
                    t= t..format('%i%%', info.coll/info.all*100)..' '..info.coll..'/'.. info.all..'  '
                end
                t=t..'('..info.numCollected..'/'..info.numTotal..')'
                m=m..'|c'..select(4,GetClassColor(info.class))..t..'|r'..'|n'
                numClass= numClass+1
            end
        end
        if numClass>1 then
            m=m..'|n'
                ..(e.onlyChinese and '已收集 ' or TRANSMOG_COLLECTED)..format('%i%% %d/%d ', coll/all*100, coll, all)
                ..(e.onlyChinese and '职业' or CLASS)..' '..numClass
        end
        self.allPlayerLabel:SetText(m)--所有玩家，收集情况
    end

    function btn:set_texture()
        self:SetNormalAtlas(Save.hideSets and e.Icon.disabled or e.Icon.icon)
    end

    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(e.onlyChinese and '套装' or WARDROBE_SETS, e.GetEnabeleDisable(Save.hideSets)..e.Icon.left)
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:Show()
        self:SetAlpha(1)
    end

    btn:SetScript("OnClick", function(self)
        Save.hideSets= not Save.hideSets and true or nil
        self:set_all_sets_text()
        self:set_all_player_text()--收集所有角色套装数据
        self:set_tab_all_text()
        self:set_texture()
        self:set_tooltips()
        WardrobeCollectionFrame.SetsCollectionFrame:Refresh()
        if WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.tipsLabel then
            WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame.tipsLabel:SetText("")
        end
    end)

    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:SetScript('OnShow', function(self)
        self:set_all_sets_text()
        self:set_all_player_text()
    end)

    btn.tabAllLabel= e.Cstr(WardrobeCollectionFrameTab2)--WardrobeCollectionFrameTab2
    btn.tabAllLabel:SetPoint('BOTTOMLEFT', WardrobeCollectionFrameTab2.Text, 'TOPLEFT', 2, 8)
    function btn:set_tab_all_text()
        local text
        if not Save.hideSets then
            for _, info in pairs(wowSaveSets) do
                if info.class==e.Player.class then
                    if info.coll and info.all and info.all> 0  then
                        text= format('%d %i%%', info.coll/info.all*100, info.coll)
                    end
                    break
                end
            end
        end
        self.tabAllLabel:SetText(text or '')
    end

    WardrobeCollectionFrame:HookScript('OnShow', function()
        Save_Sets_Colleced()--保存，套装，数据
        btn:set_tab_all_text()
    end)

    btn:set_texture()
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
    local btn= e.Cbtn(WardrobeCollectionFrame.ItemsCollectionFrame, {size={20,20}, icon='hide'})
    btn:SetPoint('TOPLEFT', WardrobeCollectionFrame.ItemsCollectionFrame, 'TOPRIGHT', 8, 60)

    function btn:set_texture()
        self:SetNormalAtlas(Save.hideItems and e.Icon.disabled or e.Icon.icon)
    end
    function btn:set_tooltips()
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddDoubleLine(e.onlyChinese and '物品' or ITEMS, e.GetEnabeleDisable(Save.hideItems)..e.Icon.left)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine((e.onlyChinese and '缩放' or UI_SCALE)..' |cnGREEN_FONT_COLOR:'..(Save.Wardrober_Items_Labels_Scale or 1), e.Icon.mid)
        e.tips:Show()
    end
    function btn:set_label_scale()--缩放
        for _, label in pairs(self.itemsLabel) do
            label:SetScale(Save.Wardrober_Items_Labels_Scale or 1)
        end
    end

    btn:SetScript('OnClick',function(self)
        Save.hideItems= not Save.hideItems and true or nil
        self:set_texture()
        self:set_all_date_text()
        self:set_tooltips()
        WardrobeCollectionFrame.ItemsCollectionFrame:UpdateItems()
    end)

    btn:SetScript('OnEnter', btn.set_tooltips)
    btn:SetScript('OnLeave', GameTooltip_Hide)
    btn:SetScript('OnMouseWheel', function(self, d)--缩放
        local n= Save.Wardrober_Items_Labels_Scale or 1
        n= d==1 and n+ 0.1 or n
        n= d==-1 and n-0.1 or n
        n= n<0.4 and 0.4 or n
        n= n>4 and 4 or n
        Save.Wardrober_Items_Labels_Scale=n
        self:set_label_scale()
        self:set_tooltips()
    end)

    btn.itemsLabel={}
    function btn:get_class_list(findClass)--查询，职业，列表
        local tab2={}
        for class, tab in pairs (wowSaveItems) do
            if class==findClass then
               for index, info in pairs(tab or {}) do
                    local name = info.index==28 and (e.onlyChinese and '武器附魔' or WEAPON_ENCHANTMENT)
                            or e.cn(C_TransmogCollection.GetCategoryInfo(info.index))
                            or ''
                    local collected, all =  info.Collected or 0, info.All or 0
                    local num= collected..'/'.. all
                    local per= format('%i%%', collected/all*100)
                    if collected==all then
                        name= '|cnGREEN_FONT_COLOR:'..name..'|r'
                        num= '|cnGREEN_FONT_COLOR:'..num..'|r'
                        per= '|cnGREEN_FONT_COLOR:'..per..'|r'
                    end
                    table.insert(tab2, {
                        icon = SlotsIcon[info.index] or '',
                        name= name,
                        num= num,
                        per= per,
                        col= select(2, math.modf(index/2))==0 and '|cffff7f00' or '|cffffffff',
                    })
                end
                break

            end
        end
        return tab2
    end
    function btn:set_all_date_text()--设置内容
        if Save.hideItems then--禁用
            for _, label in pairs(self.itemsLabel) do
                label:SetText("")
            end
            return
        end

        local last=self
        local totaleCollected, totaleAll, totaleClass = 0, 0, 0--总数
        local classCollected, classAll= 0, 0--本职业，总数
        for class, tab in pairs (wowSaveItems) do
            local label= self.itemsLabel[class]
            if not label then
                label=e.Cstr(self, {mouse=true, })
                label.class= class
                label:SetPoint('TOPLEFT', last, 'BOTTOMLEFT', 0, last~=self and 0 or -12)
                function label:get_class_color()
                    return '|c'..select(4, GetClassColor(self.class)), '|A:classicon-'..self.class..':0:0|a'
                end

                label:SetScript('OnLeave', function(self) e.tips:Hide() self:SetAlpha(1) end)
                label:SetScript('OnEnter', function(frame)--鼠标提示                    
                    e.tips:SetOwner(frame, "ANCHOR_RIGHT")
                    e.tips:ClearLines()
                    local col, classIcon= frame:get_class_color()
                    e.tips:AddDoubleLine(classIcon..col..id, col..e.cn(addName)..classIcon)
                    e.tips:AddLine(' ')

                    for index, info in pairs(frame:GetParent():get_class_list(frame.class)) do
                        e.tips:AddDoubleLine(info.col..info.icon..info.name..' '..info.per, info.col..info.num..info.icon..' ('..index..(index<10 and ' ' or ''))
                    end

                    e.tips:Show()
                    frame:SetAlpha(0.5)
                end)
                label:SetScript('OnMouseDown', function(frame)
                    local la= frame:GetParent().itemsLabel.classList
                    la.class= frame.class
                    la:set_class_text()
                end)
                self.itemsLabel[class]=label
                last=label
            end


            local collected, all = 0, 0
            for _, info in pairs(tab) do
                collected = collected + (info.Collected or 0)
                all = all + (info.All or 0)
            end
            totaleClass= totaleClass +1
            totaleCollected= totaleCollected+ collected
            totaleAll= totaleAll+ all

            local col, classIcon= label:get_class_color()
            label:SetText(col..classIcon..format('%i%% ', collected/all*100)..e.MK(collected,3)..'/'..e.MK(all,3))

            if class== e.Player.class then
                classCollected, classAll= collected, all--本职业，总数
            end
        end

        local str= self.itemsLabel.all--总数字符
        if not str then
            str=e.Cstr(self)
            str:SetPoint('TOPLEFT', last, 'BOTTOMLEFT', 0, -12)
            str:SetJustifyH('RIGHT')
            self.itemsLabel.all=str
            last= str
        end
        local text
        if totaleClass>1 then
            text= e.Icon.wow2..format('%i%% %s/%s ', totaleCollected/totaleAll*100, e.MK(totaleCollected, 3), e.MK(totaleAll,3))..(e.onlyChinese and '职业' or CLASS)..' '..totaleClass
        end
        str:SetText(text or '')

        str= self.itemsLabel.classList--职业，列表
        if not str then
            str= e.Cstr(self)
            self.itemsLabel.classList= str
            str:SetPoint('TOPLEFT', last, 'BOTTOMLEFT', 0, -12)
            function str:set_class_text()
                local text=''
                for _, info in pairs(self:GetParent():get_class_list(self.class)) do
                    text= text..info.col..info.icon..info.name..' '..info.per..' '..info.num..'|r|n'
                end
                if self.class~=e.Player.class then
                    local color= C_ClassColor.GetClassColor(self.class)
                    local className= e.cn(LOCALIZED_CLASS_NAMES_MALE[self.class])
                    if colr and className then
                        className= color:WrapTextInColorCode(className)
                    end
                    text= e.Icon.toRight2..(e.Class(nil, self.class, false) or '')..(className or '')..e.Icon.toLeft2..'|n'..text
                end
                self:SetText(text)
            end
        end
        str.class=e.Player.class
        str:set_class_text()

        str= self.itemsLabel.allTabl--WardrobeCollectionFrameTab1 上，显示数量
        if not str then
            str= e.Cstr(WardrobeCollectionFrameTab1, {justifyH='RIGHT'})
            str:SetPoint('BOTTOMRIGHT', WardrobeCollectionFrameTab1.Text, 'TOPRIGHT', 2, 8)
            self.itemsLabel.allTab=str
        end
        str:SetText(classCollected>1 and format('%d %i%%', classCollected, classCollected/classAll*100) or '')
    end

    WardrobeCollectionFrame.InfoButton:ClearAllPoints()--移动，帮助，按钮
    WardrobeCollectionFrame.InfoButton:SetPoint('BOTTOMLEFT', CollectionsJournal.NineSlice.TopLeftCorner, -10, -15)

    btn:SetScript('OnShow', function()
        Save_Items_Date()
        btn:set_all_date_text()
    end)

    btn:set_texture()
    if Save.Wardrober_Items_Labels_Scale and Save.Wardrober_Items_Labels_Scale~= 1 then
        btn:set_label_scale()
    end

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
















--设置，目标为模型
local function Init_Wardrober_Transmog()
    local check= e.Cbtn(WardrobeTransmogFrame.ModelScene, {size={22, 22}, icon='hide'})
    check.Text= e.Cstr(check)
    check.Text:SetPoint('CENTER')

    check:SetPoint('TOP',WardrobeTransmogFrame.ModelScene.ClearAllPendingButton, 'BOTTOM', 0, -2)

    function check:set_event()
        if self:IsShown() and not Save.hideTransmog then
            self:RegisterEvent('PLAYER_TARGET_CHANGED')
            self.Text:SetText(C_TransmogSets.GetBaseSetsCounts() or 0)
        else
            self:UnregisterAllEvents()
        end
    end
    check:SetScript('OnShow', check.set_event)
    check:SetScript('OnHide', check.set_event)
    check:SetScript('OnMouseDown', function(self)
        if not self.Menu then
            self.Menu=CreateFrame("Frame", nil, self, "UIDropDownMenuTemplate")
            e.LibDD:UIDropDownMenu_Initialize(self.Menu, function(_, level, menuList)
                local info

                if menuList then
                    local variantSets = SetsDataProvider:GetVariantSets(menuList) or {}
                    if #variantSets==0 then
                        table.insert(variantSets, C_TransmogSets.GetSetInfo(menuList))
                    end
                    for _, tab in pairs(variantSets) do
                        if tab.setID then
                            local num= not tab.collected and select(4, GetSetsCollectedNum(tab.setID))
                            info={
                                text= e.cn(tab.name)..(num and ' '..num or ''),
                                notCheckable=true,
                                colorCode= tab.collected and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:',
                                arg1= tab.setID,
                                tooltipOnButton=true,
                                tooltipTitle= 'setID '..tab.setID,
                                keepShownOnClick=true,
                                arg2= tab.collected,
                                func= function(_, arg1, arg2)
                                    if arg2 then
                                        WardrobeCollectionFrame.SetsTransmogFrame.selectedSetID= arg1
                                        WardrobeCollectionFrame.SetsTransmogFrame:LoadSet(arg1)
                                     end
                                end
                            }
                            e.LibDD:UIDropDownMenu_AddButton(info, level)
                        end
                    end
                    SetsDataProvider:ClearSets()
                    return
                end
                for index, tab in pairs(C_TransmogSets.GetBaseSets() or {}) do
                    if tab.setID and tab.collected then
                        local variantSets = SetsDataProvider:GetVariantSets(tab.setID) or {}
                        local num= #variantSets
                        if  #variantSets==1 then
                            variantSets= C_TransmogSets.GetSetInfo(tab.setID)
                            num=1
                        end
                        info={
                            text='|cffffffff'..index..')|r '..e.cn(tab.name)..(num>1 and ' |cffffffff'..num..'|r' or ''),
                            notCheckable=true,
                            --colorCode= tab.collected and '|cnGREEN_FONT_COLOR:' or '|cnRED_FONT_COLOR:',
                            tooltipOnButton=true,
                            tooltipTitle= 'setID '..tab.setID,
                            keepShownOnClick=true,
                            arg1=tab.setID,
                            hasArrow=num>1 and true or false,
                            menuList= num>1 and tab.setID or nil,
                            --arg2= tab.collected,
                            func= function(_, arg1)--, arg2)
                              --  if arg2 then
                                    WardrobeCollectionFrame.SetsTransmogFrame.selectedSetID= arg1
                                    WardrobeCollectionFrame.SetsTransmogFrame:LoadSet(arg1)
                                --end
                            end
                        }
                        e.LibDD:UIDropDownMenu_AddButton(info, level)

                    end
                end
                SetsDataProvider:ClearSets()
            end, 'MENU')
        end
        e.LibDD:ToggleDropDownMenu(1, nil, self.Menu, self, 15, 0)
    end)

    function check:set_target()
        if Save.hideItems or not UnitExists('target') or not UnitIsPlayer('target') then
            return
        end
        local frame= WardrobeTransmogFrame
        local actor = frame.ModelScene:GetPlayerActor();
        if actor then
            local sheatheWeapons = false;
            local autoDress = true;
            local hideWeapons = false;
            local useNativeForm = true;
            local _, raceFilename = UnitRace("target");
            if(raceFilename == "Dracthyr" or raceFilename == "Worgen") then
                useNativeForm = not frame.inAlternateForm;
            end
            actor:SetModelByUnit("target", sheatheWeapons, autoDress, hideWeapons, useNativeForm);
            frame.ModelScene.previousActor = actor
        end
        frame:Update()
    end
    check:SetScript("OnEvent", check.set_target)
    hooksecurefunc(WardrobeTransmogFrame, 'RefreshPlayerModel', check.set_target)

    check:SetScript('OnLeave', GameTooltip_Hide)
    check:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddLine(' ')
        e.tips:AddLine(format(e.onlyChinese and '已收集（%d/%d）' or ITEM_PET_KNOWN, C_TransmogSets.GetBaseSetsCounts()))
        e.tips:AddDoubleLine(e.onlyChinese and '菜单' or SLASH_TEXTTOSPEECH_MENU, e.Icon.left)
        e.tips:Show()
    end)
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
                    e.tips:SetOwner(self, "ANCHOR_RIGHT")--,8,-300)
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
            btn.limited:SetAtlas(e.Icon.clock)
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


        local tipsText= (displayData.name or btn.Name:GetText())..(displayData.label and displayData.name~= displayData.label and '|n'..displayData.label or '')
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
                    name= e.strText[name] or name
                    name= numAll==collect and '|cnGREEN_FONT_COLOR:'..name..'|r' or name--已收集

                    local isCollected= collect== numAll--是否已收

                    local tip= (collect==0 and '|cff606060'..collect..'|r' or collect)
                                ..'/'..numAll--收集数量
                                ..' '..meno..(not isCollected and ' ' or '')
                                ..name--名称
                                ..(info.limitedTimeSet and e.Icon.clock2 or '')--限时套装
                                ..' '..info.setID
                                --..(info.setID==btn.setID and ' '..e.Icon.toLeft2 or '')
                    tipsText= tipsText..'|n'..(isCollected and '|cnGREEN_FONT_COLOR:'..tip..'|r' or tip)
                end
                patch= patch or (info.patchID and info.patchID>0 and 'v'..(info.patchID/10000))
                version= version or (info.expansionID and _G['EXPANSION_NAME'..info.expansionID])
                version= e.strText[version] or version
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

    --套装, 幻化, 界面
    Init_Wardrober_Sets()

    --幻化，套装，索引
    hooksecurefunc(WardrobeCollectionFrame.SetsTransmogFrame, 'UpdateSets', set_Sets_Tooltips)

    --套装,物品, Link
    hooksecurefunc(WardrobeCollectionFrame.SetsCollectionFrame, 'SetItemFrameQuality', Init_Wardrobe_DetailsFrame)

    --套装，列表
    Init_Wardrober_ListContainer()

    --设置，目标为模型
    Init_Wardrober_Transmog()
end






























--#####
--传家宝, 按钮，提示
--Blizzard_HeirloomCollection.lua
local function Init_Heirloom()
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
                button.upLevel:SetAtlas(e.Icon.number..level)
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
        btn:SetScript('OnClick', function(self)
            HeirloomsJournal:SetClassAndSpecFilters(self.classID, self.specID)
        end)
        btn:SetScript('OnLeave', Gametooltip_Hide)
        btn:SetScript('OnEnter', function(self)
            if UnitAffectingCombat('player') then
                e.tips:SetOwner(self, "ANCHOR_LEFT")
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























--###
--玩具
--[[###
local function Init_ToyBox()
    local function ToyFun(self)
        if Save.hideToyBox then
            self:SetAlpha(1)
            return
        end
        local isUas=C_ToyBox.IsToyUsable(self.itemID)
        local _, duration, enable = C_Container.GetItemCooldown(self.itemID)
        if not isUas then
            self:SetAlpha(0.5)
        elseif enable==1 and duration>0 then
            self:SetAlpha(0.4)
            self.name:SetTextColor(1,0,0)
        else
            self:SetAlpha(1)
        end
    end

    hooksecurefunc('ToySpellButton_OnClick', ToyFun)--Blizzard_ToyBox.lua
    hooksecurefunc('ToySpellButton_UpdateButton', ToyFun)

    local toyframe=ToyBox
    toyframe.sel=e.Cbtn(toyframe, {icon=not Save.hideToyBox, size={18,18}})
    toyframe.sel:SetPoint('BOTTOMRIGHT',-25, 35)
    toyframe.sel:SetAlpha(0.5)
    toyframe.sel:SetScript('OnMouseDown',function (self2)
        Save.hideToyBox= not Save.hideToyBox and true or nil
        print(id, e.cn(addName), e.GetEnabeleDisable(not Save.hideToyBox), e.onlyChinese and '需求刷新' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, NEED, REFRESH))
        self2:SetNormalAtlas(Save.hideToyBox and e.Icon.disabled or e.Icon.icon)
    end)
    toyframe.sel:SetScript('OnEnter', function (self2)
        e.tips:SetOwner(self2, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddDoubleLine(id, e.cn(addName))
        e.tips:AddDoubleLine(e.GetEnabeleDisable(not Save.hideToyBox), e.Icon.left)
        e.tips:Show()
    end)
    toyframe.sel:SetScript('OnLeave', function ()
        e.tips:Hide()
    end)
end]]



































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
    hooksecurefunc('PetJournal_UpdatePetList', function()
        local numPets, numOwned = C_PetJournal.GetNumPets()
	    PetJournal.PetCount.Count:SetText(numOwned..'/'..numPets)
    end)
end
























local function Init()
    --试衣间, 外观列表
    --DressUpFrames.lua
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
                --[[if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
                    C_AddOns.LoadAddOn('Blizzard_Collections')
                end]]
                CollectionsJournal_LoadUI()
                local wcFrame= WardrobeCollectionFrame
                if not CollectionsJournal:IsVisible() or not wcFrame:IsVisible() then
                    ToggleCollectionsJournal(5)
                end
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










local panel=CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:RegisterEvent('TRANSMOGRIFY_ITEM_UPDATE')
panel:RegisterEvent('TRANSMOG_SETS_UPDATE_FAVORITE')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1==id then
            Save= WoWToolsSave[addName] or Save
            wowSaveSets= WoWToolsSave['WoW-CollectionWardrobeSets'] or wowSaveSets
            wowSaveItems= WoWToolsSave['WoW-CollectionWardrobeItems'] or wowSaveItems

            --添加控制面板
            e.AddPanel_Check({
                name= '|A:UI-HUD-MicroMenu-Collections-Mouseover:0:0|a'..(e.onlyChinese and '收藏' or addName),
                tooltip= e.cn(addName),
                value= not Save.disabled,
                func= function()
                    Save.disabled= not Save.disabled and true or nil
                    print(id, e.cn(addName), e.GetEnabeleDisable(not Save.disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            C_Timer.After(2, function()
                Save_Items_Date()--物品, 幻化, 界面
                Save_Sets_Colleced()--保存，套装，数据
            end)

            if Save.disabled then
                self:UnregisterAllEvents()
            else
                --[[if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
                    C_AddOns.LoadAddOn('Blizzard_Collections')
                end]]
                CollectionsJournal_LoadUI()
                Init()--试衣间, 外观列表
            end
            self:RegisterEvent("PLAYER_LOGOUT")

        elseif arg1=='Blizzard_Collections' then
            Init_SetsDataProvider()
            --Init_ToyBox()--玩具
            Init_Heirloom()--传家宝
            Init_Wardrober()--幻化
            Init_Mount()--坐骑, 界面
            Init_Pet()
        end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave[addName]=Save
            WoWToolsSave['WoW-CollectionWardrobeSets']= wowSaveSets
            WoWToolsSave['WoW-CollectionWardrobeItems']= wowSaveItems
        end

    elseif event=='TRANSMOGRIFY_ITEM_UPDATE' then
        C_Timer.After(2, Save_Items_Date)--保存，物品，数据

    elseif event=='TRANSMOG_SETS_UPDATE_FAVORITE' then
        Init_SetsDataProvider()
        C_Timer.After(2, Save_Sets_Colleced)--保存，套装，数据
    end
end)
